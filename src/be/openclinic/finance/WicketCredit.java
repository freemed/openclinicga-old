package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Date;





public class WicketCredit extends OC_Object{
    private Wicket wicket;
    private String wicketUID;
    private Timestamp operationDate;
    private double amount;
    private int userUID;
    private String operationType;
    private StringBuffer comment;
    private ObjectReference referenceObject;
    private String invoiceUID;

    public String getInvoiceUID() {
        return invoiceUID;
    }

    public Invoice getInvoice() {
        return PatientInvoice.get(getInvoiceUID());
    }

    public void setInvoiceUID(String invoiceUID) {
        this.invoiceUID = invoiceUID;
    }

    public Wicket getWicket() {
        return wicket;
    }

    public void setWicket(Wicket wicket) {
        this.wicket = wicket;
    }

    public String getWicketUID() {
        return wicketUID;
    }

    public void setWicketUID(String wicketUID) {
        this.wicketUID = wicketUID;
    }

    public Timestamp getOperationDate() {
        return operationDate;
    }

    public void setOperationDate(Timestamp operationDate) {
        this.operationDate = operationDate;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public int getUserUID() {
        return userUID;
    }

    public void setUserUID(int userUID) {
        this.userUID = userUID;
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public StringBuffer getComment() {
        return comment;
    }

    public void setComment(StringBuffer comment) {
        this.comment = comment;
    }

    public void setComment(String comment) {
        this.comment = new StringBuffer(comment);
    }

    public ObjectReference getReferenceObject() {
        return referenceObject;
    }

    public void setReferenceObject(ObjectReference referenceObject) {
        this.referenceObject = referenceObject;
    }

    public static WicketCredit get(String uid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        WicketCredit wicketOps = new WicketCredit();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_WICKET_CREDITS WHERE OC_WICKET_CREDIT_SERVERID = ? AND OC_WICKET_CREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        wicketOps.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_OBJECTID")));
                        wicketOps.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                        wicketOps.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                        wicketOps.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                        wicketOps.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                        wicketOps.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                        wicketOps.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                        wicketOps.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));
                        wicketOps.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                        //wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));

                        ObjectReference or = new ObjectReference();
                        or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                        or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                        wicketOps.setReferenceObject(or);
                        wicketOps.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                        wicketOps.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));
                    }
                    rs.close();
                    ps.close();
                }catch(Exception e){
                    Debug.println("OpenClinic => WicketCredit.java => get => "+e.getMessage());
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
        return wicketOps;
    }

    //--- GET BY REFERENCE UID --------------------------------------------------------------------
    public static WicketCredit getByReferenceUid(String sReferenceUid,String type){
        PreparedStatement ps = null;
        ResultSet rs = null;

        WicketCredit wicketCredit = new WicketCredit();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_WICKET_CREDITS"+
                             " WHERE OC_WICKET_CREDIT_REFERENCEUID = ? and OC_WICKET_CREDIT_REFERENCETYPE=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sReferenceUid);
            ps.setString(2, type);
            rs = ps.executeQuery();

            if(rs.next()){
                wicketCredit.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_SERVERID"))+"."+
                                    ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_OBJECTID")));

                wicketCredit.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                wicketCredit.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                wicketCredit.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                wicketCredit.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                wicketCredit.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                wicketCredit.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                wicketCredit.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));
                wicketCredit.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                wicketCredit.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                wicketCredit.setUserUID(rs.getInt("OC_WICKET_CREDIT_USERUID"));
                wicketCredit.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));

                // reference
                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                wicketCredit.setReferenceObject(or);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!= null) rs.close();
                if(ps!= null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return wicketCredit;
    }


    //--- GET BY REFERENCE UID --------------------------------------------------------------------
    public static WicketCredit getByReferenceUid(String sReferenceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        WicketCredit wicketCredit = new WicketCredit();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_WICKET_CREDITS"+
                             " WHERE OC_WICKET_CREDIT_REFERENCEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sReferenceUid);
            rs = ps.executeQuery();

            if(rs.next()){
                wicketCredit.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_SERVERID"))+"."+
                                    ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_OBJECTID")));

                wicketCredit.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                wicketCredit.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                wicketCredit.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                wicketCredit.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                wicketCredit.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                wicketCredit.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                wicketCredit.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));
                wicketCredit.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                wicketCredit.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                wicketCredit.setUserUID(rs.getInt("OC_WICKET_CREDIT_USERUID"));
                wicketCredit.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));

                // reference
                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                wicketCredit.setReferenceObject(or);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!= null) rs.close();
                if(ps!= null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return wicketCredit;
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
                    sSelect = " SELECT * FROM OC_WICKET_CREDITS WHERE OC_WICKET_CREDIT_SERVERID = ? AND OC_WICKET_CREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_WICKET_CREDIT_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_WICKET_CREDITS_HISTORY " +
                              " SELECT OC_WICKET_CREDIT_SERVERID," +
                                     " OC_WICKET_CREDIT_OBJECTID," +
                                     " OC_WICKET_CREDIT_WICKETUID," +
                                     " OC_WICKET_CREDIT_OPERATIONDATE," +
                                     " OC_WICKET_CREDIT_AMOUNT," +
                                     " OC_WICKET_CREDIT_USERUID," +
                                     " OC_WICKET_CREDIT_TYPE," +
                                     " OC_WICKET_CREDIT_COMMENT," +
                                     " OC_WICKET_CREDIT_REFERENCETYPE," +
                                     " OC_WICKET_CREDIT_REFERENCEUID," +
                                     " OC_WICKET_CREDIT_CREATETIME," +
                                     " OC_WICKET_CREDIT_UPDATETIME," +
                                     " OC_WICKET_CREDIT_UPDATEUID,"  +
                                     " OC_WICKET_CREDIT_VERSION," +
                                     " OC_WICKET_CREDIT_INVOICEUID" +
                              " FROM OC_WICKET_CREDITS  WHERE OC_WICKET_CREDIT_SERVERID = ? AND OC_WICKET_CREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_WICKET_CREDITS  WHERE OC_WICKET_CREDIT_SERVERID = ?  AND OC_WICKET_CREDIT_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_WICKET_CREDITS")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_WICKET_CREDITS" +
                          "(" +
                          " OC_WICKET_CREDIT_SERVERID," +
                          " OC_WICKET_CREDIT_OBJECTID," +
                          " OC_WICKET_CREDIT_WICKETUID," +
                          " OC_WICKET_CREDIT_OPERATIONDATE," +
                          " OC_WICKET_CREDIT_AMOUNT," +
                          " OC_WICKET_CREDIT_USERUID," +
                          " OC_WICKET_CREDIT_TYPE," +
                          " OC_WICKET_CREDIT_COMMENT," +
                          " OC_WICKET_CREDIT_REFERENCETYPE," +
                          " OC_WICKET_CREDIT_REFERENCEUID," +
                          " OC_WICKET_CREDIT_CREATETIME," +
                          " OC_WICKET_CREDIT_UPDATETIME," +
                          " OC_WICKET_CREDIT_UPDATEUID,"  +
                          " OC_WICKET_CREDIT_VERSION," +
                          " OC_WICKET_CREDIT_INVOICEUID" +
                          ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getWicketUID());
                ps.setTimestamp(4,this.getOperationDate());
                ps.setDouble(5,this.getAmount());
                ps.setInt(6,this.getUserUID());
                ps.setString(7,this.getOperationType());
                ps.setString(8,this.getComment().toString());
                if (this.getReferenceObject()!=null){
                    ps.setString(9,this.getReferenceObject().getObjectType());
                    ps.setString(10,this.getReferenceObject().getObjectUid());
                }
                else{
                    ps.setString(9,"");
                    ps.setString(10,"");
                }
                ps.setTimestamp(11,new Timestamp(this.getCreateDateTime()!=null?this.getCreateDateTime().getTime():new Date().getTime()));
                ps.setTimestamp(12,new Timestamp(this.getUpdateDateTime()!=null?this.getUpdateDateTime().getTime():new Date().getTime()));
                ps.setString(13,this.getUpdateUser());
                ps.setInt(14,iVersion);
                ps.setString(15,this.getInvoiceUID());
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => WicketCredit.java => store => "+e.getMessage());
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

    public static Vector selectWicketOperations(String sBegindate, String sEnddate, String sReferenceUID, String sReferenceType, String sType, String sWicketUID, String findSortColumn){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vWicketOps = new Vector();
        WicketCredit wicketOps;

        String sCondition = "";
        String sSelect = " SELECT * FROM OC_WICKET_CREDITS";

        if(sBegindate.length() > 0)     sCondition += " OC_WICKET_CREDIT_OPERATIONDATE >= ? AND";
        if(sEnddate.length() > 0)       sCondition += " OC_WICKET_CREDIT_OPERATIONDATE < ? AND";
        if(sType.length() > 0)          sCondition += " OC_WICKET_CREDIT_TYPE = ? AND";
        if(sReferenceUID.length() > 0)  sCondition += " OC_WICKET_CREDIT_REFERENCEUID = ? AND";
        if(sReferenceType.length() > 0) sCondition += " OC_WICKET_CREDIT_REFERENCETYPE = ? AND";
        if(sWicketUID.length() > 0)     sCondition += " OC_WICKET_CREDIT_WICKETUID = ? AND";

        if(sCondition.length() > 0){
            sSelect += " WHERE " + sCondition;
            sSelect = sSelect.substring(0,sSelect.length() - 3);
        }

        if(findSortColumn.length() == 0){
            findSortColumn = "OC_WICKET_CREDIT_OPERATIONDATE DESC";
        }

        sSelect += " ORDER BY " + findSortColumn;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            int i = 1;
            ps = oc_conn.prepareStatement(sSelect);

            if(sBegindate.length() > 0)       { ps.setDate(i++,ScreenHelper.getSQLDate(sBegindate));}
            if(sEnddate.length() > 0)         { ps.setDate(i++,ScreenHelper.getSQLDate(sEnddate));}
            if(sType.length() > 0)            { ps.setString(i++,sType);}
            if(sReferenceUID.length() > 0)    { ps.setString(i++,sReferenceUID);}
            if(sReferenceType.length() > 0)   { ps.setString(i++,sReferenceType);}
            if(sWicketUID.length() > 0)       { ps.setString(i,sWicketUID);}
            rs = ps.executeQuery();

            while(rs.next()){
                wicketOps = new WicketCredit();

                wicketOps.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_OBJECTID")));
                wicketOps.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                wicketOps.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                wicketOps.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                wicketOps.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                wicketOps.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                wicketOps.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                wicketOps.setUserUID(rs.getInt("OC_WICKET_CREDIT_USERUID"));
                wicketOps.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                wicketOps.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));
                //wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));

                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                wicketOps.setReferenceObject(or);
                wicketOps.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                wicketOps.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));

                vWicketOps.addElement(wicketOps);
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
        return vWicketOps;
    }


    public static Vector selectWicketOperationsByWicket(String sWicketUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_WICKET_CREDITS WHERE OC_WICKET_CREDIT_WICKETUID = ? ORDER BY OC_WICKET_CREDIT_DATE DESC";

        Vector vWicketOps = new Vector();

        WicketCredit wicketOp;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWicketUID);

            rs = ps.executeQuery();

            while(rs.next()){
                wicketOp = new WicketCredit();

                wicketOp.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_OBJECTID")));
                wicketOp.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_WICKETUID")));
                wicketOp.setCreateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_CREATETIME"));
                wicketOp.setUpdateDateTime(rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME"));
                wicketOp.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_UPDATEUID")));
                wicketOp.setAmount(rs.getDouble("OC_WICKET_CREDIT_AMOUNT"));
                wicketOp.setOperationDate(rs.getTimestamp("OC_WICKET_CREDIT_OPERATIONDATE"));
                wicketOp.setUserUID(rs.getInt("OC_WICKET_CREDIT_USERUID"));
                wicketOp.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE")));
                wicketOp.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_COMMENT"))));
                //wicket.setAuthorizedUsersId(ScreenHelper.checkString(rs.getString("OC_WICKET_AUTHORIZEDUSERS")));

                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_REFERENCEUID")));
                wicketOp.setReferenceObject(or);
                wicketOp.setVersion(rs.getInt("OC_WICKET_CREDIT_VERSION"));
                wicketOp.setInvoiceUID(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));

                vWicketOps.addElement(wicketOp);
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
        return vWicketOps;
    }

    public static Vector selectWaitingTransfers(String sWicketUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_WICKET_DEBETS WHERE OC_WICKET_DEBET_REFERENCETYPE='WicketTransfer' and OC_WICKET_DEBET_REFERENCEUID=?"
        		+ " AND NOT EXISTS (SELECT * FROM OC_WICKET_CREDITS WHERE OC_WICKET_CREDIT_REFERENCETYPE='WicketTransfer' and OC_WICKET_CREDIT_REFERENCEUID='"+MedwanQuery.getInstance().getConfigInt("serverId")+".'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "OC_WICKET_DEBET_OBJECTID")+")";

        Vector vWicketOps = new Vector();

        WicketDebet wicketOp;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sWicketUID);

            rs = ps.executeQuery();

            while(rs.next()){
                wicketOp = new WicketDebet();

                wicketOp.setUid(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_OBJECTID")));
                wicketOp.setWicketUID(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_WICKETUID")));
                wicketOp.setCreateDateTime(rs.getTimestamp("OC_WICKET_DEBET_CREATETIME"));
                wicketOp.setUpdateDateTime(rs.getTimestamp("OC_WICKET_DEBET_UPDATETIME"));
                wicketOp.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_UPDATEUID")));
                wicketOp.setAmount(rs.getDouble("OC_WICKET_DEBET_AMOUNT"));
                wicketOp.setOperationDate(rs.getTimestamp("OC_WICKET_DEBET_OPERATIONDATE"));
                wicketOp.setUserUID(rs.getInt("OC_WICKET_DEBET_USERUID"));
                wicketOp.setOperationType(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_TYPE")));
                wicketOp.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_COMMENT"))));

                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_REFERENCETYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_WICKET_DEBET_REFERENCEUID")));
                wicketOp.setReferenceObject(or);
                wicketOp.setVersion(rs.getInt("OC_WICKET_DEBET_VERSION"));

                vWicketOps.addElement(wicketOp);
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
        return vWicketOps;
    }

    public void delete(){
        PreparedStatement ps = null;

        String sInsert,sDelete;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sInsert = " INSERT INTO OC_WICKET_CREDITS_HISTORY " +
                              " SELECT OC_WICKET_CREDIT_SERVERID," +
                                     " OC_WICKET_CREDIT_OBJECTID," +
                                     " OC_WICKET_CREDIT_WICKETUID," +
                                     " OC_WICKET_CREDIT_OPERATIONDATE," +
                                     " OC_WICKET_CREDIT_AMOUNT," +
                                     " OC_WICKET_CREDIT_USERUID," +
                                     " OC_WICKET_CREDIT_TYPE," +
                                     " OC_WICKET_CREDIT_COMMENT," +
                                     " OC_WICKET_CREDIT_REFERENCETYPE," +
                                     " OC_WICKET_CREDIT_REFERENCEUID," +
                                     " OC_WICKET_CREDIT_CREATETIME," +
                                     " OC_WICKET_CREDIT_UPDATETIME," +
                                     " OC_WICKET_CREDIT_UPDATEUID,"  +
                                     " OC_WICKET_CREDIT_VERSION," +
                                     " OC_WICKET_CREDIT_INVOICEUID" +
                              " FROM OC_WICKET_CREDITS " +
                              " WHERE OC_WICKET_CREDIT_SERVERID = ?" +
                              " AND OC_WICKET_CREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_WICKET_CREDITS " +
                              " WHERE OC_WICKET_CREDIT_SERVERID = ? " +
                              " AND OC_WICKET_CREDIT_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
}