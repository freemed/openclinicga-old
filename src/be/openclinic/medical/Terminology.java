package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.openclinic.common.OC_Object;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Vector;

public class Terminology extends OC_Object {
    private String terminologyType;
    private String userUID;
    private String phrase;

    public String getTerminologyType() {
        return terminologyType;
    }

    public void setTerminologyType(String terminologyType) {
        this.terminologyType = terminologyType;
    }

    public String getUserUID() {
        return userUID;
    }

    public void setUserUID(String userUID) {
        this.userUID = userUID;
    }

    public String getPhrase() {
        return phrase;
    }

    public void setPhrase(String phrase) {
        this.phrase = phrase;
    }

    public static Terminology get(String uid){
        PreparedStatement ps = null;
        ResultSet rs =null;

        Terminology tObj = new Terminology();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_TERMINOLOGIES " +
                                     " WHERE OC_TERMINOLOGY_SERVERID = ? " +
                                     " AND OC_TERMINOLOGY_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        tObj.setTerminologyType(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_TYPE")));
                        tObj.setPhrase(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_PHRASE")));
                        tObj.setUserUID(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_USERUID")));
                        tObj.setUid(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_OBJECTID")));
                        tObj.setCreateDateTime(rs.getTimestamp("OC_TERMINOLOGY_CREATETIME"));
                        tObj.setUpdateDateTime(rs.getTimestamp("OC_TERMINOLOGY_UPDATETIME"));
                        tObj.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_UPDATEUID")));
                        tObj.setVersion(rs.getInt("OC_TERMINOLOGY_VERSION"));
                    }
                    rs.close();
                    ps.close();
                }catch(Exception e){
                    Debug.println("OpenClinic => Terminology.java => get => "+e.getMessage());
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
        return tObj;
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
                    sSelect = " SELECT * FROM OC_TERMINOLOGIES " +
                              " WHERE OC_TERMINOLOGY_SERVERID = ? " +
                              " AND OC_TERMINOLOGY_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_TERMINOLOGY_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_TERMINOLOGIES_HISTORY " +
                              " SELECT OC_TERMINOLOGY_SERVERID," +
                                     " OC_TERMINOLOGY_OBJECTID," +
                                     " OC_TERMINOLOGY_TYPE," +
                                     " OC_TERMINOLOGY_USERUID," +
                                     " OC_TERMINOLOGY_PHRASE," +
                                     " OC_TERMINOLOGY_CREATETIME," +
                                     " OC_TERMINOLOGY_UPDATETIME," +
                                     " OC_TERMINOLOGY_UPDATEUID,"  +
                                     " OC_TERMINOLOGY_VERSION" +
                              " FROM OC_TERMINOLOGIES " +
                              " WHERE OC_TERMINOLOGY_SERVERID = ?" +
                              " AND OC_TERMINOLOGY_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_TERMINOLOGIES " +
                              " WHERE OC_TERMINOLOGY_SERVERID = ? " +
                              " AND OC_TERMINOLOGY_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_TERMINOLOGIES")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_TERMINOLOGIES" +
                                      "(" +
                                      " OC_TERMINOLOGY_SERVERID," +
                                      " OC_TERMINOLOGY_OBJECTID," +
                                      " OC_TERMINOLOGY_TYPE," +
                                      " OC_TERMINOLOGY_USERUID," +
                                      " OC_TERMINOLOGY_PHRASE," +
                                      " OC_TERMINOLOGY_CREATETIME," +
                                      " OC_TERMINOLOGY_UPDATETIME," +
                                      " OC_TERMINOLOGY_UPDATEUID,"  +
                                      " OC_TERMINOLOGY_VERSION" +
                                      ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getTerminologyType());
                ps.setString(4,this.getUserUID());
                ps.setString(5,this.getPhrase());
                ps.setTimestamp(6,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(7,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,iVersion);
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => Terminology.java => store => "+e.getMessage());
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

    public static Vector getTerminologies(String sType,String sPhrase,String sUser){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vTerminologies = new Vector();

        Terminology tObj;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        String sSelect = "SELECT * FROM OC_TERMINOLOGIES " +
                         "WHERE OC_TERMINOLOGY_TYPE LIKE ? " +
                         "AND " + ScreenHelper.getConfigParam("lowerCompare","OC_TERMINOLOGY_PHRASE",oc_conn) + " LIKE ? " +
                         "AND OC_TERMINOLOGY_USERUID = ? ORDER BY OC_TERMINOLOGY_TYPE";

        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,"%"+sType+"%");
            ps.setString(2,"%"+sPhrase+"%");
            ps.setString(3,sUser);

            rs = ps.executeQuery();

            while(rs.next()){
                tObj = new Terminology();
                tObj.setTerminologyType(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_TYPE")));
                tObj.setPhrase(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_PHRASE")));
                tObj.setUserUID(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_USERUID")));
                tObj.setUid(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_OBJECTID")));
                tObj.setCreateDateTime(rs.getTimestamp("OC_TERMINOLOGY_CREATETIME"));
                tObj.setUpdateDateTime(rs.getTimestamp("OC_TERMINOLOGY_UPDATETIME"));
                tObj.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_TERMINOLOGY_UPDATEUID")));
                tObj.setVersion(rs.getInt("OC_TERMINOLOGY_VERSION"));

                vTerminologies.addElement(tObj);
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
        return vTerminologies;
    }

    public static boolean exists(String sType,String sUser){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bResult = false;

        String sSelect = "SELECT 1 FROM OC_TERMINOLOGIES " +
                         "WHERE OC_TERMINOLOGY_TYPE = ? " +
                         "AND OC_TERMINOLOGY_USERUID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sType);
            ps.setString(2,sUser);

            rs = ps.executeQuery();

            if(rs.next()){
                bResult = true;
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
        return bResult;
    }

    public void delete(){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM OC_TERMINOLOGIES"+
                         " WHERE OC_TERMINOLOGY_SERVERID = ? AND OC_TERMINOLOGY_OBJECTID = ?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            
            String ids[] = this.getUid().split("\\.");
            ps.setInt(1,Integer.parseInt(ids[0]));
            ps.setInt(2,Integer.parseInt(ids[1]));

            ps.execute();
            ps.close();
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

