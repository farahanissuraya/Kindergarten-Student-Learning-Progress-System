package bean;

import java.io.Serializable;

public class Parent implements Serializable {
    private static final long serialVersionUID = 1L;

    private int parentID;
    private String parentName;
    private String parentEmail;
    private String parentPassword;
    private String parentPhoneNumber;
    private String parentIC;
    private String parentGender;
    private String parentAddress;

    public Parent() {
    }

    public int getParentID() {
        return parentID;
    }

    public void setParentID(int parentID) {
        this.parentID = parentID;
    }

    public String getParentName() {
        return parentName;
    }

    public void setParentName(String parentName) {
        this.parentName = parentName;
    }

    public String getParentEmail() {
        return parentEmail;
    }

    public void setParentEmail(String parentEmail) {
        this.parentEmail = parentEmail;
    }

    public String getParentPassword() {
        return parentPassword;
    }

    public void setParentPassword(String parentPassword) {
        this.parentPassword = parentPassword;
    }

    public String getParentPhoneNumber() {
        return parentPhoneNumber;
    }

    public void setParentPhoneNumber(String parentPhoneNumber) {
        this.parentPhoneNumber = parentPhoneNumber;
    }
    
    public String getParentIC() { 
    	return parentIC; 
    }
    
    public void setParentIC(String parentIC) { 
    	this.parentIC = parentIC; 
    }
    
    public String getParentGender() { 
    	return parentGender; 
    }
    
    public void setParentGender(String parentGender) { 
    	this.parentGender = parentGender; 
    }
    
    public String getParentAddress() { 
    	return parentAddress; 
    }
    public void setParentAddress(String parentAddress) { 
    	this.parentAddress = parentAddress; 
    }
}