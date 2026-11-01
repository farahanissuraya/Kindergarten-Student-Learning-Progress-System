<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Progress Manager - Keedflix Centre</title>
    
    <style>
        /* NEOBRUTALISM THEME STYLING */
        * { box-sizing: border-box; }
        body, html {
            margin: 0; padding: 0; height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF; color: #2D3436;
        }

        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; background: #FAF5EF; }
        .app-header-wrapper { flex-shrink: 0; background: #FFFFFF; border-bottom: 3px solid #2D3436; }
        .app-content-body { flex-grow: 1; padding: 24px 32px; overflow-y: auto; }

        .nb-container { max-width: 1100px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .nb-card {
            background-color: #FFFFFF; border: 3px solid #2D3436;
            border-radius: 24px; padding: 24px; box-shadow: 4px 4px 0px 0px #2D3436;
        }

        .nb-select {
            width: 100%; padding: 12px 20px; border: 2px solid #2D3436;
            border-radius: 999px; background-color: #FFFFFF; font-weight: 800;
            font-size: 0.95rem; color: #2D3436; box-shadow: 2px 2px 0px 0px #2D3436;
            cursor: pointer; outline: none;
        }

        .nb-btn {
            background-color: #FFD02C; border: 2px solid #2D3436; border-radius: 999px;
            padding: 10px 24px; font-weight: 900; font-size: 0.88rem; color: #2D3436;
            cursor: pointer; box-shadow: 3px 3px 0px 0px #2D3436; transition: all 0.15s ease;
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
        }
        .nb-btn:hover { transform: translateY(-2px); background-color: #FFE066; }
        .nb-btn-mint { background-color: #34D399; }
        .nb-btn-mint:hover { background-color: #6EE7B7; }
        .nb-btn-danger { background-color: #F87171; color: white; }

        .nb-filter-btn {
            background: #FFFFFF; border: 2px solid #2D3436; border-radius: 999px;
            padding: 6px 16px; font-weight: 800; font-size: 0.8rem; cursor: pointer;
            box-shadow: 2px 2px 0px 0px #2D3436; transition: all 0.15s ease;
        }
        .nb-filter-btn.active { background: #2D3436; color: #FFFFFF; }

        /* TABLE STYLING */
        .nb-table {
            width: 100%; border-collapse: collapse; border: 2px solid #2D3436;
            border-radius: 16px; overflow: hidden; box-shadow: 3px 3px 0px 0px #2D3436;
        }
        .nb-table th { background-color: #2D3436; color: #FFFFFF; padding: 14px; text-align: left; font-weight: 900; font-size: 0.85rem; }
        .nb-table td { padding: 14px; border-bottom: 1.5px solid #E2E8F0; background-color: #FFFFFF; font-size: 0.88rem; }

        /* MODAL STYLING */
        .nb-modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.6); display: none; align-items: center; justify-content: center; z-index: 999;
        }
        .nb-modal-overlay.active { display: flex; }
        .nb-modal {
            background: #FFFFFF; border: 3px solid #2D3436; border-radius: 24px;
            padding: 28px; width: 100%; max-width: 500px; box-shadow: 6px 6px 0px 0px #2D3436;
        }
        .nb-input {
            width: 100%; padding: 10px 14px; border: 2px solid #2D3436;
            border-radius: 12px; margin-top: 4px; margin-bottom: 14px; box-sizing: border-box; font-weight: 600;
        }
    </style>
</head>
<body>

<div class="app-layout">
    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <main class="app-main-wrapper">
        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <div class="app-content-body">
            <div class="nb-container">

                <!-- 1. SELECTOR KELAS & MURID -->
                <div class="nb-card">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div>
                            <label style="font-weight: 900; display: block; margin-bottom: 6px;">Classroom</label>
                            <select class="nb-select" disabled>
                                <option>${student.studentClass != null ? student.studentClass : 'Kindergarten 3B'}</option>
                            </select>
                        </div>
                        <div>
                            <label style="font-weight: 900; display: block; margin-bottom: 6px;">Student Name</label>
                            <select class="nb-select" onchange="location.href='${pageContext.request.contextPath}/learningProgress?studentId=' + this.value">
                                <c:forEach var="s" items="${classStudents}">
                                    <option value="${s.studentID}" ${s.studentID == student.studentID ? 'selected' : ''}>${s.studentName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- 2. TEACHER ASSESSMENT CONSOLE HEADER -->
                <div class="nb-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                    <div>
                        <span style="background: #FFD02C; border: 1.5px solid #2D3436; padding: 2px 10px; border-radius: 999px; font-size: 10px; font-weight: 900;">
                            TEACHER ASSESSMENT CONSOLE
                        </span>
                        <h2 style="margin: 8px 0 0 0; font-size: 1.6rem; font-weight: 900;">
                            Learning Progress: ${student.studentName}
                        </h2>
                        <p style="margin: 4px 0 0 0; color: #636E72; font-size: 0.85rem; font-weight: 600;">
                            Evaluate reading, writing, and early counting milestones in real time.
                        </p>
                    </div>
                    <button class="nb-btn nb-btn-mint" onclick="openCreateModal()">
                        + Rekod Kemajuan Murid
                    </button>
                </div>

                <!-- 3. EVALUATED PROGRESS LEDGER -->
                <div class="nb-card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="margin: 0; font-weight: 900;">Evaluated Progress Ledger</h3>
                        <div style="display: flex; gap: 6px;">
                            <button class="nb-filter-btn active" onclick="filterCategory('All', this)">All</button>
                            <button class="nb-filter-btn" onclick="filterCategory('Reading', this)">Reading</button>
                            <button class="nb-filter-btn" onclick="filterCategory('Writing', this)">Writing</button>
                            <button class="nb-filter-btn" onclick="filterCategory('Counting', this)">Counting</button>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty progressList}">
                            <p style="text-align: center; color: #636E72; font-weight: 700; padding: 20px 0;">
                                Tiada rekod kemajuan ditemui. Sila tambah rekod baharu.
                            </p>
                        </c:when>
                        <c:otherwise>
                            <div style="display: flex; flex-direction: column; gap: 12px;" id="ledgerList">
                                <c:forEach var="p" items="${progressList}">
                                    <div class="progress-row-item" data-domain="${p.domainName}" style="border: 2px solid #2D3436; border-radius: 16px; padding: 16px; display: flex; justify-content: space-between; align-items: center; background: #FFFFFF; box-shadow: 2px 2px 0px 0px #2D3436;">
                                        <div>
                                            <span style="background: ${p.domainName == 'Reading' ? '#E0E7FF' : (p.domainName == 'Writing' ? '#FFE4E6' : '#FEF3C7')}; color: ${p.domainName == 'Reading' ? '#3730A3' : (p.domainName == 'Writing' ? '#BE185D' : '#92400E')}; border: 1px solid #2D3436; font-size: 10px; font-weight: 900; padding: 2px 8px; border-radius: 6px;">
                                                ${p.domainName != null ? p.domainName : 'General'}
                                            </span>
                                            <h4 style="margin: 6px 0 2px 0; font-weight: 900;">${p.progressName}</h4>
                                            <p style="margin: 0 0 4px 0; font-size: 0.8rem; color: #4B5563;">Status: <strong>${p.progressStatus}</strong> (Skala: ${p.ratingScale}/5)</p>
                                            <c:if test="${not empty p.notes}">
                                                <p style="margin: 0 0 4px 0; font-size: 0.78rem; color: #636E72; italic">"${p.notes}"</p>
                                            </c:if>
                                            <span style="font-size: 0.75rem; color: #636E72; font-weight: 600;">📅 Tarikh: ${p.progressDate}</span>
                                        </div>
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <span style="font-weight: 900; font-size: 1.2rem; color: #2D3436;">${p.progressPercentage}%</span>
                                            <button class="nb-btn" style="padding: 6px 14px; font-size: 0.78rem;" 
                                                    onclick="openEditModal(${p.progressID}, '${p.domainName}', '<c:out value="${p.progressName}"/>', ${p.progressPercentage}, '${p.progressStatus}', '${p.progressDate}', '${p.notes}', ${p.ratingScale}, '<c:out value="${p.homeRecommendation}"/>')">
                                                Edit
                                            </button>
                                            <form action="${pageContext.request.contextPath}/learningProgress" method="POST" style="margin:0;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="progressID" value="${p.progressID}">
                                                <input type="hidden" name="studentID" value="${student.studentID}">
                                                <button type="submit" class="nb-btn nb-btn-danger" style="padding: 6px 14px; font-size: 0.78rem;" onclick="return confirm('Padam rekod ini?')">
                                                    Padam
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- MODAL TAMBAH / EDIT REKOD -->
<div class="nb-modal-overlay" id="progressModal">
    <div class="nb-modal">
        <h3 id="modalTitle" style="margin-top:0; font-weight:900;">Rekod Kemajuan Murid</h3>
        <form action="${pageContext.request.contextPath}/learningProgress" method="POST">
            <input type="hidden" name="action" id="formAction" value="create">
            <input type="hidden" name="progressID" id="formProgressID" value="0">
            <input type="hidden" name="studentID" value="${student.studentID}">

            <label style="font-weight:800; font-size:0.85rem;">Domain</label>
            <select name="domainName" id="formDomain" class="nb-input">
                <option value="Reading">Reading</option>
                <option value="Writing">Writing</option>
                <option value="Counting">Counting</option>
            </select>

            <label style="font-weight:800; font-size:0.85rem;">Nama Aktiviti / Topik</label>
            <input type="text" name="progressName" id="formName" class="nb-input" required placeholder="Cth: CVC Phonics & Beginning Sounds">

            <label style="font-weight:800; font-size:0.85rem;">Peratus Kemajuan (%)</label>
            <input type="number" step="0.1" name="progressPercentage" id="formPercentage" class="nb-input" min="0" max="100" value="80" required>

            <label style="font-weight:800; font-size:0.85rem;">Status Kemajuan</label>
            <select name="progressStatus" id="formStatus" class="nb-input">
                <option value="Mastered">Mastered</option>
                <option value="Proficient">Proficient</option>
                <option value="Developing">Developing</option>
                <option value="Emerging">Emerging</option>
            </select>

            <label style="font-weight:800; font-size:0.85rem;">Skala Penilaian (1-5)</label>
            <input type="number" name="ratingScale" id="formRatingScale" class="nb-input" min="1" max="5" value="5">

            <label style="font-weight:800; font-size:0.85rem;">Tarikh Penilaian</label>
            <input type="date" name="progressDate" id="formDate" class="nb-input">

            <label style="font-weight:800; font-size:0.85rem;">Nota Guru</label>
            <textarea name="notes" id="formNotes" class="nb-input" rows="2"></textarea>

            <label style="font-weight:800; font-size:0.85rem;">Cadangan Aktiviti di Rumah</label>
            <input type="text" name="homeRecommendation" id="formHomeRec" class="nb-input" placeholder="Cth: Baca cerita berima 10 minit bersama">

            <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:12px;">
                <button type="button" class="nb-btn" style="background:#E2E8F0;" onclick="closeModal()">Batal</button>
                <button type="submit" class="nb-btn nb-btn-mint">Simpan</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openCreateModal() {
        document.getElementById('modalTitle').innerText = 'Tambah Rekod Kemajuan';
        document.getElementById('formAction').value = 'create';
        document.getElementById('formProgressID').value = '0';
        document.getElementById('formName').value = '';
        document.getElementById('formPercentage').value = '80';
        document.getElementById('formNotes').value = '';
        document.getElementById('formRatingScale').value = '5';
        document.getElementById('formHomeRec').value = '';
        
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('formDate').value = today;
        
        document.getElementById('progressModal').classList.add('active');
    }

    function openEditModal(id, domain, name, pct, status, dateStr, notes, scale, homeRec) {
        document.getElementById('modalTitle').innerText = 'Kemas Kini Rekod Kemajuan';
        document.getElementById('formAction').value = 'update';
        document.getElementById('formProgressID').value = id;
        if (domain) document.getElementById('formDomain').value = domain;
        document.getElementById('formName').value = name;
        document.getElementById('formPercentage').value = pct;
        document.getElementById('formStatus').value = status;
        if (dateStr) document.getElementById('formDate').value = dateStr;
        document.getElementById('formNotes').value = notes || '';
        document.getElementById('formRatingScale').value = scale || '5';
        document.getElementById('formHomeRec').value = homeRec || '';
        
        document.getElementById('progressModal').classList.add('active');
    }

    function closeModal() {
        document.getElementById('progressModal').classList.remove('active');
    }

    function filterCategory(cat, btn) {
        document.querySelectorAll('.nb-filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        document.querySelectorAll('.progress-row-item').forEach(item => {
            if (cat === 'All' || item.getAttribute('data-domain') === cat) {
                item.style.display = 'flex';
            } else {
                item.style.display = 'none';
            }
        });
    }
</script>

</body>
</html>