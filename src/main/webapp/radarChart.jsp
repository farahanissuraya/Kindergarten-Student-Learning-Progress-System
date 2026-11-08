<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Radar Penguasaan 3 Teras - Keedflix Centre</title>

    <style>
        :root {
            --bg-canvas: #FFFDF7;
            --border-dark: #2D3436;
            --yellow-accent: #FFD166;
            --coral-accent: #FF6B6B;
            --mint-accent: #2EC4B6;
            --purple-accent: #7C3AED;
            --orange-accent: #FF9F43;
            --shadow-sm: 2px 2px 0px 0px var(--border-dark);
            --shadow-md: 3px 3px 0px 0px var(--border-dark);
            --shadow-lg: 4px 4px 0px 0px var(--border-dark);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body, html {
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background-color: var(--bg-canvas);
            color: var(--border-dark);
        }

        .app-layout {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        .app-sidebar-wrapper {
            width: 280px;
            flex-shrink: 0;
            background: #FFFFFF;
            border-right: 3px solid var(--border-dark);
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            background-color: var(--bg-canvas);
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background: #FFFFFF;
            border-bottom: 3px solid var(--border-dark);
        }

        .app-content-body {
            flex-grow: 1;
            padding: 24px;
            overflow-y: auto;
        }

        .nb-radar-card {
            background-color: #FFFFFF;
            border: 3px solid var(--border-dark);
            border-radius: 24px;
            padding: 24px;
            box-shadow: var(--shadow-lg);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            user-select: none;
        }

        .series-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            border: 2px solid var(--border-dark);
            cursor: pointer;
            font-size: 0.7rem;
            font-weight: 800;
            background: #F1F5F9;
            color: #64748B;
            transition: all 0.15s ease;
        }
        .series-btn.active-target { background-color: #D1FAE5; color: #065F46; box-shadow: var(--shadow-sm); }
        .series-btn.active-class { background-color: #EDE9FE; color: #5B21B6; box-shadow: var(--shadow-sm); }
        .series-btn.active-student { background-color: #FEF3C7; color: #78350F; box-shadow: var(--shadow-sm); }

        .series-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            border: 1px solid var(--border-dark);
            display: inline-block;
        }

        .alert-box {
            padding: 12px 16px;
            border-radius: 16px;
            border: 2px solid var(--border-dark);
            box-shadow: var(--shadow-sm);
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 0.78rem;
        }
        .alert-warning { background-color: #FFFBEB; border-color: #F59E0B; }
        .alert-success { background-color: #ECFDF5; border-color: #10B981; }

        .vertex-dot {
            cursor: pointer;
            transition: transform 0.2s;
        }
        .vertex-dot:hover { transform: scale(1.3); }
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
            <c:choose>
                <c:when test="${not empty errorMessage}">
                    <div class="alert-box alert-warning" style="margin-bottom: 20px;">
                        ⚠️ <strong>Status Database:</strong> ${errorMessage}
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="nb-radar-card" id="radar-chart-card">

                        <!-- LEGEND HEADER -->
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; margin-bottom: 12px; border-bottom: 1px solid #E2E8F0; padding-bottom: 12px;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 1.1rem;">🧭</span>
                                <span style="font-weight: 900; font-size: 0.88rem;">
                                    Radar Penguasaan 3 Teras: Reading, Writing & Counting
                                </span>
                            </div>

                            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                <button type="button" id="btnTarget" class="series-btn active-target" onclick="toggleSeries('target')">
                                    <span class="series-dot" style="background-color: #10B981;"></span>
                                    🎯 Sasaran Umur ${not empty student ? student.studentAge : 5}th (Skala ${targetScale})
                                </button>

                                <button type="button" id="btnClass" class="series-btn active-class" onclick="toggleSeries('class')">
                                    <span class="series-dot" style="background-color: var(--purple-accent);"></span>
                                    Purata Kelas (Database AVG)
                                </button>

                                <button type="button" id="btnStudent" class="series-btn active-student" onclick="toggleSeries('student')">
                                    <span class="series-dot" style="background-color: var(--orange-accent);"></span>
                                    ${not empty student ? student.studentName : 'Murid'} (DB Live)
                                </button>
                            </div>
                        </div>

                        <%
                            Integer readingScaleObj = (Integer) request.getAttribute("readingScale");
                            Integer writingScaleObj = (Integer) request.getAttribute("writingScale");
                            Integer countingScaleObj = (Integer) request.getAttribute("countingScale");
                            Integer targetScaleObj = (Integer) request.getAttribute("targetScale");

                            Double classReadingObj = (Double) request.getAttribute("classReadingRadar");
                            Double classWritingObj = (Double) request.getAttribute("classWritingRadar");
                            Double classCountingObj = (Double) request.getAttribute("classCountingRadar");

                            int readingScale = readingScaleObj != null && readingScaleObj > 0 ? readingScaleObj : 3;
                            int writingScale = writingScaleObj != null && writingScaleObj > 0 ? writingScaleObj : 3;
                            int countingScale = countingScaleObj != null && countingScaleObj > 0 ? countingScaleObj : 3;
                            int targetScale = targetScaleObj != null && targetScaleObj > 0 ? targetScaleObj : 4;

                            double classReading = classReadingObj != null && classReadingObj > 0 ? classReadingObj : 7.2;
                            double classWriting = classWritingObj != null && classWritingObj > 0 ? classWritingObj : 6.4;
                            double classCounting = classCountingObj != null && classCountingObj > 0 ? classCountingObj : 7.6;

                            double cx = 190.0, cy = 165.0, R = 95.0;

                            double rValReading = readingScale * 2.0;
                            double rValWriting = writingScale * 2.0;
                            double rValCounting = countingScale * 2.0;
                            double rValTarget = targetScale * 2.0;

                            double a0 = -Math.PI / 2.0;
                            double a1 = a0 + (2.0 * Math.PI / 3.0);
                            double a2 = a1 + (2.0 * Math.PI / 3.0);

                            // Points for Target Polygon
                            double xT0 = cx + (rValTarget / 10.0) * R * Math.cos(a0), yT0 = cy + (rValTarget / 10.0) * R * Math.sin(a0);
                            double xT1 = cx + (rValTarget / 10.0) * R * Math.cos(a1), yT1 = cy + (rValTarget / 10.0) * R * Math.sin(a1);
                            double xT2 = cx + (rValTarget / 10.0) * R * Math.cos(a2), yT2 = cy + (rValTarget / 10.0) * R * Math.sin(a2);

                            // Points for Class Polygon
                            double xC0 = cx + (classReading / 10.0) * R * Math.cos(a0), yC0 = cy + (classReading / 10.0) * R * Math.sin(a0);
                            double xC1 = cx + (classWriting / 10.0) * R * Math.cos(a1), yC1 = cy + (classWriting / 10.0) * R * Math.sin(a1);
                            double xC2 = cx + (classCounting / 10.0) * R * Math.cos(a2), yC2 = cy + (classCounting / 10.0) * R * Math.sin(a2);

                            // Points for Student Polygon
                            double xS0 = cx + (rValReading / 10.0) * R * Math.cos(a0), yS0 = cy + (rValReading / 10.0) * R * Math.sin(a0);
                            double xS1 = cx + (rValWriting / 10.0) * R * Math.cos(a1), yS1 = cy + (rValWriting / 10.0) * R * Math.sin(a1);
                            double xS2 = cx + (rValCounting / 10.0) * R * Math.cos(a2), yS2 = cy + (rValCounting / 10.0) * R * Math.sin(a2);

                            String targetPts = xT0 + "," + yT0 + " " + xT1 + "," + yT1 + " " + xT2 + "," + yT2;
                            String classPts = xC0 + "," + yC0 + " " + xC1 + "," + yC1 + " " + xC2 + "," + yC2;
                            String studentPts = xS0 + "," + yS0 + " " + xS1 + "," + yS1 + " " + xS2 + "," + yS2;
                        %>

                        <!-- SVG RADAR CANVAS -->
                        <div style="position: relative; display: flex; align-items: center; justify-content: center; min-height: 290px;">
                            <svg width="380" height="310" viewBox="0 0 380 310" style="overflow: visible;">
                                
                                <!-- Concentric Triangles (Skala 1, 2, 3, 4, 5) -->
                                <c:forEach var="lvl" begin="2" end="10" step="2">
                                    <%
                                        Integer lvlVal = (Integer) pageContext.getAttribute("lvl");
                                        double rL = (lvlVal / 10.0) * R;
                                        String rPts = (cx + rL * Math.cos(a0)) + "," + (cy + rL * Math.sin(a0)) + " " +
                                                      (cx + rL * Math.cos(a1)) + "," + (cy + rL * Math.sin(a1)) + " " +
                                                      (cx + rL * Math.cos(a2)) + "," + (cy + rL * Math.sin(a2));
                                    %>
                                    <g>
                                        <polygon points="<%= rPts %>" fill="${lvl % 4 == 0 ? '#FAFAFA' : 'none'}" stroke="#CBD5E1" stroke-width="1.2" stroke-dasharray="${lvl == 10 ? 'none' : '3 3'}" />
                                        <text x="<%= cx + 5 %>" y="<%= cy - (lvlVal / 10.0) * R + 3 %>" font-size="8" fill="#64748B" font-weight="800">
                                            Skala ${lvl / 2}
                                        </text>
                                    </g>
                                </c:forEach>

                                <!-- Radial Spokes -->
                                <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a0) %>" y2="<%= cy + R * Math.sin(a0) %>" stroke="#CBD5E1" stroke-width="1.5" />
                                <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a1) %>" y2="<%= cy + R * Math.sin(a1) %>" stroke="#CBD5E1" stroke-width="1.5" />
                                <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a2) %>" y2="<%= cy + R * Math.sin(a2) %>" stroke="#CBD5E1" stroke-width="1.5" />

                                <!-- POLYGON SERIES 1: Student -->
                                <polygon id="polyStudent" points="<%= studentPts %>" fill="rgba(255, 159, 67, 0.45)" stroke="#FF9F43" stroke-width="3" />

                                <!-- POLYGON SERIES 2: Class -->
                                <polygon id="polyClass" points="<%= classPts %>" fill="rgba(108, 92, 231, 0.2)" stroke="#6C5CE7" stroke-width="2.5" />

                                <!-- POLYGON SERIES 3: Target -->
                                <polygon id="polyTarget" points="<%= targetPts %>" fill="rgba(9, 132, 227, 0.15)" stroke="#0984E3" stroke-width="2.5" stroke-dasharray="4 3" />

                                <!-- VERTICES DOTS -->
                                <circle class="vertex-dot" cx="<%= xS0 %>" cy="<%= yS0 %>" r="5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />
                                <circle class="vertex-dot" cx="<%= xS1 %>" cy="<%= yS1 %>" r="5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />
                                <circle class="vertex-dot" cx="<%= xS2 %>" cy="<%= yS2 %>" r="5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />

                                <!-- DOMAIN LABELS -->
                                <g>
                                    <text x="<%= cx %>" y="<%= cy - R - 20 %>" font-size="12" font-weight="900" fill="#2D3436" text-anchor="middle">📖 1. Reading</text>
                                    <text x="<%= cx %>" y="<%= cy - R - 7 %>" font-size="10" font-weight="800" fill="<%= readingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="middle">
                                        Skala <%= readingScale %>/5 (<%= readingScale * 20 %>%)
                                    </text>
                                </g>
                                <g>
                                    <text x="<%= cx + (R + 25) * Math.cos(a1) %>" y="<%= cy + (R + 25) * Math.sin(a1) + 8 %>" font-size="12" font-weight="900" fill="#2D3436" text-anchor="start">✏️ 2. Writing</text>
                                    <text x="<%= cx + (R + 25) * Math.cos(a1) %>" y="<%= cy + (R + 25) * Math.sin(a1) + 21 %>" font-size="10" font-weight="800" fill="<%= writingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="start">
                                        Skala <%= writingScale %>/5 (<%= writingScale * 20 %>%)
                                    </text>
                                </g>
                                <g>
                                    <text x="<%= cx + (R + 25) * Math.cos(a2) %>" y="<%= cy + (R + 25) * Math.sin(a2) + 8 %>" font-size="12" font-weight="900" fill="#2D3436" text-anchor="end">🔢 3. Counting</text>
                                    <text x="<%= cx + (R + 25) * Math.cos(a2) %>" y="<%= cy + (R + 25) * Math.sin(a2) + 21 %>" font-size="10" font-weight="800" fill="<%= countingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="end">
                                        Skala <%= countingScale %>/5 (<%= countingScale * 20 %>%)
                                    </text>
                                </g>

                            </svg>
                        </div>

                        <!-- DEVELOPMENTAL GAP ALERT BAR -->
                        <div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid #E2E8F0;">
                            <c:choose>
                                <c:when test="${hasGap}">
                                    <div class="alert-box alert-warning">
                                        <div style="padding: 4px; background: #F59E0B; color: #FFF; border-radius: 8px; border: 1px solid var(--border-dark);">
                                            ⚠️
                                        </div>
                                        <div>
                                            <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                                <strong style="color: #78350F; font-size: 0.8rem; text-transform: uppercase;">
                                                    Alert Sasaran Umur ${not empty student ? student.studentAge : 5} Tahun
                                                </strong>
                                                <span style="background: #FDE68A; color: #92400E; border: 1px solid #F59E0B; font-size: 0.65rem; font-weight: 900; padding: 1px 8px; border-radius: 999px;">
                                                    Perlu Bimbingan (${gapCount} Domain)
                                                </span>
                                            </div>
                                            <p style="color: #92400E; margin-top: 4px; font-weight: 600;">
                                                Bagi umur <strong>${not empty student ? student.studentAge : 5} tahun</strong>, sasaran standard ialah <strong>Skala ${targetScale}</strong>.
                                                Makluman ini terus dipautkan daripada data pentaksiran Oracle.
                                            </p>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert-box alert-success">
                                        <div style="padding: 4px; background: #10B981; color: #FFF; border-radius: 8px; border: 1px solid var(--border-dark);">
                                            🌟
                                        </div>
                                        <div>
                                            <strong style="color: #065F46; font-size: 0.8rem;">
                                                Tahniah! Sasaran Umur ${not empty student ? student.studentAge : 5} Tahun Tercapai:
                                            </strong>
                                            <span style="color: #047857; font-weight: 600; margin-left: 4px;">
                                                Semua 3 domain teras (Reading, Writing, Counting) memenuhi atau melebihi <strong>Skala ${targetScale}</strong>.
                                            </span>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<script>
    function toggleSeries(seriesType) {
        var poly, btn, activeClass;

        if (seriesType === 'target') {
            poly = document.getElementById('polyTarget');
            btn = document.getElementById('btnTarget');
            activeClass = 'active-target';
        } else if (seriesType === 'class') {
            poly = document.getElementById('polyClass');
            btn = document.getElementById('btnClass');
            activeClass = 'active-class';
        } else {
            poly = document.getElementById('polyStudent');
            btn = document.getElementById('btnStudent');
            activeClass = 'active-student';
        }

        if (poly && poly.style.display === 'none') {
            poly.style.display = 'block';
            btn.classList.add(activeClass);
            btn.style.opacity = '1';
        } else if (poly) {
            poly.style.display = 'none';
            btn.classList.remove(activeClass);
            btn.style.opacity = '0.4';
        }
    }
</script>
</body>
</html>