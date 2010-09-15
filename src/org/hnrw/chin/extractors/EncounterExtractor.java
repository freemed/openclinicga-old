package org.hnrw.chin.extractors;

import org.dom4j.Element;
import org.dom4j.DocumentHelper;
import org.hnrw.chin.MessageManager;



import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import be.mxs.common.util.db.MedwanQuery;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 22-mei-2008
 * Time: 23:21:27
 * To change this template use File | Settings | File Templates.
 */
public class EncounterExtractor extends Extractor{
    public String getExtractorID(){
        return "ENCOUNTER";
    }

    public void getMessage(){
        Element message = DocumentHelper.createElement("message");
        message.addAttribute("type",getExtractorID());
        message.addAttribute("source",MedwanQuery.getInstance().getConfigString("HealthnetServerID",""));
        if(lastExtract!=null){
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                Date now=new Date();
                message.addAttribute("created",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(now));
                message.addAttribute("previous",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(lastExtract));
                String sQuery = "select * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>=?";
                PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                ps.setTimestamp(1,new Timestamp(lastExtract.getTime()));
                ResultSet rs = ps.executeQuery();
                boolean initialized=false;
                while (rs.next()){
                    initialized=true;
                    //First create the encounter element
                    Element encounter=message.addElement("encounter");
                    int serverid=rs.getInt("OC_ENCOUNTER_SERVERID");
                    int objectid=rs.getInt("OC_ENCOUNTER_OBJECTID");
                    encounter.addAttribute("id",serverid+"."+objectid);
                    encounter.addAttribute("type",rs.getString("OC_ENCOUNTER_TYPE"));
                    Timestamp begin=rs.getTimestamp("OC_ENCOUNTER_BEGINDATE");
                    Timestamp end=rs.getTimestamp("OC_ENCOUNTER_ENDDATE");
                    Timestamp updatetime= rs.getTimestamp("OC_ENCOUNTER_UPDATETIME");
                    if(begin!=null){
                        encounter.addAttribute("begin",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(begin));
                    }
                    if(end!=null){
                        encounter.addAttribute("end",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(end));
                    }
                    encounter.addAttribute("patientid",rs.getString("OC_ENCOUNTER_PATIENTUID").hashCode()+"");
                    encounter.addAttribute("outcome",rs.getString("OC_ENCOUNTER_OUTCOME"));
                    encounter.addAttribute("origin",rs.getString("OC_ENCOUNTER_ORIGIN"));
                    encounter.addAttribute("destination",rs.getString("OC_ENCOUNTER_DESTINATIONUID"));
                    if(updatetime!=null){
                        encounter.addAttribute("updatetime",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime));
                    }
                    //Now we will add all services for this encounter
                    String sQuery2 = "select * from OC_ENCOUNTER_SERVICES where OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=?";
                    PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
                    ps2.setInt(1,serverid);
                    ps2.setInt(2,objectid);
                    ResultSet rs2=ps2.executeQuery();
                    while(rs2.next()){
                        Element service = encounter.addElement("service");
                        service.addAttribute("service",rs2.getString("OC_ENCOUNTER_SERVICEUID"));
                        service.addAttribute("bed",rs2.getString("OC_ENCOUNTER_BEDUID"));
                        begin=rs2.getTimestamp("OC_ENCOUNTER_SERVICEBEGINDATE");
                        if(begin!=null){
                            service.addAttribute("begin",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(begin));
                        }
                        end=rs2.getTimestamp("OC_ENCOUNTER_SERVICEENDDATE");
                        if (end!=null){
                            service.addAttribute("end",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(end));
                        }
                    }
                    rs2.close();
                    ps2.close();
                }
                rs.close();
                ps.close();
                if(!initialized){
                    return;
                }
                setLastExtract(now);
            }
            catch (Exception e){
                e.printStackTrace();
            }
            try {
				oc_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            MessageManager.storeMessage(message);
        }
    }
}
