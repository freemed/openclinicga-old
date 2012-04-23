<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInsurarUid = checkString(request.getParameter("FindInsurarUid")),
            sFindInsurarName = checkString(request.getParameter("FindInsurarName")),
            sFindInsurarContact = checkString(request.getParameter("FindInsurarContact"));
    String sFunction = checkString(request.getParameter("doFunction"));
    String sExcludeCoverageplans = checkString(request.getParameter("ExcludeCoverageplans"));
    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldInsurarUid")),
            sReturnFieldName = checkString(request.getParameter("ReturnFieldInsurarName")),
            sReturnFieldContact = checkString(request.getParameter("ReturnFieldInsurarContact"));
    if (sAction.length() == 0 && sFindInsurarName.length() > 0) sAction = "search"; // default


    String msg = "";
%>
<form name="SearchForm" method="POST" onsubmit="searchInsurar();return false;">
    <input type="hidden" name="Action">
    <input type="hidden" name="FindInsurarUid" value="<%=sFindInsurarUid%>">
    <input type="hidden" name="FindInsurarContact" value="<%=sFindInsurarContact%>">
    <input type="hidden" name="doFunction" value="<%=sFunction%>">
    <input type="hidden" name="ExcludeCoverageplans" value="<%=sExcludeCoverageplans%>">
    <%-- SEARCH FIELDS --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td class="menu">
                &nbsp;<%=getTran("web", "insurar", sWebLanguage)%>&nbsp;&nbsp;<input type="text" class="text"
                                                                                     name="FindInsurarName" size="30"
                                                                                     maxChars="255"
                                                                                     value="<%=sFindInsurarName%>">
                <%-- BUTTONS --%>
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
                     alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input type="button" class="button" name="searchButton"
                       value="<%=getTranNoLink("Web","Search",sWebLanguage)%>" onClick="searchInsurar();">
            </td>
        </tr>
    </table>

    <div id="divFindRecords">
    </div>
    <center>
        <input type="button" class="button" name="closeButton" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>
<script>
    window.resizeTo(600, 525);


    function searchInsurar() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchInsurarShow.jsp', SearchForm);
    }

    function clearSearchFields() {
        SearchForm.FindInsurarName.value = "";
        SearchForm.FindInsurarName.focus();
    }

    function selectInsurar(uid, name, contact) {
        if ("<%=sReturnFieldUid%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldUid%>"].value = uid;
        }
        if ("<%=sReturnFieldName%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldName%>"].value = name;
        }
        if ("<%=sReturnFieldContact%>".length > 0) {
            window.opener.document.all["<%=sReturnFieldContact%>"].value = contact;
        }

	    <%
	    if (sFunction.length()>0){
	        out.print("window.opener."+sFunction+";");
	    }
	    %>

        window.close();
    }
    window.setTimeout("SearchForm.FindInsurarName.focus();", 1000);
</script>