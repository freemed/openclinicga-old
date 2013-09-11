package be.openclinic.system;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 5-jan-2007
 * Time: 11:12:08
 * To change this template use Options | File Templates.
 */
public class Config {
    private String oc_key;
    private int updateuserid;
    private Timestamp updatetime;
    private Timestamp deletetime;
    private StringBuffer comment;
    private Date deletedate;
    private int override;
    private String defaultvalue;
    private StringBuffer oc_value;
    private StringBuffer sql_value;
    private String synchronize;

    public String getOc_key() {
        return oc_key;
    }

    public void setOc_key(String oc_key) {
        this.oc_key = oc_key;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletetime() {
        return deletetime;
    }

    public void setDeletetime(Timestamp deletetime) {
        this.deletetime = deletetime;
    }

    public StringBuffer getComment() {
        return comment;
    }

    public void setComment(StringBuffer comment) {
        this.comment = comment;
    }

    public Date getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Date deletedate) {
        this.deletedate = deletedate;
    }

    public int getOverride() {
        return override;
    }

    public void setOverride(int override) {
        this.override = override;
    }

    public String getDefaultvalue() {
        return defaultvalue;
    }

    public void setDefaultvalue(String defaultvalue) {
        this.defaultvalue = defaultvalue;
    }

    public StringBuffer getOc_value() {
        return oc_value;
    }

    public void setOc_value(StringBuffer oc_value) {
        this.oc_value = oc_value;
    }

    public StringBuffer getSql_value() {
        return sql_value;
    }

    public void setSql_value(StringBuffer sql_value) {
        this.sql_value = sql_value;
    }

    public String getSynchronize() {
        return synchronize;
    }

    public void setSynchronize(String synchronize) {
        this.synchronize = synchronize;
    }

