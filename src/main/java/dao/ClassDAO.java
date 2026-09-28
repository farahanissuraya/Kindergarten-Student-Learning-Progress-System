package dao;

import bean.Class;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassDAO {

    public boolean addClass(Class clazz) throws Exception {
        String sql = "INSERT INTO Class (classID, className, academicYear, teacherID) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, clazz.getClassID());
            pstmt.setString(2, clazz.getClassName());
            pstmt.setInt(3, clazz.getAcademicYear());
            pstmt.setInt(4, clazz.getTeacherID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Class getClassById(int classID) throws Exception {
        String sql = "SELECT * FROM Class WHERE classID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, classID);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Class clazz = new Class();
                clazz.setClassID(rs.getInt("classID"));
                clazz.setClassName(rs.getString("className"));
                clazz.setAcademicYear(rs.getInt("academicYear"));
                clazz.setTeacherID(rs.getInt("teacherID"));
                return clazz;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Class> getAllClasses() throws Exception {
        List<Class> list = new ArrayList<>();
        String sql = "SELECT * FROM Class";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Class clazz = new Class();
                clazz.setClassID(rs.getInt("classID"));
                clazz.setClassName(rs.getString("className"));
                clazz.setAcademicYear(rs.getInt("academicYear"));
                clazz.setTeacherID(rs.getInt("teacherID"));
                list.add(clazz);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateClass(Class clazz) throws Exception {
        String sql = "UPDATE Class SET className = ?, academicYear = ?, teacherID = ? WHERE classID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, clazz.getClassName());
            pstmt.setInt(2, clazz.getAcademicYear());
            pstmt.setInt(3, clazz.getTeacherID());
            pstmt.setInt(4, clazz.getClassID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteClass(int classID) throws Exception {
        String sql = "DELETE FROM Class WHERE classID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, classID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}