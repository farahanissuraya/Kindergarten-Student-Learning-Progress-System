import bean.LearningProgress;
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

@WebServlet("/learningProgress")
public class ProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String userRole = "Teacher";
        if (session != null && session.getAttribute("userRole") != null) {
            userRole = session.getAttribute("userRole").toString();
        }

        int studentId = 301;
        String reqStudentId = request.getParameter("studentId");
        if (reqStudentId != null && !reqStudentId.trim().isEmpty()) {
            try { studentId = Integer.parseInt(reqStudentId); } catch (NumberFormatException ignored) {}
        }

        Student currentStudent = new Student();
        List<Student> classStudents = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            if (conn != null) {
                // 1. Tarik Data Pelajar Utama
                String sqlStudent = "SELECT s.*, c.className FROM STUDENT s LEFT JOIN CLASS c ON s.classID = c.classID WHERE s.studentID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlStudent)) {
                    ps.setInt(1, studentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentStudent.setStudentID(rs.getInt("studentID"));
                            currentStudent.setStudentName(rs.getString("studentName"));
                            currentStudent.setStudentAge(rs.getInt("studentAge"));
                            currentStudent.setStudentClass(rs.getString("className"));
                        }
                    }
                }

                // 2. Tarik Senarai Pelajar
                String sqlClass = "SELECT s.studentID, s.studentName, c.className FROM STUDENT s LEFT JOIN CLASS c ON s.classID = c.classID";
                try (PreparedStatement ps = conn.prepareStatement(sqlClass);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Student st = new Student();
                        st.setStudentID(rs.getInt("studentID"));
                        st.setStudentName(rs.getString("studentName"));
                        st.setStudentClass(rs.getString("className"));
                        classStudents.add(st);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Fallback jika pangkalan data belum mempunyai data murid
        if (currentStudent.getStudentName() == null) {
            currentStudent.setStudentID(301);
            currentStudent.setStudentName("Leo Vance");
            currentStudent.setStudentAge(5);
            currentStudent.setStudentClass("Kindergarten 3B");
            classStudents.add(currentStudent);
        }

        // 3. Tarik Rekod Kemajuan melalui DAO
        LearningProgressDAO dao = new LearningProgressDAO();
        List<LearningProgress> progressList = dao.getProgressByStudentId(currentStudent.getStudentID());

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
                response.sendRedirect(request.getContextPath() + "/learningProgress?studentId=" + studentId);
                return;

            } else if ("delete".equals(action)) {
                int progressId = Integer.parseInt(request.getParameter("progressID"));
                int studentId = Integer.parseInt(request.getParameter("studentID"));
                dao.deleteProgress(progressId);
                response.sendRedirect(request.getContextPath() + "/learningProgress?studentId=" + studentId);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        doGet(request, response);
    }
}