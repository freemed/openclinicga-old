package be.mxs.common.util.system;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.openclinic.adt.Encounter;
import be.openclinic.finance.Prestation;
import be.openclinic.system.Application;
import net.admin.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;
import java.io.File;
import java.sql.*;
import java.sql.Date;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class ScreenHelper {
    public static SimpleDateFormat hourFormat     = new SimpleDateFormat("HH:mm");
    public static SimpleDateFormat stdDateFormat  = new SimpleDateFormat("dd/MM/yyyy");
    public static SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    public static String ITEM_PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";

    //--- GET TODAY -------------------------------------------------------------------------------
    public static java.util.Date getToday(){
    	Calendar cal = Calendar.getInstance();
    	cal.setTime(new java.util.Date()); // now
    	cal.set(Calendar.HOUR,0);
    	cal.set(Calendar.MINUTE,0);
    	cal.set(Calendar.SECOND,0);
    	cal.set(Calendar.MILLISECOND,0);
    	
    	return cal.getTime(); // past midnight
    }
    
    //--- GET TOMORROW ----------------------------------------------------------------------------
    public static java.util.Date getTomorrow(){
    	Calendar cal = Calendar.getInstance();
    	cal.setTime(new java.util.Date()); // now
    	cal.set(Calendar.HOUR,0);
    	cal.set(Calendar.MINUTE,0);
    	cal.set(Calendar.SECOND,0);
    	cal.set(Calendar.MILLISECOND,0);
    	
    	cal.add(Calendar.DAY_OF_YEAR,1);
    	
    	return cal.getTime(); // next midnight
    }
    
    //--- LEFT ------------------------------------------------------------------------------------
    public static String left(String s,int n){
    	if(s==null){
    		return "";
    	}
    	else if(s.length()<=n){
    		return s;
    	}
    	else{
    		return s.substring(0,n-3)+"...";
    	}
    }
    
    //--- UPPERCASE FIRST LETTER ------------------------------------------------------------------
    public static String uppercaseFirstLetter(String sValue){
        String sFirstLetter;
        if(sValue.length() > 0){
            sFirstLetter = sValue.substring(0,1).toUpperCase();
            sValue = sFirstLetter+sValue.substring(1);
        }
        
        return sValue;        
    }
    
    //--- BOLD FIRST LETTER -----------------------------------------------------------------------
    // html
    public static String boldFirstLetter(String sValue){
        String sFirstLetter;
        if(sValue.length() > 0){
            sFirstLetter = sValue.substring(0,1).toUpperCase();
            sValue = "<b>"+sFirstLetter+"</b>"+sValue.substring(1);
        }
        
        return sValue;        
    }
    
    //--- COUNT MATCHES IN STRING -----------------------------------------------------------------
    public static int countMatchesInString(String sText, String sTarget){
        int count = 0;

        while(sText.indexOf(sTarget) > -1){
            sText = sText.substring(sText.indexOf(sTarget)+sTarget.length());
            count++;
        }

        return count;
    }
    
    //--- GET PRICE FORMAT ------------------------------------------------------------------------
    public static String getPriceFormat(double value){
    	DecimalFormatSymbols formatSymbols = new DecimalFormatSymbols();
    	formatSymbols.setGroupingSeparator(MedwanQuery.getInstance().getConfigString("decimalThousandsSeparator"," ").toCharArray()[0]);
    	return new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat"),formatSymbols).format(value);
    }

	//--- VECTOR TO STRING ------------------------------------------------------------------------
	public static String vectorToString(Vector vector, String sDelimeter){
	    return vectorToString(vector,sDelimeter,true);
	}
	
	public static String vectorToString(Vector vector, String sDelimeter, boolean addApostrophes){
		StringBuffer stringBuffer = new StringBuffer();
	    
	    for(int i=0; i<vector.size(); i++){
	    	if(addApostrophes) stringBuffer.append("'");
	        stringBuffer.append((String)vector.get(i));	        
	    	if(addApostrophes) stringBuffer.append("'");
	        
	        if(i<vector.size()){
	        	stringBuffer.append(sDelimeter);
	        }
	    }		    
	    
	    return stringBuffer.toString();
	}
    
    //--- CUSTOMER INCLUDE ------------------------------------------------------------------------
    public static String customerInclude(String fileName, String sAPPFULLDIR, String sAPPDIR){
        if(fileName.indexOf("?")>0){
            fileName=fileName.substring(0,fileName.indexOf("?"));
        }

        if(new File((sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")).exists()){
            Debug.println("Customer file "+(sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")+" found");
            return ("/"+sAPPDIR+"/"+fileName).replaceAll("//","/");
        }
        else{
            Debug.println("Customer file "+(sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")+" not found, using "+("/"+fileName).replaceAll("//","/"));
            return ("/"+fileName).replaceAll("//","/");
        }
    }

    //--- GET TRAN --------------------------------------------------------------------------------
    public static String getTran(String sType, String sID, String sLanguage) {
        return getTran(sType,sID,sLanguage,false);
    }

    public static String getTran(String sType, String sID, String sLanguage, boolean displaySimplePopup) {
        String labelValue = "";

        try{
            if(sLanguage==null || sLanguage.length() != 2){
                return sID;
            }

            if(sType.equalsIgnoreCase("service") || sType.equalsIgnoreCase("function")){
                labelValue = MedwanQuery.getInstance().getLabel(sType.toLowerCase(),sID.toLowerCase(),sLanguage);

                if(labelValue.length() == 0){
                    if(checkString(MedwanQuery.getInstance().getConfigString("showLinkNoTranslation")).equals("on")){
                        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";
                        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                    }
                    else{
                        return sID;
                    }
                }
                else{
                    return labelValue;
                }
            }
            else{
                Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
                if(langHashtable == null){
                    saveUnknownLabel(sType, sID, sLanguage);
                    return sID;
                }

                Hashtable typeHashtable = (Hashtable)langHashtable.get(sLanguage.toLowerCase());
                if(typeHashtable == null){
                    if(checkString(MedwanQuery.getInstance().getConfigString("showLinkNoTranslation")).equals("on")){
                        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";
                        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                    }
                    else{
                        return sID;
                    }
                }

                Hashtable idHashtable = (Hashtable)typeHashtable.get(sType.toLowerCase());
                if(idHashtable == null){
                    if(checkString(MedwanQuery.getInstance().getConfigString("showLinkNoTranslation")).equals("on")){
                        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";
                        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                    }
                    else{
                        return sID;
                    }
                }

                Label label = (Label)idHashtable.get(sID.toLowerCase());
                if(label == null){
                    if(checkString(MedwanQuery.getInstance().getConfigString("showLinkNoTranslation")).equals("on")){
                        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";
                        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                    }
                    else{
                        return sID;
                    }
                }

                labelValue = label.value;

                // display link to label
                if(labelValue==null || labelValue.trim().length()==0){
                    if(label.showLink==null || label.showLink.equals("1")){
                        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";
                        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return labelValue.replaceAll("##CR##","\n");
    }

    //--- GET TRAN WITH LINK ----------------------------------------------------------------------
    public static String getTranWithLink(String sType, String sID, String sLanguage) {
        return getTranWithLink(sType, sID, sLanguage, false);
    }

    public static String getTranWithLink(String sType, String sID, String sLanguage, boolean displaySimplePopup) {
        String labelValue = "";
        String url = "system/"+(displaySimplePopup?"manageTranslationsPopupSimple":"manageTranslationsPopup")+".jsp&EditOldLabelID="+sID+"&EditOldLabelType="+sType+"&EditOldLabelLang="+sLanguage+"&Action=Select";

        try{
            if(sLanguage.length() != 2) throw new Exception("Language must be a two-letter notation.");

            if(sType.equalsIgnoreCase("service") || sType.equalsIgnoreCase("function")){
                labelValue = MedwanQuery.getInstance().getLabel(sType.toLowerCase(),sID.toLowerCase(),sLanguage);

                if(labelValue.length() == 0){
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }
                else{
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+labelValue+"</a>";
                }
            }
            else{
                Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
                if(langHashtable == null){
                    saveUnknownLabel(sType, sID, sLanguage);
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }

                Hashtable typeHashtable = (Hashtable)langHashtable.get(sLanguage.toLowerCase());
                if(typeHashtable == null){
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }

                Hashtable idHashtable = (Hashtable)typeHashtable.get(sType.toLowerCase());
                if(idHashtable == null){
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }

                Label label = (Label)idHashtable.get(sID.toLowerCase());
                if(label == null){
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }

                labelValue = label.value;

                // display link to label
                if(labelValue==null || labelValue.trim().length()==0){
                    return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+sID+"</a>";
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return "<a href=\"#\" onClick=\"javascript:openPopup('"+url+"');\">"+labelValue+"</a>";
    }

    //--- GET TRAN DB -----------------------------------------------------------------------------
    public static String getTranDb(String sType, String sID, String sLang){
        String labelValue = "";
        if(sType!=null && sID!=null && sLang!=null){
	        PreparedStatement ps = null;
	        ResultSet rs = null;
	        
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	        try{
	            if(sLang.length() != 2) throw new Exception("Language must be a two-letter notation.");
	
	            // LOWER
	            String sSelect = "SELECT OC_LABEL_VALUE FROM OC_LABELS"+
	                             " WHERE OC_LABEL_TYPE=? AND OC_LABEL_ID=? AND OC_LABEL_LANGUAGE=?";
	            ps = oc_conn.prepareStatement(sSelect);
	            ps.setString(1,sType.toLowerCase());
	            ps.setString(2,sID.toLowerCase());
	            ps.setString(3,sLang.toLowerCase());
	
	            rs = ps.executeQuery();
	            if(rs.next()){
	                labelValue = checkString(rs.getString("OC_LABEL_VALUE"));
	            }
	            else{
	                labelValue = sID;
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
	            catch(SQLException se){
	                se.printStackTrace();
	            }
	        }
        }
        return labelValue.replaceAll("##CR##","\n");
    }

    //--- GET TRAN NO LINK ------------------------------------------------------------------------
    public static String getTranNoLink(String sType, String sID, String sLanguage) {    	
    	if(sID==null){
    		Debug.println("WARNING - getTranNoLink : sID is null for sType:"+sType+" and sLanguage:"+sLanguage);
    		return "";
    	}
    	
        String labelValue = "";
        if(sLanguage!=null && sLanguage.equalsIgnoreCase("f")){
        	sLanguage="fr";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("n")){
        	sLanguage="nl";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("e")){
        	sLanguage="en";
        }

        try{
            if(sLanguage!=null && sLanguage.length() == 2) {
	
	            if(sType.equalsIgnoreCase("service") || sType.equalsIgnoreCase("function")){
	                labelValue = MedwanQuery.getInstance().getLabel(sType.toLowerCase(),sID.toLowerCase(),sLanguage);
	            }
	            else{
	                Hashtable labels = MedwanQuery.getInstance().getLabels();
	                if(labels==null){
	                    saveUnknownLabel(sType,sID,sLanguage);
	                    return sID;
	                }
	                else{
	                    Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
	                    if(langHashtable == null){
	                        return sID;
	                    }
	
	                    Hashtable typeHashtable = (Hashtable)langHashtable.get(sLanguage.toLowerCase());
	                    if(typeHashtable == null){
	                        return sID;
	                    }
	
	                    Hashtable idHashtable = (Hashtable)typeHashtable.get(sType.toLowerCase());
	                    if(idHashtable == null){
	                        return sID;
	                    }
	
	                    Label label = (Label)idHashtable.get(sID.toLowerCase());
	                    if(label == null){
	                        return sID;
	                    }
	
	                    labelValue = label.value;
	
	                    // empty label : return id as labelValue
	                    if(labelValue==null || labelValue.trim().length()==0) {
	                        return sID;
	                    }
	                }
	            }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return labelValue.replaceAll("##CR##","\n");
    }

    //--- GET TRAN NO LINK ------------------------------------------------------------------------
    public static String getTranExists(String sType, String sID, String sLanguage) {
        String labelValue = "";
        if(sLanguage!=null && sLanguage.equalsIgnoreCase("f")){
        	sLanguage="fr";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("n")){
        	sLanguage="nl";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("e")){
        	sLanguage="en";
        }

        try{
            if(sLanguage!=null && sLanguage.length() == 2) {
	
	            if(sType.equalsIgnoreCase("service") || sType.equalsIgnoreCase("function")){
	                labelValue = MedwanQuery.getInstance().getLabel(sType.toLowerCase(),sID.toLowerCase(),sLanguage);
	                if(labelValue==sID){
	                	return "";
	                }
	            }
	            else{
	                Hashtable labels = MedwanQuery.getInstance().getLabels();
	                if(labels==null){
	                    saveUnknownLabel(sType,sID,sLanguage);
	                    return "";
	                }
	                else{
	                    Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
	                    if(langHashtable == null){
	                        return "";
	                    }
	
	                    Hashtable typeHashtable = (Hashtable)langHashtable.get(sLanguage.toLowerCase());
	                    if(typeHashtable == null){
	                        return "";
	                    }
	
	                    Hashtable idHashtable = (Hashtable)typeHashtable.get(sType.toLowerCase());
	                    if(idHashtable == null){
	                        return "";
	                    }
	
	                    Label label = (Label)idHashtable.get(sID.toLowerCase());
	                    if(label == null){
	                        return "";
	                    }
	
	                    labelValue = label.value;
	
	                    // empty label : return id as labelValue
	                    if(labelValue==null || labelValue.trim().length()==0) {
	                        return "";
	                    }
	                }
	            }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return labelValue.replaceAll("##CR##","\n");
    }

    //--- CONVERT HTML CODE TO CHAR ---------------------------------------------------------------
    public static String convertHtmlCodeToChar(String text){
        text = text.replaceAll("&eacute;","é");
        text = text.replaceAll("&egrave;","è");
        text = text.replaceAll("&euml;","ë");
        text = text.replaceAll("&ouml;","ö");
        text = text.replaceAll("&agrave;","à");
        text = text.replaceAll("&#231;","ç");
        text = text.replaceAll("&#156;","œ");
        text = text.replaceAll("<br>","\r\n");
        text = text.replaceAll("&gt;",">");
        text = text.replaceAll("&lt;","<");

        return text;
    }

    //--- NORMALIZE SPECIAL CHARACTERS ------------------------------------------------------------
    public static String normalizeSpecialCharacters(String sTest){
        sTest = sTest.replaceAll("'","");
        sTest = sTest.replaceAll("´",""); // difference !
        sTest = sTest.replaceAll(" ","");
        sTest = sTest.replaceAll("-","");

        sTest = sTest.replaceAll("é","e");
        sTest = sTest.replaceAll("è","e");
        sTest = sTest.replaceAll("ë","e");
        sTest = sTest.replaceAll("ê","e");
        sTest = sTest.replaceAll("ï","i");
        sTest = sTest.replaceAll("ö","o");
        sTest = sTest.replaceAll("ô","o");
        sTest = sTest.replaceAll("ä","a");
        sTest = sTest.replaceAll("á","a");
        sTest = sTest.replaceAll("à","a");
        sTest = sTest.replaceAll("â","a");

        return sTest;
    }

    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public static String getConfigString(String key, Connection conn){
        String cs = "";

        try{
            Statement st = conn.createStatement();
            ResultSet Configrs = st.executeQuery("SELECT oc_value FROM OC_Config WHERE oc_key like '"+key+"' AND deletetime IS NULL ORDER BY oc_key");
            while (Configrs.next()){
                cs+= Configrs.getString("oc_value");
            }
            Configrs.close();
            st.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return cs;
    }

    //--- GET CONFIG PARAM ------------------------------------------------------------------------
    public static String getConfigParam(String key, String param, Connection conn){
        return getConfigString(key,conn).replaceAll("<param>",param);
    }

    //--- GET CONFIG PARAM ------------------------------------------------------------------------
    public static String getConfigParam(String key, String[] params, Connection conn){
        String result = getConfigString(key,conn);

        for(int i=0; i<params.length; i++){
            result = result.replaceAll("<param"+(i+1)+">",params[i]);
        }

        return result;
    }

    //--- SET ROW ---------------------------------------------------------------------------------
    public static String setRow(String sType, String sID, String sValue, String sLanguage) {
        return "<tr><td class='admin'>"+getTran(sType,sID,sLanguage)+"</td><td class='admin2'>"+sValue+"</td></tr>";
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setMaliAdminPrivateContact(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        return(
            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
            setRow("Web","region",apc.sanitarydistrict,sLanguage)+
            setRow("Web","district",apc.district,sLanguage)+
            setRow("Web","community",apc.sector,sLanguage)+
            setRow("Web","sector",apc.quarter,sLanguage)+
            setRow("Web","address",apc.address,sLanguage)+
            setRow("Web","zipcode",apc.zipcode,sLanguage)+
            setRow("Web","country",sCountry,sLanguage)+
            setRow("Web","email",apc.email,sLanguage)+
            setRow("Web","telephone",apc.telephone,sLanguage)+
            setRow("Web","mobile",apc.mobile,sLanguage)+
            setRow("Web","function",apc.businessfunction,sLanguage)+
            setRow("Web","business",apc.business,sLanguage)+
            setRow("Web","comment",apc.comment,sLanguage)
        );
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setCameroonAdminPrivateContact(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        return(
            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
            setRow("Web","region",apc.sanitarydistrict,sLanguage)+
            setRow("Web","country.department",apc.district,sLanguage)+
            setRow("Web","arrondissement",apc.sector,sLanguage)+
            setRow("Web","sector",apc.quarter,sLanguage)+
            setRow("Web","address",apc.address,sLanguage)+
            setRow("Web","postcode",apc.zipcode,sLanguage)+
            setRow("Web","country",sCountry,sLanguage)+
            setRow("Web","email",apc.email,sLanguage)+
            setRow("Web","telephone",apc.telephone,sLanguage)+
            setRow("Web","mobile",apc.mobile,sLanguage)+
            setRow("Web","function",apc.businessfunction,sLanguage)+
            setRow("Web","business",apc.business,sLanguage)+
            setRow("Web","comment",apc.comment,sLanguage)
        );
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setOpenclinicAdminPrivateContact(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        return(
            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
            setRow("Web","region",apc.sanitarydistrict,sLanguage)+
            setRow("Web","province",apc.province,sLanguage)+
            setRow("Web","district",apc.district,sLanguage)+
            setRow("Web","community",apc.sector,sLanguage)+
            setRow("Web","sector",apc.quarter,sLanguage)+
            setRow("Web","address",apc.address,sLanguage)+
            setRow("Web","zipcode",apc.zipcode,sLanguage)+
            setRow("Web","country",sCountry,sLanguage)+
            setRow("Web","email",apc.email,sLanguage)+
            setRow("Web","telephone",apc.telephone,sLanguage)+
            setRow("Web","mobile",apc.mobile,sLanguage)+
            setRow("Web","function",apc.businessfunction,sLanguage)+
            setRow("Web","business",apc.business,sLanguage)+
            setRow("Web","comment",apc.comment,sLanguage)
        );
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setAdminPrivateContact(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        if(MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1){
	        return(
		            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
		            setRow("Web","country",sCountry,sLanguage)+
		            setRow("Web","district",apc.district,sLanguage)+
		            setRow("Web","zipcode",apc.zipcode,sLanguage)+
		            setRow("Web","province",sProvince,sLanguage)+
		            setRow("Web","city",apc.city,sLanguage)+
		            setRow("Web","email",apc.email,sLanguage)+
		            setRow("Web","telephone",apc.telephone,sLanguage)+
		            setRow("Web","mobile",apc.mobile,sLanguage)+
		            setRow("Web","comment",apc.comment,sLanguage)
	        );
        }
        else{
	        return(
	            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
	            setRow("Web","address",apc.address,sLanguage)+
	            setRow("Web","zipcode",apc.zipcode,sLanguage)+
	            setRow("Web","country",sCountry,sLanguage)+
	            setRow("Web","email",apc.email,sLanguage)+
	            setRow("Web","telephone",apc.telephone,sLanguage)+
	            setRow("Web","mobile",apc.mobile,sLanguage)+
	            setRow("Web","province",sProvince,sLanguage)+
	            setRow("Web","district",apc.district,sLanguage)+
	            setRow("Web","sector",apc.sector,sLanguage)+
	            setRow("Web","cell",apc.cell,sLanguage)+
	            setRow("Web","city",apc.city,sLanguage)+
	            setRow("Web","function",apc.businessfunction,sLanguage)+
	            setRow("Web","business",apc.business,sLanguage)+
	            setRow("Web","comment",apc.comment,sLanguage)
  	        );
        }
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setAdminPrivateContactBurundi(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        return(
            setRow("Web.admin","addresschangesince",apc.begin,sLanguage)+
            setRow("Web","address",apc.address,sLanguage)+
            setRow("Web","zipcode",apc.zipcode,sLanguage)+
            setRow("Web","country",sCountry,sLanguage)+
            setRow("Web","email",apc.email,sLanguage)+
            setRow("Web","telephone",apc.telephone,sLanguage)+
            setRow("Web","mobile",apc.mobile,sLanguage)+
            setRow("Web","province",apc.district,sLanguage)+
            setRow("Web","community",apc.sector,sLanguage)+
            setRow("Web","cell",apc.cell,sLanguage)+
            setRow("Web","city",apc.city,sLanguage)+
            setRow("Web","function",apc.businessfunction,sLanguage)+
            setRow("Web","business",apc.business,sLanguage)+
            setRow("Web","comment",apc.comment,sLanguage)
        );
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static String setAdminPrivateContactCDO(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if(checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if(checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sLanguage);
        }
        return(
            setRow("Web","address",apc.address,sLanguage)+
            setRow("Web","country",sCountry,sLanguage)+
            setRow("Web","telephone",apc.telephone,sLanguage)+
            setRow("Web","mobile",apc.mobile,sLanguage)+
            setRow("Web","province",apc.district,sLanguage)+
            setRow("Web","community",apc.sector,sLanguage)+
            setRow("Web","function",apc.businessfunction,sLanguage)+
            setRow("Web","business",apc.business,sLanguage)
        );
    }

    //--- WRITE LOOSE DATE FIELD YEAR -------------------------------------------------------------
    public static String writeLooseDateFieldYear(String sName, String sForm, String sValue, boolean allowPastDates, boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR) {
        String gfPopType = "1"; // default        
        if(allowPastDates && allowFutureDates){
            gfPopType = "1";
        }
        else{
          if(allowFutureDates){ gfPopType = "3"; }
          else if(allowPastDates) { gfPopType = "2"; }
        }

        // datefield that ALSO accepts just a year
        return "<input type='text' maxlength='10' class='text' id='"+sName+"' name='"+sName+"' value='"+sValue+"' size='12' onblur='if(!checkDateOnlyYearAllowed(this)){alert(\""+getTran("Web.Occup","date.error",sWebLanguage)+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick='gfPop"+gfPopType+".fPopCalendar(document."+sForm+"."+sName+");return false;'>"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick='getToday(document."+sForm+"."+sName+");'>";
    }

    //--- WRITE DATE FIELD ------------------------------------------------------------------------
    public static String writeDateField(String sName, String sForm, String sValue, boolean allowPastDates,
    		                            boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR){
    	return writeDateField(sName,sForm,sValue,allowPastDates,allowFutureDates,sWebLanguage,sCONTEXTDIR,"");    	
    }
    
    public static String writeDateField(String sName, String sForm, String sValue, boolean allowPastDates, 
    		                            boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR, String sExtraOnBlur){
        String gfPopType = "1"; // default        
        if(allowPastDates && allowFutureDates){
            gfPopType = "1";
        }
        else{
               if(allowFutureDates) gfPopType = "3";
          else if(allowPastDates) gfPopType = "2";
        }
        
        String sExtraCondition = "";
        if(!allowFutureDates){
        	sExtraCondition = " || isFutureDate(this.value)";
        }
        
        return "<input type='text' maxlength='10' class='text' id='"+sName+"' name='"+sName+"' value='"+sValue+"' size='12' onblur='if(!checkDate(this)"+sExtraCondition+"){dateError(this);}else{"+sExtraOnBlur+"}'>"
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick='alert(\"test\")'>"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick='getToday(document."+sForm+"."+sName+");'>";
    }

    //--- NEW WRITE DATE TIME FIELD ---------------------------------------------------------------
    public static String newWriteDateTimeField(String sName, java.util.Date dValue, String sWebLanguage, String sCONTEXTDIR){
        return "<input id='"+sName+"' type='text' maxlength='10' class='text' name='"+sName+"' value='"+getSQLDate(dValue)+"' size='12' onblur='if(!checkDate(this)){alert(\""+HTMLEntities.htmlentities(getTran("Web.Occup", "date.error", sWebLanguage))+"\");this.value=\"\";}'>"
               +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","Select",sWebLanguage))+"' onclick='gfPop1.fPopCalendar($(\""+sName+"\"));return false;'>"
               +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","putToday",sWebLanguage))+"' onclick=\"putTime($('"+sName+"Time'));getToday($('"+sName+"'));\">"
               +"&nbsp;"+writeTimeField(sName+"Time", formatSQLDate(dValue, "HH:mm"))
               +"&nbsp;"+getTran("web.occup", "medwan.common.hour", sWebLanguage);
    }
    
    //--- PLANNING DATE TIME FIELD ----------------------------------------------------------------
    public static String planningDateTimeField(String sName, String dValue, String sWebLanguage, String sCONTEXTDIR){
        return "<input id='"+sName+"' type='text' maxlength='10' class='text' name='"+sName+"' value='"+dValue+"' size='12' onblur='if(!checkDate(this)){alert(\""+HTMLEntities.htmlentities(getTran("Web.Occup", "date.error", sWebLanguage))+"\");this.value=\"\";}'>"
               +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","Select",sWebLanguage))+"' onclick='gfPop1.fPopCalendar($(\""+sName+"\"));return false;'>"
               +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","putToday",sWebLanguage))+"' onclick=\"getToday($('"+sName+"'));\">";
    }
    
    //--- WRITE DATEE FIELD WITHOUT TODAY ---------------------------------------------------------
    public static String writeDateFieldWithoutToday(String sName, String sForm, String sValue, boolean allowPastDates,
    		                                        boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR){
        String gfPopType = "1"; // default        
        if(allowPastDates && allowFutureDates){
            gfPopType = "1";
        }
        else{
               if(allowFutureDates) gfPopType = "3";
          else if(allowPastDates) gfPopType = "2";
        }

        return "<input type='text' maxlength='10' class='text' id='"+sName+"' name='"+sName+"' value='"+sValue+"' size='12' onblur='if(!checkDate(this)){alert(\""+HTMLEntities.htmlentities(getTran("Web.Occup","date.error",sWebLanguage))+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' style='vertical-align:-1px;' onclick='gfPop"+gfPopType+".fPopCalendar(document."+sForm+"."+sName+");return false;' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","Select",sWebLanguage))+"'></a>";
    }

    //--- CHECK PERMISSION ------------------------------------------------------------------------
    public static String checkPermission(String sScreen, String sPermission, User activeUser,
                                         boolean screenIsPopup, String sAPPFULLDIR) {
        sPermission = sPermission.toLowerCase();
        String jsAlert = "Error in checkPermission : no screen specified !";
        if(sScreen.trim().length()>0) {
            if(Application.isDisabled(sScreen)){
            	// empty
            }
            else if(activeUser!=null && activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0){
                jsAlert = "";
            }
            else{
                // screen and permission specified
                if(sPermission.length() > 0 && !sPermission.equals("all")){
                    if(sPermission.equals("none")) {
                    	jsAlert = "";
                    }
                    else if(activeUser.getAccessRight(sScreen+"."+sPermission)) {
                        jsAlert = "";
                    }
                }
                // no permission specified -> interprete as all permissions required
                // Managing a page, means you can add, edit and delete.
                else if(activeUser.getAccessRight(sScreen+".edit") &&
                         activeUser.getAccessRight(sScreen+".add") &&
                         //activeUser.getAccessRight(sScreen+".select") &&
                         activeUser.getAccessRight(sScreen+".delete")) {
                    jsAlert = "";
                }
                if(Debug.enabled) System.out.println("3"); 

                if(jsAlert.length() > 0){
                    String sMessage = getTranNoLink("web","nopermission",activeUser.person.language);
                    jsAlert = "<script>"+(screenIsPopup?"window.close();":"window.history.go(-1);")+
                              "var popupUrl = '"+sAPPFULLDIR+"/_common/search/okPopup.jsp?ts="+getTs()+"&labelValue="+sMessage;

                    // display permission when in Debug mode
                    if(Debug.enabled) jsAlert+= " --> "+sScreen+(sPermission.length()==0?"":"."+sPermission);

                    jsAlert+= "';"+
                              "  var modalities = 'dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;';"+
                              "   var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,\"\",modalities):window.confirm(\""+sMessage+"\");"+
                              "</script>";
                }
            }
        }

        return jsAlert;
    }

    //--- CHECK TRANSACTION PERMISSION ------------------------------------------------------------
    static public String checkTransactionPermission(TransactionVO transaction, User activeUser, boolean screenIsPopup, String sAPPFULLDIR) {
    	String jsAlert="";
    	if(checkString(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRIVATETRANSACTION")).equalsIgnoreCase("1")){
    		try{
	    		if(!(transaction.getUser().getUserId()+"").equalsIgnoreCase(activeUser.userid)){
	                String sMessage = getTranNoLink("web","privatetransactionerror",activeUser.person.language);
	                jsAlert = "<script>"+(screenIsPopup?"window.close();":"window.history.go(-1);")+
	                          "var popupUrl = '"+sAPPFULLDIR+"/_common/search/okPopup.jsp?ts="+getTs()+"&labelValue="+sMessage;
	
	                jsAlert+= "';"+
	                          "  var modalities = 'dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;';"+
	                          "   var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,\"\",modalities):window.confirm(\""+sMessage+"\");"+
	                          "</script>";
	            }
    		}
    		catch(Exception e){
    			e.printStackTrace();
    		}
        }

        return jsAlert;
    }
    
    //--- CHECK PERMISSION ------------------------------------------------------------------------
    public static String checkPrestationToday(String sPersonId, String sAPPFULLDIR, boolean screenIsPopup, User activeUser, TransactionVO transaction) {
        String jsAlert = "";
        String sMessage ="";
        String sEncounterUid="";
        Encounter encounter = Encounter.getActiveEncounter(sPersonId);
    	if(encounter!=null){
    		sEncounterUid=encounter.getUid();
    	}
    	
        if(sEncounterUid.length()>0 && sEncounterUid.split("\\.").length==2 && transaction.getTransactionId()<0 && MedwanQuery.getInstance().getConfigInt("activateOutpatientConsultationPrestationCheck",0)==1){
        	String sPrestationCode=MedwanQuery.getInstance().getConfigString(transaction.getTransactionType()+".requiredPrestation","");
        	if(checkString(sPrestationCode).length()>0){
    			Prestation prestation = Prestation.getByCode(sPrestationCode);
    			if(prestation.getUid()!=null && prestation.getUid().split("\\.").length==2){
	        		try{
		        		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		        		String sQuery="select * from oc_debets where oc_debet_date>=? and oc_debet_encounteruid=? and oc_debet_prestationuid=?";
		        		if(MedwanQuery.getInstance().getConfigInt(transaction.getTransactionType()+".requiredPrestation.invoiced",0)==1){
		        			sQuery="select * from oc_debets where oc_debet_date>=? and oc_debet_encounteruid=? and oc_debet_prestationuid=? and oc_debet_patientinvoiceuid like '%.%'";
		        		}
		        		PreparedStatement ps = conn.prepareStatement(sQuery);
		        		ps.setDate(1, new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())).getTime()));
		        		ps.setString(2, sEncounterUid);
		        		ps.setString(3, prestation.getUid());
		        		ResultSet rs = ps.executeQuery();
		        		if(!rs.next()){
		        			sMessage = getTranNoLink("web","noactiveprestation",activeUser.person.language)+" `"+prestation.getCode()+": "+prestation.getDescription()+"`";
		        		}
		        		rs.close();
		        		ps.close();
		        		conn.close();
	        		}
	        		catch(Exception e){
	        			e.printStackTrace();
	        		}
    			}
        	}
        	String sPrestationClass=MedwanQuery.getInstance().getConfigString(transaction.getTransactionType()+".requiredPrestationClass","");
            if(checkString(sPrestationClass).length()>0){
        		try{
	        		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	        		String sQuery="select * from oc_debets a, oc_prestations b where a.oc_debet_date>=? and a.oc_debet_encounteruid=? and b.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId","1")+".','') and b.oc_prestation_class=?";
	        		if(MedwanQuery.getInstance().getConfigInt(transaction.getTransactionType()+".requiredPrestationClass.invoiced",0)==1){
	        			sQuery="select * from oc_debets a, oc_prestations b where a.oc_debet_date>=? and a.oc_debet_encounteruid=? and a.oc_debet_patientinvoiceuid like '%.%' and b.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId","1")+".','') and b.oc_prestation_class=?";
	        		}
	        		PreparedStatement ps = conn.prepareStatement(sQuery);
	        		ps.setDate(1, new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())).getTime()));
	        		ps.setString(2, sEncounterUid);
	        		ps.setString(3, sPrestationClass);
	        		ResultSet rs = ps.executeQuery();
	        		if(!rs.next()){
	        			sMessage = getTranNoLink("web","noactiveprestationclass",activeUser.person.language)+" `"+getTran("prestation.class",sPrestationClass,activeUser.person.language)+"`";
	        		}
	        		rs.close();
	        		ps.close();
	        		conn.close();
        		}
        		catch(Exception e){
        			e.printStackTrace();
        		}
        	}
        	if(checkString(sMessage).length()>0){
	            jsAlert = "<script>"+(screenIsPopup?"window.close();":"window.history.go(-1);")+
	                      "var popupUrl = '"+sAPPFULLDIR+"/_common/search/okPopup.jsp?ts="+getTs()+"&labelValue="+sMessage;
	
	            jsAlert+= "';"+
	                      "  var modalities = 'dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;';"+
	                      "   var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,\"\",modalities):window.confirm(\""+sMessage+"\");"+
	                      "</script>";
        	}
        }

        return jsAlert;
    }

    //--- WRITE SEARCH BUTTON ---------------------------------------------------------------------
    public static String writeSearchButton(String sButtonName, String sLabelType, String sVarCode, String sVarText,
                                           String sShowID, String sWebLanguage, String sCONTEXTDIR) {
        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +"onclick='openPopup(\"_common/search/searchScreen.jsp&LabelType="+sLabelType+"&VarCode="+sVarCode+"&VarText="+sVarText+"&ShowID="+sShowID+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sVarCode+".value='';"+sVarText+".value='';\">";
    }

    public static String writeSearchButton(String sButtonName, String sLabelType, String sVarCode, String sVarText,
                                           String sShowID,String sWebLanguage, String defaultValue, String sCONTEXTDIR) {
        return  "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +" onclick='openPopup(\"_common/search/searchScreen.jsp&LabelType="+sLabelType+"&VarCode="+sVarCode+"&VarText="+sVarText+"&ShowID="+sShowID+"&DefaultValue="+defaultValue+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sVarCode+".value='';"+sVarText+".value='';\">";
    }

    //--- WRITE SERVICE BUTTON --------------------------------------------------------------------
    public static String writeServiceButton(String sButtonName, String sVarCode, String sVarText,String sWebLanguage, String sCONTEXTDIR) {
        return writeServiceButton(sButtonName,sVarCode,sVarText,false,sWebLanguage,sCONTEXTDIR);
    }

    public static String writeServiceButton(String sButtonName, String sVarCode, String sVarText,
                                            boolean onlySelectContractWithDivision, String sWebLanguage, String sCONTEXTDIR) {
        return  "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +"onclick='openPopup(\"_common/search/searchService.jsp&VarCode="+sVarCode+"&VarText="+sVarText+"&onlySelectContractWithDivision="+onlySelectContractWithDivision+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\"document.getElementsByName('"+sVarCode+"')[0].value='';document.getElementsByName('"+sVarText+"')[0].value='';\">";
    }

    //--- WRITE SELECT (SORTED) -------------------------------------------------------------------
    public static String writeSelect(String sLabelType, String sSelected,String sWebLanguage) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,false,true);
    }

    public static String writeSelect(String sLabelType, String sSelected,String sWebLanguage, boolean showLabelID) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,showLabelID,true);
    }

    //--- WRITE SELECT UNSORTED -------------------------------------------------------------------
    public static String writeSelectUnsorted(String sLabelType, String sSelected, String sWebLanguage) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,false,false);
    }

    //--- WRITE SELECT ----------------------------------------------------------------------------
    public static String writeSelect(String sLabelType, String sSelected, String sWebLanguage, boolean showLabelID, boolean sorted){
        String sOptions = "";
        Label label;
        Iterator it;

        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        if(labelTypes!=null) {
            Hashtable labelIds = (Hashtable)labelTypes.get(sLabelType.toLowerCase());

            if(labelIds!=null) {
                Enumeration idsEnum = labelIds.elements();
                Hashtable hSelected = new Hashtable();

                if(sorted){
                    // sorted on value
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.value,label.id);
                    }
                }
                else{
                    // sorted on id
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.id,label.value);
                    }
                }

                // sort on keys :
                //  when sorted (on value), key = labelValue
                //  when !sorted (sorted on id), key = labelID
                Vector keys = new Vector(hSelected.keySet());
                Collections.sort(keys);
                it = keys.iterator();

                // to html
                String sLabelValue, sLabelID;
                while (it.hasNext()) {
                    if(sorted){
                        sLabelValue = (String)it.next();
                        sLabelID = (String)hSelected.get(sLabelValue);
                    }
                    else{
                        sLabelID = (String)it.next();
                        sLabelValue = (String)hSelected.get(sLabelID);
                    }

                    sOptions+= "<option value='"+sLabelID+"'";
                    if(sLabelID.toLowerCase().equals(sSelected.toLowerCase())) {
                        sOptions+= " selected";
                    }

                    if(showLabelID){
                        sOptions+= ">"+sLabelValue+" ("+sLabelID+")</option>";
                    }
                    else{
                        sOptions+= ">"+sLabelValue+"</option>";
                    }
                }
            }
        }

        return sOptions;
    }

    //--- WRITE SELECT ----------------------------------------------------------------------------
    public static String writeSelectUpperCase(String sLabelType, String sSelected, String sWebLanguage, boolean showLabelID, boolean sorted){
        String sOptions = "";
        Label label;
        Iterator it;

        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        if(labelTypes!=null) {
            Hashtable labelIds = (Hashtable)labelTypes.get(sLabelType.toLowerCase());

            if(labelIds!=null) {
                Enumeration idsEnum = labelIds.elements();
                Hashtable hSelected = new Hashtable();

                if(sorted){
                    // sorted on value
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.value.toUpperCase(),label.id);
                    }
                }
                else{
                    // sorted on id
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.id,label.value.toUpperCase());
                    }
                }

                // sort on keys :
                //  when sorted (on value), key = labelValue
                //  when !sorted (sorted on id), key = labelID
                Vector keys = new Vector(hSelected.keySet());
                Collections.sort(keys);
                it = keys.iterator();

                // to html
                String sLabelValue, sLabelID;
                while (it.hasNext()) {
                    if(sorted){
                        sLabelValue = (String)it.next();
                        sLabelID = (String)hSelected.get(sLabelValue);
                    }
                    else{
                        sLabelID = (String)it.next();
                        sLabelValue = (String)hSelected.get(sLabelID);
                    }

                    sOptions+= "<option value='"+sLabelID+"'";
                    if(sLabelID.toLowerCase().equals(sSelected.toLowerCase())) {
                        sOptions+= " selected";
                    }

                    if(showLabelID){
                        sOptions+= ">"+sLabelID+" - "+sLabelValue+"</option>";
                    }
                    else{
                        sOptions+= ">"+sLabelValue+"</option>";
                    }
                }
            }
        }

        return sOptions;
    }

    public static String writeSelectExclude(String sLabelType, String sSelected, String sWebLanguage, boolean showLabelID, boolean sorted, String sExclude){
        String sOptions = "";
        Label label;
        Iterator it;

        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        if(labelTypes!=null) {
            Hashtable labelIds = (Hashtable)labelTypes.get(sLabelType.toLowerCase());

            if(labelIds!=null) {
                Enumeration idsEnum = labelIds.elements();
                Hashtable hSelected = new Hashtable();

                if(sorted){
                    // sorted on value
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.value,label.id);
                    }
                }
                else{
                    // sorted on id
                    while (idsEnum.hasMoreElements()) {
                        label = (Label)idsEnum.nextElement();
                        hSelected.put(label.id,label.value);
                    }
                }

                // sort on keys :
                //  when sorted (on value), key = labelValue
                //  when !sorted (sorted on id), key = labelID
                Vector keys = new Vector(hSelected.keySet());
                Collections.sort(keys);
                it = keys.iterator();

                // to html
                String sLabelValue, sLabelID;
                while (it.hasNext()) {
                    if(sorted){
                        sLabelValue = (String)it.next();
                        sLabelID = (String)hSelected.get(sLabelValue);
                    }
                    else{
                        sLabelID = (String)it.next();
                        sLabelValue = (String)hSelected.get(sLabelID);
                    }
                    if(sExclude.indexOf(sLabelID)<0){

                        sOptions+= "<option value='"+sLabelID+"'";
                        if(sLabelID.toLowerCase().equals(sSelected.toLowerCase())) {
                            sOptions+= " selected";
                        }

                        if(showLabelID){
                            sOptions+= ">"+sLabelID+" - "+sLabelValue+"</option>";
                        }
                        else{
                            sOptions+= ">"+sLabelValue+"</option>";
                        }
                    }
                }
            }
        }

        return sOptions;
    }

    //--- WRITE ZIPCODE BUTTON --------------------------------------------------------------------
    public static String writeZipcodeButton(String sButtonName, String sZipcode, String sCity, String sWebLanguage, String sCONTEXTDIR) {
        String sSearch = sZipcode+".value";

        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"' "
              +"onclick='openPopup(\"_common/search/searchZipcode.jsp&VarCode="+sZipcode+"&VarText="+sCity+"&FindText=\"+"+sSearch+");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sZipcode+".value='';"+sCity+".value='';\">";
    }

    public static String writeZipcodeButton(String sButtonName, String sZipcode, String sCity, String sWebLanguage, String sDisplayLang, String sCONTEXTDIR) {
        String sSearch = sZipcode+".value";

        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"' "
              +"onclick='openPopup(\"_common/search/searchZipcode.jsp&VarCode="+sZipcode+"&VarText="+sCity+"&FindText=\"+"+sSearch+"+\"&DisplayLang="+sDisplayLang+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sZipcode+".value='';"+sCity+".value='';\">";
    }

    //--- SAVE UNKNOWN LABEL ----------------------------------------------------------------------
    public static void saveUnknownLabel(String sLabelType, String sLabelID, String sLabelLang) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_LABEL_TYPE FROM OC_UNKNOWNLABELS"+
                             " WHERE OC_LABEL_TYPE = ? AND OC_LABEL_ID = ? AND OC_LABEL_LANGUAGE = ?"+
                             "  AND OC_LABEL_UPDATEUSERID IS NULL";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sLabelType.toLowerCase());
            ps.setString(2,sLabelID.toLowerCase());
            ps.setString(3,sLabelLang.toLowerCase());
            rs = ps.executeQuery();

            boolean bFound = false;
            if(rs.next()) bFound = true;
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();

            if(!bFound) {
                sSelect = "INSERT INTO OC_UNKNOWNLABELS (OC_LABEL_TYPE, OC_LABEL_ID, OC_LABEL_LANGUAGE,"+
                          "  OC_LABEL_VALUE, OC_LABEL_UNKNOWNDATETIME)"+
                          " VALUES (?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sLabelType.toLowerCase());
                ps.setString(2,sLabelID.toLowerCase());
                ps.setString(3,sLabelLang.toLowerCase());
                ps.setTimestamp(4,getSQLTime()); // NOW

                ps.execute();
                if(ps!=null) ps.close();
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
    }

    //--- CHECK STRING ----------------------------------------------------------------------------
    public static String checkString(String sString) {
        // om geen 'null' weer te geven
        if((sString==null)||(sString.toLowerCase().equals("null"))) {
            return "";
        }
        else{
            sString = sString.trim();
        }
        return sString;
    }

    //--- GET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    public static AdminPrivateContact getActivePrivate(AdminPerson person) {
        AdminPrivateContact apcActive = null;
        AdminPrivateContact apc;

        for (int i=0; i<person.privateContacts.size(); i++) {
            apc = ((AdminPrivateContact)(person.privateContacts.elementAt(i)));
            if(apc.end==null || apc.end.trim().equals("")) {
                try {
                    if(apcActive==null || stdDateFormat.parse(apc.begin).after(stdDateFormat.parse(apcActive.begin))){
                        apcActive=apc;
                    }
                }
                catch (ParseException e) {
                    // nothing
                }
            }
        }

        return apcActive;
    }

    //--- REPLACE ---------------------------------------------------------------------------------
    public static String replace(String sValue, String sSearch, String sReplace) {
        String sResult = "", sLeft = sValue;

        int iIndex = sLeft.indexOf(sSearch);
        if(iIndex > -1) {
            while (iIndex > -1) {
                sResult += sLeft.substring(0,iIndex)+sReplace;
                sLeft = sLeft.substring(iIndex+1,sLeft.length());
                iIndex = sLeft.indexOf(sSearch);
            }
            sResult += sLeft;
        }
        else{
            sResult = sValue;
        }

        return sResult;
    }

    //--- GET TS ----------------------------------------------------------------------------------
    public static String getTs() {
        return new java.util.Date().hashCode()+"";
    }

    //--- GET DATE --------------------------------------------------------------------------------
    public static String getDate() {
        return stdDateFormat.format(new java.util.Date());
    }

    //--- FORMAT DATE -----------------------------------------------------------------------------
    public static String formatDate(java.util.Date dDate) {
        String sDate = "";
        if(dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET DATE --------------------------------------------------------------------------------
    public static java.util.Date getDate(java.util.Date date) throws Exception{
        return stdDateFormat.parse(stdDateFormat.format(date));
    }

    //--- WRITE TABLE FOOTER ----------------------------------------------------------------------
    public static String writeTblFooter() {
        return "</table></td></tr></td></tr></table>";
    }

    //--- WRITE TABLE HEADER ----------------------------------------------------------------------
    public static String writeTblHeader(String sHeader, String sCONTEXTDIR) {
        return "<table border='0' cellspacing='0' cellpadding='0' class='menu' width='100%'>"+
               "<tr class='admin'><td width='100%'>&nbsp;&nbsp;"+sHeader+"&nbsp;&nbsp;</td></tr>"+
               "<tr><td><img src='"+sCONTEXTDIR+"/_img/pix_bl.gif' alt='' width='100' height='1' border='0'></td></tr>"+
               "<tr><td><table width='100%' cellspacing='0'>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    public static String writeTblChild(String sPath, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <button class='buttoninvisible' accesskey='"+getAccessKey(sHeader)+"' onclick='window.location.href=\""+sCONTEXTDIR+"/"+sPath+"\"'></button><a href='"+sCONTEXTDIR+"/"+sPath+"' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    public static String writeTblChildNoButton(String sPath, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <a href='"+sCONTEXTDIR+"/"+sPath+"' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    public static String writeTblChildWithCode(String sCommand, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <button class='buttoninvisible' accesskey='"+getAccessKey(sHeader)+"' onclick='"+sCommand+"'></button><a href='"+sCommand+"' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    public static String writeTblChildWithCodeNoButton(String sCommand, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <a href='"+sCommand+"' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- GET ACCESS KEY --------------------------------------------------------------------------
    public static String getAccessKey(String label){
        label=label.toLowerCase();
        if(label.indexOf("<u>")>-1 && label.indexOf("</u>")>-1){
            return label.substring(label.indexOf("<u>")+3,label.indexOf("</u>"));
        }
        return "";
    }

    //--- SET RIGHT CLICK -------------------------------------------------------------------------
    public static String setRightClick(String itemType){
        return "onclick='this.className=\"selected\"' "+
               "onchange='this.className=\"selected\";setPopup(\"be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"\",this.value)' "+
               "onkeyup='this.className=\"selected\";setPopup(\"be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"\",this.value)' "+
               "onmouseover=\"this.style.cursor='help';setPopup('be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"',this.value);activeItem=true;setItemsMenu(true);\" "+
               "onmouseout=\"this.style.cursor='default';activeItem=false;\" ";
    }

    //--- SET RIGHT CLICK MINI --------------------------------------------------------------------
    public static String setRightClickMini(String itemType){
        return "onmouseover=\"this.style.cursor='help';setPopup('be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"',this.value);activeItem=true;setItemsMenu(true);\" "+
               "onmouseout=\"this.style.cursor='default';activeItem=false;document.oncontextmenu=function(){return true};\" ";
    }

    //--- GET DEFAULTS ----------------------------------------------------------------------------
    public static String getDefaults(HttpServletRequest request) throws SessionContainerFactoryException {
        // defaults
        String defaults = ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemDefaultsHTML();
        defaults += "<script>function loadDefaults(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if(document.getElementsByName('DefaultValue_'+document.all[n].name)[0]!=null) {"
                    +"if(document.all[n].type=='text') {document.all[n].value=document.getElementsByName('DefaultValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='textarea') {document.all[n].value=document.getElementsByName('DefaultValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='radio' && document.all[n].value==document.getElementsByName('DefaultValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='checkbox' && document.all[n].value==document.getElementsByName('DefaultValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if(document.all[n].options[m].value==document.getElementsByName('DefaultValue_'+document.all[n].name)[0].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        // previous
        defaults += ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemPreviousHTML();
        defaults += "<script>function loadPrevious(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if(document.getElementsByName('PreviousValue_'+document.all[n].name]!=null) {"
                    +"if(document.all[n].type=='text') {document.all[n].value=document.getElementsByName('PreviousValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='textarea') {document.all[n].value=document.getElementsByName('PreviousValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='radio' && document.all[n].value==document.getElementsByName('PreviousValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='checkbox' && document.all[n].value==document.getElementsByName('PreviousValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if(document.all[n].options[m].value==document.getElementsByName('PreviousValue_'+document.all[n].name)[0].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        // previous context
        defaults += ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemPreviousContextHTML();
        defaults += "<script>function loadPreviousContext(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if(document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0]!=null) {"
                    +"if(document.all[n].type=='text') {document.all[n].value=document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='textarea') {document.all[n].value=document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0].value;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='radio' && document.all[n].value==document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='checkbox' && document.all[n].value==document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if(document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if(document.all[n].options[m].value==document.getElementsByName('PreviousContextValue_'+document.all[n].name)[0].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        return defaults;
    }

    //--- FORMAT SQL DATE -------------------------------------------------------------------------
    public static String formatSQLDate(Date dDate, String sFormat) {
        String sDate = "";
        if(dDate!=null) {
            sDate = new SimpleDateFormat(sFormat).format(dDate);
        }
        return sDate;
    }

    public static String formatSQLDate(java.util.Date dDate, String sFormat) {
        String sDate = "";
        if(dDate!=null) {
            sDate = new SimpleDateFormat(sFormat).format(dDate);
        }
        return sDate;
    }

    //--- GET SQL STRING --------------------------------------------------------------------------
    public static String setSQLString(String sValue) {
        if(sValue!=null && sValue.trim().length()>249) {
            sValue = sValue.substring(0,249);
        }
        return sValue;
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    public static String getSQLTime(Time tTime) {
        String sTime = "";
        if(tTime!=null) {
            sTime = tTime.toString();
            sTime = sTime.substring(0,sTime.lastIndexOf(":"));
        }
        return sTime;
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    public static java.sql.Timestamp getSQLTime() {
        return new java.sql.Timestamp(new java.util.Date().getTime()); // now
    }

    //--- GET SQL TIME STAMP ----------------------------------------------------------------------
    public static String getSQLTimeStamp(java.sql.Timestamp timeStamp) {
        String ts = "";
        if(timeStamp != null) {
            ts = fullDateFormat.format(new Date(timeStamp.getTime()));
        }
        return ts;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    public static String getSQLDate(java.sql.Date dDate) {
        String sDate = "";
        if(dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    public static String getSQLDate(java.util.Date dDate) {
        String sDate = "";
        if(dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    public static java.sql.Date getSQLDate(String sDate) {
        try {
            if(sDate==null || sDate.trim().length()==0 || sDate.trim().length()<5 || sDate.equals("&nbsp;")) {
                return null;
            }
            else{
                sDate=sDate.replaceAll("-","/");
                return new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDate).getTime());
            }
        }
        catch(Exception e) {
            return null;
        }
    }

    //--- GET DATE ADD ----------------------------------------------------------------------------
    public static String getDateAdd(String sDate, String sAdd) {
        try {
            if(sDate==null || sDate.trim().length()==0 || sDate.trim().length()<5 || sDate.equals("&nbsp;")) {
                return null;
            }
            else{
                sDate=sDate.replaceAll("-","/");
                java.util.Date d=new SimpleDateFormat("dd/MM/yyyy").parse(sDate);
                return new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(d.getTime()+Long.parseLong(sAdd)*24*60*60000));
            }
        }
        catch(Exception e) {
            return null;
        }
    }

    //--- WRITE JS BUTTONS ------------------------------------------------------------------------
    public static String writeJSButtons(String sMyForm, String sMyButton, String sCONTEXTDIR) {
        return "<script>var myForm = document.getElementById('"+sMyForm+"'); var myButton = document.getElementById('"+sMyButton+"');</script>"+
               "<script src='"+sCONTEXTDIR+"/_common/_script/buttons.js'></script>";
    }

    public static void closeQuietly(Connection connection, Statement statement, ResultSet resultSet) {
        if(resultSet != null) try { resultSet.close(); } catch (SQLException logOrIgnore) {logOrIgnore.printStackTrace();}
        if(statement != null) try { statement.close(); } catch (SQLException logOrIgnore) {logOrIgnore.printStackTrace();}
        if(connection != null) try { connection.close(); } catch (SQLException logOrIgnore) {logOrIgnore.printStackTrace();}
    }
    
    //--- SET INCLUDE PAGE ------------------------------------------------------------------------
    public static void setIncludePage(String sPage, PageContext pageContext) {
        // ? or &
        if(sPage.indexOf("?")<0){
            if(sPage.indexOf("&")>-1){
                sPage=sPage.substring(0,sPage.indexOf("&"))+"?"+sPage.substring(sPage.indexOf("&")+1);
                if(sPage.indexOf("ts=")<0){
                    sPage+= "&ts="+new java.util.Date().getTime();
                }
            }
            else{
                sPage+= "?ts="+new java.util.Date().getTime();
            }

        }
        else if(sPage.indexOf("ts=")<0){
            sPage+= "&ts="+new java.util.Date().getTime();
        }
        try {
            pageContext.include(sPage);
        }
        catch(Exception e) {
            e.printStackTrace();
        }
    }

    //--- WRITE TIME FIELD ------------------------------------------------------------------------
    public static String writeTimeField(String sName, String sValue){
        return "<input id='"+sName+"' type='text' class='text' name='"+sName+"' value='"+sValue+"' onblur='checkTime(this)' size='5'>";
    }

    //--- GET SQL TIME STAMP ----------------------------------------------------------------------
    public static void getSQLTimestamp(PreparedStatement ps, int iIndex, String sDate, String sTime) {
        try{
            if(sDate == null || sDate.trim().length()==0) {
                ps.setNull(iIndex,Types.TIMESTAMP);
            }
            else{
                if(sTime == null || sTime.trim().length()==0){
                    ps.setDate(iIndex,getSQLDate(sDate));
                }
                else{
                    ps.setTimestamp(iIndex,new Timestamp(fullDateFormat.parse(sDate+" "+sTime).getTime()));
                }
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
        catch (ParseException e) {
            e.printStackTrace();
        }
    }

    public static void getSQLTimestamp(PreparedStatement ps, int iIndex, java.util.Date date) {
        try{
            if(date == null) {
                ps.setNull(iIndex,Types.TIMESTAMP);
            }
            else{
                ps.setTimestamp(iIndex,new Timestamp(date.getTime()));
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
    }

    //--- GET COOKIE ------------------------------------------------------------------------------
    public static String getCookie(String cookiename, HttpServletRequest request) {
        Cookie cookies[] = request.getCookies();

        if(cookies!=null){
        	for(int i=0; i<cookies.length; i++){
        		if(cookies[i].getName().equals(cookiename)){
        			return cookies[i].getValue();
        		}
        	}
        }

        return null;
    }

    //--- SET COOKIE ------------------------------------------------------------------------------
    public static void setCookie(String cookiename, String value, HttpServletResponse response) {
        Cookie cookie = new Cookie(cookiename,value);
        cookie.setMaxAge(365);
        response.addCookie(cookie);
    }

    //--- CHECK DB STRING -------------------------------------------------------------------------
    public static String checkDbString(String sString) {
        sString=checkString(sString);
        if(sString.trim().length()>0) {
            sString = sString.replaceAll("'","´");
        }
        return sString;
    }

/////////////////////////////////////////////////////////////////////////////////////////////
    public static String alignButtonsStart() {
      return "<p align='center'>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    public static String alignButtonsStop() {
      return "</p>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    public static String setFormButtonsStart(){
        return "<tr>" +
                    "<td class='admin'/>" +
                    "<td class='admin2'>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    public static String setFormButtonsStop(){
        return      "</td>" +
                "</tr>";
    }
////////////////////////////////////////////////////////////////////////////////////////////
    public static String setSearchFormButtonsStart(){
        return "<tr><td/><td>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    public static String setSearchFormButtonsStop(){
        return "</td></tr>";
    }
    
    public static String getFullPersonName(String personId){
    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
    	String s=getFullPersonName(personId,conn);
    	ScreenHelper.closeQuietly(conn, null, null);
    	return s;
    }
////////////////////////////////////////////////////////////////////////////////////////////
    public static String getFullPersonName(String personId,Connection dbConnection){
        String sReturn = "";

        if(checkString(personId).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = "SELECT lastname, firstname FROM Admin WHERE personid = ?";

            try{
                ps = dbConnection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(personId));
                rs = ps.executeQuery();

                if(rs.next()){
                    sReturn = checkString(rs.getString("lastname"))+" "+checkString(rs.getString("firstname"));
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null)rs.close();
                    if(ps!=null)ps.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        return sReturn;
    }
    
    public static String getPrestationGroupOptions(){
    	StringBuffer s=new StringBuffer();
		String sSql="select * from oc_prestation_groups order by oc_group_description";
		Connection oc_conn=null;
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
			ps=oc_conn.prepareStatement(sSql);
			rs = ps.executeQuery();
			while(rs.next()){
				s.append("<option value='"+rs.getInt("oc_group_serverid")+"."+rs.getInt("oc_group_objectid")+"'>"+rs.getString("oc_group_description")+"</option>");
			}
		}
		catch (Exception e){
			e.printStackTrace();
		}
		closeQuietly(oc_conn, ps, rs);
		return s.toString();
    }
    
    //--- GET FULL USER NAME (1) ------------------------------------------------------------------
    // no connection specified 
    public static String getFullUserName(String userId){
    	String sName = "";
    	
    	try{
	    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	        sName = getFullUserName(userId,conn);
	    	closeQuietly(conn,null,null);
    	}
    	catch(Exception e){
    		Debug.printStackTrace(e);
    	}
    	
        return sName;
    }

    //--- GET FULL USER NAME (2) ------------------------------------------------------------------
    // connection specified 
    public static String getFullUserName(String userId, Connection conn){
        String fullName = "";
        
        if(userId!=null && userId.length()>0){
        	PreparedStatement ps = null;
	        ResultSet rs = null;
	
	        String sSelect = "SELECT lastname,firstname FROM Users u, Admin a"+
	                         " WHERE u.userid = ?"+
	                         "  AND u.personid = a.personid";
	
	        try{
	            ps = conn.prepareStatement(sSelect);
	            ps.setInt(1,Integer.parseInt(userId));
	            rs = ps.executeQuery();
	
	            if(rs.next()){
	                fullName = checkString(rs.getString("lastname"))+" "+checkString(rs.getString("firstname"));
	            }
	        }
	        catch(Exception e){
	            e.printStackTrace();
	        }
	        finally{
	            try{
	                if(rs!=null) rs.close();
	                if(ps!=null) ps.close();
	            }
	            catch(Exception e){
	                e.printStackTrace();
	            }
	        }
        }
        
        return fullName;
    }

    //--- GET ACTIVE DIVISION ---------------------------------------------------------------------
    public static Service getActiveDivision(AdminPerson patient){
        return getActiveDivision(patient.personid);
    }

    public static Service getActiveDivision(String personId){
        Service patientDivision = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT b.OC_ENCOUNTER_SERVICEUID FROM OC_ENCOUNTERS a,OC_ENCOUNTER_SERVICES b"+
                    " WHERE " +
                    " a.OC_ENCOUNTER_PATIENTUID = ? AND" +
                    " a.OC_ENCOUNTER_SERVERID=b.OC_ENCOUNTER_SERVERID AND" +
                    " a.OC_ENCOUNTER_OBJECTID=b.OC_ENCOUNTER_OBJECTID AND"+
                    " a.OC_ENCOUNTER_ENDDATE IS NULL AND" +
                    " b.OC_ENCOUNTER_SERVICEENDDATE IS NULL";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,personId);

            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                patientDivision = Service.getService(rs.getString("OC_ENCOUNTER_SERVICEUID"));
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
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return patientDivision;
    }

    //--- IS PATIENT HOSPITALIZED -----------------------------------------------------------------
    public static boolean isPatientHospitalized(AdminPerson patient){
        Service activeDivision = getActiveDivision(patient);
        return (activeDivision!=null);
    }

    public static boolean isPatientHospitalized(String personId){
        Service activeDivision = getActiveDivision(personId);
        return (activeDivision!=null);
    }

    //--- TOKENIZE VECTOR -------------------------------------------------------------------------
    public static String tokenizeVector(Vector vector, String token, String aanhalingsteken){
        String values = "";

        // run thru vector
        for(int i=0; i<vector.size(); i++){
            values+= aanhalingsteken+vector.get(i)+aanhalingsteken+token;
        }

        // remove last token if any
        if(values.endsWith(token)){
            values = values.substring(0,values.length()-token.length());
        }

        if(values.length()==0) values = aanhalingsteken+aanhalingsteken;

        return values;
    }

    //--- CONTAINS LOWERCASE ----------------------------------------------------------------------
    public static boolean containsLowercase(String text){
        for(int i=0; i<text.length(); i++){
            if(Character.isLowerCase(text.charAt(i))){
                return true;
            }
        }
        return false;
    }

    //--- CONTAINS UPPERCASE ----------------------------------------------------------------------
    public static boolean containsUppercase(String text){
        for(int i=0; i<text.length(); i++){
            if(Character.isUpperCase(text.charAt(i))){
                return true;
            }
        }

        return false;
    }

    //--- CONTAINS LETTER -------------------------------------------------------------------------
    public static boolean containsLetter(String text){
        if(containsLowercase(text) || containsUppercase(text)){
            return true;
        }

        return false;
    }

    //--- CONTAINS NUMBER -------------------------------------------------------------------------
    public static boolean containsNumber(String text){
        for(int i=0; i<text.length(); i++){
            if(Character.isDigit(text.charAt(i))){
                return true;
            }
        }

        return false;
    }
    
    //--- CONTAINS ALFANUMERICS -------------------------------------------------------------------
    public static boolean containsAlfanumerics(String text){
        for(int i=0; i<text.length(); i++){
            if(!Character.isDigit(text.charAt(i)) && !Character.isLetter(text.charAt(i))){
                return true;
            }
        }

        return false;
    }
    
    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public static String getConfigString(String key) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        String s= getConfigStringDB(key, co_conn);
        try {
			co_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
        return s;
    }

    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public static String getConfigString(String key, String defaultValue) {
        return MedwanQuery.getInstance().getConfigString(key, defaultValue);
    }

    //--- GET CONFIG STRING DB --------------------------------------------------------------------
    public static String getConfigStringDB(String key, Connection ConfigdbConnection) {
        String cs = "";
        Statement st = null;
        ResultSet rs = null;

        try {
            st = ConfigdbConnection.createStatement();
            String sQuery = "SELECT oc_value FROM OC_Config" +
                            " WHERE oc_key LIKE '"+key+"' AND deletetime IS NULL ORDER BY oc_key";
            rs = st.executeQuery(sQuery);
            while(rs.next()){
                cs+= rs.getString("oc_value");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(st!=null) st.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return checkString(cs);
    }

    //--- GET CONFIG PARAM ------------------------------------------------------------------------
    public static String getConfigParam(String key, String param) {
        return getConfigParamDB(key, param);
    }

    public static String getConfigParam(String key, String[] params){
        return getConfigParamDB(key, params);
    }

    //--- GET CONFIG PARAM DB ---------------------------------------------------------------------
    public static String getConfigParamDB(String key, String param){
        return getConfigString(key).replaceAll("<param>", param);
    }

    public static String getConfigParamDB(String key, String[] params){
        String result = getConfigString(key);

        for(int i=0; i<params.length; i++){
            result = result.replaceAll("<param"+(i+1)+">",params[i]);
        }

        return result;
    }

    //--- GET ALL SERVICE CODES -------------------------------------------------------------------
    public static Vector getAllServiceCodes(){
        Vector serviceCodes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            sSelect = "SELECT DISTINCT serviceid FROM Services";
            ps = ad_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            while(rs.next()){
                serviceCodes.add(rs.getString("serviceid"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return serviceCodes;
    }

    //--- GET EXAMINATIONS FOR SERVICE ------------------------------------------------------------
    public static Vector getExaminationsForService(String serviceId, String language){
    	Vector exams = (Vector)MedwanQuery.getInstance().getServiceexaminations().get(serviceId+"."+language); 
    	if(exams==null){
	        exams = new Vector();
	        
	        Service service = Service.getService(serviceId);
	        if(service!=null && service.comment.indexOf("NOEXAMS")<0){
		        PreparedStatement ps = null;
		        ResultSet rs = null;
		        String sSelect, examIds = "";
		        
		        //*** get examination ids of examinations linked to the service ***
		        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		        try{
		            sSelect = "SELECT distinct examinationid FROM ServiceExaminations WHERE serviceid = ?";
		            ps = oc_conn.prepareStatement(sSelect);
		            ps.setString(1,serviceId);
		
		            rs = ps.executeQuery();
		            while(rs.next()){
		                examIds+= rs.getString("examinationid")+",";
		            }
		
		            // remove last comma
		            if(examIds.indexOf(",") > -1){
		                examIds = examIds.substring(0,examIds.lastIndexOf(","));
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
		            catch(SQLException sqle){
		                sqle.printStackTrace();
		            }
		        }
		
		        //*** get examination objects ***
		        if(examIds.length() > 0){
		            oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		            try{
		                sSelect = "SELECT * FROM Examinations WHERE id IN ("+examIds+") ORDER BY priority";
		                ps = oc_conn.prepareStatement(sSelect);
		                rs = ps.executeQuery();
		
		                while(rs.next()){
		                    exams.add(new ExaminationVO(new Integer(rs.getInt("id")),rs.getString("messageKey"),new Integer(rs.getInt("priority")),rs.getBytes("data"),rs.getString("transactionType"),"","",language));
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
		                catch(SQLException sqle){
		                    sqle.printStackTrace();
		                }
		            }
		        }
	        }
	        MedwanQuery.getInstance().getServiceexaminations().put(serviceId+"."+language,exams);
    	}

        return exams;
    }

    //--- GET EXAMINATIONS FOR SERVICE ------------------------------------------------------------
    public static Vector getExaminationsForServiceIncludingParents(String serviceId, String language){
    	Vector exams = (Vector)MedwanQuery.getInstance().getServiceexaminationsincludingparent().get(serviceId+"."+language); 
    	if(exams==null){
	    	exams = new Vector();
	        PreparedStatement ps = null;
	        ResultSet rs = null;
	        String sSelect, examIds = "",allserviceids="'"+serviceId+"'";
	        Vector serviceIds=Service.getParentIds(serviceId);
	        for(int n=0;n<serviceIds.size();n++){
	        	String sv=(String)serviceIds.elementAt(n);
	        	Service service = Service.getService(sv);
	        	if(service.comment.indexOf("NOEXAMS")<0){
	        		allserviceids+=",'"+sv+"'";
	        	}
	        }
	        //*** get examination ids of examinations linked to the service ***
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	        try{
	            sSelect = "SELECT distinct examinationid FROM ServiceExaminations WHERE serviceid in ("+allserviceids+")";
	            ps = oc_conn.prepareStatement(sSelect);
	            rs = ps.executeQuery();
	            while(rs.next()){
	                examIds+= rs.getString("examinationid")+",";
	            }
	
	            // remove last comma
	            if(examIds.indexOf(",") > -1){
	                examIds = examIds.substring(0,examIds.lastIndexOf(","));
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
	            catch(SQLException sqle){
	                sqle.printStackTrace();
	            }
	        }
	
	        //*** get examination objects ***
	        if(examIds.length() > 0){
	            oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	            try{
	                sSelect = "SELECT * FROM Examinations WHERE id IN ("+examIds+") ORDER BY priority";
	                ps = oc_conn.prepareStatement(sSelect);
	                rs = ps.executeQuery();
	
	                while(rs.next()){
	                    exams.add(new ExaminationVO(new Integer(rs.getInt("id")),rs.getString("messageKey"),new Integer(rs.getInt("priority")),rs.getBytes("data"),rs.getString("transactionType"),"","",language));
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
	                catch(SQLException sqle){
	                    sqle.printStackTrace();
	                }
	            }
	        }
	        MedwanQuery.getInstance().getServiceexaminationsincludingparent().put(serviceId+"."+language,exams);
    	}
        return exams;
    }

    //--- GET OTHER EXAMINATIONS FOR SERVICE ------------------------------------------------------
    public static Vector getOtherExaminationsForService(String serviceId, String language){
        Vector otherExams = new Vector(),
               linkedExamIds = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect, otherExamIds = "";

        //*** get ids of examinations linked to the specified service ***
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT examinationid FROM ServiceExaminations WHERE serviceid = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,serviceId);

            rs = ps.executeQuery();
            while(rs.next()){
                linkedExamIds.add(rs.getString("examinationid"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        //*** get ids of all examinations minus the ids of the linked examinations ***
        try{
            sSelect = "SELECT id FROM Examinations";
            ps = oc_conn.prepareStatement(sSelect);

            String examId;
            rs = ps.executeQuery();
            while(rs.next()){
                examId = rs.getString("id");
                if(!linkedExamIds.contains(examId)){
                    otherExamIds+= examId+",";
                }
            }

            // remove last comma
            if(otherExamIds.indexOf(",") > -1){
                otherExamIds = otherExamIds.substring(0,otherExamIds.lastIndexOf(","));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        //*** get examination objects ***
        if(otherExamIds.length() > 0){
            try{
                sSelect = "SELECT * FROM Examinations WHERE id IN ("+otherExamIds+") ORDER BY priority";
                ps = oc_conn.prepareStatement(sSelect);
                rs = ps.executeQuery();

                while(rs.next()){
                    otherExams.add(new ExaminationVO(new Integer(rs.getInt("id")),rs.getString("messageKey"),new Integer(rs.getInt("priority")),rs.getBytes("data"),rs.getString("transactionType"),"","",language));
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                }
                catch(SQLException sqle){
                    sqle.printStackTrace();
                }
            }
        }

        return otherExams;<%@page import="java.io.StringReader,
                org.dom4j.DocumentException,
                java.util.Vector" %>
<%@page errorPage="/includes/error.jsp" %>
<%@include file="/_common/templateAddIns.jsp" %>
<%@include file="/includes/commonFunctions.jsp"%>
<script src="<c:url value='/_common/_script/menu.js'/>"></script>

<%!
    //### INNER CLASS : Menu ######################################################################
    public class Menu {
        public String labelid;
        public String accessrights;
        public String url;
        public String patientselected;
        public String employeeselected;
        public String dossierselected;
        public String activeencounter;
        public Vector menus;
        public String target;
        
        //--- CONSTRUCTOR -------------------------------------------------------------------------
        public Menu(){
            labelid = "";
            accessrights = "";
            url = "";
            patientselected = "";
            employeeselected = "";
            dossierselected = "";
            menus = new Vector();
            target = "";
        }
        
        //--- PARSE -------------------------------------------------------------------------------
        public void parse(Element eMenu){
            this.accessrights = checkString(eMenu.attributeValue("accessrights")).toLowerCase();
            this.labelid = checkString(eMenu.attributeValue("labelid")).toLowerCase();
            this.patientselected = checkString(eMenu.attributeValue("patientselected"));
            this.employeeselected = checkString(eMenu.attributeValue("employeeselected"));
            this.dossierselected = checkString(eMenu.attributeValue("dossierselected"));
            this.activeencounter = checkString(eMenu.attributeValue("activeencounter"));
            this.target = checkString(eMenu.attributeValue("target"));

            // replace ; by & if url is no javascript
            if(checkString(eMenu.attributeValue("url")).indexOf("javascript:") > -1){
                this.url = checkString(eMenu.attributeValue("url"));
            }
            else{
                this.url = checkString(eMenu.attributeValue("url")).replaceAll(";", "&");
            }
            
            Menu childMenu;
            Element eChildMenu;
            Iterator eMenus = eMenu.elementIterator("Menu");
            while(eMenus.hasNext()){
                eChildMenu = (Element)eMenus.next();
                childMenu = new Menu();
                childMenu.parse(eChildMenu);
                this.menus.add(childMenu);
            }
        }
        
        //--- MAKE MENU ---------------------------------------------------------------------------
        public String makeMenu(boolean bMenu, String sWebLanguage, String sParentMenu, User user, boolean last, 
                               AdminPerson activePatient, boolean isEmployee){
            String sReturn = "";
            try{
                if(this.accessrights.length() > 0){
                    // permission 'sa' can see everything
                    //if(user.getParameter("sa").length()==0){
                        // screen and permission specified
                        if(this.accessrights.toLowerCase().endsWith(".edit") ||
                           this.accessrights.toLowerCase().endsWith(".add") ||
                           this.accessrights.toLowerCase().endsWith(".select") ||
                           this.accessrights.toLowerCase().endsWith(".delete")){
                            if(!user.getAccessRight(this.accessrights)){
                                return "";
                            }
                        }
                        // only screen specified -> interprete as all permissions required
                        // Manageing a page, means you can add, edit and delete.
                        else{
                            if(!user.getAccessRight((this.accessrights+".edit")) ||
                               !user.getAccessRight((this.accessrights+".add")) ||
                               //!user.getAccessRight((this.accessrights+".select")) ||
                              !user.getAccessRight((this.accessrights+".delete"))){
                                return "";
                            }
                        }
                    //}
                }
                
                if(this.activeencounter.equalsIgnoreCase("true")){
                    if(activePatient==null || Encounter.getActiveEncounter(activePatient.personid)==null){
                        return "";
                    }
                }

                if(patientselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                if(employeeselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                if(dossierselected.equalsIgnoreCase("true") && !bMenu){
                    return "";
                }
                
                if(this.url.length() > 0){
                    // leave url as-is if it contains a javascript call
                    if(!this.url.startsWith("javascript:")){
                        if(this.url.startsWith("/")){
                            this.url = sCONTEXTPATH+this.url;
                        }
                        
                        if(this.url.indexOf("?") > 0) this.url+= "&ts="+getTs();
                        else                          this.url+= "?ts="+getTs();
                    }
                    
                    sReturn+= "";
                }

                // menu has submenus
                String sTranslation = getTranNoLink("Web", this.labelid, sWebLanguage);
                String subsubMenu = "";
                if(this.menus.size() > 0){
                    Menu subMenu;
                    for (int y = 0; y < this.menus.size(); y++){
                        subMenu = (Menu)this.menus.elementAt(y);

                        /*
                        // DEBUG
                        System.out.println("\n      ["+subMenu.labelid+"] subMenu.dossierselected : "+subMenu.dossierselected);
                        System.out.println("       subMenu.patientselected : "+subMenu.patientselected);
                        System.out.println("       subMenu.employeeselected : "+subMenu.employeeselected);
                        */
                        
                        if((subMenu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                            continue;
                        }
                        else if((subMenu.patientselected.equalsIgnoreCase("true")&!bMenu) || (subMenu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                            continue;
                        }
                        else{
                            subsubMenu += subMenu.makeMenu(bMenu, sWebLanguage, this.labelid, user, (y==this.menus.size() - 1),activePatient,isEmployee);
                        }
                    }
                    
                    if(this.target.length() > 0){
                        sReturn+= "<li><a href='javascript:void(0); class='subparent''>"+sTranslation+"</a>";
                        sReturn+= "<ul class='level3'>";
                        sReturn+= (subsubMenu.length()>0)?subsubMenu:"<li><a href='javascript:void(0);'>empty</a></li>";
                        sReturn+= "</ul></li>";
                    } 
                    else{
                        sReturn+= "<li><a href='javascript:void(0);' class='subparent'>"+sTranslation+"</a>";
                        sReturn+= "<ul class='level3'>";
                        sReturn+= (subsubMenu.length()>0)?subsubMenu:"<li><a href='javascript:void(0);'>empty</a></li>";
                        sReturn+= "</ul></li>";
                    }
                } 
                else{
                    if(this.target.length() > 0){
                        sReturn+= "<li><a href=\""+this.url+"\">"+sTranslation+"</a></li>";
                    }
                    else{
                        sReturn+= "<li><a href=\""+this.url+"\">"+sTranslation+"</a></li>";
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            
            return sReturn;
        }
    }
%>

<% 
    String sPage = checkString(request.getParameter("Page")).toLowerCase(),
           sPersonID = checkString(request.getParameter("personid")),
           sPatientNew = checkString(request.getParameter("PatientNew"));
   
    if(sPage.startsWith("start") || sPage.startsWith("_common/patientslist") || sPatientNew.equals("true")){
        session.removeAttribute("activePatient");
        activePatient = null;
        SessionContainerWO sessionContainerWO = (SessionContainerWO) session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        sessionContainerWO.setPersonVO(null);
        
		%>
		<script>
		  window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";
		</script>
		<%
    } 
    else if(sPersonID.length() > 0){
        activePatient = AdminPerson.getAdminPerson(sPersonID);
        session.setAttribute("activePatient",activePatient);
        
		%>
		<script>
		  window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request,sWebLanguage)%>";
		</script>
		<%
    }
    else{ 
	    sPersonID = checkString(request.getParameter("PersonID"));
    	try{
    		sPersonID = Integer.parseInt(sPersonID)+"";
    	}
    	catch(Exception e){
    	    // empty
    	}

	    if(sPersonID.length() > 0){
	        session.removeAttribute("activePatient");
	        activePatient = AdminPerson.getAdminPerson(sPersonID);
	    }
    }
    
    //First check if user has access to the active patient
    if(sPage.indexOf("novipaccess")<0 && activePatient!=null && "1".equalsIgnoreCase((String)activePatient.adminextends.get("vip")) && !activeUser.getAccessRight("vipaccess.select")){
        //User has no access, redirect to warning screen
        %><script>window.location.href='<c:url value="main.do?Page=novipaccess.jsp"/>';</script><%
        out.flush();
    }
    session.setAttribute("activePatient",activePatient);
  
    boolean bMenu = false;
    if((activePatient!=null) && (activePatient.lastname!=null) && (activePatient.personid.trim().length() > 0)){
        if(!sPage.equals("patientslist.jsp")){
            bMenu = true;
        }
    } 
    else{
        activePatient = new AdminPerson();
    }
    
    boolean isEmployee = activePatient.isEmployee();
    Debug.println("dropdownmenu : isEmployee : "+isEmployee);
%>

<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="*">
            <div id="topmenu">
                <ul class="level1" id="root">
                    <%
                        //-- menus ----------------------------------------------------------------
                        SAXReader xmlReader = new SAXReader();
                        String sMenu = checkString((String) session.getAttribute("MenuXML"));
                        Document document;
                        
                        if(sMenu.length() > 0){
                            document = xmlReader.read(new StringReader(sMenu));
                        }
                        else{
                            String sMenuXML = MedwanQuery.getInstance().getConfigString("MenuXMLFile");
                            if(sMenuXML.length()==0) sMenuXML = "menu.xml";
                            String sMenuXMLUrl = "http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(), "")+"/"+sAPPDIR+"/_common/xml/"+sMenuXML+"&ts="+getTs();

                            // Check if menu file exists, else use file at templateSource location.
                            try{
                                document = xmlReader.read(new URL(sMenuXMLUrl));
                                if(Debug.enabled) Debug.println("Using custom menu file : "+sMenuXMLUrl);
                            }
                            catch(DocumentException e){
                                sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource")+"/"+sMenuXML;
                                document = xmlReader.read(new URL(sMenuXMLUrl));
                                if(Debug.enabled) Debug.println("Using default menu file : "+sMenuXMLUrl);
                            }
                            session.setAttribute("MenuXML",document.asXML());
                        }
                        
                        Vector vMenus = new Vector();
                        Menu menu;
                        if(document!=null){
                            Element root = document.getRootElement();
                            if(root!=null){
                                Iterator elements = root.elementIterator("Menu");
                                while(elements.hasNext()){
                                    menu = new Menu();
                                    menu.parse((Element) elements.next());
                                    vMenus.add(menu);
                                }
                            }
                        }

                        //menus
                        Menu subMenu;
                        for(int i=0; i<vMenus.size(); i++){
                            menu = (Menu) vMenus.elementAt(i);
                            String subs = "";

                            /*
                            // DEBUG
                            System.out.println("\n["+menu.labelid+"] menu.dossierselected : "+menu.dossierselected);
                            System.out.println(" menu.patientselected : "+menu.patientselected);
                            System.out.println(" menu.employeeselected : "+menu.employeeselected);
                            */
                            
                            if((menu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                                continue;
                            }
                            else if((menu.patientselected.equalsIgnoreCase("true")&!bMenu) || (menu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                                continue;
                            }
                            else if(menu.menus.size() > 0){
                                if(!menu.labelid.equalsIgnoreCase("hidden")){
                                    for (int y = 0; y < menu.menus.size(); y++){
                                        subMenu = (Menu) menu.menus.elementAt(y);
                                         
                                        /*
                                        // DEBUG
                                        System.out.println("\n   ["+subMenu.labelid+"] subMenu.dossierselected : "+subMenu.dossierselected);
                                        System.out.println("    subMenu.patientselected : "+subMenu.patientselected);
                                        System.out.println("    subMenu.employeeselected : "+subMenu.employeeselected);
                                        */
                                        
                                        if((subMenu.dossierselected.equalsIgnoreCase("true") && (activePatient==null || activePatient.personid.length()==0))){
                                            continue;
                                        }
                                        else if((subMenu.patientselected.equalsIgnoreCase("true")&!bMenu) || (subMenu.employeeselected.equalsIgnoreCase("true")&!isEmployee)){
                                            continue;
                                        }
                                        else{
                                            subs += subMenu.makeMenu(bMenu, sWebLanguage, menu.labelid, activeUser, (y==menu.menus.size() - 1),activePatient,isEmployee);
                                        }
                                    }
                                    
                                    out.write("<li class='menu_"+menu.labelid+"'>");
                                    out.write("<a href='javascript:void(0)' class='parent'>"+getTranNoLink("Web", menu.labelid, sWebLanguage)+"</a>");
                                    out.write("<ul class='level2'>");
                                    out.write(subs);
                                    out.write("</ul></li>");
                                }
                            }
                            // no submenus
                            else{
                                if(!menu.patientselected.equalsIgnoreCase("true") || bMenu){
                                    if(menu.url.length() > 0){
                                        if(menu.url.startsWith("/")){
                                            menu.url = sCONTEXTPATH+menu.url;
                                        }
                                        if(menu.url.indexOf("javascript:") < 0){
                                            if(menu.url.indexOf("?") > 0){
                                                menu.url+= "&ts="+getTs();
                                            }
                                            else menu.url+= "?ts="+getTs();
                                        }
                                    }

                                    // only add menu to menubar if the user has the required accessright
                                    // or when no accessright is specified or when the user has 'sa' as a userparameter
                                    if((menu.accessrights.length() > 0 && activeUser.getAccessRight(menu.accessrights)) ||
                                            menu.accessrights.length()==0) /*|| activeUser.getParameter("sa").length()>0)*/ {
                                        if(menu.target.length() > 0){
                                            out.write("<li class='menu_"+menu.labelid+"'>");
                                            out.write("<a href="+menu.url+">"+getTranNoLink("Web", menu.labelid, sWebLanguage)+"</a>");
                                            out.write("</li>");
                                        } 
                                        else{
                                            out.write("<li class='menu_"+menu.labelid+"'><a href="+menu.url+">"+getTranNoLink("Web", menu.labelid, sWebLanguage)+"</a></li>");
                                        }
                                    }
                                }
                            }
                        }
                        
                        String sHelp = MedwanQuery.getInstance().getConfigString("HelpFile");%>
                </ul>
            </div>
        </td>
    </tr>
</table>

<script>
  <%-- OPEN HELP FILE --%>
  function openHelpFile(){
    window.open("<%=sHelp.replaceAll("@@language@@",activeUser.person.language.toLowerCase())%>");
  }

  <%-- NEW ENCOUNTER --%>
  function newEncounter(){
    <%
        Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog("web","close.active.encounter.first");<%
        }
        else{
            %>window.location.href = '<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>';<%
        }
    %>
  }

  <%-- NEW FAST ENCOUNTER --%>
  function newFastEncounter(init){
    <%
        activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null && activeEncounter.getEnd()==null){
            %>alertDialog("web","close.active.encounter.first");<%
        }
        else{
            %>
              var params = '';
              var today = new Date();
              var url = '<c:url value="/"/>/adt/newEncounter.jsp?ts=<%=getTs()%>&init='+init;
              new Ajax.Request(url,{
                method: "GET",
                parameters: params,
                onSuccess: function(resp){
                  window.location.reload();
                }
              });
            <%
        }
    %>
  }

  <%-- NEW FAST TRANSACTION --%>
  function newFastTransaction(transactionType){
    if(<%=Encounter.selectEncounters("","","","","","","","",activePatient.personid,"").size()%>>0){
      window.location.href='<c:url value="/"/>healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType='+transactionType+'&ts=<%=getTs()%>';
    }
    else{
      alertDialog("web","create.encounter.first");
    }
  }
    
  <%-- READ BARCODE --%>
  function readBarcode(){
    openPopup("/_common/readBarcode.jsp&ts=<%=getTs()%>");
  }
    
  function readBarcode2(barcode){
    var transform = "<%=MedwanQuery.getInstance().getConfigString("CCDKeyboardTransformString","à&é\\\"'(§è!ç")%>";
    var oldbarcode = barcode;
    barcode = "";
    for(var n=0; n<oldbarcode.length; n++){
      if(transform.indexOf(oldbarcode.substring(n,n+1)) > -1){
        barcode = barcode+transform.indexOf(oldbarcode.substring(n,n+1));
      }
      else{
        barcode = barcode+oldbarcode.substring(n,n+1);
      }
    }
    document.getElementsByName('barcode')[0].style.visibility = "hidden";
    if(barcode.substring(0,1)=="0"){
      window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+barcode.substring(1);
    }
    else if(barcode.substring(0,1)=="1"){
      alert("OldBarcode = "+oldbarcode);
      alert("Barcode = "+barcode);
    }
    else if(barcode.substring(0,1)=="2"){
      if(document.getElementsByName('sampleReceiver')[0]!=undefined){
        document.getElementsByName('sampleReceiver')[0].innerHTML = "<input type='hidden' name='receive."+barcode.substring(1,3)+"."+barcode.substring(3, 11)+"."+(barcode.length > 11 ? barcode.substring(11) : "?")+"' value='1'/>";
        frmSampleReception.submit();
      }
    }
    else if(barcode.substring(0,1)=="4" || barcode.substring(0,1)=="5"){
      window.open("<c:url value='/popup.jsp'/>?Page=_common/readBarcode.jsp&ts=<%=ScreenHelper.getTs()%>&barcode="+barcode,"barcode","toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no");
    }
    else if(barcode.substring(0,1)=="7"){
      url = "<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientInvoiceUID="+barcode.substring(1);
      window.location.href = url;
    }
    else if(barcode.substring(0,1)=="8"){
      url = "<c:url value='/main.do'/>?Page=financial/patientCreditEdit.jsp&ts=<%=ScreenHelper.getTs()%>&LoadPatientId=true&FindPatientCreditUID="+barcode.substring(1);
      window.location.href = url;
    }
  }

  <%-- READ BARCODE 3 --%>
  function readBarcode3(barcode){
    var transform = "<%=MedwanQuery.getInstance().getConfigString("CCDKeyboardTransformString","à&é\\\"'(§è!ç")%>";
    var oldbarcode = barcode;
    barcode = "";
    for(var n=0; n<oldbarcode.length; n++){
      if(transform.indexOf(oldbarcode.substring(n,n+1)) > -1){
        barcode = barcode+transform.indexOf(oldbarcode.substring(n,n+1));
      }
      else{
        barcode = barcode+oldbarcode.substring(n,n+1);
      }
    }
    document.getElementsByName('barcode')[0].style.visibility = "hidden";
    if(barcode.substring(0,1)=="0"){
      window.open("<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+barcode.substring(1), "Popup"+new Date().getTime(), "toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width - 800) / 2, (screen.height - 600) / 2);
    }
  }
    
  <%-- CREATE ARCHIVE FILE --%>
  function createArchiveFile(){
    openPopup("_common/createArchiveFile.jsp&ts=<%=getTs()%>",1,1);
  }

  <%-- READ FINGER PRINT --%>
  function readFingerprint(){
    <%
        if(checkString(MedwanQuery.getInstance().getConfigString("referringServer")).length()==0){
            %>openPopup("_common/readFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%="http://"+request.getServerName()+"/"+sCONTEXTPATH%>",400,100);<%
        }
        else{
            %>openPopup("_common/readFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%=MedwanQuery.getInstance().getConfigString("referringServer")+sCONTEXTPATH%>",400,300);<%
        }
    %>
  }
  
  <%-- ENROLL FINGER PRINT --%>
  function enrollFingerPrint(){
    <%
        if(checkString(MedwanQuery.getInstance().getConfigString("referringServer")).length()==0){
            %>openPopup("_common/enrollFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%="http://"+request.getServerName()+"/"+sCONTEXTPATH%>");<%
        }
        else{
            %>openPopup("_common/enrollFingerPrint.jsp&ts=<%=getTs()%>&referringServer=<%=MedwanQuery.getInstance().getConfigString("referringServer")+sCONTEXTPATH%>");<%
        }
    %>
  }
  function printPatientCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createPatientCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
  }
  function printInsuranceCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter", "Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no, resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createInsuranceCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes, resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
  }
  function printCNOMCard(){
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=cardprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
    window.open("<c:url value='/adt/createCNOMCardPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }
  function printPatientLabel(){
    window.open("<c:url value='/adt/createPatientLabelPdf.jsp'/>?ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300)/2);
  }
  function storePicture(){
    var url = "<c:url value='/util/ajax/webcam.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","loadPicture",sWebLanguage)%>',width:650});
  }
  function showPicture(){
    var url = "<c:url value="/util/ajax/showPicture.jsp"/>?personid=<%=activePatient!=null?activePatient.personid:"0"%>&ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","showPicture",sWebLanguage)%>',width:162});
  }
  function deletePicture(){
    var url = "<c:url value='/util/ajax/deletePicture.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:'<%=getTranNoLink("web","loadPicture",sWebLanguage)%>',width:162});
  }
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/printPatient.jsp&Field=mijn&ts=<%=getTs()%>");
  }
    
  function deletepaperprescription(prescriptionuid){
	if(yesnoDialog("Web","areYouSureToDelete")){
      window.open('<c:url value='/medical/deletePaperPrescription.jsp'/>?ts=<%=getTs()%>&prescriptionuid='+prescriptionuid,"delete","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    }
  }
    
  function getPOSPrinterServer(){
    var POSPrinterServer = 'http://localhost/openclinic';
    var url = '<%=MedwanQuery.getInstance().getConfigString("javaPOSServer","http://localhost/openclinic")%>/util/getPOSPrinterServer.jsp';
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.server.length>0){
          POSPrinterServer=label.server;
        };
      }
    });
    return POSPrinterServer;
  }
   
  <%-- CONFIRM LOGOUT --%>
  function confirmLogout(){
    if(verifyPrestationCheck()){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=999999999&labelType=Web.occup&labelID=confirm.logout";
      var modalitiesIE = "dialogWidth:250px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer;
      if(window.showModalDialog){
        answer = window.showModalDialog(popupUrl,'',modalitiesIE);
      }
      else{
        answer = window.confirm("<%=getTranNoLink("Web.occup","confirm.logout",sWebLanguage)%>");
      }
      if(answer==1){
        document.location.href = '<c:url value='/logout.do'/>?ts=<%=getTs()%>';
      }
    }
  }
 
  <%-- CLOSE MODALBOX--%>
  function closeModalbox(msg,time){
    if(!msg){
      Modalbox.hide();
    }
    else{
      if(!time) time = 1000;
      Modalbox.show('<div class=\'valid\'><p>'+msg+'</p><p style="text-align:center"><input class=\'button\' type=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","ok",sWebLanguage)%>\' onclick=\'Modalbox.hide()\' /></p></div>',{title:"...",width: 200});
      setTimeout("Modalbox.hide()",time);
    }
  }
  
  function refreshWindow(){
    window.location.reload(true);
  }
    
  <%-- MODALBOX YES OR NO --%>
  function yesOrNo(myfunction,msg){
    Modalbox.show('<div class=\'warning\'><p>'+msg+'</p><p style="text-align:center"><input class=\'button\' type=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","yes",sWebLanguage)%>\' onclick=\'eval("'+myfunction+'");Modalbox.hide()\' />&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;<input type=\'button\' class=\'button\' style=\'padding-left:7px;padding-right:7px\' value=\'<%=getTranNoLink("web","no",sWebLanguage)%>\' onclick=\'Modalbox.hide()\' /></p></div>',{title:"<%=getTranNoLink("web","areyousure",sWebLanguage)%>",width:300});
  }

  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title){
    var url = "<c:url value='/popup.jsp'/>?Page="+page;
    if(width!=undefined) url+= "&PopupWidth="+width;
    if(height!=undefined) url+= "&PopupHeight="+height;
    if(title==undefined){
      if(page.indexOf("&") < 0){
        title = page.replace("/","_");
        title = replaceAll(title,".","_");
      }
      else{
        title = replaceAll(page.substring(1,page.indexOf("&")),"/","_");
        title = replaceAll(title,".","_");
      }
    }
    var w = window.open(url,title,"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    w.moveBy(2000,2000);
  }
  
  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
    return s;
  }
    
  <%-- open search in progress popup --%>
  function openSearchInProgressPopup(){
    var popupWidth = 250;
    var popupHeight = 120;
    popup = window.open("","Searching","titlebar=no,title=no,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,width="+popupWidth+",height="+popupHeight);
    popup.moveTo((this.screen.width-popupWidth)/2,(this.screen.height-popupHeight)/2);
    popup.document.write("<head><title><%=sWEBTITLE+" "+sAPPTITLE%></title><%=sCSSNORMAL%></head>");
    popup.document.write("<body onBlur='this.focus();' cellpadding='0' cellspacing='0'>");
    popup.document.write("<table width='100%' height='100%' cellspacing='0' cellpadding='0'>");
     popup.document.write("<tr>");
      popup.document.write("<td bgcolor='#eeeeee' style='text-align:center'>");
       popup.document.write("<%=getTran("web","searchInProgress",sWebLanguage)%>");
      popup.document.write("</td>");
     popup.document.write("</tr>");
    popup.document.write("</table>");
    popup.document.write("</body>");
    popup.document.close();
    popup.focus();
  }
  <%-- show drugs out barcode --%>
  function showdrugsoutbarcode(){
    openPopup("pharmacy/drugsOutBarcode.jsp&ts=<%=getTs()%>",700,500);
  }
  <%-- show global health barometer --%>
  function showglobalhealthbarometer(){
    window.open("http://www.globalhealthbarometer.net/globalhealthbarometer/datacenter/datacenterHomePublic.jsp?me=<%=MedwanQuery.getInstance().getConfigString("globalHealthBarometerUID","")%>&ts=<%=getTs()%>");
  }
  <%-- show sourge force --%>
  function showsourceforge(){
    window.open("http://sourceforge.net/projects/open-clinic");
  }
  <%-- open RFE list --%>
  function openRFEList(){
    <%
        if(activePatient!=null && activePatient.personid.length() > 0){
            Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
            if(encounter!=null){
                %>openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400);<%
            }
        }
    %>
  }
  function showAdminPopup(){
    openPopup("/_common/patient/patientdataPopup.jsp&ts=<%=getTs()%>");
  }
  function searchLab(){
    window.location.href = "<c:url value="/"/>main.do?Page=labos/showLabRequestList.jsp&ts=<%=getTs()%>";
  }
  function showLabResultsEdit(){
    window.location.href = "<c:url value="/"/>main.do?Page=labos/manageLaboResultsEdit.jsp&type=patient&open=true&Action=find&ts=<%=getTs()%>";
  }
  function searchMyHospitalized(){
    clearPatient();
    SF.Action.value = "MY_HOSPITALIZED";
    SF.submit();
  }
  function searchMyVisits(){
    clearPatient();
    SF.Action.value = "MY_VISITS";
    SF.submit();
  }

  <%-- show manual --%>
  function showmanual(){
    <%
        if(MedwanQuery.getInstance().getConfigString("documentationLanguages","en,fr").toLowerCase().indexOf(sWebLanguage.toLowerCase())>-1){
            %>window.open("<c:url value="/documents/help/"/>openclinic_manual_<%=sWebLanguage.toLowerCase()%>.pdf");<%
        }
        else{
            %>window.open("<c:url value="/documents/help/"/>openclinic_manual_en.pdf");<%
        }
    %>
  }    
    
  function downloadPharmacyExport(){
    var w = window.open("<c:url value='/pharmacy/exportFile.jsp'/>");
  }

  <%
      if(MedwanQuery.getInstance().getConfigInt("enableNationalBarcodeID",0)==1){
  %>
  function redirectNationalBarcodeId(id,lastname,firstname){
    window.location.href = '<c:url value="/"/>/main.do?Page=_common/patientslist.jsp?findnatreg='+id+'&findName='+lastname+'&findFirstname='+firstname;
  }
    
  function checkNationalBarcodeIdRedirect(){
    var params = '';
    var today = new Date();
    var url = '<c:url value="/adt/ajaxActions/checkNationalBarcodeId.jsp"/>?natreg=<%=activePatient==null?"":activePatient.getID("natreg")%>&ts='+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: params,
      onSuccess: function(resp){
        var data = resp.responseText.split("$");
        if(data.length > 1){
          redirectNationalBarcodeId(data[0],data[1],data[2]);
        }
      }
    });
  }
  window.setInterval('checkNationalBarcodeIdRedirect();',2000);
  <%
      }
  %>
    
  function addAutoCompleter(key,id,div){
    new Ajax.Autocompleter(id,div,'util/loadAutoCompleteItems.jsp?key='+key,{   
      inChars:1,
      method:'post',
      callback:genericEventDateCallback
    });
  }
    
  function genericEventDateCallback(element,entry){
    return "search="+element.value;
  }
</script>
    }

    //--- WRITE DATE TIME FIELD -------------------------------------------------------------------
    public static String writeDateTimeField(String sName, String sForm, java.util.Date dValue,
    		                                String sWebLanguage, String sCONTEXTDIR){        
        return "<input type='text' maxlength='10' class='text' name='"+sName+"' value='"+getSQLDate(dValue)+"' size='12' onblur='if(!checkDate(this)){alert(\""+getTran("Web.Occup","date.error",sWebLanguage)+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick='gfPop1.fPopCalendar(document."+sForm+"."+sName+");return false;'>"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick=\"getToday(document."+sForm+".all['"+sName+"']);getTime(document."+sForm+".all['"+sName+"Time'])\">"
              +"&nbsp;"+writeTimeField(sName+"Time", formatSQLDate(dValue,"HH:mm"))
              +"&nbsp;"+getTran("web.occup","medwan.common.hour",sWebLanguage);
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    public static java.util.Date getSQLTime(String sTime){
        java.util.Date date = null;

        if(sTime.length()>0){
            try{
                date = new SimpleDateFormat().parse(sTime);
            }
            catch(Exception e){
                date = null;
            }
        }
        return date;
    }

    //--- GET PRODUCT UNIT TYPES ------------------------------------------------------------------
    public static Vector getProductUnitTypes(String sLang){
        Vector unitTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        // LOWER
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        String lcaseLabelType = getConfigParam("lowerCompare","OC_LABEL_TYPE",co_conn);
        String lcaseLabelLang = getConfigParam("lowerCompare","OC_LABEL_LANGUAGE",co_conn);

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_LABEL_ID FROM OC_LABELS"+
                             " WHERE "+lcaseLabelType+"=? AND "+lcaseLabelLang+"=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,"product.unit");
            ps.setString(2,sLang.toLowerCase());

            rs = ps.executeQuery();
            while(rs.next()){
                unitTypes.add(checkString(rs.getString("OC_LABEL_ID")));
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
                co_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return unitTypes;
    }

    //--- CONVERT TO ALFABETICAL CODE -------------------------------------------------------------
    public static String convertToAlfabeticalCode(String numberString){
        String[] alfabet = {"a","b","c","d","e","f","g","h","i","j","k","l","m",
                            "n","o","p","q","r","s","t","u","v","w","x","y","z"};

        String letters = "";
        int number = Integer.parseInt(numberString);
        while(number>0){
            number--;
            letters=alfabet[(number % alfabet.length)]+letters;
            number=number-(number % alfabet.length);
            number=number/alfabet.length;
        }
        return letters;
    }

    //--- CONVERT FROM ALFABETICAL CODE -------------------------------------------------------------
    public static int convertFromAlfabeticalCode(String numberString){
        String alfabet = "abcdefghijklmnopqrstuvwxyz";

        int value=0;
        int counter=0;
        for (int i=0;i<numberString.length();i++){
            int number = alfabet.indexOf(numberString.substring(i, i+1))+1;
            for(int k=numberString.length()-i-1;k>0;k--){
            	number*=alfabet.length();
            }
            value+=number;
        }
        return value;
    }

    //--- IS USER A DOCTOR ------------------------------------------------------------------------
    public static boolean isUserADoctor(User user){
        return isUserADoctor(Integer.parseInt(user.personid));
    }

    public static boolean isUserADoctor(UserVO user){
        return isUserADoctor(user.getPersonVO().personId.intValue());
    }

    public static boolean isUserADoctor(int personId){
        boolean userIsADoctor = false;
        ResultSet rs = null;
        PreparedStatement ps = null;

        String sSelect = "SELECT p.value"+
                         " FROM UserParameters p, Admin a, Users u"+
                         "  WHERE "+getConfigParam("lowerCompare","parameter")+" = 'organisationid' "+
                         "   AND value LIKE '9__'"+
                         "   AND a.personid = ?"+
                         "   AND u.userid = p.userid"+
                         "   AND a.personid = u.personid";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,personId);
            rs = ps.executeQuery();

            if(rs.next()){
                // person who did the examination has a doctor code
                userIsADoctor = true;
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();

            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return userIsADoctor;
    }
    //--- CONTEXT FOOTER --------------------------------------------------------------------------
    public static String contextFooter(HttpServletRequest request) {
        String result = "</div>";

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            if(sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0
                    || checkString(request.getParameter("be.mxs.healthrecord.transaction_id")).equalsIgnoreCase("currentTransaction")
                    || MedwanQuery.getInstance().getConfigString("doNotAskForContext").equalsIgnoreCase("on")) {
                result += "<script>show('content-details');hide('confirm');</script>";
            }
        }
        catch (Exception e) {
            // nothing
        }

        return result;
    }

    //--- GET LAST ITEM ---------------------------------------------------------------------------
    public static ItemVO getLastItem(HttpServletRequest request, String sType) {
        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            if(sessionContainerWO.getHealthRecordVO() != null && sessionContainerWO.getCurrentTransactionVO() != null) {
                ItemVO actualItem = sessionContainerWO.getCurrentTransactionVO().getItem(sType);
                if(actualItem == null || actualItem.getItemId().intValue() < 0) {
                    ItemVO lastItem = MedwanQuery.getInstance().getLastItemVO(sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(), sType);
                    if(lastItem == null) {
                        if(sessionContainerWO.getCurrentTransactionVO().getItem(sType) != null) {
                            return sessionContainerWO.getCurrentTransactionVO().getItem(sType);
                        }
                    } 
                    else{
                        return lastItem;
                    }
                } 
                else{
                    return actualItem;
                }
            }
        }
        catch (SessionContainerFactoryException e) {
            e.printStackTrace();
        }

        // no last item found, so return a blank item
        return new ItemVO(null, "", "", null, null);
    }
    
    //--- CHECK SPECIAL CHARACTERS ----------------------------------------------------------------
    // this function is used by DBSynchroniser and AdminPerson
    public static String checkSpecialCharacters(String sTest){
        sTest = sTest.replaceAll("'","");
        sTest = sTest.replaceAll(" ","");
        sTest = sTest.replaceAll("-","");
        sTest = sTest.replaceAll("é","e");
        sTest = sTest.replaceAll("è","e");
        sTest = sTest.replaceAll("ï","i");
        sTest = sTest.replaceAll("é","e");
        sTest = sTest.replaceAll("è","e");
        sTest = sTest.replaceAll("ë","e");
        sTest = sTest.replaceAll("ï","i");
        sTest = sTest.replaceAll("ö","o");
        sTest = sTest.replaceAll("ä","a");
        sTest = sTest.replaceAll("á","a");
        sTest = sTest.replaceAll("à","a");

        return sTest;
    }
    
    //--- SET SQL DATE ----------------------------------------------------------------------------
    public static void setSQLDate(PreparedStatement ps, int iIndex, String sDate) {
        try{
            if((sDate == null)||(sDate.trim().length()==0)) {
                ps.setNull(iIndex, Types.DATE);
            }
            else{
                ps.setDate(iIndex, ScreenHelper.getSQLDate(sDate));
            }
        }
        catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    //--- PAD LEFT --------------------------------------------------------------------------------
    public static String padLeft(String s, String padCharacter, int size){
        int i = s.length();
        for(int n = 0; n<size-i; n++){
            s = padCharacter+s;
        }
        
        return s;
    }

    //--- PAD RIGHT -------------------------------------------------------------------------------
    public static String padRight(String s, String padCharacter, int size){
        int i = s.length();
        for(int n = 0; n<size-i; n++){
            s = s+padCharacter;
        }
        
        return s;
    }

    //--- GET SERVICE CONTEXTS --------------------------------------------------------------------
    public static Hashtable getServiceContexts(){
        Hashtable serviceContexts = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            sSelect = "SELECT DISTINCT serviceid,defaultcontext FROM Services";
            ps = ad_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            while(rs.next()){
                serviceContexts.put(rs.getString("serviceid"),rs.getString("defaultcontext"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }

        return serviceContexts;
    }
    
}
