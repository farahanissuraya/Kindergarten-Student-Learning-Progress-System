<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Progress Manager - Keedsflix Centre</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    
    <style>
        /* ==========================================
           NEOBRUTALISM THEME & LAYOUT STYLING
           ========================================== */
        * { box-sizing: border-box; }
        body, html {
            margin: 0; padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #FAF5EF;
            color: #2D3436;
        }

        .app-layout { display: flex; min-height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; background: #FAF5EF; }
        .app-header-wrapper { flex-shrink: 0; background: #FFFFFF; border-bottom: 3px solid #2D3436; }
        .app-content-body { flex-grow: 1; padding: 28px 36px; overflow-y: auto; }

        .nb-container { max-width: 1150px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        
        /* CARD STYLING */
        .nb-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 28px;
            padding: 24px 28px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            transition: all 0.2s ease;
        }

        /* SELECT DROPDOWNS */
        .nb-label {
            display: block;
            font-weight: 900;
            font-size: 0.95rem;
            color: #2D3436;
            margin-bottom: 8px;
        }
        .nb-select {
            width: 100%;
            padding: 12px 20px;
            border: 2.5px solid #2D3436;
            border-radius: 999px;
            background-color: #FFFFFF;
            font-weight: 800;
            font-size: 0.95rem;
            color: #2D3436;
            box-shadow: 2px 2px 0px 0px #2D3436;
            cursor: pointer;
            outline: none;
            appearance: none;
            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%232D3436' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 20px center;
        }

        /* BUTTONS */
        .nb-btn {
            background-color: #FFFFFF;
            border: 2px solid #2D3436;
            border-radius: 999px;
            padding: 9px 20px;
            font-weight: 900;
            font-size: 0.85rem;
            color: #2D3436;
            cursor: pointer;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            transition: all 0.15s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        .nb-btn:hover { transform: translateY(-2px); background-color: #F8FAFC; }
        .nb-btn-yellow { background-color: #FFD02C; }
        .nb-btn-yellow:hover { background-color: #FFE066; }
        .nb-btn-mint { background-color: #34D399; }
        .nb-btn-mint:hover { background-color: #6EE7B7; }
        .nb-btn-danger { background-color: #FFFFFF; color: #EF4444; border-color: #2D3436; }
        .nb-btn-danger:hover { background-color: #FEF2F2; color: #DC2626; }

        /* BADGES & TAGS */
        .nb-badge-yellow {
            background: #FFD02C; border: 1.5px solid #2D3436;
            padding: 3px 10px; border-radius: 999px;
            font-size: 10px; font-weight: 900; text-transform: uppercase; letter-spacing: 0.5px;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .nb-badge-mint {
            background: #D1FAE5; color: #065F46; border: 1.5px solid #10B981;
            padding: 3px 12px; border-radius: 999px; font-size: 11px; font-weight: 900;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .nb-badge-gray {
            background: #F1F5F9; color: #475569; border: 1.5px solid #94A3B8;
            padding: 3px 12px; border-radius: 999px; font-size: 11px; font-weight: 900;
            display: inline-flex; align-items: center; gap: 4px;
        }

        .domain-pill {
            font-size: 11px; font-weight: 900; padding: 4px 10px; border-radius: 8px;
            display: inline-flex; align-items: center; gap: 5px;
        }

        /* TABLE STYLING */
        .nb-table-card {
            border: 2.5px solid #2D3436; border-radius: 20px; overflow: hidden;
            box-shadow: 3px 3px 0px 0px #2D3436; background: #FFFFFF;
        }
        .nb-table { width: 100%; border-collapse: collapse; text-align: left; }
        .nb-table th {
            background-color: #2D3436; color: #FFFFFF; padding: 14px 18px;
            font-weight: 900; font-size: 0.85rem; border-right: 1px solid #4B5563;
        }
        .nb-table td { padding: 16px 18px; border-bottom: 2px solid #E2E8F0; border-right: 1.5px solid #E2E8F0; }
        
        /* SECTION BANNERS IN TABLE */
        .table-section-banner {
            background-color: #D1FAE5; border-top: 2px solid #2D3436; border-bottom: 2px solid #2D3436;
            padding: 10px 18px; font-weight: 900; font-size: 0.82rem; color: #065F46;
            display: flex; justify-content: space-between; align-items: center;
        }
        .table-section-banner-gray {
            background-color: #F1F5F9; color: #334155;
        }

        /* MODAL STYLING */
        .nb-modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.65); display: none; align-items: center; justify-content: center; z-index: 9999;
        }
        .nb-modal-overlay.active { display: flex; }
        .nb-modal {
            background: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px;
            padding: 28px; width: 100%; max-width: 520px; box-shadow: 6px 6px 0px 0px #2D3436;
        }
        .nb-input {
            width: 100%; padding: 10px 14px; border: 2px solid #2D3436;
            border-radius: 12px; margin-top: 4px; margin-bottom: 14px; box-sizing: border-box; font-weight: 700;
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
            <div class="nb-container">

                <!-- =========================================================
                     CARD 1: CLASS & STUDENT NAME SELECTORS
                     ========================================================= -->
                <div class="nb-card">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px;">
                        <div>
                            <label class="nb-label">Class</label>
                            <select class="nb-select" disabled>
                                <option>${student.studentClass != null ? student.studentClass : 'Kindergarten 3B'}</option>
                            </select>
                        </div>
                        <div>
                            <label class="nb-label">Student Name</label>
                            <select class="nb-select" onchange="location.href='${pageContext.request.contextPath}/learningProgress?studentId=' + this.value">
                                <c:forEach var="s" items="${classStudents}">
                                    <option value="${s.studentID}" ${s.studentID == student.studentID ? 'selected' : ''}>
                                        ${s.studentName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- =========================================================
                     CARD 2: TEACHER ASSESSMENT CONSOLE HEADER
                     ========================================================= -->
                <div class="nb-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                            <span class="nb-badge-yellow">TEACHER ASSESSMENT CONSOLE</span>
                            <span style="font-size: 0.8rem; font-weight: 700; color: #64748B;">
                                Class: ${student.studentClass != null ? student.studentClass : 'Kindergarten 3B'} · Student ID: #${student.studentID}
                            </span>
                        </div>
                        <h2 style="margin: 0; font-size: 1.8rem; font-weight: 900; letter-spacing: -0.5px;">
                            Learning Progress: ${student.studentName}
                        </h2>
                        <p style="margin: 6px 0 0 0; color: #64748B; font-size: 0.88rem; font-weight: 600; max-width: 650px;">
                            Evaluate reading, writing, and early counting milestones in real time. Log observations, calibrate domain benchmarks, and generate progress reports.
                        </p>
                    </div>
                </div>

                <!-- =========================================================
                     CARD 4: PROGRESS REPORT TABLE
                     ========================================================= -->
                <div class="nb-card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; flex-wrap: wrap; gap: 12px;">
                        <div>
                            <h3 style="margin: 0; font-size: 1.4rem; font-weight: 900;">Progress Report</h3>
                            <p style="margin: 2px 0 0 0; color: #64748B; font-size: 0.82rem; font-weight: 600;">
                                Viewing record(s) (6)
                            </p>
                        </div>

                        <div style="display: flex; align-items: center; gap: 16px; font-size: 0.85rem; font-weight: 800;">
                            <div>
                                Year: 
                                <select style="padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436; font-weight: 800; cursor: pointer;">
                                    <option>2026</option>
                                    <option>2025</option>
                                </select>
                            </div>
                            <div>
                                Filter by: 
                                <select style="padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436; font-weight: 800; cursor: pointer;">
                                    <option>All</option>
                                    <option>Reading</option>
                                    <option>Writing</option>
                                    <option>Counting</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- TABLE CONTAINER -->
                    <div class="nb-table-card">
                        
                        <!-- SECTION 1 HEADER: CURRENT RECORD -->
                        <div class="table-section-banner">
                            <span style="display: inline-flex; align-items: center; gap: 6px;">
                                <%= IconUtil.icon("Sparkles", "icon-sm") %> REKOD TERKINI (CURRENT RECORD)
                            </span>
                            <span class="nb-badge-mint" style="font-size: 10px;">Tarikh Aktif: 2026-10-31</span>
                        </div>

                        <table class="nb-table">
                            <thead>
                                <tr>
                                    <th style="width: 20%;">Date</th>
                                    <th style="width: 62%;">Content</th>
                                    <th style="width: 18%; text-align: center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- ROW 1: CURRENT RECORD (2026-10-31) -->
                                <tr>
                                    <td style="vertical-align: top; text-align: center;">
                                        <div style="font-weight: 900; font-size: 1rem; color: #2D3436;">2026-10-31</div>
                                        <div style="font-size: 0.78rem; font-weight: 700; color: #64748B; margin-top: 2px;">31 Oktober 2026</div>
                                        <div style="margin-top: 8px;">
                                            <span class="nb-badge-mint" style="font-size: 9px; padding: 2px 8px;">
                                                <%= IconUtil.icon("Star", "icon-xs") %> CURRENT RECORD
                                            </span>
                                        </div>
                                    </td>
                                    <td style="vertical-align: top;">
                                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 8px;">
                                            <span class="domain-pill" style="background: #FEF3C7; color: #92400E; border: 1px solid #FCD34D;">
                                                <%= IconUtil.icon("BarChart3", "icon-xs") %> Counting (Skala 4/5 · 88%)
                                            </span>
                                            <span class="domain-pill" style="background: #FFE4E6; color: #BE185D; border: 1px solid #FDA4AF;">
                                                <%= IconUtil.icon("PenTool", "icon-xs") %> Writing (Skala 3/5 · 68%)
                                            </span>
                                            <span class="domain-pill" style="background: #F3E8FF; color: #7E22CE; border: 1px solid #D8B4FE;">
                                                <%= IconUtil.icon("BookOpen", "icon-xs") %> Reading (Skala 3/5 · 68%)
                                            </span>
                                            <span style="background: #2D3436; color: #FFF; font-size: 11px; font-weight: 900; padding: 4px 10px; border-radius: 999px;">
                                                Purata Skor: 67%
                                            </span>
                                        </div>

                                        <p style="margin: 6px 0; font-size: 0.83rem; color: #1E293B; font-weight: 700;">
                                            <strong>Fokus & Topik:</strong> Pengecaman Nombor & Pembilangan Objek (1-30) · Kawalan Motor Halus & Genggaman Pensel (Tripod Grip) · Penguasaan Fonik & Pengecaman Bunyi Huruf (Phonics)
                                        </p>

                                        <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px; padding: 8px 12px; margin-top: 8px; font-size: 0.8rem; color: #475569; font-style: italic; font-weight: 600;">
                                            "Skala Penilaian: 4/5 (Proficient). Sasaran umur tercapai."
                                        </div>

                                        <div style="margin-top: 10px;">
                                            <a href="#" style="color: #6366F1; font-weight: 900; font-size: 0.8rem; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                                <%= IconUtil.icon("Eye", "icon-xs") %>
                                                <span>Tekan untuk buka laporan penuh di halaman baharu</span>
                                                <%= IconUtil.icon("ArrowRight", "icon-xs") %>
                                            </a>
                                        </div>
                                    </td>
                                    <td style="vertical-align: top; text-align: center;">
                                        <div style="display: flex; flex-direction: column; gap: 8px;">
                                            <button type="button" class="nb-btn nb-btn-yellow" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Eye", "icon-xs") %> Buka Laporan
                                            </button>
                                            <button type="button" class="nb-btn" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Edit2", "icon-xs") %> Edit
                                            </button>
                                            <button type="button" class="nb-btn nb-btn-danger" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Trash2", "icon-xs") %> Padam
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                        <!-- SECTION 2 HEADER: PREVIOUS RECORDS -->
                        <div class="table-section-banner table-section-banner-gray">
                            <span style="display: inline-flex; align-items: center; gap: 6px;">
                                <%= IconUtil.icon("Clock", "icon-sm") %> REKOD-REKOD TERDAHULU (PREVIOUS RECORDS)
                            </span>
                            <span class="nb-badge-gray" style="font-size: 10px;">1 Rekod Terdahulu</span>
                        </div>

                        <table class="nb-table">
                            <tbody>
                                <!-- ROW 2: PREVIOUS RECORD (2026-09-15) -->
                                <tr>
                                    <td style="width: 20%; vertical-align: top; text-align: center;">
                                        <div style="font-weight: 900; font-size: 1rem; color: #2D3436;">2026-09-15</div>
                                        <div style="font-size: 0.78rem; font-weight: 700; color: #64748B; margin-top: 2px;">15 September 2026</div>
                                        <div style="margin-top: 8px;">
                                            <span class="nb-badge-gray" style="font-size: 9px; padding: 2px 8px; background: #FEF3C7; color: #92400E; border-color: #FCD34D;">
                                                <%= IconUtil.icon("History", "icon-xs") %> PREVIOUS RECORD
                                            </span>
                                        </div>
                                    </td>
                                    <td style="width: 62%; vertical-align: top;">
                                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 8px;">
                                            <span class="domain-pill" style="background: #F3E8FF; color: #7E22CE; border: 1px solid #D8B4FE;">
                                                <%= IconUtil.icon("BookOpen", "icon-xs") %> Reading (Skala 5/5 · 82%)
                                            </span>
                                            <span class="domain-pill" style="background: #FFE4E6; color: #BE185D; border: 1px solid #FDA4AF;">
                                                <%= IconUtil.icon("PenTool", "icon-xs") %> Writing (Skala 5/5 · 78%)
                                            </span>
                                            <span class="domain-pill" style="background: #FEF3C7; color: #92400E; border: 1px solid #FCD34D;">
                                                <%= IconUtil.icon("BarChart3", "icon-xs") %> Counting (Skala 5/5 · 92%)
                                            </span>
                                            <span style="background: #2D3436; color: #FFF; font-size: 11px; font-weight: 900; padding: 4px 10px; border-radius: 999px;">
                                                Purata Skor: 81%
                                            </span>
                                        </div>

                                        <p style="margin: 6px 0; font-size: 0.83rem; color: #1E293B; font-weight: 700;">
                                            <strong>Fokus & Topik:</strong> CVC Phonics & Beginning Sounds Evaluation · Name Handwriting & Dynamic Tripod Grip · Manipulative Counting & Numeral Recognition 1-20
                                        </p>

                                        <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px; padding: 8px 12px; margin-top: 8px; font-size: 0.8rem; color: #475569; font-style: italic; font-weight: 600;">
                                            "Demonstrates confident recognition of short vowels."
                                        </div>

                                        <div style="margin-top: 10px;">
                                            <a href="#" style="color: #6366F1; font-weight: 900; font-size: 0.8rem; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                                <%= IconUtil.icon("Eye", "icon-xs") %>
                                                <span>Tekan untuk buka laporan penuh di halaman baharu</span>
                                                <%= IconUtil.icon("ArrowRight", "icon-xs") %>
                                            </a>
                                        </div>
                                    </td>
                                    <td style="width: 18%; vertical-align: top; text-align: center;">
                                        <div style="display: flex; flex-direction: column; gap: 8px;">
                                            <button type="button" class="nb-btn nb-btn-yellow" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Eye", "icon-xs") %> Buka Laporan
                                            </button>
                                            <button type="button" class="nb-btn" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Edit2", "icon-xs") %> Edit
                                            </button>
                                            <button type="button" class="nb-btn nb-btn-danger" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Trash2", "icon-xs") %> Padam
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- BUTTON AT BOTTOM RIGHT -->
                    <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                        <a href="${pageContext.request.contextPath}/createProgress.jsp?studentId=${student != null ? student.studentID : 1}" 
                           class="nb-btn nb-btn-yellow" 
                           style="padding: 10px 24px; font-size: 0.9rem;">
                            <%= IconUtil.icon("Plus", "icon-sm") %>
                            <span>Create Progress</span>
                        </a>
                    </div>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- =========================================================
     MODAL: TAMBAH / EDIT REKOD KEMAJUAN
     ========================================================= -->
<div class="nb-modal-overlay" id="progressModal">
    <div class="nb-modal">
        <h3 id="modalTitle" style="margin-top:0; font-weight:900; font-size: 1.3rem;">Rekod Kemajuan Murid</h3>
        <form action="${pageContext.request.contextPath}/learningProgress" method="POST">
            <input type="hidden" name="action" id="formAction" value="create">
            <input type="hidden" name="progressID" id="formProgressID" value="0">
            <input type="hidden" name="studentID" value="${student.studentID}">

            <label class="nb-label" style="font-size:0.85rem;">Domain</label>
            <select name="domainName" id="formDomain" class="nb-input">
                <option value="Reading">Reading</option>
                <option value="Writing">Writing</option>
                <option value="Counting">Counting</option>
            </select>

            <label class="nb-label" style="font-size:0.85rem;">Nama Aktiviti / Topik</label>
            <input type="text" name="progressName" id="formName" class="nb-input" required placeholder="Cth: CVC Phonics & Beginning Sounds">

            <label class="nb-label" style="font-size:0.85rem;">Peratus Kemajuan (%)</label>
            <input type="number" step="0.1" name="progressPercentage" id="formPercentage" class="nb-input" min="0" max="100" value="80" required>

            <label class="nb-label" style="font-size:0.85rem;">Status Kemajuan</label>
            <select name="progressStatus" id="formStatus" class="nb-input">
                <option value="Mastered">Mastered</option>
                <option value="Proficient">Proficient</option>
                <option value="Developing">Developing</option>
                <option value="Emerging">Emerging</option>
            </select>

            <label class="nb-label" style="font-size:0.85rem;">Skala Penilaian (1-5)</label>
            <input type="number" name="ratingScale" id="formRatingScale" class="nb-input" min="1" max="5" value="4">

            <label class="nb-label" style="font-size:0.85rem;">Tarikh Penilaian</label>
            <input type="date" name="progressDate" id="formDate" class="nb-input">

            <label class="nb-label" style="font-size:0.85rem;">Nota Guru</label>
            <textarea name="notes" id="formNotes" class="nb-input" rows="2"></textarea>

            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:16px;">
                <button type="button" class="nb-btn" onclick="closeModal('progressModal')">Batal</button>
                <button type="submit" class="nb-btn nb-btn-mint">
                    <%= IconUtil.icon("Save", "icon-xs") %> Simpan
                </button>
            </div>
        </form>
    </div>
</div>

<!-- =========================================================
     MODAL: DIAGRAM SPECS (UML & DCD VERIFICATION)
     ========================================================= -->
<div class="nb-modal-overlay" id="diagramSpecsModal">
    <div class="nb-modal" style="max-width: 620px;">
        <h3 style="margin-top:0; font-weight:900; font-size: 1.3rem; display: flex; align-items: center; gap: 8px;">
            <%= IconUtil.icon("Layers", "icon-md") %> Diagram Specifications Alignment
        </h3>
        <p style="font-size: 0.85rem; color: #475569; font-weight: 600;">Keedsflix Centre System Architecture & Oracle Compliance</p>
        
        <div style="background: #F8FAFC; border: 1.5px solid #CBD5E1; border-radius: 12px; padding: 14px; margin: 12px 0; font-size: 0.8rem; line-height: 1.5;">
            <strong>Database Mapping (Oracle `KINDERGARTEN`):</strong>
            <ul>
                <li><strong>LEARNINGPROGRESS:</strong> progressID, learningID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID, notes, ratingScale, assessorName</li>
                <li><strong>LEARNING:</strong> learningID (1 = Reading, 2 = Writing, 3 = Counting), learningName</li>
                <li><strong>STUDENT:</strong> studentID, studentName, studentAge, classID, teacherComment</li>
            </ul>
        </div>

        <div style="display:flex; justify-content:flex-end; margin-top:16px;">
            <button type="button" class="nb-btn nb-btn-yellow" onclick="closeModal('diagramSpecsModal')">Tutup Specs</button>
        </div>
    </div>
</div>

<script>
    function openCreateModal() {
        document.getElementById('modalTitle').innerText = 'Tambah Rekod Kemajuan';
        document.getElementById('formAction').value = 'create';
        document.getElementById('formProgressID').value = '0';
        document.getElementById('formName').value = '';
        document.getElementById('formPercentage').value = '80';
        document.getElementById('formNotes').value = '';
        document.getElementById('formRatingScale').value = '4';
        
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('formDate').value = today;
        
        document.getElementById('progressModal').classList.add('active');
    }

    function openEditModal(id, domain, name, pct, status, dateStr, notes, scale, homeRec) {
        document.getElementById('modalTitle').innerText = 'Kemas Kini Rekod Kemajuan';
        document.getElementById('formAction').value = 'update';
        document.getElementById('formProgressID').value = id;
        if (domain) document.getElementById('formDomain').value = domain;
        document.getElementById('formName').value = name;
        document.getElementById('formPercentage').value = pct;
        document.getElementById('formStatus').value = status;
        if (dateStr) document.getElementById('formDate').value = dateStr;
        document.getElementById('formNotes').value = notes || '';
        document.getElementById('formRatingScale').value = scale || '4';
        
        document.getElementById('progressModal').classList.add('active');
    }

    function openDiagramSpecsModal() {
        document.getElementById('diagramSpecsModal').classList.add('active');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('active');
    }

    function confirmDelete(id) {
        if (confirm('Adakah anda pasti mahu memadam rekod penilaian ini?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/learningProgress';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'progressID';
            idInput.value = id;
            form.appendChild(idInput);

            const studentInput = document.createElement('input');
            studentInput.type = 'hidden';
            studentInput.name = 'studentID';
            studentInput.value = '${student.studentID}';
            form.appendChild(studentInput);

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<jsp:include page="icons.jsp" />
</body>
</html>