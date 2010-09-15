package be.mxs.common.util.system;

import java.text.SimpleDateFormat;

///////////////////////////////////////////////////////////////////////////////////////////////////
// This should be the only place where "System.out.print" is used.
///////////////////////////////////////////////////////////////////////////////////////////////////

public class Debug {

    public static boolean enabled = false;


    public static void println(String sText){
        if(enabled) System.out.println(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": "+sText);
    }

    public static void print(String sText){
        if(enabled) System.out.print(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": "+sText);
    }

    public static void println(int iText){
        if(enabled) System.out.println(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": "+iText);
    }

     public static void println(boolean bText){
        if(enabled) System.out.println(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": "+bText);
    }
      public static void printProjectErr(Exception e,StackTraceElement[] s,String more){
         System.out.println(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date())+ " ERROR IN OpenClinic OCCURRED IN PAGE '" + s[2].getFileName() + "' METHOD '" + s[2].getMethodName() + "' LINE '" + s[2].getLineNumber() + "'\n                    MSG '"+more+" + " + ((e!=null)?e.fillInStackTrace().toString():"null")+ "'\n");
     }
      public static void printProjectErr(Exception e,StackTraceElement[] s){
          System.out.println(new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date())+ " ERROR IN OpenClinic OCCURRED IN PAGE '" + s[2].getFileName() + "' METHOD '" + s[2].getMethodName() + "' LINE '" + s[2].getLineNumber() + "'\n                    MSG '" + ((e!=null)?e.fillInStackTrace().toString():"null") + "'\n");
     }
}
