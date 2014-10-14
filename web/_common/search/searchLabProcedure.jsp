<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sFindLabProcedureName = checkString(request.getParameter("FindLabProcedureName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    
    String sReturnFieldUid   = checkString(request.getParameter("ReturnFieldUid")),
    	   sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** _common/search/searchlabProcedure.jsp *****************");
    	Debug.println("sFindLabProcedureName : "+sFindLabProcedureName);
    	Debug.println("sFunction             : "+sFunction);
    	Debug.println("sReturnFieldUid       : "+sReturnFieldUid);
    	Debug.println("sReturnFieldDescr     : "+sReturnFieldDescr+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="SearchForm" method="POST" onkeyup="if(enterEvent(event,13)){searchProcedures();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ReturnFieldUid" value="<%=sReturnFieldUid%>">
    <input type="hidden" name="ReturnFieldDescr" value="<%=sReturnFieldDescr%>">

    <%=writeTableHeader("web","searchlabprocedure",sWebLanguage," window.close();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%
            if(!"no".equalsIgnoreCase(request.getParameter("header"))){
        %>
        <tr>
            <td class="admin2" width="120" nowrap><%=getTran("web","name",sWebLanguage)%></td>
            <td class="admin2" width="380" nowrap>
                <input type="text" class="text" name="FindLabProcedureName" id="FindLabProcedureName" size="20" maxlength="20"  value="<%=sFindLabProcedureName%>" onkeyup="searchLabProcedures();">
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchLabProcedures();" name="searchButton"
                       value="<%=getTranNoLink("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="2" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  window.resizeTo(800,600);
  SearchForm.FindLabProcedureName.focus();

  function clearFields(){
    SearchForm.FindLabProcedureName.value = "";
  }

  function searchLabProcedures(){
    SearchForm.Action.value = "search";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchLabProcedureShow.jsp',SearchForm);
  }

  <%-- SET LAB PROCEDURE --%>
  function setLabProcedure(uid,descr){
    if("<%=sReturnFieldUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
    }
    if("<%=sReturnFieldDescr%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldDescr%>")[0].value = descr;
    }

    <%
	    if(sFunction.length() > 0){
	        out.print("window.opener."+sFunction+";");
	    }
    %>

    window.close();
  }
  
  window.setTimeout("document.getElementsByName('FindLabProcedureName')[0].focus();",300)
</script>