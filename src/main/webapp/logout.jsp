<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>

<%
    // Ambil data pengguna dari session (fallback jika tiada)
    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.isBlank()) {
        Teacher teacher = (Teacher) session.getAttribute("user");
        userName = (teacher != null && teacher.getTeacherName() != null) ? teacher.getTeacherName() : "Current User";
    }

    String userRole = (String) session.getAttribute("role");
    if (userRole == null || userRole.isBlank()) {
        userRole = "Teacher";
    }
%>

<!-- Gaya CSS Khas untuk Modal Log Keluar -->
<style>
    /* Overlay Latar Belakang Modal */
    .logout-modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.6);
        backdrop-filter: blur(2px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        padding: 16px;
        opacity: 0;
        visibility: hidden;
        transition: opacity 0.2s ease, visibility 0.2s ease;
    }

    .logout-modal-backdrop.open {
        opacity: 1;
        visibility: visible;
    }

    /* Kotak Dialog Modal */
    .logout-modal-card {
        background-color: #FFFFFF;
        border-radius: 24px;
        width: 100%;
        max-width: 440px;
        padding: 28px;
        position: relative;
        z-index: 1010;
        border: 2px solid #2D3436;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
        transform: scale(0.95) translateY(10px);
        transition: transform 0.2s ease;
        box-sizing: border-box;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .logout-modal-backdrop.open .logout-modal-card {
        transform: scale(1) translateY(0);
    }

    /* Butang Tutup (X) */
    .modal-close-btn {
        position: absolute;
        top: 20px;
        right: 20px;
        padding: 6px;
        border-radius: 50%;
        background: transparent;
        border: none;
        color: #71717A;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background-color 0.15s ease;
    }

    .modal-close-btn:hover {
        background-color: #F4F4F5;
    }

    /* Header & Ikon */
    .modal-header-container {
        display: flex;
        align-items: center;
        gap: 14px;
        margin-bottom: 16px;
    }

    .modal-icon-box {
        width: 48px;
        height: 48px;
        border-radius: 16px;
        background-color: #FFE4E6;
        border: 2px solid #2D3436;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #E11D48;
        box-shadow: 2px 2px 0px #2D3436;
        flex-shrink: 0;
    }

    .modal-title {
        font-size: 1.25rem;
        font-weight: 900;
        color: #2D3436;
        margin: 0;
        letter-spacing: -0.02em;
    }

    .modal-subtitle {
        font-size: 0.75rem;
        color: #71717A;
        font-weight: 500;
        margin: 2px 0 0 0;
    }

    .modal-description {
        font-size: 0.75rem;
        color: #52525B;
        font-weight: 500;
        line-height: 1.6;
        margin: 16px 0;
    }

    .user-info-pill {
        font-weight: 700;
        color: #2D3436;
    }

    /* Butang Tindakan */
    .modal-actions {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
        padding-top: 8px;
    }

    .btn-cancel {
        padding: 10px 20px;
        border-radius: 12px;
        border: 2px solid rgba(45, 52, 54, 0.3);
        background-color: #FFFFFF;
        color: #404040;
        font-size: 0.75rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-cancel:hover {
        border-color: #2D3436;
        background-color: #F4F4F5;
    }

    .btn-confirm-logout {
        padding: 10px 20px;
        border-radius: 12px;
        border: 2px solid #2D3436;
        background-color: #F43F5E;
        color: #FFFFFF;
        font-size: 0.75rem;
        font-weight: 900;
        cursor: pointer;
        box-shadow: 2px 2px 0px #2D3436;
        display: flex;
        align-items: center;
        gap: 6px;
        text-decoration: none;
        transition: all 0.15s ease;
    }

    .btn-confirm-logout:hover {
        background-color: #E11D48;
    }

    .btn-confirm-logout:active {
        transform: translate(1px, 1px);
        box-shadow: 1px 1px 0px #2D3436;
    }
</style>

<!-- Struktur HTML Modal -->
<div class="logout-modal-backdrop" id="logoutModalBackdrop" aria-hidden="true">
    <!-- Click Outside Backdrop Handler -->
    <div style="position: absolute; inset: 0;" onclick="closeLogoutModal()"></div>

    <div class="logout-modal-card" role="dialog" aria-modal="true" aria-labelledby="logout-dialog-title">
        <!-- Butang Tutup (X) -->
        <button type="button" class="modal-close-btn" onclick="closeLogoutModal()" aria-label="Close dialog">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12"/>
            </svg>
        </button>

        <!-- Header Modal -->
        <div class="modal-header-container">
            <div class="modal-icon-box">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
            </div>
            <div>
                <h3 id="logout-dialog-title" class="modal-title">Sign Out of Platform?</h3>
                <p class="modal-subtitle">End current active session in Keedflix Centre</p>
            </div>
        </div>

        <p class="modal-description">
            Logged in as <span class="user-info-pill"><%= userName %> (<%= userRole %>)</span>. You will be redirected to the secure login screen.
        </p>

        <!-- Butang Tindakan -->
        <div class="modal-actions">
            <button type="button" class="btn-cancel" onclick="closeLogoutModal()">
                Cancel
            </button>
            <a href="LogoutServlet" class="btn-confirm-logout" id="confirm-logout-btn">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
                <span>Confirm Sign Out</span>
            </a>
        </div>
    </div>
</div>

<!-- JavaScript untuk Buka & Tutup Modal -->
<script>
    function openLogoutModal() {
        const modal = document.getElementById('logoutModalBackdrop');
        if (modal) {
            modal.classList.add('open');
            modal.setAttribute('aria-hidden', 'false');
        }
    }

    function closeLogoutModal() {
        const modal = document.getElementById('logoutModalBackdrop');
        if (modal) {
            modal.classList.remove('open');
            modal.setAttribute('aria-hidden', 'true');
        }
    }

    // Pautkan secara automatik ke butang Sign Out dalam sidebar jika wujud
    document.addEventListener('DOMContentLoaded', function() {
        const sidebarSignOutBtn = document.getElementById('nav-sign-out');
        if (sidebarSignOutBtn) {
            sidebarSignOutBtn.addEventListener('click', function(e) {
                e.preventDefault();
                openLogoutModal();
            });
        }
    });
</script>