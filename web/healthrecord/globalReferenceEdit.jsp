<%@ page import="be.openclinic.adt.Reference" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("reference","select",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));
    String sUID = checkString(request.getParameter("EditUID"));
    String sExecutionDate = "";
    String sRequestServiceName = "";
    String sCreationUserName = "";
    Reference reference;

    if (sAction.equals("SAVE")){
        if (sUID.length()==0){
            reference = new Reference();
            reference.setCreateDateTime(getSQLTime());
        }
        else{
            reference = Reference.get(sUID);
            reference.setUid(sUID);
        }

        String sCreationServiceUID = "";

        if (activeUser.activeService!=null){
            sCreationServiceUID = checkString(activeUser.activeService.code);
        }
        reference.setPatientUID(activePatient.personid);
        reference.setRequestDate(ScreenHelper.getSQLDate(request.getParameter("EditRequestDate")));
        reference.setRequestServiceUID(checkString(request.getParameter("EditRequestServiceUID")));
        reference.setStatus(checkString(request.getParameter("EditStatus")));
        reference.setExecutionDate(ScreenHelper.getSQLDate(request.getParameter("EditExecutionDate")));
        reference.setCreationUserUID(checkString(request.getParameter("EditCreationUserUID")));
        reference.setCreationServiceUID(sCreationServiceUID);
        reference.setUpdateDateTime(getSQLTime());
        reference.setUpdateUser(activeUser.userid);
        reference.store();
        %>
        <script>
            window.location.href = "<c:url value='/main.do'/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>";
        </script>
        <%
    }
    else {

       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        if (sUID.length()>0){
            reference = Reference.get(sUID);
            if (reference.getCreationUserUID().length()>0){
                sCreationUserName = ScreenHelper.getFullUserName(reference.getCreationUserUID(),ad_conn);
            }
        }
        else {
            reference = new Reference();
            reference.setRequestDate(ScreenHelper.parseDate(getDate()));
            reference.setCreationUserUID(activeUser.userid);
            sCreationUserName = ScreenHelper.getFullUserName(activeUser.userid,ad_conn);
        }
        ad_conn.close();

        if (reference.getExecutionDate()!=null){
            sExecutionDate = checkString(ScreenHelper.stdDateFormat.format(reference.getExecutionDate()));
        }

        if (checkString(reference.getRequestServiceUID()).length()>0){
            sRequestServiceName = getTran("service",reference.getRequestServiceUID(),sWebLanguage);
        }
%>
<form name="editForm" method="post" action="<c:url value='/main.do'/>?Page=healthrecord/referenceEdit.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","internal_references",sWebLanguage," doMyBack();")%>
    <table class="list" width="100%" border="0" cellspacing="1" cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","reference.request.date",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("EditRequestDate","editForm",checkString(ScreenHelper.stdDateFormat.format(reference.getRequestDate())),sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reference.request.service",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' TYPE="text" NAME="EditRequestServiceName" readonly size="<%=sTextWidth%>" TITLE="<%=sRequestServiceName%>" VALUE="<%=sRequestServiceName%>">
                <%=ScreenHelper.writeServiceButton("buttonRequestServiceUID","EditRequestServiceUID", "EditRequestServiceName", sWebLanguage,sCONTEXTPATH)%>
                <input TYPE="hidden" NAME="EditRequestServiceUID" VALUE="<%=checkString(reference.getRequestServiceUID())%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reference.status",sWebLanguage)%></td>
            <td class="admin2">
                <input type='text' class='text' name="EditStatus" value="<%=checkString(reference.getStatus())%>" size="<%=sTextWidth%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reference.execution.date",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("EditExecutionDate","editForm",sExecutionDate,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reference.createdby",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="EditCreationUserUID" name="EditCreationUserUID" value="<%=checkString(reference.getCreationUserUID())%>">
                <input class="text" type="text" name="EditCreationUserName" readonly size="<%=sTextWidth%>" value="<%=sCreationUserName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchUser('EditCreationUserUID','EditCreationUserName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditCreationUserUID').value='';editForm.EditCreationUserName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if ((activeUser.getAccessRight("reference.add") || activeUser.getAccessRight("reference.edit"))){
    %>
            <INPUT class="button" type="button" name="buttonSave" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){doMyBack();}">
            </td>
        </tr>
    </table>
    <input type='hidden' name='Action' value=''>
    <input type='hidden' name='EditUID' value='<%=reference.getUid()%>'>
    <script>

    function searchUser(userID,userName){
        openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+userID+"&ReturnName="+userName);
    }

    function submitForm(){
        editForm.buttonSave.disabled = true;
        editForm.Action.value = "SAVE";
        editForm.submit();
    }

    function doMyBack(){
        window.location.href='<c:url value="/main.do"/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>';
    }
    </script>
</form>
<%
    }
%>