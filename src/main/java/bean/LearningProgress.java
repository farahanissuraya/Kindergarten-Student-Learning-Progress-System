package bean;

import java.io.Serializable;

public class LearningProgress implements Serializable {
    private static final long serialVersionUID = 1L;

    private int progressID;
    private int learningID;
    private int studentID;
    private String progressName;
    private String progressDate; // Boleh guna String atau java.util.Date / java.sql.Date
    private double progressPercentage;
    private String progressStatus;
    private int teacherID;

    public LearningProgress() {
    }

    public int getProgressID() {
        return progressID;
    }

    public void setProgressID(int progressID) {
        this.progressID = progressID;
    }

    public int getLearningID() {
        return learningID;
    }

    public void setLearningID(int learningID) {
        this.learningID = learningID;
    }

    public int getStudentID() {
        return studentID;
    }

    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }

    public String getProgressName() {
        return progressName;
    }

    public void setProgressName(String progressName) {
        this.progressName = progressName;
    }

    public String getProgressDate() {
        return progressDate;
    }

    public void setProgressDate(String progressDate) {
        this.progressDate = progressDate;
    }

    public double getProgressPercentage() {
        return progressPercentage;
    }

    public void setProgressPercentage(double progressPercentage) {
        this.progressPercentage = progressPercentage;
    }

    public String getProgressStatus() {
        return progressStatus;
    }

    public void setProgressStatus(String progressStatus) {
        this.progressStatus = progressStatus;
    }

    public int getTeacherID() {
        return teacherID;
    }

    public void setTeacherID(int teacherID) {
        this.teacherID = teacherID;
    }
}