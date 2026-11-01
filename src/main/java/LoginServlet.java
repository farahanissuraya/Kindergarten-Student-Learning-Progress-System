import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import util.DatabaseConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (role == null || role.isBlank()) role = "Parent";
        if (email == null) email = "";

        if (email.isBlank() || password == null || password.isBlank()) {
            redirectWithError(response, "Sila masukkan e-mel dan kata laluan.", role, email);
            return;
        }

        if ("Parent".equalsIgnoreCase(role)) {
            try {
                authenticateParent(request, response, email, password);
            } catch (ClassNotFoundException | IOException e) {
                e.printStackTrace();
            }
        } else if ("Teacher".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
            try {
                authenticateTeacher(request, response, email, password, role);
            } catch (ClassNotFoundException | IOException e) {
                e.printStackTrace();
            }
        } else {
            redirectWithError(response, "Peranan pengguna tidak sah.", role, email);
        }
    }

    private void authenticateParent(HttpServletRequest request, HttpServletResponse response, String email, String password)
            throws IOException, ClassNotFoundException {
        
        String sql = "SELECT parentID, parentName, parentEmail, parentPhoneNumber FROM Parent WHERE parentEmail = ? AND parentPassword = ?";

        try (Connection con = DatabaseConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int parentID = rs.getInt("parentID");
                    String parentName = rs.getString("parentName");
                    String parentEmail = rs.getString("parentEmail");
                    String parentPhoneNumber = rs.getString("parentPhoneNumber");

                    HttpSession session = request.getSession(true);
                    
                    session.setAttribute("role", "Parent");
                    session.setAttribute("userRole", "Parent");
                    session.setAttribute("parentId", parentID);
                    session.setAttribute("parentID", parentID);
                    session.setAttribute("parentName", parentName);
                    session.setAttribute("parentEmail", parentEmail);
                    session.setAttribute("parentPhoneNumber", parentPhoneNumber);

                    response.sendRedirect("parentDashboard.jsp");
                    
                } else {
                    // ✅ Hantar semula role "Parent" dan e-mel jika log masuk gagal
                    redirectWithError(response, "E-mel atau kata laluan tidak sah.", "Parent", email);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            redirectWithError(response, "Ralat sistem. Sila cuba lagi.", "Parent", email);
        }
    }

    private void authenticateTeacher(HttpServletRequest request, HttpServletResponse response, String email, String password, String requestedRole)
            throws IOException, ClassNotFoundException {

        String sql = "SELECT teacherID, teacherName, teacherEmail, teacherPhoneNumber, adminID FROM Teacher WHERE teacherEmail = ? AND teacherPassword = ?";

        try (Connection con = DatabaseConnection.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int teacherID = rs.getInt("teacherID");
                    String teacherName = rs.getString("teacherName");
                    String teacherEmail = rs.getString("teacherEmail");
                    String teacherPhoneNumber = rs.getString("teacherPhoneNumber");
                    int adminID = rs.getInt("adminID"); 
                    boolean wasNull = rs.wasNull();

                    boolean isAdmin = wasNull || adminID == 0;

                    if ("Admin".equalsIgnoreCase(requestedRole) && !isAdmin) {
                        // ✅ Hantar semula requestedRole dan e-mel jika tiada akses Admin
                        redirectWithError(response, "Akaun anda tidak mempunyai akses sebagai Admin.", requestedRole, email);
                        return;
                    }

                    HttpSession session = request.getSession(true);
                    
                    session.setAttribute("teacherId", teacherID);
                    session.setAttribute("teacherID", teacherID);
                    session.setAttribute("teacherName", teacherName);
                    session.setAttribute("teacherEmail", teacherEmail);
                    session.setAttribute("teacherPhoneNumber", teacherPhoneNumber);

                    if ("Admin".equalsIgnoreCase(requestedRole) && isAdmin) {
                        session.setAttribute("role", "Admin");
                        session.setAttribute("userRole", "Admin");
                        response.sendRedirect("adminDashboard.jsp");
                    } else {
                        session.setAttribute("role", "Teacher");
                        session.setAttribute("userRole", "Teacher");
                        response.sendRedirect("teacherDashboard.jsp");
                    }

                } else {
                    // ✅ Hantar semula requestedRole (Teacher/Admin) dan e-mel jika kata laluan salah
                    redirectWithError(response, "E-mel atau kata laluan tidak sah.", requestedRole, email);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            redirectWithError(response, "Ralat sistem. Sila cuba lagi.", requestedRole, email);
        }
    }

    // Helper method untuk menghantar mesej ralat bersama role dan email
    private void redirectWithError(HttpServletResponse response, String errorMessage, String role, String email) throws IOException {
        String redirectUrl = "login.jsp?error=" + url(errorMessage) 
                + "&role=" + url(role) 
                + "&email=" + url(email);
        response.sendRedirect(redirectUrl);
    }

    private String url(String s) {
        if (s == null) return "";
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}