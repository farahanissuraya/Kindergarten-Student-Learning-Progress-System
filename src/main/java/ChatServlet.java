import bean.Chat;
import dao.ChatDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int parentID = 1;
            int teacherID = 101;

            String parentParam = request.getParameter("parentID");
            String teacherParam = request.getParameter("teacherID");

            if (parentParam != null && !parentParam.trim().isEmpty()) {
                parentID = Integer.parseInt(parentParam);
            }
            if (teacherParam != null && !teacherParam.trim().isEmpty()) {
                teacherID = Integer.parseInt(teacherParam);
            }

            ChatDAO chatDAO = new ChatDAO();
            List<Chat> chatHistory = chatDAO.getChatHistory(parentID, teacherID);

            request.setAttribute("chatHistory", chatHistory);
            request.setAttribute("parentID", parentID);
            request.setAttribute("teacherID", teacherID);

            String senderRole = request.getParameter("senderRole");
            if (senderRole == null || senderRole.isEmpty()) {
                senderRole = "parent";
            }
            request.setAttribute("senderRole", senderRole);

        } catch (Exception e) {
            e.printStackTrace();
        }

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
                chat.setSenderRole(senderRole != null ? senderRole : "parent");
                chat.setMessageContent(messageContent.trim());

                ChatDAO dao = new ChatDAO();
                dao.sendMessage(chat);
            }

            response.sendRedirect(request.getContextPath() + "/chat?parentID=" + parentID + "&teacherID=" + teacherID + "&senderRole=" + senderRole);
            return;

        } catch (Exception e) {
            e.printStackTrace();
        }

        doGet(request, response);
    }
}