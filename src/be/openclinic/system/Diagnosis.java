package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 15-mrt-2007
 * Time: 17:34:25
 * To change this template use File | Settings | File Templates.
 */
public class Diagnosis {
    private String itemTypeId;
    private String criterium;


    public String getItemTypeId() {
        return itemTypeId;
    }

    public void setItemTypeId(String itemTypeId) {
        this.itemTypeId = itemTypeId;
    }

    public String getCriterium() {
        return criterium;
    }

    public void setCriterium(String criterium) {
        this.criterium = criterium;
    }

    public static void insert(String sColumns, String sWhere){
        PreparedStatement ps = null;

        String sInsert = "insert into diagnoses(itemTypeId) select ? where ? not in (select itemTypeId from diagnoses)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,sColumns);
            ps.setString(2,sWhere);

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
}
