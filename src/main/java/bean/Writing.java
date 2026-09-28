package bean;

public class Writing extends Learning {
    private static final long serialVersionUID = 1L;

    private String letterTracing;
    private boolean nameWriting; // CHECK (0, 1) ditukar ke boolean

    public Writing() {
        super();
    }

    public String getLetterTracing() {
        return letterTracing;
    }

    public void setLetterTracing(String letterTracing) {
        this.letterTracing = letterTracing;
    }

    public boolean isNameWriting() {
        return nameWriting;
    }

    public void setNameWriting(boolean nameWriting) {
        this.nameWriting = nameWriting;
    }
}