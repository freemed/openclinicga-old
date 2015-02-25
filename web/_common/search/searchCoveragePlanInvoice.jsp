<%@page import="java.text.DecimalFormat"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%=sJSNUMBER%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoiceDate        = checkString(request.getParameter("FindInvoiceDate")),
           sFindInvoiceNr          = checkString(request.getParameter("FindInvoiceNr")),
           sFindInvoiceBalanceMin  = checkString(request.getParameter("FindInvoiceBalanceMin")),
           sFindInvoiceBalanceMax  = checkString(request.getParameter("FindInvoiceBalanceMax")),
           sFindInvoiceInsurarUID  = checkString(request.getParameter("FindInvoiceInsurarUID")),
           sFindInvoiceInsurarText = checkString(request.getParameter("FindInvoiceInsurarText")),
           sFindInvoiceStatus      = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid     = checkString(request.getParameter("ReturnFieldInvoiceUid")),
           sReturnFieldInvoiceNr      = checkString(request.getParameter("ReturnFieldInvoiceNr")),
           sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
           sReturnFieldInvoiceStatus  = checkString(request.getParameter("ReturnFieldInvoiceStatus")),
           sReturnFieldInsurarUid     = checkString(request.getParameter("ReturnFieldInsurarUid")),
           sReturnFieldInsurarName    = checkString(request.getParameter("ReturnFieldInsurarName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** search/searchCoveragePlanInvoice.jsp *****************");
    	Debug.println("sAction                 : "+sAction);
    	Debug.println("sFindInvoiceDate        : "+sFindInvoiceDate);
    	Debug.println("sFindInvoiceNr          : "+sFindInvoiceNr);
    	Debug.println("sFindInvoiceBalanceMin  : "+sFindInvoiceBalanceMin);
    	Debug.println("sFindInvoiceBalanceMax  : "+sFindInvoiceBalanceMax);
    	Debug.println("sFindInvoiceInsurarUID  : "+sFindInvoiceInsurarUID);
    	Debug.println("sFindInvoiceInsurarText : "+sFindInvoiceInsurarText);
    	Debug.println("sFindInvoiceStatus      : "+sFindInvoiceStatus+"\n");
    	
    	Debug.println("sReturnFieldInvoiceUid     : "+sReturnFieldInvoiceUid);
    	Debug.println("sReturnFieldInvoiceNr      : "+sReturnFieldInvoiceNr);
    	Debug.println("sReturnFieldInvoiceBalance : "+sReturnFieldInvoiceBalance);
    	Debug.println("sReturnFieldInvoiceStatus  : "+sReturnFieldInvoiceStatus);
    	Debug.println("sReturnFieldInsurarUid     : "+sReturnFieldInsurarUid);
    	Debug.println("sFindInvoiceStatus         : "+sFindInvoiceStatus+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");

%>
<form name="SearchForm" method="POST" onsubmit="searchInvoices();return false;" onkeydown="if(enterEvent(event,13)){searchInvoices();}" action="<c:url value='/popup.jsp'/>?Page=_common/search/searchCoveragePlanInvoice.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action">

    <%=writeTableHeader("web","searchreimbursementdocument",sWebLanguage," window.close();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="menu">        
        <%-- COVERAGE PLAN --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","coverageplan",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="FindInvoiceInsurarUID" value="<%=sFindInvoiceInsurarUID%>">
                <input type="text" class="text" readonly name="FindInvoiceInsurarText" value="<%=sFindInvoiceInsurarText%>" size="60">
              
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
            </td>
        </tr>
        
        <%-- DATE --%>
        <tr>
            <td class="admin"><%=getTran("Web","date",sWebLanguage)%>&nbsp;</td>
            <td class="admin2"><%=writeDateField("FindInvoiceDate","SearchForm",sFindInvoiceDate,sWebLanguage)%></td>
        </tr>
        
        <%-- NUMBER --%>
        <tr>
            <td class="admin"><%=getTran("web","number",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="FindInvoiceNr" size="12" maxlength="12" onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindInvoiceNr%>">
            </td>
        </tr>
        
        <%-- BALANCE --%>
        <tr>
            <td class="admin"><%=getTran("web","balance",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("web","min",sWebLanguage)%>:
                <input type="text" class="text" name="FindInvoiceBalanceMin" size="10" maxlength="8" onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMin%>">&nbsp;<%=sCurrency%>
                &nbsp;
                <%=getTran("web","max",sWebLanguage)%>:
                <input type="text" class="text" name="FindInvoiceBalanceMax" size="10" maxlength="8" onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMax%>">&nbsp;<%=sCurrency%>
            </td>
        </tr>
        
        <%-- STATUS --%>
        <tr>
            <td class="admin"><%=getTran("web.finance","reimbursementdocument.status",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="FindInvoiceStatus">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("finance.patientinvoice.status",sFindInvoiceStatus,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr height="25">
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchInvoices();" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="3" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    
    <center>
        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>

    <%-- hidden fields --%>
    <input type="hidden" name="ReturnFieldInvoiceUid" value="<%=sReturnFieldInvoiceUid%>">
    <input type="hidden" name="ReturnFieldInvoiceNr" value="<%=sReturnFieldInvoiceNr%>">
    <input type="hidden" name="ReturnFieldInvoiceBalance" value="<%=sReturnFieldInvoiceBalance%>">
    <input type="hidden" name="ReturnFieldInvoiceStatus" value="<%=sReturnFieldInvoiceStatus%>">
    <input type="hidden" name="ReturnFieldInsurarUid" value="<%=sReturnFieldInsurarUid%>">
    <input type="hidden" name="ReturnFieldInsurarName" value="<%=sReturnFieldInsurarName%>">
    <input type="hidden" name="doFunction" value="<%=sFunction%>">
</form>

<script>
  window.resizeTo(700,600);
  getOpenerInsurance();
    
  function searchInsurar(){
    openPopup("/_common/search/searchCoveragePlan.jsp&ts=<%=getTs()%>&VarCompUID=FindInvoiceInsurarUID&VarText=FindInvoiceInsurarText");
  }

  function doClearInsurar(){
    SearchForm.FindInvoiceInsurarUID.value = "";
    SearchForm.FindInvoiceInsurarText.value = "";
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    SearchForm.FindInvoiceDate.value = "";
    SearchForm.FindInvoiceNr.value = "";
    SearchForm.FindInvoiceBalanceMin.value = "";
    SearchForm.FindInvoiceBalanceMax.value = "";
    SearchForm.FindInvoiceStatus.value = "";
    SearchForm.FindInvoiceInsurarUID.value = "";
    SearchForm.FindInvoiceInsurarText.value = "";
    SearchForm.FindInvoiceDate.focus();
  }

  <%-- SEARCH PRESTATIONS --%>
  function searchInvoices(){
    SearchForm.Action.value = "search";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchCoveragePlanInvoiceShow.jsp',SearchForm);
  }

  <%-- GET SELECTED ASSURANCE --%>
  function getOpenerInsurance(){
    var form = window.opener.document.forms["EditForm"];
    var InsuranceId = form['EditCreditInsurarUid'];
    var InsuranceName = form['EditCreditInsurarName'];

    if(InsuranceName){
      var newForm = document.forms["SearchForm"];
      newForm["FindInvoiceInsurarUID"].value = InsuranceId.value;
      newForm["FindInvoiceInsurarText"].value = InsuranceName.value;
      searchInvoices();
    }
  }

  <%-- SELECT INVOICE --%>
  function selectInvoice(sInvoiceUid,sInvoiceDate,sInvoiceNr,sInvoiceBalance,sInvoiceStatus,sInsurarUid,sInsurarName){
    if("<%=sReturnFieldInvoiceUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInvoiceUid%>")[0].value = sInvoiceUid;
    }

    if("<%=sReturnFieldInvoiceNr%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInvoiceNr%>")[0].value = sInvoiceNr;
    }

    if("<%=sReturnFieldInvoiceBalance%>".length > 0){
      if(sInvoiceBalance > 0 && window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value * 1 == 0){
        window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value = format_number(sInvoiceBalance,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
      }
    }

    if("<%=sReturnFieldInvoiceStatus%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInvoiceStatus%>")[0].value = sInvoiceStatus;
    }

    if("<%=sReturnFieldInsurarUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInsurarUid%>")[0].value = sInsurarUid;
    }

    if("<%=sReturnFieldInsurarName%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInsurarName%>")[0].value = sInsurarName;
    }

    <%
	    if(sFunction.length()>0){
	        out.print("window.opener."+sFunction+";");
	    }
    %>

    if(window.opener.loadUnassignedCredits != null){
      window.opener.loadUnassignedCredits(sInsurarUid);
    }

    window.close();
  }
</script>