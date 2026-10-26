<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.Parent"%>

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
    <style>
        * {
            box-sizing: border-box;
        }

        .directory-root {
            display: flex;
            flex-direction: column;
            gap: 20px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: #2D3436;
        }

        /* Banner Card */
        .directory-banner {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 28px;
            padding: 24px 32px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }

        .banner-title {
            font-size: 1.6rem;
            font-weight: 900;
            color: #2D3436;
            margin: 8px 0 4px 0;
        }

        .banner-subtitle {
            font-size: 0.85rem;
            color: #636E72;
            font-weight: 600;
        }

        .banner-badge {
            background-color: #6C5CE7;
            color: #FFFFFF;
            font-size: 10px;
            font-weight: 900;
            padding: 4px 12px;
            border-radius: 999px;
            border: 2px solid #2D3436;
            text-transform: uppercase;
        }

        /* Stats Row */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .stat-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 20px;
            padding: 16px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .stat-icon {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            border: 2px solid #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            font-weight: 900;
            flex-shrink: 0;
        }

        .stat-val {
            font-size: 1.4rem;
            font-weight: 900;
            color: #2D3436;
            line-height: 1;
            margin: 0;
        }

        .stat-lbl {
            font-size: 10px;
            font-weight: 900;
            color: #636E72;
            text-transform: uppercase;
            margin: 0 0 2px 0;
        }

        /* Controls Bar */
        .controls-bar {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 20px;
            padding: 14px 20px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .search-input-box {
            padding: 10px 16px;
            border: 2.5px solid #2D3436;
            border-radius: 12px;
            font-weight: 700;
            font-size: 0.85rem;
            width: 280px;
            background-color: #FAF5EF;
            outline: none;
        }

        .search-input-box:focus {
            background-color: #FFFFFF;
            box-shadow: 2px 2px 0px #2D3436;
        }

        /* Grid View Cards */
        .students-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(310px, 1fr));
            gap: 20px;
        }

        .student-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 20px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .student-avatar-box {
            width: 50px;
            height: 50px;
            border-radius: 16px;
            background-color: #FFD02C;
            border: 2px solid #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            box-shadow: 2px 2px 0px #2D3436;
        }

        .progress-bar-bg {
            width: 100%;
            height: 10px;
            background-color: #E2E8F0;
            border-radius: 999px;
            border: 1.5px solid #2D3436;
            overflow: hidden;
        }

        .progress-bar-fill {
            height: 100%;
            background-color: #FF6B6B;
        }

        .btn-neo {
            padding: 10px 16px;
            border-radius: 12px;
            border: 2.5px solid #2D3436;
            font-weight: 900;
            font-size: 0.8rem;
            cursor: pointer;
            box-shadow: 3px 3px 0px #2D3436;
            transition: all 0.15s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .btn-neo:active {
            transform: translate(1px, 1px);
            box-shadow: 1px 1px 0px #2D3436;
        }

        .btn-yellow { background-color: #FFD02C; color: #2D3436; }
        .btn-mint { background-color: #D1F7E8; color: #2D3436; }
        .btn-coral { background-color: #FF6B6B; color: #FFFFFF; }
        
        /* Layout Pokok / Utama (Sekiranya belum ada) */
        html, body { height: 100%; margin: 0; background-color: #FAF5EF; color: #2D3436; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; overflow: hidden; }
        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background-color: #FFFFFF; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; min-width: 0; height: 100vh; overflow: hidden; }
        .app-header-wrapper { flex-shrink: 0; background-color: #FFFFFF; border-bottom: 3px solid #2D3436 !important; }
        .app-content-body { padding: 24px 32px; flex-grow: 1; overflow-y: auto; background-color: #FAF5EF; }
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
                <div class="directory-root">
                    
                    <!-- Banner -->
                    <div class="directory-banner">
                        <div>
                            <span class="banner-badge">Administrator Console</span>
                            <h1 class="banner-title">Student Directory & Profiles</h1>
                            <p class="banner-subtitle">Centralized Oracle database registry for Keedflix Centre cohorts</p>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button type="button" onclick="window.print()" class="btn-neo" style="background-color: #FFFFFF;">🖨️ Print Roster</button>
                            <button type="button" onclick="window.location.href='${pageContext.request.contextPath}/RegisterStudentServlet'" class="btn-neo btn-coral">➕ Enroll New Student</button>
                        </div>
                    </div>

                    <!-- Quick Stats -->
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #FFD02C;">👶</div>
                            <div>
                                <p class="stat-lbl">Enrolled Pupils</p>
                                <p class="stat-val"><%= totalStudentsCount != null ? totalStudentsCount : 0 %> Children</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #D1F7E8;">🏆</div>
                            <div>
                                <p class="stat-lbl">Cohort Avg Progress</p>
                                <p class="stat-val"><%= cohortAvgProgress != null ? cohortAvgProgress : 0.0 %>%</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background-color: #FFE3E3;">📝</div>
                            <div>
                                <p class="stat-lbl">Progress Logs</p>
                                <p class="stat-val"><%= totalLogsCount != null ? totalLogsCount : 0 %> Logged</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Controls Bar (Kotak Carian & Penapis Kelas) -->
                    <div class="controls-bar">
                        <input type="text" id="directorySearchInput" onkeyup="filterStudents()" 
                               placeholder="Search pupil name, class, parent..." class="search-input-box">

                        <div style="display: flex; align-items: center; gap: 12px;">
                            <div style="display: flex; align-items: center; gap: 6px; font-size: 0.8rem; font-weight: 900;">
                                <span>CLASS:</span>
                                <select id="classFilterSelect" onchange="filterStudents()" style="padding: 8px 12px; border: 2.5px solid #2D3436; border-radius: 12px; font-weight: 700; background-color: #FAF5EF; outline: none;">
                                    <option value="">All Classes (4)</option>
                                    <option value="Kindergarten 3B">Kindergarten 3B</option>
                                </select>
                            </div>
                            <div style="display: flex; align-items: center; gap: 4px;">
                                <button type="button" class="btn-neo btn-yellow" onclick="switchView('grid')" style="padding: 8px 12px;">🔲</button>
                                <button type="button" class="btn-neo" style="background-color: #FFFFFF; padding: 8px 12px;" onclick="switchView('table')">📋</button>
                            </div>
                        </div>
                    </div>

					<!-- Grid Cards View -->
                    <div class="students-grid" style="margin-top: 20px;">
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
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <div class="student-avatar-box">👶</div>
                                            <div>
                                                <h3 style="margin: 0; font-weight: 900; font-size: 1.05rem;"><%= s.getStudentName() %></h3>
                                                <span style="font-size: 0.75rem; color: #636E72; font-weight: 600;">
                                                    <%= s.getStudentClass() != null ? s.getStudentClass() : "Kindergarten 3B" %> • Age <%= s.getStudentAge() != null ? s.getStudentAge() : "-" %>
                                                </span>
                                            </div>
                                        </div>
                                        <span style="font-weight: 900; font-size: 0.8rem; padding: 4px 8px; border: 2px solid #2D3436; border-radius: 8px; background: #FAF5EF;">
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

                                    <!-- Kotak Mockup Subjek (Reading, Writing, Counting) -->
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
                                <div style="display: flex; gap: 8px; border-top: 2px dashed #CBD5E1; padding-top: 12px;">
                                    <a href="ProgressServlet?studentID=<%= s.getStudentID() %>" class="btn-neo btn-yellow" style="flex: 1; text-align: center;">📊 Progress</a>
                                    <button type="button" onclick="alert('Student Profile ID: <%= s.getStudentID() %>')" class="btn-neo" style="flex: 1; background: #FFF;">👤 Profile</button>
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

</body>
</html>