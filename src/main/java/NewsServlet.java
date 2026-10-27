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
        
        // Ambil peranan pengguna dari sesi (lalai kepada 'Teacher' jika tiada)
        String userRole = (String) session.getAttribute("userRole");
        if (userRole == null) userRole = "Teacher"; 

        String action = request.getParameter("action");

        try {
            // Teacher & Admin boleh Tambah (Add)
            if ("add".equals(action) && "Teacher".equals(userRole)) {
                News news = new News();
                news.setNewsID(getNextNewsId());
                news.setNewsTitle(request.getParameter("title"));
                news.setNewsCategory(request.getParameter("category"));
                news.setTargetAudience(request.getParameter("targetAudience"));
                news.setNewsContent(request.getParameter("content"));
                news.setTeacherID(201); // ID Guru contoh
                news.setNewsDate(new Timestamp(System.currentTimeMillis()));
                news.setPinned(request.getParameter("pinned") != null);

                newsDAO.addNews(news);

            // Teacher & Admin boleh Kemas Kini (Update)
            } else if ("update".equals(action) && "Teacher".equals(userRole)) {
                News news = new News();
                news.setNewsID(Integer.parseInt(request.getParameter("newsID")));
                news.setNewsTitle(request.getParameter("title"));
                news.setNewsCategory(request.getParameter("category"));
                news.setTargetAudience(request.getParameter("targetAudience"));
                news.setNewsContent(request.getParameter("content"));
                news.setTeacherID(201);
                news.setPinned(request.getParameter("pinned") != null);

                newsDAO.updateNews(news);

            // HANYA ADMIN BOLEH PADAM (Delete) - Teacher TIDAK BOLEH padam
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

    // Fungsi utiliti untuk menjana ID baharu secara manual jika tiada sequence auto
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