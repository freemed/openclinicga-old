package org.hnrw.report;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Hashtable;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 12-jan-2009
 * Time: 12:43:35
 * To change this template use File | Settings | File Templates.
 */
public class Report_Identification {
    Date date;
    Hashtable items=new Hashtable();

    public String getItem(String name){
        return ScreenHelper.checkString((String)items.get(name));
    }

    public Report_Identification(Date date){
        this.date=date;
        //Find the identification data applicable at the specified date
        //First check if the active data are applicable
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            boolean found=false;
            PreparedStatement ps1 = oc_conn.prepareStatement("select * from OC_HC");
            ResultSet rs1 = ps1.executeQuery();
            if(rs1.next()){
                Date updateTime = rs1.getDate("OC_HC_UPDATETIME");
                if(updateTime.before(date)){
                    setItems(rs1);
                    found=true;
                }
                else {
                    //Search the history
                    PreparedStatement ps = oc_conn.prepareStatement("select * from OC_HC_HISTORY order by OC_HC_VERSION DESC");
                    ResultSet rs = ps.executeQuery();
                    while(rs.next() && !found){
                        updateTime = rs.getDate("OC_HC_UPDATETIME");
                        if(updateTime.before(date)){
                            setItems(rs);
                            found=true;
                        }
                    }
                    rs.close();
                    ps.close();
                }
                if(!found){
                    setItems(rs1);
                }
            }
            rs1.close();
            ps1.close();
        } catch (SQLException e) {
            e.printStackTrace();  
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private void setItems(ResultSet rs) throws SQLException {
        items.put("OC_HC_NAME",ScreenHelper.checkString(rs.getString("OC_HC_NAME")));
        items.put("OC_HC_UID",ScreenHelper.checkString(rs.getString("OC_HC_UID")));
        items.put("OC_HC_PROVINCE",ScreenHelper.checkString(rs.getString("OC_HC_PROVINCE")));
        items.put("OC_HC_DISTRICT",ScreenHelper.checkString(rs.getString("OC_HC_DISTRICT")));
        items.put("OC_HC_ZONE",ScreenHelper.checkString(rs.getString("OC_HC_ZONE")));
        items.put("OC_HC_SECTOR",ScreenHelper.checkString(rs.getString("OC_HC_SECTOR")));
        items.put("OC_HC_FOSA",ScreenHelper.checkString(rs.getString("OC_HC_FOSA")));
        items.put("OC_HC_CELL",ScreenHelper.checkString(rs.getString("OC_HC_CELL")));
        items.put("OC_HC_CONTACTNAME",ScreenHelper.checkString(rs.getString("OC_HC_CONTACTNAME")));
        items.put("OC_HC_REM_EPIDEMIOLOGY",ScreenHelper.checkString(rs.getString("OC_HC_REM_EPIDEMIOLOGY")));
        items.put("OC_HC_REM_DRUGS",ScreenHelper.checkString(rs.getString("OC_HC_REM_DRUGS")));
        items.put("OC_HC_REM_VACCINATIONS",ScreenHelper.checkString(rs.getString("OC_HC_REM_VACCINATIONS")));
        items.put("OC_HC_REM_EQUIPMENT",ScreenHelper.checkString(rs.getString("OC_HC_REM_EQUIPMENT")));
        items.put("OC_HC_REM_BUILDING",ScreenHelper.checkString(rs.getString("OC_HC_REM_BUILDING")));
        items.put("OC_HC_REM_TRANSPORT",ScreenHelper.checkString(rs.getString("OC_HC_REM_TRANSPORT")));
        items.put("OC_HC_REM_PERSONNEL",ScreenHelper.checkString(rs.getString("OC_HC_REM_PERSONNEL")));
        items.put("OC_HC_REM_OTHER",ScreenHelper.checkString(rs.getString("OC_HC_REM_OTHER")));
        items.put("OC_HC_POPULATION_TOTAL",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_TOTAL")));
        items.put("OC_HC_POPULATION_LT1M",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_LT1M")));
        items.put("OC_HC_POPULATION_LT1Y",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_LT1Y")));
        items.put("OC_HC_POPULATION_LT5Y",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_LT5Y")));
        items.put("OC_HC_POPULATION_LT25Y",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_LT25Y")));
        items.put("OC_HC_POPULATION_LT50Y",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_LT50Y")));
        items.put("OC_HC_POPULATION_MT50Y",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_MT50Y")));
        items.put("OC_HC_POPULATION_PREG",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_PREG")));
        items.put("OC_HC_POPULATION_MUT",ScreenHelper.checkString(rs.getString("OC_HC_POPULATION_MUT")));
        items.put("OC_HC_BEDS",ScreenHelper.checkString(rs.getString("OC_HC_BEDS")));
    }

}
