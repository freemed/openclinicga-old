<%@ taglib uri="/WEB-INF/struts-template.tld" prefix="template" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri='/WEB-INF/mxs-taglib.tld' prefix='mxs' %>
<%@ taglib uri="/WEB-INF/c-1_0.tld" prefix="c" %>
<%@ page info="checks out user on every page" %>
<%@ page import="net.admin.*,
                 java.text.SimpleDateFormat,
                 be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                 be.mxs.webapp.wl.session.SessionContainerFactory,
                 be.mxs.common.util.system.Debug,
                 be.mxs.common.util.system.ScreenHelper,
                 java.sql.*,
                 be.mxs.common.model.vo.healthrecord.TransactionVO,
                 be.mxs.common.model.vo.healthrecord.ItemVO,
                 org.dom4j.io.SAXReader,
                 java.net.URL,
                 org.dom4j.Document,
                 org.dom4j.Element,
                 java.io.IOException,
                 be.openclinic.common.ObjectReference,
                 be.openclinic.adt.Encounter,
                 be.openclinic.system.Config,
                 be.dpms.medwan.common.model.vo.authentication.UserVO,java.util.regex.*,be.mxs.common.util.db.MedwanQuery" %>
<%@ page import="net.admin.system.AccessLog" %>
<%@ page import="java.util.*" %>

