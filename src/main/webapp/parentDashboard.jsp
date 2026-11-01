<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Parent"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.News"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix Parent Platform</title>
    
    <style>
        /* ================================================================= */
        /* NEOBRUTALISM GLOBAL & DASHBOARD STYLES                            */
        /* ================================================================= */
        * {
            box-sizing: border-box;
        }

        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF;
            color: #2D3436;
        }

        .app-layout {
            display: flex;
            height: 100vh;
            width: 100%;
        }

        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background-color: #FFFFFF;
            z-index: 10;
            border-right: 3px solid #2D3436;
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background-color: #FAF5EF;
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background-color: #FFFFFF;
            border-bottom: 3px solid #2D3436;
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px 32px;
            overflow-y: auto;
        }

        .parent-platform-root {
            display: flex;
            flex-direction: column;
            gap: 24px;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* ERROR CARD */
        .db-error-card {
            background-color: #FEF2F2;
            border: 3.5px solid #2D3436;
            border-radius: 24px;
            padding: 32px;
            box-shadow: 6px 6px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-top: 20px;
        }
        .db-error-header { display: flex; align-items: center; gap: 16px; }
        .db-error-icon {
            width: 56px; height: 56px; border-radius: 18px; background-color: #EF4444; color: white;
            border: 3px solid #2D3436; display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; box-shadow: 3px 3px 0px 0px #2D3436; flex-shrink: 0;
        }
        .db-error-title { font-size: 1.4rem; font-weight: 900; color: #991B1B; margin: 0; }
        .db-error-msg { font-size: 0.95rem; font-weight: 700; color: #7F1D1D; margin: 4px 0 0 0; line-height: 1.5; }

        /* BANNER CARD */
        .banner-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        @media (min-width: 1024px) {
            .banner-card { flex-direction: row; align-items: center; justify-content: space-between; }
        }
        .banner-left { display: flex; align-items: center; gap: 16px; }
        .heart-icon-box {
            width: 64px; height: 64px; border-radius: 16px; background-color: #FFB3C6; 
            border: 3px solid #2D3436; display: flex; align-items: center; justify-content: center; 
            color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; flex-shrink: 0; font-size: 1.8rem;
        }
        .banner-title-group { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 4px; }
        .banner-title { font-size: 1.5rem; font-weight: 900; color: #2D3436; margin: 0; }
        .banner-badge {
            background-color: #FFB3C6; color: #2D3436; font-size: 10px; font-weight: 900; 
            text-transform: uppercase; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436;
        }
        .banner-subtitle { font-size: 0.85rem; color: #636E72; margin: 0; }
        .banner-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .info-pill { border: 2.5px solid #2D3436; border-radius: 16px; padding: 10px 16px; display: flex; flex-direction: column; }
        .pill-pink { background-color: #FFF0F3; }
        .pill-amber { background-color: #FFF9E6; }
        .pill-label { font-size: 10px; font-weight: 800; text-transform: uppercase; margin-bottom: 2px; }
        .pill-value { font-size: 1.1rem; font-weight: 900; color: #2D3436; display: flex; align-items: center; gap: 6px; }

        /* METRICS GRID */
        .metrics-grid { display: grid; grid-template-columns: repeat(1, 1fr); gap: 16px; }
        @media (min-width: 640px) { .metrics-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (min-width: 1024px) { .metrics-grid { grid-template-columns: repeat(4, 1fr); } }
        .metric-card {
            background-color: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px; 
            padding: 20px; box-shadow: 4px 4px 0px 0px #2D3436;
        }
        .metric-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
        .metric-label { font-size: 11px; font-weight: 900; text-transform: uppercase; color: #636E72; }
        .metric-icon-box {
            width: 34px; height: 34px; border-radius: 12px; display: flex; align-items: center; 
            justify-content: center; border: 2px solid #2D3436; font-weight: 900;
        }
        .bg-purple { background-color: #F3E8FF; color: #7E22CE; }
        .bg-amber { background-color: #FEF3C7; color: #B45309; }
        .bg-emerald { background-color: #D1FAE5; color: #059669; }
        .bg-rose { background-color: #FFE4E6; color: #E11D48; }
        .metric-value { font-size: 2rem; font-weight: 900; color: #2D3436; margin: 0 0 4px 0; line-height: 1; }
        .metric-sub { font-size: 11px; color: #636E72; margin: 0; }

        /* DROPDOWN SELECTOR */
        .child-selector-bar {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 16px 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 4px 4px 0px 0px #2D3436;
            position: relative;
        }
        .child-selector-bar.has-multiple { cursor: pointer; }
        .child-selector-bar.has-multiple:hover { background-color: #FFF5F7; }
        .child-info-left { display: flex; align-items: center; gap: 16px; }
        .child-avatar-box {
            width: 48px; height: 48px; border-radius: 18px; background-color: #FF8FB1;
            border: 2.5px solid #2D3436; display: flex; align-items: center; justify-content: center;
            font-size: 1.6rem; box-shadow: 2px 2px 0px 0px #2D3436; flex-shrink: 0;
        }
        .child-name-text { font-size: 1.25rem; font-weight: 900; color: #2D3436; }
        .badge-class-pink {
            background-color: #FFE4E6; color: #BE185D; font-size: 10px; font-weight: 900;
            padding: 3px 10px; border-radius: 999px; border: 1.5px solid #F472B6;
        }
        .badge-active-portfolio {
            background-color: #D1F7E8; color: #065F46; font-size: 10px; font-weight: 900;
            text-transform: uppercase; padding: 3px 10px; border-radius: 999px; border: 1.5px solid #34D399;
        }
        .child-subtext { font-size: 0.78rem; color: #64748B; font-weight: 600; margin-top: 2px; }
        .btn-switch-child {
            background-color: #FF8FB1; border: 2px solid #2D3436; border-radius: 999px;
            padding: 8px 18px; font-size: 0.8rem; font-weight: 900; color: #2D3436;
            display: flex; align-items: center; gap: 6px; box-shadow: 2px 2px 0px 0px #2D3436;
        }
        .dropdown-menu-list {
            position: absolute; top: 110%; left: 0; right: 0; background-color: #FFFFFF;
            border: 3px solid #2D3436; border-radius: 24px; box-shadow: 6px 6px 0px 0px #2D3436;
            padding: 16px; z-index: 40; display: none;
        }
        .dropdown-menu-list.show { display: block; }
        .child-option-item {
            width: 100%; display: flex; align-items: center; justify-content: space-between;
            padding: 12px; border: 2px solid transparent; border-radius: 16px; background: none;
            cursor: pointer; text-align: left; transition: all 0.15s ease; text-decoration: none; color: inherit;
        }
        .child-option-item:hover { border-color: #2D3436; background-color: #FFF0F3; }
        .child-option-item.selected { background-color: #FFF0F3; border-color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; }

        /* CHARTS ROW */
        .charts-row { display: grid; grid-template-columns: 1fr; gap: 24px; }
        @media (min-width: 1024px) { .charts-row { grid-template-columns: 1fr 1fr; } }
        .chart-card-container {
            background-color: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px;
            padding: 24px; box-shadow: 5px 5px 0px 0px #2D3436; display: flex; flex-direction: column; gap: 16px;
        }

        /* KSPK ALERT CARD */
        .kspk-alert-card-warning {
            background-color: #FFFDF0; border: 3px solid #2D3436; border-radius: 28px;
            padding: 24px 28px; box-shadow: 5px 5px 0px 0px #2D3436; display: flex; flex-direction: column; gap: 20px;
        }
        .kspk-alert-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; }
        .kspk-alert-left { display: flex; align-items: flex-start; gap: 16px; }
        .kspk-alert-warning-icon {
            width: 52px; height: 52px; border-radius: 18px; background-color: #FACC15;
            border: 2.5px solid #2D3436; display: flex; align-items: center; justify-content: center;
            box-shadow: 2px 2px 0px 0px #2D3436; flex-shrink: 0; font-size: 1.4rem;
        }
        .kspk-badge-alert {
            background-color: #FF0055; color: #FFFFFF; font-size: 10px; font-weight: 900;
            text-transform: uppercase; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436;
        }
        .kspk-badge-target {
            background-color: #FEF08A; color: #854D0E; font-size: 11px; font-weight: 900;
            padding: 4px 12px; border-radius: 999px; border: 2px solid #CA8A04;
        }
        .kspk-alert-title { font-size: 1.35rem; font-weight: 900; color: #2D3436; margin: 6px 0; }
        .kspk-alert-desc { font-size: 0.88rem; font-weight: 600; color: #2D3436; margin: 0; line-height: 1.55; }

        .kspk-domain-grid { display: grid; grid-template-columns: repeat(1, 1fr); gap: 16px; margin-top: 4px; border-top: 2px solid #FDE68A; padding-top: 20px; }
        @media (min-width: 640px) { .kspk-domain-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (min-width: 1024px) { .kspk-domain-grid { grid-template-columns: repeat(3, 1fr); } }
        .kspk-domain-card {
            background-color: #FFFFFF; border: 2.5px solid #2D3436; border-radius: 18px;
            padding: 16px 18px; box-shadow: 3px 3px 0px 0px #2D3436; display: flex; flex-direction: column; gap: 8px;
        }
        .kspk-domain-card-header { display: flex; justify-content: space-between; align-items: center; }
        .kspk-domain-name { font-weight: 900; font-size: 0.9rem; color: #2D3436; }
        .kspk-gap-badge { font-size: 10px; font-weight: 900; color: #D10000; background-color: #FFE3E3; padding: 2px 8px; border-radius: 6px; border: 1.5px solid #F87171; }
        .kspk-domain-scale-value { font-size: 1.35rem; font-weight: 900; color: #2D3436; margin-top: 2px; }
        .kspk-domain-scale-target { font-size: 0.8rem; color: #6B7280; font-weight: 700; }
        .kspk-progress-track { width: 100%; background-color: #E5E7EB; height: 10px; border-radius: 999px; border: 1.5px solid #2D3436; overflow: hidden; margin-top: 4px; }
        .kspk-progress-fill { height: 100%; background-color: #FFD02C; border-radius: 999px; }

        .kspk-alert-card-success {
            background-color: #ECFDF5; border: 3px solid #2D3436; border-radius: 28px;
            padding: 20px 24px; box-shadow: 4px 4px 0px 0px #2D3436; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;
        }

        /* ================================================================= */
        /* NEWS PORTAL & BULLETINS SECTION (EXACT NEOBRUTALISM MATCH)        */
        /* ================================================================= */
        .nb-news-container {
            margin-top: 28px;
            background: #FFFFFF !important;
            border: 3px solid #2D3436 !important;
            border-radius: 24px !important;
            padding: 24px !important;
            box-shadow: 6px 6px 0px 0px #2D3436 !important;
        }
        
        .nb-filter-btn {
            background: #FFFFFF !important;
            border: 2px solid #2D3436 !important;
            border-radius: 999px !important;
            padding: 6px 18px !important;
            font-weight: 800 !important;
            font-size: 0.85rem !important;
            color: #2D3436 !important;
            cursor: pointer !important;
            box-shadow: 2px 2px 0px 0px #2D3436 !important;
            transition: all 0.15s ease !important;
            outline: none !important;
        }
        
        .nb-filter-btn:hover {
            transform: translateY(-2px) !important;
        }
        
        .nb-filter-btn.active {
            background: #FF7597 !important;
            color: #2D3436 !important;
        }

        .nb-card-item {
            background: #FFFFFF !important;
            border: 2.5px solid #EAB308 !important; /* BINGKAI KUNING NEOBRUTALISM */
            border-radius: 18px !important;
            padding: 20px !important;
            box-shadow: 4px 4px 0px 0px #2D3436 !important;
            display: flex !important;
            flex-direction: column !important;
            justify-content: space-between !important;
            min-height: 240px !important;
            transition: transform 0.15s ease !important;
        }
        .nb-card-item:hover {
            transform: translateY(-3px) !important;
        }

        .nb-badge {
            font-size: 0.68rem !important;
            font-weight: 900 !important;
            padding: 4px 12px !important;
            border-radius: 999px !important;
            text-transform: uppercase !important;
            display: inline-block !important;
        }

        .nb-badge-alert { background: #FFE4E6 !important; color: #BE185D !important; border: 1.5px solid #F472B6 !important; }
        .nb-badge-academic { background: #F3E8FF !important; color: #6C5CE7 !important; border: 1.5px solid #A855F7 !important; }
        .nb-badge-event { background: #FFE4E6 !important; color: #E11D48 !important; border: 1.5px solid #F472B6 !important; }
        .nb-badge-default { background: #F1F5F9 !important; color: #475569 !important; border: 1.5px solid #2D3436 !important; }

        .nb-badge-pinned {
            background: #FACC15 !important;
            color: #2D3436 !important;
            border: 2px solid #2D3436 !important;
            font-size: 0.68rem !important;
            font-weight: 900 !important;
            padding: 3px 10px !important;
            border-radius: 999px !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 4px !important;
        }
    </style>
</head>
<body>

    <div class="app-layout">
        
        <!-- SIDEBAR -->
        <aside class="app-sidebar-wrapper">
            <jsp:include page="sidebar.jsp" />
        </aside>

        <!-- MAIN CONTENT -->
        <main class="app-main-wrapper">
            
            <!-- HEADER -->
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <!-- CONTENT BODY -->
            <div class="app-content-body">
                
                <div class="parent-platform-root">

                    <!-- SEMAKAN JIKA TERDAPAT RALAT DATABASE -->
                    <c:choose>
                        <c:when test="${not empty errorMessage}">
                            <div class="db-error-card">
                                <div class="db-error-header">
                                    <div class="db-error-icon">❌</div>
                                    <div>
                                        <h2 class="db-error-title">Ralat Capaian Pangkalan Data</h2>
                                        <p class="db-error-msg">${errorMessage}</p>
                                    </div>
                                </div>
                                <div style="background-color: #FFFFFF; border: 2px solid #2D3436; border-radius: 16px; padding: 16px; font-size: 0.85rem; color: #4B5563;">
                                    <strong>Langkah Penyahpepijatan Oracle DB (KINDERGARTEN):</strong>
                                    <ul style="margin: 8px 0 0 0; padding-left: 20px;">
                                        <li>Pastikan jadual <code>STUDENT</code> mengandungi rekod dengan <code>parentID = ${parent.parentID}</code>.</li>
                                        <li>Jalankan SQL: <code>SELECT * FROM STUDENT WHERE PARENTID = 201;</code> di Oracle SQL Developer.</li>
                                        <li>Jalankan arahan <code>COMMIT;</code> selepas membuat sebarang perubahan data.</li>
                                    </ul>
                                </div>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <!-- 1. PARENT BANNER CARD -->
                            <div class="banner-card">
                                <div class="banner-left">
                                    <div class="heart-icon-box">❤️</div>
                                    <div>
                                        <div class="banner-title-group">
                                            <h1 class="banner-title">Keedflix Parent & Family Platform</h1>
                                            <span class="banner-badge">Family Connection Hub</span>
                                        </div>
                                        <p class="banner-subtitle">
                                            Logged in as: <strong>${parent.parentName}</strong> (${parentTitle}) • Connected to <strong>${currentStudent.studentName}</strong>
                                        </p>
                                    </div>
                                </div>

                                <div class="banner-right">
                                    <div class="info-pill pill-pink">
                                        <span class="pill-label" style="color: #BE185D;">Linked Pupil</span>
                                        <span class="pill-value">
                                            <span>${activeAvatar}</span>
                                            <span>${currentStudent.studentName}</span>
                                        </span>
                                    </div>
                                    <div class="info-pill pill-amber">
                                        <span class="pill-label" style="color: #92400E;">Enrolled Classroom</span>
                                        <span class="pill-value">${currentStudent.studentClass}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- 2. METRICS GRID -->
                            <div class="metrics-grid">
                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Developmental Score</span>
                                        <div class="metric-icon-box bg-purple">🏆</div>
                                    </div>
                                    <p class="metric-value">${averageLevel}%</p>
                                    <p class="metric-sub">Average mastery across 3 learning areas</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Photo Evidence</span>
                                        <div class="metric-icon-box bg-amber">📷</div>
                                    </div>
                                    <p class="metric-value">${photoProofsCount}</p>
                                    <p class="metric-sub">Classroom photos verified by educators</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Milestones Achieved</span>
                                        <div class="metric-icon-box bg-emerald">✅</div>
                                    </div>
                                    <p class="metric-value">${completedMilestones}</p>
                                    <p class="metric-sub">Certificated early learning milestones</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Academic Cycle</span>
                                        <div class="metric-icon-box bg-rose">📅</div>
                                    </div>
                                    <p class="metric-value">${academicCycle}</p>
                                    <p class="metric-sub">Official term portfolio certified</p>
                                </div>
                            </div>

                            <!-- 3. KSPK ALERT PERKEMBANGAN -->
                            <c:choose>
                                <c:when test="${hasDevelopmentalGap}">
                                    <div class="kspk-alert-card-warning">
                                        <div class="kspk-alert-header">
                                            <div class="kspk-alert-left">
                                                <div class="kspk-alert-warning-icon">⚠️</div>
                                                <div>
                                                    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-bottom: 4px;">
                                                        <span class="kspk-badge-alert">ALERT PERKEMBANGAN AKTIF</span>
                                                        <span class="kspk-badge-target">🎯 Sasaran Umur ${childAge} Tahun: Skala ${targetScale}</span>
                                                    </div>
                                                    <h2 class="kspk-alert-title">${currentStudent.studentName} Memerlukan Bimbingan Tambahan</h2>
                                                    <p class="kspk-alert-desc">
                                                        Mengikut <strong>Standard Kurikulum Prasekolah Kebangsaan (KSPK)</strong>, kanak-kanak berumur <strong>${childAge} tahun</strong> disasarkan mencapai sekurang-kurangnya <strong>Skala ${targetScale} (${targetLabel})</strong> merentasi semua domain. Terdapat <strong>${belowDomainsCount} domain</strong> yang memerlukan latihan pengukuhan bersama antara rumah dan tadika.
                                                    </p>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="kspk-domain-grid">
                                            <c:if test="${readingBelow}">
                                                <div class="kspk-domain-card">
                                                    <div class="kspk-domain-card-header">
                                                        <span class="kspk-domain-name">Membaca (Reading)</span>
                                                        <span class="kspk-gap-badge">Kurang ${readingGap} Skala</span>
                                                    </div>
                                                    <div class="kspk-domain-scale-value">
                                                        Skala ${readingScale} <span class="kspk-domain-scale-target">/ Sasaran ${targetScale}</span>
                                                    </div>
                                                    <div class="kspk-progress-track">
                                                        <div class="kspk-progress-fill" style="width: ${(readingScale / targetScale) * 100}%;"></div>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <c:if test="${writingBelow}">
                                                <div class="kspk-domain-card">
                                                    <div class="kspk-domain-card-header">
                                                        <span class="kspk-domain-name">Menulis (Writing)</span>
                                                        <span class="kspk-gap-badge">Kurang ${writingGap} Skala</span>
                                                    </div>
                                                    <div class="kspk-domain-scale-value">
                                                        Skala ${writingScale} <span class="kspk-domain-scale-target">/ Sasaran ${targetScale}</span>
                                                    </div>
                                                    <div class="kspk-progress-track">
                                                        <div class="kspk-progress-fill" style="width: ${(writingScale / targetScale) * 100}%;"></div>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <c:if test="${countingBelow}">
                                                <div class="kspk-domain-card">
                                                    <div class="kspk-domain-card-header">
                                                        <span class="kspk-domain-name">Mengira (Counting)</span>
                                                        <span class="kspk-gap-badge">Kurang ${countingGap} Skala</span>
                                                    </div>
                                                    <div class="kspk-domain-scale-value">
                                                        Skala ${countingScale} <span class="kspk-domain-scale-target">/ Sasaran ${targetScale}</span>
                                                    </div>
                                                    <div class="kspk-progress-track">
                                                        <div class="kspk-progress-fill" style="width: ${(countingScale / targetScale) * 100}%;"></div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <div class="kspk-alert-card-success">
                                        <div style="display: flex; align-items: center; gap: 14px;">
                                            <div style="width: 44px; height: 44px; border-radius: 14px; background-color: #34D399; border: 2.5px solid #2D3436; display: flex; align-items: center; justify-content: center; box-shadow: 2px 2px 0px 0px #2D3436; flex-shrink: 0;">✅</div>
                                            <div>
                                                <h4 style="font-size: 1.1rem; font-weight: 900; color: #065F46; margin: 0;">Tahniah! ${currentStudent.studentName} Menepati Sasaran Umur ${childAge} Tahun</h4>
                                                <p style="font-size: 0.85rem; color: #047857; margin: 3px 0 0 0; font-weight: 600;">Semua domain teras (Membaca, Menulis, Mengira) mencapai atau melebihi Skala ${targetScale} mengikut kurikulum KSPK.</p>
                                            </div>
                                        </div>
                                        <span style="font-size: 11px; font-weight: 900; background: #A7F3D0; color: #065F46; padding: 6px 16px; border-radius: 999px; border: 2px solid #059669; text-transform: uppercase;">🌞 Pencapaian Optimum</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <!-- 4. PEMILIH MURID / SWITCH CHILD BAR -->
                            <div class="child-selector-bar ${hasMultipleChildren ? 'has-multiple' : ''}" 
                                 id="childSelectorBtn" 
                                 onclick="toggleChildDropdown()">
                                
                                <div class="child-info-left">
                                    <div class="child-avatar-box">${activeAvatar}</div>
                                    <div>
                                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                            <span class="child-name-text">${currentStudent.studentName}</span>
                                            <c:if test="${not empty currentStudent.studentClass}">
                                                <span class="badge-class-pink">${currentStudent.studentClass}</span>
                                            </c:if>
                                            <span class="badge-active-portfolio">ACTIVE PORTFOLIO</span>
                                        </div>
                                        <div class="child-subtext">
                                            Age: ${currentStudent.studentAge} Years 
                                            • Registered Children: ${registeredChildren.size()}
                                            <c:if test="${hasMultipleChildren}"> • Click to switch child</c:if>
                                        </div>
                                    </div>
                                </div>

                                <c:if test="${hasMultipleChildren}">
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <button type="button" class="btn-switch-child">
                                            <span>Switch Child</span> ▼
                                        </button>
                                    </div>

                                    <div class="dropdown-menu-list" id="childDropdownMenu">
                                        <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; margin-bottom: 10px;">Select Registered Child</p>
                                        <c:forEach var="child" items="${registeredChildren}">
                                            <a href="${pageContext.request.contextPath}/parentDashboard?studentId=${child.studentID}" class="child-option-item ${child.studentID == currentStudent.studentID ? 'selected' : ''}">
                                                <div>
                                                    <p style="font-size: 14px; font-weight: 900; margin: 0; color: #2D3436;">${child.studentName}</p>
                                                    <p style="font-size: 11px; color: #636E72; margin: 0;">${child.studentClass} • Age: ${child.studentAge} Years</p>
                                                </div>
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>

                            <!-- 5. CHARTS ROW -->
                            <div class="charts-row">
                                <div class="chart-card-container">
                                    <iframe src="${pageContext.request.contextPath}/RadarChartServlet?studentId=${currentStudent.studentID}" width="100%" height="380" frameborder="0" scrolling="no" title="Radar Chart"></iframe>
                                </div>
                                <div class="chart-card-container">
                                    <iframe src="${pageContext.request.contextPath}/TrendChartServlet?studentId=${currentStudent.studentID}" width="100%" height="480" frameborder="0" scrolling="no" title="Trend Chart"></iframe>
                                </div>
                            </div>

                            <!-- 6. SEKSYEN KEEDFLIX CENTRE NEWS & WEEKLY BULLETINS -->
                            <div class="nb-news-container">
                                
                                <!-- HEADER SEKSYEN -->
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; margin-bottom: 20px;">
                                    <div style="display: flex; align-items: center; gap: 14px;">
                                        <div style="width: 52px; height: 52px; background: #FF7597; border: 2.5px solid #2D3436; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; box-shadow: 3px 3px 0px 0px #2D3436;">
                                            📰
                                        </div>
                                        <div>
                                            <h3 style="margin: 0; font-size: 1.35rem; font-weight: 900; color: #2D3436; display: flex; align-items: center; gap: 8px;">
                                                <span style="color: #FF7597; font-size: 0.9rem;">●</span> Keedflix Centre News & Weekly Bulletins
                                            </h3>
                                            <p style="margin: 4px 0 0 0; font-size: 0.88rem; color: #636E72; font-weight: 600;">
                                                Curriculum updates, reading & counting activities, and upcoming centre events for families
                                            </p>
                                        </div>
                                    </div>
                                    
                                    <a href="javascript:void(0);" style="text-decoration: none; background: #FFFFFF; color: #2D3436; border: 2.5px solid #2D3436; border-radius: 999px; padding: 8px 20px; font-weight: 900; font-size: 0.85rem; box-shadow: 3px 3px 0px 0px #2D3436; display: inline-flex; align-items: center; gap: 6px;">
                                        View Full News Portal &rarr;
                                    </a>
                                </div>

                                <hr style="border: none; border-top: 2px solid #F1F5F9; margin: 0 0 20px 0;">

                                <!-- BAR PENAPIS KATEGORI (CATEGORY FILTERS) -->
                                <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 24px;">
                                    <span style="font-weight: 900; font-size: 0.9rem; color: #636E72; display: flex; align-items: center; gap: 6px; margin-right: 4px;">
                                        🔍 Category:
                                    </span>
                                    <button type="button" class="nb-filter-btn active" onclick="filterNewsCategory('all', this)">All</button>
                                    <button type="button" class="nb-filter-btn" onclick="filterNewsCategory('Academic Focus', this)">Academic Focus</button>
                                    <button type="button" class="nb-filter-btn" onclick="filterNewsCategory('Announcement', this)">Announcement</button>
                                    <button type="button" class="nb-filter-btn" onclick="filterNewsCategory('Event', this)">Event</button>
                                    <button type="button" class="nb-filter-btn" onclick="filterNewsCategory('Holiday', this)">Holiday</button>
                                    <button type="button" class="nb-filter-btn" onclick="filterNewsCategory('Nutrition', this)">Nutrition</button>
                                </div>

                                <!-- SENARAI KAD BERITA (3 KOLOM GRID ATOMIK) -->
                                <c:choose>
                                    <%-- KETIKA DATABASE KOSONG / TIADA BERITA --%>
                                    <c:when test="${empty newsList}">
                                        <div style="background: #FAF5EF; border: 3px dashed #2D3436; border-radius: 20px; padding: 36px 20px; text-align: center; margin: 10px 0;">
                                            <p style="margin: 0; font-size: 1.1rem; font-weight: 900; color: #2D3436;">
                                                📫 Tiada berita atau pengumuman buat masa ini.
                                            </p>
                                            <p style="margin: 6px 0 0 0; font-size: 0.88rem; color: #636E72; font-weight: 600;">
                                                Sila semak semula kelak untuk sebarang makluman terkini daripada pihak tadika.
                                            </p>
                                        </div>
                                    </c:when>

                                    <%-- KETIKA ADA BERITA DALAM DATABASE --%>
                                    <c:otherwise>
                                        <div id="newsGridList" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
                                            <c:forEach var="news" items="${newsList}">
                                                <div class="nb-card-item" data-category="${news.newsCategory}">
                                                    <div>
                                                        <!-- TAG KATEGORI & PINNED -->
                                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; gap: 8px;">
                                                            <span class="nb-badge ${news.newsCategory == 'ALERT' ? 'nb-badge-alert' : (news.newsCategory == 'Academic Focus' ? 'nb-badge-academic' : (news.newsCategory == 'Event' ? 'nb-badge-event' : 'nb-badge-default'))}">
                                                                ${news.newsCategory != null ? news.newsCategory : 'GENERAL'}
                                                            </span>
                                                            <c:if test="${news.pinned}">
                                                                <span class="nb-badge-pinned">
                                                                    📌 PINNED
                                                                </span>
                                                            </c:if>
                                                        </div>

                                                        <!-- TAJUK BERITA -->
                                                        <h4 style="margin: 0 0 8px 0; font-size: 1.05rem; font-weight: 900; color: #2D3436; line-height: 1.35;">
                                                            ${news.newsTitle}
                                                        </h4>

                                                        <!-- KANDUNGAN RINGKAS -->
                                                        <p style="margin: 0 0 16px 0; font-size: 0.85rem; color: #4B5563; line-height: 1.5; font-weight: 500; display: -webkit-box; -webkit-line-clamp: 4; -webkit-box-orient: vertical; overflow: hidden;">
                                                            ${news.newsContent}
                                                        </p>
                                                    </div>

                                                    <!-- BAHAGIAN BAWAH (GURU & TARIKH) -->
                                                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.78rem; font-weight: 700; color: #636E72; border-top: 1.5px dashed #E2E8F0; padding-top: 12px; margin-top: auto;">
                                                        <span style="display: flex; align-items: center; gap: 4px; max-width: 65%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                            <span style="color: #6366F1;">👤</span> Teacher #${news.teacherID != 0 ? news.teacherID : 'Admin'}
                                                        </span>
                                                        <span style="display: flex; align-items: center; gap: 4px;">
                                                            <span style="color: #F97316;">📅</span> ${news.newsDate != null ? news.newsDate : '2026-11-01'}
                                                        </span>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                            </div>

                        </c:otherwise>
                    </c:choose>

                </div>

            </div>
            
        </main>
    </div>

    <script>
        function toggleChildDropdown() {
            const menu = document.getElementById('childDropdownMenu');
            if (menu) {
                menu.classList.toggle('show');
            }
        }

        function filterNewsCategory(categoryName, btnElement) {
            document.querySelectorAll('.nb-filter-btn').forEach(b => b.classList.remove('active'));
            btnElement.classList.add('active');

            const cards = document.querySelectorAll('.nb-card-item');
            cards.forEach(card => {
                const cat = card.getAttribute('data-category');
                if (categoryName === 'all' || (cat && cat.toLowerCase() === categoryName.toLowerCase())) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        window.onclick = function(event) {
            if (!event.target.closest('#childSelectorBtn')) {
                const dropdowns = document.getElementsByClassName("dropdown-menu-list");
                for (let i = 0; i < dropdowns.length; i++) {
                    const openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) {
                        openDropdown.classList.remove('show');
                    }
                }
            }
        }
    </script>
</body>
</html>