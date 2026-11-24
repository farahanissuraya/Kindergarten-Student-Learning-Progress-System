<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="bean.Parent"%>
<%@ page import="util.IconUtil"%>

<%
    List<Parent> existingParents = (List<Parent>) request.getAttribute("existingParents");
    Map<Integer, String> parentChildrenMap = (Map<Integer, String>) request.getAttribute("parentChildrenMap");

    // Jika halaman dibuka terus melalui URL .jsp tanpa melalui Servlet, redirect ke Servlet
    if (existingParents == null) {
        response.sendRedirect("RegisterStudentServlet");
        return;
    }

    int parentCount = existingParents.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Keedflix Centre - Register Student</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/registerStudent.css">

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
                        <a href="StudentDirectoryServlet?tab=directory" class="btn-neo">
                            <%= IconUtil.icon("ArrowLeft", "icon-sm") %>
                            <span>Back to Directory</span>
                        </a>
                    </div>

                    <!-- Step Indicators -->
                    <div class="steps-wrapper">
                        <div id="ind-step1" class="step-pill active parent-step">
                            <div class="step-num">1</div>
                            <div>
                                <div style="font-weight: 900; font-size: 0.9rem;">Parent's Information</div>
                                <div id="step1-sub" style="font-size: 0.72rem; color: #475569; font-weight: 700;">Langkah 1: Maklumat Penjaga</div>
                            </div>
                        </div>
                        <div id="ind-step2" class="step-pill student-step">
                            <div class="step-num">2</div>
                            <div>
                                <div style="font-weight: 900; font-size: 0.9rem;">Student's Information</div>
                                <div style="font-size: 0.72rem; color: #475569; font-weight: 700;">Langkah 2: Maklumat Murid</div>
                            </div>
                        </div>
                    </div>

                    <!-- ERROR MESSAGE -->
                    <div id="error-msg" class="error-box">
                        <%= IconUtil.icon("AlertCircle", "icon-sm") %>
                        <span id="error-text">Sila isikan semua maklumat yang wajib.</span>
                    </div>

                    <!-- MAIN FORM (POST ke Servlet) -->
                    <form action="RegisterStudentServlet" method="POST" id="registerForm">
                        <!-- Hidden field untuk simpan ID jika memilih penjaga sedia ada -->
                        <input type="hidden" name="existingParentId" id="existingParentId" value="">
                        <input type="hidden" id="selectedParentChildren" value="">
                        
                        <!-- ================= CARD 1: PARENT ================= -->
                        <div id="card-step1" class="form-card">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #E2E8F0; padding-bottom: 14px; margin-bottom: 20px; gap: 12px; flex-wrap: wrap;">
                                <div>
                                    <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                                        <h2 style="margin: 0; font-weight: 900; display: flex; align-items: center; gap: 8px;">
                                            <%= IconUtil.icon("Users", "icon-md") %>
                                            <span>Parent's Information</span>
                                        </h2>
                                        <span id="selectedBadge" class="badge-selected-mint">
                                            <%= IconUtil.icon("CheckCircle", "icon-xs") %> DIPILIH / DATA TERSIMPAN
                                        </span>
                                    </div>
                                    <p id="parentCardHelper" style="margin: 6px 0 0 0; font-size: 0.78rem; color: #64748B; font-weight: 600;">
                                        Taip nama penuh penjaga — jika penjaga sudah berdaftar, pilih daripada senarai dropdown untuk auto-isi &amp; terus skip.
                                    </p>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 0.75rem; font-weight: 800; color: #64748B; display: block;">Step 1 of 2</span>
                                    <button type="button" id="resetParentLink" onclick="clearSelectedParent()" style="display: none; background: none; border: none; color: #EF4444; font-weight: 800; font-size: 0.75rem; cursor: pointer; padding: 4px 0 0 0;">
                                        (Batal / Klik X untuk tukar penjaga)
                                    </button>
                                </div>
                            </div>
                            
                            <!-- Full Name + Existing Parent Dropdown -->
                            <div class="form-row">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; flex-wrap: wrap; gap: 6px;">
                                        <label class="neo-label" style="margin-bottom: 0;">
                                            <%= IconUtil.icon("User", "icon-xs") %> Full Name
                                        </label>
                                    </div>

                                    <div class="parent-search-wrapper" id="parentSearchWrapper">
                                        <input type="text" name="parentName" id="parentName" class="neo-input" 
                                               placeholder="e.g. Sarah Vance (taip nama untuk cari rekod sedia ada)" 
                                               autocomplete="off"
                                               oninput="filterParentDropdown()" required>
                                        <button type="button" id="clearParentBtn" class="clear-parent-btn" onclick="clearSelectedParent()" title="Batal pilihan penjaga">
                                            <%= IconUtil.icon("X", "icon-xs") %>
                                        </button>

                                        <!-- Dropdown Senarai Penjaga Berdaftar -->
                                        <div class="parent-dropdown" id="parentDropdown">
                                            <div class="dropdown-header">
                                                <span style="display: inline-flex; align-items: center; gap: 6px;">
                                                    <%= IconUtil.icon("UserCheck", "icon-xs") %>
                                                    Penjaga Sudah Berdaftar Disimpan (<span id="visibleParentCount"><%= parentCount %></span>)
                                                </span>
                                                <span style="color: #64748B; font-weight: 700;">Klik untuk auto-isi semua maklumat</span>
                                            </div>

                                            <% if (existingParents.isEmpty()) { %>
                                                <div style="padding: 12px; text-align: center; font-size: 0.8rem; color: #64748B; font-weight: 700;">
                                                    Tiada rekod penjaga sedia ada. Teruskan mengisi borang untuk penjaga baharu.
                                                </div>
                                            <% } else { 
                                                for (Parent p : existingParents) {
                                                    String pName = p.getParentName() != null ? p.getParentName() : "";
                                                    String pEmail = p.getParentEmail() != null ? p.getParentEmail() : "";
                                                    String pPhone = p.getParentPhoneNumber() != null ? p.getParentPhoneNumber() : "";
                                                    String pIc = p.getParentIC() != null ? p.getParentIC() : "";
                                                    String pGender = p.getParentGender() != null ? p.getParentGender() : "Female";
                                                    String pAddress = p.getParentAddress() != null ? p.getParentAddress() : "";
                                                    String childrenNames = (parentChildrenMap != null && parentChildrenMap.containsKey(p.getParentID()))
                                                                         ? parentChildrenMap.get(p.getParentID()) : "Tiada anak berdaftar lagi";
                                                    String initial = !pName.isEmpty() ? pName.substring(0, 1).toUpperCase() : "P";
                                            %>
                                                <div class="parent-item" 
                                                     data-id="<%= p.getParentID() %>"
                                                     data-name="<%= pName.replace("\"", "&quot;") %>"
                                                     data-email="<%= pEmail.replace("\"", "&quot;") %>"
                                                     data-phone="<%= pPhone.replace("\"", "&quot;") %>"
                                                     data-ic="<%= pIc.replace("\"", "&quot;") %>"
                                                     data-gender="<%= pGender.replace("\"", "&quot;") %>"
                                                     data-address="<%= pAddress.replace("\"", "&quot;") %>"
                                                     data-children="<%= childrenNames.replace("\"", "&quot;") %>"
                                                     onclick="selectExistingParent(this)">
                                                    <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
                                                        <div class="parent-avatar"><%= initial %></div>
                                                        <div style="min-width: 0;">
                                                            <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
                                                                <span style="font-weight: 900; font-size: 0.9rem; color: #2D3436;"><%= pName %></span>
                                                                <span class="badge-registered">BERDAFTAR</span>
                                                            </div>
                                                            <div style="font-size: 0.75rem; color: #64748B; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                                <%= !pEmail.isEmpty() ? pEmail : "Tiada emel" %> · <%= !pPhone.isEmpty() ? pPhone : "-" %>
                                                            </div>
                                                            <div style="font-size: 0.72rem; color: #059669; font-weight: 800; margin-top: 2px;">
                                                                Anak berdaftar: <%= childrenNames %>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <button type="button" class="btn-pick-auto">Pick &amp; Auto-isi</button>
                                                </div>
                                            <%  } 
                                               } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("Mail", "icon-xs") %> Email Address
                                    </label>
                                    <input type="email" name="parentEmail" id="parentEmail" class="neo-input" placeholder="e.g. sarah@example.com">
                                </div>
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("Phone", "icon-xs") %> Phone Number
                                    </label>
                                    <input type="text" name="parentPhone" id="parentPhone" class="neo-input" placeholder="e.g. 0123456789" required>
                                </div>
                            </div>

                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("CreditCard", "icon-xs") %> IC Number (Parent)
                                    </label>
                                    <input type="text" name="parentIc" id="parentIc" class="neo-input" placeholder="e.g. 890412-10-5234">
                                </div>
                                <div>
                                    <label class="neo-label">Gender</label>
                                    <select name="parentGender" id="parentGender" class="neo-input" style="cursor: pointer;">
                                        <option value="Female">Female</option>
                                        <option value="Male">Male</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-row">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("MapPin", "icon-xs") %> Address
                                    </label>
                                    <input type="text" name="parentAddress" id="parentAddress" class="neo-input" placeholder="e.g. No. 12, Jalan Flora, Presint 3">
                                </div>
                            </div>

                            <!-- Sepanduk Info Adik-Beradik (Muncul apabila penjaga sedia ada dipilih) -->
                            <div id="siblingBanner" class="sibling-banner">
                                <%= IconUtil.icon("UserCheck", "icon-sm") %>
                                <span id="siblingBannerText">Pendaftaran adik-beradik untuk keluarga</span>
                            </div>
                            
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 26px; border-top: 2px solid #E2E8F0; padding-top: 20px; flex-wrap: wrap; gap: 12px;">
                                <span id="step1FooterNote" style="font-size: 0.78rem; color: #64748B; font-weight: 700;">
                                    Sila lengkapkan maklumat penjaga sebelum ke langkah seterusnya.
                                </span>
                                <button type="button" class="btn-neo btn-yellow" onclick="goToStep2()">
                                    <span id="nextStepBtnText">Next</span>
                                    <%= IconUtil.icon("ArrowRight", "icon-sm") %>
                                </button>
                            </div>
                        </div>

                        <!-- ================= CARD 2: STUDENT ================= -->
                        <div id="card-step2" class="form-card" style="display: none;">
                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">
                                <h2 style="margin: 0; font-weight: 900; display: flex; align-items: center; gap: 8px;">
                                    <%= IconUtil.icon("Smile", "icon-md") %>
                                    <span>Student's Information</span>
                                </h2>
                                <span style="font-size: 0.75rem; font-weight: 800; color: #64748B;">Step 2 of 2</span>
                            </div>
                            
                            <div class="form-row">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("User", "icon-xs") %> Full Name
                                    </label>
                                    <input type="text" name="studentName" id="studentName" class="neo-input" placeholder="e.g. Adam Rayyan" required>
                                </div>
                            </div>
                            
                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("CreditCard", "icon-xs") %> IC Number
                                    </label>
                                    <input type="text" name="studentIc" id="studentIc" class="neo-input" placeholder="e.g. 190520-10-6181">
                                </div>
                                <div>
                                    <label class="neo-label">Gender</label>
                                    <select name="studentGender" id="studentGender" class="neo-input" style="cursor: pointer;">
                                        <option value="Boy">Boy</option>
                                        <option value="Girl">Girl</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-row two-cols">
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("Calendar", "icon-xs") %> Age
                                    </label>
                                    <input type="number" name="studentAge" id="studentAge" class="neo-input" placeholder="e.g. 5" required>
                                </div>
                                <div>
                                    <label class="neo-label">
                                        <%= IconUtil.icon("GraduationCap", "icon-xs") %> Class
                                    </label>
                                    <select name="studentClass" id="studentClass" class="neo-input" style="cursor: pointer;">
                                        <option value="Kindergarten 3B">Kindergarten 3B</option>
                                        <option value="Kindergarten 2A">Kindergarten 2A</option>
                                        <option value="Kindergarten 1">Kindergarten 1</option>
                                        <option value="Preschool 4A">Preschool 4A</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Kotak Linked Parent (Muncul di Langkah 2 jika memilih penjaga sedia ada) -->
                            <div id="linkedParentBox" class="linked-parent-box">
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div style="width: 38px; height: 38px; border-radius: 50%; background: #A7F3D0; border: 2px solid #2D3436; display: flex; align-items: center; justify-content: center; color: #065F46;">
                                        <%= IconUtil.icon("UserCheck", "icon-sm") %>
                                    </div>
                                    <div>
                                        <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
                                            <span style="font-size: 10px; font-weight: 900; color: #047857; text-transform: uppercase;">LINKED PARENT</span>
                                            <span style="background: #D1FAE5; border: 1px solid #10B981; color: #065F46; font-size: 9px; font-weight: 900; padding: 2px 8px; border-radius: 999px;">
                                                DIHUBUNGKAN • PENJAGA SEDIA ADA DALAM REKOD
                                            </span>
                                        </div>
                                        <div id="linkedParentDetails" style="font-size: 0.85rem; font-weight: 900; color: #2D3436; margin-top: 2px;"></div>
                                        <div id="linkedParentSiblings" style="font-size: 0.75rem; font-weight: 700; color: #059669; margin-top: 2px;"></div>
                                    </div>
                                </div>
                                <button type="button" onclick="goToStep1()" style="background: none; border: none; color: #4F46E5; font-weight: 900; font-size: 0.8rem; cursor: pointer; text-decoration: underline;">
                                    Edit / Change Parent
                                </button>
                            </div>
                            
                            <div style="display: flex; justify-content: space-between; margin-top: 26px; border-top: 2px solid #E2E8F0; padding-top: 20px; flex-wrap: wrap; gap: 10px;">
                                <button type="button" class="btn-neo" onclick="goToStep1()">
                                    <%= IconUtil.icon("ArrowLeft", "icon-sm") %>
                                    <span>Back</span>
                                </button>
                                <div style="display: flex; gap: 10px;">
                                    <button type="button" class="btn-neo" onclick="resetStudentForm()">
                                        <%= IconUtil.icon("RotateCcw", "icon-sm") %>
                                        <span>Reset</span>
                                    </button>
                                    <button type="submit" class="btn-neo btn-mint">
                                        <%= IconUtil.icon("CheckCircle", "icon-sm") %>
                                        <span>Confirm</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                    </form>
                </div>
            </div>
        </main>
    </div>

    <!-- SCRIPT KAWALAN AUTOCOMPLETE & LANGKAH PENDAFTARAN -->
    <script>
        function filterParentDropdown() {
            const dropdown = document.getElementById('parentDropdown');
            if (document.getElementById('existingParentId').value !== '') {
                dropdown.classList.remove('open');
                return;
            }

            const query = document.getElementById('parentName').value.toLowerCase().trim();

            // Jangan buka dropdown jika kotak input masih kosong
            if (query === '') {
                dropdown.classList.remove('open');
                return;
            }

            const items = document.querySelectorAll('.parent-item');
            let visible = 0;

            items.forEach(item => {
                const name = (item.dataset.name || '').toLowerCase();

                // Paparkan hanya jika huruf yang ditaip sepadan dengan nama penjaga
                if (name.includes(query)) {
                    item.style.display = 'flex';
                    visible++;
                } else {
                    item.style.display = 'none';
                }
            });

            document.getElementById('visibleParentCount').innerText = visible;

            // Buka dropdown hanya jika ada nama yang sepadan; tutup jika tiada padanan
            if (visible > 0) {
                dropdown.classList.add('open');
            } else {
                dropdown.classList.remove('open');
            }
        }

        function selectExistingParent(el) {
            const id = el.dataset.id;
            const name = el.dataset.name;
            const email = el.dataset.email;
            const phone = el.dataset.phone;
            const ic = el.dataset.ic;
            const gender = el.dataset.gender || 'Female';
            const address = el.dataset.address;
            const children = el.dataset.children;

            // Set nilai dan kunci medan penjaga
            document.getElementById('existingParentId').value = id;
            document.getElementById('selectedParentChildren').value = children;

            const nameInput = document.getElementById('parentName');
            const emailInput = document.getElementById('parentEmail');
            const phoneInput = document.getElementById('parentPhone');
            const icInput = document.getElementById('parentIc');
            const genderSelect = document.getElementById('parentGender');
            const addressInput = document.getElementById('parentAddress');

            nameInput.value = name;
            emailInput.value = email;
            phoneInput.value = phone;
            icInput.value = ic;
            genderSelect.value = gender;
            addressInput.value = address;

            nameInput.readOnly = true;
            emailInput.readOnly = true;
            phoneInput.readOnly = true;
            icInput.readOnly = true;
            addressInput.readOnly = true;
            genderSelect.classList.add('locked-field');
            genderSelect.style.pointerEvents = 'none';

            // Kemas kini UI indikator & sepanduk
            document.getElementById('parentDropdown').classList.remove('open');
            document.getElementById('clearParentBtn').style.display = 'flex';
            document.getElementById('selectedBadge').style.display = 'inline-flex';
            document.getElementById('resetParentLink').style.display = 'inline-block';
            document.getElementById('dropdownHintText').style.display = 'none';

            document.getElementById('step1-sub').innerText = 'Dipilih: ' + name;
            document.getElementById('parentCardHelper').innerText = 'Segala maklumat penjaga sedia ada menjadi mod baca sahaja. Kemaskini hanya boleh dibuat di bahagian Profile.';
            document.getElementById('siblingBanner').style.display = 'flex';
            document.getElementById('siblingBannerText').innerText = 'Pendaftaran adik-beradik untuk keluarga ' + name;
            document.getElementById('step1FooterNote').innerText = 'Maklumat penjaga sudah lengkap daripada rekod sistem.';
            document.getElementById('nextStepBtnText').innerText = 'Skip & Continue';

            // Sediakan kotak ringkasan Linked Parent untuk Step 2
            document.getElementById('linkedParentBox').style.display = 'flex';
            document.getElementById('linkedParentDetails').innerText = name + ' (' + (phone || '-') + ')';
            document.getElementById('linkedParentSiblings').innerText = 'Adik-beradik sedia ada di tadika: ' + children;
        }

        function clearSelectedParent() {
            document.getElementById('existingParentId').value = '';
            document.getElementById('selectedParentChildren').value = '';

            const nameInput = document.getElementById('parentName');
            const emailInput = document.getElementById('parentEmail');
            const phoneInput = document.getElementById('parentPhone');
            const icInput = document.getElementById('parentIc');
            const genderSelect = document.getElementById('parentGender');
            const addressInput = document.getElementById('parentAddress');

            nameInput.value = '';
            emailInput.value = '';
            phoneInput.value = '';
            icInput.value = '';
            genderSelect.selectedIndex = 0;
            addressInput.value = '';

            nameInput.readOnly = false;
            emailInput.readOnly = false;
            phoneInput.readOnly = false;
            icInput.readOnly = false;
            addressInput.readOnly = false;
            genderSelect.classList.remove('locked-field');
            genderSelect.style.pointerEvents = 'auto';

            // Kembalikan UI asal
            document.getElementById('clearParentBtn').style.display = 'none';
            document.getElementById('selectedBadge').style.display = 'none';
            document.getElementById('resetParentLink').style.display = 'none';
            document.getElementById('dropdownHintText').style.display = 'inline';
            document.getElementById('siblingBanner').style.display = 'none';
            document.getElementById('linkedParentBox').style.display = 'none';
            document.getElementById('parentDropdown').classList.remove('open');

            document.getElementById('step1-sub').innerText = 'Langkah 1: Maklumat Penjaga';
            document.getElementById('parentCardHelper').innerText = 'Taip nama penuh penjaga — jika penjaga sudah berdaftar, pilih daripada senarai dropdown untuk auto-isi & terus skip.';
            document.getElementById('step1FooterNote').innerText = 'Sila lengkapkan maklumat penjaga sebelum ke langkah seterusnya.';
            document.getElementById('nextStepBtnText').innerText = 'Next';

            nameInput.focus();
        }

        // Tutup dropdown apabila klik di luar kotak carian penjaga
        document.addEventListener('click', function(e) {
            if (!e.target.closest('#parentSearchWrapper')) {
                const dropdown = document.getElementById('parentDropdown');
                if (dropdown) dropdown.classList.remove('open');
            }
        });

        function goToStep2() {
            const pName = document.getElementById('parentName').value.trim();
            const pPhone = document.getElementById('parentPhone').value.trim();
            const errorBox = document.getElementById('error-msg');
            const errorText = document.getElementById('error-text');

            if (pName === '' || pPhone === '') {
                errorBox.style.display = 'flex';
                errorText.innerText = 'Sila masukkan sekurang-kurangnya Nama Penuh dan Nombor Telefon Penjaga.';
                return;
            }

            errorBox.style.display = 'none';
            document.getElementById('card-step1').style.display = 'none';
            document.getElementById('card-step2').style.display = 'block';
            
            document.getElementById('ind-step1').classList.remove('active');
            document.getElementById('ind-step2').classList.add('active');
        }

        function goToStep1() {
            document.getElementById('error-msg').style.display = 'none';
            document.getElementById('card-step2').style.display = 'none';
            document.getElementById('card-step1').style.display = 'block';
            
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

    <jsp:include page="icons.jsp" />
</body>
</html>