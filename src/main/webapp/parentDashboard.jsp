<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="bean.Parent"%>
<%@ page import="util.IconUtil"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keedflix - Parent Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/parentDashboard.css">
    
</head>
<body>

    <div class="app-layout">
        
        <!-- 1. LEFT: SIDEBAR -->
        <aside class="app-sidebar-wrapper">
            <jsp:include page="sidebar.jsp" />
        </aside>

        <!-- 2. RIGHT: MAIN (HEADER + CONTENT) -->
        <main class="app-main-wrapper">
            
            <!-- A. HEADER SECTION -->
            <div class="app-header-wrapper">
                <jsp:include page="header.jsp" />
            </div>

            <!-- B. CONTENT BODY SECTION -->
            <div class="app-content-body">
                
                <div class="parent-platform-root" id="parent-platform-root">
                    
                    <!-- 1. Parent Title & Interactive Child Switcher Banner -->
                    <div class="banner-dropdown-wrapper" id="bannerDropdownWrapper">
                        <button type="button" class="banner-card" onclick="toggleBannerDropdown()">
                            <div class="banner-left">
                                <div class="heart-icon-box">
                                    <%= IconUtil.icon("Heart", "icon-lg") %>
                                </div>
                                <div>
                                    <div class="banner-title-group">
                                        <h1 class="banner-title">Welcome back, <strong>${parentName}</strong></h1>
                                    </div>
                                    <p class="banner-subtitle">
                                        Logged in as: ${parentTitle} • Connected to <strong>${currentStudent.name}</strong>
                                    </p>
                                </div>
                            </div>

                            <div class="banner-right">
                                <div class="banner-chevron" title="Tukar pilihan anak">
                                    <%= IconUtil.icon("ChevronDown", "icon-md") %>
                                </div>
                            </div>
                        </button>

                        <!-- Dropdown Menu List (Senarai Anak Berdaftar Under Parent) -->
                        <div class="banner-child-menu" id="bannerChildMenu">
                            <p style="font-size: 11px; font-weight: 900; color: #636E72; text-transform: uppercase; letter-spacing: 0.04em; margin: 0 0 12px 4px;">
                                SELECT REGISTERED CHILD (${not empty registeredChildren ? registeredChildren.size() : 1})
                            </p>
                            
                            <c:choose>
                                <c:when test="${not empty registeredChildren}">
                                    <c:forEach var="child" items="${registeredChildren}">
                                        <a href="${pageContext.request.contextPath}/parentDashboard?studentId=${child.id}" class="child-option ${child.id == currentStudent.id ? 'selected' : ''}">
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <span style="background: ${child.id == currentStudent.id ? '#FFB3C6' : '#FAF5EF'}; border: 2px solid #2D3436; border-radius: 50%; width: 42px; height: 42px; display: flex; justify-content: center; align-items: center; flex-shrink: 0;">
                                                    <%= IconUtil.icon("Smile", "icon-sm") %>
                                                </span>
                                                <div>
                                                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                                        <p style="font-size: 15px; font-weight: 900; margin: 0; color: #2D3436;">${child.name}</p>
                                                        <c:if test="${child.id == currentStudent.id}">
                                                            <span style="background: #FFD02C; color: #2D3436; border: 1.5px solid #2D3436; font-size: 10px; font-weight: 900; padding: 1px 8px; border-radius: 999px;">
                                                                Current
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                    <p style="font-size: 12px; color: #636E72; margin: 2px 0 0 0; font-weight: 600;">${child.className} • Age: ${child.age}</p>
                                                </div>
                                            </div>
                                            <c:if test="${child.id == currentStudent.id}">
                                                <div style="background: #2D3436; color: white; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                                    <%= IconUtil.icon("Check", "icon-xs") %>
                                                </div>
                                            </c:if>
                                        </a>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="child-option selected" style="cursor: default;">
                                        <div style="display: flex; align-items: center; gap: 12px;">
                                            <span style="background: #FFB3C6; border: 2px solid #2D3436; border-radius: 50%; width: 42px; height: 42px; display: flex; justify-content: center; align-items: center;">
                                                <%= IconUtil.icon("Smile", "icon-sm") %>
                                            </span>
                                            <div>
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <p style="font-size: 15px; font-weight: 900; margin: 0; color: #2D3436;">${currentStudent.name}</p>
                                                    <span style="background: #FFD02C; color: #2D3436; border: 1.5px solid #2D3436; font-size: 10px; font-weight: 900; padding: 1px 8px; border-radius: 999px;">Current</span>
                                                </div>
                                                <p style="font-size: 12px; color: #636E72; margin: 2px 0 0 0; font-weight: 600;">${currentStudent.className} • Age: ${currentStudent.age}</p>
                                            </div>
                                        </div>
                                        <div style="background: #2D3436; color: white; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                            <%= IconUtil.icon("Check", "icon-xs") %>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- 2. Quick Metrics Cards -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Developmental Score</span>
                                <div class="metric-icon-box bg-purple">
                                    <%= IconUtil.icon("Award", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${averageLevel}%</p>
                            <p class="metric-sub">Average mastery across 3 learning areas</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Photo Evidence</span>
                                <div class="metric-icon-box bg-amber">
                                    <%= IconUtil.icon("Camera", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${photoProofsCount}</p>
                            <p class="metric-sub">Classroom photos verified by educators</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Milestones Achieved</span>
                                <div class="metric-icon-box bg-emerald">
                                    <%= IconUtil.icon("CheckCircle", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${completedMilestones}</p>
                            <p class="metric-sub">Certificated early learning milestones</p>
                        </div>

                        <div class="metric-card">
                            <div class="metric-header">
                                <span class="metric-label">Academic Cycle</span>
                                <div class="metric-icon-box bg-rose">
                                    <%= IconUtil.icon("Calendar", "icon-sm") %>
                                </div>
                            </div>
                            <p class="metric-value">${academicCycle}</p>
                            <p class="metric-sub">Official term portfolio certified</p>
                        </div>
                    </div>

                    <!-- 3. Child Developmental Balance Charts Row -->
                    <div class="charts-row">
                        <!-- Kotak Radar Chart -->
                        <div style="width: 100%; height: 560px;">
                            <iframe src="${pageContext.request.contextPath}/RadarChartServlet?studentId=${currentStudent.id}" 
                                    width="100%" 
                                    height="100%" 
                                    frameborder="0" 
                                    scrolling="no"
                                    allowtransparency="true"
                                    style="background: transparent; display: block;"
                                    title="Radar Chart">
                            </iframe>
                        </div>
                        
                        <!-- Kotak Trend Chart -->
                        <div style="width: 100%; height: 560px;">
                            <iframe src="${pageContext.request.contextPath}/TrendChartServlet?studentId=${currentStudent.id}" 
                                    width="100%" 
                                    height="100%" 
                                    frameborder="0" 
                                    scrolling="no"
                                    allowtransparency="true"
                                    style="background: transparent; display: block;"
                                    title="Trend Chart">
                            </iframe>
                        </div>
                    </div>
                    
                    <!-- 4. Keedflix Centre News &  Bulletins -->
                    <div class="news-section">
                        
                        <!-- Header Berita -->
                        <div class="news-header-container">
                            <div class="news-header-left">
                                <div class="news-icon-box">
                                    <%= IconUtil.icon("Newspaper", "icon-md") %>
                                </div>
                                <div>
                                    <h2 class="news-title">
                                        Keedflix Centre News &amp;  Bulletins
                                    </h2>
                                    <p class="news-subtitle">Curriculum updates, reading &amp; counting activities, and upcoming centre events for families</p>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/NewsServlet" class="btn-view-portal">
                                <span>View Full News Portal</span>
                                <%= IconUtil.icon("ArrowRight", "icon-sm") %>
                            </a>
                        </div>

                        <!-- Penapis Kategori -->
                        <div class="news-filters">
                            <span class="filter-label">
                                <%= IconUtil.icon("Filter", "icon-xs") %>
                                Category:
                            </span>
                            <button type="button" class="filter-btn active" onclick="filterNews('All', this)">All</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Academic Focus', this)">Academic Focus</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Announcement', this)">Announcement</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Event', this)">Event</button>
                            <button type="button" class="filter-btn" onclick="filterNews('Holiday', this)">Holiday</button>
                        </div>

                        <!-- Grid Kad Berita -->
                        <div class="news-grid" id="parentNewsGrid">
                            
                            <!-- Kad Berita 1 -->
                            <div class="news-card" data-category="Academic Focus">
                                <div class="nc-header">
                                    <span class="nc-tag tag-academic">ACADEMIC FOCUS</span>
                                    <span class="nc-pinned">
                                        <%= IconUtil.icon("Pin", "icon-xs") %>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">September Literacy Expedition: Phonics &amp; CVC Blending Week</h3>
                                <p class="nc-excerpt">This week across all kindergarten classrooms, teachers and students are embarking on our interactive Phonics &amp; Letter Blending Expedition! Children will be building tactile 3-letter CVC word cubes and matching...</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <%= IconUtil.icon("User", "icon-xs") %>
                                        Eleanor Ward (Principal)
                                    </span>
                                    <span class="nc-date">
                                        <%= IconUtil.icon("Calendar", "icon-xs") %>
                                        2026-09-12
                                    </span>
                                </div>
                            </div>

                            <!-- Kad Berita 2 -->
                            <div class="news-card" data-category="Event">
                                <div class="nc-header">
                                    <span class="nc-tag tag-event">EVENT</span>
                                    <span class="nc-pinned">
                                        <%= IconUtil.icon("Pin", "icon-xs") %>
                                        PINNED
                                    </span>
                                </div>
                                <h3 class="nc-title">Autumn Counting Carnival &amp; Family Math Day</h3>
                                <p class="nc-excerpt">Join us on Friday, September 25th for our annual Kindergarten Math &amp; Counting Carnival. Interactive stations include 1-to-1 acorn counting, numeral scavenger hunts, and giant floor number line hops....</p>
                                <div class="nc-footer">
                                    <span class="nc-author">
                                        <%= IconUtil.icon("User", "icon-xs") %>
                                        Eleanor Ward (Principal)
                                    </span>
                                    <span class="nc-date">
                                        <%= IconUtil.icon("Calendar", "icon-xs") %>
                                        2026-09-08
                                    </span>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>

            </div>
            
        </main>
    </div>

    <!-- SCRIPT FOR INTERACTIVITY -->
    <script>
        function toggleBannerDropdown() {
            const wrapper = document.getElementById('bannerDropdownWrapper');
            const menu = document.getElementById('bannerChildMenu');
            if (wrapper && menu) {
                wrapper.classList.toggle('open');
                menu.classList.toggle('show');
            }
        }

        function filterNews(category, btn) {
            document.querySelectorAll('.news-filters .filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            document.querySelectorAll('#parentNewsGrid .news-card').forEach(card => {
                if (category === 'All' || card.dataset.category === category) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        window.onclick = function(event) {
            if (!event.target.closest('#bannerDropdownWrapper')) {
                const wrapper = document.getElementById('bannerDropdownWrapper');
                const menu = document.getElementById('bannerChildMenu');
                if (wrapper) wrapper.classList.remove('open');
                if (menu) menu.classList.remove('show');
            }
        };
    </script>

    <jsp:include page="icons.jsp" />
</body>
</html>