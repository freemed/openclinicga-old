package be.mxs.common.util.io;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileInputStream;
import java.util.*;

/**
 * User: stijn smets
 * Date: 29-dec-2006
 */

//### PUBLIC METHODS ##############################################################################
// Run thru transactionItems in source file.
// Check if they exist in TransactionItems table.
// If not, insert a item record in DB.
// *** AND VICE VERSA ***

// * public setOut(javax.servlet.jsp.JspWriter out)
// * public static TransactionItemSyncService getInstance()
// * public void setDebug(boolean debug)
// * public boolean isSyncNeeded()
// * public void updateINIFile()
// * public void updateDB()
// * public void updateAutoSyncIniFileValue(String value)

// TransactionItems : transactionTypeId,itemTypeId,defaultValue,modifier,priority,updatetime
//#################################################################################################
public class TransactionItemSyncService {

    // declarations
    private static TransactionItemSyncService instance;
    private PreparedStatement ps, psGetItems, psInsertItem;
    private ResultSet rs;
    private String sItemTypeID, sItemType, sItemID, query, iniKey, sItem;
    private int itemCount, invalidItemCount, itemStoreCount;
    private FileWriter csvWriter;
    private Enumeration keys;
    private boolean debug;
    private String INIFILENAME;
    private Timestamp nowTimestamp;
    private javax.servlet.jsp.JspWriter out;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    private TransactionItemSyncService() throws Exception {
        // locate ini files
        String templateDirectory = MedwanQuery.getInstance().getConfigString("templateDirectory");
        if(templateDirectory == null){
            throw new Exception("TransactionItemSyncService : ConfigString 'templateDirectory' is empty or does not exist");
        }

        INIFILENAME = templateDirectory+"/TransactionItems.ini";
    }

    //--- SET OUT ---------------------------------------------------------------------------------
    public void setOut(javax.servlet.jsp.JspWriter out){
        this.out = out;
    }

    //--- GET INSTANCE ----------------------------------------------------------------------------
    public static TransactionItemSyncService getInstance() throws Exception {
        if(instance==null) instance = new TransactionItemSyncService();
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

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT oc_key,oc_value FROM OC_Config WHERE oc_key = ?";
            ps = oc_conn.prepareStatement(sQuery);
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
                String sSelect = "INSERT INTO OC_Config(oc_key,oc_value,updatetime) VALUES(?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,"autoSyncIniFiles");
                ps.setString(2,"1");
                ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
                ps.close();

                MedwanQuery.reload();
                keyExists = true;
            }
            else{
                // keyvalue indicates wheter sync is needed
                oc_conn.close();
                if(keyValue.equals("1")) return true;
                else                     return false;
            }
            oc_conn.close();
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
        status("UPDATING TRANSACTION ITEMS IN DATABASE...");

        if(debug){
            if(Debug.enabled) Debug.println("\nUPDATING TRANSACTION ITEMS IN DB ("+INIFILENAME+")");
        }

        // reset counters
        itemCount = 0;
        itemStoreCount = 0;
        invalidItemCount = 0;

        nowTimestamp = new Timestamp(new java.util.Date().getTime());
        Hashtable itemsDB = getTransactionItemsFromDB();

