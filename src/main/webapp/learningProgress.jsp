<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.Parent"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="dao.LearningProgressDAO"%>
<%@ page import="util.DatabaseConnection"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.time.*"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.time.temporal.TemporalAdjusters"%>

<%
    // 1. Semak Role & Maklumat Parent daripada Session
    String currentRole = "Teacher";
    if (session.getAttribute("role") != null) {
        currentRole = session.getAttribute("role").toString();
    } else if (session.getAttribute("userRole") != null) {
        currentRole = session.getAttribute("userRole").toString();
    }
    boolean isParent = "Parent".equalsIgnoreCase(currentRole);
    boolean isAdmin = "Admin".equalsIgnoreCase(currentRole);
    boolean isTeacher = !isParent && !isAdmin;

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

    // 2. Tarik senarai murid terus dari Oracle DB
    try (Connection conn = DatabaseConnection.getConnection()) {
        if (conn != null) {
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

    if (activeStudent == null) {
        activeStudent = new Student();
        activeStudent.setStudentID(301);
        activeStudent.setStudentName("Leo Vance");
        activeStudent.setStudentAge(5);
        activeStudent.setStudentClass("Kindergarten 3B");
        dropdownStudents.add(activeStudent);
    }

    // 3. Tarik rekod pentaksiran sebenar dari Oracle dan himpunkan mengikut tarikh
    LearningProgressDAO lpDao = new LearningProgressDAO();
    List<LearningProgress> studentProgressList = new ArrayList<>();
    try {
        studentProgressList = lpDao.getProgressByStudentId(activeStudent.getStudentID());
    } catch (Exception e) {
        e.printStackTrace();
    }

    Map<String, List<LearningProgress>> groupedReports = new LinkedHashMap<>();
    for (LearningProgress lp : studentProgressList) {
        String dKey = (lp.getProgressDate() != null && !lp.getProgressDate().trim().isEmpty())
                      ? lp.getProgressDate().trim() : "Tanpa Tarikh";
        if (dKey.length() > 10 && (dKey.charAt(10) == ' ' || dKey.charAt(10) == 'T')) {
            dKey = dKey.substring(0, 10);
        }
        groupedReports.computeIfAbsent(dKey, k -> new ArrayList<>()).add(lp);
    }

    List<String> allDates = new ArrayList<>(groupedReports.keySet());

    // 4. Semak sama ada minggu semasa (Isnin - Ahad) sudah mempunyai rekod pentaksiran
    String[] malayMonths = {"Januari", "Februari", "Mac", "April", "Mei", "Jun",
                            "Julai", "Ogos", "September", "Oktober", "November", "Disember"};
    String[] malayDays = {"", "Isnin", "Selasa", "Rabu", "Khamis", "Jumaat", "Sabtu", "Ahad"};
    DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
    DateTimeFormatter[] supportedParsers = new DateTimeFormatter[] {
        DateTimeFormatter.ofPattern("yyyy-MM-dd"),
        DateTimeFormatter.ofPattern("dd-MM-yyyy"),
        DateTimeFormatter.ofPattern("dd/MM/yyyy"),
        DateTimeFormatter.ofPattern("yyyy/MM/dd")
    };

    LocalDate today = LocalDate.now();
    LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    LocalDate weekEnd   = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

    String weekRangeMalay = weekStart.getDayOfMonth() + " " + malayMonths[weekStart.getMonthValue() - 1] + " " + weekStart.getYear()
                          + " – "
                          + weekEnd.getDayOfMonth() + " " + malayMonths[weekEnd.getMonthValue() - 1] + " " + weekEnd.getYear();

    String weeklyExistingDate = null;     // Nilai asal untuk parameter URL reportDate
    String weeklyExistingDisplay = "";    // Format paparan Malaysia: dd-MM-yyyy
    String weeklyExistingMalay = "";
    String weeklyExistingDay = "";

    for (String dStr : allDates) {
        if (dStr == null) continue;
        String cleanDate = dStr.trim();
        if (cleanDate.length() > 10 && (cleanDate.charAt(10) == ' ' || cleanDate.charAt(10) == 'T')) {
            cleanDate = cleanDate.substring(0, 10);
        }

        LocalDate parsed = null;
        for (DateTimeFormatter fmt : supportedParsers) {
            try {
                parsed = LocalDate.parse(cleanDate, fmt);
                break;
            } catch (Exception ignored) {}
        }

        if (parsed != null && !parsed.isBefore(weekStart) && !parsed.isAfter(weekEnd)) {
            weeklyExistingDate = cleanDate;
            weeklyExistingDisplay = parsed.format(dmyFormatter);
            weeklyExistingMalay = parsed.getDayOfMonth() + " " + malayMonths[parsed.getMonthValue() - 1] + " " + parsed.getYear();
            weeklyExistingDay = malayDays[parsed.getDayOfWeek().getValue()];
            break;
        }
    }
    boolean hasWeeklyRecord = (weeklyExistingDate != null);
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Progress Manager - Keedsflix Centre</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/learningProgress.css?v=2">
</head>
<body>

<div class="app-layout">
    <aside class="app-sidebar-wrapper">
        <% request.setAttribute("activeTab", "progress"); %>
        <jsp:include page="sidebar.jsp" />
    </aside>

    <main class="app-main-wrapper">
        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <div class="app-content-body">
            <div class="nb-container">

                <!-- CARD 2: INTERACTIVE CONSOLE HEADER WITH DROPDOWN -->
                <div class="lp-banner-wrapper" id="lpBannerWrapper">
                    <button type="button" class="lp-banner-btn" onclick="toggleLpDropdown()">
                        <div>
                            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px; flex-wrap: wrap;">
                                <% if (isParent) { %>
                                    <span class="nb-badge-pink">PARENT PROGRESS PORTAL</span>
                                <% } else if (isAdmin) { %>
                                    <span class="nb-badge-blue">ADMIN ASSESSMENT CONSOLE</span>
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
                                <% } else if (isAdmin) { %>
                                    Review and manage kindergarten student learning progress logs and official developmental assessment reports.
                                <% } else { %>
                                    Evaluate reading, writing, and early counting milestones in real time. Log observations, calibrate domain benchmarks, and generate progress reports.
                                <% } %>
                            </p>
                        </div>

                        <div class="lp-chevron-circle" title="<%= isParent ? "Pilih anak berdaftar" : "Pilih murid" %>">
                            <%= IconUtil.icon("ChevronDown", "icon-md") %>
                        </div>
                    </button>

                    <!-- DROPDOWN SENARAI ANAK / MURID -->
                    <div class="lp-dropdown-menu" id="lpDropdownMenu">
                        <p style="font-size: 11px; font-weight: 900; color: #64748B; text-transform: uppercase; letter-spacing: 0.04em; margin: 0 0 12px 4px;">
                            <%= isParent ? "PILIH ANAK BERDAFTAR" : "PILIH MURID" %> (<%= dropdownStudents.size() %>)
                        </p>

                        <% for (Student st : dropdownStudents) { 
                            boolean isSelected = (st.getStudentID() == activeStudent.getStudentID());
                        %>
                            <a href="?studentId=<%= st.getStudentID() %>" 
                               class="lp-child-option <%= isSelected ? "active" : "" %>">
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <span style="width: 38px; height: 38px; border-radius: 50%; background-color: <%= isSelected ? "#FFD02C" : "#FAF5EF" %>; border: 2px solid #2D3436; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                        <%= IconUtil.icon("User", "icon-sm") %>
                                    </span>
                                    <div>
                                        <div style="font-size: 15px; font-weight: 900; color: #2D3436;">
                                            <%= st.getStudentName() %>
                                        </div>
                                        <div style="font-size: 12px; font-weight: 600; color: #64748B;">
                                            <%= st.getStudentClass() %> · Umur: <%= st.getStudentAge() %> tahun · ID: #<%= st.getStudentID() %>
                                        </div>
                                    </div>
                                </div>

                                <% if (isSelected) { %>
                                    <span style="width: 14px; height: 14px; border-radius: 50%; background-color: #2D3436; display: inline-block; flex-shrink: 0;"></span>
                                <% } %>
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- CARD 3: PROGRESS REPORT TABLE (CURRENT + STACKED PREVIOUS RECORDS) -->
                <div class="nb-card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; flex-wrap: wrap; gap: 12px;">
                        <div>
                            <h3 style="margin: 0; font-size: 1.4rem; font-weight: 900;">Progress Report</h3>
                            <p style="margin: 2px 0 0 0; color: #64748B; font-size: 0.82rem; font-weight: 600;">
                                Viewing record(s) for <%= activeStudent.getStudentName() %>
                            </p>
                        </div>
                    </div>

                    <% if (allDates.isEmpty()) { %>
                        <div style="padding: 28px; text-align: center; border: 2px dashed #CBD5E1; border-radius: 18px; color: #64748B; font-weight: 700;">
                            Tiada rekod pentaksiran ditemui dalam pangkalan data untuk <%= activeStudent.getStudentName() %>.
                        </div>
                    <% } else {
                        // 1. PAPARAN REKOD TERKINI (CURRENT RECORD - INDEKS 0)
                        String curDateKey = allDates.get(0);
                        List<LearningProgress> curRecords = groupedReports.get(curDateKey);

                        String curDisplayDate = curDateKey;
                        String curMalayDate = curDateKey;
                        for (DateTimeFormatter fmt : supportedParsers) {
                            try {
                                LocalDate pDate = LocalDate.parse(curDateKey.trim(), fmt);
                                curDisplayDate = pDate.format(dmyFormatter);
                                curMalayDate = pDate.getDayOfMonth() + " " + malayMonths[pDate.getMonthValue() - 1] + " " + pDate.getYear();
                                break;
                            } catch (Exception ignored) {}
                        }

                        List<String> curTopics = new ArrayList<>();
                        for (LearningProgress item : curRecords) {
                            if (item.getProgressName() != null && !item.getProgressName().trim().isEmpty()) {
                                curTopics.add(item.getProgressName().trim());
                            }
                        }

                        LearningProgress curTargetRec = curRecords.get(0);
                        int curTargetPct = (int) Math.round(curTargetRec.getProgressPercentage());
                        String curSummaryText = (curTargetRec.getProgressName() != null ? curTargetRec.getProgressName() : "Pentaksiran")
                                + " (" + (curTargetRec.getDomainName() != null ? curTargetRec.getDomainName() : "Reading") + ") • " + curTargetPct + "%";
                    %>
                        <!-- KAD 1: REKOD TERKINI -->
                        <div class="nb-table-card">
                            <div class="table-section-banner">
                                <span style="display: inline-flex; align-items: center; gap: 6px;">
                                    <%= IconUtil.icon("Sparkles", "icon-sm") %>
                                    REKOD TERKINI (CURRENT RECORD)
                                </span>
                                <span class="nb-badge-mint" style="font-size: 10px;">
                                    Tarikh Aktif: <%= curDisplayDate %>
                                </span>
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
                                        <td style="vertical-align: top; text-align: center; border-bottom: none;">
                                            <div style="font-weight: 900; font-size: 1rem; color: #2D3436;"><%= curDisplayDate %></div>
                                            <div style="font-size: 0.78rem; font-weight: 700; color: #64748B; margin-top: 2px;"><%= curMalayDate %></div>
                                            <div style="margin-top: 8px;">
                                                <span class="nb-badge-mint" style="font-size: 9px; padding: 2px 8px;">
                                                    <%= IconUtil.icon("Star", "icon-xs") %> CURRENT RECORD
                                                </span>
                                            </div>
                                        </td>
                                        <td style="vertical-align: top; border-bottom: none;">
                                            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 8px;">
                                                <% for (LearningProgress domRec : curRecords) {
                                                    String dName = (domRec.getDomainName() != null) ? domRec.getDomainName() : "Reading";
                                                    boolean isRead = "Reading".equalsIgnoreCase(dName);
                                                    boolean isWrite = "Writing".equalsIgnoreCase(dName);

                                                    String pillBg = isRead ? "#F3E8FF" : (isWrite ? "#FFE4E6" : "#FEF3C7");
                                                    String pillText = isRead ? "#7E22CE" : (isWrite ? "#BE185D" : "#92400E");
                                                    String pillBorder = isRead ? "#D8B4FE" : (isWrite ? "#FDA4AF" : "#FCD34D");
                                                    String dIcon = isRead ? "BookOpen" : (isWrite ? "PenTool" : "BarChart3");
                                                    int pctRound = (int) Math.round(domRec.getProgressPercentage());
                                                %>
                                                    <span class="domain-pill" style="background: <%= pillBg %>; color: <%= pillText %>; border: 1px solid <%= pillBorder %>;">
                                                        <%= IconUtil.icon(dIcon, "icon-xs") %>
                                                        <%= dName %> (Skala <%= domRec.getRatingScale() %>/5 · <%= pctRound %>%)
                                                    </span>
                                                <% } %>
                                            </div>
                                            <p style="margin: 6px 0; font-size: 0.83rem; color: #1E293B; font-weight: 700;">
                                                <strong>Fokus &amp; Topik:</strong> <%= String.join(" · ", curTopics) %>
                                            </p>
                                        </td>
                                        <td style="vertical-align: top; text-align: center; border-bottom: none;">
                                            <div style="display: flex; flex-direction: column; gap: 8px;">
                                                <a href="<%= request.getContextPath() %>/reportDetail?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= curDateKey %>"
                                                   class="nb-btn nb-btn-yellow"
                                                   style="width: 100%; font-size: 0.78rem; padding: 6px 12px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 6px; box-sizing: border-box;">
                                                    <%= IconUtil.icon("Eye", "icon-xs") %> View
                                                </a>

                                                <% if (isTeacher) { %>
                                                    <a href="<%= request.getContextPath() %>/createProgress.jsp?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= curDateKey %>"
                                                       class="nb-btn"
                                                       style="width: 100%; font-size: 0.78rem; padding: 6px 12px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 6px; box-sizing: border-box;">
                                                        <%= IconUtil.icon("Edit2", "icon-xs") %> Edit
                                                    </a>
                                                <% } %>

                                                <% if (isAdmin) { %>
                                                    <button type="button"
													        class="nb-btn nb-btn-danger js-delete-btn"
													        style="width: 100%; font-size: 0.78rem; padding: 6px 12px;"
													        data-progress-id="<%= curTargetRec.getProgressID() %>"
													        data-report-date="<%= curDateKey %>"
													        data-student-name="<%= activeStudent.getStudentName().replace("\"", "&quot;") %>"
													        data-summary="<%= curSummaryText.replace("\"", "&quot;") %>">
													    <%= IconUtil.icon("Trash2", "icon-xs") %> Padam
													</button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- KAD 2: SEMUA REKOD TERDAHULU BERTINDAN DALAM SATU JADUAL -->
                        <% if (allDates.size() > 1) { %>
                            <div class="nb-table-card">
                                <div class="table-section-banner table-section-banner-gray">
                                    <span style="display: inline-flex; align-items: center; gap: 6px;">
                                        <%= IconUtil.icon("History", "icon-sm") %>
                                        REKOD TERDAHULU (PREVIOUS RECORD)
                                    </span>
                                    <span class="nb-badge-gray" style="font-size: 10px;">
                                        <%= allDates.size() - 1 %> Rekod Arkib
                                    </span>
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
                                        <% for (int i = 1; i < allDates.size(); i++) {
                                            String dateKey = allDates.get(i);
                                            List<LearningProgress> dayRecords = groupedReports.get(dateKey);
                                            boolean isLastRow = (i == allDates.size() - 1);

                                            String rowDisplayDate = dateKey;
                                            String malayDate = dateKey;
                                            for (DateTimeFormatter fmt : supportedParsers) {
                                                try {
                                                    LocalDate pDate = LocalDate.parse(dateKey.trim(), fmt);
                                                    rowDisplayDate = pDate.format(dmyFormatter);
                                                    malayDate = pDate.getDayOfMonth() + " " + malayMonths[pDate.getMonthValue() - 1] + " " + pDate.getYear();
                                                    break;
                                                } catch (Exception ignored) {}
                                            }

                                            List<String> topicTitles = new ArrayList<>();
                                            for (LearningProgress item : dayRecords) {
                                                if (item.getProgressName() != null && !item.getProgressName().trim().isEmpty()) {
                                                    topicTitles.add(item.getProgressName().trim());
                                                }
                                            }
                                            String joinedTopics = String.join(" · ", topicTitles);

                                            LearningProgress rowTargetRec = dayRecords.get(0);
                                            int rowTargetPct = (int) Math.round(rowTargetRec.getProgressPercentage());
                                            String rowSummaryText = (rowTargetRec.getProgressName() != null ? rowTargetRec.getProgressName() : "Pentaksiran")
                                                    + " (" + (rowTargetRec.getDomainName() != null ? rowTargetRec.getDomainName() : "Reading") + ") • " + rowTargetPct + "%";
                                        %>
                                            <tr>
                                                <td style="vertical-align: top; text-align: center; <%= isLastRow ? "border-bottom: none;" : "" %>">
                                                    <div style="font-weight: 900; font-size: 1rem; color: #2D3436;"><%= rowDisplayDate %></div>
                                                    <div style="font-size: 0.78rem; font-weight: 700; color: #64748B; margin-top: 2px;"><%= malayDate %></div>
                                                    <div style="margin-top: 8px;">
                                                        <span class="nb-badge-gray" style="font-size: 9px; padding: 2px 8px;">
                                                            <%= IconUtil.icon("Clock", "icon-xs") %> ARCHIVE
                                                        </span>
                                                    </div>
                                                </td>
                                                <td style="vertical-align: top; <%= isLastRow ? "border-bottom: none;" : "" %>">
                                                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 8px;">
                                                        <% for (LearningProgress domRec : dayRecords) {
                                                            String dName = (domRec.getDomainName() != null) ? domRec.getDomainName() : "Reading";
                                                            boolean isRead = "Reading".equalsIgnoreCase(dName);
                                                            boolean isWrite = "Writing".equalsIgnoreCase(dName);

                                                            String pillBg = isRead ? "#F3E8FF" : (isWrite ? "#FFE4E6" : "#FEF3C7");
                                                            String pillText = isRead ? "#7E22CE" : (isWrite ? "#BE185D" : "#92400E");
                                                            String pillBorder = isRead ? "#D8B4FE" : (isWrite ? "#FDA4AF" : "#FCD34D");
                                                            String dIcon = isRead ? "BookOpen" : (isWrite ? "PenTool" : "BarChart3");
                                                            int pctRound = (int) Math.round(domRec.getProgressPercentage());
                                                        %>
                                                            <span class="domain-pill" style="background: <%= pillBg %>; color: <%= pillText %>; border: 1px solid <%= pillBorder %>;">
                                                                <%= IconUtil.icon(dIcon, "icon-xs") %>
                                                                <%= dName %> (Skala <%= domRec.getRatingScale() %>/5 · <%= pctRound %>%)
                                                            </span>
                                                        <% } %>
                                                    </div>
                                                    <p style="margin: 6px 0; font-size: 0.83rem; color: #1E293B; font-weight: 700;">
                                                        <strong>Fokus &amp; Topik:</strong> <%= joinedTopics %>
                                                    </p>
                                                </td>
                                                <td style="vertical-align: top; text-align: center; <%= isLastRow ? "border-bottom: none;" : "" %>">
                                                    <div style="display: flex; flex-direction: column; gap: 8px;">
                                                        <a href="<%= request.getContextPath() %>/reportDetail?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= dateKey %>"
                                                           class="nb-btn nb-btn-yellow"
                                                           style="width: 100%; font-size: 0.78rem; padding: 6px 12px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 6px; box-sizing: border-box;">
                                                            <%= IconUtil.icon("Eye", "icon-xs") %> View
                                                        </a>

                                                        <% if (isTeacher) { %>
                                                            <a href="<%= request.getContextPath() %>/createProgress.jsp?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= dateKey %>"
                                                               class="nb-btn"
                                                               style="width: 100%; font-size: 0.78rem; padding: 6px 12px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 6px; box-sizing: border-box;">
                                                                <%= IconUtil.icon("Edit2", "icon-xs") %> Edit
                                                            </a>
                                                        <% } %>

                                                        <% if (isAdmin) { %>
                                                            <button type="button"
															        class="nb-btn nb-btn-danger js-delete-btn"
															        style="width: 100%; font-size: 0.78rem; padding: 6px 12px;"
															        data-progress-id="<%= curTargetRec.getProgressID() %>"
															        data-report-date="<%= curDateKey %>"
															        data-student-name="<%= activeStudent.getStudentName().replace("\"", "&quot;") %>"
															        data-summary="<%= curSummaryText.replace("\"", "&quot;") %>">
															    <%= IconUtil.icon("Trash2", "icon-xs") %> Padam
															</button>
                                                        <% } %>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    <% } %>

                    <!-- HANYA TEACHER boleh Create Progress -->
                    <% if (isTeacher) { %>
                        <div style="display: flex; justify-content: flex-end; align-items: center; gap: 14px; flex-wrap: wrap; margin-top: 16px;">
                            <% if (hasWeeklyRecord) { %>
                                <div class="weekly-status-pill">
                                    <%= IconUtil.icon("CalendarCheck", "icon-xs") %>
                                    <span>Rekod minggu ini telah diisi (<%= weeklyExistingDisplay %>)</span>
                                </div>

                                <button type="button"
                                        onclick="openWeeklyLimitModal()"
                                        class="nb-btn nb-btn-yellow"
                                        style="padding: 10px 24px; font-size: 0.9rem; opacity: 0.78;">
                                    <%= IconUtil.icon("Plus", "icon-sm") %>
                                    <span>Create Progress</span>
                                </button>
                            <% } else { %>
                                <a href="<%= request.getContextPath() %>/createProgress.jsp?studentId=<%= activeStudent.getStudentID() %>" 
                                   class="nb-btn nb-btn-yellow" 
                                   style="padding: 10px 24px; font-size: 0.9rem;">
                                    <%= IconUtil.icon("Plus", "icon-sm") %>
                                    <span>Create Progress</span>
                                </a>
                            <% } %>
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- MODAL AMARAN HAD PENTAKSIRAN 1 KALI SEMINGGU (TEACHER) -->
<% if (isTeacher && hasWeeklyRecord) { %>
<div class="wk-modal-overlay" id="weeklyLimitModal">
    <div class="wk-modal-card">
        <div class="wk-modal-top">
            <div class="wk-modal-title-wrap">
                <div class="wk-warn-icon-box">
                    <%= IconUtil.icon("AlertTriangle", "icon-md") %>
                </div>
                <div>
                    <div class="wk-kicker">HAD PENTAKSIRAN: 1 KALI SEMINGGU</div>
                    <h3 class="wk-heading">Rekod Minggu Ini Sudah Wujud</h3>
                </div>
            </div>

            <button type="button" class="wk-close-btn" onclick="closeWeeklyLimitModal()" title="Tutup">
                <%= IconUtil.icon("X", "icon-xs") %>
            </button>
        </div>

        <p class="wk-desc">
            Pentaksiran kemajuan murid ditetapkan hanya <strong>sekali setiap minggu</strong>. Murid <strong><%= activeStudent.getStudentName() %></strong> sudah mempunyai rekod pentaksiran bagi minggu semasa.
        </p>

        <div class="wk-info-box">
            <div class="wk-info-row">
                <span class="wk-info-lbl">Tarikh Rekod Sedia Ada</span>
                <span class="wk-info-val"><%= weeklyExistingMalay %> (<%= weeklyExistingDay %>)</span>
            </div>
            <div class="wk-info-row">
                <span class="wk-info-lbl">Tempoh Minggu Semasa</span>
                <span class="wk-info-val"><%= weekRangeMalay %></span>
            </div>
        </div>

        <p class="wk-sub-note">
            Anda boleh menyemak laporan minggu ini atau mengemaskini rekod sedia ada tanpa mencipta rekod baharu pada minggu yang sama.
        </p>

        <div class="wk-actions">
            <a href="<%= request.getContextPath() %>/reportDetail?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= weeklyExistingDate %>"
               class="wk-btn-action wk-btn-white">
                <%= IconUtil.icon("Eye", "icon-xs") %>
                <span>Lihat Laporan</span>
            </a>

            <a href="<%= request.getContextPath() %>/createProgress.jsp?studentId=<%= activeStudent.getStudentID() %>&reportDate=<%= weeklyExistingDate %>"
               class="wk-btn-action wk-btn-yellow">
                <%= IconUtil.icon("Edit2", "icon-xs") %>
                <span>Edit Rekod Minggu Ini</span>
            </a>
        </div>
    </div>
</div>
<% } %>

<!-- CUSTOM DELETE CONFIRMATION MODAL (ADMIN ONLY) -->
<% if (isAdmin) { %>
<div class="del-modal-overlay" id="deleteConfirmModal">
    <div class="del-modal-box">
        <div class="del-modal-header">
            <div class="del-modal-icon">
                <%= IconUtil.icon("Trash2", "icon-md") %>
            </div>
            <div>
                <h3 style="margin: 0; font-size: 1.2rem; font-weight: 900; color: #1E293B;">
                    Delete Evaluation Record?
                </h3>
                <p style="margin: 3px 0 0 0; font-size: 0.78rem; font-weight: 600; color: #64748B;">
                    This action will remove the record from <span id="delModalStudentName"><%= activeStudent.getStudentName() %></span>'s file.
                </p>
            </div>
        </div>

        <form action="<%= request.getContextPath() %>/ProgressServlet" method="POST" style="margin: 0;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="studentID" value="<%= activeStudent.getStudentID() %>">
            <input type="hidden" name="progressID" id="delModalProgressID" value="">
            <input type="hidden" name="reportDate" id="delModalReportDate" value="">

            <div class="del-modal-actions">
                <button type="button" class="btn-modal-cancel" id="btnCancelDelete">
                    Cancel
                </button>
                <button type="submit" class="btn-modal-confirm">
                    Confirm Delete
                </button>
            </div>
        </form>
    </div>
</div>
<% } %>

<script>
    function toggleLpDropdown() {
        const wrapper = document.getElementById('lpBannerWrapper');
        const menu = document.getElementById('lpDropdownMenu');
        if (wrapper && menu) {
            wrapper.classList.toggle('open');
            menu.classList.toggle('show');
        }
    }

    function openWeeklyLimitModal() {
        const modal = document.getElementById('weeklyLimitModal');
        if (modal) {
            modal.classList.add('show');
        }
    }

    function closeWeeklyLimitModal() {
        const modal = document.getElementById('weeklyLimitModal');
        if (modal) {
            modal.classList.remove('show');
        }
    }

    function closeDeleteModal() {
        const modal = document.getElementById('deleteConfirmModal');
        if (modal) {
            modal.classList.remove('show');
        }
    }

    document.addEventListener('click', function(event) {
        // 1. Kesan klik pada mana-mana butang Padam Admin (.js-delete-btn)
        const delBtn = event.target.closest('.js-delete-btn');
        if (delBtn) {
            event.preventDefault();
            const modal = document.getElementById('deleteConfirmModal');
            if (modal) {
                const pidEl = document.getElementById('delModalProgressID');
                const rdateEl = document.getElementById('delModalReportDate');
                const snameEl = document.getElementById('delModalStudentName');
                const sumEl = document.getElementById('delModalSummary');

                if (pidEl) pidEl.value = delBtn.getAttribute('data-progress-id') || '';
                if (rdateEl) rdateEl.value = delBtn.getAttribute('data-report-date') || '';
                if (snameEl) snameEl.innerText = delBtn.getAttribute('data-student-name') || '';
                if (sumEl) sumEl.innerText = delBtn.getAttribute('data-summary') || '';

                modal.classList.add('show');
            }
            return;
        }

        // 2. Kesan klik di luar kotak modal amaran mingguan
        const wkModalOverlay = document.getElementById('weeklyLimitModal');
        if (event.target === wkModalOverlay) {
            closeWeeklyLimitModal();
            return;
        }

        // 3. Kesan klik pada butang Cancel atau kawasan luar kotak modal delete
        const modalOverlay = document.getElementById('deleteConfirmModal');
        if (event.target.closest('#btnCancelDelete') || event.target === modalOverlay) {
            closeDeleteModal();
            return;
        }

        // 4. Tutup dropdown murid jika klik di luar banner
        if (!event.target.closest('#lpBannerWrapper')) {
            const wrapper = document.getElementById('lpBannerWrapper');
            const menu = document.getElementById('lpDropdownMenu');
            if (wrapper) wrapper.classList.remove('open');
            if (menu) menu.classList.remove('show');
        }
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeDeleteModal();
            closeWeeklyLimitModal();
        }
    });
</script>

<jsp:include page="icons.jsp" />
</body>
</html>