import bean.LearningProgress;
import bean.Student;
import dao.LearningProgressDAO;
import dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

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

            // Jika ada parameter edit
            String editIdParam = request.getParameter("editProgressID");
            if (editIdParam != null && !editIdParam.isEmpty()) {
                int editId = Integer.parseInt(editIdParam);
                LearningProgressDAO lpDAO = new LearningProgressDAO();
                List<LearningProgress> editingRecord = lpDAO.getProgressByStudentId(editId);
                request.setAttribute("editingRecord", editingRecord);
            }
            
            // Tarik studentId lalai jika ada
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
        
        try {
            LearningProgressDAO dao = new LearningProgressDAO();
            int studentID = Integer.parseInt(request.getParameter("studentID"));
            String progressDate = request.getParameter("progressDate");
            String assessorName = request.getParameter("assessorName");
            String homeRecommendation = request.getParameter("homeRecommendation");
            String editProgressIDStr = request.getParameter("editProgressID");

            boolean isSingleEdit = (editProgressIDStr != null && !editProgressIDStr.equals("0") && !editProgressIDStr.isEmpty());

            if (isSingleEdit) {
                // MODEDIT REKOD TUNGGAL
                int progressID = Integer.parseInt(editProgressIDStr);
                String domain = request.getParameter("singleDomainName");
                int learningID = "Writing".equals(domain) ? 2 : "Counting".equals(domain) ? 3 : 1;

                LearningProgress lp = new LearningProgress();
                lp.setProgressID(progressID);
                lp.setLearningID(learningID);
                lp.setStudentID(studentID);
                lp.setProgressName(request.getParameter("singleProgressName"));
                lp.setProgressDate(progressDate);
                
                int scale = Integer.parseInt(request.getParameter("singleRatingScale"));
                lp.setRatingScale(scale);
                lp.setProgressPercentage(scale * 20.0);
                lp.setProgressStatus(getStatusFromScale(scale));
                lp.setTeacherID(201);
                lp.setAssessorName(assessorName);
                lp.setHomeRecommendation(homeRecommendation);
                lp.setNotes(request.getParameter("singleNotes"));
       //         lp.setRubricCriteriaJson(request.getParameter("singleRubricCriteriaJson"));

                dao.updateLearningProgress(lp);

            } else {
                // SIMPAN BATCH (3 TERAS: READING, WRITING, COUNTING)
                String activeDomainFilter = request.getParameter("activeDomainFilter");
                String[] domains = "All".equals(activeDomainFilter) 
                        ? new String[]{"Reading", "Writing", "Counting"} 
                        : new String[]{activeDomainFilter};

                for (String dom : domains) {
                    int learningID = "Writing".equals(dom) ? 2 : "Counting".equals(dom) ? 3 : 1;
                    
                    String topicName = request.getParameter(dom.toLowerCase() + "_progressName");
                    String scaleStr = request.getParameter(dom.toLowerCase() + "_ratingScale");
                    int scale = (scaleStr != null && !scaleStr.isEmpty()) ? Integer.parseInt(scaleStr) : 4;
                    String notes = request.getParameter(dom.toLowerCase() + "_notes");
                    String criteriaJson = request.getParameter(dom.toLowerCase() + "_rubricCriteriaJson");

                    LearningProgress lp = new LearningProgress();
                    lp.setLearningID(learningID);
                    lp.setStudentID(studentID);
                    lp.setProgressName(topicName != null ? topicName : "Pentaksiran " + dom);
                    lp.setProgressDate(progressDate);
                    lp.setRatingScale(scale);
                    lp.setProgressPercentage(scale * 20.0);
                    lp.setProgressStatus(getStatusFromScale(scale));
                    lp.setTeacherID(201);
                    lp.setAssessorName(assessorName);
                    lp.setHomeRecommendation(homeRecommendation);
                    lp.setNotes(notes);
        //            lp.setRubricCriteriaJson(criteriaJson);

                    dao.addLearningProgress(lp);
                }
            }

            response.sendRedirect(request.getContextPath() + "/learningProgress?studentId=" + studentID);
            return;

        } catch (Exception e) {
            e.printStackTrace();
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