        // run thru items in INI file
        String sItemValue, sItemModifier;
        Properties iniProps = getPropertyFile(INIFILENAME);
        Enumeration e = iniProps.propertyNames();
        while(e.hasMoreElements()){
            // display progress
            if(!debug){
                if(Debug.enabled){
                    if(itemCount%100==0) Debug.print(".");
                    if(itemCount>0 && itemCount%5000==0) Debug.println("");
                }
            }

            sItemTypeID = (String)e.nextElement();

            if(sItemTypeID.indexOf("$") > 0){
                sItemType = sItemTypeID.substring(0,sItemTypeID.indexOf("$"));
                sItemID   = sItemTypeID.substring(sItemTypeID.indexOf("$")+1);

                // check if item exists in DB; if not, insert item in DB
                if(itemsDB.get(sItemTypeID.toLowerCase())==null){
                    sItemType = sItemType.toLowerCase();
                    sItemID = sItemID.toLowerCase();

                    sItem = iniProps.getProperty(sItemTypeID);
                    sItemValue    = sItem.substring(0,sItem.indexOf("$"));
                    sItemModifier = sItem.substring(sItem.indexOf("$")+1);

                    storeItem(sItemType,sItemID,sItemValue,sItemModifier,0);

                    if(debug){
                        if(Debug.enabled){
                            Debug.println("\nStore transaction item in DB :");
                            Debug.println(" - itemType     : "+sItemType);
                            Debug.println(" - itemID       : "+sItemID);
                            Debug.println(" - itemValue    : "+sItemValue);
                            Debug.println(" - itemModifier : "+sItemModifier);
                        }
                    }

                    itemStoreCount++;
                }

                itemCount++;
            }
            else{
                if(Debug.enabled){
                    Debug.println("\n!!! INVALID TRANSACTION ITEM in DB !!!");
                    Debug.println(" - Type : "+sItemType);
                    Debug.println(" - ID   : "+sItemID);
                    Debug.println(" - ItemTypeID : "+sItemTypeID);
                }

                invalidItemCount++;
            }
        }

