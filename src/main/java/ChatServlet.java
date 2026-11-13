import bean.Chat;
import dao.ChatDAO;
import util.DatabaseConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("parentID") == null && session.getAttribute("teacherID") == null)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionRole = (session.getAttribute("userRole") != null)
                             ? session.getAttribute("userRole").toString()
                             : "Parent";
        String senderRole = ("Teacher".equalsIgnoreCase(sessionRole) || "Admin".equalsIgnoreCase(sessionRole))
                            ? "Teacher"
                            : "Parent";

        int parentID = 0;
        int teacherID = 0;

        if (session.getAttribute("parentID") != null) {
            parentID = Integer.parseInt(session.getAttribute("parentID").toString());
        }
        if (session.getAttribute("teacherID") != null) {
            teacherID = Integer.parseInt(session.getAttribute("teacherID").toString());
        }

        String parentParam = request.getParameter("parentID");
        String teacherParam = request.getParameter("teacherID");
        boolean hasParentParam = false;
        boolean hasTeacherParam = false;

        if (parentParam != null && !parentParam.trim().isEmpty()) {
            try {
                parentID = Integer.parseInt(parentParam);
                hasParentParam = true;
            } catch (NumberFormatException ignored) {}
        }
        if (teacherParam != null && !teacherParam.trim().isEmpty()) {
            try {
                teacherID = Integer.parseInt(teacherParam);
                hasTeacherParam = true;
            } catch (NumberFormatException ignored) {}
        }

        String parentName = "";
        String teacherName = "";
        String studentName = "";
        String studentClass = "";
        List<HashMap<String, Object>> contactList = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1. Senarai kenalan disusun mengikut mesej terkini & paparan pratonton mesej terakhir
            if ("Teacher".equalsIgnoreCase(senderRole)) {
                String sqlAllParents =
                    "SELECT p.parentID, p.parentName, " +
                    "       (SELECT MIN(s.studentName) FROM Student s WHERE s.parentID = p.parentID) AS studentName, " +
                    "       (SELECT MAX(c.chatID) FROM Chat c WHERE c.parentID = p.parentID AND c.teacherID = ?) AS lastChatID, " +
                    "       (SELECT c.messageContent FROM Chat c WHERE c.chatID = (" +
                    "           SELECT MAX(c2.chatID) FROM Chat c2 WHERE c2.parentID = p.parentID AND c2.teacherID = ?" +
                    "       )) AS lastMessage " +
                    "FROM Parent p " +
                    "ORDER BY lastChatID DESC NULLS LAST, p.parentID ASC";

                try (PreparedStatement ps = conn.prepareStatement(sqlAllParents)) {
                    ps.setInt(1, teacherID);
                    ps.setInt(2, teacherID);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            HashMap<String, Object> item = new HashMap<>();
                            item.put("id", rs.getInt("parentID"));
                            item.put("name", rs.getString("parentName"));

                            String lastMsg = rs.getString("lastMessage");
                            String stName = rs.getString("studentName");
                            if (lastMsg != null && !lastMsg.trim().isEmpty()) {
                                item.put("subtitle", lastMsg);
                            } else {
                                item.put("subtitle", (stName != null) ? "Murid: " + stName : "Ibu Bapa / Penjaga");
                            }
                            contactList.add(item);
                        }
                    }
                }

                if (!hasParentParam && !contactList.isEmpty()) {
                    parentID = (int) contactList.get(0).get("id");
                }

            } else {
                String sqlAllTeachers =
                    "SELECT t.teacherID, t.teacherName, " +
                    "       (SELECT MAX(c.chatID) FROM Chat c WHERE c.parentID = ? AND c.teacherID = t.teacherID) AS lastChatID, " +
                    "       (SELECT c.messageContent FROM Chat c WHERE c.chatID = (" +
                    "           SELECT MAX(c2.chatID) FROM Chat c2 WHERE c2.parentID = ? AND c2.teacherID = t.teacherID" +
                    "       )) AS lastMessage " +
                    "FROM Teacher t " +
                    "ORDER BY lastChatID DESC NULLS LAST, t.teacherID ASC";

                try (PreparedStatement ps = conn.prepareStatement(sqlAllTeachers)) {
                    ps.setInt(1, parentID);
                    ps.setInt(2, parentID);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            HashMap<String, Object> item = new HashMap<>();
                            item.put("id", rs.getInt("teacherID"));
                            item.put("name", rs.getString("teacherName"));

                            String lastMsg = rs.getString("lastMessage");
                            if (lastMsg != null && !lastMsg.trim().isEmpty()) {
                                item.put("subtitle", lastMsg);
                            } else {
                                item.put("subtitle", "Guru Kelas • Active Now");
                            }
                            contactList.add(item);
                        }
                    }
                }

                if (!hasTeacherParam && !contactList.isEmpty()) {
                    teacherID = (int) contactList.get(0).get("id");
                }
            }

            // 2. Dapatkan nama Teacher aktif
            if (teacherID > 0) {
                String sqlTeacher = "SELECT teacherName FROM Teacher WHERE teacherID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlTeacher)) {
                    ps.setInt(1, teacherID);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            teacherName = rs.getString("teacherName");
                        }
                    }
                }
            }

            // 3. Dapatkan nama Parent & Student aktif
            if (parentID > 0) {
                String sqlParent = "SELECT parentName FROM Parent WHERE parentID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlParent)) {
                    ps.setInt(1, parentID);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            parentName = rs.getString("parentName");
                        }
                    }
                }

                String sqlStudent = "SELECT studentName, studentClass FROM Student WHERE parentID = ? ORDER BY studentID ASC";
                try (PreparedStatement ps = conn.prepareStatement(sqlStudent)) {
                    ps.setInt(1, parentID);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            studentName = rs.getString("studentName");
                            studentClass = rs.getString("studentClass");
                        }
                    }
                }
            }

            // 4. Tarik sejarah perbualan & tandakan mesej pihak lawan sebagai telah dibaca guna markAsRead(chatID)
            ChatDAO chatDAO = new ChatDAO();
            List<Chat> chatHistory = chatDAO.getChatHistory(parentID, teacherID);

            for (Chat c : chatHistory) {
                if (c.getSenderRole() != null && !c.getSenderRole().equalsIgnoreCase(senderRole) && !c.isRead()) {
                    chatDAO.markAsRead(c.getChatID());
                    c.setRead(true);
                }
            }

            request.setAttribute("contactList", contactList);
            request.setAttribute("chatHistory", chatHistory);
            request.setAttribute("parentID", parentID);
            request.setAttribute("teacherID", teacherID);
            request.setAttribute("senderRole", senderRole);
            request.setAttribute("parentName", parentName);
            request.setAttribute("teacherName", teacherName);
            request.setAttribute("studentName", studentName);
            request.setAttribute("studentClass", studentClass);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("activeTab", "chat");
        request.setAttribute("activePage", "chat");
        request.getRequestDispatcher("chat.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int parentID = Integer.parseInt(request.getParameter("parentID"));
            int teacherID = Integer.parseInt(request.getParameter("teacherID"));
            String senderRole = request.getParameter("senderRole");
            String messageContent = request.getParameter("messageContent");

            if (messageContent != null && !messageContent.trim().isEmpty()) {
                Chat chat = new Chat();
                chat.setParentID(parentID);
                chat.setTeacherID(teacherID);
                chat.setSenderRole((senderRole != null && !senderRole.isEmpty()) ? senderRole : "Parent");
                chat.setMessageContent(messageContent.trim());
                chat.setRead(false);

                ChatDAO dao = new ChatDAO();
                dao.sendMessage(chat);
            }

            response.sendRedirect(request.getContextPath() + "/ChatServlet?parentID=" + parentID + "&teacherID=" + teacherID + "&senderRole=" + senderRole);
            return;

        } catch (Exception e) {
            e.printStackTrace();
        }

        doGet(request, response);
    }
}