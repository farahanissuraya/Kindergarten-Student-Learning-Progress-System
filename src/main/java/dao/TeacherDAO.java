package dao;

import bean.Teacher;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class TeacherDAO {

    public boolean addTeacher(Teacher teacher) throws Exception {
        String sql = "INSERT INTO Teacher (teacherID, teacherName, teacherEmail, teacherPassword, teacherPhoneNumber, adminID) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacher.getTeacherID());
            pstmt.setString(2, teacher.getTeacherName());
            pstmt.setString(3, teacher.getTeacherEmail());
            pstmt.setString(4, teacher.getTeacherPassword());
            pstmt.setString(5, teacher.getTeacherPhoneNumber());
            if (teacher.getAdminID() != null) {
                pstmt.setInt(6, teacher.getAdminID());
            } else {
                pstmt.setNull(6, Types.INTEGER);
            }
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Teacher getTeacherById(int teacherID) throws Exception {
        String sql = "SELECT * FROM Teacher WHERE teacherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherID);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Teacher teacher = new Teacher();
                teacher.setTeacherID(rs.getInt("teacherID"));
                teacher.setTeacherName(rs.getString("teacherName"));
                teacher.setTeacherEmail(rs.getString("teacherEmail"));
                teacher.setTeacherPassword(rs.getString("teacherPassword"));
                teacher.setTeacherPhoneNumber(rs.getString("teacherPhoneNumber"));
                int adminID = rs.getInt("adminID");
                teacher.setAdminID(rs.wasNull() ? null : adminID);
                return teacher;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Teacher> getAllTeachers() throws Exception {
        List<Teacher> list = new ArrayList<>();
        String sql = "SELECT * FROM Teacher";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Teacher teacher = new Teacher();
                teacher.setTeacherID(rs.getInt("teacherID"));
                teacher.setTeacherName(rs.getString("teacherName"));
                teacher.setTeacherEmail(rs.getString("teacherEmail"));
                teacher.setTeacherPassword(rs.getString("teacherPassword"));
                teacher.setTeacherPhoneNumber(rs.getString("teacherPhoneNumber"));
                int adminID = rs.getInt("adminID");
                teacher.setAdminID(rs.wasNull() ? null : adminID);
                list.add(teacher);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateTeacher(Teacher teacher) throws Exception {
        String sql = "UPDATE Teacher SET teacherName = ?, teacherEmail = ?, teacherPassword = ?, teacherPhoneNumber = ?, adminID = ? WHERE teacherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, teacher.getTeacherName());
            pstmt.setString(2, teacher.getTeacherEmail());
            pstmt.setString(3, teacher.getTeacherPassword());
            pstmt.setString(4, teacher.getTeacherPhoneNumber());
            if (teacher.getAdminID() != null) {
                pstmt.setInt(5, teacher.getAdminID());
            } else {
                pstmt.setNull(5, Types.INTEGER);
            }
            pstmt.setInt(6, teacher.getTeacherID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteTeacher(int teacherID) throws Exception {
        String sql = "DELETE FROM Teacher WHERE teacherID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

	public int getTeacherCount() {
		// TODO Auto-generated method stub
		return 0;
	}
}