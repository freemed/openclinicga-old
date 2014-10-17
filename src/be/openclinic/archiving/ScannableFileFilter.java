package be.openclinic.archiving;

import java.io.File;
import java.io.FileFilter;

import be.mxs.common.util.system.Debug;

public class ScannableFileFilter implements FileFilter {
    private String sExcludedExtensions = "";

    //--- CONSTRUCTOR ---
    public ScannableFileFilter(String sExt){
        super();
    	sExcludedExtensions = sExt;
    }
    
    //--- ACCEPT ----------------------------------------------------------------------------------
    public boolean accept(File file){
    	// only files
        if(!file.isDirectory()){
            String sFileName = file.getName().toLowerCase();
            String sFileExtension = sFileName.substring(sFileName.lastIndexOf(".")+1);

            return sExcludedExtensions.indexOf(sFileExtension) < 0;
        }
        // no directories
        else{
            return false;
        }
    }

    //--- GET DESCRIPTION -------------------------------------------------------------------------
    public String getDescription() {
        return "Any extension except those configured in 'notScannableFileExtensions'. ("+sExcludedExtensions+")";
    }

}
