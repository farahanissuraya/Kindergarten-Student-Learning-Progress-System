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

<!-- STYLING NEOBRUTALISM DROPDOWN -->
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
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="dropdown-logout-btn" id="menu-sign-out-btn">
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

<!-- JAVASCRIPT KAWALAN BUKA/TUTUP -->
<script>
    function toggleProfileDropdown(event) {
        event.stopPropagation();
        const dropdown = document.getElementById('user-profile-dropdown');
        if (dropdown) {
            dropdown.classList.toggle('show');
        }
    }

    // Tutup dropdown secara automatik apabila pengguna menekan di luar menu
    window.addEventListener('click', function(event) {
        const dropdown = document.getElementById('user-profile-dropdown');
        const trigger = document.getElementById('user-avatar-trigger');
        if (dropdown && dropdown.classList.contains('show')) {
            if (!dropdown.contains(event.target) && !trigger.contains(event.target)) {
                dropdown.classList.remove('show');
            }
        }
    });
</script>