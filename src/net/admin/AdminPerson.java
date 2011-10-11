package net.admin;

import be.dpms.medwan.common.model.vo.occupationalmedicine.ExportActivityVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import be.openclinic.medical.Prescription;

import java.lang.reflect.Field;
import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

import net.admin.system.AccessLog;


public class AdminPerson extends OC_Object{
    // declarations
    public String personid;
    public String sourceid;
    public Vector ids;
    public String lastname;
    public String middlename;
    public String firstname;
    public String language;
    public String gender;
    public String dateOfBirth;
    public String comment;
    public Vector privateContacts;
    public Vector familyRelations;
    public Vector workContacts;
    public String pension;
    public String engagement;
    public String statute;
    public String claimant;
    public String claimantExpiration;
    public String nativeCountry;
    public String nativeTown;
    public String personType;
    public String situationEndOfService;
    public String motiveEndOfService;
    public String startdateInactivity;
    public String enddateInactivity;
    public String codeInactivity;
    public String updateStatus;
    public String updateuserid;
    public String comment1;
    public String comment2;
    public String comment3;
    public String comment4;
    public String comment5;
    public String begin;
    public String end;
    public Hashtable adminextends;
    public boolean export = true;
    public boolean checkNatreg = true;
    public boolean checkImmatnew = true;
    public boolean checkImmatold = false;
    public boolean checkArchiveFileCode = false;
    String activeMedicalCenter="";
    String activeMD="";
    String activePara="";
    public AdminSocSec socsec;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public AdminPerson() {
        personid = "";
        sourceid = "";
        ids = new Vector();
        lastname = "";
        middlename = "";
        firstname = "";
        language = "";
        gender = "";
        dateOfBirth = "";
        comment = "";
        privateContacts = new Vector();
        familyRelations = new Vector();
        workContacts = new Vector();
        pension = "";
        engagement = "";
        statute = "";
        claimant = "";
        claimantExpiration = "";
        nativeCountry = "";
        nativeTown = "";
        personType = "";
        situationEndOfService = "";
        motiveEndOfService = "";
        startdateInactivity = "";
        enddateInactivity = "";
        codeInactivity = "";
        updateStatus = "";
        updateuserid = "";
        comment1 = "";
        comment2 = "";
        comment3 = "";
        comment4 = "";
        comment5 = "";
        begin = "";
        end = "";
        adminextends = new Hashtable();
        socsec = new AdminSocSec();

        export = true;
        checkNatreg = true;
        checkImmatnew = true;
        checkImmatold = false;
        checkArchiveFileCode = false;
    }

    //--- GET ADMIN PERSON ------------------------------------------------------------------------
    public static AdminPerson getAdminPerson (Connection connection, String sPersonID){
        AdminPerson adminPerson = new AdminPerson();
        adminPerson.initialize(connection,sPersonID);
        return adminPerson;
    }

    //--- GET ADMIN PERSON ------------------------------------------------------------------------
    public static AdminPerson getAdminHistoryPerson (Connection connection, String sPersonID, java.util.Date updatetime){
        AdminPerson adminPerson = new AdminPerson();
        adminPerson.initializeHistory(connection,sPersonID,updatetime);
        return adminPerson;
    }
    
    public String getFullName(){
    	return lastname.toUpperCase()+", "+firstname;
    }

