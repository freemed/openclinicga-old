package org.hnrw.chin.integrators;

import org.dom4j.Element;

import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 23-mei-2008
 * Time: 23:04:47
 * To change this template use File | Settings | File Templates.
 */
public class BedInventoryIntegrator extends Integrator {
    public boolean integrate(Element message){
        boolean bSuccess=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            Iterator services = message.elementIterator("service");
            while(services.hasNext()){
                Element service = (Element)services.next();
                String sQuery="delete from HealthNetServices where hn_id=? and hn_source=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1, ScreenHelper.checkString(service.attributeValue("id")));
                ps.setString(2, ScreenHelper.checkString(message.attributeValue("source")));
                ps.execute();
                ps.close();
                sQuery = "insert into HealthNetServices(hn_id,hn_labelnl,hn_labelfr,hn_labelen,hn_beds,hn_updatetime,hn_source)" +
                        "values(?,?,?,?,?,?,?)";
                if(service.attributeValue("beds")!=null && !service.attributeValue("beds").equalsIgnoreCase("0")){
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setString(1, ScreenHelper.checkString(service.attributeValue("id")));
                    ps.setString(2, ScreenHelper.checkString(service.attributeValue("labelnl")));
                    ps.setString(3, ScreenHelper.checkString(service.attributeValue("labelfr")));
                    ps.setString(4, ScreenHelper.checkString(service.attributeValue("labelen")));
                    ps.setInt(5, Integer.parseInt(service.attributeValue("beds")));
                    ps.setTimestamp(6, makeTimestamp(service.attributeValue("updatetime")));
                    ps.setString(7, ScreenHelper.checkString(message.attributeValue("source")));
                    ps.execute();
                    ps.close();
                }
            }
            bSuccess=true;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return bSuccess;
    }

}
