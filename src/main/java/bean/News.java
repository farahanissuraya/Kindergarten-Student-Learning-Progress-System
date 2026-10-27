package bean;

import java.io.Serializable;
import java.sql.Timestamp;

public class News implements Serializable {
    private static final long serialVersionUID = 1L;

    private int newsID;
    private String newsTitle;
    private String newsContent;
    private Timestamp newsDate;
    private String newsCategory;
    private int teacherID;
    private String targetAudience;
    private boolean pinned;

    public News() {
    }

    public int getNewsID() {
        return newsID;
    }

    public void setNewsID(int newsID) {
        this.newsID = newsID;
    }

    public String getNewsTitle() {
        return newsTitle;
    }

    public void setNewsTitle(String newsTitle) {
        this.newsTitle = newsTitle;
    }

    public String getNewsContent() {
        return newsContent;
    }

    public void setNewsContent(String newsContent) {
        this.newsContent = newsContent;
    }

    public Timestamp getNewsDate() {
        return newsDate;
    }

    public void setNewsDate(Timestamp newsDate) {
        this.newsDate = newsDate;
    }

    public String getNewsCategory() {
        return newsCategory;
    }

    public void setNewsCategory(String newsCategory) {
        this.newsCategory = newsCategory;
    }
    
    public String getTargetAudience() { 
    	return targetAudience; 
    }
    
    public void setTargetAudience(String targetAudience) { 
    	this.targetAudience = targetAudience; 
    }

    public boolean isPinned() { 
    	return pinned; 
    }
    public void setPinned(boolean pinned) { 
    	this.pinned = pinned; 
    }

    public int getTeacherID() {
        return teacherID;
    }

    public void setTeacherID(int teacherID) {
        this.teacherID = teacherID;
    }
}