<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.IconUtil"%>

<%
    String mrRole = (session.getAttribute("role") != null)
            ? session.getAttribute("role").toString()
            : (session.getAttribute("userRole") != null)
            ? session.getAttribute("userRole").toString()
            : "Teacher";
    boolean mrIsAdmin = "Admin".equalsIgnoreCase(mrRole.trim());
%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/monthlyReport.css">

<!-- MONTHLY PROGRESS REPORT MODAL POPUP -->
<div id="monthlyReportModal" class="mr-backdrop" onclick="if(event.target === this) closeMonthlyReportModal()">
    <div class="mr-modal-box">

        <!-- 1. Modal Yellow Header -->
        <div class="mr-modal-header mr-no-print">
            <div class="mr-header-brand">
                <div class="mr-header-icon">
                    <%= IconUtil.icon("Award", "icon-sm") %>
                </div>
                <div>
                    <h3 class="mr-header-title">Generate Monthly Progress Report</h3>
                    <p class="mr-header-sub">Official Learning Progress Certificate &bull; <span id="mrHeaderMonth">Loading...</span></p>
                </div>
            </div>

            <div class="mr-header-btns">
                <button type="button" onclick="closeMonthlyReportModal()" class="mr-btn mr-btn-close" title="Close">
                    <%= IconUtil.icon("X", "icon-xs") %>
                </button>
            </div>
        </div>

        <!-- 2. Controls Bar (Locked Student + Month Dropdown) -->
        <div class="mr-controls mr-no-print">
            <div class="mr-controls-group">
                <div class="mr-field">
                    <span class="mr-field-lbl">Student:</span>
                    <div class="mr-locked-pill" title="Murid dikunci mengikut pilihan yang dibuka">
                        <%= IconUtil.icon("Lock", "icon-xs") %>
                        <span id="mrLockedStudentText">Loading...</span>
                    </div>
                </div>

                <div class="mr-field">
                    <label for="mrMonthDropdown" class="mr-field-lbl">Month:</label>
                    <select id="mrMonthDropdown" class="mr-month-select" onchange="changeReportMonth(this.value)">
                        <option value="">Loading...</option>
                    </select>
                </div>
            </div>

            <span id="mrWeeksBadge" style="font-size: 0.72rem; font-weight: 900; color: #4338CA; background: #EEF2FF; border: 1.5px solid #C7D2FE; padding: 4px 12px; border-radius: 999px;">
                Purata Bulanan: 0 Minggu Rekod
            </span>
        </div>

        <!-- 3. Certificate Content Body -->
        <div class="mr-scroll-body">
            <div class="mr-cert-frame">

                <!-- Top School Branding -->
                <div class="mr-cert-top">
                    <div class="mr-cert-brand">
                        <div class="mr-cert-emblem">
                            <%= IconUtil.icon("GraduationCap", "icon-md") %>
                        </div>
                        <div>
                            <h2 class="mr-cert-title">Keedflix Kindergarten Centre</h2>
                            <p class="mr-cert-subtitle">Monthly Learning Progress Assessment Report</p>
                            <p class="mr-cert-desc">Licensed Early Childhood Literacy &amp; Numeracy Academy</p>
                        </div>
                    </div>

                    <div class="mr-cert-status">
                        <span class="mr-badge-certified">STATUS: CERTIFIED</span>
                        <p class="mr-period">Period: <span id="mrCertPeriod">-</span></p>
                    </div>
                </div>

                <!-- Student Metadata -->
                <div class="mr-meta-grid">
                    <div>
                        <span class="mr-meta-lbl">Student Name</span>
                        <p class="mr-meta-val" id="mrMetaName">-</p>
                    </div>
                    <div>
                        <span class="mr-meta-lbl">Class Cohort</span>
                        <p class="mr-meta-val" id="mrMetaClass">-</p>
                    </div>
                    <div>
                        <span class="mr-meta-lbl">Age</span>
                        <p class="mr-meta-val" id="mrMetaAge">-</p>
                    </div>
                </div>

                <!-- Core Domain Progress Evaluation -->
                <div>
                    <h4 class="mr-sec-heading">
                        <%= IconUtil.icon("Award", "icon-xs") %>
                        <span>Core Domain Progress Evaluation</span>
                    </h4>

                    <div class="mr-domains-grid">
                        <!-- Reading -->
                        <div class="mr-dom-card reading">
                            <div class="mr-dom-top">
                                <div class="mr-dom-name">
                                    <%= IconUtil.icon("BookOpen", "icon-xs") %>
                                    <span>Reading &amp; Phonics</span>
                                </div>
                                <span class="mr-dom-pct" id="mrReadPct">0%</span>
                            </div>
                            <div class="mr-bar-track">
                                <div class="mr-bar-fill fill-read" id="mrReadBar" style="width: 0%;"></div>
                            </div>
                            <ul class="mr-skills-ul" id="mrReadTopics"></ul>
                        </div>

                        <!-- Writing -->
                        <div class="mr-dom-card writing">
                            <div class="mr-dom-top">
                                <div class="mr-dom-name">
                                    <%= IconUtil.icon("PenTool", "icon-xs") %>
                                    <span>Writing &amp; Penmanship</span>
                                </div>
                                <span class="mr-dom-pct" id="mrWritePct">0%</span>
                            </div>
                            <div class="mr-bar-track">
                                <div class="mr-bar-fill fill-write" id="mrWriteBar" style="width: 0%;"></div>
                            </div>
                            <ul class="mr-skills-ul" id="mrWriteTopics"></ul>
                        </div>

                        <!-- Counting -->
                        <div class="mr-dom-card counting">
                            <div class="mr-dom-top">
                                <div class="mr-dom-name">
                                    <%= IconUtil.icon("Hash", "icon-xs") %>
                                    <span>Counting &amp; Numbers</span>
                                </div>
                                <span class="mr-dom-pct" id="mrCountPct">0%</span>
                            </div>
                            <div class="mr-bar-track">
                                <div class="mr-bar-fill fill-count" id="mrCountBar" style="width: 0%;"></div>
                            </div>
                            <ul class="mr-skills-ul" id="mrCountTopics"></ul>
                        </div>
                    </div>
                </div>

                <!-- Overall Developmental Mastery Index -->
                <div class="mr-mastery-box">
                    <div class="mr-mastery-left">
                        <div class="mr-star-icon">
                            <%= IconUtil.icon("Star", "icon-sm") %>
                        </div>
                        <div>
                            <p style="font-size: 0.9rem; font-weight: 900; color: #2D3436;">
                                Overall Developmental Mastery Index
                            </p>
                            <p style="font-size: 0.72rem; color: #475569; font-weight: 600;">
                                Cumulative composite across foundational literacy, penmanship, and numeracy
                            </p>
                        </div>
                    </div>

                    <div>
                        <span class="mr-overall-num" id="mrOverallScore">0%</span>
                        <span class="mr-overall-lvl" id="mrMasteryLevel">-</span>
                    </div>
                </div>

                <!-- Lead Educator Observational Notes -->
                <div class="mr-remarks">
                    <span class="mr-meta-lbl" style="margin-bottom: 4px;">Lead Educator Observational Notes</span>
                    <p style="font-size: 0.8rem; font-style: italic; font-weight: 600; color: #2D3436; line-height: 1.5;" id="mrReportNote">
                        "-"
                    </p>
                </div>

                <!-- Administrative Endorsement & Signature -->
                <div class="mr-endorsement">
                    <div>
                        <div style="display: flex; align-items: center; gap: 6px; font-size: 0.82rem; font-weight: 900; margin-bottom: 4px;">
                            <%= IconUtil.icon("ShieldCheck", "icon-xs") %>
                            <span>Administrative Endorsement</span>
                        </div>
                        <p style="font-size: 0.72rem; color: #64748B; font-weight: 600; line-height: 1.45;">
                            This document verifies that <strong id="mrEndorseName">-</strong> has completed the
                            <strong id="mrEndorseMonth">-</strong> developmental assessment cycle at Keedflix Centre.
                        </p>
                        <p style="font-family: monospace; font-size: 0.68rem; color: #94A3B8; margin-top: 6px;">
                            Verification ID: <span id="mrVerifyId">-</span>
                        </p>
                    </div>

                    <div style="text-align: right; display: flex; flex-direction: column; align-items: flex-end;">
                        <div style="border-bottom: 2px solid #2D3436; padding-bottom: 4px; min-width: 210px; margin-bottom: 4px; font-size: 0.88rem; font-weight: 900;" id="mrAdminSig">
                            -
                        </div>
                        <p style="font-size: 0.62rem; font-weight: 800; text-transform: uppercase; color: #64748B;">
                            Keedflix Centre Administration Seal &amp; Signature
                        </p>
                    </div>
                </div>

            </div>
        </div>

        <!-- 4. Modal Bottom Bar -->
        <div class="mr-modal-footer mr-no-print">
            <span style="color: #64748B; font-weight: 700;">Report ready for export or classroom filing.</span>
            <div style="display: flex; align-items: center; gap: 8px;">
                <button type="button" onclick="closeMonthlyReportModal()" class="mr-btn">Done</button>
                <% if (mrIsAdmin) { %>
                    <button type="button" onclick="window.print()" class="mr-btn mr-btn-yellow">
                        <%= IconUtil.icon("Download", "icon-xs") %>
                        <span>Download Report</span>
                    </button>
                <% } %>
            </div>
        </div>

    </div>
