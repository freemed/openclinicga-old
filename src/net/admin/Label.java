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


    //--- CONSTRUCTOR (1) -------------------------------------------------------------------------
    public Label(String type, String id, String language, String value, String showLink, String updateUserId){
        this.type         = type;
        this.id           = id;
        this.language     = language;
        this.value        = value;
        this.showLink     = showLink;
        this.updateUserId = updateUserId;
    }

    //--- CONSTRUCTOR (2) -------------------------------------------------------------------------
    public Label(){
        this.type         = "";
        this.id           = "";
        this.language     = "";
        this.value        = "";
        this.showLink     = "1";
        this.updateUserId = "";
    }

    //--- CONSTRUCTOR 3 ---------------------------------------------------------------------------
    public Label(String sLanguage, String sValue){
        this.type         = "";
        this.id           = "";
        this.language     = sLanguage;
        this.value        = sValue;
        this.showLink     = "1";
        this.updateUserId = "";
    }

    //--- IS COMPLETE -----------------------------------------------------------------------------
    public void isComplete() throws Exception {
        if(this.showLink.length()==0) this.showLink = "1"; // show by default

        if(this.type.length()==0)         throw new Exception("Label ("+id+"$MISSING$"+language+") is not complete : type missing");
        if(this.id.length()==0)           throw new Exception("Label (MISSING$"+type+"$"+language+") is not complete : id missing");
        if(this.language.length()==0)     throw new Exception("Label ("+id+"$"+type+"$MISSING) is not complete : language missing");
        if(this.value.length()==0)        System.out.println("Label ("+id+"$"+type+"$"+language+") is not complete : value missing");
        if(this.updateUserId.length()==0) throw new Exception("Label ("+id+"$"+type+"$"+language+") is not complete : updateUserId missing");
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

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_LABELS"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";
            ps = conn.prepareStatement(sSql);
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
                conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return labelExists;
    }

    //--- INSERT ----------------------------------------------------------------------------------
    private void insert() throws Exception {
        isComplete();
        
        if(this.value.length() > 0){
	        PreparedStatement ps = null;
	
	        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	        try{
	            String sSql = "INSERT INTO OC_LABELS (OC_LABEL_TYPE,OC_LABEL_ID,OC_LABEL_LANGUAGE,"+
	                          "  OC_LABEL_VALUE,OC_LABEL_UPDATETIME,OC_LABEL_SHOWLINK,OC_LABEL_UPDATEUSERID)"+
	                          " VALUES(?,?,?,?,?,?,?)";
	            ps = conn.prepareStatement(sSql);
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
	                conn.close();
	            }
	            catch(SQLException e){
	                e.printStackTrace();
	            }
	        }
        }
    }

    //--- UPDATE ----------------------------------------------------------------------------------
    private void update() throws Exception {
    	isComplete();
        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "UPDATE OC_LABELS"+
                          "  SET OC_LABEL_VALUE=?, OC_LABEL_UPDATETIME=?, OC_LABEL_SHOWLINK=?, OC_LABEL_UPDATEUSERID=?"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";
            ps = conn.prepareStatement(sSql);
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
                conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

    //--- UPDATE BY TYPE ID LANGUAGE --------------------------------------------------------------
    public void updateByTypeIdLanguage(String sOldLabelType, String sOldLabelId, String sOldLabelLanguage) throws Exception {
    	isComplete();
        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "UPDATE OC_LABELS"+
                          " SET OC_LABEL_TYPE=?, OC_LABEL_ID=?, OC_LABEL_LANGUAGE=?, OC_LABEL_VALUE=?,"+
                          "     OC_LABEL_UPDATETIME=?, OC_LABEL_SHOWLINK=?, OC_LABEL_UPDATEUSERID=?"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";
            ps = conn.prepareStatement(sSql);
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
                conn.close();
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

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_LABELS"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=? AND "+lcaseLabelLang+"=?";
            ps = conn.prepareStatement(sSql);
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
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
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

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_LABELS"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelValue+"=? AND "+lcaseLabelLang+"=?";
            ps = conn.prepareStatement(sSql);
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
                conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return labelExists;
    }

    //--- HAS SIBLINGS ----------------------------------------------------------------------------
    // same type, _comparable_ id, same language and same value
    public static boolean hasSiblings(String type, String id, String value, String lang){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean hasSiblings = false;

        String lcaseLabelType  = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelId    = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang  = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE"),
               lcaseLabelValue = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE");

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_LABELS"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelId+" LIKE ?"+
            		      "  AND "+lcaseLabelLang+"=? AND "+lcaseLabelValue+"=?";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,type.toLowerCase());
            ps.setString(2,id.toLowerCase());
            ps.setString(3,lang.toLowerCase());
            ps.setString(4,value);
            rs = ps.executeQuery();

            if(rs.next()) hasSiblings = true;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return hasSiblings;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String sType, String sId){
        delete(sType,sId,""); // all languages	
    }
    
    public static void delete(String sType, String sId, String sLanguage){
        PreparedStatement ps = null;

        String lcaseLabelType = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE"),
               lcaseLabelID   = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID"),
               lcaseLabelLang = ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE");

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_LABELS"+
                          " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelID+"=?";
            
            if(sLanguage.length() > 0){
            	sSql+= "AND "+lcaseLabelLang+"=?";
            }
            
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sType.toLowerCase());
            ps.setString(2,sId.toLowerCase());
            if(sLanguage.length() > 0){
                ps.setString(3,sLanguage.toLowerCase());
            }
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
    
    //--- SAVE TO DB ------------------------------------------------------------------------------
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

    //--- GET LABELS ------------------------------------------------------------------------------
    public static Vector getLabels(String sType, String sCode, String sText, String sLanguage, String sSort){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSql = "SELECT * FROM OC_LABELS";
        String sAdd = "";
        if(sType.length() > 0){
            sAdd+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" like ? AND ";
        }

        if(sCode.length() > 0){
            sAdd+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" like ? AND ";
        }

        if(sLanguage.length() > 0){
            sAdd+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" like ? AND ";
        }

        if(sText.length() > 0){
            sAdd+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_VALUE")+" like ? AND ";
        }

        if(sAdd.length() > 0){
            sSql = sSql+" WHERE "+sAdd.substring(0,sAdd.length()-4);
        }

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sSort.length() > 0){
                sSql+= " ORDER BY "+sSort;
            }
            ps = oc_conn.prepareStatement(sSql);
            int iIndex = 1;
            if(sType.length() > 0){
                ps.setString(iIndex++,"%"+sType.toLowerCase()+"%");
            }

            if(sCode.length() > 0){
                ps.setString(iIndex++,"%"+sCode.toLowerCase()+"%");
            }

            if(sLanguage.length() > 0){
                ps.setString(iIndex++,"%"+sLanguage.toLowerCase()+"%");
            }

            if(sText.length() > 0){
                ps.setString(iIndex++,"%"+sText.toLowerCase()+"%");
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
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vLabels;
    }

    //--- GET EXTERNAL CONTACTS LABELS ------------------------------------------------------------
    public static Vector getExternalContactsLabels(String sType, String sText, String sLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sQuery = "SELECT * FROM OC_LABELS"+
                " WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+sType +
                "  AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" LIKE ?"+
                "  AND ("+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                "   OR "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                "   OR "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_VALUE")+" LIKE ?"+
                "  )";

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = conn.prepareStatement(sQuery);
            ps.setString(1,"%"+sLanguage.toLowerCase()+"%");
            ps.setString(2,"%"+sText.toLowerCase()+"%");
            ps.setString(3,"%"+sText.toLowerCase()+".%");
            ps.setString(4,"%"+sText.toLowerCase()+"%");
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
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vLabels;
    }

    //--- GET NON-SERVICE FUNCTION LABELS ---------------------------------------------------------
    public static Vector getNonServiceFunctionLabels(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSql = "SELECT * FROM OC_LABELS"+
                      " WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE")+
                      "  NOT IN ('service','function')";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSql);
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
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vLabels;
    }

    //--- UPDATE LABELTYPE BY TYPE ----------------------------------------------------------------
    public static void UpdateLabelTypeByType(String sOldType, String sNewType){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE OC_LABELS SET OC_LABEL_TYPE = ? WHERE OC_LABEL_TYPE = ?";
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = conn.prepareStatement(sUpdate);
            ps.setString(1,sNewType);
            ps.setString(2,sOldType);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- UPDATE NON-SERVICE FUNCTION LABELS ------------------------------------------------------
    public static void UpdateNonServiceFunctionLabels(String sNewLabelType, String sNewLabelId,
    		                                          String sNewLabelLanguage, String sOldLabelType){
        PreparedStatement ps = null;
        
        StringBuffer query = new StringBuffer();
        query.append("UPDATE OC_LABELS")
             .append(" SET OC_LABEL_TYPE = "+sNewLabelType+",")
             .append("     OC_LABEL_ID = "+sNewLabelId+",")
             .append("     OC_LABEL_LANGUAGE = "+sNewLabelLanguage)
             .append(" WHERE "+sOldLabelType+" NOT IN ('service','function')");

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = conn.prepareStatement(query.toString());
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- GET LABELTYPES --------------------------------------------------------------------------
    public static Vector getLabelTypes(){
        Vector vLabelTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSql = "SELECT DISTINCT OC_LABEL_TYPE FROM OC_LABELS ORDER BY 1";
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = conn.prepareStatement(sSql);
            rs = ps.executeQuery();

            while(rs.next()){
                vLabelTypes.addElement(ScreenHelper.checkString(rs.getString("OC_LABEL_TYPE")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vLabelTypes;
    }

    //--- FIND FUNCTION MANAGE TRANSLATIONSPAGE ---------------------------------------------------
    public static Vector findFunction_manageTranslationsPage(String findLabelType, String findLabelID, String findLabelLang,
    		                                                 String findLabelValue, boolean excludeFunctions, boolean excludeServices){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSql = "SELECT * FROM OC_LABELS WHERE ";

        if(findLabelType.length() > 0){
            sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" = '"+ScreenHelper.checkDbString(findLabelType).toLowerCase()+"' AND ";
        }

        if(findLabelID.length() > 0){
            sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" like '%"+ScreenHelper.checkDbString(findLabelID).toLowerCase()+"%' AND ";
        }

        if(findLabelLang.length() > 0){
            sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" = '"+ScreenHelper.checkDbString(findLabelLang).toLowerCase()+"' AND ";
        }

        if(findLabelValue.length() > 0){
            sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_VALUE")+" like '%"+ScreenHelper.checkDbString(findLabelValue).toLowerCase()+"%' AND ";
        }

        // exclusions on labeltype
        if(excludeFunctions) sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" <> 'function' AND ";
        if(excludeServices)  sSql+= MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" NOT IN ('service','externalservice') AND ";

        sSql = sSql.substring(0,sSql.length()-4); // remove last " AND"
        sSql+= "ORDER BY OC_LABEL_TYPE, OC_LABEL_ID, OC_LABEL_LANGUAGE";

        Vector vLabels = new Vector();

        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = conn.prepareStatement(sSql);
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
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vLabels;
    }

    //--- FIND FUNCTION SERVICELABELS -------------------------------------------------------------
    public static Vector findFunctionServiceLabels(String sLabelType, String sLabelLang, String sFindText){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vLabels = new Vector();

        String sSql = "SELECT OC_LABEL_VALUE, OC_LABEL_ID FROM OC_LABELS"+
                      " WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE")+" = ?"+
                      "  AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE")+" = ?"+
                      "  AND ("+MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID")+" LIKE ?"+
                      "   OR "+MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_VALUE")+" LIKE ?"+
                      "  )"+
                      " ORDER BY OC_LABEL_VALUE ASC";

        // functions never have special characters, so search them with normalised characters.
        if(sLabelType.equalsIgnoreCase("function")){
            sFindText = ScreenHelper.normalizeSpecialCharacters(sFindText);
        }
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sLabelType.toLowerCase());
            ps.setString(2,sLabelLang.toLowerCase());
            ps.setString(3,"%"+sFindText.toLowerCase()+"%");
            ps.setString(4,"%"+sFindText.toLowerCase()+"%");
            rs = ps.executeQuery();

            Label label;
            while(rs.next()){
                label = new Label();
                label.id = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                label.value = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));

                vLabels.addElement(label);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return vLabels;
    }
    
}