package dao;

import bean.Student;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    public boolean addStudent(Student student) throws Exception {
        String sql = "INSERT INTO Student (studentID, studentName, studentAge, studentClass, parentID, studentIC, studentGender) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, student.getStudentID());
            pstmt.setString(2, student.getStudentName());
            if (student.getStudentAge() != null) {
                pstmt.setInt(3, student.getStudentAge());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            pstmt.setString(4, student.getStudentClass());
            pstmt.setInt(5, student.getParentID());
            pstmt.setString(6, student.getStudentIC());
            pstmt.setString(7, student.getStudentGender());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Student getStudentById(int studentID) throws Exception {
        String sql = "SELECT * FROM Student WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Student student = new Student();
                student.setStudentID(rs.getInt("studentID"));
                student.setStudentName(rs.getString("studentName"));
                int age = rs.getInt("studentAge");
                student.setStudentAge(rs.wasNull() ? null : age);
                student.setStudentClass(rs.getString("studentClass"));
                student.setParentID(rs.getInt("parentID"));
                
                // DATA BAHARU
                student.setStudentIC(rs.getString("studentIC"));
                student.setStudentGender(rs.getString("studentGender"));
                
                return student;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Student> getAllStudents() throws Exception {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM Student";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Student student = new Student();
                student.setStudentID(rs.getInt("studentID"));
                student.setStudentName(rs.getString("studentName"));
                int age = rs.getInt("studentAge");
                student.setStudentAge(rs.wasNull() ? null : age);
                student.setStudentClass(rs.getString("studentClass"));
                student.setParentID(rs.getInt("parentID"));
                
                // DATA BAHARU
                student.setStudentIC(rs.getString("studentIC"));
                student.setStudentGender(rs.getString("studentGender"));
                
                list.add(student);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStudent(Student student) throws Exception {
        String sql = "UPDATE Student SET studentName = ?, studentAge = ?, studentClass = ?, parentID = ?, studentIC = ?, studentGender = ? WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, student.getStudentName());
            if (student.getStudentAge() != null) {
                pstmt.setInt(2, student.getStudentAge());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, student.getStudentClass());
            pstmt.setInt(4, student.getParentID());
            
            // DATA BAHARU
            pstmt.setString(5, student.getStudentIC());
            pstmt.setString(6, student.getStudentGender());
            
            pstmt.setInt(7, student.getStudentID()); // Kunci Utama sentiasa di hujung
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteStudent(int studentID) throws Exception {
        String sql = "DELETE FROM Student WHERE studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getStudentCount() {
        String sql = "SELECT COUNT(*) FROM Student";
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