</div>

<script>
    let activeReportStudentId = null;

    function openMonthlyReportModal(studentId, monthVal) {
        activeReportStudentId = studentId;
        const modal = document.getElementById("monthlyReportModal");
        modal.classList.add("open");
        document.body.style.overflow = "hidden";

        let url = "${pageContext.request.contextPath}/MonthlyReportServlet?studentId=" + encodeURIComponent(studentId);
        if (monthVal) {
            url += "&month=" + encodeURIComponent(monthVal);
        }

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    alert(data.error);
                    closeMonthlyReportModal();
                    return;
                }
                renderMonthlyReportData(data);
            })
            .catch(err => console.error("Gagal memuatkan laporan bulanan:", err));
    }

    function changeReportMonth(monthVal) {
        if (activeReportStudentId) {
            openMonthlyReportModal(activeReportStudentId, monthVal);
        }
    }

    function closeMonthlyReportModal() {
        const modal = document.getElementById("monthlyReportModal");
        modal.classList.remove("open");
        document.body.style.overflow = "";
    }

    function renderMonthlyReportData(d) {
        document.getElementById("mrHeaderMonth").innerText = d.selectedMonthLabel;
        document.getElementById("mrLockedStudentText").innerText = d.studentName + " (" + d.studentClass + ")";
        document.getElementById("mrWeeksBadge").innerText = "Purata Bulanan: " + d.weeksCount + " Minggu Rekod";

        const sel = document.getElementById("mrMonthDropdown");
        sel.innerHTML = "";
        (d.months || []).forEach(m => {
            const opt = document.createElement("option");
            opt.value = m.value;
            opt.text = m.label;
            if (m.value === d.selectedMonth) opt.selected = true;
            sel.appendChild(opt);
        });

        document.getElementById("mrCertPeriod").innerText = d.selectedMonthLabel;
        document.getElementById("mrMetaName").innerText = d.studentName;
        document.getElementById("mrMetaClass").innerText = d.studentClass;
        document.getElementById("mrMetaAge").innerText = d.studentAge + " Years";

        document.getElementById("mrReadPct").innerText = d.readingScore + "%";
        document.getElementById("mrReadBar").style.width = d.readingScore + "%";
        renderTopicList("mrReadTopics", d.readingTopics);

        document.getElementById("mrWritePct").innerText = d.writingScore + "%";
        document.getElementById("mrWriteBar").style.width = d.writingScore + "%";
        renderTopicList("mrWriteTopics", d.writingTopics);

        document.getElementById("mrCountPct").innerText = d.countingScore + "%";
        document.getElementById("mrCountBar").style.width = d.countingScore + "%";
        renderTopicList("mrCountTopics", d.countingTopics);

        document.getElementById("mrOverallScore").innerText = d.overallScore + "%";
        document.getElementById("mrMasteryLevel").innerText = d.masteryLevel;
        document.getElementById("mrReportNote").innerText = '"' + d.reportNote + '"';

        document.getElementById("mrEndorseName").innerText = d.studentName;
        document.getElementById("mrEndorseMonth").innerText = d.selectedMonthLabel;
        document.getElementById("mrVerifyId").innerText = d.verificationId;
        document.getElementById("mrAdminSig").innerText = d.adminSignature;
    }

    function renderTopicList(ulId, topics) {
        const ul = document.getElementById(ulId);
        ul.innerHTML = "";
        if (!topics || topics.length === 0) {
            ul.innerHTML = "<li><span>&#10003;</span><span>Tiada rekod minggu pada bulan ini</span></li>";
            return;
        }
        topics.forEach(t => {
            const li = document.createElement("li");
            li.innerHTML = "<span>&#10003;</span><span>" + escapeHtml(t) + "</span>";
            ul.appendChild(li);
        });
    }

    function escapeHtml(str) {
        const div = document.createElement("div");
        div.innerText = str;
        return div.innerHTML;
    }
</script>