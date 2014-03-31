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
%>
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
<div class="search" style="width:585px;">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab('Admin')" id="td0" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab('AdminPrivate')" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","private",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab('AdminSocSec')" id="td2" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","socsec",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab('AdminFamilyRelation')" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","familyrelation",sWebLanguage)%></b>&nbsp;</td>
            <td style="border-bottom: 1px solid Black;" width="*">&nbsp;</td>
        </tr>
    </table>
    <%-- ONE TAB -------------------------------------------------------------------------------------%>
    <table style="vertical-align:top;" width="100%" border="0" cellspacing="0">
        <tr id="tr0-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdmin.jsp")+"?ShowButton=false",pageContext);%></td>
        </tr>
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminPrivate.jsp")+"?ShowButton=false",pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminFamilyRelation.jsp")+"?ShowButton=false",pageContext);%></td>
        </tr>
    </table>

    <script>
    function activateTab(sTab){
      document.getElementById('tr0-view').style.display = 'none';
      document.getElementById('tr1-view').style.display = 'none';
      document.getElementById('tr3-view').style.display = 'none';

      td0.className="tabunselected";
      td1.className="tabunselected";
      td3.className="tabunselected";

      if (sTab=='Admin'){
        document.getElementById('tr0-view').style.display = '';
        td0.className="tabselected";
      }
      else if (sTab=='AdminPrivate'){
        document.getElementById('tr1-view').style.display = '';
        td1.className="tabselected";
      }
      else if (sTab=='AdminFamilyRelation'){
        document.getElementById('tr3-view').style.display = '';
        td3.className="tabselected";
      }
    }

    activateTab('Admin');
    </script>
</div>
<br>
<center>
    <input type="button" class="button" name="ButtonEdit" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="doEdit()">&nbsp;
    <input type="button" class="button" name="ButtonClose" value="<%=getTran("Web","close",sWebLanguage)%>" onclick="window.close();">
</center>
<script>
  function doEdit(){
    window.opener.location.href = "<c:url value="/patientedit.do"/>";
    window.close();
  }
</script>