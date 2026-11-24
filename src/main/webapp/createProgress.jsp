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

    int reqStudentId = -1;
    String paramSid = request.getParameter("studentId");
    if (paramSid == null || paramSid.isEmpty()) paramSid = request.getParameter("studentID");
    if (paramSid != null && !paramSid.isEmpty()) {
        try { reqStudentId = Integer.parseInt(paramSid); } catch (Exception ignored) {}
    }

    try (Connection conn = DatabaseConnection.getConnection()) {
        if (conn != null) {
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
    
    <style>
        /* ==========================================================================
           1. LAYOUT WRAPPER (SIDEBAR + HEADER + MAIN CONTENT)
           ========================================================================== */
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body, html {
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #FFFDF7;
            color: #2D3436;
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
            border-right: 3px solid #2D3436;
        }

        .app-main-wrapper {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            background-color: #FFFDF7;
        }

        .app-header-wrapper {
            flex-shrink: 0;
            background: #FFFFFF;
            border-bottom: 3px solid #2D3436;
        }

        .app-content-body {
            flex-grow: 1;
            padding: 28px 36px;
            overflow-y: auto;
        }

        /* ==========================================================================
           2. NEOBRUTALISM THEME & COMPONENT STYLES
           ========================================================================== */
        :root {
            --bg-canvas: #FFFDF7;
            --border-dark: #2D3436;
            --yellow-accent: #FFD166;
            --coral-accent: #FF6B6B;
            --mint-accent: #2EC4B6;
            --purple-accent: #7C3AED;
            --purple-light: #F3E8FF;
            --emerald-bg: #ECFDF5;
            --emerald-border: #10B981;
            --danger-bg: #FFF1F2;
            --danger-border: #F43F5E;
            --shadow-sm: 2px 2px 0px 0px var(--border-dark);
            --shadow-md: 3px 3px 0px 0px var(--border-dark);
            --shadow-lg: 4px 4px 0px 0px var(--border-dark);
        }

        .nb-wrapper, #progressForm {
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* ==========================================================================
           CLEAN PAGE HEADER (GAYA REGISTER STUDENT)
           ========================================================================== */
        .page-top-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            padding-bottom: 20px;
            border-bottom: 2px dashed #CBD5E1;
        }
        .page-top-pill {
            display: inline-block;
            background-color: var(--yellow-accent);
            color: var(--border-dark);
            border: 2px solid var(--border-dark);
            border-radius: 999px;
            padding: 4px 14px;
            font-size: 0.7rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            margin-bottom: 10px;
        }
        .page-top-title {
            font-size: 1.95rem;
            font-weight: 900;
            color: var(--border-dark);
            letter-spacing: -0.5px;
            line-height: 1.15;
        }
        .btn-back-pill {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            background-color: #FFFFFF;
            color: var(--border-dark);
            border: 2.5px solid var(--border-dark);
            border-radius: 999px;
            font-size: 0.9rem;
            font-weight: 900;
            text-decoration: none;
            box-shadow: 0px 4px 0px 0px var(--border-dark);
            transition: all 0.12s ease;
        }
        .btn-back-pill:hover {
            transform: translateY(-1px);
            box-shadow: 0px 5px 0px 0px var(--border-dark);
            background-color: #FFFBEB;
        }
        .btn-back-pill:active {
            transform: translateY(2px);
            box-shadow: 0px 2px 0px 0px var(--border-dark);
        }

        /* CARD CONTAINERS */
        .nb-card {
            background-color: #FFFFFF;
            border: 2.5px solid var(--border-dark);
            border-radius: 24px;
            padding: 20px 24px;
            box-shadow: var(--shadow-lg);
        }

        /* BADGES */
        .nb-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: 1px solid var(--border-dark);
        }
        .badge-purple { background-color: #EEF2FF; color: #4338CA; border-color: #C7D2FE; }
        .badge-mint { background-color: var(--mint-accent); color: var(--border-dark); box-shadow: 1px 1px 0px 0px var(--border-dark); }
        .badge-yellow { background-color: var(--yellow-accent); color: var(--border-dark); }
        .badge-coral { background-color: var(--coral-accent); color: #FFFFFF; }
        .badge-target { background-color: var(--purple-light); color: var(--purple-accent); border-color: #D8B4FE; }
        .badge-success { background-color: #D1FAE5; color: #065F46; border-color: #34D399; }
        .badge-warning { background-color: #FFE4E6; color: #BE123C; border-color: #F43F5E; }

        /* BUTTONS */
        .nb-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 9px 18px;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            background-color: #FFFFFF;
            color: var(--border-dark);
            font-weight: 900;
            font-size: 0.85rem;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.1s ease;
            text-decoration: none;
        }
        .nb-btn:hover { transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .nb-btn:active { transform: translate(1px, 1px); box-shadow: 1px 1px 0px 0px var(--border-dark); }
        .nb-btn-dark { background-color: var(--border-dark); color: #FFFFFF; }
        .nb-btn-yellow { background-color: var(--yellow-accent); color: var(--border-dark); box-shadow: var(--shadow-md); }
        .nb-btn-coral { background-color: var(--coral-accent); color: #FFFFFF; }
        .nb-btn-mint { background-color: var(--mint-accent); color: var(--border-dark); }

        /* INPUTS & SELECTS */
        .nb-input, .nb-select, .nb-textarea {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid var(--border-dark);
            border-radius: 16px;
            background-color: var(--bg-canvas);
            font-weight: 700;
            font-size: 0.85rem;
            color: var(--border-dark);
            outline: none;
        }
        .nb-input:focus, .nb-select:focus, .nb-textarea:focus {
            background-color: #FFFFFF;
            border-color: var(--border-dark);
            box-shadow: 0 0 0 3px rgba(255, 209, 102, 0.4);
        }

        /* LIVE PREVIEW GRID */
        .preview-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-top: 14px;
        }
        @media (max-width: 768px) { .preview-grid { grid-template-columns: 1fr; } }
        .preview-card {
            background-color: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 18px;
            padding: 14px;
            box-shadow: var(--shadow-md);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            cursor: pointer;
            transition: transform 0.12s ease, opacity 0.15s ease;
        }
        .preview-card:hover { transform: translateY(-2px); }
        .preview-card.locked {
            opacity: 0.65;
            cursor: not-allowed;
        }
        .preview-card.locked:hover {
            transform: none;
        }

        /* ==========================================================================
           3. STEP WIZARD BAR (GAYA REGISTER STUDENT: SOLID YELLOW ACTIVE + MUTED LOCKED)
           ========================================================================== */
        .step-wizard-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
        }
        @media (max-width: 960px) { .step-wizard-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 540px) { .step-wizard-grid { grid-template-columns: 1fr; } }

        .step-pill-btn {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 18px;
            background-color: #FFFFFF;
            border: 2px solid #64748B;
            border-radius: 20px;
            cursor: pointer;
            text-align: left;
            transition: all 0.15s ease;
        }
        .step-pill-btn:hover:not(.locked):not(.active) {
            border-color: var(--border-dark);
            background-color: #FFFDF7;
        }

        /* Active Step: Kuning Penuh + Shadow Gelap + Bulatan Nombor Hitam */
        .step-pill-btn.active {
            background-color: var(--yellow-accent);
            border: 2.5px solid var(--border-dark);
            box-shadow: 0px 4px 0px 0px var(--border-dark);
        }

        /* Completed Step (Sudah dilalui & boleh diklik semula) */
        .step-pill-btn.completed {
            background-color: #FFFFFF;
            border: 2px solid var(--border-dark);
            box-shadow: 0px 2px 0px 0px var(--border-dark);
        }

        /* Locked Step (Belum tekan Seterusnya) */
        .step-pill-btn.locked {
            background-color: #FFFFFF;
            border: 2px solid #94A3B8;
            opacity: 0.72;
            cursor: not-allowed;
        }

        .step-num-circle {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 2px solid #64748B;
            background-color: #FFFFFF;
            color: #475569;
            font-weight: 900;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.15s ease;
        }
        .step-pill-btn.active .step-num-circle {
            background-color: var(--border-dark);
            border-color: var(--border-dark);
            color: #FFFFFF;
        }
        .step-pill-btn.completed .step-num-circle {
            background-color: #D1FAE5;
            border-color: var(--border-dark);
            color: #065F46;
        }

        .step-pill-title {
            font-size: 0.92rem;
            font-weight: 900;
            color: #475569;
            line-height: 1.2;
        }
        .step-pill-sub {
            font-size: 0.74rem;
            font-weight: 700;
            color: #64748B;
            margin-top: 2px;
        }
        .step-pill-btn.active .step-pill-title,
        .step-pill-btn.completed .step-pill-title {
            color: var(--border-dark);
        }
        .step-pill-btn.active .step-pill-sub {
            color: #334155;
        }

        .step-panel { display: none; }
        .step-panel.active { display: block; animation: fadeStepIn 0.18s ease-out; }
        @keyframes fadeStepIn {
            from { opacity: 0; transform: translateY(4px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* CHECKLIST ITEMS */
        .checklist-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            border-radius: 14px;
            border: 2px solid var(--border-dark);
            margin-bottom: 8px;
            background-color: #FFFFFF;
            cursor: pointer;
            transition: all 0.15s;
        }
        .checklist-item.checked-yellow { background-color: #FFFBEB; border-color: #F59E0B; }
        .checklist-item.checked-coral { background-color: #FFF1F2; border-color: #F43F5E; }
        .checklist-item.checked-mint { background-color: #ECFDF5; border-color: #10B981; }

        .check-box {
            width: 22px; height: 22px;
            border-radius: 50%;
            border: 2px solid var(--border-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            font-size: 12px;
            font-weight: 900;
            background: #FFF;
            flex-shrink: 0;
        }
        .checked-yellow .check-box { background: var(--yellow-accent); }
        .checked-coral .check-box { background: var(--coral-accent); color: #FFF; }
        .checked-mint .check-box { background: var(--mint-accent); }

        .btn-del-crit {
            background: transparent;
            border: none;
            color: #94A3B8;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 4px;
            border-radius: 6px;
        }
        .btn-del-crit:hover { color: #EF4444; background-color: #FEE2E2; }

        /* RATING SCALE 1 - 5 GRID */
        .scale-selector-container {
            background-color: var(--bg-canvas);
            border: 2px solid var(--border-dark);
            border-radius: 18px;
            padding: 16px;
            margin-top: 16px;
            box-shadow: var(--shadow-sm);
        }
        .scale-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-top: 12px;
        }
        .scale-btn {
            position: relative;
            background: #FFFFFF;
            border: 2px solid var(--border-dark);
            border-radius: 14px;
            padding: 10px 6px;
            text-align: center;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all 0.15s;
        }
        .scale-btn .num { font-size: 1.2rem; font-weight: 900; display: block; }
        .scale-btn .lbl { font-size: 0.7rem; font-weight: 700; color: #64748B; }

        /* ACTIVE SCALE COLORED STATES */
        .scale-btn.active-yellow { background-color: var(--yellow-accent); transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .scale-btn.active-coral { background-color: var(--coral-accent); color: #FFF; transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }
        .scale-btn.active-coral .lbl { color: #FFE4E6; }
        .scale-btn.active-mint { background-color: var(--mint-accent); transform: translate(-1px, -1px); box-shadow: var(--shadow-md); }

        .target-pill {
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--purple-accent);
            color: #FFF;
            font-size: 0.55rem;
            font-weight: 900;
            padding: 1px 8px;
            border-radius: 999px;
            border: 1px solid var(--border-dark);
            text-transform: uppercase;
        }

        /* BENCHMARK STATUS BOX (GREEN vs RED DANGER ALERT) */
        .benchmark-box {
            border-radius: 14px;
            padding: 12px 16px;
            margin-top: 14px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            font-size: 0.75rem;
            font-weight: 800;
            line-height: 1.45;
        }
        .benchmark-box.ok {
            background: var(--emerald-bg);
            border: 1.5px solid var(--emerald-border);
            color: #065F46;
            align-items: center;
        }
        .benchmark-box.alert {
            background-color: var(--danger-bg);
            border: 2px solid var(--danger-border);
            color: #9F1239;
            box-shadow: 2.5px 2.5px 0px 0px var(--danger-border);
        }
    </style>
</head>
<body>

<div class="app-layout">

    <!-- 1. SIDEBAR INCLUDE -->
    <aside class="app-sidebar-wrapper">
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
                         CLEAN PAGE HEADER (GAYA REGISTER STUDENT + GARISAN PUTUS-PUTUS)
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
                                    <!-- Dropdown 1: Pilihan Kelas dari Oracle -->
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

                                    <!-- Dropdown 2: Sasaran Murid Dinilai dari Oracle -->
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

                                    <!-- Badge Sasaran Umur & Nama Ibu Bapa -->
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

                            <!-- Kotak Tengah: Tarikh Pentaksiran -->
                            <div style="background: #FFF; border: 2px solid var(--border-dark); border-radius: 18px; padding: 14px 16px; box-shadow: var(--shadow-sm);">
                                <label style="font-size: 0.65rem; font-weight: 900; text-transform: uppercase; color: #64748B; display: flex; align-items: center; gap: 5px; margin-bottom: 6px;">
                                    <%= IconUtil.icon("Calendar", "icon-xs") %>
                                    <span>TARIKH PENTAKSIRAN</span>
                                </label>
                                <input type="date" name="progressDate" class="nb-input" value="<%= formDateVal %>" required>
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
                                        Penguasaan: <strong id="prevReadingCount">4/5</strong> kriteria standard konstruk KSPK.
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
                                        Penguasaan: <strong id="prevWritingCount">4/5</strong> kriteria standard konstruk KSPK.
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
                                        Penguasaan: <strong id="prevCountingCount">4/5</strong> kriteria standard konstruk KSPK.
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
                         4-STEP WIZARD BAR (DI ATAS PANEL TERAS + TERKUNCI HINGGA TEKAN SETERUSNYA)
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
                            <button type="button" class="nb-btn" onclick="resetRubric('reading')">
                                <%= IconUtil.icon("RotateCcw", "icon-xs") %>
                                <span>Reset Rubrik Reading</span>
                            </button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Reading <span style="color:red;">*</span></label>
                        <input type="text" name="reading_progressName" id="readingTopic" class="nb-input" value="<%= readTopicVal %>" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #FFFBEB; border: 2px solid #FCD34D; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #F59E0B; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #B45309;" id="readingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #78350F;" id="readingRatioTitle">4 daripada 5 Kriteria Reading Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #92400E;">Cadangan skala automatik: <strong id="readingSuggestedLbl">Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-yellow" onclick="applySuggestedScale('reading')">
                                <%= IconUtil.icon("Sparkles", "icon-xs") %>
                                <span>Gunakan Skor Cadangan</span>
                            </button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="readingCriteriaList">
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Mengecam dan membunyikan huruf vokal (a, e, i, o, u) dengan tepat</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'reading')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Membunyikan konsonan asas secara fonik tanpa kekeliruan</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'reading')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Menggabungkan bunyi konsonan dan vokal menjadi suku kata terbuka (KV)</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'reading')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-yellow" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Membaca perkataan mudah suku kata tertutup (CVC / KVK)</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'reading')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'reading')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Mendengar dan mengulang sebutan intonasi bacaan dengan yakin</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'reading')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customReadingInput" class="nb-input" placeholder="Tambah kriteria bacaan khusus...">
                            <button type="button" class="nb-btn nb-btn-yellow" onclick="addCustomCriteria('reading')">
                                <%= IconUtil.icon("Plus", "icon-xs") %>
                                <span>Tambah</span>
                            </button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
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
                            <button type="button" class="nb-btn" onclick="resetRubric('writing')">
                                <%= IconUtil.icon("RotateCcw", "icon-xs") %>
                                <span>Reset Rubrik Writing</span>
                            </button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Writing <span style="color:red;">*</span></label>
                        <input type="text" name="writing_progressName" id="writingTopic" class="nb-input" value="<%= writeTopicVal %>" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #FFF1F2; border: 2px solid #FDA4AF; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #F43F5E; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #BE185D;" id="writingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #881337;" id="writingRatioTitle">4 daripada 5 Kriteria Writing Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #9F1239;">Cadangan skala automatik: <strong id="writingSuggestedLbl">Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-coral" onclick="applySuggestedScale('writing')">
                                <%= IconUtil.icon("Sparkles", "icon-xs") %>
                                <span>Gunakan Skor Cadangan</span>
                            </button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="writingCriteriaList">
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Memegang pensel menggunakan genggaman dinamik tripod dengan selesa</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'writing')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Mengawal tekanan pensel pada kertas tanpa merosakkan lembaran</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'writing')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Menyambung garisan titik (lurus, beralun, zig-zag) dengan kemas</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'writing')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-coral" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Melukis bentuk geometri asas dengan kawalan pergerakan tangan yang stabil</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'writing')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'writing')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Mengekalkan postur badan yang ergonomik semasa aktiviti menulis</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'writing')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customWritingInput" class="nb-input" placeholder="Tambah kriteria penulisan khusus...">
                            <button type="button" class="nb-btn nb-btn-coral" onclick="addCustomCriteria('writing')">
                                <%= IconUtil.icon("Plus", "icon-xs") %>
                                <span>Tambah</span>
                            </button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
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
                            <button type="button" class="nb-btn" onclick="resetRubric('counting')">
                                <%= IconUtil.icon("RotateCcw", "icon-xs") %>
                                <span>Reset Rubrik Counting</span>
                            </button>
                        </div>

                        <label style="font-size: 0.75rem; font-weight: 900; display: block; margin-bottom: 4px;">Tajuk / Topik Pentaksiran Counting <span style="color:red;">*</span></label>
                        <input type="text" name="counting_progressName" id="countingTopic" class="nb-input" value="<%= countTopicVal %>" oninput="updateLivePreview()">

                        <!-- Suggested Score Banner -->
                        <div style="background: #ECFDF5; border: 2px solid #6EE7B7; border-radius: 16px; padding: 12px 16px; margin: 14px 0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #FFF; border: 2px solid #10B981; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.8rem; color: #047857;" id="countingRatioBadge">
                                    4/5
                                </div>
                                <div>
                                    <h5 style="font-size: 0.8rem; font-weight: 900; color: #064E3B;" id="countingRatioTitle">4 daripada 5 Kriteria Counting Telah Dikuasai</h5>
                                    <p style="font-size: 0.7rem; color: #065F46;">Cadangan skala automatik: <strong id="countingSuggestedLbl">Skala 4 / 5</strong></p>
                                </div>
                            </div>
                            <button type="button" class="nb-btn nb-btn-mint" onclick="applySuggestedScale('counting')">
                                <%= IconUtil.icon("Sparkles", "icon-xs") %>
                                <span>Gunakan Skor Cadangan</span>
                            </button>
                        </div>

                        <!-- Checklist Items -->
                        <div id="countingCriteriaList">
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">1. Menyebut turutan nombor 1 hingga 20+ secara lisan dengan lancar</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'counting')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">2. Membilang objek konkrit dengan padanan satu-ke-satu (1-to-1 correspondence)</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'counting')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">3. Memadankan simbol angka dengan kuantiti objek yang betul</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'counting')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item checked-mint" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"><%= IconUtil.icon("Check", "icon-xs") %></div>
                                    <span style="font-size: 0.8rem; font-weight: 800;">4. Mengecam angka yang hilang dalam urutan nombor mudah</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'counting')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                            <div class="checklist-item" onclick="toggleCriteria(this, 'counting')">
                                <div style="display: flex; align-items: center;">
                                    <div class="check-box"></div>
                                    <span style="font-size: 0.8rem; font-weight: 700; color: #475569;">5. Membezakan konsep kuantiti: "lebih banyak", "lebih sedikit", "sama banyak"</span>
                                </div>
                                <button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, 'counting')" title="Padam kriteria">
                                    <%= IconUtil.icon("Trash2", "icon-xs") %>
                                </button>
                            </div>
                        </div>

                        <!-- Custom Criteria Add Input -->
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <input type="text" id="customCountingInput" class="nb-input" placeholder="Tambah kriteria pengiraan khusus...">
                            <button type="button" class="nb-btn nb-btn-mint" onclick="addCustomCriteria('counting')">
                                <%= IconUtil.icon("Plus", "icon-xs") %>
                                <span>Tambah</span>
                            </button>
                        </div>

                        <!-- Rating Scale Selector (1-5) -->
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

<!-- Bekas ikon SVG tersembunyi untuk kriteria baharu yang ditambah melalui JS -->
<div id="tplCheckIcon" style="display: none;"><%= IconUtil.icon("Check", "icon-xs") %></div>
<div id="tplTrashIcon" style="display: none;"><%= IconUtil.icon("Trash2", "icon-xs") %></div>

<!-- JAVASCRIPT LOGIC FOR STEP WIZARD & DYNAMIC INTERACTIONS -->
<script>
    const statusTextMap = { 1: "NOT STARTED", 2: "EMERGING", 3: "DEVELOPING", 4: "PROFICIENT", 5: "MASTERED" };
    const stepNextNames = { 1: "Seterusnya: Writing", 2: "Seterusnya: Counting", 3: "Seterusnya: Cadangan" };
    const allStudentOptions = [];
    let currentStep = 1;
    let maxUnlockedStep = <%= isEditMode ? 4 : 1 %>;

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
        goToStep(1);
    });

    function goToStep(stepNum) {
        // Sekat akses jika langkah belum dibuka melalui butang "Seterusnya"
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
        const btnSaveDirect = document.getElementById("btnSaveDirect");
        const btnNext = document.getElementById("btnNextStep");
        const btnFinal = document.getElementById("btnFinalSubmit");

        if (btnPrev) btnPrev.style.display = (stepNum > 1) ? "inline-flex" : "none";
        if (btnCancel) btnCancel.style.display = (stepNum === 1) ? "inline-flex" : "none";

        if (stepNum < 4) {
            if (btnSaveDirect) btnSaveDirect.style.display = "inline-flex";
            if (btnNext) {
                btnNext.style.display = "inline-flex";
                document.getElementById("btnNextLabel").innerText = stepNextNames[stepNum];
            }
            if (btnFinal) btnFinal.style.display = "none";
        } else {
            if (btnSaveDirect) btnSaveDirect.style.display = "none";
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

    function toggleCriteria(itemElem, domain) {
        const checkbox = itemElem.querySelector('.check-box');
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');

        if (itemElem.classList.contains(colorClass)) {
            itemElem.classList.remove(colorClass);
            checkbox.innerHTML = '';
        } else {
            itemElem.classList.add(colorClass);
            checkbox.innerHTML = document.getElementById('tplCheckIcon').innerHTML;
        }
        updateCriteriaCount(domain);
    }

    function removeCriteria(event, btnElem, domain) {
        event.stopPropagation();
        const item = btnElem.closest('.checklist-item');
        if (item) {
            item.remove();
            updateCriteriaCount(domain);
        }
    }

    function addCustomCriteria(domain) {
        const input = document.getElementById('custom' + capitalize(domain) + 'Input');
        const text = input.value.trim();
        if (!text) return;

        const container = document.getElementById(domain + 'CriteriaList');
        const count = container.querySelectorAll('.checklist-item').length + 1;
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');

        const div = document.createElement('div');
        div.className = 'checklist-item ' + colorClass;
        div.setAttribute('onclick', "toggleCriteria(this, '" + domain + "')");
        div.innerHTML =
            '<div style="display: flex; align-items: center;">' +
                '<div class="check-box">' + document.getElementById('tplCheckIcon').innerHTML + '</div>' +
                '<span style="font-size: 0.8rem; font-weight: 800;">' + count + '. ' + escapeHtml(text) + '</span>' +
            '</div>' +
            '<button type="button" class="btn-del-crit" onclick="removeCriteria(event, this, \'' + domain + '\')" title="Padam kriteria">' +
                document.getElementById('tplTrashIcon').innerHTML +
            '</button>';

        container.appendChild(div);
        input.value = '';
        updateCriteriaCount(domain);
    }

    function resetRubric(domain) {
        const container = document.getElementById(domain + 'CriteriaList');
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');
        container.querySelectorAll('.checklist-item').forEach(item => {
            item.classList.remove(colorClass);
            item.querySelector('.check-box').innerHTML = '';
        });
        updateCriteriaCount(domain);
    }

    function getSuggestedScaleValue(domain) {
        const container = document.getElementById(domain + 'CriteriaList');
        const total = container.querySelectorAll('.checklist-item').length;
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');
        const checked = container.querySelectorAll('.' + colorClass).length;

        const ratio = checked / (total || 1);
        if (ratio >= 0.9) return 5;
        if (ratio >= 0.7) return 4;
        if (ratio >= 0.5) return 3;
        if (ratio >= 0.25) return 2;
        return 1;
    }

    function updateCriteriaCount(domain) {
        const container = document.getElementById(domain + 'CriteriaList');
        const total = container.querySelectorAll('.checklist-item').length;
        const colorClass = 'checked-' + (domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint');
        const checked = container.querySelectorAll('.' + colorClass).length;
        const suggested = getSuggestedScaleValue(domain);

        document.getElementById(domain + 'RatioBadge').innerText = checked + '/' + total;
        document.getElementById(domain + 'RatioTitle').innerText = checked + ' daripada ' + total + ' Kriteria ' + capitalize(domain) + ' Telah Dikuasai';
        document.getElementById(domain + 'SuggestedLbl').innerText = 'Skala ' + suggested + ' / 5';
        document.getElementById('prev' + capitalize(domain) + 'Count').innerText = checked + '/' + total;
    }

    function applySuggestedScale(domain) {
        const suggested = getSuggestedScaleValue(domain);
        const colorTheme = domain === 'reading' ? 'yellow' : domain === 'writing' ? 'coral' : 'mint';
        const targetBtn = document.querySelectorAll('#stepPanel' + (domain === 'reading' ? 1 : domain === 'writing' ? 2 : 3) + ' .scale-btn')[suggested - 1];
        if (targetBtn) {
            selectScale(domain, suggested, colorTheme, targetBtn);
        }
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

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.innerText = text;
        return div.innerHTML;
    }
</script>

<jsp:include page="icons.jsp" />
</body>
</html>