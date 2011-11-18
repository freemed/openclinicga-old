package be.mxs.common.util.broker;

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
import be.openclinic.reporting.LabresultsNotifier;

public class BrokerScheduler implements Runnable{
	static LabresultsNotifier lrNotifier = new LabresultsNotifier();
	Thread thread;
	boolean stopped=false;
	
	public boolean isStopped() {
		return stopped;
	}

	public void setStopped(boolean stopped) {
		this.stopped = stopped;
	}

	public BrokerScheduler(){
		thread = new Thread(this);
		thread.start();
	}
	
	public static void runScheduler(){
		lrNotifier.sendNewLabs();
	}
	
	public void run() {
        try {
        	while(!isStopped()){
        		runScheduler();
        		thread.sleep(MedwanQuery.getInstance().getConfigInt("brokerScheduleInterval",20000));
        	}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	

}
