<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.IconUtil"%>

<!-- Pustaka Lucide Vanilla JS (Ringan & Tidak Perlukan React) -->
<script src="https://unpkg.com/lucide@latest"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        if (typeof lucide !== "undefined") {
            lucide.createIcons();
        }
    });
</script>

<%-- Bahagian paparan galeri hanya dipaparkan jika fail icons.jsp dibuka terus di pelayar --%>
<% if (request.getRequestURI().endsWith("icons.jsp")) { %>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <title>Keedflix Neobrutalism Icon Library</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <style>
        body {
            background-color: #FAF5EF;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            color: #2D3436;
            padding: 28px;
        }
        .nb-container {
            max-width: 1200px;
            margin: 0 auto;
            background: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 24px;
            box-shadow: 4px 4px 0px 0px #2D3436;
            overflow: hidden;
        }
        .nb-header {
            background: #FFD166;
            border-bottom: 3px solid #2D3436;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .icon-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
            gap: 14px;
            padding: 24px;
        }
        .icon-card {
            background: #FFFDF9;
            border: 2px solid #2D3436;
            border-radius: 16px;
            padding: 14px 10px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            box-shadow: 2px 2px 0px 0px #2D3436;
            text-align: center;
        }
        .icon-card code {
            font-size: 0.72rem;
            font-weight: 800;
            background: #F3E8FF;
            color: #6D28D9;
            padding: 3px 8px;
            border-radius: 8px;
            border: 1px solid #C4B5FD;
        }
    </style>
</head>
<body>
    <div class="nb-container">
        <div class="nb-header">
            <div style="display: flex; align-items: center; gap: 12px;">
                <%= IconUtil.box("Sparkles", "", "icon-md") %>
                <div>
                    <h2 style="font-size: 1.2rem; font-weight: 900;">Keedflix Neobrutalism Icon Set</h2>
                    <p style="font-size: 0.78rem; font-weight: 700;">93 Lucide Icons sedia digunakan dalam fail .jsp</p>
                </div>
            </div>
            <span style="background: #FFFFFF; border: 2px solid #2D3436; padding: 6px 14px; border-radius: 999px; font-size: 0.75rem; font-weight: 900;">
                JSP + CSS + Java
            </span>
        </div>

        <div class="icon-grid">
            <% for (String iconName : IconUtil.ALL_ICONS) { %>
                <div class="icon-card">
                    <span class="nb-icon-box nb-bg-cream">
                        <i data-lucide="<%= iconName %>" class="icon-md"></i>
                    </span>
                    <code><%= iconName %></code>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
<% } %>