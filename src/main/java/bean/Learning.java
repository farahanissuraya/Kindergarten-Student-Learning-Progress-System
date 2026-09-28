package bean;

import java.io.Serializable;

public class Learning implements Serializable {
    private static final long serialVersionUID = 1L;

    private int learningID;
    private String learningName;
    private String learningCategory;

    public Learning() {
    }

    public int getLearningID() {
        return learningID;
    }

    public void setLearningID(int learningID) {
        this.learningID = learningID;
    }

    public String getLearningName() {
        return learningName;
    }

    public void setLearningName(String learningName) {
        this.learningName = learningName;
    }

    public String getLearningCategory() {
        return learningCategory;
    }

    public void setLearningCategory(String learningCategory) {
        this.learningCategory = learningCategory;
    }
}