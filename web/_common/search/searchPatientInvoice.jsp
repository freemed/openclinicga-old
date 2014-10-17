<%@page import="java.text.DecimalFormat"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));
 
    String sFindInvoicePatientId  = checkString(request.getParameter("FindInvoicePatientId")),
           sFindInvoiceDate       = checkString(request.getParameter("FindInvoiceDate")),
           sFindInvoiceNr         = checkString(request.getParameter("FindInvoiceNr")),
           sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
           sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
           sFindInvoiceStatus     = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid        = checkString(request.getParameter("ReturnFieldInvoiceUid")),
           sReturnFieldInvoiceNr         = checkString(request.getParameter("ReturnFieldInvoiceNr")),
           sReturnFieldInvoiceBalance    = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
           sReturnFieldInvoiceMaxBalance = checkString(request.getParameter("ReturnFieldInvoiceMaxBalance")),
           sReturnFieldInvoiceStatus     = checkString(request.getParameter("ReturnFieldInvoiceStatus"));

    /// DEBUG//////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************** _common/search/searchPatientInvoice.jsp *****************");
        Debug.println("sAction                   : "+sAction);
        Debug.println("sFindInvoicePatientId     : "+sFindInvoicePatientId);
        Debug.println("sFindInvoiceDate          : "+sFindInvoiceDate);
        Debug.println("sFindInvoiceNr            : "+sFindInvoiceNr);
        Debug.println("sFindInvoiceType (static) : P");
        Debug.println("sFunction                 : "+sFunction+"\n");
        Debug.println("sFindInvoiceBalanceMin    : "+sFindInvoiceBalanceMin);
        Debug.println("sFindInvoiceBalanceMax    : "+sFindInvoiceBalanceMax);
        Debug.println("sFindInvoiceStatus        : "+sFindInvoiceStatus+"\n");
        Debug.println("sReturnFieldInvoiceUid        : "+sReturnFieldInvoiceUid);
        Debug.println("sReturnFieldInvoiceNr         : "+sReturnFieldInvoiceNr);
        Debug.println("sReturnFieldInvoiceBalance    : "+sReturnFieldInvoiceBalance);
        Debug.println("sReturnFieldInvoiceMaxBalance : "+sReturnFieldInvoiceMaxBalance);
        Debug.println("sReturnFieldInvoiceStatus     : "+sReturnFieldInvoiceStatus+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
%>

<form name="SearchForm" method="POST" onKeyDown="if(enterEvent(event,13)){searchInvoices();}" action="<c:url value='/popup.jsp'/>?Page=_common/search/searchPatientInvoice.jsp&ts=<%=getTs()%>">
	<%-- hidden fields --%>
	<input type="hidden" name="Action">
	<input type="hidden" name="ReturnFieldInvoiceUid" value="<%=sReturnFieldInvoiceUid%>">
	<input type="hidden" name="ReturnFieldInvoiceNr" value="<%=sReturnFieldInvoiceNr%>">
	<input type="hidden" name="ReturnFieldInvoiceBalance" value="<%=sReturnFieldInvoiceBalance%>">
	<input type="hidden" name="ReturnFieldInvoiceMaxBalance" value="<%=sReturnFieldInvoiceMaxBalance%>">
	<input type="hidden" name="ReturnFieldInvoiceStatus" value="<%=sReturnFieldInvoiceStatus%>">
	<input type="hidden" name="FindInvoicePatientId" value="<%=sFindInvoicePatientId%>"/>

<%=writeTableHeader("web","searchpatientinvoice",sWebLanguage," window.close();")%>
<table width="100%" cellspacing="1" cellpadding="0" class="menu">
    <%
        if(!"false".equalsIgnoreCase(request.getParameter("header"))){
    %>
    <%-- INVOICE DATE --%>
    <tr>
        <td class="admin2" width="120" nowrap><%=getTran("Web","date",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="330" nowrap>
            <%=writeDateField("FindInvoiceDate","SearchForm",sFindInvoiceDate,sWebLanguage)%>
        </td>
    </tr>

    <%-- INVOICE NR --%>
    <tr>
        <td class="admin2"><%=getTran("web","number",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceNr" size="10" maxlength="10" onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindInvoiceNr%>">
        </td>
    </tr>

    <%-- INVOICE BALANCE MIN --%>
    <tr>
        <td class="admin2"><%=getTran("web", "balance", sWebLanguage)%> <%=getTran("web","min",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceBalanceMin" size="10" maxlength="8" onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMin%>">&nbsp;<%=sCurrency%>
        </td>
    </tr>

    <%-- INVOICE BALANCE MAX --%>
    <tr>
        <td class="admin2"><%=getTran("web","balance",sWebLanguage)%> <%=getTran("web","max",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceBalanceMax" size="10" maxlength="8" onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMax%>">&nbsp;<%=sCurrency%>
        </td>
    </tr>

    <%-- INVOICE STATUS --%>
    <tr>
        <td class="admin2"><%=getTran("web.finance","patientinvoice.status",sWebLanguage)%></td>
        <td class="admin2">
            <select class="text" name="FindInvoiceStatus">
                <option value=""></option>
                <%=ScreenHelper.writeSelect("finance.patientinvoice.status",sFindInvoiceStatus,sWebLanguage)%>
            </select>
        </td>
    </tr>

    <%-- BUTTONS --%>
    <tr height="25">
        <td class="admin2">&nbsp;</td>
        <td class="admin2">
            <input class="button" type="button" onClick="searchInvoices();" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>">&nbsp;
            <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">
        </td>
    </tr>
    <%
        }
    %>
</table>

<div id="divFindRecords" style="margin-top:2px;"></div>
<br>

<%-- BUTTONS --%>
<center>
    <input type="button" class="button" name="buttonClose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
</center>
</form>

<script>
  window.resizeTo(460,580);

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    SearchForm.FindInvoiceDate.value = "";
    SearchForm.FindInvoiceNr.value = "";
    SearchForm.FindInvoiceBalanceMin.value = "";
    SearchForm.FindInvoiceBalanceMax.value = "";
    SearchForm.FindInvoiceStatus.value = "";
    
    SearchForm.FindInvoiceDate.focus();
  }

  <%-- SEARCH PRESTATIONS --%>
  function searchInvoices(){
    SearchForm.Action.value = "search";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientInvoiceShow.jsp',SearchForm);
  }

  <%-- SELECT INVOICE --%>
  function selectInvoice(sInvoiceUid,sInvoiceDate,sInvoiceNr,sInvoiceBalance,sInvoiceStatus){
    if("<%=sReturnFieldInvoiceUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInvoiceUid%>")[0].value = sInvoiceUid;
    }

    if("<%=sReturnFieldInvoiceNr%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldInvoiceNr%>")[0].value = sInvoiceNr;
    }

    if("<%=sReturnFieldInvoiceBalance%>".length > 0){
      if(window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0]!=null){
      	if(window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value!=null){             	
          if(window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value.length == 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value = format_number(sInvoiceBalance, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
          }
        }
      }
    }

    if("<%=sReturnFieldInvoiceMaxBalance%>".length > 0){
      if(window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0]!=null){
        window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value = format_number(sInvoiceBalance, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
      }
    }

    if("<%=sReturnFieldInvoiceStatus%>".length > 0){
      if(window.opener.document.getElementsByName("<%=sReturnFieldInvoiceStatus%>")[0]!=null){
        window.opener.document.getElementsByName("<%=sReturnFieldInvoiceStatus%>")[0].value = sInvoiceStatus;
      }
    }

    <%
        if(sFunction.length()>0){
            out.print("window.opener."+sFunction+";");
        }
    %>

    window.close();
  }

  <%
      if(sAction.equalsIgnoreCase("search")){
          out.print("searchInvoices();") ;
      }
  %>
</script>