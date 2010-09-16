<%@ page import="net.admin.system.MedicalCenter
,java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please...</p>
<%
    String sSearchCode = checkString(request.getParameter("SearchCode")).toLowerCase();
    String sSourceVar = checkString(request.getParameter("SourceVar"));
    String sMsgVar = checkString(request.getParameter("MsgVar"));
    boolean clearField = !checkString(request.getParameter("ClearField")).equalsIgnoreCase("no");

    // compose select
    String lowerCode = MedwanQuery.getInstance().getConfigParam("lowerCompare", "code");
    Hashtable hResults = MedicalCenter.blurSelectMedicalCenterInfo(lowerCode, sSearchCode);

    String sName = "";
    boolean centerFound = false;
    if (((String) hResults.get("name")).length() > 0) {
        centerFound = true;
        sName = (String) hResults.get("name");
        sName = sName.replaceAll("'", "´");
    }

    // no MedicalCenter record found, display message
    if (!centerFound) {
%>
          <script>
            var msgField = window.opener.document.getElementById('<%=sMsgVar%>');
            msgField.innerHTML = '<%=getTran("web.manage","medicalcenternotfound",sWebLanguage)%>';
            msgField.style.color = 'red';

            var srcField = window.opener.document.getElementById('<%=sSourceVar%>');
            <% if(clearField){ %>
              srcField.value = '';
              srcField.focus();
            <% } %>

            window.close();
          </script>
        <%
    }
    // MedicalCenter was found, clear message
    else{
        %>
          <script>
            var msgField = window.opener.document.getElementById('<%=sMsgVar%>');
            msgField.innerHTML = '<%=sName%>';
            msgField.style.color = 'black';

            window.close();
          </script>
        <%
    }

    out.flush();
%>