<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Teacher"%>
<%@ page import="bean.Parent"%>
<%@ page import="util.IconUtil"%>

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">

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
                            <%= IconUtil.icon("Edit2", "icon-sm") %>
                            <span>Edit Profile</span>
                        </button>
                    </div>

                    <% if (isSuccess) { %>
                        <div class="alert-success-banner">
                            <%= IconUtil.icon("CheckCircle", "icon-md") %>
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
                                        <%= IconUtil.icon("ShieldCheck", "icon-xs") %>
                                        <span><%= badgeText %></span>
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
                                    <label class="field-label">
                                        <%= IconUtil.icon("User", "icon-xs") %> Full Name
                                    </label>
                                    <input type="text" name="name" class="field-input" value="${profileName}" required readonly id="input-name">
                                </div>

                                <div class="field-group">
                                    <label class="field-label">
                                        <%= IconUtil.icon("Mail", "icon-xs") %> Email Address
                                    </label>
                                    <input type="email" name="email" class="field-input" value="${profileEmail}" required readonly id="input-email">
                                </div>

                                <!-- Field Password Dengan Eye Icon -->
                                <div class="field-group">
                                    <label class="field-label">
                                        <%= IconUtil.icon("KeyRound", "icon-xs") %> Password
                                    </label>
                                    <div class="password-input-wrapper">
                                        <input type="password" name="password" class="field-input" value="${profilePassword}" required readonly id="input-password" placeholder="Enter password">
                                        <button type="button" class="btn-toggle-eye" onclick="togglePasswordVisibility()" title="Toggle Password Visibility">
                                            <span id="eye-show" style="display: inline-flex;">
                                                <%= IconUtil.icon("Eye", "icon-md") %>
                                            </span>
                                            <span id="eye-hide" style="display: none;">
                                                <i data-lucide="eye-off" class="icon-md"></i>
                                            </span>
                                        </button>
                                    </div>
                                </div>

                                <div class="field-group">
                                    <label class="field-label">
                                        <%= IconUtil.icon("Phone", "icon-xs") %> Phone Number
                                    </label>
                                    <input type="text" name="phone" class="field-input" value="${profilePhone}" required readonly id="input-phone">
                                </div>

                                <div class="field-group">
                                    <label class="field-label">
                                        <%= IconUtil.icon("MapPin", "icon-xs") %> Address
                                    </label>
                                    <input type="text" name="address" class="field-input" value="${profileAddress != null ? profileAddress : '742 Evergreen Terrace, Springfield'}" readonly id="input-address">
                                </div>

                                <div class="action-bar" id="edit-action-bar" style="display: none;">
                                    <button type="button" class="btn-cancel" onclick="disableEditMode()">
                                        <%= IconUtil.icon("X", "icon-xs") %> Cancel
                                    </button>
                                    <button type="submit" class="btn-save">
                                        <%= IconUtil.icon("Check", "icon-xs") %> Save Changes
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
            const eyeShow = document.getElementById('eye-show');
            const eyeHide = document.getElementById('eye-hide');

            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeShow.style.display = 'none';
                eyeHide.style.display = 'inline-flex';
            } else {
                passwordInput.type = 'password';
                eyeShow.style.display = 'inline-flex';
                eyeHide.style.display = 'none';
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
            document.getElementById('edit-toggle-btn').style.display = 'inline-flex';
            document.getElementById('edit-action-bar').style.display = 'none';

            const inputs = document.querySelectorAll('.field-input');
            inputs.forEach(input => {
                input.setAttribute('readonly', 'true');
                input.classList.remove('editable');
            });
        }
    </script>

    <jsp:include page="icons.jsp" />
</body>
</html>