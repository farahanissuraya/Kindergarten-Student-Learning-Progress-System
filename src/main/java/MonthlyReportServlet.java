import bean.LearningProgress;
import bean.Student;
import dao.LearningProgressDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/MonthlyReportServlet")
public class MonthlyReportServlet extends HttpServlet {

    private final LearningProgressDAO dao = new LearningProgressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        int studentID = -1;
        String sidParam = request.getParameter("studentId");
        if (sidParam == null || sidParam.isEmpty()) sidParam = request.getParameter("studentID");
        if (sidParam != null && !sidParam.isEmpty()) {
            try { studentID = Integer.parseInt(sidParam.trim()); } catch (Exception ignored) {}
        }

        Student student = dao.getStudentById(studentID);
        if (student == null) {
            out.print("{\"error\":\"Murid tidak ditemui\"}");
            return;
        }

        // Ambil semua rekod pentaksiran murid dari Oracle KINDERGARTEN
        List<LearningProgress> allRecords = dao.getRecordsByStudentId(studentID);

        // Kumpul senarai bulan unik (YYYY-MM)
        Set<String> availableMonths = new LinkedHashSet<>();
        for (LearningProgress lp : allRecords) {
            String dt = lp.getProgressDate();
            if (dt != null && dt.trim().length() >= 7) {
                availableMonths.add(dt.trim().substring(0, 7));
            }
        }

        String selectedMonth = request.getParameter("month");
        if (selectedMonth == null || selectedMonth.trim().isEmpty() || !availableMonths.contains(selectedMonth.trim())) {
            if (!availableMonths.isEmpty()) {
                selectedMonth = availableMonths.iterator().next();
            } else {
                selectedMonth = new SimpleDateFormat("yyyy-MM").format(new Date());
                availableMonths.add(selectedMonth);
            }
        } else {
            selectedMonth = selectedMonth.trim();
        }

        // Kira purata mingguan -> bulanan bagi Reading, Writing & Counting
        double readSum = 0; int readCount = 0;
        double writeSum = 0; int writeCount = 0;
        double countSum = 0; int countCount = 0;

        Set<String> distinctWeeks = new LinkedHashSet<>();
        Set<String> readingTopics = new LinkedHashSet<>();
        Set<String> writingTopics = new LinkedHashSet<>();
        Set<String> countingTopics = new LinkedHashSet<>();

        String reportNote = "";
        HttpSession session = request.getSession(false);
        String adminSignature = (session != null && session.getAttribute("userName") != null)
                ? session.getAttribute("userName").toString()
                : "Eleanor Ward, Centre Principal";

        for (LearningProgress lp : allRecords) {
            String dt = (lp.getProgressDate() != null) ? lp.getProgressDate().trim() : "";
            if (!dt.startsWith(selectedMonth)) continue;

            if (dt.length() >= 10) distinctWeeks.add(dt.substring(0, 10));

            String domain = (lp.getDomainName() != null) ? lp.getDomainName().trim() : "";
            String topic  = (lp.getProgressName() != null) ? lp.getProgressName().trim() : "";

            if ("Reading".equalsIgnoreCase(domain)) {
                readSum += lp.getProgressPercentage();
                readCount++;
                if (!topic.isEmpty()) readingTopics.add(topic);
            } else if ("Writing".equalsIgnoreCase(domain)) {
                writeSum += lp.getProgressPercentage();
                writeCount++;
                if (!topic.isEmpty()) writingTopics.add(topic);
            } else if ("Counting".equalsIgnoreCase(domain)) {
                countSum += lp.getProgressPercentage();
                countCount++;
                if (!topic.isEmpty()) countingTopics.add(topic);
            }

            if (reportNote.isEmpty() && lp.getNotes() != null && !lp.getNotes().trim().isEmpty()) {
                reportNote = lp.getNotes().trim();
            }
            if (lp.getAssessorName() != null && !lp.getAssessorName().trim().isEmpty()) {
                adminSignature = lp.getAssessorName().trim();
            }
        }

