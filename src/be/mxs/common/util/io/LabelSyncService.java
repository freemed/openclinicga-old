package be.mxs.common.util.io;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.Connection;
import java.sql.SQLException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileInputStream;
import java.util.*;

/**
 * User: stijn smets
 * Date: 26-okt-2005
 */

//### PUBLIC METHODS ##############################################################################
// Run thru labels in source file.
// Check if labelnl and labelfr exist in Labels table.
// If not, insert a label record in DB.
// *** AND VICE VERSA ***

// * public setOut(javax.servlet.jsp.JspWriter out)
// * public static LabelSyncService getInstance()
// * public void setDebug(boolean debug)
// * public boolean isSyncNeeded()
// * public void updateINIFile()
// * public void updateDB()
// * public void updateAutoSyncIniFileValue(String value)
//#################################################################################################
public class LabelSyncService {

    // declarations
    private static LabelSyncService instance;
    private PreparedStatement ps;
    private ResultSet rs;
    private Vector supportedLanguages;
    private String sLabelTypeID, sLabelType, sLabelID, sLabelLang, sLabelValue,
                   query, iniKey, templateDirectory ;
    private int labelCount, invalidLabelCount, labelStoreCount;
    private Enumeration keys;
    private boolean debug;
    private Timestamp nowTimestamp;
    private javax.servlet.jsp.JspWriter out;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    private LabelSyncService() throws Exception {
        // locate ini files
        templateDirectory = MedwanQuery.getInstance().getConfigString("templateDirectory");
        if(templateDirectory == null){
            throw new Exception("LabelSyncService : ConfigString 'templateDirectory' is empty or does not exist.");
        }

        // supported languages
        supportedLanguages = new Vector();

        String supportedLangs = MedwanQuery.getInstance().getConfigString("supportedLanguages");
        if(supportedLangs.length()==0) supportedLangs = "nl,fr";

        StringTokenizer tokenizer = new StringTokenizer(supportedLangs,",");
        String tmpLang;
        while(tokenizer.hasMoreTokens()){
            tmpLang = tokenizer.nextToken();
            supportedLanguages.add(tmpLang);
        }
    }

    //--- SET OUT ---------------------------------------------------------------------------------
    public void setOut(javax.servlet.jsp.JspWriter out){
        this.out = out;
    }

    //--- GET INSTANCE ----------------------------------------------------------------------------
    public static LabelSyncService getInstance() throws Exception {
        if(instance==null) instance = new LabelSyncService();
        return instance;
    }

    //--- SET DEBUG -------------------------------------------------------------------------------
    public void setDebug(boolean debug){
        this.debug = debug;
    }

