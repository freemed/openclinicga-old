package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.DatabaseMetaData;
import java.util.Vector;
import java.util.Calendar;


public class AdminHistory {
    private int personid;
    private String natreg;
    private String immatold;
    private String immatnew;
    private String candidate;
    private String lastname;
    private String firstname;
    private String gender;
    private Timestamp dateofbirth;
    private String comment;
    private String sourceid;
    private String language;
    private Timestamp engagement;
    private Timestamp pension;
    private String statute;
    private String claimant;
    private String searchname;
    private Timestamp updatetime;
    private Timestamp claimant_expiration;
    private String native_town;
    private String motive_end_of_service;
    private Timestamp startdate_inactivity;
    private Timestamp enddate_inactivity;
    private String code_inactivity;
    private String update_status;
    private String person_type;
    private String situation_end_of_service;
    private int updateuserid;
    private String comment1;
    private String comment2;
    private String comment3;
    private String comment4;
    private String comment5;
    private String native_country;
    private String middlename;
    private Timestamp begindate;
    private Timestamp enddate;
    private int updateserverid;


    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public String getNatreg() {
        return natreg;
    }

    public void setNatreg(String natreg) {
        this.natreg = natreg;
    }

    public String getImmatold() {
        return immatold;
    }

    public void setImmatold(String immatold) {
        this.immatold = immatold;
    }

    public String getImmatnew() {
        return immatnew;
    }

    public void setImmatnew(String immatnew) {
        this.immatnew = immatnew;
    }

    public String getCandidate() {
        return candidate;
    }

