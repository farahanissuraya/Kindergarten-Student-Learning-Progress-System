import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import util.DatabaseConnection; // Pastikan package pencapaian pangkalan data anda betul

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

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            response.sendRedirect("login.jsp?error=" + url("Sila masukkan e-mel dan kata laluan."));
            return;
        }

        // Semak log masuk mengikut peranan pengguna
        if ("Parent".equalsIgnoreCase(role)) {
            try {
				authenticateParent(request, response, email, password);
			} catch (ClassNotFoundException | IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } else if ("Teacher".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
            try {
				authenticateTeacher(request, response, email, password, role);
			} catch (ClassNotFoundException | IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } else {
            response.sendRedirect("login.jsp?error=" + url("Peranan pengguna tidak sah."));
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

                    // ✅ Create Session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("userRole", "Parent");
                    session.setAttribute("parentID", parentID);
                    session.setAttribute("parentName", parentName);
                    session.setAttribute("parentEmail", parentEmail);
                    session.setAttribute("parentPhoneNumber", parentPhoneNumber);

                    // ✅ Redirect ke dashboard Parent
                    response.sendRedirect("parentDashboard.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=" + url("E-mel atau kata laluan tidak sah."));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=" + url("Ralat sistem. Sila cuba lagi."));
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
                    boolean wasNull = rs.wasNull(); // Semak jika adminID bernilai NULL dalam database

                    // Jika adminID NULL atau 0, pengguna ini adalah Admin
                    boolean isAdmin = wasNull || adminID == 0;

                    // Semak jika cuba log masuk sebagai Admin tetapi akaun bukan Admin
                    if ("Admin".equalsIgnoreCase(requestedRole) && !isAdmin) {
                        response.sendRedirect("login.jsp?error=" + url("Akaun anda tidak mempunyai akses sebagai Admin."));
                        return;
                    }

                    // ✅ Create Session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("teacherID", teacherID);
                    session.setAttribute("teacherName", teacherName);
                    session.setAttribute("teacherEmail", teacherEmail);
                    session.setAttribute("teacherPhoneNumber", teacherPhoneNumber);

                    // ✅ Redirect berasaskan peranan
                    if ("Admin".equalsIgnoreCase(requestedRole) && isAdmin) {
                        session.setAttribute("userRole", "Admin");
                        response.sendRedirect("adminDashboard.jsp");
                    } else {
                        session.setAttribute("userRole", "Teacher");
                        response.sendRedirect("teacherDashboard.jsp");
                    }

                } else {
                    response.sendRedirect("login.jsp?error=" + url("E-mel atau kata laluan tidak sah."));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=" + url("Ralat sistem. Sila cuba lagi."));
        }
    }

    private String url(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}