package be.mxs.common.util.system;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.openclinic.system.Application;
import net.admin.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;
import java.io.File;
import java.sql.*;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class ScreenHelper {
    static SimpleDateFormat stdDateFormat  = new SimpleDateFormat("dd/MM/yyyy");
    static SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    static public String left(String s,int n){
    	if(s==null){
    		return "";
    	}
    	else if(s.length()<=n){
    		return s;
    	}
    	else {
    		return s.substring(0,n-3)+"...";
    	}
    }
    //--- CUSTOMER INCLUDE ------------------------------------------------------------------------
    static public String customerInclude(String fileName, String sAPPFULLDIR, String sAPPDIR){
        if (fileName.indexOf("?")>0){
            fileName=fileName.substring(0,fileName.indexOf("?"));
        }

        if (new File((sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")).exists()){
            if(Debug.enabled) Debug.println("Customer file "+(sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")+" found");
            return ("/"+sAPPDIR+"/"+fileName).replaceAll("//","/");
        }
        else {
            if(Debug.enabled) Debug.println("Customer file "+(sAPPFULLDIR+"/"+sAPPDIR+"/"+fileName).replaceAll("//","/")+" not found, using "+("/"+fileName).replaceAll("//","/"));
            return ("/"+fileName).replaceAll("//","/");
        }
    }

    //--- GET TRAN --------------------------------------------------------------------------------
    static public String getTran(String sType, String sID, String sLanguage) {
        return getTran(sType,sID,sLanguage,false);
    }

    static public String getTran(String sType, String sID, String sLanguage, boolean displaySimplePopup) {
        String labelValue = "";

        try{
            if(sLanguage==null || sLanguage.length() != 2){
                System.out.println("Exception in ScreenHelper.getTran : Language is null or not composed of two-letters");
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
            else {
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
    static public String getTranWithLink(String sType, String sID, String sLanguage) {
        return getTranWithLink(sType, sID, sLanguage, false);
    }

    static public String getTranWithLink(String sType, String sID, String sLanguage, boolean displaySimplePopup) {
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
            else {
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
    static public String getTranDb(String sType, String sID, String sLang){
        String labelValue = "";
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

        return labelValue.replaceAll("##CR##","\n");
    }

    //--- GET TRAN NO LINK ------------------------------------------------------------------------
    static public String getTranNoLink(String sType, String sID, String sLanguage) {
        String labelValue = "";
        if(sLanguage!=null && sLanguage.equalsIgnoreCase("f")){
        	sLanguage="fr";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("n")){
        	sLanguage="nl";
        }
        else if(sLanguage!=null && sLanguage.equalsIgnoreCase("e")){
        	sLanguage="e";
        }

        try{
            if(sLanguage==null || sLanguage.length() != 2) throw new Exception("Language must be a two-letter notation. sType="+sType+", sID="+sID+", sLanguage="+sLanguage);

            if(sType.equalsIgnoreCase("service") || sType.equalsIgnoreCase("function")){
                labelValue = MedwanQuery.getInstance().getLabel(sType.toLowerCase(),sID.toLowerCase(),sLanguage);
            }
            else {
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
        catch(Exception e){
            e.printStackTrace();
        }

        return labelValue.replaceAll("##CR##","\n");
    }

    //--- CONVERT HTML CODE TO CHAR ---------------------------------------------------------------
    static public String convertHtmlCodeToChar(String text){
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
    static public String normalizeSpecialCharacters(String sTest){
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
    static public String getConfigString(String key, Connection conn){
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
    static public String getConfigParam(String key, String param, Connection conn){
        return getConfigString(key,conn).replaceAll("<param>",param);
    }

    //--- GET CONFIG PARAM ------------------------------------------------------------------------
    static public String getConfigParam(String key, String[] params, Connection conn){
        String result = getConfigString(key,conn);

        for(int i=0; i<params.length; i++){
            result = result.replaceAll("<param"+(i+1)+">",params[i]);
        }

        return result;
    }

    //--- SET ROW ---------------------------------------------------------------------------------
    static public String setRow(String sType, String sID, String sValue, String sLanguage) {
        return "<tr><td class='admin'>"+getTran(sType,sID,sLanguage)+"</td><td class='admin2'>"+sValue+"</td></tr>";
    }

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    static public String setAdminPrivateContact(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if (checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if (checkString(apc.province).trim().length()>0) {
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

    //--- SET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    static public String setAdminPrivateContactBurundi(AdminPrivateContact apc, String sLanguage) {
        String sCountry = "&nbsp;";
        if (checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sLanguage);
        }

        String sProvince = "&nbsp;";
        if (checkString(apc.province).trim().length()>0) {
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

    //--- WRITE LOOSE DATE FIELD YEAR -------------------------------------------------------------
    static public String writeLooseDateFieldYear(String sName, String sForm, String sValue, boolean allowPastDates, boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR) {
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
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick=\"gfPop"+gfPopType+".fPopCalendar(document."+sForm+"."+sName+");return false;\">"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick=\"getToday(document."+sForm+"."+sName+");\">";
    }

    //--- WRITE DATE FIELD ------------------------------------------------------------------------
    static public String writeDateField(String sName, String sForm, String sValue, boolean allowPastDates, boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR) {
        String gfPopType = "1"; // default
        if(allowPastDates && allowFutureDates){
            gfPopType = "1";
        }
        else{
          if(allowFutureDates){ gfPopType = "3"; }
          else if(allowPastDates) { gfPopType = "2"; }
        }

        return "<input type='text' maxlength='10' class='text' id='"+sName+"' name='"+sName+"' value='"+sValue+"' size='12' onblur='if(!checkDate(this)){alert(\""+getTran("Web.Occup","date.error",sWebLanguage)+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick=\"gfPop"+gfPopType+".fPopCalendar(document."+sForm+"."+sName+");return false;\">"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick=\"getToday(document."+sForm+"."+sName+");\">";
    }
     static public String newWriteDateTimeField(String sName, java.util.Date dValue, String sWebLanguage, String sCONTEXTDIR) {
        return "<input id='" + sName + "' type='text' maxlength='10' class='text' name='" + sName + "' value='" + getSQLDate(dValue) + "' size='12' onblur='if(!checkDate(this)){alert(\"" + HTMLEntities.htmlentities(getTran("Web.Occup", "date.error", sWebLanguage)) + "\");this.value=\"\";}'>"
                + "&nbsp;<img name='popcal' class='link' src='" + sCONTEXTDIR + "/_img/icon_agenda.gif' alt='" + HTMLEntities.htmlentities(getTran("Web", "Select", sWebLanguage)) + "' onclick='gfPop1.fPopCalendar($(\"" + sName + "\"));return false;'>"
                + "&nbsp;<img class='link' src='" + sCONTEXTDIR + "/_img/icon_compose.gif' alt='" + HTMLEntities.htmlentities(getTran("Web", "PutToday", sWebLanguage)) + "' onclick=\"putTime($('" + sName + "Time'));getToday($('" + sName + "'));\">"
                + "&nbsp;" + writeTimeField(sName + "Time", formatSQLDate(dValue, "HH:mm"))
                + "&nbsp;" + getTran("web.occup", "medwan.common.hour", sWebLanguage);
    }
    static public String planningDateTimeField(String sName, String dValue, String sWebLanguage, String sCONTEXTDIR) {
        return "<input id='" + sName + "' type='text' maxlength='10' class='text' name='" + sName + "' value='" + dValue + "' size='12' onblur='if(!checkDate(this)){alert(\"" + HTMLEntities.htmlentities(getTran("Web.Occup", "date.error", sWebLanguage)) + "\");this.value=\"\";}'>"
                + "&nbsp;<img name='popcal' class='link' src='" + sCONTEXTDIR + "/_img/icon_agenda.gif' alt='" + HTMLEntities.htmlentities(getTran("Web", "Select", sWebLanguage)) + "' onclick='gfPop1.fPopCalendar($(\"" + sName + "\"));return false;'>"
                + "&nbsp;<img class='link' src='" + sCONTEXTDIR + "/_img/icon_compose.gif' alt='" + HTMLEntities.htmlentities(getTran("Web", "PutToday", sWebLanguage)) + "' onclick=\"getToday($('" + sName + "'));\">";
    }
    //--- WRITE DATEE FIELD WITHOUT TODAY ---------------------------------------------------------
    static public String writeDateFieldWithoutToday(String sName, String sForm, String sValue, boolean allowPastDates, boolean allowFutureDates, String sWebLanguage, String sCONTEXTDIR) {
        String gfPopType = "1"; // default
        if(allowPastDates && allowFutureDates){
            gfPopType = "1";
        }
        else{
          if(allowFutureDates){ gfPopType = "3"; }
          else if(allowPastDates) { gfPopType = "2"; }
        }

        return "<input type='text' maxlength='10' class='text' id='"+sName+"' name='"+sName+"' value='"+sValue+"' size='12' onblur='if(!checkDate(this)){alert(\""+HTMLEntities.htmlentities(getTran("Web.Occup","date.error",sWebLanguage))+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' style='vertical-align:-1px;' onclick='gfPop"+gfPopType+".fPopCalendar(document."+sForm+"."+sName+");return false;' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+HTMLEntities.htmlentities(getTran("Web","Select",sWebLanguage))+"'></a>";
    }

    //--- CHECK PERMISSION ------------------------------------------------------------------------
    static public String checkPermission(String sScreen, String sPermission, User activeUser,
                                         boolean screenIsPopup, String sAPPFULLDIR) {
        sPermission = sPermission.toLowerCase();
        String jsAlert = "Error in checkPermission : no screen specified !";

        if (sScreen.trim().length()>0) {
            if (Application.isDisabled(sScreen)){
            
            }
            else if (activeUser!=null && activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0){
                jsAlert = "";
            }
            else{
                // screen and permission specified
                if (sPermission.length() > 0 && !sPermission.equals("all")){
                    if(sPermission.equals("none")) jsAlert = "";
                    else if(activeUser.getAccessRight(sScreen+"."+sPermission)) {
                        jsAlert = "";
                    }
                }
                // no permission specified -> interprete as all permissions required
                // Manageing a page, means you can add, edit and delete.
                else if (activeUser.getAccessRight(sScreen + ".edit") &&
                         activeUser.getAccessRight(sScreen + ".add") &&
                         //activeUser.getAccessRight(sScreen + ".select") &&
                         activeUser.getAccessRight(sScreen + ".delete")) {
                    jsAlert = "";
                }

                if(jsAlert.length() > 0){
                    String sMessage = getTranNoLink("web","nopermission",activeUser.person.language);

                    jsAlert = "<script>"+
                              "  var popupUrl = '"+sAPPFULLDIR+"/_common/search/okPopup.jsp?ts="+getTs()+"&labelValue="+sMessage;

                    // display permission when in Debug mode
                    if(Debug.enabled) jsAlert+= " --> "+sScreen+(sPermission.length()==0?"":"."+sPermission);

                    jsAlert+= "';"+
                              "  var modalities = 'dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;';"+
                              "   var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,\"\",modalities):window.confirm(\""+sMessage+"\");"+
                              (screenIsPopup?"window.close();":"window.history.go(-1);return false;")+
                              "</script>";
                }
            }
        }

        return jsAlert;
    }

    //--- WRITE SEARCH BUTTON ---------------------------------------------------------------------
    static public String writeSearchButton(String sButtonName, String sLabelType, String sVarCode, String sVarText,
                                           String sShowID, String sWebLanguage, String sCONTEXTDIR) {
        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +"onclick='openPopup(\"_common/search/searchScreen.jsp&LabelType="+sLabelType+"&VarCode="+sVarCode+"&VarText="+sVarText+"&ShowID="+sShowID+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sVarCode+".value='';"+sVarText+".value='';\">";
    }

    static public String writeSearchButton(String sButtonName, String sLabelType, String sVarCode, String sVarText,
                                           String sShowID,String sWebLanguage, String defaultValue, String sCONTEXTDIR) {
        return  "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +" onclick='openPopup(\"_common/search/searchScreen.jsp&LabelType="+sLabelType+"&VarCode="+sVarCode+"&VarText="+sVarText+"&ShowID="+sShowID+"&DefaultValue="+defaultValue+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sVarCode+".value='';"+sVarText+".value='';\">";
    }

    //--- WRITE SERVICE BUTTON --------------------------------------------------------------------
    static public String writeServiceButton(String sButtonName, String sVarCode, String sVarText,String sWebLanguage, String sCONTEXTDIR) {
        return writeServiceButton(sButtonName,sVarCode,sVarText,false,sWebLanguage,sCONTEXTDIR);
    }

    static public String writeServiceButton(String sButtonName, String sVarCode, String sVarText,
                                            boolean onlySelectContractWithDivision, String sWebLanguage, String sCONTEXTDIR) {
        return  "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"'"
              +"onclick='openPopup(\"_common/search/searchService.jsp&VarCode="+sVarCode+"&VarText="+sVarText+"&onlySelectContractWithDivision="+onlySelectContractWithDivision+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\"document.all['"+sVarCode+"'].value='';document.all['"+sVarText+"'].value='';\">";
    }

    //--- WRITE SELECT (SORTED) -------------------------------------------------------------------
    static public String writeSelect(String sLabelType, String sSelected,String sWebLanguage) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,false,true);
    }

    static public String writeSelect(String sLabelType, String sSelected,String sWebLanguage, boolean showLabelID) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,showLabelID,true);
    }

    //--- WRITE SELECT UNSORTED -------------------------------------------------------------------
    static public String writeSelectUnsorted(String sLabelType, String sSelected, String sWebLanguage) {
        return writeSelect(sLabelType,sSelected,sWebLanguage,false,false);
    }

    //--- WRITE SELECT ----------------------------------------------------------------------------
    static public String writeSelect(String sLabelType, String sSelected, String sWebLanguage, boolean showLabelID, boolean sorted){
        String sOptions = "";
        Label label;
        Iterator it;

        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        if (labelTypes!=null) {
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
                    if (sLabelID.toLowerCase().equals(sSelected.toLowerCase())) {
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

    static public String writeSelectExclude(String sLabelType, String sSelected, String sWebLanguage, boolean showLabelID, boolean sorted, String sExclude){
        String sOptions = "";
        Label label;
        Iterator it;

        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        if (labelTypes!=null) {
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
                        if (sLabelID.toLowerCase().equals(sSelected.toLowerCase())) {
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
    static public String writeZipcodeButton(String sButtonName, String sZipcode, String sCity, String sWebLanguage, String sCONTEXTDIR) {
        String sSearch = sZipcode+".value";

        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"' "
              +"onclick='openPopup(\"_common/search/searchZipcode.jsp&VarCode="+sZipcode+"&VarText="+sCity+"&FindText=\"+"+sSearch+");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sZipcode+".value='';"+sCity+".value='';\">";
    }

    static public String writeZipcodeButton(String sButtonName, String sZipcode, String sCity, String sWebLanguage, String sDisplayLang, String sCONTEXTDIR) {
        String sSearch = sZipcode+".value";

        return "<img src='"+sCONTEXTDIR+"/_img/icon_search.gif' id='"+sButtonName+"' class='link' alt='"+getTran("Web","select",sWebLanguage)+"' "
              +"onclick='openPopup(\"_common/search/searchZipcode.jsp&VarCode="+sZipcode+"&VarText="+sCity+"&FindText=\"+"+sSearch+"+\"&DisplayLang="+sDisplayLang+"\");'>"
              +"&nbsp;<img src='"+sCONTEXTDIR+"/_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick=\""+sZipcode+".value='';"+sCity+".value='';\">";
    }

    //--- SAVE UNKNOWN LABEL ----------------------------------------------------------------------
    static public void saveUnknownLabel(String sLabelType, String sLabelID, String sLabelLang) {
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
    static public String checkString(String sString) {
        // om geen 'null' weer te geven
        if ((sString==null)||(sString.toLowerCase().equals("null"))) {
            return "";
        }
        else {
            sString = sString.trim();
        }
        return sString;
    }

    //--- GET ADMIN PRIVATE CONTACT ---------------------------------------------------------------
    static public AdminPrivateContact getActivePrivate(AdminPerson person) {
        AdminPrivateContact apcActive = null;
        AdminPrivateContact apc;

        for (int i=0; i<person.privateContacts.size(); i++) {
            apc = ((AdminPrivateContact)(person.privateContacts.elementAt(i)));
            if (apc.end==null || apc.end.trim().equals("")) {
                try {
                    if (apcActive==null || stdDateFormat.parse(apc.begin).after(stdDateFormat.parse(apcActive.begin))){
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
    static public String replace(String sValue, String sSearch, String sReplace) {
        String sResult = "", sLeft = sValue;

        int iIndex = sLeft.indexOf(sSearch);
        if (iIndex > -1) {
            while (iIndex > -1) {
                sResult += sLeft.substring(0,iIndex)+sReplace;
                sLeft = sLeft.substring(iIndex+1,sLeft.length());
                iIndex = sLeft.indexOf(sSearch);
            }
            sResult += sLeft;
        }
        else {
            sResult = sValue;
        }

        return sResult;
    }

    //--- GET TS ----------------------------------------------------------------------------------
    static public String getTs() {
        return new java.util.Date().hashCode()+"";
    }

    //--- GET DATE --------------------------------------------------------------------------------
    static public String getDate() {
        return stdDateFormat.format(new java.util.Date());
    }

    //--- FORMAT DATE -----------------------------------------------------------------------------
    static public String formatDate(java.util.Date dDate) {
        String sDate = "";
        if(dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET DATE --------------------------------------------------------------------------------
    static public java.util.Date getDate(java.util.Date date) throws Exception{
        return stdDateFormat.parse(stdDateFormat.format(date));
    }

    //--- WRITE TABLE FOOTER ----------------------------------------------------------------------
    static public String writeTblFooter() {
        return "</table></td></tr></td></tr></table>";
    }

    //--- WRITE TABLE HEADER ----------------------------------------------------------------------
    static public String writeTblHeader(String sHeader, String sCONTEXTDIR) {
        return "<table border='0' cellspacing='0' cellpadding='0' class='menu' width='100%'>"+
               "<tr class='admin'><td width='100%'>&nbsp;&nbsp;"+sHeader+"&nbsp;&nbsp;</td></tr>"+
               "<tr><td><img src='"+sCONTEXTDIR+"/_img/pix_bl.gif' alt='' width='100' height='1' border='0'></td></tr>"+
               "<tr><td><table width='100%' cellspacing='0'>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    static public String writeTblChild(String sPath, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <button class='buttoninvisible' accesskey='"+getAccessKey(sHeader)+"' onclick='window.location.href=\""+sCONTEXTDIR+"/"+sPath+"\"'></button><a href='"+sCONTEXTDIR+"/"+sPath+"' class='menuItem' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    static public String writeTblChildNoButton(String sPath, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <a href='"+sCONTEXTDIR+"/"+sPath+"' class='menuItem' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    static public String writeTblChildWithCode(String sCommand, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <button class='buttoninvisible' accesskey='"+getAccessKey(sHeader)+"' onclick='"+sCommand+"'></button><a href='"+sCommand+"' class='menuItem' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- WRITE TABLE CHILD -----------------------------------------------------------------------
    static public String writeTblChildWithCodeNoButton(String sCommand, String sHeader, String sCONTEXTDIR) {
        return "<tr>"+
               " <td class='arrow'><img src='"+sCONTEXTDIR+"/_img/pijl.gif'></td>"+
               " <td width='99%' nowrap>"+
               "  <a href='"+sCommand+"' class='menuItem' onMouseOver=\"window.status='';return true;\">"+sHeader+"</a>&nbsp;"+
               " </td>"+
               "</tr>";
    }

    //--- GET ACCESS KEY --------------------------------------------------------------------------
    static public String getAccessKey(String label){
        label=label.toLowerCase();
        if (label.indexOf("<u>")>-1 && label.indexOf("</u>")>-1){
            return label.substring(label.indexOf("<u>")+3,label.indexOf("</u>"));
        }
        return "";
    }

    //--- SET RIGHT CLICK -------------------------------------------------------------------------
    static public String setRightClick(String itemType){
        return "onclick='this.className=\"selected\"' "+
               "onchange='this.className=\"selected\";setPopup(\"be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"\",this.value)' "+
               "onkeyup='this.className=\"selected\";setPopup(\"be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"\",this.value)' "+
               "onmouseover=\"this.style.cursor='help';setPopup('be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"',this.value);activeItem=true;setItemsMenu(true);\" "+
               "onmouseout=\"this.style.cursor='default';activeItem=false;\" ";
    }

    //--- SET RIGHT CLICK MINI --------------------------------------------------------------------
    static public String setRightClickMini(String itemType){
        return "onmouseover=\"this.style.cursor='help';setPopup('be.mxs.common.model.vo.healthrecord.IConstants."+itemType+"',this.value);activeItem=true;setItemsMenu(true);\" "+
               "onmouseout=\"this.style.cursor='default';activeItem=false;document.oncontextmenu=function(){return true};\" ";
    }

    //--- GET DEFAULTS ----------------------------------------------------------------------------
    static public String getDefaults(HttpServletRequest request) throws SessionContainerFactoryException {
        // defaults
        String defaults = ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemDefaultsHTML();
        defaults += "<script>function loadDefaults(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if (document.all['DefaultValue_'+document.all[n].name]!=null) {"
                    +"if (document.all[n].type=='text') {document.all[n].value=document.all['DefaultValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='textarea') {document.all[n].value=document.all['DefaultValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='radio' && document.all[n].value==document.all['DefaultValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='checkbox' && document.all[n].value==document.all['DefaultValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if (document.all[n].options[m].value==document.all['DefaultValue_'+document.all[n].name].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        // previous
        defaults += ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemPreviousHTML();
        defaults += "<script>function loadPrevious(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if (document.all['PreviousValue_'+document.all[n].name]!=null) {"
                    +"if (document.all[n].type=='text') {document.all[n].value=document.all['PreviousValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='textarea') {document.all[n].value=document.all['PreviousValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='radio' && document.all[n].value==document.all['PreviousValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='checkbox' && document.all[n].value==document.all['PreviousValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if (document.all[n].options[m].value==document.all['PreviousValue_'+document.all[n].name].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        // previous context
        defaults += ((SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName())).getItemPreviousContextHTML();
        defaults += "<script>function loadPreviousContext(){"
                    +"for (n=0;n<document.all.length;n++){"
                    +"if (document.all['PreviousContextValue_'+document.all[n].name]!=null) {"
                    +"if (document.all[n].type=='text') {document.all[n].value=document.all['PreviousContextValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='textarea') {document.all[n].value=document.all['PreviousContextValue_'+document.all[n].name].value;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='radio' && document.all[n].value==document.all['PreviousContextValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='checkbox' && document.all[n].value==document.all['PreviousContextValue_'+document.all[n].name].value) {document.all[n].checked=true;document.all[n].className='modified'}"
                    +"if (document.all[n].type=='select-one') {for(m=0;m<document.all[n].options.length;m++){if (document.all[n].options[m].value==document.all['PreviousContextValue_'+document.all[n].name].value){document.all[n].selectedIndex=m;document.all[n].className='modified'}}}"
                    +"}"
                    +"}"
                    +"}</script>";

        return defaults;
    }

    //--- FORMAT SQL DATE -------------------------------------------------------------------------
    static public String formatSQLDate(Date dDate, String sFormat) {
        String sDate = "";
        if (dDate!=null) {
            sDate = new SimpleDateFormat(sFormat).format(dDate);
        }
        return sDate;
    }

    static public String formatSQLDate(java.util.Date dDate, String sFormat) {
        String sDate = "";
        if (dDate!=null) {
            sDate = new SimpleDateFormat(sFormat).format(dDate);
        }
        return sDate;
    }

    //--- GET SQL STRING --------------------------------------------------------------------------
    static public String setSQLString(String sValue) {
        if (sValue!=null && sValue.trim().length()>249) {
            sValue = sValue.substring(0,249);
        }
        return sValue;
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    static public String getSQLTime(Time tTime) {
        String sTime = "";
        if (tTime!=null) {
            sTime = tTime.toString();
            sTime = sTime.substring(0,sTime.lastIndexOf(":"));
        }
        return sTime;
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    static public java.sql.Timestamp getSQLTime() {
        return new java.sql.Timestamp(new java.util.Date().getTime()); // now
    }

    //--- GET SQL TIME STAMP ----------------------------------------------------------------------
    static public String getSQLTimeStamp(java.sql.Timestamp timeStamp) {
        String ts = "";
        if (timeStamp != null) {
            ts = fullDateFormat.format(new Date(timeStamp.getTime()));
        }
        return ts;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    static public String getSQLDate(java.sql.Date dDate) {
        String sDate = "";
        if (dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    static public String getSQLDate(java.util.Date dDate) {
        String sDate = "";
        if (dDate!=null) {
            sDate = stdDateFormat.format(dDate);
        }
        return sDate;
    }

    //--- GET SQL DATE ----------------------------------------------------------------------------
    static public java.sql.Date getSQLDate(String sDate) {
        try {
            if(sDate==null || sDate.trim().length()==0 || sDate.trim().length()<5 || sDate.equals("&nbsp;")) {
                return null;
            }
            else {
                sDate=sDate.replaceAll("-","/");
                return new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sDate).getTime());
            }
        }
        catch(Exception e) {
            return null;
        }
    }

    //--- GET DATE ADD ----------------------------------------------------------------------------
    static public String getDateAdd(String sDate, String sAdd) {
        try {
            if(sDate==null || sDate.trim().length()==0 || sDate.trim().length()<5 || sDate.equals("&nbsp;")) {
                return null;
            }
            else {
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
    static public String writeJSButtons(String sMyForm, String sMyButton, String sCONTEXTDIR) {
        return "<script>var myForm = document.getElementById('"+sMyForm+"'); var myButton = document.getElementById('"+sMyButton+"');</script>"+
               "<script src='"+sCONTEXTDIR+"/_common/_script/buttons.js'></script>";
    }

    //--- SET INCLUDE PAGE ------------------------------------------------------------------------
    static public void setIncludePage(String sPage, PageContext pageContext) {
        // ? or &
        if(sPage.indexOf("?")<0){
            if(sPage.indexOf("&")>-1){
                sPage=sPage.substring(0,sPage.indexOf("&"))+"?"+sPage.substring(sPage.indexOf("&")+1);
                if(sPage.indexOf("ts=")<0){
                    sPage+= "&ts="+new java.util.Date().getTime();
                }
            }
            else {
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
    static public String writeTimeField(String sName, String sValue){
        return "<input id='"+sName+"' type='text' class='text' name='"+sName+"' value='"+sValue+"' onblur='checkTime(this)' size='5'>";
    }

    //--- GET SQL TIME STAMP ----------------------------------------------------------------------
    static public void getSQLTimestamp(PreparedStatement ps, int iIndex, String sDate, String sTime) {
        try{
            if (sDate == null || sDate.trim().length()==0) {
                ps.setNull(iIndex,Types.TIMESTAMP);
            }
            else{
                if (sTime == null || sTime.trim().length()==0){
                    ps.setDate(iIndex,getSQLDate(sDate));
                }
                else {
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

    static public void getSQLTimestamp(PreparedStatement ps, int iIndex, java.util.Date date) {
        try{
            if (date == null) {
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
    static public String getCookie(String cookiename, HttpServletRequest request) {
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
    static public void setCookie(String cookiename, String value, HttpServletResponse response) {
        Cookie cookie = new Cookie(cookiename,value);
        cookie.setMaxAge(365);
        response.addCookie(cookie);
    }

    //--- CHECK DB STRING -------------------------------------------------------------------------
    static public String checkDbString(String sString) {
        sString=checkString(sString);
        if (sString.trim().length()>0) {
            sString = sString.replaceAll("'","´");
        }
        return sString;
    }

/////////////////////////////////////////////////////////////////////////////////////////////
    static public String alignButtonsStart() {
      return "<p align='center'>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    static public String alignButtonsStop() {
      return "</p>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    static public String setFormButtonsStart(){
        return "<tr>" +
                    "<td class='admin'/>" +
                    "<td class='admin2'>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    static public String setFormButtonsStop(){
        return      "</td>" +
                "</tr>";
    }
////////////////////////////////////////////////////////////////////////////////////////////
    static public String setSearchFormButtonsStart(){
        return "<tr><td/><td>";
    }
/////////////////////////////////////////////////////////////////////////////////////////////
    static public String setSearchFormButtonsStop(){
        return "</td></tr>";
    }
////////////////////////////////////////////////////////////////////////////////////////////
    static public String getFullPersonName(String personId,Connection dbConnection){
        String sReturn = "";

        if (checkString(personId).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = "SELECT lastname, firstname FROM Admin WHERE personid = ?";

            try{
                ps = dbConnection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(personId));
                rs = ps.executeQuery();

                if(rs.next()){
                    sReturn = checkString(rs.getString("lastname")) + " " + checkString(rs.getString("firstname"));
                }
            }catch(Exception e){
                e.printStackTrace();
            }finally{
                try{
                    if(rs!=null)rs.close();
                    if(ps!=null)ps.close();
                }catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
        return sReturn;
    }

    //--- GET FULL USER NAME ----------------------------------------------------------------------
    static public String getFullUserName(String userId, Connection conn){
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

        return otherExams;
    }

    static public String writeDateTimeField(String sName, String sForm, java.util.Date dValue, String sWebLanguage, String sCONTEXTDIR) {
        return "<input type='text' maxlength='10' class='text' name='"+sName+"' value='"+getSQLDate(dValue)+"' size='12' onblur='if(!checkDate(this)){alert(\""+getTran("Web.Occup","date.error",sWebLanguage)+"\");this.value=\"\";}'>"
              +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTDIR+"/_img/icon_agenda.gif' alt='"+getTran("Web","Select",sWebLanguage)+"' onclick='gfPop1.fPopCalendar(document."+sForm+".all[\""+sName+"\"]);return false;'>"
              +"&nbsp;<img class='link' src='"+sCONTEXTDIR+"/_img/icon_compose.gif' alt='"+getTran("Web","PutToday",sWebLanguage)+"' onclick=\"getToday(document."+sForm+".all['"+sName+"']);getTime(document."+sForm+".all['"+sName+"Time'])\">"
              +"&nbsp;"+writeTimeField(sName+"Time", formatSQLDate(dValue,"HH:mm"))
              +"&nbsp;"+getTran("web.occup","medwan.common.hour",sWebLanguage);
    }

    static public java.util.Date getSQLTime(String sTime) {
        java.util.Date date = null;

        if (sTime.length()>0){
            try{
                date = new SimpleDateFormat().parse(sTime);
            }
            catch (Exception e){
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
            if (sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0
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
            if (sessionContainerWO.getHealthRecordVO() != null && sessionContainerWO.getCurrentTransactionVO() != null) {
                ItemVO actualItem = sessionContainerWO.getCurrentTransactionVO().getItem(sType);
                if (actualItem == null || actualItem.getItemId().intValue() < 0) {
                    ItemVO lastItem = MedwanQuery.getInstance().getLastItemVO(sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(), sType);
                    if (lastItem == null) {
                        if (sessionContainerWO.getCurrentTransactionVO().getItem(sType) != null) {
                            return sessionContainerWO.getCurrentTransactionVO().getItem(sType);
                        }
                    } else {
                        return lastItem;
                    }
                } else {
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
/*************************/
    static public String newCounter(String sCounterName, Connection connection){
// gets a new countervalue
/*************************/
        try {
            String sSelect = " SELECT counter FROM Counters WHERE name = ? ";
            PreparedStatement ps = connection.prepareStatement(sSelect);
            ps.setString(1,sCounterName);
            ResultSet rs = ps.executeQuery();
	        String sCounterValue;

            if (rs.next()) {
                sCounterValue = rs.getString("counter");
                sSelect = " UPDATE Counters SET counter = counter + 1 WHERE name = ? ";
                rs.close();
                ps.close();
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,sCounterName);
                ps.executeUpdate();
                ps.close();

                sSelect = " SELECT counter -1 AS CounterValue FROM Counters WHERE name = ? ";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,sCounterName);
                rs = ps.executeQuery();

                if (rs.next()) {
                    String sNewCounterValue = rs.getInt("CounterValue")+"";

                    if (!sNewCounterValue.equals(sCounterValue)){
                        try {
                            Thread.sleep(new Random().nextInt(500));
                        } catch (InterruptedException e) {
                            writeMessage("Helper (newCounter 1) "+e.getMessage());
                        }
                        sCounterValue = newCounter(sCounterName,connection);
                    }
                }
                rs.close();
                ps.close();
            }
            else{
                rs.close();
                ps.close();
                sSelect = " INSERT Counters (name, counter) VALUES (?,2) ";
                sCounterValue = "1";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,sCounterName);
   	            ps.executeUpdate();
                ps.close();
            }

            return sCounterValue;
        }
        catch(SQLException e) {
            writeMessage("Helper (newCounter) "+e.getMessage());
        }
	    return "";
    }

/*************************/
    static public void writeMessage(String sMessage){
//  writes an errormessage to the screen and/or file
/*************************/
 	    if(Debug.enabled) Debug.println(sMessage);
    }

    //--- CHECK SPECIAL CHARACTERS ----------------------------------------------------------------
    // this function is used by DBSynchroniser and AdminPerson
    static public String checkSpecialCharacters(String sTest){
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
    static public void setSQLDate(PreparedStatement ps, int iIndex, String sDate) {
        try{
            if ((sDate == null)||(sDate.trim().length()==0)) {
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

    public static String padLeft(String s,String padCharacter,int size){
        int i=s.length();
        for(int n=0;n<size-i;n++){
            s=padCharacter+s;
        }
        return s;
    }

    public static String padRight(String s,String padCharacter,int size){
        int i=s.length();
        for(int n=0;n<size-i;n++){
            s=s+padCharacter;
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
