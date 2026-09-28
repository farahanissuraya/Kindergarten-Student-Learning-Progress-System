<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix Centre - Log Masuk</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }

        body {
            background-color: #828282;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px;
        }

        ::selection {
            background-color: #8A9E77;
            color: #ffffff;
        }

        .card {
            background-color: #EFEFEF;
            border-radius: 32px;
            width: 100%;
            max-width: 460px;
            padding: 36px 32px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(212, 212, 212, 0.6);
        }

        .title {
            font-size: 1.75rem;
            font-weight: 800;
            text-align: center;
            color: #000000;
            letter-spacing: -0.025em;
            margin-bottom: 24px;
        }

        /* Peranan / Radio Selector */
        .role-selector {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 28px;
            margin-bottom: 24px;
            user-select: none;
        }

        .role-option {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-size: 0.95rem;
            color: #000000;
        }

        .role-option input[type="radio"] {
            accent-color: #000000;
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        /* Borang Input */
        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 700;
            color: #000000;
            margin-bottom: 6px;
            margin-left: 4px;
        }

        .form-input {
            width: 100%;
            background-color: #D6D6D6;
            color: #171717;
            border-radius: 9999px;
            padding: 12px 20px;
            font-size: 0.875rem;
            font-weight: 500;
            border: 1px solid transparent;
            outline: none;
            transition: all 0.2s ease;
        }

        .form-input:hover {
            background-color: #D0D0D0;
        }

        .form-input:focus {
            background-color: #FFFFFF;
            border-color: #8A9E77;
            box-shadow: 0 0 0 2px #8A9E77;
        }

        /* Banner Mesej */
        .alert-error {
            background-color: #FEE2E2;
            border: 1px solid #F87171;
            color: #B91C1C;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 10px 14px;
            border-radius: 12px;
            margin-bottom: 16px;
        }

        .alert-success {
            background-color: rgba(138, 158, 119, 0.2);
            border: 1px solid #8A9E77;
            color: #3E522F;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 10px 14px;
            border-radius: 12px;
            margin-bottom: 16px;
        }

        /* Butang */
        .btn-container {
            text-align: center;
            margin-top: 8px;
        }

        .btn-submit {
            width: 170px;
            background-color: #8A9E77;
            color: #000000;
            font-weight: 700;
            font-size: 0.875rem;
            border-radius: 9999px;
            padding: 10px 24px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-block;
        }

        .btn-submit:hover {
            background-color: #7D916B;
        }

        .btn-submit:active {
            background-color: #728560;
            transform: scale(0.98);
        }

        .link-btn {
            background: none;
            border: none;
            color: #262626;
            font-size: 0.8rem;
            cursor: pointer;
            margin-top: 10px;
            text-decoration: none;
            display: inline-block;
        }

        .link-btn:hover {
            color: #000000;
            text-decoration: underline;
        }

        .toggle-auth {
            text-align: center;
            margin-top: 6px;
        }

        /* Modal Reset Kata Laluan */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(2px);
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: 16px;
        }

        .modal-card {
            background-color: #FFFFFF;
            border-radius: 24px;
            width: 100%;
            max-width: 420px;
            padding: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #F3F4F6;
            padding-bottom: 12px;
            margin-bottom: 16px;
        }

        .modal-header h3 {
            font-size: 1.125rem;
            font-weight: 700;
            color: #111827;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 1.25rem;
            color: #6B7280;
            cursor: pointer;
        }

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 8px;
            margin-top: 16px;
        }

        .btn-cancel {
            background: none;
            border: none;
            padding: 8px 16px;
            font-size: 0.75rem;
            font-weight: 600;
            color: #4B5563;
            cursor: pointer;
        }

        .btn-reset {
            background-color: #8A9E77;
            color: #000000;
            padding: 8px 20px;
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: 9999px;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>

    <div class="card">
        <h1 class="title">Keedflix Centre</h1>

        <%-- Paparan Mesej Ralat / Kejayaan daripada Servlet --%>
        <% 
            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");
            if (errorMessage != null) { 
        %>
            <div class="alert-error"><%= errorMessage %></div>
        <% } %>
        <% if (successMessage != null) { %>
            <div class="alert-success"><%= successMessage %></div>
        <% } %>

        <%-- FORM LOG MASUK --%>
        <div id="loginFormContainer">
            <form action="LoginServlet" method="POST">
                <input type="hidden" name="action" value="login">

                <!-- Pilihan Peranan -->
                <div class="role-selector">
                    <label class="role-option">
                        <input type="radio" name="role" value="Parent" checked onclick="updateDefaultEmail('Parent')">
                        Parent
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Teacher" onclick="updateDefaultEmail('Teacher')">
                        Teacher
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Admin" onclick="updateDefaultEmail('Admin')">
                        Admin
                    </label>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" value="sarah.vance@example.com" required class="form-input" placeholder="e.g. name@keedflix.com">
                </div>

                <!-- Kata Laluan -->
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" value="••••••••" required class="form-input" placeholder="Enter your password">
                </div>

                <div class="btn-container">
                    <button type="submit" class="btn-submit">Sign in</button>
                </div>

                <div style="text-align: center;">
                    <button type="button" class="link-btn" onclick="openForgotPasswordModal()">Forget Password</button>
                </div>
            </form>

            <div class="toggle-auth">
                <button type="button" class="link-btn" onclick="toggleAuthMode('register')">Don't have an account? Register</button>
            </div>
        </div>

        <%-- FORM PENDAFTARAN --%>
        <div id="registerFormContainer" style="display: none;">
            <form action="LoginServlet" method="POST">
                <input type="hidden" name="action" value="register">

                <div style="text-align: center; margin-top: -8px; margin-bottom: 12px;">
                    <span style="font-size: 0.75rem; font-weight: 600; color: #525252; text-transform: uppercase;">
                        Create Account
                    </span>
                </div>

                <!-- Pilihan Peranan bagi Pendaftaran -->
                <div class="role-selector">
                    <label class="role-option">
                        <input type="radio" name="role" value="Parent" checked>
                        Parent
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Teacher">
                        Teacher
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="Admin">
                        Admin
                    </label>
                </div>

                <!-- Nama Penuh -->
                <div class="form-group">
                    <label for="regName">Full Name *</label>
                    <input type="text" id="regName" name="regName" required class="form-input" placeholder="e.g. Ms. Clara Davis">
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="regEmail">Email Address *</label>
                    <input type="email" id="regEmail" name="regEmail" required class="form-input" placeholder="e.g. new.educator@keedflix.edu">
                </div>

                <!-- Nombor Telefon -->
                <div class="form-group">
                    <label for="regPhone">Phone Number</label>
                    <input type="tel" id="regPhone" name="regPhone" class="form-input" placeholder="e.g. +1 (555) 019-2834">
                </div>

                <!-- Kata Laluan -->
                <div class="form-group">
                    <label for="regPassword">Password *</label>
                    <input type="password" id="regPassword" name="regPassword" required class="form-input" placeholder="Create a secure password">
                </div>

                <div class="btn-container">
                    <button type="submit" class="btn-submit" style="width: 200px;">Register Account</button>
                </div>
            </form>

            <div class="toggle-auth">
                <button type="button" class="link-btn" onclick="toggleAuthMode('login')">Already have an account? Sign in</button>
            </div>
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
        // Tukar mod antara Log Masuk dan Pendaftaran
        function toggleAuthMode(mode) {
            const loginForm = document.getElementById('loginFormContainer');
            const registerForm = document.getElementById('registerFormContainer');
            if (mode === 'register') {
                loginForm.style.display = 'none';
                registerForm.style.display = 'block';
            } else {
                loginForm.style.display = 'block';
                registerForm.style.display = 'none';
            }
        }

        // Kemaskini cadangan e-mel berdasarkan peranan yang dipilih
        function updateDefaultEmail(role) {
            const emailInput = document.getElementById('email');
            if (role === 'Parent') {
                emailInput.value = 'sarah.vance@example.com';
            } else if (role === 'Teacher') {
                emailInput.value = 'clara.davis@keedflix.edu';
            } else if (role === 'Admin') {
                emailInput.value = 'principal.ward@keedflix.edu';
            }
        }

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