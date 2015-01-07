<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String tab = checkString(request.getParameter("Tab"));
    if(tab.equals("")) tab = "Admin";

    boolean activePatientIsUser = false;
    if(activePatient!=null){
        activePatientIsUser = activePatient.isUser();
    }
%>
<form name="PatientEditForm" id="PatientEditForm" method="POST" action='<c:url value='/main.do'/>?Page=_common/patient/patienteditSave.jsp&SavePatientEditForm=ok&Tab=<%=tab%>&ts=<%=getTs()%>'>
    <%-- TABS -----------------------------------------------------------------------------------%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="tabs">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('Admin')" id="td0" nowrap>&nbsp;<b><%=getTran("Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
            <td class="tabs">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('AdminPrivate')" id="td1" nowrap>&nbsp;<b><%=getTran("Web","private",sWebLanguage)%></b>&nbsp;</td>
            <td class="tabs">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('AdminFamilyRelation')" id="td3" nowrap>&nbsp;<b><%=getTran("Web","AdminFamilyRelation",sWebLanguage)%></b>&nbsp;</td>
            <td class="tabs">&nbsp;</td>
            <td class="tabunselected" width="1%" onclick="activateTab('AdminResource')" id="td4" nowrap>&nbsp;<b><%=getTran("Web","AdminResource",sWebLanguage)%></b>&nbsp;</td>
            <td class="tabs" width="100%">&nbsp;</td>
        </tr>
    </table>
    
    <%-- ONE TAB --------------------------------------------------------------------------------%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr id="tr0-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdmin.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminPrivate.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminFamilyRelation.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr4-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminResource.jsp"),pageContext);%></td>
        </tr>
    </table>
    
    <%-- BUTTONS --%>
    <%
        if (activeUser.getAccessRight("patient.administration.edit")||activeUser.getAccessRight("patient.administration.add")){
            %>
                <div id="saveMsg"><%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%></div>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input class="button" type="button" name="SavePatientEditForm" value="<%=getTranNoLink("Web","Save",sWebLanguage)%>" onclick="checkSubmit();">&nbsp;
                    <input class="button" type="button" name="cancel" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onClick='window.location.href="<c:url value='/patientdata.do'/>?ts=<%=getTs()%>";'>&nbsp;
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>
</form>
    
<script>
  var maySubmit = true;
  var displayGenericAlert = true;

  <%-- CHECK SUBMIT --%>
  function checkSubmit(){
    maySubmit = true;
    if(maySubmit){ maySubmit = checkSubmitAdmin(); }
    if(maySubmit){ maySubmit = checkSubmitAdminPrivate(); }
    if(maySubmit){ maySubmit = checkSubmitAdminFamilyRelation(); }

    if(maySubmit){
      openPopup("/_common/patient/patienteditSavePopup.jsp&PersonID=<%=(activePatient!=null?activePatient.personid:"")%>&Lastname="+PatientEditForm.Lastname.value+"&Firstname="+PatientEditForm.Firstname.value+"&DateOfBirth="+PatientEditForm.DateOfBirth.value+"&ImmatNew="+PatientEditForm.ImmatNew.value+"&NatReg="+PatientEditForm.NatReg.value+"&ts=<%=getTs()%>");
    }
    else if(displayGenericAlert){  
      alertDialog("web.manage","somefieldsareempty");
    }
  }

  <%-- DO SUBMIT --%>
  function doSubmit(){
    PatientEditForm.SavePatientEditForm.disabled = true;
    PatientEditForm.submit();
  }

  <%-- ACTIVATE TAB --%>
  function activateTab(sTab){
    document.getElementById("tr0-view").style.display = "none";
    td0.className = "tabunselected";
    if(sTab=="Admin"){
      document.getElementById("tr0-view").style.display = "";
      td0.className = "tabselected";
      PatientEditForm.Lastname.focus();
      document.getElementById("saveMsg").style.display = "block";
    }

    document.getElementById("tr1-view").style.display = "none";
    td1.className = "tabunselected";
    if(sTab=="AdminPrivate"){
      document.getElementById("tr1-view").style.display = "";
      td1.className = "tabselected";
      PatientEditForm.PBegin.focus();
      document.getElementById("saveMsg").style.display = "block";
    }

    document.getElementById("tr3-view").style.display = "none";
    td3.className = "tabunselected";
    if(sTab=="AdminFamilyRelation"){
      document.getElementById("tr3-view").style.display = "";
      td3.className = "tabselected";
      document.getElementById("saveMsg").style.display = "none";
    }

    document.getElementById("tr4-view").style.display = "none";
    td4.className = "tabunselected";
    if(sTab=="AdminResource"){
      document.getElementById("tr4-view").style.display = "";
      td4.className = "tabselected";
      document.getElementById("saveMsg").style.display = "none";
    }
  }
  
  activateTab("<%=tab%>");
</script>

<%=writeJSButtons("PatientEditForm","SavePatientEditForm")%>