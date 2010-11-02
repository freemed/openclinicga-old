package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Vector;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;

public class UserDiagnosis {
    private int userid;
    private String code;
    private String codeType;

    public void setUserid(int userid){
        this.userid = userid;
    }

    public int getUserid(){
        return this.userid;
    }

    public void setDiagnoseCode(String code){
        this.code = code;
    }

    public String getCode(){
        return this.code;
    }

    public String getCodeType() {
        return codeType;
    }

    public void setCodeType(String codeType) {
        this.codeType = codeType;
    }

    public static Vector selectUserDiagnoses(String userID,String diagnoseCode,String codeType, String sortColumn){

        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_USERDIAGNOSES";
        String sConditions = "";
        if(userID.length() > 0)         { sConditions += " OC_USERDIAGNOSIS_USERID = ? AND";}
        if(diagnoseCode.length() > 0)   { sConditions += " OC_USERDIAGNOSIS_CODE = ? AND";}
        if(codeType.length() > 0)       { sConditions += " OC_USERDIAGNOSIS_CODETYPE = ? AND";}

        if(sConditions.length() > 0) {
            sSelect += " WHERE " + sConditions;
            sSelect = sSelect.substring(0,sSelect.length() - 3);
        }
        if(sortColumn.length() > 0){
            sSelect += " ORDER BY " + sortColumn;
        }


        int i = 1;


        Vector vUserDiagnoses = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            if(userID.length() > 0)      { ps.setInt(i++,Integer.parseInt(userID));}
            if(diagnoseCode.length() > 0){ ps.setString(i++,diagnoseCode);}
            if(codeType.length() > 0){ ps.setString(i++,codeType);}

            rs = ps.executeQuery();

            UserDiagnosis uTmp;

            String sUserid;

            while(rs.next()){
                uTmp = new UserDiagnosis();
                sUserid = ScreenHelper.checkString(rs.getString("OC_USERDIAGNOSIS_USERID"));
                if(sUserid.length() > 0){
                    uTmp.setUserid(Integer.parseInt(sUserid));
                }
                uTmp.setDiagnoseCode(ScreenHelper.checkString(rs.getString("OC_USERDIAGNOSIS_CODE")));
                uTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_USERDIAGNOSIS_CODETYPE")));
                vUserDiagnoses.addElement(uTmp);
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

        return vUserDiagnoses;
    }


    public static void deleteUserDiagnosis(String userID,String diagnosisCode, String codeType){
        PreparedStatement ps = null;

        String sDelete = " DELETE FROM OC_USERDIAGNOSES" +
                         " WHERE OC_USERDIAGNOSIS_USERID = ?" +
                         " AND OC_USERDIAGNOSIS_CODE = ?" +
                         " AND OC_USERDIAGNOSIS_CODETYPE = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,Integer.parseInt(userID));
            ps.setString(2,diagnosisCode);
            ps.setString(3,codeType);

            ps.executeUpdate();
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

    public static void insertUserDiagnosis(String userID, String diagnosisCode, String codeType){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO OC_USERDIAGNOSES(OC_USERDIAGNOSIS_USERID,OC_USERDIAGNOSIS_CODE,OC_USERDIAGNOSIS_CODETYPE) VALUES(?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setInt(1,Integer.parseInt(userID));
            ps.setString(2,diagnosisCode);
            ps.setString(3,codeType);

            ps.executeUpdate();
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

    public static Vector searchInICPC2(String userID,String labelLanguage,String keywords){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUserDiagnoses = new Vector();

        String sSelect = "SELECT * FROM ICPC2View a, OC_USERDIAGNOSES b " +
                         "WHERE a.code = b.OC_USERDIAGNOSIS_CODE " +
                         "AND b.OC_USERDIAGNOSIS_USERID = ? " +
                         "AND a." + labelLanguage + " LIKE ?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(userID));
            ps.setString(2,"%" + keywords.toUpperCase() + "%");

            rs = ps.executeQuery();

            UserDiagnosis uTmp;
            while(rs.next()){
                uTmp = new UserDiagnosis();
                uTmp.setUserid(rs.getInt("OC_USERDIAGNOSIS_USERID"));
                uTmp.setDiagnoseCode(ScreenHelper.checkString(rs.getString("OC_USERDIAGNOSIS_CODE")));
                uTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_USERDIAGNOSIS_CODETYPE")));
                vUserDiagnoses.addElement(uTmp);
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
        return vUserDiagnoses;
    }
}