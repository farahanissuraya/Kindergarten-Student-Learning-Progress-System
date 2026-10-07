package dao;

import bean.News;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NewsDAO {

    public boolean addNews(News news) throws Exception {
        String sql = "INSERT INTO News (newsID, newsTitle, newsContent, newsCategory, teacherID) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, news.getNewsID());
            pstmt.setString(2, news.getNewsTitle());
            pstmt.setString(3, news.getNewsContent());
            pstmt.setString(4, news.getNewsCategory());
            pstmt.setInt(5, news.getTeacherID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<News> getAllNews() throws Exception {
        List<News> list = new ArrayList<>();
        String sql = "SELECT * FROM News ORDER BY newsDate DESC";
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
                list.add(news);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateNews(News news) throws Exception {
        String sql = "UPDATE News SET newsTitle = ?, newsContent = ?, newsCategory = ?, teacherID = ? WHERE newsID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, news.getNewsTitle());
            pstmt.setString(2, news.getNewsContent());
            pstmt.setString(3, news.getNewsCategory());
            pstmt.setInt(4, news.getTeacherID());
            pstmt.setInt(5, news.getNewsID());
            
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
		// TODO Auto-generated method stub
		return 0;
	}
}