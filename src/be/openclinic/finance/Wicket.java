package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Iterator;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;


import net.admin.Service;
import net.admin.User;


public class Wicket extends OC_Object{
    private Service service;
    private String serviceUID;
    private double balance;
    private Vector authorizedUsers;
    private String authorizedUsersId;

    public Service getService() {
        return service;
    }

    public void setService(Service service) {
        this.service = service;
    }

    public String getServiceUID() {
        return serviceUID;
    }

    public void setServiceUID(String serviceUID) {
        this.serviceUID = serviceUID;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public Vector getAuthorizedUsers() {
        return authorizedUsers;
    }

    public void setAuthorizedUsers(Vector authorizedUsers) {
        this.authorizedUsers = authorizedUsers;
    }

    public String getAuthorizedUsersId() {
        return authorizedUsersId;
    }

    public void setAuthorizedUsersId(String authorizedUsersId) {
        this.authorizedUsersId = authorizedUsersId;
    }

    public static Wicket get(String uid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Wicket wicket = new Wicket();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_WICKETS " +
                                     " WHERE OC_WICKET_SERVERID = ? " +
                                     " AND OC_WICKET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        wicket.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_OBJECTID")));
                        wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREATETIME"));
                        wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_UPDATETIME"));
                        wicket.setServiceUID(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID")));
                        wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_UPDATEUID")));
                        wicket.setBalance(rs.getDouble("OC_WICKET_BALANCE"));
                        wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));
                        wicket.setVersion(rs.getInt("OC_WICKET_VERSION"));

                        // set service
                        Service wicketService = Service.getService(wicket.getServiceUID());
                        wicket.setService(wicketService);
                    }
                }catch(Exception e){
                    Debug.println("OpenClinic => Wicket.java => get => "+e.getMessage());
                    e.printStackTrace();
                }finally{
                    try{
                        if(rs!= null) rs.close();
                        if(ps!= null) ps.close();
                        oc_conn.close();
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }
        return wicket;
    }

    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect,sInsert,sDelete;

        int iVersion = 1;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = " SELECT * FROM OC_WICKETS " +
                              " WHERE OC_WICKET_SERVERID = ? " +
                              " AND OC_WICKET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_WICKET_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_WICKETS_HISTORY " +
                              " SELECT OC_WICKET_SERVERID," +
                                     " OC_WICKET_OBJECTID," +
                                     " OC_WICKET_BALANCE," +
                                     " OC_WICKET_AUTHORIZEDUSERS," +
                                     " OC_WICKET_SERVICEUID," +
                                     " OC_WICKET_CREATETIME," +
                                     " OC_WICKET_UPDATETIME," +
                                     " OC_WICKET_UPDATEUID,"  +
                                     " OC_WICKET_VERSION" +
                              " FROM OC_WICKETS " +
                              " WHERE OC_WICKET_SERVERID = ?" +
                              " AND OC_WICKET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_WICKETS " +
                              " WHERE OC_WICKET_SERVERID = ? " +
                              " AND OC_WICKET_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_WICKETS")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_WICKETS" +
                                      "(" +
                                      " OC_WICKET_SERVERID," +
                                      " OC_WICKET_OBJECTID," +
                                      " OC_WICKET_BALANCE," +
                                      " OC_WICKET_AUTHORIZEDUSERS," +
                                      " OC_WICKET_SERVICEUID," +
                                      " OC_WICKET_CREATETIME," +
                                      " OC_WICKET_UPDATETIME," +
                                      " OC_WICKET_UPDATEUID,"  +
                                      " OC_WICKET_VERSION" +
                                      ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDouble(3,this.getBalance());
                ps.setString(4,this.getAuthorizedUsersId());
                if(this.getService() != null){
                    ps.setString(5,ScreenHelper.checkString(this.getService().code));
                }else{
                    ps.setString(5,"");
                }
                ps.setTimestamp(6,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(7,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,iVersion);
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => Wicket.java => store => "+e.getMessage());
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
    }

    public static Vector selectWicketsInService(String sServiceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vChildServices = Service.getChildIds(sServiceUID);
        String sServiceUIDS = "";
        if(vChildServices.size() != 0){
            Iterator iter = vChildServices.iterator();

            while(iter.hasNext()){
                sServiceUIDS += "'" + iter.next() + "',";
            }
        }else{
            sServiceUIDS += "'" + sServiceUID + "',";
        }
        Vector vWickets = new Vector();

        String sSelect = "SELECT * FROM OC_WICKETS WHERE OC_WICKET_SERVICEUID IN (" + sServiceUIDS.substring(0,sServiceUIDS.length()-1) + ")";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            String sTmp,sTmp1;

            Wicket wicket;

            while(rs.next()){
                wicket = new Wicket();

                sTmp = ScreenHelper.checkString(rs.getString("OC_WICKET_SERVERID"));
                sTmp1 = ScreenHelper.checkString(rs.getString("OC_WICKET_OBJECTID"));

                if(sTmp.length() > 0 && sTmp1.length() > 0){
                    wicket.setUid(sTmp + "." + sTmp1);
                }

                wicket.setBalance(rs.getDouble("OC_WICKET_BALANCE"));
                wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));
                wicket.setServiceUID(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID")));
                wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREATETIME"));
                wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_UPDATETIME"));
                wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_UPDATEUID")));
                wicket.setVersion(rs.getInt("OC_WICKET_VERSION"));

                vWickets.addElement(wicket);
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
        return vWickets;
    }

     public static Vector selectWickets(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vWickets = new Vector();

        String sSelect = "SELECT * FROM OC_WICKETS";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            String sTmp,sTmp1;

            Wicket wicket;

            while(rs.next()){
                wicket = new Wicket();

                sTmp = ScreenHelper.checkString(rs.getString("OC_WICKET_SERVERID"));
                sTmp1 = ScreenHelper.checkString(rs.getString("OC_WICKET_OBJECTID"));

                if(sTmp.length() > 0 && sTmp1.length() > 0){
                    wicket.setUid(sTmp + "." + sTmp1);
                }

                wicket.setBalance(rs.getDouble("OC_WICKET_BALANCE"));
                wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));
                wicket.setServiceUID(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID")));
                wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREATETIME"));
                wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_UPDATETIME"));
                wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_UPDATEUID")));
                wicket.setVersion(rs.getInt("OC_WICKET_VERSION"));

                vWickets.addElement(wicket);
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
        return vWickets;
    }

    //--- GET WICKETS FOR USER --------------------------------------------------------------------
    public static Vector getWicketsForUser(String sUserUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vWickets = new Vector();
        User user = new User();
        user.initialize(Integer.parseInt(sUserUid));

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_WICKETS ORDER BY OC_WICKET_OBJECTID";
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            String sServerId, sObjectId, sAuthorisedUserIds;
            Wicket wicket;

            while(rs.next()){
                sAuthorisedUserIds = ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS"));
                if(sAuthorisedUserIds.indexOf(sUserUid) > -1 || (user!=null && user.getAccessRight("sa"))){
                    wicket = new Wicket();

                    // set uid
                    sServerId = ScreenHelper.checkString(rs.getString("OC_WICKET_SERVERID"));
                    sObjectId = ScreenHelper.checkString(rs.getString("OC_WICKET_OBJECTID"));

                    if(sServerId.length() > 0 && sObjectId.length() > 0){
                        wicket.setUid(sServerId + "." + sObjectId);
                    }

                    wicket.setBalance(rs.getDouble("OC_WICKET_BALANCE"));
                    wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));
                    wicket.setServiceUID(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID")));
                    wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREATETIME"));
                    wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_UPDATETIME"));
                    wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_UPDATEUID")));
                    wicket.setVersion(rs.getInt("OC_WICKET_VERSION"));

                    vWickets.addElement(wicket);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vWickets;
    }

    public static Vector getWicketsByService(String sServiceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vWickets = new Vector();
        Wicket wicket;

        String sSelect = "SELECT * FROM OC_WICKETS WHERE OC_WICKET_SERVICEUID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sServiceUID);
            rs = ps.executeQuery();

            while(rs.next()){
                wicket = new Wicket();

                wicket.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_OBJECTID")));
                wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREATETIME"));
                wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_UPDATETIME"));
                wicket.setServiceUID(ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID")));
                wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_UPDATEUID")));
                wicket.setBalance(rs.getDouble("OC_WICKET_BALANCE"));
                wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));
                wicket.setVersion(rs.getInt("OC_WICKET_VERSION"));

                vWickets.addElement(wicket);
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
        return vWickets;
    }

    public static String getWicketName(String sWicketUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sName = "";
        String sServiceUID = "";
        String sSelect = "SELECT OC_WICKET_SERVICEUID FROM OC_WICKETS WHERE OC_WICKET_SERVERID = ? AND OC_WICKET_OBJECTID = ?";

        if(sWicketUID != null && sWicketUID.length() > 0){
            String sUids[] = sWicketUID.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        sServiceUID = ScreenHelper.checkString(rs.getString("OC_WICKET_SERVICEUID"));
                    }
                    rs.close();
                    ps.close();

                    sName = sWicketUID + " " + sServiceUID;
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
            }
        }
        return sName;
    }

    public void processWicketOperation(double amount){
        double endBalance = this.getBalance() + amount;
        this.setBalance(endBalance);
        this.store();
    }

    //--- RECALCULATE BALANCE ---------------------------------------------------------------------
    public void recalculateBalance(){
        PreparedStatement ps = null, ps2 = null;
        ResultSet rs = null;

        double dCredit = 0;
        double dDebet = 0;
        String sSql;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // wicket credit total
            sSql = "SELECT SUM(OC_WICKET_CREDIT_AMOUNT) AS WicketCredit"+
                   " FROM OC_WICKET_CREDITS WHERE OC_WICKET_CREDIT_WICKETUID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            rs = ps.executeQuery();
            if(rs.next()){
                dCredit = rs.getFloat("WicketCredit");
            }
            rs.close();
            ps.close();

            // wicket debet total
            sSql = "SELECT SUM(OC_WICKET_DEBET_AMOUNT) AS WicketDebet"+
                   " FROM OC_WICKET_DEBETS WHERE OC_WICKET_DEBET_WICKETUID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            rs = ps.executeQuery();
            if(rs.next()){
                dDebet = rs.getFloat("WicketDebet");
            }
            rs.close();
            ps.close();

            // update wicket balance in DB
            if(this.getUid() != null && this.getUid().length() > 0){
                String sUids[] = this.getUid().split("\\.");

                if(sUids.length == 2){
                    sSql = "UPDATE OC_WICKETS SET OC_WICKET_BALANCE = ?"+
                           " WHERE OC_WICKET_SERVERID = ? AND OC_WICKET_OBJECTID = ?";
                    ps2 = oc_conn.prepareStatement(sSql);
                    ps2.setDouble(1,dCredit-dDebet);
                    ps2.setInt(2,Integer.parseInt(sUids[0]));
                    ps2.setInt(3,Integer.parseInt(sUids[1]));

                    ps2.executeUpdate();
                    ps2.close();
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
                if(ps2!=null) ps2.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- CALCULATE BALANCE -----------------------------------------------------------------------
    public double calculateBalance(){
        return calculateBalance("");
    }

    public double calculateBalance(String sDateTo){
        PreparedStatement ps = null;
        ResultSet rs = null;

        double dWicketSaldo = 0, dDebetTotal = 0, dCreditTotal = 0;
        String sSql;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //*** calculate wicket debet total ***
            sSql = "SELECT SUM(OC_WICKET_DEBET_AMOUNT) AS debetTotal"+
                   " FROM OC_WICKET_DEBETS"+
                   "  WHERE OC_WICKET_DEBET_WICKETUID = ?";

            // end date of calculation
            if(sDateTo.length() > 0){
                sSql+= " AND OC_WICKET_DEBET_OPERATIONDATE < ?";
            }

            oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            if(sDateTo.length() > 0){
                ps.setDate(2,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sDateTo,"1"))); // next day
            }

            rs = ps.executeQuery();
            if(rs.next()){
                dDebetTotal = rs.getFloat("debetTotal");
            }
            rs.close();
            ps.close();

            //*** calculate wicket credit total ***
            sSql = "SELECT SUM(OC_WICKET_CREDIT_AMOUNT) AS creditTotal"+
                   " FROM OC_WICKET_CREDITS"+
                   "  WHERE OC_WICKET_CREDIT_WICKETUID = ?";

            // end date of calculation
            if(sDateTo.length() > 0){
                sSql+= " AND OC_WICKET_CREDIT_OPERATIONDATE < ?";
            }

            oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            if(sDateTo.length() > 0){
                ps.setDate(2,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sDateTo,"1"))); // next day
            }
            rs = ps.executeQuery();

            if(rs.next()){
                dCreditTotal = rs.getFloat("creditTotal");
            }
            rs.close();
            ps.close();

            // compute wicket balance
            dWicketSaldo = dCreditTotal - dDebetTotal;
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return dWicketSaldo;
    }

    public double calculateBalance(Date dateTo){
        PreparedStatement ps = null;
        ResultSet rs = null;

        double dWicketSaldo = 0, dDebetTotal = 0, dCreditTotal = 0;
        String sSql;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //*** calculate wicket debet total ***
            sSql = "SELECT SUM(OC_WICKET_DEBET_AMOUNT) AS debetTotal"+
                   " FROM OC_WICKET_DEBETS"+
                   "  WHERE OC_WICKET_DEBET_WICKETUID = ?";

            // end date of calculation
            if(dateTo!=null){
                sSql+= " AND OC_WICKET_DEBET_OPERATIONDATE < ?";
            }

            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            if(dateTo!=null){
                ps.setTimestamp(2,new Timestamp(dateTo.getTime()));
            }

            rs = ps.executeQuery();
            if(rs.next()){
                dDebetTotal = rs.getFloat("debetTotal");
            }
            rs.close();
            ps.close();

            //*** calculate wicket credit total ***
            sSql = "SELECT SUM(OC_WICKET_CREDIT_AMOUNT) AS creditTotal"+
                   " FROM OC_WICKET_CREDITS"+
                   "  WHERE OC_WICKET_CREDIT_WICKETUID = ?";

            // end date of calculation
            if(dateTo!=null){
                sSql+= " AND OC_WICKET_CREDIT_OPERATIONDATE < ?";
            }

            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
            if(dateTo!=null){
                ps.setTimestamp(2,new Timestamp(dateTo.getTime()));
            }
            rs = ps.executeQuery();

            if(rs.next()){
                dCreditTotal = rs.getFloat("creditTotal");
            }
            rs.close();
            ps.close();

            // compute wicket balance
            dWicketSaldo = dCreditTotal - dDebetTotal;
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return dWicketSaldo;
    }

    //--- GET DEBETS ------------------------------------------------------------------------------
    public static Vector getDebets(String sWicketUid){
        return getDebets(sWicketUid,"","");
    }

    public static Vector getDebets(String sWicketUid, String sDateFrom, String sDateTo){
        return getDebets(sWicketUid,sDateFrom,sDateTo,"","");
    }

    public static Vector getDebets(String sWicketUid, String sDateFrom, String sDateTo, String sSortCol, String sSortDirection){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Date fromDate=null,toDate=null;
        try {
            if(ScreenHelper.checkString(sDateFrom).length()==0){
                fromDate=new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date()));
            }
            else {
                fromDate=new SimpleDateFormat("dd/MM/yyyy").parse(sDateFrom);
            }
            if(ScreenHelper.checkString(sDateTo).length()==0){
                toDate=new Date(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())).getTime()+24*3600*1000-1);
            }
            else {
                toDate=new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDateTo).getTime()+24*3600*1000-1);
            }
        } catch (ParseException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        Vector vResults = new Vector();
        WicketDebet wicket;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT * FROM OC_WICKET_DEBETS"+
                             " WHERE OC_WICKET_DEBET_WICKETUID = ?";

            if(sDateFrom.length() > 0 && sDateTo.length() > 0){
                sSelect+= " AND OC_WICKET_DEBET_OPERATIONDATE >= ? AND OC_WICKET_DEBET_OPERATIONDATE< ?";
            }
            else if(sDateFrom.length() > 0){
                sSelect+= " AND OC_WICKET_DEBET_OPERATIONDATE >= ?";
            }
            else if(sDateTo.length() > 0){
                sSelect+= " AND OC_WICKET_DEBET_OPERATIONDATE < ?";
            }

            // order by
            if(sSortCol.length() > 0){
                sSelect+= " ORDER BY "+sSortCol;

                if(sSortDirection.length() > 0){
                    sSelect+= " "+sSortDirection;
                }
            }

            // set question marks
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWicketUid);

            int qmIdx = 2;
            if(sDateFrom.length() > 0){
                ps.setTimestamp(qmIdx++,new Timestamp(fromDate.getTime()));
            }
            if(sDateTo.length() > 0){
                ps.setTimestamp(qmIdx,new Timestamp(toDate.getTime())); // next day
            }
            rs = ps.executeQuery();

            while(rs.next()){
                wicket = new WicketDebet();

                wicket.setUid(rs.getString("OC_WICKET_DEBET_SERVERID") + "." + rs.getString("OC_WICKET_DEBET_OBJECTID"));
                wicket.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_WICKETUID")));
                wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_DEBET_CREATETIME"));
                wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_DEBET_UPDATETIME"));
                wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_UPDATEUID")));
                wicket.setAmount(rs.getDouble("OC_WICKET_DEBET_AMOUNT"));
                wicket.setOperationDate(rs.getTimestamp("OC_WICKET_DEBET_OPERATIONDATE"));
                wicket.setUserUID(rs.getInt("OC_WICKET_DEBET_USERUID"));
                wicket.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_TYPE")));
                wicket.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_COMMENT"))));

                // reference
                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_REFERENCEUID")));
                wicket.setReferenceObject(or);

                wicket.setVersion(rs.getInt("OC_WICKET_DEBET_VERSION"));
                vResults.addElement(wicket);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vResults;
    }

    //--- GET CREDITS -----------------------------------------------------------------------------
    public static Vector getCredits(String sWicketUid){
        return getCredits(sWicketUid,"","");
    }

    public static Vector getCredits(String sWicketUid, String sDateFrom, String sDateTo){
        return getCredits(sWicketUid,sDateFrom,sDateTo,"","");
    }

    public static Vector getCredits(String sWicketUid, String sDateFrom, String sDateTo, String sSortCol, String sSortDirection){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Date fromDate=null,toDate=null;
        try {
            if(ScreenHelper.checkString(sDateFrom).length()==0){
                fromDate=new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date()));
            }
            else {
                fromDate=new SimpleDateFormat("dd/MM/yyyy").parse(sDateFrom);
            }
            if(ScreenHelper.checkString(sDateTo).length()==0){
                toDate=new Date(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())).getTime()+24*3600*1000-1);
            }
            else {
                toDate=new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDateTo).getTime()+24*3600*1000-1);
            }
        } catch (ParseException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }


        Vector vResults = new Vector();
        WicketCredit wicket;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT * FROM OC_WICKET_CREDITS"+
                             " WHERE OC_WICKET_CREDIT_WICKETUID = ?";

            // add date range
            if(sDateFrom.length() > 0 && sDateTo.length() > 0){
                sSelect+= " AND OC_WICKET_CREDIT_OPERATIONDATE >=? AND OC_WICKET_CREDIT_OPERATIONDATE<?";
            }
            else if(sDateFrom.length() > 0){
                sSelect+= " AND OC_WICKET_CREDIT_OPERATIONDATE >= ?";
            }
            else if(sDateTo.length() > 0){
                sSelect+= " AND OC_WICKET_CREDIT_OPERATIONDATE < ?";
            }

            // order by
            if(sSortCol.length() > 0){
                sSelect+= " ORDER BY "+sSortCol;

                if(sSortDirection.length() > 0){
                    sSelect+= " "+sSortDirection;
                }
            }

            // set question marks
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWicketUid);

            int qmIdx = 2;
            if(sDateFrom.length() > 0){
                ps.setTimestamp(qmIdx++,new Timestamp(fromDate.getTime()));
            }
            if(sDateTo.length() > 0){
                ps.setTimestamp(qmIdx,new Timestamp(toDate.getTime())); // next day
            }
            rs = ps.executeQuery();

            while(rs.next()){
                wicket = new WicketCredit();

                wicket.setUid(rs.getString("OC_WICKET_CREDIT_SERVERID") + "." + rs.getString("OC_WICKET_CREDIT_OBJECTID"));
                wicket.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                wicket.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                wicket.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                wicket.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                wicket.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                wicket.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                wicket.setUserUID(rs.getInt("OC_WICKET_CREDIT_USERUID"));
                wicket.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                wicket.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));

                // reference
                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                wicket.setReferenceObject(or);

                wicket.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                wicket.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));
                vResults.addElement(wicket);
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
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vResults;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(){
        PreparedStatement ps = null;
        String ids[];
        String sDelete, sInsert;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");

                if(ids.length == 2){
                    // copy to history
                    sInsert = "INSERT INTO OC_WICKETS_HISTORY"+
                              " SELECT OC_WICKET_SERVERID,"+
                                     " OC_WICKET_OBJECTID,"+
                                     " OC_WICKET_BALANCE,"+
                                     " OC_WICKET_AUTHORIZEDUSERS,"+
                                     " OC_WICKET_SERVICEUID,"+
                                     " OC_WICKET_CREATETIME,"+
                                     " OC_WICKET_UPDATETIME,"+
                                     " OC_WICKET_UPDATEUID,"+
                                     " OC_WICKET_VERSION"+
                              " FROM OC_WICKETS"+
                              "  WHERE OC_WICKET_SERVERID = ?"+
                              "   AND OC_WICKET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    // delete record
                    sDelete = "DELETE FROM OC_WICKETS "+
                              " WHERE OC_WICKET_SERVERID = ? "+
                              "  AND OC_WICKET_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }
}
