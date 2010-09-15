package org.hnrw.chin.extractors;

import org.dom4j.Element;
import org.dom4j.DocumentHelper;
import org.hnrw.chin.MessageManager;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.text.SimpleDateFormat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 27-mei-2008
 * Time: 22:19:27
 * To change this template use File | Settings | File Templates.
 */
public class BedInventoryExtractor extends Extractor{
    public String getExtractorID(){
        return "BEDINVENTORY";
    }

    public void getMessage(){
        Element message = DocumentHelper.createElement("message");
        message.addAttribute("type",getExtractorID());
        message.addAttribute("source", MedwanQuery.getInstance().getConfigString("HealthnetServerID",""));
        if(lastExtract!=null){
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try{
                Date now=new Date();
                message.addAttribute("created",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(now));
                message.addAttribute("previous",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(lastExtract));
                String sQuery = "select * from Services where updatetime>=?";
                PreparedStatement ps = ad_conn.prepareStatement(sQuery);
                ps.setTimestamp(1,new Timestamp(lastExtract.getTime()));
                ResultSet rs = ps.executeQuery();
                boolean initialized=false;
                while (rs.next()){
                    initialized=true;
                    //First create the service element
                    Element service=message.addElement("service");
                    String id=rs.getString("serviceid");
                    service.addAttribute("id",id);
                    service.addAttribute("labelfr",MedwanQuery.getInstance().getLabel("service",id,"FR"));
                    service.addAttribute("labelen",MedwanQuery.getInstance().getLabel("service",id,"EN"));
                    service.addAttribute("labelnl",MedwanQuery.getInstance().getLabel("service",id,"NL"));
                    service.addAttribute("beds",rs.getInt("totalbeds")+"");
                    Timestamp updatetime= rs.getTimestamp("updatetime");
                    if(updatetime!=null){
                        service.addAttribute("updatetime",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime));
                    }
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
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            MessageManager.storeMessage(message);
        }
    }
}
