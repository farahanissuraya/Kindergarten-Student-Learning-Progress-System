<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="bean.Parent"%>
<%@ page import="util.IconUtil"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix - Parent Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    
    <!-- CSS FOR MAIN LAYOUT & NEOBRUTALISM DESIGN (EMBEDDED) -->
    <style>
        * { box-sizing: border-box; }
        body, html {
            margin: 0; 
            padding: 0; 
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF;
        }

        /* Main Wrapper (Left & Right Split) */
        .app-layout {
            display: flex;
            height: 100vh;
            width: 100%;
        }

        /* Left Sidebar Wrapper */
        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background-color: #FFFFFF;
            z-index: 10;
        }

        /* Right Content Wrapper (Header + Body) */
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
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px 32px;
            overflow-y: auto;
        }

        /* --- PARENT PLATFORM CONTENT STYLING --- */
        .parent-platform-root {
            display: flex;
            flex-direction: column;
            gap: 24px;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Interactive Banner Card + Child Switcher Dropdown */
        .banner-dropdown-wrapper {
            position: relative;
            width: 100%;
            z-index: 30;
        }

        .banner-card {
            width: 100%;
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 22px 24px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            gap: 16px;
            cursor: pointer;
            text-align: left;
            transition: all 0.15s ease;
        }
        @media (min-width: 1024px) {
            .banner-card { flex-direction: row; align-items: center; justify-content: space-between; }
        }
        .banner-card:hover {
            background-color: #FFFDF9;
            transform: translate(-1px, -1px);
            box-shadow: 6px 6px 0px 0px #2D3436;
        }

        .banner-left { display: flex; align-items: center; gap: 16px; }
        .heart-icon-box {
            width: 60px; height: 60px; border-radius: 16px; background-color: #FFB3C6; 
            border: 3px solid #2D3436; display: flex; align-items: center; justify-content: center; 
            color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; flex-shrink: 0;
        }
        .banner-title-group { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 4px; }
        .banner-title { font-size: 1.45rem; font-weight: 900; color: #2D3436; margin: 0; }
        .banner-badge {
            background-color: #FFB3C6; color: #2D3436; font-size: 10px; font-weight: 900; 
            text-transform: uppercase; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436;
        }
        .banner-subtitle { font-size: 0.85rem; color: #636E72; margin: 0; font-weight: 600; }

        .banner-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .info-pill { border: 2.5px solid; border-radius: 16px; padding: 8px 14px; display: flex; flex-direction: column; }
        .pill-pink { background-color: #FFF0F3; border-color: #FFB3C6; }
        .pill-amber { background-color: #FFF9E6; border-color: #FFE082; }
        .pill-label { font-size: 10px; font-weight: 800; text-transform: uppercase; margin-bottom: 2px; }
        .pill-value { font-size: 1rem; font-weight: 900; color: #2D3436; display: flex; align-items: center; gap: 6px; }

        .banner-chevron {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            border: 2.5px solid #2D3436;
            background-color: #FAF5EF;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2D3436;
            flex-shrink: 0;
            transition: transform 0.2s ease, background-color 0.2s ease;
        }
        .banner-dropdown-wrapper.open .banner-chevron {
            transform: rotate(180deg);
            background-color: #FFD02C;
        }

        /* Dropdown Menu List Under Banner */
        .banner-child-menu {
            position: absolute;
            top: calc(100% + 10px);
            left: 0;
            right: 0;
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            box-shadow: 6px 6px 0px 0px #2D3436;
            padding: 18px 20px;
            z-index: 50;
            display: none;
        }
        .banner-child-menu.show { display: block; }

        .child-option {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            border: 2.5px solid transparent;
            border-radius: 16px;
            background: #FFFFFF;
            cursor: pointer;
            text-align: left;
            transition: all 0.15s ease;
            text-decoration: none;
            color: #2D3436;
            margin-bottom: 8px;
        }
        .child-option:last-child { margin-bottom: 0; }
        .child-option:hover { border-color: #2D3436; background-color: #FFF0F3; }
        .child-option.selected {
            background-color: #FFF5F7;
            border-color: #2D3436;
            box-shadow: 3px 3px 0px 0px #2D3436;
        }

        /* Metrics Grid */
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
            width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; 
            justify-content: center; border: 2px solid #2D3436; box-shadow: 2px 2px 0px 0px #2D3436;
        }
        .bg-purple { background-color: #F3E8FF; color: #7E22CE; }
        .bg-amber { background-color: #FEF3C7; color: #B45309; }
        .bg-emerald { background-color: #D1FAE5; color: #059669; }
        .bg-rose { background-color: #FFE4E6; color: #E11D48; }
        .metric-value { font-size: 2rem; font-weight: 900; color: #2D3436; margin: 0 0 4px 0; line-height: 1; }
        .metric-sub { font-size: 11px; color: #636E72; margin: 0; }

        /* Charts Row */
        .charts-row { display: grid; grid-template-columns: 1fr; gap: 24px; }
        @media (min-width: 1024px) { .charts-row { grid-template-columns: 1fr 1fr; } }
        
        /* --- 5. NEWS & BULLETINS SECTION --- */
        .news-section {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .news-header-container {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #F1F5F9;
            padding-bottom: 16px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .news-header-left {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .news-icon-box {
            width: 52px;
            height: 52px;
            background-color: #FFB3C6;
            border: 2.5px solid #2D3436;
            border-radius: 14px;
            box-shadow: 3px 3px 0px 0px #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2D3436;
            flex-shrink: 0;
        }

        .news-title {
            font-size: 1.4rem;
            font-weight: 900;
            color: #2D3436;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .news-subtitle {
            font-size: 0.9rem;
            color: #636E72;
            margin: 4px 0 0 0;
            font-weight: 500;
        }

        .btn-view-portal {
            background-color: #FFFFFF;
            border: 2.5px solid #2D3436;
            border-radius: 999px;
            padding: 10px 20px;
            font-size: 0.85rem;
            font-weight: 900;
            color: #2D3436;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .btn-view-portal:hover {
            background-color: #FFD02C;
            box-shadow: 3px 3px 0px 0px #2D3436;
            transform: translate(-1px, -1px);
        }

        /* Penapis Kategori (Filters) */
        .news-filters {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 8px;
        }
        .filter-label {
            font-size: 0.8rem;
            color: #636E72;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-btn {
            background-color: #FFFFFF;
            border: 2px solid #2D3436;
            border-radius: 999px;
            padding: 6px 14px;
            font-size: 0.8rem;
            font-weight: 800;
            color: #2D3436;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .filter-btn.active {
            background-color: #FFB3C6;
            box-shadow: 2px 2px 0px 0px #2D3436;
        }
        .filter-btn:not(.active):hover {
            background-color: #F1F5F9;
        }

        /* Grid Kad Berita */
        .news-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 16px;
        }
        @media (min-width: 1024px) {
            .news-grid { grid-template-columns: 1fr 1fr; }
        }

        .news-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            position: relative;
            display: flex;
            flex-direction: column;
            gap: 12px;
            z-index: 1;
        }
        
        /* Inner Yellow Border Hack */
        .news-card::after {
            content: '';
            position: absolute;
            top: 4px; left: 4px; right: 4px; bottom: 4px;
            border: 2.5px solid #FFD02C;
            border-radius: 10px;
            pointer-events: none;
            z-index: -1;
        }

        .nc-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nc-tag {
            font-size: 0.65rem;
            font-weight: 900;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 999px;
            border: 1.5px solid currentColor;
            letter-spacing: 0.05em;
        }
        .tag-academic { color: #6C5CE7; background-color: #F3E8FF; }
        .tag-event { color: #E11D48; background-color: #FFE4E6; }
        
        .nc-pinned {
            background-color: #FFD02C;
            color: #2D3436;
            border: 2px solid #2D3436;
            font-size: 0.65rem;
            font-weight: 900;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .nc-title {
            font-size: 1.15rem;
            font-weight: 900;
            color: #2D3436;
            margin: 4px 0;
            line-height: 1.4;
        }
        .nc-excerpt {
            font-size: 0.85rem;
            color: #4B5563;
            margin: 0;
            line-height: 1.6;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            font-weight: 500;
        }

        .nc-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 12px;
            border-top: 2px dashed #E2E8F0;
        }
        .nc-author, .nc-date {
            font-size: 0.8rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .nc-author { color: #6C5CE7; }
        .nc-date { color: #FF6B6B; }
    </style>
</head>
<body>

    <div class="app-layout">
        
        <!-- 1. LEFT: SIDEBAR -->
        <aside class="app-sidebar-wrapper">
            <jsp:include page="sidebar.jsp" />
        </aside>

        <!-- 2. RIGHT: MAIN (HEADER + CONTENT) -->
        <main class="app-main-wrapper">
            
            <!-- A. HEADER SECTION -->
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <!-- B. CONTENT BODY SECTION -->
            <div class="app-content-body">
                
                <div class="parent-platform-root" id="parent-platform-root">
                    
                    <!-- 1. Parent Title & Interactive Child Switcher Banner -->
                    <div class="banner-dropdown-wrapper" id="bannerDropdownWrapper">
                        <button type="button" class="banner-card" onclick="toggleBannerDropdown()">
                            <div class="banner-left">
                                <div class="heart-icon-box">
                                    <%= IconUtil.icon("Heart", "icon-lg") %>
                                </div>
                                <div>
                                    <div class="banner-title-group">
                                        <h1 class="banner-title">Welcome back, <strong>${parentName}</strong></h1>
                                    </div>
                                    <p class="banner-subtitle">
                                        Logged in as: ${parentTitle} • Connected to <strong>${currentStudent.name}</strong>
                                    </p>
                                </div>
                            </div>

                            <div class="banner-right">
                                <div class="banner-chevron" title="Tukar pilihan anak">
                                    <%= IconUtil.icon("ChevronDown", "icon-md") %>
                                </div>
                            </div>
                        </button>

                        <!-- Dropdown Menu List (Senarai Anak Berdaftar Under Parent) -->
                        <div class="banner-child-menu" id="bannerChildMenu">
                            <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; letter-spacing: 0.04em; margin: 0 0 12px 4px;">
                                SELECT REGISTERED CHILD (${not empty registeredChildren ? registeredChildren.size() : 1})
                            </p>
                            
                            <c:choose>
                                <c:when test="${not empty registeredChildren}">
                                    <c:forEach var="child" items="${registeredChildren}">
                                        <a href="${pageContext.request.contextPath}/parentDashboard?studentId=${child.id}" class="child-option ${child.id == currentStudent.id ? 'selected' : ''}">
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <span style="background: ${child.id == currentStudent.id ? '#FFB3C6' : '#FAF5EF'}; border: 2px solid #2D3436; border-radius: 50%; width: 42px; height: 42px; display: flex; justify-content: center; align-items: center; flex-shrink: 0;">
                                                    <%= IconUtil.icon("Smile", "icon-sm") %>
                                                </span>
                                                <div>
                                                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                                        <p style="font-size: 15px; font-weight: 900; margin: 0; color: #2D3436;">${child.name}</p>
                                                        <c:if test="${child.id == currentStudent.id}">
                                                            <span style="background: #FFD02C; color: #2D3436; border: 1.5px solid #2D3436; font-size: 10px; font-weight: 900; padding: 1px 8px; border-radius: 999px;">
                                                                Current
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                    <p style="font-size: 12px; color: #636E72; margin: 2px 0 0 0; font-weight: 600;">${child.className} • Age: ${child.age}</p>
                                                </div>
                                            </div>
                                            <c:if test="${child.id == currentStudent.id}">
                                                <div style="background: #2D3436; color: white; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                                    <%= IconUtil.icon("Check", "icon-xs") %>
                                                </div>
                                            </c:if>
                                        </a>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="child-option selected" style="cursor: default;">
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <span style="background: #FFB3C6; border: 2px solid #2D3436; border-radius: 50%; width: 42px; height: 42px; display: flex; justify-content: center; align-items: center;">
                                                <%= IconUtil.icon("Smile", "icon-sm") %>
                                            </span>
                                            <div>
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <p style="font-size: 15px; font-weight: 900; margin: 0; color: #2D3436;">${currentStudent.name}</p>
                                                    <span style="background: #FFD02C; color: #2D3436; border: 1.5px solid #2D3436; font-size: 10px; font-weight: 900; padding: 1px 8px; border-radius: 999px;">Current</span>
                                                </div>
                                                <p style="font-size: 12px; color: #636E72; margin: 2px 0 0 0; font-weight: 600;">${currentStudent.className} • Age: ${currentStudent.age}</p>
                                            </div>
                                        </div>
                                        <div style="background: #2D3436; color: white; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                            <%= IconUtil.icon("Check", "icon-xs") %>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- 2. Quick Metrics Cards -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Developmental Score</span>
                                <div class="metric-icon-box bg-purple">
                                    <%= IconUtil.icon("Award", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${averageLevel}%</p>
                            <p class="metric-sub">Average mastery across 3 learning areas</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Photo Evidence</span>
                                <div class="metric-icon-box bg-amber">
                                    <%= IconUtil.icon("Camera", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${photoProofsCount}</p>
                            <p class="metric-sub">Classroom photos verified by educators</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Milestones Achieved</span>
                                <div class="metric-icon-box bg-emerald">
                                    <%= IconUtil.icon("CheckCircle", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${completedMilestones}</p>
                            <p class="metric-sub">Certificated early learning milestones</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Academic Cycle</span>
                                <div class="metric-icon-box bg-rose">
                                    <%= IconUtil.icon("Calendar", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${academicCycle}</p>
                            <p class="metric-sub">Official term portfolio certified</p>
                        </div>
                    </div>

                    <!-- 3. Child Developmental Balance Charts Row -->
                    <div class="charts-row">
                        <!-- Kotak Radar Chart -->
                        <div style="width: 100%; height: 560px;">
                            <iframe src="${pageContext.request.contextPath}/RadarChartServlet?studentId=${currentStudent.id}" 
                                    width="100%" 
                                    height="100%" 
                                    frameborder="0" 
                                    scrolling="no"
                                    allowtransparency="true"
                                    style="background: transparent; display: block;"
                                    title="Radar Chart">
                            </iframe>
                        </div>
                        
                        <!-- Kotak Trend Chart -->
                        <div style="width: 100%; height: 560px;">
                            <iframe src="${pageContext.request.contextPath}/TrendChartServlet?studentId=${currentStudent.id}" 
                                    width="100%" 
                                    height="100%" 
                                    frameborder="0" 
                                    scrolling="no"
                                    allowtransparency="true"
                                    style="background: transparent; display: block;"
                                    title="Trend Chart">
                            </iframe>
                        </div>
                    </div>
                    
                    <!-- 4. Keedflix Centre News & Weekly Bulletins -->
                    <div class="news-section">
                        
                        <!-- Header Berita -->
                        <div class="news-header-container">
                            <div class="news-header-left">
                                <div class="news-icon-box">
                                    <%= IconUtil.icon("Newspaper", "icon-md") %>
                                </div>
                                <div>
                                    <h2 class="news-title">
                                        Keedflix Centre News &amp; Weekly Bulletins
                                    </h2>
                                    <p class="news-subtitle">Curriculum updates, reading &amp; counting activities, and upcoming centre events for families</p>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/NewsServlet" class="btn-view-portal">
                                <span>View Full News Portal</span>
                                <%= IconUtil.icon("ArrowRight", "icon-sm") %>
                            </a>
                        </div>

                        <!-- Penapis Kategori -->
                        <div class="news-filters">
                            <span class="filter-label">
                                <%= IconUtil.icon("Filter", "icon-xs") %>
                                Category:
                            </span>
                            <button type="button" class="filter-btn active" onclick="filterNews('All', this)">All</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Academic Focus', this)">Academic Focus</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Announcement', this)">Announcement</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Event', this)">Event</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Holiday', this)">Holiday</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Nutrition', this)">Nutrition</button>
                        </div>

                        <!-- Grid Kad Berita -->
                        <div class="news-grid" id="parentNewsGrid">
                            
                            <!-- Kad Berita 1 -->
                            <div class="news-card" data-category="Academic Focus">
                                <div class="nc-header">
                                    <span class="nc-tag tag-academic">ACADEMIC FOCUS</span>
                                    <span class="nc-pinned">
                                        <%= IconUtil.icon("Pin", "icon-xs") %>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">September Literacy Expedition: Phonics &amp; CVC Blending Week</h3>
                                <p class="nc-excerpt">This week across all kindergarten classrooms, teachers and students are embarking on our interactive Phonics &amp; Letter Blending Expedition! Children will be building tactile 3-letter CVC word cubes and matching...</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <%= IconUtil.icon("User", "icon-xs") %>
                                        Eleanor Ward (Principal)
                                    </span>
                                    <span class="nc-date">
                                        <%= IconUtil.icon("Calendar", "icon-xs") %>
                                        2026-09-12
                                    </span>
                                </div>
                            </div>

                            <!-- Kad Berita 2 -->
                            <div class="news-card" data-category="Event">
                                <div class="nc-header">
                                    <span class="nc-tag tag-event">EVENT</span>
                                    <span class="nc-pinned">
                                        <%= IconUtil.icon("Pin", "icon-xs") %>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">Autumn Counting Carnival &amp; Family Math Day</h3>
                                <p class="nc-excerpt">Join us on Friday, September 25th for our annual Kindergarten Math &amp; Counting Carnival. Interactive stations include 1-to-1 acorn counting, numeral scavenger hunts, and giant floor number line hops....</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <%= IconUtil.icon("User", "icon-xs") %>
                                        Eleanor Ward (Principal)
                                    </span>
                                    <span class="nc-date">
                                        <%= IconUtil.icon("Calendar", "icon-xs") %>
                                        2026-09-08
                                    </span>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>

            </div>
            
        </main>
    </div>

    <!-- SCRIPT FOR INTERACTIVITY -->
    <script>
        function toggleBannerDropdown() {
            const wrapper = document.getElementById('bannerDropdownWrapper');
            const menu = document.getElementById('bannerChildMenu');
            if (wrapper && menu) {
                wrapper.classList.toggle('open');
                menu.classList.toggle('show');
            }
        }

        function filterNews(category, btn) {
            document.querySelectorAll('.news-filters .filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            document.querySelectorAll('#parentNewsGrid .news-card').forEach(card => {
                if (category === 'All' || card.dataset.category === category) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        window.onclick = function(event) {
            if (!event.target.closest('#bannerDropdownWrapper')) {
                const wrapper = document.getElementById('bannerDropdownWrapper');
                const menu = document.getElementById('bannerChildMenu');
                if (wrapper) wrapper.classList.remove('open');
                if (menu) menu.classList.remove('show');
            }
        };
    </script>

    <jsp:include page="icons.jsp" />
</body>
</html>