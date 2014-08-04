package net.admin;

public class Parameter{
    public String parameter;
    public String value;
    public java.util.Date updatetime;
    public String updateuserid;

    public Parameter(){
        parameter = "";
        value = "";
    }

    public Parameter(String sParameter, String sValue) {
        parameter = sParameter;
        value = sValue;
    }
    
    //--- CONSTRUCTOR 2 ---
    public Parameter(String name, String value, String updateuserid) {
        this.parameter = name;
        this.value = value;
        this.updateuserid = updateuserid;

        this.updatetime = new java.util.Date(); // now
    }
}