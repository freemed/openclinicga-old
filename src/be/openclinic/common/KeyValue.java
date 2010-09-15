package be.openclinic.common;

public class KeyValue implements Comparable{
    private String key;
    private String value;

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.value.compareTo(((KeyValue)o).value);
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

    public String getValue() {
        return value;
    }

    public int getValueInt() {
        try{
            return Integer.parseInt(value);
        }
        catch(Exception e){
            return -1;
        }
    }

    public void setValue(String value) {
        this.value = value;
    }

    public KeyValue(String key, String value) {
        this.key = key;
        this.value = value;
    }
}