        // report to user
        if(debug){
            if(Debug.enabled){
                Debug.println("\n\n=== UPDATED TRANSACTION ITEMS IN DB ================");
                Debug.println(" "+itemCount+" items in input file");
                Debug.println(" "+itemStoreCount+" items inserted in DB");
                Debug.println(" "+invalidItemCount+" invalid items found");
                Debug.println("====================================================\n");
            }
        }
    }

    //--- UPDATE INI FILE -------------------------------------------------------------------------
    // In DB, not in ini (DB TO INI)
    //---------------------------------------------------------------------------------------------
    public void updateINIFile(){
        status("UPDATING TRANSACTION ITEMS IN INIFILE...");

        if(debug){
            if(Debug.enabled) Debug.println("\nUPDATING TRANSACTION ITEMS IN INIFILE");
        }

        // reset counters
        itemCount = 0;
        itemStoreCount = 0;
        invalidItemCount = 0;

        // create writer
        try{ csvWriter = new FileWriter(INIFILENAME,true); }
        catch(IOException e){
            e.printStackTrace();
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // get items
            query = "SELECT transactionTypeId,itemTypeId,defaultValue,modifier FROM TransactionItems";
            psGetItems = oc_conn.prepareStatement(query);
            rs = psGetItems.executeQuery();

            Properties iniProps = getPropertyFile(INIFILENAME);

            // run thru items in DB
            String sItemValue, sItemModifier;
            while(rs.next()){
                // display progress
                if(!debug){
                    if(Debug.enabled){
                        if(itemCount%100==0) Debug.print(".");
                        if(itemCount>0 && itemCount%5000==0) Debug.println("");
                    }
                }

                sItemType   = checkString(rs.getString("transactionTypeId").toLowerCase());
                sItemID     = checkString(rs.getString("itemTypeId").toLowerCase());
                sItemTypeID = sItemType+"$"+sItemID;

                itemCount++;

                // only list records if not in ini, so check existence in ini.
                if(!containsKey(iniProps,sItemTypeID)){
                    // not found in INI file, so add.
                    if(sItemTypeID.indexOf(" ") < 0 && sItemTypeID.indexOf("/") < 0 && sItemTypeID.indexOf(":") < 0){
                        sItemValue    = checkString(rs.getString("defaultValue"));
                        sItemModifier = checkString(rs.getString("modifier"));
                        sItem = sItemValue+"$"+sItemModifier;

                        csvWriter.write(sItemTypeID+"="+sItem.replaceAll("\n","")+"\r\n");
                        csvWriter.flush();

                        if(debug){
                            if(Debug.enabled){
                                Debug.println("\nadd transaction item to input file :");
                                Debug.println(" - item : "+sItemTypeID+"="+sItem);
                            }
                        }

                        itemStoreCount++;
                    }
                    // invalid characters in item, not added.
                    else{
                        if(Debug.enabled){
                            Debug.println("\n!!! INVALID transaction item in input file !!!");
                            Debug.println(" - Type : "+sItemType);
                            Debug.println(" - ID   : "+sItemID);
                        }

                        invalidItemCount++;
                    }
                }
            }
            rs.close();
            ps.close();

            // report to user
            if(debug){
                if(Debug.enabled){
                    Debug.println("\n\n=== UPDATED TRANSACTION ITEMS IN INI FILE =========");
                    Debug.println(" "+itemCount+" items in DB");
                    Debug.println(" "+itemStoreCount+" items inserted in INI file");
                    Debug.println(" "+invalidItemCount+" invalid items found in DB");
                    Debug.println("===================================================\n");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            // close writer
            try{ csvWriter.close(); }
            catch(Exception e){}
        }
    	try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

    }

    //--- UPDATE AUTO SYNC INI FILE VALUE ---------------------------------------------------------
    public void updateAutoSyncIniFileValue(String value){
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
        	String sQuery = "UPDATE OC_Config SET oc_value=?, updatetime=? WHERE oc_key=?";
            ps = oc_conn.prepareStatement(sQuery);
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

    //--- GET TRANSCACTIONITEMS FROM DB -----------------------------------------------------------
    // transactionTypeId $ itemTypeId = defaultValue
    //---------------------------------------------------------------------------------------------
    private Hashtable getTransactionItemsFromDB(){
        Hashtable items = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String select = "SELECT transactionTypeId,itemTypeId,defaultValue,modifier"+
                            " FROM TransactionItems";
            ps = loc_conn.prepareStatement(select);
            rs = ps.executeQuery();

            String transactionTypeId, itemTypeId, defaultValue, modifier;
            while(rs.next()){
                // uniqueKey
                transactionTypeId = checkString(rs.getString("transactionTypeId")).toLowerCase();
                itemTypeId        = checkString(rs.getString("itemTypeId")).toLowerCase();
                defaultValue      = checkString(rs.getString("defaultValue"));
                modifier          = checkString(rs.getString("modifier"));

                if(transactionTypeId.length() > 0 && itemTypeId.length() > 0){
                    items.put(transactionTypeId+"$"+itemTypeId,defaultValue+"$"+modifier);
                }
                else{
                    // throw exception when invalid uniqueKey
                    if(transactionTypeId.length()==0) throw new Exception("TransactionItemSyncService : transactionTypeId is null or empty");
                    if(itemTypeId.length()==0)        throw new Exception("TransactionItemSyncService : itemTypeId is null or empty");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
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

        return items;
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
    private Properties getPropertyFile(String sFilename){
        FileInputStream iniIs = null;
        Properties iniProps = new Properties();

        // create ini file if they do not exist
        try{
          iniIs = new FileInputStream(sFilename);
          iniProps.load(iniIs);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            if(iniIs!=null){
                try{ iniIs.close(); }
                catch(Exception e){}
            }
        }

        return iniProps;
    }

    //--- STORE ITEM ------------------------------------------------------------------------------
    private void storeItem(String itemType, String itemId, String defaultValue, String modifier, int priority){
        try{
            query = "INSERT INTO TransactionItems(transactionTypeId,itemTypeId,defaultValue,modifier,priority,updatetime)"+
                    " VALUES (?,?,?,?,?,?)";
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            psInsertItem = oc_conn.prepareStatement(query);

            psInsertItem.setString(1,itemType);
            psInsertItem.setString(2,itemId);
            psInsertItem.setString(3,defaultValue);
            psInsertItem.setString(4,modifier);
            psInsertItem.setInt(5,priority);
            psInsertItem.setTimestamp(6,nowTimestamp); // same updatetime for all items
            psInsertItem.execute();
            psInsertItem.close();
            oc_conn.close();
        }
        catch(Exception e){
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