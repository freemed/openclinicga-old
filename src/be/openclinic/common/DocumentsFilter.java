package be.openclinic.common;

import be.mxs.common.util.db.MedwanQuery;
import java.io.File;
import java.io.FileFilter;

public class DocumentsFilter implements FileFilter {
    private String sDefaultExtensions = "doc,pdf,txt,rtf";
    private String sExtensions = MedwanQuery.getInstance().getConfigString("printableDocumentExtensions",sDefaultExtensions);

    //--- CONSTRUCTOR ---
    public DocumentsFilter(){
        super();

        // check which extension sare configed to be accepted
        if(sExtensions.length()==0){
            sExtensions = sDefaultExtensions;
        }

        sExtensions = sExtensions.toLowerCase();
    }

    //--- ACCEPT ----------------------------------------------------------------------------------
    public boolean accept(File file) {
        if(!file.isDirectory()){
            String sFileName = file.getName().toLowerCase();
            String sFileExtension = sFileName.substring(sFileName.lastIndexOf(".")+1);

            return sExtensions.indexOf(sFileExtension) > -1;
        }
        else{
            return false;
        }
    }

    //--- GET DESCRIPTION -------------------------------------------------------------------------
    public String getDescription() {
        return "Any extension which is configured in 'printableDocumentExtensions' document. ("+sExtensions+")";
    }

}
