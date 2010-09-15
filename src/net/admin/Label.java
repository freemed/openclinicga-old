package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

public class Label implements Serializable {
    // variables
    public String type;
    public String id;
    public String language;
    public String value;
    public String showLink;
    public String updateUserId;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public Label(String type, String id, String language, String value, String showLink, String updateUserId){
        this.type         = type;
        this.id           = id;
        this.language     = language;
        this.value        = value;
        this.showLink     = showLink;
        this.updateUserId = updateUserId;
    }

    //--- EMPTY CONSTRUCTOR -----------------------------------------------------------------------
    public Label() {
        this.type         = "";
        this.id           = "";
        this.language     = "";
        this.value        = "";
        this.showLink     = "1";
        this.updateUserId = "";
    }

    //--- Start Copied from AdminLabel --------------
    //--- CONSTRUCTOR 3 ------
    public Label(String sLanguage, String sValue){
        this.type         = "";
        this.id           = "";
        this.language     = sLanguage;
        this.value        = sValue;
        this.showLink     = "1";
        this.updateUserId = "";
    }
    //--- End Copied from AdminLabel --------------

    //--- COMPLETE --------------------------------------------------------------------------------
    public void complete() throws Exception {
        if(this.showLink.length()==0) this.showLink = "1"; //show by default

        if(this.type.length()==0)         throw new Exception("Label is not complete : 'type' missing");
        if(this.id.length()==0)           throw new Exception("Label is not complete : 'id' missing");
        if(this.language.length()==0)     throw new Exception("Label is not complete : 'language' missing");
        if(this.value.length()==0)        throw new Exception("Label is not complete : 'value' missing");
        if(this.updateUserId.length()==0) throw new Exception("Label is not complete : 'updateUserId' missing");
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public void saveToDB(){
        try{
            if(this.exists()) update();
            else              insert();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    public boolean exists(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean labelExists = false;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_LABELS"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,this.type.toLowerCase());
            ps.setString(2,this.id.toLowerCase());
            ps.setString(3,this.language.toLowerCase());
            rs = ps.executeQuery();

            if(rs.next()) labelExists = true;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return labelExists;
    }

    //--- INSERT ----------------------------------------------------------------------------------
    private void insert() throws Exception {
        complete();
        PreparedStatement ps = null;

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "INSERT INTO OC_LABELS (OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,"+
                             "  OC_LABEL_VALUE,OC_LABEL_UPDATETIME,OC_LABEL_SHOWLINK,OC_LABEL_UPDATEUSERID)"+
                             " VALUES(?,?,?,?,?,?,?)";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,this.type.toLowerCase());
            ps.setString(2,this.id.toLowerCase());
            ps.setString(3,this.language.toLowerCase());
            ps.setString(4,this.value);
            ps.setTimestamp(5,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setInt(6,this.showLink.equals("1")?1:0);
            ps.setInt(7,Integer.parseInt(this.updateUserId));
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }

    //--- UPDATE ----------------------------------------------------------------------------------
    private void update() throws Exception {
        complete();

        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "UPDATE OC_LABELS"+
                             "  SET OC_LABEL_VALUE=?,OC_LABEL_UPDATETIME=?, OC_LABEL_SHOWLINK=?, OC_LABEL_UPDATEUSERID=?"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,this.value);
            ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setBoolean(3,this.showLink.equals("1"));
            ps.setInt(4,Integer.parseInt(this.updateUserId));

            // where
            ps.setString(5,this.type.toLowerCase());
            ps.setString(6,this.id.toLowerCase());
            ps.setString(7,this.language.toLowerCase());

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }

    public void updateByTypeIdLanguage(String sOldLabelType,String sOldLabelId, String sOldLabelLanguage) throws Exception {
        complete();

        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = " UPDATE OC_LABELS"+
                             " SET OC_LABEL_TYPE=?, OC_LABEL_ID=?, OC_LABEL_LANGUAGE=?, OC_LABEL_VALUE=?,"+
                             "     OC_LABEL_UPDATETIME=?, OC_LABEL_SHOWLINK=?, OC_LABEL_UPDATEUSERID=?"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,this.type);
            ps.setString(2,this.id);
            ps.setString(3,this.language);
            ps.setString(4,this.value);
            ps.setTimestamp(5,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setBoolean(6,this.showLink.equals("1"));
            ps.setInt(7,Integer.parseInt(this.updateUserId));

            // where
            ps.setString(8,sOldLabelType);
            ps.setString(9,sOldLabelId);
            ps.setString(10,sOldLabelLanguage);

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }


    //--- GET -------------------------------------------------------------------------------------
    public static Label get(String type, String id, String lang){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Label label = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_LABELS"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,type.toLowerCase());
            ps.setString(2,id.toLowerCase());
            ps.setString(3,lang.toLowerCase());

            rs = ps.executeQuery();
            if(rs.next()){
                label = new Label();
                label.type = type;
                label.id = id;
                label.language = lang;
                label.showLink = (rs.getBoolean("OC_LABEL_SHOWLINK")?"1":"0");
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return label;
    }

    //--- EXISTS BASED ON NAME --------------------------------------------------------------------
    public static boolean existsBasedOnName(String type, String value, String lang){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean labelExists = false;

        String lcaseLabelType  = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelValue = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE"),
               lcaseLabelLang  = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_LABELS"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelValue+"=? AND "+lcaseLabelLang+"=?";

            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,type.toLowerCase());
            ps.setString(2,value);
            ps.setString(3,lang.toLowerCase());
            rs = ps.executeQuery();

            if(rs.next()) labelExists = true;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return labelExists;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String sType, String sId, String sLanguage){
        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_LABELS"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sType.toLowerCase());
            ps.setString(2,sId.toLowerCase());
            ps.setString(3,sLanguage.toLowerCase());
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }
    
    public void saveToDB(String sType, String sCode){
        Label label = new Label();
        label.type = sType;
        label.id = sCode;
        label.language = this.language;
        label.value = this.value;
        label.showLink = "1";
        label.updateUserId = "1"; // system

        label.saveToDB();
    }
    //--- End Copied from AdminLabel ---

    public static Vector getLabels(String sType,String sCode,String sText,String sLanguage, String sSort){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSelect = "SELECT * FROM OC_LABELS";
        String sAdd = "";
        if(sType.length() > 0){
            sAdd += MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE") + " like ? AND ";
        }

        if (sCode.length() > 0) {
            sAdd += MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID") + " like ? AND ";
        }

        if (sLanguage.length() > 0) {
            sAdd += MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE") + " like ? AND ";
        }

        if (sText.length() > 0) {
            sAdd += MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_VALUE") + " like ? AND ";
        }

        if(sAdd.length() > 0){
            sSelect = sSelect + " WHERE " + sAdd.substring(0,sAdd.length()-4);
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sSort.length() > 0){
                sSelect += " ORDER BY " + sSort;
            }
            ps = oc_conn.prepareStatement(sSelect);
            int iIndex = 1;
            if (sType.length() > 0) {
                ps.setString(iIndex++, "%" + sType.toLowerCase() + "%");
            }

            if (sCode.length() > 0) {
                ps.setString(iIndex++, "%" + sCode.toLowerCase() + "%");
            }

            if (sLanguage.length() > 0) {
                ps.setString(iIndex++, "%" + sLanguage.toLowerCase() + "%");
            }

            if (sText.length() > 0) {
                ps.setString(iIndex++, "%" + sText.toLowerCase() + "%");
            }

            rs = ps.executeQuery();

            Label label;
            while(rs.next()){
                label = new Label();
                label.type = ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE"));
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.language = ScreenHelper.checkString(rs.getString("OC_LABEL_LANGUAGE"));
                label.showLink = (rs.getBoolean("OC_LABEL_SHOWLINK")?"1":"0");
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));
                vLabels.addElement(label);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabels;
    }

    public static Vector getExternalContactsLabels(String sType, String sText,String sLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sQuery = "SELECT * FROM OC_LABELS" +
                " WHERE " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE") + sType +
                "  AND " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE") + " LIKE ?" +
                "  AND (" + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID") + " LIKE ?" +
                "   OR " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID") + " LIKE ?" +
                "   OR " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_VALUE") + " LIKE ?" +
                "  )";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery);
            ps.setString(1, "%" + sLanguage.toLowerCase() + "%");
            ps.setString(2, "%" + sText.toLowerCase() + "%");
            ps.setString(3, "%" + sText.toLowerCase() + ".%");
            ps.setString(4, "%" + sText.toLowerCase() + "%");
            rs = ps.executeQuery();

            Label label;
            while(rs.next()){
                label = new Label();
                label.type = ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE"));
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.language = ScreenHelper.checkString(rs.getString("OC_LABEL_LANGUAGE"));
                label.showLink = (rs.getBoolean("OC_LABEL_SHOWLINK")?"1":"0");
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));
                vLabels.addElement(label);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabels;
    }

    public static Vector getNonServiceFunctionLabels(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSelect = "SELECT * FROM OC_LABELS" +
                    " WHERE " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE") +
                    "  NOT IN ('service','function')";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();
            
            Label label;

            while(rs.next()){
                label = new Label();
                label.type = ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE"));
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.language = ScreenHelper.checkString(rs.getString("OC_LABEL_LANGUAGE"));
                label.showLink = (rs.getBoolean("OC_LABEL_SHOWLINK")?"1":"0");
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));

                vLabels.addElement(label);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabels;
    }

    public static void UpdateLabelTypeByType(String sOldType, String sNewType){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE OC_LABELS SET OC_LABEL_TYPE = ? WHERE OC_LABEL_TYPE = ?";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sUpdate);
            ps.setString(1,sNewType);
            ps.setString(2,sOldType);
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void UpdateNonServiceFunctionLabels(String sNewLabelType,String sNewLabelId,String sNewLabelLanguage, String sOldLabelType){
        PreparedStatement ps = null;
        
        StringBuffer query = new StringBuffer();
        query.append("UPDATE OC_LABELS")
                .append(" SET OC_LABEL_TYPE = " + sNewLabelType + ",")
                .append("     OC_LABEL_ID = " + sNewLabelId + ",")
                .append("     OC_LABEL_LANGUAGE = " + sNewLabelLanguage)
                .append(" WHERE " + sOldLabelType + " NOT IN ('service','function')");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(query.toString());
            ps.executeUpdate();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Vector getLabelTypes(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabelTypes = new Vector();

        String sSelect = "SELECT DISTINCT OC_LABEL_TYPE FROM OC_LABELS ORDER BY 1";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                vLabelTypes.addElement(ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE")));
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return vLabelTypes;
    }

    public static Vector findFunction_manageTranslationsPage(String findLabelType,String findLabelID,String findLabelLang, String findLabelValue,boolean excludeFunctions,boolean excludeServices){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_LABELS WHERE ";

        if(findLabelType.length()>0) {
            sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" = '"+ScreenHelper.checkDbString(findLabelType).toLowerCase()+"' AND ";
        }

        if(findLabelID.length()>0) {
            sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" like '%"+ScreenHelper.checkDbString(findLabelID).toLowerCase()+"%' AND ";
        }

        if(findLabelLang.length()>0) {
            sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" = '"+ScreenHelper.checkDbString(findLabelLang).toLowerCase()+"' AND ";
        }

        if(findLabelValue.length()>0) {
            sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_VALUE")+" like '%"+ScreenHelper.checkDbString(findLabelValue).toLowerCase()+"%' AND ";
        }

        // exclusions on labeltype
        if(excludeFunctions) sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" <> 'function' AND ";
        if(excludeServices)  sSelect+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" NOT IN ('service','externalservice') AND ";

        sSelect = sSelect.substring(0,sSelect.length()-4); // remove last " AND"
        sSelect+= "ORDER BY OC_LABEL_TYPE, OC_LABEL_ID, OC_LABEL_LANGUAGE";

        Vector vLabels = new Vector();

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            Label label;

            while(rs.next()){
                label = new Label();
                label.type = ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE"));
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.language = ScreenHelper.checkString(rs.getString("OC_LABEL_LANGUAGE"));
                label.showLink = (rs.getBoolean("OC_LABEL_SHOWLINK")?"1":"0");
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));

                vLabels.addElement(label);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabels;
    }

    public static Vector findFunctionServiceLabels(String sLabelType,String sLabelLang, String sFindText){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSelect = " SELECT OC_LABEL_VALUE, OC_LABEL_ID FROM OC_LABELS" +
                         " WHERE " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE") + " = ?" +
                         "  AND " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE") + " = ?" +
                         "  AND (" + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID") + " LIKE ?" +
                         "   OR " + MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_VALUE") + " LIKE ?" +
                         "  )" +
                         " ORDER BY OC_LABEL_VALUE ASC";

        // functions never have special characters, so search them with normalised characters.
        if (sLabelType.equalsIgnoreCase("function")) {
            sFindText = ScreenHelper.normalizeSpecialCharacters(sFindText);
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sLabelType.toLowerCase());
            ps.setString(2, sLabelLang.toLowerCase());
            ps.setString(3, "%" + sFindText.toLowerCase() + "%");
            ps.setString(4, "%" + sFindText.toLowerCase() + "%");
            rs = ps.executeQuery();

            Label label;
            while(rs.next()){
                label = new Label();
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));

                vLabels.addElement(label);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabels;
    }
}