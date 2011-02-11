package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import be.mxs.common.util.db.MedwanQuery;

public class ExporterSystem extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("system.1")){
			//Export operating system info when changed
			exportUniqueValue(System.getProperty("os.name")+" v"+System.getProperty("os.version")+" "+System.getProperty("os.arch"), "system.1");
		}
		else if(getParam().equalsIgnoreCase("system.2")){
			//Export java version when changed
			exportUniqueValue(System.getProperty("java.vendor")+" "+System.getProperty("java.version"), "system.2");
		}
		else if(getParam().equalsIgnoreCase("system.3")){
			//Export available data disk space when changed
			exportUniqueValue(new java.io.File(MedwanQuery.getInstance().getConfigString("datacenterDataPartition","/")).getUsableSpace()+"", "system.3");
		}
		else if(getParam().equalsIgnoreCase("system.4")){
			//Export available processors when changed
			exportUniqueValue(Runtime.getRuntime().availableProcessors()+"", "system.4");
		}
		else if(getParam().equalsIgnoreCase("system.5")){
			//Export max Java Memory when changed
			exportUniqueValue(Runtime.getRuntime().maxMemory()+"", "system.5");
		}
	}
}
