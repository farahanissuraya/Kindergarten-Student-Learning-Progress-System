<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>

<%
    Student radarStudent = (Student) request.getAttribute("student");
    if (radarStudent == null) {
        radarStudent = (Student) request.getAttribute("currentStudent");
    }

    String errorMessage = (String) request.getAttribute("errorMessage");

    Integer readingScaleObj = (Integer) request.getAttribute("readingScale");
    Integer writingScaleObj = (Integer) request.getAttribute("writingScale");
    Integer countingScaleObj = (Integer) request.getAttribute("countingScale");
    Integer targetScaleObj = (Integer) request.getAttribute("targetScale");

    Double classReadingObj = (Double) request.getAttribute("classReadingRadar");
    Double classWritingObj = (Double) request.getAttribute("classWritingRadar");
    Double classCountingObj = (Double) request.getAttribute("classCountingRadar");

    int readingScale = (readingScaleObj != null && readingScaleObj > 0) ? readingScaleObj : 3;
    int writingScale = (writingScaleObj != null && writingScaleObj > 0) ? writingScaleObj : 3;
    int countingScale = (countingScaleObj != null && countingScaleObj > 0) ? countingScaleObj : 4;
    int targetScale = (targetScaleObj != null && targetScaleObj > 0) ? targetScaleObj : 4;

    double classReading = (classReadingObj != null && classReadingObj > 0) ? classReadingObj : 7.2;
    double classWriting = (classWritingObj != null && classWritingObj > 0) ? classWritingObj : 6.4;
    double classCounting = (classCountingObj != null && classCountingObj > 0) ? classCountingObj : 7.6;

    int studentAge = (radarStudent != null && radarStudent.getStudentAge() != null && radarStudent.getStudentAge() > 0)
            ? radarStudent.getStudentAge() : 5;
    String studentName = (radarStudent != null && radarStudent.getStudentName() != null)
            ? radarStudent.getStudentName() : "Lily";

    List<String> gapDomains = new ArrayList<>();
    if (readingScale < targetScale) gapDomains.add("Reading (Skala " + readingScale + "/5)");
    if (writingScale < targetScale) gapDomains.add("Writing (Skala " + writingScale + "/5)");
    if (countingScale < targetScale) gapDomains.add("Counting (Skala " + countingScale + "/5)");

    boolean hasGap = !gapDomains.isEmpty();
    int gapCount = gapDomains.size();

    // Koordinat Segitiga Radar
    double cx = 210.0, cy = 165.0, R = 115.0;

    double rValReading = readingScale * 2.0;
    double rValWriting = writingScale * 2.0;
    double rValCounting = countingScale * 2.0;
    double rValTarget = targetScale * 2.0;

    double a0 = -Math.PI / 2.0;
    double a1 = a0 + (2.0 * Math.PI / 3.0);
    double a2 = a1 + (2.0 * Math.PI / 3.0);

    double xT0 = cx + (rValTarget / 10.0) * R * Math.cos(a0), yT0 = cy + (rValTarget / 10.0) * R * Math.sin(a0);
    double xT1 = cx + (rValTarget / 10.0) * R * Math.cos(a1), yT1 = cy + (rValTarget / 10.0) * R * Math.sin(a1);
    double xT2 = cx + (rValTarget / 10.0) * R * Math.cos(a2), yT2 = cy + (rValTarget / 10.0) * R * Math.sin(a2);

    double xC0 = cx + (classReading / 10.0) * R * Math.cos(a0), yC0 = cy + (classReading / 10.0) * R * Math.sin(a0);
    double xC1 = cx + (classWriting / 10.0) * R * Math.cos(a1), yC1 = cy + (classWriting / 10.0) * R * Math.sin(a1);
    double xC2 = cx + (classCounting / 10.0) * R * Math.cos(a2), yC2 = cy + (classCounting / 10.0) * R * Math.sin(a2);

    double xS0 = cx + (rValReading / 10.0) * R * Math.cos(a0), yS0 = cy + (rValReading / 10.0) * R * Math.sin(a0);
    double xS1 = cx + (rValWriting / 10.0) * R * Math.cos(a1), yS1 = cy + (rValWriting / 10.0) * R * Math.sin(a1);
    double xS2 = cx + (rValCounting / 10.0) * R * Math.cos(a2), yS2 = cy + (rValCounting / 10.0) * R * Math.sin(a2);

    String targetPts = String.format(java.util.Locale.US, "%.1f,%.1f %.1f,%.1f %.1f,%.1f", xT0, yT0, xT1, yT1, xT2, yT2);
    String classPts = String.format(java.util.Locale.US, "%.1f,%.1f %.1f,%.1f %.1f,%.1f", xC0, yC0, xC1, yC1, xC2, yC2);
    String studentPts = String.format(java.util.Locale.US, "%.1f,%.1f %.1f,%.1f %.1f,%.1f", xS0, yS0, xS1, yS1, xS2, yS2);
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/radarChart.css">
</head>
<body>

