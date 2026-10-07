import bean.Teacher;
import dao.ParentDAO;
import dao.TeacherDAO;
import dao.StudentDAO;
import dao.NewsDAO;

import java.io.IOException;

// Import daripada pakej jakarta.*
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminDashboard")
public class adminDashboard extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private TeacherDAO teacherDAO;
    private ParentDAO parentDAO;
    private StudentDAO studentDAO;
    private NewsDAO newsDAO;

    @Override
    public void init() throws ServletException {
        // Inisialisasi DAO
        teacherDAO = new TeacherDAO();
        parentDAO = new ParentDAO();
        studentDAO = new StudentDAO();
        newsDAO = new NewsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Semak authentication pengguna
        Teacher loggedInTeacher = (Teacher) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        // Kawalan capaian: Pastikan pengguna log masuk dan bertindak sebagai Admin / Head Teacher
        if (loggedInTeacher == null && role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 1. Kira jumlah Teachers & Parents daripada DAO masing-masing
            int totalTeachers = teacherDAO.getTeacherCount();
            int totalParents = parentDAO.getParentCount();
            
            // 2. Gabungkan jumlah akaun (Teachers + Parents)
            int totalAccounts = totalTeachers + totalParents;

            // 3. Dapatkan jumlah Pelajar dan Buletin/News
            int totalStudents = studentDAO.getStudentCount();
            int totalNews = newsDAO.getNewsCount();

            // 4. Hantar nilai statistik ke request attribute
            request.setAttribute("totalAccounts", totalAccounts);
            request.setAttribute("totalTeachers", totalTeachers);
            request.setAttribute("totalParents", totalParents);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("totalNews", totalNews);
            
            // Set tab aktif (secara lalai 'overview')
            String tab = request.getParameter("tab");
            request.setAttribute("activeTab", (tab != null && !tab.isBlank()) ? tab : "overview");

            // 5. Forward ke halaman JSP
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Gagal memuatkan data dashboard: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}