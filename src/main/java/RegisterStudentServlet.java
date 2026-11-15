import bean.Parent;
import bean.Student;
import dao.ParentDAO;
import dao.StudentDAO;
import util.DatabaseConnection;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/RegisterStudentServlet")
public class RegisterStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private ParentDAO parentDAO;
    private StudentDAO studentDAO;

    @Override
    public void init() {
        parentDAO = new ParentDAO();
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("activeTab", "directory");

        // Tarik senarai penjaga sedia ada beserta nama anak-anak mereka untuk fungsi Pick & Auto-isi
        List<Parent> existingParents = new ArrayList<>();
        Map<Integer, String> parentChildrenMap = new HashMap<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            if (conn != null) {
                String sqlParents = "SELECT * FROM PARENT ORDER BY parentName ASC";
                try (PreparedStatement ps = conn.prepareStatement(sqlParents);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Parent p = new Parent();
                        p.setParentID(rs.getInt("parentID"));
                        p.setParentName(rs.getString("parentName"));
                        p.setParentEmail(rs.getString("parentEmail"));
                        p.setParentPhoneNumber(rs.getString("parentPhoneNumber"));
                        p.setParentIC(rs.getString("parentIC"));
                        p.setParentGender(rs.getString("parentGender"));
                        p.setParentAddress(rs.getString("parentAddress"));
                        existingParents.add(p);
                    }
                }

                String sqlStudents = "SELECT parentID, studentName FROM STUDENT ORDER BY studentID ASC";
                try (PreparedStatement ps = conn.prepareStatement(sqlStudents);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int pid = rs.getInt("parentID");
                        String sName = rs.getString("studentName");
                        if (sName != null && !sName.isBlank()) {
                            String current = parentChildrenMap.get(pid);
                            parentChildrenMap.put(pid, (current == null) ? sName : current + ", " + sName);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("existingParents", existingParents);
        request.setAttribute("parentChildrenMap", parentChildrenMap);
        request.getRequestDispatcher("registerStudent.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Semak sama ada penjaga sedia ada dipilih (existingParentId > 0)
            String existingParentIdStr = request.getParameter("existingParentId");
            int targetParentId = 0;
            boolean proceedToAddStudent = false;

            if (existingParentIdStr != null && !existingParentIdStr.trim().isEmpty()) {
                try {
                    targetParentId = Integer.parseInt(existingParentIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            if (targetParentId > 0) {
                // Guna ID penjaga sedia ada tanpa mencipta rekod pendua dalam jadual PARENT
                proceedToAddStudent = true;
            } else {
                // ==========================================
                // 1. CIPTA PENJAGA BAHARU JIKA TIADA DALAM REKOD
                // ==========================================
                String parentName = request.getParameter("parentName");
                String parentEmail = request.getParameter("parentEmail");
                String parentPhone = request.getParameter("parentPhone");
                String parentIC = request.getParameter("parentIc");
                String parentGender = request.getParameter("parentGender");
                String parentAddress = request.getParameter("parentAddress");
                String parentPassword = "keedflix123";

                targetParentId = getNextId("Parent", "parentID");

                Parent parent = new Parent();
                parent.setParentID(targetParentId);
                parent.setParentName(parentName);
                parent.setParentEmail(parentEmail);
                parent.setParentPhoneNumber(parentPhone);
                parent.setParentPassword(parentPassword);
                parent.setParentIC(parentIC);
                parent.setParentGender(parentGender);
                parent.setParentAddress(parentAddress);

                proceedToAddStudent = parentDAO.addParent(parent);
            }

            if (proceedToAddStudent) {
                // ==========================================
                // 2. SIMPAN DATA MURID BAHARU DI BAWAH PARENTID TERSEBUT
                // ==========================================
                String studentName = request.getParameter("studentName");
                String studentAgeStr = request.getParameter("studentAge");
                String studentClass = request.getParameter("studentClass");
                String studentIC = request.getParameter("studentIc");
                String studentGender = request.getParameter("studentGender");
                
                int age = (studentAgeStr != null && !studentAgeStr.isEmpty()) ? Integer.parseInt(studentAgeStr) : 0;
                int newStudentId = getNextId("Student", "studentID");

                Student student = new Student();
                student.setStudentID(newStudentId);
                student.setStudentName(studentName);
                student.setStudentAge(age);
                student.setStudentClass(studentClass);
                student.setParentID(targetParentId);
                student.setStudentIC(studentIC);
                student.setStudentGender(studentGender);

                studentDAO.addStudent(student);
            }

            response.sendRedirect("StudentDirectoryServlet?tab=directory&success=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Gagal mendaftar murid dan penjaga.");
        }
    }

    private int getNextId(String tableName, String columnName) {
        int nextId = 1;
        String sql = "SELECT MAX(" + columnName + ") FROM " + tableName;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                nextId = rs.getInt(1) + 1;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return nextId;
    }
}