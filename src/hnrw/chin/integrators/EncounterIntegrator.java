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
public class EncounterIntegrator extends Integrator {
    public boolean integrate(Element message){
        boolean bSuccess=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            Iterator encounters = message.elementIterator("encounter");
            while(encounters.hasNext()){
                Element encounter = (Element)encounters.next();
                String sQuery="delete from HealthNetEncounters where hn_id=? and hn_source=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1, ScreenHelper.checkString(encounter.attributeValue("id")));
                ps.setString(2, ScreenHelper.checkString(message.attributeValue("source")));
                ps.execute();
                ps.close();
                Iterator services = encounter.elementIterator("service");
                while(services.hasNext()){
                    Element service = (Element)services.next();
                    sQuery = "insert into HealthNetEncounters(hn_id,hn_type,hn_begin,hn_end,hn_patientid," +
                            "hn_outcome,hn_origin,hn_destination,hn_serviceid,hn_bed,hn_servicebegin,hn_serviceend,hn_source)" +
                            "values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setString(1, ScreenHelper.checkString(encounter.attributeValue("id")));
                    ps.setString(2, ScreenHelper.checkString(encounter.attributeValue("type")));
                    ps.setTimestamp(3, makeTimestamp(encounter.attributeValue("begin")));
                    ps.setTimestamp(4, makeTimestamp(encounter.attributeValue("end")));
                    ps.setString(5, ScreenHelper.checkString(encounter.attributeValue("patientid")));
                    ps.setString(6, ScreenHelper.checkString(encounter.attributeValue("outcome")));
                    ps.setString(7, ScreenHelper.checkString(encounter.attributeValue("origin")));
                    ps.setString(8, ScreenHelper.checkString(encounter.attributeValue("destination")));
                    ps.setString(9, ScreenHelper.checkString(service.attributeValue("service")));
                    ps.setString(10, ScreenHelper.checkString(service.attributeValue("bed")));
                    ps.setTimestamp(11, makeTimestamp(service.attributeValue("begin")));
                    ps.setTimestamp(12, makeTimestamp(service.attributeValue("end")));
                    ps.setString(13, ScreenHelper.checkString(message.attributeValue("source")));
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
