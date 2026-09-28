package dao;

import bean.LearningProgress;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LearningProgressDAO {

    public boolean addLearningProgress(LearningProgress progress) throws Exception {
        String sql = "INSERT INTO LearningProgress (progressID, learningID, studentID, progressName, progressPercentage, progressStatus, teacherID) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, progress.getProgressID());
            pstmt.setInt(2, progress.getLearningID());
            pstmt.setInt(3, progress.getStudentID());
            pstmt.setString(4, progress.getProgressName());
            pstmt.setDouble(5, progress.getProgressPercentage());
            pstmt.setString(6, progress.getProgressStatus());
            pstmt.setInt(7, progress.getTeacherID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<LearningProgress> getProgressByStudentId(int studentID) throws Exception {
        List<LearningProgress> list = new ArrayList<>();
        String sql = "SELECT * FROM LearningProgress WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                LearningProgress progress = new LearningProgress();
                progress.setProgressID(rs.getInt("progressID"));
                progress.setLearningID(rs.getInt("learningID"));
                progress.setStudentID(rs.getInt("studentID"));
                progress.setProgressName(rs.getString("progressName"));
                progress.setProgressDate(rs.getString("progressDate"));
                progress.setProgressPercentage(rs.getDouble("progressPercentage"));
                progress.setProgressStatus(rs.getString("progressStatus"));
                progress.setTeacherID(rs.getInt("teacherID"));
                list.add(progress);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateLearningProgress(LearningProgress progress) throws Exception {
        String sql = "UPDATE LearningProgress SET progressName = ?, progressPercentage = ?, progressStatus = ?, teacherID = ? WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, progress.getProgressName());
            pstmt.setDouble(2, progress.getProgressPercentage());
            pstmt.setString(3, progress.getProgressStatus());
            pstmt.setInt(4, progress.getTeacherID());
            pstmt.setInt(5, progress.getProgressID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteLearningProgress(int progressID) throws Exception {
        String sql = "DELETE FROM LearningProgress WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, progressID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}