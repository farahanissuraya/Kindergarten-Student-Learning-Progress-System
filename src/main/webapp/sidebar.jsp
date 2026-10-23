<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>

<%
    // Tetapkan tab aktif (lalai: dashboard)
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = (String) request.getAttribute("activeTab");
    }
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = "dashboard";
    }

    // Ambil peranan pengguna dari Session
    String userRole = (String) session.getAttribute("role");
    Teacher loggedInTeacher = (Teacher) session.getAttribute("user");

    // Tetapkan peranan fallback jika tidak ditetapkan secara eksplisit
    if (userRole == null || userRole.isBlank()) {
        if (loggedInTeacher != null) {
            userRole = "Admin"; 
        } else {
            userRole = "Parent";
        }
    }

    boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
    boolean isTeacher = "Teacher".equalsIgnoreCase(userRole);
    boolean isParent = "Parent".equalsIgnoreCase(userRole);
%>

<!-- CSS Khusus untuk Sidebar Neobrutalism (Boleh diletakkan di fail berasingan jika mahu) -->
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

    /* 1. Header & Logo Styling */
    .sidebar-logo-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 32px;
    }
    
    .logo-box {
        width: 64px;
        height: 64px;
        background-color: #FFD02C;
        border: 3px solid #2D3436;
        border-radius: 16px;
        box-shadow: 3px 3px 0px #2D3436;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 16px;
        color: #2D3436;
    }

    .sidebar-title {
        font-size: 1.25rem;
        font-weight: 900;
        color: #2D3436;
        margin: 0 0 8px 0;
        text-align: center;
    }

    .sidebar-badge {
        background-color: #F8F5FF; /* Ungu cair lembut */
        color: #9333EA;
        border: 1.5px solid #E9D5FF;
        font-size: 0.65rem;
        font-weight: 900;
        padding: 6px 12px;
        border-radius: 999px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    /* 2. Navigation Menu Styling */
    .sidebar-nav {
        display: flex;
        flex-direction: column;
        gap: 16px;
        flex-grow: 1;
    }

    .nav-btn {
        display: block;
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
    }

    .nav-btn.btn-active {
        background-color: #FFD02C; /* Warna kuning bila aktif */
        box-shadow: 4px 4px 0px #2D3436;
        transform: translate(-2px, -2px);
    }

    /* 3. Footer & Sign Out Styling */
    .sidebar-footer {
        margin-top: auto;
    }

    .footer-divider {
        border: 0;
        border-top: 2px dashed #CBD5E1;
        margin: 0 0 24px 0;
    }

    .btn-logout {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
</style>

<aside class="sidebar-aside" id="sidebar-navigation">
    
    <!-- Header Logo & Judul -->
    <div class="sidebar-logo-container">
        <div class="logo-box">
            <svg class="sparkles-icon" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/>
                <path d="M5 3v4M3 5h4M19 17v4M17 19h4"/>
            </svg>
        </div>
        <h1 class="sidebar-title">Keedflix Centre</h1>
        <span class="sidebar-badge">EARLY LEARNING PLATFORM</span>
    </div>

    <!-- Navigasi Menu (Sengaja dibuang ikon supaya sama dengan gambar) -->
    <nav class="sidebar-nav">
        
        <!-- Dashboard / Admin Console (Untuk Semua Peranan) -->
        <a href="${pageContext.request.contextPath}/DashboardServlet?tab=dashboard" 
           class="nav-btn <%= "dashboard".equals(activeTab) || "overview".equals(activeTab) ? "btn-active" : "" %>">
            <%= isAdmin ? "Admin Console" : "Dashboard" %>
        </a>

        <!-- Learning Progress (Untuk Semua Peranan) -->
        <a href="${pageContext.request.contextPath}/ProgressServlet?tab=progress" 
           class="nav-btn <%= "progress".equals(activeTab) ? "btn-active" : "" %>">
            Learning Progress
        </a>

        <!-- Student Directory (Hanya Admin & Teacher) -->
        <% if (isAdmin || isTeacher) { %>
            <a href="${pageContext.request.contextPath}/StudentServlet?tab=directory" 
               class="nav-btn <%= "directory".equals(activeTab) ? "btn-active" : "" %>">
                Student Directory
            </a>
        <% } %>

        <!-- Parent Directory (Hanya Admin) -->
        <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/ParentDirectoryServlet?tab=parents" 
               class="nav-btn <%= "parents".equals(activeTab) ? "btn-active" : "" %>">
                Parent Directory
            </a>
        <% } %>

        <!-- Weekly News (Untuk Semua Peranan) -->
        <a href="${pageContext.request.contextPath}/NewsServlet?tab=news" 
           class="nav-btn <%= "news".equals(activeTab) ? "btn-active" : "" %>">
            Weekly News
        </a>

        <!-- Direct Message (Hanya Parent & Teacher, Admin tidak ada) -->
        <% if (!isAdmin) { %>
            <a href="${pageContext.request.contextPath}/ChatServlet?tab=chat" 
               class="nav-btn <%= "chat".equals(activeTab) ? "btn-active" : "" %>">
                Direct Message
            </a>
        <% } %>
        
    </nav>

    <!-- Footer: Garis Putus-putus & Sign Out (Ikon dibenarkan di sini berdasarkan gambar) -->
    <div class="sidebar-footer">
        <hr class="footer-divider" />
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-btn btn-logout">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                <polyline points="16 17 21 12 16 7"></polyline>
                <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            <span>Sign Out</span>
        </a>
    </div>
</aside>