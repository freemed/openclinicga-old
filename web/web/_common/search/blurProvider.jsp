<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please...</p>
<%
    String sSearchCode = checkString(request.getParameter("SearchCode")).toLowerCase();
    String sSourceVar  = checkString(request.getParameter("SourceVar"));
    String sMsgVar     = checkString(request.getParameter("MsgVar"));
    boolean clearField = !checkString(request.getParameter("ClearField")).equalsIgnoreCase("no");

    // compose select
    String lowerCode = MedwanQuery.getInstance().getConfigParam("lowerCompare","code");
    String sValue = Provider.blurSelectProviderName(lowerCode,sSearchCode);

    String sName = "";
    boolean providerFound = false;
    if(sValue.length() > 0){
        providerFound = true;
        sName = sValue;
        sName = sName.replaceAll("'","´");
    }

    // no provider record found, display message
    if(!providerFound){
        %>
          <script>
            var msgField = window.opener.document.getElementById('<%=sMsgVar%>');
            msgField.innerHTML = '<%=getTran("web.manage","providernotfound",sWebLanguage)%>';
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
    // provider was found, clear message
    else{
        %>
          <script>
            var msgField = window.opener.document.getElementById('<%=sMsgVar%>');
            msgField.style.color = 'black';
            msgField.innerHTML = '<%=sName%>';

            window.close();
          </script>
        <%
    }

    out.flush();
%>