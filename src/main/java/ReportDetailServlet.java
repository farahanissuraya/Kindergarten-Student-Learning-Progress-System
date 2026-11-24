import bean.LearningProgress;
import bean.Student;
import dao.LearningProgressDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@WebServlet("/reportDetail")
public class ReportDetailServlet extends HttpServlet {

    private final LearningProgressDAO dao = new LearningProgressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") != null)
                ? session.getAttribute("role").toString()
                : (session != null && session.getAttribute("userRole") != null)
                ? session.getAttribute("userRole").toString()
                : "Teacher";

        boolean isParent = "Parent".equalsIgnoreCase(role.trim());
        boolean isAdmin  = "Admin".equalsIgnoreCase(role.trim());

        int studentID = 301;
        String sidParam = request.getParameter("studentId");
        if (sidParam == null || sidParam.isEmpty()) sidParam = request.getParameter("studentID");
        if (sidParam != null && !sidParam.isEmpty()) {
            try { studentID = Integer.parseInt(sidParam); } catch (Exception ignored) {}
        }

        Student student = dao.getStudentById(studentID);
        if (student == null) {
            response.sendRedirect(request.getContextPath() + "/learningProgress");
            return;
        }

        String latestDate = dao.getLatestReportDate(studentID);
        String reportDate = request.getParameter("reportDate");
        if (reportDate == null || reportDate.trim().isEmpty()) {
            reportDate = latestDate;
        }

        List<LearningProgress> records = (reportDate != null)
                ? dao.getRecordsByStudentAndDate(studentID, reportDate)
                : Collections.emptyList();

        // Susun kad mengikut urutan Counting (1), Writing (2), Reading (3)
        if (records != null && !records.isEmpty()) {
            records.sort(Comparator.comparingInt(r -> {
                String d = r.getDomainName() != null ? r.getDomainName().trim().toLowerCase() : "";
                if ("counting".equals(d)) return 1;
                if ("writing".equals(d)) return 2;
                if ("reading".equals(d)) return 3;
                return 4;
            }));
        }

        double totalPct = 0;
        for (LearningProgress r : records) {
            totalPct += r.getProgressPercentage();
        }
        int avgPercentage = records.isEmpty() ? 0 : (int) Math.round(totalPct / records.size());
        boolean isLatest = (latestDate != null && latestDate.equals(reportDate));

        request.setAttribute("student", student);
        request.setAttribute("reportDate", reportDate);
        request.setAttribute("records", records);
        request.setAttribute("avgPercentage", avgPercentage);
        request.setAttribute("isLatest", isLatest);
        request.setAttribute("isParent", isParent);
        request.setAttribute("isAdmin", isAdmin);

        request.getRequestDispatcher("/reportDetail.jsp").forward(request, response);
    }
}