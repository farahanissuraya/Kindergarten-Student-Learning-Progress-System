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
import util.DatabaseConnection; 

@WebServlet("/teacherDashboard")
public class teacherDashboard extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        // Default to a teacher ID if none found in session
        String teacherId = (session != null && session.getAttribute("userId") != null) 
                          ? (String) session.getAttribute("userId") 
                          : "T101";

        String selectedStudentId = request.getParameter("studentId");

        String teacherName = "Educator";
        String teacherTitle = "Teacher";
        String className = "Kindergarten 3B";
        
        List<Map<String, Object>> students = new ArrayList<>();
        Map<String, Object> currentStudent = new HashMap<>();

        int totalObservations = 0;
        int totalMilestones = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {
            
            // 1. Fetch Teacher Info
            String sqlTeacher = "SELECT teacher_name, title, class_assigned FROM teacher WHERE teacher_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlTeacher)) {
                ps.setString(1, teacherId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        teacherName = rs.getString("teacher_name");
                        teacherTitle = rs.getString("title");
                        className = rs.getString("class_assigned");
                    }
                }
            }

            // 2. Fetch Assigned Students (Classroom Roster)
            String sqlStudents = "SELECT student_id, student_name, age, avatar_seed FROM student WHERE class_name = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlStudents)) {
                ps.setString(1, className);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> student = new HashMap<>();
                        student.put("id", rs.getString("student_id"));
                        student.put("name", rs.getString("student_name"));
                        student.put("age", rs.getInt("age"));
                        student.put("className", className);
                        
                        String avatar = rs.getString("avatar_seed");
                        student.put("avatarSeed", (avatar != null && !avatar.isEmpty()) ? avatar : "🧒");
                        
                        students.add(student);
                    }
                }
            }

            // 3. Set Active/Selected Student
            if (!students.isEmpty()) {
                if (selectedStudentId != null) {
                    for (Map<String, Object> s : students) {
                        if (s.get("id").equals(selectedStudentId)) {
                            currentStudent = s;
                            break;
                        }
                    }
                }
                if (currentStudent.isEmpty()) {
                    currentStudent = students.get(0); // Default to first student
                }
            }

            // 4. Calculate Aggregate Metrics for the entire class
            String sqlMetrics = "SELECT " +
                                "(SELECT COUNT(*) FROM activity_logs l JOIN student s ON l.student_id = s.student_id WHERE s.class_name = ?) AS total_obs, " +
                                "(SELECT COUNT(*) FROM milestones m JOIN student s ON m.student_id = s.student_id WHERE s.class_name = ? AND m.status = 'achieved') AS total_miles " +
                                "FROM dual";
            try (PreparedStatement ps = conn.prepareStatement(sqlMetrics)) {
                ps.setString(1, className);
                ps.setString(2, className);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalObservations = rs.getInt("total_obs");
                        totalMilestones = rs.getInt("total_miles");
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Fallback Dummy Data
            teacherName = "Eleanor Ward";
            teacherTitle = "Principal Educator";
            
            Map<String, Object> dummyStudent = new HashMap<>();
            dummyStudent.put("id", "S101");
            dummyStudent.put("name", "Leo Vance");
            dummyStudent.put("className", "Kindergarten 3B");
            dummyStudent.put("age", 5);
            dummyStudent.put("avatarSeed", "🦁");
            students.add(dummyStudent);
            currentStudent = dummyStudent;
            
            totalObservations = 142;
            totalMilestones = 64;
        } catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        request.setAttribute("teacherName", teacherName);
        request.setAttribute("teacherTitle", teacherTitle);
        request.setAttribute("className", className);
        request.setAttribute("students", students);
        request.setAttribute("currentStudent", currentStudent);
        request.setAttribute("totalObservations", totalObservations);
        request.setAttribute("totalMilestones", totalMilestones);

        request.getRequestDispatcher("teacherPlatform.jsp").forward(request, response);
    }
}