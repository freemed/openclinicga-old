package be.openclinic.common;

public class NumericKeyValue implements Comparable{
    private String key;
    private Double value;

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = -this.value.compareTo(((NumericKeyValue)o).value);
            if (comp==0){
            	comp = -this.key.compareTo(((NumericKeyValue)o).key);
            }
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public String getKey() {
        return key;
    }

    public int getKeyInt() {
        try{
            return Integer.parseInt(key);
        }
        catch(Exception e){
            return -1;
        }
    }

    public void setKey(String key) {
        this.key = key;
    }

    public Double getValue() {
        return value;
    }

    public int getValueInt() {
        try{
            return value.intValue();
        }
        catch(Exception e){
            return -1;
        }
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public NumericKeyValue(String key, Double value) {
        this.key = key;
        this.value = value;
    }
}
