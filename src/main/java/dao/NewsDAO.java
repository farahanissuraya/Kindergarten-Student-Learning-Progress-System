package dao;

import bean.News;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewsDAO {

	public boolean addNews(News news) throws Exception {
        // Kita masukkan newsDate ke dalam senarai INSERT
        String sql = "INSERT INTO News (newsID, newsTitle, newsContent, newsDate, newsCategory, teacherID, targetAudience, pinned) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, news.getNewsID());
            pstmt.setString(2, news.getNewsTitle());
            pstmt.setString(3, news.getNewsContent());
            pstmt.setTimestamp(4, news.getNewsDate()); // Hantar tarikh & masa
            pstmt.setString(5, news.getNewsCategory());
            pstmt.setInt(6, news.getTeacherID());
            pstmt.setString(7, news.getTargetAudience());
            pstmt.setInt(8, news.isPinned() ? 1 : 0);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            // Ralat akan dipaparkan di Console Eclipse jika gagal
            System.out.println("Ralat SQL semasa tambah berita: " + e.getMessage());
            e.printStackTrace(); 
        }
        return false;
    }

	public List<News> getAllNews() throws Exception {
        List<News> list = new ArrayList<>();
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
                news.setTeacherID(rs.getInt("teacherID")); // FK Sahaja
                news.setTargetAudience(rs.getString("targetAudience"));
                news.setPinned(rs.getInt("pinned") == 1);
                list.add(news);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tambah kaedah ini untuk dapatkan nama guru berdasarkan teacherID (FK)
    public String getTeacherNameById(int teacherID) {
        String sql = "SELECT teacherName FROM Teacher WHERE teacherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("teacherName");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Teacher #" + teacherID; // Fallback jika guru tak dijumpai
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
    
    public int getValidTeacherID() {
        String sql = "SELECT teacherID FROM Teacher FETCH FIRST 1 ROWS ONLY";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("teacherID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1;
    }
}