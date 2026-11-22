import bean.LearningProgress;
import bean.Student;
import dao.LearningProgressDAO;
import dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/createProgress")
public class CreateProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            StudentDAO studentDAO = new StudentDAO();
            List<Student> students = studentDAO.getAllStudents();
            request.setAttribute("students", students);

            String studentIdParam = request.getParameter("studentId");
            if (studentIdParam != null && !studentIdParam.isEmpty()) {
                request.setAttribute("targetStudentId", Integer.parseInt(studentIdParam));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        request.getRequestDispatcher("createProgress.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            LearningProgressDAO dao = new LearningProgressDAO();
            int studentID = Integer.parseInt(request.getParameter("studentID"));
            String progressDate = request.getParameter("progressDate");
            String assessorName = request.getParameter("assessorName");
            String homeRecommendation = request.getParameter("homeRecommendation");
            String editProgressIDStr = request.getParameter("editProgressID");
            String editReportDate = request.getParameter("editReportDate");

            HttpSession session = request.getSession(false);
            int teacherID = 102;
            if (session != null && session.getAttribute("teacherID") != null) {
                try {
                    teacherID = Integer.parseInt(session.getAttribute("teacherID").toString());
                } catch (Exception ignored) {}
            }

            boolean isSingleEdit = (editProgressIDStr != null && !editProgressIDStr.equals("0") && !editProgressIDStr.isEmpty());
            boolean isDateGroupEdit = (editReportDate != null && !editReportDate.trim().isEmpty());

            if (isSingleEdit) {
                int progressID = Integer.parseInt(editProgressIDStr);
                String domain = request.getParameter("singleDomainName");

                LearningProgress lp = new LearningProgress();
                lp.setProgressID(progressID);
                lp.setDomainName(domain != null ? domain : "Reading");
                lp.setStudentID(studentID);
                lp.setProgressName(request.getParameter("singleProgressName"));
                lp.setProgressDate(progressDate);

                int scale = Integer.parseInt(request.getParameter("singleRatingScale"));
                lp.setRatingScale(scale);
                lp.setProgressPercentage(scale * 20.0);
                lp.setProgressStatus(getStatusFromScale(scale));
                lp.setTeacherID(teacherID);
                lp.setAssessorName(assessorName);
                lp.setHomeRecommendation(homeRecommendation);
                lp.setNotes(request.getParameter("singleNotes"));

                dao.updateLearningProgress(lp);

            } else if (isDateGroupEdit) {
                // MOD EDIT LAPORAN BERDASARKAN TARIKH: Peta rekod asal ikut domain (READING / WRITING / COUNTING)
                List<LearningProgress> existingList = dao.getRecordsByStudentAndDate(studentID, editReportDate.trim());
                Map<String, LearningProgress> existingByDomain = new HashMap<>();
                for (LearningProgress item : existingList) {
                    if (item.getDomainName() != null) {
                        existingByDomain.put(item.getDomainName().trim().toUpperCase(), item);
                    }
                }

                String[] domains = {"Reading", "Writing", "Counting"};
                for (String dom : domains) {
                    String key = dom.toLowerCase();
                    String topicName = request.getParameter(key + "_progressName");
                    String scaleStr = request.getParameter(key + "_ratingScale");
                    int scale = (scaleStr != null && !scaleStr.isEmpty()) ? Integer.parseInt(scaleStr) : 4;
                    String notes = request.getParameter(key + "_notes");

                    LearningProgress existingRec = existingByDomain.get(dom.toUpperCase());
                    LearningProgress lp = (existingRec != null) ? existingRec : new LearningProgress();

                    lp.setDomainName(dom);
                    lp.setStudentID(studentID);
                    lp.setProgressName(topicName != null && !topicName.trim().isEmpty() ? topicName : "Pentaksiran " + dom);
                    lp.setProgressDate(progressDate);
                    lp.setRatingScale(scale);
                    lp.setProgressPercentage(scale * 20.0);
                    lp.setProgressStatus(getStatusFromScale(scale));
                    lp.setTeacherID(teacherID);
                    lp.setAssessorName(assessorName);
                    lp.setHomeRecommendation(homeRecommendation);
                    lp.setNotes(notes);

                    if (existingRec != null && existingRec.getProgressID() > 0) {
                        dao.updateLearningProgress(lp);
                    } else {
                        dao.addLearningProgress(lp);
                    }
                }

            } else {
                // MOD TAMBAH REKOD BAHARU (CREATE)
                String activeDomainFilter = request.getParameter("activeDomainFilter");
                String[] domains = (activeDomainFilter == null || "All".equalsIgnoreCase(activeDomainFilter))
                        ? new String[]{"Reading", "Writing", "Counting"}
                        : new String[]{activeDomainFilter};

                for (String dom : domains) {
                    String key = dom.toLowerCase();
                    String topicName = request.getParameter(key + "_progressName");
                    String scaleStr = request.getParameter(key + "_ratingScale");
                    int scale = (scaleStr != null && !scaleStr.isEmpty()) ? Integer.parseInt(scaleStr) : 4;
                    String notes = request.getParameter(key + "_notes");

                    LearningProgress lp = new LearningProgress();
                    lp.setDomainName(dom);
                    lp.setStudentID(studentID);
                    lp.setProgressName(topicName != null && !topicName.trim().isEmpty() ? topicName : "Pentaksiran " + dom);
                    lp.setProgressDate(progressDate);
                    lp.setRatingScale(scale);
                    lp.setProgressPercentage(scale * 20.0);
                    lp.setProgressStatus(getStatusFromScale(scale));
                    lp.setTeacherID(teacherID);
                    lp.setAssessorName(assessorName);
                    lp.setHomeRecommendation(homeRecommendation);
                    lp.setNotes(notes);

                    dao.addLearningProgress(lp);
                }
            }

            response.sendRedirect(request.getContextPath() + "/ProgressServlet?studentId=" + studentID);
            return;

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Ralat simpan rekod: " + e.getMessage());
        }

        doGet(request, response);
    }

    private String getStatusFromScale(int scale) {
        switch (scale) {
            case 5: return "Mastered";
            case 4: return "Proficient";
            case 3: return "Developing";
            case 2: return "Emerging";
            default: return "Not Started";
        }
    }
}