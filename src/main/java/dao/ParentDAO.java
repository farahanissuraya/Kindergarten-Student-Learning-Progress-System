package dao;

import bean.Parent;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ParentDAO {

    public boolean addParent(Parent parent) throws Exception {
        String sql = "INSERT INTO Parent (parentID, parentName, parentEmail, parentPassword, parentPhoneNumber) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, parent.getParentID());
            pstmt.setString(2, parent.getParentName());
            pstmt.setString(3, parent.getParentEmail());
            pstmt.setString(4, parent.getParentPassword());
            pstmt.setString(5, parent.getParentPhoneNumber());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Parent getParentById(int parentID) throws Exception {
        String sql = "SELECT * FROM Parent WHERE parentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, parentID);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Parent parent = new Parent();
                parent.setParentID(rs.getInt("parentID"));
                parent.setParentName(rs.getString("parentName"));
                parent.setParentEmail(rs.getString("parentEmail"));
                parent.setParentPassword(rs.getString("parentPassword"));
                parent.setParentPhoneNumber(rs.getString("parentPhoneNumber"));
                return parent;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Parent> getAllParents() throws Exception {
        List<Parent> list = new ArrayList<>();
        String sql = "SELECT * FROM Parent";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Parent parent = new Parent();
                parent.setParentID(rs.getInt("parentID"));
                parent.setParentName(rs.getString("parentName"));
                parent.setParentEmail(rs.getString("parentEmail"));
                parent.setParentPassword(rs.getString("parentPassword"));
                parent.setParentPhoneNumber(rs.getString("parentPhoneNumber"));
                list.add(parent);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateParent(Parent parent) throws Exception {
        String sql = "UPDATE Parent SET parentName = ?, parentEmail = ?, parentPassword = ?, parentPhoneNumber = ? WHERE parentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, parent.getParentName());
            pstmt.setString(2, parent.getParentEmail());
            pstmt.setString(3, parent.getParentPassword());
            pstmt.setString(4, parent.getParentPhoneNumber());
            pstmt.setInt(5, parent.getParentID());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteParent(int parentID) throws Exception {
        String sql = "DELETE FROM Parent WHERE parentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, parentID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

	public int getParentCount() {
		// TODO Auto-generated method stub
		return 0;
	}
}