<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sImmatnew = "", sImmatold = "", sNatreg = "", sName = "", sFirstname = "", sDateofbirth = "",
            msg = "", sClass = "1", sResult = "";

    // after reactivation, the page is reloaded, losing the reactivated-message, so here that is fixed.
    boolean displaymsg = checkString(request.getParameter("displaymsg")).equals("true");
    if (displaymsg) msg = getTran("Web.manage", "archivedfilereactivated", sWebLanguage);

    //#############################################################################################
    //### Search ##################################################################################
    //#############################################################################################
    if (sAction.equals("Search")) {
        // retreive form-data
        sImmatnew = checkString(request.getParameter("immatnew"));
        sImmatold = checkString(request.getParameter("immatold"));
        sNatreg = checkString(request.getParameter("natreg"));
        sName = checkString(request.getParameter("name"));
        sFirstname = checkString(request.getParameter("firstname"));
        sDateofbirth = checkString(request.getParameter("dateofbirth"));

        // search AdminHistory with specified criteria
        Vector vAH = AdminHistory.searchAdminHistoryWithCriteria(sImmatnew, sImmatold, sNatreg, sName, sFirstname, sDateofbirth);
        AdminHistory objAH;

        Iterator iter = vAH.iterator();


        String altTitle = getTran("web.manage", "reactivatefile", sWebLanguage);

        while (iter.hasNext()) {
            objAH = (AdminHistory) iter.next();
            // alternate row-styles
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            sResult += "<tr onClick=\"doReactivate('" + objAH.getPersonid() + "');\" title='" + altTitle + "' class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\">" +
                    " <td>&nbsp;" + objAH.getImmatnew() + "</td>" +
                    " <td>" + objAH.getNatreg() + "</td>" +
                    " <td>" + objAH.getLastname() + " " + objAH.getFirstname() + "</td>" +
                    " <td>" + objAH.getGender().toUpperCase() + "</td>" +
                    " <td>" + ScreenHelper.getSQLDate(objAH.getDateofbirth()) + "</td>" +
                    "</tr>";

        }
        if (vAH.size() == 0) {
            // no records found
            msg = getTran("web", "nopatientsfound", sWebLanguage);
        }
    }
    //#############################################################################################
    //### Reactivate (AdminHistory to Admin) ######################################################
    //#############################################################################################
    else if (sAction.equals("Reactivate")) {
        // get data of requested history-person
        String historyPersonid = checkString(request.getParameter("historyPersonid"));
        if (!AdminHistory.existsByPersonid(historyPersonid)) {
            msg = getTran("web.manage", "personnotfound", sWebLanguage);
        } else {
            AdminHistory.reactivateArchivedFile(historyPersonid);
        }
        // refresh page
        out.print("<script defer>window.location.href = '" + sCONTEXTPATH + "/main.do?Page=system/reactivateArchivedFile.jsp&personid=" + historyPersonid + "&displaymsg=true&ts=" + getTs() + "';</script>");
        out.flush();
    }
