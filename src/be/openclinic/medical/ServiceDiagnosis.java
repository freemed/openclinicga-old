package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Vector;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;

public class ServiceDiagnosis {
    private String serviceid;
    private String code;
    private String codeType;

    public void setServiceid(String serviceid){
        this.serviceid = serviceid;
    }

    public String getServiceid(){
        return this.serviceid;
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

    public static Vector selectServiceDiagnoses(String serviceID,String diagnoseCode,String codeType, String sortColumn){

        Vector vServiceDiagnoses = new Vector();

        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_SERVICEDIAGNOSES";
        String sConditions = "";
        if(serviceID.length() > 0){
        	sConditions += " (OC_SERVICEDIAGNOSIS_SERVICEUID='' OR replace(?,OC_SERVICEDIAGNOSIS_SERVICEUID,'')<>?) AND";
        }
        else {
        	sConditions += " OC_SERVICEDIAGNOSIS_SERVICEUID='' AND";
        }
        
        
        if(diagnoseCode.length() > 0)   { sConditions += " OC_SERVICEDIAGNOSIS_CODE = ? AND";}
        if(codeType.length() > 0)       { sConditions += " OC_SERVICEDIAGNOSIS_CODETYPE = ? AND";}

        if(sConditions.length() > 0) {
            sSelect += " WHERE " + sConditions;
            sSelect = sSelect.substring(0,sSelect.length() - 3);
        }
        if(sortColumn.length() > 0){
            sSelect += " ORDER BY " + sortColumn;
        }


        int i = 1;



        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            if(serviceID.length() > 0)      { ps.setString(i++,serviceID);ps.setString(i++,serviceID);}
            if(diagnoseCode.length() > 0){ ps.setString(i++,diagnoseCode);}
            if(codeType.length() > 0){ ps.setString(i++,codeType);}

            rs = ps.executeQuery();

            ServiceDiagnosis uTmp;

            String sServiceid;

            while(rs.next()){
                uTmp = new ServiceDiagnosis();
                sServiceid = ScreenHelper.checkString(rs.getString("OC_SERVICEDIAGNOSIS_SERVICEUID"));
                if(sServiceid.length() > 0){
                    uTmp.setServiceid(sServiceid);
                }
                uTmp.setDiagnoseCode(ScreenHelper.checkString(rs.getString("OC_SERVICEDIAGNOSIS_CODE")));
                uTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_SERVICEDIAGNOSIS_CODETYPE")));
                vServiceDiagnoses.addElement(uTmp);
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

        return vServiceDiagnoses;
    }


    public static void deleteServiceDiagnosis(String serviceID,String diagnosisCode, String codeType){
        PreparedStatement ps = null;

        String sDelete = " DELETE FROM OC_SERVICEDIAGNOSES" +
                         " WHERE OC_SERVICEDIAGNOSIS_SERVICEUID = ?" +
                         " AND OC_SERVICEDIAGNOSIS_CODE = ?" +
                         " AND OC_SERVICEDIAGNOSIS_CODETYPE = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1,serviceID);
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

    public static void insertServiceDiagnosis(String serviceID, String diagnosisCode, String codeType){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO OC_SERVICEDIAGNOSES(OC_SERVICEDIAGNOSIS_SERVICEUID,OC_SERVICEDIAGNOSIS_CODE,OC_SERVICEDIAGNOSIS_CODETYPE) VALUES(?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,serviceID);
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

    public static Vector searchInICPC2(String serviceID,String labelLanguage,String keywords){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vServiceDiagnoses = new Vector();

        String sSelect = "SELECT * FROM ICPC2View a, OC_SERVICEDIAGNOSES b " +
                         "WHERE a.code = b.OC_SERVICEDIAGNOSIS_CODE " +
                         "AND b.OC_SERVICEDIAGNOSIS_SERVICEUID = ? " +
                         "AND a." + labelLanguage + " LIKE ?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,serviceID);
            ps.setString(2,"%" + keywords.toUpperCase() + "%");

            rs = ps.executeQuery();

            ServiceDiagnosis uTmp;
            while(rs.next()){
                uTmp = new ServiceDiagnosis();
                uTmp.setServiceid(rs.getString("OC_SERVICEDIAGNOSIS_SERVICEUID"));
                uTmp.setDiagnoseCode(ScreenHelper.checkString(rs.getString("OC_SERVICEDIAGNOSIS_CODE")));
                uTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_SERVICEDIAGNOSIS_CODETYPE")));
                vServiceDiagnoses.addElement(uTmp);
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
        return vServiceDiagnoses;
    }
}