package dao;

import bean.Counting;
import bean.Learning;
import bean.Reading;
import bean.Writing;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LearningDAO {

    public boolean addReading(Reading reading) throws Exception {
        String sqlSuper = "INSERT INTO Learning (learningID, learningName, learningCategory) VALUES (?, ?, ?)";
        String sqlSub = "INSERT INTO Reading (learningID, phonicsStatus, readingLevel) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement p1 = conn.prepareStatement(sqlSuper);
                 PreparedStatement p2 = conn.prepareStatement(sqlSub)) {
                
                p1.setInt(1, reading.getLearningID());
                p1.setString(2, reading.getLearningName());
                p1.setString(3, reading.getLearningCategory());
                p1.executeUpdate();
                
                p2.setInt(1, reading.getLearningID());
                p2.setString(2, reading.getPhonicsStatus());
                p2.setString(3, reading.getReadingLevel());
                p2.executeUpdate();
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addWriting(Writing writing) throws Exception {
        String sqlSuper = "INSERT INTO Learning (learningID, learningName, learningCategory) VALUES (?, ?, ?)";
        String sqlSub = "INSERT INTO Writing (learningID, letterTracing, nameWriting) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement p1 = conn.prepareStatement(sqlSuper);
                 PreparedStatement p2 = conn.prepareStatement(sqlSub)) {
                
                p1.setInt(1, writing.getLearningID());
                p1.setString(2, writing.getLearningName());
                p1.setString(3, writing.getLearningCategory());
                p1.executeUpdate();
                
                p2.setInt(1, writing.getLearningID());
                p2.setString(2, writing.getLetterTracing());
                p2.setInt(3, writing.isNameWriting() ? 1 : 0);
                p2.executeUpdate();
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addCounting(Counting counting) throws Exception {
        String sqlSuper = "INSERT INTO Learning (learningID, learningName, learningCategory) VALUES (?, ?, ?)";
        String sqlSub = "INSERT INTO Counting (learningID, numberRange, objectCounting, shapeRecognition) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement p1 = conn.prepareStatement(sqlSuper);
                 PreparedStatement p2 = conn.prepareStatement(sqlSub)) {
                
                p1.setInt(1, counting.getLearningID());
                p1.setString(2, counting.getLearningName());
                p1.setString(3, counting.getLearningCategory());
                p1.executeUpdate();
                
                p2.setInt(1, counting.getLearningID());
                p2.setString(2, counting.getNumberRange());
                p2.setString(3, counting.getObjectCounting());
                p2.setInt(4, counting.isShapeRecognition() ? 1 : 0);
                p2.executeUpdate();
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteLearning(int learningID) throws Exception {
        String sql = "DELETE FROM Learning WHERE learningID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, learningID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}