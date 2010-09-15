package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 20-mrt-2007
 * Time: 16:45:12
 * To change this template use File | Settings | File Templates.
 */
public class Labo {
    public static Hashtable getLabRequestDefaultData(String sCode,String language){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sLowerLabelType = MedwanQuery.getInstance().getConfigParam("lowerCompare", "l.OC_LABEL_TYPE");

        StringBuffer sSelect = new StringBuffer();
        sSelect.append("SELECT la.labtype,la.monster,l.OC_LABEL_VALUE")
                    .append(" FROM LabAnalysis la, OC_LABELS l")
                    .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","la.labID")+" = l.OC_LABEL_ID")
                    .append("  AND " + sLowerLabelType + " = 'labanalysis'")
                    .append("  AND la.labcode = ? and l.OC_LABEL_LANGUAGE=? and la.deletetime is null");

        Hashtable hDefaultData = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect.toString());
            ps.setString(1, sCode);
            ps.setString(2, language);
            rs = ps.executeQuery();

            if(rs.next()){
                hDefaultData = new Hashtable();

                hDefaultData.put("labtype", ScreenHelper.checkString(rs.getString("labtype")));
                hDefaultData.put("OC_LABEL_VALUE",ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE")));
                hDefaultData.put("monster",ScreenHelper.checkString(rs.getString("monster")));
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
        return hDefaultData;
    }
}
