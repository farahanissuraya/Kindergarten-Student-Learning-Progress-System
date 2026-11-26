<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>
<%@ page import="util.IconUtil"%>

<%
    // Retrieve logged in user from session using existing Teacher bean or Session Attributes
    Teacher loggedInTeacher = (Teacher) session.getAttribute("user");
    
    // Retrieve display name and title safely from session or database bean
    String adminName = (String) session.getAttribute("userName");
    if (adminName == null && loggedInTeacher != null) {
        adminName = loggedInTeacher.getTeacherName();
    }
    if (adminName == null || adminName.isBlank()) {
        adminName = "Administrator";
    }

    String adminRole = (String) session.getAttribute("role");
    if (adminRole == null || adminRole.isBlank()) {
        adminRole = "System Admin";
    }
    
    // Fetch live data retrieved from Oracle DB via Servlet & DAO
    Integer totalAccounts = (Integer) request.getAttribute("totalAccounts");
    Integer totalTeachers = (Integer) request.getAttribute("totalTeachers");
    Integer totalParents = (Integer) request.getAttribute("totalParents");
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalNews = (Integer) request.getAttribute("totalNews");
    
    // Fallback safely to 0 if DB query returns null or empty
    if (totalAccounts == null) totalAccounts = 0;
    if (totalTeachers == null) totalTeachers = 0;
    if (totalParents == null) totalParents = 0;
    if (totalStudents == null) totalStudents = 0;
    if (totalNews == null) totalNews = 0;

    // Check active tab filter
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = (String) request.getAttribute("activeTab");
    }
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = "overview";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix Centre - Admin Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adminDashboard.css">

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

            <!-- B. DASHBOARD CONTENT BODY -->
            <div class="app-content-body">
                
                <div class="admin-platform-root" id="admin-platform-root">
                    
                    <!-- TOP BANNER CARD -->
                    <div class="admin-banner-card">
                        <div class="admin-banner-flex">
                            
                            <!-- Left Info -->
                            <div class="admin-banner-left">
                                <div class="shield-icon-container">
                                    <%= IconUtil.icon("ShieldCheck", "icon-lg") %>
                                </div>
                                <div>
                                    <h1 class="admin-main-title">Keedflix Administrator Platform</h1>
                                    <div>
                                        <span class="admin-badge">Central Admin Console</span>
                                    </div>
                                    <p class="admin-subtext">
                                        Logged in as: <strong><%= adminName %></strong> (<%= adminRole %>) • Full System Privileges
                                    </p>
                                </div>
                            </div>

                            <!-- Right Dynamic Badges from DB -->
                            <div class="admin-banner-right">
                                <div class="badge-box badge-purple">
                                    <span class="badge-label label-purple">Total Accounts</span>
                                    <span class="badge-value">
                                        <%= IconUtil.icon("UserCheck", "icon-sm") %>
                                        <span><%= totalAccounts %> Registered</span>
                                    </span>
                                </div>
                                <div class="badge-box badge-amber">
                                    <span class="badge-label label-amber">Enrolled Students</span>
                                    <span class="badge-value">
                                        <%= IconUtil.icon("GraduationCap", "icon-sm") %>
                                        <span><%= totalStudents %> Pupils</span>
                                    </span>
                                </div>
                            </div>

                        </div>
                    </div>

                    <!-- DYNAMIC METRICS GRID FROM ORACLE DB -->
                    <% if ("overview".equals(activeTab) || "dashboard".equals(activeTab)) { %>
                        <div class="metrics-grid">
                            
                            <!-- Card 1: System Users -->
                            <div class="metric-card">
                                <div class="metric-header">
                                    <span class="metric-title">System Users</span>
                                    <div class="metric-icon-box bg-purple-100">
                                        <%= IconUtil.icon("Users", "icon-sm") %>
                                    </div>
                                </div>
                                <p class="metric-number"><%= totalAccounts %></p>
                                <p class="metric-footer"><%= totalTeachers %> Teachers • <%= totalParents %> Parents</p>
                            </div>

                            <!-- Card 2: Active Pupils -->
                            <div class="metric-card">
                                <div class="metric-header">
                                    <span class="metric-title">Active Pupils</span>
                                    <div class="metric-icon-box bg-amber-100">
                                        <%= IconUtil.icon("Award", "icon-sm") %>
                                    </div>
                                </div>
                                <p class="metric-number"><%= totalStudents %></p>
                                <p class="metric-footer">Reading, Writing &amp; Counting Cohorts</p>
                            </div>

                            <!-- Card 3:  Bulletins -->
                            <div class="metric-card">
                                <div class="metric-header">
                                    <span class="metric-title"> Bulletins</span>
                                    <div class="metric-icon-box bg-rose-100">
                                        <%= IconUtil.icon("Newspaper", "icon-sm") %>
                                    </div>
                                </div>
                                <p class="metric-number"><%= totalNews %></p>
                                <p class="metric-footer">School &amp; classroom announcements</p>
                            </div>

                            <!-- Card 4: Monthly Reports -->
                            <div class="metric-card">
                                <div class="metric-header">
                                    <span class="metric-title">Monthly Reports</span>
                                    <div class="metric-icon-box bg-emerald-100">
                                        <%= IconUtil.icon("FileText", "icon-sm") %>
                                    </div>
                                </div>
                                <p class="metric-number">Active</p>
                                <p class="metric-footer">October 2026 Cycle certified</p>
                            </div>

                        </div>
                    <% } %>

                </div>

            </div>
        </main>

    </div>

    <jsp:include page="icons.jsp" />
</body>
</html>