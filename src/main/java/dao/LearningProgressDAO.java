package dao;

import bean.LearningProgress;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LearningProgressDAO {

    // 1. TARIK REKOD KEMAJUAN BERDASARKAN studentID
    public List<LearningProgress> getProgressByStudentId(int studentId) {
        List<LearningProgress> list = new ArrayList<>();
        String sql = "SELECT lp.progressID, lp.learningID, lp.studentID, lp.progressName, " +
                     "TO_CHAR(lp.progressDate, 'YYYY-MM-DD') AS formattedDate, " +
                     "lp.progressPercentage, lp.progressStatus, lp.teacherID, " +
                     "l.learningName AS domainName " +
                     "FROM LEARNINGPROGRESS lp " +
                     "JOIN LEARNING l ON lp.learningID = l.learningID " +
                     "WHERE lp.studentID = ? " +
                     "ORDER BY lp.progressDate DESC, lp.progressID DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LearningProgress lp = new LearningProgress();
                    lp.setProgressID(rs.getInt("progressID"));
                    lp.setLearningID(rs.getInt("learningID"));
                    lp.setStudentID(rs.getInt("studentID"));
                    lp.setProgressName(rs.getString("progressName"));
                    lp.setProgressDate(rs.getString("formattedDate"));
                    lp.setProgressPercentage(rs.getDouble("progressPercentage"));
                    lp.setProgressStatus(rs.getString("progressStatus"));
                    lp.setTeacherID(rs.getInt("teacherID"));
                    lp.setDomainName(rs.getString("domainName"));
                    
                    list.add(lp);
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat SQL semasa mengambil rekod kemajuan: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 2. TAMBAH REKOD KEMAJUAN BAHARU (CREATE)
    public boolean addProgress(LearningProgress lp) {
        String sql = "INSERT INTO LEARNINGPROGRESS (progressID, learningID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID) " +
                     "VALUES (seq_progress_id.NEXTVAL, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, lp.getLearningID());
            ps.setInt(2, lp.getStudentID());
            ps.setString(3, lp.getProgressName());
            
            // Tarikh lalai jika kosong
            String dateStr = (lp.getProgressDate() != null && !lp.getProgressDate().trim().isEmpty()) 
                             ? lp.getProgressDate() 
                             : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            ps.setString(4, dateStr);
            
            ps.setDouble(5, lp.getProgressPercentage());
            ps.setString(6, lp.getProgressStatus());
            ps.setInt(7, lp.getTeacherID());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Ralat SQL semasa tambah rekod kemajuan: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 3. KEMAS KINI REKOD KEMAJUAN (UPDATE)
    public boolean updateProgress(LearningProgress lp) {
        String sql = "UPDATE LEARNINGPROGRESS SET learningID = ?, progressName = ?, progressDate = TO_DATE(?, 'YYYY-MM-DD'), progressPercentage = ?, progressStatus = ? WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, lp.getLearningID());
            ps.setString(2, lp.getProgressName());
            ps.setString(3, lp.getProgressDate());
            ps.setDouble(4, lp.getProgressPercentage());
            ps.setString(5, lp.getProgressStatus());
            ps.setInt(6, lp.getProgressID());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Ralat SQL semasa kemas kini rekod kemajuan: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 4. PADAM REKOD KEMAJUAN (DELETE)
    public boolean deleteProgress(int progressId) {
        String sql = "DELETE FROM LEARNINGPROGRESS WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, progressId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Ralat SQL semasa padam rekod kemajuan: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}