    public void setCandidate(String candidate) {
        this.candidate = candidate;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Timestamp getDateofbirth() {
        return dateofbirth;
    }

    public void setDateofbirth(Timestamp dateofbirth) {
        this.dateofbirth = dateofbirth;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getSourceid() {
        return sourceid;
    }

    public void setSourceid(String sourceid) {
        this.sourceid = sourceid;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public Timestamp getEngagement() {
        return engagement;
    }

    public void setEngagement(Timestamp engagement) {
        this.engagement = engagement;
    }

    public Timestamp getPension() {
        return pension;
    }

    public void setPension(Timestamp pension) {
        this.pension = pension;
    }

    public String getStatute() {
        return statute;
    }

    public void setStatute(String statute) {
        this.statute = statute;
    }

    public String getClaimant() {
        return claimant;
    }

    public void setClaimant(String claimant) {
        this.claimant = claimant;
    }

    public String getSearchname() {
        return searchname;
    }

    public void setSearchname(String searchname) {
        this.searchname = searchname;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getClaimant_expiration() {
        return claimant_expiration;
    }

    public void setClaimant_expiration(Timestamp claimant_expiration) {
        this.claimant_expiration = claimant_expiration;
    }

    public String getNative_town() {
        return native_town;
    }

    public void setNative_town(String native_town) {
        this.native_town = native_town;
    }

    public String getMotive_end_of_service() {
        return motive_end_of_service;
    }

    public void setMotive_end_of_service(String motive_end_of_service) {
        this.motive_end_of_service = motive_end_of_service;
    }

    public Timestamp getStartdate_inactivity() {
        return startdate_inactivity;
    }

    public void setStartdate_inactivity(Timestamp startdate_inactivity) {
        this.startdate_inactivity = startdate_inactivity;
    }

    public Timestamp getEnddate_inactivity() {
        return enddate_inactivity;
    }

    public void setEnddate_inactivity(Timestamp enddate_inactivity) {
        this.enddate_inactivity = enddate_inactivity;
    }

    public String getCode_inactivity() {
        return code_inactivity;
    }

    public void setCode_inactivity(String code_inactivity) {
        this.code_inactivity = code_inactivity;
    }

    public String getUpdate_status() {
        return update_status;
    }

    public void setUpdate_status(String update_status) {
        this.update_status = update_status;
    }

    public String getPerson_type() {
        return person_type;
    }

    public void setPerson_type(String person_type) {
        this.person_type = person_type;
    }

    public String getSituation_end_of_service() {
        return situation_end_of_service;
    }

    public void setSituation_end_of_service(String situation_end_of_service) {
        this.situation_end_of_service = situation_end_of_service;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public String getComment1() {
        return comment1;
    }

    public void setComment1(String comment1) {
        this.comment1 = comment1;
    }

    public String getComment2() {
        return comment2;
    }

    public void setComment2(String comment2) {
        this.comment2 = comment2;
    }

    public String getComment3() {
        return comment3;
    }

    public void setComment3(String comment3) {
        this.comment3 = comment3;
    }

    public String getComment4() {
        return comment4;
    }

    public void setComment4(String comment4) {
        this.comment4 = comment4;
    }

    public String getComment5() {
        return comment5;
    }

    public void setComment5(String comment5) {
        this.comment5 = comment5;
    }

    public String getNative_country() {
        return native_country;
    }

    public void setNative_country(String native_country) {
        this.native_country = native_country;
    }

    public String getMiddlename() {
        return middlename;
    }

    public void setMiddlename(String middlename) {
        this.middlename = middlename;
    }

    public Timestamp getBegindate() {
        return begindate;
    }

    public void setBegindate(Timestamp begindate) {
        this.begindate = begindate;
    }

    public Timestamp getEnddate() {
        return enddate;
    }

    public void setEnddate(Timestamp enddate) {
        this.enddate = enddate;
    }

    public int getUpdateserverid() {
        return updateserverid;
    }

    public void setUpdateserverid(int updateserverid) {
        this.updateserverid = updateserverid;
    }

    public static Vector searchAdminHistoryWithCriteria(String sImmatnew, String sImmatold, String sNatreg, String sName, String sFirstname, String sDateofbirth){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vAH = new Vector();

        String sSelect =  " SELECT personid, immatold, immatnew, candidate, lastname, firstname,"+
                          " gender, dateofbirth, comment, sourceid, language, engagement, pension,statute, claimant, searchname, updatetime,"+
                          " claimant_expiration, native_country,native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,"+
                          " code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,"+
                          " comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid"+
                          " FROM AdminHistory ";
        String sWhere = " WHERE ";

        // immatnew
        if(sImmatnew.length()>0){
            sImmatnew = sImmatnew.replaceAll("\\.","");
            sImmatnew = sImmatnew.replaceAll("-","");
            sImmatnew = sImmatnew.replaceAll("/","");

            sWhere+= " immatnew = '"+sImmatnew+"' AND";
        }

        // immatold
        if(sImmatold.length()>0){
            sWhere+= " immatold = '"+sImmatold+"' AND";
        }

        // natreg
        if (sNatreg.length()>0){
            sWhere+= " natreg = '"+sNatreg+"' AND";
        }

        // names
        String sNameNormalised      = ScreenHelper.normalizeSpecialCharacters(sName);
        String sFirstnameNormalised = ScreenHelper.normalizeSpecialCharacters(sFirstname);

        if((sNameNormalised.length() > 0) && (sFirstnameNormalised.length() > 0)){
            sWhere+= " searchname LIKE '"+sNameNormalised.toUpperCase()+"%,"+sFirstnameNormalised.toUpperCase()+"%' AND";
        }
        else if(sName.length()>0){
            sWhere+= " searchname LIKE '"+sNameNormalised.toUpperCase()+"%' AND";
        }
        else if(sFirstname.length()>0){
            sWhere+= " searchname LIKE '%,"+sFirstnameNormalised.toUpperCase()+"%' AND";
        }

        // date of birth
        if(sDateofbirth.length()==10){
            if(sDateofbirth.indexOf("/")>0){
                sWhere+= " dateofbirth LIKE ? AND";
            }
            else{
                sDateofbirth = "";
            }
        }
        else{
            sDateofbirth = "";
        }
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(sWhere.length() > 0){
                String sQuery = sSelect+sWhere.substring(0,sWhere.length()-3)+" ORDER BY searchname";
                ps = ad_conn.prepareStatement(sQuery);

                // format date of birth
                if (sDateofbirth.trim().length()>0) {
                    String sSeparator = "/";
                    String sDate = sDateofbirth;
                    if (sDate.indexOf(sSeparator)<1) {
                        sSeparator = "-";
                    }

                    String sDay = sDate.substring(0,sDate.indexOf(sSeparator));
                    if (sDay.startsWith("0")){
                        sDay = sDay.substring(1);
                    }

                    String sMonth = sDate.substring(sDate.indexOf(sSeparator)+1,sDate.lastIndexOf(sSeparator));
                    if (sMonth.startsWith("0")){
                        sMonth = sMonth.substring(1);
                    }

                    int iDay = Integer.parseInt(sDay);
                    int iMonth = Integer.parseInt(sMonth);
                    int iYear = Integer.parseInt(sDate.substring(sDate.lastIndexOf(sSeparator) + 1));
                    if (iYear<100) {
                        iYear = 2000 + iYear;
                    }

                    Calendar c = Calendar.getInstance();
                    c.set(iYear, iMonth-1, iDay, 0,0);
                    java.sql.Date dDate = new java.sql.Date(c.getTimeInMillis());
                    ps.setDate(1,dDate);
                }

                rs = ps.executeQuery();

                AdminHistory objAH;

                while(rs.next()){
                    objAH = new AdminHistory();
                    objAH.setPersonid(rs.getInt("personid"));
                    objAH.setImmatnew(ScreenHelper.checkString(rs.getString("immatnew")));
                    objAH.setImmatold(ScreenHelper.checkString(rs.getString("immatold")));
                    objAH.setNatreg(ScreenHelper.checkString(rs.getString("natreg")));
                    objAH.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                    objAH.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                    objAH.setGender(ScreenHelper.checkString(rs.getString("gender")));
                    objAH.setDateofbirth(rs.getTimestamp("dateofbirth"));

                    vAH.addElement(objAH);
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
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vAH;
    }

    public static void reactivateArchivedFile(String historyPersonid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = " SELECT personid, immatold, immatnew, candidate, lastname,firstname,"+
                         " gender, dateofbirth, comment, sourceid, language, engagement, pension,statute, claimant, searchname, updatetime,"+
                         " claimant_expiration, native_country,native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,"+
                         " code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,"+
                         " comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid"+
                         " FROM AdminHistory WHERE personid = ?";

        StringBuffer sbQuery = new StringBuffer();
        // insert AdminHistory in Admin (note that the columns have a different order in both tables !)
        sbQuery.append("INSERT INTO Admin(personid, immatold, immatnew, candidate, lastname,")
               .append("  firstname, gender, dateofbirth, comment, sourceid, language, engagement, pension,")
               .append("  statute, claimant, searchname, updatetime, claimant_expiration, native_country,")
               .append("  native_town, motive_end_of_service, startdate_inactivity, enddate_inactivity,")
               .append("  code_inactivity, update_status, person_type, situation_end_of_service, updateuserid,")
               .append("  comment1, comment2, comment3, comment4, comment5, natreg, middlename, begindate, enddate, updateserverid) ")
               .append(" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"); // 38
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(historyPersonid));
            rs = ps.executeQuery();
            if(rs.next()){
                // get admin metadata : put column types in a vector
                Vector adminMetaData = new Vector();
                DatabaseMetaData databaseMetaData = ad_conn.getMetaData();
                ResultSet rsMD = databaseMetaData.getColumns(null,null,"Admin",null);
                String type;

                while(rsMD.next()){
                    type = rsMD.getString("TYPE_NAME");

                    if(type.equals("varchar") || type.equals("nvarchar") || type.equals("char")){
                        adminMetaData.add("String");
                    }
                    else if(type.equals("datetime") || type.equals("smalldatetime")){
                        adminMetaData.add("Date");
                    }
                    else{
                        adminMetaData.add(type);
                    }
                }

                rsMD.close();

                // set questionmarks in query
                Object obj;
                String columnType;
                ps = ad_conn.prepareStatement(sbQuery.toString());

                for(int i=1; i<=38; i++){
                    obj = rs.getObject(i);

                    if(obj==null){
                        columnType = (String)adminMetaData.elementAt((i-1));

                             if(columnType.equals("int"))    ps.setInt(i,0);
                        else if(columnType.equals("String")) ps.setString(i,"");
                        else if(columnType.equals("Date"))   ps.setTimestamp(i,new Timestamp(new java.util.Date().getTime())); // now
                    }
                    else{
                        ps.setObject(i,obj);
                    }
                }

                // set updatetime = now
                ps.setTimestamp(17,new Timestamp(new java.util.Date().getTime()));

                ps.executeUpdate();
                ps.close();

                // delete AdminHistory
                ps = ad_conn.prepareStatement("DELETE FROM AdminHistory WHERE personid = ?");
                ps.setInt(1,Integer.parseInt(historyPersonid));
                ps.executeUpdate();
                ps.close();

                //msg = getTran("Web.manage","archivedfilereactivated",sWebLanguage);

                if(Debug.enabled) Debug.println("AdminHistory (personid "+historyPersonid+") moved to Admin");
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
    }


    public static boolean existsByPersonid(String historyPersonid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = "SELECT 1 FROM AdminHistory WHERE personid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(historyPersonid));
            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
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

        return bExists;
    }
}
