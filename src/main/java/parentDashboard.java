import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.Parent;
import bean.Student;
import bean.News;
import dao.NewsDAO;
import util.DatabaseConnection;

@WebServlet("/parentDashboard")
public class parentDashboard extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int parentId = 201; 

        HttpSession session = request.getSession(false);
        if (session != null) {
            Object parentIdObj = session.getAttribute("parentID");
            if (parentIdObj != null) {
                try {
                    String parsedId = parentIdObj.toString().trim();
                    if (!parsedId.isEmpty() && !parsedId.equals("null")) {
                        parentId = Integer.parseInt(parsedId);
                    }
                } catch (Exception ignored) {}
            }
        }

        Parent currentParent = new Parent();
        Student currentStudent = new Student();
        List<Student> registeredChildren = new ArrayList<>();
        List<News> newsList = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            if (conn != null) {
                // Tarik Data Parent
                String sqlParent = "SELECT parentID, parentName, parentEmail, parentPhoneNumber, parentIC, parentGender, parentAddress FROM PARENT WHERE parentID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlParent)) {
                    ps.setInt(1, parentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentParent.setParentID(rs.getInt("parentID"));
                            currentParent.setParentName(rs.getString("parentName"));
                            currentParent.setParentEmail(rs.getString("parentEmail"));
                            currentParent.setParentPhoneNumber(rs.getString("parentPhoneNumber"));
                            currentParent.setParentIC(rs.getString("parentIC"));
                            currentParent.setParentGender(rs.getString("parentGender"));
                            currentParent.setParentAddress(rs.getString("parentAddress"));
                        }
                    }
                }

                // Tarik Data Student
                String sqlChildren = "SELECT studentID, studentName, studentAge, studentClass, parentID, studentIC, studentGender FROM STUDENT WHERE parentID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlChildren)) {
                    ps.setInt(1, parentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Student child = new Student();
                            child.setStudentID(rs.getInt("studentID"));
                            child.setStudentName(rs.getString("studentName"));
                            child.setStudentAge(rs.getInt("studentAge"));
                            child.setStudentClass(rs.getString("studentClass"));
                            child.setParentID(rs.getInt("parentID"));
                            child.setStudentIC(rs.getString("studentIC"));
                            child.setStudentGender(rs.getString("studentGender"));
                            
                            registeredChildren.add(child);
                        }
                    }
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        // Tarik Data Berita dari Oracle DB melalui NewsDAO
        try {
            NewsDAO newsDAO = new NewsDAO();
            newsList = newsDAO.getNewsForParents();
        } catch (Exception e) {
            System.err.println("Ralat tarik berita: " + e.getMessage());
            e.printStackTrace();
        }

        // FALLBACK: Data Sarah & Leo Vance jika DB kosong atau gagal
        if (currentParent.getParentName() == null || currentParent.getParentName().isEmpty()) {
            currentParent.setParentID(201);
            currentParent.setParentName("Sarah Vance");
            currentParent.setParentGender("Female");
            currentParent.setParentEmail("sarah.vance@example.com");
        }

        if (registeredChildren.isEmpty()) {
            Student fallbackChild = new Student();
            fallbackChild.setStudentID(301);
            fallbackChild.setStudentName("Leo Vance");
            fallbackChild.setStudentAge(5);
            fallbackChild.setStudentClass("Kindergarten 3B");
            fallbackChild.setStudentGender("Male");
            fallbackChild.setParentID(201);
            
            registeredChildren.add(fallbackChild);
            currentStudent = fallbackChild;
        } else {
            currentStudent = registeredChildren.get(0);
        }

        // Hantar Atribut Selamat ke JSP
        request.setAttribute("errorMessage", null);
        request.setAttribute("parent", currentParent);
        request.setAttribute("parentTitle", "Mother");
        request.setAttribute("currentStudent", currentStudent);
        request.setAttribute("registeredChildren", registeredChildren);
        request.setAttribute("hasMultipleChildren", registeredChildren.size() > 1);
        request.setAttribute("activeAvatar", "👦");
        request.setAttribute("newsList", newsList);
        
        request.setAttribute("averageLevel", 85);
        request.setAttribute("photoProofsCount", 2);
        request.setAttribute("completedMilestones", 4);
        request.setAttribute("academicCycle", "Sept 2026");
        request.setAttribute("childAge", currentStudent.getStudentAge() != 0 ? currentStudent.getStudentAge() : 5);
        request.setAttribute("targetScale", 4);

        request.getRequestDispatcher("parentDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}