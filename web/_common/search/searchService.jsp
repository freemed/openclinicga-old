<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.*"%>

<%    
    // form data
	boolean needsbeds    = "1".equalsIgnoreCase(request.getParameter("needsbeds")),
	        needsvisits  = "1".equalsIgnoreCase(request.getParameter("needsvisits")),
            showinactive = "1".equalsIgnoreCase(request.getParameter("showinactive"));
    
    String sVarCode  = checkString(request.getParameter("VarCode")),
           sVarText  = checkString(request.getParameter("VarText")),
           sFindText = checkString(request.getParameter("FindText")).toUpperCase();
    
    String sStartID = checkString(request.getParameter("FindCode"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** _common/search/searchService.jsp *******************");
    	Debug.println("needsbeds    : "+needsbeds);
    	Debug.println("needsvisits  : "+needsvisits);
    	Debug.println("showinactive : "+showinactive+"\n");
    	Debug.println("sVarCode  : "+sVarCode);
    	Debug.println("sVarText  : "+sVarText);
    	Debug.println("sFindText : "+sFindText);
    	Debug.println("sStartID  : "+sStartID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
%>
<body onblur="window.focus()">
<form name="SearchForm" method="POST" onSubmit="doFind();return false;" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%-- hidden fields --%>
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="FindCode">
    <input type="hidden" name="ViewCode">
    <input type="hidden" name="showinactive">
    <input type="hidden" name="needsbeds" value="<%=checkString(request.getParameter("needsbeds"))%>"/>
    <input type="hidden" name="needsvisits" value="<%=checkString(request.getParameter("needsvisits"))%>"/>

    <%=writeTableHeader("web","searchService",sWebLanguage," window.close()")%>
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">        
        <%-- SEARCH FIELDS --%>
        <tr>
            <td height="25" class="admin2">
                <%=getTran("Web","Find",sWebLanguage)%>&nbsp;&nbsp;
                <input type="text" name="FindText" class="text" value="<%=sFindText%>" size="40">

                <%-- buttons --%>
                <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearSearchFields();">
            </td>
        </tr>
        
        <%-- SEARCH RESULTS --%>
        <tr>
            <td class="white" style="vertical-align:top;">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  doFind();
  window.resizeTo(550,520);
  SearchForm.FindText.focus();
    
  <%-- SELECT PARENT SERVICE --%>
  function selectParentService(sCode,sText){
    window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sCode;

    if('1'=='<%=MedwanQuery.getInstance().getConfigString("showUnitID")%>'){
      window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sCode+" "+sText;
    }
    else{
      window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sText;
    }

    window.opener.document.getElementsByName('<%=sVarText%>')[0].title = sText;

    if(window.opener.submitSelect!=null){
      window.opener.submitSelect();
    }
    
    if(window.opener.document.getElementsByName('<%=sVarCode%>')[0] != null){
      if(window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange != null){
         window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange();
      }
    }
       
    window.close();
  }
    
  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    SearchForm.FindText.value = "";
    SearchForm.FindText.focus();
  }

  <%-- POPULATE SERVICE --%>
  function populateService(sID){
    SearchForm.FindCode.value = sID;
    SearchForm.showinactive.value = "<%=showinactive?"1":"0"%>";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp',SearchForm);
  }

  <%-- VIEW SERVICE --%>
  function viewService(sID){
    SearchForm.FindCode.value = sID;
    SearchForm.ViewCode.value = sID;
    SearchForm.showinactive.value = "<%=showinactive?"1":"0"%>";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp',SearchForm);
  }

  <%-- DO FIND --%>
  function doFind(){
    SearchForm.FindCode.value = "<%=sStartID%>";
    SearchForm.ViewCode.value = "";
    SearchForm.showinactive.value = "<%=showinactive?"1":"0"%>";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceShow.jsp',SearchForm);
  }
    
  window.setInterval("window.focus();",1000);
</script>
</body>