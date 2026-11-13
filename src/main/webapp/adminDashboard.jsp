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

    <style>
        /* ==========================================
           GLOBAL NEOBRUTALISM SETUP & LAYOUT FIXES
           ========================================== */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }

        html, body {
            height: 100%;
            width: 100%;
            background-color: #FAF5EF;
            color: #2D3436;
            overflow: hidden;
        }

        .app-layout {
            display: flex;
            height: 100vh;
            width: 100%;
            background-color: #FAF5EF;
        }

        /* Sidebar Wrapper */
        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background-color: #FFFFFF;
        }

        /* Main Section Layout */
        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            height: 100vh;
            background-color: #FAF5EF;
            overflow: hidden;
        }

        /* ==========================================
           HEADER STYLING & BORDER FIX
           ========================================== */
        .app-header-wrapper {
            flex-shrink: 0;
            background-color: #FFFFFF;
            border-bottom: 3px solid #2D3436 !important;
            width: 100%;
            z-index: 5;
        }

        .app-header-wrapper header,
        .app-header-wrapper .topbar-header,
        .app-header-wrapper .top-header {
            border-bottom: none !important;
            margin: 0 !important;
            box-shadow: none !important;
        }

        .app-content-body {
            padding: 24px 32px;
            flex-grow: 1;
            overflow-y: auto;
            background-color: #FAF5EF;
        }

        .admin-platform-root {
            max-width: 1200px;
            margin: 0 auto;
        }

        /* ==========================================
           BANNER CARD
           ========================================== */
        .admin-banner-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 32px;
            padding: 32px;
            box-shadow: 6px 6px 0px 0px #2D3436;
            margin-bottom: 28px;
        }

        .admin-banner-flex {
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }

        .admin-banner-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .shield-icon-container {
            width: 72px;
            height: 72px;
            border-radius: 20px;
            background-color: #6C5CE7;
            border: 3px solid #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #FFFFFF;
            box-shadow: 3px 3px 0px 0px #2D3436;
            flex-shrink: 0;
        }

        .admin-main-title {
            font-size: 1.6rem;
            font-weight: 900;
            color: #1E272C;
            letter-spacing: -0.02em;
        }

        .admin-badge {
            display: inline-block;
            background-color: #6C5CE7;
            color: #FFFFFF;
            font-size: 10px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 3px 12px;
            border-radius: 999px;
            border: 2px solid #2D3436;
            margin-top: 6px;
            margin-bottom: 6px;
        }

        .admin-subtext {
            font-size: 0.8rem;
            color: #2D3436;
            font-weight: 500;
        }

        .admin-banner-right {
            display: flex;
            flex-direction: column;
            gap: 12px;
            min-width: 190px;
        }

        .badge-box {
            border-radius: 16px;
            padding: 10px 16px;
            border: 2px solid #2D3436;
        }

        .badge-purple {
            background-color: #F0E8FF;
        }

        .badge-amber {
            background-color: #FFF9E5;
        }

        .badge-label {
            font-size: 9px;
            font-weight: 800;
            text-transform: uppercase;
            display: block;
            margin-bottom: 2px;
        }

        .label-purple { color: #6C5CE7; }
        .label-amber { color: #B7791F; }

        .badge-value {
            font-weight: 900;
            font-size: 1.05rem;
            color: #2D3436;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* ==========================================
           METRICS GRID & CARDS
           ========================================== */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(1, 1fr);
            gap: 20px;
        }
        @media (min-width: 640px) { .metrics-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (min-width: 1024px) { .metrics-grid { grid-template-columns: repeat(4, 1fr); } }

        .metric-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 24px 20px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .metric-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .metric-title {
            font-size: 11px;
            font-weight: 900;
            text-transform: uppercase;
            color: #636E72;
            letter-spacing: 0.03em;
        }

        .metric-icon-box {
            width: 36px;
            height: 36px;
            border-radius: 12px;
            border: 2px solid #2D3436;
            box-shadow: 2px 2px 0px 0px #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .bg-purple-100 { background-color: #F0E8FF; color: #6C5CE7; }
        .bg-amber-100  { background-color: #FFF3C4; color: #D69E2E; }
        .bg-rose-100   { background-color: #FFE3E3; color: #FF6B6B; }
        .bg-emerald-100 { background-color: #D1F7E8; color: #10B981; }

        .metric-number {
            font-size: 1.8rem;
            font-weight: 900;
            color: #2D3436;
            margin-bottom: 12px;
            line-height: 1;
        }

        .metric-footer {
            font-size: 11px;
            color: #636E72;
            font-weight: 600;
            line-height: 1.3;
        }
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

                            <!-- Card 3: Weekly Bulletins -->
                            <div class="metric-card">
                                <div class="metric-header">
                                    <span class="metric-title">Weekly Bulletins</span>
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