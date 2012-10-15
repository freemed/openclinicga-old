<%@ page import="java.text.DecimalFormat" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("Action"));
    String sFindInvoicePatientId = checkString(request.getParameter("FindInvoicePatientId")),
            sFindInvoiceDate = checkString(request.getParameter("FindInvoiceDate")),
            sFindInvoiceNr = checkString(request.getParameter("FindInvoiceNr")),
            sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
            sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
            sFindInvoiceStatus = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid = checkString(request.getParameter("ReturnFieldInvoiceUid")),
            sReturnFieldInvoiceNr = checkString(request.getParameter("ReturnFieldInvoiceNr")),
            sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
            sReturnFieldInvoiceMaxBalance = checkString(request.getParameter("ReturnFieldInvoiceMaxBalance")),
            sReturnFieldInvoiceStatus = checkString(request.getParameter("ReturnFieldInvoiceStatus"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n############### searchPatientInvoice : " + sAction + " ##############");
        System.out.println("* sFindInvoicePatientId     : " + sFindInvoicePatientId);
        System.out.println("* sFindInvoiceDate          : " + sFindInvoiceDate);
        System.out.println("* sFindInvoiceNr            : " + sFindInvoiceNr);
        System.out.println("* sFindInvoiceType (static) : P");
        System.out.println("* sFunction                 : " + sFunction + "\n");
        System.out.println("* sFindInvoiceBalanceMin    : " + sFindInvoiceBalanceMin);
        System.out.println("* sFindInvoiceBalanceMax    : " + sFindInvoiceBalanceMax);
        System.out.println("* sFindInvoiceStatus        : " + sFindInvoiceStatus + "\n");
        System.out.println("* sReturnFieldInvoiceUid        : " + sReturnFieldInvoiceUid);
        System.out.println("* sReturnFieldInvoiceNr         : " + sReturnFieldInvoiceNr);
        System.out.println("* sReturnFieldInvoiceBalance    : " + sReturnFieldInvoiceBalance);
        System.out.println("* sReturnFieldInvoiceMaxBalance : " + sReturnFieldInvoiceMaxBalance);
        System.out.println("* sReturnFieldInvoiceStatus     : " + sReturnFieldInvoiceStatus + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00"));
%>

<form name="SearchForm" method="POST" onKeyDown="if(enterEvent(event,13)){searchInvoices();}"
      action="<c:url value='/popup.jsp'/>?Page=_common/search/searchPatientInvoice.jsp&ts=<%=getTs()%>">
<%-- hidden fields --%>
<input type="hidden" name="Action">
<input type="hidden" name="ReturnFieldInvoiceUid" value="<%=sReturnFieldInvoiceUid%>">
<input type="hidden" name="ReturnFieldInvoiceNr" value="<%=sReturnFieldInvoiceNr%>">
<input type="hidden" name="ReturnFieldInvoiceBalance" value="<%=sReturnFieldInvoiceBalance%>">
<input type="hidden" name="ReturnFieldInvoiceMaxBalance" value="<%=sReturnFieldInvoiceMaxBalance%>">
<input type="hidden" name="ReturnFieldInvoiceStatus" value="<%=sReturnFieldInvoiceStatus%>">
<input type="hidden" name="FindInvoicePatientId" value="<%=sFindInvoicePatientId%>"/>

<table width="100%" cellspacing="1" cellpadding="0" class="menu">
    <%-- TITLE --%>
    <tr class="admin">
        <td colspan="4"><%=getTran("web", "searchpatientinvoice", sWebLanguage)%>
        </td>
    </tr>

    <%
        if (!"false".equalsIgnoreCase(request.getParameter("header"))) {
    %>
    <%-- INVOICE DATE --%>
    <tr>
        <td class="admin2" width="120" nowrap><%=getTran("Web", "date", sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="330" nowrap><%=
            writeDateField("FindInvoiceDate", "SearchForm", sFindInvoiceDate, sWebLanguage)%>
        </td>
    </tr>

    <%-- INVOICE NR --%>
    <tr>
        <td class="admin2"><%=getTran("web", "number", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceNr" size="10" maxlength="10"
                   onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindInvoiceNr%>">
        </td>
    </tr>

    <%-- INVOICE BALANCE MIN --%>
    <tr>
        <td class="admin2"><%=getTran("web", "balance", sWebLanguage)%> <%=getTran("web", "min", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceBalanceMin" size="10" maxlength="8"
                   onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMin%>">&nbsp;<%=
            sCurrency%>
        </td>
    </tr>

    <%-- INVOICE BALANCE MAX --%>
    <tr>
        <td class="admin2"><%=getTran("web", "balance", sWebLanguage)%> <%=getTran("web", "max", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" name="FindInvoiceBalanceMax" size="10" maxlength="8"
                   onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMax%>">&nbsp;<%=
            sCurrency%>
        </td>
    </tr>

    <%-- INVOICE STATUS --%>
    <tr>
        <td class="admin2"><%=getTran("web.finance", "patientinvoice.status", sWebLanguage)%>
        </td>
        <td class="admin2">
            <select class="text" name="FindInvoiceStatus">
                <option value=""></option>
                <%=ScreenHelper.writeSelect("finance.patientinvoice.status", sFindInvoiceStatus, sWebLanguage)%>
            </select>
        </td>
    </tr>

    <%-- BUTTONS --%>
    <tr height="25">
        <td class="admin2">&nbsp;</td>
        <td class="admin2">
            <input class="button" type="button" onClick="searchInvoices();" name="searchButton"
                   value="<%=getTran("Web","search",sWebLanguage)%>">&nbsp;
            <input class="button" type="button" onClick="clearSearchFields();" name="clearButton"
                   value="<%=getTran("Web","clear",sWebLanguage)%>">
        </td>
    </tr>
    <%
        }
    %>
    <tr>
        <%-- SEARCH RESULTS TABLE --%>
    <tr>
        <td valign="top" colspan="3" class="white" width="100%">
            <div id="divFindRecords">
            </div>
        </td>
    </tr>
</table>

<br/>

<%-- BUTTONS --%>
<center>
    <input type="button" class="button" name="buttonClose" value="<%=getTran("Web","Close",sWebLanguage)%>"
           onclick="window.close();">
</center>
</form>

<script>
    window.resizeTo(450, 500);

    <%-- CLEAR SEARCH FIELDS --%>
    function clearSearchFields() {
        SearchForm.FindInvoiceDate.value = "";
        SearchForm.FindInvoiceNr.value = "";
        SearchForm.FindInvoiceBalanceMin.value = "";
        SearchForm.FindInvoiceBalanceMax.value = "";
        SearchForm.FindInvoiceStatus.value = "";
        SearchForm.FindInvoiceDate.focus();
    }

    <%-- SEARCH PRESTATIONS --%>
    function searchInvoices() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientInvoiceShow.jsp', SearchForm);
    }

    <%-- SELECT INVOICE --%>
    function selectInvoice(sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceBalance, sInvoiceStatus) {
        if ("<%=sReturnFieldInvoiceUid%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldInvoiceUid%>")[0].value = sInvoiceUid;
        }

        if ("<%=sReturnFieldInvoiceNr%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldInvoiceNr%>")[0].value = sInvoiceNr;
        }

        if ("<%=sReturnFieldInvoiceBalance%>".length > 0) {
            if (window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value.length == 0) {
                window.opener.document.getElementsByName("<%=sReturnFieldInvoiceBalance%>")[0].value = format_number(sInvoiceBalance, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
            }
        }

        if ("<%=sReturnFieldInvoiceMaxBalance%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldInvoiceMaxBalance%>")[0].value = format_number(sInvoiceBalance, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
        }

        if ("<%=sReturnFieldInvoiceStatus%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldInvoiceStatus%>")[0].value = sInvoiceStatus;
        }

    <%
    if (sFunction.length()>0){
        out.print("window.opener."+sFunction+";");
    }
    %>

        window.close();
    }

    <%
    if (sAction.equalsIgnoreCase("search")){
        out.print("searchInvoices();") ;
    }
    %>

</script>

<%-- CALENDAR FRAMES --%>
<iframe width="174" height="189" name="gToday:normal1:agenda.js:gfPop1" id="gToday:normal1:agenda.js:gfPop1"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>
<iframe width="174" height="189" name="gToday:normal2:agenda.js:gfPop2" id="gToday:normal2:agenda.js:gfPop2"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>
<iframe width="174" height="189" name="gToday:normal3:agenda.js:gfPop3" id="gToday:normal3:agenda.js:gfPop3"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>