    //--- IS SYNC NEEDED --------------------------------------------------------------------------
    public boolean isSyncNeeded(){
        boolean keyExists = false;
        String keyValue = "";
        ResultSet rs;

        try{
            Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();

            ps = conn.prepareStatement("SELECT oc_key,oc_value FROM OC_Config WHERE oc_key=?");
            ps.setString(1,"autoSyncIniFiles");
            rs = ps.executeQuery();
            if(rs.next()){
                keyExists = true;
                keyValue = rs.getString("oc_value");
            }
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();

            if(!keyExists){
                // key not found, so insert it
                ps = conn.prepareStatement("INSERT INTO OC_Config(oc_key,oc_value,updatetime) VALUES(?,?,?)");
                ps.setString(1,"autoSyncIniFiles");
                ps.setString(2,"1");
                ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
                ps.close();

                MedwanQuery.reload();
                keyExists = true;
            }
            else{
            	conn.close();
                // keyvalue indicates sync is needed
                if(keyValue.equals("1")) return true;
                else                     return false;
            }
            conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return keyExists;
    }

    //--- UPDATE DB -------------------------------------------------------------------------------
    // In ini, not in DB (INI TO DB)
    //---------------------------------------------------------------------------------------------
    public void updateDB(){
        for(int i=0; i<supportedLanguages.size(); i++){
            updateDB((String)supportedLanguages.get(i));
        }
    }

    //--- UPDATE DB -------------------------------------------------------------------------------
    public void updateDB(String language){
        status("UPDATING LABELS IN DATABASE ("+language+") ...");

        // reset counters
        labelCount = 0;
        labelStoreCount = 0;
        invalidLabelCount = 0;

        nowTimestamp = new Timestamp(new java.util.Date().getTime());
        Hashtable labels = MedwanQuery.getInstance().getLabels();

        try{
            String iniFileName = templateDirectory+"/Labels."+language+".ini";
            if(debug){
                if(Debug.enabled) Debug.println("\nUPDATING LABELS IN DB ("+iniFileName+")");
            }

            // run thru labels in INI file of active language
            Properties iniProps = getPropertyFile(iniFileName);
            Enumeration e = iniProps.propertyNames();
            Hashtable labelsPerLanguage = (Hashtable)labels.get(language);
            while(e.hasMoreElements()){
                labelCount++;

                // display progress
                if(!debug){
                    if(Debug.enabled){
                        if(labelCount%100==0) Debug.print(".");
                        if(labelCount>0 && labelCount%5000==0) Debug.println("");
                    }
                }

                sLabelTypeID = ((String)e.nextElement()).toLowerCase();

                if(sLabelTypeID.indexOf("$") > 0){
                    sLabelType = sLabelTypeID.split("\\$")[0];
                    sLabelID   = sLabelTypeID.split("\\$")[1];
                    sLabelLang = sLabelTypeID.split("\\$")[2];

                    if(!sLabelLang.equals(language)){
                        throw new Exception("LabelSyncService : language in inifile different from language in database : "+sLabelLang+" <> "+language);
                    }

                    if(labelsPerLanguage.get(sLabelType)==null || ((Hashtable)labelsPerLanguage.get(sLabelType)).get(sLabelID)==null){
                        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                        try{
                            // get specific label
                            String lowerLabelType = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE"),
                                   lowerLabelId   = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID"),
                                   lowerLabelLang = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

                            query = "SELECT OC_LABEL_ID FROM OC_LABELS "+
                                    " WHERE "+lowerLabelLang+" = ?"+
                                    "  AND "+lowerLabelType+" = ?"+
                                    "  AND "+lowerLabelId+" = ?";
                            ps = loc_conn.prepareStatement(query);
                            ps.setString(1,sLabelLang.toLowerCase());
                            ps.setString(2,sLabelType.toLowerCase());
                            ps.setString(3,sLabelID.toLowerCase());
                            rs = ps.executeQuery();

                            // label not found in DB
                            if(!rs.next()){
                                sLabelValue = iniProps.getProperty(sLabelTypeID);

                                storeLabel(sLabelType,sLabelID,language,sLabelValue,0);

                                if(debug){
                                    if(Debug.enabled){
                                        Debug.println("\nStore label in DB :");
                                        Debug.println(" - LabelType  : "+sLabelType);
                                        Debug.println(" - LabelID    : "+sLabelID);
                                        Debug.println(" - LabelLang  : "+sLabelLang);
                                        Debug.println(" - LabelValue : "+sLabelValue);
                                    }
                                }

                                labelStoreCount++;
                            }
                        }
                        catch(SQLException ex){
                            ex.printStackTrace();
                        }
                        finally{
                            try{
                                if(rs!=null) rs.close();
                                if(ps!=null) ps.close();
                                loc_conn.close();
                            }
                            catch(SQLException sqle){
                                sqle.printStackTrace();
                            }
                        }
                    }
                }
                else{
                    if(Debug.enabled){
                        Debug.println("\n!!! INVALID LABEL in DB !!!");
                        Debug.println(" - Type  : "+sLabelType);
                        Debug.println(" - ID    : "+sLabelID);
                        Debug.println(" - Lang  : "+sLabelLang);
                        Debug.println(" - Value : "+sLabelValue);
                    }

                    invalidLabelCount++;
                }
            }

            // report to user
            if(debug){
                if(Debug.enabled){
                    Debug.println("\n\n=== UPDATED LABELS IN DB ("+sLabelLang+") ================");
                    Debug.println(" "+labelCount+" labels in input file");
                    Debug.println(" "+labelStoreCount+" labels inserted in DB");
                    Debug.println(" "+invalidLabelCount+" invalid labels found");
                    Debug.println("==============================================\n");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- UPDATE INI FILES ------------------------------------------------------------------------
    // In DB, not in ini (DB TO INI)
    //---------------------------------------------------------------------------------------------
    public void updateINIFiles(){
        for(int i=0; i<supportedLanguages.size(); i++){
            updateINIFile((String)supportedLanguages.get(i));
        }
    }

    //--- UPDATE INI FILES ------------------------------------------------------------------------
    public void updateINIFile(String language){
        status("UPDATING LABELS IN INIFILE ("+language+") ...");

        // reset counters
        labelCount = 0;
        labelStoreCount = 0;
        invalidLabelCount = 0;

        FileWriter csvWriter = null;
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // get labels from INI
            String iniFileName = templateDirectory+"/Labels."+language+".ini";
            if(debug){
                if(Debug.enabled) Debug.println("\nUPDATING LABELS IN INIFILE ("+iniFileName+")");
            }

            Properties iniProps = getPropertyFile(iniFileName);
            csvWriter = new FileWriter(iniFileName,true);

            // get labels of one language from DB
            String lowerLabelType = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE"),
                   lowerLabelLang = MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

            query = "SELECT OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,OC_LABEL_VALUE"+
                    " FROM OC_LABELS"+
                    " WHERE "+lowerLabelType+" NOT IN ('externalservice','service','function')"+
                    "  AND "+lowerLabelLang+" = ?";
            ps = loc_conn.prepareStatement(query);
            ps.setString(1,language.toLowerCase());
            rs = ps.executeQuery();

            // run thru labels in DB
            while(rs.next()){
                // display progress
                if(!debug){
                    if(Debug.enabled){
                        if(labelCount%100==0) Debug.print(".");
                        if(labelCount>0 && labelCount%5000==0) Debug.println("");
                    }
                }

                sLabelType = checkString(rs.getString("OC_LABEL_TYPE").toLowerCase());
                sLabelID   = checkString(rs.getString("OC_LABEL_ID").toLowerCase());
                sLabelTypeID = sLabelType+"$"+sLabelID+"$"+language;

                // skip some labels
                if(!sLabelType.equals("labanalysis") && !sLabelType.equals("labprofiles") && !sLabelType.equals("activitycodes")){
                    labelCount++;

                    // only list records if not in ini, so check existence in ini.
                    if(!containsKey(iniProps,sLabelTypeID)){
                        sLabelValue = checkString(rs.getString("OC_LABEL_VALUE"));

                        // not found in INI file, so add.
                        if(sLabelTypeID.indexOf(" ") < 0 && sLabelTypeID.indexOf("/") < 0 && sLabelTypeID.indexOf(":") < 0){
                            csvWriter.write(sLabelTypeID+"="+sLabelValue.replaceAll("\n","")+"\r\n");
                            csvWriter.flush();

                            if(debug){
                                if(Debug.enabled){
                                    Debug.println("\nadd label to input file :");
                                    Debug.println(" - "+language+" : "+sLabelTypeID+"="+sLabelValue);
                                }
                            }

                            labelStoreCount++;
                        }
                        // invalid characters in label, not added.
                        else{
                            if(Debug.enabled){
                                Debug.println("\n!!! INVALID LABEL in DB !!!");
                                Debug.println(" - Type  : "+sLabelType);
                                Debug.println(" - ID    : "+sLabelID);
                                Debug.println(" - Lang  : "+language);
                                Debug.println(" - Value : "+sLabelValue);
                            }

                            invalidLabelCount++;
                        }
                    }
                }
            }

            // report to user
            if(debug){
                if(Debug.enabled){
                    Debug.println("\n\n=== UPDATED LABELS IN INI FILE ("+language+") =========");
                    Debug.println(" "+labelCount+" labels in DB");
                    Debug.println(" "+labelStoreCount+" labels inserted in INI file");
                    Debug.println(" "+invalidLabelCount+" invalid labels found in DB");
                    Debug.println("=============================================\n");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(csvWriter!=null) csvWriter.close();
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- UPDATE AUTO SYNC INI FILE VALUE ---------------------------------------------------------
    public void updateAutoSyncIniFileValue(String value){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
            String sSelect = "UPDATE OC_Config SET oc_value=?, updatetime=? WHERE oc_key=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,value);
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
            ps.setString(3,"autoSyncIniFiles");
            ps.executeUpdate();
        }
        catch(SQLException e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################

    //--- CHECK STRING ----------------------------------------------------------------------------
    private String checkString(String string) {
        if(string==null || string.equalsIgnoreCase("null")){
            return "";
        }
        else{
            return string.trim();
        }
    }

    //--- CONTAINS KEY ----------------------------------------------------------------------------
    // a properties object is case sensitive; this function makes it INsensitive.
    //---------------------------------------------------------------------------------------------
    private boolean containsKey(Properties properties, String key){
        keys = properties.keys();

        while(keys.hasMoreElements()){
            iniKey = (String)keys.nextElement();
            if(iniKey.equalsIgnoreCase(key)){
                return true;
            }
        }

        return false;
    }

    //--- GET PROPERTY FILE -----------------------------------------------------------------------
    private Properties getPropertyFile(String sFilename) throws Exception {
        FileInputStream iniIs = null;
        Properties iniProps = new Properties();

        // create ini file if they do not exist
        try{
          iniIs = new FileInputStream(sFilename);
          iniProps.load(iniIs);
        }
        finally{
            if(iniIs!=null){
                try{ iniIs.close(); }
                catch(Exception e){}
            }
        }

        return iniProps;
    }

    //--- STORE LABEL -----------------------------------------------------------------------------
    // insert label in DB.
    //---------------------------------------------------------------------------------------------
    private void storeLabel(String labelType, String labelId, String labelLang, String labelValue, int userid){
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // insert label
            query = "INSERT INTO OC_LABELS(OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,OC_LABEL_VALUE,"+
                    "  OC_LABEL_SHOWLINK,OC_LABEL_UPDATETIME,OC_LABEL_UPDATEUSERID)"+
                    " VALUES (?,?,?,?,?,?,?)";
            ps = loc_conn.prepareStatement(query);

            ps.setString(1,labelType);
            ps.setString(2,labelId);
            ps.setString(3,labelLang);
            ps.setString(4,labelValue);
            ps.setInt(5,userid);
            ps.setTimestamp(6,nowTimestamp); // same updatetime for all labels
            ps.setBoolean(7,false); // showLink
            ps.execute();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    //--- STATUS ----------------------------------------------------------------------------------
    private void status(String message){
        try{
            if(out!=null){
                out.print("<script>window.status='"+message+"';</script>");
                out.flush();
            }
        }
        catch(IOException e){
            e.printStackTrace();
        }
    }

}
