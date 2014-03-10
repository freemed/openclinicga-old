<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));
    // message
    String msg;
    if(activePatient==null){
        msg = getTran("Web","noactivepatient",sWebLanguage);
    }
    else{
        msg = getTran("Web.manage","clicktoarchiveactivefile",sWebLanguage);
    }

    //#############################################################################################
    //### Archive (COPY ACTIVE ADMIN TO ADMINHISTORY) #############################################
    //#############################################################################################
    if(sAction.equals("Archive")){
        boolean isFound = AdminPerson.copyActiveToHistory(activePatient.personid);

        if(isFound){
            msg = getTran("Web.manage","activefilearchived",sWebLanguage);
            // disable archive-button
            out.print("<script defer>archiveForm.archiveButton.disabled = true;</script>");
            out.flush();

            Debug.println("ActivePatient (personid "+activePatient.personid+") moved to AdminHistory");
        }
    }
%>
<form name="archiveForm" method="post">
    <input type="hidden" name="Action" value="">
    <%=writeTableHeader("Web.manage","archiveActiveFile",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width='100%' cellspacing="0" class="menu">
        <tr>
            <td><br>&nbsp;<%=msg%><br><br></td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" name="archiveButton" value="<%=getTran("Web.manage","archivefile",sWebLanguage)%>" onClick="doArchive();">&nbsp;
        <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
        <br><br>
        <%-- link to reactivate archived file --%>
        <img src='<c:url value="/_img/pijl.gif"/>'>
        <a  href="<c:url value='/main.do?Page=system/reactivateArchivedFile.jsp?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.manage","reactivatearchivedfile",sWebLanguage)%></a>&nbsp;
    <%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
  <%
      if(activePatient==null){
          %>archiveForm.archiveButton.disabled = true;<%
      }
  %>

  function doArchive(){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=areyousuretoarchiveactivefile";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

    if(answer==1){
      archiveForm.Action.value = 'Archive';
      archiveForm.archiveButton.disabled = true;
      archiveForm.submit();
    }
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp";
  }
</script>