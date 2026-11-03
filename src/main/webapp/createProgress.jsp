<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="java.util.List"%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Borang Pentaksiran Komprehensif - Keedflix Centre</title>
    
    <style>
        /* ==========================================================================
           1. LAYOUT WRAPPER (SIDEBAR + HEADER + MAIN CONTENT)
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
            padding: 24px 32px;
            overflow-y: auto;
        }

        /* ==========================================================================
           2. NEOBRUTALISM THEME & COMPONENT STYLES
           ========================================================================== */
        :root {
            --bg-canvas: #FFFDF7;
            --border-dark: #2D3436;
            --yellow-accent: #FFD166;
            --coral-accent: #FF6B6B;
            --mint-accent: #2EC4B6;
            --purple-accent: #7C3AED;
            --purple-light: #F3E8FF;
            --emerald-bg: #ECFDF5;
            --emerald-border: #10B981;
            --shadow-sm: 2px 2px 0px 0px var(--border-dark);
            --shadow-md: 3px 3px 0px 0px var(--border-dark);
            --shadow-lg: 4px 4px 0px 0px var(--border-dark);
        }

        .nb-wrapper {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* CARD CONTAINERS */
        .nb-card {
            background-color: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 24px;
            padding: 20px 24px;
            box-shadow: var(--shadow-lg);
        }

        /* BADGES */
        .nb-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: 1px solid var(--border-dark);
        }
        .badge-purple { background-color: #EEF2FF; color: #4338CA; border-color: #C7D2FE; }
        .badge-mint { background-color: var(--mint-accent); color: var(--border-dark); box-shadow: 1px 1px 0px 0px var(--border-dark); }
        .badge-yellow { background-color: var(--yellow-accent); color: var(--border-dark); }
        .badge-coral { background-color: var(--coral-accent); color: #FFFFFF; }
        .badge-target { background-color: var(--purple-light); color: var(--purple-accent); border-color: #D8B4FE; }
        .badge-success { background-color: #D1FAE5; color: #065F46; border-color: #34D399; }

        /* BUTTONS */
        .nb-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 8px 18px;
            border: 2px solid var(--border-dark);
            border-radius: 16px;
            background-color: #FFFFFF;
            color: var(--border-dark);
            font-weight: 900;
            font-size: 0.85rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.1s ease;
            text-decoration: none;
        }
        .nb-btn:hover { transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .nb-btn:active { transform: translate(1px, 1px); box-shadow: 1px 1px 0px 0px var(--border-dark); }
        .nb-btn-dark { background-color: var(--border-dark); color: #FFFFFF; }
        .nb-btn-yellow { background-color: var(--yellow-accent); color: var(--border-dark); box-shadow: var(--shadow-md); }
        .nb-btn-coral { background-color: var(--coral-accent); color: #FFFFFF; }
        .nb-btn-mint { background-color: var(--mint-accent); color: var(--border-dark); }

        /* INPUTS & SELECTS */
        .nb-input, .nb-select, .nb-textarea {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid var(--border-dark);
            border-radius: 16px;
            background-color: var(--bg-canvas);
            font-weight: 700;
            font-size: 0.85rem;
            color: var(--border-dark);
            outline: none;
        }
        .nb-input:focus, .nb-select:focus, .nb-textarea:focus {
            background-color: #FFFFFF;
            border-color: var(--border-dark);
            box-shadow: 0 0 0 3px rgba(255, 209, 102, 0.4);
        }

        /* DOMAIN FILTER STRIP */
        .filter-strip {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px dashed rgba(45, 52, 54, 0.2);
            flex-wrap: wrap;
            gap: 12px;
        }
        .filter-btn-group { display: flex; gap: 8px; flex-wrap: wrap; }
        .filter-btn-group .nb-btn { border-radius: 12px; font-size: 0.8rem; padding: 6px 14px; }

        /* LIVE PREVIEW GRID */
        .preview-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-top: 14px;
        }
        @media (max-width: 768px) { .preview-grid { grid-template-columns: 1fr; } }
        .preview-card {
            background-color: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 18px;
            padding: 14px;
            box-shadow: var(--shadow-md);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        /* CHECKLIST ITEMS */
        .checklist-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            border-radius: 14px;
            border: 2px solid var(--border-dark);
            margin-bottom: 8px;
            background-color: #FFFFFF;
            cursor: pointer;
            transition: all 0.15s;
        }
        .checklist-item.checked-yellow { background-color: #FFFBEB; border-color: #F59E0B; }
        .checklist-item.checked-coral { background-color: #FFF1F2; border-color: #F43F5E; }
        .checklist-item.checked-mint { background-color: #ECFDF5; border-color: #10B981; }

        .check-box {
            width: 22px; height: 22px;
            border-radius: 50%;
            border: 2px solid var(--border-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            font-size: 12px;
            font-weight: 900;
            background: #FFF;
            flex-shrink: 0;
        }
        .checked-yellow .check-box { background: var(--yellow-accent); }
        .checked-coral .check-box { background: var(--coral-accent); color: #FFF; }
        .checked-mint .check-box { background: var(--mint-accent); }

        /* RATING SCALE 1 - 5 GRID */
        .scale-selector-container {
            background-color: var(--bg-canvas);
            border: 2px solid var(--border-dark);
            border-radius: 18px;
            padding: 16px;
            margin-top: 16px;
            box-shadow: var(--shadow-sm);
        }
        .scale-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-top: 12px;
        }
        .scale-btn {
            position: relative;
            background: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            padding: 10px 6px;
            text-align: center;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.15s;
        }
        .scale-btn .num { font-size: 1.2rem; font-weight: 900; display: block; }
        .scale-btn .lbl { font-size: 0.7rem; font-weight: 700; color: #64748B; }

        /* ACTIVE SCALE COLORED STATES */
        .scale-btn.active-yellow { background-color: var(--yellow-accent); transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .scale-btn.active-coral { background-color: var(--coral-accent); color: #FFF; transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .scale-btn.active-coral .lbl { color: #FFE4E6; }
        .scale-btn.active-mint { background-color: var(--mint-accent); transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }

        .target-pill {
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--purple-accent);
            color: #FFF;
            font-size: 0.55rem;
            font-weight: 900;
            padding: 1px 8px;
            border-radius: 999px;
            border: 1px solid var(--border-dark);
            text-transform: uppercase;
        }
    </style>
</head>
<body>

<div class="app-layout">

    <!-- 1. SIDEBAR INCLUDE -->
    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <!-- 2. MAIN APPLICATION WRAPPER -->
    <main class="app-main-wrapper">

        <!-- HEADER INCLUDE -->
        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <!-- MAIN BODY CONTENT AREA -->
        <div class="app-content-body">
            <div class="nb-wrapper">
                <form action="${pageContext.request.contextPath}/createProgress" method="POST" id="progressForm">
                    <input type="hidden" name="studentID" id="formStudentID" value="${editingRecord != null ? editingRecord.studentID : 1}">
                    <input type="hidden" name="editProgressID" value="${editingRecord != null ? editingRecord.progressID : 0}">
                    <input type="hidden" name="activeDomainFilter" id="activeDomainFilter" value="All">

                    <!-- TOP BREADCRUMB & HEADER BAR -->
                    <div class="nb-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                        <div style="display: flex; align-items: center; gap: 14px;">
                            <a href="${pageContext.request.contextPath}/learningProgress" class="nb-btn">
                                ← Kembali
                            </a>
                            <div>
                                <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-bottom: 4px;">
                                    <span class="nb-badge badge-purple">PENTAKSIRAN BERSEPADU KSPK</span>
                                    <span class="nb-badge badge-mint">SKALA RATING 1 - 5 (RADAR CHART SYNC)</span>
                                </div>
                                <h1 style="font-size: 1.25rem; font-weight: 900;">
                                    ${editingRecord != null ? 'Kemaskini Rekod Pentaksiran' : 'Borang Pentaksiran Komprehensif (Reading, Writing & Counting)'}
                                </h1>
                            </div>
                        </div>
                        <div style="font-size: 0.8rem; font-weight: 800; color: #64748B;">
                            Penilai: <strong style="color: var(--border-dark);">${editingRecord != null ? editingRecord.assessorName : 'Ms. Clara Davis'}</strong>
                        </div>
                    </div>

                    <!-- STUDENT & DATE CONTEXT SELECTOR CARD -->
                    <div class="nb-card" style="margin-top: 16px;">
                        <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 16px;">
                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 12px 16px; box-shadow: var(--shadow-sm); display: flex; gap: 12px; align-items: center;">
                                <div style="width: 44px; height: 44px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; box-shadow: var(--shadow-sm);">
                                    🦁
                                </div>
                                <div style="flex-grow: 1;">
                                    <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 2px;">
                                        SASARAN MURID DINILAI
                                    </label>
                                    <select id="studentSelect" class="nb-select" onchange="updateStudentContext(this)">
                                        <c:forEach var="st" items="${students}">
                                            <option value="${st.studentID}" data-age="${st.studentAge}" data-parent="${st.parentName}">
                                                ${st.studentName} — ${st.studentClass} (${st.studentAge} Years, 4 Months)
                                            </option>
                                        </c:forEach>
                                        <option value="1" data-age="5" data-parent="Encik Ahmad" selected>Leo Vance — Kindergarten 3B (5 Years, 4 Months)</option>
                                    </select>
                                    <div style="display: flex; gap: 8px; margin-top: 6px; align-items: center; flex-wrap: wrap;">
                                        <span class="nb-badge badge-target">🎯 SASARAN UMUR 5 TAHUN: SKALA 4: MAHIR (PROFICIENT)</span>
                                        <span style="font-size: 0.7rem; font-weight: 600; color: #475569;">Ibu Bapa: <strong id="lblParent">Encik Ahmad</strong></span>
                                    </div>
                                </div>
                            </div>

                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 12px 16px; box-shadow: var(--shadow-sm);">
                                <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 4px;">
                                    📅 TARIKH PENTAKSIRAN
                                </label>
                                <input type="date" name="progressDate" class="nb-input" value="2026-11-03" required>
                            </div>

                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 12px 16px; box-shadow: var(--shadow-sm);">
                                <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 4px;">
                                    🧑‍🏫 GURU PENILAI (ASSESSOR)
                                </label>
                                <input type="text" name="assessorName" class="nb-input" value="Ms. Clara Davis" required>
                            </div>
                        </div>

                        <!-- DOMAIN CONTAINER FILTER -->
                        <div class="filter-strip">
                            <div style="font-size: 0.75rem; font-weight: 900; display: flex; align-items: center; gap: 6px;">
                                📚 PILIHAN PAPARAN CONTAINER:
                            </div>
                            <div class="filter-btn-group">
                                <button type="button" class="nb-btn nb-btn-dark" onclick="filterDomain('All', this)">Semua 3 Teras (All 3)</button>
                                <button type="button" class="nb-btn" onclick="filterDomain('Reading', this)">📖 1. Reading</button>
                                <button type="button" class="nb-btn" onclick="filterDomain('Writing', this)">✏️ 2. Writing</button>
                                <button type="button" class="nb-btn" onclick="filterDomain('Counting', this)"># 3. Counting</button>
                            </div>
                        </div>
                    </div>

                    <!-- LIVE PREVIEW CARD CONTAINER (WITH RADAR SYNC) -->
                    <div class="nb-card" style="margin-top: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(45, 52, 54, 0.1); padding-bottom: 10px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 32px; height: 32px; border-radius: 10px; background: #FFE4E6; border: 2px solid var(--border-dark); display: flex; align-items: center; justify-content: center; font-size: 14px;">
                                    👁️
                                </div>
                                <div>
                                    <h3 style="font-size: 0.95rem; font-weight: 900; display: flex; align-items: center; gap: 6px;">
                                        Pratonton Kad Rekod 3 Teras & Radar Chart (Live Preview)
                                        <span style="width: 8px; height: 8px; background: #10B981; border-radius: 50%; display: inline-block;"></span>
                                    </h3>
                                    <p style="font-size: 0.7rem; color: #64748B; font-weight: 600;">
                                        Peringatan: Umur <strong>5 tahun</strong> disasarkan mencapai <strong>Skala 4: Mahir (Proficient)</strong>. Jurang penilaian akan mencetuskan amaran kepada guru dan ibu bapa.
                                    </p>
                                </div>
                            </div>
                            <span class="nb-badge" style="background: #FFF; border: 2px solid var(--border-dark); box-shadow: var(--shadow-sm);">RADAR & ALERT SYNC</span>
                        </div>

                        <!-- 3 Mini Cards Grid -->
                        <div class="preview-grid">
                            <!-- Reading Card -->
                            <div class="preview-card">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-yellow">📖 READING</span>
                                        <span class="nb-badge badge-success">✓ CAPAI SASARAN</span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevReadingTitle">
                                        Penguasaan Fonik & Pengecaman Bunyi Huruf (Phonics)
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Penguasaan: <strong id="prevReadingCount">4/5</strong> kriteria standard konstruk KSPK.
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevReadingRadar">8/10</strong></span>
                                    <span style="font-weight: 900;" id="prevReadingScale">Skala 4/5</span>
                                </div>
                            </div>

                            <!-- Writing Card -->
                            <div class="preview-card">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-coral">✏️ WRITING</span>
                                        <span class="nb-badge badge-success">✓ CAPAI SASARAN</span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevWritingTitle">
                                        Kawalan Motor Halus & Genggaman Pensel (Tripod Grip)
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Penguasaan: <strong id="prevWritingCount">4/5</strong> kriteria standard konstruk KSPK.
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevWritingRadar">8/10</strong></span>
                                    <span style="font-weight: 900;" id="prevWritingScale">Skala 4/5</span>
                                </div>
                            </div>

                            <!-- Counting Card -->
                            <div class="preview-card">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-mint"># COUNTING</span>
                                        <span class="nb-badge badge-success">✓ CAPAI SASARAN</span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevCountingTitle">
                                        Pengecaman Nombor & Pembilangan Objek (1-30)
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Penguasaan: <strong id="prevCountingCount">4/5</strong> kriteria standard konstruk KSPK.
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevCountingRadar">8/10</strong></span>
                                    <span style="font-weight: 900;" id="prevCountingScale">Skala 4/5</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- TERAS 1: READING DOMAIN CONTAINER -->
                    <div class="nb-card domain-section" id="sectionReading" style="margin-top: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; box-shadow: var(--shadow-sm);">
                                    📖
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-yellow">TERAS 1</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Reading (Fonik & Kemahiran Membaca)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran penguasaan vokal, konsonan, suku kata terbuka (KV) & pemahaman teks bacaan.</p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn" onclick="resetRubric('reading')">🔄 Reset Rubrik Reading</button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Reading <span style="color:red;">*</span></label>
                        <input type="text" name="reading_progressName" id="readingTopic" class="nb-input" value="Penguasaan Fonik & Pengecaman Bunyi Huruf (Phonics)" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #FFFBEB; border: 2px solid #FCD34D; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #F59E0B; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #B45309;" id="readingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #78350F;">4 daripada 5 Kriteria Reading Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #92400E;">Cadangan skala automatik: <strong>Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-yellow" onclick="applySuggestedScale('reading')">✨ Gunakan Skor Cadangan</button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="readingCriteriaList">
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Mengecam dan membunyikan huruf vokal (a, e, i, o, u) dengan tepat</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Membunyikan konsonan asas secara fonik tanpa kekeliruan</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Menggabungkan bunyi konsonan dan vokal menjadi suku kata terbuka (KV)</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Membaca perkataan mudah suku kata tertutup (CVC / KVK)</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Mendengar dan mengulang sebutan intonasi bacaan dengan yakin</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customReadingInput" class="nb-input" placeholder="Tambah kriteria bacaan khusus...">
                            <button type="button" class="nb-btn nb-btn-yellow" onclick="addCustomCriteria('reading')">Tambah</button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: block;">🏅 Skala Penilaian Perkembangan (Rating Scale 1 - 5)</label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: 8.0/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblReadingScale">4</span> / 5</span>
                                    <span class="nb-badge badge-yellow" id="lblReadingStatus">PROFICIENT</span>
                                </div>
                            </div>

                            <input type="hidden" name="reading_ratingScale" id="reading_scale" value="4">
                            <div class="scale-grid">
                                <div class="scale-btn" onclick="selectScale('reading', 1, 'yellow', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn" onclick="selectScale('reading', 2, 'yellow', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn" onclick="selectScale('reading', 3, 'yellow', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn active-yellow" onclick="selectScale('reading', 4, 'yellow', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn" onclick="selectScale('reading', 5, 'yellow', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div style="background: var(--emerald-bg); border: 1px solid var(--emerald-border); border-radius: 12px; padding: 8px 14px; margin-top: 12px; display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem; font-weight: 800; color: #065F46;">
                                <span>✓ Mencapai Penanda Aras Umur (5 Tahun ➔ Skala 4: Mahir (Proficient))</span>
                                <span class="nb-badge badge-success">Sasaran Tercapai</span>
                            </div>
                        </div>
                    </div>

                    <!-- TERAS 2: WRITING DOMAIN CONTAINER -->
                    <div class="nb-card domain-section" id="sectionWriting" style="margin-top: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--coral-accent); color:#FFF; border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; box-shadow: var(--shadow-sm);">
                                    ✏️
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-coral">TERAS 2</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Writing (Motor Halus & Kemahiran Menulis)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran genggaman pensel tripod, kawalan koordinasi tangan-mata, dan pembentukan huruf.</p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn" onclick="resetRubric('writing')">🔄 Reset Rubrik Writing</button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Writing <span style="color:red;">*</span></label>
                        <input type="text" name="writing_progressName" id="writingTopic" class="nb-input" value="Kawalan Motor Halus & Genggaman Pensel (Tripod Grip)" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #FFF1F2; border: 2px solid #FDA4AF; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #F43F5E; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #BE185D;" id="writingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #881337;">4 daripada 5 Kriteria Writing Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #9F1239;">Cadangan skala automatik: <strong>Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-coral" onclick="applySuggestedScale('writing')">✨ Gunakan Skor Cadangan</button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="writingCriteriaList">
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Memegang pensel menggunakan genggaman dinamik tripod dengan selesa</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Mengawal tekanan pensel pada kertas tanpa merosakkan lembaran</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Menyambung garisan titik (lurus, beralun, zig-zag) dengan kemas</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Melukis bentuk geometri asas dengan kawalan pergerakan tangan yang stabil</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Mengekalkan postur badan yang ergonomik semasa aktiviti menulis</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customWritingInput" class="nb-input" placeholder="Tambah kriteria penulisan khusus...">
                            <button type="button" class="nb-btn nb-btn-coral" onclick="addCustomCriteria('writing')">Tambah</button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: block;">🏅 Skala Penilaian Perkembangan (Rating Scale 1 - 5)</label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: 8.0/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblWritingScale">4</span> / 5</span>
                                    <span class="nb-badge badge-coral" id="lblWritingStatus">PROFICIENT</span>
                                </div>
                            </div>

                            <input type="hidden" name="writing_ratingScale" id="writing_scale" value="4">
                            <div class="scale-grid">
                                <div class="scale-btn" onclick="selectScale('writing', 1, 'coral', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn" onclick="selectScale('writing', 2, 'coral', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn" onclick="selectScale('writing', 3, 'coral', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn active-coral" onclick="selectScale('writing', 4, 'coral', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn" onclick="selectScale('writing', 5, 'coral', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div style="background: var(--emerald-bg); border: 1px solid var(--emerald-border); border-radius: 12px; padding: 8px 14px; margin-top: 12px; display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem; font-weight: 800; color: #065F46;">
                                <span>✓ Mencapai Penanda Aras Umur (5 Tahun ➔ Skala 4: Mahir (Proficient))</span>
                                <span class="nb-badge badge-success">Sasaran Tercapai</span>
                            </div>
                        </div>
                    </div>

                    <!-- TERAS 3: COUNTING DOMAIN CONTAINER -->
                    <div class="nb-card domain-section" id="sectionCounting" style="margin-top: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--mint-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; box-shadow: var(--shadow-sm);">
                                    #
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-mint">TERAS 3</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Counting (Nombor, Operasi & Bentuk Geometri)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran pembilangan objek 1-ke-1, pengecaman angka, bentuk 2D dan operasi matematik awal.</p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn" onclick="resetRubric('counting')">🔄 Reset Rubrik Counting</button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Counting <span style="color:red;">*</span></label>
                        <input type="text" name="counting_progressName" id="countingTopic" class="nb-input" value="Pengecaman Nombor & Pembilangan Objek (1-30)" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #ECFDF5; border: 2px solid #6EE7B7; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #10B981; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #047857;" id="countingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #064E3B;">4 daripada 5 Kriteria Counting Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #065F46;">Cadangan skala automatik: <strong>Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-mint" onclick="applySuggestedScale('counting')">✨ Gunakan Skor Cadangan</button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="countingCriteriaList">
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Menyebut turutan nombor 1 hingga 20+ secara lisan dengan lancar</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Membilang objek konkrit dengan padanan satu-ke-satu (1-to-1 correspondence)</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Memadankan simbol angka dengan kuantiti objek yang betul</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box">✓</div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Mengecam angka yang hilang dalam urutan nombor mudah</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Membezakan konsep kuantiti: "lebih banyak", "lebih sedikit", "sama banyak"</span>
                                </div>
                                <span style="color: #94A3B8; cursor: pointer;">🗑️</span>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customCountingInput" class="nb-input" placeholder="Tambah kriteria pengiraan khusus...">
                            <button type="button" class="nb-btn nb-btn-mint" onclick="addCustomCriteria('counting')">Tambah</button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: block;">🏅 Skala Penilaian Perkembangan (Rating Scale 1 - 5)</label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: 8.0/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblCountingScale">4</span> / 5</span>
                                    <span class="nb-badge badge-mint" id="lblCountingStatus">PROFICIENT</span>
                                </div>
                            </div>

                            <input type="hidden" name="counting_ratingScale" id="counting_scale" value="4">
                            <div class="scale-grid">
                                <div class="scale-btn" onclick="selectScale('counting', 1, 'mint', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn" onclick="selectScale('counting', 2, 'mint', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn" onclick="selectScale('counting', 3, 'mint', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn active-mint" onclick="selectScale('counting', 4, 'mint', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn" onclick="selectScale('counting', 5, 'mint', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div style="background: var(--emerald-bg); border: 1px solid var(--emerald-border); border-radius: 12px; padding: 8px 14px; margin-top: 12px; display: flex; justify-content: space-between; align-items: center; font-size: 0.75rem; font-weight: 800; color: #065F46;">
                                <span>✓ Mencapai Penanda Aras Umur (5 Tahun ➔ Skala 4: Mahir (Proficient))</span>
                                <span class="nb-badge badge-success">Sasaran Tercapai</span>
                            </div>
                        </div>
                    </div>

                    <!-- HOME RECOMMENDATION TEXTAREA CARD -->
                    <div class="nb-card" style="margin-top: 16px;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
                            <div style="width: 32px; height: 32px; border-radius: 10px; background: #EEF2FF; border: 2px solid var(--border-dark); display: flex; align-items: center; justify-content: center; font-size: 16px;">
                                🤝
                            </div>
                            <div>
                                <h3 style="font-size: 0.95rem; font-weight: 900;">Cadangan Perkongsian Aktiviti di Rumah (Untuk Ibu Bapa)</h3>
                                <p style="font-size: 0.7rem; color: #64748B;">Saranan praktikal untuk ibu bapa terus menyokong perkembangan murid di rumah secara santai.</p>
                            </div>
                        </div>
                        <textarea name="homeRecommendation" class="nb-textarea" rows="3" placeholder="Contoh: Ibu bapa digalakkan meluangkan masa 10 minit membaca buku cerita bergambar bersama anak, mengira objek mainan semasa mengemas, dan memberi anak peluang melukis bebas...">${editingRecord != null ? editingRecord.homeRecommendation : ''}</textarea>
                    </div>

                    <!-- BOTTOM ACTION SUBMIT BAR -->
                    <div class="nb-card" style="margin-top: 16px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                        <div style="font-size: 0.75rem; font-weight: 700; color: #475569; display: flex; align-items: center; gap: 8px;">
                            <span style="color: var(--purple-accent); font-size: 1rem;">ℹ️</span>
                            <span>Semua skor mencapai penanda aras umur 5 tahun (Skala 4: Mahir (Proficient)). Data akan terus dikemas kini ke Radar Chart.</span>
                        </div>
                        <div style="display: flex; gap: 12px;">
                            <a href="${pageContext.request.contextPath}/learningProgress" class="nb-btn">Batal</a>
                            <button type="submit" class="nb-btn nb-btn-yellow" style="padding: 10px 24px;">
                                💾 Simpan Semua Rekod Pentaksiran (3 Teras)
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<!-- JAVASCRIPT LOGIC FOR DYNAMIC INTERACTIONS -->
<script>
    const statusTextMap = { 1: "NOT STARTED", 2: "EMERGING", 3: "DEVELOPING", 4: "PROFICIENT", 5: "MASTERED" };

    function selectScale(domain, val, colorTheme, btnElem) {
        document.getElementById(domain + '_scale').value = val;
        document.getElementById('lbl' + capitalize(domain) + 'Scale').innerText = val;
        document.getElementById('lbl' + capitalize(domain) + 'Status').innerText = statusTextMap[val];

        const parent = btnElem.closest('.scale-grid');
        parent.querySelectorAll('.scale-btn').forEach(b => {
            b.classList.remove('active-yellow', 'active-coral', 'active-mint');
        });
        btnElem.classList.add('active-' + colorTheme);

        updateLivePreview();
    }

    function toggleCriteria(itemElem, domain) {
        const checkbox = itemElem.querySelector('.check-box');
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');

        if (itemElem.classList.contains(colorClass)) {
            itemElem.classList.remove(colorClass);
            checkbox.innerText = '';
        } else {
            itemElem.classList.add(colorClass);
            checkbox.innerText = '✓';
        }
        updateCriteriaCount(domain);
    }

    function updateCriteriaCount(domain) {
        const container = document.getElementById(domain + 'CriteriaList');
        const total = container.querySelectorAll('.checklist-item').length;
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');
        const checked = container.querySelectorAll('.' + colorClass).length;

        document.getElementById(domain + 'RatioBadge').innerText = checked + '/' + total;
        document.getElementById('prev' + capitalize(domain) + 'Count').innerText = checked + '/' + total;
    }

    function applySuggestedScale(domain) {
        const container = document.getElementById(domain + 'CriteriaList');
        const total = container.querySelectorAll('.checklist-item').length;
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');
        const checked = container.querySelectorAll('.' + colorClass).length;
        
        const ratio = checked / (total || 1);
        let suggested = 4;
        if (ratio >= 0.9) suggested = 5;
        else if (ratio >= 0.7) suggested = 4;
        else if (ratio >= 0.5) suggested = 3;
        else if (ratio >= 0.25) suggested = 2;
        else suggested = 1;

        const colorTheme = domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint';
        const targetBtn = document.querySelectorAll('#section' + capitalize(domain) + ' .scale-btn')[suggested - 1];
        selectScale(domain, suggested, colorTheme, targetBtn);
    }

    function filterDomain(domain, btnElem) {
        document.getElementById('activeDomainFilter').value = domain;
        
        const btnGroup = btnElem.parentElement;
        btnGroup.querySelectorAll('.nb-btn').forEach(b => b.classList.remove('nb-btn-dark'));
        btnElem.classList.add('nb-btn-dark');

        const sections = document.querySelectorAll('.domain-section');
        sections.forEach(sec => {
            if (domain === 'All') {
                sec.style.display = 'block';
            } else {
                sec.style.display = sec.id === ('section' + domain) ? 'block' : 'none';
            }
        });
    }

    function updateLivePreview() {
        ['reading', 'writing', 'counting'].forEach(dom => {
            const topic = document.getElementById(dom + 'Topic').value;
            const scale = document.getElementById(dom + '_scale').value;

            document.getElementById('prev' + capitalize(dom) + 'Title').innerText = topic || ('Pentaksiran ' + capitalize(dom));
            document.getElementById('prev' + capitalize(dom) + 'Scale').innerText = 'Skala ' + scale + '/5';
            document.getElementById('prev' + capitalize(dom) + 'Radar').innerText = (scale * 2) + '/10';
        });
    }

    function updateStudentContext(selectElem) {
        const selectedOpt = selectElem.options[selectElem.selectedIndex];
        document.getElementById('formStudentID').value = selectElem.value;
        document.getElementById('lblParent').innerText = selectedOpt.getAttribute('data-parent') || 'Encik Ahmad';
    }

    function capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
</script>
</body>
</html>