<%!
    String sAPPTITLE = "Openclinic";
    String sWEBTITLE = "MXS - "+MedwanQuery.getInstance().getConfigString("edition").toUpperCase();
    String sAPPDIR = "";
    String sAPPFULLDIR = "";
    String sBackgroundColor = "CEFFCE;";
    String sCONTEXTPATH = "/openclinic";
    String sTextWidth = "70";
    String sTextareaCols = "68";
    String sTextAreaRows = "2";
    String[] sCOLORS = {"#E6BC56", "#FF4A12", "#94B3C5", "#ABC507","#74C6F1","#3E4F4F","#D1E26A","#C24798","#4096EE","#FF0084","#008C00"};


    //--- CHECK STRING ----------------------------------------------------------------------------
    public String checkString(String sString) {
        return ScreenHelper.checkString(sString);
    }

    //--- GET DATE --------------------------------------------------------------------------------
    public String getDate() {
        return ScreenHelper.getDate();
    }

    //-- SET RIGHTCLICK ---------------------------------------------------------------------------
    public String setRightClick(String itemType) {
        return ScreenHelper.setRightClick(itemType);
    }

    //--- SET RIGHTCLICK MINI ---------------------------------------------------------------------
    public String setRightClickMini(String itemType) {
        return ScreenHelper.setRightClickMini(itemType);
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    public String getSQLTime(Time tTime) {
        return ScreenHelper.getSQLTime(tTime);
    }

    //-- SET SQL STRING ---------------------------------------------------------------------------
    public String setSQLString(String sValue) {
        return ScreenHelper.setSQLString(sValue);
    }

    //--- GET SQL TIME ----------------------------------------------------------------------------
    public java.sql.Timestamp getSQLTime() {
        return ScreenHelper.getSQLTime();
    }

    //--- GET SQL TIME STAMP ----------------------------------------------------------------------
    public String getSQLTimeStamp(java.sql.Timestamp tStamp) {
        return ScreenHelper.getSQLTimeStamp(tStamp);
    }

    //--- WRITE TABEL CHILD -----------------------------------------------------------------------
    public String writeTblChild(String sPath, String sHeader) {
        return ScreenHelper.writeTblChild(sPath, sHeader, sCONTEXTPATH);
    }

    //--- WRITE TABEL CHILD -----------------------------------------------------------------------
    public String writeTblChildNoButton(String sPath, String sHeader) {
        return ScreenHelper.writeTblChildNoButton(sPath, sHeader, sCONTEXTPATH);
    }

    public String writeTblChildWithCode(String sCommand, String sHeader) {
        return ScreenHelper.writeTblChildWithCode(sCommand, sHeader, sCONTEXTPATH);
    }

    public String writeTblChildWithCodeNoButton(String sCommand, String sHeader) {
        return ScreenHelper.writeTblChildWithCodeNoButton(sCommand, sHeader, sCONTEXTPATH);
    }

    //--- GET TS ----------------------------------------------------------------------------------
    public String getTs() {
        return ScreenHelper.getTs();
    }

    //--- SET TYPE ITEM TO SHORT STRING ------------------------------------------------------------
    public String[] setTypeToShort(String type) {
        String[] result = new String[2];
        String re1 = ".*";    // Non-greedy match on filler
        String re2 = "(ICONSTANTS)";    // Word 1
        String re3 = "(.?)";    // Non-greedy match on filler
        String re4 = "(.*)";    // Word 2
        Pattern p = Pattern.compile(re1 + re2 + re3 + re4, Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
        Matcher m = p.matcher(type);
        if (m.find()) {

            result[0] = m.group(3);

        } else {
            result[0] = type;
        }
        result[1] = type;
        return result;
    }

    //--- GET SELECTED ITEMS FROM USER FOR AUTOCOMPLETION FIELDS ------------------------------------------------------------
    public java.util.List getItemTypeFromUser(String type, int user) {
        java.util.List itemsTypes = MedwanQuery.getInstance().getAllAutocompleteTypeItemsByUser(user);
        String re1 = ".*";    // Non-greedy match on filler
        String re2 = "(" + type + ")";    // Word 1
        String re3 = "(.?)";    // Non-greedy match on filler
        String re4 = "(.*)";    // Word 2
        Iterator it = itemsTypes.iterator();
        while (it.hasNext()) {
            type = (String) it.next();
            // test if type exists in item type string //
            Pattern p = Pattern.compile(re1 + re2 + re3 + re4, Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
            Matcher m = p.matcher(type);
            if (!m.find()) {
                // if net es-xists remove then from the list //
                it.remove();
            }

        }
        return itemsTypes;
    }

    //--- REPEAT ----------------------------------------------------------------------------------
    public String repeat(String sChar, int amount) {
        String repetition = "";

        for (int i = 0; i < amount; i++) {
            repetition += sChar;
        }

        return repetition;
    }

    public String writeTextarea(String sName, String sCols, String sRows, String sOther, String sValue) {
        if (sCols.trim().length() == 0) {
            sCols = sTextareaCols;
        }
        if (sRows.trim().length() == 0) {
            sRows = sTextAreaRows;
        }

        return "<textarea id='"+sName+"' name='" + sName + "' cols='" + sCols + "' rows='" + sRows + "' onKeyup='resizeTextarea(this,10);' class='text' " + sOther + ">" + sValue + "</textarea>";
    }

    //--- GET CONFIG STRING DB --------------------------------------------------------------------
    public String getConfigStringDB(String key, Connection connection) {
        String cs = Config.getNotDeletedConfigByKey(key);
        return ScreenHelper.checkString(cs);
    }

    //--- SET CONFIG STRING DB --------------------------------------------------------------------
    public void setConfigStringDB(String key, String value, Connection connection) {
        Config.deleteConfig(key);
        // insert
        Config.insert(key, value);
    }

    //--- CONTEXT HEADER --------------------------------------------------------------------------
    public String contextHeader(HttpServletRequest request, String language) {
        return contextHeader(request, language, true);
    }

    public String contextHeader(HttpServletRequest request, String language, String subTitle) {
        return contextHeader(request, language, true, subTitle);
    }

    public String contextHeader(HttpServletRequest request, String language, boolean setBackGround) {
        return contextHeader(request, language, setBackGround, "");
    }

    public String contextHeader(HttpServletRequest request, String language, boolean setBackGround, String subTitle) {
        String result = "<table width='100%' cellspacing='0'>";

        // background ?
        // - "manageClinicalExamination_view" : background of contextHeader interferes with existing background.
        if (setBackGround) {
            result += "<tr class='admin' height='25'>";
        } else {
            result += "<tr class='admin' style='background-image:none;'>";
        }

        result += "<td nowrap>";

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());

            String currentContext = sessionContainerWO.getFlags().getContext();
            Debug.println("Current context=" + currentContext);
            TransactionVO transactionVO = sessionContainerWO.getCurrentTransactionVO();

            ItemVO itemVO = null;
            if (transactionVO != null) {
                itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                if (itemVO != null) {
                    currentContext = itemVO.getValue();
                }

                if (transactionVO.getTransactionId().intValue() < 0) {
                    // NEW
                    Collection colTrans = sessionContainerWO.getTransactionsLimited();
                    TransactionVO lastTransactionVO = null;

                    if (colTrans.size() > 0) {
                        Iterator iTrans = colTrans.iterator();
                        TransactionVO tmpVO;
                        while (iTrans.hasNext()) {
                            tmpVO = (TransactionVO) iTrans.next();
                            if (lastTransactionVO == null) {
                                lastTransactionVO = tmpVO;
                            } else if (lastTransactionVO.getUpdateTime().compareTo(tmpVO.getUpdateTime()) < 0) {
                                lastTransactionVO = tmpVO;
                            }
                        }
                    }

                    if (lastTransactionVO != null) {
                        SimpleDateFormat stdDateFormat = new SimpleDateFormat("yyyy/MM/dd");
                        String sToday = stdDateFormat.format(new java.util.Date());
                        String sTransDate = stdDateFormat.format(lastTransactionVO.getUpdateTime());

                        if (sToday.equals(sTransDate)) {
                            try {
                                ItemVO oldItemVO = lastTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                                if (oldItemVO != null) {
                                    currentContext = oldItemVO.getValue();
                                }
                            }
                            catch (Exception e) {
                                // nothing
                            }
                        }
                    }
                    currentContext = sessionContainerWO.getFlags().getContext();
                }

                result += "&nbsp;" + ScreenHelper.getTran("Web.Occup", transactionVO.getTransactionType(), language);

                // subtitle
                if (subTitle.length() > 0) {
                    result += " : " + subTitle;
                }
                // select active contact
                String activeEncounterUid="";
                ItemVO oldItemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                if (oldItemVO != null && oldItemVO.getValue().length()>0) {
                	activeEncounterUid = oldItemVO.getValue();
                }
                else {
	                AdminPerson activePatient = (AdminPerson)request.getSession().getAttribute("activePatient");
	                Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(transactionVO.getUpdateTime().getTime()),activePatient.personid);
	                if(activeEnc!=null){
	                	activeEncounterUid=activeEnc.getUid();
	                }
                }
                result += "&nbsp;<input type='hidden' name='currentTransactionVO.items.<ItemVO[hashCode="+oldItemVO.getItemId()+ "]>.value' id='encounteruid' value='"+activeEncounterUid+"'/>";
            }
            result += "</td>";

            // context selector
            result  +="<td>"+getLastTransactionAccess("T."+transactionVO.getServerId()+"."+transactionVO.getTransactionId(),language,request)+"</td>";
            result += "<td align='right' style='padding-top:2px;'>" + "<select id='ctxt' class='text' onchange=\"document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=" + itemVO.getItemId() + "]>.value')[0].value=this.value;show('content-details');if($('confirm'))hide('confirm');\">";
            UserVO user = sessionContainerWO.getUserVO();
            User activeUser = new User();
            activeUser.initialize(user.getUserId().intValue());
            net.admin.Service service;
            for (int i = 0; i < activeUser.vServices.size(); i++) {
                service = (net.admin.Service) activeUser.vServices.elementAt(i);
                result += "<option value='" + service.code + "'";
                if (service.code.equals(activeUser.activeService.code)) {
                    result += " selected";
                }
                result += ">" + getTran("Service", service.code, language) + "</option>";
            }
            result += "</select>&nbsp;";
            result += "<input id='confirm' type='button' value='OK' name='confirm' class='button' onclick=\"show('content-details');hide('confirm');\"/>";
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        result += "</td><td align='right'><a alt='"+getTran("Web", "Back", language)+"' title='"+getTran("Web", "Back", language)+"' class='previousButton' href='main.do?Page=curative/index.jsp&ts=" + ScreenHelper.getTs() + "'>&nbsp;</a>" + "</td></tr></table>" + "<div id='content-details' style='display:none'></div>" + "<script>document.getElementById('ctxt').onchange();</script>";

        return result;
    }
    public String getLastTransactionAccess(String sTrans, String sWebLanguage,HttpServletRequest request){
      String sReturn = "";
        SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy '"+getTranNoLink("web.occup"," - ",sWebLanguage)+"' HH:mm:ss");
             java.util.List l =  AccessLog.getLastAccess(sTrans,2);
             if(l.size()>1){
                 Object[] ss = (Object[])l.get(1);
                 Timestamp t = (Timestamp)ss[0];
                 Hashtable u = User.getUserName((String)ss[1]);
                 sReturn+= "<div style='float:right'><span style='font-weight:normal'>"+getTranNoLink("web.occup","last.access",sWebLanguage)+"  "+ dateformat.format(t)+" "+getTranNoLink("web","by",sWebLanguage)+" <b>"+u.get("firstname")+" "+u.get("lastname")+"</b></span>";
                 sReturn+=" | <a href='javascript:void(0)' onclick=\"Modalbox.show('"+sCONTEXTPATH+"/healthrecord/ajax/getTransHistoryAccess.jsp?ts="+getTs()+"&trans="+sTrans+"&nb=15', {title: '"+getTran("web", "history", sWebLanguage)+"', width: 420,height:370},{evalScripts: true} );\" class='link linkdark history' title='"+getTranNoLink("web","history",sWebLanguage)+"' alt=\""+getTranNoLink("web","history",sWebLanguage)+"\">...</a></div>";
             }

        return sReturn;
    }
    //--- GET TRAN -------------------------------------------------------------------------------
    public String getTran(String sType, String sID, String sWebLanguage) {
        return ScreenHelper.getTran(sType, sID, sWebLanguage);
    }

    public String getTran(String sType, String sID, String sWebLanguage, boolean displaySimplePopup) {
        return ScreenHelper.getTran(sType, sID, sWebLanguage, displaySimplePopup);
    }

    //--- GET TRAN NO LINK ------------------------------------------------------------------------
    public String getTranNoLink(String sType, String sID, String sLanguage) {
        return ScreenHelper.getTranNoLink(sType, sID, sLanguage);
    }

    //--- GET TRAN NO LINK ------------------------------------------------------------------------
    public String getTranExists(String sType, String sID, String sLanguage) {
        return ScreenHelper.getTranExists(sType, sID, sLanguage);
    }

    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(String sType, String sID, String sLanguage, String sObject) {
        return "<label for='" + sObject + "'>" + getTran(sType, sID, sLanguage) + "</label>";
    }

    //--- SET ROW ---------------------------------------------------------------------------------
    public String setRow(String sType, String sID, String sValue, String sLanguage) {
        return ScreenHelper.setRow(sType, sID, sValue, sLanguage);
    }

    //--- WRITE DATE FIELD ------------------------------------------------------------------------
    public String writeDateField(String sName, String sForm, String sValue, String sWebLanguage) {
        return ScreenHelper.writeDateField(sName, sForm, sValue, true, true, sWebLanguage, sCONTEXTPATH);
    }
    
    //--- WRITE DATE FIELD ------------------------------------------------------------------------
    public String writeDateField(String sName, String sForm, String sValue, String sWebLanguage, String sExtra) {
        return ScreenHelper.writeDateField(sName, sForm, sValue, true, true, sWebLanguage, sCONTEXTPATH, sExtra);
    }
    
    //--- WRITE FUTURE DATE FIELD (only future dates) ---------------------------------------------
    public String writeFutureDateField(String sName, String sForm, String sValue, String sWebLanguage) {
        return ScreenHelper.writeDateField(sName, sForm, sValue, false, true, sWebLanguage, sCONTEXTPATH);
    }
    
    //--- WRITE PAST DATE FIELD (only past dates) -------------------------------------------------
    public String writePastDateField(String sName, String sForm, String sValue, String sWebLanguage) {
        return ScreenHelper.writeDateField(sName, sForm, sValue, true, false, sWebLanguage, sCONTEXTPATH);
    }

    public String checkPrestationToday(String sPersonId, boolean screenIsPopup, User activeUser, TransactionVO transaction) {
    	return ScreenHelper.checkPrestationToday(sPersonId, sCONTEXTPATH, screenIsPopup, activeUser,transaction);
    }

    //--- CHECK PERMISSION (screen is a parent window) --------------------------------------------
    public String checkPermission(String sScreen, String sPermission, User activeUser) {
        return ScreenHelper.checkPermission(sScreen, sPermission, activeUser, false, sCONTEXTPATH);
    }

    //--- CHECK PERMISSION POPUP (screen is a popup) ----------------------------------------------
    public String checkPermissionPopup(String sScreen, String sPermission, User activeUser) {
        return ScreenHelper.checkPermission(sScreen, sPermission, activeUser, true, sCONTEXTPATH);
    }

    //--- WRITE JS BUTTONS ------------------------------------------------------------------------
    public String writeJSButtons(String sMyForm, String sMyButton) {
        return ScreenHelper.writeJSButtons(sMyForm, sMyButton, sCONTEXTPATH);
    }

    //--- STATUS ----------------------------------------------------------------------------------
    public void status(JspWriter out, String message) throws IOException {
        out.print("<script>window.status=\"" + message + "\";</script>");
        out.flush();
    }

    //--- CUSTOMER INCLUDE ------------------------------------------------------------------------
    public String customerInclude(String fileName) {
        return ScreenHelper.customerInclude(fileName, sAPPFULLDIR, sAPPDIR);
    }

    //--- GET WINDOW TITLE ------------------------------------------------------------------------
    public String getWindowTitle(HttpServletRequest request, String sWebLanguage) {
        String title = sAPPTITLE;
        AdminPerson activePatient = (AdminPerson) request.getSession().getAttribute("activePatient");

        if (activePatient != null && activePatient.personid.length() > 0 && "On".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("showAdminInTitleBar"))) {
            title += " - " + checkString(activePatient.lastname) + ", " + checkString(activePatient.firstname) + "   -    " + checkString(activePatient.getActivePrivate().address) + "    " + checkString(activePatient.getActivePrivate().zipcode) + " " + checkString(activePatient.getActivePrivate().city);
            if (checkString(activePatient.getActivePrivate().telephone).length() > 0) {
                title += "   Tel: " + activePatient.getActivePrivate().telephone;
            }
        }

        return title;
    }

    //--- WRITE TABLE HEADER ----------------------------------------------------------------------
    public String writeTableHeader(String sType, String sID, String sLanguage) {
        return writeTableHeader(sType, sID, sLanguage, "");
    }

    public String writeTableHeader(String sType, String sID, String sLanguage, String sPage) {
        String tableHeader = "<table  width='100%' cellspacing='0' class='list' style='border-bottom:none;'>"+
                              "<tr class='admin'>"+
                               "<td id='tableHeaderTitle'>"+getTran(sType, sID, sLanguage)+"</td>";

        if (sPage.trim().length() > 0) {
            tableHeader += "<td align='right'>";

            // sPage is a link
            if (sPage.indexOf("()") < 0) {
                tableHeader += "<a class='previousButton' alt='"+getTran("Web", "Back", sLanguage)+"' title='"+getTran("Web", "Back", sLanguage)+"' href='" + sPage + "'>&nbsp;</a>";
            }
            // sPage is a javascript function (like "doBack()")
            else {
                tableHeader += "<a class='previousButton' alt='"+getTran("Web", "Back", sLanguage)+"' title='"+getTran("Web", "Back", sLanguage)+"' href='javascript:" + sPage + "'>&nbsp;</a>";
            }

            tableHeader += "</td>";
        }

        tableHeader += " </tr>" +
                       "</table>";

        return tableHeader;
    }

    //--- GET TRAN DB -----------------------------------------------------------------------------
    public String getTranDb(String sType, String sID, String sLanguage) {
        return ScreenHelper.getTranDb(sType, sID, sLanguage);
    }

    //--- GET USER INTERVAL -----------------------------------------------------------------------
    public String getUserInterval(javax.servlet.http.HttpSession session, User activeUser) {
        // compute starttime
        String sJS = "starttime=new Date().getTime()+";

        if (checkString(activeUser.getParameter("Timeout")).length() > 0) {
            sJS += Integer.parseInt(activeUser.getParameter("Timeout")) * 1000;
        }
        else {
            sJS += session.getMaxInactiveInterval() * 1000;
        }

        sJS += ";";

        // function
        sJS += "function checkSessionForExpiration(){" +
                " if(new Date().getTime()>starttime){" +
                "  if(window.opener==null){" +
                "    window.location.href=\"" + sCONTEXTPATH + "/sessionExpired.jsp\";" +
                "  }" +
                "  else{" +
                "    window.close();" +
                "  }" +
                " }" +
                "}";

        // open setInterval function
        sJS += "userinterval=window.setInterval(";

        // put NOW and username in statusbar
        sJS += "'window.status=\"" + new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) + "  -  " + activeUser.person.firstname + " " + activeUser.person.lastname;

        // add medical centre to statusbar if medical center specified
        sJS += (checkString((String) (session.getAttribute("activeMedicalCenter"))).length() > 0 ? " (" + getTran("Web.Occup", "MedicalCenter", activeUser.person.language) + " = " + session.getAttribute("activeMedicalCenter") + ")" : "");

        // show remaining seconds till session expiration
        //sJS+= "  [\"+(Math.round((starttime-new Date().getTime())/1000))+\" seconds till session expiration]";

        sJS += "\";";

        // check if session expired
        sJS += "checkSessionForExpiration();";

        // close setInterval function
        sJS += "',2000);";

        return sJS;
    }

    //--- REPLACE ---------------------------------------------------------------------------------
    public String replace(String source, String target, String substitute) {
        return ScreenHelper.replace(source, target, substitute);
    }

    //--- TAKE OVER TRANSACTION -------------------------------------------------------------------
    public String takeOverTransaction(SessionContainerWO sessionContainerWO,
                                      User activeUser, String sFunction) {
        String sReturn = sFunction;
        TransactionVO tran = sessionContainerWO.getCurrentTransactionVO();

        if (tran != null) {
            if ((tran.getTransactionId().intValue() > 0) && (!activeUser.userid.equals(tran.getUser().getUserId().intValue() + ""))) {
                sReturn = "var url_source = '" + sCONTEXTPATH +
                        "/popup.jsp?Page=_common/search/takeOverTransaction.jsp&ts=" + getTs() +
                        "';" + "var modal_dim = 'dialogWidth:260px; dialogHeight:160px; center:yes;scrollbars:no; resizable:no; status:no; location:no;';" +
                        "var answer = window.showModalDialog(url_source,'',modal_dim);" + "if(answer==1){" +
                        "openPopup('/_common/search/takeOverTransactionSave.jsp&ts=" + getTs() +
                        "');" + "}" + sFunction;
            }
        }

        return sReturn;
    }

    //--- WRITE HISTORY FUNCTIONS -----------------------------------------------------------------
    public String writeHistoryFunctions(String transactionType, String sWebLanguage) {
        StringBuffer buf = new StringBuffer();

        buf.append("<script>")
                .append("  var historyPopup;");

        buf.append("function openHistoryPopup(){")
//                .append("  var url = '" + sCONTEXTPATH + sAPPDIR + "/healthrecord/managePrintHistoryPopup.do?transactionType=" + transactionType + "&ts=" + getTs() + "';")
                //              .append("  historyPopup = window.open(url,'History','height=1, width=1, toolbar=no, status=no, scrollbars=yes, resizable=yes, menubar=no');")
                .append("openPopup('/healthrecord/printHistoryPopup.jsp&transactionType=" + transactionType + "&ts=" + getTs() + "');")
                .append("}");

        buf.append("</script>");

        return buf.toString();
    }

    public String getObjectReferenceName(ObjectReference or, String sWebLanguage) {
        String sReturn = "";
        if ((or != null) && (or.getObjectUid() != null) && (or.getObjectUid().length() > 0)) {
            if (or.getObjectType().equalsIgnoreCase("person")) {
                String s = checkString(ScreenHelper.getFullPersonName(or.getObjectUid()));
                return s;
            } else if (or.getObjectType().equalsIgnoreCase("service")) {
                sReturn = getTranDb("service", or.getObjectUid(), sWebLanguage);
            }
        }
        return sReturn;
    }

    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    public String getItemType(Collection collection, String sItemType) {
        String sText = "";
        ItemVO item;
        Object[] aItems = collection.toArray();
        int i, y;

        for (i = 1; i < 6; i++) {
            for (y = 0; y < aItems.length; y++) {
                item = (ItemVO) aItems[y];
                if (item.getType().toLowerCase().equals(sItemType.toLowerCase() + i)) {
                    sText += checkString(item.getValue());
                }
            }
        }

        if (sText.trim().length() == 0) {
            for (y = 0; y < aItems.length; y++) {
                item = (ItemVO) aItems[y];
                if (item.getType().toLowerCase().equals(sItemType.toLowerCase())) {
                    sText += checkString(item.getValue());
                }
            }
        }

        return sText;
    }
    
    public void autoLogin(String username, String password,javax.servlet.http.HttpServletRequest request){
    	String ag = request.getHeader("User-Agent"), browser="", version="";
    	try{
    		int tmpPos; 
    		ag = ag.toLowerCase();
    		if (ag.contains("msie")) {
    			browser = "Internet Explorer";
    		    String str = ag.substring(ag.indexOf("msie") + 5);
    		    version = str.substring(0, str.indexOf(";"));
    		}
    		else if (ag.contains("opera")){
    			browser = "Opera";
    			ag=ag.substring(ag.indexOf("version"));
    			String str="";
    			if(ag.indexOf(" ")>-1){
    				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
    			    version = str.substring(0, str.indexOf(" "));
    			}
    			else{
    				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
    			}
    		}
    		else if (ag.contains("chrome")){
    			browser = "Chrome";
    			ag=ag.substring(ag.indexOf("chrome"));
    			String str="";
    			if(ag.indexOf(" ")>-1){
    				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
    			    version = str.substring(0, str.indexOf(" "));
    			}
    			else{
    				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
    			}
    		}
    		else if (ag.contains("firefox")){
    			browser = "Firefox";
    			ag=ag.substring(ag.indexOf("firefox"));
    			String str="";
    			if(ag.indexOf(" ")>-1){
    				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
    			    version = str.substring(0, str.indexOf(" "));
    			}
    			else{
    				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
    			}
    		}
    		else if (ag.contains("safari") && ag.contains("version")){
    			browser = "Safari";
    			ag=ag.substring(ag.indexOf("version"));
    			String str="";
    			if(ag.indexOf(" ")>-1){
    				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
    			    version = str.substring(0, str.indexOf(" "));
    			}
    			else{
    				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
    			}
    		}
    	}
    	catch(Exception e3){
    		e3.printStackTrace();
    	}
    	User user=new User();
    	user.initialize(username, user.encrypt(password));
        request.getSession().setAttribute("activeUser",user);
        MedwanQuery.setSession(request.getSession(),user);
        //Add some session attributes for user connectivity monitoring
        request.getSession().setAttribute("mon_ipaddress",request.getRemoteAddr());
        request.getSession().setAttribute("mon_browser",browser+" "+version);
        request.getSession().setAttribute("mon_start",new java.util.Date());
    }

    //--- GET BUTTONS HTML ------------------------------------------------------------------------
    public String getButtonsHtml(HttpServletRequest req, User activeUser, AdminPerson activePatient,
                                 String sAccessRight, String sWebLanguage) {
        StringBuffer html = new StringBuffer();

        // print language
        String sPrintLanguage = checkString(req.getParameter("PrintLanguage"));
        if (sPrintLanguage.length() == 0) {
            sPrintLanguage = activePatient.language;
        }

        if (!sAccessRight.equalsIgnoreCase("readonly") && ((activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0) || activeUser.getAccessRight(sAccessRight + ".add") || activeUser.getAccessRight(sAccessRight + ".edit"))) {
            html.append(getTran("Web.Occup", "PrintLanguage", sWebLanguage) + "&nbsp;")
                    .append("<select class='text' name='PrintLanguage'>");

            // supported languages
            String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
            if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
            supportedLanguages = supportedLanguages.toLowerCase();

            // print language selector
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            String tmpLang;
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();
                tmpLang = tmpLang.toUpperCase();

                html.append("<option value='" + tmpLang + "' " + (sPrintLanguage.equalsIgnoreCase(tmpLang) ? "selected" : "") + ">" + tmpLang + "</option>\n");
            }

            html.append("</select>&nbsp;\n");

            // save buttons
            html.append("<input class='button' type='button' name='saveAndPrintButton' id='saveAndPrintButton' value='" + getTran("Web.Occup", "medwan.common.record-and-print", sWebLanguage) + "' onclick='doSave(true);'/>&nbsp;\n")
                    .append("<button accesskey='" + ScreenHelper.getAccessKey(getTranNoLink("accesskey", "save", sWebLanguage)) + "' class='buttoninvisible' onclick='submitForm();'></button>\n")
                    .append("<input type='button' class='button' name='saveButton' id='saveButton' onclick='submitForm();' value='" + getTran("accesskey", "save", sWebLanguage) + "'/>&nbsp;\n");
        }

        // back button
        html.append("<input class='button' type='button' name='backButton' value='" + getTran("Web", "back", sWebLanguage) + "' onclick='doBack();'>\n");

        // javascripts
        html.append("<script>");

        // DO SAVE
        html.append("function doSave(printDocument){")
                .append(" var maySubmit = true;")
                .append(" var printLang;")
                .append(" if(printDocument){")
                .append("  printLang = transactionForm.PrintLanguage.value;\n")
                .append("  document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = '/healthrecord/editTransaction.do?ForwardUpdateTransactionId=true&printPDF=true&ts=" + getTs() + "&PrintLanguage='+printLang;\n")
                .append("  window.open('','newwindow','height=600,width=850,toolbar=yes,status=yes,scrollbars=yes,resizable=yes,menubar=yes');\n")
                .append("  document.transactionForm.target = 'newwindow';\n")
                .append(" }")
                .append(" submitForm(printLang);")
                .append("}");

        // CREATE PDF
        html.append("function createPdf(printLang,tranSubType){")
                .append(" var tranID   = '" + checkString(req.getParameter("be.mxs.healthrecord.transaction_id")) + "';")
                .append(" var serverID = '" + checkString(req.getParameter("be.mxs.healthrecord.server_id")) + "';")
                .append(" window.location.href = '" + sCONTEXTPATH + "/healthrecord/createPdf.jsp?actionField=print&tranAndServerID_1='+tranID+'_'+serverID+'&PrintLanguage='+printLang+'&ts=" + getTs() + "';\n")
                .append(" window.opener.document.transactionForm.saveButton.disabled = false;\n")
                .append(" window.opener.document.transactionForm.saveAndPrintButton.disabled = false;\n")
                .append(" window.opener.bSaveHasNotChanged = true;")
                .append(" window.opener.location.reload();")
                .append(" window.opener.location.href = '" + sCONTEXTPATH + "/main.do?Page=curative/index.jsp&ts=" + getTs() + "';\n")
                .append("}");

        // DO BACK
        html.append("function doBack(){")
                .append(" if(checkSaveButton('" + sCONTEXTPATH + "','" + getTran("Web.Occup", "medwan.common.buttonquestion", sWebLanguage) + "')){\n")
                .append("  window.location.href = '" + sCONTEXTPATH + "/main.do?Page=curative/index.jsp&ts=" + getTs() + "';\n")
                .append(" }")
                .append("}");

        boolean printPDF = checkString(req.getParameter("printPDF")).equals("true");
        if (printPDF) {
            html.append("createPdf('" + sPrintLanguage + "');");
        }

        html.append("</script>");

        return html.toString();
    }
