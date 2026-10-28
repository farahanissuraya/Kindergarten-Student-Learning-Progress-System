import bean.News;
import dao.NewsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/NewsServlet")
public class NewsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private NewsDAO newsDAO;

    @Override
    public void init() {
        newsDAO = new NewsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<News> newsList = newsDAO.getAllNews();
            request.setAttribute("newsList", newsList);
            request.setAttribute("activeTab", "news");
            request.getRequestDispatcher("news.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Ralat memuatkan data buletin.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Ambil peranan pengguna daripada session
        String userRole = (String) session.getAttribute("userRole");
        if (userRole == null) userRole = "Teacher"; 

        // Ambil teacherID dinamik daripada session
        Integer loggedInTeacherID = (Integer) session.getAttribute("teacherID");
        
        // Sekiranya tiada ID dalam session, dapatkan ID guru pertama dari Oracle secara dinamik
        if (loggedInTeacherID == null || loggedInTeacherID == 0) {
            loggedInTeacherID = newsDAO.getValidTeacherID();
        }

        String action = request.getParameter("action");

        try {
            // Mana-mana pengguna bernama 'Teacher' atau 'Admin' berhak publish/update
            if ("add".equals(action) && ("Teacher".equals(userRole) || "Admin".equals(userRole))) {
                News news = new News();
                news.setNewsID(getNextNewsId());
                news.setNewsTitle(request.getParameter("title"));
                news.setNewsCategory(request.getParameter("category"));
                news.setTargetAudience(request.getParameter("targetAudience"));
                news.setNewsContent(request.getParameter("content"));
                
                // Gunakan ID Guru yang dinamik dari Oracle
                news.setTeacherID(loggedInTeacherID);
                
                news.setNewsDate(new Timestamp(System.currentTimeMillis()));
                news.setPinned(request.getParameter("pinned") != null);

                newsDAO.addNews(news);

            } else if ("update".equals(action) && ("Teacher".equals(userRole) || "Admin".equals(userRole))) {
                News news = new News();
                news.setNewsID(Integer.parseInt(request.getParameter("newsID")));
                news.setNewsTitle(request.getParameter("title"));
                news.setNewsCategory(request.getParameter("category"));
                news.setTargetAudience(request.getParameter("targetAudience"));
                news.setNewsContent(request.getParameter("content"));
                
                news.setTeacherID(loggedInTeacherID);
                news.setPinned(request.getParameter("pinned") != null);

                newsDAO.updateNews(news);

            } else if ("delete".equals(action) && "Admin".equals(userRole)) {
                int newsID = Integer.parseInt(request.getParameter("newsID"));
                newsDAO.deleteNews(newsID);
            }

            response.sendRedirect("NewsServlet");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("NewsServlet?error=true");
        }
    }

    private int getNextNewsId() {
        try {
            List<News> all = newsDAO.getAllNews();
            if (all.isEmpty()) return 1;
            int max = 0;
            for (News n : all) {
                if (n.getNewsID() > max) max = n.getNewsID();
            }
            return max + 1;
        } catch (Exception e) {
            return (int) (System.currentTimeMillis() % 10000);
        }
    }
}