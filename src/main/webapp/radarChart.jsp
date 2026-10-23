<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Ambil nilai dinamik dari Servlet (Fallback disediakan jika null)
    String studentName = (String) request.getAttribute("studentName");
    if (studentName == null) studentName = "Ammar";

    Double scorePhonics = (Double) request.getAttribute("scorePhonics");
    Double scoreSightWords = (Double) request.getAttribute("scoreSightWords");
    Double scorePencilGrip = (Double) request.getAttribute("scorePencilGrip");
    Double scoreLetterWriting = (Double) request.getAttribute("scoreLetterWriting");
    Double scoreCounting = (Double) request.getAttribute("scoreCounting");

    if (scorePhonics == null) scorePhonics = 8.0;
    if (scoreSightWords == null) scoreSightWords = 6.0;
    if (scorePencilGrip == null) scorePencilGrip = 7.0;
    if (scoreLetterWriting == null) scoreLetterWriting = 5.0;
    if (scoreCounting == null) scoreCounting = 9.0;

    // Nama pertama murid
    String firstName = studentName.split(" ")[0];

    // Tetapan Poligon SVG (Skala 5 Paksi)
    int width = 360;
    int height = 300;
    double cx = width / 2.0;
    double cy = height / 2.0 + 8.0;
    double R = 95.0;
    int N = 5; // 5 Kompetensi

    // Nilai penanda aras (Baseline & Class Avg)
    double[] std = {5.0, 4.5, 4.0, 5.0, 6.0};
    double[] prm = {7.0, 6.5, 6.0, 7.0, 7.5};
    double[] dlx = {scorePhonics, scoreSightWords, scorePencilGrip, scoreLetterWriting, scoreCounting};

    // Fungsi pengiraan koordinat (x, y)
    StringBuilder stdPts = new StringBuilder();
    StringBuilder prmPts = new StringBuilder();
    StringBuilder dlxPts = new StringBuilder();

    double[][] stdCoords = new double[5][2];
    double[][] prmCoords = new double[5][2];
    double[][] dlxCoords = new double[5][2];

    for (int i = 0; i < N; i++) {
        double angle = -Math.PI / 2.0 + (i * 2.0 * Math.PI) / N;

        // Standard Baseline
        double rStd = (std[i] / 10.0) * R;
        stdCoords[i][0] = cx + rStd * Math.cos(angle);
        stdCoords[i][1] = cy + rStd * Math.sin(angle);
        stdPts.append(stdCoords[i][0]).append(",").append(stdCoords[i][1]).append(" ");

        // Class Avg
        double rPrm = (prm[i] / 10.0) * R;
        prmCoords[i][0] = cx + rPrm * Math.cos(angle);
        prmCoords[i][1] = cy + rPrm * Math.sin(angle);
        prmPts.append(prmCoords[i][0]).append(",").append(prmCoords[i][1]).append(" ");

        // Student Level
        double rDlx = (dlx[i] / 10.0) * R;
        dlxCoords[i][0] = cx + rDlx * Math.cos(angle);
        dlxCoords[i][1] = cy + rDlx * Math.sin(angle);
        dlxPts.append(dlxCoords[i][0]).append(",").append(dlxCoords[i][1]).append(" ");
    }

    String[] labels = {"Phonics & Sounds", "Sight & Words", "Pencil Grip", "Letter Writing", "Counting & Numbers"};
    String[] hints = {
        "Reading: Letter sounds & phonological awareness",
        "Reading: High-frequency words & print direction",
        "Writing: Dynamic tripod grip & hand coordination",
        "Writing: Name writing & lowercase stroke formation",
        "Counting: 1-to-1 touch counting & numeral matching"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Radar Chart - <%= studentName %></title>

    <!-- CSS EMBEDDED (NEOBRUTALISM STYLING) -->
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        body {
            background-color: transparent;
            margin: 0;
            padding: 4px 8px 12px 4px;
            height: 100vh;
            display: flex;
            box-sizing: border-box;
        }

        .radar-card {
            background-color: #FFFFFF;
            border-radius: 24px;
            padding: 24px;
            border: 3px solid #2D3436;
            box-shadow: 4px 4px 0px 0px #2D3436;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            position: relative;
            user-select: none;
            box-sizing: border-box;
        }

        .radar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 8px;
            border-bottom: 2px dashed #E2E8F0;
            padding-bottom: 12px;
            margin-bottom: 12px;
        }

        .radar-title-group {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.85rem;
            font-weight: 900;
            color: #2D3436;
        }

        .legend-buttons {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .legend-btn {
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 999px;
            border: 2px solid #2D3436;
            font-size: 11px;
            font-weight: 800;
            cursor: pointer;
            transition: all 0.15s ease;
            background-color: #F1F5F9;
            color: #64748B;
            opacity: 0.5;
        }

        .legend-btn.active {
            opacity: 1;
            box-shadow: 2px 2px 0px #2D3436;
        }

        .btn-std.active { background-color: #DBEAFE; color: #1E3A8A; }
        .btn-prm.active { background-color: #F3E8FF; color: #581C87; }
        .btn-dlx.active { background-color: #FEF3C7; color: #78350F; }

        .dot-icon {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            border: 1px solid #2D3436;
            display: inline-block;
        }

        .canvas-container {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 250px;
        }

        /* Hover Tooltip */
        .radar-tooltip {
            position: absolute;
            bottom: 6px;
            left: 50%;
            transform: translateX(-50%);
            background-color: #2D3436;
            color: #FFFFFF;
            font-size: 11px;
            padding: 6px 14px;
            border-radius: 999px;
            border: 2px solid #FFD02C;
            box-shadow: 3px 3px 0px rgba(0,0,0,0.3);
            pointer-events: none;
            white-space: nowrap;
            display: none;
            z-index: 20;
        }

        .radar-tooltip.show {
            display: flex;
            gap: 6px;
        }

        .tooltip-title {
            color: #FFD02C;
            font-weight: 900;
        }

        .label-text {
            font-size: 10px;
            font-weight: 800;
            fill: #2D3436;
            cursor: pointer;
            transition: fill 0.15s ease;
        }

        .label-text:hover {
            fill: #6C5CE7;
        }
    </style>
</head>
<body>

    <div class="radar-card" id="radar-chart-card">
        
        <!-- Header & Legend -->
        <div class="radar-header">
            <div class="radar-title-group">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6C5CE7" stroke-width="2.5">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
                </svg>
                <span>Reading, Writing &amp; Counting Radar</span>
            </div>

            <div class="legend-buttons">
                <button type="button" class="legend-btn btn-std active" id="btn-std" onclick="toggleSeries('std')">
                    <span class="dot-icon" style="background-color: #3B82F6;"></span>
                    <span>Baseline</span>
                </button>
                <button type="button" class="legend-btn btn-prm active" id="btn-prm" onclick="toggleSeries('prm')">
                    <span class="dot-icon" style="background-color: #6C5CE7;"></span>
                    <span>Class Avg</span>
                </button>
                <button type="button" class="legend-btn btn-dlx active" id="btn-dlx" onclick="toggleSeries('dlx')">
                    <span class="dot-icon" style="background-color: #FFD02C;"></span>
                    <span><%= firstName %></span>
                </button>
            </div>
        </div>

        <!-- Canvas SVG -->
        <div class="canvas-container">
            <svg width="100%" height="<%= height %>" viewBox="0 0 <%= width %> <%= height %>" style="overflow: visible;">
                
                <!-- Concentric Grid Polygons (Levels 2, 4, 6, 8, 10) -->
                <% 
                   int[] levels = {2, 4, 6, 8, 10};
                   for (int level : levels) {
                       StringBuilder ringPts = new StringBuilder();
                       for (int i = 0; i < N; i++) {
                           double angle = -Math.PI / 2.0 + (i * 2.0 * Math.PI) / N;
                           double rRing = (level / 10.0) * R;
                           double rx = cx + rRing * Math.cos(angle);
                           double ry = cy + rRing * Math.sin(angle);
                           ringPts.append(rx).append(",").append(ry).append(" ");
                       }
                %>
                    <polygon points="<%= ringPts.toString() %>" 
                             fill="<%= (level % 4 == 0) ? "#FAFAFA" : "none" %>" 
                             stroke="#CBD5E1" 
                             stroke-width="1.2" 
                             stroke-dasharray="<%= (level == 10) ? "none" : "3 3" %>" />
                    <text x="<%= cx + 4 %>" y="<%= cy - (level / 10.0) * R + 3 %>" font-size="8" fill="#64748B" font-weight="800"><%= level %></text>
                <% } %>

                <!-- Radial Spokes -->
                <% for (int i = 0; i < N; i++) { 
                       double angle = -Math.PI / 2.0 + (i * 2.0 * Math.PI) / N;
                       double rx = cx + R * Math.cos(angle);
                       double ry = cy + R * Math.sin(angle);
                %>
                    <line x1="<%= cx %>" y1="<%= cy %>" x2="<%= rx %>" y2="<%= ry %>" stroke="#CBD5E1" stroke-width="1.2" />
                <% } %>

                <!-- Series 1: Student Level (Yellow/Gold) -->
                <polygon id="series-dlx" points="<%= dlxPts.toString() %>" 
                         fill="rgba(255, 208, 44, 0.35)" stroke="#FF9F43" stroke-width="2.5" />

                <!-- Series 2: Class Avg (Purple) -->
                <polygon id="series-prm" points="<%= prmPts.toString() %>" 
                         fill="rgba(108, 92, 231, 0.28)" stroke="#6C5CE7" stroke-width="2.5" />

                <!-- Series 3: Baseline Standard (Blue) -->
                <polygon id="series-std" points="<%= stdPts.toString() %>" 
                         fill="rgba(59, 130, 246, 0.3)" stroke="#0984E3" stroke-width="2.5" />

                <!-- Vertices Dots -->
                <% for (int i = 0; i < N; i++) { %>
                    <g class="dots-dlx">
                        <circle cx="<%= dlxCoords[i][0] %>" cy="<%= dlxCoords[i][1] %>" r="4" fill="#FF9F43" stroke="#2D3436" stroke-width="1.5" />
                    </g>
                    <g class="dots-prm">
                        <circle cx="<%= prmCoords[i][0] %>" cy="<%= prmCoords[i][1] %>" r="4" fill="#6C5CE7" stroke="#2D3436" stroke-width="1.5" />
                    </g>
                    <g class="dots-std">
                        <circle cx="<%= stdCoords[i][0] %>" cy="<%= stdCoords[i][1] %>" r="4" fill="#0984E3" stroke="#2D3436" stroke-width="1.5" />
                    </g>
                <% } %>

                <!-- Axis Labels -->
                <% for (int i = 0; i < N; i++) { 
                       double angle = -Math.PI / 2.0 + (i * 2.0 * Math.PI) / N;
                       double labelR = R + 20;
                       double lx = cx + labelR * Math.cos(angle);
                       double ly = cy + labelR * Math.sin(angle);

                       String anchor = "middle";
                       if (i == 1 || i == 2) anchor = "start";
                       if (i == 3 || i == 4) anchor = "end";
                %>
                    <text x="<%= lx %>" y="<%= ly + 3 %>" 
                          class="label-text" 
                          text-anchor="<%= anchor %>"
                          onmouseenter="showTooltip('<%= labels[i] %>', '<%= hints[i] %>')" 
                          onmouseleave="hideTooltip()">
                        <%= labels[i] %>
                    </text>
                <% } %>

            </svg>

            <!-- Dynamic Tooltip -->
            <div id="radar-tooltip" class="radar-tooltip">
                <span class="tooltip-title" id="tt-title"></span>
                <span id="tt-hint"></span>
            </div>
        </div>

    </div>

    <!-- JAVASCRIPT FOR INTERACTIVITY -->
    <script>
        const state = { std: true, prm: true, dlx: true };

        function toggleSeries(key) {
            state[key] = !state[key];
            const btn = document.getElementById('btn-' + key);
            const poly = document.getElementById('series-' + key);
            const dots = document.querySelectorAll('.dots-' + key);

            if (state[key]) {
                btn.classList.add('active');
                if (poly) poly.style.display = 'block';
                dots.forEach(d => d.style.display = 'block');
            } else {
                btn.classList.remove('active');
                if (poly) poly.style.display = 'none';
                dots.forEach(d => d.style.display = 'none');
            }
        }

        function showTooltip(title, hint) {
            const tt = document.getElementById('radar-tooltip');
            document.getElementById('tt-title').innerText = title + ':';
            document.getElementById('tt-hint').innerText = hint;
            tt.classList.add('show');
        }

        function hideTooltip() {
            const tt = document.getElementById('radar-tooltip');
            tt.classList.remove('show');
        }
    </script>
</body>
</html>