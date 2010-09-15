<%@ page import="java.text.DecimalFormat" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%=sJSDROPDOWNMENU%>
<%=sJSNUMBER%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoiceDate = checkString(request.getParameter("FindInvoiceDate")),
            sFindInvoiceNr = checkString(request.getParameter("FindInvoiceNr")),
            sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
            sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
            sFindInvoiceInsurarUID = checkString(request.getParameter("FindInvoiceInsurarUID")),
            sFindInvoiceInsurarText = checkString(request.getParameter("FindInvoiceInsurarText")),
            sFindInvoiceStatus = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid = checkString(request.getParameter("ReturnFieldInvoiceUid")),
            sReturnFieldInvoiceNr = checkString(request.getParameter("ReturnFieldInvoiceNr")),
            sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
            sReturnFieldInvoiceStatus = checkString(request.getParameter("ReturnFieldInvoiceStatus")),
            sReturnFieldInsurarUid = checkString(request.getParameter("ReturnFieldInsurarUid")),
            sReturnFieldInsurarName = checkString(request.getParameter("ReturnFieldInsurarName"));


    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");

%>
<form name="SearchForm" method="POST" onsubmit="searchInvoices();return false;"
      onkeydown="if(enterEvent(event,13)){searchInvoices();}"
      action="<c:url value='/popup.jsp'/>?Page=_common/search/searchInsurarInvoice.jsp&ts=<%=getTs()%>">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">

    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("web", "searchinsurarinvoice", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("medical.accident", "insurancecompany", sWebLanguage)%>
            </td>
            <td>
                <input type="hidden" name="FindInvoiceInsurarUID" value="<%=sFindInvoiceInsurarUID%>">
                <input type="text" class="text" readonly name="FindInvoiceInsurarText"
                       value="<%=sFindInvoiceInsurarText%>" size="60">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link"
                     alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
                     alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web", "date", sWebLanguage)%>&nbsp;</td>
            <td><%=writeDateField("FindInvoiceDate", "SearchForm", sFindInvoiceDate, sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td><%=getTran("web", "number", sWebLanguage)%>
            </td>
            <td>
                <input type="text" class="text" name="FindInvoiceNr" size="12" maxlength="12"
                       onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindInvoiceNr%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("web", "balance", sWebLanguage)%>
            </td>
            <td>
                <%=getTran("web", "min", sWebLanguage)%>:
                <input type="text" class="text" name="FindInvoiceBalanceMin" size="10" maxlength="8"
                       onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMin%>">&nbsp;<%=sCurrency%>
                &nbsp;
                <%=getTran("web", "max", sWebLanguage)%>:
                <input type="text" class="text" name="FindInvoiceBalanceMax" size="10" maxlength="8"
                       onKeyUp="if(!isNumberNegativeAllowed(this)){this.value='';}" value="<%=sFindInvoiceBalanceMax%>">&nbsp;<%=sCurrency%>
            </td>
        </tr>
        <tr>
            <td><%=getTran("web.finance", "patientinvoice.status", sWebLanguage)%>
            </td>
            <td>
                <select class="text" name="FindInvoiceStatus">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("finance.patientinvoice.status", sFindInvoiceStatus, sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%-- BUTTONS --%>
        <tr height="25">
            <td/>
            <td>
                <input class="button" type="button" onClick="searchInvoices();" name="searchButton"
                       value="<%=getTran("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td valign="top" colspan="3" class="white" width="100%">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <center>
        <input type="button" class="button" name="closeButton" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
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
    window.resizeTo(700, 600);
    getOpenerInsurance();
    function searchInsurar() {
        openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>&ReturnFieldInsurarUid=FindInvoiceInsurarUID&ReturnFieldInsurarName=FindInvoiceInsurarText");
    }

    function doClearInsurar() {
        SearchForm.FindInvoiceInsurarUID.value = "";
        SearchForm.FindInvoiceInsurarText.value = "";
    }

    <%-- CLEAR SEARCH FIELDS --%>
    function clearSearchFields() {
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
    function searchInvoices() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchInsurarInvoiceShow.jsp', SearchForm);
    }

    <%-- GET SELECTED ASSURANCE --%>
    function getOpenerInsurance() {

        var form = window.opener.document.forms["EditForm"];
        var InsuranceId = form['EditCreditInsurarUid'];
        var InsuranceName = form['EditCreditInsurarName'];


        if (InsuranceName) {
            var newForm = document.forms["SearchForm"];
            newForm["FindInvoiceInsurarUID"].value = InsuranceId.value;
            newForm["FindInvoiceInsurarText"].value = InsuranceName.value;
            searchInvoices();
        }

    }

    <%-- SELECT INVOICE --%>
    function selectInvoice(sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceBalance, sInvoiceStatus, sInsurarUid, sInsurarName) {
        if ("<%=sReturnFieldInvoiceUid%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldInvoiceUid%>"].value = sInvoiceUid;
        }

        if ("<%=sReturnFieldInvoiceNr%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldInvoiceNr%>"].value = sInvoiceNr;
        }

        if ("<%=sReturnFieldInvoiceBalance%>".length > 0) {
            if (sInvoiceBalance > 0 && window.opener.document.all["<%=sReturnFieldInvoiceBalance%>"].value * 1 == 0) {
                window.opener.document.all["<%=sReturnFieldInvoiceBalance%>"].value = format_number(sInvoiceBalance, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
            }
        }

        if ("<%=sReturnFieldInvoiceStatus%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldInvoiceStatus%>"].value = sInvoiceStatus;
        }

        if ("<%=sReturnFieldInsurarUid%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldInsurarUid%>"].value = sInsurarUid;
        }

        if ("<%=sReturnFieldInsurarName%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldInsurarName%>"].value = sInsurarName;
        }

    <%
    if (sFunction.length()>0){
        out.print("window.opener."+sFunction+";");
    }
    %>

        if (window.opener.loadUnassignedCredits != null) {
            window.opener.loadUnassignedCredits(sInsurarUid);
        }

        window.close();
    }
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