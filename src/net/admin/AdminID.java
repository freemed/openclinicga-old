package net.admin;

public class AdminID {
    public String type;
    public String alternateType;
    public String value;

    //--- CONSTRUCTOR 1 ---------------------------------------------------------------------------
    public AdminID(){
        this.type = "";
        this.alternateType = "";
        this.value = "";
    }

    //--- CONSTRUCTOR 2 ---------------------------------------------------------------------------
    public AdminID(String sType, String sValue) {
        this.type = sType;
        this.value = sValue;
    }
}