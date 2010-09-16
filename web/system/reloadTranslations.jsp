<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>
<%
    String sReload = checkString(request.getParameter("ReloadButton"));
    String sText = getTran("Web.Translations","ReloadText",sWebLanguage);

    if (sReload.length()>0){
        reloadSingleton(session);
        sText = getTran("Web.Translations","TranslationsAreReloaded",sWebLanguage);
    }
%>
<form name="workForm" method="post">
<%=writeTableHeader("Web.manage","Translations",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<table border="0" width='100%' align='center' cellspacing="0" class="menu">
    <tr>
        <td><br>&nbsp;<%=sText%><br><br></td>
    </tr>
</table>
<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input type='submit' name="ReloadButton" class="button" value='<%=getTran("Web.Translations","Reload",sWebLanguage)%>'>&nbsp;
    <Input class='button' type=button name=cancel value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick='javascript:window.location.href="main.do?Page=system/menu.jsp"'>
<%=ScreenHelper.alignButtonsStop()%>
</form>