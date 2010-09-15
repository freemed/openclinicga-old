package be.mxs.common.util.system;

import java.io.*;
import java.util.Date;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 9-sept-2005
 */

/***************************************************************************************************
  MOST IMPORTANT PUBLIC METHODS :
    public static void setAppend(boolean value)
    public static void setOutputFile(String filepath)

    public static void log(String msg)
    public static void log(String msg, String linenr)
    public static void log(String msg, int level, String linenr)
***************************************************************************************************/
public class Logger{

    //--- DECLARATIONS -----------------------------------------------------------------------------
    private static String DATE_FORMAT_TIME = "dd/MM/yyyy @HH:mm:ss";
    private static SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_FORMAT_TIME);

    public static final int ERROR_LEVEL_INFO    = 0;
    public static final int ERROR_LEVEL_WARNING = 1;
    public static final int ERROR_LEVEL_ERROR   = 2;
    public static final int ERROR_LEVEL_SEVERE  = 3;

    private static FileOutputStream fileOutputStream ;
    private static PrintStream printStream;
    private static String outputFile;
    private static boolean append;
    private static StringBuffer buffer;


    //--- SETAPPEND --------------------------------------------------------------------------------
    // If true, append the error-messages to the existing logfile, without emptying it first.
    //----------------------------------------------------------------------------------------------
    public static void setAppend(boolean value){
        append = value;
    }

    //--- SETOUTPUTFILE ----------------------------------------------------------------------------
    // What file will be the log-file ?
    //----------------------------------------------------------------------------------------------
    public static void setOutputFile(String filepath) throws Exception {
        outputFile = filepath;

        try{
            fileOutputStream = new FileOutputStream(outputFile,append);
            printStream = new PrintStream(fileOutputStream);
        }
        catch(FileNotFoundException e){
            throw new Exception("Logger.setOutputFile() : filepath ("+filepath+") not found.");
        }
    }

    //--- LOG METHODS ------------------------------------------------------------------------------
    public static void log(String msg){
        writeToLogfile(formatMsg(msg,0));
    }

    public static void log(String msg, String linenr){
        writeToLogfile(formatMsg(msg,0).append(" [line "+linenr+"]"));
    }

    public static void log(String msg, int level, String linenr){
        writeToLogfile(formatMsg(msg,level).append(" [line "+linenr+"]"));
    }

    public static void log(String msg, int level){
        writeToLogfile(formatMsg(msg,level));
    }


    public static void log(StringBuffer buf){
        writeToLogfile(formatMsg(buf.toString(),0));
    }

    public static void log(StringBuffer buf, String linenr){
        writeToLogfile(formatMsg(buf.toString(),0).append(" [line "+linenr+"]"));
    }

    public static void log(StringBuffer buf, int level){
        writeToLogfile(formatMsg(buf.toString(),level));
    }

    public static void log(StringBuffer buf, int level, String linenr){
        writeToLogfile(formatMsg(buf.toString(),level).append(" [line "+linenr+"]"));
    }


    public static void log(int value){
        writeToLogfile(formatMsg(value+"",0));
    }

    public static void log(int value, String linenr){
        writeToLogfile(formatMsg(value+"",0).append(" [line "+linenr+"]"));
    }

    public static void log(int value, int level){
        writeToLogfile(formatMsg(value+"",level));
    }

    public static void log(int value, int level, String linenr){
        writeToLogfile(formatMsg(value+"",level).append(" [line "+linenr+"]"));
    }


    //--- CLOSE ------------------------------------------------------------------------------------
    // close the log-file and delete it if it is empty.
    //----------------------------------------------------------------------------------------------
    public static void close(){
        // draw line
        //if(append){
        //    printStream.println("\n");
        //}

        // close file
        try{
            printStream.flush();
            printStream.close();
            fileOutputStream.close();
        }
        catch(IOException e){
            e.printStackTrace();
        }

        // delete file if no content
        File file = new File(outputFile);
        if(file.exists()){
            if(file.length()==0){
                file.delete();
            }
        }
    }

    //--- FINALISE ---------------------------------------------------------------------------------
    public void finalise(){
        close();
    }


    //### PRIVATE METHODS ##########################################################################

    //--- FORMATMSG --------------------------------------------------------------------------------
    private static StringBuffer formatMsg(String msg, int level){
        buffer = new StringBuffer();

        // append timestamp
        buffer.append("[")
              .append(simpleDateFormat.format(new Date()))
              .append("] ");

        // append level-label
             if(level == ERROR_LEVEL_INFO)    buffer.append("INFO    : ");
        else if(level == ERROR_LEVEL_WARNING) buffer.append("WARNING : ");
        else if(level == ERROR_LEVEL_ERROR)   buffer.append("ERROR   : ");
        else if(level == ERROR_LEVEL_SEVERE)  buffer.append("SEVERE  : ");

        // add message
        buffer.append(msg);

        return buffer;
    }

    //--- WRITETOLOGFILE ---------------------------------------------------------------------------
    private static void writeToLogfile(StringBuffer buffer) {
        if(printStream == null){
            if(Debug.enabled) Debug.println("ERROR : OutputFile not set for ErrorLogger (Logger.log()).");
        }
        else{
            printStream.println(buffer.toString());
            checkError();
        }
    }

    //--- CHECKERROR -------------------------------------------------------------------------------
    // PrintStream does not throw any IOExceptions.. but you can check an internal error-flag..
    //----------------------------------------------------------------------------------------------
    private static void checkError(){
        if(printStream.checkError()){
            if(Debug.enabled) Debug.println("INFO  : printStream.checkError() in Logger is TRUE.");
        }
    }

}
