<%@page import="be.openclinic.system.Center"%>
<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%String sAction = checkString(request.getParameter("action"));%>

<form id="searchFormForm" name="searchFormForm">
    <table width="100%" class="menu" cellspacing="0">
        <tr class="admin">
            <td colspan="2"><%=getTran("web","search",sWebLanguage)%></td>
        </tr>
        
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","searchFormForm","",sWebLanguage)%></td>
        </tr>
        
        <tr>
            <td class="admin2"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","searchFormForm","",sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onclick="setSearch();" value="<%=getTran("web","search",sWebLanguage)%>" title="<%=getTranNoLink("web","new",sWebLanguage)%>" value="<%=getTran("web","new",sWebLanguage)%>"/>
                <input class="button" type="button" onclick="window.location='<c:url value="/main.do"/>?Page=center/manage.jsp&action=set&version=0'" value="<%=getTran("web","new",sWebLanguage)%>" title="<%=getTranNoLink("web","new",sWebLanguage)%>" value="<%=getTran("web","new",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
    
    <div id="msgDiv" style="height:20px"></div>
    <div id="responseByAjax"></div>
</form>

<script>
  <%-- SET SEARCH --%>
  function setSearch(){
    var params = "FindBegin="+$F("FindBegin")+"&FindEnd="+$F("FindEnd")+"&ts="+<%=getTs()%>;
    var url = '<c:url value="/"/>center/ajax/searchServices.jsp';
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
    window.location = '<c:url value="/main.do"/>?Page=center/manage.jsp&action=set&version='+version;
  }
  
  <%-- DELETE SERVICE --%>
  function deleteService(serviceUid){
    if(yesnoDialog("Web","areYouSureToDelete")){
	  var url = "<c:url value=''/>center/ajax/deleteService.jsp?ts=<%=getTs()%>";
	  new Ajax.Request(url,{
	    parameters:"ServiceUid="+serviceUid,
	    onSuccess:function(resp){
	      var data = eval("("+resp.responseText+")");
	      
	      document.getElementById("msgDiv").innerHTML = data.message;
	  	  setSearch();
	    }
	  });	  
    }
  }
  
  <%
      if(sAction.length()>0){
        out.write("document.onload = setSearch();");
      }
  %>
</script>