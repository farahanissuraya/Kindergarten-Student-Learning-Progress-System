<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix Centre - Log Masuk</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">

</head>
<body>

    <div class="card">
        <h1 class="title">Keedflix Centre</h1>

        <%-- Mengingati peranan dan e-mel sebenar jika terdapat pusingan semula selepas log masuk gagal --%>
        <% 
            String selectedRole = request.getParameter("role");
            if (selectedRole == null || selectedRole.isBlank()) {
                selectedRole = "Parent"; // Laluan peranan pilihan utama
            }

            // Ambil e-mel yang ditaip oleh pengguna (kosong jika baru buka halaman)
            String enteredEmail = request.getParameter("email");
            if (enteredEmail == null) {
                enteredEmail = ""; // Tiada e-mel dummy
            }

            String error = request.getParameter("error");
            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");

            if (error != null && !error.isBlank()) { 
        %>
            <div class="alert-error"><%= error %></div>
        <% } else if (errorMessage != null && !errorMessage.isBlank()) { %>
            <div class="alert-error"><%= errorMessage %></div>
        <% } %>

        <% if (successMessage != null && !successMessage.isBlank()) { %>
            <div class="alert-success"><%= successMessage %></div>
        <% } %>

        <%-- FORM LOG MASUK --%>
        <div id="loginFormContainer">
            <form action="LoginServlet" method="POST">
                <input type="hidden" name="action" value="login">

                <!-- Pilihan Peranan -->
                <div class="role-selector">
                    <label class="role-option">
                        <input type="radio" name="role" value="Parent" <%= "Parent".equalsIgnoreCase(selectedRole) ? "checked" : "" %>>
                        Parent
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Teacher" <%= "Teacher".equalsIgnoreCase(selectedRole) ? "checked" : "" %>>
                        Teacher
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Admin" <%= "Admin".equalsIgnoreCase(selectedRole) ? "checked" : "" %>>
                        Admin
                    </label>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" value="<%= enteredEmail %>" required class="form-input" placeholder="e.g. name@keedflix.com">
                </div>

                <!-- Kata Laluan -->
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" value="" required class="form-input" placeholder="Enter your password">
                </div>

                <div class="btn-container">
                    <button type="submit" class="btn-submit">Sign in</button>
                </div>

                <div style="text-align: center;">
                    <button type="button" class="link-btn" onclick="openForgotPasswordModal()">Forget Password</button>
                </div>
            </form>
        </div>
    </div>

    <%-- MODAL FORGOT PASSWORD --%>
    <div id="forgotPasswordModal" class="modal-overlay">
        <div class="modal-card">
            <div class="modal-header">
                <h3>Reset Your Password</h3>
                <button type="button" class="close-btn" onclick="closeForgotPasswordModal()">&times;</button>
            </div>

            <form action="LoginServlet" method="POST">
                <input type="hidden" name="action" value="resetPassword">

                <p style="font-size: 0.75rem; color: #4B5563; margin-bottom: 12px;">
                    Enter the email address associated with your account. We'll send you a secure link to reset your password.
                </p>

                <div class="form-group">
                    <label for="resetEmail">Account Email</label>
                    <input type="email" id="resetEmail" name="resetEmail" required class="form-input" placeholder="e.g. user@keedflix.com">
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeForgotPasswordModal()">Cancel</button>
                    <button type="submit" class="btn-reset">Send Reset Link</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Kawalan Modal Forgot Password
        function openForgotPasswordModal() {
            const currentEmail = document.getElementById('email').value;
            document.getElementById('resetEmail').value = currentEmail;
            document.getElementById('forgotPasswordModal').style.display = 'flex';
        }

        function closeForgotPasswordModal() {
            document.getElementById('forgotPasswordModal').style.display = 'none';
        }
    </script>
</body>
</html>