<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    int[] readingData = (int[]) request.getAttribute("readingData");
    int[] writingData = (int[]) request.getAttribute("writingData");
    int[] countingData = (int[]) request.getAttribute("countingData");

    if (readingData == null) readingData = new int[]{15, 22, 26, 30, 32, 36, 38};
    if (writingData == null) writingData = new int[]{10, 16, 20, 24, 28, 30, 34};
    if (countingData == null) countingData = new int[]{22, 28, 32, 36, 38, 40, 40};

    String[] checkpoints = {"01", "02", "03", "04", "05", "06", "07"};

    int width = 420;
    int height = 260;
    int padLeft = 45;
    int padRight = 25;
    int padTop = 30;
    int padBottom = 40;
    int yMax = 40;
    int yMin = 0;

    class TrendUtils {
        public double getX(int index, int totalCheckpoints, int w, int pl, int pr) {
            double chartWidth = w - pl - pr;
            return pl + ((double) index / (totalCheckpoints - 1)) * chartWidth;
        }

        public double getY(int val, int h, int pt, int pb, int yMax, int yMin) {
            double chartHeight = h - pt - pb;
            double clamped = Math.max(yMin, Math.min(yMax, val));
            return h - pb - (clamped / (yMax - yMin)) * chartHeight;
        }

        public String buildPath(int[] values, int w, int h, int pl, int pr, int pt, int pb, int yM, int ym) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < values.length; i++) {
                double x = getX(i, values.length, w, pl, pr);
                double y = getY(values[i], h, pt, pb, yM, ym);
                sb.append(i == 0 ? "M " : "L ").append(x).append(" ").append(y).append(" ");
            }
            return sb.toString();
        }
    }

    TrendUtils tu = new TrendUtils();
    String readingPath = tu.buildPath(readingData, width, height, padLeft, padRight, padTop, padBottom, yMax, yMin);
    String writingPath = tu.buildPath(writingData, width, height, padLeft, padRight, padTop, padBottom, yMax, yMin);
    String countingPath = tu.buildPath(countingData, width, height, padLeft, padRight, padTop, padBottom, yMax, yMin);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trend Chart</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        body {
            background-color: transparent;
            padding: 0;
            display: flex;
            justify-content: center;
        }

        .trend-card {
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
            transition: all 0.2s ease;
        }

        .trend-card:hover {
            box-shadow: 5px 5px 0px 0px #2D3436;
        }

        .trend-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 8px;
            border-bottom: 2px dashed #F1F5F9;
            padding-bottom: 12px;
            margin-bottom: 12px;
        }

        .trend-title-group {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.85rem;
            font-weight: 900;
            color: #2D3436;
        }

        .legend-group {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 11px;
            font-weight: 800;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 4px;
            color: #4B5563;
        }

        .legend-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            border: 1.5px solid #2D3436;
            display: inline-block;
        }

        .canvas-container {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-grow: 1;
            min-height: 250px;
        }

        .data-dot {
            cursor: pointer;
            transition: transform 0.15s ease;
            transform-origin: center;
        }

        .data-dot:hover {
            transform: scale(1.6);
        }

        .trend-tooltip {
            position: absolute;
            background-color: #2D3436;
            color: #FFFFFF;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 12px;
            border: 2px solid #FFD02C;
            box-shadow: 3px 3px 0px rgba(0,0,0,0.3);
            pointer-events: none;
            white-space: nowrap;
            display: none;
            flex-direction: column;
            z-index: 20;
            transform: translate(-50%, -100%);
            margin-top: -10px;
        }

        .trend-tooltip.show {
            display: flex;
        }

        .tt-header {
            font-weight: 900;
            color: #FFD02C;
            display: flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 2px;
        }

        .tt-series {
            font-size: 10px;
            color: #D1D5DB;
            font-weight: 500;
        }

        .tt-score {
            font-weight: 700;
            color: #F3F4F6;
        }
    </style>
