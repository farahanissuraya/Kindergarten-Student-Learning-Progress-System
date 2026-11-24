<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.util.List"%>

<%
    Student student = (Student) request.getAttribute("student");
    String reportDate = (String) request.getAttribute("reportDate");
    List<LearningProgress> records = (List<LearningProgress>) request.getAttribute("records");
    Integer avgObj = (Integer) request.getAttribute("avgPercentage");
    int avgPercentage = (avgObj != null) ? avgObj : 0;
    boolean isLatest = Boolean.TRUE.equals(request.getAttribute("isLatest"));
    boolean isParent = Boolean.TRUE.equals(request.getAttribute("isParent"));
    boolean isAdmin  = Boolean.TRUE.equals(request.getAttribute("isAdmin"));

    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/learningProgress");
        return;
    }

    int studentAge = student.getStudentAge();
    int targetScale = (studentAge >= 6) ? 5 : (studentAge == 5 ? 4 : 3);

    boolean hasAlert = false;
    String sharedHomeRec = "";
    if (records != null) {
        for (LearningProgress r : records) {
            if (r.getRatingScale() < targetScale) {
                hasAlert = true;
            }
            if (sharedHomeRec.isEmpty() && r.getHomeRecommendation() != null && !r.getHomeRecommendation().trim().isEmpty()) {
                sharedHomeRec = r.getHomeRecommendation().trim();
            }
        }
    }

    if (sharedHomeRec.isEmpty()) {
        sharedHomeRec = "Ibu bapa digalakkan meluangkan masa 10–15 minit setiap hari untuk membaca buku cerita bergambar bersama anak, melatih genggaman pensel melalui aktiviti melukis bebas, dan mengira objek harian di rumah secara santai.";
    }

    // Format tarikh ke Bahasa Melayu (contoh: 23 November 2026)
    String formattedDateMalay = (reportDate != null) ? reportDate : "Tanpa Tarikh";
    if (reportDate != null && reportDate.contains("-")) {
        String[] parts = reportDate.split("-");
        if (parts.length == 3) {
            String[] months = {"Januari", "Februari", "Mac", "April", "Mei", "Jun",
                               "Julai", "Ogos", "September", "Oktober", "November", "Disember"};
            try {
                int m = Integer.parseInt(parts[1]);
                int d = Integer.parseInt(parts[2]);
                if (m >= 1 && m <= 12) {
                    formattedDateMalay = d + " " + months[m - 1] + " " + parts[0];
                }
            } catch (Exception ignored) {}
        }
    }

    String assessorDisplay = "Ms. Clara Davis";
    if (records != null && !records.isEmpty() && records.get(0).getAssessorName() != null && !records.get(0).getAssessorName().trim().isEmpty()) {
        assessorDisplay = records.get(0).getAssessorName();
    } else if (session.getAttribute("userName") != null && !isParent) {
        assessorDisplay = session.getAttribute("userName").toString();
    }
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporan Penuh Pentaksiran - <%= student.getStudentName() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <style>
        /* ==========================================================================
           1. LAYOUT ASAS & NEOBRUTALISM THEME
           ========================================================================== */
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body, html {
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #FFFDF7;
            color: #2D3436;
        }

        .app-layout {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background: #FFFFFF;
            border-right: 3px solid #2D3436;
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            background-color: #FFFDF7;
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background: #FFFFFF;
            border-bottom: 3px solid #2D3436;
        }

        .app-content-body {
            flex-grow: 1;
            padding: 28px 36px;
            overflow-y: auto;
        }

        .rd-container {
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 22px;
        }

        /* ==========================================================================
           2. TOP BAR & BUTTONS (GAYA PILL BUTTON BERBAYANG)
           ========================================================================== */
        .rd-topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .rd-breadcrumb {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.82rem;
            font-weight: 800;
            color: #64748B;
        }

        .nb-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 20px;
            background-color: #FFFFFF;
            color: #2D3436;
            border: 2.5px solid #2D3436;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 900;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0px 4px 0px 0px #2D3436;
            transition: all 0.12s ease;
        }
        .nb-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0px 5px 0px 0px #2D3436;
        }
        .nb-btn:active {
            transform: translateY(2px);
            box-shadow: 0px 2px 0px 0px #2D3436;
        }

        .nb-btn-yellow {
            background-color: #FFD166;
            color: #2D3436;
        }

        /* ==========================================================================
           3. MAIN BANNER CARD
           ========================================================================== */
        .nb-card {
            background-color: #FFFFFF;
            border: 2.5px solid #2D3436;
            border-radius: 26px;
            padding: 24px 28px;
            box-shadow: 0px 5px 0px 0px #2D3436;
        }

        .rd-banner-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 18px;
        }

        .nb-pill-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: 2px solid #2D3436;
        }
        .badge-emerald {
            background-color: #10B981;
            color: #2D3436;
        }
        .badge-amber {
            background-color: #FFD166;
            color: #2D3436;
        }

        .badge-date {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 800;
            background-color: #F8FAFC;
            border: 1.5px solid #CBD5E1;
            color: #334155;
        }

        /* KOTAK KUNING PURATA KESELURUHAN */
        .rd-avg-box {
            background-color: #FFD166;
            border: 2.5px solid #2D3436;
            border-radius: 20px;
            padding: 14px 24px;
            text-align: center;
            min-width: 175px;
            box-shadow: 3px 3px 0px 0px #2D3436;
        }

        .rd-alert-box {
            margin-top: 18px;
            border-radius: 16px;
            padding: 12px 16px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 0.8rem;
            line-height: 1.45;
        }
        .rd-alert-warn {
            background-color: #FFFBEB;
            border: 2px solid #F59E0B;
            color: #92400E;
        }
        .rd-alert-ok {
            background-color: #ECFDF5;
            border: 2px solid #10B981;
            color: #065F46;
        }

        /* ==========================================================================
           4. 3 DOMAIN CARDS GRID (COUNTING / WRITING / READING)
           ========================================================================== */
        .rd-domain-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            align-items: stretch;
        }
        @media (max-width: 1024px) { .rd-domain-grid { grid-template-columns: 1fr; } }

        .rd-domain-card {
            background-color: #FFFFFF;
            border: 2.5px solid #2D3436;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 4px 4px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
        }

        .rd-domain-header {
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #FFFFFF;
            border-bottom: 2.5px solid #2D3436;
        }
        .hdr-counting { background-color: #F99B35; } /* Oren */
        .hdr-writing  { background-color: #F26463; } /* Coral / Merah Jambu */
        .hdr-reading  { background-color: #6B5CE7; } /* Ungu / Indigo */

        .rd-icon-box {
            width: 38px;
            height: 38px;
            border-radius: 12px;
            background-color: rgba(255, 255, 255, 0.22);
            border: 1.5px solid rgba(255, 255, 255, 0.55);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            flex-shrink: 0;
        }

        .rd-domain-body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 16px;
            flex-grow: 1;
        }

        /* Kotak Skala Kemahiran 1 - 5 */
        .rd-scale-box {
            background-color: #F8FAFC;
            border: 1.5px solid #E2E8F0;
            border-radius: 16px;
            padding: 14px;
        }
        .rd-scale-bars {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 6px;
            margin: 10px 0 8px 0;
        }
        .rd-bar {
            height: 8px;
            border-radius: 999px;
            background-color: #CBD5E1;
        }
        .bar-counting { background-color: #F99B35; }
        .bar-writing  { background-color: #F26463; }
        .bar-reading  { background-color: #6B5CE7; }

        /* Cip Status Sasaran Umur */
        .rd-status-chip {
            border-radius: 14px;
            padding: 10px 14px;
            display: flex;
            align-items: flex-start;
            gap: 8px;
            font-size: 0.74rem;
            line-height: 1.4;
        }
        .chip-ok {
            background-color: #ECFDF5;
            border: 1.5px solid #6EE7B7;
            color: #065F46;
        }
        .chip-warn {
            background-color: #FFF1F2;
            border: 1.5px solid #FDA4AF;
            color: #9F1239;
        }

        /* Kotak Catatan Guru */
        .rd-notes-box {
            background-color: #F8FAFC;
            border: 1.5px solid #E2E8F0;
            border-radius: 14px;
            padding: 12px 14px;
            font-size: 0.8rem;
            font-style: italic;
            font-weight: 700;
            color: #334155;
            line-height: 1.45;
        }

        /* ==========================================================================
           5. KAD CADANGAN PENGUKUHAN DI RUMAH (BERASINGAN DI BAWAH)
           ========================================================================== */
        .rd-recommendation-card {
            background-color: #FFFBEB;
            border: 2.5px solid #2D3436;
            border-radius: 24px;
            padding: 22px 26px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            display: flex;
            align-items: flex-start;
            gap: 16px;
        }
        .rd-rec-icon {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            background-color: #FFD166;
            border: 2px solid #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2D3436;
            flex-shrink: 0;
            box-shadow: 2px 2px 0px 0px #2D3436;
        }
        .rd-rec-content-box {
            margin-top: 10px;
            background-color: #FFFFFF;
            border: 2px solid #2D3436;
            border-radius: 16px;
            padding: 14px 18px;
            font-size: 0.88rem;
            font-weight: 700;
            color: #2D3436;
            line-height: 1.55;
        }

        @media print {
            .app-sidebar-wrapper, .app-header-wrapper, .no-print { display: none !important; }
            .app-content-body { padding: 0; }
            .nb-card, .rd-domain-card, .rd-recommendation-card { box-shadow: none; }
        }
    </style>
</head>
<body>

<div class="app-layout">
    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <main class="app-main-wrapper">
        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <div class="app-content-body">
            <div class="rd-container">

                <!-- TOP ACTION BAR -->
                <div class="rd-topbar no-print">
                    <div style="display: flex; align-items: center; gap: 14px; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/ProgressServlet?studentId=<%= student.getStudentID() %>" class="nb-btn">
                            <%= IconUtil.icon("ArrowLeft", "icon-xs") %>
                            <span>Kembali ke Senarai Laporan</span>
                        </a>
                    </div>

					<div style="display: flex; align-items: center; gap: 10px;">
                        <% if (isAdmin) { %>
                            <button type="button" onclick="window.print()" class="nb-btn">
                                <%= IconUtil.icon("Printer", "icon-xs") %>
                                <span>Cetak / PDF</span>
                            </button>
                        <% } %>
                    </div>
                </div>

                <!-- MAIN BANNER: STUDENT & REPORT METADATA -->
                <div class="nb-card">
                    <div class="rd-banner-top">
                        <div>
                            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 10px;">
                                <% if (isLatest) { %>
                                    <span class="nb-pill-badge badge-emerald">
                                        <%= IconUtil.icon("Star", "icon-xs") %> Rekod Semasa (Current Record)
                                    </span>
                                <% } else { %>
                                    <span class="nb-pill-badge badge-amber">
                                        <%= IconUtil.icon("Clock", "icon-xs") %> Rekod Terdahulu (Previous Record)
                                    </span>
                                <% } %>
                                <span class="badge-date">
                                    <%= IconUtil.icon("Calendar", "icon-xs") %>
                                    <span><%= reportDate != null ? reportDate : "-" %> · <%= formattedDateMalay %></span>
                                </span>
                            </div>

                            <h2 style="font-size: 1.75rem; font-weight: 900; letter-spacing: -0.5px; margin-bottom: 8px;">
                                Laporan Penuh Pentaksiran Bersepadu 3 Teras KSPK
                            </h2>

                            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; font-size: 0.85rem; font-weight: 700; color: #475569;">
                                <span style="color: #2D3436;"><strong>Murid:</strong> <%= student.getStudentName() %></span>
                                <span>·</span>
                                <span><strong>Umur:</strong> <%= studentAge %> Tahun</span>
                                <span>·</span>
                                <span><strong>Kelas:</strong> <%= student.getStudentClass() %></span>
                                <span>·</span>
                                <span><strong>Penilai:</strong> <%= assessorDisplay %></span>
                            </div>
                        </div>

                        <!-- PURATA KESELURUHAN -->
                        <div class="rd-avg-box">
                            <span style="font-size: 10px; font-weight: 900; text-transform: uppercase; letter-spacing: 0.04em; display: block;">
                                Purata Keseluruhan
                            </span>
                            <span style="font-size: 2.1rem; font-weight: 900; display: block; margin: 2px 0;">
                                <%= avgPercentage %>%
                            </span>
                            <span style="font-size: 11px; font-weight: 800; display: block;">
                                <%= avgPercentage >= 85 ? "Tahap Cemerlang" : (avgPercentage >= 70 ? "Tahap Penguasaan Baik" : "Tahap Bimbingan") %>
                            </span>
                        </div>
                    </div>

                    <!-- AGE BENCHMARK ALERT BANNER -->
                    <% if (studentAge >= 6 && hasAlert) { %>
                        <div class="rd-alert-box rd-alert-warn">
                            <span style="flex-shrink: 0; margin-top: 2px;"><%= IconUtil.icon("AlertTriangle", "icon-sm") %></span>
                            <div>
                                <strong style="font-weight: 900; display: block;">
                                    Status Sasaran Perkembangan KSPK (Umur 6 Tahun - Sasaran: Skala 5/5):
                                </strong>
                                <span>
                                    Bagi murid berumur 6 tahun, sasaran kompetensi penuh KSPK adalah Skala 5/5 bagi persediaan ke Tahun 1. Terdapat domain dalam laporan ini yang masih memerlukan pengukuhan.
                                </span>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- 3 DEDICATED NEOBRUTALISM CONTAINERS FOR THE 3 CORE DOMAINS -->
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="font-size: 1.25rem; font-weight: 900; display: flex; align-items: center; gap: 8px;">
                            <%= IconUtil.icon("Sparkles", "icon-sm") %>
                            <span>Perincian 3 Domain Teras Pembelajaran (KSPK)</span>
                        </h3>
                        <span style="font-size: 12px; font-weight: 800; color: #475569; background: #FFFFFF; border: 2px solid #2D3436; padding: 4px 14px; border-radius: 999px;">
                            <%= (records != null) ? records.size() : 0 %> Teras Dinilai
                        </span>
                    </div>

                    <% if (records == null || records.isEmpty()) { %>
                        <div class="nb-card" style="text-align: center; color: #64748B; font-weight: 700;">
                            Tiada rekod pentaksiran ditemui bagi tarikh ini.
                        </div>
                    <% } else { %>
                        <div class="rd-domain-grid">
                            <% for (LearningProgress rec : records) {
                                String dom = (rec.getDomainName() != null && !rec.getDomainName().trim().isEmpty())
                                        ? rec.getDomainName().trim() : "Reading";
                                boolean isReading = "Reading".equalsIgnoreCase(dom);
                                boolean isWriting = "Writing".equalsIgnoreCase(dom);

                                String hdrClass = isReading ? "hdr-reading" : (isWriting ? "hdr-writing" : "hdr-counting");
                                String barClass = isReading ? "bar-reading" : (isWriting ? "bar-writing" : "bar-counting");
                                String iconName = isReading ? "BookOpen" : (isWriting ? "PenTool" : "Hash");

                                int pctDisplay = (int) Math.round(rec.getProgressPercentage());
                                int scaleVal = rec.getRatingScale();
                                boolean isBelowTarget = (scaleVal < targetScale);

                                String scaleLabel =
                                    (scaleVal == 5) ? "Tahap 5 - Mahir Sepenuhnya (Mastered)" :
                                    (scaleVal == 4) ? "Tahap 4 - Cekap & Konsisten (Proficient)" :
                                    (scaleVal == 3) ? "Tahap 3 - Sedang Berkembang (Developing)" :
                                    (scaleVal == 2) ? "Tahap 2 - Pengenalan Asas (Emerging)" :
                                                      "Tahap 1 - Memerlukan Bimbingan";
                            %>
                                <div class="rd-domain-card">
                                    <!-- Card Header -->
                                    <div class="rd-domain-header <%= hdrClass %>">
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <div class="rd-icon-box">
                                                <%= IconUtil.icon(iconName, "icon-sm") %>
                                            </div>
                                            <div>
                                                <h4 style="font-size: 1.05rem; font-weight: 900;"><%= dom %></h4>
                                                <span style="font-size: 11px; font-weight: 700; opacity: 0.92;">
                                                    Teras KSPK · ID: <%= rec.getProgressID() %>
                                                </span>
                                            </div>
                                        </div>
                                        <div style="text-align: right;">
                                            <span style="font-size: 1.2rem; font-weight: 900; display: block;"><%= pctDisplay %>%</span>
                                            <span style="font-size: 10px; font-weight: 800; text-transform: uppercase;"><%= rec.getProgressStatus() %></span>
                                        </div>
                                    </div>

                                    <!-- Card Body -->
                                    <div class="rd-domain-body">
                                        <div>
                                            <span style="font-size: 10px; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 4px;">
                                                Topik &amp; Standard Pembelajaran:
                                            </span>
                                            <h5 style="font-size: 0.96rem; font-weight: 900; line-height: 1.4;">
                                                <%= rec.getProgressName() %>
                                            </h5>
                                        </div>

                                        <!-- Rating Scale Indicator (1 - 5) -->
                                        <div class="rd-scale-box">
                                            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; font-weight: 800;">
                                                <span>Penarafan Skala Kemahiran:</span>
                                                <span style="background: #FFFFFF; border: 1.5px solid #2D3436; padding: 2px 10px; border-radius: 8px; font-weight: 900;">
                                                    Skala <%= scaleVal %> / 5
                                                </span>
                                            </div>

                                            <div class="rd-scale-bars">
                                                <% for (int lvl = 1; lvl <= 5; lvl++) { %>
                                                    <div class="rd-bar <%= (lvl <= scaleVal) ? barClass : "" %>"></div>
                                                <% } %>
                                            </div>

                                            <div style="font-size: 11px; font-weight: 700; color: #475569;">
                                                <%= scaleLabel %>
                                            </div>
                                        </div>

                                        <!-- Age Benchmark Status -->
                                        <% if (isBelowTarget) { %>
                                            <div class="rd-status-chip chip-warn">
                                                <span style="flex-shrink: 0; margin-top: 1px;"><%= IconUtil.icon("AlertTriangle", "icon-xs") %></span>
                                                <div>
                                                    <strong style="font-weight: 900; display: block;">Perlu Pengukuhan Umur <%= studentAge %> Tahun</strong>
                                                    <span>Sasaran standard: Skala <%= targetScale %>/5. Latihan berterusan disyorkan.</span>
                                                </div>
                                            </div>
                                        <% } else { %>
                                            <div class="rd-status-chip chip-ok">
                                                <span style="flex-shrink: 0; margin-top: 1px;"><%= IconUtil.icon("CheckCircle", "icon-xs") %></span>
                                                <div>
                                                    <strong style="font-weight: 900; display: block;">Mencapai Sasaran Umur <%= studentAge %> Tahun</strong>
                                                    <span>Menguasai kemahiran mengikut piawaian tanda aras umur.</span>
                                                </div>
                                            </div>
                                        <% } %>

                                        <!-- Catatan Guru Penilai -->
                                        <div>
                                            <span style="font-size: 11px; font-weight: 900; text-transform: uppercase; color: #64748B; display: flex; align-items: center; gap: 5px; margin-bottom: 6px;">
                                                <%= IconUtil.icon("MessageSquare", "icon-xs") %>
                                                <span>Catatan Guru Penilai:</span>
                                            </span>
                                            <div class="rd-notes-box">
                                                "<%= (rec.getNotes() != null && !rec.getNotes().trim().isEmpty())
                                                        ? rec.getNotes()
                                                        : "Skala Penilaian: " + scaleVal + "/5 (" + rec.getProgressStatus() + "). Sasaran umur tercapai." %>"
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <!-- ==========================================================================
                             KAD BERASINGAN: CADANGAN PENGUKUHAN DI RUMAH (MEWAKILI SEMUA TERAS)
                             ========================================================================== -->
                        <div class="rd-recommendation-card" style="margin-top: 22px;">
                            <div class="rd-rec-icon">
                                <%= IconUtil.icon("Lightbulb", "icon-sm") %>
                            </div>
                            <div style="flex-grow: 1;">
                                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                    <div>
                                        <h4 style="font-size: 1.05rem; font-weight: 900; color: #2D3436;">
                                            Cadangan Pengukuhan &amp; Perkongsian Aktiviti di Rumah
                                        </h4>
                                    </div>
                                </div>
                                <div class="rd-rec-content-box">
                                    <%= sharedHomeRec %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
    </main>
</div>

<jsp:include page="icons.jsp" />
</body>
</html>