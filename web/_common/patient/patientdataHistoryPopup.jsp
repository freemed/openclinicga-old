<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    // Set to expire far in the past.
    response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");

    // Set standard HTTP/1.1 no-cache headers.
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

    // Set IE extended HTTP/1.1 no-cache headers (use addHeader).
    response.addHeader("Cache-Control", "post-check=0, pre-check=0");

    // Set standard HTTP/1.0 no-cache header.
    response.setHeader("Pragma", "no-cache");
    String personid = request.getParameter("personid");
    java.util.Date updatetime = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(request.getParameter("updatetime"));
    AdminPerson activeHistoryPatient = AdminPerson.getAdminHistoryPerson(personid,updatetime);
%>
<table width="100%" class="list" cellspacing="1">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activeHistoryPatient.lastname)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","firstname",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activeHistoryPatient.firstname)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","immatnew",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activeHistoryPatient.getID("immatnew"))%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","ImmatOld",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activeHistoryPatient.getID("immatold"))%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","NatReg",sWebLanguage)%></td>
        <td class="admin2"><%=checkString(activeHistoryPatient.getID("natreg"))%></td>
    </tr>
</table>
<br>
<div class="search" style="width:585px;">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab('Admin')" id="td0" nowrap>&nbsp;<b><%=getTran("Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
        </tr>
    </table>
    <%-- ONE TAB -------------------------------------------------------------------------------------%>
    <table style="vertical-align:top;" width="100%" border="0" cellspacing="0">
        <tr id="tr0-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataHistoryAdmin.jsp")+"?ShowButton=false&updatetime="+request.getParameter("updatetime")+"&personid="+personid,pageContext);%></td>
        </tr>
    </table>

    <script>
    function activateTab(sTab){
      document.getElementsByName('tr0-view')[0].style.display = 'none';


      if (sTab=='Admin'){
        document.getElementsByName('tr0-view')[0].style.display = '';
        td0.className="tabselected";
      }
    }

    activateTab('Admin');
    </script>
</div>
<br>
<center>
    <input type="button" class="button" name="ButtonEdit" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="doEdit()">&nbsp;
    <input type="button" class="button" name="ButtonClose" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
</center>
<script>
  function doEdit(){
    window.opener.location.href = "<c:url value="/patientedit.do"/>";
    window.close();
  }
</script>