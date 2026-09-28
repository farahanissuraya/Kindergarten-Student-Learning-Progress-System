package dao;

import bean.Chat;
import util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public boolean sendMessage(Chat chat) throws Exception {
        String sql = "INSERT INTO Chat (chatID, parentID, teacherID, senderRole, messageContent, isRead) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, chat.getChatID());
            pstmt.setInt(2, chat.getParentID());
            pstmt.setInt(3, chat.getTeacherID());
            pstmt.setString(4, chat.getSenderRole());
            pstmt.setString(5, chat.getMessageContent());
            pstmt.setInt(6, chat.isRead() ? 1 : 0);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Chat> getChatHistory(int parentID, int teacherID) throws Exception {
        List<Chat> list = new ArrayList<>();
        String sql = "SELECT * FROM Chat WHERE parentID = ? AND teacherID = ? ORDER BY sentDateTime ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, parentID);
            pstmt.setInt(2, teacherID);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Chat chat = new Chat();
                chat.setChatID(rs.getInt("chatID"));
                chat.setParentID(rs.getInt("parentID"));
                chat.setTeacherID(rs.getInt("teacherID"));
                chat.setSenderRole(rs.getString("senderRole"));
                chat.setMessageContent(rs.getString("messageContent"));
                chat.setSentDateTime(rs.getTimestamp("sentDateTime"));
                chat.setRead(rs.getInt("isRead") == 1);
                list.add(chat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean markAsRead(int chatID) throws Exception {
        String sql = "UPDATE Chat SET isRead = 1 WHERE chatID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, chatID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}