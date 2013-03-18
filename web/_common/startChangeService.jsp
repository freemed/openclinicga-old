<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditDefaultService = checkString(request.getParameter("EditDefaultService"));
    String sActionField = checkString(request.getParameter("ActionField"));
    String sNextPage = checkString(request.getParameter("NextPage"));


   if ((sActionField.equals("update"))&&(sEditDefaultService.length()>0)){
        User.setActiveServiceById(activeUser.userid);
        User.setUpdatetimeAndActiveServiceByIdAndService(activeUser.userid,sEditDefaultService);
        activeUser.initializeService();
        session.setAttribute("activeMedicalCenter",sEditDefaultService);
        session.setAttribute("activeUser",activeUser);
        out.print("<script>window.location.href='main.do?Page="+sNextPage+"&NextPage=ok&CheckEmail=true'</script>");
    }
%>
<form name="UserProfile" action="main.do?Page=_common/startChangeService.jsp?ts=<%=getTs()%>" method="post">
<table border="0" width="100%" cellspacing="1" class="list">
    <tr class="admin">
        <td colspan="2">&nbsp;&nbsp;<%=(getTran("Web.UserProfile","ChangeService",sWebLanguage))%>&nbsp;</td>
    </tr>

    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.UserProfile","SelectService",sWebLanguage)%></td>
        <td class="admin2">
            <select name='EditDefaultService' class="text">
                <%
                    Service service;
                    for (int i=0; i<activeUser.vServices.size(); i++){
                        service = (Service)activeUser.vServices.elementAt(i);

                        %><option value="<%=service.code%>"<%if(service.code.equals(activeUser.activeService.code)){out.print(" selected");}%>><%=getTran("Service",service.code,sWebLanguage)%></option><%
                    }
                %>
            </select>
            <input type='button' name='ButtonSaveUserProfile' class="button" value='<%=getTran("Web","Select",sWebLanguage)%>' onclick="saveTransaction('update')">
        </td>
    </tr>
</table>

<input type="hidden" name="ActionField">
<input type="hidden" name="NextPage" value="<%=sNextPage%>">

<script>
  function saveTransaction(action){
    UserProfile.ActionField.value = action;
    UserProfile.ButtonSaveUserProfile.disabled = true;
    UserProfile.submit();
  }
</script>
</form>