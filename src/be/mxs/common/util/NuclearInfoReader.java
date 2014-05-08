package be.mxs.common.util;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Logger;
import be.mxs.common.util.system.ScreenHelper;

import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

/**
 * User: stijn smets
 * Date: 31-okt-2005
 */

//=================================================================================================
// PUBLIC METHODS :
//  * void readFlatFiles()
//  * boolean readFlatFile(String flatFilename)
//  * String getStatus()
//=================================================================================================
public class NuclearInfoReader {

    // declarations
    private StringBuffer sbQuery;
    private Connection conn;
    private PreparedStatement psGetPersonIds, psGetDosiTranid;
    private SimpleDateFormat dateFormat;

    // transaction stuff
    private String itemType;
    private Collection itemVOs;
    private ItemVO itemVO;
    private UserVO userVO;
    private Integer tranId;
    private TransactionVO transaction;

    // file objects
    private String expositionDirPath;
    private FileInputStream fileInputStream;
    private InputStreamReader inputStreamReader;
    private LineNumberReader lineNumberReader;

    // finals
    private final int BADGEID_LEN   = 12;
    private final int EXPOMONTH_LEN = 12;
    //private final int EXPOVALUE_LEN = 17;

    private final String PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public NuclearInfoReader() throws Exception {
        if(Debug.enabled) Debug.println("\n================== NuclearInfoReader ==================");

        dateFormat = ScreenHelper.stdDateFormat;

        try{
            conn = MedwanQuery.getInstance().getOpenclinicConnection();

            // get persons who were exposed (during a least one moment of their visit to the site)
            // to the radiation value in the flatfile.
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT BadgePersonId FROM Badges")
                   .append(" WHERE BadgeId = ?")
                   .append("  AND BadgeCentre = ?")
                   .append("  AND (SUBSTRING("+ MedwanQuery.getInstance().convert("varchar(255)","BadgeBegin")+",0,4) = ? OR SUBSTRING("+ MedwanQuery.getInstance().convert("varchar(255)","BadgeEnd")+",0,4) = ?)")
                   .append("  AND (")
                   .append("   (BadgeBegin < ? AND BadgeEnd >= ?) OR ")
                   .append("   (BadgeBegin >= ? OR BadgeEnd < ?)")
                   .append("  )")
                   .append(" GROUP BY BadgePersonId");
            psGetPersonIds = conn.prepareStatement(sbQuery.toString());

            // get the dosimetry of the specified person and the specified year
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT tr.transactionId, tr.serverId FROM Transactions tr, Healthrecord hr, Items i")
                   .append(" WHERE hr.personId = ?")
                   .append("  AND tr.healthRecordId = hr.healthRecordId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_DOSIMETRY'")
                   .append("  AND tr.transactionId = i.transactionId")
                   .append("  AND i.type = '").append(PREFIX).append("ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR'")
                   .append("  AND i.value = ?");
            psGetDosiTranid = conn.prepareStatement(sbQuery.toString());
            conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    /*
    //--- READ FLATFILES --------------------------------------------------------------------------
    // Apply readFlatFile function on all files in the specified directory.
    //---------------------------------------------------------------------------------------------
    public void readFlatFiles() throws Exception {
        // path where exposition files will be read from
        expositionDirPath = Helper.checkString(MedwanQuery.getInstance().getConfigString("nuclearExpositionDir"));
        if(expositionDirPath.length() == 0){
            throw new Exception("ERROR : config string \"nuclearExpositionDir\" is empty or does not exist.");
        }

        String inFilename;

        // get files in inputDir
        File inputDir = new File(expositionDirPath);
        if(inputDir.exists()){
            File[] inputFiles = inputDir.listFiles();
            fileCounter = 0;

            for(int i=0; i<inputFiles.length; i++){
                if(inputFiles[i].isFile()){
                    inFilename = inputFiles[i].getName();
                    if(inFilename.indexOf(".log") < 0){
                        if(readFlatFile(expositionDirPath,inFilename)){
                            fileCounter++;
                        }
                    }
                }
            }

            if(fileCounter == 0){
                if(Debug.enabled) Debug.println("\nNo files in input dir '"+expositionDirPath+"'.\n");
            }
            else{
                if(Debug.enabled) Debug.println("Processed "+fileCounter+" files in '"+expositionDirPath+"'.\n");
            }
        }
        else{
            if(Debug.enabled) Debug.println("Input dir '"+expositionDirPath+"' does not exist.\n");
        }
    }
    */

    //--- READ FLATFILE ---------------------------------------------------------------------------
    // badgeID, expositionMonth, expositionValue
    //---------------------------------------------------------------------------------------------
    public int readFlatFile(String flatFilename, int expoYear) throws Exception {
        // path where exposition files will be read from
        expositionDirPath = ScreenHelper.checkString(MedwanQuery.getInstance().getConfigString("nuclearExpositionDir"));
        if(expositionDirPath.length() == 0){
            throw new Exception("ERROR : config string 'nuclearExpositionDir' is empty or does not exist.");
        }

        return readFlatFile(expositionDirPath,flatFilename,expoYear);
    }

    //#############################################################################################
    //#################################### PRIVATE FUNCTIONS ######################################
    //#############################################################################################

    //--- READ FLATFILE ---------------------------------------------------------------------------
    private int readFlatFile(String expositionDirPath, String flatFilename, int expoYear){
        String badgeID, expoValue, line = "";
        int lineCounter = 0, idx = 0, expoMonth = 0;

        try{
            // set up a logger
            Logger.setOutputFile(expositionDirPath+"/"+flatFilename.substring(0,flatFilename.length()-4)+".log");
            Logger.setAppend(false);

            // exposite -> expoSiteId
            String expoSite = flatFilename.substring(0,3);
            int expoSiteId = 0;
                 if(expoSite.equalsIgnoreCase("DOE")) expoSiteId = 1;
            else if(expoSite.equalsIgnoreCase("TIH")) expoSiteId = 2;
            else if(expoSite.equalsIgnoreCase("IRE")) expoSiteId = 3;
            else if(expoSite.equalsIgnoreCase("OTH")) expoSiteId = 4;

            openInputFile(expositionDirPath+"/"+flatFilename);

            // run thru lines in file
            while((line = lineNumberReader.readLine()) != null){
                lineCounter++;
                idx = 0;

                if(line.length() > 0){
                    badgeID = line.substring(idx,idx+BADGEID_LEN).trim();     idx+=BADGEID_LEN;
                    expoMonth = Integer.parseInt(line.substring(idx,idx+BADGEID_LEN).trim());   idx+=EXPOMONTH_LEN+5; // 5 = redundant chars
                    expoValue = line.substring(idx).trim();

                    // date range in which the expositions took place (1 whole month)
                    Calendar expoDate = new GregorianCalendar(expoYear,expoMonth-1,1,0,0,0);
                    Date expoDateBegin = expoDate.getTime();
                    expoDate.add(Calendar.MONTH,1);
                    Date expoDateEnd = expoDate.getTime();

                    if(Debug.enabled){
                        Debug.println("\n###### ["+badgeID+", "+expoMonth+", "+expoValue+"] ######");
                        Debug.println("expoDateBegin : "+dateFormat.format(expoDateBegin));
                        Debug.println("expoDateEnd   : "+dateFormat.format(expoDateEnd)+"\n");
                    }

                    saveExpositionInDB(badgeID,expoSiteId,expoMonth,expoYear,expoDateBegin,expoDateEnd,expoValue);
                }
                else{
                    Logger.log("Empty line in flatfile '"+flatFilename+"'.",Logger.ERROR_LEVEL_INFO,""+lineCounter);
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            Logger.close();

            try{
                closeInputFile();
            }
            catch(IOException ioe){
                ioe.printStackTrace();
            }
        }

        if(Debug.enabled) Debug.println("\n=======================================================");
        if(Debug.enabled) Debug.println("flat file '"+flatFilename+"' read.\n\n");

        return lineCounter;
    }

    //--- SAVE EXPOSITION IN DB --------------------------------------------------------------------
    // Exposition file tells you on what site, in which month and how much radiation was emitted.
    // This function adds that amount of radiation to all employees that were at the site in that month.
    //----------------------------------------------------------------------------------------------
    private void saveExpositionInDB(String badgeID, int expoSiteId, int expoMonth, int expoYear,
                                    Date expoDateBegin, Date expoDateEnd, String expoValue)
            throws SQLException {

        // do not process exposition is its value is 'M'.
        if(expoValue.equalsIgnoreCase("M")){
            Logger.log("Skipped exposition because value is 'M'. ("+badgeID+","+expoMonth+","+expoValue+")",Logger.ERROR_LEVEL_INFO);
        }
        else{
            try{
                // check if value is an integer, otherwise, skip
                Integer.parseInt(expoValue);

                // find badgePersonId exposed to this exposition
                psGetPersonIds.setString(1,badgeID);
                psGetPersonIds.setInt(2,expoSiteId);
                psGetPersonIds.setString(3,expoYear+"");
                psGetPersonIds.setString(4,expoYear+"");
                psGetPersonIds.setTimestamp(5,new Timestamp(expoDateBegin.getTime()));
                psGetPersonIds.setTimestamp(6,new Timestamp(expoDateEnd.getTime()));
                psGetPersonIds.setTimestamp(7,new Timestamp(expoDateBegin.getTime()));
                psGetPersonIds.setTimestamp(8,new Timestamp(expoDateEnd.getTime()));
                ResultSet rs = psGetPersonIds.executeQuery();

                // convert to site-id to site-name
                String expoSite = "";
                     if(expoSiteId==1) expoSite = "DOEL";
                else if(expoSiteId==2) expoSite = "TIHANGE";
                else if(expoSiteId==3) expoSite = "IRE";
                else if(expoSiteId==4) expoSite = "OTHER";

                // at least one badge found, so add the expoValue to table Items.
                int personCount = 0, personid;
                while(rs.next()){
                    // get personid belonging to the found badge
                    personid = rs.getInt("BadgePersonId");

                    // create 3 items to be stored
                    itemVOs = new Vector();

                    // expoValue
                    itemType = PREFIX+"ITEM_TYPE_DOSIMETRY_"+expoSite+"_GLOBAL_MONTH"+expoMonth;
                    itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),itemType,expoValue,new Date(),null);
                    itemVOs.add(itemVO);

                    // badgeID
                    itemType = PREFIX+"ITEM_TYPE_DOSIMETRY_BADGEID_"+expoSite;
                    itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),itemType,badgeID,new Date(),null);
                    itemVOs.add(itemVO);

                    // expoYear
                    itemType = PREFIX+"ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR";
                    itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),itemType,expoYear+"",new Date(),null);
                    itemVOs.add(itemVO);

                    storeTransaction(personid,itemVOs,expoSite,expoYear);
                    personCount++;
                }

                rs.close();
                psGetPersonIds.close();
                // rs empty, no badge found
                if(personCount == 0){
                    Logger.log("No Badges with BadgeId ("+badgeID+") for site ("+expoSite+","+expoSiteId+") found in year ("+expoYear+").",Logger.ERROR_LEVEL_INFO);
                }
            }
            // expoValue is no integer
            catch(NumberFormatException e){
                Logger.log("Exposition value is no Integer. ("+badgeID+","+expoMonth+","+expoValue+")",Logger.ERROR_LEVEL_ERROR);
                if(Debug.enabled) Debug.println("ERROR : Exposition value is no Integer. ("+badgeID+","+expoMonth+","+expoValue+")");
            }
        }
    }

    //--- STORE TRANSACTION -----------------------------------------------------------------------
    private void storeTransaction(int personid, Collection itemsToStore, String expoSite, int expoYear) throws SQLException {
        int itemsAddedToTransaction = 0;

        // get transactionId
        psGetDosiTranid.setInt(1,personid);
        psGetDosiTranid.setInt(2,expoYear);
        ResultSet rs = psGetDosiTranid.executeQuery();

        // 0 or 1 transaction per year per person.
        if(rs.next()){
            //#####################################################################################
            //### TRANSACTION FOUND ###############################################################
            //#####################################################################################

            // get transaction from DB
            int tranid = rs.getInt("transactionId");
            int serverid = rs.getInt("serverId");

            transaction = MedwanQuery.getInstance().loadTransaction(serverid,tranid);
            Collection savedItems = transaction.getItems();
            rs.close();
            psGetDosiTranid.close();
            // if a collection of items yet exists, complete it (no doubles)
            if(savedItems!=null){
                // get storeBadgeItem
                ItemVO storeBadgeItem = null;
                Iterator storeItemIter = itemsToStore.iterator();
                while(storeItemIter.hasNext()){
                    storeBadgeItem = (ItemVO)storeItemIter.next();
                    if(storeBadgeItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_BADGEID_"+expoSite)){
                        break;
                    }
                }

                // check if a badgeItem and yearItem are allready saved
                // and if badgeItem contains badgeId
                ItemVO savedItem = null;
                boolean storeYearItemFoundInSavedItems = false;
                boolean storeBadgeItemFoundInSavedItems = false;
                boolean storeBadgeIdFoundInSavedBadgeItem = false;

                Iterator savedItemIter = savedItems.iterator();
                while(savedItemIter.hasNext()){
                    savedItem = (ItemVO)savedItemIter.next();

                    if(savedItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR")){
                        storeYearItemFoundInSavedItems = true;
                    }
                    else if(savedItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_BADGEID_"+expoSite)){
                        storeBadgeItemFoundInSavedItems = true;

                        // check if storeBadgeId occurs in savedBadgeIds
                        if(savedItem.getValue().indexOf(storeBadgeItem.getValue()) > -1){
                            storeBadgeIdFoundInSavedBadgeItem = true;
                        }
                    }

                    // quit if both items were found
                    if(storeYearItemFoundInSavedItems && storeBadgeItemFoundInSavedItems){
                        break;
                    }
                }

                if(storeBadgeIdFoundInSavedBadgeItem){
                    //*****************************************************************************
                    //**************************** BADGEID FOUND **********************************
                    //*****************************************************************************
                    // badgeid for site does exist; add only non-existing items

                    // run thru storeItems
                    ItemVO storeItem;
                    String itemType, storeMonth;
                    storeItemIter = itemsToStore.iterator();

                    while(storeItemIter.hasNext()){
                        storeItem = (ItemVO)storeItemIter.next();
                        itemType = storeItem.getType();

                        //*** YEAR-ITEM ***********************************************************
                        if(itemType.equals(PREFIX+"ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR")){
                            if(!storeYearItemFoundInSavedItems){
                                savedItems.add(storeItem);
                                transaction.setItems(savedItems);
                                itemsAddedToTransaction++;
                            }
                        }
                        //*** VALUE-ITEMS *********************************************************
                        else if(itemType.startsWith(PREFIX+"ITEM_TYPE_DOSIMETRY_"+expoSite+"_GLOBAL_MONTH")){
                            storeMonth = itemType.substring(itemType.length()-1);
                            savedItem = transaction.getItem(PREFIX+"ITEM_TYPE_DOSIMETRY_"+expoSite+"_GLOBAL_MONTH"+storeMonth);

                            if(savedItem==null){
                                // add monthItem from itemsToStore
                                savedItems.add(storeItem);
                                transaction.setItems(savedItems);
                                itemsAddedToTransaction++;
                            }
                            else{
                                // replace saved value with imported value
                                savedItem.setValue(storeItem.getValue());
                                transaction.setItems(savedItems);
                            }
                        }
                    }

                    transaction.setItems(savedItems);
                }
                else{
                    //*****************************************************************************
                    //************************** BADGEID NOT FOUND ********************************
                    //*****************************************************************************
                    // badgeid for site does NOT exist; add it and all new items (no doubles)

                    // run thre storeItems and decide what items should be added
                    ItemVO storeItem = null;
                    ItemVO savedBadgeItem;
                    String ids;

                    storeItemIter = itemsToStore.iterator();
                    while(storeItemIter.hasNext()){
                        storeItem = (ItemVO)storeItemIter.next();

                        //*** BADGE-ITEM **********************************************************
                        if(storeItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_BADGEID_"+expoSite)){
                            if(storeBadgeItemFoundInSavedItems){
                                // append storeBadgeId to savedBadgeItem-value
                                savedItemIter = savedItems.iterator();
                                while(savedItemIter.hasNext()){
                                    savedBadgeItem = (ItemVO)savedItemIter.next();

                                    if(savedBadgeItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_BADGEID_"+expoSite)){
                                        ids = savedBadgeItem.getValue()+","+storeItem.getValue();
                                        savedBadgeItem.setValue(ids);
                                        transaction.setItems(savedItems);
                                    }
                                }
                            }
                            else{
                                // add new badgeId-item
                                savedItems.add(storeItem);
                                transaction.setItems(savedItems);
                            }
                        }
                        //*** YEAR-ITEM ***********************************************************
                        else if(storeItem.getType().equals(PREFIX+"ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR")){
                            if(!storeYearItemFoundInSavedItems){
                                savedItems.add(storeItem);
                                transaction.setItems(savedItems);
                            }
                        }
                        //*** VALUE-ITEMS *********************************************************
                        else{
                            // add store items to saved items (no doubles)
                            String storeMonth = storeItem.getType().substring(storeItem.getType().length()-1);
                            savedItem = transaction.getItem(PREFIX+"ITEM_TYPE_DOSIMETRY_"+expoSite+"_GLOBAL_MONTH"+storeMonth);

                            if(savedItem==null){
                                savedItems.add(storeItem);
                                transaction.setItems(savedItems);
                                itemsAddedToTransaction++;
                            }
                            else{
                                // replace saved value with imported value
                                savedItem.setValue(storeItem.getValue());
                                transaction.setItems(savedItems);
                            }
                        }
                    }
                }
            }
            else{
                // no saved items found, so simply set the new items
                transaction.setItems(itemsToStore);
            }

            // update existing transaction
            //if(itemsAddedToTransaction > 0){
                MedwanQuery.getInstance().updateTransaction(personid,transaction);
            //}
        }
        else{
            //#####################################################################################
            //### NO TRANSACTION FOUND ############################################################
            //#####################################################################################
            rs.close();
            psGetDosiTranid.close();
            // create NEW Transaction
            userVO = MedwanQuery.getInstance().getUser("9"); // welke user ???????????
            tranId = new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier());
            transaction = new TransactionVO(tranId,PREFIX+"TRANSACTION_TYPE_DOSIMETRY",new Date(),new Date(),IConstants.TRANSACTION_STATUS_CLOSED,userVO,null);

            // add context-item
            itemType = PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT";
            itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),itemType,"context.context.periodic-examinations",new Date(),null);
            itemsToStore.add(itemVO);

            // add department-item
            itemType = PREFIX+"ITEM_TYPE_CONTEXT_DEPARTMENT";
            itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),itemType,"context.department.occup",new Date(),null);
            itemsToStore.add(itemVO);

            transaction.setItems(itemsToStore);

            // update transaction
            MedwanQuery.getInstance().updateTransaction(personid,transaction);

            // TODO : ADD transaction also to session, otherwise you must relogin to see the new (imported) transaction.
            // via de link "arbeidsgeneeskunde" (=occupationalmedicine/ShowWelcomePageAction.do) gaat het wel
            // something like below, but how to get the request over here..
            /*
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            sessionContainerWO.setCurrentTransactionVO(transaction);
            HttpSession session = request.getSession();
            session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER",sessionContainerWO);
            */
        }
    }

    //--- OPENINPUTFILE ---------------------------------------------------------------------------
    private void openInputFile(String filename) throws FileNotFoundException {
        fileInputStream   = new FileInputStream(filename);
        inputStreamReader = new InputStreamReader(fileInputStream);
        lineNumberReader  = new LineNumberReader(inputStreamReader);
    }

    //--- CLOSEINPUTFILE --------------------------------------------------------------------------
    private void closeInputFile() throws IOException {
        lineNumberReader.close();
        inputStreamReader.close();
        fileInputStream.close();
    }

}
