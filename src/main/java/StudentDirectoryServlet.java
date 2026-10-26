import bean.Parent;
import bean.Student;
import dao.LearningProgressDAO;
import dao.ParentDAO;
import dao.StudentDAO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

@WebServlet("/StudentDirectoryServlet")
public class StudentDirectoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private StudentDAO studentDAO;
    private ParentDAO parentDAO;
    private LearningProgressDAO progressDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
        parentDAO = new ParentDAO();
        progressDAO = new LearningProgressDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Ambil data asing dari DAO masing-masing
            List<Student> studentList = studentDAO.getAllStudents();
            Map<Integer, Parent> parentMap = parentDAO.getAllParentsMap();
            Map<Integer, Double> progressMap = progressDAO.getAvgProgressMap();

            int totalLogs = progressDAO.getTotalLogsCount();
            
            // Kira purata keseluruhan
            double totalProgressSum = 0;
            for (Student s : studentList) {
                Double avg = progressMap.get(s.getStudentID());
                if (avg != null) {
                    totalProgressSum += avg;
                }
            }
            double cohortAvgProgress = studentList.isEmpty() ? 0 : Math.round((totalProgressSum / studentList.size()) * 10.0) / 10.0;

            // Set atribut berasingan untuk JSP
            request.setAttribute("studentList", studentList);
            request.setAttribute("parentMap", parentMap);
            request.setAttribute("progressMap", progressMap);
            
            request.setAttribute("totalStudentsCount", studentList.size());
            request.setAttribute("totalLogsCount", totalLogs);
            request.setAttribute("cohortAvgProgress", cohortAvgProgress);
            request.setAttribute("activeTab", "directory");

            request.getRequestDispatcher("studentDirectory.jsp").forward(request, response);
            
	        } catch (Exception e) {
	            // Print error di Console IDE
	            e.printStackTrace();
	            
	            // Print ralat sebenar ke skrin browser
	            response.setContentType("text/html");
	            java.io.PrintWriter out = response.getWriter();
	            out.println("<div style='background:#FFE3E3; padding:20px; border:3px solid #FF6B6B; border-radius:12px; margin:20px; font-family:sans-serif;'>");
	            out.println("<h2 style='color:#D10000;'>Ralat Sistem Dikesan!</h2>");
	            out.println("<h3>Mesej Ralat: " + e.toString() + "</h3>");
	            out.println("<pre style='background:#FFF; padding:10px; overflow-x:auto;'>");
	            e.printStackTrace(out);
	            out.println("</pre>");
	            out.println("</div>");
	        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}