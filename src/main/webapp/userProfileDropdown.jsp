<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Ambil data profil sebenar daripada sesi Oracle pengguna
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || userRole.isBlank()) {
        userRole = (String) session.getAttribute("userRole");
    }
    if (userRole == null || userRole.isBlank()) {
        userRole = "Parent";
    }

    String userName = "User";
    String userTitle = "Family Hub User";

    if ("Parent".equalsIgnoreCase(userRole)) {
        if (session.getAttribute("parentName") != null) {
            userName = (String) session.getAttribute("parentName");
        }
        userTitle = "Parent / Guardian Connection";
    } else if ("Teacher".equalsIgnoreCase(userRole)) {
        if (session.getAttribute("teacherName") != null) {
            userName = (String) session.getAttribute("teacherName");
        }
        userTitle = "Kindergarten Lead Educator";
    } else if ("Admin".equalsIgnoreCase(userRole)) {
        if (session.getAttribute("teacherName") != null) {
            userName = (String) session.getAttribute("teacherName");
        }
        userTitle = "Centre Administrator";
    }

    // Jana huruf awalan (Initials) daripada nama sebenar pangkalan data
    String avatarInitials = "U";
    if (userName != null && !userName.isBlank() && !"User".equals(userName)) {
        String[] parts = userName.trim().split("\\s+");
        if (parts.length >= 2) {
            avatarInitials = ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        } else if (parts.length == 1) {
            avatarInitials = ("" + parts[0].charAt(0)).toUpperCase();
        }
    }

    // Warna latar belakang berasaskan peranan pengguna
    String avatarBgColor = "#FFB3C6"; // Parent (Pink)
    String avatarTextColor = "#2D3436";

    if ("Admin".equalsIgnoreCase(userRole)) {
        avatarBgColor = "#6C5CE7"; // Admin (Purple)
        avatarTextColor = "#FFFFFF";
    } else if ("Teacher".equalsIgnoreCase(userRole)) {
        avatarBgColor = "#FFD02C"; // Teacher (Yellow)
        avatarTextColor = "#2D3436";
    }
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/userProfileDropdown.css">

<!-- STRUKTUR HTML DROPDOWN -->
<div class="profile-dropdown-wrapper">
    <!-- Butang Avatar Pemicu -->
    <button type="button" class="profile-avatar-btn" id="user-avatar-trigger" 
            style="background-color: <%= avatarBgColor %>; color: <%= avatarTextColor %>;" 
            onclick="toggleProfileDropdown(event)">
        <%= avatarInitials %>
    </button>

    <!-- Menu Lungsur Popup -->
    <div class="user-dropdown-menu" id="user-profile-dropdown">
        
        <!-- Ringkasan Pengguna -->
        <div class="dropdown-user-header">
            <div class="dropdown-avatar-badge" style="background-color: <%= avatarBgColor %>; color: <%= avatarTextColor %>;">
                <%= avatarInitials %>
            </div>
            <div class="dropdown-user-info">
                <p class="dropdown-user-name"><%= userName %></p>
                <p class="dropdown-user-title"><%= userTitle %></p>
            </div>
        </div>

        <!-- Tindakan Profil & Keluar -->
        <div class="dropdown-actions">
            <a href="${pageContext.request.contextPath}/ProfileServlet" class="dropdown-action-btn" id="menu-view-profile-btn">
                <span>Profile</span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6C5CE7" stroke-width="2.5">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </a>

            <div class="dropdown-logout-wrapper">
                <!-- Memanggil Modal Sign Out bukannya terus redirect -->
                <a href="javascript:void(0);" onclick="openLogoutModal(event)" class="dropdown-logout-btn" id="menu-sign-out-btn">
                    <span>Sign Out</span>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                        <polyline points="16 17 21 12 16 7"></polyline>
                        <line x1="21" y1="12" x2="9" y2="12"></line>
                    </svg>
                </a>
            </div>
        </div>

    </div>
</div>

<!-- STRUKTUR HTML MODAL SIGN OUT NEOBRUTALISM -->
<div class="logout-modal-overlay" id="logoutModalOverlay" onclick="closeLogoutModalOnOverlay(event)">
    <div class="logout-modal-card" role="dialog" aria-modal="true" onclick="event.stopPropagation()">
        
        <!-- Butang Tutup (X) -->
        <button type="button" class="modal-close-x" onclick="closeLogoutModal()" aria-label="Close">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M18 6L6 18M6 6l12 12"></path>
            </svg>
        </button>

        <!-- Tajuk & Ikon -->
        <div class="modal-header-flex">
            <div class="modal-icon-box">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
            </div>
            <div>
                <h2 class="modal-title-text">Sign Out of Platform?</h2>
                <p class="modal-subtitle-text">End current active session in Keedflix Centre</p>
            </div>
        </div>

        <!-- Perenggan Penerangan -->
        <p class="modal-description-body">
            You will be redirected to the secure login screen. Any unsaved in-progress edits will be stored in your local session.
        </p>

        <!-- Butang Tindakan -->
        <div class="modal-actions-flex">
            <button type="button" class="btn-modal-cancel" onclick="closeLogoutModal()">
                Cancel
            </button>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn-modal-confirm" id="confirm-signout-link">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
                <span>Confirm Sign Out</span>
            </a>
        </div>

    </div>
</div>

<script>
    function toggleProfileDropdown(event) {
        event.stopPropagation();
        const dropdown = document.getElementById('user-profile-dropdown');
        if (dropdown) {
            dropdown.classList.toggle('show');
        }
    }

    function openLogoutModal(event) {
        if (event) event.stopPropagation();
        
        // 1. Tutup dropdown menu
        const dropdown = document.getElementById('user-profile-dropdown');
        if (dropdown) {
            dropdown.classList.remove('show');
        }

        // 2. Buka modal overlay
        const modal = document.getElementById('logoutModalOverlay');
        if (modal) {
            // Memindahkan modal terus ke <body> supaya overlay gelap dapat menutup sidebar
            if (modal.parentNode !== document.body) {
                document.body.appendChild(modal);
            }
            modal.classList.add('active');
        }
    }

    function closeLogoutModal() {
        const modal = document.getElementById('logoutModalOverlay');
        if (modal) {
            modal.classList.remove('active');
        }
    }

    function closeLogoutModalOnOverlay(event) {
        if (event.target.id === 'logoutModalOverlay') {
            closeLogoutModal();
        }
    }

    window.addEventListener('click', function(event) {
        const dropdown = document.getElementById('user-profile-dropdown');
        const trigger = document.getElementById('user-avatar-trigger');
        if (dropdown && dropdown.classList.contains('show')) {
            if (!dropdown.contains(event.target) && !trigger.contains(event.target)) {
                dropdown.classList.remove('show');
            }
        }
    });

    window.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeLogoutModal();
        }
    });
</script>