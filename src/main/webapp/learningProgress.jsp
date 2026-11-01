<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="bean.Student"%>
<%@ page import="bean.LearningProgress"%>
<%
    Student student = (Student) request.getAttribute("currentStudent");
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    List<LearningProgress> progressList = (List<LearningProgress>) request.getAttribute("progressList");

    if (studentList == null) {
        studentList = new ArrayList<>();
    }
    if (progressList == null) {
        progressList = new ArrayList<>();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Learning Progress - <%= (student != null) ? student.getStudentName() : "Keedflix Centre" %></title>
    <style>
        /* --- NEOBRUTALISM STYLING --- */
        * { box-sizing: border-box; }
        html, body { height: 100%; margin: 0; background-color: #FAF5EF; color: #2D3436; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; overflow: hidden; }
        
        .app-layout { display: flex; height: 100vh; width: 100%; }
        .app-sidebar-wrapper { width: 280px; flex-shrink: 0; background-color: #FFFFFF; border-right: 3px solid #2D3436; }
        .app-main-wrapper { flex-grow: 1; display: flex; flex-direction: column; min-width: 0; height: 100vh; overflow: hidden; }
        .app-header-wrapper { flex-shrink: 0; background-color: #FFFFFF; border-bottom: 3px solid #2D3436 !important; }
        .app-content-body { padding: 32px; flex-grow: 1; overflow-y: auto; background-color: #FAF5EF; display: flex; justify-content: center; }
        
        .container { width: 100%; max-width: 1100px; display: flex; flex-direction: column; gap: 24px; padding-bottom: 60px; }
        
        /* Neobrutalist Cards */
        .neo-card { background: #FFF; border: 3px solid #2D3436; border-radius: 24px; padding: 28px; box-shadow: 4px 4px 0px 0px #2D3436; }
        
        /* Form Inputs & Selectors */
        .neo-label { display: block; font-weight: 900; font-size: 0.95rem; margin-bottom: 8px; color: #2D3436; }
        .neo-select { width: 100%; padding: 14px 20px; border: 2.5px solid #2D3436; border-radius: 999px; font-weight: 700; font-size: 0.95rem; box-shadow: 2px 2px 0px 0px #2D3436; outline: none; background: #FFF; cursor: pointer; }
        
        /* Buttons */
        .btn-neo { padding: 10px 20px; border: 2.5px solid #2D3436; border-radius: 14px; font-weight: 900; cursor: pointer; box-shadow: 3px 3px 0px #2D3436; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: #2D3436; background: #FFF; transition: transform 0.1s; font-size: 0.85rem; }
        .btn-neo:active { transform: translate(2px, 2px); box-shadow: 1px 1px 0px #2D3436; }
        .btn-mint { background-color: #7BE495; }
        .btn-yellow { background-color: #FFD02C; }
        .btn-rose { background-color: #FFE3E3; color: #D10000; border-color: #D10000; }
        
        /* Badges */
        .badge-console { background-color: #FFD02C; color: #2D3436; font-size: 10px; font-weight: 900; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436; text-transform: uppercase; display: inline-block; margin-bottom: 8px; }
        .badge-domain { font-size: 10px; font-weight: 900; padding: 4px 10px; border-radius: 8px; border: 2px solid #2D3436; text-transform: uppercase; }
        .badge-reading { background-color: #EED6FF; color: #6B21A8; }
        .badge-writing { background-color: #FFE3E3; color: #9B1C1C; }
        .badge-counting { background-color: #FEF08A; color: #854D0E; }
        
        .status-pill { font-size: 11px; font-weight: 900; padding: 4px 12px; border-radius: 999px; border: 2px solid #2D3436; background: #F3F4F6; display: inline-flex; align-items: center; gap: 6px; }
        
        /* Ledger Items */
        .ledger-item { border: 2px solid #2D3436; border-radius: 16px; padding: 20px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; background: #FAF5EF; box-shadow: 2px 2px 0px 0px #2D3436; }
        
        /* Progress Report Table */
        .neo-table { width: 100%; border-collapse: collapse; border: 2.5px solid #2D3436; border-radius: 16px; overflow: hidden; box-shadow: 3px 3px 0px 0px #2D3436; }
        .neo-table th { background-color: #2D3436; color: #FFF; padding: 14px 16px; font-weight: 900; text-align: left; font-size: 0.9rem; }
        .neo-table td { padding: 16px; border-bottom: 2px solid #2D3436; background: #FFF; font-size: 0.9rem; }
        
        /* Modal Overlay */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: none; justify-content: center; align-items: center; z-index: 1000; }
        .modal-content { background: #FFF; border: 3px solid #2D3436; border-radius: 24px; padding: 32px; width: 90%; max-width: 520px; box-shadow: 8px 8px 0px 0px #2D3436; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-weight: 900; font-size: 0.85rem; margin-bottom: 6px; }
        .form-group input, .form-group select { width: 100%; padding: 12px; border: 2px solid #2D3436; border-radius: 12px; font-weight: 700; }
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
                <div class="container">
                    
                    <% if (studentList.isEmpty()) { %>
                        <div class="neo-card" style="text-align: center; padding: 50px;">
                            <h2 style="font-weight: 900;">Tiada Rekod Murid Dijumpai</h2>
                            <p style="font-weight: 600; color: #636E72; margin-bottom: 20px;">Sila daftar murid terlebih dahulu melalui direktori.</p>
                            <a href="StudentDirectoryServlet?tab=directory" class="btn-neo btn-mint">Pergi ke Direktori Murid</a>
                        </div>
                    <% } else { %>

                        <!-- 1. CLASS & STUDENT SELECTOR CARD (Sesuai Gambar 1) -->
                        <div class="neo-card" style="display: flex; flex-direction: column; gap: 20px;">
                            <div>
                                <label class="neo-label">Class</label>
                                <select class="neo-select" disabled>
                                    <option><%= (student != null) ? student.getStudentClass() : "Kindergarten 3B" %></option>
                                </select>
                            </div>
                            <div>
                                <label class="neo-label">Student Name</label>
                                <select class="neo-select" onchange="window.location.href='ProgressServlet?studentID=' + this.value;">
                                    <% for (Student s : studentList) { %>
                                        <option value="<%= s.getStudentID() %>" <%= (student != null && s.getStudentID() == student.getStudentID()) ? "selected" : "" %>>
                                            <%= s.getStudentName() %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <% if (student != null) { %>
                            <!-- 2. TEACHER ASSESSMENT CONSOLE HEADER (Sesuai Gambar 1 & 2) -->
                            <div class="neo-card" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                                <div>
                                    <span class="badge-console">Teacher Assessment Console</span>
                                    <div style="font-size: 0.8rem; font-weight: 700; color: #636E72; margin-bottom: 6px;">
                                        Class: <%= student.getStudentClass() %> &nbsp;&middot;&nbsp; Student ID: #<%= student.getStudentID() %>
                                    </div>
                                    <h1 style="font-size: 1.8rem; font-weight: 900; margin: 0 0 6px 0;">Learning Progress: <%= student.getStudentName() %></h1>
                                    <p style="font-size: 0.85rem; font-weight: 600; color: #636E72; margin: 0;">Evaluate reading, writing, and early counting milestones in real time. Log observations and manage reports.</p>
                                </div>
                                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                                    <button type="button" class="btn-neo" onclick="alert('Diagram Specs Info')">Diagram Specs</button>
                                    <button type="button" class="btn-neo" onclick="alert('Monthly Report PDF Generated')">🖨️ Monthly Report</button>
                                    <button type="button" class="btn-neo btn-mint" onclick="document.getElementById('addModal').style.display='flex'">
                                        ➕ Rekod Kemajuan Murid
                                    </button>
                                </div>
                            </div>

                            <!-- 3. EVALUATED PROGRESS LEDGER (Sesuai Gambar 2 & 3) -->
                            <div class="neo-card">
                                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px dashed #CBD5E1; padding-bottom: 16px; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
                                    <div>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <h2 style="font-size: 1.3rem; font-weight: 900; margin: 0;">Evaluated Progress Ledger</h2>
                                            <span style="background: #E2E8F0; padding: 2px 10px; border-radius: 999px; font-size: 11px; font-weight: 900; border: 1.5px solid #2D3436;"><%= progressList.size() %> records</span>
                                        </div>
                                        <p style="font-size: 0.8rem; font-weight: 600; color: #636E72; margin: 4px 0 0 0;">Select, modify, or record new rubric evaluations for <%= student.getStudentName() %></p>
                                    </div>
                                    <div style="display: flex; gap: 6px; background: #F3F4F6; padding: 4px; border-radius: 999px; border: 2px solid #2D3436;">
                                        <button type="button" style="border: none; background: #2D3436; color: #FFF; padding: 6px 14px; border-radius: 999px; font-weight: 900; font-size: 0.75rem; cursor: pointer;">All</button>
                                        <button type="button" style="border: none; background: transparent; color: #2D3436; padding: 6px 14px; border-radius: 999px; font-weight: 900; font-size: 0.75rem; cursor: pointer;">Reading</button>
                                        <button type="button" style="border: none; background: transparent; color: #2D3436; padding: 6px 14px; border-radius: 999px; font-weight: 900; font-size: 0.75rem; cursor: pointer;">Writing</button>
                                        <button type="button" style="border: none; background: transparent; color: #2D3436; padding: 6px 14px; border-radius: 999px; font-weight: 900; font-size: 0.75rem; cursor: pointer;">Counting</button>
                                    </div>
                                </div>

                                <div>
                                    <% if (progressList.isEmpty()) { %>
                                        <div style="text-align: center; padding: 30px; color: #636E72; font-weight: 700;">
                                            Tiada rekod kemajuan dicatatkan lagi untuk murid ini.
                                        </div>
                                    <% } else { %>
                                        <% for (LearningProgress lp : progressList) { %>
                                            <div class="ledger-item">
                                                <div style="flex-grow: 1; padding-right: 20px;">
                                                    <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 8px;">
                                                        <span class="badge-domain badge-reading">Domain ID: <%= lp.getLearningID() %></span>
                                                        <span class="status-pill"><span style="width: 8px; height: 8px; background: #3B82F6; border-radius: 50%;"></span> <%= lp.getProgressStatus() %></span>
                                                    </div>
                                                    <h4 style="margin: 0 0 6px 0; font-size: 1.1rem; font-weight: 900;"><%= lp.getProgressName() %></h4>
                                                    <div style="font-size: 0.75rem; color: #636E72; font-weight: 700; display: flex; gap: 12px; align-items: center;">
                                                        <span>📅 <%= lp.getProgressDate() %></span>
                                                        <span>&middot;</span>
                                                        <span>Assessor ID: #<%= lp.getTeacherID() %></span>
                                                        <span>&middot;</span>
                                                        <span>Record ID: #<%= lp.getProgressID() %></span>
                                                    </div>
                                                </div>
                                                <div style="display: flex; align-items: center; gap: 20px; flex-shrink: 0;">
                                                    <div style="text-align: right;">
                                                        <div style="font-weight: 900; font-size: 1.1rem;"><%= (int)lp.getProgressPercentage() %>%</div>
                                                        <div style="width: 80px; height: 8px; background: #E2E8F0; border-radius: 999px; border: 1.5px solid #2D3436; overflow: hidden; margin-top: 4px;">
                                                            <div style="width: <%= (int)lp.getProgressPercentage() %>%; height: 100%; background: #2D3436;"></div>
                                                        </div>
                                                    </div>
                                                    <div style="display: flex; gap: 8px;">
                                                        <button type="button" class="btn-neo" style="padding: 8px 12px;" onclick="alert('Edit ID: <%= lp.getProgressID() %>')">✏️</button>
                                                        <form action="ProgressServlet" method="POST" style="margin: 0;">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="studentID" value="<%= student.getStudentID() %>">
                                                            <input type="hidden" name="progressID" value="<%= lp.getProgressID() %>">
                                                            <button type="submit" class="btn-neo btn-rose" style="padding: 8px 12px;" onclick="return confirm('Padam rekod ini?');">🗑️</button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        <% } %>
                                    <% } %>
                                </div>
                            </div>

                            <!-- 4. PROGRESS REPORT TABLE (Sesuai Gambar 4) -->
                            <div class="neo-card">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
                                    <div>
                                        <h3 style="font-size: 1.3rem; font-weight: 900; margin: 0;">Progress Report</h3>
                                        <p style="font-size: 0.8rem; font-weight: 600; color: #636E72; margin: 4px 0 0 0;">Viewing record(s) (<%= progressList.size() %>)</p>
                                    </div>
                                    <div style="display: flex; gap: 16px; align-items: center; font-weight: 900; font-size: 0.85rem;">
                                        <div>
                                            Year: 
                                            <select style="padding: 6px 12px; border: 2px solid #2D3436; border-radius: 999px; font-weight: 700; background: #FFF;">
                                                <option>2026</option>
                                                <option>2025</option>
                                            </select>
                                        </div>
                                        <div>
                                            Filter by: 
                                            <select style="padding: 6px 12px; border: 2px solid #2D3436; border-radius: 999px; font-weight: 700; background: #FFF;">
                                                <option>All</option>
                                                <option>Reading</option>
                                                <option>Writing</option>
                                                <option>Counting</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <table class="neo-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 25%;">Date</th>
                                            <th style="width: 60%;">Content</th>
                                            <th style="width: 15%; text-align: center;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (progressList.isEmpty()) { %>
                                            <tr>
                                                <td colspan="3" style="text-align: center; color: #636E72; font-weight: 700; padding: 30px;">
                                                    Tiada data laporan kemajuan untuk dipaparkan.
                                                </td>
                                            </tr>
                                        <% } else { %>
                                            <% for (LearningProgress lp : progressList) { %>
                                                <tr>
                                                    <td style="font-weight: 900; font-family: monospace;"><%= lp.getProgressDate() %></td>
                                                    <td>
                                                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                                                            <span class="badge-domain badge-reading">Domain</span>
                                                            <strong style="font-size: 0.95rem;"><%= lp.getProgressName() %></strong>
                                                            <span style="color: #636E72; font-size: 0.8rem;">(<%= (int)lp.getProgressPercentage() %>% &middot; <%= lp.getProgressStatus() %>)</span>
                                                        </div>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <div style="display: flex; justify-content: center; gap: 8px;">
                                                            <button type="button" class="btn-neo" style="padding: 6px 10px;">✏️</button>
                                                            <button type="button" class="btn-neo btn-rose" style="padding: 6px 10px;">🗑️</button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                </table>

                                <div style="display: flex; justify-content: flex-end; margin-top: 20px;">
                                    <button type="button" class="btn-neo btn-yellow" onclick="document.getElementById('addModal').style.display='flex'">Create Progress</button>
                                </div>
                            </div>
                        <% } %>

                    <% } %>
                    
                </div>
            </div>
        </main>
    </div>

    <% if (student != null) { %>
        <!-- MODAL: ADD RECORD -->
        <div id="addModal" class="modal-overlay">
            <div class="modal-content">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h2 style="margin: 0; font-weight: 900;">New Evaluation Record</h2>
                    <button onclick="document.getElementById('addModal').style.display='none'" style="background: none; border: none; font-weight: 900; font-size: 1.2rem; cursor: pointer;">X</button>
                </div>
                
                <form action="ProgressServlet" method="POST">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="studentID" value="<%= student.getStudentID() %>">
                    
                    <div class="form-group">
                        <label>Learning Domain ID</label>
                        <select name="learningID">
                            <option value="101">Reading (101)</option>
                            <option value="102">Writing (102)</option>
                            <option value="103">Counting (103)</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Evaluation Title / Milestone</label>
                        <input type="text" name="progressName" placeholder="e.g. Phonics & CVC Blending" required>
                    </div>
                    
                    <div style="display: flex; gap: 16px;">
                        <div class="form-group" style="flex: 1;">
                            <label>Confidence (%)</label>
                            <input type="number" name="progressPercentage" min="0" max="100" value="85" required>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label>Status Level</label>
                            <select name="progressStatus">
                                <option value="Mastered">Mastered</option>
                                <option value="Proficient">Proficient</option>
                                <option value="Developing">Developing</option>
                                <option value="Emerging">Emerging</option>
                            </select>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-neo btn-mint" style="width: 100%; justify-content: center; margin-top: 10px;">Save Progress Record</button>
                </form>
            </div>
        </div>
    <% } %>

</body>
</html>