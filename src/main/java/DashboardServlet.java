import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Semak jika sesi wujud
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil peranan pengguna daripada session (menyokong "role" dan "userRole")
        String role = (String) session.getAttribute("role");
        if (role == null || role.isBlank()) {
            role = (String) session.getAttribute("userRole");
        }

        // Jika tiada peranan ditemui, kembali ke halaman log masuk
        if (role == null || role.isBlank()) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 3. Tetapkan atribut tab aktif untuk kegunaan sidebar.jsp
        request.setAttribute("activeTab", "dashboard");

        // 4. Halakan (forward) ke dashboard mengikut peranan pengguna
        if ("Admin".equalsIgnoreCase(role) || "Administrator".equalsIgnoreCase(role)) {
            request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
        } else if ("Teacher".equalsIgnoreCase(role)) {
            request.getRequestDispatcher("teacherDashboard.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("parentDashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}