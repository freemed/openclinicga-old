package net.admin;

public class Parameter {
    public String parameter; // ~ name
    public String value;
    public java.util.Date updatetime;
    public String updateuserid;

    public Parameter(){
    	parameter = "";
        value = "";
    }

    public Parameter(String sName, String sValue) {
    	parameter = sName;
        value = sValue;
    }
    
    //--- CONSTRUCTOR 1 ---
    public Parameter(String name, String value, String updateuserid){
        this.parameter = name;
        this.value = value;
        this.updateuserid = updateuserid;            

        this.updatetime = new java.util.Date(); // now
    }

    //--- CONSTRUCTOR 2 ---
    public Parameter(String name, String value, java.util.Date updatetime, String updateuserid){
        this.parameter = name;
        this.value = value;
        this.updatetime = updatetime;
        this.updateuserid = updateuserid;  
    }

    //--- EQUALS ----------------------------------------------------------------------------------
    public boolean equals(Object obj){
        if(!(obj instanceof Parameter)) return false;
        else{
            return (this.parameter.equalsIgnoreCase(((Parameter)obj).parameter));
        }
    }

}