    public static AdminPerson getAdminPerson (String sPersonID){
    	AdminPerson adminPerson=null;
    	try {
	        Connection conn = MedwanQuery.getInstance().getAdminConnection();
	        adminPerson= AdminPerson.getAdminPerson(conn,sPersonID);
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return adminPerson;
    }

    public String getUid(){
    	return personid;
    }
    
    //--- INITIALIZE ------------------------------------------------------------------------------
    public boolean initialize (Connection connection, String sPersonID) {
        boolean bReturn = false;
        if ((sPersonID!=null)&&(sPersonID.trim().length()>0)) {
            String sSelect = "";
            try {
                PreparedStatement ps;
                String sID;
                this.personid = sPersonID;

                sSelect = " SELECT * FROM AdminView WHERE personid = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    // IDs
                    sID = ScreenHelper.checkString(rs.getString("natreg"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("NatReg",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("immatold"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("ImmatOld",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("immatnew"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("ImmatNew",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("archiveFileCode"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("archiveFileCode",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("candidate"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("Candidate",sID));
                    }

                    // simple attributes
                    lastname = ScreenHelper.checkString(rs.getString("lastname"));
                    firstname = ScreenHelper.checkString(rs.getString("firstname"));
                    gender = ScreenHelper.checkString(rs.getString("gender"));
                    dateOfBirth = ScreenHelper.getSQLDate(rs.getDate("dateofbirth"));
                    comment = ScreenHelper.checkString(rs.getString("comment"));
                    sourceid = ScreenHelper.checkString(rs.getString("sourceid"));
                    language = ScreenHelper.checkString(rs.getString("language"));

                    // correct language // todo : may be removed when in production
                    if(language.equalsIgnoreCase("N")) language = "nl";
                    else if(language.equalsIgnoreCase("F")) language = "fr";

                    pension = ScreenHelper.getSQLDate(rs.getDate("pension"));
                    statute = ScreenHelper.checkString(rs.getString("statute"));
                    engagement = ScreenHelper.getSQLDate(rs.getDate("engagement"));
                    claimant = ScreenHelper.checkString(rs.getString("claimant"));
                    claimantExpiration =ScreenHelper.getSQLDate(rs.getDate("claimant_expiration"));
                    nativeCountry =ScreenHelper.checkString(rs.getString("native_country"));
                    nativeTown = ScreenHelper.checkString(rs.getString("native_town"));
                    personType = ScreenHelper.checkString(rs.getString("person_type"));
                    motiveEndOfService =ScreenHelper.checkString(rs.getString("motive_end_of_service"));
                    situationEndOfService =ScreenHelper.checkString(rs.getString("situation_end_of_service"));
                    startdateInactivity =ScreenHelper.getSQLDate(rs.getDate("startdate_inactivity"));
                    enddateInactivity =ScreenHelper.getSQLDate(rs.getDate("enddate_inactivity"));
                    codeInactivity =ScreenHelper.checkString(rs.getString("code_inactivity"));
                    updateStatus = ScreenHelper.checkString(rs.getString("update_status"));
                    updateuserid = ScreenHelper.checkString(rs.getString("updateuserid"));
                    comment1 = ScreenHelper.checkString(rs.getString("comment1"));
                    comment2 = ScreenHelper.checkString(rs.getString("comment2"));
                    comment3 = ScreenHelper.checkString(rs.getString("comment3"));
                    comment4 = ScreenHelper.checkString(rs.getString("comment4"));
                    comment5 = ScreenHelper.checkString(rs.getString("comment5"));
                    middlename = ScreenHelper.checkString(rs.getString("middlename"));
                    begin =ScreenHelper.getSQLDate(rs.getDate("begindate"));
                    end =ScreenHelper.getSQLDate(rs.getDate("enddate"));

            //private
                    AdminPrivateContact apc;
                    sSelect = "SELECT privateid FROM PrivateView WHERE personid = ? ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        apc = new AdminPrivateContact();
                        apc.privateid = ScreenHelper.checkString(rs.getString("privateid"));
                        apc.initialize(connection);
                        privateContacts.add(apc);
                    }

            //socsec
                    sSelect = "SELECT socsecid FROM AdminSocSec WHERE personid = ? ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        socsec.socsecid = ScreenHelper.checkString(rs.getString("socsecid"));
                        socsec.initialize(connection);
                    }

            //family relation
                    AdminFamilyRelation afr;
                    sSelect = "SELECT relationid FROM AdminFamilyRelation"+
                              " WHERE (sourceid = ? OR destinationid = ?)";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setInt(2,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while(rs.next()){
                        afr = new AdminFamilyRelation();
                        afr.relationId = ScreenHelper.checkString(rs.getString("relationid"));
                        afr.initialize(connection);
                        familyRelations.add(afr);
                    }

             //extends
                    String sLabelID, sExtendValue;
                    sSelect = " SELECT labelid, extendvalue FROM AdminExtends WHERE personid = ? AND extendtype = 'A' ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        sLabelID = ScreenHelper.checkString(rs.getString("labelid"));
                        sExtendValue = ScreenHelper.checkString(rs.getString("extendvalue"));
                        adminextends.put(sLabelID.toLowerCase(),sExtendValue);
                    }
                    bReturn = true;
                }
                if(rs!=null) rs.close();
                if (ps!=null)ps.close();
            }
            catch(SQLException e) {
                e.printStackTrace();
                if(Debug.enabled) Debug.println("AdminPerson initialize error: "+e.getMessage()+" "+sSelect);
            }
        }
        return bReturn;
    }

    //--- INITIALIZE ------------------------------------------------------------------------------
    public boolean initializeHistory (Connection connection, String sPersonID, java.util.Date updatetime) {
        boolean bReturn = false;
        if ((sPersonID!=null)&&(sPersonID.trim().length()>0)) {
            String sSelect = "";
            try {
                PreparedStatement ps;
                String sID;
                this.personid = sPersonID;

                sSelect = " SELECT * FROM AdminHistory WHERE personid = ? and updatetime=?";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.setTimestamp(2, new java.sql.Timestamp(updatetime.getTime()));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    // IDs
                    sID = ScreenHelper.checkString(rs.getString("natreg"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("NatReg",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("immatold"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("ImmatOld",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("immatnew"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("ImmatNew",sID));
                    }

                    sID = ScreenHelper.checkString(rs.getString("candidate"));
                    if((sID!=null)&&(sID.trim().length()>0)&&(!sID.trim().toLowerCase().equals("null"))) {
                        ids.add(new AdminID("Candidate",sID));
                    }

                    // simple attributes
                    lastname = ScreenHelper.checkString(rs.getString("lastname"));
                    firstname = ScreenHelper.checkString(rs.getString("firstname"));
                    gender = ScreenHelper.checkString(rs.getString("gender"));
                    dateOfBirth = ScreenHelper.getSQLDate(rs.getDate("dateofbirth"));
                    comment = ScreenHelper.checkString(rs.getString("comment"));
                    sourceid = ScreenHelper.checkString(rs.getString("sourceid"));
                    language = ScreenHelper.checkString(rs.getString("language"));

                    // correct language // todo : may be removed when in production
                    if(language.equalsIgnoreCase("N")) language = "nl";
                    else if(language.equalsIgnoreCase("F")) language = "fr";

                    pension = ScreenHelper.getSQLDate(rs.getDate("pension"));
                    statute = ScreenHelper.checkString(rs.getString("statute"));
                    engagement = ScreenHelper.getSQLDate(rs.getDate("engagement"));
                    claimant = ScreenHelper.checkString(rs.getString("claimant"));
                    claimantExpiration =ScreenHelper.getSQLDate(rs.getDate("claimant_expiration"));
                    nativeCountry =ScreenHelper.checkString(rs.getString("native_country"));
                    nativeTown = ScreenHelper.checkString(rs.getString("native_town"));
                    personType = ScreenHelper.checkString(rs.getString("person_type"));
                    motiveEndOfService =ScreenHelper.checkString(rs.getString("motive_end_of_service"));
                    situationEndOfService =ScreenHelper.checkString(rs.getString("situation_end_of_service"));
                    startdateInactivity =ScreenHelper.getSQLDate(rs.getDate("startdate_inactivity"));
                    enddateInactivity =ScreenHelper.getSQLDate(rs.getDate("enddate_inactivity"));
                    codeInactivity =ScreenHelper.checkString(rs.getString("code_inactivity"));
                    updateStatus = ScreenHelper.checkString(rs.getString("update_status"));
                    updateuserid = ScreenHelper.checkString(rs.getString("updateuserid"));
                    comment1 = ScreenHelper.checkString(rs.getString("comment1"));
                    comment2 = ScreenHelper.checkString(rs.getString("comment2"));
                    comment3 = ScreenHelper.checkString(rs.getString("comment3"));
                    comment4 = ScreenHelper.checkString(rs.getString("comment4"));
                    comment5 = ScreenHelper.checkString(rs.getString("comment5"));
                    middlename = ScreenHelper.checkString(rs.getString("middlename"));
                    begin =ScreenHelper.getSQLDate(rs.getDate("begindate"));
                    end =ScreenHelper.getSQLDate(rs.getDate("enddate"));

            //private
                    AdminPrivateContact apc;
                    sSelect = "SELECT privateid FROM PrivateView WHERE personid = ? ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        apc = new AdminPrivateContact();
                        apc.privateid = ScreenHelper.checkString(rs.getString("privateid"));
                        apc.initialize(connection);
                        privateContacts.add(apc);
                    }

            //socsec
                    sSelect = "SELECT socsecid FROM AdminSocSec WHERE personid = ? ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        socsec.socsecid = ScreenHelper.checkString(rs.getString("socsecid"));
                        socsec.initialize(connection);
                    }

            //family relation
                    AdminFamilyRelation afr;
                    sSelect = "SELECT relationid FROM AdminFamilyRelation"+
                              " WHERE (sourceid = ? OR destinationid = ?)";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setInt(2,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while(rs.next()){
                        afr = new AdminFamilyRelation();
                        afr.relationId = ScreenHelper.checkString(rs.getString("relationid"));
                        afr.initialize(connection);
                        familyRelations.add(afr);
                    }

             //extends
                    String sLabelID, sExtendValue;
                    sSelect = " SELECT labelid, extendvalue FROM AdminExtends WHERE personid = ? AND extendtype = 'A' ";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        sLabelID = ScreenHelper.checkString(rs.getString("labelid"));
                        sExtendValue = ScreenHelper.checkString(rs.getString("extendvalue"));
                        adminextends.put(sLabelID.toLowerCase(),sExtendValue);
                    }
                    bReturn = true;
                }
                if(rs!=null) rs.close();
                if (ps!=null)ps.close();
            }
            catch(SQLException e) {
                e.printStackTrace();
                if(Debug.enabled) Debug.println("AdminPerson initialize error: "+e.getMessage()+" "+sSelect);
            }
        }
        return bReturn;
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public boolean saveToDB(Connection connection,String activeMedicalCenter,String activeMD,String activePara){
        this.activeMedicalCenter=activeMedicalCenter;
        this.activeMD=activeMD;
        this.activePara=activePara;
        return saveToDB(connection);
    }

    public boolean hasLabRequests(){
        boolean ok=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sQuery="select * from RequestedLabAnalyses where patientid=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,Integer.parseInt(personid));
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
                ok=true;
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return ok;
    }

    public boolean saveToDB(Connection connection) {
        boolean bReturn = true;
        String sSelect = "";
        try {
            PreparedStatement ps;
            ResultSet rs;
            String sPersonID = "", sSourceID, sSearchname, sLastname, sFirstname, sMiddlename;

            sSourceID = this.sourceid;
            if ((this.personid!=null)&&(this.personid.trim().length()>0)) {
                sPersonID = this.personid;
            }

            // NATREG
            if(checkNatreg && (sPersonID.trim().length()==0)&&(getID("natreg").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE natreg = ? ";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("natreg"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // IMMATNEW
            if(checkImmatnew && (sPersonID.trim().length()==0)&&(getID("immatnew").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE immatnew = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("immatnew"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // IMMATOLD
            if(checkImmatold && (sPersonID.trim().length()==0)&&(getID("immatold").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE immatold = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("immatold"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // archiveFileCode
            if(checkArchiveFileCode && (sPersonID.trim().length()==0)&&(getID("archiveFileCode").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE archiveFileCode = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("archiveFileCode"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            sLastname = ScreenHelper.checkSpecialCharacters(lastname);
            sFirstname = ScreenHelper.checkSpecialCharacters(firstname);
            sMiddlename = ScreenHelper.checkSpecialCharacters(middlename);
            sSearchname = sLastname.toUpperCase().trim()+","+sFirstname.toUpperCase().trim();
            sSearchname = ScreenHelper.normalizeSpecialCharacters(sSearchname);
            
            firstname = firstname.replaceAll("'","´");
            lastname = lastname.replaceAll("'","´");
            
            //*** INSERT ***
            if ((bReturn)&&(sPersonID.trim().length()==0)) {
                sPersonID = ScreenHelper.newCounter("PersonID",connection);
                if(this.getID("immatnew").length()==0){
                    this.setID("immatnew",sPersonID);
                }
                if ((sPersonID.trim().length()>0)&&(this.sourceid.trim().length()>0)) {
                    this.personid = sPersonID;
                    sSelect = " INSERT INTO Admin (personid, natreg, lastname, sourceid) VALUES (?,?,?,?) ";
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setString(2,ScreenHelper.checkString(getID("natreg")));
                    ps.setString(3,this.lastname);
                    ps.setString(4,sSourceID);
                    ps.executeUpdate();
                    if (ps!=null)ps.close();

                    if ((this.updateuserid==null)||(this.updateuserid.trim().length()==0)) {
                        this.updateuserid = "0";
                    }

                    // Er werd een nieuw dossier aangemaakt, genereer eventueel de bijgaande prestatiecode
                    if (export && MedwanQuery.getInstance().getConfigInt("exportEnabled")==1){
                        ExportActivityVO exportActivityVO=new ExportActivityVO(Integer.parseInt(personid),Integer.parseInt(this.updateuserid),new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()),null,"RECORD-CREATION."+personid+"."+MedwanQuery.getInstance().getConfigString("serverId"));
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setMD(activeMD);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("RECORD-CREATION") && !this.updateuserid.equals("0")){
                            exportActivityVO.store(true,this.updateuserid);
                        }
                    }
                }
                else {
                    ScreenHelper.writeMessage(" SourceID error with "+getID("natreg")+""+getID("immatold")+" "+getID("immatnew")+" "+sSelect);
                    bReturn = false;
                }
            }

            if (bReturn) {
                //*** UPDATE ***
                if (sSourceID.toLowerCase().equals(this.sourceid.toLowerCase())) {
                    Hashtable hSelect = new Hashtable();
                    hSelect.put(" natreg = ? ",getID("natreg"));
                    hSelect.put(" immatold = ? ",getID("immatold"));
                    hSelect.put(" immatnew = ? ",getID("immatnew"));
                    hSelect.put(" archiveFileCode = ? ",getID("archiveFileCode"));
                    hSelect.put(" candidate = ? ",getID("candidate"));

                    hSelect.put(" gender = ? ",this.gender);
                    hSelect.put(" language = ? ",this.language);
                    hSelect.put(" dateofbirth = ? ",this.dateOfBirth);
                    hSelect.put(" sourceid = ? ",this.sourceid);
                    hSelect.put(" comment = ? ",this.comment);
                    hSelect.put(" pension = ? ",this.pension);
                    hSelect.put(" engagement = ? ",this.engagement);
                    hSelect.put(" statute = ? ",this.statute);
                    hSelect.put(" claimant = ? ",this.claimant);
                    hSelect.put(" claimant_expiration = ? ",this.claimantExpiration);
                    hSelect.put(" native_country = ? ",this.nativeCountry);
                    hSelect.put(" native_town = ? ",this.nativeTown);
                    hSelect.put(" person_type = ? ",this.personType);
                    hSelect.put(" situation_end_of_service = ? ",this.situationEndOfService);
                    hSelect.put(" motive_end_of_service = ? ",this.motiveEndOfService);
                    hSelect.put(" startdate_inactivity = ? ",this.startdateInactivity);
                    hSelect.put(" enddate_inactivity = ? ",this.enddateInactivity);
                    hSelect.put(" code_inactivity = ? ",this.codeInactivity);
                    hSelect.put(" update_status = ?",this.updateStatus);
                    hSelect.put(" comment1 = ? ",this.comment1);
                    hSelect.put(" comment2 = ? ",this.comment2);
                    hSelect.put(" comment3 = ? ",this.comment3);
                    hSelect.put(" comment4 = ? ",this.comment4);
                    hSelect.put(" comment5 = ? ",this.comment5);
                    hSelect.put(" middlename = ? ",sMiddlename);
                    hSelect.put(" enddate = ? ",this.end);
                    hSelect.put(" begindate = ? ",this.begin);

                    if (hSelect.size()>0) {
                        if ((this.updateuserid==null)||(this.updateuserid.trim().length()==0)) {
                            this.updateuserid = "0";
                        }
                        sSelect = "UPDATE Admin SET searchname = ?, lastname = ?, firstname = ?, updatetime = ? , updateuserid = ? "+", updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" ";

                        Enumeration e = hSelect.keys();
                        String sKey;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sSelect += ","+sKey;
                        }
                        sSelect += " WHERE personid = "+sPersonID;


                        ps = connection.prepareStatement(sSelect);
                        ps.setString(1,sSearchname);
                        ps.setString(2,this.lastname);
                        ps.setString(3,this.firstname);
                        ps.setTimestamp(4,new java.sql.Timestamp(new java.util.Date().getTime()));
                        ps.setInt(5,Integer.parseInt(this.updateuserid));

                        int iIndex = 6;
                        e = hSelect.keys();
                        String sValue;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sValue = (String)hSelect.get(sKey);
                            if ( (sKey.equalsIgnoreCase(" dateofbirth = ? "))
                                ||(sKey.equalsIgnoreCase(" engagement = ? "))
                                ||(sKey.equalsIgnoreCase(" pension = ? "))
                                ||(sKey.equalsIgnoreCase(" claimant_expiration = ? "))
                                ||(sKey.equalsIgnoreCase(" startdate_inactivity = ? "))
                                ||(sKey.equalsIgnoreCase(" enddate_inactivity = ? "))
                                ||(sKey.equalsIgnoreCase(" begindate = ? "))
                                ||(sKey.equalsIgnoreCase(" enddate = ? ")) ){
                                ScreenHelper.setSQLDate(ps,iIndex,sValue);
                            }
                            else {
                                ps.setString(iIndex,sValue);
                            }
                            iIndex++;
                        }
                    	copyActiveToHistoryNoDelete(this.personid);

                        ps.executeUpdate();
                        if (ps!=null)ps.close();
                        this.personid = sPersonID;
                    }
                }
                else {
                    // WRONG OWNER
                    ScreenHelper.writeMessage(" Wrong owner of "+getID("natreg")+" "+getID("immatold")+" "+getID("immatnew"));
                    bReturn = false;
                }
            }
            else {
                ScreenHelper.writeMessage(" Error with "+getID("natreg")+" "+getID("immatold")+" "+getID("immatnew")+" "+sSelect);
            }

            // adminprivate
            if (bReturn) {
                for (int i=0;(i<this.privateContacts.size())&&(bReturn);i++) {
                    bReturn = ((AdminPrivateContact)this.privateContacts.elementAt(i)).saveToDB(sPersonID, connection);
                }
            }

            // socsec
            if (bReturn) {
                bReturn = socsec.saveToDB(sPersonID, connection);
            }

            // admin family relations
            if(bReturn){
                AdminFamilyRelation.deleteAllRelationsForPerson(this.personid);
                AdminFamilyRelation relation;
                for(int i=0; i<this.familyRelations.size(); i++){
                    relation = ((AdminFamilyRelation)this.familyRelations.elementAt(i));

                    // update sourceId to saved personid if none specified
                    if(relation.sourceId.length()==0 || Integer.parseInt(relation.sourceId) < 0){
                        relation.sourceId = this.personid;
                    }

                    // update destinationId to saved personid if none specified
                    if(relation.destinationId.length()==0 || Integer.parseInt(relation.destinationId) < 0){
                        relation.destinationId = this.personid;
                    }

                    relation.saveToDB(connection);
                }
            }

            // adminextends
            if (bReturn) {
                sSelect = "DELETE FROM AdminExtends WHERE personid = ? AND extendtype = 'A'";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.executeUpdate();
                if (ps!=null)ps.close();

                String sLabelID, sExtendValue;
                Enumeration eExtends = this.adminextends.keys();
                while (eExtends.hasMoreElements()){
                    sLabelID = (String)eExtends.nextElement();
                    sExtendValue = (String) this.adminextends.get(sLabelID);
                    sSelect = " INSERT INTO AdminExtends (personid, extendtype, extendvalue, labelid, updatetime, updateuserid,updateserverid) "
                        +" VALUES (?,'A', ?,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")";
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setString(2,sExtendValue);
                    ps.setString(3,sLabelID);
                    ps.setDate(4,ScreenHelper.getSQLDate(ScreenHelper.getDate()));
                    ps.setInt(5,Integer.parseInt(this.updateuserid));
                    ps.executeUpdate();
                    if (ps!=null)ps.close();
                }
            }

            if(export) MedwanQuery.getInstance().exportPerson(Integer.parseInt(this.personid));
        }
        catch(Exception e) {
            e.printStackTrace();
            ScreenHelper.writeMessage(getClass()+" (1) "+e.getMessage()+" "+sSelect);
            bReturn = false;
        }

        AccessLog.insert(this.updateuserid==null?"0":this.updateuserid,"M."+this.personid);
        return bReturn;
    }

    //--- SAVE TO DB WITH SUPPLIED ID -------------------------------------------------------------
    public boolean saveToDBWithSuppliedID(Connection connection, String sPersonID,String activeMedicalCenter,String activeMD,String activePara) {
        this.activeMedicalCenter=activeMedicalCenter;
        this.activeMD=activeMD;
        this.activePara=activePara;
        return saveToDBWithSuppliedID(connection,sPersonID);
    }

    public boolean saveToDBWithSuppliedID(Connection connection, String sPersonID) {
        boolean bReturn = true;
        PreparedStatement ps;
        ResultSet rs;
        String sSelect = "", sSourceID, sSearchname, sLastname, sFirstname, sMiddlename;

        try {
            sSourceID = this.sourceid;

            // NATREG
            if(checkNatreg && (sPersonID.trim().length()==0)&&(getID("natreg").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE natreg = ? ";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("natreg"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // IMMATNEW
            if(checkImmatnew && (sPersonID.trim().length()==0)&&(getID("immatnew").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE immatnew = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("immatnew"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // IMMATOLD
            if(checkImmatold && (sPersonID.trim().length()==0)&&(getID("immatold").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE immatold = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("immatold"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            // archiveFileCode
            if(checkArchiveFileCode && (sPersonID.trim().length()==0)&&(getID("archiveFileCode").trim().length()>0)) {
                sSelect = " SELECT personid, sourceid FROM Admin WHERE archiveFileCode = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,getID("archiveFileCode"));
                rs = ps.executeQuery();
                if (rs.next()) {
                    sPersonID = rs.getString("personid");
                    sSourceID = rs.getString("sourceid");
                }
                rs.close();
                ps.close();
            }

            sLastname = ScreenHelper.checkSpecialCharacters(lastname);
            sFirstname = ScreenHelper.checkSpecialCharacters(firstname);
            sMiddlename = ScreenHelper.checkSpecialCharacters(middlename);
            sSearchname = sLastname.toUpperCase().trim()+","+sFirstname.toUpperCase().trim();

            //*** INSERT ***
            if(bReturn){
                if ((sPersonID.trim().length()>0)&&(this.sourceid.trim().length()>0)) {
                    this.personid = sPersonID;

                    sSelect = "INSERT INTO Admin (personid, natreg, lastname, sourceid) VALUES (?,?,?,?)";
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setString(2,getID("natreg"));
                    ps.setString(3,this.lastname);
                    ps.setString(4,sSourceID);
                    ps.executeUpdate();
                    if (ps!=null)ps.close();

                    if ((this.updateuserid==null)||(this.updateuserid.trim().length()==0)) {
                        this.updateuserid = "0";
                    }

                    // Er werd een nieuw dossier aangemaakt, genereer eventueel de bijgaande prestatiecode
                    if (export && MedwanQuery.getInstance().getConfigInt("exportEnabled")==1){
                        ExportActivityVO exportActivityVO=new ExportActivityVO(Integer.parseInt(personid),Integer.parseInt(this.updateuserid),new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()),null,"RECORD-CREATION."+personid+"."+MedwanQuery.getInstance().getConfigString("serverId"));
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setMD(activeMD);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("RECORD-CREATION") && !this.updateuserid.equals("0")){
                            exportActivityVO.store(true,this.updateuserid);
                        }
                    }
                }
                else {
                    ScreenHelper.writeMessage(" SourceID error with "+getID("natreg")+""+getID("immatold")+" "+getID("immatnew")+" "+sSelect);
                    bReturn = false;
                }
            }

            if (bReturn) {
                //*** UPDATE ***
                if (sSourceID.toLowerCase().equals(this.sourceid.toLowerCase())) {
                    Hashtable hSelect = new Hashtable();
                    hSelect.put(" natreg = ? ",getID("natreg"));
                    hSelect.put(" immatold = ? ",getID("immatold"));
                    hSelect.put(" immatnew = ? ",getID("immatnew"));
                    hSelect.put(" archiveFileCode = ? ",getID("archiveFileCode"));
                    hSelect.put(" candidate = ? ",getID("candidate"));

                    hSelect.put(" gender = ? ",this.gender);
                    hSelect.put(" language = ? ",this.language);
                    hSelect.put(" dateofbirth = ? ",this.dateOfBirth);
                    hSelect.put(" sourceid = ? ",this.sourceid);
                    hSelect.put(" comment = ? ",this.comment);
                    hSelect.put(" pension = ? ",this.pension);
                    hSelect.put(" engagement = ? ",this.engagement);
                    hSelect.put(" statute = ? ",this.statute);
                    hSelect.put(" claimant = ? ",this.claimant);
                    hSelect.put(" claimant_expiration = ? ",this.claimantExpiration);
                    hSelect.put(" native_country = ? ",this.nativeCountry);
                    hSelect.put(" native_town = ? ",this.nativeTown);
                    hSelect.put(" person_type = ? ",this.personType);
                    hSelect.put(" situation_end_of_service = ? ",this.situationEndOfService);
                    hSelect.put(" motive_end_of_service = ? ",this.motiveEndOfService);
                    hSelect.put(" startdate_inactivity = ? ",this.startdateInactivity);
                    hSelect.put(" enddate_inactivity = ? ",this.enddateInactivity);
                    hSelect.put(" code_inactivity = ? ",this.codeInactivity);
                    hSelect.put(" update_status = ?",this.updateStatus);
                    hSelect.put(" comment1 = ? ",this.comment1);
                    hSelect.put(" comment2 = ? ",this.comment2);
                    hSelect.put(" comment3 = ? ",this.comment3);
                    hSelect.put(" comment4 = ? ",this.comment4);
                    hSelect.put(" comment5 = ? ",this.comment5);
                    hSelect.put(" middlename = ? ",sMiddlename);
                    hSelect.put(" enddate = ? ",this.end);
                    hSelect.put(" begindate = ? ",this.begin);

                    if (hSelect.size()>0) {
                        if ((this.updateuserid==null)||(this.updateuserid.trim().length()==0)) {
                            this.updateuserid = "0";
                        }
                        sSelect = "UPDATE Admin SET searchname = ?, lastname = ?, firstname = ?, updatetime = ? , updateuserid = ? "+", updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" ";
                        Enumeration e = hSelect.keys();
                        String sKey;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sSelect += ","+sKey;
                        }
                        sSelect += " WHERE personid = "+sPersonID;

                        ps = connection.prepareStatement(sSelect);
                        ps.setString(1,sSearchname);
                        ps.setString(2,this.lastname);
                        ps.setString(3,this.firstname);
                        ps.setTimestamp(4,new java.sql.Timestamp(new java.util.Date().getTime()));
                        ps.setInt(5,Integer.parseInt(this.updateuserid));

                        int iIndex = 6;
                        e = hSelect.keys();
                        String sValue;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sValue = (String)hSelect.get(sKey);
                            if ( (sKey.equalsIgnoreCase(" dateofbirth = ? "))
                                ||(sKey.equalsIgnoreCase(" engagement = ? "))
                                ||(sKey.equalsIgnoreCase(" pension = ? "))
                                ||(sKey.equalsIgnoreCase(" claimant_expiration = ? "))
                                ||(sKey.equalsIgnoreCase(" startdate_inactivity = ? "))
                                ||(sKey.equalsIgnoreCase(" enddate_inactivity = ? "))
                                ||(sKey.equalsIgnoreCase(" begindate = ? "))
                                ||(sKey.equalsIgnoreCase(" enddate = ? ")) ){

                                ScreenHelper.setSQLDate(ps,iIndex,sValue);
                            }
                            else {
                                ps.setString(iIndex,sValue);
                            }
                            iIndex++;
                        }
                    	copyActiveToHistoryNoDelete(this.personid);

                        ps.executeUpdate();
                        if (ps!=null)ps.close();
                        this.personid = sPersonID;
                    }
                }
                else {
                    // WRONG OWNER
                    ScreenHelper.writeMessage(" Wrong owner of "+getID("natreg")+" "+getID("immatold")+" "+getID("immatnew"));
                    bReturn = false;
                }
            }
            else {
                ScreenHelper.writeMessage(" Error with "+getID("natreg")+" "+getID("immatold")+" "+getID("immatnew")+" "+sSelect);
            }

            // adminprivate
            if (bReturn) {
                for (int i=0;(i<this.privateContacts.size())&&(bReturn);i++) {
                    bReturn = ((AdminPrivateContact)this.privateContacts.elementAt(i)).saveToDB(sPersonID, connection);
                }
            }

            // socsec
            if (bReturn) {
                bReturn = socsec.saveToDB(sPersonID, connection);
            }

            // adminextends
            if (bReturn) {
                sSelect = "DELETE FROM AdminExtends WHERE personid = ? AND extendtype = 'A'";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.executeUpdate();
                if (ps!=null)ps.close();

                String sLabelID, sExtendValue;
                Enumeration eExtends = this.adminextends.keys();
                while (eExtends.hasMoreElements()){
                    sLabelID = (String)eExtends.nextElement();
                    sExtendValue = (String) this.adminextends.get(sLabelID);
                    sSelect = " INSERT INTO AdminExtends (personid, extendtype, extendvalue, labelid, updatetime, updateuserid,updateserverid) "
                        +" VALUES (?,'A', ?,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")";
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setString(2,sExtendValue);
                    ps.setString(3,sLabelID);
                    ps.setDate(4,ScreenHelper.getSQLDate(ScreenHelper.getDate()));
                    ps.setInt(5,Integer.parseInt(this.updateuserid));
                    ps.executeUpdate();
                    if (ps!=null)ps.close();
                }
            }

            if(export) MedwanQuery.getInstance().exportPerson(Integer.parseInt(this.personid));
        }
        catch(SQLException e) {
            ScreenHelper.writeMessage(getClass()+" (1) "+e.getMessage()+" "+sSelect);
            bReturn = false;
        }
        AccessLog.insert(this.updateuserid==null?"0":this.updateuserid,"M."+this.personid);

        return bReturn;
    }

    //--- SET ID 1 --------------------------------------------------------------------------------
    public String getID(String sType) {
        AdminID id;
        for (int i=0;i<this.ids.size();i++) {
            id = (AdminID) this.ids.elementAt(i);
            if (id.type.toLowerCase().equals(sType.toLowerCase())) {
                return id.value;
            }
        }
        return "";
    }

    //--- SET ID 1 --------------------------------------------------------------------------------
    public AdminID getAdminID(String sType) {
        AdminID id;
        for (int i=0;i<this.ids.size();i++) {
            id = (AdminID) this.ids.elementAt(i);
            if (id.type.toLowerCase().equals(sType.toLowerCase())) {
                return id;
            }
        }
        return null;
    }

    //--- SET ID 2 --------------------------------------------------------------------------------
    public void setID(String sType,String sValue) {
        AdminID id;
        for (int i=0;i<this.ids.size();i++) {
            id = (AdminID) this.ids.elementAt(i);
            if (id.type.toLowerCase().equals(sType.toLowerCase())) {
                id.value=sValue;
                return;
            }
        }

        // id not found, so add it
        this.ids.add(new AdminID(sType,sValue));
    }

    //--- GET ACTIVE PRIVATE ----------------------------------------------------------------------
    public AdminPrivateContact getActivePrivate() {
        AdminPrivateContact apc;

        for (int i=0;i<privateContacts.size();i++) {
            apc = (AdminPrivateContact) privateContacts.elementAt(i);
            if (apc.end.equals("")) {
                return apc;
            }
        }
        return new AdminPrivateContact();
    }

    //--- COMPARE FIELD ---------------------------------------------------------------------------
    private boolean compareField(Object source,Object target,String sField){
        try {
            Field field=source.getClass().getField(sField);
            if (field.get(source)!=null && (field.getType().isPrimitive() || (field.getType().isInstance("") && ((String)field.get(source)).length()>0))){
                if (!field.get(source).equals(field.get(target))){
                    return false;
                }
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return true;
    }

    //--- EQUALS PARTIAL PERSON -------------------------------------------------------------------
    public boolean equalsPartialPerson(AdminPerson person){
        //Eerst vergelijken we de signaletiek
        if (person.ids!=null){
            AdminID id;
            for (int n=0;n<person.ids.size();n++){
                id = (AdminID)person.ids.elementAt(n);
                if (!id.value.trim().equals(this.getID(id.type).trim())) return false;
            }
        }
        if (!compareField(person,this,"firstname")) return false;
        if (!compareField(person,this,"middlename")) return false;
        if (!compareField(person,this,"lastname")) return false;
        if (!compareField(person,this,"language")) return false;
        if (!compareField(person,this,"gender")) return false;
        if (!compareField(person,this,"dateOfBirth")) return false;
        if (!compareField(person,this,"comment")) return false;
        if (!compareField(person,this,"pension")) return false;
        if (!compareField(person,this,"engagement")) return false;
        if (!compareField(person,this,"statute")) return false;
        if (!compareField(person,this,"claimant")) return false;
        if (!compareField(person,this,"claimantExpiration")) return false;
        if (!compareField(person,this,"nativeCountry")) return false;
        if (!compareField(person,this,"nativeTown")) return false;
        if (!compareField(person,this,"personType")) return false;
        if (!compareField(person,this,"situationEndOfService")) return false;
        if (!compareField(person,this,"motiveEndOfService")) return false;
        if (!compareField(person,this,"startdateInactivity")) return false;
        if (!compareField(person,this,"enddateInactivity")) return false;
        if (!compareField(person,this,"codeInactivity")) return false;
        if (!compareField(person,this,"comment1")) return false;
        if (!compareField(person,this,"comment2")) return false;
        if (!compareField(person,this,"comment3")) return false;
        if (!compareField(person,this,"comment4")) return false;
        if (!compareField(person,this,"comment5")) return false;

        //Daarna de privégegevens
        AdminPrivateContact personPrivate=person.getActivePrivate();
        AdminPrivateContact thisPrivate=this.getActivePrivate();
        if(!compareField(personPrivate,thisPrivate,"address")) return false;
        if(!compareField(personPrivate,thisPrivate,"city")) return false;
        if(!compareField(personPrivate,thisPrivate,"zipcode")) return false;
        if(!compareField(personPrivate,thisPrivate,"country")) return false;
        if(!compareField(personPrivate,thisPrivate,"telephone")) return false;
        if(!compareField(personPrivate,thisPrivate,"fax")) return false;
        if(!compareField(personPrivate,thisPrivate,"mobile")) return false;
        if(!compareField(personPrivate,thisPrivate,"email")) return false;
        if(!compareField(personPrivate,thisPrivate,"comment")) return false;
        if(!compareField(personPrivate,thisPrivate,"type")) return false;
        return true;
    }

    //--- GET ACTIVE PERSON -----------------------------------------------------------------------
    public AdminPerson getActivePerson(){
        AdminPrivateContact privateContact = getActivePrivate();
        privateContacts=new Vector();
        if (privateContact.privateid.length()!=0){
            privateContacts.add(privateContact);
        }
        return this;
    }

    //--- IS HOSPITALIZED -------------------------------------------------------------------------
    public boolean isHospitalized(){
        Service activeDivision = getActiveDivision();
        return (activeDivision!=null);
    }

    //--- GET ACTIVE DIVISION ---------------------------------------------------------------------
    public Service getActiveDivision(){
        return ScreenHelper.getActiveDivision(this.personid);
    }

    //--- GET ACTIVE PRESCRIPTIONS (internal supplying service) -----------------------------------
    public Vector getActivePrescriptions(){
        Vector prescriptions = new Vector();
        Prescription prescription;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT OC_PRESCR_SERVERID, OC_PRESCR_OBJECTID, OC_PRESCR_PRODUCTUID, OC_PRESCR_SUPPLYINGSERVICEUID"+
                             " FROM OC_PRESCRIPTIONS"+
                             "  WHERE OC_PRESCR_PATIENTUID = ?"+
                             "   AND (OC_PRESCR_END >= ? OR OC_PRESCR_END IS NULL) "+
                             //"   AND "+lowerServiceCode+" NOT LIKE 'extfour%'"+
                             " ORDER BY OC_PRESCR_BEGIN DESC";

            // set questionmark values
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,this.personid);
            ps.setDate(2,new Date(new java.util.Date().getTime())); // now

            // execute
            String supplyingServiceUid;
            rs = ps.executeQuery();
            while(rs.next()){
                // only get prescriptions supplied by internal services
                supplyingServiceUid = ScreenHelper.checkString(rs.getString("OC_PRESCR_SUPPLYINGSERVICEUID"));
                boolean supplyingServiceIsExternalService = false;
                if(supplyingServiceUid.length() > 0){
                    supplyingServiceIsExternalService = Service.isExternalService(supplyingServiceUid);
                }

                if(!supplyingServiceIsExternalService){
                    prescription = Prescription.get(rs.getString("OC_PRESCR_SERVERID")+"."+rs.getString("OC_PRESCR_OBJECTID"));
                    prescriptions.add(prescription);
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
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return prescriptions;
    }

    //--- IS USER ---------------------------------------------------------------------------------
    public boolean isUser(){
        boolean isUser = false;
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            // compose query
            String sSelect = "SELECT userid FROM Users WHERE personid = ?";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(this.personid));

            // execute
            rs = ps.executeQuery();
            if(rs.next()) isUser = true;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return isUser;
    }

    public static List getUserHospitalized(String sUserID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        //Vector vResults = new Vector();
        List lResults = new ArrayList();

        String sSelect =" SELECT DISTINCT OC_ENCOUNTER_PATIENTUID," +
                                        " personid," +
                                        " immatnew," +
                                        " natreg," +
                                        " lastname," +
                                        " firstname," +
                                        " gender," +
                                        " dateofbirth," +
                                        " pension" +
                        " FROM AdminView a,OC_ENCOUNTERS_VIEW o" +
                        " WHERE(o.OC_ENCOUNTER_ENDDATE IS NULL OR o.OC_ENCOUNTER_ENDDATE > ?)" +
                        " AND o.OC_ENCOUNTER_TYPE = 'admission'" +
                        " AND o.OC_ENCOUNTER_MANAGERUID = ?" +
                        " AND o.OC_ENCOUNTER_PATIENTUID = " + MedwanQuery.getInstance().convert("varchar(255)","personid");
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect.trim());
            ps.setTimestamp(1,new Timestamp(ScreenHelper.getSQLTime().getTime()));
            ps.setString(2,sUserID);

            rs = ps.executeQuery();

            AdminPerson tempPat;
            while(rs.next()){
                tempPat = new AdminPerson();
                //tempPat.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                //tempPat.setPersonid(ScreenHelper.checkString(rs.getString("personid")));
                tempPat.ids.addElement(new AdminID("ImmatNew",ScreenHelper.checkString(rs.getString("immatnew"))));
                //tempPat.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                tempPat.ids.addElement(new AdminID("NatReg",ScreenHelper.checkString(rs.getString("natreg"))));
                //tempPat.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                //tempPat.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                //tempPat.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                tempPat.gender = ScreenHelper.checkString(rs.getString("gender"));
                //tempPat.setGender(ScreenHelper.checkString(rs.getString("gender")));
                tempPat.pension = ScreenHelper.checkString(rs.getString("pension"));
                //tempPat.setPension(ScreenHelper.checkString(rs.getString("pension")));
                if(rs.getDate("dateofbirth") != null){
                    tempPat.dateOfBirth = new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dateofbirth"));
                }else{
                    tempPat.dateOfBirth = "";
                }
                //tempPat.setDateofbirth(rs.getDate("dateofbirth"));

                lResults.add(tempPat);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return lResults;
    }

    public static List getUserVisits(String sUserID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        //Vector vResults = new Vector();
        List lResults = new ArrayList();

        String sSelect =" SELECT DISTINCT OC_ENCOUNTER_PATIENTUID," +
                                        " personid," +
                                        " immatnew," +
                                        " natreg," +
                                        " lastname," +
                                        " firstname," +
                                        " gender," +
                                        " dateofbirth," +
                                        " pension" +
                        " FROM AdminView a,OC_ENCOUNTERS_VIEW o" +
                        " WHERE(o.OC_ENCOUNTER_ENDDATE IS NULL OR o.OC_ENCOUNTER_ENDDATE > ?)" +
                        " AND o.OC_ENCOUNTER_TYPE = 'visit'" +
                        " AND o.OC_ENCOUNTER_MANAGERUID = ?" +
                        " AND o.OC_ENCOUNTER_PATIENTUID = " + MedwanQuery.getInstance().convert("varchar(255)","personid");
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect.trim());
            ps.setTimestamp(1,new Timestamp(ScreenHelper.getSQLTime().getTime()));
            ps.setString(2,sUserID);

            rs = ps.executeQuery();

            AdminPerson tempPat;
            while(rs.next()){
                tempPat = new AdminPerson();
                //tempPat.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                //tempPat.setPersonid(ScreenHelper.checkString(rs.getString("personid")));
                tempPat.ids.addElement(new AdminID("ImmatNew",ScreenHelper.checkString(rs.getString("immatnew"))));
                //tempPat.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                tempPat.ids.addElement(new AdminID("NatReg",ScreenHelper.checkString(rs.getString("natreg"))));
                //tempPat.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                //tempPat.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                //tempPat.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                tempPat.gender = ScreenHelper.checkString(rs.getString("gender"));
                //tempPat.setGender(ScreenHelper.checkString(rs.getString("gender")));
                tempPat.pension = ScreenHelper.checkString(rs.getString("pension"));
                //tempPat.setPension(ScreenHelper.checkString(rs.getString("pension")));
                if(rs.getDate("dateofbirth") != null){
                    tempPat.dateOfBirth = new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dateofbirth"));
                }else{
                    tempPat.dateOfBirth = "";
                }
                //tempPat.setDateofbirth(rs.getDate("dateofbirth"));
                lResults.add(tempPat);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return lResults;
    }

    public static Vector getPatientsAdmittedInService(String serviceid){
        Vector patients=new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sQuery="select OC_ENCOUNTER_PATIENTUID " +
                    " from OC_ENCOUNTERS_VIEW a where " +
                    " OC_ENCOUNTER_SERVICEUID=? and" +
                    " (OC_ENCOUNTER_ENDDATE IS NULL or OC_ENCOUNTER_ENDDATE>=?) and" +
                    " OC_ENCOUNTER_BEGINDATE<=?";
            ps=oc_conn.prepareStatement(sQuery);
            ps.setString(1,serviceid);
            ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
            ps.setDate(3,new java.sql.Date(new java.util.Date().getTime()));
            rs = ps.executeQuery();
            while(rs.next()){
                patients.add(rs.getString("OC_ENCOUNTER_PATIENTUID"));
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return patients;
    }

    public static List getPatientsInEncounterServiceUID(String simmatnew,String sArchiveFileCode,String snatreg,String sName,String sFirstname,String sDateOfBirth,String sEncounterServiceUID, String sPersonID, String sDistrict){
        PreparedStatement ps = null;
        ResultSet rs = null;

        //Vector vResults = new Vector();
        List lResults = new ArrayList();

        String sSQLSelect = " SELECT distinct searchname,OC_ENCOUNTER_PATIENTUID,a.personid, immatnew, natreg, lastname, firstname, gender, dateofbirth, pension";
        String sSQLFrom   = " FROM AdminView a, OC_ENCOUNTERS_VIEW o ";
        String sSQLWhere  = " (OC_ENCOUNTER_ENDDATE IS NULL OR OC_ENCOUNTER_ENDDATE >= ?) AND" +
                            " (OC_ENCOUNTER_TYPE = 'admission' OR OC_ENCOUNTER_TYPE = 'visit') AND" +
                            " OC_ENCOUNTER_PATIENTUID = " + MedwanQuery.getInstance().convert("varchar(255)","a.personid") + " AND";

        if (simmatnew.trim().length()>0) {
            simmatnew = simmatnew.replaceAll("\\.","");
            simmatnew = simmatnew.replaceAll("-","");
            simmatnew = simmatnew.replaceAll("/","");
            sSQLWhere += " immatnew = '"+simmatnew+"' AND";
        }
        /*
        if (simmatold.trim().length()>0) {
            sSQLWhere += " immatold = '"+simmatold+"' AND";
        } */
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

        if (sArchiveFileCode.trim().length()>0) {
            String lowerArchiverFileCode = ScreenHelper.getConfigParam("lowerCompare","archiveFileCode",oc_conn);
            sSQLWhere += " "+lowerArchiverFileCode+" LIKE '"+sArchiveFileCode.toLowerCase()+"%' AND";
        }

        if (snatreg.trim().length()>0) {
            sSQLWhere += " natreg = '"+snatreg+"' AND";
        }

        if (sPersonID.trim().length()>0) {
            sSQLWhere += " a.personid = '"+sPersonID+"' AND";
        }

        sName = ScreenHelper.normalizeSpecialCharacters(sName);
        sFirstname = ScreenHelper.normalizeSpecialCharacters(sFirstname);

        if ((sName.trim().length()>0)&&(sFirstname.trim().length()>0)) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%,"+sFirstname.toUpperCase()+"%' AND";
        }
        else if (sName.trim().length()>0) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%' AND";
        }
        else if (sFirstname.trim().length()>0) {
            sSQLWhere += " searchname like '%,"+sFirstname.toUpperCase()+"%' AND";
        }

        if (sDateOfBirth.trim().length()==10) {
            if (sDateOfBirth.indexOf("/")>0) {
                sSQLWhere += " dateofbirth = ? AND";
            }
            else {
                sDateOfBirth = "";
            }
        }
        else {
            sDateOfBirth = "";
        }

        if (sEncounterServiceUID.trim().length()>0) {
            if (MedwanQuery.getInstance().getConfigString("showChildServices").toLowerCase().equals("true")) {
                sEncounterServiceUID = "'"+sEncounterServiceUID+"'"+AdminPerson.getChildServices(sEncounterServiceUID);
                sSQLWhere += " OC_ENCOUNTER_SERVICEUID IN ("+sEncounterServiceUID+") AND";
            }
            else {
                sSQLWhere += " OC_ENCOUNTER_SERVICEUID  = '"+sEncounterServiceUID+"' AND";
            }
        }
        if(sDistrict.trim().length()>0){
            sSQLFrom+=",PrivateView p ";
            sSQLWhere+=" a.personid=p.personid AND p.district = '"+sDistrict+"' AND";
        }
        try{
            if (sSQLWhere.trim().length()>0) {
                String sSelect = sSQLSelect+" "+sSQLFrom+" WHERE "+sSQLWhere.substring(0,sSQLWhere.length()-3)+
                          " ORDER BY searchname ";
                ps = oc_conn.prepareStatement(sSelect.trim());
                ps.setDate(1,new java.sql.Date(new java.util.Date().getTime())); // now

                if (sDateOfBirth.trim().length()>0) {
                    java.sql.Date dDate=null;
                    try {
                        dDate=new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDateOfBirth).getTime());
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
                    ps.setDate(2,dDate);
                }
                rs = ps.executeQuery();

                AdminPerson tempPat;
                while(rs.next()){
                    tempPat = new AdminPerson();
                    //tempPat.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                    tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                    //tempPat.setPersonid(ScreenHelper.checkString(rs.getString("personid")));
                    tempPat.ids.addElement(new AdminID("ImmatNew",ScreenHelper.checkString(rs.getString("immatnew"))));
                    //tempPat.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                    tempPat.ids.addElement(new AdminID("NatReg",ScreenHelper.checkString(rs.getString("natreg"))));
                    //tempPat.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                    tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                    //tempPat.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                    tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                    //tempPat.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                    tempPat.gender = ScreenHelper.checkString(rs.getString("gender"));
                    //tempPat.setGender(ScreenHelper.checkString(rs.getString("gender")));
                    tempPat.pension = ScreenHelper.checkString(rs.getString("pension"));
                    //tempPat.setPension(ScreenHelper.checkString(rs.getString("pension")));
                    if(rs.getDate("dateofbirth") != null){
                        tempPat.dateOfBirth = new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dateofbirth"));
                    }else{
                        tempPat.dateOfBirth = "";
                    }
                    //tempPat.setDateofbirth(rs.getDate("dateofbirth"));

                    lResults.add(tempPat);
                }

                rs.close();
                ps.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return lResults;
    }

    public static List getAllPatients(String simmatnew,String sArchiveFileCode,String snatreg,String sName,String sFirstname,String sDateOfBirth, String sPersonID, String sDistrict){
        PreparedStatement ps = null;
        ResultSet rs = null;
        //Vector vResults = new Vector();
        List lResultList = new ArrayList();

        String sSQLSelect = " SELECT DISTINCT a.searchname, a.personid, a.immatnew, a.natreg, a.lastname, a.firstname, a.gender, a.dateofbirth, a.pension";
        String sSQLFrom   = " FROM AdminView a";
        String sSQLWhere  = " 1=1 AND";

        if (simmatnew.trim().length()>0) {
            //simmatnew = simmatnew.replaceAll("\\.","");
            //simmatnew = simmatnew.replaceAll("-","");
            //simmatnew = simmatnew.replaceAll("/","");
            sSQLWhere += " immatnew like '"+simmatnew+"%' AND";
        }

        /*if (simmatold.trim().length()>0) {
            sSQLWhere += " immatold = '"+simmatold+"' AND";
        }*/
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

        if (sArchiveFileCode.trim().length()>0) {
            String lowerArchiverFileCode = ScreenHelper.getConfigParam("lowerCompare","archiveFileCode",oc_conn);
            sSQLWhere += " "+lowerArchiverFileCode+" LIKE '"+sArchiveFileCode.toLowerCase()+"' AND";
        }

        if (snatreg.trim().length()>0) {
            sSQLWhere += " natreg like '"+snatreg+"%' AND";
        }

        if (sPersonID.trim().length()>0) {
            sSQLWhere += " a.personid = "+sPersonID+" AND";
        }

        if (sDistrict.trim().length()>0){
            sSQLFrom += ", AdminPrivate p";
            sSQLWhere += " p.personid = a.personid AND district = '"+sDistrict+"' AND";
        }

        sName = ScreenHelper.normalizeSpecialCharacters(sName);
        sFirstname = ScreenHelper.normalizeSpecialCharacters(sFirstname);

        if ((sName.trim().length()>0)&&(sFirstname.trim().length()>0)) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%,"+sFirstname.toUpperCase()+"%' AND";
        }
        else if (sName.trim().length()>0) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%' AND";
        }
        else if (sFirstname.trim().length()>0) {
            sSQLWhere += " searchname like '%,"+sFirstname.toUpperCase()+"%' AND";
        }

        if (sDateOfBirth.trim().length()==10) {
            if (sDateOfBirth.indexOf("/")>0) {
                sSQLWhere += " dateofbirth = ? AND";
            }
            else {
                sDateOfBirth = "";
            }
        }
        else {
            sDateOfBirth = "";
        }

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if (sSQLWhere.trim().length()>0) {
                String sSelect = sSQLSelect+" "+sSQLFrom+" WHERE "+sSQLWhere.substring(0,sSQLWhere.length()-3)+
                          " ORDER BY searchname ";
                ps = ad_conn.prepareStatement(sSelect.trim());

                if (sDateOfBirth.trim().length()>0) {
                    ps.setDate(1,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDateOfBirth.replaceAll("-","/")).getTime()));
                }
                rs = ps.executeQuery();

                AdminPerson tempPat;
                while(rs.next()){
                    tempPat = new AdminPerson();
                    //tempPat.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                    tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                    //tempPat.setPersonid(ScreenHelper.checkString(rs.getString("personid")));
                    tempPat.ids.addElement(new AdminID("ImmatNew",ScreenHelper.checkString(rs.getString("immatnew"))));
                    //tempPat.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                    tempPat.ids.addElement(new AdminID("NatReg",ScreenHelper.checkString(rs.getString("natreg"))));
                    //tempPat.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                    tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                    //tempPat.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                    tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                    //tempPat.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                    tempPat.gender = ScreenHelper.checkString(rs.getString("gender"));
                    //tempPat.setGender(ScreenHelper.checkString(rs.getString("gender")));
                    tempPat.pension = ScreenHelper.checkString(rs.getString("pension"));
                    //tempPat.setPension(ScreenHelper.checkString(rs.getString("pension")));
                    if(rs.getDate("dateofbirth") != null){
                        tempPat.dateOfBirth = new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dateofbirth"));
                    }else{
                        tempPat.dateOfBirth = "";
                    }
                    //tempPat.setDateofbirth(rs.getDate("dateofbirth"));
                    lResultList.add(tempPat);
                    //vResults.addElement(tempPat);
                }

                rs.close();
                ps.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return lResultList;
    }
    public static List getAllPatients(String simmatnew,String sArchiveFileCode,String snatreg,String sName,String sFirstname,String sDateOfBirth, String sPersonID, String sDistrict, int iMaxResults){
        PreparedStatement ps = null;
        ResultSet rs = null;
        //Vector vResults = new Vector();
        List lResultList = new ArrayList();

        String sSQLSelect = " SELECT DISTINCT a.searchname, a.personid, a.immatnew, a.natreg, a.lastname, a.firstname, a.gender, a.dateofbirth, a.pension";
        String sSQLFrom   = " FROM AdminView a";
        String sSQLWhere  = " 1=1 AND";

        if (simmatnew.trim().length()>0) {
            //simmatnew = simmatnew.replaceAll("\\.","");
            //simmatnew = simmatnew.replaceAll("-","");
            //simmatnew = simmatnew.replaceAll("/","");
            sSQLWhere += " immatnew like '"+simmatnew+"%' AND";
        }

        /*if (simmatold.trim().length()>0) {
            sSQLWhere += " immatold = '"+simmatold+"' AND";
        }*/
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

        if (sArchiveFileCode.trim().length()>0) {
            String lowerArchiverFileCode = ScreenHelper.getConfigParam("lowerCompare","archiveFileCode",oc_conn);
            sSQLWhere += " "+lowerArchiverFileCode+" LIKE '"+sArchiveFileCode.toLowerCase()+"' AND";
        }

        if (snatreg.trim().length()>0) {
            sSQLWhere += " natreg like '"+snatreg+"%' AND";
        }

        if (sPersonID.trim().length()>0) {
            sSQLWhere += " a.personid = "+sPersonID+" AND";
        }

        if (sDistrict.trim().length()>0){
            sSQLFrom += ", AdminPrivate p";
            sSQLWhere += " p.personid = a.personid AND district = '"+sDistrict+"' AND";
        }

        sName = ScreenHelper.normalizeSpecialCharacters(sName);
        sFirstname = ScreenHelper.normalizeSpecialCharacters(sFirstname);

        if ((sName.trim().length()>0)&&(sFirstname.trim().length()>0)) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%,"+sFirstname.toUpperCase()+"%' AND";
        }
        else if (sName.trim().length()>0) {
            sSQLWhere += " searchname like '"+sName.toUpperCase()+"%' AND";
        }
        else if (sFirstname.trim().length()>0) {
            sSQLWhere += " searchname like '%,"+sFirstname.toUpperCase()+"%' AND";
        }

        if (sDateOfBirth.trim().length()==10) {
            if (sDateOfBirth.indexOf("/")>0) {
                sSQLWhere += " dateofbirth = ? AND";
            }
            else {
                sDateOfBirth = "";
            }
        }
        else {
            sDateOfBirth = "";
        }

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if (sSQLWhere.trim().length()>0) {
                String sSelect = sSQLSelect+" "+sSQLFrom+" WHERE "+sSQLWhere.substring(0,sSQLWhere.length()-3)+
                          " ORDER BY searchname ";
                ps = ad_conn.prepareStatement(sSelect.trim());

                if (sDateOfBirth.trim().length()>0) {
                    ps.setDate(1,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDateOfBirth.replaceAll("-","/")).getTime()));
                }
                rs = ps.executeQuery();

                AdminPerson tempPat;
                while(rs.next() && lResultList.size()<=iMaxResults){
                    tempPat = new AdminPerson();
                    //tempPat.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                    tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                    //tempPat.setPersonid(ScreenHelper.checkString(rs.getString("personid")));
                    tempPat.ids.addElement(new AdminID("ImmatNew",ScreenHelper.checkString(rs.getString("immatnew"))));
                    //tempPat.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                    tempPat.ids.addElement(new AdminID("NatReg",ScreenHelper.checkString(rs.getString("natreg"))));
                    //tempPat.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                    tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                    //tempPat.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                    tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                    //tempPat.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                    tempPat.gender = ScreenHelper.checkString(rs.getString("gender"));
                    //tempPat.setGender(ScreenHelper.checkString(rs.getString("gender")));
                    tempPat.pension = ScreenHelper.checkString(rs.getString("pension"));
                    //tempPat.setPension(ScreenHelper.checkString(rs.getString("pension")));
                    if(rs.getDate("dateofbirth") != null){
                        tempPat.dateOfBirth = new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dateofbirth"));
                    }else{
                        tempPat.dateOfBirth = "";
                    }
                    //tempPat.setDateofbirth(rs.getDate("dateofbirth"));
                    lResultList.add(tempPat);
                    //vResults.addElement(tempPat);
                }

                rs.close();
                ps.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return lResultList;
    }

    public static List getLimitedPatients(String sName,String sFirstname, int iMaxRows){
           PreparedStatement ps = null;
           ResultSet rs = null;
           //Vector vResults = new Vector();
           List lResultList = new ArrayList();


           String sSQLSelect = " SELECT "+MedwanQuery.getInstance().topFunction(""+iMaxRows)+" searchname,personid, lastname, firstname";
           String sSQLFrom   = " FROM AdminView a";
           String sSQLWhere  = " 1=1 AND";


           sName = ScreenHelper.normalizeSpecialCharacters(sName);
           sFirstname = ScreenHelper.normalizeSpecialCharacters(sFirstname);

           if ((sName.trim().length()>0)&&(sFirstname.trim().length()>0)) {
               sSQLWhere += " searchname like '"+sName.toUpperCase()+"%,"+sFirstname.toUpperCase()+"%' AND";
           }
           else if (sName.trim().length()>0) {
               sSQLWhere += " searchname like '"+sName.toUpperCase()+"%' AND";
           }
           else if (sFirstname.trim().length()>0) {
               sSQLWhere += " searchname like '%,"+sFirstname.toUpperCase()+"%' AND";
           }

           Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
           try{
               if (sSQLWhere.trim().length()>0) {
                   String sSelect = sSQLSelect+" "+sSQLFrom+" WHERE "+sSQLWhere.substring(0,sSQLWhere.length()-3);

                   if (sFirstname.length()>0){
                        sSelect += " ORDER BY firstname, searchname ";
                   }
                   else {
                        sSelect += " ORDER BY searchname ";
                   }
                   sSelect +=MedwanQuery.getInstance().limitFunction(""+iMaxRows);
                   ps = oc_conn.prepareStatement(sSelect.trim());

                   rs = ps.executeQuery();

                   AdminPerson tempPat;
                   while(rs.next()){
                       tempPat = new AdminPerson();
                       tempPat.personid = ScreenHelper.checkString(rs.getString("personid"));
                       tempPat.lastname = ScreenHelper.checkString(rs.getString("lastname"));
                       tempPat.firstname = ScreenHelper.checkString(rs.getString("firstname"));
                       lResultList.add(tempPat);
                   }

                   rs.close();
                   ps.close();
               }
           }catch(Exception e){
               e.printStackTrace();
           }finally{
               try{
                   if(rs!=null)rs.close();
                   if(ps!=null)ps.close();
                   oc_conn.close();
               }catch(Exception e){
                   e.printStackTrace();
               }
           }

           return lResultList;
       }

    private static String getChildServices(String sParentServiceID) {
        String sReturnServiceIDs = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            String sTmpServiceID;
            String sTmpSelect = "SELECT serviceid FROM Services WHERE serviceparentid = ?";
            ps = ad_conn.prepareStatement(sTmpSelect);
            ps.setString(1,sParentServiceID);
            rs = ps.executeQuery();

            while (rs.next()) {
                sTmpServiceID = ScreenHelper.checkString(rs.getString("serviceid"));
                sReturnServiceIDs+= ",'"+sTmpServiceID+"'";
                sReturnServiceIDs+= getChildServices(sTmpServiceID);
            }
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println(e.getMessage());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return sReturnServiceIDs;
    }

    public static boolean copyActiveToHistory(String personid){
        PreparedStatement ps = null,ps2 = null;
        ResultSet rs = null;

        boolean isFound = false;
        String sSelect = "SELECT personid, immatold, immatnew, candidate, lastname,firstname," +
                " gender, dateofbirth, comment, sourceid, language, engagement, pension,statute, claimant, searchname, updatetime," +
                " claimant_expiration, native_country,native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity," +
                " code_inactivity, update_status, person_type, situation_end_of_service, updateuserid," +
                " comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid" +
                " FROM Admin WHERE personid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(personid));
            rs = ps.executeQuery();

            if(rs.next()){
                isFound = true;
                // insert Admin in AdminHistory (note that the columns have a different order in both tables !)
                StringBuffer sbQuery = new StringBuffer();
                sbQuery.append("INSERT INTO AdminHistory(personid, immatold, immatnew, candidate, lastname,")
                       .append("  firstname, gender, dateofbirth, comment, sourceid, language, engagement, pension,")
                       .append("  statute, claimant, searchname, updatetime, claimant_expiration, native_country,")
                       .append("  native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,")
                       .append("  code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,")
                       .append("  comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid) ")
                       .append(" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"); // 38
                ps2 = ad_conn.prepareStatement(sbQuery.toString());

                Object obj;
                String columnType;

                // get adminHistory metadata : put column types in a vector
                Vector adminHistoryMetaData = new Vector();
                DatabaseMetaData databaseMetaData = ad_conn.getMetaData();
                ResultSet rsMD = databaseMetaData.getColumns(null,null,"AdminHistory",null);
                String type;

                while(rsMD.next()){
                    type = rsMD.getString("TYPE_NAME");

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

                rsMD.close();

                // set questionmarks in query
                for(int i=1; i<=38; i++){
                    obj = rs.getObject(i);

                    if(obj==null){
                        columnType = (String)adminHistoryMetaData.elementAt((i-1));

                             if(columnType.equals("int"))    ps2.setInt(i,0);
                        else if(columnType.equals("String")) ps2.setString(i,"");
                        else if(columnType.equals("Date"))   ps2.setTimestamp(i,new Timestamp(new java.util.Date().getTime())); // now
                    }
                    else{
                        ps2.setObject(i,obj);
                    }
                }

                // set updatetime = now (~deletetime)
                ps2.setTimestamp(17,new Timestamp(new java.util.Date().getTime()));
                ps2.executeUpdate();
                ps2.close();

                // delete Admin
                ps2 = ad_conn.prepareStatement("DELETE FROM Admin WHERE personid = ?");
                ps2.setInt(1,Integer.parseInt(personid));
                ps2.executeUpdate();
                ps2.close();
            }
            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                if(ps2!=null)ps2.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return isFound;
    }

    public static boolean copyActiveToHistoryNoDelete(String personid){
        PreparedStatement ps2 = null;

        boolean isFound = true;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            // insert Admin in AdminHistory (note that the columns have a different order in both tables !)
            StringBuffer sbQuery = new StringBuffer();
            sbQuery.append("INSERT INTO AdminHistory(personid, immatold, immatnew, candidate, lastname,")
                   .append("  firstname, gender, dateofbirth, comment, sourceid, language, engagement, pension,")
                   .append("  statute, claimant, searchname, updatetime, claimant_expiration, native_country,")
                   .append("  native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,")
                   .append("  code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,")
                   .append("  comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid) ")
                   .append("SELECT personid, immatold, immatnew, candidate, lastname,firstname,")
			       .append(" gender, dateofbirth, comment, sourceid, language, engagement, pension,statute, claimant, searchname, updatetime,")
			       .append(" claimant_expiration, native_country,native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,")
			       .append(" code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,")
			       .append(" comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid")
			       .append(" FROM Admin WHERE personid = ?");
            ps2 = ad_conn.prepareStatement(sbQuery.toString());
            ps2.setInt(1,Integer.parseInt(personid));
            ps2.executeUpdate();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps2!=null)ps2.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return isFound;
    }

    public static Vector searchDoubles(int iSelectedFields){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hAdminInfo;
        Vector vDoubles = new Vector();

        StringBuffer sbQuery = new StringBuffer();

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            sbQuery.append("SELECT a1.personid, a2.personid, a1.lastname, a1.firstname, a1.dateofbirth, a1.immatnew, a2.immatnew")
               .append(" FROM Admin a1, Admin a2 ");

            // search on immatnew
            if(iSelectedFields==1){
                sbQuery.append("WHERE a1.immatnew = a2.immatnew");
            }
            // search on searchname AND dateOfBirth
            else if(iSelectedFields==2){
                sbQuery.append("WHERE a1.searchname = a2.searchname")
                       .append(" AND a1.dateofbirth = a2.dateofbirth");
            }

            sbQuery.append(" AND a1.personid != a2.personid")
                   .append(" ORDER BY a1.searchname");

            ps = ad_conn.prepareStatement(sbQuery.toString());
            rs = ps.executeQuery();

            while(rs.next()){
                hAdminInfo = new Hashtable();
                hAdminInfo.put("pid1",ScreenHelper.checkString(rs.getString(1)));
                hAdminInfo.put("pid2",ScreenHelper.checkString(rs.getString(2)));
                hAdminInfo.put("lastname",ScreenHelper.checkString(rs.getString(3)));
                hAdminInfo.put("firstname",ScreenHelper.checkString(rs.getString(4)));
                hAdminInfo.put("dateofbirth",ScreenHelper.checkString(ScreenHelper.getSQLDate(rs.getDate(5))));
                hAdminInfo.put("immatnew1",ScreenHelper.checkString(rs.getString(6)));
                hAdminInfo.put("immatnew2",ScreenHelper.checkString(rs.getString(7)));

                vDoubles.addElement(hAdminInfo);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vDoubles;
    }

    public static String[] getPersonDetails(String sPersonid,String[] personDetails){
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuffer sSelect = new StringBuffer();
        sSelect.append(" SELECT personid,natreg,immatold,immatnew,candidate,lastname,firstname,")
               .append(" gender,dateofbirth,comment,sourceid,language,engagement,pension,")
               .append(" statute,claimant,updatetime,claimant_expiration,native_country,native_town,")
               .append(" motive_end_of_service,startdate_inactivity,enddate_inactivity,")
               .append(" code_inactivity,update_status,person_type,situation_end_of_service,")
               .append(" updateuserid,comment1,comment2,comment3,comment4,comment5,native_country,")
               .append(" middlename,begindate,enddate")
               .append(" FROM Admin WHERE personid = ?");

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect.toString());
            ps.setInt(1,Integer.parseInt(sPersonid));
            rs = ps.executeQuery();

            if(rs.next()){
                for(int i=1; i<personDetails.length; i++){
                // dates should be formatted
                if(i==9 || i==17 || i==18 || i==22 || i==23 || i==36 || i==37){
                    personDetails[i] = ScreenHelper.checkString(ScreenHelper.getSQLDate(rs.getDate(i)));
                }
                else{
                    personDetails[i] = ScreenHelper.checkString(rs.getString(i));
                }
            }
            }

            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return personDetails;
    }

    public static Hashtable checkDoublesByOR(Hashtable hSelect,String sQueryAddon){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hResults = new Hashtable();
        Enumeration e;
        String sSelect;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if (hSelect.size()>0) {
                sSelect = "SELECT personid, lastname, firstname, dateofbirth FROM Admin WHERE ";

                if(sQueryAddon.trim().length() > 0){
                    sSelect += " ( ";
                }
                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sSelect+= (String)e.nextElement();
                }

                // remove OR
                sSelect = sSelect.substring(0,sSelect.length()-3);

                ps = ad_conn.prepareStatement(sSelect);
                int iIndex = 1;
                String sKey, sValue;

                // set values
                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sKey = (String)e.nextElement();
                    sValue = (String)hSelect.get(sKey);

                    if (sKey.equalsIgnoreCase(" dateofbirth = ? OR")){
                        ps.setDate(iIndex,new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sValue).getTime()));
                    }
                    else {
                        ps.setString(iIndex,sValue);
                    }

                    iIndex++;
                }
                if(sQueryAddon.trim().length() > 0){
                    sSelect += " ) " + sQueryAddon;
                }
                rs = ps.executeQuery();

                if(rs.next()){
                    hResults.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                    hResults.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                    hResults.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                    hResults.put("dateofbirth",ScreenHelper.getSQLTimeStamp(rs.getTimestamp("dateofbirth")));
                }
                rs.close();
                ps.close();
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception ex){
                ex.printStackTrace();
            }
        }
        return hResults;
    }

    public static Hashtable checkDoublesByAND(Hashtable hSelect){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hResults = new Hashtable();

        Enumeration e;
        String sSelect;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if (hSelect.size()>0) {
                sSelect = "SELECT personid,lastname,firstname,dateofbirth FROM Admin WHERE ";

                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sSelect+= (String)e.nextElement();
                }

                // remove AND
                sSelect = sSelect.substring(0,sSelect.length()-4);

                ps = ad_conn.prepareStatement(sSelect);
                int iIndex = 1;
                String sKey, sValue;

                // set values
                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sKey = (String)e.nextElement();
                    sValue = (String)hSelect.get(sKey);

                    if (sKey.equalsIgnoreCase(" dateofbirth = ? AND")){
                        ps.setDate(iIndex,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sValue).getTime()));
                    }
                    else {
                        ps.setString(iIndex,sValue.toUpperCase());
                    }

                    iIndex++;
                }

                // execute query
                rs = ps.executeQuery();
                if (rs.next()) {
                    hResults.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                    hResults.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                    hResults.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                    hResults.put("dateofbirth",ScreenHelper.getSQLTimeStamp(rs.getTimestamp("dateofbirth")));
                }

                rs.close();
                ps.close();
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception ex){
                ex.printStackTrace();
            }
        }
        return hResults;
    }

    public static Vector multipleCheckDoublesByAND(Hashtable hSelect){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hResults = new Hashtable();
        Vector vResults = new Vector();
        Enumeration e;
        String sSelect;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if (hSelect.size()>0) {
                sSelect = "SELECT personid,lastname,firstname,dateofbirth FROM Admin WHERE ";

                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sSelect+= (String)e.nextElement();
                }

                // remove AND
                sSelect = sSelect.substring(0,sSelect.length()-4);

                ps = ad_conn.prepareStatement(sSelect);
                int iIndex = 1;
                String sKey, sValue;

                // set values
                e = hSelect.keys();
                while (e.hasMoreElements()){
                    sKey = (String)e.nextElement();
                    sValue = (String)hSelect.get(sKey);

                    if (sKey.equalsIgnoreCase(" dateofbirth = ? AND")){
                        ps.setDate(iIndex,new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sValue).getTime()));
                    }
                    else {
                        ps.setString(iIndex,sValue);
                    }

                    iIndex++;
                }

                // execute query
                rs = ps.executeQuery();
                while (rs.next()) {
                    hResults = new Hashtable();
                    hResults.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                    hResults.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                    hResults.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                    hResults.put("dateofbirth",ScreenHelper.getSQLTimeStamp(rs.getTimestamp("dateofbirth")));
                    vResults.addElement(hResults);
                }

                rs.close();
                ps.close();
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception ex){
                ex.printStackTrace();
            }
        }
        return vResults;
    }

