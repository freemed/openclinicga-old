package org.hnrw.chin.integrators;

import org.dom4j.Element;
import org.dom4j.Document;
import org.dom4j.io.SAXReader;
import be.mxs.common.util.db.MedwanQuery;

import java.net.URL;
import java.util.Iterator;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 23-mei-2008
 * Time: 22:51:22
 * To change this template use File | Settings | File Templates.
 */
public abstract class Integrator {
    public abstract boolean integrate(Element message);

    static public boolean readMessage(String filename){
        boolean bSuccess=false;
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "healthnet.xml";
        SAXReader reader = new SAXReader(false);
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            Document hnConfig = reader.read(new URL(sDoc));
            Element root=hnConfig.getRootElement();
            Element integrator = root.element("integrator");
            Document msg = reader.read((integrator.attributeValue("directory","c:/hn/received")+"/"+filename).replaceAll("//","/"));
            Element message = msg.getRootElement();
            Iterator classes = integrator.elementIterator("class");
            while(classes.hasNext()){
                Element cls = (Element)classes.next();
                if(cls.attributeValue("id").equals(message.attributeValue("type"))){
                    Integrator i = (Integrator)Class.forName(cls.attributeValue("name")).newInstance();
                    if(i.integrate(message)){
                        String sQuery="update HealthNetIntegratedMessages set integrationDateTime=?,creationDateTime=? where hn_filename=?";
                        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                        ps.setTimestamp(1,new Timestamp(new Date().getTime()));
                        ps.setTimestamp(2,new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(message.attributeValue("created")).getTime()));
                        ps.setString(3,filename);
                        ps.execute();
                        ps.close();
                    }
                }
            }
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

    Timestamp makeTimestamp(String s){
        Timestamp d = null;
        try{
            d=new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(s).getTime());
        }
        catch(Exception e){

        }
        return d;
    }
}