%>

<%
    sAPPTITLE = checkString((String) session.getAttribute("activeProjectTitle"));
    sAPPDIR = checkString((String) session.getAttribute("activeProjectDir"));
    sAPPFULLDIR = application.getRealPath("");
    sCONTEXTPATH = request.getRequestURI().replaceAll(request.getServletPath(), "");
    String sPREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";

    // stylesheets
    String sCSSPRINT         = "<link href='"+sCONTEXTPATH+"/_common/_css/print.css' rel='stylesheet' type='text/css'>";
    String sCSSNORMAL        = "<link href='"+sCONTEXTPATH+"/_common/_css/web.css' rel='stylesheet' type='text/css'>"+
                               "<link href='"+sCONTEXTPATH+"/"+sAPPDIR+"/_common/_css/web.css' rel='stylesheet' type='text/css'>";
    String sCSSRTEDITOR      = "<link href='"+sCONTEXTPATH+"/_common/_css/rteditor.css' rel='stylesheet' type='text/css'>";
    String sCSSWEEKPLANNER   = "<link href='"+sCONTEXTPATH+"/_common/_css/weekPlanner.css' rel='stylesheet' type='text/css'>";
    String sCSSMONTHPLANNER  = "<link href='"+sCONTEXTPATH+"/_common/_css/monthPlanner.css' rel='stylesheet' type='text/css'>";
    String sCSSMODALBOX      = "<link href='"+sCONTEXTPATH+"/_common/_css/modalbox.css' rel='stylesheet' type='text/css'>";
    String sCSSMODALBOXDATACENTER   = "<link href='"+sCONTEXTPATH+"/_common/_css/modalboxdatacenter.css' rel='stylesheet' type='text/css'>";
    String sCSSGNOOCALENDAR  = "<link href='"+sCONTEXTPATH+"/_common/_css/gnoocalendar.css' rel='stylesheet' type='text/css'>";
    String sCSSOPERA         = "<link href='"+sCONTEXTPATH+"/_common/_css/opera.css' rel='stylesheet' type='text/css'>";
    String sCSSDATACENTER    = "<link href='"+sCONTEXTPATH+"/_common/_css/datacenter.css' rel='stylesheet' type='text/css'>";
    String sCSSDATACENTERIE  = "<link href='"+sCONTEXTPATH+"/_common/_css/datacenterie.css' rel='stylesheet' type='text/css'>";
    String sCSSTREEMENU      = "<link href='"+sCONTEXTPATH+"/_common/_css/dhtmlxtree.css' rel='stylesheet' type='text/css'>";
    
    // JS
    String sJSSHORTCUTS = "<script src='" + sCONTEXTPATH + "/_common/_script/shortcuts.js'></script>";
    String sJSCHAR = "<script src='" + sCONTEXTPATH + "/_common/_script/char.js'></script>";
    String sJSPOPUPSEARCH = "<script src='" + sCONTEXTPATH + "/_common/_script/popupsearch.js'></script>";
    String sJSEMAIL = "<script src='" + sCONTEXTPATH + "/_common/_script/email.js'></script>";
    String sJSCOOKIE = "<script src='" + sCONTEXTPATH + "/_common/_script/cookie.js'></script>";
    String sJSSORTTABLE = "<script src='" + sCONTEXTPATH + "/_common/_script/sorttable.js'></script>";
    String sJSAXMAKER = "<script src='" + sCONTEXTPATH + "/_common/_script/ajaxMaker.js'></script>";
    String sJSPROTOTYPE = "<script src='" + sCONTEXTPATH + "/_common/_script/prototype.js'></script>";
    String sJSSCRPTACULOUS = "<script src='" + sCONTEXTPATH + "/_common/_script/scriptaculous.js'></script>";
    String sJSCONTROLMODAL = "<script src='" + sCONTEXTPATH + "/_common/_script/modalDialog.js'></script>";
    String sJSSTRINGFUNCTIONS = "<script src='" + sCONTEXTPATH + "/_common/_script/stringFunctions.js'></script>";
    String sJSDROPDOWNMENU = "<script src='" + sCONTEXTPATH + "/_common/_script/dropdownmenu.js'></script>";
    String sJSDATE = "<script src='" + sCONTEXTPATH + "/_common/_script/date.js'></script>";
    String sJSPOPUPMENU = "<script src='" + sCONTEXTPATH + "/_common/_script/popupmenu.js'></script>";
    String sJSTOGGLE = "<script src='" + sCONTEXTPATH + "/_common/_script/toggle_lib.js'></script>";
    String sJSFORM = "<script src='" + sCONTEXTPATH + "/_common/_script/form_lib.js'></script>";
    String sJSDIAGRAM2 = "<script src='" + sCONTEXTPATH + "/_common/_script/diagram2.js'></script>";
    String sJSDIAGRAM = "<script src='" + sCONTEXTPATH + "/_common/_script/diagram.js'></script>";
    String sJSNUMBER = "<script src='" + sCONTEXTPATH + "/_common/_script/number.js'></script>";
    String sJSBUTTONS = "<script src='" + sCONTEXTPATH + "/_common/_script/buttons.js'></script>";
    String sJSRTEDITOR = "<script src='" + sCONTEXTPATH + "/_common/_script/rteditor.js'></script>" +
                         "<script src='" + sCONTEXTPATH + "/_common/_script/html2xhtml.js'></script>";
    String sJSGRAPHICS = "<script src='" + sCONTEXTPATH + "/_common/_script/wz_jsgraphics.js'></script>";
    String sJSHASHTABLE = "<script src='" + sCONTEXTPATH + "/_common/_script/hashtable.js'></script>";
    String sJSJUIST = "<script>rcts = Juist.getClientRects();Juist.style.height = document.body.offsetHeight - rcts[0].top - 5;</script>";
    String sJSWEEKPLANNERAJAX  = "<script src='"+sCONTEXTPATH+"/_common/_script/weekPlanner/ajax.js'></script>";
    String sJSWEEKPLANNER  = "<script src='"+sCONTEXTPATH+"/_common/_script/weekPlanner/dhtmlgoodies-week-planner.js'></script>";
    String sJSMONTHPLANNERAJAX  = "<script src='"+sCONTEXTPATH+"/_common/_script/monthPlanner/ajax.js'></script>";
    String sJSMONTHPLANNER  = "<script src='"+sCONTEXTPATH+"/_common/_script/monthPlanner/month-planner.js'></script>";
    String sJSMODALBOX  = "<script src='"+sCONTEXTPATH+"/_common/_script/modalbox.js'></script>";
    String sJSGNOOCALENDAR  = "<script src='"+sCONTEXTPATH+"/_common/_script/gnoocalendar.js'></script>";
    String sJSPROTOCHART  = "<script src='"+sCONTEXTPATH+"/_common/_script/protochart/ProtoChart.js'></script>";
    String sJSEXCANVAS  = "<script src='"+sCONTEXTPATH+"/_common/_script/protochart/excanvas.js'></script>";
    String sJSROTATE  = "<script src='"+sCONTEXTPATH+"/_common/_script/rotate.js'></script>";
    String sPROGRESSBAR  = "<script src='"+sCONTEXTPATH+"/_common/_script/pb_prototype.js'></script><script src='"+sCONTEXTPATH+"/_common/_script/pb_ProgressBarHandler.js'></script>";
    String sJSFUSIONCHARTS  = "<script src='"+sCONTEXTPATH+"/_common/_script/FusionCharts.js'></script>";
    String sJSTREEMENU = "<script src='"+sCONTEXTPATH+"/_common/_script/treemenu/dhtmlxtree_std.js'></script>"+ // ".._compacted.js"
                         "<script src='"+sCONTEXTPATH+"/_common/_script/treemenu/dhtmlxcommon.js'></script>";
	String sJSCOLORPICKER = "<link rel='Stylesheet' type='text/css' href='"+sCONTEXTPATH+"/_common/_css/jPicker-1.1.6.min.css' />"+
	  						"<link rel='Stylesheet' type='text/css' href='"+sCONTEXTPATH+"/_common/_css/jPicker.css' />"+
	  						"<script src='"+sCONTEXTPATH+"/_common/_script/jquery-1.4.4.min.js' type='text/javascript'></script>"+
	  						"<script src='"+sCONTEXTPATH+"/_common/_script/jpicker-1.1.6.min.js' type='text/javascript'></script>";

    // varia
    String sTDAdminWidth = "200";
    String sIcon = "<link rel='shortcut icon' href='"+sCONTEXTPATH+"/_img/openclinic.ico'>\n" +
                    "<link rel='icon' type='image/x-icon' href='"+sCONTEXTPATH+"/_img/openclinic.ico'/>";

%>