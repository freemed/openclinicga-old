package be.openclinic.healthrecord;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 12-jan-2007
 * Time: 16:52:34
 * To change this template use Options | File Templates.
 */
public class RiskCode {
    private int id;
    private String code;
    private String messageKey;
    private int showDefault;
    private String NL;
    private String FR;
    private int active;
    private Timestamp updatetime;
    private Timestamp deletedate;
    private int updateuserid;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public int getShowDefault() {
        return showDefault;
    }

    public void setShowDefault(int showDefault) {
        this.showDefault = showDefault;
    }

    public String getNL() {
        return NL;
    }

    public void setNL(String NL) {
        this.NL = NL;
    }

    public String getFR() {
        return FR;
    }

    public void setFR(String FR) {
        this.FR = FR;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Timestamp deletedate) {
        this.deletedate = deletedate;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }


    public static Vector selectTranslations(String sLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        Hashtable hResults;

        String sSelect = "SELECT id, ";
        if(sLanguage.equalsIgnoreCase("N")) sSelect+= " NL";
        else                                sSelect+= " FR";

        sSelect+= " AS Translation FROM RiskCodes WHERE active=1 AND deletedate IS NULL";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            while(rs.next()){
                hResults = new Hashtable();
                hResults.put("id",ScreenHelper.checkString(rs.getString("id")));
                if(sLanguage.equalsIgnoreCase("N")) hResults.put("translation",ScreenHelper.checkString("NL"));
                else                                hResults.put("translation",ScreenHelper.checkString("FR"));

                vResults.addElement(hResults);
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
        return vResults;
    }
}