        int readingScore  = (readCount > 0)  ? (int) Math.round(readSum / readCount)   : 0;
        int writingScore  = (writeCount > 0) ? (int) Math.round(writeSum / writeCount) : 0;
        int countingScore = (countCount > 0) ? (int) Math.round(countSum / countCount) : 0;

        int activeDomains = (readCount > 0 ? 1 : 0) + (writeCount > 0 ? 1 : 0) + (countCount > 0 ? 1 : 0);
        int overallScore  = (activeDomains > 0)
                ? (int) Math.round((double) (readingScore + writingScore + countingScore) / activeDomains)
                : 0;

        String masteryLevel = (overallScore >= 90) ? "Mastered Level"
                            : (overallScore >= 75) ? "Proficient Level"
                            : (overallScore >= 50) ? "Developing Level"
                            : "Needs Guidance";

        String[] monthsEn = {"January", "February", "March", "April", "May", "June",
                             "July", "August", "September", "October", "November", "December"};

        String selectedMonthLabel = formatMonthLabel(selectedMonth, monthsEn);

        if (reportNote.isEmpty()) {
            reportNote = "Demonstrating consistent enthusiasm in daily literacy circle and counting challenges across " +
                         Math.max(distinctWeeks.size(), 1) + " weekly evaluation(s).";
        }

        String verificationId = String.format("KED-%s-REP-%04d-%s",
                selectedMonth.substring(0, 4),
                student.getStudentID(),
                selectedMonth.substring(5, 7));

        StringBuilder json = new StringBuilder("{");
        json.append("\"studentId\":").append(student.getStudentID()).append(",");
        json.append("\"studentName\":\"").append(esc(student.getStudentName())).append("\",");
        json.append("\"studentClass\":\"").append(esc(student.getStudentClass() != null ? student.getStudentClass() : "Kindergarten 3B")).append("\",");
        json.append("\"studentAge\":").append(student.getStudentAge()).append(",");
        json.append("\"selectedMonth\":\"").append(esc(selectedMonth)).append("\",");
        json.append("\"selectedMonthLabel\":\"").append(esc(selectedMonthLabel)).append("\",");
        json.append("\"weeksCount\":").append(distinctWeeks.size()).append(",");
        json.append("\"readingScore\":").append(readingScore).append(",");
        json.append("\"writingScore\":").append(writingScore).append(",");
        json.append("\"countingScore\":").append(countingScore).append(",");
        json.append("\"overallScore\":").append(overallScore).append(",");
        json.append("\"masteryLevel\":\"").append(esc(masteryLevel)).append("\",");
        json.append("\"reportNote\":\"").append(esc(reportNote)).append("\",");
        json.append("\"adminSignature\":\"").append(esc(adminSignature)).append("\",");
        json.append("\"verificationId\":\"").append(esc(verificationId)).append("\",");

        json.append("\"months\":[");
        int mIdx = 0;
        for (String mKey : availableMonths) {
            if (mIdx++ > 0) json.append(",");
            json.append("{\"value\":\"").append(esc(mKey)).append("\",\"label\":\"")
                .append(esc(formatMonthLabel(mKey, monthsEn))).append("\"}");
        }
        json.append("],");

        json.append("\"readingTopics\":").append(toJsonArray(readingTopics)).append(",");
        json.append("\"writingTopics\":").append(toJsonArray(writingTopics)).append(",");
        json.append("\"countingTopics\":").append(toJsonArray(countingTopics));
        json.append("}");

        out.print(json.toString());
    }

    private String formatMonthLabel(String ym, String[] monthsEn) {
        if (ym != null && ym.contains("-")) {
            String[] p = ym.split("-");
            try {
                int m = Integer.parseInt(p[1]);
                if (m >= 1 && m <= 12) return monthsEn[m - 1] + " " + p[0];
            } catch (Exception ignored) {}
        }
        return ym;
    }

    private String toJsonArray(Set<String> items) {
        StringBuilder sb = new StringBuilder("[");
        int i = 0;
        for (String s : items) {
            if (i++ > 0) sb.append(",");
            sb.append("\"").append(esc(s)).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", " ");
    }
}