<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%@ page import="dao.LearningProgressDAO"%>
<%@ page import="util.DatabaseConnection"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>

<%
    List<Student> oracleStudents = new ArrayList<>();
    Set<String> oracleClasses = new LinkedHashSet<>();
    Map<Integer, String> parentNameMap = new HashMap<>();
    Map<Integer, List<String>> studentExistingDates = new HashMap<>();

    int reqStudentId = -1;
    String paramSid = request.getParameter("studentId");
    if (paramSid == null || paramSid.isEmpty()) paramSid = request.getParameter("studentID");
    if (paramSid != null && !paramSid.isEmpty()) {
        try { reqStudentId = Integer.parseInt(paramSid); } catch (Exception ignored) {}
    }

    try (Connection conn = DatabaseConnection.getConnection()) {
        if (conn != null) {
            // 1. Dapatkan senarai murid & kelas dari Oracle
            String sql = "select s.studentID, s.studentName, s.studentAge, s.studentClass, p.parentName " +
                         "from student s " +
                         "left join parent p on s.parentID = p.parentID " +
                         "order by s.studentClass asc, s.studentName asc";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Student st = new Student();
                    int sid = rs.getInt("studentID");
                    st.setStudentID(sid);
                    st.setStudentName(rs.getString("studentName"));
                    st.setStudentAge(rs.getInt("studentAge"));

                    String sclass = rs.getString("studentClass");
                    if (sclass == null || sclass.trim().isEmpty()) {
                        sclass = "Kindergarten 3B";
                    } else {
                        sclass = sclass.trim();
                    }
                    st.setStudentClass(sclass);

                    String pname = rs.getString("parentName");
                    parentNameMap.put(sid, (pname != null && !pname.trim().isEmpty()) ? pname.trim() : "-");

                    oracleStudents.add(st);
                    oracleClasses.add(sclass);
                }
            }

            // 2. Dapatkan semua tarikh pentaksiran sedia ada bagi setiap murid (Format: YYYY-MM-DD)
            String sqlDates = "SELECT DISTINCT studentID, TO_CHAR(progressDate, 'YYYY-MM-DD') AS pDate " +
                              "FROM learningprogress " +
                              "WHERE progressDate IS NOT NULL " +
                              "ORDER BY pDate DESC";
            try (PreparedStatement psDates = conn.prepareStatement(sqlDates);
                 ResultSet rsDates = psDates.executeQuery()) {
                while (rsDates.next()) {
                    int sid = rsDates.getInt("studentID");
                    String pDate = rsDates.getString("pDate");
                    studentExistingDates.computeIfAbsent(sid, k -> new ArrayList<>()).add(pDate);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    Student initialStudent = oracleStudents.isEmpty() ? null : oracleStudents.get(0);
    if (reqStudentId != -1) {
        for (Student st : oracleStudents) {
            if (st.getStudentID() == reqStudentId) {
                initialStudent = st;
                break;
            }
        }
    }

    String initialClass = (initialStudent != null) ? initialStudent.getStudentClass() : "Kindergarten 3B";
    int initialStudentId = (initialStudent != null) ? initialStudent.getStudentID() : 1;
    int initialAge = (initialStudent != null) ? initialStudent.getStudentAge() : 5;
    String initialParent = parentNameMap.getOrDefault(initialStudentId, "-");

    // Semak Mod Edit berdasarkan parameter reportDate
    String editReportDate = request.getParameter("reportDate");
    boolean isEditMode = (editReportDate != null && !editReportDate.trim().isEmpty());

    LearningProgress editReading = null;
    LearningProgress editWriting = null;
    LearningProgress editCounting = null;
    String savedHomeRec = "";
    String savedAssessor = "";

    if (isEditMode && initialStudentId > 0) {
        LearningProgressDAO editDao = new LearningProgressDAO();
        List<LearningProgress> oldRecs = editDao.getRecordsByStudentAndDate(initialStudentId, editReportDate.trim());
        for (LearningProgress r : oldRecs) {
            if ("Reading".equalsIgnoreCase(r.getDomainName())) editReading = r;
            else if ("Writing".equalsIgnoreCase(r.getDomainName())) editWriting = r;
            else if ("Counting".equalsIgnoreCase(r.getDomainName())) editCounting = r;

            if (r.getHomeRecommendation() != null && !r.getHomeRecommendation().trim().isEmpty()) {
                savedHomeRec = r.getHomeRecommendation();
            }
            if (r.getAssessorName() != null && !r.getAssessorName().trim().isEmpty()) {
                savedAssessor = r.getAssessorName();
            }
        }
    }

    String todayDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String formDateVal = isEditMode ? editReportDate.trim() : todayDate;

    String defaultAssessor = (session.getAttribute("userName") != null && !session.getAttribute("userName").toString().isEmpty())
            ? session.getAttribute("userName").toString() : "Ms. Clara Davis";
    String formAssessorVal = (isEditMode && !savedAssessor.isEmpty()) ? savedAssessor : defaultAssessor;

    String readTopicVal = (editReading != null && editReading.getProgressName() != null)
            ? editReading.getProgressName() : "Penguasaan Fonik & Pengecaman Bunyi Huruf (Phonics)";
    String writeTopicVal = (editWriting != null && editWriting.getProgressName() != null)
            ? editWriting.getProgressName() : "Kawalan Motor Halus & Genggaman Pensel (Tripod Grip)";
    String countTopicVal = (editCounting != null && editCounting.getProgressName() != null)
            ? editCounting.getProgressName() : "Pengecaman Nombor & Pembilangan Objek (1-30)";

    String readNotesVal = (editReading != null && editReading.getNotes() != null) ? editReading.getNotes() : "";
    String writeNotesVal = (editWriting != null && editWriting.getNotes() != null) ? editWriting.getNotes() : "";
    String countNotesVal = (editCounting != null && editCounting.getNotes() != null) ? editCounting.getNotes() : "";

    int readScaleVal = (editReading != null && editReading.getRatingScale() > 0) ? editReading.getRatingScale() : 4;
    int writeScaleVal = (editWriting != null && editWriting.getRatingScale() > 0) ? editWriting.getRatingScale() : 4;
    int countScaleVal = (editCounting != null && editCounting.getRatingScale() > 0) ? editCounting.getRatingScale() : 4;

    String[] statusNames = {"", "NOT STARTED", "EMERGING", "DEVELOPING", "PROFICIENT", "MASTERED"};

    request.setAttribute("oracleStudents", oracleStudents);
    request.setAttribute("oracleClasses", oracleClasses);
    request.setAttribute("parentNameMap", parentNameMap);
    request.setAttribute("initialClass", initialClass);
    request.setAttribute("initialStudentId", initialStudentId);
    request.setAttribute("initialAge", initialAge);
    request.setAttribute("initialParent", initialParent);
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEditMode ? "Kemaskini Rekod Pentaksiran" : "Borang Pentaksiran Komprehensif" %> - Keedsflix Centre</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/createProgress.css">
</head>
<body>

<div class="app-layout">

    <!-- 1. SIDEBAR INCLUDE -->
    <aside class="app-sidebar-wrapper">
        <% request.setAttribute("activeTab", "progress"); %>
        <jsp:include page="sidebar.jsp" />
    </aside>

    <!-- 2. MAIN APPLICATION WRAPPER -->
    <main class="app-main-wrapper">

        <!-- HEADER INCLUDE -->
        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <!-- MAIN BODY CONTENT AREA -->
        <div class="app-content-body">
            <div class="nb-wrapper">
                <form action="${pageContext.request.contextPath}/createProgress" method="POST" id="progressForm">
                    <input type="hidden" name="studentID" id="formStudentID" value="${editingRecord != null ? editingRecord.studentID : initialStudentId}">
                    <input type="hidden" name="editProgressID" value="${editingRecord != null ? editingRecord.progressID : 0}">
                    <input type="hidden" name="editReportDate" value="<%= isEditMode ? editReportDate.trim() : "" %>">
                    <input type="hidden" name="activeDomainFilter" id="activeDomainFilter" value="All">

                    <!-- ==========================================================================
                         CLEAN PAGE HEADER
                         ========================================================================== -->
                    <div class="page-top-header">
                        <div>
                            <span class="page-top-pill">
                                <%= isEditMode ? "MOD KEMASKINI REKOD PENTAKSIRAN" : "PENTAKSIRAN BERSEPADU KSPK" %>
                            </span>
                            <h1 class="page-top-title">
                                <%= isEditMode ? "Kemaskini Rekod Pentaksiran (" + editReportDate.trim() + ")" : "Borang Pentaksiran Komprehensif" %>
                            </h1>
                        </div>
                    </div>

                    <!-- STUDENT, CLASS & DATE CONTEXT SELECTOR CARD (ORACLE DB SYNCED) -->
                    <div class="nb-card">
                        <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 16px; align-items: start;">
                            
                            <!-- Kotak Kiri: Pilihan Kelas + Sasaran Murid Dinilai -->
                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 14px 16px; box-shadow: var(--shadow-sm); display: flex; gap: 14px; align-items: flex-start;">
                                <div style="width: 44px; height: 44px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 14px; display: flex; align-items: center; justify-content: center; color: var(--border-dark); flex-shrink: 0; box-shadow: var(--shadow-sm); margin-top: 4px;">
                                    <%= IconUtil.icon("Smile", "icon-md") %>
                                </div>
                                
                                <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 10px;">
                                    <div>
                                        <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 4px;">
                                            PILIHAN KELAS
                                        </label>
                                        <select id="classSelect" class="nb-select" onchange="filterStudentsByClass()">
                                            <option value="ALL">Semua Kelas (${oracleStudents.size()} Murid)</option>
                                            <c:forEach var="cls" items="${oracleClasses}">
                                                <option value="${cls}" ${cls == initialClass ? 'selected' : ''}>${cls}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div>
                                        <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: block; margin-bottom: 4px;">
                                            SASARAN MURID DINILAI
                                        </label>
                                        <select id="studentSelect" class="nb-select" onchange="updateStudentContext(this)">
                                            <c:forEach var="st" items="${oracleStudents}">
                                                <option value="${st.studentID}"
                                                        data-class="${st.studentClass}"
                                                        data-age="${st.studentAge}"
                                                        data-parent="${parentNameMap[st.studentID]}"
                                                        ${st.studentID == initialStudentId ? 'selected' : ''}>
                                                    ${st.studentName} — ${st.studentClass} (${st.studentAge} Years)
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                        <span class="nb-badge badge-target">
                                            <%= IconUtil.icon("Target", "icon-xs") %>
                                            <span id="lblTargetAge">SASARAN UMUR ${initialAge} TAHUN: SKALA 4: MAHIR (PROFICIENT)</span>
                                        </span>
                                        <span style="font-size: 0.72rem; font-weight: 600; color: #475569;">
                                            Ibu Bapa: <strong id="lblParent" style="color: var(--border-dark);">${initialParent}</strong>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Kotak Tengah: Tarikh Pentaksiran + Kotak Amaran Mingguan -->
                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 14px 16px; box-shadow: var(--shadow-sm);">
                                <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: flex; align-items: center; gap: 5px; margin-bottom: 6px;">
                                    <%= IconUtil.icon("Calendar", "icon-xs") %>
                                    <span>TARIKH PENTAKSIRAN</span>
                                </label>
                                <input type="date" name="progressDate" id="progressDateInput" class="nb-input"
                                       value="<%= formDateVal %>" onchange="checkWeeklyDuplicate()" required>

                                <!-- Amaran jika sudah wujud rekod dalam minggu yang sama -->
                                <div id="weeklyWarningBox" style="display: none; margin-top: 10px; background: #FEF2F2; border: 2px solid #EF4444; border-radius: 12px; padding: 10px 12px; font-size: 0.72rem; color: #991B1B; line-height: 1.45;">
                                    <div style="font-weight: 900; display: flex; align-items: center; gap: 5px; margin-bottom: 3px;">
                                        <%= IconUtil.icon("AlertTriangle", "icon-xs") %>
                                        <span>REKOD MINGGU INI SUDAH WUJUD</span>
                                    </div>
                                    <div id="weeklyWarningText"></div>
                                </div>
                            </div>

                            <!-- Kotak Kanan: Guru Penilai -->
                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 14px 16px; box-shadow: var(--shadow-sm);">
                                <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: flex; align-items: center; gap: 5px; margin-bottom: 6px;">
                                    <%= IconUtil.icon("UserCheck", "icon-xs") %>
                                    <span>GURU PENILAI (ASSESSOR)</span>
                                </label>
                                <input type="text" name="assessorName" class="nb-input" value="<%= formAssessorVal %>" required>
                            </div>

                        </div>
                    </div>

                    <!-- LIVE PREVIEW CARD CONTAINER (WITH RADAR SYNC) -->
                    <div class="nb-card">
                        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(45, 52, 54, 0.1); padding-bottom: 10px; flex-wrap: wrap; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 32px; height: 32px; border-radius: 10px; background: #FFE4E6; border: 2px solid var(--border-dark); display: flex; align-items: center; justify-content: center; color: #E11D48;">
                                    <%= IconUtil.icon("Eye", "icon-xs") %>
                                </div>
                                <div>
                                    <h3 style="font-size: 0.95rem; font-weight: 900; display: flex; align-items: center; gap: 6px;">
                                        Pratonton Kad Rekod 3 Teras &amp; Radar Chart (Live Preview)
                                        <span style="width: 8px; height: 8px; background: #10B981; border-radius: 50%; display: inline-block;"></span>
                                    </h3>
                                    <p style="font-size: 0.7rem; color: #64748B; font-weight: 600;">
                                        Peringatan: Umur <strong id="lblPreviewAge">${initialAge} tahun</strong> disasarkan mencapai <strong>Skala 4: Mahir (Proficient)</strong>. Jurang penilaian akan mencetuskan amaran kepada guru dan ibu bapa.
                                    </p>
                                </div>
                            </div>
                            <span class="nb-badge" style="background: #FFF; border: 2px solid var(--border-dark); box-shadow: var(--shadow-sm);">RADAR &amp; ALERT SYNC</span>
                        </div>

                        <!-- 3 Mini Cards Grid -->
                        <div class="preview-grid">
                            <!-- Reading Card -->
                            <div class="preview-card" id="prevCard1" onclick="goToStep(1)">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-yellow">
                                            <%= IconUtil.icon("BookOpen", "icon-xs") %>
                                            <span>READING</span>
                                        </span>
                                        <span class="nb-badge <%= readScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="prevReadingBadge">
                                            <%= readScaleVal >= 4 ? "CAPAI SASARAN" : "PERLU BIMBINGAN" %>
                                        </span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevReadingTitle">
                                        <%= readTopicVal %>
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Status: <strong id="prevReadingStatusTxt"><%= statusNames[readScaleVal] %></strong> (Konstruk KSPK).
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevReadingRadar"><%= readScaleVal * 2 %>/10</strong></span>
                                    <span style="font-weight: 900;" id="prevReadingScale">Skala <%= readScaleVal %>/5</span>
                                </div>
                            </div>

                            <!-- Writing Card -->
                            <div class="preview-card locked" id="prevCard2" onclick="goToStep(2)">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-coral">
                                            <%= IconUtil.icon("PenTool", "icon-xs") %>
                                            <span>WRITING</span>
                                        </span>
                                        <span class="nb-badge <%= writeScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="prevWritingBadge">
                                            <%= writeScaleVal >= 4 ? "CAPAI SASARAN" : "PERLU BIMBINGAN" %>
                                        </span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevWritingTitle">
                                        <%= writeTopicVal %>
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Status: <strong id="prevWritingStatusTxt"><%= statusNames[writeScaleVal] %></strong> (Konstruk KSPK).
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevWritingRadar"><%= writeScaleVal * 2 %>/10</strong></span>
                                    <span style="font-weight: 900;" id="prevWritingScale">Skala <%= writeScaleVal %>/5</span>
                                </div>
                            </div>

                            <!-- Counting Card -->
                            <div class="preview-card locked" id="prevCard3" onclick="goToStep(3)">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                        <span class="nb-badge badge-mint">
                                            <%= IconUtil.icon("Hash", "icon-xs") %>
                                            <span>COUNTING</span>
                                        </span>
                                        <span class="nb-badge <%= countScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="prevCountingBadge">
                                            <%= countScaleVal >= 4 ? "CAPAI SASARAN" : "PERLU BIMBINGAN" %>
                                        </span>
                                    </div>
                                    <h4 style="font-size: 0.85rem; font-weight: 900; margin-bottom: 4px;" id="prevCountingTitle">
                                        <%= countTopicVal %>
                                    </h4>
                                    <p style="font-size: 0.7rem; color: #475569; font-weight: 600;">
                                        Status: <strong id="prevCountingStatusTxt"><%= statusNames[countScaleVal] %></strong> (Konstruk KSPK).
                                    </p>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #CBD5E1; padding-top: 8px; margin-top: 12px; font-size: 0.75rem;">
                                    <span style="color: #64748B; font-weight: 700;">Paksi Radar: <strong style="color: var(--border-dark);" id="prevCountingRadar"><%= countScaleVal * 2 %>/10</strong></span>
                                    <span style="font-weight: 900;" id="prevCountingScale">Skala <%= countScaleVal %>/5</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ==========================================================================
                         4-STEP WIZARD BAR
                         ========================================================================== -->
                    <div class="step-wizard-grid" id="stepWizardBar">
                        <button type="button" class="step-pill-btn active" id="stepTab1" onclick="goToStep(1)">
                            <span class="step-num-circle" id="stepCircle1">1</span>
                            <div>
                                <div class="step-pill-title">Reading</div>
                                <div class="step-pill-sub">Langkah 1: Kemahiran Membaca</div>
                            </div>
                        </button>

                        <button type="button" class="step-pill-btn locked" id="stepTab2" onclick="goToStep(2)">
                            <span class="step-num-circle" id="stepCircle2">2</span>
                            <div>
                                <div class="step-pill-title">Writing</div>
                                <div class="step-pill-sub">Langkah 2: Kemahiran Menulis</div>
                            </div>
                        </button>

                        <button type="button" class="step-pill-btn locked" id="stepTab3" onclick="goToStep(3)">
                            <span class="step-num-circle" id="stepCircle3">3</span>
                            <div>
                                <div class="step-pill-title">Counting</div>
                                <div class="step-pill-sub">Langkah 3: Kemahiran Mengira</div>
                            </div>
                        </button>

                        <button type="button" class="step-pill-btn locked" id="stepTab4" onclick="goToStep(4)">
                            <span class="step-num-circle" id="stepCircle4">4</span>
                            <div>
                                <div class="step-pill-title">Cadangan</div>
                                <div class="step-pill-sub">Langkah 4: Aktiviti di Rumah</div>
                            </div>
                        </button>
                    </div>

                    <!-- ==========================================================================
                         LANGKAH 1: TERAS 1 - READING
                         ========================================================================== -->
                    <div class="nb-card step-panel active" id="stepPanel1">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--border-dark); box-shadow: var(--shadow-sm);">
                                    <%= IconUtil.icon("BookOpen", "icon-sm") %>
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-yellow">TERAS 1</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Reading (Fonik &amp; Kemahiran Membaca)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran penguasaan vokal, konsonan, suku kata terbuka (KV) &amp; pemahaman teks bacaan.</p>
                                </div>
                            </div>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Reading <span style="color:red;">*</span></label>
                        <input type="text" name="reading_progressName" id="readingTopic" class="nb-input" value="<%= readTopicVal %>" oninput="updateLivePreview()" required>

                        <!-- 1. Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: flex; align-items: center; gap: 5px;">
                                        <%= IconUtil.icon("Award", "icon-xs") %>
                                        <span>Skala Penilaian Perkembangan (Rating Scale 1 - 5)</span>
                                    </label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: <span id="lblReadingAxis"><%= readScaleVal * 2 %>.0</span>/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblReadingScale"><%= readScaleVal %></span> / 5</span>
                                    <span class="nb-badge badge-yellow" id="lblReadingStatus"><%= statusNames[readScaleVal] %></span>
                                </div>
                            </div>

                            <input type="hidden" name="reading_ratingScale" id="reading_scale" value="<%= readScaleVal %>">
                            <div class="scale-grid">
                                <div class="scale-btn <%= readScaleVal == 1 ? "active-yellow" : "" %>" onclick="selectScale('reading', 1, 'yellow', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn <%= readScaleVal == 2 ? "active-yellow" : "" %>" onclick="selectScale('reading', 2, 'yellow', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn <%= readScaleVal == 3 ? "active-yellow" : "" %>" onclick="selectScale('reading', 3, 'yellow', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn <%= readScaleVal == 4 ? "active-yellow" : "" %>" onclick="selectScale('reading', 4, 'yellow', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn <%= readScaleVal == 5 ? "active-yellow" : "" %>" onclick="selectScale('reading', 5, 'yellow', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div class="benchmark-box <%= readScaleVal >= 4 ? "ok" : "alert" %>" id="readingBenchmarkBox">
                                <span id="readingBenchmarkText">
                                    <%= readScaleVal >= 4 ? "Mencapai Penanda Aras Umur (Skala 4: Mahir (Proficient))" : "AMARAN JURANG PERKEMBANGAN: Skor semasa di bawah penanda aras umur." %>
                                </span>
                                <span class="nb-badge <%= readScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="readingBenchmarkBadge">
                                    <%= readScaleVal >= 4 ? "Sasaran Tercapai" : "Jurang -" + (4 - readScaleVal) + " Skala" %>
                                </span>
                            </div>
                        </div>

                        <!-- 2. Komen & Pemerhatian Guru (Reading) -->
                        <div style="margin-top: 16px;">
                            <label style="font-size: 0.78rem; font-weight: 900; display: flex; align-items: center; gap: 6px; margin-bottom: 6px; color: var(--border-dark);">
                                <span style="color: #F59E0B; display: inline-flex; align-items: center;"><%= IconUtil.icon("MessageSquare", "icon-xs") %></span>
                                <span>Komen &amp; Pemerhatian Guru (Reading)</span>
                            </label>
                            <textarea name="reading_notes" class="nb-textarea" rows="4" placeholder="Tulis komen atau pemerhatian guru mengenai penguasaan fonik, bacaan, dan pemahaman murid..."><%= readNotesVal %></textarea>
                        </div>
                    </div>

                    <!-- ==========================================================================
                         LANGKAH 2: TERAS 2 - WRITING
                         ========================================================================== -->
                    <div class="nb-card step-panel" id="stepPanel2">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--coral-accent); color:#FFF; border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: var(--shadow-sm);">
                                    <%= IconUtil.icon("PenTool", "icon-sm") %>
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-coral">TERAS 2</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Writing (Motor Halus &amp; Kemahiran Menulis)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran genggaman pensel tripod, kawalan koordinasi tangan-mata, dan pembentukan huruf.</p>
                                </div>
                            </div>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Writing <span style="color:red;">*</span></label>
                        <input type="text" name="writing_progressName" id="writingTopic" class="nb-input" value="<%= writeTopicVal %>" oninput="updateLivePreview()" required>

                        <!-- 1. Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: flex; align-items: center; gap: 5px;">
                                        <%= IconUtil.icon("Award", "icon-xs") %>
                                        <span>Skala Penilaian Perkembangan (Rating Scale 1 - 5)</span>
                                    </label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: <span id="lblWritingAxis"><%= writeScaleVal * 2 %>.0</span>/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblWritingScale"><%= writeScaleVal %></span> / 5</span>
                                    <span class="nb-badge badge-coral" id="lblWritingStatus"><%= statusNames[writeScaleVal] %></span>
                                </div>
                            </div>

                            <input type="hidden" name="writing_ratingScale" id="writing_scale" value="<%= writeScaleVal %>">
                            <div class="scale-grid">
                                <div class="scale-btn <%= writeScaleVal == 1 ? "active-coral" : "" %>" onclick="selectScale('writing', 1, 'coral', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn <%= writeScaleVal == 2 ? "active-coral" : "" %>" onclick="selectScale('writing', 2, 'coral', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn <%= writeScaleVal == 3 ? "active-coral" : "" %>" onclick="selectScale('writing', 3, 'coral', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn <%= writeScaleVal == 4 ? "active-coral" : "" %>" onclick="selectScale('writing', 4, 'coral', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn <%= writeScaleVal == 5 ? "active-coral" : "" %>" onclick="selectScale('writing', 5, 'coral', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div class="benchmark-box <%= writeScaleVal >= 4 ? "ok" : "alert" %>" id="writingBenchmarkBox">
                                <span id="writingBenchmarkText">
                                    <%= writeScaleVal >= 4 ? "Mencapai Penanda Aras Umur (Skala 4: Mahir (Proficient))" : "AMARAN JURANG PERKEMBANGAN: Skor semasa di bawah penanda aras umur." %>
                                </span>
                                <span class="nb-badge <%= writeScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="writingBenchmarkBadge">
                                    <%= writeScaleVal >= 4 ? "Sasaran Tercapai" : "Jurang -" + (4 - writeScaleVal) + " Skala" %>
                                </span>
                            </div>
                        </div>

                        <!-- 2. Komen & Pemerhatian Guru (Writing) -->
                        <div style="margin-top: 16px;">
                            <label style="font-size: 0.78rem; font-weight: 900; display: flex; align-items: center; gap: 6px; margin-bottom: 6px; color: var(--border-dark);">
                                <span style="color: #F43F5E; display: inline-flex; align-items: center;"><%= IconUtil.icon("MessageSquare", "icon-xs") %></span>
                                <span>Komen &amp; Pemerhatian Guru (Writing)</span>
                            </label>
                            <textarea name="writing_notes" class="nb-textarea" rows="4" placeholder="Tulis komen atau pemerhatian guru mengenai genggaman pensel, motor halus, dan kekemasan tulisan murid..."><%= writeNotesVal %></textarea>
                        </div>
                    </div>

                    <!-- ==========================================================================
                         LANGKAH 3: TERAS 3 - COUNTING
                         ========================================================================== -->
                    <div class="nb-card step-panel" id="stepPanel3">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 38px; height: 38px; background: var(--mint-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--border-dark); box-shadow: var(--shadow-sm);">
                                    <%= IconUtil.icon("Hash", "icon-sm") %>
                                </div>
                                <div>
                                    <div style="display: flex; gap: 6px; align-items: center;">
                                        <span class="nb-badge badge-mint">TERAS 3</span>
                                        <h2 style="font-size: 1.05rem; font-weight: 900;">Counting (Nombor, Operasi &amp; Bentuk Geometri)</h2>
                                    </div>
                                    <p style="font-size: 0.7rem; color: #64748B;">Pentaksiran pembilangan objek 1-ke-1, pengecaman angka, bentuk 2D dan operasi matematik awal.</p>
                                </div>
                            </div>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Counting <span style="color:red;">*</span></label>
                        <input type="text" name="counting_progressName" id="countingTopic" class="nb-input" value="<%= countTopicVal %>" oninput="updateLivePreview()" required>

                        <!-- 1. Rating Scale Selector (1-5) -->
                        <div class="scale-selector-container">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                <div>
                                    <label style="font-size: 0.75rem; font-weight: 900; display: flex; align-items: center; gap: 5px;">
                                        <%= IconUtil.icon("Award", "icon-xs") %>
                                        <span>Skala Penilaian Perkembangan (Rating Scale 1 - 5)</span>
                                    </label>
                                    <p style="font-size: 0.68rem; color: #64748B;">Diselaraskan terus ke graf Radar Chart (Paksi: <span id="lblCountingAxis"><%= countScaleVal * 2 %>.0</span>/10).</p>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <span class="nb-badge" style="background:#FFF;">Skala <span id="lblCountingScale"><%= countScaleVal %></span> / 5</span>
                                    <span class="nb-badge badge-mint" id="lblCountingStatus"><%= statusNames[countScaleVal] %></span>
                                </div>
                            </div>

                            <input type="hidden" name="counting_ratingScale" id="counting_scale" value="<%= countScaleVal %>">
                            <div class="scale-grid">
                                <div class="scale-btn <%= countScaleVal == 1 ? "active-mint" : "" %>" onclick="selectScale('counting', 1, 'mint', this)"><span class="num">1</span><span class="lbl">Bermula</span></div>
                                <div class="scale-btn <%= countScaleVal == 2 ? "active-mint" : "" %>" onclick="selectScale('counting', 2, 'mint', this)"><span class="num">2</span><span class="lbl">Asas</span></div>
                                <div class="scale-btn <%= countScaleVal == 3 ? "active-mint" : "" %>" onclick="selectScale('counting', 3, 'mint', this)"><span class="num">3</span><span class="lbl">Membangun</span></div>
                                <div class="scale-btn <%= countScaleVal == 4 ? "active-mint" : "" %>" onclick="selectScale('counting', 4, 'mint', this)">
                                    <span class="target-pill">SASARAN</span>
                                    <span class="num">4</span><span class="lbl">Mahir</span>
                                </div>
                                <div class="scale-btn <%= countScaleVal == 5 ? "active-mint" : "" %>" onclick="selectScale('counting', 5, 'mint', this)"><span class="num">5</span><span class="lbl">Cemerlang</span></div>
                            </div>

                            <div class="benchmark-box <%= countScaleVal >= 4 ? "ok" : "alert" %>" id="countingBenchmarkBox">
                                <span id="countingBenchmarkText">
                                    <%= countScaleVal >= 4 ? "Mencapai Penanda Aras Umur (Skala 4: Mahir (Proficient))" : "AMARAN JURANG PERKEMBANGAN: Skor semasa di bawah penanda aras umur." %>
                                </span>
                                <span class="nb-badge <%= countScaleVal >= 4 ? "badge-success" : "badge-warning" %>" id="countingBenchmarkBadge">
                                    <%= countScaleVal >= 4 ? "Sasaran Tercapai" : "Jurang -" + (4 - countScaleVal) + " Skala" %>
                                </span>
                            </div>
                        </div>

                        <!-- 2. Komen & Pemerhatian Guru (Counting) -->
                        <div style="margin-top: 16px;">
                            <label style="font-size: 0.78rem; font-weight: 900; display: flex; align-items: center; gap: 6px; margin-bottom: 6px; color: var(--border-dark);">
                                <span style="color: #10B981; display: inline-flex; align-items: center;"><%= IconUtil.icon("MessageSquare", "icon-xs") %></span>
                                <span>Komen &amp; Pemerhatian Guru (Counting)</span>
                            </label>
                            <textarea name="counting_notes" class="nb-textarea" rows="4" placeholder="Tulis komen atau pemerhatian guru mengenai pengecaman nombor, pembilangan objek, dan konsep matematik awal murid..."><%= countNotesVal %></textarea>
                        </div>
                    </div>

                    <!-- ==========================================================================
                         LANGKAH 4: CADANGAN AKTIVITI DI RUMAH (UNTUK IBU BAPA)
                         ========================================================================== -->
                    <div class="nb-card step-panel" id="stepPanel4">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                            <div style="width: 36px; height: 36px; border-radius: 12px; background: #EEF2FF; border: 2px solid var(--border-dark); display: flex; align-items: center; justify-content: center; color: #4338CA; box-shadow: var(--shadow-sm);">
                                <%= IconUtil.icon("Home", "icon-sm") %>
                            </div>
                            <div>
                                <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 2px;">
                                    <span class="nb-badge badge-purple">LANGKAH 4</span>
                                    <h3 style="font-size: 1rem; font-weight: 900;">Cadangan Perkongsian Aktiviti di Rumah (Untuk Ibu Bapa)</h3>
                                </div>
                                <p style="font-size: 0.72rem; color: #64748B;">Saranan praktikal untuk ibu bapa terus menyokong perkembangan murid di rumah secara santai.</p>
                            </div>
                        </div>
                        <textarea name="homeRecommendation" class="nb-textarea" rows="4" placeholder="Contoh: Ibu bapa digalakkan meluangkan masa 10 minit membaca buku cerita bergambar bersama anak, mengira objek mainan semasa mengemas, dan memberi anak peluang melukis bebas..."><%= isEditMode ? savedHomeRec : "" %></textarea>
                    </div>

                    <!-- ==========================================================================
                         BOTTOM STEP NAVIGATION & SUBMIT BAR
                         ========================================================================== -->
                    <div class="nb-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                        <div style="font-size: 0.75rem; font-weight: 700; color: #475569; display: flex; align-items: center; gap: 8px; max-width: 560px;">
                            <span id="bottomStatusIcon" style="color: var(--purple-accent); display: inline-flex; align-items: center; flex-shrink: 0;">
                                <%= IconUtil.icon("Info", "icon-sm") %>
                            </span>
                            <span id="bottomStatusText">Semua skor mencapai penanda aras umur (Skala 4: Mahir (Proficient)). Data akan terus dikemas kini ke Radar Chart.</span>
                        </div>

                        <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                            <button type="button" class="nb-btn" id="btnPrevStep" onclick="prevStep()" style="display: none;">
                                <%= IconUtil.icon("ArrowLeft", "icon-xs") %>
                                <span>Sebelumnya</span>
                            </button>

                            <a href="${pageContext.request.contextPath}/ProgressServlet?studentId=${initialStudentId}" class="nb-btn" id="btnCancelForm">
                                Batal
                            </a>

                            <button type="button" class="nb-btn nb-btn-yellow" id="btnNextStep" onclick="nextStep()" style="padding: 9px 22px;">
                                <span id="btnNextLabel">Seterusnya: Writing</span>
                                <%= IconUtil.icon("ArrowRight", "icon-xs") %>
                            </button>

                            <button type="submit" class="nb-btn nb-btn-yellow" id="btnFinalSubmit" style="display: none; padding: 10px 24px;">
                                <%= IconUtil.icon("Save", "icon-xs") %>
                                <span><%= isEditMode ? "Kemas Kini Rekod Pentaksiran" : "Simpan Semua Rekod Pentaksiran (3 Teras)" %></span>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<!-- JAVASCRIPT LOGIC FOR STEP WIZARD & DYNAMIC INTERACTIONS -->