    public static Vector getPrivateId(String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();

        String sSelect = "SELECT privateid FROM PrivateView WHERE personid = ? ORDER BY start DESC";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonId));
            rs = ps.executeQuery();

            while(rs.next()){
                vResults.addElement(ScreenHelper.checkString(rs.getString("privateid")));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public static Vector searchPatients(String sSelectLastname,String sSelectFirstname,String sFindGender,String sFindDOB,boolean bIsUser){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();

        Hashtable hInfo;

        String sSelect = "";

        try{
            if ((sSelectLastname.trim().length()>0) && (sSelectFirstname.trim().length()>0)) {
                sSelect+= " searchname LIKE '"+sSelectLastname.toUpperCase()+"%,"+sSelectFirstname.toUpperCase()+"%' AND";
            }
            else if (sSelectLastname.trim().length()>0) {
                sSelect+= " searchname LIKE '"+sSelectLastname.toUpperCase()+"%,%' AND";
            }
            else if (sSelectFirstname.trim().length()>0) {
                sSelect+= " searchname LIKE '%,"+sSelectFirstname.toUpperCase()+"%' AND";
            }

            if(sFindGender.trim().length() > 0){
                sSelect+= " gender = '"+sFindGender+"' AND";
            }

            // check if sFindDOB has a valid date format
            if(sFindDOB.length() > 0){
                try{
                    sFindDOB = sFindDOB.replaceAll("-","/");
                    new SimpleDateFormat("dd/MM/yyyy").parse(sFindDOB);
                    sSelect+= " dateofbirth = ? AND";
                }
                catch(Exception e){
                    sFindDOB = "";
                }
            }

            // complete query
            String sQuery;
            if(sSelect.length()>0 || bIsUser) {
                if (sSelect.endsWith("AND")){
                    sSelect = sSelect.substring(0,sSelect.length()-3);
                }
                if(bIsUser){
                    sQuery = "SELECT b.userid, a.personid, a.dateofbirth, a.gender, a.lastname, a.firstname, a.immatnew"+
                              " FROM Admin a, Users b"+
                              "  WHERE a.personid=b.personid";
                              if(sSelect.length() > 0) sQuery+= " AND ";
                    sQuery+= " ORDER BY searchname";
                }
                else {
                    sQuery = "SELECT personid, dateofbirth, gender, lastname, firstname, immatnew"+
                              " FROM Admin"+
                              "  WHERE "+sSelect+
                              " ORDER BY searchname";
                }

            	Connection lad_conn = MedwanQuery.getInstance().getAdminConnection();
                ps = lad_conn.prepareStatement(sQuery);
                if(sFindDOB.trim().length()>0){
                    ps.setString(1,ScreenHelper.getSQLDate(sFindDOB).toString());
                }

                rs = ps.executeQuery();

                SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
                while(rs.next()){
                    hInfo = new Hashtable();
                    if(bIsUser){
                        hInfo.put("userid",ScreenHelper.checkString(rs.getString("userid")));
                    }
                    hInfo.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                    hInfo.put("dateofbirth",ScreenHelper.checkString(ScreenHelper.getSQLDate(rs.getDate("dateofbirth"))));
                    hInfo.put("gender",ScreenHelper.checkString(rs.getString("gender")));
                    hInfo.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                    hInfo.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                    hInfo.put("immatnew",ScreenHelper.checkString(rs.getString("immatnew")));

                    vResults.addElement(hInfo);
                }
                rs.close();
                ps.close();
                lad_conn.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return vResults;
    }

    //--- GET AGE ------------------------------------------------------------------------------------
    public int getAge(){
        int age = -1;

        if(this.dateOfBirth.length() > 0){
            try{
                java.util.Date dob = new SimpleDateFormat("dd/MM/yyyy").parse(this.dateOfBirth);
                GregorianCalendar dateOfBirth = new GregorianCalendar();
                dateOfBirth.setTime(dob);

                GregorianCalendar now = new GregorianCalendar();

                //*** check wether the birthday in the current year is passed ***
                // check month
                if(now.get(Calendar.MONTH) < dateOfBirth.get(Calendar.MONTH)){
                    // dob not passed
                    age = now.get(Calendar.YEAR) - dateOfBirth.get(Calendar.YEAR) - 1;
                }
                else if(now.get(Calendar.MONTH) > dateOfBirth.get(Calendar.MONTH)){
                    // dob passed
                    age = now.get(Calendar.YEAR) - dateOfBirth.get(Calendar.YEAR);
                }
                else if(now.get(Calendar.MONTH) == dateOfBirth.get(Calendar.MONTH)){
                    // check day
                    if(now.get(Calendar.DAY_OF_MONTH) < dateOfBirth.get(Calendar.DAY_OF_MONTH)){
                        // dob not passed
                        age = now.get(Calendar.YEAR) - dateOfBirth.get(Calendar.YEAR) - 1;
                    }
                    else if(now.get(Calendar.DAY_OF_MONTH) >= dateOfBirth.get(Calendar.DAY_OF_MONTH)){
                        // dob passed
                        age = now.get(Calendar.YEAR) - dateOfBirth.get(Calendar.YEAR);
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return age;
    }

    public static Vector getUpdateTimes(java.sql.Date dBegin, java.sql.Date dEnd, int iUserid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUpdateTimes = new Vector();

        String sSelect = "Select updatetime FROM Admin WHERE updatetime BETWEEN ? AND ? AND updateuserid = ? ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setDate(1, dBegin);
            ps.setDate(2, dEnd);
            ps.setInt(3, iUserid);

            rs = ps.executeQuery();
            while(rs.next()){
                vUpdateTimes.addElement(rs.getDate("updatetime"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vUpdateTimes;
    }

    public static String getEnclosedFileId(String id){
        PreparedStatement ps =null;
        ResultSet rs = null;

        String sSelect = " SELECT a.immatnew FROM Admin a, AdminExtends e"+
                         " WHERE a.personid = e.personid"+
                         "  AND e.labelid = 'includedin'"+
                         "  AND e.extendvalue = ?";

        String sReturn = "";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,id);
            rs = ps.executeQuery();

            if(rs.next()){
                sReturn = ScreenHelper.checkString(rs.getString("immatnew"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return sReturn;
    }

    public static String getPersonIdByImmatnew(String sImmatnew){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT personid FROM Admin WHERE immatnew = ?";

        String sPersonid = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sImmatnew);
            rs = ps.executeQuery();

            if(rs.next()){
                sPersonid = ScreenHelper.checkString(rs.getString("personid"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return sPersonid;
    }

    public static String getPersonIdByNatReg(String sNatReg){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT personid FROM Admin WHERE natreg = ?";

        String sPersonid = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sNatReg);
            rs = ps.executeQuery();

            if(rs.next()){
                sPersonid = ScreenHelper.checkString(rs.getString("personid"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return sPersonid;
    }

    /*
        Query customized for patientEditSavePopup.jsp
     */
    public static String getPersonIdBySearchNameDateofBirth(Hashtable hSelect){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT personid FROM Admin WHERE ";

        Enumeration enum2 = hSelect.keys();
        while (enum2.hasMoreElements()) {
            sSelect += (String) enum2.nextElement();
        }

        // remove AND
        sSelect = sSelect.substring(0, sSelect.length() - 4);

        String sPersonId = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            int iIndex = 1;
            String sKey, sValue;

            // set values
            enum2 = hSelect.keys();
            while (enum2.hasMoreElements()) {
                sKey = (String) enum2.nextElement();
                sValue = (String) hSelect.get(sKey);

                if (sKey.equalsIgnoreCase(" dateofbirth = ? AND")) {
                    ps.setDate(iIndex, new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sValue).getTime()));
                } else {
                    ps.setString(iIndex, sValue);
                }

                iIndex++;
            }

            // execute query
            rs = ps.executeQuery();

            if(rs.next()){
                sPersonId = ScreenHelper.checkString(rs.getString("personid"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return sPersonId;
    }

    public static Vector getImmatNewPersonIdByImmatNew(String sImmatNew){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT immatnew, personid FROM Admin WHERE immatnew = ?";

        Hashtable hData = new Hashtable();
        Vector vData = new Vector();
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sImmatNew);
            rs = ps.executeQuery();

            while(rs.next()){
                hData = new Hashtable();
                hData.put("immatnew",ScreenHelper.checkString(rs.getString("immatnew")));
                hData.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                vData.addElement(hData);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vData;
    }

    public static Vector getImmatNewPersonIdByNatReg(String sNatReg){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT immatnew, personid FROM Admin WHERE natreg = ?";

        Hashtable hData = new Hashtable();
        Vector vData = new Vector();
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sNatReg);
            rs = ps.executeQuery();

            while(rs.next()){
                hData = new Hashtable();
                hData.put("immatnew",ScreenHelper.checkString(rs.getString("immatnew")));
                hData.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                vData.addElement(hData);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vData;
    }

    public java.util.Date isDead(){
    	java.util.Date death=null;
    	PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * from oc_encounters where oc_encounter_patientuid=? and oc_encounter_outcome='dead' order by oc_encounter_enddate desc";

    	Connection ad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,this.personid);
            rs = ps.executeQuery();

            if(rs.next()){
            	death=rs.getDate("oc_encounter_enddate");
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return death;
    }

    /*
        Query customized for patientEditSavePopup.jsp
     */
    public static Vector getImmatNewPersonIdBySearchNameDateofBirth(Hashtable hSelect){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT immatnew,personid FROM Admin WHERE ";

        Enumeration enum2 = hSelect.keys();
        while (enum2.hasMoreElements()) {
            sSelect += (String) enum2.nextElement();
        }

        // remove AND
        sSelect = sSelect.substring(0, sSelect.length() - 4);

        Vector vData = new Vector();

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            int iIndex = 1;
            String sKey, sValue;

            // set values
            enum2 = hSelect.keys();
            while (enum2.hasMoreElements()) {
                sKey = (String) enum2.nextElement();
                sValue = (String) hSelect.get(sKey);

                if (sKey.equalsIgnoreCase(" dateofbirth = ? AND")) {
                    ps.setDate(iIndex, new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sValue).getTime()));
                } else {
                    ps.setString(iIndex, sValue);
                }

                iIndex++;
            }

            // execute query
            rs = ps.executeQuery();
            Hashtable hData;
            if(rs.next()){
                hData = new Hashtable();
                hData.put("immatnew",ScreenHelper.checkString(rs.getString("immatnew")));
                hData.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                vData.addElement(hData);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vData;
    }

    public boolean saveMiniToDB(Connection connection) {
        boolean bReturn = true;
        String sSelect = "";

        try {
            PreparedStatement ps;
            String sPersonID = "", sSearchname, sLastname, sFirstname;

            sLastname = ScreenHelper.checkSpecialCharacters(lastname);
            sFirstname = ScreenHelper.checkSpecialCharacters(firstname);
            sSearchname = sLastname.toUpperCase().trim()+","+sFirstname.toUpperCase().trim();
            sSearchname = ScreenHelper.normalizeSpecialCharacters(sSearchname);

            sPersonID = ScreenHelper.newCounter("PersonID",connection);

            if (sPersonID.trim().length()>0) {
                this.personid = sPersonID;
                sSelect = " INSERT INTO Admin (personid, lastname, firstname, gender, dateofbirth, searchname, updatetime, updateuserid, updateserverid) VALUES (?,?,?,?,?,?,?,?,?) ";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.setString(2,this.lastname);
                ps.setString(3,this.firstname);
                ps.setString(4,this.gender);
                ps.setString(5,this.dateOfBirth);
                ps.setString(6,sSearchname);
                ps.setTimestamp(7,new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(8,Integer.parseInt(this.updateuserid));
                ps.setInt(9,MedwanQuery.getInstance().getConfigInt("serverId"));
                ps.executeUpdate();
                if (ps!=null)ps.close();
            }
        }
        catch(Exception e) {
            e.printStackTrace();
            ScreenHelper.writeMessage(getClass()+" (3) "+e.getMessage()+" "+sSelect);
            bReturn = false;
        }

        return bReturn;
    }

    public boolean store(){
        boolean bResult=false;
    	try {
        	Connection connection=MedwanQuery.getInstance().getAdminConnection();
            bResult=saveToDB(connection);
    		connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return bResult;
    }

}

