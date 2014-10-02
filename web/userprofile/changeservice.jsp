<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sAction             = checkString(request.getParameter("Action"));
    String sEditDefaultService = checkString(request.getParameter("EditDefaultService"));
    String sAddServiceCode     = checkString(request.getParameter("AddServiceCode"));
    //--- ADD -------------------------------------------------------------------------------------
    if (sAction.equals("add") && sAddServiceCode.length()>0){
        boolean bExists;

        bExists = UserService.exists(activeUser.userid,sAddServiceCode);
        if (!bExists){
            UserService uService = new UserService();
            uService.setUserid(Integer.parseInt(activeUser.userid));
            uService.setServiceid(sAddServiceCode);
            if (activeUser.vServices.size()==0){
                uService.setActiveservice(1);
            }
            else {
                uService.setActiveservice(0);
            }
            uService.saveToDB();
            activeUser.initializeService();
            session.setAttribute("activeUser",activeUser);
        }
    }
    //--- UPDATE ----------------------------------------------------------------------------------
    else if (sAction.equals("update") && sEditDefaultService.length()>0){
        UserService uService = new UserService();
        uService.setActiveservice(1);
        uService.setUserid(Integer.parseInt(activeUser.userid));
        uService.setServiceid(sEditDefaultService);
        uService.update();

        activeUser.initializeService();

        Parameter parameter = new Parameter("defaultserviceid",sEditDefaultService);
        activeUser.removeParameter("defaultserviceid");
        activeUser.updateParameter(parameter);
        session.setAttribute("activeMedicalCenter",sEditDefaultService);
        activeUser.parameters.add(parameter);
        activeUser.activeService.code = sEditDefaultService;
        session.setAttribute("activeUser",activeUser);
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete") && sEditDefaultService.length()>0){
        UserService uService = new UserService();
        uService.setUserid(Integer.parseInt(activeUser.userid));
        uService.setServiceid(sEditDefaultService);
        uService.delete();
        activeUser.initializeService();
        session.setAttribute("activeUser",activeUser);
    }
%>
<form name="UserProfile" method="post">
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.UserProfile","ChangeService",sWebLanguage," doBack();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- SELECT SERVICE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Service",sWebLanguage)%></td>
            <td class="admin2">
                <select name='EditDefaultService' class="text">
                <%
                    Service service;
                    for (int i=0; i<activeUser.vServices.size(); i++){
                        service = (Service)activeUser.vServices.elementAt(i);
                        if(service!=null && service.code.length()>0){
                        	%><option value="<%=service.code%>"<%if(service.code.equals(activeUser.activeService.code)){out.print(" selected");}%>><%=service.code+": "+getTranNoLink("Service",service.code,sWebLanguage)%></option><%
                        }
                    }
                %>
                </select>
                <%-- BUTTONS --%>
                <input type='button' name='ButtonSaveUserProfile' class="button" value='<%=getTranNoLink("Web","Select",sWebLanguage)%>' onclick="saveTransaction('update');">
                <input type='button' name='ButtonDeleteUserProfile' class="button" value='<%=getTranNoLink("Web","Delete",sWebLanguage)%>' onclick="saveTransaction('delete');">
            </td>
        </tr>
        <%-- ADD SERVICE --%>
        <tr>
            <td class="admin"><%=getTran("Web","add",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="AddServiceCode">
                <input class="text" type="text" name="AddServiceDescription" size="<%=sTextWidth%>" readonly>
                <%-- BUTTONS --%>
                <%=ScreenHelper.writeServiceButton("buttonService","AddServiceCode","AddServiceDescription",sWebLanguage,sCONTEXTPATH)%>
                <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="saveTransaction('add')">
            </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type='button' name='backButton' class="button" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <script>
      function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
      }

      function saveTransaction(action){
        UserProfile.Action.value = action;
        UserProfile.submit();
      }
    </script>
</form>