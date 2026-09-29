<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>
<%@ page import="bean.Parent"%>

<%
    // Fetch active tab from request parameter or attribute (default: dashboard)
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = (String) request.getAttribute("activeTab");
    }
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = "dashboard";
    }

    // Retrieve user role from session
    String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "Parent";

    boolean isAdmin = "Admin".equalsIgnoreCase(userRole);
    boolean isTeacher = "Teacher".equalsIgnoreCase(userRole);
    boolean isParent = "Parent".equalsIgnoreCase(userRole);
%>

<link rel="stylesheet" type="text/css" href="css/sidebar.css">

<aside class="sidebar-aside" id="sidebar-navigation">
    <!-- Top Square Box Logo & Centre Title -->
    <div class="sidebar-logo-container">
        <div class="logo-box-outer">
            <div class="logo-box-inner">
                <!-- Sparkles SVG Icon -->
                <svg class="sparkles-icon" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2">
                    <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/>
                    <path d="M5 3v4M3 5h4M19 17v4M17 19h4"/>
                </svg>
            </div>
        </div>
        <h1 class="sidebar-title">Keedflix Centre</h1>
        <span class="sidebar-badge">Early Learning Platform</span>
    </div>

    <!-- Navigation Menu Pill Buttons -->
    <nav class="sidebar-nav">
        <!-- Dashboard Button -->
        <a href="DashboardServlet?tab=dashboard" 
           class="nav-btn <%= "dashboard".equals(activeTab) ? "btn-dashboard-active" : "btn-default" %>" 
           id="nav-tab-dashboard">
            <%= isAdmin ? "Admin Console" : "Dashboard" %>
        </a>

        <!-- Learning Progress Tab -->
        <a href="ProgressServlet?tab=progress" 
           class="nav-btn <%= "progress".equals(activeTab) ? "btn-progress-active" : "btn-default" %>" 
           id="nav-tab-progress">
            Learning Progress
        </a>

        <!-- Student Directory Section (Admin & Teacher Only) -->
        <% if (isAdmin || isTeacher) { %>
            <a href="StudentServlet?tab=directory" 
               class="nav-btn <%= "directory".equals(activeTab) ? "btn-directory-active" : "btn-default" %>" 
               id="nav-tab-directory" 
               title="Student Directory (Teacher & Admin)">
                <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                </svg>
                <span>Student Directory</span>
            </a>
        <% } %>

        <!-- Parent Directory Section (Admin Only) -->
        <% if (isAdmin) { %>
            <a href="ParentDirectoryServlet?tab=parents" 
               class="nav-btn <%= "parents".equals(activeTab) ? "btn-parents-active" : "btn-default" %>" 
               id="nav-tab-parents" 
               title="Parent & Guardian Directory (Admin)">
                <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"></path>
                </svg>
                <span>Parent Directory</span>
            </a>
        <% } %>

        <!-- Weekly News Tab -->
        <a href="NewsServlet?tab=news" 
           class="nav-btn <%= "news".equals(activeTab) ? "btn-news-active" : "btn-default" %>" 
           id="nav-tab-news">
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-2 2Zm0 0a2 2 0 0 1-2-2v-9c0-1.1.9-2 2-2h2"></path>
                <path d="M18 14h-8"></path>
                <path d="M15 18h-5"></path>
                <path d="M10 6h8v4h-8z"></path>
            </svg>
            <span>Weekly News</span>
        </a>

        <!-- Direct Message & Chat (Non-Admin: Parent & Teacher) -->
        <% if (!isAdmin) { %>
            <a href="ChatServlet?tab=chat" 
               class="nav-btn <%= "chat".equals(activeTab) ? "btn-chat-active" : "btn-default" %>" 
               id="nav-tab-chat">
                <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
                <span>Direct Message</span>
            </a>
        <% } %>
    </nav>

    <!-- Profile & Sign Out Controls at Bottom -->
    <div class="sidebar-footer">
        <a href="ProfileServlet" class="footer-btn btn-profile" id="nav-my-profile">
            <svg class="btn-icon text-purple" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                <circle cx="12" cy="7" r="4"></circle>
            </svg>
            <span>My Profile</span>
        </a>

        <a href="LogoutServlet" class="footer-btn btn-logout" id="nav-sign-out">
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                <polyline points="16 17 21 12 16 7"></polyline>
                <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            <span>Sign Out</span>
        </a>
    </div>
</aside>