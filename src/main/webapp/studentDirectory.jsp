<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.Parent"%>
<%@ page import="util.IconUtil"%>

<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    Map<Integer, Parent> parentMap = (Map<Integer, Parent>) request.getAttribute("parentMap");
    Map<Integer, Double> progressMap = (Map<Integer, Double>) request.getAttribute("progressMap");
    
    Integer totalStudentsCount = (Integer) request.getAttribute("totalStudentsCount");
    Integer totalLogsCount = (Integer) request.getAttribute("totalLogsCount");
    Double cohortAvgProgress = (Double) request.getAttribute("cohortAvgProgress");

    if (studentList == null) {
        response.sendRedirect("StudentDirectoryServlet");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Keedflix Centre - Student Directory</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/studentDirectory.css">

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
                <div class="directory-root">
                    
                    <!-- Banner -->
                    <div class="directory-banner">
                        <div>
                            <span class="banner-badge">Administrator Console</span>
                            <h1 class="banner-title">Student Directory & Profiles</h1>
                            <p class="banner-subtitle">Centralized Oracle database registry for Keedflix Centre cohorts</p>
                        </div>
                        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                            <button type="button" onclick="window.location.href='${pageContext.request.contextPath}/RegisterStudentServlet'" class="btn-neo btn-coral">
                                <%= IconUtil.icon("UserPlus", "icon-sm") %>
                                <span>Enroll New Student</span>
                            </button>
                        </div>
                    </div>

                    <!-- Quick Stats -->
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #FFD02C;">
                                <%= IconUtil.icon("Users", "icon-md") %>
                            </div>
                            <div>
                                <p class="stat-lbl">Enrolled Pupils</p>
                                <p class="stat-val"><%= totalStudentsCount != null ? totalStudentsCount : 0 %> Children</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #D1F7E8;">
                                <%= IconUtil.icon("Trophy", "icon-md") %>
                            </div>
                            <div>
                                <p class="stat-lbl">Cohort Avg Progress</p>
                                <p class="stat-val"><%= cohortAvgProgress != null ? cohortAvgProgress : 0.0 %>%</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #FFE3E3;">
                                <%= IconUtil.icon("ClipboardList", "icon-md") %>
                            </div>
                            <div>
                                <p class="stat-lbl">Progress Logs</p>
                                <p class="stat-val"><%= totalLogsCount != null ? totalLogsCount : 0 %> Logged</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Controls Bar (Kotak Carian & Penapis Kelas) -->
                    <div class="controls-bar">
                        <div class="search-wrap">
                            <span class="search-icon"><%= IconUtil.icon("Search", "icon-sm") %></span>
                            <input type="text" id="directorySearchInput" onkeyup="filterStudents()" 
                                   placeholder="Search pupil name, class, parent..." class="search-input-box">
                        </div>

                        <div style="display: flex; align-items: center; gap: 12px;">
                            <div style="display: flex; align-items: center; gap: 6px; font-size: 0.8rem; font-weight: 900;">
                                <span>CLASS:</span>
                                <select id="classFilterSelect" onchange="filterStudents()" style="padding: 8px 12px; border: 2.5px solid #2D3436; border-radius: 12px; font-weight: 700; background-color: #FAF5EF; outline: none;">
                                    <option value="">All Classes (<%= studentList.size() %>)</option>
                                    <option value="Kindergarten 3B">Kindergarten 3B</option>
                                </select>
                            </div>
                            <div style="display: flex; align-items: center; gap: 6px;">
                                <button type="button" class="btn-neo btn-yellow" onclick="switchView('grid')" style="padding: 8px 12px;" title="Grid View">
                                    <%= IconUtil.icon("LayoutGrid", "icon-sm") %>
                                </button>
                                <button type="button" class="btn-neo" style="background-color: #FFFFFF; padding: 8px 12px;" onclick="switchView('table')" title="List View">
                                    <%= IconUtil.icon("List", "icon-sm") %>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Grid Cards View -->
                    <div class="students-grid">
                        <% 
                            for (Student s : studentList) { 
                                Parent p = (parentMap != null) ? parentMap.get(s.getParentID()) : null;
                                Double progress = (progressMap != null && progressMap.containsKey(s.getStudentID())) ? progressMap.get(s.getStudentID()) : 0.0;
                                
                                String parentName = (p != null && p.getParentName() != null) ? p.getParentName() : "N/A";
                                String parentPhone = (p != null && p.getParentPhoneNumber() != null && !p.getParentPhoneNumber().isEmpty()) ? p.getParentPhoneNumber() : "N/A";
                        %>
                            <div class="student-card">
                                <div>
                                    <!-- Header Kad: Nama & ID -->
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; gap: 8px;">
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <div class="student-avatar-box">
                                                <%= IconUtil.icon("Smile", "icon-lg") %>
                                            </div>
                                            <div>
                                                <h3 style="margin: 0; font-weight: 900; font-size: 1.05rem;"><%= s.getStudentName() %></h3>
                                                <span style="font-size: 0.75rem; color: #636E72; font-weight: 600;">
                                                    <%= s.getStudentClass() != null ? s.getStudentClass() : "Kindergarten 3B" %> · Age <%= s.getStudentAge() != null ? s.getStudentAge() : "-" %>
                                                </span>
                                            </div>
                                        </div>
                                        <span style="font-weight: 900; font-size: 0.8rem; padding: 4px 8px; border: 2px solid #2D3436; border-radius: 8px; background: #FAF5EF; flex-shrink: 0;">
                                            ID: <%= s.getStudentID() %>
                                        </span>
                                    </div>

                                    <!-- Progress Bar Keseluruhan -->
                                    <div style="background: #FAF5EF; border: 2px solid #2D3436; border-radius: 12px; padding: 10px; margin-bottom: 12px;">
                                        <div style="display: flex; justify-content: space-between; font-size: 0.75rem; font-weight: 900; margin-bottom: 4px;">
                                            <span>Milestone Progress</span>
                                            <span><%= progress %>%</span>
                                        </div>
                                        <div class="progress-bar-bg">
                                            <div class="progress-bar-fill" style="width: <%= progress %>%;"></div>
                                        </div>
                                    </div>

                                    <!-- Kotak Subjek (Reading, Writing, Counting) -->
                                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-bottom: 12px;">
                                        <div style="background: #FFFFFF; border: 2px solid #2D3436; border-radius: 10px; padding: 8px; text-align: center;">
                                            <span style="font-size: 0.65rem; font-weight: 900; color: #636E72; display: block;">Reading</span>
                                            <span style="font-size: 0.9rem; font-weight: 900; color: #2D3436;"><%= progress > 0 ? "4.5" : "-" %></span>
                                        </div>
                                        <div style="background: #FFFFFF; border: 2px solid #2D3436; border-radius: 10px; padding: 8px; text-align: center;">
                                            <span style="font-size: 0.65rem; font-weight: 900; color: #636E72; display: block;">Writing</span>
                                            <span style="font-size: 0.9rem; font-weight: 900; color: #2D3436;"><%= progress > 0 ? "4.0" : "-" %></span>
                                        </div>
                                        <div style="background: #FFFFFF; border: 2px solid #2D3436; border-radius: 10px; padding: 8px; text-align: center;">
                                            <span style="font-size: 0.65rem; font-weight: 900; color: #636E72; display: block;">Counting</span>
                                            <span style="font-size: 0.9rem; font-weight: 900; color: #2D3436;"><%= progress > 0 ? "4.8" : "-" %></span>
                                        </div>
                                    </div>

                                    <!-- Guardian Details -->
                                    <div style="background: #FFFFFF; border: 2px solid #2D3436; border-radius: 12px; padding: 10px; margin-bottom: 12px;">
                                        <span style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #6C5CE7;">Guardian Details</span>
                                        <p style="margin: 2px 0 0 0; font-size: 0.75rem; font-weight: 700;">
                                            <%= parentName %> (<%= parentPhone %>)
                                        </p>
                                    </div>
                                </div>

                                <!-- Butang Tindakan Bawah -->
                                <div class="sd-card-actions">
								    <button type="button" class="sd-action-btn" onclick="openMonthlyReportModal(<%= s.getStudentID() %>)">
								        <%= IconUtil.icon("TrendingUp", "icon-xs") %>
								        <span>Progress</span>
								    </button>
								
								    <a href="${pageContext.request.contextPath}/studentProfile?studentId=<%= s.getStudentID() %>" class="sd-action-btn">
								        <%= IconUtil.icon("User", "icon-xs") %>
								        <span>Profile</span>
								    </a>
								</div>
                            </div>
                        <% } %>
                    </div>

                </div>
            </div>
        </main>
    </div>
    
    <script>
        function filterStudents() {
            var input = document.getElementById('directorySearchInput').value.toLowerCase();
            var classFilter = document.getElementById('classFilterSelect').value.toLowerCase();
            var nodes = document.getElementsByClassName('student-card');
            
            for (var i = 0; i < nodes.length; i++) {
                var textContent = nodes[i].innerText.toLowerCase();
                var matchesSearch = textContent.indexOf(input) > -1;
                var matchesClass = classFilter === "" || textContent.indexOf(classFilter) > -1;
                
                if (matchesSearch && matchesClass) {
                    nodes[i].style.display = "";
                } else {
                    nodes[i].style.display = "none";
                }
            }
        }

        function switchView(mode) {
            console.log("Switch view to: " + mode);
        }
    </script>

	<jsp:include page="monthlyReportModal.jsp" />
    <jsp:include page="icons.jsp" />
</body>
</html>