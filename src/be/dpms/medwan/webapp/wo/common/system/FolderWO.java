package be.dpms.medwan.webapp.wo.common.system;

import java.util.Collection;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 30-mai-2003
 * Time: 16:34:18
 * To change this template use Options | File Templates.
 */
public class FolderWO extends be.mxs.webapp.wo.common.system.FolderWO {

    // -----------------------------------------------------------------------------------------------------------------
    // ---- Folders definition ------------------------------------------------------------------------------------------
    // -----------------------------------------------------------------------------------------------------------------

    public static String FOLDER_OCCUPATIONAL_MEDICINE = "FOLDER_OCCUPATIONAL_MEDICINE";
    public static String FOLDER_RECRUITMENT = "FOLDER_RECRUITMENT";

    // -----------------------------------------------------------------------------------------------------------------
    // ---- Folder entries definition ----------------------------------------------------------------------------------
    // -----------------------------------------------------------------------------------------------------------------

    public static String FOLDER_ENTRY_ALL_WORLPLACES = "FOLDER_ENTRY_ALL_WORLPLACES";
    public static String FOLDER_ENTRY_RISK_PROFILE = "FOLDER_ENTRY_RISK_PROFILE";

    // -----------------------------------------------------------------------------------------------------------------
    // ---- Folder setters/getters -------------------------------------------------------------------------------------
    // -----------------------------------------------------------------------------------------------------------------

    public void setWorkplaces(Collection workplaces){

        this.put(FolderWO.FOLDER_ENTRY_ALL_WORLPLACES, workplaces);
    }

    public Collection getWorkplaces() { return (Collection)this.get(FolderWO.FOLDER_ENTRY_ALL_WORLPLACES); }
}