<script>
    const statusTextMap = { 1: "NOT STARTED", 2: "EMERGING", 3: "DEVELOPING", 4: "PROFICIENT", 5: "MASTERED" };
    const stepNextNames = { 1: "Seterusnya: Writing", 2: "Seterusnya: Counting", 3: "Seterusnya: Cadangan" };
    const allStudentOptions = [];
    let currentStep = 1;
    let maxUnlockedStep = <%= isEditMode ? 4 : 1 %>;

    // Peta tarikh sedia ada setiap murid dari pangkalan data Oracle
    const existingDatesByStudent = {
        <% 
           int sCount = 0;
           for (Map.Entry<Integer, List<String>> entry : studentExistingDates.entrySet()) { 
               if (sCount++ > 0) out.print(",");
        %>
        "<%= entry.getKey() %>": [<%
            List<String> dList = entry.getValue();
            for (int j = 0; j < dList.size(); j++) {
                if (j > 0) out.print(",");
                out.print("\"" + dList.get(j) + "\"");
            }
        %>]<% } %>
    };

    const isCurrentlyEditMode = <%= isEditMode %>;
    const originalEditDate = "<%= isEditMode ? editReportDate.trim() : "" %>";

    document.addEventListener("DOMContentLoaded", function () {
        const studentSelect = document.getElementById("studentSelect");
        if (studentSelect) {
            Array.from(studentSelect.options).forEach(opt => {
                allStudentOptions.push({
                    value: opt.value,
                    text: opt.text,
                    studentClass: opt.getAttribute("data-class") || "",
                    age: opt.getAttribute("data-age") || "5",
                    parent: opt.getAttribute("data-parent") || "-",
                    selected: opt.selected
                });
            });
            filterStudentsByClass(true);
        }
        updateLivePreview();
        checkWeeklyDuplicate();
        goToStep(1);
    });

    function getMondayOfWeek(dateStr) {
        const parts = dateStr.split("-");
        if (parts.length !== 3) return null;
        const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
        const day = d.getDay(); // 0 = Ahad, 1 = Isnin, ..., 6 = Sabtu
        const diff = d.getDate() - day + (day === 0 ? -6 : 1);
        const monday = new Date(d.setDate(diff));
        monday.setHours(0, 0, 0, 0);
        return monday.getTime();
    }

    function formatDisplayDate(dateStr) {
        const parts = dateStr.split("-");
        if (parts.length !== 3) return dateStr;
        return parts[2] + "/" + parts[1] + "/" + parts[0]; // DD/MM/YYYY
    }

    function checkWeeklyDuplicate() {
        const studentId = document.getElementById("formStudentID").value;
        const selectedDate = document.getElementById("progressDateInput").value;
        const warnBox = document.getElementById("weeklyWarningBox");
        const warnText = document.getElementById("weeklyWarningText");

        if (!studentId || !selectedDate || !warnBox) return;

        const dates = existingDatesByStudent[studentId] || [];
        const selectedWeekMonday = getMondayOfWeek(selectedDate);
        if (selectedWeekMonday === null) {
            warnBox.style.display = "none";
            return;
        }

        const matchingDates = dates.filter(d => {
            if (isCurrentlyEditMode && d === originalEditDate) return false;
            return getMondayOfWeek(d) === selectedWeekMonday;
        });

        if (matchingDates.length > 0) {
            const formattedList = matchingDates.map(d => "<strong>" + formatDisplayDate(d) + "</strong>").join(", ");
            const latestExistingDate = matchingDates[0];

            warnText.innerHTML =
                "Guru telah mencipta rekod pentaksiran untuk murid ini dalam minggu yang sama pada tarikh " +
                formattedList + ". Anda masih boleh menyimpan rekod baharu ini, atau " +
                "<a href='${pageContext.request.contextPath}/createProgress.jsp?studentId=" + studentId +
                "&reportDate=" + latestExistingDate + "' style='color:#B91C1C; font-weight:900; text-decoration:underline;'>kemaskini rekod sedia ada</a>.";

            warnBox.style.display = "block";
        } else {
            warnBox.style.display = "none";
        }
    }

    function goToStep(stepNum) {
        if (stepNum > maxUnlockedStep) {
            const btnNext = document.getElementById("btnNextStep");
            if (btnNext) {
                btnNext.style.transform = "scale(1.05)";
                setTimeout(() => { btnNext.style.transform = ""; }, 180);
            }
            return;
        }

        currentStep = stepNum;

        for (let i = 1; i <= 4; i++) {
            const panel = document.getElementById("stepPanel" + i);
            const tab = document.getElementById("stepTab" + i);
            const circle = document.getElementById("stepCircle" + i);
            const prevCard = document.getElementById("prevCard" + i);
            const isLocked = i > maxUnlockedStep;

            if (panel) panel.classList.toggle("active", i === stepNum);
            if (prevCard) prevCard.classList.toggle("locked", isLocked);

            if (tab) {
                tab.classList.remove("active", "completed", "locked");
                if (isLocked) {
                    tab.classList.add("locked");
                    tab.title = "Sila tekan butang 'Seterusnya' untuk membuka langkah ini";
                    if (circle) circle.innerText = i;
                } else if (i === stepNum) {
                    tab.classList.add("active");
                    tab.title = "";
                    if (circle) circle.innerText = i;
                } else if (i < maxUnlockedStep) {
                    tab.classList.add("completed");
                    tab.title = "";
                    if (circle) circle.innerHTML = "&#10003;";
                } else {
                    tab.title = "";
                    if (circle) circle.innerText = i;
                }
            }
        }

        const btnPrev = document.getElementById("btnPrevStep");
        const btnCancel = document.getElementById("btnCancelForm");
        const btnNext = document.getElementById("btnNextStep");
        const btnFinal = document.getElementById("btnFinalSubmit");

        if (btnPrev) btnPrev.style.display = (stepNum > 1) ? "inline-flex" : "none";
        if (btnCancel) btnCancel.style.display = (stepNum === 1) ? "inline-flex" : "none";

        if (stepNum < 4) {
            if (btnNext) {
                btnNext.style.display = "inline-flex";
                document.getElementById("btnNextLabel").innerText = stepNextNames[stepNum];
            }
            if (btnFinal) btnFinal.style.display = "none";
        } else {
            if (btnNext) btnNext.style.display = "none";
            if (btnFinal) btnFinal.style.display = "inline-flex";
        }
    }

    function nextStep() {
        if (currentStep < 4) {
            if (currentStep + 1 > maxUnlockedStep) {
                maxUnlockedStep = currentStep + 1;
            }
            goToStep(currentStep + 1);
            document.getElementById("stepWizardBar").scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
    }

    function prevStep() {
        if (currentStep > 1) {
            goToStep(currentStep - 1);
            document.getElementById("stepWizardBar").scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
    }

    function filterStudentsByClass(preserveInitial) {
        const selectedClass = document.getElementById("classSelect").value;
        const studentSelect = document.getElementById("studentSelect");
        const targetId = preserveInitial ? document.getElementById("formStudentID").value : studentSelect.value;

        studentSelect.innerHTML = "";

        const filtered = allStudentOptions.filter(st =>
            selectedClass === "ALL" || st.studentClass === selectedClass
        );

        if (filtered.length === 0) {
            const emptyOpt = document.createElement("option");
            emptyOpt.value = "";
            emptyOpt.text = "Tiada murid berdaftar dalam kelas ini";
            studentSelect.appendChild(emptyOpt);
            document.getElementById("formStudentID").value = "";
            document.getElementById("lblParent").innerText = "-";
            checkWeeklyDuplicate();
            return;
        }

        filtered.forEach(st => {
            const opt = document.createElement("option");
            opt.value = st.value;
            opt.text = st.text;
            opt.setAttribute("data-class", st.studentClass);
            opt.setAttribute("data-age", st.age);
            opt.setAttribute("data-parent", st.parent);
            if (st.value === targetId) {
                opt.selected = true;
            }
            studentSelect.appendChild(opt);
        });

        updateStudentContext(studentSelect);
    }

    function updateStudentContext(selectElem) {
        if (!selectElem || selectElem.selectedIndex < 0) return;
        const selectedOpt = selectElem.options[selectElem.selectedIndex];
        const age = selectedOpt.getAttribute("data-age") || "5";

        document.getElementById("formStudentID").value = selectElem.value;
        document.getElementById("lblParent").innerText = selectedOpt.getAttribute("data-parent") || "-";
        document.getElementById("lblTargetAge").innerText =
            "SASARAN UMUR " + age + " TAHUN: SKALA 4: MAHIR (PROFICIENT)";
        const prevAge = document.getElementById("lblPreviewAge");
        if (prevAge) prevAge.innerText = age + " tahun";

        updateLivePreview();
        checkWeeklyDuplicate();
    }

    function selectScale(domain, val, colorTheme, btnElem) {
        document.getElementById(domain + '_scale').value = val;
        document.getElementById('lbl' + capitalize(domain) + 'Scale').innerText = val;
        document.getElementById('lbl' + capitalize(domain) + 'Status').innerText = statusTextMap[val];
        document.getElementById('lbl' + capitalize(domain) + 'Axis').innerText = (val * 2) + '.0';

        const parent = btnElem.closest('.scale-grid');
        parent.querySelectorAll('.scale-btn').forEach(b => {
            b.classList.remove('active-yellow', 'active-coral', 'active-mint');
        });
        btnElem.classList.add('active-' + colorTheme);

        updateLivePreview();
    }

    function updateLivePreview() {
        const studentSelect = document.getElementById("studentSelect");
        let age = "5";
        if (studentSelect && studentSelect.selectedIndex >= 0) {
            age = studentSelect.options[studentSelect.selectedIndex].getAttribute("data-age") || "5";
        }

        let hasGap = false;

        ['reading', 'writing', 'counting'].forEach(dom => {
            const cap = capitalize(dom);
            const topic = document.getElementById(dom + 'Topic').value;
            const scale = parseInt(document.getElementById(dom + '_scale').value || "4", 10);

            document.getElementById('prev' + cap + 'Title').innerText = topic || ('Pentaksiran ' + cap);
            document.getElementById('prev' + cap + 'Scale').innerText = 'Skala ' + scale + '/5';
            document.getElementById('prev' + cap + 'Radar').innerText = (scale * 2) + '/10';
            const statusEl = document.getElementById('prev' + cap + 'StatusTxt');
            if (statusEl) statusEl.innerText = statusTextMap[scale];

            const prevBadge = document.getElementById('prev' + cap + 'Badge');
            const benchBox = document.getElementById(dom + 'BenchmarkBox');
            const benchText = document.getElementById(dom + 'BenchmarkText');
            const benchBadge = document.getElementById(dom + 'BenchmarkBadge');

            if (scale >= 4) {
                if (prevBadge) {
                    prevBadge.className = 'nb-badge badge-success';
                    prevBadge.innerText = 'CAPAI SASARAN';
                }
                if (benchBox) benchBox.className = 'benchmark-box ok';
                if (benchText) benchText.innerText = 'Mencapai Penanda Aras Umur (Skala 4: Mahir (Proficient))';
                if (benchBadge) {
                    benchBadge.className = 'nb-badge badge-success';
                    benchBadge.innerText = 'Sasaran Tercapai';
                }
            } else {
                hasGap = true;
                const gap = 4 - scale;
                if (prevBadge) {
                    prevBadge.className = 'nb-badge badge-warning';
                    prevBadge.innerText = 'PERLU BIMBINGAN';
                }
                if (benchBox) benchBox.className = 'benchmark-box alert';
                if (benchText) {
                    benchText.innerHTML = '<strong>AMARAN JURANG PERKEMBANGAN (ALERT GURU &amp; IBU BAPA)</strong><br>' +
                        '<span style="font-weight:600;">Murid berumur ' + age + ' tahun disasarkan mencapai Skala 4: Mahir (Proficient). Skor semasa (Skala ' + scale + ') memerlukan bimbingan intervensi. Notifikasi amaran akan dihantar serentak ke konsol Guru dan portal Ibu Bapa.</span>';
                }
                if (benchBadge) {
                    benchBadge.className = 'nb-badge badge-warning';
                    benchBadge.innerText = 'Jurang -' + gap + ' Skala';
                }
            }
        });

        const bottomText = document.getElementById('bottomStatusText');
        const bottomIcon = document.getElementById('bottomStatusIcon');
        if (bottomText) {
            if (hasGap) {
                bottomText.innerHTML = '<strong style="color:#BE123C;">Peringatan:</strong> Terdapat skor di bawah sasaran umur ' + age + ' tahun. Notifikasi intervensi akan dihantar serentak kepada Guru dan Ibu Bapa.';
                if (bottomIcon) bottomIcon.style.color = '#E11D48';
            } else {
                bottomText.innerText = 'Semua skor mencapai penanda aras umur (Skala 4: Mahir (Proficient)). Data akan terus dikemas kini ke Radar Chart.';
                if (bottomIcon) bottomIcon.style.color = 'var(--purple-accent)';
            }
        }
    }

    function capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
</script>

<jsp:include page="icons.jsp" />
</body>
</html>