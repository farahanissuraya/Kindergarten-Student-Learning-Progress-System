package dao;

import bean.LearningProgress;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LearningProgressDAO {

    // ==========================================
    // 1. TAMBAH REKOD KEMAJUAN (CREATE)
    // ==========================================
    public boolean addLearningProgress(LearningProgress progress) throws Exception {
        return addProgress(progress);
    }

    public boolean addProgress(LearningProgress progress) throws Exception {
        // Menggunakan sequence seq_progress_id jika progressID bernilai 0
        String sql;
        if (progress.getProgressID() > 0) {
            sql = "INSERT INTO LEARNINGPROGRESS (progressID, learningID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID, notes, ratingScale, assessorName, homeRecommendation) " +
                  "VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO LEARNINGPROGRESS (progressID, learningID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID, notes, ratingScale, assessorName, homeRecommendation) " +
                  "VALUES (seq_progress_id.NEXTVAL, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?, ?)";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            int idx = 1;
            if (progress.getProgressID() > 0) {
                pstmt.setInt(idx++, progress.getProgressID());
            }
            pstmt.setInt(idx++, progress.getLearningID());
            pstmt.setInt(idx++, progress.getStudentID());
            pstmt.setString(idx++, progress.getProgressName());

            String dateStr = (progress.getProgressDate() != null && !progress.getProgressDate().trim().isEmpty())
                             ? progress.getProgressDate()
                             : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            pstmt.setString(idx++, dateStr);

            pstmt.setDouble(idx++, progress.getProgressPercentage());
            pstmt.setString(idx++, progress.getProgressStatus());
            pstmt.setInt(idx++, progress.getTeacherID() > 0 ? progress.getTeacherID() : 201);
            pstmt.setString(idx++, progress.getNotes());
            pstmt.setInt(idx++, progress.getRatingScale() > 0 ? progress.getRatingScale() : 5);
            pstmt.setString(idx++, progress.getAssessorName() != null ? progress.getAssessorName() : "Teacher");
            pstmt.setString(idx++, progress.getHomeRecommendation());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Ralat addLearningProgress: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 2. DAPATKAN REKOD PENILAIAN MURID (READ)
    // ==========================================
    public List<LearningProgress> getProgressByStudentId(int studentID) throws Exception {
        List<LearningProgress> list = new ArrayList<>();
        String sql = "SELECT lp.progressID, lp.learningID, lp.studentID, lp.progressName, " +
                     "TO_CHAR(lp.progressDate, 'YYYY-MM-DD') AS formattedDate, " +
                     "lp.progressPercentage, lp.progressStatus, lp.teacherID, lp.notes, " +
                     "NVL(lp.ratingScale, 5) AS ratingScale, lp.assessorName, lp.homeRecommendation, " +
                     "NVL(l.learningName, 'General') AS domainName " +
                     "FROM LEARNINGPROGRESS lp " +
                     "LEFT JOIN LEARNING l ON lp.learningID = l.learningID " +
                     "WHERE lp.studentID = ? " +
                     "ORDER BY lp.progressDate DESC, lp.progressID DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    LearningProgress progress = new LearningProgress();
                    progress.setProgressID(rs.getInt("progressID"));
                    progress.setLearningID(rs.getInt("learningID"));
                    progress.setStudentID(rs.getInt("studentID"));
                    progress.setProgressName(rs.getString("progressName"));
                    progress.setProgressDate(rs.getString("formattedDate"));
                    progress.setProgressPercentage(rs.getDouble("progressPercentage"));
                    progress.setProgressStatus(rs.getString("progressStatus"));
                    progress.setTeacherID(rs.getInt("teacherID"));
                    progress.setNotes(rs.getString("notes"));
                    progress.setRatingScale(rs.getInt("ratingScale"));
                    progress.setAssessorName(rs.getString("assessorName"));
                    progress.setHomeRecommendation(rs.getString("homeRecommendation"));
                    progress.setDomainName(rs.getString("domainName"));
                    
                    list.add(progress);
                }
            }
        } catch (SQLException e) {
            System.err.println("Ralat getProgressByStudentId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ==========================================
    // 3. KEMAS KINI REKOD KEMAJUAN (UPDATE)
    // ==========================================
    public boolean updateLearningProgress(LearningProgress progress) throws Exception {
        return updateProgress(progress);
    }

    public boolean updateProgress(LearningProgress progress) throws Exception {
        String sql = "UPDATE LEARNINGPROGRESS SET learningID = ?, progressName = ?, progressDate = TO_DATE(?, 'YYYY-MM-DD'), " +
                     "progressPercentage = ?, progressStatus = ?, teacherID = ?, notes = ?, ratingScale = ?, homeRecommendation = ? " +
                     "WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, progress.getLearningID());
            pstmt.setString(2, progress.getProgressName());
            pstmt.setString(3, progress.getProgressDate());
            pstmt.setDouble(4, progress.getProgressPercentage());
            pstmt.setString(5, progress.getProgressStatus());
            pstmt.setInt(6, progress.getTeacherID() > 0 ? progress.getTeacherID() : 201);
            pstmt.setString(7, progress.getNotes());
            pstmt.setInt(8, progress.getRatingScale());
            pstmt.setString(9, progress.getHomeRecommendation());
            pstmt.setInt(10, progress.getProgressID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Ralat updateLearningProgress: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 4. PADAM REKOD KEMAJUAN (DELETE)
    // ==========================================
    public boolean deleteLearningProgress(int progressID) throws Exception {
        return deleteProgress(progressID);
    }

    public boolean deleteProgress(int progressID) throws Exception {
        String sql = "DELETE FROM LEARNINGPROGRESS WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, progressID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Ralat deleteLearningProgress: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // 5. KOD TAMBAHAN UNTUK STUDENT DIRECTORY
    // ==========================================
    public Map<Integer, Double> getAvgProgressMap() throws Exception {
        Map<Integer, Double> progressMap = new HashMap<>();
        String sql = "SELECT studentID, NVL(AVG(progressPercentage), 0) AS avgProgress FROM LEARNINGPROGRESS GROUP BY studentID";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                progressMap.put(rs.getInt("studentID"), Math.round(rs.getDouble("avgProgress") * 10.0) / 10.0);
            }
        } catch (Exception e) {
            System.err.println("Ralat getAvgProgressMap: " + e.getMessage());
            e.printStackTrace();
        }
        return progressMap;
    }

    public int getTotalLogsCount() {
        String sql = "SELECT COUNT(*) FROM LEARNINGPROGRESS";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("Ralat getTotalLogsCount: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}