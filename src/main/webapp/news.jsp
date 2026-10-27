<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="bean.News"%>
<%
    List<News> newsList = (List<News>) request.getAttribute("newsList");
    
    // Semak peranan pengguna dari sesi ('Admin', 'Teacher', 'Parent')
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null) userRole = "Teacher"; // Tetapan lalai untuk pengujian

    boolean canCreateUpdate = userRole.equals("Admin") || userRole.equals("Teacher");
    boolean canDelete = userRole.equals("Admin"); // Teacher tidak boleh delete
    
    String selectedCategory = request.getParameter("category");
    if (selectedCategory == null) selectedCategory = "All";
    
    String viewMode = request.getParameter("mode"); // Mode 'create' atau 'edit'
    boolean isEditorMode = "create".equals(viewMode) || "edit".equals(viewMode);
    
    News editNews = null;
    if ("edit".equals(viewMode) && request.getParameter("id") != null) {
        try {
            int editId = Integer.parseInt(request.getParameter("id"));
            if (newsList != null) {
                for (News n : newsList) {
                    if (n.getNewsID() == editId) {
                        editNews = n;
                        break;
                    }
                }
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Keedflix Centre - Weekly News & Bulletins</title>
    <style>
        /* --- NEOBRUTALISM THEMED STYLING --- */
        * { box-sizing: border-box; }
        html, body { height: 100%; margin: 0; background-color: #FAF5EF; color: #2D3436; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; overflow: hidden; }
        
        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background-color: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; min-width: 0; height: 100vh; overflow: hidden; }
        .app-header-wrapper { flex-shrink: 0; background-color: #FFFFFF; border-bottom: 3px solid #2D3436 !important; }
        .app-content-body { padding: 32px; flex-grow: 1; overflow-y: auto; background-color: #FAF5EF; display: flex; justify-content: center; }
        
        .container { width: 100%; max-width: 1100px; display: flex; flex-direction: column; gap: 24px; padding-bottom: 60px; }
        
        .neo-card { background: #FFF; border: 3px solid #2D3436; border-radius: 24px; padding: 28px; box-shadow: 5px 5px 0px 0px #2D3436; }
        
        /* Buttons */
        .btn-neo { padding: 10px 20px; border: 2.5px solid #2D3436; border-radius: 14px; font-weight: 900; cursor: pointer; box-shadow: 3px 3px 0px #2D3436; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: #2D3436; background: #FFF; transition: transform 0.1s; font-size: 0.85rem; }
        .btn-neo:active { transform: translate(2px, 2px); box-shadow: 1px 1px 0px #2D3436; }
        .btn-mint { background-color: #7BE495; }
        .btn-yellow { background-color: #FFD02C; }
        .btn-rose { background-color: #FFE3E3; color: #D10000; border-color: #D10000; }

        /* Filter Pills */
        .filter-pill { padding: 8px 18px; border-radius: 999px; border: 2.5px solid #2D3436; font-size: 0.85rem; font-weight: 800; background: #FFF; cursor: pointer; text-decoration: none; color: #2D3436; box-shadow: 2px 2px 0px 0px #2D3436; }
        .filter-pill.active { background: #2D3436; color: #FFF; }

        /* Badges */
        .badge { font-size: 10px; font-weight: 900; padding: 4px 10px; border-radius: 999px; border: 2px solid #2D3436; text-transform: uppercase; }
        .badge-academic { background-color: #E9D5FF; color: #6B21A8; border-color: #C084FC; }
        .badge-announcement { background-color: #FEF08A; color: #854D0E; border-color: #FACC15; }
        .badge-event { background-color: #FFE3E3; color: #D10000; border-color: #F87171; }
        .badge-holiday { background-color: #D1F7E8; color: #065F46; border-color: #34D399; }
        .badge-nutrition { background-color: #FFEDD5; color: #C2410C; border-color: #FB923C; }

        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-weight: 900; font-size: 0.85rem; margin-bottom: 8px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 14px; border: 2.5px solid #2D3436; border-radius: 16px; font-weight: 700; font-family: inherit; background: #FAF5EF; outline: none; }
        
        .topic-chip { padding: 6px 12px; border-radius: 12px; border: 2px solid #2D3436; font-size: 11px; font-weight: 800; background: #FEFCE8; cursor: pointer; transition: all 0.1s; }
        .topic-chip:hover { background: #FFD02C; transform: translate(-1px, -1px); box-shadow: 2px 2px 0px 0px #2D3436; }

        .cat-select-card { border: 2.5px solid #2D3436; border-radius: 16px; padding: 16px; text-align: center; cursor: pointer; background: #FFF; transition: all 0.1s; display: flex; flex-direction: column; align-items: center; gap: 8px; }
        .cat-select-card.selected { background: #E9D5FF; border-color: #2D3436; box-shadow: 3px 3px 0px 0px #2D3436; transform: translate(-2px, -2px); font-weight: 900; }

        .audience-card { border: 2.5px solid #2D3436; border-radius: 16px; padding: 16px; cursor: pointer; background: #FFF; transition: all 0.1s; }
        .audience-card.selected { background: #7BE495; box-shadow: 3px 3px 0px 0px #2D3436; transform: translate(-2px, -2px); }
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
                <div class="container">
                    
                    <% if (isEditorMode) { %>
                        <!-- ================= DEDICATED FULL-PAGE EDITOR (MENGIKUT GAYA IMEJ RUJUKAN) ================= -->
                        
                        <!-- 1. Header Bar -->
                        <div class="neo-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; padding: 20px 28px;">
                            <div style="display: flex; align-items: center; gap: 16px; flex-wrap: wrap;">
                                <a href="NewsServlet" class="btn-neo" style="background: #FFF; border-radius: 16px;">
                                    ⬅️ Kembali ke Buletin
                                </a>
                                <div style="height: 24px; width: 2px; background: #CBD5E1;"></div>
                                <div>
                                    <div style="display: flex; gap: 8px; margin-bottom: 4px;">
                                        <span class="badge badge-academic">Keedflix Weekly Bulletin</span>
                                        <span id="previewCatBadge" class="badge badge-academic">Academic Focus</span>
                                    </div>
                                    <h1 style="font-size: 1.5rem; font-weight: 900; margin: 0;"><%= (editNews != null) ? "Kemaskini Buletin Mingguan" : "Cipta Buletin Mingguan Baharu" %></h1>
                                </div>
                            </div>
                            <div style="font-size: 0.85rem; font-weight: 800; color: #64748B;">
                                Penerbit: <span style="color: #2D3436;">Ms. Clara Davis</span> (<%= userRole %>)
                            </div>
                        </div>

                        <!-- 2. Live Preview Card -->
                        <div class="neo-card" style="background: #FFFDF7;">
                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 32px; height: 32px; background: #FFD02C; border: 2px solid #2D3436; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem;">👁️</div>
                                    <div>
                                        <h3 style="font-size: 1rem; font-weight: 900; margin: 0;">Pratonton Kad Buletin (Live Preview)</h3>
                                        <p style="font-size: 0.75rem; color: #64748B; margin: 0;">Paparan sebenar bagaimana kad berita ini akan kelihatan kepada ibu bapa dan guru.</p>
                                    </div>
                                </div>
                                <span class="badge" style="background: #FFF; border-color: #2D3436;">News Card Preview</span>
                            </div>

                            <div style="max-width: 700px; margin: 0 auto; background: #FFF; border: 2.5px solid #2D3436; border-radius: 20px; padding: 24px; box-shadow: 4px 4px 0px 0px #2D3436;">
                                <div style="display: flex; gap: 8px; margin-bottom: 12px; align-items: center;">
                                    <span id="cardPrevCat" class="badge badge-academic">Academic Focus</span>
                                    <span id="cardPrevAud" class="badge" style="background: #F1F5F9; color: #64748B;">Sasaran: Semua (Ibu Bapa & Guru)</span>
                                </div>
                                <h3 id="cardPrevTitle" style="font-size: 1.2rem; font-weight: 900; margin: 0 0 10px 0; color: #2D3436;">Tajuk Buletin Mingguan Akan Dipaparkan Di Sini...</h3>
                                <p id="cardPrevContent" style="font-size: 0.85rem; font-weight: 600; color: #4B5563; line-height: 1.5; margin: 0 0 20px 0; white-space: pre-line;">Kandungan berita mingguan, pengumuman kurikulum, makluman aktiviti pembelajaran, dan pesanan mesra untuk keluarga akan dipaparkan di bahagian ini secara langsung semasa anda menaip...</p>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 2px dashed #CBD5E1; padding-top: 12px; font-size: 0.75rem; font-weight: 800; color: #64748B;">
                                    <span>👤 Ms. Clara Davis (Teacher)</span>
                                    <span>📅 2026-10-27</span>
                                </div>
                            </div>
                        </div>

                        <!-- 3. Form Sections -->
                        <form action="NewsServlet" method="POST">
                            <input type="hidden" name="action" value="<%= (editNews != null) ? "update" : "add" %>">
                            <% if (editNews != null) { %>
                                <input type="hidden" name="newsID" value="<%= editNews.getNewsID() %>">
                            <% } %>

                            <!-- Section 1: Butiran Asas -->
                            <div class="neo-card">
                                <div style="display: flex; align-items: center; gap: 10px; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">
                                    <div style="width: 32px; height: 32px; background: #FFD02C; border: 2px solid #2D3436; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem;">📰</div>
                                    <div>
                                        <h3 style="font-size: 1.1rem; font-weight: 900; margin: 0;">1. Butiran Asas & Tajuk Utama Buletin</h3>
                                        <p style="font-size: 0.75rem; color: #64748B; margin: 0;">Tetapkan tajuk berita yang menarik, pilih kategori teras, dan sasaran pembaca.</p>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <label style="margin: 0;">Tajuk Buletin / Artikel *</label>
                                        <span style="font-size: 0.75rem; color: #64748B; font-weight: 700;">Pilih cadangan topik pantas atau taip sendiri:</span>
                                    </div>
                                    <input type="text" id="inputTitle" name="title" value="<%= (editNews != null) ? editNews.getNewsTitle() : "" %>" placeholder="Contoh: Minggu Penerokaan Fonik & Bacaan Suku Kata Berirama" required oninput="updatePreview()">
                                    
                                    <!-- Quick Topic Chips -->
                                    <div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px;">
                                        <span style="font-size: 11px; font-weight: 900; color: #64748B; align-self: center;">Cadangan Topik Pantas:</span>
                                        <button type="button" class="topic-chip" onclick="applyTopic('Minggu Penerokaan Fonik & Bacaan CVC Berirama', 'Academic Focus', 'Sepanjang minggu ini, murid-murid prasekolah akan mendalami kemahiran membunyikan vokal dan konsonan serta penggabungan perkataan mudah CVC.')">Minggu Penerokaan Fonik & Bacaan CVC Berirama</button>
                                        <button type="button" class="topic-chip" onclick="applyTopic('Karnival Mengira Musim Luruh & Hari Matematik Cilik', 'Event', 'Jemputan mesra kepada semua ibu bapa untuk menyertai Hari Matematik Cilik pada hari Jumaat ini.')">Karnival Mengira Musim Luruh & Hari Matematik Cilik</button>
                                        <button type="button" class="topic-chip" onclick="applyTopic('Makluman Cuti Penggal Persekolahan & Modul Rumah', 'Holiday', 'Pusat pembelajaran akan bercuti sempena cuti penggal persekolahan mulai minggu hadapan.')">Makluman Cuti Penggal Persekolahan</button>
                                    </div>
                                </div>

                                <!-- Category Selection Grid -->
                                <div class="form-group">
                                    <label>Pilih Kategori Buletin (Bulletin Category)</label>
                                    <input type="hidden" id="selectedCategoryInput" name="category" value="<%= (editNews != null) ? editNews.getNewsCategory() : "Academic Focus" %>">
                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin-top: 8px;">
                                        <% String currentCat = editNews != null ? editNews.getNewsCategory() : "Academic Focus"; %>
                                        <div class="cat-select-card <%= "Academic Focus".equals(currentCat) ? "selected" : "" %>" onclick="setCategory('Academic Focus', this)">
                                            <span style="font-size: 1.2rem;">📖</span>
                                            <span style="font-size: 0.8rem;">Academic Focus</span>
                                        </div>
                                        <div class="cat-select-card <%= "Announcement".equals(currentCat) ? "selected" : "" %>" onclick="setCategory('Announcement', this)">
                                            <span style="font-size: 1.2rem;">📢</span>
                                            <span style="font-size: 0.8rem;">Announcement</span>
                                        </div>
                                        <div class="cat-select-card <%= "Event".equals(currentCat) ? "selected" : "" %>" onclick="setCategory('Event', this)">
                                            <span style="font-size: 1.2rem;">🎉</span>
                                            <span style="font-size: 0.8rem;">Event</span>
                                        </div>
                                        <div class="cat-select-card <%= "Holiday".equals(currentCat) ? "selected" : "" %>" onclick="setCategory('Holiday', this)">
                                            <span style="font-size: 1.2rem;">🌴</span>
                                            <span style="font-size: 0.8rem;">Holiday</span>
                                        </div>
                                        <div class="cat-select-card <%= "Nutrition".equals(currentCat) ? "selected" : "" %>" onclick="setCategory('Nutrition', this)">
                                            <span style="font-size: 1.2rem;">🍎</span>
                                            <span style="font-size: 0.8rem;">Nutrition</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Target Audience Grid -->
                                <div class="form-group" style="margin-bottom: 0;">
                                    <label>Sasaran Pembaca (Target Audience)</label>
                                    <input type="hidden" id="selectedAudienceInput" name="targetAudience" value="<%= (editNews != null) ? editNews.getTargetAudience() : "All" %>">
                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; margin-top: 8px;">
                                        <% String currentAud = editNews != null ? editNews.getTargetAudience() : "All"; %>
                                        <div class="audience-card <%= "All".equals(currentAud) ? "selected" : "" %>" onclick="setAudience('All', this)">
                                            <div style="font-weight: 900; font-size: 0.9rem;">Semua Komuniti</div>
                                            <div style="font-size: 0.75rem; color: #64748B;">Ibu Bapa & Guru</div>
                                        </div>
                                        <div class="audience-card <%= "Parents".equals(currentAud) ? "selected" : "" %>" onclick="setAudience('Parents', this)">
                                            <div style="font-weight: 900; font-size: 0.9rem;">Ibu Bapa Sahaja</div>
                                            <div style="font-size: 0.75rem; color: #64748B;">Keluarga Murid</div>
                                        </div>
                                        <div class="audience-card <%= "Teachers".equals(currentAud) ? "selected" : "" %>" onclick="setAudience('Teachers', this)">
                                            <div style="font-weight: 900; font-size: 0.9rem;">Guru & Staf Sahaja</div>
                                            <div style="font-size: 0.75rem; color: #64748B;">Warga Pendidik</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 2: Kandungan Mesej -->
                            <div class="neo-card" style="margin-top: 24px;">
                                <div style="display: flex; align-items: center; gap: 10px; border-bottom: 2px solid #E2E8F0; padding-bottom: 12px; margin-bottom: 20px;">
                                    <div style="width: 32px; height: 32px; background: #7BE495; border: 2px solid #2D3436; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem;">✍️</div>
                                    <div>
                                        <h3 style="font-size: 1.1rem; font-weight: 900; margin: 0;">2. Kandungan Mesej Buletin & Tetapan Penonjolan</h3>
                                        <p style="font-size: 0.75rem; color: #64748B; margin: 0;">Tulis penerangan aktiviti, objektif pembelajaran, atau arahan penting secara jelas.</p>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <label style="margin: 0;">Teks Kandungan Buletin (Bulletin Message)</label>
                                        <span id="charCount" style="font-size: 0.75rem; color: #64748B; font-family: monospace; font-weight: 800;">0 aksara</span>
                                    </div>
                                    <textarea id="inputContent" name="content" rows="6" placeholder="Terangkan secara terperinci mengenai aktiviti mingguan, objektif pembelajaran, tarikh penting, atau pesanan praktikal untuk ibu bapa..." required oninput="updatePreview()"><%= (editNews != null) ? editNews.getNewsContent() : "" %></textarea>
                                </div>

                                <!-- Pinned Toggle Box -->
                                <div style="border: 2.5px solid #2D3436; border-radius: 16px; padding: 16px; background: #FEFCE8; display: flex; align-items: center; justify-content: space-between; cursor: pointer;" onclick="togglePin()">
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <div style="width: 36px; height: 36px; background: #FFD02C; border: 2px solid #2D3436; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem;">📌</div>
                                        <div>
                                            <div style="font-weight: 900; font-size: 0.9rem;">Sematkan Sebagai Pengumuman Utama (Pin Announcement)</div>
                                            <div style="font-size: 0.75rem; color: #64748B;">Buletin yang disematkan akan sentiasa berada di kedudukan paling atas suapan dengan bingkai serlahan khas.</div>
                                        </div>
                                    </div>
                                    <input type="checkbox" id="inputPinned" name="pinned" style="width: 22px; height: 22px; cursor: pointer;" <%= (editNews != null && editNews.isPinned()) ? "checked" : "" %>>
                                </div>
                            </div>

                            <!-- Section 3: Submit Actions Bar -->
                            <div class="neo-card" style="margin-top: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; padding: 20px 28px;">
                                <div style="font-size: 0.8rem; font-weight: 700; color: #64748B;">
                                    ℹ️ Buletin yang diterbitkan akan terus diselaraskan ke papan pemuka ibu bapa dan guru secara masa nyata.
                                </div>
                                <div style="display: flex; gap: 12px; width: 100%; sm:width: auto; justify-content: flex-end;">
                                    <a href="NewsServlet" class="btn-neo" style="background: #FFF;">Batal</a>
                                    <button type="submit" class="btn-neo btn-yellow" style="padding: 12px 28px; font-size: 0.95rem;">
                                        🚀 Terbitkan Buletin Mingguan
                                    </button>
                                </div>
                            </div>
                        </form>

                        <script>
                            function updatePreview() {
                                const title = document.getElementById('inputTitle').value;
                                const content = document.getElementById('inputContent').value;
                                
                                document.getElementById('cardPrevTitle').innerText = title.trim() || 'Tajuk Buletin Mingguan Akan Dipaparkan Di Sini...';
                                document.getElementById('cardPrevContent').innerText = content.trim() || 'Kandungan berita mingguan, pengumuman kurikulum, makluman aktiviti pembelajaran, dan pesanan mesra untuk keluarga akan dipaparkan di bahagian ini secara langsung semasa anda menaip...';
                                document.getElementById('charCount').innerText = content.length + ' aksara';
                            }

                            function setCategory(cat, element) {
                                document.getElementById('selectedCategoryInput').value = cat;
                                document.querySelectorAll('.cat-select-card').forEach(el => el.classList.remove('selected'));
                                element.classList.add('selected');
                                
                                const badge = document.getElementById('previewCatBadge');
                                const cardBadge = document.getElementById('cardPrevCat');
                                badge.innerText = cat;
                                cardBadge.innerText = cat;
                            }

                            function setAudience(aud, element) {
                                document.getElementById('selectedAudienceInput').value = aud;
                                document.querySelectorAll('.audience-card').forEach(el => el.classList.remove('selected'));
                                element.classList.add('selected');
                                
                                const audText = aud === 'All' ? 'Semua (Ibu Bapa & Guru)' : aud === 'Parents' ? 'Ibu Bapa Sahaja' : 'Guru & Staf Sahaja';
                                document.getElementById('cardPrevAud').innerText = 'Sasaran: ' + audText;
                            }

                            function applyTopic(title, category, sampleText) {
                                document.getElementById('inputTitle').value = title;
                                document.getElementById('inputContent').value = sampleText;
                                
                                // Pilih kategori secara automatik
                                const cards = document.querySelectorAll('.cat-select-card');
                                cards.forEach(card => {
                                    if(card.innerText.includes(category)) {
                                        card.click();
                                    }
                                });
                                updatePreview();
                            }

                            function togglePin() {
                                const checkbox = document.getElementById('inputPinned');
                                checkbox.checked = !checkbox.checked;
                            }

                            // Run initial preview sync
                            window.onload = function() {
                                if(document.getElementById('inputTitle')) {
                                    updatePreview();
                                }
                            }
                        </script>

                    <% } else { %>
                        <!-- ================= STANDARD FEED VIEW ================= -->
                        <div class="neo-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                            <div style="display: flex; gap: 16px; align-items: center;">
                                <div style="width: 54px; height: 54px; background: #FFD02C; border: 2.5px solid #2D3436; border-radius: 16px; display: flex; align-items: center; justify-content: center; box-shadow: 3px 3px 0px #2D3436; font-size: 1.5rem;">
                                    📰
                                </div>
                                <div>
                                    <h2 style="font-size: 1.6rem; font-weight: 900; margin: 0 0 4px 0;">Keedflix Weekly News & Bulletins</h2>
                                    <p style="font-size: 0.85rem; font-weight: 600; color: #64748B; margin: 0;">Curriculum updates, reading & counting activities. (Role: <strong><%= userRole %></strong>)</p>
                                </div>
                            </div>

                            <% if (canCreateUpdate) { %>
                                <a href="NewsServlet?mode=create" class="btn-neo btn-yellow">
                                    ➕ Create News
                                </a>
                            <% } %>
                        </div>

                        <!-- Category Filter Pills -->
                        <div style="display: flex; flex-wrap: wrap; gap: 10px; align-items: center;">
                            <span style="font-weight: 900; font-size: 0.85rem; margin-right: 4px;">Filter Category:</span>
                            <% 
                                String[] cats = {"All", "Academic Focus", "Announcement", "Event", "Holiday", "Nutrition"};
                                for (String cat : cats) {
                                    boolean isActive = selectedCategory.equals(cat);
                            %>
                                <a href="NewsServlet?category=<%= cat %>" class="filter-pill <%= isActive ? "active" : "" %>"><%= cat %></a>
                            <% } %>
                        </div>

                        <!-- News Cards Grid -->
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
                            <% 
                                boolean hasNews = false;
                                if (newsList != null) {
                                    for (News item : newsList) {
                                        if (!selectedCategory.equals("All") && !item.getNewsCategory().equalsIgnoreCase(selectedCategory)) continue;
                                        if (userRole.equals("Parent") && "Teachers".equalsIgnoreCase(item.getTargetAudience())) continue;
                                        hasNews = true;

                                        String badgeClass = "badge-academic";
                                        if ("Announcement".equalsIgnoreCase(item.getNewsCategory())) badgeClass = "badge-announcement";
                                        else if ("Event".equalsIgnoreCase(item.getNewsCategory())) badgeClass = "badge-event";
                                        else if ("Holiday".equalsIgnoreCase(item.getNewsCategory())) badgeClass = "badge-holiday";
                                        else if ("Nutrition".equalsIgnoreCase(item.getNewsCategory())) badgeClass = "badge-nutrition";
                            %>
                                <div class="neo-card" style="display: flex; flex-direction: column; justify-content: space-between; position: relative; <%= item.isPinned() ? "border: 3px solid #EAB308; background: #FEFCE8;" : "" %>">
                                    <div>
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                            <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                                                <span class="badge <%= badgeClass %>"><%= item.getNewsCategory() %></span>
                                                <% if (item.isPinned()) { %>
                                                    <span class="badge" style="background: #FEF08A; border-color: #2D3436;">📌 Pinned</span>
                                                <% } %>
                                                <span class="badge" style="background: #F1F5F9; color: #64748B;">Audience: <%= item.getTargetAudience() != null ? item.getTargetAudience() : "All" %></span>
                                            </div>

                                            <div style="display: flex; gap: 6px;">
                                                <% if (canCreateUpdate) { %>
                                                    <a href="NewsServlet?mode=edit&id=<%= item.getNewsID() %>" class="btn-neo" style="padding: 6px 10px; font-size: 0.75rem;" title="Kemaskini">✏️</a>
                                                <% } %>
                                                <% if (canDelete) { %>
                                                    <form action="NewsServlet" method="POST" style="margin: 0;">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="newsID" value="<%= item.getNewsID() %>">
                                                        <button type="submit" class="btn-neo btn-rose" style="padding: 6px 10px; font-size: 0.75rem;" onclick="return confirm('Padam buletin ini?');" title="Padam">🗑️</button>
                                                    </form>
                                                <% } %>
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1.1rem; font-weight: 900; margin: 0 0 8px 0;"><%= item.getNewsTitle() %></h3>
                                        <p style="font-size: 0.85rem; font-weight: 600; color: #4B5563; line-height: 1.5; margin: 0; white-space: pre-line;"><%= item.getNewsContent() %></p>
                                    </div>

                                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 2px dashed #CBD5E1; margin-top: 20px; padding-top: 12px; font-size: 0.75rem; font-weight: 800; color: #64748B;">
                                        <span>👤 Teacher ID: #<%= item.getTeacherID() %></span>
                                        <span>📅 <%= item.getNewsDate() != null ? item.getNewsDate().toString().substring(0, 10) : "" %></span>
                                    </div>
                                </div>
                            <%      }
                                }
                                if (!hasNews) {
                            %>
                                <div class="neo-card" style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                                    <h3>Tiada buletin dijumpai dalam kategori ini.</h3>
                                </div>
                            <% } %>
                        </div>
                    <% } %>

                </div>
            </div>
        </main>
    </div>

</body>
</html>