<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%@ page import="java.util.*" %>
<%
    // form data
    String sVarCode = checkString(request.getParameter("VarCode")),
           sVarText = checkString(request.getParameter("VarText")),
           sFindText = checkString(request.getParameter("FindText")).toUpperCase();
%>
<form name="SearchForm" method="POST" onSubmit="doFind();return false;" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%-- hidden fields --%>
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="FindCode">
    <input type="hidden" name="ViewCode">

    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="menu">
        <tr>
            <td width="100%" height="25">
                &nbsp;<%=getTran("Web", "Find", sWebLanguage)%>&nbsp;&nbsp;
                <input type="text" name="FindText" class="text" value="<%=sFindText%>" size="40">

                <%-- buttons --%>
                <input class="button" type="button" name="FindButton" value="<%=getTran("Web","find",sWebLanguage)%>"
                       onClick="doFind();">&nbsp;
                <input class="button" type="button" name="ClearButton" value="<%=getTran("Web","clear",sWebLanguage)%>"
                       onClick="clearSearchFields();">
            </td>
        </tr>
        <tr>
            <td class="navigation_line" height="1"/>
        </tr>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td class="white" style="vertical-align:top;">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>
<script>
    doFind();
    window.resizeTo(550, 520);
    SearchForm.FindText.focus();

    function selectParentCategory(sCode, sText) {
        window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sCode;
        window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sText;
        window.opener.document.getElementsByName('<%=sVarText%>')[0].title = sText;

        if (window.opener.document.getElementsByName('<%=sVarCode%>')[0] != null) {
            if (window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange != null) {
                window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange();
            }
        }

        window.close();
    }

    function populateCategory(sID) {
        SearchForm.FindCode.value = sID;
        ajaxChangeSearchResults('_common/search/searchByAjax/searchCategoryShow.jsp', SearchForm);
    }
    <%-- CLEAR SEARCH FIELDS --%>
    function clearSearchFields() {
        SearchForm.FindText.value = "";
        SearchForm.FindText.focus();
    }

    function viewCategory(sID) {
        SearchForm.FindCode.value = sID;
        SearchForm.ViewCode.value = sID;
        ajaxChangeSearchResults('_common/search/searchByAjax/searchCategoryShow.jsp', SearchForm);
    }

    function doFind() {
        SearchForm.FindCode.value = "";
        SearchForm.ViewCode.value = "";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchCategoryShow.jsp', SearchForm);
    }
</script>