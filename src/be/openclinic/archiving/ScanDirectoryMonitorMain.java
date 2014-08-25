package be.openclinic.archiving;

import be.openclinic.archiving.ScanDirectoryMonitor;


public class ScanDirectoryMonitorMain {
	
	//--- MAIN ------------------------------------------------------------------------------------
	public static void main(String[] args){
		ScanDirectoryMonitor scanDirMon = new ScanDirectoryMonitor();
		scanDirMon.activate();
	}

}