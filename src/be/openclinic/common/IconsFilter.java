package be.openclinic.common;

import be.mxs.common.util.db.MedwanQuery;
import java.io.File;
import java.io.FileFilter;

public class IconsFilter implements FileFilter {
    private String sDefaultExtensions = "ico,png,jpg,bmp,gif";
    private String sExtensions = MedwanQuery.getInstance().getConfigString("iconExtensions",sDefaultExtensions);

    //--- CONSTRUCTOR ---
    public IconsFilter(){
        super();

        // check which extension are configured to be accepted
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
        return "Any extension which is configured in 'iconExtensions'. ("+sExtensions+")";
    }

}
