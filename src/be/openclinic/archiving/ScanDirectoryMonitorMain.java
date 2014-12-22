package be.openclinic.archiving;

import uk.org.primrose.vendor.standalone.PrimroseLoader;
import be.openclinic.archiving.ScanDirectoryMonitor;


public class ScanDirectoryMonitorMain {
	
	//--- MAIN ------------------------------------------------------------------------------------
	public static void main(String[] args){
    	try {
			PrimroseLoader.load(args[0], true);
		}
    	catch (Exception e) {
			e.printStackTrace();
		}
		ScanDirectoryMonitor scanDirMon = new ScanDirectoryMonitor();
		scanDirMon.activate();
	}

}