import bean.Student;
import dao.StudentDAO;
import dao.LearningProgressDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/RadarChartServlet")
public class RadarChartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int studentID = 1;
            String studentIdParam = request.getParameter("studentId");
            if (studentIdParam != null && !studentIdParam.trim().isEmpty()) {
                studentID = Integer.parseInt(studentIdParam);
            }

            // 1. Tarik Data Sebenar Murid dari Database
            StudentDAO studentDAO = new StudentDAO();
            Student student = studentDAO.getStudentById(studentID);

            if (student != null) {
                // 2. Tarik Skala Sebenar Murid dari Database (Reading, Writing, Counting)
                LearningProgressDAO progressDAO = new LearningProgressDAO();
                
                int readingScale = progressDAO.getDomainScale(studentID, "reading");
                int writingScale = progressDAO.getDomainScale(studentID, "writing");
                int countingScale = progressDAO.getDomainScale(studentID, "counting");

                // 3. Tarik Purata Kelas Sebenar dari Database (SQL AVG)
                double classReadingRadar = progressDAO.getClassAverageScale("reading");
                double classWritingRadar = progressDAO.getClassAverageScale("writing");
                double classCountingRadar = progressDAO.getClassAverageScale("counting");

                // 4. Kirakan Sasaran Umur mengikut umur murid dalam Database
                int targetScale = student.getStudentAge() >= 6 ? 5 : (student.getStudentAge() == 5 ? 4 : 3);
                double targetRadarValue = targetScale * 2.0;

                // Semak jurang perkembangan
                int gapCount = 0;
                if (readingScale < targetScale) gapCount++;
                if (writingScale < targetScale) gapCount++;
                if (countingScale < targetScale) gapCount++;
                
                // Semak sama ada murid mempunyai rekod pentaksiran
                int totalLogs = progressDAO.getProgressByStudentId(studentID).size();
                boolean isNewStudent = (totalLogs == 0);

                request.setAttribute("isNewStudent", isNewStudent);

                // Hantar data sebenar ke JSP
                request.setAttribute("student", student);
                request.setAttribute("readingScale", readingScale);
                request.setAttribute("writingScale", writingScale);
                request.setAttribute("countingScale", countingScale);
                
                request.setAttribute("classReadingRadar", classReadingRadar);
                request.setAttribute("classWritingRadar", classWritingRadar);
                request.setAttribute("classCountingRadar", classCountingRadar);

                request.setAttribute("targetScale", targetScale);
                request.setAttribute("targetRadarValue", targetRadarValue);
                request.setAttribute("gapCount", gapCount);
                request.setAttribute("hasGap", gapCount > 0);
            } else {
                request.setAttribute("errorMessage", "Rekod murid tidak dijumpai dalam pangkalan data.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Ralat sistem semasa memuatkan data pangkalan data.");
        }

        request.getRequestDispatcher("radarChart.jsp").forward(request, response);
    }
}