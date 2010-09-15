package net.admin;

import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import be.openclinic.system.Application;

import java.security.MessageDigest;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.Vector;

public class User extends OC_Object {
    public String userid;
    public String personid;
    public byte[] password;
    public String start;
    public String stop;
    public AdminPerson person;
    public Vector parameters;
    private Hashtable accessRights;
    public String project;
    public Service activeService;
    public Vector vServices;
    public Vector myExaminations=null,otherExaminations=null;
    public Hashtable popularPrestations;

    public User()  {
        userid = "";
        personid = "";
        password = null;
        start = "";
        stop = "";
        person = new AdminPerson();
        parameters = new Vector();
        accessRights = new Hashtable();
        activeService = new Service();
        vServices = new Vector();
        project = "";
    }
    
    public String getUid(){
    	return userid;
    }

    public void setOtherExaminations(Vector otherExaminations) {
        this.otherExaminations = otherExaminations;
    }

    public void setMyExaminations(Vector myExaminations) {
        this.myExaminations = myExaminations;
    }

    public void clearAccessRights(){
    	this.accessRights=new Hashtable();
    }
    
    public Vector getMyExaminations(){
        if(myExaminations==null){
            try {
                myExaminations = new Vector();
                Connection dbOpenClinic = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbOpenClinic.prepareStatement("select examinationid from OC_USEREXAMINATIONS where userid=?");
                ps.setInt(1,Integer.parseInt(userid));
                ResultSet rs = ps.executeQuery();
                String ex = "";
                while (rs.next()){
                    if(ex.length()>0){
                        ex+=",";
                    }
                    ex+=rs.getString("examinationid");
                }
                rs.close();
                ps.close();
                dbOpenClinic.close();
                Connection dbOccup = MedwanQuery.getInstance().getOpenclinicConnection();
                ps = dbOccup.prepareStatement("select * from Examinations where id in ("+ex+") order by priority");
                rs=ps.executeQuery();
                while(rs.next()){
                    myExaminations.add(new ExaminationVO(new Integer(rs.getInt("id")),rs.getString("messageKey"),new Integer(rs.getInt("priority")),rs.getBytes("data"),rs.getString("transactionType"),rs.getString("nl"),rs.getString("fr"),person.language));
                }
                rs.close();
                ps.close();
                dbOccup.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return myExaminations;
    }

    public Hashtable getPopularPrestations(){
        if(popularPrestations==null){
            try {
                popularPrestations = new Hashtable();
                Connection dbOpenClinic = MedwanQuery.getInstance().getOpenclinicConnection();
                String sSql = "select count(*) as total,OC_DEBET_PRESTATIONUID from oc_debets WHERE OC_DEBET_DATE>? AND OC_DEBET_UPDATEUID=? group by OC_DEBET_PRESTATIONUID";
                PreparedStatement ps = dbOpenClinic.prepareStatement(sSql);
                int year = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1;
                java.util.Date startDate = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/").format(new java.util.Date())+year);
                ps.setDate(1, new java.sql.Date(startDate.getTime()));
                ps.setInt(2,Integer.parseInt(userid));
                ResultSet rs = ps.executeQuery();
                while (rs.next()){
                	popularPrestations.put(rs.getString("OC_DEBET_PRESTATIONUID"),rs.getInt("total"));
                }
                rs.close();
                ps.close();
                dbOpenClinic.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return popularPrestations;
    }
    
    public void addPrestation(String prestationuid){
    	System.out.println("counter prestationuid "+prestationuid+" = "+popularPrestations.get(prestationuid));
    	if(popularPrestations.get(prestationuid)==null){
    		popularPrestations.put(prestationuid, 1);
    	}
    	else {
    		popularPrestations.put(prestationuid,(Integer)popularPrestations.get(prestationuid)+1);
    	}
    }
    
    public Vector getTopPopularPrestations(int top){
    	Vector p = new Vector();
    	SortedSet set = new TreeSet();
    	Enumeration e = getPopularPrestations().keys();
    	while(e.hasMoreElements()){
    		String prestation=(String)e.nextElement();
    		String value=("0000000000000000"+(10000000-(Integer)popularPrestations.get(prestation))+"");
    		value=value.substring(value.length()-10);
    		set.add(value+"_"+prestation);
    	}
    	Iterator i = set.iterator();
    	while(i.hasNext() && p.size()<top){
    		p.add(((String)i.next()).split("_")[1]);
    	}
    	return p;
    }

    public Vector getOtherExaminations(){
        if(otherExaminations==null){
            try {
                otherExaminations = new Vector();
                Connection dbOpenClinic = MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = dbOpenClinic.prepareStatement("select examinationid from OC_USEREXAMINATIONS where userid=?");
                ps.setInt(1,Integer.parseInt(userid));
                ResultSet rs = ps.executeQuery();
                String ex = "";
                while (rs.next()){
                    if(ex.length()>0){
                        ex+=",";
                    }
                    ex+=rs.getString("examinationid");
                }
                rs.close();
                ps.close();
                dbOpenClinic.close();
                Connection dbOccup = MedwanQuery.getInstance().getOpenclinicConnection();
                ps = dbOccup.prepareStatement("select * from Examinations where id not in ("+ex+") order by priority");
                rs=ps.executeQuery();
                while(rs.next()){
                    otherExaminations.add(new ExaminationVO(new Integer(rs.getInt("id")),rs.getString("messageKey"),new Integer(rs.getInt("priority")),rs.getBytes("data"),rs.getString("transactionType"),rs.getString("nl"),rs.getString("fr"),person.language));
                }
                rs.close();
                ps.close();
                dbOccup.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return otherExaminations;
    }

    public boolean initialize (Connection connection, String sLogin, byte[] aPassword) {
    	boolean bReturn = false;

         if ((sLogin!=null)&&(sLogin.trim().length()>0)&&(aPassword!=null)&&(aPassword.length>0)) {
             try  {
                 String sSelect = "SELECT userid,personid, encryptedpassword, start, stop, project FROM Users WHERE userid = ? ";
                 PreparedStatement ps = connection.prepareStatement(sSelect);
                 ps.setInt(1,Integer.parseInt(sLogin));
                 ResultSet rs = ps.executeQuery();
                 if (rs.next()) {
                     this.userid = rs.getString("userid");
                     this.personid = rs.getString("personid");
                     this.password = rs.getBytes("encryptedpassword");
                     this.start = ScreenHelper.getSQLDate(rs.getDate("start"));
                     this.stop = ScreenHelper.getSQLDate(rs.getDate("stop"));
                     this.project = ScreenHelper.checkString(rs.getString("project"));

                     if (!checkPassword(aPassword))  {
                         return false;
                     }
                     sSelect = "SELECT * FROM UserParameters WHERE userid = ? AND active = 1 ";
                     rs.close();
                     ps.close();
                     ps = connection.prepareStatement(sSelect);
                     ps.setInt(1,Integer.parseInt(this.userid));
                     rs = ps.executeQuery();
                     String sParameter, sValue;
                     String sUserProfileID = "";
                     while (rs.next()) {
                         sParameter = rs.getString("parameter");
                         sValue = ScreenHelper.checkString(rs.getString("value"));

                         parameters.add(new Parameter(sParameter,sValue));

                         if (sParameter.equalsIgnoreCase("userprofileid")){
                            sUserProfileID = sValue;
                         }
                         else if (sParameter.equalsIgnoreCase("sa")){
                             accessRights.put("sa","true");
                         }
                     }
                     rs.close();
                     ps.close();

                     if (this.person.initialize(connection,personid)) {
                         bReturn = true;
                     }

                     loadAccessRights(sUserProfileID,connection);
                     initializeService(connection);
                 }
                 else {
	                 rs.close();
	                 ps.close();
                 }
             }
             catch(SQLException e) {
                 if(Debug.enabled) Debug.println("User initialize error: "+e.getMessage());
             }

             //initialize(Integer.parseInt(sLogin));
         }
         return bReturn;
     }

    public boolean initializeAuto (Connection connection, String sLogin, String aPassword) {
         boolean bReturn = false;

         if ((sLogin!=null)&&(sLogin.trim().length()>0)&&(aPassword!=null)&&(aPassword.length()>0)) {
             try  {
                 String sSelect = "SELECT userid,personid, encryptedpassword, start, stop, project FROM Users WHERE userid = ? ";
                 PreparedStatement ps = connection.prepareStatement(sSelect);
                 ps.setInt(1,Integer.parseInt(sLogin));
                 ResultSet rs = ps.executeQuery();
                 if (rs.next()) {
                     this.userid = rs.getString("userid");
                     this.personid = rs.getString("personid");
                     this.password = rs.getBytes("encryptedpassword");
                     this.start = ScreenHelper.getSQLDate(rs.getDate("start"));
                     this.stop = ScreenHelper.getSQLDate(rs.getDate("stop"));
                     this.project = ScreenHelper.checkString(rs.getString("project"));
                     if (!(hashPassword(this.password)==Integer.parseInt(aPassword)))  {
                         return false;
                     }
                     sSelect = "SELECT * FROM UserParameters WHERE userid = ? AND active = 1 ";
                     rs.close();
                     ps.close();
                     ps = connection.prepareStatement(sSelect);
                     ps.setInt(1,Integer.parseInt(this.userid));
                     rs = ps.executeQuery();
                     String sParameter, sValue;
                     String sUserProfileID = "";
                     while (rs.next()) {
                         sParameter = rs.getString("parameter");
                         sValue = ScreenHelper.checkString(rs.getString("value"));

                         parameters.add(new Parameter(sParameter,sValue));

                         if (sParameter.equalsIgnoreCase("userprofileid")){
                            sUserProfileID = sValue;
                         }
                         else if (sParameter.equalsIgnoreCase("sa")){
                             accessRights.put("sa","true");
                         }
                     }
                     rs.close();
                     ps.close();


                     if (this.person.initialize(connection,personid)) {
                         bReturn = true;
                     }

                     loadAccessRights(sUserProfileID,connection);
                     initializeService(connection);
                 }
                 else {
                     rs.close();
                     ps.close();
                 }
             }
             catch(SQLException e) {
                 if(Debug.enabled) Debug.println("User initialize error: "+e.getMessage());
             }

             //initialize(Integer.parseInt(sLogin));
         }
         return bReturn;
     }

    public boolean initialize (int userid){
         boolean bReturn = false;

         try  {
             Connection connection = MedwanQuery.getInstance().getAdminConnection();
             String sSelect = "SELECT userid, personid, encryptedpassword, start, stop, project"+
                              " FROM Users WHERE userid = ?";
             PreparedStatement ps = connection.prepareStatement(sSelect);
             ps.setInt(1,userid);
             ResultSet rs = ps.executeQuery();

             if (rs.next()) {
                 this.userid = rs.getString("userid");
                 this.personid = rs.getString("personid");
                 this.password = rs.getBytes("encryptedpassword");
                 this.start = ScreenHelper.getSQLDate(rs.getDate("start"));
                 this.stop = ScreenHelper.getSQLDate(rs.getDate("stop"));
                 this.project = ScreenHelper.checkString(rs.getString("project"));

                 sSelect = "SELECT * FROM UserParameters"+
                           "  WHERE userid = ? AND active = 1";
                 rs.close();
                 ps.close();
                 ps = connection.prepareStatement(sSelect);
                 ps.setInt(1,Integer.parseInt(this.userid));
                 rs = ps.executeQuery();
                 String sParameter, sValue, sUserProfileID = "";
                 this.accessRights = new Hashtable();
                 while (rs.next()) {
                     sParameter = rs.getString("parameter");
                     sValue = ScreenHelper.checkString(rs.getString("value"));

                     parameters.add(new Parameter(sParameter,sValue));

                     if (sParameter.equalsIgnoreCase("userprofileid")){
                        sUserProfileID = sValue;
                     }
                     else if (sParameter.equalsIgnoreCase("sa")){
                         accessRights.put("sa","true");
                     }
                 }
                 rs.close();
                 ps.close();

                 // reload accessrights from database
                 loadAccessRights(sUserProfileID,connection);

                 initializeService(connection);
                 bReturn = true;
             }
             else {
                 rs.close();
                 ps.close();
             }
             connection.close();
         }
         catch(SQLException e) {
             if(Debug.enabled) Debug.println("User initialize error: "+e.getMessage());
         }

         return bReturn;
     }

    //--- INITIALIZE WITH MEDCODE ------------------------------------------------------------------
    public boolean initializeWithMedCode (int medcode) {
        boolean bReturn = false;

        try  {
            Connection connection = MedwanQuery.getInstance().getAdminConnection();
            String sSelect = "SELECT u.userid, u.personid, encryptedpassword, start, stop, project"+
                             " FROM UserParameters p, Users u"+
                             "  WHERE u.userid = p.userid"+
                             "   AND LOWER(parameter) = 'organisationid' "+
                             "   AND "+MedwanQuery.getInstance().getConfigString("valueColumn")+"  = ?";

            PreparedStatement ps = connection.prepareStatement(sSelect);
            ps.setString(1,medcode+"");

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                this.userid   = rs.getString("userid");
                this.personid = rs.getString("personid");
                this.password = rs.getBytes("encryptedpassword");
                this.start    = ScreenHelper.getSQLDate(rs.getDate("start"));
                this.stop     = ScreenHelper.getSQLDate(rs.getDate("stop"));
                this.project  = ScreenHelper.checkString(rs.getString("project"));

                // LOAD PARAMETERS
                sSelect = "SELECT * FROM UserParameters WHERE userid = ? AND active = 1";
                rs.close();
                ps.close();
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.userid));
                rs = ps.executeQuery();
                String sParameter, sValue;
                String sUserProfileID = "";
                while (rs.next()) {
                     sParameter = rs.getString("parameter");
                     sValue = ScreenHelper.checkString(rs.getString("value"));

                     parameters.add(new Parameter(sParameter,sValue));

                     if (sParameter.equalsIgnoreCase("userprofileid")){
                        sUserProfileID = sValue;
                     }
                     else if (sParameter.equalsIgnoreCase("sa")){
                         accessRights.put("sa","true");
                     }
                }
                rs.close();
                ps.close();

                if (this.person.initialize(connection,personid)) {
                    bReturn = true;
                }

                loadAccessRights(sUserProfileID,connection);

                // LOAD SERVICES
                initializeService(connection);
            }
            else {
                rs.close();
                ps.close();
            }
            connection.close();
        }
        catch(SQLException e) {
            if(Debug.enabled) Debug.println("User initialize error: "+e.getMessage());
        }

        return bReturn;
    }

      public String getParameter(String sParameter) {
        Parameter ap;
        for (int i=0;i<this.parameters.size();i++) {
            ap = (Parameter) this.parameters.elementAt(i);
            if (ap.parameter.equalsIgnoreCase(sParameter)) {
                return ap.value;
            }
        }
        return "";
    }

    public boolean saveToDB(Connection connection) {
        boolean bReturn = true;
        String sSelect = "";
        try {
            PreparedStatement ps;

            if ((userid==null)||(userid.trim().length()==0)) {
    //INSERT
                this.userid = ScreenHelper.newCounter("UserID",connection);
                sSelect = " INSERT INTO Users (userid, personid, encryptedpassword, start, stop, updatetime, project) "
                    +" VALUES (?,?,?,?,?,?,?) ";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.userid));
                ps.setInt(2,Integer.parseInt(this.personid));
                ps.setBytes(3,this.password);
                ps.setDate(4,ScreenHelper.getSQLDate(this.start));
                if (this.stop.trim().length()>0) {
                    ps.setDate(5,ScreenHelper.getSQLDate(this.stop));
                }
                else {
                    ps.setNull(5,91);
                }
                ps.setTimestamp(6,new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setString(7,this.project);
                ps.executeUpdate();
                ps.close();
            }
            else {
    //UPDATE
                sSelect = " UPDATE Users SET encryptedpassword = ?, start = ?,  stop = ?, updatetime = ? "
                    +" WHERE personid = ? AND userid = ? AND project = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setBytes(1,this.password);
                ps.setDate(2,ScreenHelper.getSQLDate(this.start));
                if (this.stop.trim().length()>0) {
                    ps.setDate(3,ScreenHelper.getSQLDate(this.stop));
                }
                else {
                    ps.setNull(3,java.sql.Types.DATE);
                }
                ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime()));
                ps.setInt(5,Integer.parseInt(this.personid));
                ps.setInt(6,Integer.parseInt(this.userid));
                ps.setString(7,this.project);
                ps.executeUpdate();
                ps.close();

                sSelect = " UPDATE UserParameters SET active = 0, updatetime = ? WHERE userid = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
                ps.setInt(2,Integer.parseInt(this.userid));
                ps.executeUpdate();
                ps.close();
            }

            String sUserProfileID = "";
            Parameter parameter;
            for (int i=0;i<parameters.size();i++) {
                parameter = (Parameter) parameters.elementAt(i);
                updateParameter(parameter, connection);

                if (parameter.parameter.equalsIgnoreCase("userprofileid")){
                    sUserProfileID = ScreenHelper.checkString(parameter.value);
                }
                else if (parameter.parameter.equalsIgnoreCase("sa")){
                    accessRights.put("sa","true");
                }
            }

            loadAccessRights(sUserProfileID,connection);
        }
        catch(SQLException e) {
            ScreenHelper.writeMessage(getClass()+" (1) "+e.getMessage()+" "+sSelect);
            bReturn = false;
        }
        return bReturn;
    }

