import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DatabaseConnection; // Pastikan anda ada utiliti connection ini

@WebServlet("/parentDashboard")
public class parentDashboard extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        // Semak ID Ibu Bapa dari session (contoh: P101)
        String parentId = (session != null && session.getAttribute("userId") != null) 
                          ? (String) session.getAttribute("userId") 
                          : "P101";

        // Parameter anak yang dipilih (jika ada lebih dari 1 anak)
        String selectedStudentId = request.getParameter("studentId");

        // Data Ibu Bapa
        String parentName = "Parent";
        String parentTitle = "Guardian";

        // Data Anak Semasa
        Map<String, Object> currentStudent = new HashMap<>();
        List<Map<String, Object>> registeredChildren = new ArrayList<>();

        // Metrik
        int completedMilestones = 0;
        int photoProofsCount = 0;
        int averageLevel = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // 1. Ambil data Ibu Bapa
            String sqlParent = "SELECT parent_name, relation_title FROM parent WHERE parent_id = ?";
            try (PreparedStatement psParent = conn.prepareStatement(sqlParent)) {
                psParent.setString(1, parentId);
                try (ResultSet rsParent = psParent.executeQuery()) {
                    if (rsParent.next()) {
                        parentName = rsParent.getString("parent_name");
                        parentTitle = rsParent.getString("relation_title");
                    }
                }
            }

            // 2. Ambil senarai anak-anak yang didaftarkan di bawah ibu bapa ini
            String sqlChildren = "SELECT student_id, student_name, class_name, age, avatar_seed " +
                                 "FROM student WHERE guardian_id = ?";
            try (PreparedStatement psChildren = conn.prepareStatement(sqlChildren)) {
                psChildren.setString(1, parentId);
                try (ResultSet rsChildren = psChildren.executeQuery()) {
                    while (rsChildren.next()) {
                        Map<String, Object> child = new HashMap<>();
                        child.put("id", rsChildren.getString("student_id"));
                        child.put("name", rsChildren.getString("student_name"));
                        child.put("className", rsChildren.getString("class_name"));
                        child.put("age", rsChildren.getInt("age"));
                        
                        String avatar = rsChildren.getString("avatar_seed");
                        child.put("avatarSeed", (avatar != null && !avatar.isEmpty()) ? avatar : "🧒");
                        
                        registeredChildren.add(child);
                    }
                }
            }

            // 3. Tentukan anak yang sedang aktif dilihat (Current Student)
            if (!registeredChildren.isEmpty()) {
                if (selectedStudentId != null) {
                    for (Map<String, Object> child : registeredChildren) {
                        if (child.get("id").equals(selectedStudentId)) {
                            currentStudent = child;
                            break;
                        }
                    }
                }
                // Default kepada anak pertama jika tiada pilihan
                if (currentStudent.isEmpty()) {
                    currentStudent = registeredChildren.get(0);
                }
                selectedStudentId = (String) currentStudent.get("id");
            }

            // 4. Ambil Metrik untuk Anak Semasa (Milestones, Photos, Average Score)
            if (selectedStudentId != null) {
                // Contoh pengiraan metrik (ubah suai query mengikut table sebenar)
                String sqlMetrics = "SELECT " +
                        "(SELECT COUNT(*) FROM milestones WHERE student_id = ? AND status = 'achieved') AS milestones_count, " +
                        "(SELECT COUNT(*) FROM activity_logs WHERE student_id = ? AND image_url IS NOT NULL) AS photos_count, " +
                        "(SELECT AVG(score) FROM learning_progress WHERE student_id = ?) AS avg_score " +
                        "FROM dual";
                
                try (PreparedStatement psMetrics = conn.prepareStatement(sqlMetrics)) {
                    psMetrics.setString(1, selectedStudentId);
                    psMetrics.setString(2, selectedStudentId);
                    psMetrics.setString(3, selectedStudentId);
                    try (ResultSet rsMetrics = psMetrics.executeQuery()) {
                        if (rsMetrics.next()) {
                            completedMilestones = rsMetrics.getInt("milestones_count");
                            photoProofsCount = rsMetrics.getInt("photos_count");
                            // Convert avg (1-10) to percentage (0-100%)
                            double avgScore = rsMetrics.getDouble("avg_score");
                            averageLevel = (int) Math.round((avgScore / 10.0) * 100); 
                        }
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Data dummy jika gagal
            parentName = "Sarah Vance";
            parentTitle = "Mother";
            currentStudent.put("id", "S101");
            currentStudent.put("name", "Leo Vance");
            currentStudent.put("className", "Kindergarten 3B");
            currentStudent.put("age", 5);
            currentStudent.put("avatarSeed", "👦");
            registeredChildren.add(currentStudent);
            averageLevel = 82;
            photoProofsCount = 14;
            completedMilestones = 6;
        } catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        // 5. Hantar data ke JSP
        request.setAttribute("parentName", parentName);
        request.setAttribute("parentTitle", parentTitle);
        request.setAttribute("currentStudent", currentStudent);
        request.setAttribute("registeredChildren", registeredChildren);
        request.setAttribute("hasMultipleChildren", registeredChildren.size() > 1);
        
        request.setAttribute("averageLevel", averageLevel > 0 ? averageLevel : 82);
        request.setAttribute("photoProofsCount", photoProofsCount);
        request.setAttribute("completedMilestones", completedMilestones);
        request.setAttribute("academicCycle", "Oct 2026");

        request.getRequestDispatcher("parentPlatform.jsp").forward(request, response);
    }
}