    public static boolean exists(String sOC_Key){
        PreparedStatement ps;
        ResultSet rs;

        boolean bExists = false;

        String sSelect = " SELECT oc_key FROM OC_Config WHERE oc_key = ?";

    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sSelect);
            ps.setString(1,sOC_Key);

            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
            }
            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return bExists;
    }

    public static Vector searchConfig(String sFindKey, String sFindValue){
        PreparedStatement ps;
        ResultSet rs;

        Vector vConfig = new Vector();
        String sSelect = "SELECT oc_key, oc_value, updatetime, deletetime FROM OC_Config";


        if(sFindKey.length() == 0 && sFindValue.length() == 0){
            // select all records
        }
        else{
            sSelect+= " WHERE ";

            if(sFindKey.length() > 0 && sFindValue.length() > 0){
                sSelect+= ScreenHelper.getConfigParam("lowerCompare","oc_key")+" LIKE '%"+ScreenHelper.checkDbString(sFindKey.toLowerCase())+"%'"+
                          " AND oc_value LIKE '%"+ScreenHelper.checkDbString(sFindValue)+"%'";
            }
            else if(sFindKey.length() > 0){
                sSelect+= ScreenHelper.getConfigParam("lowerCompare","oc_key")+" LIKE '%"+ScreenHelper.checkDbString(sFindKey.toLowerCase())+"%'";
            }
            else if(sFindValue.length() > 0){
                sSelect+= "oc_value LIKE '%"+ScreenHelper.checkDbString(sFindValue)+"%'";
            }
        }

        sSelect+= " ORDER BY "+ScreenHelper.getConfigParam("lowerCompare","oc_key");



    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();

            Config objConfig;
            while(rs.next()){
                objConfig = new Config();
                objConfig.setOc_key(ScreenHelper.checkString(rs.getString(1)));
                objConfig.setOc_value(new StringBuffer(ScreenHelper.checkString(rs.getString(2))));
                objConfig.setUpdatetime(rs.getTimestamp(3));
                objConfig.setDeletetime(rs.getTimestamp(4));
                vConfig.addElement(objConfig);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return vConfig;
    }

    public static void addConfig(Config objConfig){
        PreparedStatement ps;

        String sInsert = "INSERT INTO OC_Config(oc_key, oc_value, updateuserid, updatetime, comment,"+
                          "  defaultvalue, override, sql_value, deletetime) VALUES(?,?,?,?,?,?,?,?,?)";
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sInsert);
            ps.setString(1,objConfig.getOc_key());
            ps.setString(2,objConfig.getOc_value().toString());
            ps.setInt(3,objConfig.getUpdateuserid());
            ps.setTimestamp(4,objConfig.getUpdatetime());
            ps.setString(5,objConfig.getComment().toString());
            ps.setString(6,objConfig.getDefaultvalue());
            ps.setInt(7,objConfig.getOverride());
            ps.setString(8,objConfig.getSql_value().toString());
            ps.setTimestamp(9,objConfig.getDeletetime());

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void saveConfig(Config objConfig){
        PreparedStatement ps;
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();

        String sUpdate = " UPDATE OC_Config SET oc_value = ?," +
                                              " oc_key = ?," +
                                              " updateuserid = ?," +
                                              " updatetime = ?, "+
                                              " comment = ?," +
                                              " defaultvalue = ?," +
                                              " override = ?," +
                                              " sql_value = ?," +
                                              " deletetime = ?," +
                                              " synchronize = ?"+
                         " WHERE oc_key = ?";

        try{
            ps = co_conn.prepareStatement(sUpdate);
            ps.setString(1,objConfig.getOc_value().toString());
            ps.setString(2,objConfig.getOc_key());
            ps.setInt(3,objConfig.getUpdateuserid());
            ps.setTimestamp(4,objConfig.getUpdatetime());
            ps.setString(5,objConfig.getComment().toString());
            ps.setString(6,objConfig.getDefaultvalue());
            ps.setInt(7,objConfig.getOverride());
            ps.setString(8,objConfig.getSql_value().toString());
            ps.setTimestamp(9,objConfig.getDeletetime());
            ps.setString(10,objConfig.getSynchronize());
            ps.setString(11,objConfig.getOc_key());

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void deleteConfig(String oc_key){
        PreparedStatement ps;

        String sDelete = "DELETE FROM OC_Config WHERE oc_key = ?";

    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sDelete);
            ps.setString(1,oc_key);

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static Config getConfig(String oc_key){
        PreparedStatement ps;
        ResultSet rs;

        Config objConfig = new Config();

        String sSelect = " SELECT * FROM OC_Config WHERE oc_key = ?";

    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sSelect);
            ps.setString(1,oc_key);

            rs = ps.executeQuery();

            if(rs.next()){
                objConfig.setOc_key(ScreenHelper.checkString(rs.getString("oc_key")));
                objConfig.setOc_value(new StringBuffer(ScreenHelper.checkString(rs.getString("oc_value"))));
                                
                objConfig.setUpdateuserid(rs.getInt("updateuserid"));
                objConfig.setUpdatetime(rs.getTimestamp("updatetime"));
                objConfig.setComment(new StringBuffer(ScreenHelper.checkString(rs.getString("comment"))));
                objConfig.setDefaultvalue(ScreenHelper.checkString(rs.getString("defaultvalue")));
                if(ScreenHelper.checkString(rs.getString("override")).length() > 0){
                    objConfig.setOverride(Integer.parseInt(ScreenHelper.checkString(rs.getString("override"))));
                }
                objConfig.setSql_value(new StringBuffer(ScreenHelper.checkString(rs.getString("sql_value"))));
                objConfig.setDeletedate(rs.getDate("deletedate"));
                objConfig.setDeletetime(rs.getTimestamp("deletetime"));
                objConfig.setSynchronize(ScreenHelper.checkString(rs.getString("synchronize")));
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return objConfig;
    }

    public static Hashtable executeConfigSQL_value(String sql_value){
        PreparedStatement ps;
        ResultSet rs;

        Hashtable hSQL = new Hashtable();

    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sql_value);

            rs = ps.executeQuery();

            while(rs.next()){
                hSQL.put(ScreenHelper.checkString(rs.getString("SQLID")),ScreenHelper.checkString(rs.getString("SQLName")));
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			co_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return hSQL;
    }

    public static Vector getLastSyncConfigs(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT oc_key, oc_value " +
                         "FROM OC_Config " +
                         "WHERE LOWER(oc_key) LIKE 'lastsync%' " +
                         "order by "+ MedwanQuery.getInstance().convert("varchar(255)","oc_value") ;
        if(MedwanQuery.getInstance().getConfigInt("cacheDB")==1){
            sSelect = "SELECT oc_key, oc_value " +
                      "FROM OC_Config " +
                      "WHERE LOWER(oc_key) LIKE 'lastsync%' " +
                      "order by oc_value" ;
        }

        Config objConfig;
        Vector vConfigs = new Vector();
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                objConfig = new Config();
                objConfig.setOc_key(ScreenHelper.checkString(rs.getString("oc_key")));
                objConfig.setOc_value(new StringBuffer(ScreenHelper.checkString(rs.getString("oc_value"))));

                vConfigs.addElement(objConfig);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                co_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return  vConfigs;
    }

    public static String getNotDeletedConfigByKey(String sKey){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sValue = "";

        String sQuery = "SELECT oc_value FROM OC_Config" +
                    " WHERE oc_key like '" + sKey + "' AND deletetime is null ORDER BY oc_key";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sQuery);
            rs = ps.executeQuery();
            while (rs.next()) {
                sValue = rs.getString("oc_value");
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
        return sValue;
    }

    public static void insert(String sKey,String sValue){
        PreparedStatement ps = null;

        String sInsert ="insert into OC_Config(oc_key,oc_value) values(?,?)";

    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            ps = co_conn.prepareStatement(sInsert);
            ps.setString(1, sKey);
            ps.setString(2, sValue);
            ps.execute();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                co_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

}
