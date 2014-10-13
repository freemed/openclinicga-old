<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    response.setHeader("Expires","Sat, 6 May 1995 12:00:00 GMT");
    response.setHeader("Cache-Control","no-store, no-cache, must-revalidate");
    response.addHeader("Cache-Control","post-check=0, pre-check=0");
    response.setHeader("Pragma","no-cache");
%>

<%=writeTableHeader("web","patient",sWebLanguage," window.close()")%>

<table width="100%" class="list" cellspacing="1">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activePatient.lastname)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","firstname",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activePatient.firstname)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","immatnew",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activePatient.getID("immatnew"))%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","ImmatOld",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activePatient.getID("immatold"))%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","NatReg",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activePatient.getID("natreg"))%></td>
    </tr>
</table>
<br>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td class='tabs' width='5'>&nbsp;</td>
        <td class='tabunselected' width="1%" onclick="activateTab('Admin')" id="td0" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
        <td class='tabs' width='5'>&nbsp;</td>
        <td class='tabunselected' width="1%" onclick="activateTab('AdminPrivate')" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","private",sWebLanguage)%></b>&nbsp;</td>
        <td class='tabs' width='5'>&nbsp;</td>
        <td class='tabunselected' width="1%" onclick="activateTab('AdminFamilyRelation')" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","familyrelation",sWebLanguage)%></b>&nbsp;</td>
        <td class='tabs' width='5'>&nbsp;</td>
        <td class="tabunselected" width="1%" onclick="activateTab('AdminResource')" id="td4" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","AdminResource",sWebLanguage)%></b>&nbsp;</td>
        <td class="tabs" width="*">&nbsp;</td>
    </tr>
</table>

<%-- ONE TAB -------------------------------------------------------------------------------------%>
<table style="vertical-align:top;" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr id="tr0-view" style="display:none">
        <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdmin.jsp")+"?ShowButton=false",pageContext);%></td>
    </tr>
    <tr id="tr1-view" style="display:none">
        <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminPrivate.jsp")+"?ShowButton=false",pageContext);%></td>
    </tr>
    <tr id="tr3-view" style="display:none">
        <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminFamilyRelation.jsp")+"?ShowButton=false",pageContext);%></td>
    </tr>
    <tr id="tr4-view" style="display:none">
        <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patienteditAdminResource.jsp"),pageContext);%></td>
    </tr>
</table>
<br>

<%-- BUTTONS --%>
<center>
    <input type="button" class="button" name="ButtonEdit" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="doEdit()">&nbsp;
    <input type="button" class="button" name="ButtonClose" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
</center>

<script>
  window.resizeTo(600,450);

  <%-- ACTIVATE TAB --%>
  function activateTab(sTab){
    document.getElementById('tr0-view').style.display = 'none';
    document.getElementById('tr1-view').style.display = 'none';
    document.getElementById('tr3-view').style.display = 'none';
    document.getElementById('tr4-view').style.display = 'none';

    td0.className = "tabunselected";
    td1.className = "tabunselected";
    td3.className = "tabunselected";
    td4.className = "tabunselected";

    if(sTab=='Admin'){
      document.getElementById('tr0-view').style.display = "";
      td0.className = "tabselected";
    }
    else if(sTab=='AdminPrivate'){
      document.getElementById('tr1-view').style.display = "";
      td1.className = "tabselected";
    }
    else if(sTab=='AdminFamilyRelation'){
      document.getElementById('tr3-view').style.display = "";
      td3.className = "tabselected";
    }
    else if(sTab=='AdminResource'){
      document.getElementById('tr4-view').style.display = "";
      td4.className = "tabselected";
    }
  }

  function doEdit(){
    window.opener.location.href = "<c:url value='patientedit.do'/>";
    window.close();
  }
  
  activateTab('Admin');
</script>