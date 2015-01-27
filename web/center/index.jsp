<%@page import="be.openclinic.system.Center,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));
%>

<form id="searchFormForm" name="searchFormForm">
    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
        <tr class="admin">
            <td colspan="2"><%=getTran("web","search",sWebLanguage)%></td>
        </tr>
        
        <%-- DATES --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","searchFormForm","",sWebLanguage)%></td>
        </tr>        
        <tr>
            <td class="admin"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","searchFormForm","",sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onclick="setSearch();" value="<%=getTranNoLink("web","search",sWebLanguage)%>"/>
                <input class="button" type="button" onclick="doNew();" value="<%=getTranNoLink("web","new",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
    
    <div id="msgDiv" style="height:20px"></div>
    <div id="responseByAjax"></div>
</form>

<script>
  <%-- SET SEARCH --%>
  function setSearch(){
    var params = "FindBegin="+$F("FindBegin")+
                 "&FindEnd="+$F("FindEnd")+
                 "&ts="+new Date().getTime();
    var url = "<%=sCONTEXTPATH%>/center/ajax/searchServices.jsp";
    new Ajax.Request(url,{
      parameters:params,
      method:"POST",
      onSuccess:function(resp){
        $("responseByAjax").update(resp.responseText);
      }
    });
  }
  
  <%-- SHOW SERVICE --%>
  function showService(version){
    window.location = "<c:url value='/main.do'/>?Page=center/manage.jsp&Action=set&version="+version;
  }
  
  <%-- DO NEW --%>
  function doNew(){
    window.location = "<c:url value='/main.do'/>?Page=center/manage.jsp&Action=set&version=0";
  }
  
  <%-- DELETE SERVICE --%>
  function deleteService(serviceUid,serviceVersion){
      if(yesnoDeleteDialog()){
	  var url = "<c:url value=''/>center/ajax/deleteService.jsp?ts=<%=getTs()%>";
	  new Ajax.Request(url,{
	    parameters:"ServiceUid="+serviceUid+
	               "&ServiceVersion="+serviceVersion,
	    onSuccess:function(resp){
	      var data = eval("("+resp.responseText+")");
	      
	      document.getElementById("msgDiv").innerHTML = data.message;
	  	  setSearch();
	    }
	  });	  
    }
  }
  
  <%
      if(sAction.length() > 0){
        out.write("document.onload = setSearch();");
      }
  %>
</script>