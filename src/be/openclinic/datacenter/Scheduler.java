package be.openclinic.datacenter;

import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class Scheduler implements Runnable{
	Thread thread;
	long startTime=new java.util.Date().getTime();
	boolean stopped=false;
	
	public boolean isStopped() {
		return stopped;
	}

	public void setStopped(boolean stopped) {
		this.stopped = stopped;
	}

	public Scheduler(){
		thread = new Thread(this);
		thread.start();
	}
	
	public boolean isActive(){
		boolean isActive=!isStopped();
		long day=24*3600*1000;
		isActive=isActive && (new java.util.Date().getTime()-startTime)<day;
		return isActive;
	}
	
	public static void runScheduler(){
        // load scheduler config from XML

		String sDoc=null;
		SAXReader reader=null;
		Document document=null;
		Element root=null;
        try {
            sDoc = MedwanQuery.getInstance().getConfigString("datacenterTemplateSource",MedwanQuery.getInstance().getConfigString("templateSource")) + "datacenterschedule.xml";
            reader = new SAXReader(false);
            document = reader.read(new URL(sDoc));
            root = document.getRootElement();
            Element exporters = root.element("exporters");
            @SuppressWarnings("unchecked")
			Iterator<Element> elements = exporters.elementIterator("module");
            Element module;
            while (elements.hasNext()) {
                module = (Element) elements.next();
                String className = module.attributeValue("class");
                String param = module.attributeValue("param");
                //Execute exporter 
                Exporter exporter = (Exporter)Class.forName(className).newInstance();
                exporter.setParam(param);
                exporter.setDeadline(parseDeadline(module.attributeValue("interval")));
                exporter.export();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
            Element senders = root.element("senders");
            @SuppressWarnings("unchecked")
			Iterator<Element> elements = senders.elementIterator("module");
            Element module;
            while (elements.hasNext()) {
                module = (Element) elements.next();
                String className = module.attributeValue("class");
                //Execute sender 
                Sender sender = (Sender)Class.forName(className).newInstance();
                sender.setDeadline(parseDeadline(module.attributeValue("interval")));
                sender.send();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
            Element receivers = root.element("receivers");
            @SuppressWarnings("unchecked")
			Iterator<Element> elements = receivers.elementIterator("module");
            Element module;
            while (elements.hasNext()) {
                module = (Element) elements.next();
                String className = module.attributeValue("class");
                //Execute sender 
                Receiver receiver = (Receiver)Class.forName(className).newInstance();
                receiver.receive();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        Importer.execute();
	}
	
	public void run() {
		/*
        try {
        	while(!isStopped()){
        		if(MedwanQuery.getInstance().getConfigInt("datacenterEnabled",0)==1){
	        		Debug.println("Running scheduler...");
        			runScheduler();
        		}
        		Thread.sleep(MedwanQuery.getInstance().getConfigInt("datacenterScheduleInterval",20000));
        	}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		*/
	}
	
	public static Date parseDeadline(String s){
		Date deadline = null;
		try {
			deadline=new SimpleDateFormat("ddMMyyyy").parse("01011900");	
			if(s.indexOf(":")<0){
				deadline=new Date(new Date().getTime()-Long.parseLong(s));
			}
			else if(s.split("\\:")[0].equalsIgnoreCase("DAILY")){
				String[] times = s.split("\\:")[1].split(";");
				for(int n=0;n<times.length;n++){
					if(Integer.parseInt(times[n])<=getTime()){
						deadline= new SimpleDateFormat("ddMMyyyyHHmm").parse(new SimpleDateFormat("ddMMyyyy").format(new Date())+times[n]);
					}
					else {
						deadline= new SimpleDateFormat("ddMMyyyyHHmm").parse(new SimpleDateFormat("ddMMyyyy").format(getYesterday())+times[n]);
					}
				}
			}
			else if(s.split("\\:")[0].equalsIgnoreCase("WEEKLY")){
				String weekdays = s.split("\\:")[1].split(";")[0];
				Calendar calendar = Calendar.getInstance();
				calendar.setTime(new Date());
				if(weekdays.indexOf(""+calendar.get(Calendar.DAY_OF_WEEK))>-1){
					if(Integer.parseInt(s.split("\\:")[1].split(";")[1])<=getTime()){
						deadline= new SimpleDateFormat("ddMMyyyyHHmm").parse(new SimpleDateFormat("ddMMyyyy").format(new Date())+s.split("\\:")[1].split(";")[1]);
					}
				}
			}
			else if(s.split("\\:")[0].equalsIgnoreCase("MONTHLY")){
				String[] days = s.split("\\:")[1].split(",");
				for(int n=0;n<days.length;n++){
					if(days[n].split(";")[0].equalsIgnoreCase(new SimpleDateFormat("d").format(new Date()))){
						if(Integer.parseInt(days[n].split(";")[1])<=getTime()){
							deadline= new SimpleDateFormat("ddMMyyyyHHmm").parse(new SimpleDateFormat("ddMMyyyy").format(new Date())+days[n].split(";")[1]);
						}
					}
				}
			}
			else if(s.split("\\:")[0].equalsIgnoreCase("YEARLY")){
				String[] months = s.split("\\:")[1].split(",");
				for(int n=0;n<months.length;n++){
					if(months[n].split(";")[0].equalsIgnoreCase(new SimpleDateFormat("M").format(new Date())) && months[n].split(";")[1].equalsIgnoreCase(new SimpleDateFormat("d").format(new Date()))){
						if(getTime()>=0){
							deadline= new SimpleDateFormat("ddMMyyyyHHmm").parse(new SimpleDateFormat("ddMMyyyy").format(new Date())+"0000");
						}
					}
				}
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return deadline;
	}
	
	public static int getTime(){
		return Integer.parseInt(new SimpleDateFormat("HHmm").format(new Date()));
	}
	
	public static Date getYesterday(){
		long l = 24*3600*1000;
		Date date = new Date(new Date().getTime()-l);
		return date;
	}

}
