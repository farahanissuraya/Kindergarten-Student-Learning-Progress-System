<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ParentDAO"%>
<%@ page import="dao.TeacherDAO"%>
<%@ page import="bean.Parent"%>
<%@ page import="bean.Teacher"%>

<%
    // =========================================================
    // SESSION RETRIEVAL
    // =========================================================
    String roleTB = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "Parent";
    
    String fullNameTB = "User";
    String initials = "U";

    // =========================================================
    // DATA MAPPING BASED ON ROLE
    // =========================================================
    if ("Parent".equalsIgnoreCase(roleTB)) {
        Integer parentId = (Integer) session.getAttribute("parentId");
        if (parentId != null) {
            try {
                ParentDAO pDao = new ParentDAO();
                Parent parent = pDao.getParentById(parentId);
                if (parent != null && parent.getParentName() != null) {
                    fullNameTB = parent.getParentName();
                }
            } catch (Exception e) {
                if (session.getAttribute("parentName") != null) {
                    fullNameTB = session.getAttribute("parentName").toString();
                }
            }
        }
    } else if ("Teacher".equalsIgnoreCase(roleTB) || "Admin".equalsIgnoreCase(roleTB)) {
        Integer teacherId = (Integer) session.getAttribute("teacherId");
        if (teacherId != null) {
            try {
                TeacherDAO tDao = new TeacherDAO();
                Teacher teacher = tDao.getTeacherById(teacherId);
                if (teacher != null && teacher.getTeacherName() != null) {
                    fullNameTB = teacher.getTeacherName();
                }
            } catch (Exception e) {
                if (session.getAttribute("teacherName") != null) {
                    fullNameTB = session.getAttribute("teacherName").toString();
                }
            }
        }
    }

    // Generate Initials (e.g., "Sarah Vance" -> "SV")
    if (fullNameTB != null && !fullNameTB.isBlank() && !"User".equals(fullNameTB)) {
        String[] nameParts = fullNameTB.trim().split("\\s+");
        if (nameParts.length >= 2) {
            initials = ("" + nameParts[0].charAt(0) + nameParts[1].charAt(0)).toUpperCase();
        } else if (nameParts.length == 1) {
            initials = ("" + nameParts[0].charAt(0)).toUpperCase();
        }
    }

    // Portal Platform Badge & Subtitle
    String platformBadge = "PARENT PLATFORM";
    String platformSubtitle = "Family Connection Hub";

    if ("Admin".equalsIgnoreCase(roleTB)) {
        platformBadge = "ADMIN PLATFORM";
        platformSubtitle = "Management & Administrative Hub";
    } else if ("Teacher".equalsIgnoreCase(roleTB)) {
        platformBadge = "TEACHER PLATFORM";
        platformSubtitle = "Classroom & Student Tracking Hub";
    }
%>

<link rel="stylesheet" type="text/css" href="css/header.css">

<header class="topbar-header">
    <!-- Left Side: Portal Badge & Subtitle -->
    <div class="header-left">
        <div class="platform-badge">
            <svg class="heart-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
            </svg>
            <span><%= platformBadge %></span>
        </div>
        <span class="platform-subtitle"><%= platformSubtitle %></span>
    </div>

    <!-- Right Side: Notification & User Profile Dropdown -->
    <div class="header-right">
        <!-- Notification Icon -->
        <button class="icon-btn" title="Notifications">
            <svg class="bell-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
            </svg>
            <span class="notification-dot"></span>
        </button>

        <!-- User Profile Avatar & Dropdown Menu -->
        <div class="profile-dropdown-container">
            <button class="avatar-btn">
                <%= initials %>
            </button>

            <!-- Dropdown Menu -->
            <div class="dropdown-menu">
                <div class="dropdown-header">
                    <p class="user-name"><%= fullNameTB %></p>
                    <p class="user-role"><%= roleTB %></p>
                </div>
                <div class="dropdown-body">
                    <a href="Profile" class="dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                        </svg>
                        <span>MY PROFILE</span>
                    </a>
                    <a href="LogoutServlet" class="dropdown-item logout-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16 17 21 12 16 7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        <span>LOG OUT</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</header>