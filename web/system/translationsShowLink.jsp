<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    boolean bShowLink = MedwanQuery.getInstance().getConfigString("showLinkNoTranslation").equalsIgnoreCase("on");
    String sButtonShowLink = checkString(request.getParameter("ButtonShowLink"));
    String sText;

    if(bShowLink){
        if(sButtonShowLink!=null){
            // disable showLink
            MedwanQuery.getInstance().setConfigString("showLinkNoTranslation","off");
            sText = getTran("Web.Translations","HideLink",sWebLanguage);
        }
        else {
            sText = getTran("Web.Translations","ShowLink",sWebLanguage);
        }
    }
    else{
        if(sButtonShowLink.length() > 0){
            // enable showLink
            MedwanQuery.getInstance().setConfigString("showLinkNoTranslation","on");
            sText = getTran("Web.Translations","ShowLink",sWebLanguage);
        }
        else{
            sText = getTran("Web.Translations","HideLink",sWebLanguage);
        }
    }
%>
<form name="workForm" method="post">
<%=writeTableHeader("Web.translations","ShowLink",sWebLanguage," doBack();")%>
<table border="0" width='100%' align='center' cellspacing="0" class="menu">
    <%-- BUTTON --%>
    <tr>
        <td><br>&nbsp;<input type='submit' name="ButtonShowLink" class="button" value='<%=sText%>'><br><br></td>
    </tr>
</table>
<%-- BACK BUTTON --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick='doBack();'>
<%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>