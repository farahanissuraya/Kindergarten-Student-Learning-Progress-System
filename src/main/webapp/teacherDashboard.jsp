<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>
<%@ page import="util.IconUtil"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix - Teacher Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/teacherDashboard.css">

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
                
                <!-- TEACHER DASHBOARD POPULATED -->
                <div class="teacher-platform-root" id="teacher-platform-root">
                    
                    <!-- 1. Teacher Banner -->
                    <div class="banner-card">
                        <div class="banner-left">
                            <div class="icon-box-yellow">
                                <%= IconUtil.icon("GraduationCap", "icon-lg") %>
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
                                <span class="pill-value">
                                    <%= IconUtil.icon("Users", "icon-sm") %>
                                    <span>${students.size()} Pupils Enrolled</span>
                                </span>
                            </div>
                            <div class="info-pill pill-purple">
                                <span class="pill-label" style="color: #6B21A8;">Assigned Class</span>
                                <span class="pill-value">
                                    <%= IconUtil.icon("Building", "icon-sm") %>
                                    <span>${className}</span>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- 2. Metrics Grid -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Active Pupils</span>
                                <div class="metric-icon-box bg-amber">
                                    <%= IconUtil.icon("Users", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${students.size()}</p>
                            <p class="metric-sub">${className} pupils under supervision</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Learning Domains</span>
                                <div class="metric-icon-box bg-purple">
                                    <%= IconUtil.icon("BookOpen", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">3 Areas</p>
                            <p class="metric-sub">Reading, Writing & Counting tracked</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Logged Observations</span>
                                <div class="metric-icon-box bg-emerald">
                                    <%= IconUtil.icon("Camera", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${totalObservations}</p>
                            <p class="metric-sub">Photo evidence & pedagogical notes</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Milestones Achieved</span>
                                <div class="metric-icon-box bg-rose">
                                    <%= IconUtil.icon("Award", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${totalMilestones}</p>
                            <p class="metric-sub">Certified developmental milestones</p>
                        </div>
                    </div>

                    <!-- 3. Student Selector Dropdown -->
                    <div class="dropdown-container">
                        <button type="button" class="dropdown-btn" id="dropdownBtn" onclick="toggleDropdown()">
                            <div style="display: flex; align-items: center; gap: 16px;">
                                <span style="background: #FFD02C; border: 2px solid #2D3436; border-radius: 50%; width: 42px; height: 42px; display: flex; justify-content: center; align-items: center;">
                                    <%= IconUtil.icon("Smile", "icon-md") %>
                                </span>
                                <div>
                                    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                        <span style="font-size: 1.2rem; font-weight: 900; color: #2D3436;">${currentStudent.name}</span>
                                        <span style="font-size: 10px; font-weight: 800; background: #F3E8FF; color: #6B21A8; padding: 2px 8px; border-radius: 10px; border: 1px solid #D8B4FE;">${currentStudent.className}</span>
                                    </div>
                                    <span style="font-size: 12px; color: #636E72; font-weight: 600;">Age: ${currentStudent.age} • Active Pupil Evaluation</span>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 12px; font-weight: 900; background: #FFD02C; padding: 4px 12px; border-radius: 999px; border: 1.5px solid #2D3436;">Switch Pupil</span>
                                <%= IconUtil.icon("ChevronDown", "icon-md") %>
                            </div>
                        </button>

                        <div class="dropdown-menu" id="dropdownMenu">
                            <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; margin: 0 0 10px 0;">Select Pupil in Classroom Roster</p>
                            
                            <c:forEach var="st" items="${students}">
                                <a href="${pageContext.request.contextPath}/TeacherPlatformServlet?studentId=${st.id}" class="student-option ${st.id == currentStudent.id ? 'selected' : ''}">
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <span style="background: #FFF; border: 2px solid #2D3436; border-radius: 50%; width: 36px; height: 36px; display: flex; justify-content: center; align-items: center;">
                                            <%= IconUtil.icon("User", "icon-sm") %>
                                        </span>
                                        <div>
                                            <p style="font-size: 14px; font-weight: 900; margin: 0; color: #2D3436;">${st.name}</p>
                                            <p style="font-size: 11px; color: #636E72; margin: 0;">${st.className} • Age: ${st.age}</p>
                                        </div>
                                    </div>
                                    <c:if test="${st.id == currentStudent.id}">
                                        <div style="background: #2D3436; color: white; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                            <%= IconUtil.icon("Check", "icon-xs") %>
                                        </div>
                                    </c:if>
                                </a>
                            </c:forEach>

                            <!-- Enroll Button Option -->
                            <button type="button" class="enroll-btn" onclick="alert('Open Add Student Modal')">
                                <%= IconUtil.icon("UserPlus", "icon-sm") %>
                                <span>Enroll Another Child to Class</span>
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

            </div>
        </main>
    </div>

    <!-- SCRIPT FOR DROPDOWN -->
    <script>
        function toggleDropdown() {
            const menu = document.getElementById('dropdownMenu');
            if (menu) {
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

    <jsp:include page="icons.jsp" />
</body>
</html>