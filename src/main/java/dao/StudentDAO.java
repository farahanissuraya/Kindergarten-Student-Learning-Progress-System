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
        String sql = "INSERT INTO Student (studentID, studentName, studentAge, studentClass, parentID) VALUES (?, ?, ?, ?, ?)";
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
                list.add(student);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStudent(Student student) throws Exception {
        String sql = "UPDATE Student SET studentName = ?, studentAge = ?, studentClass = ?, parentID = ? WHERE studentID = ?";
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
            pstmt.setInt(5, student.getStudentID());
            
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
		// TODO Auto-generated method stub
		return 0;
	}
}