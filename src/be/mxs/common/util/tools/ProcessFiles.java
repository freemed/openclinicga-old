package be.mxs.common.util.tools;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class ProcessFiles {
	
	public static Boolean renameFile(String oldName, String newName) throws IOException{		
		File oldFile = new File(oldName);

		Boolean success = oldFile.renameTo(new File(newName));
		
		if (!success){
			//System.out.println("Failed to Rename");			
		}
		else{
			//System.out.println("Rename Successful");			
		}
		return success;
	}	
    
    public static void writeFile(String sFullFileName, String sTextToWrite){
	
		try{
			
			//BufferedWriter out = new BufferedWriter(new OutputStreamWriter
			//		  (new FileOutputStream(file),"UTF8"));
			
			// Create file 
			FileWriter fwStream = new FileWriter(sFullFileName);
	        BufferedWriter bwOut = new BufferedWriter(fwStream);
	        bwOut.write(sTextToWrite);
			//Close the output stream
			bwOut.close();
		}catch (Exception e){//Catch exception if any
			System.err.println("Error: " + e.getMessage());
		}
    }
	
	static void pMoveFiles(int indent, String sFromDir, File file, File destDir) throws IOException {
 
    	String sNewPath = ""; 
    	String sFullString = file.getPath();
    		    
	    for (int i = 0; i < indent; i++)
		      System.out.print("-");	    
    	
	    if (file.isFile()) {   	
	    	sFullString = sFullString + " (F)";
	    	if (file.getPath().lastIndexOf(".java") > -1){
	    		//sNewPath = file.getPath().substring(0, file.getPath().length() - 15 - file.getName().length() ); // .svn\text-base\ = 15 //.java.svn-base
	    		sNewPath = destDir + file.getPath().substring(sFromDir.length(), file.getPath().length() ); // .svn\text-base\ = 15
	    		
	    		//sFullString = sFullString + ". Will be moved to: " + sNewPath;
	    		///*	    		
	    		if (renameFile(file.getPath(), sNewPath)){	    			
	    			sFullString = "File: "  + file.getPath() + " Successfully Moved to: " + sNewPath;
	    		} else {
	    			sFullString = "Failed to Move File: " + file.getPath() + " To: " + sNewPath;
	    		}
	    		//*/	    		
	    	}
	    }
	    

	    if (file.isDirectory()) {
	      File[] files = file.listFiles();
	      for (int i = 0; i < files.length; i++)
	    	  pMoveFiles(indent + 3, sFromDir, files[i], destDir);
	    }
	    	    
	}	
    
    public static void main(String[] a) throws IOException{

    	String sFromDir = "/home/fernando/work/onlySourceCode/src"; 
    	String sToDir =   "/home/fernando/work/onlyHiddenFiles/src"; 	// 	"/projects/openclinic/src"
    	Integer iIndent = 1;
    	pMoveFiles(iIndent, sFromDir, new File(sFromDir), new File(sToDir));

	}		
}
