import bean.LearningProgress;
import bean.Parent;
import bean.Student;
import dao.LearningProgressDAO;
import util.DatabaseConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/learningProgress", "/ProgressServlet"})
public class ProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setAttribute("activeTab", "progress");
        
        HttpSession session = request.getSession(false);
        String userRole = "Teacher";
        Integer loggedParentId = null;
        String loggedParentEmail = null;

        if (session != null) {
            Object roleObj = session.getAttribute("role") != null 
                           ? session.getAttribute("role") 
                           : session.getAttribute("userRole");
            if (roleObj != null) {
                userRole = roleObj.toString();
            }

            // Kesan parentID daripada pelbagai kemungkinan nama atribut session
            Object userObj = session.getAttribute("user");
            if (userObj instanceof Parent) {
                loggedParentId = ((Parent) userObj).getParentID();
                loggedParentEmail = ((Parent) userObj).getParentEmail();
            }
            if (loggedParentId == null && session.getAttribute("parentID") != null) {
                loggedParentId = Integer.parseInt(session.getAttribute("parentID").toString());
            }
            if (loggedParentId == null && session.getAttribute("parentId") != null) {
                loggedParentId = Integer.parseInt(session.getAttribute("parentId").toString());
            }
            if (loggedParentId == null && session.getAttribute("userID") != null) {
                loggedParentId = Integer.parseInt(session.getAttribute("userID").toString());
            }
            if (loggedParentId == null && session.getAttribute("userId") != null) {
                loggedParentId = Integer.parseInt(session.getAttribute("userId").toString());
            }
            if (loggedParentEmail == null && session.getAttribute("userEmail") != null) {
                loggedParentEmail = session.getAttribute("userEmail").toString();
            }
        }

        System.out.println("[DEBUG ProgressServlet] Role: " + userRole + " | ParentID: " + loggedParentId + " | Email: " + loggedParentEmail);

        int studentId = -1;
        String reqStudentId = request.getParameter("studentId");
        if (reqStudentId == null || reqStudentId.trim().isEmpty()) {
            reqStudentId = request.getParameter("studentID");
        }
        if (reqStudentId != null && !reqStudentId.trim().isEmpty()) {
            try { 
                studentId = Integer.parseInt(reqStudentId); 
            } catch (NumberFormatException ignored) {}
        }

        Student currentStudent = new Student();
        List<Student> classStudents = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            if (conn != null) {
                // Jika Parent login menggunakan email tetapi parentID tiada dalam session, cari parentID dalam jadual PARENT
                if ("Parent".equalsIgnoreCase(userRole) && loggedParentId == null && loggedParentEmail != null) {
                    String sqlFindParent = "SELECT parentID FROM PARENT WHERE LOWER(parentEmail) = LOWER(?)";
                    try (PreparedStatement ps = conn.prepareStatement(sqlFindParent)) {
                        ps.setString(1, loggedParentEmail);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                loggedParentId = rs.getInt("parentID");
                            }
                        }
                    }
                }

                // 1. Tarik Senarai Pelajar terus daripada jadual STUDENT (tanpa JOIN CLASS yang bermasalah)
                if ("Parent".equalsIgnoreCase(userRole) && loggedParentId != null) {
                    String sqlParentKids = "SELECT * FROM STUDENT WHERE parentID = ? ORDER BY studentID ASC";
                    try (PreparedStatement ps = conn.prepareStatement(sqlParentKids)) {
                        ps.setInt(1, loggedParentId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Student st = new Student();
                                st.setStudentID(rs.getInt("studentID"));
                                st.setStudentName(rs.getString("studentName"));
                                st.setStudentAge(rs.getInt("studentAge"));
                                st.setStudentClass(rs.getString("studentClass"));
                                classStudents.add(st);
                            }
                        }
                    }
                } else {
                    String sqlClass = "SELECT * FROM STUDENT ORDER BY studentID ASC";
                    try (PreparedStatement ps = conn.prepareStatement(sqlClass);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Student st = new Student();
                            st.setStudentID(rs.getInt("studentID"));
                            st.setStudentName(rs.getString("studentName"));
                            st.setStudentAge(rs.getInt("studentAge"));
                            st.setStudentClass(rs.getString("studentClass"));
                            classStudents.add(st);
                        }
                    }
                }

                // 2. Pilih murid pertama dalam senarai (cth: Lily) jika tiada parameter studentId
                if (!classStudents.isEmpty()) {
                    if (studentId != -1) {
                        for (Student st : classStudents) {
                            if (st.getStudentID() == studentId) {
                                currentStudent = st;
                                break;
                            }
                        }
                    }
                    if (currentStudent.getStudentName() == null) {
                        currentStudent = classStudents.get(0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Fallback hanya jika jadual STUDENT kosong atau sambungan DB gagal
        if (currentStudent.getStudentName() == null) {
            currentStudent.setStudentID(301);
            currentStudent.setStudentName("Leo Vance");
            currentStudent.setStudentAge(5);
            currentStudent.setStudentClass("Kindergarten 3B");
            classStudents.add(currentStudent);
        }

        // 3. Tarik Rekod Kemajuan melalui DAO
        LearningProgressDAO dao = new LearningProgressDAO();
        List<LearningProgress> progressList = new ArrayList<>();
        try {
            progressList = dao.getProgressByStudentId(currentStudent.getStudentID());
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("userRole", userRole);
        request.setAttribute("student", currentStudent);
        request.setAttribute("classStudents", classStudents);
        request.setAttribute("progressList", progressList);

        request.getRequestDispatcher("learningProgress.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        LearningProgressDAO dao = new LearningProgressDAO();

        try {
            if ("create".equals(action) || "update".equals(action)) {
                LearningProgress lp = new LearningProgress();
                int studentId = Integer.parseInt(request.getParameter("studentID"));
                lp.setStudentID(studentId);
                
                String domain = request.getParameter("domainName");
                int learningId = "Writing".equals(domain) ? 2 : "Counting".equals(domain) ? 3 : 1;
                lp.setLearningID(learningId);
                lp.setProgressName(request.getParameter("progressName"));
                lp.setProgressPercentage(Double.parseDouble(request.getParameter("progressPercentage")));
                lp.setProgressStatus(request.getParameter("progressStatus"));
                lp.setNotes(request.getParameter("notes"));
                
                String scaleStr = request.getParameter("ratingScale");
                lp.setRatingScale(scaleStr != null && !scaleStr.isEmpty() ? Integer.parseInt(scaleStr) : 5);
                lp.setHomeRecommendation(request.getParameter("homeRecommendation"));

                String dateStr = request.getParameter("progressDate");
                if (dateStr == null || dateStr.trim().isEmpty()) {
                    dateStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
                }
                lp.setProgressDate(dateStr);
                lp.setTeacherID(201);

                if ("create".equals(action)) {
                    dao.addProgress(lp);
                } else {
                    lp.setProgressID(Integer.parseInt(request.getParameter("progressID")));
                    dao.updateProgress(lp);
                }
                response.sendRedirect(request.getContextPath() + "/ProgressServlet?studentId=" + studentId);
                return;

            } else if ("delete".equals(action)) {
                int progressId = Integer.parseInt(request.getParameter("progressID"));
                int studentId = Integer.parseInt(request.getParameter("studentID"));
                dao.deleteProgress(progressId);
                response.sendRedirect(request.getContextPath() + "/ProgressServlet?studentId=" + studentId);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        doGet(request, response);
    }
}