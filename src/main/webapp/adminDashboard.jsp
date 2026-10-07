<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>

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

    <style>
        /* ==========================================
           GLOBAL NEOBRUTALISM SETUP & LAYOUT
           ========================================== */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }

        body {
            display: flex;
            min-height: 100vh;
            background-color: #FAF5EF;
            color: #2D3436;
        }

        /* Sidebar Wrapper */
        .app-sidebar-wrapper {
            width: 250px;
            flex-shrink: 0;
            background-color: #FFFFFF;
            border-right: 3px solid #2D3436;
        }

        /* Main Section Layout */
        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .app-content-body {
            padding: 28px 32px;
            flex-grow: 1;
        }

        /* ==========================================
           HEADER STYLING (Top Bar)
           ========================================== */
        .top-header {
            background-color: #FFFFFF;
            border-bottom: 3px solid #2D3436;
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .admin-pill {
            background-color: #6C5CE7;
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 800;
            padding: 6px 16px;
            border-radius: 999px;
            border: 2px solid #2D3436;
            display: flex;
            align-items: center;
            gap: 6px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .header-subtitle {
            font-size: 13px;
            color: #636E72;
            font-weight: 600;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .icon-btn {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 2px solid #2D3436;
            background-color: #FFFFFF;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            cursor: pointer;
        }

        .notification-dot {
            position: absolute;
            top: 6px;
            right: 8px;
            width: 8px;
            height: 8px;
            background-color: #FF7675;
            border-radius: 50%;
        }

        .avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #6C5CE7;
            border: 2px solid #2D3436;
            color: #FFFFFF;
            font-weight: 800;
            font-size: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
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
            min-width: 170px;
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
        }

        /* ==========================================
           METRICS GRID & CARDS
           ========================================== */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

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
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .bg-purple-100 { background-color: #F0E8FF; }
        .bg-amber-100 { background-color: #FFF3C4; }
        .bg-rose-100 { background-color: #FFE3E3; }
        .bg-emerald-100 { background-color: #D1F7E8; }

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

    <!-- 1. SIDEBAR INCLUSION -->
    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <!-- MAIN APP STRUCTURE -->
    <main class="app-main-wrapper">
        
        <!-- 2. HEADER INCLUSION -->
        <header class="top-header">
            <div class="header-left">
                <div class="admin-pill">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                    ADMIN PLATFORM
                </div>
                <span class="header-subtitle">Central Administration & Governance</span>
            </div>
            
            <div class="header-right">
                <button class="icon-btn" aria-label="Notifications">
                    <span class="notification-dot"></span>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2D3436" stroke-width="2">
                        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                        <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                    </svg>
                </button>
                <div class="avatar-circle">
                    <%= adminName.length() >= 2 ? adminName.substring(0, 2).toUpperCase() : "AD" %>
                </div>
            </div>
        </header>

        <!-- 3. DASHBOARD CONTENT BODY -->
        <div class="app-content-body">
            
            <div class="admin-platform-root" id="admin-platform-root">
                
                <!-- TOP BANNER CARD -->
                <div class="admin-banner-card">
                    <div class="admin-banner-flex">
                        
                        <!-- Left Info -->
                        <div class="admin-banner-left">
                            <div class="shield-icon-container">
                                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                                </svg>
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
                                <span class="badge-value"><%= totalAccounts %> Registered</span>
                            </div>
                            <div class="badge-box badge-amber">
                                <span class="badge-label label-amber">Enrolled Students</span>
                                <span class="badge-value"><%= totalStudents %> Pupils</span>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- DYNAMIC METRICS GRID FROM ORACLE DB -->
                <% if ("overview".equals(activeTab)) { %>
                    <div class="metrics-grid">
                        
                        <!-- Card 1: System Users -->
                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-title">System Users</span>
                                <div class="metric-icon-box bg-purple-100">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6C5CE7" stroke-width="2.5">
                                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="9" cy="7" r="4"></circle>
                                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                                    </svg>
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
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#D69E2E" stroke-width="2.5">
                                        <circle cx="12" cy="8" r="6"></circle>
                                        <path d="M15.477 12.89 17 22l-5-3-5 3 1.523-9.11"></path>
                                    </svg>
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
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FF6B6B" stroke-width="2.5">
                                        <path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-2 2Zm0 0a2 2 0 0 1-2-2v-9c0-1.1.9-2 2-2h2"></path>
                                        <path d="M18 14h-8"></path>
                                        <path d="M15 18h-5"></path>
                                        <path d="M10 6h8v4h-8z"></path>
                                    </svg>
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
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.5">
                                        <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path>
                                        <polyline points="14 2 14 8 20 8"></polyline>
                                        <line x1="16" y1="13" x2="8" y2="13"></line>
                                        <line x1="16" y1="17" x2="8" y2="17"></line>
                                        <line x1="10" y1="9" x2="8" y2="9"></line>
                                    </svg>
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

</body>
</html>