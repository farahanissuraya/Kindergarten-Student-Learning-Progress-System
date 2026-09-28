package bean;

public class Reading extends Learning {
    private static final long serialVersionUID = 1L;

    private String phonicsStatus;
    private String readingLevel;

    public Reading() {
        super();
    }

    public String getPhonicsStatus() {
        return phonicsStatus;
    }

    public void setPhonicsStatus(String phonicsStatus) {
        this.phonicsStatus = phonicsStatus;
    }

    public String getReadingLevel() {
        return readingLevel;
    }

    public void setReadingLevel(String readingLevel) {
        this.readingLevel = readingLevel;
    }
}