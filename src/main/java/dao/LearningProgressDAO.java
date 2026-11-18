package dao;

import bean.LearningProgress;
import bean.Student;
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
        String sql;
        if (progress.getProgressID() > 0) {
            sql = "INSERT INTO LEARNINGPROGRESS (progressID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID, domainName, notes, ratingScale, assessorName, homeRecommendation) " +
                  "VALUES (?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO LEARNINGPROGRESS (progressID, studentID, progressName, progressDate, progressPercentage, progressStatus, teacherID, domainName, notes, ratingScale, assessorName, homeRecommendation) " +
                  "VALUES (seq_progress_id.NEXTVAL, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?, ?, ?)";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            int idx = 1;
            if (progress.getProgressID() > 0) {
                pstmt.setInt(idx++, progress.getProgressID());
            }
            pstmt.setInt(idx++, progress.getStudentID());
            pstmt.setString(idx++, progress.getProgressName());

            String dateStr = (progress.getProgressDate() != null && !progress.getProgressDate().trim().isEmpty())
                             ? progress.getProgressDate()
                             : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            pstmt.setString(idx++, dateStr);

            pstmt.setDouble(idx++, progress.getProgressPercentage());
            pstmt.setString(idx++, progress.getProgressStatus());
            pstmt.setInt(idx++, progress.getTeacherID() > 0 ? progress.getTeacherID() : 201);
            pstmt.setString(idx++, progress.getDomainName() != null ? progress.getDomainName() : "Reading");
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
        String sql = "SELECT progressID, studentID, progressName, " +
                     "TO_CHAR(progressDate, 'YYYY-MM-DD') AS formattedDate, " +
                     "progressPercentage, progressStatus, teacherID, " +
                     "NVL(domainName, 'General') AS domainName, notes, " +
                     "NVL(ratingScale, 5) AS ratingScale, assessorName, homeRecommendation " +
                     "FROM LEARNINGPROGRESS " +
                     "WHERE studentID = ? " +
                     "ORDER BY progressDate DESC, progressID DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    LearningProgress progress = new LearningProgress();
                    progress.setProgressID(rs.getInt("progressID"));
                    progress.setStudentID(rs.getInt("studentID"));
                    progress.setProgressName(rs.getString("progressName"));
                    progress.setProgressDate(rs.getString("formattedDate"));
                    progress.setProgressPercentage(rs.getDouble("progressPercentage"));
                    progress.setProgressStatus(rs.getString("progressStatus"));
                    progress.setTeacherID(rs.getInt("teacherID"));
                    progress.setDomainName(rs.getString("domainName"));
                    progress.setNotes(rs.getString("notes"));
                    progress.setRatingScale(rs.getInt("ratingScale"));
                    progress.setAssessorName(rs.getString("assessorName"));
                    progress.setHomeRecommendation(rs.getString("homeRecommendation"));
                    
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
        String sql = "UPDATE LEARNINGPROGRESS SET domainName = ?, progressName = ?, progressDate = TO_DATE(?, 'YYYY-MM-DD'), " +
                     "progressPercentage = ?, progressStatus = ?, teacherID = ?, notes = ?, ratingScale = ?, homeRecommendation = ? " +
                     "WHERE progressID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, progress.getDomainName() != null ? progress.getDomainName() : "Reading");
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

    // ==========================================
    // 6. DAPATKAN SKALA DOMAIN MURID DARI DATABASE
    // ==========================================
    public int getDomainScale(int studentID, String domainName) {
        int scale = 1;
        String sql = "SELECT NVL(ratingScale, 1) AS ratingScale " +
                     "FROM LEARNINGPROGRESS " +
                     "WHERE studentID = ? AND (LOWER(domainName) LIKE ? OR LOWER(progressName) LIKE ?) " +
                     "ORDER BY progressDate DESC, progressID DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studentID);
            pstmt.setString(2, "%" + domainName.toLowerCase() + "%");
            pstmt.setString(3, "%" + domainName.toLowerCase() + "%");

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    scale = rs.getInt("ratingScale");
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat getDomainScale: " + e.getMessage());
        }
        return scale;
    }
    
    // ==========================================
    // 7. DAPATKAN PURATA KELAS DARI DATABASE (DYNAMIC)
    // ==========================================
    public double getClassAverageScale(String domainName) {
        double avgRadarValue = 0.0;
        String sql = "SELECT NVL(AVG(ratingScale) * 2.0, 0.0) AS classAvgRadar " +
                     "FROM LEARNINGPROGRESS " +
                     "WHERE LOWER(domainName) LIKE ? OR LOWER(progressName) LIKE ?";
    
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
    
            pstmt.setString(1, "%" + domainName.toLowerCase() + "%");
            pstmt.setString(2, "%" + domainName.toLowerCase() + "%");
    
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    avgRadarValue = Math.round(rs.getDouble("classAvgRadar") * 10.0) / 10.0;
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat getClassAverageScale: " + e.getMessage());
            e.printStackTrace();
        }
        return avgRadarValue;
    }

    // ==========================================
    // 8. KAEDAH UNTUK LAPORAN PENUH (REPORT DETAIL)
    // ==========================================
    public Student getStudentById(int studentID) {
        Student st = null;
        String sql = "SELECT studentID, studentName, studentAge, studentClass FROM STUDENT WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, studentID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    st = new Student();
                    st.setStudentID(rs.getInt("studentID"));
                    st.setStudentName(rs.getString("studentName"));
                    st.setStudentAge(rs.getInt("studentAge"));
                    String sClass = rs.getString("studentClass");
                    st.setStudentClass((sClass != null && !sClass.trim().isEmpty()) ? sClass : "Kindergarten 3B");
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat getStudentById: " + e.getMessage());
            e.printStackTrace();
        }
        return st;
    }

    public String getLatestReportDate(int studentID) {
        String sql = "SELECT TO_CHAR(MAX(progressDate), 'YYYY-MM-DD') AS latestDate " +
                     "FROM LEARNINGPROGRESS WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, studentID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next() && rs.getString("latestDate") != null) {
                    return rs.getString("latestDate");
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat getLatestReportDate: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<LearningProgress> getRecordsByStudentAndDate(int studentID, String reportDate) {
        List<LearningProgress> list = new ArrayList<>();
        String sql = "SELECT progressID, studentID, progressName, " +
                     "TO_CHAR(progressDate, 'YYYY-MM-DD') AS formattedDate, " +
                     "progressPercentage, progressStatus, teacherID, " +
                     "NVL(domainName, 'Reading') AS domainName, notes, " +
                     "NVL(ratingScale, 4) AS ratingScale, assessorName, homeRecommendation " +
                     "FROM LEARNINGPROGRESS " +
                     "WHERE studentID = ? AND TO_CHAR(progressDate, 'YYYY-MM-DD') = ? " +
                     "ORDER BY CASE UPPER(domainName) " +
                     "WHEN 'READING' THEN 1 WHEN 'WRITING' THEN 2 WHEN 'COUNTING' THEN 3 ELSE 4 END, progressID ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, studentID);
            pstmt.setString(2, reportDate);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    LearningProgress progress = new LearningProgress();
                    progress.setProgressID(rs.getInt("progressID"));
                    progress.setStudentID(rs.getInt("studentID"));
                    progress.setProgressName(rs.getString("progressName"));
                    progress.setProgressDate(rs.getString("formattedDate"));
                    progress.setProgressPercentage(rs.getDouble("progressPercentage"));
                    progress.setProgressStatus(rs.getString("progressStatus"));
                    progress.setTeacherID(rs.getInt("teacherID"));
                    progress.setDomainName(rs.getString("domainName"));
                    progress.setNotes(rs.getString("notes"));
                    progress.setRatingScale(rs.getInt("ratingScale"));
                    progress.setAssessorName(rs.getString("assessorName"));
                    progress.setHomeRecommendation(rs.getString("homeRecommendation"));

                    list.add(progress);
                }
            }
        } catch (Exception e) {
            System.err.println("Ralat getRecordsByStudentAndDate: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}