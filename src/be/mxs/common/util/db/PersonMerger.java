package be.mxs.common.util.db;

import be.mxs.common.util.system.Debug;
import java.sql.*;
import java.util.Vector;

/**
 * User: stijn smets
 * Date: 30-mei-2006
 */
public class PersonMerger {

    //--- VARIABLES ---
    ResultSet rs;
    Connection adminConn, occupConn;
    PreparedStatement ps;
    StringBuffer sbQuery;
    String sQuery;
    Vector adminHistoryMetaData;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PersonMerger(){
        sbQuery = new StringBuffer();
        adminConn = MedwanQuery.getInstance().getAdminConnection();
        occupConn = MedwanQuery.getInstance().getOpenclinicConnection();
        adminHistoryMetaData = new Vector();
        String type;

        // adminHistory metadata : put column types in a vector
        try{
            DatabaseMetaData databaseMetaData = adminConn.getMetaData();
            rs = databaseMetaData.getColumns(null,null,"AdminHistory",null); // all columns

            while(rs.next()){
                type = rs.getString("TYPE_NAME");

                if(type.equals("varchar") || type.equals("nvarchar") || type.equals("char")){
                    adminHistoryMetaData.add("String");
                }
                else if(type.equals("datetime") || type.equals("smalldatetime")){
                    adminHistoryMetaData.add("Date");
                }
                else{
                    adminHistoryMetaData.add(type);
                }
            }

            rs.close();
            occupConn.close();
            adminConn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- MERGE -----------------------------------------------------------------------------------
    public void merge(int keepPersonId, int removePersonId, boolean addPersonsToMergePersons) throws Exception {
        adminConn = MedwanQuery.getInstance().getAdminConnection();
        occupConn = MedwanQuery.getInstance().getOpenclinicConnection();
        int updates;

        if(Debug.enabled){
            Debug.println("\n=== PERSONMERGER ================================");
            Debug.println("Merging : keep person (id:"+keepPersonId+"), put person (id:"+removePersonId+") in history");
        }

        //*** STEP 1 : COPY SOURCE PERSON TO ADMINHISTORY *****************************************
        if(Debug.enabled) Debug.println("*** STEP 1 ***");

        // check if Admin exists in AdminHistory.
        ps = adminConn.prepareStatement("SELECT personid FROM AdminHistory WHERE personid = ?");
        ps.setInt(1,removePersonId);
        rs = ps.executeQuery();
        boolean adminFoundInHistory = false;
        if(rs.next()) adminFoundInHistory = true;
        rs.close();
        ps.close();

        // insert Admin if it does not exist in adminHistory.
        if(!adminFoundInHistory){
            // get source person from Admin
            String sQuery = "SELECT personid, immatold, immatnew, candidate, lastname, firstname,"+
                            "  gender, dateofbirth, comment, sourceid, Admin.language, engagement, pension,statute,"+
                            "  claimant, searchname, updatetime, claimant_expiration, native_country,native_town,"+
                            "  motive_end_of_service, startdate_inactivity, enddate_inactivity, code_inactivity,"+
                            "  update_status, person_type, situation_end_of_service, updateuserid, comment1, comment2,"+
                            "  comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid"+
                            " FROM Admin WHERE personid = ?";
            ps = adminConn.prepareStatement(sQuery);
            ps.setInt(1,removePersonId);
            rs = ps.executeQuery();

            if(rs.next()){
                // prepare ps to insert Admin in AdminHistory
                // (remind that the columns have a different order in both tables !)
                sbQuery = new StringBuffer();
                sbQuery.append("INSERT INTO AdminHistory(personid, immatold, immatnew, candidate, lastname,")
                       .append("  firstname, gender, dateofbirth, comment, sourceid, language, engagement, pension,")
                       .append("  statute, claimant, searchname, updatetime, claimant_expiration, native_country,")
                       .append("  native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,")
                       .append("  code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,")
                       .append("  comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid) ")
                       .append(" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"); // 38
                PreparedStatement psInsert = adminConn.prepareStatement(sbQuery.toString());

                // set values in insert query
                Object obj;
                for(int i=1; i<=38; i++){
                    obj = rs.getObject(i);
                    if(obj==null){
                        psInsert.setObject(i,null);
                    }
                    else{
                        psInsert.setObject(i,obj);
                    }
                }
                rs.close();
                ps.close();

                // set updatetime = now (~deletetime)
                psInsert.setTimestamp(17,new Timestamp(new java.util.Date().getTime()));

                psInsert.executeUpdate();
                psInsert.close();
            }
            else {
                rs.close();
                ps.close();
            }

        }

        // delete source person from Admin
        ps = adminConn.prepareStatement("DELETE FROM Admin WHERE personid = ?");
        ps.setInt(1,removePersonId);
        ps.executeUpdate();
        ps.close();

        if(Debug.enabled) Debug.println("RemovePerson ("+removePersonId+") moved to AdminHistory");

        //*** STEP 2 : UPDATE HEALTHRECORD *********************************************************
        if(Debug.enabled) Debug.println("*** STEP 2 ***");

        // get healthRecordId of target healthRecord
        ps = occupConn.prepareStatement("SELECT healthRecordId FROM Healthrecord WHERE personId = ?");
        ps.setInt(1,keepPersonId);
        rs = ps.executeQuery();
        int keepHealthRecordId = -1;
        if(rs.next()) keepHealthRecordId = rs.getInt(1);
        rs.close();
        ps.close();
        // get healthRecordId of source healthRecord
        ps = occupConn.prepareStatement("SELECT healthRecordId FROM Healthrecord WHERE personId = ?");
        ps.setInt(1,removePersonId);
        rs = ps.executeQuery();
        int removeHealthRecordId = -1;
        if(rs.next()) removeHealthRecordId = rs.getInt(1);
        rs.close();
        ps.close();

        // both persons have a HR : update HRid of removePerson's Transactions with RHid of keepPerson.
        if(keepHealthRecordId > -1 && removeHealthRecordId > -1){
            sQuery = "UPDATE Transactions SET healthRecordId = ? WHERE healthRecordId = ?";
            ps = occupConn.prepareStatement(sQuery);
            ps.setInt(1,new Integer(keepHealthRecordId).intValue());
            ps.setInt(2,new Integer(removeHealthRecordId).intValue());

            updates = ps.executeUpdate();
            ps.close();

            if(Debug.enabled) Debug.println("Both persons have a HealthRecord : "+updates+" Transactions updated");
        }
        // only keepPerson has a HR : do nothing.
        else if(keepHealthRecordId > -1 && removeHealthRecordId < 0){
            if(Debug.enabled) Debug.println("Only keepPerson ("+keepPersonId+") has a HealthRecord : do nothing.");
        }
        // only removePerson has a HR : update HRid of removePerson's *HR* with RHid of keepPerson.
        else if(keepHealthRecordId < 0 && removeHealthRecordId > -1){
            sQuery = "UPDATE Healthrecord SET personId = ? WHERE personId = ?";
            ps = occupConn.prepareStatement(sQuery);
            ps.setInt(1,keepPersonId);
            ps.setInt(2,removePersonId);

            updates = ps.executeUpdate();
            ps.close();

            if(Debug.enabled){
                Debug.println("Only removePerson ("+removePersonId+") has a HealthRecord : "+updates+" Healthrecord updated");
            }
        }
        // nobody has a HealthRecord : do nothing.
        else{
            if(Debug.enabled) Debug.println("Nobody has a HealthRecord : do nothing.");
        }

        //*** STEP 3 : UPDATE APPOINTMENTS *********************************************************
        if(Debug.enabled) Debug.println("*** STEP 3 ***");
        sQuery = "UPDATE Appointments SET personId = ? WHERE personId = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);

        updates = ps.executeUpdate();
        ps.close();
        if(Debug.enabled) Debug.println(updates+" Appointments updated");

        //*** STEP 4 : UPDATE BADGES ***************************************************************
        if(Debug.enabled) Debug.println("*** STEP 4 ***");
        sQuery = "UPDATE Badges SET BadgePersonId = ? WHERE BadgePersonId = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);

        updates = ps.executeUpdate();
        ps.close();
        if(Debug.enabled) Debug.println(updates+" Badges updated");

        //*** STEP 5 : UPDATE EXPORTACTIVITIES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 5 ***");
        sQuery = "UPDATE exportActivities SET personId = ? WHERE personId = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);

        updates = ps.executeUpdate();
        ps.close();
        if(Debug.enabled) Debug.println(updates+" exportActivities updated");

        //*** STEP 6 : UPDATE EXPORTPERSONS ********************************************************
        if(Debug.enabled) Debug.println("*** STEP 6 ***");
        sQuery = "UPDATE exportPersons SET personId = ? WHERE personId = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);

        updates = ps.executeUpdate();
        ps.close();
        if(Debug.enabled) Debug.println(updates+" exportPersons updated");

        //*** STEP 7 : UPDATE PATIENTDIAGNOSIS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7 ***");
        sQuery = "UPDATE patientDiagnosis SET personId = ? WHERE personId = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);

        updates = ps.executeUpdate();
        ps.close();
        if(Debug.enabled) Debug.println(updates+" patientDiagnosis updated");

        //*** STEP 7.1 : UPDATE OC_ENCOUNTERS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.1 ***");
        sQuery = "UPDATE OC_ENCOUNTERS SET OC_ENCOUNTER_PATIENTUID = ? WHERE OC_ENCOUNTER_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.2 : UPDATE OC_BALANCES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.2 ***");
        sQuery = "UPDATE OC_BALANCES SET OC_BALANCE_OWNERUID = ? WHERE OC_BALANCE_OWNERTYPE='Person' and OC_BALANCE_OWNERUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.3 : UPDATE OC_BARCODES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.3 ***");
        sQuery = "UPDATE OC_BARCODES SET personid = ? WHERE personid = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.4 : UPDATE OC_CAREPRESCRIPTIONS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.4 ***");
        sQuery = "UPDATE OC_CAREPRESCRIPTIONS SET OC_CAREPRESCR_PATIENTUID = ? WHERE OC_CAREPRESCR_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.5 : UPDATE OC_CHRONICMEDICATIONS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.5 ***");
        sQuery = "UPDATE OC_CHRONICMEDICATIONS SET OC_CHRONICMED_PATIENTUID = ? WHERE OC_CHRONICMED_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.6 : UPDATE OC_PRESCRIPTIONS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.6 ***");
        sQuery = "UPDATE OC_PRESCRIPTIONS SET OC_PRESCR_PATIENTUID = ? WHERE OC_PRESCR_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.7 : UPDATE OC_FINGERPRINTS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.7 ***");
        sQuery = "UPDATE OC_FINGERPRINTS SET personid = ? WHERE personid = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.8 : UPDATE OC_CHRONICMEDICATIONS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.8 ***");
        sQuery = "UPDATE OC_INSURANCES SET OC_INSURANCE_PATIENTUID = ? WHERE OC_INSURANCE_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.9 : UPDATE OC_INVOICES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.9 ***");
        sQuery = "UPDATE OC_INVOICES SET OC_INVOICE_CLIENTUID = ? WHERE OC_INVOICE_TYPE='P' and OC_INVOICE_CLIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.10 : UPDATE OC_PATIENTINVOICES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.10 ***");
        sQuery = "UPDATE OC_PATIENTINVOICES SET OC_PATIENTINVOICE_PATIENTUID = ? WHERE OC_PATIENTINVOICE_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.11 : UPDATE OC_PERSON_PICTURES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.11 ***");
        sQuery = "UPDATE OC_PERSON_PICTURES SET personid = ? WHERE personid = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setInt(1,keepPersonId);
        ps.setInt(2,removePersonId);
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.12 : UPDATE OC_PLANNING *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.12 ***");
        sQuery = "UPDATE OC_PLANNING SET OC_PLANNING_PATIENTID = ? WHERE OC_PLANNING_PATIENTID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.13 : UPDATE OC_PROBLEMS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.13 ***");
        sQuery = "UPDATE OC_PROBLEMS SET OC_PROBLEM_PATIENTUID = ? WHERE OC_PROBLEM_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.14 : UPDATE OC_REFERENCES *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.14 ***");
        sQuery = "UPDATE OC_REFERENCES SET OC_REFERENCE_PATIENTUID = ? WHERE OC_REFERENCE_PATIENTUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.15 : UPDATE OC_WICKET_CREDITS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.15 ***");
        sQuery = "UPDATE OC_WICKET_CREDITS SET OC_WICKET_CREDIT_REFERENCEUID = ? WHERE OC_WICKET_CREDIT_REFERENCETYPE='Person' and OC_WICKET_CREDIT_REFERENCEUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 7.16 : UPDATE OC_WICKET_DEBETS *****************************************************
        if(Debug.enabled) Debug.println("*** STEP 7.16 ***");
        sQuery = "UPDATE OC_WICKET_DEBETS SET OC_WICKET_DEBET_REFERENCEUID = ? WHERE OC_WICKET_DEBET_REFERENCETYPE='Person' and OC_WICKET_DEBET_REFERENCEUID = ?";
        ps = occupConn.prepareStatement(sQuery);
        ps.setString(1,keepPersonId+"");
        ps.setString(2,removePersonId+"");
        updates = ps.executeUpdate();
        ps.close();

        //*** STEP 8 : UPDATE MERGEPERSONS *********************************************************
        // put the merged persons in the MergePersons table for a later synchronistation.
        if(addPersonsToMergePersons){
            if(Debug.enabled) Debug.println("*** STEP 8 ***");
            ps = adminConn.prepareStatement("INSERT INTO MergePersons VALUES(?,?,?)");
            ps.setInt(1,removePersonId); // source
            ps.setInt(2,keepPersonId); // target
            ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime())); // now
            ps.executeUpdate();
            ps.close();
            if(Debug.enabled) Debug.println("persons added to MergePersons");
        }

        if(Debug.enabled) Debug.println("=================================================");
        adminConn.close();
        occupConn.close();
    }

}

