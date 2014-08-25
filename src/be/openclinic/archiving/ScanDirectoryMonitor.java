package be.openclinic.archiving;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class ScanDirectoryMonitor implements Runnable{
	private boolean stopped = false;
	private int runCounter;
	private Thread thread;
	
	// config-values
	public static String SCANDIR_URL, SCANDIR_BASE, SCANDIR_FROM, SCANDIR_TO, SCANDIR_ERR, SCANDIR_DEL;		
	public static int FILES_PER_DIRECTORY;
	public static long MONITORING_INTERVAL;
	public static String EXCLUDED_EXTENSIONS;
		
	private static final String ALPHABET = "abcdefghijklmnopqrstuvwxyz"; 
	private boolean OK_TO_START;
	
	
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
	public ScanDirectoryMonitor(){
		OK_TO_START = true;
		loadConfig();
		
		if(Debug.enabled){
			Debug.println("\n******************************** ScanDirectoryMonitor ********************************");
			Debug.println("'scanDirectoryMonitor_basePath'                   : "+SCANDIR_BASE);
			Debug.println("'scanDirectoryMonitor_dirFrom'                    : "+SCANDIR_FROM);
			Debug.println("'scanDirectoryMonitor_dirTo'                      : "+SCANDIR_TO);
			Debug.println("'scanDirectoryMonitor_dirError'                   : "+SCANDIR_ERR);
			Debug.println("'scanDirectoryMonitor_dirDeleted'                 : "+SCANDIR_DEL);
		    Debug.println("'scanDirectoryMonitor_filesPerDirectory'          : "+FILES_PER_DIRECTORY);
		    Debug.println("'scanDirectoryMonitor_interval'                   : "+MONITORING_INTERVAL+" millis");
		    Debug.println("'scanDirectoryMonitor_notScannableFileExtensions' : "+EXCLUDED_EXTENSIONS);
		    Debug.println("'scanDirectoryMonitor_url'                        : "+SCANDIR_URL);
		}
		
		runCounter = 0;

        // check dir BASE
		if(SCANDIR_BASE.length()==0){
		    Debug.println("WARNING : 'scanDirectoryMonitor_basePath' is not configured");
		    OK_TO_START = false;
	    }
		else{
	    	File scanDir = new File(SCANDIR_BASE);
	    	if(!scanDir.exists()){	
	    		scanDir.mkdir();
	    		Debug.println("INFO : 'scanDirectoryMonitor_basePath' created");
	    	}
	    }
		
        // check dir FROM
		if(SCANDIR_FROM.length()==0){
		    Debug.println("WARNING : 'scanDirectoryMonitor_dirFrom' is not configured");
		    OK_TO_START = false;
	    }
		else{
	    	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_FROM);
	    	if(!scanDir.exists()){	
	    		scanDir.mkdir();
	    		Debug.println("INFO : 'scanDirectoryMonitor_dirFrom' created");
	    	}
	    }

        // check dir TO
		if(SCANDIR_TO.length()==0){
		    Debug.println("WARNING : 'scanDirectoryMonitor_dirTo' is not configured");
		    OK_TO_START = false;
	    }
		else{
	    	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_TO);
	    	if(!scanDir.exists()){	
	    		scanDir.mkdir();
	    		Debug.println("INFO : 'scanDirectoryMonitor_dirTo' created");
	    	}
	    }

        // check dir ERR
		if(SCANDIR_ERR.length()==0){
		    Debug.println("WARNING : 'scanDirectoryMonitor_dirError' is not configured");
		    OK_TO_START = false;
	    }
		else{
	    	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_ERR);
	    	if(!scanDir.exists()){	
	    		scanDir.mkdir();
	    		Debug.println("INFO : 'scanDirectoryMonitor_dirError' created");
	    	}
	    }
		
        // check dir DEL
		if(SCANDIR_DEL.length()==0){
		    Debug.println("WARNING : 'scanDirectoryMonitor_dirDeleted' is not configured");
		    OK_TO_START = false;
	    }
		else{
	    	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_DEL);
	    	if(!scanDir.exists()){	
	    		scanDir.mkdir();
	    		Debug.println("INFO : 'scanDirectoryMonitor_dirDeleted' created");
	    	}
	    }
    	
		Debug.println("******************************************************************************************\n");
	}
	
	//--- ACTIVATE --------------------------------------------------------------------------------
	public void activate(){
		//*** start thread ***
    	if(OK_TO_START){
			thread = new Thread(this);
			thread.start();
			
    		Debug.println("ScanDirectoryMonitor is active");
    	}
    	else{
    		Debug.println("ScanDirectoryMonitor NOT ACTIVE due to previous errors");
    	}
	}
	
	//--- LOAD CONFIG -----------------------------------------------------------------------------
	public static void loadConfig(){
		SCANDIR_URL  = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_url");
		SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath");
		SCANDIR_FROM = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirFrom");
	    SCANDIR_TO   = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo");
	    SCANDIR_ERR  = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirError");
	    SCANDIR_DEL  = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirDeleted");
				
		FILES_PER_DIRECTORY = MedwanQuery.getInstance().getConfigInt("scanDirectoryMonitor_filesPerDirectory",1024);
		MONITORING_INTERVAL = MedwanQuery.getInstance().getConfigInt("scanDirectoryMonitor_interval",60*1000);
	    EXCLUDED_EXTENSIONS = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_notScannableFileExtensions").toLowerCase();
	}
			
	//--- IS ACTIVE -------------------------------------------------------------------------------
	public boolean isActive(){
		return !isStopped();
	}
	
	//--- STOPPED ---------------------------------------------------------------------------------
	public boolean isStopped(){
		return stopped;
	}

	public void setStopped(boolean stopped){
		this.stopped = stopped;
	}
	
	//--- RUN SCHEDULER ---------------------------------------------------------------------------
	public static void runScheduler(){	
        try{        
        	int acceptedFilesInRun = 0, faultyFilesInRun = 0, deniedFilesInRun = 0;
        	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_FROM);
        	
        	ScannableFileFilter fileFilter = new ScannableFileFilter(EXCLUDED_EXTENSIONS);        	
        	File[] scannableFiles = scanDir.listFiles(fileFilter); 
        	if(scannableFiles.length > 0){
	        	Debug.println(" ScannableFiles in 'scanDirectoryMonitor_dirFrom' : "+scannableFiles.length);
	        	for(int i=0; i<scannableFiles.length; i++){
	        		int result = storeFileInDB((File)scannableFiles[i],(i+1));
	        		
	        	    if(result > 0){
	        	    	acceptedFilesInRun++;
	        	    }
	        	    else if(result < 0){
	        	    	faultyFilesInRun++;
	        	    }
	        	}

	        	Debug.println("===> "+acceptedFilesInRun+" accepted files");
	        	Debug.println("===> "+faultyFilesInRun+" faulty files");
        	}
        	
        	// move files which are not scannable
        	deniedFilesInRun = moveNotScannableFiles();  
        	if(deniedFilesInRun > 0){
        	    Debug.println("===> "+deniedFilesInRun+" denied files");
        	}
        	
        	// remove files which were deleted more than a week ago, by using the double-scan-files-module 
        	removeOldDeletedFiles();
        }
        catch(Exception e){
            e.printStackTrace();
        }
	}
    
    //--- STORE FILE IN DataBase ------------------------------------------------------------------
    // meta-data in DB
    // file itself as file in 'scanDirectoryTo'
    public static int storeFileInDB(File file, int fileIdx){
        return storeFileInDB(file,false,fileIdx);	
    }
    
    public static int storeFileInDB(File file, boolean forced, int fileIdx){
    	if(Debug.enabled){
	        Debug.println("\n*******************************************************************");	
	        Debug.println("************************ storeFileInDB ("+fileIdx+") ************************");	
	        Debug.println("*******************************************************************");	
	        Debug.println("file : "+file.getName()+" ("+(file.length()/1024)+"kb)");	        
	        if(forced) Debug.println("forced : "+forced);
    	}
    	
    	int result = 0; // -1 = 'faulty file', +1 = 'file accepted', 0 = 'file denied'
    	
      	if(file.getName().startsWith("SCAN_")){
            try{
	    	    String sUDI = file.getName().substring(file.getName().indexOf("_")+1,file.getName().lastIndexOf(".")); // remove prefix and extension
		        Debug.println("--> UDI : "+sUDI);
		        
		        if(sUDI.length()==11){
	        		if(validUDI(sUDI)){
			        	if(!forced){	
			        		//*** CONDITIONAL READ ******************************************
				        	// check existence of archive-document
				        	ArchiveDocument existingDoc = ArchiveDocument.get(sUDI);
			        		if(existingDoc!=null){
					        	// check existence of linked file
			        			if(existingDoc.storageName.length() > 0){
			                        File existingFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+existingDoc.storageName);
					        		if(existingFile.exists()){
					        			//*** ARCH_DOC FOUND, WITH EXISTING LINKED FILE ***
						        	    Debug.println("WARNING : A file '"+existingDoc.storageName+"' exists for the archive-document with UDI '"+existingDoc.udi+"'."+
						        	                  " --> incoming file '"+file.getName()+"' is a double file.");
						        	    
						        	    // must be read by a person before overwriting the existing file
							        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","DOUBLE_"));
						        	    moveFile(file,errFile);
								        Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
								        result = -1; // err
					        		}
					        		else{
					        			//*** ARCH_DOC FOUND, WITHOUT EXISTING LINKED FILE ***
						        	    Debug.println("INFO : An archive-document with UDI '"+existingDoc.udi+"' exists, but its linked file does not."+
					        		                  " --> saved incoming file as file for the archive-document");
						        	    acceptIncomingFile(sUDI,file);
								        result = 1; // acc
					        		}
				        		}
				        		else{
				        			//*** ARCH_DOC FOUND, WITHOUT REGISTERED LINKED FILE ***
					        	    Debug.println("INFO : An archive-document with UDI '"+existingDoc.udi+"' exists and it has no linked file."+
				        		                  " --> saved incoming file as file for the archive-document");
					        	    acceptIncomingFile(sUDI,file);
							        result = 1; // acc
				        		}
			        		}
			        		else{
			        			//*** NO ARCH_DOC FOUND ***
				        	    Debug.println("WARNING : No archive-document with UDI '"+sUDI+"' found."+
	         		        	              " --> incoming file '"+file.getName()+"' is an orphan. Register an archive-document first.");
				        	    
				        	    // an archive-document, to attach the scan to, must be created first
					        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","ORPHAN_"));
				        	    moveFile(file,errFile);
						        Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
						        result = -1; // err
			        		}
			        	}
			        	else{
			        		//*** UN-CONDITIONAL READ ***************************************
		        			acceptIncomingFile(sUDI,file);
					        result = 1; // acc
			        	}
	        		}
	        		else{
	        			//*** UDI NOT VALID ***
		        	    Debug.println("WARNING : UDI '"+sUDI+"' is not valid (~ 9 first digit MOD 97 = last 2 digits).");
		        	    
			        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","INVUDI_"));
		        	    moveFile(file,errFile);
				        Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
				        result = -1; // err
	        		}
		        }
		        else{
		        	//*** INVALID UDI ***
		        	Debug.println("WARNING : Invalid UDI; length must be 11");
		        	
			        File noscanFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","INVUDI_"));
			    	moveFile(file,noscanFile);
				    Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
			        result = -1; // err
		        }
	        }
	        catch(Exception e){
	        	Debug.printStackTrace(e);
	        }
      	}
      	else{
        	//*** INVALID PREFIX ***
      		Debug.println("WARNING : Filenames must begin with 'SCAN_' ("+file.getName()+")");
      		
      		try{ 
	        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/INVPREFIX_"+file.getName());
	    	    moveFile(file,errFile);
		        Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
		        result = -1; // err
      		}
	        catch(Exception e){
	        	Debug.printStackTrace(e);
	        }
      	}
      	
      	return result;
    }
    
    //--- ACCEPT INCOMING FILE --------------------------------------------------------------------
    private static void acceptIncomingFile(String sUDI, File file) throws Exception {
    	if(Debug.enabled){
	        Debug.println("\n********************** acceptIncomingFile **********************");	
	        Debug.println("file : "+file.getName()+" ("+(file.length()/1024)+"kb)"); 	
	        Debug.println("sUDI : "+sUDI+"\n"); 	
    	}
    	
        String sOrigExt = file.getName().substring(file.getName().lastIndexOf(".")+1);
        
    	String sPathAndName = getFilePathAndName(sUDI,sOrigExt);
   		String sDir = sPathAndName.substring(0,sPathAndName.lastIndexOf("/"));
		createDirs(SCANDIR_BASE+"/"+SCANDIR_TO,sDir);
		
    	File toFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName);
        moveFile(file,toFile);	        
        Debug.println("--> moved file to '"+SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName+"'");
        
        ArchiveDocument.setStorageName(sUDI,sPathAndName);
    }
    
    //--- CREATE DIRS -----------------------------------------------------------------------------
    private static void createDirs(String sBaseDir, String sPath){
        File tempDir = new File(sBaseDir+"/"+sPath);

        if(!tempDir.exists()){
            tempDir.mkdirs();
        }
    }
	
    //--- GET FILE PATH AND NAME ------------------------------------------------------------------
    private static String getFilePathAndName(String sUDI, String sOrigExt){
    	/*
    	if(Debug.enabled){
    	    Debug.println("\n********************* getFilePathAndName ******************");
    	    Debug.println("sUDI     : "+sUDI);
    	    Debug.println("sOrigExt : "+sOrigExt);
    	}
    	*/
    	
    	//int numberOfFile = deMod(sUDI);
    	int numberOfFile = MedwanQuery.getInstance().getOpenclinicCounter("archiveDocumentStoreCount");
    	Debug.println("numberOfFile : "+numberOfFile); 
    	String sPath = getDirName("",numberOfFile).toUpperCase();  
    	String sPathAndName = sPath+"/"+sUDI+"."+sOrigExt.toLowerCase();
    	
    	Debug.println("--> sPathAndName : "+sPathAndName);    	
    	return sPathAndName;
    }
    
    //--- VALID UDI -------------------------------------------------------------------------------
    // laatste 2 cijfers = 97 - (9 eerste cijfers mod 97)
    private static boolean validUDI(String sUDI){
    	if(sUDI.length()!=11) return false;    	
    	boolean udiValid = true;
    	
    	int iPart1 = Integer.parseInt(sUDI.substring(0,9)),
    		iPart2 = Integer.parseInt(sUDI.substring(9,11));
    	
    	udiValid = (iPart2==97-(iPart1%97));
    	
    	return udiValid;
    }
    
    //--- DE-MOD ----------------------------------------------------------------------------------
    // reverse modulo
    //
    // '00012347209' --> 123472 / 09
    //  --> 09 = 97 - (123472%97)
    //  --> 09 = 97 - 88
    //  --> 09 = 09
    //
    private static int deMod(String sUDI){
    	if(Debug.enabled){
	    	Debug.println("\n***************************** deMod ***********************");
	    	Debug.println("sUDI : "+sUDI);
    	}
    	    	
    	String part1 = sUDI.substring(0,sUDI.length()-2); // first 9 digits
    	while(part1.startsWith("0")) part1 = part1.substring(1); // trim zeroes
    	    	
    	Debug.println("--> orig number : "+part1);
    	
    	return Integer.parseInt(part1);
    }
        
    //--- GET DIR NAME ----------------------------------------------------------------------------
    private static String getDirName(String sDirName, int numberOfFile){    	
    	//int remainder = numberOfFile%1024;
    	numberOfFile = numberOfFile/1024;
    	
    	if(numberOfFile > 1024){
        	sDirName+= "/"+numberToDirName(sDirName,numberOfFile)+"/"+getDirName(sDirName,numberOfFile);
    	}
    	else{    			
    	    sDirName+= "/"+numberToDirName(sDirName,numberOfFile);
        }
   	  	
    	return sDirName;
    }
    
    //--- NUMBER TO DIR NAME ----------------------------------------------------------------------
    // number means 'numberOfFile'
    private static String numberToDirName(String sDirName, int number){
    	int remainder = number%26;
    	number = number/26;
    	
    	if(number > 26){
    		sDirName = numberToDirName(sDirName,number);
    	}
    	else{
    	    sDirName = alfabetise(number)+"/"+alfabetise(remainder);
    	}
    	
    	return sDirName;
    }
    
    //--- ALFABETISE ------------------------------------------------------------------------------
    //  0 --> A
    // 25 --> Z
    private static String alfabetise(int number){
    	String sLetter = Character.toString(ALPHABET.charAt(number));
    	sLetter = sLetter.toString().toUpperCase();
    	return sLetter;
    }
    
    //--- MOVE FILE -------------------------------------------------------------------------------
    public static String moveFile(File srcFile, File dstFile) throws IOException {
        InputStream in = new FileInputStream(srcFile);
        OutputStream out = new FileOutputStream(dstFile);

        byte[] buf = new byte[1024];
        int len;
        while((len = in.read(buf)) > 0){
            out.write(buf,0,len);
        }

        in.close();
        out.close();
        
        // preserve original datetime
        dstFile.setLastModified(srcFile.lastModified());
        
        srcFile.delete();
        
        return "moved file '"+srcFile.getName()+"' from '"+srcFile.getAbsolutePath()+"' to '"+dstFile.getAbsolutePath()+"'";
    }
    
    //--- REMOVE OLD DELETED FILES ----------------------------------------------------------------
    // really remove files which are in the 'scanDirectoryMonitor_dirDeleted', when they are one week old
    private static int removeOldDeletedFiles(){
    	int filesDeleted = -1;

        try{        	
        	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_DEL);        	   
        	File[] files = scanDir.listFiles(); 
        	File tmpFile;
        		        	
	        for(int i=0; i<files.length; i++){
	       		tmpFile = (File)files[i];
	       		
	    		if(tmpFile.isFile()){	        		
	        	    if(tmpFile.lastModified() < (new java.util.Date().getTime()-(7*24*3600*1000))){ // millis in week
	        	    	tmpFile.delete();
	        	    	filesDeleted++;
	        	    }
	        	}
    		}
        }
        catch(Exception e){
            e.printStackTrace();
        }

        if(filesDeleted > 0){
       		Debug.println("\n************************ removeOldDeletedFiles ***********************");
			Debug.println("--> "+filesDeleted+" files, older than one week,"+
			              " permanently removed from 'scanDirectoryMonitor_dirDeleted' : "+SCANDIR_BASE+"/"+SCANDIR_DEL);
        }
        
    	return filesDeleted;
    }
    
    //--- MOVE NOT SCANNABLE FILES ----------------------------------------------------------------
    // move files which are in the 'scanDirectoryMonitor_dirFrom', when they do not have a scannable extension (and are not created just now)
    private static int moveNotScannableFiles(){
   		int filesMoved = 0;

        try{        	
        	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_FROM);        	 
        	File[] files = scanDir.listFiles(); // all files 
        	File tmpFile, movedFile;
        	
        	for(int i=0; i<files.length; i++){
        		tmpFile = (File)files[i];
        		
        		if(tmpFile.isFile()){
        			String sExt = tmpFile.getName().substring(tmpFile.getName().lastIndexOf(".")+1);
        			if(EXCLUDED_EXTENSIONS.indexOf(sExt) > -1){
		        	    if(tmpFile.lastModified() < (new java.util.Date().getTime()-(60*1000))){ // millis in minute
		            		movedFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+tmpFile.getName().replaceAll("SCAN_","INVEXT_"));
		            	    moveFile(tmpFile,movedFile);
		            	    filesMoved++;
		        	    }
	        	    }
        		}
        	}
        }
        catch(Exception e){
            e.printStackTrace();
        }

        if(filesMoved > 0){
       		Debug.println("\n************************ moveNotScannableFiles ***********************");
			Debug.println("--> "+filesMoved+" files with extensions other than '"+EXCLUDED_EXTENSIONS+"'"+
			              " moved to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
        }
        
    	return filesMoved;
    }
     	
	//--- RUN -------------------------------------------------------------------------------------
	public void run(){		
        try{
        	while(!isStopped()){
        		if(MedwanQuery.getInstance().getConfigInt("scanDirectoryMonitorEnabled",1)==1){
	        		Debug.println("Running scan-directory-monitor.. ("+(++runCounter)+")");
        			runScheduler();
        		}
        		Thread.sleep(MONITORING_INTERVAL); // default : each minute
        	}
		}
        catch(InterruptedException e){
			e.printStackTrace();
		}
	}
	
}
