<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>
<%@ page import="bean.Parent"%>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || role.isBlank()) {
        role = "Parent";
    }

    String name = (String) request.getAttribute("profileName");
    if (name == null) name = "User";

    // Jana huruf awalan (Initials) daripada nama sebenar
    String avatarInitials = "U";
    if (name != null && !name.isBlank() && !"User".equals(name)) {
        String[] parts = name.trim().split("\\s+");
        if (parts.length >= 2) {
            avatarInitials = ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        } else if (parts.length == 1) {
            avatarInitials = ("" + parts[0].charAt(0)).toUpperCase();
        }
    }

    String badgeColor = "#FFB3C6"; // Parent Pink
    String badgeText = "Parent";
    if ("Admin".equalsIgnoreCase(role)) {
        badgeColor = "#6C5CE7"; // Admin Purple
        badgeText = "Admin";
    } else if ("Teacher".equalsIgnoreCase(role)) {
        badgeColor = "#FFD02C"; // Teacher Yellow
        badgeText = "Teacher";
    }

    boolean isSuccess = "true".equals(request.getParameter("success"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix Centre - My Profile</title>

    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF;
        }

        .app-layout {
            display: flex;
            height: 100vh;
            width: 100%;
        }

        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background-color: #FFFFFF;
            z-index: 10;
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background-color: #FAF5EF;
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background-color: #FFFFFF;
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px 32px;
            overflow-y: auto;
        }

        .profile-container {
            max-width: 1000px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* Top Bar */
        .top-nav-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .btn-back {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 18px;
            background-color: #FFFFFF;
            border: 2px solid #2D3436;
            border-radius: 9999px;
            font-size: 0.8rem;
            font-weight: 800;
            color: #2D3436;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .btn-back:hover {
            background-color: #F8FAFC;
        }

        .breadcrumb-text {
            font-size: 0.8rem;
            font-weight: 800;
            color: #64748B;
        }

        /* Title Row */
        .title-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .page-title {
            font-size: 2rem;
            font-weight: 900;
            color: #2D3436;
            margin: 0;
        }

        .btn-edit-toggle {
            padding: 10px 28px;
            border-radius: 9999px;
            border: 2.5px solid #2D3436;
            font-size: 0.85rem;
            font-weight: 900;
            background-color: #FFFFFF;
            color: #2D3436;
            box-shadow: 3.5px 3.5px 0px 0px #2D3436;
            cursor: pointer;
            transition: all 0.15s ease;
        }

        .btn-edit-toggle:hover {
            background-color: #FFD02C;
        }

        /* Grid Layout */
        .profile-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 24px;
        }

        @media (min-width: 768px) {
            .profile-grid {
                grid-template-columns: 320px 1fr;
            }
        }

        /* Left Card */
        .profile-left-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 28px 20px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            justify-content: space-between;
            min-height: 420px;
            box-sizing: border-box;
        }

        .avatar-circle {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 3px solid #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            font-weight: 900;
            box-shadow: 3.5px 3.5px 0px 0px #2D3436;
            margin-bottom: 12px;
        }

        .user-name-title {
            font-size: 1.25rem;
            font-weight: 900;
            color: #2D3436;
            margin: 0 0 6px 0;
        }

        .role-badge-pill {
            display: inline-block;
            font-size: 0.65rem;
            font-weight: 900;
            text-transform: uppercase;
            padding: 4px 14px;
            border-radius: 9999px;
            border: 2px solid #2D3436;
            box-shadow: 1.5px 1.5px 0px 0px #2D3436;
        }

        .pill-field-group {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-top: 20px;
            padding-top: 16px;
            border-top: 2px dashed #CBD5E1;
            text-align: left;
        }

        .field-label-center {
            font-size: 0.75rem;
            font-weight: 900;
            text-transform: uppercase;
            color: #2D3436;
            margin-bottom: 6px;
            text-align: center;
            display: block;
        }

        .pill-input-box {
            width: 100%;
            border-radius: 9999px;
            border: 2px solid #2D3436;
            padding: 10px 16px;
            text-align: center;
            font-weight: 900;
            font-size: 0.85rem;
            background-color: #FAF5EF;
            color: #2D3436;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            outline: none;
            box-sizing: border-box;
        }

        /* Right Card */
        .profile-right-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            padding: 32px;
            box-shadow: 5px 5px 0px 0px #2D3436;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 18px;
            min-height: 420px;
            box-sizing: border-box;
        }

        .field-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .field-label {
            font-size: 0.85rem;
            font-weight: 900;
            color: #2D3436;
        }

        .field-input {
            width: 100%;
            border-radius: 9999px;
            border: 2px solid #2D3436;
            padding: 12px 20px;
            font-size: 0.9rem;
            font-weight: 700;
            color: #2D3436;
            background-color: #FAF5EF;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            box-sizing: border-box;
            outline: none;
        }

        .field-input.editable {
            background-color: #FFFFFF;
        }

        .field-input.editable:focus {
            background-color: #FFF9E6;
        }

        /* Container Khas Untuk Password & Eye Icon */
        .password-input-wrapper {
            position: relative;
            width: 100%;
        }

        .password-input-wrapper .field-input {
            padding-right: 48px;
        }

        .btn-toggle-eye {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #2D3436;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 4px;
            border-radius: 50%;
            transition: all 0.15s ease;
        }

        .btn-toggle-eye:hover {
            background-color: rgba(45, 52, 54, 0.1);
        }

        .action-bar {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 8px;
        }

        .btn-cancel {
            padding: 10px 24px;
            border-radius: 9999px;
            border: 2px solid #2D3436;
            font-size: 0.85rem;
            font-weight: 800;
            background-color: #FFFFFF;
            color: #2D3436;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            cursor: pointer;
        }

        .btn-save {
            padding: 10px 28px;
            border-radius: 9999px;
            border: 2px solid #2D3436;
            font-size: 0.85rem;
            font-weight: 900;
            background-color: #D1FAE5;
            color: #065F46;
            box-shadow: 3px 3px 0px 0px #2D3436;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .alert-success-banner {
            background-color: #D1FAE5;
            border: 2px solid #059669;
            color: #065F46;
            padding: 12px 20px;
            border-radius: 16px;
            font-size: 0.85rem;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>

    <div class="app-layout">
        
        <!-- Sidebar -->
        <aside class="app-sidebar-wrapper">
            <jsp:include page="sidebar.jsp" />
        </aside>

        <!-- Main Body Wrapper -->
        <main class="app-main-wrapper">
            
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <div class="app-content-body">
                
                <div class="profile-container">
                    
                    <!-- Title & Edit Button -->
                    <div class="title-row">
                        <h1 class="page-title">My Profile</h1>
                        
                        <button type="button" class="btn-edit-toggle" id="edit-toggle-btn" onclick="enableEditMode()">
                            Edit Profile
                        </button>
                    </div>

                    <% if (isSuccess) { %>
                        <div class="alert-success-banner">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            <span>Profile successfully updated!</span>
                        </div>
                    <% } %>

                    <!-- Form Wrapper -->
                    <form action="ProfileServlet" method="POST" id="profile-form">
                        
                        <div class="profile-grid">
                            
                            <!-- LEFT CARD -->
                            <div class="profile-left-card">
                                <div style="width: 100%; display: flex; flex-direction: column; align-items: center;">
                                    <div class="avatar-circle" style="background-color: <%= badgeColor %>; color: #2D3436;">
                                        <%= avatarInitials %>
                                    </div>
                                    <h2 class="user-name-title">${profileName}</h2>
                                    <span class="role-badge-pill" style="background-color: <%= badgeColor %>; color: #2D3436;">
                                        <%= badgeText %>
                                    </span>
                                </div>

                                <div class="pill-field-group">
                                    <div>
                                        <label class="field-label-center">PERSONAL ID</label>
                                        <input type="text" class="pill-input-box" value="${profilePersonalId}" readonly>
                                    </div>

                                    <div>
                                        <label class="field-label-center">IC NUMBER</label>
                                        <input type="text" class="pill-input-box" value="${profileIcNumber}" readonly>
                                    </div>
                                </div>
                            </div>

                            <!-- RIGHT CARD -->
                            <div class="profile-right-card">
                                
                                <div class="field-group">
                                    <label class="field-label">Full Name</label>
                                    <input type="text" name="name" class="field-input" value="${profileName}" required readonly id="input-name">
                                </div>

                                <div class="field-group">
                                    <label class="field-label">Email Address</label>
                                    <input type="email" name="email" class="field-input" value="${profileEmail}" required readonly id="input-email">
                                </div>

                                <!-- Field Password Dengan Eye Icon -->
                                <div class="field-group">
                                    <label class="field-label">Password</label>
                                    <div class="password-input-wrapper">
                                        <input type="password" name="password" class="field-input" value="${profilePassword}" required readonly id="input-password" placeholder="Enter password">
                                        <button type="button" class="btn-toggle-eye" onclick="togglePasswordVisibility()" title="Toggle Password Visibility">
                                            <svg id="eye-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                        </button>
                                    </div>
                                </div>

                                <div class="field-group">
                                    <label class="field-label">Phone Number</label>
                                    <input type="text" name="phone" class="field-input" value="${profilePhone}" required readonly id="input-phone">
                                </div>

                                <div class="field-group">
                                    <label class="field-label">Address</label>
                                    <input type="text" name="address" class="field-input" value="${profileAddress != null ? profileAddress : '742 Evergreen Terrace, Springfield'}" readonly id="input-address">
                                </div>

                                <div class="action-bar" id="edit-action-bar" style="display: none;">
                                    <button type="button" class="btn-cancel" onclick="disableEditMode()">Cancel</button>
                                    <button type="submit" class="btn-save">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                        Save Changes
                                    </button>
                                </div>

                            </div>

                        </div>

                    </form>

                </div>

            </div>

        </main>
    </div>

    <!-- Toggle Javascript -->
    <script>
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('input-password');
            const eyeIcon = document.getElementById('eye-icon');

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                // Tukar kepada SVG Eye-Off (Mata Bergaris Cross)
                eyeIcon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line>';
            } else {
                passwordInput.type = 'password';
                // Tukar kembali kepada SVG Eye Biasa
                eyeIcon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';
            }
        }

        function enableEditMode() {
            document.getElementById('edit-toggle-btn').style.display = 'none';
            document.getElementById('edit-action-bar').style.display = 'flex';

            const inputs = document.querySelectorAll('.field-input');
            inputs.forEach(input => {
                input.removeAttribute('readonly');
                input.classList.add('editable');
            });
        }

        function disableEditMode() {
            document.getElementById('edit-toggle-btn').style.display = 'block';
            document.getElementById('edit-action-bar').style.display = 'none';

            const inputs = document.querySelectorAll('.field-input');
            inputs.forEach(input => {
                input.setAttribute('readonly', 'true');
                input.classList.remove('editable');
            });
        }
    </script>
</body>
</html>