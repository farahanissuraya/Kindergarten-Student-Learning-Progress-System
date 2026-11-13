import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DatabaseConnection;

@WebServlet("/parentDashboard")
public class parentDashboard extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("parentID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int parentID = (int) session.getAttribute("parentID");
        String parentName = (String) session.getAttribute("parentName");
        String parentTitle = "Guardian";

        String selectedStudentIdParam = request.getParameter("studentId");
        int selectedStudentId = 0;
        if (selectedStudentIdParam != null && !selectedStudentIdParam.isEmpty()) {
            try {
                selectedStudentId = Integer.parseInt(selectedStudentIdParam);
            } catch (NumberFormatException ignored) {}
        }

        HashMap<String, Object> currentStudent = new HashMap<>();
        List<HashMap<String, Object>> registeredChildren = new ArrayList<>();

        int completedMilestones = 0;
        int photoProofsCount = 0;
        int averageLevel = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // 1. Ambil data Ibu Bapa
            String sqlParent = "SELECT PARENTNAME FROM PARENT WHERE PARENTID = ?";
            try (PreparedStatement psParent = conn.prepareStatement(sqlParent)) {
                psParent.setInt(1, parentID);
                try (ResultSet rsParent = psParent.executeQuery()) {
                    if (rsParent.next()) {
                        parentName = rsParent.getString("PARENTNAME");
                    }
                }
            }

            // 2. Ambil senarai anak di bawah PARENTID ini
            String sqlChildren = "SELECT STUDENTID, STUDENTNAME, STUDENTCLASS, STUDENTAGE, STUDENTGENDER " +
                                 "FROM STUDENT WHERE PARENTID = ? ORDER BY STUDENTID ASC";
            try (PreparedStatement psChildren = conn.prepareStatement(sqlChildren)) {
                psChildren.setInt(1, parentID);
                try (ResultSet rsChildren = psChildren.executeQuery()) {
                    while (rsChildren.next()) {
                        HashMap<String, Object> child = new HashMap<>();
                        int stId = rsChildren.getInt("STUDENTID");
                        String gender = rsChildren.getString("STUDENTGENDER");
                        
                        child.put("id", stId);
                        child.put("name", rsChildren.getString("STUDENTNAME"));
                        child.put("className", rsChildren.getString("STUDENTCLASS"));
                        child.put("age", rsChildren.getInt("STUDENTAGE"));
                        
                        String avatar = ("Girl".equalsIgnoreCase(gender) || "Female".equalsIgnoreCase(gender)) ? "👧" : "👦";
                        child.put("avatarSeed", avatar);
                        
                        registeredChildren.add(child);
                    }
                }
            }

            // 3. Tentukan anak aktif
            if (!registeredChildren.isEmpty()) {
                if (selectedStudentId > 0) {
                    for (HashMap<String, Object> child : registeredChildren) {
                        if ((int) child.get("id") == selectedStudentId) {
                            currentStudent = child;
                            break;
                        }
                    }
                }
                if (currentStudent.isEmpty()) {
                    currentStudent = registeredChildren.get(0);
                }
                selectedStudentId = (int) currentStudent.get("id");
            }

            // 4. Ambil Metrik dari jadual LEARNINGPROGRESS
            if (selectedStudentId > 0) {
                String sqlMetrics = "SELECT " +
                        "COUNT(CASE WHEN PROGRESSSTATUS = 'Mastered' THEN 1 END) AS milestones_count, " +
                        "NVL(AVG(PROGRESSPERCENTAGE), 0) AS avg_score " +
                        "FROM LEARNINGPROGRESS WHERE STUDENTID = ?";
                
                try (PreparedStatement psMetrics = conn.prepareStatement(sqlMetrics)) {
                    psMetrics.setInt(1, selectedStudentId);
                    try (ResultSet rsMetrics = psMetrics.executeQuery()) {
                        if (rsMetrics.next()) {
                            completedMilestones = rsMetrics.getInt("milestones_count");
                            averageLevel = (int) Math.round(rsMetrics.getDouble("avg_score"));
                        }
                    }
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        // 5. Hantar data ke JSP
        request.setAttribute("parentName", parentName);
        request.setAttribute("parentTitle", parentTitle);
        request.setAttribute("currentStudent", currentStudent);
        request.setAttribute("registeredChildren", registeredChildren);
        request.setAttribute("hasMultipleChildren", registeredChildren.size() > 1);
        
        request.setAttribute("averageLevel", averageLevel);
        request.setAttribute("photoProofsCount", photoProofsCount);
        request.setAttribute("completedMilestones", completedMilestones);
        request.setAttribute("academicCycle", "Oct 2026");

        request.getRequestDispatcher("parentDashboard.jsp").forward(request, response);
    }
}