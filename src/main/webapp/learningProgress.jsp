<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.Parent"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="dao.LearningProgressDAO"%>
<%@ page import="util.DatabaseConnection"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>

<%
    // 1. Semak Role & Maklumat Parent daripada Session
    String currentRole = "Teacher";
    if (session.getAttribute("role") != null) {
        currentRole = session.getAttribute("role").toString();
    } else if (session.getAttribute("userRole") != null) {
        currentRole = session.getAttribute("userRole").toString();
    }
    boolean isParent = "Parent".equalsIgnoreCase(currentRole);

    Integer loggedParentId = null;
    String loggedUserName = (String) session.getAttribute("userName");
    Object userObj = session.getAttribute("user");

    if (userObj instanceof Parent) {
        Parent p = (Parent) userObj;
        loggedParentId = p.getParentID();
        if (loggedUserName == null) loggedUserName = p.getParentName();
    }
    if (loggedParentId == null && session.getAttribute("parentID") != null) {
        loggedParentId = Integer.parseInt(session.getAttribute("parentID").toString());
    }
    if (loggedParentId == null && session.getAttribute("parentId") != null) {
        loggedParentId = Integer.parseInt(session.getAttribute("parentId").toString());
    }

    // Semak parameter studentId dari URL jika user tukar dropdown
    int reqStudentId = -1;
    String paramSid = request.getParameter("studentId");
    if (paramSid == null || paramSid.isEmpty()) paramSid = request.getParameter("studentID");
    if (paramSid != null && !paramSid.isEmpty()) {
        try { reqStudentId = Integer.parseInt(paramSid); } catch (Exception ignored) {}
    }

    Student activeStudent = null;
    List<Student> dropdownStudents = new ArrayList<>();

    // 2. Tarik data terus dari Oracle DB supaya tidak tersangkut pada default #301
    try (Connection conn = DatabaseConnection.getConnection()) {
        if (conn != null) {
            // Jika Parent login tapi parentID belum ada, cari melalui nama dalam jadual PARENT
            if (isParent && loggedParentId == null && loggedUserName != null) {
                try (PreparedStatement psP = conn.prepareStatement(
                        "SELECT parentID FROM PARENT WHERE LOWER(parentName) LIKE LOWER(?)")) {
                    psP.setString(1, "%" + loggedUserName.trim() + "%");
                    try (ResultSet rsP = psP.executeQuery()) {
                        if (rsP.next()) {
                            loggedParentId = rsP.getInt("parentID");
                        }
                    }
                }
            }

            String sql = (isParent && loggedParentId != null)
                    ? "SELECT * FROM STUDENT WHERE parentID = ? ORDER BY studentID ASC"
                    : "SELECT * FROM STUDENT ORDER BY studentID ASC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (isParent && loggedParentId != null) {
                    ps.setInt(1, loggedParentId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    ResultSetMetaData meta = rs.getMetaData();
                    Set<String> cols = new HashSet<>();
                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        cols.add(meta.getColumnName(i).toUpperCase());
                    }

                    while (rs.next()) {
                        Student st = new Student();
                        st.setStudentID(rs.getInt("STUDENTID"));
                        st.setStudentName(rs.getString("STUDENTNAME"));
                        if (cols.contains("STUDENTAGE")) {
                            st.setStudentAge(rs.getInt("STUDENTAGE"));
                        }
                        if (cols.contains("STUDENTCLASS") && rs.getString("STUDENTCLASS") != null) {
                            st.setStudentClass(rs.getString("STUDENTCLASS"));
                        } else {
                            st.setStudentClass("Kindergarten 3B");
                        }
                        dropdownStudents.add(st);
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Pilih murid yang diminta atau murid pertama dalam senarai (Lily)
    if (!dropdownStudents.isEmpty()) {
        if (reqStudentId != -1) {
            for (Student st : dropdownStudents) {
                if (st.getStudentID() == reqStudentId) {
                    activeStudent = st;
                    break;
                }
            }
        }
        if (activeStudent == null) {
            activeStudent = dropdownStudents.get(0);
        }
    }

    // Fallback terakhir hanya jika jadual STUDENT betul-betul kosong
    if (activeStudent == null) {
        activeStudent = new Student();
        activeStudent.setStudentID(301);
        activeStudent.setStudentName("Leo Vance");
        activeStudent.setStudentAge(5);
        activeStudent.setStudentClass("Kindergarten 3B");
        dropdownStudents.add(activeStudent);
    }
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Progress Manager - Keedsflix Centre</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    
    <style>
        * { box-sizing: border-box; }
        body, html {
            margin: 0; padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #FAF5EF;
            color: #2D3436;
        }

        .app-layout { display: flex; min-height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; background: #FAF5EF; }
        .app-header-wrapper { flex-shrink: 0; background: #FFFFFF; border-bottom: 3px solid #2D3436; }
        .app-content-body { flex-grow: 1; padding: 28px 36px; overflow-y: auto; }

        .nb-container { max-width: 1150px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        
        .nb-card {
            background-color: #FFFFFF;
            border: 3px solid #2D3436;
            border-radius: 28px;
            padding: 24px 28px;
            box-shadow: 4px 4px 0px 0px #2D3436;
        }

        .nb-label {
            display: block;
            font-weight: 900;
            font-size: 0.95rem;
            color: #2D3436;
            margin-bottom: 8px;
        }
        .nb-select {
            width: 100%;
            padding: 12px 20px;
            border: 2.5px solid #2D3436;
            border-radius: 999px;
            background-color: #FFFFFF;
            font-weight: 800;
            font-size: 0.95rem;
            color: #2D3436;
            box-shadow: 2px 2px 0px 0px #2D3436;
            cursor: pointer;
            outline: none;
            appearance: none;
            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%232D3436' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 20px center;
        }

        .nb-btn {
            background-color: #FFFFFF;
            border: 2px solid #2D3436;
            border-radius: 999px;
            padding: 9px 20px;
            font-weight: 900;
            font-size: 0.85rem;
            color: #2D3436;
            cursor: pointer;
            box-shadow: 2.5px 2.5px 0px 0px #2D3436;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        .nb-btn-yellow { background-color: #FFD02C; }
        .nb-btn-danger { background-color: #FFFFFF; color: #EF4444; }

        .nb-badge-yellow {
            background: #FFD02C; border: 1.5px solid #2D3436;
            padding: 3px 10px; border-radius: 999px;
            font-size: 10px; font-weight: 900; text-transform: uppercase;
        }
        .nb-badge-pink {
            background: #FFB3C6; border: 1.5px solid #2D3436;
            padding: 3px 10px; border-radius: 999px;
            font-size: 10px; font-weight: 900; text-transform: uppercase;
        }
        .nb-badge-mint {
            background: #D1FAE5; color: #065F46; border: 1.5px solid #10B981;
            padding: 3px 12px; border-radius: 999px; font-size: 11px; font-weight: 900;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .nb-badge-gray {
            background: #F1F5F9; color: #475569; border: 1.5px solid #94A3B8;
            padding: 3px 12px; border-radius: 999px; font-size: 11px; font-weight: 900;
            display: inline-flex; align-items: center; gap: 4px;
        }

        .domain-pill {
            font-size: 11px; font-weight: 900; padding: 4px 10px; border-radius: 8px;
            display: inline-flex; align-items: center; gap: 5px;
        }

        .nb-table-card {
            border: 2.5px solid #2D3436; border-radius: 20px; overflow: hidden;
            box-shadow: 3px 3px 0px 0px #2D3436; background: #FFFFFF;
        }
        .nb-table { width: 100%; border-collapse: collapse; text-align: left; }
        .nb-table th {
            background-color: #2D3436; color: #FFFFFF; padding: 14px 18px;
            font-weight: 900; font-size: 0.85rem;
        }
        .nb-table td { padding: 16px 18px; border-bottom: 2px solid #E2E8F0; border-right: 1.5px solid #E2E8F0; }
        
        .table-section-banner {
            background-color: #D1FAE5; border-top: 2px solid #2D3436; border-bottom: 2px solid #2D3436;
            padding: 10px 18px; font-weight: 900; font-size: 0.82rem; color: #065F46;
            display: flex; justify-content: space-between; align-items: center;
        }
        .table-section-banner-gray { background-color: #F1F5F9; color: #334155; }
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

                <!-- CARD 1: CLASS & STUDENT NAME SELECTORS (PURE JAVA LOOP) -->
                <div class="nb-card">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px;">
                        <div>
                            <label class="nb-label">Class</label>
                            <select class="nb-select" disabled>
                                <option><%= activeStudent.getStudentClass() != null ? activeStudent.getStudentClass() : "Kindergarten 3B" %></option>
                            </select>
                        </div>
                        <div>
                            <label class="nb-label">Student Name</label>
                            <select class="nb-select" onchange="location.href='<%= request.getContextPath() %>/learningProgress.jsp?studentId=' + this.value">
                                <% for (Student s : dropdownStudents) { %>
                                    <option value="<%= s.getStudentID() %>" <%= (s.getStudentID() == activeStudent.getStudentID()) ? "selected" : "" %>>
                                        <%= s.getStudentName() %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- CARD 2: CONSOLE HEADER -->
                <div class="nb-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                            <% if (isParent) { %>
                                <span class="nb-badge-pink">PARENT PROGRESS PORTAL</span>
                            <% } else { %>
                                <span class="nb-badge-yellow">TEACHER ASSESSMENT CONSOLE</span>
                            <% } %>
                            <span style="font-size: 0.8rem; font-weight: 700; color: #64748B;">
                                Class: <%= activeStudent.getStudentClass() %> · Student ID: #<%= activeStudent.getStudentID() %>
                            </span>
                        </div>
                        <h2 style="margin: 0; font-size: 1.8rem; font-weight: 900; letter-spacing: -0.5px;">
                            Learning Progress: <%= activeStudent.getStudentName() %>
                        </h2>
                        <p style="margin: 6px 0 0 0; color: #64748B; font-size: 0.88rem; font-weight: 600; max-width: 650px;">
                            <% if (isParent) { %>
                                Track your child's reading, writing, and early counting developmental milestones and educator observations.
                            <% } else { %>
                                Evaluate reading, writing, and early counting milestones in real time. Log observations, calibrate domain benchmarks, and generate progress reports.
                            <% } %>
                        </p>
                    </div>
                </div>

                <!-- CARD 3: PROGRESS REPORT TABLE -->
                <div class="nb-card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; flex-wrap: wrap; gap: 12px;">
                        <div>
                            <h3 style="margin: 0; font-size: 1.4rem; font-weight: 900;">Progress Report</h3>
                            <p style="margin: 2px 0 0 0; color: #64748B; font-size: 0.82rem; font-weight: 600;">
                                Viewing record(s) for <%= activeStudent.getStudentName() %>
                            </p>
                        </div>
                    </div>

                    <div class="nb-table-card">
                        <div class="table-section-banner">
                            <span style="display: inline-flex; align-items: center; gap: 6px;">
                                <%= IconUtil.icon("Sparkles", "icon-sm") %> REKOD TERKINI (CURRENT RECORD)
                            </span>
                            <span class="nb-badge-mint" style="font-size: 10px;">Tarikh Aktif: 2026-10-31</span>
                        </div>

                        <table class="nb-table">
                            <thead>
                                <tr>
                                    <th style="width: 20%;">Date</th>
                                    <th style="width: 62%;">Content</th>
                                    <th style="width: 18%; text-align: center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td style="vertical-align: top; text-align: center;">
                                        <div style="font-weight: 900; font-size: 1rem; color: #2D3436;">2026-10-31</div>
                                        <div style="font-size: 0.78rem; font-weight: 700; color: #64748B; margin-top: 2px;">31 Oktober 2026</div>
                                        <div style="margin-top: 8px;">
                                            <span class="nb-badge-mint" style="font-size: 9px; padding: 2px 8px;">
                                                <%= IconUtil.icon("Star", "icon-xs") %> CURRENT RECORD
                                            </span>
                                        </div>
                                    </td>
                                    <td style="vertical-align: top;">
                                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 8px;">
                                            <span class="domain-pill" style="background: #FEF3C7; color: #92400E; border: 1px solid #FCD34D;">
                                                <%= IconUtil.icon("BarChart3", "icon-xs") %> Counting (Skala 4/5 · 88%)
                                            </span>
                                            <span class="domain-pill" style="background: #FFE4E6; color: #BE185D; border: 1px solid #FDA4AF;">
                                                <%= IconUtil.icon("PenTool", "icon-xs") %> Writing (Skala 3/5 · 68%)
                                            </span>
                                            <span class="domain-pill" style="background: #F3E8FF; color: #7E22CE; border: 1px solid #D8B4FE;">
                                                <%= IconUtil.icon("BookOpen", "icon-xs") %> Reading (Skala 3/5 · 68%)
                                            </span>
                                        </div>
                                        <p style="margin: 6px 0; font-size: 0.83rem; color: #1E293B; font-weight: 700;">
                                            <strong>Fokus & Topik:</strong> Pengecaman Nombor & Pembilangan Objek (1-30) · Kawalan Motor Halus · Penguasaan Fonik
                                        </p>
                                    </td>
                                    <td style="vertical-align: top; text-align: center;">
                                        <div style="display: flex; flex-direction: column; gap: 8px;">
                                            <button type="button" class="nb-btn nb-btn-yellow" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                <%= IconUtil.icon("Eye", "icon-xs") %> Buka Laporan
                                            </button>
                                            <% if (!isParent) { %>
                                                <button type="button" class="nb-btn" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                    <%= IconUtil.icon("Edit2", "icon-xs") %> Edit
                                                </button>
                                                <button type="button" class="nb-btn nb-btn-danger" style="width: 100%; font-size: 0.78rem; padding: 6px 12px;">
                                                    <%= IconUtil.icon("Trash2", "icon-xs") %> Padam
                                                </button>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <% if (!isParent) { %>
                        <div style="display: flex; justify-content: flex-end; margin-top: 16px;">
                            <a href="<%= request.getContextPath() %>/createProgress.jsp?studentId=<%= activeStudent.getStudentID() %>" 
                               class="nb-btn nb-btn-yellow" 
                               style="padding: 10px 24px; font-size: 0.9rem;">
                                <%= IconUtil.icon("Plus", "icon-sm") %>
                                <span>Create Progress</span>
                            </a>
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
    </main>
</div>

<jsp:include page="icons.jsp" />
</body>
</html>