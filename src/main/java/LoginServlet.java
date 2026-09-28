import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import bean.Parent;
import bean.Teacher;
import dao.ParentDAO;
import dao.TeacherDAO;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private TeacherDAO teacherDAO;
    private ParentDAO parentDAO;

    @Override
    public void init() throws ServletException {
        teacherDAO = new TeacherDAO();
        parentDAO = new ParentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Paparkan halaman jsp log masuk
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if ("login".equalsIgnoreCase(action)) {
            handleLogin(request, response);
        } else if ("register".equalsIgnoreCase(action)) {
            handleRegister(request, response);
        } else if ("resetPassword".equalsIgnoreCase(action)) {
            handleResetPassword(request, response);
        } else {
            request.setAttribute("errorMessage", "Tindakan tidak sah.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Sila masukkan alamat e-mel anda.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("userRole", role);
        session.setAttribute("userEmail", email);

        // Hala mengikut peranan selepas log masuk berjaya
        if ("Parent".equalsIgnoreCase(role)) {
            response.sendRedirect("parentDashboard.jsp");
        } else if ("Teacher".equalsIgnoreCase(role)) {
            response.sendRedirect("teacherDashboard.jsp");
        } else if ("Admin".equalsIgnoreCase(role)) {
            response.sendRedirect("adminDashboard.jsp");
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String regName = request.getParameter("regName");
        String regEmail = request.getParameter("regEmail");
        String regPhone = request.getParameter("regPhone");
        String regPassword = request.getParameter("regPassword");

        if (regName == null || regEmail == null || regPassword == null ||
            regName.trim().isEmpty() || regEmail.trim().isEmpty() || regPassword.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Sila lengkapkan semua medan pendaftaran yang diwajibkan.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Contoh integrasi pendaftaran dengan DAO
        boolean isSuccess = false;
        if ("Parent".equalsIgnoreCase(role)) {
            Parent parent = new Parent();
            parent.setParentName(regName);
            parent.setParentEmail(regEmail);
            parent.setParentPassword(regPassword);
            parent.setParentPhoneNumber(regPhone);
            // isSuccess = parentDAO.addParent(parent);
            isSuccess = true; // Simulasi berjaya
        } else if ("Teacher".equalsIgnoreCase(role)) {
            Teacher teacher = new Teacher();
            teacher.setTeacherName(regName);
            teacher.setTeacherEmail(regEmail);
            teacher.setTeacherPassword(regPassword);
            teacher.setTeacherPhoneNumber(regPhone);
            // isSuccess = teacherDAO.addTeacher(teacher);
            isSuccess = true; // Simulasi berjaya
        } else {
            isSuccess = true;
        }

        if (isSuccess) {
            request.setAttribute("successMessage", "Akaun " + role + " berjaya didaftarkan! Sila log masuk.");
        } else {
            request.setAttribute("errorMessage", "Pendaftaran gagal. Sila cuba lagi.");
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String resetEmail = request.getParameter("resetEmail");

        if (resetEmail != null && !resetEmail.trim().isEmpty()) {
            request.setAttribute("successMessage", "Pautan penetapan semula kata laluan telah dihantar ke " + resetEmail);
        } else {
            request.setAttribute("errorMessage", "Sila masukkan alamat e-mel yang sah.");
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}