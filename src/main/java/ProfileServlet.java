import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
        
        String name = "";
        String email = "";
        String password = "";
        String phone = "";
        String address = "";
        String personalId = "";
        String icNumber = "";

        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("Parent".equalsIgnoreCase(role)) {
                Object parentIdObj = session.getAttribute("parentId");
                if (parentIdObj == null) parentIdObj = session.getAttribute("parentID");

                if (parentIdObj != null) {
                    int parentId = Integer.parseInt(parentIdObj.toString());
                    String sql = "SELECT parentName, parentEmail, parentPassword, parentPhoneNumber FROM Parent WHERE parentID = ?";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, parentId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                name = rs.getString("parentName");
                                email = rs.getString("parentEmail");
                                password = rs.getString("parentPassword");
                                phone = rs.getString("parentPhoneNumber");
                                address = "742 Evergreen Terrace, Springfield";
                                personalId = "PID-PRT-" + String.format("%03d", parentId);
                                icNumber = "920315-10-" + String.format("%04d", parentId);
                            }
                        }
                    }
                }
            } else if ("Teacher".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
                Object teacherIdObj = session.getAttribute("teacherId");
                if (teacherIdObj == null) teacherIdObj = session.getAttribute("teacherID");

                if (teacherIdObj != null) {
                    int teacherId = Integer.parseInt(teacherIdObj.toString());
                    String sql = "SELECT teacherName, teacherEmail, teacherPassword, teacherPhoneNumber FROM Teacher WHERE teacherID = ?";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, teacherId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                name = rs.getString("teacherName");
                                email = rs.getString("teacherEmail");
                                password = rs.getString("teacherPassword");
                                phone = rs.getString("teacherPhoneNumber");
                                address = "15 Blossom Garden Avenue, Springfield";
                                personalId = "Admin".equalsIgnoreCase(role) ? "PID-ADM-" + String.format("%03d", teacherId) : "PID-TCH-" + String.format("%03d", teacherId);
                                icNumber = "881120-14-" + String.format("%04d", teacherId);
                            }
                        }
                    }
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        request.setAttribute("profileName", name);
        request.setAttribute("profileEmail", email);
        request.setAttribute("profilePassword", password);
        request.setAttribute("profilePhone", phone);
        request.setAttribute("profileAddress", address);
        request.setAttribute("profilePersonalId", personalId);
        request.setAttribute("profileIcNumber", icNumber);

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("Parent".equalsIgnoreCase(role)) {
                Object parentIdObj = session.getAttribute("parentId");
                if (parentIdObj == null) parentIdObj = session.getAttribute("parentID");

                if (parentIdObj != null) {
                    int parentId = Integer.parseInt(parentIdObj.toString());
                    String sql = "UPDATE Parent SET parentName = ?, parentEmail = ?, parentPassword = ?, parentPhoneNumber = ? WHERE parentID = ?";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, name);
                        ps.setString(2, email);
                        ps.setString(3, password);
                        ps.setString(4, phone);
                        ps.setInt(5, parentId);
                        ps.executeUpdate();
                    }

                    session.setAttribute("parentName", name);
                    session.setAttribute("parentEmail", email);
                    session.setAttribute("parentPhoneNumber", phone);
                }
            } else if ("Teacher".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
                Object teacherIdObj = session.getAttribute("teacherId");
                if (teacherIdObj == null) teacherIdObj = session.getAttribute("teacherID");

                if (teacherIdObj != null) {
                    int teacherId = Integer.parseInt(teacherIdObj.toString());
                    String sql = "UPDATE Teacher SET teacherName = ?, teacherEmail = ?, teacherPassword = ?, teacherPhoneNumber = ? WHERE teacherID = ?";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, name);
                        ps.setString(2, email);
                        ps.setString(3, password);
                        ps.setString(4, phone);
                        ps.setInt(5, teacherId);
                        ps.executeUpdate();
                    }

                    session.setAttribute("teacherName", name);
                    session.setAttribute("teacherEmail", email);
                    session.setAttribute("teacherPhoneNumber", phone);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("ProfileServlet?error=" + URLEncoder.encode("Gagal mengemaskini maklumat profil.", StandardCharsets.UTF_8));
            return;
        }

        response.sendRedirect("ProfileServlet?success=true");
    }
}