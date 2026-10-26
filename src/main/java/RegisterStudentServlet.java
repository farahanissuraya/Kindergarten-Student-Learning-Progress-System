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
        // Paparkan halaman borang pendaftaran
        request.setAttribute("activeTab", "directory"); // Set tab aktif untuk sidebar
        request.getRequestDispatcher("registerStudent.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // ==========================================
            // 1. AMBIL DATA PENJAGA (PARENT) DARI BORANG
            // ==========================================
            String parentName = request.getParameter("parentName");
            String parentEmail = request.getParameter("parentEmail");
            String parentPhone = request.getParameter("parentPhone"); // Ambil terus sebagai String
            String parentIC = request.getParameter("parentIc");
            String parentGender = request.getParameter("parentGender");
            String parentAddress = request.getParameter("parentAddress");
            String parentPassword = "keedflix123"; // Kata laluan lalai untuk ibubapa baharu

            // Jana ID Penjaga Baharu (Ambil nilai maksimum + 1 dari pangkalan data)
            int newParentId = getNextId("Parent", "parentID");

            Parent parent = new Parent();
            parent.setParentID(newParentId);
            parent.setParentName(parentName);
            parent.setParentEmail(parentEmail);
            parent.setParentPhoneNumber(parentPhone); // Set menggunakan String terus
            parent.setParentPassword(parentPassword);
            parent.setParentIC(parentIC);
            parent.setParentGender(parentGender);
            parent.setParentAddress(parentAddress);

            // Simpan Parent ke Database
            boolean isParentAdded = parentDAO.addParent(parent);

            if (isParentAdded) {
                // ==========================================
                // 2. AMBIL DATA MURID (STUDENT) DARI BORANG
                // ==========================================
                String studentName = request.getParameter("studentName");
                String studentAgeStr = request.getParameter("studentAge");
                String studentClass = request.getParameter("studentClass");
                String studentIC = request.getParameter("studentIc");
                String studentGender = request.getParameter("studentGender");
                
                int age = (studentAgeStr != null && !studentAgeStr.isEmpty()) ? Integer.parseInt(studentAgeStr) : 0;
                
                // Jana ID Murid Baharu
                int newStudentId = getNextId("Student", "studentID");

                Student student = new Student();
                student.setStudentID(newStudentId);
                student.setStudentName(studentName);
                student.setStudentAge(age);
                student.setStudentClass(studentClass);
                student.setParentID(newParentId); // Hubungkan dengan ID Penjaga di atas
                student.setStudentIC(studentIC);
                student.setStudentGender(studentGender);

                // Simpan Student ke Database
                studentDAO.addStudent(student);
            }

            // Jika berjaya, kembali ke halaman senarai murid
            response.sendRedirect("StudentDirectoryServlet?tab=directory&success=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Gagal mendaftar murid dan penjaga.");
        }
    }

    // Fungsi utiliti untuk menjana ID baharu secara automatik (Auto-Increment Manual)
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