    public void loadAccessRights(String sUserProfileID, Connection connection){
        String sSelect = "";
        try{
            if (sUserProfileID.length()>0){
                 sSelect = "SELECT screenid, permission FROM UserProfilePermissions WHERE userprofileid = ? AND active = 1 ";
                 PreparedStatement ps = connection.prepareStatement(sSelect);
                 ps.setInt(1,Integer.parseInt(sUserProfileID));
                 ResultSet rs = ps.executeQuery();
                 while (rs.next())  {
                     this.accessRights.put(rs.getString("screenid")+"."+rs.getString("permission"),"true");
                 }
                 rs.close();
                 ps.close();
             }
        }
        catch(SQLException e) {
            e.printStackTrace();
        }
    }

    public byte[] encrypt(String sValue) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            return md.digest(sValue.getBytes());
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println("User encryption error: "+e.getMessage());
        }
        return null;
    }

    public boolean checkPassword(byte[] aPassword)  {
        try {
            if (MessageDigest.isEqual(aPassword,this.password)) {
                return true;
            }
        }
        catch (Exception e) {
	        if(Debug.enabled) Debug.println("User checkPassword error: "+e.getMessage());
        }
        return false;
    }

    public boolean updateParameter(Parameter parameter, Connection connection) {
        String sSelect = "";
        try {
            PreparedStatement ps=connection.prepareStatement("select * from UserParameters where userid=? and parameter=?");
            ps.setInt(1,Integer.parseInt(this.userid));
            ps.setString(2,parameter.parameter);
            ResultSet rs=ps.executeQuery();
            if (rs.next()){
                if (parameter.parameter.toLowerCase().equals("favorite")){
                    sSelect = " UPDATE UserParameters SET active = 1,updatetime=? WHERE "+MedwanQuery.getInstance().getConfigString("valueColumn")+" = ? AND userid = ? AND parameter = ? ";
                }
                else {
                    sSelect = " UPDATE UserParameters SET active = 1,updatetime=?, "+MedwanQuery.getInstance().getConfigString("valueColumn")+" = ? WHERE userid = ? AND parameter = ? ";
                }
                rs.close();
                ps.close();
                ps = connection.prepareStatement(sSelect);
                ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
                ps.setString(2,parameter.value);
                ps.setInt(3,Integer.parseInt(this.userid));
                ps.setString(4,parameter.parameter);
                ps.execute();
                ps.close();
            }
            else {
                sSelect = " INSERT INTO UserParameters(userid,parameter,"+MedwanQuery.getInstance().getConfigString("valueColumn")+" ,updatetime,active) VALUES (?,?,?,?,1)";
                rs.close();
                ps.close();
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.userid));
                ps.setString(2,parameter.parameter);
                ps.setString(3,parameter.value);
                ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime()));
                ps.execute();
                ps.close();
            }

            if (ps!=null){
                ps.close();
            }
            return true;
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println("User updateParameter error: "+e.getMessage()+" "+sSelect);
            return false;
        }
    }

    public boolean removeParameter(String sParameter, Connection connection) {
        try {
            String sSelect = "UPDATE UserParameters SET active = 0, updatetime = ? WHERE userid = ? AND parameter = ? ";
            PreparedStatement ps = connection.prepareStatement(sSelect);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()));
            ps.setInt(2,Integer.parseInt(this.userid));
            ps.setString(3,sParameter);
            ps.executeUpdate();
            ps.close();

            Parameter parameter;
            Vector vTmp = (Vector)this.parameters.clone();
            for(int i=0; i<vTmp.size(); i++) {
                parameter = (Parameter)vTmp.elementAt(i);
                if(parameter.parameter.trim().equalsIgnoreCase(sParameter.trim())) {
                    this.parameters.removeElement(parameter);
                }
            }
            return true;
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println("User removeParameter error: "+e.getMessage());
            return false;
        }
    }

    public boolean initializeService(Connection connection){
        boolean bReturn = true;
        PreparedStatement ps = null;
        ResultSet rs = null;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(getParameter("defaultserviceid").length()>0){
                activeService=MedwanQuery.getInstance().getService(getParameter("defaultserviceid"));    
            }

             String sSelect = "SELECT serviceid FROM UserServices WHERE userid = ?";

             ps = ad_conn.prepareStatement(sSelect);
             ps.setInt(1,Integer.parseInt(userid));
             rs = ps.executeQuery();
             String sServiceID;
             Service service;
             vServices.clear();
             while (rs.next()){
                 sServiceID = rs.getString("serviceid");
                 service = MedwanQuery.getInstance().getService(sServiceID);
                 if (service!=null){
                     vServices.add(service);
                 }
             }
             rs.close();
             ps.close();
        }
        catch (Exception e){
            e.printStackTrace();
            bReturn = false;
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return bReturn;
    }

    public static int hashPassword(byte[] password){
        int hash=0;
        for (int n=0;n<password.length;n++){
            hash+=password[n];
        }
        return hash;
    }

    public static Vector getUsersByPersonId(String sPersonid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUsers = new Vector();

        String sSelect = "SELECT userid, encryptedpassword, start, stop, project FROM Users WHERE personid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonid));

            rs  = ps.executeQuery();
            User user;
            while(rs.next()){
                user = new User();
                user.userid = ScreenHelper.checkString(rs.getString("userid"));
                user.password = rs.getBytes("encryptedpassword");
                user.start = ScreenHelper.checkString(rs.getString("start"));
                user.stop  = ScreenHelper.checkString(rs.getString("stop"));
                user.project = ScreenHelper.checkString(rs.getString("project"));

                vUsers.addElement(user);
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
        return vUsers;
    }

    public static String getUseridByPersonid(String sPersonid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sUserid = "";

        String sSelect = "SELECT userid FROM Users WHERE personid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonid));
            rs = ps.executeQuery();

            if(rs.next()){
                sUserid = ScreenHelper.checkString(rs.getString("userid"));
            }
            else{
                sUserid = null;
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

        return sUserid;
    }

    public static boolean hasPermission(String sUserId,String sDate){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bPermission = false;

        String sSelect = "SELECT userid FROM Users WHERE userid = ? AND (stop IS NULL OR stop > ?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sUserId));
            ps.setDate(2,ScreenHelper.getSQLDate(sDate));
            rs = ps.executeQuery();

            if(rs.next()){
                bPermission = true;
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
        return bPermission;
    }

    public static void setActiveServiceById(String sId){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE UserServices SET activeservice = 0 WHERE userid = ? ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1,sId);
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void setUpdatetimeAndActiveServiceByIdAndService(String sUserid, String sDefaultService){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE UserServices SET updatetime = ?, activeservice = ? WHERE userid = ? AND serviceid = ? ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1,ScreenHelper.getSQLTime());
            ps.setInt(2,1);
            ps.setInt(3,Integer.parseInt(sUserid));
            ps.setString(4,sDefaultService);
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

    }

    public static String blurSelectUserName(String sSearchCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sValue = "";

        String sSelect = " SELECT (firstname+' '+lastname) AS name"+
                         " FROM UserParameters p, Admin a, Users u"+
                         " WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare","parameter")+" = 'organisationid'"+
                         " AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare","value")+" = ?"+
                         " AND u.userid = p.userid"+
                         " AND a.personid = u.personid"+
                         " ORDER BY a.searchname";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sSearchCode);

            rs = ps.executeQuery();

            while(rs.next()){
                sValue = ScreenHelper.checkString(rs.getString("name"));
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
        return sValue;
    }

    public static Vector searchUsers(String sSelectLastname,String sSelectFirstname){
        PreparedStatement ps = null,psChild=null;
        ResultSet rs = null;
        Vector vResults = new Vector();
        Hashtable hInfo;
        String sSelect = "";

    	Connection lad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(sSelectLastname.length()>0 && sSelectFirstname.length()>0){
                sSelect+= " searchname LIKE '"+sSelectLastname.toUpperCase()+"%,"+sSelectFirstname.toUpperCase()+"%' AND ";
            }
            else if(sSelectLastname.length()>0){
                sSelect+= " searchname LIKE '"+sSelectLastname.toUpperCase()+"%,%' AND ";
            }
            else if(sSelectFirstname.length()>0){
                sSelect+= " searchname LIKE '%,"+sSelectFirstname.toUpperCase()+"%' AND ";
            }

            // remove last AND if any
            if(sSelect.indexOf("AND ")>0){
                sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
            }

            // complete query
            String sQuery = "SELECT u.userid, a.personid, a.lastname, a.firstname, a.immatnew"+
                            " FROM Admin a, Users u"+
                            "  WHERE a.personid = u.personid";

            if(sSelect.length() > 0) sQuery+= " AND "+sSelect;
            sQuery+= " ORDER BY searchname";

            ps = lad_conn.prepareStatement(sQuery);
            rs = ps.executeQuery();
            String sUserID;
            ResultSet rsChild;
            while(rs.next()){
                hInfo = new Hashtable();
                sUserID = ScreenHelper.checkString(rs.getString("userid"));
                hInfo.put("userid",sUserID);
                hInfo.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                hInfo.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                hInfo.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                hInfo.put("immatnew",ScreenHelper.checkString(rs.getString("immatnew")));

                sQuery = "SELECT serviceid FROM UserServices WHERE userid = ? AND activeservice = 1";
                psChild = lad_conn.prepareStatement(sQuery);
                psChild.setInt(1,Integer.parseInt(sUserID));
                rsChild = psChild.executeQuery();

                if (rsChild.next()){
                    hInfo.put("serviceid",ScreenHelper.checkString(rsChild.getString("serviceid")));    
                }
                rsChild.close();
                psChild.close();

                vResults.addElement(hInfo);
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                lad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public void savePasswordToDB(){
        PreparedStatement ps = null;

        String updQuery = "UPDATE Users SET encryptedpassword=?, updatetime=? WHERE userid = ? ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(updQuery);
            ps.setBytes(1,this.password);
            ps.setTimestamp(2,ScreenHelper.getSQLTime());
            ps.setInt(3,Integer.parseInt(this.userid));
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Hashtable getUserName(String sUserId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT lastname, firstname FROM Users u, Admin a WHERE u.userid = ? AND a.personid = u.personid";

        Hashtable hName = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sUserId);
            rs = ps.executeQuery();

            if(rs.next()){
                hName = new Hashtable();
                hName.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                hName.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
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
        return hName;
    }

    public boolean getAccessRight(String sPermission){
        if (Application.isDisabled(sPermission)){
            return false;
        }
        else if (ScreenHelper.checkString((String)accessRights.get("sa")).equals("true")){
            return true;
        }
        else {
            return (accessRights.get(sPermission.toLowerCase())!=null);
        }
    }

    public static String getFirstUserName(String sUserId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT lastname, firstname FROM Users u, Admin a WHERE u.userid = ? AND a.personid = u.personid";

        String hName = "";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sUserId);
            rs = ps.executeQuery();

            if(rs.next()){
                hName = ScreenHelper.checkString(rs.getString("firstname"))+", "+ScreenHelper.checkString(rs.getString("lastname"));
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
        return hName;
    }

}