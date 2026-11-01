<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Tetapkan tab aktif
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.isBlank()) {
        activeTab = (String) request.getAttribute("activeTab");
    }
    // DIBETULKAN: Tukar lalai (default) kepada "dashboard"
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
        background-color: #F8F5FF;
        color: #9333EA;
        border: 1.5px solid #E9D5FF;
        font-size: 0.65rem;
        font-weight: 900;
        padding: 6px 12px;
        border-radius: 999px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

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
        background-color: #FFD02C;
        box-shadow: 4px 4px 0px #2D3436;
        transform: translate(-2px, -2px);
    }

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
    
/* Kotak Logo Tanpa Background Kuning & Border */
    .logo-box {
        width: 100%;
        max-width: 200px; /* Menghadkan lebar maksimum supaya ada gap kiri/kanan */
        height: auto;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 16px;
        padding: 0 16px; /* Ruang gap selamat dari tepi barrier sidebar */
        box-sizing: border-box;
    }

    /* Saiz Logo Mengikut Lebar Kotak */
    .logo-img {
        width: 100%;
        height: auto;
        max-height: 80px; /* Ketinggian optimum supaya tidak terlalu tinggi */
        object-fit: contain;
        display: block;
    }
    
</style>

<aside class="sidebar-aside" id="sidebar-navigation">
    
    <!-- Logo Header -->
	<div class="sidebar-logo-container">

            <img src="${pageContext.request.contextPath}/images/logo-keedsflix.png" 
                 alt="Keedflix Logo" 
                 class="logo-img" />


    </div>

    <!-- Navigation Links -->
    <nav class="sidebar-nav">
        
        <!-- Dashboard Link -->
        <a href="${pageContext.request.contextPath}/DashboardServlet?tab=dashboard" 
           class="nav-btn <%= "dashboard".equals(activeTab) || "overview".equals(activeTab) ? "btn-active" : "" %>">
            Dashboard
        </a>

        <!-- Learning Progress -->
        <a href="${pageContext.request.contextPath}/ProgressServlet?tab=progress" 
           class="nav-btn <%= "progress".equals(activeTab) ? "btn-active" : "" %>">
            Learning Progress
        </a>

        <!-- Student Directory (Admin Only) -->
        <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/StudentDirectoryServlet?tab=directory" 
               class="nav-btn <%= "directory".equals(activeTab) ? "btn-active" : "" %>">
                Student Directory
            </a>
        <% } %>

      <!-- Parent Directory (Admin Only) -->
   <!--        <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/ParentDirectoryServlet?tab=parents" 
               class="nav-btn <%= "parents".equals(activeTab) ? "btn-active" : "" %>">
                Parent Directory
            </a>
        <% } %> --> 

        <!-- Weekly News -->
        <a href="${pageContext.request.contextPath}/NewsServlet?tab=news" 
           class="nav-btn <%= "news".equals(activeTab) ? "btn-active" : "" %>">
            News
        </a>

        <!-- Direct Message (Parent & Teacher Only) -->
        <% if (!isAdmin) { %>
            <a href="${pageContext.request.contextPath}/ChatServlet?tab=chat" 
               class="nav-btn <%= "chat".equals(activeTab) ? "btn-active" : "" %>">
                Direct Message
            </a>
        <% } %>
        
    </nav>

</aside>