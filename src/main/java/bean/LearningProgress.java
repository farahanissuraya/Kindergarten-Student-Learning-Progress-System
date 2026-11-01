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
    
    private String domainName;
    private String notes;
    private int ratingScale;
    private String assessorName;
    private String homeRecommendation;

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
    
    public String getDomainName() { return domainName; }
    public void setDomainName(String domainName) { this.domainName = domainName; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public int getRatingScale() { return ratingScale; }
    public void setRatingScale(int ratingScale) { this.ratingScale = ratingScale; }

    public String getAssessorName() { return assessorName; }
    public void setAssessorName(String assessorName) { this.assessorName = assessorName; }

    public String getHomeRecommendation() { return homeRecommendation; }
    public void setHomeRecommendation(String homeRecommendation) { this.homeRecommendation = homeRecommendation; }
}