</head>
<body>

    <div class="trend-card">
        
        <div class="trend-header">
            <div class="trend-title-group">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10B981" stroke-width="2.5">
                    <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
                    <polyline points="17 6 23 6 23 12"></polyline>
                </svg>
                <span>Growth Trajectory Checkpoints</span>
            </div>

            <div class="legend-group">
                <div class="legend-item">
                    <span class="legend-dot" style="background-color: #6C5CE7;"></span>
                    <span>Reading</span>
                </div>
                <div class="legend-item">
                    <span class="legend-dot" style="background-color: #FF6B6B;"></span>
                    <span>Writing</span>
                </div>
                <div class="legend-item">
                    <span class="legend-dot" style="background-color: #FF9F43;"></span>
                    <span>Counting</span>
                </div>
            </div>
        </div>

        <div class="canvas-container">
            <svg width="100%" height="100%" viewBox="0 0 <%= width %> <%= height %>" preserveAspectRatio="xMidYMid meet" style="overflow: visible;">
                
                <!-- Y-Axis Grid & Labels (0, 10, 20, 30, 40) -->
                <% 
                   int[] yLabels = {0, 10, 20, 30, 40};
                   for (int val : yLabels) {
                       double y = tu.getY(val, height, padTop, padBottom, yMax, yMin);
                %>
                    <g>
                        <line x1="<%= padLeft %>" y1="<%= y %>" x2="<%= width - padRight %>" y2="<%= y %>" 
                              stroke="#E2E8F0" stroke-width="1.2" stroke-dasharray="4 4" />
                        <text x="<%= padLeft - 10 %>" y="<%= y + 3.5 %>" font-size="10" font-weight="700" 
                              fill="#64748B" text-anchor="end"><%= val %></text>
                    </g>
                <% } %>

                <!-- X-Axis Checkpoints (01 - 07) -->
                <% 
                   for (int i = 0; i < checkpoints.length; i++) {
                       double x = tu.getX(i, checkpoints.length, width, padLeft, padRight);
                %>
                    <g>
                        <rect x="<%= x - 12 %>" y="<%= height - padBottom + 8 %>" width="24" height="18" rx="4" 
                              fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
                        <text x="<%= x %>" y="<%= height - padBottom + 21 %>" font-size="10" font-weight="800" 
                              fill="#2D3436" text-anchor="middle"><%= checkpoints[i] %></text>
                    </g>
                <% } %>

                <!-- Paths -->
                <path d="<%= readingPath %>" fill="none" stroke="#6C5CE7" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                <path d="<%= writingPath %>" fill="none" stroke="#FF6B6B" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                <path d="<%= countingPath %>" fill="none" stroke="#FF9F43" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />

                <!-- Interactive Dots -->
                <% for (int i = 0; i < checkpoints.length; i++) { 
                       double xr = tu.getX(i, checkpoints.length, width, padLeft, padRight);
                       double yrReading = tu.getY(readingData[i], height, padTop, padBottom, yMax, yMin);
                       double yrWriting = tu.getY(writingData[i], height, padTop, padBottom, yMax, yMin);
                       double yrCounting = tu.getY(countingData[i], height, padTop, padBottom, yMax, yMin);
                %>
                    <circle cx="<%= xr %>" cy="<%= yrReading %>" r="3.5" fill="#6C5CE7" stroke="#2D3436" stroke-width="1.5" class="data-dot"
                            onmousemove="showTooltip(event, 'Reading & Phonics', '<%= checkpoints[i] %>', <%= readingData[i] %>)" 
                            onmouseout="hideTooltip()" />
                            
                    <circle cx="<%= xr %>" cy="<%= yrWriting %>" r="3.5" fill="#FF6B6B" stroke="#2D3436" stroke-width="1.5" class="data-dot"
                            onmousemove="showTooltip(event, 'Writing & Penmanship', '<%= checkpoints[i] %>', <%= writingData[i] %>)" 
                            onmouseout="hideTooltip()" />
                            
                    <circle cx="<%= xr %>" cy="<%= yrCounting %>" r="3.5" fill="#FF9F43" stroke="#2D3436" stroke-width="1.5" class="data-dot"
                            onmousemove="showTooltip(event, 'Counting & Numbers', '<%= checkpoints[i] %>', <%= countingData[i] %>)" 
                            onmouseout="hideTooltip()" />
                <% } %>

            </svg>

            <!-- Tooltip Container -->
            <div id="trend-tooltip" class="trend-tooltip">
                <div class="tt-header">
                    <span id="tt-cp"></span>
                    <span class="tt-series" id="tt-series"></span>
                </div>
                <div class="tt-score">Score: <span id="tt-value"></span> / 40 Points</div>
            </div>
        </div>
    </div>

    <script>
        function showTooltip(event, seriesName, checkpoint, value) {
            const tooltip = document.getElementById('trend-tooltip');
            
            document.getElementById('tt-cp').innerText = 'Checkpoint ' + checkpoint;
            document.getElementById('tt-series').innerText = '(' + seriesName + ')';
            document.getElementById('tt-value').innerText = value;

            const container = document.querySelector('.canvas-container');
            const containerRect = container.getBoundingClientRect();
            
            // Adjust for viewBox scaling if necessary, though basic clientX often works 
            // for simple embedded SVGs if pointer-events are correct.
            const relativeX = event.clientX - containerRect.left;
            const relativeY = event.clientY - containerRect.top;

            tooltip.style.left = relativeX + 'px';
            tooltip.style.top = relativeY + 'px';
            tooltip.classList.add('show');
        }

        function hideTooltip() {
            document.getElementById('trend-tooltip').classList.remove('show');
        }
    </script>
</body>
</html>