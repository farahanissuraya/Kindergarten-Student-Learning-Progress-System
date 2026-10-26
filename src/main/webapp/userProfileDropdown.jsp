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

<!-- STYLING NEOBRUTALISM DROPDOWN & MODAL LOGOUT -->
<style>
    .profile-dropdown-wrapper {
        position: relative;
        display: inline-block;
    }

    .profile-avatar-btn {
        width: 42px;
        height: 42px;
        border-radius: 9999px;
        border: 2.5px solid #2D3436;
        box-shadow: 2.5px 2.5px 0px 0px #2D3436;
        font-weight: 900;
        font-size: 0.85rem;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.15s ease;
    }

    .profile-avatar-btn:hover {
        transform: translate(-1px, -1px);
        box-shadow: 4px 4px 0px 0px #2D3436;
    }

    .profile-avatar-btn:active {
        transform: translate(1px, 1px);
        box-shadow: 1px 1px 0px 0px #2D3436;
    }

    /* Menu Container */
    .user-dropdown-menu {
        position: absolute;
        right: 0;
        top: calc(100% + 10px);
        width: 280px;
        background-color: #FFFFFF;
        border: 3px solid #2D3436;
        border-radius: 24px;
        box-shadow: 5px 5px 0px 0px #2D3436;
        z-index: 100;
        padding: 20px;
        display: none;
        flex-direction: column;
        user-select: none;
    }

    .user-dropdown-menu.show {
        display: flex;
    }

    /* Header Ringkasan Pengguna */
    .dropdown-user-header {
        display: flex;
        align-items: center;
        gap: 12px;
        border-bottom: 2px dashed #E2E8F0;
        padding-bottom: 12px;
        margin-bottom: 12px;
    }

    .dropdown-avatar-badge {
        width: 40px;
        height: 40px;
        border-radius: 9999px;
        border: 2px solid #2D3436;
        box-shadow: 2px 2px 0px 0px #2D3436;
        font-weight: 900;
        font-size: 0.8rem;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .dropdown-user-info {
        min-width: 0;
        flex-grow: 1;
    }

    .dropdown-user-name {
        font-size: 0.9rem;
        font-weight: 900;
        color: #2D3436;
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .dropdown-user-title {
        font-size: 0.75rem;
        color: #64748B;
        margin: 2px 0 0 0;
        font-weight: 600;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* Senarai Tindakan Menu */
    .dropdown-actions {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .dropdown-action-btn {
        width: 100%;
        text-align: left;
        padding: 10px 12px;
        border-radius: 12px;
        background-color: #FFFFFF;
        border: 2px solid transparent;
        font-size: 0.8rem;
        font-weight: 800;
        color: #2D3436;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: space-between;
        text-decoration: none;
        transition: all 0.15s ease;
        box-sizing: border-box;
    }

    .dropdown-action-btn:hover {
        background-color: #FAF5EF;
        border-color: #2D3436;
    }

    .dropdown-logout-wrapper {
        border-top: 2px dashed #E2E8F0;
        padding-top: 8px;
        margin-top: 4px;
    }

    .dropdown-logout-btn {
        width: 100%;
        text-align: left;
        padding: 10px 12px;
        border-radius: 12px;
        background-color: #FFFFFF;
        border: 2px solid transparent;
        font-size: 0.8rem;
        font-weight: 900;
        color: #E11D48;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: space-between;
        text-decoration: none;
        transition: all 0.15s ease;
        box-sizing: border-box;
    }

    .dropdown-logout-btn:hover {
        background-color: #FFE4E6;
        border-color: #FDA4AF;
    }

    /* ==========================================
       MODAL SIGN OUT NEOBRUTALISM STYLES
       ========================================== */
    .logout-modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(0, 0, 0, 0.45);
        backdrop-filter: blur(3px);
        z-index: 9999;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 20px;
        box-sizing: border-box;
    }

    .logout-modal-overlay.active {
        display: flex;
    }

    .logout-modal-card {
        background-color: #FFFFFF;
        border: 3.5px solid #2D3436;
        border-radius: 32px;
        box-shadow: 8px 8px 0px 0px #2D3436;
        width: 100%;
        max-width: 500px;
        padding: 32px;
        position: relative;
        box-sizing: border-box;
        animation: popIn 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }

    @keyframes popIn {
        from { transform: scale(0.9); opacity: 0; }
        to { transform: scale(1); opacity: 1; }
    }

    .modal-close-x {
        position: absolute;
        top: 24px;
        right: 24px;
        background: transparent;
        border: none;
        cursor: pointer;
        color: #64748B;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 4px;
        border-radius: 50%;
        transition: all 0.15s ease;
    }

    .modal-close-x:hover {
        color: #2D3436;
        background-color: #F1F5F9;
    }

    .modal-header-flex {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        margin-bottom: 20px;
    }

    .modal-icon-box {
        width: 56px;
        height: 56px;
        border-radius: 20px;
        background-color: #FFE4E6;
        border: 2.5px solid #2D3436;
        box-shadow: 3px 3px 0px 0px #2D3436;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #FF2A5F;
        flex-shrink: 0;
    }

    .modal-title-text {
        font-size: 1.4rem;
        font-weight: 900;
        color: #1E293B;
        margin: 0;
        line-height: 1.2;
    }

    .modal-subtitle-text {
        font-size: 0.82rem;
        font-weight: 600;
        color: #64748B;
        margin: 4px 0 0 0;
    }

    .modal-description-body {
        font-size: 0.88rem;
        color: #475569;
        font-weight: 500;
        line-height: 1.55;
        margin: 0 0 28px 0;
    }

    .modal-actions-flex {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
    }

    .btn-modal-cancel {
        padding: 12px 24px;
        border-radius: 9999px;
        border: 2px solid #CBD5E1;
        background-color: #FFFFFF;
        color: #475569;
        font-size: 0.85rem;
        font-weight: 800;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-modal-cancel:hover {
        background-color: #F8FAFC;
        border-color: #94A3B8;
        color: #1E293B;
    }

    .btn-modal-confirm {
        padding: 12px 24px;
        border-radius: 9999px;
        border: 2.5px solid #2D3436;
        background-color: #FF2A5F;
        color: #FFFFFF;
        font-size: 0.85rem;
        font-weight: 900;
        cursor: pointer;
        box-shadow: 3px 3px 0px 0px #2D3436;
        display: flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        transition: all 0.15s ease;
    }

    .btn-modal-confirm:hover {
        background-color: #E11D48;
        transform: translate(-1px, -1px);
        box-shadow: 4px 4px 0px 0px #2D3436;
    }

    .btn-modal-confirm:active {
        transform: translate(1px, 1px);
        box-shadow: 2px 2px 0px 0px #2D3436;
    }
</style>

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
                <span>View & Update Profile</span>
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