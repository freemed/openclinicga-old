<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.openclinic.medical.RequestedLabAnalysis,
                java.util.Vector,
                java.util.Hashtable,
                java.util.Collections"%>
<%@page import="be.openclinic.medical.Labo"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.labrequest","select",activeUser)%>
<%=sJSSORTTABLE%>
<%=sJSEMAIL%>

<%
    // LabAnalyses are saved by SaveLabAnalysesAction after the transaction itself has been saved.
    // That duality makes this code might appear complicated.
%>

<%!
    //--- ADD LABANALYSIS -------------------------------------------------------------------------
    private String addLA(int iTotal, String serverId, String transactionId, String sCode, String sType,
                         String sLabel, String sComment, String sMonster, String sResultValue,
                         String sResultModifier, String sWebLanguage){
        // translate comment
        if(sComment.trim().length() > 0){
            sComment = getTranNoLink("web.analysis",sComment,sWebLanguage);
        }

        // alternate row-style; red when empty resultModifier
        String sClass;
        if(sResultModifier.length()==0){
            sClass = "red";
        }
        else{
            if(iTotal%2==0) sClass = "";
            else            sClass = "list";
        }

        String detailsTran = getTran("web","showDetails",sWebLanguage);
        StringBuffer buf = new StringBuffer();
        buf.append("<tr id='rowLA"+iTotal+"' class='"+sClass+"' title='"+detailsTran+"' onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\">")
            .append("<td align='center'>")
             .append("<a href='#' onclick=\"deleteLA(rowLA"+iTotal+",'"+sMonster+"');\">")
              .append("<img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='").append(getTran("Web","delete",sWebLanguage)).append("' border='0'>")
             .append("</a>")
            .append("</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+sCode+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+sType+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+sLabel+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+sComment+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+getTran("labanalysis.monster",sMonster,sWebLanguage)+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+sResultValue+"</td>")
            .append("<td onClick=\"showResultDetails('"+serverId+"','"+transactionId+"','"+sCode+"');\">&nbsp;"+(sResultModifier.length()>0?getTran("labanalysis.resultmodifier",sResultModifier,sWebLanguage):"")+"</td>")
           .append("</tr>");

        return buf.toString();
    }
%>
<script>
  var labAnalysisArray = new Array();
  var selectedMonsters = new Array();
  var labanalysisCodes = new Array();
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
  <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

  <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
  <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
  <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>

  <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
  <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

  <input type="hidden" name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
  <input type="hidden" name="LAOther" value=""/>
  <input type="hidden" name="Action" value=""/>

<%
    // variables
    String sTmpCode, sTmpComment, sTmpModifier, sTmpResultUnit, sTmpResultValue, sTmpResult,
            sTmpType = "", sTmpLabel = "", sTmpMonster = "", sTmpServerId, sTmpTransactionId;
    StringBuffer sScriptsToExecute = new StringBuffer();
    TransactionVO tran = (TransactionVO)transaction;
    Hashtable labAnalyses = new Hashtable();
    RequestedLabAnalysis labAnalysis;
    String sLA = "", sDivLA = "";
    int iTotal = 1;

    // get chosen labanalyses from existing transaction.
    if (tran != null && (tran.getTransactionId().intValue() > 0 || MedwanQuery.getInstance().getConfigInt("enableSlaveServer",0)==1)){
        labAnalyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(tran.getServerId(), tran.getTransactionId().intValue());
    }

    // sort analysis-codes
    Vector codes = new Vector(labAnalyses.keySet());
    Collections.sort(codes);

    // run thru saved labanalysis
    for(int i = 0; i < codes.size(); i++){
        sTmpCode = (String) codes.get(i);
        labAnalysis = (RequestedLabAnalysis) labAnalyses.get(sTmpCode);

        sTmpServerId = labAnalysis.getServerId();
        sTmpTransactionId = labAnalysis.getTransactionId();
        sTmpComment = labAnalysis.getComment();
        sTmpModifier = labAnalysis.getResultModifier();

        // get resultvalue
        if(labAnalysis.getFinalvalidation()>0){
            sTmpResultValue = labAnalysis.getResultValue();
        }
        else{
            sTmpResultValue = "";
        }
        sTmpResultUnit = getTranNoLink("labanalysis.resultunit", labAnalysis.getResultUnit(), sWebLanguage);
        sTmpResult = sTmpResultValue+" "+sTmpResultUnit;

        // get default-data from DB

        Hashtable hLabRequestData = Labo.getLabRequestDefaultData(sTmpCode,sWebLanguage);

        if (hLabRequestData != null) {
            sTmpType = (String) hLabRequestData.get("labtype");
            sTmpLabel = (String) hLabRequestData.get("OC_LABEL_VALUE");
            sTmpMonster = (String) hLabRequestData.get("monster");
        }

        // translate labtype
        if (sTmpType.equals("1")) sTmpType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
        else if (sTmpType.equals("2")) sTmpType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
        else if (sTmpType.equals("3")) sTmpType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
        else if (sTmpType.equals("4")) sTmpType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
        else if (sTmpType.equals("5")) sTmpType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
        else if (sTmpType.equals("6")) sTmpType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
        else if (sTmpType.equals("7")) sTmpType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

        // compose sLA
        sLA += "rowLA"+iTotal+"="+sTmpCode+"£"+sTmpComment+"$";
        sDivLA += addLA(iTotal, sTmpServerId, sTmpTransactionId, sTmpCode, sTmpType, sTmpLabel, sTmpComment, sTmpMonster, sTmpResult, sTmpModifier, sWebLanguage);
        sScriptsToExecute.append("addToMonsterList('"+(sTmpMonster.length()>0?getTranNoLink("labanalysis.monster",sTmpMonster,sWebLanguage):"")+"');");
        iTotal++;
    }

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>

<%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
<%=contextHeader(request,sWebLanguage)%>

<%-- DATE --%>
<table width="100%" class="list" cellspacing="1">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" onBlur='checkDate(this)'>
            <script>writeTranDate();</script>&nbsp;&nbsp;&nbsp;
            <input type="button" class="button" name="ButtonSearchLA" value="<%=getTran("Web","add",sWebLanguage)%>" onclick='openSearchWindow();'/>
            <input type="button" class="button" name="ButtonQuickList" value="<%=getTran("Web","quicklist",sWebLanguage)%>" onclick='openQuickListWindow();'/>
        </td>
    </tr>
</table>

<br>

<%-- LABANALYSIS --------------------------------------------------------------------------------%>
<table id="tblLA" width="100%" cellspacing="1" class="sortable">
    <%-- HEADER --%>
    <tr class="admin">
        <td width="18"></td>

        <%-- default data --%>
        <td width="80"><%=getTran("Web.manage","labanalysis.cols.code",sWebLanguage)%></td>
        <td width="80"><%=getTran("Web.manage","labanalysis.cols.type",sWebLanguage)%></td>
        <td width="200"><%=getTran("Web.manage","labanalysis.cols.name",sWebLanguage)%></td>
        <td width="150"><%=getTran("Web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
        <td width="200"><%=getTran("Web.manage","labanalysis.cols.monster",sWebLanguage)%></td>

        <%-- result data --%>
        <td width="100"><%=getTran("Web.manage","labanalysis.cols.resultvalue",sWebLanguage)%></td>
        <td width="100"><%=getTran("Web.manage","labanalysis.cols.resultmodifier",sWebLanguage)%></td>
    </tr>

    <%-- chosen LabAnalysis --%>
    <%=sDivLA%>
</table>

<%-- delete all --%>
<a href="#" onclick="deleteAllLA();"><%=getTran("Web.manage","deleteAllLabAnalysis",sWebLanguage)%></a>

<br><br>

<table width="100%" class="list" cellspacing="1">
    <%-- MONSTERS --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","labrequest.monsters",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="80" id="monsterList" READONLY>
        </td>
    </tr>

    <%-- MONSTER HOUR --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","labrequest.hour",sWebLanguage)%></td>
        <td class="admin2">
            <input id="hour" size="5" type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HOUR" property="value"/>" onblur="limitLength(this);"/>
            <a href="javascript:setCurrentTime('hour');">
                <img src="<c:url value="/_img/icon_compose.gif"/>" class="link" style='vertical-align:bottom' title="<%=getTranNoLink("web","currenttime",sWebLanguage)%>" border="0"/>
            </a>
        </td>
    </tr>

    <%-- PRESCRIBER --%>
    <tr>
        <td class="admin"><%=getTran("Web","prescriber",sWebLanguage)%></td>
        <td class="admin2">
            <input type='text' id="prescriber" <%=setRightClick("ITEM_TYPE_LAB_PRESCRIBER")%> class="text" size="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_PRESCRIBER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_PRESCRIBER" property="value"/>"/>
        </td>
    </tr>

    <%-- COMMENT --%>
    <tr>
        <td class="admin"><%=getTran("Web","comment",sWebLanguage)%></td>
        <td class="admin2">
            <textarea id="remark" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_LAB_COMMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT" property="value"/></textarea>
        </td>
    </tr>

    <%-- URGENCY --%>
    <%
        ItemVO item = ((TransactionVO)transaction).getItem(sPREFIX+"ITEM_TYPE_LAB_URGENCY");
        String sUrgency = "";
        if(item!=null) sUrgency = item.getValue();
    %>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","urgency",sWebLanguage)%></td>
        <td class="admin2">
            <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_URGENCY" property="itemId"/>]>.value">
                <option><%=getTran("web","choose",sWebLanguage)%></option>
                <%=ScreenHelper.writeSelect("labrequest.urgency",sUrgency,sWebLanguage)%>
            </select>
        </td>
    </tr>

    <%-- SMS --%>
    <tr>
        <td class="admin"><%=getTran("Web","warnSms",sWebLanguage)%></td>
        <td class="admin2" >
            <input type='text' id="labsms" <%=setRightClick("ITEM_TYPE_LAB_SMS")%> class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS" property="value"/>"/>
	        <%
	        	if(tran.getTransactionId()<=0){
	        		String labSMS=UserParameter.getParameter(activeUser.userid,"lastLabSMS");
	        		if(checkString(labSMS).length()>0){
	        			%><a href="javascript:set('labsms','<%=labSMS %>')"><img class='link' src='<c:url value="/_img/valid.gif"/>'/> <%=labSMS%></a><%
	        		}
	        	}
	        %>
        </td>
    </tr>
    <script>
      function set(fieldid,val){
        document.getElementById(fieldid).value=val
      }
    </script>

    <%-- EMAIL --%>
    <tr>
        <td class="admin"><%=getTran("Web","warnEmail",sWebLanguage)%></td>
        <td class="admin2">
            <input type='text' id="labmail" <%=setRightClick("ITEM_TYPE_LAB_EMAIL")%> class="text" size="50" onBlur="checkEmailAddress(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL" property="value"/>"/>
	        <%
	        	if(tran.getTransactionId()<=0){
	        		String labMail=UserParameter.getParameter(activeUser.userid,"lastLabEmail");
	        		if(checkString(labMail).length()>0){
	        			%><a href="javascript:set('labmail','<%=labMail %>')"><img class='link' src='<c:url value="/_img/valid.gif"/>'/> <%=labMail%></a><%
	        		}
	        	}
	        %>
        </td>
    </tr>

    <%-- hidden fields --%>
    <input type="hidden" name="selectedLabCodes" value="">

    <%-- BUTTONS --------------------------------------------------------------------------------%>
    <tr>
        <td class="admin"/>
        <td class="admin2">
            <%
                String sPrintLanguage = sWebLanguage;
                if(activeUser.getAccessRight("occup.labrequest.add") || activeUser.getAccessRight("occup.labrequest.edit")){
                    // only display print-button and language-selector if transaction is saved
                    if(((TransactionVO)transaction).getTransactionId().intValue() > 0){
                        %>
                            <input class="button" type="button" name="showStatus" value="<%=getTran("Web","details",sWebLanguage)%>" onclick="showRequest(<bean:write name="transaction" scope="page" property="serverId"/>,<bean:write name="transaction" scope="page" property="transactionId"/>);">
                            <input class="button" type="button" name="receive" value="<%=getTran("Web","receive",sWebLanguage)%>" onclick="receiveSamples();">&nbsp;
                        <%
                    }

                    %>
                        <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="doSave(false);"></button>
                        <button class="button" name="saveButton" id="saveButton" onclick="doSave(false);"><%=getTran("accesskey","save",sWebLanguage)%></button>
                        <input class="button" type="button" name="printLabelsButton" value="<%=getTran("Web","saveandprintlabels",sWebLanguage)%>" onclick="doSave(true)"/>&nbsp;
                    <%
                }
            %>
            <input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
            <input type="hidden" name="monsterids"/>
        </td>
    </tr>
</table>

<input type="hidden" name="exitmessage"/>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  var maxSelectedLabAnalysesAlerted = false;
  var iIndexLA = <%=iTotal%>;
  var sLA = "<%=sLA%>";

  <%-- CHECK EMAIL ADDRESS --%>
  function checkEmailAddress(inputField){
    if(inputField.value.length > 0){
      if(!validEmailAddress(inputField.value)){
    	alertDialog("web","invalidemailaddress");
        inputField.focus();
      }
    }
  }
  
  <%-- SHOW REQUEST --%>
  function showRequest(serverid,transactionid){
    window.open("<c:url value='/labos/manageLabResult_view.jsp'/>?ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
  }

  <%
      // set time when creating the labRequest
      if(tran.getTransactionId().intValue() < 0){
          %>setCurrentTime('hour');<%
      }

      int maxSelectedLabAnalyses;
      if(MedwanQuery.getInstance().getConfigString("maxSelectedLabAnalyses").length() == 0){
          %>var maxSelectedLabAnalyses = 10;<%
      }
      else{
          try{
              maxSelectedLabAnalyses = Integer.parseInt(MedwanQuery.getInstance().getConfigString("maxSelectedLabAnalyses"));
              %>var maxSelectedLabAnalyses = <%=maxSelectedLabAnalyses%>;<%
          }
          catch(Exception e){
              Debug.println("ERROR : Invalid value for configstring 'maxSelectedLabAnalyses'.");
              %>var maxSelectedLabAnalyses = 10;<%
          }
      }
  %>

  <%-- OPEN SEARCH WINDOW --%>
  function openSearchWindow(){
    maxSelectedLabAnalysesAlerted = false;
    openPopup("/_common/search/searchLabAnalysisForPatient.jsp"+
    		  "&VarID=LabID&VarType=LabType&VarCode=LabCode&VarText=LabLabel"+
              "&selectedLabCodes="+transactionForm.selectedLabCodes.value,600,460);
  }

  function openQuickListWindow(){
    openPopup("/labos/quicklist.jsp&selectedLabCodes="+transactionForm.selectedLabCodes.value,800,600);
  }

  <%-- CREATE OFFICIAL PDF --%>
  function createOfficialPdf(printLang){
    var tranID   = "<%=checkString(request.getParameter("be.mxs.healthrecord.transaction_id"))%>";
    var serverID = "<%=checkString(request.getParameter("be.mxs.healthrecord.server_id"))%>";

    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp?tranAndServerID_1="+tranID+"_"+serverID+"&PrintLanguage="+printLang+"&ts=<%=getTs()%>";

    window.opener.document.transactionForm.saveButton.disabled = false;
    window.opener.document.transactionForm.SaveAndPrint.disabled = false;
    window.opener.bSaveHasNotChanged = true;
    window.opener.location.reload();
  }

  <%
      boolean printPDF = checkString(request.getParameter("printPDF")).equals("true");
      if(printPDF){
          %>createOfficialPdf('<%=sPrintLanguage%>');<%
      }
  %>

  <%-- DO SAVE --%>
  function doSave(printDocument){
    if(tblLA.rows.length > 1){
      if(printDocument==true){
        document.getElementsByName('exitmessage')[0].value='printlabels';
      }

      doSubmit();
    }
    else{
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectAtLeastOneAnalysis";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.manage","selectAtLeastOneAnalysis",sWebLanguage)%>");
    }
  }

  <%-- DO PRINT --%>
  function doPrint(){
    var tranID    = document.getElementById('transactionId').value;
    var serverID  = document.getElementById('serverId').value;
    var printLang = transactionForm.PrintLanguage.value;

    var url = "<c:url value='/healthrecord/createOfficialPdf.jsp'/>?tranAndServerID_1="+tranID+"_"+serverID+"&PrintLanguage="+printLang+"&ts=<%=getTs()%>";
    window.open(url,"_new","height=600, width=850, toolbar=yes, status=yes, scrollbars=yes, resizable=yes, menubar=yes");
  }

  <%-- SET CURRENT TIME --%>
  function setCurrentTime(objName){
    var now = new Date();

    var minutes = now.getMinutes();
    if(minutes<10) minutes = "0"+minutes;

    var hours = now.getHours();
    if(hours<10) hours = "0"+hours;

    document.getElementById(objName).value = hours+":"+minutes;
  }

  <%-- INDICATE LA --%>
  var sLASaved;
  function indicateLA(){
    sLASaved = sLA;
  }

  indicateLA();

  <%-- DO SUBMIT --%>
  function doSubmit(){
    <%-- remove row id --%>
    while(sLA.indexOf("rowLA") > -1){
      sTmpBegin = sLA.substring(sLA.indexOf("rowLA"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sLA = sLA.substring(0,sLA.indexOf("rowLA"))+sTmpEnd;
    }

    <%-- remove row id --%>
    while(sLASaved.indexOf("rowLA") > -1){
      sTmpBegin = sLASaved.substring(sLASaved.indexOf("rowLA"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sLASaved = sLASaved.substring(0,sLASaved.indexOf("rowLA"))+sTmpEnd;
    }

    <%-- set the forward key --%>
    if(sLASaved != sLA){
      <%-- when some labanalyses were removed or added, update the transaction and reload this page in order to save the labanalyses --%>
      document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = "<c:url value='../healthrecord/saveLabAnalyses.do'/>?ForwardUpdateTransactionId&labAnalysesToSave="+sLA+"&savedLabAnalyses="+sLASaved+"&patientId=<%=activePatient.personid%>&userId=<%=activeUser.userid%>&ts=<%=getTs()%>";
    }
    else{
      <%-- when no labanalyses were removed or added, update the transaction and go to the consultation-overview --%>
      document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = "<c:url value="../main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- SORT LABANALYSES --%>
  function sortLabAnalyses(){
    var sortLink = document.getElementById('lnk1');
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }
  }

  <%-- ASSEMBLE A LIST OF ALL UNIQUE MONSTERS USED IN THE SELECTED LABANALYSES --%>
  function addToMonsterList(monster){
    if(monster != ""){
      var monsterList = document.getElementById('monsterList');

      var monsterArray;
      if(monsterList.value == ""){
        monsterArray = new Array();
      }
      else{
        monsterArray = monsterList.value.split(",");
      }

      var monsterExists = false;
      for(var i=0; i<monsterArray.length; i++){
        if(monsterArray[i] == monster){
          monsterExists = true;
          break;
        }
      }

      if(!monsterExists){
        monsterArray.push(monster);
      }

      monsterArray.sort();
      monsterList.value = monsterArray.join(",");
      selectedMonsters.push(monster);
    }
  }

  <%-- REMOVE MONSTER FROM MONSTERLIST IF IT OCCURS ONCE --%>
  function removeFromMonsterList(monster){
    if(monster != ""){
      var monsterList = document.getElementById('monsterList');

      var monsterArray;
      if(monsterList.value == ""){
        monsterArray = new Array();
      }
      else{
        monsterArray = monsterList.value.split(",");
      }

      var monsterOccurences = 0;
      for(var i=0; i<selectedMonsters.length; i++){
        if(selectedMonsters[i] == monster){
          monsterOccurences++;
        }
      }

      if(monsterOccurences == 1){
        monsterArray.pop(monster);
      }

      monsterArray.sort();
      monsterList.value = monsterArray.join(",");

      for(var i=0; i<selectedMonsters.length; i++){
        if(selectedMonsters[i] == monster){
          selectedMonsters.splice(i,1);
        }
      }
    }
  }

  <%-- DELETE LAB ANALYSIS --%>
  function deleteLA(rowid,monster){
    if(yesnoDialog("Web","areYouSureToDelete")){
      sLA = deleteRowFromArrayString(sLA,rowid.id);
      initLabAnalysisArray(sLA);
      removeFromMonsterList(monster);
      tblLA.deleteRow(rowid.rowIndex);
      updateRowStyles();
    }
  }

  <%-- INIT LAB ANALYSIS ARRAY --%>
  function initLabAnalysisArray(sArray){
    labAnalysisArray = new Array();
    labAnalysisCodes = new Array();
    transactionForm.selectedLabCodes.value = "";

    if(sArray != ''){
      var sOneLA;
      for(var i=0; i<iIndexLA-1; i++){
        sOneLA = getRowFromArrayString(sLA,"rowLA"+(i+1));
        if(sOneLA != ''){
          var oneLA = sOneLA.split("£");
          labAnalysisArray.push(oneLA);
          labAnalysisCodes.push(oneLA[0]);
        }
      }
      transactionForm.selectedLabCodes.value = labAnalysisCodes.join(",");
    }
  }

  function addQuickListAnalyses(sSelectedAnalyses){
	// lijst van bijhorende analyses ophalen via Ajax
    var params = "newanalyses="+sSelectedAnalyses+
                 "&existinganalyses="+transactionForm.selectedLabCodes.value;
    var url = '<c:url value="/labos/getLabAnalyses.jsp"/>?ts='+new Date();
	new Ajax.Request(url,{
	  method: "GET",
      parameters: params,
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        var analysestoadd = label.analyses.split("£");
        for(n=0; n<analysestoadd.length; n++){
          addLabAnalysis(analysestoadd[n].split("$")[0],analysestoadd[n].split("$")[1],analysestoadd[n].split("$")[2],analysestoadd[n].split("$")[3],analysestoadd[n].split("$")[4]);
        }
      },
      onFailure: function(){
        alert("error");
      }
	});
  }
  
  <%-- CALLED BY SEARCHPOPUP : ADD THE LABANALYSE, CHOSEN IN THE POPUP, TO THIS LABREQUEST --%>
  function addLabAnalysis(code,type,label,comment,monster){
    if(labAnalysisArray.length >= maxSelectedLabAnalyses){
      if(!maxSelectedLabAnalysesAlerted){
        maxSelectedLabAnalysesAlerted = true;
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelValue=<%=getTran("Web.Occup","maxselectedlabanalysisreached",sWebLanguage)%> ("+maxSelectedLabAnalyses+")";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.Occup","maxselectedlabanalysisreached",sWebLanguage)%>");
      }
    }
    else{
      if(!allreadySelected(code,comment)){
        sLA+= "rowLA"+iIndexLA+"="+code+"£"+comment+"$";

        var tr = tblLA.insertRow(tblLA.rows.length);
        tr.id = "rowLA"+iIndexLA;

        if(tblLA.rows.length%2==0){
          tr.className = "list";
        }

        <%-- insert cells in row --%>
        var td = tr.insertCell(0);
        td.innerHTML = "<center><a href=\"#\" onclick=\"deleteLA(rowLA"+iIndexLA+",'"+monster+"');\"><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' border='0'></a></center>";
        tr.appendChild(td);

        <%-- default data --%>
        td = tr.insertCell(1);
        td.innerHTML =  "&nbsp;"+code;
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+type;
        tr.appendChild(td);

        td = tr.insertCell(3);
        td.innerHTML = "&nbsp;"+label;
        tr.appendChild(td);

        td = tr.insertCell(4);
        td.innerHTML = "&nbsp;"+comment;
        tr.appendChild(td);

        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;"+monster;
        tr.appendChild(td);

        <%-- result data --%>
        td = tr.insertCell(6);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        td = tr.insertCell(7);   // resultmodifier
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        iIndexLA++;
        labAnalysisArray[labAnalysisArray.length] = new Array(code,comment);
        labAnalysisCodes.push(code);
        transactionForm.selectedLabCodes.value = labAnalysisCodes.join(",");
        addToMonsterList(monster);
      }
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

  <%-- ALLREADY SELECTED --%>
  function allreadySelected(code,comment){
    for(var i=0; i<labAnalysisArray.length; i++){
      if(labAnalysisArray[i][0] == code){
        if(comment != ''){
          if(labAnalysisArray[i][1] == comment){ return true; }
          else{ return false; }
        }
        else{
          return true;
        }

        return false;
      }
    }
  }

  <%-- GET ROW FROM ARRAY STRING --%>
  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for(var i=0;i<array.length;i++){
      if(array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }

  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  <%-- DELETE ALL LABANALYSIS --%>
  function deleteAllLA(){
    if(tblLA.rows.length > 1){
      if(yesnoDialog("Web","areYouSureToDelete")){
        deleteAllLANoConfirm();
      }
    }
  }

  <%-- CLEAR ALL LABANALYSIS --%>
  function deleteAllLANoConfirm(){
    if(tblLA.rows.length > 1){
      var len = tblLA.rows.length;
      for(i=len-1; i!=0; i--){
        tblLA.deleteRow(i);
      }

      sLA = "";
      initLabAnalysisArray("");
      clearMonsterList();
    }
  }

  <%-- CLEAR MONSTER LIST --%>
  function clearMonsterList(){
    document.getElementById('monsterList').value = "";
    monsterArray = new Array();
    selectedMonsters = new Array();
  }

  <%-- UPDATE ROW STYLES (especially after sorting, red row when no resultmodifier) --%>
  function updateRowStyles(){
    for(i=1; i<tblLA.rows.length; i++){
      tblLA.rows[i].className = "";
      tblLA.rows[i].style.cursor = 'hand';
    }

    for(i=1; i<tblLA.rows.length; i++){
      if(tblLA.rows[i].cells[7].innerHTML == "&nbsp;"){
        tblLA.rows[i].className = "red";
      }
      else if(i%2>0){
        tblLA.rows[i].className = "list";
      }
    }
  }

  <%-- SHOW LAB LABRESULT DETAILS --%>
  function showResultDetails(serverId,transactionId,analysisCode){
    openPopup("/healthrecord/labResultPopup.jsp&serverId="+serverId+"&transactionId="+transactionId+"&analysisCode="+analysisCode+"&editable=false");
  }

  <%-- REFRESH CONTENT --%>
  function refreshContent(){
    window.location.href = "<c:url value='/main.do'/>?Page=healthrecord/manageLabRequest_view.jsp&ts=<%=getTs()%>";
  }

  <%-- PRINT LABELS --%>
  function printLabels(){
    window.open("<c:url value="/healthrecord/createLabSampleLabelPdf.jsp"/>?serverid=<bean:write name="transaction" scope="page" property="serverId"/>&transactionid=<bean:write name="transaction" scope="page" property="transactionId"/>&ts=<%=getTs()%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=400, height=300, menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }

  <%-- RECEIVE SAMPLES --%>
  function receiveSamples(){
    openPopup("/labos/manageLabSampleReception.jsp&labrequestid=<bean:write name="transaction" scope="page" property="serverId"/>.<bean:write name="transaction" scope="page" property="transactionId"/>&PopupWidth=500&PopupHeight=300&ts=<%=getTs()%>");
  }

  initLabAnalysisArray(sLA);

  <%=sScriptsToExecute%>
</script>

<%=writeJSButtons("transactionForm","saveButton")%>