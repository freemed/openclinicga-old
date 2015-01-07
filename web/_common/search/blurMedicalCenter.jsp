<%@ page import="net.admin.system.MedicalCenter,
                 java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please...</p>

<%
    String sSearchCode = checkString(request.getParameter("SearchCode")).toLowerCase(),
           sSourceVar  = checkString(request.getParameter("SourceVar")),
           sMsgVar     = checkString(request.getParameter("MsgVar"));

    boolean clearField = !checkString(request.getParameter("ClearField")).equalsIgnoreCase("no");

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** _common/search/blurMedicalCenter.jsp ****************");
    	Debug.println("sSearchCode : "+sSearchCode);
    	Debug.println("sSourceVar  : "+sSourceVar);
    	Debug.println("sMsgVar     : "+sMsgVar);
    	Debug.println("clearField  : "+clearField);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // compose select
    String lowerCode = MedwanQuery.getInstance().getConfigParam("lowerCompare","code");
    Hashtable hResults = MedicalCenter.blurSelectMedicalCenterInfo(lowerCode,sSearchCode);

    boolean centerFound = false;
    String sName = checkString((String)hResults.get("name"));
    if(sName.length() > 0){
        centerFound = true;
        sName = sName.replaceAll("'","´");
    }
	Debug.println("--> centerFound  : "+centerFound+"\n");

    // no MedicalCenter record found, display message
    if(!centerFound){
        %>
          <script>
            var msgField = window.opener.document.getElementById('<%=sMsgVar%>');
            msgField.innerHTML = '<%=getTranNoLink("web.manage","medicalcenternotfound",sWebLanguage)%>';
            msgField.style.color = 'red';

            <%
                if(clearField){
                    %>
                      var srcField = window.opener.document.getElementById('<%=sSourceVar%>');
                      srcField.value = '';
                      srcField.focus();
                    <%
                }
            %>

            window.close();
          </script>
        <%
    }
    // MedicalCenter found, clear message
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