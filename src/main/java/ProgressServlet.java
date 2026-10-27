import bean.LearningProgress;
import bean.Student;
import dao.LearningProgressDAO;
import dao.StudentDAO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/ProgressServlet")
public class ProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private LearningProgressDAO progressDAO;
    private StudentDAO studentDAO;

    @Override
    public void init() {
        progressDAO = new LearningProgressDAO();
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<Student> allStudents = studentDAO.getAllStudents();
            Student currentStudent = null;
            int studentId = 0;

            String studentIdStr = request.getParameter("studentID");
            
            if (studentIdStr != null && !studentIdStr.isEmpty()) {
                studentId = Integer.parseInt(studentIdStr);
                currentStudent = studentDAO.getStudentById(studentId);
            } 
            
            // Jika tiada studentID diberikan atau murid tidak wujud, 
            // tetapi senarai murid ada, ambil murid pertama dalam senarai secara automatik
            if (currentStudent == null && !allStudents.isEmpty()) {
                currentStudent = allStudents.get(0);
                studentId = currentStudent.getStudentID();
            }

            List<LearningProgress> progressList = new ArrayList<>();
            if (currentStudent != null) {
                progressList = progressDAO.getProgressByStudentId(studentId);
            }

            request.setAttribute("currentStudent", currentStudent);
            request.setAttribute("studentList", allStudents);
            request.setAttribute("progressList", progressList);
            request.setAttribute("activeTab", "progress");

            request.getRequestDispatcher("learningProgress.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Ralat memuatkan data kemajuan.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String studentIdStr = request.getParameter("studentID");
        
        try {
            if ("add".equals(action)) {
                LearningProgress lp = new LearningProgress();
                // setProgressID dijana oleh DAO/Oracle sequence
                lp.setStudentID(Integer.parseInt(studentIdStr));
                lp.setLearningID(Integer.parseInt(request.getParameter("learningID")));
                lp.setProgressName(request.getParameter("progressName"));
                lp.setProgressPercentage(Double.parseDouble(request.getParameter("progressPercentage")));
                lp.setProgressStatus(request.getParameter("progressStatus"));
                lp.setTeacherID(201); // ID Guru contoh
                // progressDate menggunakan SYSDATE di dalam DAO
                
                progressDAO.addLearningProgress(lp);
                
            } else if ("delete".equals(action)) {
                int progressId = Integer.parseInt(request.getParameter("progressID"));
                progressDAO.deleteLearningProgress(progressId);
            }

            response.sendRedirect("ProgressServlet?studentID=" + studentIdStr);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ProgressServlet?studentID=" + studentIdStr + "&error=true");
        }
    }
}