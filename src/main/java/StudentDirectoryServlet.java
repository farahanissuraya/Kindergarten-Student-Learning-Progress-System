import bean.Parent;
import bean.Student;
import dao.LearningProgressDAO;
import dao.ParentDAO;
import dao.StudentDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
            // 1. Ambil parameter carian dan penapis dari request
            String searchQuery = request.getParameter("searchQuery");
            String classFilter = request.getParameter("classFilter");

            // 2. Tarik data asas dari DAO masing-masing
            List<Student> allStudents = studentDAO.getAllStudents();
            Map<Integer, Parent> parentMap = parentDAO.getAllParentsMap();
            Map<Integer, Double> progressMap = progressDAO.getAvgProgressMap();
            int totalLogs = progressDAO.getTotalLogsCount();

            // 3. Tapis senarai murid berdasarkan carian & kelas (jika ada)
            List<Student> filteredStudents = new ArrayList<>();
            for (Student s : allStudents) {
                boolean matchesSearch = (searchQuery == null || searchQuery.trim().isEmpty()) ||
                        (s.getStudentName() != null && s.getStudentName().toLowerCase().contains(searchQuery.toLowerCase().trim())) ||
                        (s.getStudentIC() != null && s.getStudentIC().contains(searchQuery.trim()));

                boolean matchesClass = (classFilter == null || classFilter.trim().isEmpty() || "All".equalsIgnoreCase(classFilter)) ||
                        (s.getStudentClass() != null && s.getStudentClass().equalsIgnoreCase(classFilter.trim()));

                if (matchesSearch && matchesClass) {
                    filteredStudents.add(s);
                }
            }

            // 4. Kira purata keseluruhan kohort (Cohort Average Progress)
            double totalProgressSum = 0;
            int countWithProgress = 0;

            for (Student s : allStudents) {
                Double avg = progressMap.get(s.getStudentID());
                if (avg != null && avg > 0) {
                    totalProgressSum += avg;
                    countWithProgress++;
                }
            }

            double cohortAvgProgress = (countWithProgress == 0) 
                    ? 0.0 
                    : Math.round((totalProgressSum / countWithProgress) * 10.0) / 10.0;

            // 5. Hantar atribut ke JSP
            request.setAttribute("studentList", filteredStudents);
            request.setAttribute("parentMap", parentMap);
            request.setAttribute("progressMap", progressMap);
            
            request.setAttribute("totalStudentsCount", allStudents.size());
            request.setAttribute("filteredCount", filteredStudents.size());
            request.setAttribute("totalLogsCount", totalLogs);
            request.setAttribute("cohortAvgProgress", cohortAvgProgress);
            
            // Simpan nilai carian semula untuk kekalkan input pada UI
            request.setAttribute("searchQuery", searchQuery);
            request.setAttribute("classFilter", classFilter);
            request.setAttribute("activeTab", "directory");

            request.getRequestDispatcher("studentDirectory.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<div style='background:#FFE3E3; padding:20px; border:3px solid #FF6B6B; border-radius:12px; margin:20px; font-family:sans-serif;'>");
            out.println("<h2 style='color:#D10000; margin-top:0;'>Ralat Sistem Dikesan (StudentDirectoryServlet)!</h2>");
            out.println("<h3>Mesej Ralat: " + e.getMessage() + "</h3>");
            out.println("<pre style='background:#FFF; padding:12px; border:1px solid #CCC; overflow-x:auto;'>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("</div>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if ("delete".equals(action)) {
                int studentId = Integer.parseInt(request.getParameter("studentID"));
                studentDAO.deleteStudent(studentId);
                response.sendRedirect(request.getContextPath() + "/StudentDirectoryServlet");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        doGet(request, response);
    }
}