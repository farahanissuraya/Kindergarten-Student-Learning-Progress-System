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
import util.DatabaseConnection; // Menggunakan utiliti sambungan Oracle anda

@WebServlet("/RadarChartServlet")
public class RadarChartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Ambil student_id dari request (fallback ke ID 'S101' jika tiada)
        String studentId = request.getParameter("studentId");
        if (studentId == null || studentId.isBlank()) {
            studentId = "S101";
        }

        String studentName = "Student";
        
        // Nilai skor kompetensi (skala 1 - 10)
        double scorePhonics = 6.0;
        double scoreSightWords = 6.0;
        double scorePencilGrip = 6.0;
        double scoreLetterWriting = 6.0;
        double scoreCounting = 6.0;

        // Query Oracle DB dari skema KINDERGARTEN
        String sql = "SELECT s.student_name, "
                   + "       COALESCE(l.phonics_score, 6) AS phonics, "
                   + "       COALESCE(l.sight_words_score, 6) AS sight_words, "
                   + "       COALESCE(l.pencil_grip_score, 6) AS pencil_grip, "
                   + "       COALESCE(l.letter_writing_score, 6) AS letter_writing, "
                   + "       COALESCE(l.counting_score, 6) AS counting "
                   + "FROM student s "
                   + "LEFT JOIN learning_progress l ON s.student_id = l.student_id "
                   + "WHERE s.student_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, studentId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    studentName = rs.getString("student_name");
                    scorePhonics = rs.getDouble("phonics");
                    scoreSightWords = rs.getDouble("sight_words");
                    scorePencilGrip = rs.getDouble("pencil_grip");
                    scoreLetterWriting = rs.getDouble("letter_writing");
                    scoreCounting = rs.getDouble("counting");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        // Tetapkan atribut untuk JSP
        request.setAttribute("studentName", studentName);
        request.setAttribute("scorePhonics", scorePhonics);
        request.setAttribute("scoreSightWords", scoreSightWords);
        request.setAttribute("scorePencilGrip", scorePencilGrip);
        request.setAttribute("scoreLetterWriting", scoreLetterWriting);
        request.setAttribute("scoreCounting", scoreCounting);

        // Majukan ke radarChart.jsp
        request.getRequestDispatcher("radarChart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}