<div class="nb-radar-card" id="radar-chart-card">

    <!-- LEGEND HEADER -->
    <div style="display: flex; flex-direction: column; gap: 8px; border-bottom: 1.5px solid #F1F5F9; padding-bottom: 10px;">
        <div style="display: flex; align-items: center; gap: 8px;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6C5CE7" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
            </svg>
            <span style="font-weight: 900; font-size: 0.95rem; color: #2D3436;">
                Radar Penguasaan 3 Teras: Reading, Writing &amp; Counting
            </span>
        </div>

        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
            <button type="button" id="btnTarget" class="series-btn active-target" onclick="toggleSeries('target')">
                <span class="series-dot" style="background-color: #10B981;"></span>
                <span>Sasaran Umur <%= studentAge %>th (Skala <%= targetScale %>)</span>
            </button>

            <button type="button" id="btnClass" class="series-btn active-class" onclick="toggleSeries('class')">
                <span class="series-dot" style="background-color: #7C3AED;"></span>
                <span>Purata Kelas</span>
            </button>

            <button type="button" id="btnStudent" class="series-btn active-student" onclick="toggleSeries('student')">
                <span class="series-dot" style="background-color: #FF9F43;"></span>
                <span><%= studentName %> (Direkod)</span>
            </button>
        </div>
    </div>

    <!-- SVG RADAR CANVAS -->
    <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 100%; flex-grow: 1;">
        <svg viewBox="0 0 420 265" style="width: 100%; max-width: 440px; height: auto; overflow: visible;">
            
            <% for (int lvl = 2; lvl <= 10; lvl += 2) {
                double rL = (lvl / 10.0) * R;
                String rPts = String.format(java.util.Locale.US, "%.1f,%.1f %.1f,%.1f %.1f,%.1f",
                        cx + rL * Math.cos(a0), cy + rL * Math.sin(a0),
                        cx + rL * Math.cos(a1), cy + rL * Math.sin(a1),
                        cx + rL * Math.cos(a2), cy + rL * Math.sin(a2));
            %>
                <g>
                    <polygon points="<%= rPts %>" fill="<%= (lvl % 4 == 0) ? "#FAFAFA" : "none" %>" stroke="#CBD5E1" stroke-width="1.3" stroke-dasharray="<%= (lvl == 10) ? "none" : "3 3" %>" />
                    <text x="<%= cx + 6 %>" y="<%= cy - rL + 3 %>" font-size="9" fill="#64748B" font-weight="800">
                        Skala <%= lvl / 2 %>
                    </text>
                </g>
            <% } %>

            <!-- Radial Spokes -->
            <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a0) %>" y2="<%= cy + R * Math.sin(a0) %>" stroke="#CBD5E1" stroke-width="1.5" />
            <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a1) %>" y2="<%= cy + R * Math.sin(a1) %>" stroke="#CBD5E1" stroke-width="1.5" />
            <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= cx + R * Math.cos(a2) %>" y2="<%= cy + R * Math.sin(a2) %>" stroke="#CBD5E1" stroke-width="1.5" />

            <!-- POLYGONS -->
            <polygon id="polyStudent" points="<%= studentPts %>" fill="rgba(255, 159, 67, 0.42)" stroke="#FF9F43" stroke-width="3" />
            <polygon id="polyClass" points="<%= classPts %>" fill="rgba(108, 92, 231, 0.16)" stroke="#6C5CE7" stroke-width="2.4" />
            <polygon id="polyTarget" points="<%= targetPts %>" fill="rgba(9, 132, 227, 0.10)" stroke="#0984E3" stroke-width="2.4" stroke-dasharray="4 3" />

            <!-- VERTICES DOTS -->
            <circle class="vertex-dot" cx="<%= xS0 %>" cy="<%= yS0 %>" r="5.5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />
            <circle class="vertex-dot" cx="<%= xS1 %>" cy="<%= yS1 %>" r="5.5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />
            <circle class="vertex-dot" cx="<%= xS2 %>" cy="<%= yS2 %>" r="5.5" fill="#FF9F43" stroke="#2D3436" stroke-width="2" />

            <!-- DOMAIN LABELS -->
            <g>
                <text x="<%= cx %>" y="<%= cy - R - 20 %>" font-size="12" font-weight="900" fill="#4F46E5" text-anchor="middle">1. Reading</text>
                <text x="<%= cx %>" y="<%= cy - R - 7 %>" font-size="10" font-weight="800" fill="<%= readingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="middle">
                    Skala <%= readingScale %>/5 (<%= readingScale * 20 %>%)
                </text>
            </g>
            <g>
                <text x="<%= cx + (R + 18) * Math.cos(a1) %>" y="<%= cy + (R + 18) * Math.sin(a1) + 4 %>" font-size="12" font-weight="900" fill="#2D3436" text-anchor="start">2. Writing</text>
                <text x="<%= cx + (R + 18) * Math.cos(a1) %>" y="<%= cy + (R + 18) * Math.sin(a1) + 17 %>" font-size="10" font-weight="800" fill="<%= writingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="start">
                    Skala <%= writingScale %>/5 (<%= writingScale * 20 %>%)
                </text>
            </g>
            <g>
                <text x="<%= cx + (R + 18) * Math.cos(a2) %>" y="<%= cy + (R + 18) * Math.sin(a2) + 4 %>" font-size="12" font-weight="900" fill="#2D3436" text-anchor="end">3. Counting</text>
                <text x="<%= cx + (R + 18) * Math.cos(a2) %>" y="<%= cy + (R + 18) * Math.sin(a2) + 17 %>" font-size="10" font-weight="800" fill="<%= countingScale >= targetScale ? "#059669" : "#DC2626" %>" text-anchor="end">
                    Skala <%= countingScale %>/5 (<%= countingScale * 20 %>%)
                </text>
            </g>
        </svg>
    </div>

    <!-- DEVELOPMENTAL GAP ALERT BAR -->
    <div>
        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="alert-box alert-warning">
                <div><strong>Status Database:</strong> <%= errorMessage %></div>
            </div>
        <% } else if (hasGap) { %>
            <div class="alert-box alert-warning">
                <div style="width: 32px; height: 32px; background: #FFD02C; border-radius: 10px; border: 2px solid #2D3436; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px;">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#2D3436" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                        <line x1="12" y1="9" x2="12" y2="13"></line>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                </div>
                <div>
                    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                        <strong style="color: #78350F; font-size: 0.76rem; text-transform: uppercase;">
                            ALERT SASARAN UMUR <%= studentAge %> TAHUN
                        </strong>
                        <span style="background: #FDE68A; color: #92400E; border: 1px solid #F59E0B; font-size: 0.65rem; font-weight: 900; padding: 1px 8px; border-radius: 999px;">
                            Perlu Bimbingan (<%= gapCount %> Domain)
                        </span>
                    </div>
                    <p style="color: #92400E; margin-top: 3px; font-weight: 600;">
                        Bagi umur <strong><%= studentAge %> tahun</strong>, sasaran standard ialah <strong>Skala <%= targetScale %> (Skala <%= targetScale %>: Mahir (Proficient))</strong>.
                        Domain di bawah sasaran: <strong style="text-decoration: underline;"><%= String.join(", ", gapDomains) %></strong>. Makluman aktif telah diselaraskan untuk tindakan bersama guru &amp; ibu bapa.
                    </p>
                </div>
            </div>
        <% } else { %>
            <div class="alert-box alert-success">
                <div style="width: 32px; height: 32px; background: #34D399; border-radius: 10px; border: 2px solid #2D3436; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#2D3436" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
                <div>
                    <strong style="color: #065F46; font-size: 0.78rem;">
                        Tahniah! Sasaran Umur <%= studentAge %> Tahun Tercapai:
                    </strong>
                    <span style="color: #047857; font-weight: 600; margin-left: 4px;">
                        Semua 3 domain teras (Reading, Writing, Counting) memenuhi atau melebihi <strong>Skala <%= targetScale %></strong>.
                    </span>
                </div>
            </div>
        <% } %>
    </div>

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