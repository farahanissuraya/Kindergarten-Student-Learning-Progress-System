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
import util.DatabaseConnection; 

@WebServlet("/TrendChartServlet")
public class TrendChartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentId = request.getParameter("studentId");
        if (studentId == null || studentId.isBlank()) {
            studentId = "S101"; // Fallback ID
        }

        // Arrays to hold scores for 7 weeks
        int[] readingData = new int[7];
        int[] writingData = new int[7];
        int[] countingData = new int[7];
        boolean hasData = false;

        String sql = "SELECT week_number, reading_score, writing_score, counting_score "
                   + "FROM progress_trajectory "
                   + "WHERE student_id = ? "
                   + "ORDER BY week_number ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, studentId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    hasData = true;
                    int week = rs.getInt("week_number");
                    if (week >= 1 && week <= 7) {
                        int index = week - 1;
                        readingData[index] = rs.getInt("reading_score");
                        writingData[index] = rs.getInt("writing_score");
                        countingData[index] = rs.getInt("counting_score");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

        // Use default trajectory if DB fails or data is empty
        if (!hasData) {
            readingData = new int[]{15, 22, 26, 30, 32, 36, 38};
            writingData = new int[]{10, 16, 20, 24, 28, 30, 34};
            countingData = new int[]{22, 28, 32, 36, 38, 40, 40};
        }

        request.setAttribute("readingData", readingData);
        request.setAttribute("writingData", writingData);
        request.setAttribute("countingData", countingData);

        request.getRequestDispatcher("trendChart.jsp").forward(request, response);
    }
}