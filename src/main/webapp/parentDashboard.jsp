<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Parent"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix - Parent Platform</title>
    
    <!-- CSS FOR MAIN LAYOUT & NEOMBRUTALISM DESIGN (EMBEDDED) -->
    <style>
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
            height: 100vh; /* Full screen height */
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
            overflow: hidden; /* Prevent full-page scroll */
            background-color: #FAF5EF;
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background-color: #FFFFFF;
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px 32px;
            overflow-y: auto; /* Scroll only inside the content area */
        }

        /* --- PARENT PLATFORM CONTENT STYLING --- */
        .parent-platform-root {
            display: flex;
            flex-direction: column;
            gap: 24px;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Banner Card */
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
            color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; flex-shrink: 0;
        }
        .banner-title-group { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 4px; }
        .banner-title { font-size: 1.5rem; font-weight: 900; color: #2D3436; margin: 0; }
        .banner-badge {
            background-color: #FFB3C6; color: #2D3436; font-size: 10px; font-weight: 900; 
            text-transform: uppercase; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436;
        }
        .banner-subtitle { font-size: 0.85rem; color: #636E72; margin: 0; }
        .banner-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .info-pill { border: 2.5px solid; border-radius: 16px; padding: 10px 16px; display: flex; flex-direction: column; }
        .pill-pink { background-color: #FFF0F3; border-color: #FFB3C6; }
        .pill-amber { background-color: #FFF9E6; border-color: #FFE082; }
        .pill-label { font-size: 10px; font-weight: 800; text-transform: uppercase; margin-bottom: 2px; }
        .pill-value { font-size: 1.1rem; font-weight: 900; color: #2D3436; display: flex; align-items: center; gap: 6px; }

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
            width: 32px; height: 32px; border-radius: 10px; display: flex; align-items: center; 
            justify-content: center; border: 1.5px solid currentColor;
        }
        .bg-purple { background-color: #F3E8FF; color: #7E22CE; }
        .bg-amber { background-color: #FEF3C7; color: #B45309; }
        .bg-emerald { background-color: #D1FAE5; color: #059669; }
        .bg-rose { background-color: #FFE4E6; color: #E11D48; }
        .metric-value { font-size: 2rem; font-weight: 900; color: #2D3436; margin: 0 0 4px 0; line-height: 1; }
        .metric-sub { font-size: 11px; color: #636E72; margin: 0; }

        /* Dropdown */
        .dropdown-container { position: relative; width: 100%; z-index: 20; }
        .dropdown-btn {
            width: 100%; background-color: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px; 
            padding: 16px 20px; display: flex; align-items: center; justify-content: space-between; 
            box-shadow: 4px 4px 0px 0px #2D3436; cursor: pointer; transition: all 0.15s ease; text-align: left;
        }
        .dropdown-btn:hover { background-color: #FFF0F3; }
        .dropdown-menu {
            position: absolute; top: 110%; left: 0; right: 0; background-color: #FFFFFF; 
            border: 3px solid #2D3436; border-radius: 24px; box-shadow: 6px 6px 0px 0px #2D3436; 
            padding: 16px; z-index: 40; display: none;
        }
        .dropdown-menu.show { display: block; }
        .child-option {
            width: 100%; display: flex; align-items: center; justify-content: space-between; 
            padding: 12px; border: 2px solid transparent; border-radius: 16px; background: none; 
            cursor: pointer; text-align: left; transition: all 0.15s ease; text-decoration: none; color: inherit;
        }
        .child-option:hover { border-color: #2D3436; background-color: #FFF0F3; }
        .child-option.selected { background-color: #FFF0F3; border-color: #2D3436; box-shadow: 3px 3px 0px #2D3436; }

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
            margin-top: 24px;
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
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2D3436;
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
            display: flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .btn-view-portal:hover {
            background-color: #F8FAFC;
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
            display: flex;
            align-items: center;
            gap: 4px;
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
            .news-grid { grid-template-columns: 1fr 1fr; } /* 2 Kolum untuk skrin besar */
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
            display: flex;
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
            margin-top: 12px;
            padding-top: 16px;
        }
        .nc-author, .nc-date {
            font-size: 0.8rem;
            font-weight: 700;
            display: flex;
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
                    
                    <!-- 1. Parent Title & Role Banner -->
                    <div class="banner-card">
                        <div class="banner-left">
                            <div class="heart-icon-box">
                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                                </svg>
                            </div>
                            <div>
                                <div class="banner-title-group">
                                    <h1 class="banner-title">Keedflix Parent & Family Platform</h1>
                                    <span class="banner-badge">Family Connection Hub</span>
                                </div>
                                <p class="banner-subtitle">
                                    Logged in as: <strong>${parentName}</strong> (${parentTitle}) • Connected to <strong>${currentStudent.name}</strong>
                                </p>
                            </div>
                        </div>

                        <div class="banner-right">
                            <div class="info-pill pill-pink">
                                <span class="pill-label" style="color: #BE185D;">Linked Pupil</span>
                                <span class="pill-value">
                                    <span>${currentStudent.avatarSeed}</span>
                                    <span>${currentStudent.name}</span>
                                </span>
                            </div>
                            <div class="info-pill pill-amber">
                                <span class="pill-label" style="color: #92400E;">Enrolled Classroom</span>
                                <span class="pill-value">${currentStudent.className}</span>
                            </div>
                        </div>
                    </div>

                    <!-- 2. Quick Metrics Cards -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Developmental Score</span>
                                <div class="metric-icon-box bg-purple">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                </div>
                            </div>
                            <p class="metric-value">${averageLevel}%</p>
                            <p class="metric-sub">Average mastery across 3 learning areas</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Photo Evidence</span>
                                <div class="metric-icon-box bg-amber">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle></svg>
                                </div>
                            </div>
                            <p class="metric-value">${photoProofsCount}</p>
                            <p class="metric-sub">Classroom photos verified by educators</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Milestones Achieved</span>
                                <div class="metric-icon-box bg-emerald">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                                </div>
                            </div>
                            <p class="metric-value">${completedMilestones}</p>
                            <p class="metric-sub">Certificated early learning milestones</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Academic Cycle</span>
                                <div class="metric-icon-box bg-rose">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                </div>
                            </div>
                            <p class="metric-value">${academicCycle}</p>
                            <p class="metric-sub">Official term portfolio certified</p>
                        </div>
                    </div>

                    <!-- 3. Registered Child Dropdown -->
                    <c:if test="${hasMultipleChildren}">
                        <div class="dropdown-container">
                            <button class="dropdown-btn" id="dropdownBtn" onclick="toggleDropdown()">
                                <div style="display: flex; align-items: center; gap: 16px;">
                                    <span style="font-size: 2rem;">${currentStudent.avatarSeed}</span>
                                    <div>
                                        <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                            <span style="font-size: 1.2rem; font-weight: 900; color: #2D3436;">${currentStudent.name}</span>
                                            <span style="font-size: 10px; font-weight: 800; background: #FFB3C6; padding: 2px 8px; border-radius: 10px; border: 1px solid #2D3436;">${currentStudent.className}</span>
                                        </div>
                                        <span style="font-size: 12px; color: #636E72; font-weight: 600;">Age: ${currentStudent.age} • Click to switch child</span>
                                    </div>
                                </div>
                                <div>
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2D3436" stroke-width="2.5">
                                        <polyline points="6 9 12 15 18 9"></polyline>
                                    </svg>
                                </div>
                            </button>

                            <!-- Dropdown Menu List -->
                            <div class="dropdown-menu" id="dropdownMenu">
                                <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; margin-bottom: 10px;">Select Registered Child</p>
                                
                                <c:forEach var="child" items="${registeredChildren}">
                                    <a href="${pageContext.request.contextPath}/ParentPlatformServlet?studentId=${child.id}" class="child-option ${child.id == currentStudent.id ? 'selected' : ''}">
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <span style="font-size: 1.5rem; background: #FFF; border: 2px solid #2D3436; border-radius: 50%; width: 40px; height: 40px; display: flex; justify-content: center; align-items: center;">${child.avatarSeed}</span>
                                            <div>
                                                <p style="font-size: 14px; font-weight: 900; margin: 0; color: #2D3436;">${child.name}</p>
                                                <p style="font-size: 11px; color: #636E72; margin: 0;">${child.className} • Age: ${child.age}</p>
                                            </div>
                                        </div>
                                        <c:if test="${child.id == currentStudent.id}">
                                            <div style="background: #2D3436; color: white; padding: 4px; border-radius: 50%;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                            </div>
                                        </c:if>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- 4. Child Developmental Balance Charts Row -->
					<div class="charts-row">
					    
					    <!-- Kotak Radar Chart -->
					    <div style="width: 100%; height: 480px; border-radius: 24px;">
					        <iframe src="${pageContext.request.contextPath}/RadarChartServlet?studentId=${currentStudent.id}" 
					                width="100%" 
					                height="100%" 
					                frameborder="0" 
					                scrolling="no"
					                title="Radar Chart">
					        </iframe>
					    </div>
					    
					    <!-- Kotak Trend Chart -->
					    <div style="width: 100%; height: 480px; border-radius: 24px;">
					        <iframe src="${pageContext.request.contextPath}/TrendChartServlet?studentId=${currentStudent.id}" 
					                width="100%" 
					                height="100%" 
					                frameborder="0" 
					                scrolling="no"
					                title="Trend Chart">
					        </iframe>
					    </div>
					
					</div>
					
					<!-- 5. Keedflix Centre News & Weekly Bulletins -->
                    <div class="news-section">
                        
                        <!-- Header Berita -->
                        <div class="news-header-container">
                            <div class="news-header-left">
                                <div class="news-icon-box">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                        <path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-2 2Zm0 0a2 2 0 0 1-2-2v-9c0-1.1.9-2 2-2h2"></path>
                                        <path d="M18 14h-8"></path>
                                        <path d="M15 18h-5"></path>
                                        <path d="M10 6h8v4h-8z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <h2 class="news-title">
                                        <span style="color: #FFB3C6; font-size: 1.8rem; line-height: 0;">•</span> 
                                        Keedflix Centre News & Weekly Bulletins
                                    </h2>
                                    <p class="news-subtitle">Curriculum updates, reading & counting activities, and upcoming centre events for families</p>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/NewsServlet" class="btn-view-portal">
							    View Full News Portal 
							    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
							</a>
                        </div>

                        <!-- Penapis Kategori -->
                        <div class="news-filters">
                            <span class="filter-label">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
                                Category:
                            </span>
                            <button class="filter-btn active">All</button>
                            <button class="filter-btn">Academic Focus</button>
                            <button class="filter-btn">Announcement</button>
                            <button class="filter-btn">Event</button>
                            <button class="filter-btn">Holiday</button>
                            <button class="filter-btn">Nutrition</button>
                        </div>

                        <!-- Grid Kad Berita -->
                        <div class="news-grid">
                            
                            <!-- Kad Berita 1 -->
                            <div class="news-card">
                                <div class="nc-header">
                                    <span class="nc-tag tag-academic">ACADEMIC FOCUS</span>
                                    <span class="nc-pinned">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2.5"><path d="M12 17v5"/><path d="M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H8a2 2 0 0 0 0 4 1 1 0 0 1 1 1z"/></svg>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">September Literacy Expedition: Phonics & CVC Blending Week</h3>
                                <p class="nc-excerpt">This week across all kindergarten classrooms, teachers and students are embarking on our interactive Phonics & Letter Blending Expedition! Children will be building tactile 3-letter CVC word cubes and matching...</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                        Eleanor Ward (Princi...
                                    </span>
                                    <span class="nc-date">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                        2026-09-12
                                    </span>
                                </div>
                            </div>

                            <!-- Kad Berita 2 -->
                            <div class="news-card">
                                <div class="nc-header">
                                    <span class="nc-tag tag-event">EVENT</span>
                                    <span class="nc-pinned">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2.5"><path d="M12 17v5"/><path d="M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H8a2 2 0 0 0 0 4 1 1 0 0 1 1 1z"/></svg>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">Autumn Counting Carnival & Family Math Day</h3>
                                <p class="nc-excerpt">Join us on Friday, September 25th for our annual Kindergarten Math & Counting Carnival. Interactive stations include 1-to-1 acorn counting, numeral scavenger hunts, and giant floor number line hops....</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                        Eleanor Ward (Princi...
                                    </span>
                                    <span class="nc-date">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
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

    <!-- SCRIPT FOR CHILD DROPDOWN INTERACTIVITY -->
    <script>
        function toggleDropdown() {
            const menu = document.getElementById('dropdownMenu');
            if(menu) {
                menu.classList.toggle('show');
            }
        }

        window.onclick = function(event) {
            if (!event.target.closest('.dropdown-container')) {
                const dropdowns = document.getElementsByClassName("dropdown-menu");
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