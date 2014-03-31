<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%@ page import="java.util.*" %>
<%!
    boolean needsbeds = false;
	boolean needsvisits = false;
    boolean showinactive = false;
%>
<%
	needsbeds = "1".equalsIgnoreCase(request.getParameter("needsbeds"));
	needsvisits = "1".equalsIgnoreCase(request.getParameter("needsvisits"));
    showinactive = "1".equalsIgnoreCase(request.getParameter("showinactive"));
    // form data
    String sVarCode = checkString(request.getParameter("VarCode")),
            sVarText = checkString(request.getParameter("VarText")),
            sFindText = checkString(request.getParameter("FindText")).toUpperCase();
    String sStartID=checkString(request.getParameter("FindCode"));
%>
<body onblur="window.focus()">
<form name="SearchForm" method="POST" onSubmit="doFind();return false;" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%-- hidden fields --%>
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="FindCode">
    <input type="hidden" name="ViewCode">
    <input type="hidden" name="showinactive">
    <input type="hidden" name="needsbeds" value="<%=checkString(request.getParameter("needsbeds"))%>"/>
    <input type="hidden" name="needsvisits" value="<%=checkString(request.getParameter("needsvisits"))%>"/>

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
        <%-- menubar --%>
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
        <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>
<script>
    doFind();
    window.resizeTo(550, 520);
    SearchForm.FindText.focus();


    function selectParentService(sCode, sText) {
        window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sCode;

        if ('1' == '<%=MedwanQuery.getInstance().getConfigString("showUnitID")%>') {
            window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sCode + " " + sText;
        }
        else {
            window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sText;
        }

        window.opener.document.getElementsByName('<%=sVarText%>')[0].title = sText;

        if (window.opener.submitSelect != null) {
            window.opener.submitSelect()
        }
        ;

        if (window.opener.document.getElementsByName('<%=sVarCode%>')[0] != null) {
            if (window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange != null) {
                window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange();
            }
        }
        
        window.close();
    }

    function populateService(sID) {
        SearchForm.FindCode.value = sID;
        SearchForm.showinactive.value="<%=showinactive?"1":"0"%>";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp', SearchForm);
    }
    <%-- CLEAR SEARCH FIELDS --%>
    function clearSearchFields() {
        SearchForm.FindText.value = "";
        SearchForm.FindText.focus();
    }

    function viewService(sID) {
        SearchForm.FindCode.value = sID;
        SearchForm.ViewCode.value = sID;
        SearchForm.showinactive.value="<%=showinactive?"1":"0"%>";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp', SearchForm);
    }

    function doFind() {
        SearchForm.FindCode.value = "<%=sStartID%>";
        SearchForm.ViewCode.value = "";
        SearchForm.showinactive.value="<%=showinactive?"1":"0"%>";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp', SearchForm);
    }
    window.setInterval("window.focus();",1000);
</script>
</body>