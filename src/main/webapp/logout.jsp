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

	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/logout.css">

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
	    var modal = document.getElementById('logoutModalBackdrop');
	    if (modal) {
	        modal.classList.add('open');
	        modal.style.display = 'flex'; // Force display jika CSS class bermasalah
	        modal.setAttribute('aria-hidden', 'false');
	    } else {
	        console.error('Logout modal element (logoutModalBackdrop) not found!');
	    }
	}
	
	function closeLogoutModal() {
	    var modal = document.getElementById('logoutModalBackdrop');
	    if (modal) {
	        modal.classList.remove('open');
	        modal.style.display = 'none';
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