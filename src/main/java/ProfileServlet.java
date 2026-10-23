import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DatabaseConnection;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("Parent".equalsIgnoreCase(role)) {
                Object parentIdObj = session.getAttribute("parentId");
                if (parentIdObj == null) parentIdObj = session.getAttribute("parentID");
                
                if (parentIdObj != null) {
                    int parentId = Integer.parseInt(parentIdObj.toString());
                    String sql = "SELECT parentName, parentEmail, parentPhoneNumber FROM Parent WHERE parentID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, parentId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                request.setAttribute("profileName", rs.getString("parentName"));
                                request.setAttribute("profileEmail", rs.getString("parentEmail"));
                                request.setAttribute("profilePhone", rs.getString("parentPhoneNumber"));
                                request.setAttribute("profileTitle", "Parent & Guardian");
                            }
                        }
                    }
                }
            } else if ("Teacher".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
                Object teacherIdObj = session.getAttribute("teacherId");
                if (teacherIdObj == null) teacherIdObj = session.getAttribute("teacherID");
                
                if (teacherIdObj != null) {
                    int teacherId = Integer.parseInt(teacherIdObj.toString());
                    String sql = "SELECT teacherName, teacherEmail, teacherPhoneNumber, NVL(title, 'Lead Educator') AS title FROM Teacher WHERE teacherID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, teacherId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                request.setAttribute("profileName", rs.getString("teacherName"));
                                request.setAttribute("profileEmail", rs.getString("teacherEmail"));
                                request.setAttribute("profilePhone", rs.getString("teacherPhoneNumber"));
                                request.setAttribute("profileTitle", rs.getString("title"));
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}