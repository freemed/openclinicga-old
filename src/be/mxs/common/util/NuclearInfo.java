package be.mxs.common.util;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Vector;
import java.util.Iterator;
import java.util.Hashtable;
import java.util.Enumeration;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 31-okt-2005
 */

//==================================================================================================
// PUBLIC METHODS :
//   * NuclearInfo(String badgePersonId, Date infoBegin, Date infoEnd)
//   * double getSumOfAllPreviousEffectiveDoses()
//   * ExpositionInfo getData(int month, String site)
//==================================================================================================
public class NuclearInfo {

    // declarations
    private String personId;
    private ExpositionInfo expoInfo;
    private StringBuffer sbQuery;
    private Connection conn;
    private PreparedStatement psGetItemValue, psGetDosiTranid, psGetIETranid, psGetIEItems,
                              psGetIEDoses, psGetYearOfFirstDosi, psGetYearOfFirstIE;

    // date stuff
    private SimpleDateFormat dateFormat;
    public int beginMonth, endMonth;
    private Calendar beginCal, endCal;
    private Vector applicableMonths;

    private final String PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public NuclearInfo(String badgePersonId, Date infoBegin, Date infoEnd) throws Exception {
        this.personId = badgePersonId;

        if(Debug.enabled) Debug.println("=== NuclearInfo =========================================================================");///////
        if(Debug.enabled) Debug.println("personId  : "+personId);

        //*** month stuff **************************************************************************
        dateFormat = ScreenHelper.stdDateFormat;

        // beginMonth
        beginCal = new GregorianCalendar();
        beginCal.setTime(infoBegin);
        beginMonth = beginCal.get(Calendar.MONTH)+1;

        // endMonth
        endCal = new GregorianCalendar();
        endCal.setTime(infoEnd);
        endMonth = endCal.get(Calendar.MONTH)+1;

        // beginMonth < endMonth ?
        if(endCal.before(beginCal)){
            throw new Exception("ERROR : infoEnd < infoBegin ("+dateFormat.format(infoEnd)+" < "+dateFormat.format(infoBegin)+")");
        }

        // check if dates belong to the same year
        if(beginCal.get(Calendar.YEAR) != endCal.get(Calendar.YEAR)){
            throw new Exception("ERROR : infoBegin and infoEnd not in same year. ("+dateFormat.format(infoBegin)+", "+dateFormat.format(infoEnd)+")");
        }

        // a list of months in which the data in this class are applicable.
        applicableMonths = new Vector();
        for(int i=beginMonth; i<=endMonth; i++){
            applicableMonths.add(new Integer(i));
        }

        //*** DB-stuff *****************************************************************************
        try{
            conn = MedwanQuery.getInstance().getOpenclinicConnection();

            // get the value of an item of the specified type, belonging to the specified dosimetry
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT i."+MedwanQuery.getInstance().getConfigString("valueColumn")+" FROM Transactions tr, Items i")
                   .append(" WHERE tr.transactionId = ?")
                   .append("  AND tr.transactionId = i.transactionId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_DOSIMETRY'")
                   .append("  AND i.type = ?");
            psGetItemValue = conn.prepareStatement(sbQuery.toString());

            // get the dose of the internal exposition of the specified person in the specified period
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT i."+MedwanQuery.getInstance().getConfigString("valueColumn")+"  FROM Transactions tr, Healthrecord hr, Items i")
                   .append(" WHERE hr.personid = ?")
                   .append("  AND tr.updateTime BETWEEN ? AND ?")
                   .append("  AND tr.healthRecordId = hr.healthRecordId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_INTERNAL_EXPOSITION'")
                   .append("  AND tr.transactionId = i.transactionId")
                   .append("  AND i.type = '").append(PREFIX).append("ITEM_TYPE_INTERNAL_EXPOSITION_DOSE'");
            psGetIEDoses = conn.prepareStatement(sbQuery.toString());

            // get the dosimetry of the specified person and the specified year
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT tr.transactionId, tr.serverId FROM Transactions tr, Healthrecord hr, Items i")
                   .append(" WHERE hr.personId = ?")
                   .append("  AND tr.healthRecordId = hr.healthRecordId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_DOSIMETRY'") // dosi
                   .append("  AND tr.transactionId = i.transactionId")
                   .append("  AND i.type = '").append(PREFIX).append("ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR'")
                   .append("  AND i.value = ?");
            psGetDosiTranid = conn.prepareStatement(sbQuery.toString());

            // get all items of the specified internal exposition
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT type,"+MedwanQuery.getInstance().getConfigString("valueColumn")+"  FROM Items")
                   .append(" WHERE transactionId = ?")
                   .append("  AND type LIKE '").append(PREFIX).append("ITEM_TYPE_INTERNAL_EXPOSITION_%'");
            psGetIEItems = conn.prepareStatement(sbQuery.toString());

            // get year of first Dosimetry
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT i."+MedwanQuery.getInstance().getConfigString("valueColumn")+"  FROM Transactions tr, Healthrecord hr, Items i")
                   .append(" WHERE hr.personId = ?")
                   .append("  AND tr.healthRecordId = hr.healthRecordId")
                   .append("  AND tr.transactionId = i.transactionId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_DOSIMETRY'")
                   .append("  AND i.type = '").append(PREFIX).append("ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR'")
                   .append(" ORDER BY 1 ASC");
            psGetYearOfFirstDosi = conn.prepareStatement(sbQuery.toString());

            // get year of first Internal Expo
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT tr.creationDate FROM Transactions tr, Healthrecord hr")
                   .append(" WHERE hr.personId = ?")
                   .append("  AND tr.healthRecordId = hr.healthRecordId")
                   .append("  AND tr.transactionType = '").append(PREFIX).append("TRANSACTION_TYPE_INTERNAL_EXPOSITION'")
                   .append(" ORDER BY 1 ASC");
            psGetYearOfFirstIE = conn.prepareStatement(sbQuery.toString());

            /*
            sbQuery = new StringBuffer();
            sbQuery.append("SELECT value FROM Items")
                   .append(" WHERE transactionId = ?")
                   .append("  AND type LIKE ?");
            psGetIEItemValue = conn.prepareStatement(sbQuery.toString());
            */
            conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- GET SUM OF ALL PREVIOUS EFFECTIVE DOSES --------------------------------------------------
    // Total of all internal and external exposition doses.
    // *** OF ALL _PREVIOUS_ YEARS *** (excluding the current year)
    //----------------------------------------------------------------------------------------------
    public double getSumOfAllPreviousEffectiveDoses(){
        int firstDosiYear = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()));
        int firstIEYear = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()));
        double dose = -1;

        try{
            firstDosiYear = getYearOfFirstDosimetry();
            firstIEYear   = getYearOfFirstInternalExposition();
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // if none of both first-date found, the dose is 0
        if(firstDosiYear > 0 && firstIEYear > 0){
            dose = this.getSumOfAllPreviousEffectiveDoses(Math.min(firstDosiYear,firstIEYear));
        }
        else{
            if(firstDosiYear > 0){
                dose = this.getSumOfAllPreviousEffectiveDoses(firstDosiYear);
            }
            else if(firstIEYear > 0){
                dose = this.getSumOfAllPreviousEffectiveDoses(firstIEYear);
            }
        }

        return dose;
    }

    public double getSumOfAllPreviousEffectiveDoses(int sinceYear){
        double totalDose = -1, dose;
        int untilYear = beginCal.get(Calendar.YEAR)-1;

        // run thru all years since the first contamination
        for(int year=sinceYear; year<=untilYear; year++){
            if(Debug.enabled) Debug.println("specific year : "+year);/////////////////
            try{
                // get the total EXternal dose of a specific year
                dose = calculateTotalExternalDose(year);
                if(dose > -1){
                    if(totalDose <= -1) totalDose = 0;
                    totalDose+= dose;
                }

                // get the total INternal dose of a specific year
                dose = calculateTotalInternalDose(year);
                if(dose > -1){
                    if(totalDose <= -1) totalDose = 0;
                    totalDose+= dose;
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        if(Debug.enabled) Debug.println("NuclearInfo.getSumOfAllPreviousEffectiveDoses : "+totalDose);/////////////////////////////////////
        return totalDose;
    }

    //--- GET DATA ---------------------------------------------------------------------------------
    // Get DTO containing all exposition doses in the specified month at the specified site.
    // site = (ALL | DOEL | TIHANGE | IRE | OTHER)
    //----------------------------------------------------------------------------------------------
    public ExpositionInfo getData(int month, String site) throws Exception {
        site = site.toUpperCase();

        // check if the requested month is valid.
        if(applicableMonths.contains(new Integer(month))){
            // check if the requested site is valid.
            if(site.equals("ALL") || site.equals("DOEL") || site.equals("TIHANGE") ||
               site.equals("IRE") || site.equals("OTHER")){

                expoInfo = new ExpositionInfo(personId,month,site);

                //*** EXTERNAL EXPOSITION **********************************************************
                // get transactionId of the only dosimetry
                psGetDosiTranid.setString(1,this.personId);
                psGetDosiTranid.setInt(2,beginCal.get(Calendar.YEAR));
                ResultSet rs = psGetDosiTranid.executeQuery();
                int dosiTranid = -1;

                if(rs.next()){
                    dosiTranid = rs.getInt(1);

                    double globalDose = calculateExternalExpositionDose(dosiTranid,"GLOBAL",month,site);
                    expoInfo.setExternalGlobalExpositionDose(globalDose);

                    double partialDose = calculateExternalExpositionDose(dosiTranid,"PARTIAL",month,site);
                    expoInfo.setExternalPartialExpositionDose(partialDose);
                }
                else{
                    if(Debug.enabled) Debug.println("NuclearInfo.getData : no Dosimetry found for person ("+personId+") in year ("+beginCal.get(Calendar.YEAR)+")");
                }
                rs.close();
                psGetDosiTranid.close();
                
                //*** INTERNAL EXPOSITION **********************************************************
                String siteIds = "0";
                if(site.equals("ALL")) siteIds = "1,2,3,4";
                else{
                    // convert to site-name to site-id
                         if(site.equals("DOEL"))    siteIds = "1";
                    else if(site.equals("TIHANGE")) siteIds = "2";
                    else if(site.equals("IRE"))     siteIds = "3";
                    else if(site.equals("OTHER"))   siteIds = "4";
                }

                // calculate 2 dates that represent begin and end of the specified month
                Calendar monthCal = new GregorianCalendar(beginCal.get(Calendar.YEAR),month-1,1,0,0,0);
                Date monthBegin = monthCal.getTime();
                monthCal.add(Calendar.MONTH,1);
                Date monthEnd = monthCal.getTime();

                // get transactionid of internal expositions
                sbQuery = new StringBuffer();
                sbQuery.append("SELECT tr.transactionId FROM transactions tr, healthrecord hr, Items i")
                       .append(" WHERE hr.personid = ?")
                       .append("  AND tr.updateTime BETWEEN ? AND ?")
                       .append("  AND tr.healthrecordid = hr.healthRecordId")
                       .append("  AND tr.transactiontype = '").append(PREFIX).append("TRANSACTION_TYPE_INTERNAL_EXPOSITION'")
                       .append("  AND tr.transactionid = i.transactionId")
                       .append("  AND i.type = '").append(PREFIX).append("ITEM_TYPE_INTERNAL_EXPOSITION_PLACE'")
                       .append("  AND i.value IN (").append(siteIds).append(")");
                psGetIETranid = conn.prepareStatement(sbQuery.toString());

                // set values
                psGetIETranid.setString(1,this.personId);
                psGetIETranid.setTimestamp(2,new Timestamp(monthBegin.getTime()));
                psGetIETranid.setTimestamp(3,new Timestamp(monthEnd.getTime()));
                rs = psGetIETranid.executeQuery();

                // collect all transaction ids
                Vector tranids = new Vector();
                while(rs.next()){
                    tranids.add(new Integer(rs.getString(1)));
                }
                rs.close();
                psGetIETranid.close();
                if(tranids.size() > 0){
                    Hashtable ieItems;
                    int tranid;

                    for(int i=0; i<tranids.size(); i++){
                        tranid = ((Integer)(tranids.get(i))).intValue();
                        ieItems = getInternalExpositionItems(tranid);
                        setInternalExpositionItems(ieItems);

                        //setInternalExpositionOrgan(tranid);
                        //setInternalExpositionContaminant(tranid);
                        //setInternalExpositionDose(tranid);
                        //setInternalExpositionRemark(tranid);
                    }
                }
                else{
                    if(Debug.enabled) Debug.println("NuclearInfo.getData : no Internal Expositions found for person ("+personId+") in month/year ("+month+"/"+monthCal.get(Calendar.YEAR)+")");
                }

                return expoInfo;
            }
            else{
                throw new Exception("NuclearInfo.getData : parameter 'site' ("+site+") must be (ALL | DOEL | TIHANGE | IRE | OTHER)");
            }
        }
        else{
            throw new Exception("NuclearInfo.getData : parameter 'month' ("+month+") not in valid range. ("+beginMonth+" -> "+endMonth+")");
        }
    }

    //--- GET YEAR OF FIRST DOSIMETRY --------------------------------------------------------------
    public int getYearOfFirstDosimetry() throws Exception {
        int year = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()));

        psGetYearOfFirstDosi.setString(1,this.personId);
        ResultSet rs = psGetYearOfFirstDosi.executeQuery();

        // ITEM_TYPE_DOSIMETRY_REGISTRATIONYEAR
        if(rs.next()){
            year = Integer.parseInt(rs.getString(1));
        }
        
        rs.close();
        psGetYearOfFirstDosi.close();
        if(Debug.enabled) Debug.println("NuclearInfo.getYearOfFirstDosimetry : "+year);///////////////////////
        return year;
    }

    //--- GET YEAR OF FIRST INTERNAL EXPOSITION ----------------------------------------------------
    public int getYearOfFirstInternalExposition() throws Exception {
        int year = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()));

        psGetYearOfFirstIE.setString(1,this.personId);
        ResultSet rs = psGetYearOfFirstIE.executeQuery();

        // transaction.creationDate, TRANSACTION_TYPE_INTERNAL_EXPOSITION
        if(rs.next()){
            GregorianCalendar cal = new GregorianCalendar();
            cal.setTime(rs.getDate(1));
            year = cal.get(Calendar.YEAR);
        }

        rs.close();
        psGetYearOfFirstIE.close();
        if(Debug.enabled) Debug.println("NuclearInfo.getYearOfFirstInternalExposition : "+year);///////////////////////
        return year;
    }


    //##############################################################################################
    //#################################### PRIVATE FUNCTIONS #######################################
    //##############################################################################################

    //--- GET INTERNAL EXPOSITION ITEMS ------------------------------------------------------------
    // get all items of the internal exposition of the specified person, month and place.
    //----------------------------------------------------------------------------------------------
    private Hashtable getInternalExpositionItems(int tranid) throws SQLException {
        Hashtable items = new Hashtable();

        // get items of specified exposition
        psGetIEItems.setInt(1,tranid);
        ResultSet rs = psGetIEItems.executeQuery();

        while(rs.next()){
            items.put(rs.getString("type"),rs.getString("value"));
        }

        rs.close();
        psGetIEItems.close();
        return items;
    }

    //--- CALCULATE EXTERNAL EXPOSITION DOSE -------------------------------------------------------
    private double calculateExternalExpositionDose(int tranid, String expoType, int expoMonth, String expoSite) throws SQLException {
        double totalDose = -1, dose;

        // ALL sites : Doel, Tihange, IRE, Other
        if(expoSite.equals("ALL")){
            dose = getDose(tranid,PREFIX+"ITEM_TYPE_DOSIMETRY_DOEL_"+expoType+"_MONTH"+expoMonth);
            if(dose > -1){
                if(totalDose <= -1) totalDose = 0;
                totalDose+= dose;
            }

            dose = getDose(tranid,PREFIX+"ITEM_TYPE_DOSIMETRY_TIHANGE_"+expoType+"_MONTH"+expoMonth);
            if(dose > -1){
                if(totalDose <= -1) totalDose = 0;
                totalDose+= dose;
            }

            dose = getDose(tranid,PREFIX+"ITEM_TYPE_DOSIMETRY_IRE_"+expoType+"_MONTH"+expoMonth);
            if(dose > -1){
                if(totalDose <= -1) totalDose = 0;
                totalDose+= dose;
            }

            dose = getDose(tranid,PREFIX+"ITEM_TYPE_DOSIMETRY_OTHER_"+expoType+"_MONTH"+expoMonth);
            if(dose > -1){
                if(totalDose <= -1) totalDose = 0;
                totalDose+= dose;
            }
        }
        // only the specified site
        else{
            dose = getDose(tranid,PREFIX+"ITEM_TYPE_DOSIMETRY_"+expoSite+"_"+expoType+"_MONTH"+expoMonth);
            if(dose > -1){
                if(totalDose <= -1) totalDose = 0;
                totalDose = dose;
            }
        }

        return totalDose;
    }

    //--- SET INTERNAL EXPOSITION ITEMS ------------------------------------------------------------
    private void setInternalExpositionItems(Hashtable items){
        String itemType, itemValue;

        Enumeration keyEnum = items.keys();
        while(keyEnum.hasMoreElements()){
            itemType = (String)keyEnum.nextElement();
            itemValue = (String)items.get(itemType);

            if(itemType.equals(PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_ORGAN")){
                expoInfo.addInternalExpositionOrgan(itemValue);
            }
            else if(itemType.equals(PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_CONTAMINANT")){
                expoInfo.addInternalExpositionContaminant(itemValue);
            }
            else if(itemType.equals(PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_DOSE")){
                expoInfo.addInternalExpositionDose(itemValue);
            }
            else if(itemType.equals(PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_CONCLUSIONS")){
                expoInfo.addInternalExpositionRemark(itemValue);
            }
        }
    }

    /*
    //--- SET INTERNAL EXPOSITION ORGAN ------------------------------------------------------------
    private void setInternalExpositionOrgan(int tranid) throws SQLException {
        psGetIEItemValue.setInt(1,tranid);
        psGetIEItemValue.setString(2,PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_ORGAN");
        ResultSet rs = psGetIEItemValue.executeQuery();

        if(rs.next()){
            expoInfo.addInternalExpositionOrgan(rs.getString("value"));
        }

        rs.close();
    }

    //--- SET INTERNAL EXPOSITION CONTAMINANT ------------------------------------------------------
    private void setInternalExpositionContaminant(int tranid) throws SQLException {
        psGetIEItemValue.setInt(1,tranid);
        psGetIEItemValue.setString(2,PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_CONTAMINANT");
        ResultSet rs = psGetIEItemValue.executeQuery();

        if(rs.next()){
            expoInfo.addInternalExpositionContaminant(rs.getString("value"));
        }

        rs.close();
    }

    //--- SET INTERNAL EXPOSITION DOSE -------------------------------------------------------------
    private void setInternalExpositionDose(int tranid) throws SQLException {
        psGetIEItemValue.setInt(1,tranid);
        psGetIEItemValue.setString(2,PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_DOSE");
        ResultSet rs = psGetIEItemValue.executeQuery();

        if(rs.next()){
            expoInfo.addInternalExpositionDose(rs.getString("value"));
        }

        rs.close();
    }

    //--- SET INTERNAL EXPOSITION REMARK -----------------------------------------------------------
    private void setInternalExpositionRemark(int tranid) throws SQLException {
        psGetIEItemValue.setInt(1,tranid);
        psGetIEItemValue.setString(2,PREFIX+"ITEM_TYPE_INTERNAL_EXPOSITION_CONCLUSIONS");
        ResultSet rs = psGetIEItemValue.executeQuery();

        if(rs.next()){
            expoInfo.addInternalExpositionRemark(rs.getString("value"));
        }

        rs.close();
    }
    */

    //--- CALCULATE TOTAL EXTERNAL DOSE ------------------------------------------------------------
    private double calculateTotalExternalDose(int year) {
        double totalExtDose = -1;
        double tempDose;

        try{
            // get transactionId of dosimetry
            psGetDosiTranid.setString(1,this.personId);
            psGetDosiTranid.setInt(2,year);
            ResultSet rs = psGetDosiTranid.executeQuery();
            int tranid = -1;

            if(rs.next()){
                tranid = rs.getInt(1);
                rs.close();

                tempDose = calculateTotalExternalGlobalExpositionDose(tranid,"ALL");
                if(tempDose > -1){
                    if(totalExtDose <= -1) totalExtDose = 0;
                    totalExtDose+= tempDose;
                }

                tempDose = calculateTotalExternalPartialExpositionDose(tranid,"ALL");
                if(tempDose > -1){
                    if(totalExtDose <= -1) totalExtDose = 0;
                    totalExtDose+= tempDose;
                }
            }
            rs.close();
            psGetDosiTranid.close();

        }
        catch(SQLException e){
            e.printStackTrace();
        }

        if(Debug.enabled) Debug.println("calculateTotalExternalDose : "+totalExtDose);////////////
        return totalExtDose;
    }

    //--- CALCULATE TOTAL EXTERNAL GLOBAL EXPOSITION DOSE ------------------------------------------
    private double calculateTotalExternalGlobalExpositionDose(int tranid, String site) throws SQLException {
        double globalDose = -1, dose;
        int month;

        Iterator iter = applicableMonths.iterator();
        while(iter.hasNext()){
            month = ((Integer)iter.next()).intValue();
            dose = calculateExternalExpositionDose(tranid,"GLOBAL",month,site);
            if(dose > -1){
                if(globalDose <= -1) globalDose = 0;
                globalDose+= dose;
            }
        }

        if(globalDose <= -1) globalDose = 0;

        if(Debug.enabled) Debug.println("calculateTotalExternalGlobalExpositionDose : "+globalDose);////////////
        return globalDose;
    }

    //--- CALCULATE TOTAL EXTERNAL PARTIAL EXPOSITION DOSE -----------------------------------------
    private double calculateTotalExternalPartialExpositionDose(int tranid, String site) throws SQLException {
        double partialDose = -1, dose;
        int month;

        Iterator iter = applicableMonths.iterator();
        while(iter.hasNext()){
            month = ((Integer)iter.next()).intValue();
            dose = calculateExternalExpositionDose(tranid,"PARTIAL",month,site);
            if(dose > -1){
                if(partialDose <= -1) partialDose = 0;
                partialDose+= dose;
            }
        }

        if(partialDose <= -1) partialDose = 0;

        if(Debug.enabled) Debug.println("calculateTotalExternalPartialExpositionDose : "+partialDose);////////////
        return partialDose;
    }

    //--- CALCULATE TOTAL INTERNAL DOSE ------------------------------------------------------------
    private int calculateTotalInternalDose(int year) {
        int totalIntDose = -1, dose;

        Calendar monthCal;
        Date monthBegin, monthEnd;

        try{
            Iterator iter = applicableMonths.iterator();
            while(iter.hasNext()){
                int month = ((Integer)iter.next()).intValue();

                // calculate 2 dates that represent begin and end of the specified month
                monthCal = new GregorianCalendar(year,month-1,1,0,0,0);
                monthBegin = monthCal.getTime();
                monthCal.add(Calendar.MONTH,1);
                monthEnd = monthCal.getTime();

                // get transactionId of internal expositions
                psGetIEDoses.setString(1,this.personId);
                psGetIEDoses.setTimestamp(2,new Timestamp(monthBegin.getTime()));
                psGetIEDoses.setTimestamp(3,new Timestamp(monthEnd.getTime()));
                ResultSet rs = psGetIEDoses.executeQuery();

                while(rs.next()){
                    dose = rs.getInt(1);

                    if(dose > -1){
                        if(totalIntDose <= -1) totalIntDose = 0;
                        totalIntDose+= dose;
                    }
                }

                rs.close();
            }
        }
        catch(SQLException e){
            e.printStackTrace();
        }

        if(Debug.enabled) Debug.println("calculateTotalInternalDose : "+totalIntDose);////////////
        return totalIntDose;
    }

    //--- GET DOSE ---------------------------------------------------------------------------------
    private double getDose(int tranid, String itemType) throws SQLException {
        double dose = -1;

        psGetItemValue.setInt(1,tranid);
        psGetItemValue.setString(2,itemType);
        ResultSet rs = psGetItemValue.executeQuery();

        if(rs.next()){
            dose = rs.getDouble(1);
        }

        rs.close();
        psGetItemValue.close();
        
        if(Debug.enabled){
            if(dose > -1){
                Debug.println("getDose : "+itemType+" = "+dose);//////////////////
            }
        }

        return dose;
    }

}
