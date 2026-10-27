package dao;

import bean.News;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewsDAO {

    public boolean addNews(News news) throws Exception {
        String sql = "INSERT INTO News (newsID, newsTitle, newsContent, newsCategory, teacherID, targetAudience, pinned) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, news.getNewsID());
            pstmt.setString(2, news.getNewsTitle());
            pstmt.setString(3, news.getNewsContent());
            pstmt.setString(4, news.getNewsCategory());
            pstmt.setInt(5, news.getTeacherID());
            pstmt.setString(6, news.getTargetAudience());
            pstmt.setInt(7, news.isPinned() ? 1 : 0); // Simpan boolean sebagai 1 atau 0 dalam Oracle
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<News> getAllNews() throws Exception {
        List<News> list = new ArrayList<>();
        // Susun berita yang 'pinned' di atas sekali, diikuti tarikh terkini
        String sql = "SELECT * FROM News ORDER BY pinned DESC, newsDate DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                News news = new News();
                news.setNewsID(rs.getInt("newsID"));
                news.setNewsTitle(rs.getString("newsTitle"));
                news.setNewsContent(rs.getString("newsContent"));
                news.setNewsDate(rs.getTimestamp("newsDate"));
                news.setNewsCategory(rs.getString("newsCategory"));
                news.setTeacherID(rs.getInt("teacherID"));
                news.setTargetAudience(rs.getString("targetAudience"));
                news.setPinned(rs.getInt("pinned") == 1); // Tukar 1/0 kepada boolean
                list.add(news);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateNews(News news) throws Exception {
        String sql = "UPDATE News SET newsTitle = ?, newsContent = ?, newsCategory = ?, teacherID = ?, targetAudience = ?, pinned = ? WHERE newsID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, news.getNewsTitle());
            pstmt.setString(2, news.getNewsContent());
            pstmt.setString(3, news.getNewsCategory());
            pstmt.setInt(4, news.getTeacherID());
            pstmt.setString(5, news.getTargetAudience());
            pstmt.setInt(6, news.isPinned() ? 1 : 0);
            pstmt.setInt(7, news.getNewsID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteNews(int newsID) throws Exception {
        String sql = "DELETE FROM News WHERE newsID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, newsID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getNewsCount() {
        String sql = "SELECT COUNT(*) FROM News";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}