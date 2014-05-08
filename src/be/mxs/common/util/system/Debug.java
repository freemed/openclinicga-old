package be.mxs.common.util.system;

import java.text.SimpleDateFormat;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This should be the only place where "System.out.print" is used.
///////////////////////////////////////////////////////////////////////////////////////////////////

public class Debug {

    public static boolean enabled = false;
    public static boolean printStackTrace = true; // error-info
    public static SimpleDateFormat timeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS");

  
    //--- PRINT LN --------------------------------------------------------------------------------
    public static void println(String sText){
        if(enabled){
            if(sText.startsWith("\n\n")){
                System.out.println("\n\n["+timeFormat.format(new java.util.Date())+"] : "+sText.substring(2));
            }
            else if(sText.startsWith("\n")){
                System.out.println("\n["+timeFormat.format(new java.util.Date())+"] : "+sText.substring(1));
            }
            else{
                System.out.println("["+timeFormat.format(new java.util.Date())+"] : "+sText);
            }
        }
    }

    //--- PRINT -----------------------------------------------------------------------------------
    public static void print(String sText){
        if(enabled){
            if(sText.startsWith("\n\n")){
                System.out.print("\n\n["+timeFormat.format(new java.util.Date())+"] : "+sText.substring(2));
            }
            else if(sText.startsWith("\n")){
                System.out.print("\n["+timeFormat.format(new java.util.Date())+"] : "+sText.substring(1));
            }
            else{
                System.out.print("["+timeFormat.format(new java.util.Date())+"] : "+sText);
            }
        }
    }

    //--- PRINTLN ---------------------------------------------------------------------------------
    public static void println(int iText){
        if(enabled) System.out.println(timeFormat.format(new java.util.Date())+": "+iText);
    }

    public static void println(boolean bText){
        if(enabled) System.out.println(timeFormat.format(new java.util.Date())+": "+bText);
    }
    
    //--- PRINT PROJECT ERR -----------------------------------------------------------------------
    public static void printProjectErr(Exception e, StackTraceElement[] s, String more){
        System.out.println(ScreenHelper.fullDateFormatSS.format(new java.util.Date())+ " ERROR IN OpenClinic OCCURRED IN PAGE '" + s[2].getFileName() + "' METHOD '" + s[2].getMethodName() + "' LINE '" + s[2].getLineNumber() + "'\n                    MSG '"+more+" + " + ((e!=null)?e.fillInStackTrace().toString():"null")+ "'\n");
    }
    
    public static void printProjectErr(Exception e, StackTraceElement[] s){
        System.out.println(ScreenHelper.fullDateFormatSS.format(new java.util.Date())+ " ERROR IN OpenClinic OCCURRED IN PAGE '" + s[2].getFileName() + "' METHOD '" + s[2].getMethodName() + "' LINE '" + s[2].getLineNumber() + "'\n                    MSG '" + ((e!=null)?e.fillInStackTrace().toString():"null") + "'\n");
    }
    
    //--- PRINT STACKTRACE ------------------------------------------------------------------------
    public static void printStackTrace(Exception e){
        if(printStackTrace){
            System.out.println("\n********************** ERROR in OpenClinic ["+getTimeString()+"] **********************");
            e.printStackTrace();
        }
    }

    //--- GET TIME STRING -------------------------------------------------------------------------
    private static String getTimeString(){
        return timeFormat.format(new java.util.Date()); // now
    }
    
}
