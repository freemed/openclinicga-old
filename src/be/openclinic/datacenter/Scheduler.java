package be.openclinic.datacenter;

import java.net.URL;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class Scheduler implements Runnable{
	Thread thread;
	
	public Scheduler(){
		thread = new Thread(this);
		thread.start();
	}
	
	public static void runScheduler(){
        // load scheduler config from XML
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "datacenterschedule.xml";
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Element exporters = root.element("exporters");
            Iterator elements = exporters.elementIterator("module");
            Element module;
            while (elements.hasNext()) {
                module = (Element) elements.next();
                String className = module.attributeValue("class");
                String param = module.attributeValue("param");
                long interval = Long.parseLong(module.attributeValue("interval"));
                //Execute exporter 
                Exporter exporter = (Exporter)Class.forName(className).newInstance();
                exporter.setParam(param);
                exporter.setInterval(interval);
                exporter.export();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
	}

	public void run() {
		// TODO Auto-generated method stub
        try {
        	while(true){
        		if(MedwanQuery.getInstance().getConfigInt("datacenterEnabled",0)==1){
	        		runScheduler();
        		}
        		thread.sleep(MedwanQuery.getInstance().getConfigInt("datacenterScheduleInterval",20000));
        	}
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
