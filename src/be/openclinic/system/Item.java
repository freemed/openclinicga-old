package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Connection;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 10-jan-2007
 * Time: 14:00:45
 * To change this template use Options | File Templates.
 */
public class Item {
    private int itemId;
    private String type;
    private String value;
    private Timestamp date;
    private int transactionId;
    private int serverid;
    private int version;
    private int versionserverid;
    private int priority;
    private int valuehash;

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getServerid() {
        return serverid;
    }

    public void setServerid(int serverid) {
        this.serverid = serverid;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public int getVersionserverid() {
        return versionserverid;
    }

    public void setVersionserverid(int versionserverid) {
        this.versionserverid = versionserverid;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public int getValuehash() {
        return valuehash;
    }

    public void setValuehash(int valuehash) {
        this.valuehash = valuehash;
    }

    public static String selectMaxItemIdByServer(String serverid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT max(itemId) AS MaxId FROM Items WHERE serverid = ? ";

        String value = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(serverid));
            rs = ps.executeQuery();

            if(rs.next()){
                value = ScreenHelper.checkString(rs.getString("MaxId"));
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
        return value;
    }

    public static Vector getItems(String sTransactionId,String sServerId,String sType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vItems = new Vector();

        String sSelect = " SELECT type, "+MedwanQuery.getInstance().getConfigString("valueColumn")+"  FROM Items";
        String sAdd = "";
        if(sTransactionId.length() > 0){sAdd += " transactionId = ? AND"; }
        if(sServerId.length() > 0)     {sAdd += " serverid = ? AND";}
        if(sType.length() > 0)         {sAdd += " type = ? AND";}

        if(sAdd.length() > 0){
            sSelect += " WHERE " + sAdd.substring(0,sAdd.length()-3);
        }

        int iQuestionCounter = 1;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            if(sTransactionId.length() > 0){ps.setInt(iQuestionCounter++,Integer.parseInt(sTransactionId));}
            if(sServerId.length() > 0)     {ps.setInt(iQuestionCounter++,Integer.parseInt(sServerId));}
            if(sType.length() > 0)         {ps.setString(iQuestionCounter++,sType);}
            rs = ps.executeQuery();

            Item item;

            while(rs.next()){
                item = new Item();
                item.setType(ScreenHelper.checkString(rs.getString("type")));
                item.setValue(ScreenHelper.checkString(rs.getString("value")));

                vItems.addElement(item);
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
        return vItems;
    }
}


