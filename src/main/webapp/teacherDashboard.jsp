<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix - Teacher Platform</title>

    <style>
        /* --- GLOBAL & LAYOUT --- */
        body, html {
            margin: 0; padding: 0; height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF;
        }
        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background-color: #FFFFFF; z-index: 10; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; background-color: #FAF5EF; }
        .app-header-wrapper { flex-shrink: 0; background-color: #FFFFFF; }
        .app-content-body { flex-grow: 1; padding: 24px 32px; overflow-y: auto; }
        
        .teacher-platform-root {
            display: flex; flex-direction: column; gap: 24px; max-width: 1200px; margin: 0 auto;
        }

        /* --- 1. BANNER CARD --- */
        .banner-card {
            background-color: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px;
            padding: 24px; box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex; flex-direction: column; gap: 16px;
        }
        @media (min-width: 1024px) {
            .banner-card { flex-direction: row; align-items: center; justify-content: space-between; }
        }
        .banner-left { display: flex; align-items: center; gap: 16px; }
        .icon-box-yellow {
            width: 64px; height: 64px; border-radius: 16px; background-color: #FFD02C; 
            border: 3px solid #2D3436; display: flex; align-items: center; justify-content: center; 
            color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; flex-shrink: 0;
        }
        .banner-title-group { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 4px; }
        .banner-title { font-size: 1.5rem; font-weight: 900; color: #2D3436; margin: 0; }
        .banner-badge {
            background-color: #FFD02C; color: #2D3436; font-size: 10px; font-weight: 900; 
            text-transform: uppercase; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436;
        }
        .banner-subtitle { font-size: 0.85rem; color: #636E72; margin: 0; }
        .banner-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        
        .info-pill { border: 2.5px solid; border-radius: 16px; padding: 10px 16px; display: flex; flex-direction: column; }
        .pill-amber { background-color: #FFF9E6; border-color: #FFE082; }
        .pill-purple { background-color: #F3E8FF; border-color: #D8B4FE; }
        .pill-label { font-size: 10px; font-weight: 800; text-transform: uppercase; margin-bottom: 2px; }
        .pill-value { font-size: 1.1rem; font-weight: 900; color: #2D3436; }

        /* --- 2. METRICS GRID --- */
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
        .bg-amber { background-color: #FFF9E6; color: #B45309; }
        .bg-purple { background-color: #F3E8FF; color: #7E22CE; }
        .bg-emerald { background-color: #D1FAE5; color: #059669; }
        .bg-rose { background-color: #FFE4E6; color: #E11D48; }
        .metric-value { font-size: 2rem; font-weight: 900; color: #2D3436; margin: 0 0 4px 0; line-height: 1; }
        .metric-sub { font-size: 11px; color: #636E72; margin: 0; }

        /* --- 3. STUDENT SELECTOR DROPDOWN --- */
        .dropdown-container { position: relative; width: 100%; z-index: 20; }
        .dropdown-btn {
            width: 100%; background-color: #FFFFFF; border: 3px solid #2D3436; border-radius: 999px; 
            padding: 14px 24px; display: flex; align-items: center; justify-content: space-between; 
            box-shadow: 4px 4px 0px 0px #2D3436; cursor: pointer; transition: all 0.15s ease; text-align: left;
        }
        .dropdown-btn:hover { background-color: #FFF9E6; }
        .dropdown-btn:active { transform: translate(2px, 2px); box-shadow: 2px 2px 0px 0px #2D3436; }
        
        .dropdown-menu {
            position: absolute; top: 110%; left: 0; right: 0; background-color: #FFFFFF; 
            border: 3px solid #2D3436; border-radius: 24px; box-shadow: 6px 6px 0px 0px #2D3436; 
            padding: 16px; z-index: 40; display: none; max-height: 320px; overflow-y: auto;
        }
        .dropdown-menu.show { display: block; }
        
        .student-option {
            width: 100%; display: flex; align-items: center; justify-content: space-between; 
            padding: 12px; border: 2px solid transparent; border-radius: 16px; background: none; 
            cursor: pointer; text-align: left; transition: all 0.15s ease; text-decoration: none; color: inherit;
        }
        .student-option:hover { border-color: #2D3436; background-color: #F8FAFC; }
        .student-option.selected { background-color: #FFD02C; border-color: #2D3436; box-shadow: 3px 3px 0px #2D3436; }
        
        .enroll-btn {
            width: 100%; margin-top: 8px; padding: 12px; border-top: 2px dashed #CBD5E1; 
            display: flex; align-items: center; justify-content: center; gap: 8px;
            background-color: #F8FAFC; border: 2px solid #2D3436; border-radius: 16px;
            font-size: 12px; font-weight: 900; color: #2D3436; cursor: pointer; transition: all 0.15s ease;
        }
        .enroll-btn:hover { background-color: #D1FAE5; box-shadow: 2px 2px 0px #2D3436; }

        /* --- 4. CHARTS ROW --- */
        .charts-row { display: grid; grid-template-columns: 1fr; gap: 24px; align-items: stretch; }
        @media (min-width: 1024px) { .charts-row { grid-template-columns: 1fr 1fr; } }
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
            
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <div class="app-content-body">
                

                    <c:otherwise>
                        <!-- TEACHER DASHBOARD POPULATED -->
                        <div class="teacher-platform-root" id="teacher-platform-root">
                            
                            <!-- 1. Teacher Banner -->
                            <div class="banner-card">
                                <div class="banner-left">
                                    <div class="icon-box-yellow">
                                        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                            <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
                                            <path d="M6 12v5c3 3 9 3 12 0v-5"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <div class="banner-title-group">
                                            <h1 class="banner-title">Keedflix Educator & Teacher Platform</h1>
                                            <span class="banner-badge">Classroom Progress Console</span>
                                        </div>
                                        <p class="banner-subtitle">
                                            Logged in as: <strong>${teacherName}</strong> (${teacherTitle}) • ${className} Lead Educator
                                        </p>
                                    </div>
                                </div>

                                <div class="banner-right">
                                    <div class="info-pill pill-amber">
                                        <span class="pill-label" style="color: #92400E;">Classroom Roster</span>
                                        <span class="pill-value">${students.size()} Pupils Enrolled</span>
                                    </div>
                                    <div class="info-pill pill-purple">
                                        <span class="pill-label" style="color: #6B21A8;">Assigned Class</span>
                                        <span class="pill-value">${className}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- 2. Metrics Grid -->
                            <div class="metrics-grid">
                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Active Pupils</span>
                                        <div class="metric-icon-box bg-amber">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                                        </div>
                                    </div>
                                    <p class="metric-value">${students.size()}</p>
                                    <p class="metric-sub">${className} pupils under supervision</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Learning Domains</span>
                                        <div class="metric-icon-box bg-purple">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                                        </div>
                                    </div>
                                    <p class="metric-value">3 Areas</p>
                                    <p class="metric-sub">Reading, Writing & Counting tracked</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Logged Observations</span>
                                        <div class="metric-icon-box bg-emerald">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle></svg>
                                        </div>
                                    </div>
                                    <p class="metric-value">${totalObservations}</p>
                                    <p class="metric-sub">Photo evidence & pedagogical notes</p>
                                </div>

                                <div class="metric-card">
                                    <div class="metric-header">
                                        <span class="metric-label">Milestones Achieved</span>
                                        <div class="metric-icon-box bg-rose">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                        </div>
                                    </div>
                                    <p class="metric-value">${totalMilestones}</p>
                                    <p class="metric-sub">Certified developmental milestones</p>
                                </div>
                            </div>

                            <!-- 3. Student Selector Dropdown -->
                            <div class="dropdown-container">
                                <button class="dropdown-btn" id="dropdownBtn" onclick="toggleDropdown()">
                                    <div style="display: flex; align-items: center; gap: 16px;">
                                        <span style="font-size: 1.5rem; background: #FFD02C; border: 2px solid #2D3436; border-radius: 50%; width: 40px; height: 40px; display: flex; justify-content: center; align-items: center;">${currentStudent.avatarSeed}</span>
                                        <div>
                                            <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                                <span style="font-size: 1.2rem; font-weight: 900; color: #2D3436;">${currentStudent.name}</span>
                                                <span style="font-size: 10px; font-weight: 800; background: #F3E8FF; color: #6B21A8; padding: 2px 8px; border-radius: 10px; border: 1px solid #D8B4FE;">${currentStudent.className}</span>
                                            </div>
                                            <span style="font-size: 12px; color: #636E72; font-weight: 600;">Age: ${currentStudent.age} • Active Pupil Evaluation</span>
                                        </div>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <span style="font-size: 12px; font-weight: 900; background: #FFD02C; padding: 4px 12px; border-radius: 999px; border: 1px solid #2D3436;">Switch Pupil</span>
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#2D3436" stroke-width="2.5"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                    </div>
                                </button>

                                <div class="dropdown-menu" id="dropdownMenu">
                                    <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; margin-bottom: 10px;">Select Pupil in Classroom Roster</p>
                                    
                                    <c:forEach var="st" items="${students}">
                                        <a href="${pageContext.request.contextPath}/TeacherPlatformServlet?studentId=${st.id}" class="student-option ${st.id == currentStudent.id ? 'selected' : ''}">
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <span style="font-size: 1.2rem; background: #FFF; border: 2px solid #2D3436; border-radius: 50%; width: 36px; height: 36px; display: flex; justify-content: center; align-items: center;">${st.avatarSeed}</span>
                                                <div>
                                                    <p style="font-size: 14px; font-weight: 900; margin: 0; color: #2D3436;">${st.name}</p>
                                                    <p style="font-size: 11px; color: #636E72; margin: 0;">${st.className} • Age: ${st.age}</p>
                                                </div>
                                            </div>
                                            <c:if test="${st.id == currentStudent.id}">
                                                <div style="background: #2D3436; color: white; padding: 4px; border-radius: 50%;">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                                </div>
                                            </c:if>
                                        </a>
                                    </c:forEach>

                                    <!-- Enroll Button Option -->
                                    <button class="enroll-btn" onclick="alert('Open Add Student Modal')">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                        Enroll Another Child to Class
                                    </button>
                                </div>
                            </div>

                            <!-- 4. Pedagogical Charts Row -->
                            <div class="charts-row" style="align-items: stretch;">
                                <div style="width: 100%; height: 460px;">
                                    <iframe src="${pageContext.request.contextPath}/RadarChartServlet?studentId=${currentStudent.id}" 
                                            width="100%" height="100%" frameborder="0" scrolling="no" title="Radar Chart">
                                    </iframe>
                                </div>
                                <div style="width: 100%; height: 460px;">
                                    <iframe src="${pageContext.request.contextPath}/TrendChartServlet?studentId=${currentStudent.id}" 
                                            width="100%" height="100%" frameborder="0" scrolling="no" title="Trend Chart">
                                    </iframe>
                                </div>
                            </div>

                        </div>
                    </c:otherwise>

            </div>
        </main>
    </div>

    <!-- SCRIPT FOR DROPDOWN -->
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