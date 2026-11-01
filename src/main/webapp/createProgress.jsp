<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="java.util.List"%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Borang Pentaksiran Komprehensif - Keedflix Centre</title>
    
    <style>
        /* NEOBRUTALISM THEME STYLING */
        * { box-sizing: border-box; }
        body, html {
            margin: 0; padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: #FAF5EF; color: #2D3436;
        }

        .app-layout { display: flex; min-height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; background: #FAF5EF; }
        .app-header-wrapper { flex-shrink: 0; background: #FFFFFF; border-bottom: 3px solid #2D3436; }
        .app-content-body { flex-grow: 1; padding: 24px 32px; overflow-y: auto; }

        .nb-container { max-width: 1100px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .nb-card {
            background-color: #FFFFFF; border: 3px solid #2D3436;
            border-radius: 24px; padding: 24px; box-shadow: 4px 4px 0px 0px #2D3436;
        }

        .nb-select, .nb-input {
            width: 100%; padding: 10px 16px; border: 2px solid #2D3436;
            border-radius: 14px; background-color: #FFFFFF; font-weight: 700;
            font-size: 0.9rem; color: #2D3436; box-shadow: 2px 2px 0px 0px #2D3436;
            outline: none;
        }

        .nb-btn {
            background-color: #FFFFFF; border: 2px solid #2D3436; border-radius: 999px;
            padding: 10px 22px; font-weight: 900; font-size: 0.85rem; color: #2D3436;
            cursor: pointer; box-shadow: 3px 3px 0px 0px #2D3436; transition: all 0.15s ease;
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
        }
        .nb-btn:hover { transform: translateY(-2px); background-color: #F8FAFC; }
        .nb-btn-yellow { background-color: #FFD02C; }
        .nb-btn-coral { background-color: #FF6B6B; color: white; }
        .nb-btn-mint { background-color: #34D399; }

        /* SCALE BUTTONS */
        .scale-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-top: 10px; }
        .scale-btn {
            border: 2px solid #2D3436; border-radius: 16px; padding: 12px;
            text-align: center; background: #FFFFFF; cursor: pointer;
            box-shadow: 2px 2px 0px 0px #2D3436; font-weight: 900; transition: all 0.15s;
        }
        .scale-btn.selected { background-color: #FFD02C; transform: translateY(-2px); box-shadow: 3px 3px 0px 0px #2D3436; }

        /* RUBRIC CHECKLIST ITEM */
        .rubric-item {
            border: 2px solid #2D3436; border-radius: 12px; padding: 10px 14px;
            margin-bottom: 8px; background: #FFFFFF; display: flex; align-items: center; justify-content: space-between;
            cursor: pointer; font-weight: 700; font-size: 0.85rem;
        }
        .rubric-item.checked { background-color: #FEF3C7; border-color: #D97706; }

        .domain-badge {
            display: inline-block; padding: 4px 12px; border-radius: 999px;
            border: 1.5px solid #2D3436; font-size: 0.75rem; font-weight: 900; text-transform: uppercase;
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
            <form action="${pageContext.request.contextPath}/createProgress" method="POST" id="progressForm">
                <input type="hidden" name="editProgressID" value="${editingRecord != null ? editingRecord.progressID : 0}">
                <input type="hidden" name="activeDomainFilter" id="activeDomainFilter" value="All">

                <div class="nb-container">

                    <!-- 1. HEADER BAR -->
                    <div class="nb-card" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px;">
                        <div>
                            <span class="domain-badge" style="background:#E0E7FF; color:#3730A3;">PENTAKSIRAN BERSEPADU KSPK</span>
                            <h2 style="margin:8px 0 0 0; font-weight:900;">
                                ${editingRecord != null ? 'Kemaskini Rekod Pentaksiran' : 'Borang Pentaksiran Komprehensif (Reading, Writing & Counting)'}
                            </h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/learningProgress" class="nb-btn">← Kembali</a>
                    </div>

                    <!-- 2. STUDENT & DATE CONTEXT -->
                    <div class="nb-card">
                        <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:16px;">
                            <div>
                                <label style="font-weight:900; display:block; margin-bottom:6px;">Sasaran Murid Dinilai</label>
                                <select name="studentID" id="studentID" class="nb-select" onchange="updateStudentInfo(this)">
                                    <c:forEach var="st" items="${students}">
                                        <option value="${st.studentID}" data-age="${st.studentAge}" ${st.studentID == targetStudentId ? 'selected' : ''}>
                                            ${st.studentName} (${st.studentAge} Tahun) — ${st.studentClass}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label style="font-weight:900; display:block; margin-bottom:6px;">Tarikh Pentaksiran</label>
                                <input type="date" name="progressDate" class="nb-input" value="${editingRecord != null ? editingRecord.progressDate : '2026-10-31'}" required>
                            </div>
                            <div>
                                <label style="font-weight:900; display:block; margin-bottom:6px;">Guru Penilai</label>
                                <input type="text" name="assessorName" class="nb-input" value="${editingRecord != null ? editingRecord.assessorName : 'Cikgu Farah (Lead Educator)'}">
                            </div>
                        </div>
                    </div>

                    <!-- 3. DOMAIN CONTAINER: READING -->
                    <div class="nb-card" id="cardReading">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                            <span class="domain-badge" style="background:#FEF3C7; color:#92400E;">TERAS 1: READING</span>
                            <span style="font-size:0.8rem; font-weight:800;">Skala Penilaian Perkembangan (1 - 5)</span>
                        </div>

                        <label style="font-weight:900; display:block; margin-bottom:4px;">Tajuk / Topik Pentaksiran Reading</label>
                        <input type="text" name="reading_progressName" class="nb-input" style="margin-bottom:14px;" value="${editingRecord != null ? editingRecord.progressName : 'Penguasaan Fonik & Pengecaman Bunyi Huruf (Phonics)'}">

                        <!-- Scale Selector -->
                        <input type="hidden" name="reading_ratingScale" id="reading_scale" value="${editingRecord != null ? editingRecord.ratingScale : 4}">
                        <div class="scale-grid">
                            <div class="scale-btn" onclick="selectScale('reading', 1, this)">1<br><small>Bermula</small></div>
                            <div class="scale-btn" onclick="selectScale('reading', 2, this)">2<br><small>Asas</small></div>
                            <div class="scale-btn" onclick="selectScale('reading', 3, this)">3<br><small>Membangun</small></div>
                            <div class="scale-btn selected" onclick="selectScale('reading', 4, this)">4<br><small>Mahir</small></div>
                            <div class="scale-btn" onclick="selectScale('reading', 5, this)">5<br><small>Cemerlang</small></div>
                        </div>
                    </div>

                    <!-- 4. DOMAIN CONTAINER: WRITING -->
                    <div class="nb-card" id="cardWriting">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                            <span class="domain-badge" style="background:#FFE4E6; color:#BE185D;">TERAS 2: WRITING</span>
                            <span style="font-size:0.8rem; font-weight:800;">Skala Penilaian Perkembangan (1 - 5)</span>
                        </div>

                        <label style="font-weight:900; display:block; margin-bottom:4px;">Tajuk / Topik Pentaksiran Writing</label>
                        <input type="text" name="writing_progressName" class="nb-input" style="margin-bottom:14px;" value="Kawalan Motor Halus & Genggaman Pensel (Tripod Grip)">

                        <input type="hidden" name="writing_ratingScale" id="writing_scale" value="3">
                        <div class="scale-grid">
                            <div class="scale-btn" onclick="selectScale('writing', 1, this)">1<br><small>Bermula</small></div>
                            <div class="scale-btn" onclick="selectScale('writing', 2, this)">2<br><small>Asas</small></div>
                            <div class="scale-btn selected" onclick="selectScale('writing', 3, this)">3<br><small>Membangun</small></div>
                            <div class="scale-btn" onclick="selectScale('writing', 4, this)">4<br><small>Mahir</small></div>
                            <div class="scale-btn" onclick="selectScale('writing', 5, this)">5<br><small>Cemerlang</small></div>
                        </div>
                    </div>

                    <!-- 5. DOMAIN CONTAINER: COUNTING -->
                    <div class="nb-card" id="cardCounting">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                            <span class="domain-badge" style="background:#D1FAE5; color:#065F46;">TERAS 3: COUNTING</span>
                            <span style="font-size:0.8rem; font-weight:800;">Skala Penilaian Perkembangan (1 - 5)</span>
                        </div>

                        <label style="font-weight:900; display:block; margin-bottom:4px;">Tajuk / Topik Pentaksiran Counting</label>
                        <input type="text" name="counting_progressName" class="nb-input" style="margin-bottom:14px;" value="Pengecaman Nombor & Pembilangan Objek (1-30)">

                        <input type="hidden" name="counting_ratingScale" id="counting_scale" value="4">
                        <div class="scale-grid">
                            <div class="scale-btn" onclick="selectScale('counting', 1, this)">1<br><small>Bermula</small></div>
                            <div class="scale-btn" onclick="selectScale('counting', 2, this)">2<br><small>Asas</small></div>
                            <div class="scale-btn" onclick="selectScale('counting', 3, this)">3<br><small>Membangun</small></div>
                            <div class="scale-btn selected" onclick="selectScale('counting', 4, this)">4<br><small>Mahir</small></div>
                            <div class="scale-btn" onclick="selectScale('counting', 5, this)">5<br><small>Cemerlang</small></div>
                        </div>
                    </div>

                    <!-- 6. HOME RECOMMENDATION -->
                    <div class="nb-card">
                        <label style="font-weight:900; display:block; margin-bottom:6px;">Cadangan Perkongsian Aktiviti di Rumah (Untuk Ibu Bapa)</label>
                        <textarea name="homeRecommendation" class="nb-input" rows="3" placeholder="Contoh: Ibu bapa digalakkan meluangkan masa 10 minit membaca buku cerita bergambar bersama anak...">${editingRecord != null ? editingRecord.homeRecommendation : ''}</textarea>
                    </div>

                    <!-- SUBMIT BAR -->
                    <div style="display:flex; justify-content:flex-end; gap:12px;">
                        <a href="${pageContext.request.contextPath}/learningProgress" class="nb-btn">Batal</a>
                        <button type="submit" class="nb-btn nb-btn-yellow">💾 Simpan Rekod Pentaksiran</button>
                    </div>

                </div>
            </form>
        </div>
    </main>
</div>

<script>
    function selectScale(domain, val, btn) {
        document.getElementById(domain + '_scale').value = val;
        let parent = btn.parentElement;
        parent.querySelectorAll('.scale-btn').forEach(b => b.classList.remove('selected'));
        btn.classList.add('selected');
    }
</script>

</body>
</html>