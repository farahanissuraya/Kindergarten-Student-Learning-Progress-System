package bean;

public class Counting extends Learning {
    private static final long serialVersionUID = 1L;

    private String numberRange;
    private String objectCounting;
    private boolean shapeRecognition; // CHECK (0, 1) ditukar ke boolean

    public Counting() {
        super();
    }

    public String getNumberRange() {
        return numberRange;
    }

    public void setNumberRange(String numberRange) {
        this.numberRange = numberRange;
    }

    public String getObjectCounting() {
        return objectCounting;
    }

    public void setObjectCounting(String objectCounting) {
        this.objectCounting = objectCounting;
    }

    public boolean isShapeRecognition() {
        return shapeRecognition;
    }

    public void setShapeRecognition(boolean shapeRecognition) {
        this.shapeRecognition = shapeRecognition;
    }
}