%>
<form name="reactivateForm" method="post" action="<%=sCONTEXTPATH%>/main.do?Page=system/reactivateArchivedFile.jsp?ts=<%=getTs()%>" onKeyDown="if(event.keyCode==13){searchHistoryPatient();}">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="historyPersonid" value="">
    <%=writeTableHeader("Web.manage","reactivatearchivedfile",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width="100%" cellspacing="1" class="menu">
        <%-- search fields : row 1 --%>
        <tr>
            <td width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","Name",sWebLanguage)%></td>
            <td><input class="text" TYPE="TEXT" style="text-transform:uppercase" NAME="name" VALUE="<%=sName%>" size="<%=sTextWidth%>" onblur="validateText(this);limitLength(this);"></td>
        </tr>
        <tr>
            <td><%=getTran("Web","Firstname",sWebLanguage)%></td>
            <td><input class="text" type="TEXT" style="text-transform:uppercase" name="firstname" value="<%=sFirstname%>" size="<%=sTextWidth%>" onblur="validateText(this);limitLength(this);"></td>
        </tr>
        <tr>
            <td><%=getTran("Web","DateOfBirth",sWebLanguage)%></td>
            <td><input class="text" type="TEXT" name="dateofbirth" value="<%=sDateofbirth%>" size="<%=sTextWidth%>" OnBlur="checkDate(this)" maxlength="10"></td>
        </tr>
        <%-- search fields : row 2 --%>
        <tr>
            <td><%=getTran("Web","natreg.short",sWebLanguage)%></td>
            <td><input class="text" TYPE="TEXT" NAME="natreg" VALUE="<%=sNatreg%>" size="<%=sTextWidth%>" onblur="validateText(this);limitLength(this);"></td>
        </tr>
        <tr>
            <td><%=getTran("Web","immatnew",sWebLanguage)%></td>
            <td><input class="text" type="TEXT" style="text-transform:uppercase" name="immatnew" value="<%=sImmatnew%>" size="<%=sTextWidth%>" onblur="validateText(this);limitLength(this);"></td>
        </tr>
        <tr>
            <td><%=getTran("Web","immatold",sWebLanguage)%></td>
            <td><input class="text" type="TEXT" style="text-transform:uppercase" name="immatold" value="<%=sImmatold%>" size="<%=sTextWidth%>" onblur="validateText(this);limitLength(this);"></td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td/>
            <td>
                <input class="button" type="button" name="searchButton" onclick="searchHistoryPatient();" value="<%=getTran("Web","Find",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" name="clearButton" onClick="clearHistoryPatient();" value="<%=getTran("web","Clear",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <%-- search results --%>
    <%
        if(sResult.length() > 0){
            %>
                <br>
                <table width="100%" cellspacing="0">
                    <%-- header --%>
                    <tr height="20" class="admin">
                        <td width="107">&nbsp;<%=getTran("Web","immatnew",sWebLanguage)%></td>
                        <td width="107"><%=getTran("Web","natreg.short",sWebLanguage)%></td>
                        <td width="*"><%=getTran("Web","name",sWebLanguage)%></td>
                        <td width="50"><%=getTran("Web","gender",sWebLanguage)%>&nbsp;</td>
                        <td width="110"><%=getTran("Web","dateofbirth",sWebLanguage)%></td>
                    </tr>
                    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%=sResult%>
                    </tbody>
                </table>
            <%
        }
    %>
    <%-- message --%>
    <%
        if(msg.length() > 0){
            %><%=msg%><%
        }
    %>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <br><br>
        <%-- link to archive active file --%>
        <img src="<c:url value="/_img/pijl.gif"/>">
        <a class="menuItem" href="<c:url value='/main.do'/>?Page=system/archiveActiveFile.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.manage","archiveactivefile",sWebLanguage)%></a>&nbsp;
    <%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
  reactivateForm.name.focus();

  function searchHistoryPatient(){
    if(reactivateForm.name.value.length > 0 ||
       reactivateForm.firstname.value.length > 0 ||
       reactivateForm.dateofbirth.value.length > 0 ||
       reactivateForm.natreg.value.length > 0 ||
       reactivateForm.immatnew.value.length > 0 ||
       reactivateForm.immatold.value.length > 0 ){
      reactivateForm.Action.value = "Search";
      reactivateForm.searchButton.disabled = true;
      reactivateForm.submit();
    }
    else{
      reactivateForm.name.focus();
    }
  }

  function doReactivate(personid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=areyousuretoreactivatefile";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

    if(answer==1){
      <%-- set parameter for activePatient to be initialised (in dropdownmenu) --%>
      reactivateForm.action = reactivateForm.action+"&personid="+personid;

      reactivateForm.historyPersonid.value = personid;
      reactivateForm.Action.value = "Reactivate";
      reactivateForm.submit();
    }
  }

  function clearHistoryPatient(){
    reactivateForm.name.value = "";
    reactivateForm.firstname.value = "";
    reactivateForm.dateofbirth.value = "";
    reactivateForm.natreg.value = "";
    reactivateForm.immatnew.value = "";
    reactivateForm.immatold.value = "";

    reactivateForm.name.focus();
  }

  function doBack(){
    window.location.href = "<c:url value="/main.do"/>?Page=system/menu.jsp";
  }
</script>