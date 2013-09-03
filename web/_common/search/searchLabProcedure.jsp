<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%
    String sFindLabProcedureName = checkString(request.getParameter("FindLabProcedureName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldUid")),sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr"));
%>
<form name="SearchForm" method="POST" onkeyup="if(enterEvent(event,13)){searchProcedures();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ReturnFieldUid" value="<%=sReturnFieldUid%>">
    <input type="hidden" name="ReturnFieldDescr" value="<%=sReturnFieldDescr%>">

    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%
            if (!"no".equalsIgnoreCase(request.getParameter("header"))) {
        %>
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("web", "searchlabprocedure", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin2" width="120" nowrap><%=getTran("web", "name", sWebLanguage)%>
            </td>
            <td class="admin2" width="380" nowrap>
                <input type="text" class="text" name="FindLabProcedureName" id="FindLabProcedureName" size="20" maxlength="20"
                       value="<%=sFindLabProcedureName%>" onkeyup="searchLabProcedures();">
            </td>
        </tr>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchLabProcedures();" name="searchButton"
                       value="<%=getTran("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td valign="top" colspan="2" class="white" width="100%">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>

<script>
    window.resizeTo(800, 600);
    SearchForm.FindLabProcedureName.focus();

    function clearFields() {
        SearchForm.FindLabProcedureName.value = "";
    }

    function searchLabProcedures() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchLabProcedureShow.jsp', SearchForm);
    }

    function setLabProcedure(uid, descr) {
        if ("<%=sReturnFieldUid%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
        }
        if ("<%=sReturnFieldDescr%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldDescr%>")[0].value = descr;
        }

    <%
    if (sFunction.length()>0){
        out.print("window.opener."+sFunction+";");
    }
    %>

        window.close();
    }
    window.setTimeout("document.getElementsByName('FindLabProcedureName')[0].focus();")
</script>
