package dao;

import bean.News;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewsDAO {

    // 1. TAMBAH BERITA BAHARU
    public boolean addNews(News news) throws Exception {
        String sql = "INSERT INTO News (newsID, newsTitle, newsContent, newsDate, newsCategory, teacherID, targetAudience, pinned) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, news.getNewsID());
            pstmt.setString(2, news.getNewsTitle());
            pstmt.setString(3, news.getNewsContent());
            pstmt.setTimestamp(4, news.getNewsDate());
            pstmt.setString(5, news.getNewsCategory());
            pstmt.setInt(6, news.getTeacherID());
            pstmt.setString(7, news.getTargetAudience());
            pstmt.setInt(8, news.isPinned() ? 1 : 0);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Ralat SQL semasa tambah berita: " + e.getMessage());
            e.printStackTrace(); 
        }
        return false;
    }

    // 2. AMBIL SEMUA BERITA (UNTUK ADMIN / TEACHER)
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
                news.setTeacherID(rs.getInt("teacherID"));
                news.setTargetAudience(rs.getString("targetAudience"));
                news.setPinned(rs.getInt("pinned") == 1);
                list.add(news);
            }
        } catch (SQLException e) {
            System.err.println("Ralat SQL semasa ambil semua berita: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 3. AMBIL BERITA KHAS UNTUK PARENT DASHBOARD (SASARAN: 'All' ATAU 'Parents')
    public List<News> getNewsForParents() throws Exception {
        List<News> list = new ArrayList<>();
        String sql = "SELECT * FROM News WHERE LOWER(targetAudience) IN ('all', 'parents') OR targetAudience IS NULL ORDER BY pinned DESC, newsDate DESC";
        
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
                news.setPinned(rs.getInt("pinned") == 1);
                list.add(news);
            }
        } catch (SQLException e) {
            System.err.println("Ralat SQL semasa ambil berita Parent: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 4. DAPATKAN NAMA GURU BERDASARKAN teacherID
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
        return "Teacher #" + teacherID;
    }

    // 5. KEMAS KINI BERITA
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
            System.err.println("Ralat SQL semasa kemas kini berita: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 6. PADAM BERITA
    public boolean deleteNews(int newsID) throws Exception {
        String sql = "DELETE FROM News WHERE newsID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, newsID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Ralat SQL semasa padam berita: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 7. KIRA JUMLAH BERITA
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
    
    // 8. AMBIL TEACHER ID SAH REKOD PERTAMA
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