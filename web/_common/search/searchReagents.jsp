<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%
    String sFindReagentName = checkString(request.getParameter("FindReagentName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr")),
           sReturnFieldUnit = checkString(request.getParameter("ReturnFieldUnit"));
%>
<form name="SearchForm" method="POST" onkeyup="if(enterEvent(event,13)){searchReagents();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ReturnFieldUid" value="<%=sReturnFieldUid%>">
    <input type="hidden" name="ReturnFieldDescr" value="<%=sReturnFieldDescr%>">
    <input type="hidden" name="ReturnFieldUnit" value="<%=sReturnFieldUnit%>">

    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%
            if (!"no".equalsIgnoreCase(request.getParameter("header"))) {
        %>
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("web", "searchreagent", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin2" width="120" nowrap><%=getTran("web", "name", sWebLanguage)%>
            </td>
            <td class="admin2" width="380" nowrap>
                <input type="text" class="text" name="FindReagentName" id="FindReagentName" size="20" maxlength="20"
                       value="<%=sFindReagentName%>" onkeyup="searchReagents();">
            </td>
        </tr>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchReagents();" name="searchButton"
                       value="<%=getTranNoLink("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="2" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>

<script>
    window.resizeTo(800, 600);
    SearchForm.FindReagentName.focus();

    function clearFields() {
        SearchForm.FindReagentName.value = "";
    }

    function searchReagents() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchReagentShow.jsp', SearchForm);
    }

    function setReagent(uid, descr,unit) {
        if ("<%=sReturnFieldUid%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
        }
        if ("<%=sReturnFieldDescr%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldDescr%>")[0].value = descr;
        }
        if ("<%=sReturnFieldUnit%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldUnit%>")[0].value = unit;
        }

    <%
    if (sFunction.length()>0){
        out.print("window.opener."+sFunction+";");
    }
    %>

        window.close();
    }
    window.setTimeout("document.getElementsByName('FindReagentName')[0].focus();")
</script>
