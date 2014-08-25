package be.openclinic.archiving;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;

//import be.mxs.common.util.db.MedwanQuery; // independant of MWQ
import be.mxs.common.util.system.Debug;

public class ScanDirectoryMonitorBasic implements Runnable{
	private boolean stopped = false;
	private static int runCounter;
	private Thread thread;
	
	// config-values
	public static String SCANDIR_URL, SCANDIR_BASE, SCANDIR_FROM, SCANDIR_TO, SCANDIR_ERR, SCANDIR_DEL;		
	public static int FILES_PER_DIRECTORY;
	public static long MONITORING_INTERVAL;
	public static String EXCLUDED_EXTENSIONS;
	
	static{
	    Debug.enabled = true;
	}
	
	private static final String ALPHABET = "abcdefghijklmnopqrstuvwxyz"; 
	private boolean OK_TO_START;
	
	
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
	public ScanDirectoryMonitorBasic(Object args[]){
		OK_TO_START = true;
		loadConfig(args);
		
		if(Debug.enabled){
			Debug.println("\n************************ ScanDirectoryMonitor ********************************************");
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
	    loadConfig(null);	
	}
	
	public static void loadConfig(Object args[]){
		Connection conn = null;
		
		try{
		    Class.forName("com.mysql.jdbc.Driver");	
		    if(args==null){
		        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/openclinic_dbo");
		    }
		    else if(args.length==1){
		    	String sUrl = "jdbc:mysql://localhost:3306/openclinic_dbo?user="+args[0];
		    	conn = DriverManager.getConnection(sUrl);
		    }
		    else if(args.length==2){
		    	String sUrl = "jdbc:mysql://localhost:3306/openclinic_dbo?user="+args[0]+"&password="+args[1];
		    	conn = DriverManager.getConnection(sUrl);
		    }
		    
			SCANDIR_URL  = getConfigStringDB("scanDirectoryMonitor_url",conn);
			SCANDIR_BASE = getConfigStringDB("scanDirectoryMonitor_basePath",conn);
			SCANDIR_FROM = getConfigStringDB("scanDirectoryMonitor_dirFrom",conn);
		    SCANDIR_TO   = getConfigStringDB("scanDirectoryMonitor_dirTo",conn);
		    SCANDIR_ERR  = getConfigStringDB("scanDirectoryMonitor_dirError",conn);
		    SCANDIR_DEL  = getConfigStringDB("scanDirectoryMonitor_dirDeleted",conn);
					
			FILES_PER_DIRECTORY = getConfigIntDB("scanDirectoryMonitor_filesPerDirectory",1024,conn);
			MONITORING_INTERVAL = getConfigIntDB("scanDirectoryMonitor_interval",60*1000,conn);
		    EXCLUDED_EXTENSIONS = getConfigStringDB("scanDirectoryMonitor_notScannableFileExtensions",conn).toLowerCase();		    
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
		        if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
	}
	
	//--- GET CONFIG STRING DB --------------------------------------------------------------------
	private static String getConfigStringDB(String sID, Connection conn){
	    return getConfigStringDB(sID,"",conn);	
	}
	
	private static String getConfigStringDB(String sID, String sDefault, Connection conn){
		String sValue = sDefault;
				
		try{ 		    
			PreparedStatement ps = conn.prepareStatement("SELECT oc_value FROM oc_config WHERE oc_key = ?");
			ps.setString(1,sID);
		    ResultSet rs = ps.executeQuery();
		    if(rs.next()){
		    	sValue = rs.getString(1);
		    }
		    rs.close();
		    ps.close();	    
		}
		catch(Exception e){			
			e.printStackTrace();
		}		
		
		return sValue;
	}
	
	//--- GET CONFIG INT DB -----------------------------------------------------------------------
	private static int getConfigIntDB(String sID, int iDefault, Connection conn){
		int iValue = iDefault;
		
		try{ 		    
			PreparedStatement ps = conn.prepareStatement("SELECT oc_value FROM oc_config WHERE oc_key = ?");
			ps.setString(1,sID);
		    ResultSet rs = ps.executeQuery();
		    if(rs.next()){
		    	iValue = Integer.parseInt(rs.getString(1));
		    }
		    rs.close();
		    ps.close();	    
		}
		catch(Exception e){			
			e.printStackTrace();
		}
		
		return iValue;		
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
        	File scanDir = new File(SCANDIR_BASE+"/"+SCANDIR_FROM);
        	
        	ScannableFileFilter fileFilter = new ScannableFileFilter(EXCLUDED_EXTENSIONS);        	
        	File[] scannableFiles = scanDir.listFiles(fileFilter); 
        	if(scannableFiles.length > 0){
	        	Debug.println(" ScannableFiles in 'scanDirectoryMonitor_dirFrom' : "+scannableFiles.length);
	        	for(int i=0; i<scannableFiles.length; i++){
	        	    storeFileInDB((File)scannableFiles[i]);
	        	}
        	}
        	
        	moveNotScannableFiles();        	
        	removeOldDeletedFiles();
        }
        catch(Exception e){
            e.printStackTrace();
        }
	}
    
    //--- STORE FILE IN DataBase ------------------------------------------------------------------
    // meta-data in DB
    // file itself as file in 'scanDirectoryTo'
    public static void storeFileInDB(File file){
        storeFileInDB(file,false);	
    }
    
    public static void storeFileInDB(File file, boolean forced){
    	if(Debug.enabled){
	        Debug.println("\n************************** storeFileInDB **************************");	
	        Debug.println("file : "+file.getName()+" ("+(file.length()/1024)+"kb)"); 	
	        Debug.println("forced : "+forced+"\n"); 	
    	}
    	
      	if(file.getName().startsWith("SCAN_")){
            try{
	    	    String sUDI = file.getName().substring(file.getName().indexOf("_")+1,file.getName().lastIndexOf(".")); // remove prefix and extension
		        Debug.println("--> sUDI : "+sUDI);
		        
		        if(sUDI.length()==11){
		        	if(!forced){	
		        		//*** CONDITIONAL READ ******************************************
			        	// check existence of archive-document
		        		ArchiveDocumentBasic existingDoc = ArchiveDocumentBasic.get(sUDI);
		        		if(existingDoc!=null){
				        	// check existence of linked file
	                        File existingFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+existingDoc.storageName);
			        		if(existingFile.exists()){
			        			//*** DOUBLE FILE, WITH EXISTING FILE ***
				        	    Debug.println("WARNING : A file '"+existingDoc.storageName+"' exists for the archive-document with UDI '"+existingDoc.udi+"'."+
				        	                  " --> incoming file '"+file.getName()+"' is a double file.");
				        	    
				        	    // must be read by a person before overwriting the existing file
					        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","DOUBLE_"));
				        	    moveFile(file,errFile);
						        Debug.println("--> moved file to 'scanDirectoryErr' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
			        		}
			        		else{
			        			//*** DOUBLE FILE, WITHOUT EXISTING FILE ***
				        	    Debug.println("INFO : An archive-document with UDI '"+existingDoc.udi+"' exists, but its linked file does not."+
			        		                  " --> saved incoming file as file for the archive-document");
				        	    acceptIncomingFile(sUDI,file);
			        		}
		        		}
		        		else{
		        			//*** NO ARCH-DOC EXISTS ***
			        	    Debug.println("WARNING : No archive-document with UDI '"+sUDI+"' found."+
         		        	              " --> incoming file '"+file.getName()+"' is an orphan. Register an archive-document first.");
			        	    
			        	    // an archive-document, to attach the scan to, must be created first
				        	File errFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","ORPHAN_"));
			        	    moveFile(file,errFile);
					        Debug.println("--> moved file to 'scanDirectoryErr' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
		        		}
		        	}
		        	else{
		        		//*** UN-CONDITIONAL READ ***************************************
	        			acceptIncomingFile(sUDI,file);
		        	}
		        }
		        else{
		        	//*** INVALID UDI ***
		        	Debug.println("WARNING : Invalid UDI; length must be 11");
		        	
			        File noscanFile = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+file.getName().replaceAll("SCAN_","INVUDI_"));
			    	moveFile(file,noscanFile);
				    Debug.println("--> moved file to 'scanDirectoryMonitor_dirError' : "+SCANDIR_BASE+"/"+SCANDIR_ERR);
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
      		}
	        catch(Exception e){
	        	Debug.printStackTrace(e);
	        }
      	}
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
    	if(sPathAndName.length() > 0){
    		String sDir = sPathAndName.substring(0,sPathAndName.lastIndexOf("/"));
    		createDirs(SCANDIR_BASE+"/"+SCANDIR_TO,sDir);
    		
        	File toFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName);
	        moveFile(file,toFile);	        
	        Debug.println("--> moved file to '"+SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName+"'");
	        
	        ArchiveDocument.setStorageName(sUDI,sPathAndName);
    	}
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
    	if(Debug.enabled){
    	    Debug.println("\n********************* getFilePathAndName ******************");
    	    Debug.println("sUDI     : "+sUDI);
    	    Debug.println("sOrigExt : "+sOrigExt);
    	}
    	
    	int numberOfFile = deMod(sUDI);
    	//int numberOfFile = MedwanQuery.getInstance().getOpenclinicCounter("archiveDocumentStoreCount");
    	Debug.println("numberOfFile : "+numberOfFile); 
    	String sPath = getDirName("",numberOfFile).toUpperCase();  
    	String sPathAndName = sPath+"/"+sUDI+"."+sOrigExt.toLowerCase();
    	
    	Debug.println("--> sPathAndName : "+sPathAndName);    	
    	return sPathAndName;
    }
    
    //--- DE-MOD ----------------------------------------------------------------------------------
    // reverse modulo
    private static int deMod(String sUDI){
    	if(Debug.enabled){
	    	Debug.println("\n***************************** deMod ***********************");
	    	Debug.println("sUDI : "+sUDI);
    	}
    	
    	String[] sUDIParts = new String[2];
    	
    	sUDIParts[0] = sUDI.substring(0,sUDI.length()-2); // first 9 digits
    	while(sUDIParts[0].startsWith("0")) sUDIParts[0] = sUDIParts[0].substring(1);
    	
    	sUDIParts[1] = sUDI.substring(sUDI.length()-2); // last 2 digits
    	while(sUDIParts[1].startsWith("0")) sUDIParts[1] = sUDIParts[1].substring(1);
    	
    	int deMod = (Integer.parseInt(sUDIParts[0])*97)+Integer.parseInt(sUDIParts[1]);
    	Debug.println("--> deMod : "+deMod);
    	
    	return deMod;
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
   		int filesMoved = -1;

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
    
    //--- CHECK STRING ----------------------------------------------------------------------------
    private static String checkString(String sString) {
        // om geen 'null' weer te geven
        if((sString==null)||(sString.toLowerCase().equals("null"))) {
            return "";
        }
        else{
            sString = sString.trim();
        }
        return sString;
    }
    	
	//--- RUN -------------------------------------------------------------------------------------
	public void run(){		
        try{
        	while(!isStopped()){
        		//if(getConfigIntDB("scanDirectoryMonitorEnabled",1)==1){
	        		Debug.println("Running scan-directory-monitor.. ("+(++runCounter)+")");
        			runScheduler();
        		//}
        		Thread.sleep(MONITORING_INTERVAL); // default : each minute
        	}
		}
        catch(InterruptedException e){
			e.printStackTrace();
		}
	}
	
}
