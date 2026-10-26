<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Keedflix Centre - Register Student</title>
    
    <style>
        /* ==========================================
           NEOBRUTALISM STYLING
           ========================================== */
        * { box-sizing: border-box; }
        html, body { height: 100%; margin: 0; background-color: #FAF5EF; color: #2D3436; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; overflow: hidden; }
        
        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background-color: #FFFFFF; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; min-width: 0; height: 100vh; overflow: hidden; }
        .app-header-wrapper { flex-shrink: 0; background-color: #FFFFFF; border-bottom: 3px solid #2D3436 !important; }
        .app-content-body { padding: 32px; flex-grow: 1; overflow-y: auto; background-color: #FAF5EF; display: flex; justify-content: center; }
        
        .register-container { width: 100%; max-width: 800px; display: flex; flex-direction: column; gap: 24px; margin-bottom: 40px; }
        
        /* Header Banner */
        .page-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px dashed #CBD5E1; padding-bottom: 12px; }
        .page-badge { background-color: #FFD02C; color: #2D3436; font-size: 10px; font-weight: 900; padding: 4px 10px; border-radius: 999px; border: 2px solid #2D3436; text-transform: uppercase; }
        .page-title { font-size: 1.8rem; font-weight: 900; margin: 8px 0 0 0; }
        
        /* Steps Indicators */
        .steps-wrapper { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .step-pill { padding: 12px; border-radius: 16px; border: 2px solid #2D3436; display: flex; align-items: center; gap: 12px; transition: all 0.2s; opacity: 0.7; background: #FFF; }
        .step-pill.active { opacity: 1; box-shadow: 3px 3px 0px 0px #2D3436; }
        .step-pill.active.parent-step { background-color: #FFD02C; }
        .step-pill.active.student-step { background-color: #D1F7E8; }
        .step-num { width: 32px; height: 32px; border-radius: 50%; border: 2px solid #2D3436; display: flex; align-items: center; justify-content: center; font-weight: 900; background: #FFF; }
        .step-pill.active .step-num { background: #2D3436; color: #FFF; }
        
        /* Form Cards */
        .form-card { background: #FFF; border: 3px solid #2D3436; border-radius: 24px; padding: 32px; box-shadow: 5px 5px 0px 0px #2D3436; }
        .form-row { display: grid; grid-template-columns: 1fr; gap: 20px; margin-bottom: 20px; }
        @media(min-width: 600px) { .form-row.two-cols { grid-template-columns: 1fr 1fr; } }
        
        .neo-label { display: block; font-size: 0.85rem; font-weight: 900; margin-bottom: 8px; color: #2D3436; }
        .neo-input { width: 100%; border: 2.5px solid #2D3436; border-radius: 999px; padding: 12px 20px; font-weight: 700; font-size: 0.9rem; box-shadow: 2px 2px 0px 0px #2D3436; outline: none; }
        .neo-input:focus { background-color: #FAF5EF; }
        select.neo-input { appearance: none; background-image: url('data:image/svg+xml;utf8,<svg fill="%232D3436" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>'); background-repeat: no-repeat; background-position-x: 95%; background-position-y: 50%; }
        
        /* Buttons */
        .btn-neo { padding: 12px 24px; border: 2.5px solid #2D3436; border-radius: 999px; font-weight: 900; cursor: pointer; box-shadow: 3px 3px 0px #2D3436; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; color: #2D3436; background: #FFF; transition: transform 0.1s; }
        .btn-neo:active { transform: translate(2px, 2px); box-shadow: 1px 1px 0px #2D3436; }
        .btn-yellow { background-color: #FFD02C; }
        .btn-mint { background-color: #D1F7E8; }
        
        /* Error Box */
        .error-box { background: #FFE3E3; border: 2px solid #FF6B6B; color: #D10000; padding: 12px; border-radius: 12px; font-weight: 900; font-size: 0.85rem; display: none; margin-bottom: 20px; }
    </style>
</head>
<body>

    <div class="app-layout">
        <!-- Sidebar -->
        <aside class="app-sidebar-wrapper">
            <jsp:include page="sidebar.jsp" />
        </aside>

        <!-- Main Content -->
        <main class="app-main-wrapper">
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <div class="app-content-body">
                <div class="register-container">
                    
                    <!-- Header -->
                    <div class="page-header">
                        <div>
                            <span class="page-badge">Student Enrollment Portal</span>
                            <h1 class="page-title">Register Student</h1>
                        </div>
                        <a href="StudentDirectoryServlet?tab=directory" class="btn-neo">← Back to Directory</a>
                    </div>

                    <!-- Step Indicators -->
                    <div class="steps-wrapper">
                        <div id="ind-step1" class="step-pill active parent-step">
                            <div class="step-num">1</div>
                            <div>
                                <div style="font-weight: 900; font-size: 0.9rem;">Parent's Information</div>
                                <div style="font-size: 0.7rem; color: #636E72;">Langkah 1: Maklumat Penjaga</div>
                            </div>
                        </div>
                        <div id="ind-step2" class="step-pill student-step">
                            <div class="step-num">2</div>
                            <div>
                                <div style="font-weight: 900; font-size: 0.9rem;">Student's Information</div>
                                <div style="font-size: 0.7rem; color: #636E72;">Langkah 2: Maklumat Murid</div>
                            </div>
                        </div>
                    </div>

                    <!-- ERROR MESSAGE -->
                    <div id="error-msg" class="error-box">Sila isikan semua maklumat yang wajib.</div>

                    <!-- MAIN FORM (POST ke Servlet) -->
                    <form action="RegisterStudentServlet" method="POST" id="registerForm">
                        
                        <!-- ================= CARD 1: PARENT ================= -->
                        <div id="card-step1" class="form-card">
                            <h2 style="margin-top: 0; font-weight: 900; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">Parent's Information</h2>
                            
                            <div class="form-row">
                                <div>
                                    <label class="neo-label">Full Name (Required)</label>
                                    <input type="text" name="parentName" id="parentName" class="neo-input" placeholder="e.g. Sarah Vance" required>
                                </div>
                            </div>
                            
                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">Email Address</label>
                                    <input type="email" name="parentEmail" id="parentEmail" class="neo-input" placeholder="e.g. sarah@example.com">
                                </div>
                                <div>
                                    <label class="neo-label">Phone Number (Numbers only)</label>
                                    <input type="number" name="parentPhone" id="parentPhone" class="neo-input" placeholder="e.g. 0123456789" required>
                                </div>
                            </div>

                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">IC Number (Parent)</label>
                                    <input type="text" name="parentIc" id="parentIc" class="neo-input" placeholder="e.g. 890412-10-5234">
                                </div>
                                <div>
                                    <label class="neo-label">Gender</label>
                                    <select name="parentGender" id="parentGender" class="neo-input" style="cursor: pointer; background-color: #FFF;">
                                        <option value="Female">Female</option>
                                        <option value="Male">Male</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-row">
                                <div>
                                    <label class="neo-label">Address</label>
                                    <input type="text" name="parentAddress" id="parentAddress" class="neo-input" placeholder="e.g. No. 12, Jalan Flora, Presint 3">
                                </div>
                            </div>
                            
                            <div style="display: flex; justify-content: flex-end; margin-top: 30px; border-top: 2px solid #E2E8F0; padding-top: 20px;">
                                <button type="button" class="btn-neo btn-yellow" onclick="goToStep2()">Next Step →</button>
                            </div>
                        </div>

                        <!-- ================= CARD 2: STUDENT ================= -->
                        <div id="card-step2" class="form-card" style="display: none;">
                            <h2 style="margin-top: 0; font-weight: 900; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">Student's Information</h2>
                            
                            <div class="form-row">
                                <div>
                                    <label class="neo-label">Student Full Name (Required)</label>
                                    <input type="text" name="studentName" id="studentName" class="neo-input" placeholder="e.g. Adam Rayyan" required>
                                </div>
                            </div>
                            
                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">Student IC Number</label>
                                    <input type="text" name="studentIc" id="studentIc" class="neo-input" placeholder="e.g. 190520-10-6181">
                                </div>
                                <div>
                                    <label class="neo-label">Gender</label>
                                    <select name="studentGender" id="studentGender" class="neo-input" style="cursor: pointer; background-color: #FFF;">
                                        <option value="Boy">Boy</option>
                                        <option value="Girl">Girl</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">Age (Numbers only)</label>
                                    <input type="number" name="studentAge" id="studentAge" class="neo-input" placeholder="e.g. 5" required>
                                </div>
                                <div>
                                    <label class="neo-label">Assigned Class</label>
                                    <select name="studentClass" id="studentClass" class="neo-input" style="cursor: pointer; background-color: #FFF;">
                                        <option value="Kindergarten 3B">Kindergarten 3B</option>
                                        <option value="Kindergarten 2A">Kindergarten 2A</option>
                                        <option value="Kindergarten 1">Kindergarten 1</option>
                                        <option value="Preschool 4A">Preschool 4A</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div style="display: flex; justify-content: space-between; margin-top: 30px; border-top: 2px solid #E2E8F0; padding-top: 20px;">
                                <button type="button" class="btn-neo" onclick="goToStep1()">← Back</button>
                                <div style="display: flex; gap: 10px;">
                                    <button type="button" class="btn-neo" onclick="resetStudentForm()">Reset</button>
                                    <button type="submit" class="btn-neo btn-mint">✔️ Confirm & Register</button>
                                </div>
                            </div>
                        </div>
                        
                    </form>
                </div>
            </div>
        </main>
    </div>

    <!-- SCRIPT KAWALAN ANTARAMUKA (UX) -->
    <script>
        function goToStep2() {
            const pName = document.getElementById('parentName').value.trim();
            const pPhone = document.getElementById('parentPhone').value.trim();
            const errorBox = document.getElementById('error-msg');

            // Validasi Asas (Mesti isi Nama dan Telefon sebelum ke Step 2)
            if(pName === '' || pPhone === '') {
                errorBox.style.display = 'block';
                errorBox.innerText = 'Sila masukkan sekurang-kurangnya Nama Penuh dan Nombor Telefon Penjaga.';
                return;
            }

            errorBox.style.display = 'none';
            
            // Sembunyikan kad 1, tunjuk kad 2
            document.getElementById('card-step1').style.display = 'none';
            document.getElementById('card-step2').style.display = 'block';
            
            // Ubah gaya indicator pil (pill)
            document.getElementById('ind-step1').classList.remove('active');
            document.getElementById('ind-step2').classList.add('active');
        }

        function goToStep1() {
            document.getElementById('error-msg').style.display = 'none';
            
            // Sembunyikan kad 2, tunjuk kad 1
            document.getElementById('card-step2').style.display = 'none';
            document.getElementById('card-step1').style.display = 'block';
            
            // Ubah gaya indicator pil (pill)
            document.getElementById('ind-step2').classList.remove('active');
            document.getElementById('ind-step1').classList.add('active');
        }
        
        function resetStudentForm() {
            document.getElementById('studentName').value = '';
            document.getElementById('studentIc').value = '';
            document.getElementById('studentAge').value = '';
            document.getElementById('studentGender').selectedIndex = 0;
            document.getElementById('studentClass').selectedIndex = 0;
        }
    </script>
</body>
</html>