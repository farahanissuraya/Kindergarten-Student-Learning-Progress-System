<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.IconUtil"%>

<%
    // Tetapkan tab aktif
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = (String) request.getAttribute("activeTab");
    }
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = "dashboard";
    }

    // Ambil peranan pengguna dari Session dengan selamat
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || userRole.isBlank()) {
        userRole = (String) session.getAttribute("userRole");
    }
    if (userRole == null || userRole.isBlank()) {
        if (session.getAttribute("teacherId") != null || session.getAttribute("teacherID") != null) {
            userRole = "Teacher";
        } else {
            userRole = "Parent";
        }
    }

    boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
    boolean isTeacher = "Teacher".equalsIgnoreCase(userRole);
    boolean isParent = "Parent".equalsIgnoreCase(userRole);
%>

<style>
    .sidebar-aside {
        width: 280px;
        background-color: #FFFFFF;
        border-right: 3px solid #2D3436;
        display: flex;
        flex-direction: column;
        padding: 32px 24px;
        height: 100vh;
        box-sizing: border-box;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .sidebar-logo-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 24px;
        width: 100%;
    }

    .logo-img {
        width: 100%;
        height: auto;
        max-height: 80px;
        object-fit: contain;
        display: block;
    }

    .sidebar-nav {
        display: flex;
        flex-direction: column;
        gap: 16px;
        flex-grow: 1;
    }

    .nav-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        text-decoration: none;
        text-align: center;
        padding: 14px 20px;
        border: 2.5px solid #2D3436;
        border-radius: 999px;
        color: #2D3436;
        font-weight: 800;
        font-size: 0.95rem;
        background-color: #FFFFFF;
        transition: all 0.15s ease;
    }

    .nav-btn:hover {
        background-color: #F8FAFC;
        transform: translate(-1px, -1px);
    }

    .nav-btn.btn-active {
        background-color: #FFD02C;
        box-shadow: 4px 4px 0px #2D3436;
        transform: translate(-2px, -2px);
    }
</style>

<aside class="sidebar-aside" id="sidebar-navigation">
    
    <!-- Logo Header -->
    <div class="sidebar-logo-container">
        <img src="${pageContext.request.contextPath}/images/logo-keedsflix.png" 
             alt="Keedsflix Logo" 
             class="logo-img" />
    </div>

    <!-- Navigation Links -->
    <nav class="sidebar-nav">
        
        <% if (isAdmin) { %>
            <!-- Dashboard Link -->
            <a href="${pageContext.request.contextPath}/adminDashboard" 
               class="nav-btn <%= "dashboard".equals(activeTab) || "overview".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("LayoutGrid", "icon-sm") %>
                <span>Dashboard</span>
            </a>
        
            <!-- Learning Progress -->
            <a href="${pageContext.request.contextPath}/ProgressServlet" 
               class="nav-btn <%= "progress".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("TrendingUp", "icon-sm") %>
                <span>Learning Progress</span>
            </a>
        
            <!-- Student Directory -->
            <a href="${pageContext.request.contextPath}/StudentDirectoryServlet" 
               class="nav-btn <%= "directory".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("Users", "icon-sm") %>
                <span>Student Directory</span>
            </a>
        
            <!-- Weekly News -->
            <a href="${pageContext.request.contextPath}/NewsServlet" 
               class="nav-btn <%= "news".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("Newspaper", "icon-sm") %>
                <span>News</span>
            </a>
        
        <% } else if (isTeacher) { %>
            <!-- Dashboard Link -->
            <a href="${pageContext.request.contextPath}/teacherDashboard" 
               class="nav-btn <%= "dashboard".equals(activeTab) || "overview".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("LayoutGrid", "icon-sm") %>
                <span>Dashboard</span>
            </a>
        
            <!-- Learning Progress -->
            <a href="${pageContext.request.contextPath}/ProgressServlet" 
               class="nav-btn <%= "progress".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("TrendingUp", "icon-sm") %>
                <span>Learning Progress</span>
            </a>
        
            <!-- Weekly News -->
            <a href="${pageContext.request.contextPath}/NewsServlet" 
               class="nav-btn <%= "news".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("Newspaper", "icon-sm") %>
                <span>News</span>
            </a>
        
            <!-- Direct Message -->
            <a href="${pageContext.request.contextPath}/ChatServlet" 
               class="nav-btn <%= "chat".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("MessageCircle", "icon-sm") %>
                <span>Direct Message</span>
            </a>
        
        <% } else { %>
            <!-- Dashboard Link -->
            <a href="${pageContext.request.contextPath}/parentDashboard" 
               class="nav-btn <%= "dashboard".equals(activeTab) || "overview".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("LayoutGrid", "icon-sm") %>
                <span>Dashboard</span>
            </a>
        
            <!-- Learning Progress -->
            <a href="${pageContext.request.contextPath}/ProgressServlet" 
               class="nav-btn <%= "progress".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("TrendingUp", "icon-sm") %>
                <span>Learning Progress</span>
            </a>
        
            <!-- Weekly News -->
            <a href="${pageContext.request.contextPath}/NewsServlet" 
               class="nav-btn <%= "news".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("Newspaper", "icon-sm") %>
                <span>News</span>
            </a>
        
            <!-- Direct Message -->
            <a href="${pageContext.request.contextPath}/ChatServlet" 
               class="nav-btn <%= "chat".equals(activeTab) ? "btn-active" : "" %>">
                <%= IconUtil.icon("MessageCircle", "icon-sm") %>
                <span>Direct Message</span>
            </a>
        <% } %>
        
    </nav>

</aside>