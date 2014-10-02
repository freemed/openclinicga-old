<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSPROTOTYPE%>
<div id='connections'></div>
<script>
  function getConnections(){
	var url = '<c:url value="/system/getConnectedUsers.jsp"/>?ts=<%=getTs()%>';
	document.getElementById('connections').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
	new Ajax.Request(url,{
	  method: "POST",
	  onSuccess: function(resp){
	    $('connections').innerHTML = resp.responseText;
	  }
	});
	starttime = new Date().getTime()+3600000;
  }

  function opensession(id){
    openPopup("system/getSessionAttributes.jsp&ts=<%=getTs()%>&sessionid="+id,400,300);
  }

  getConnections();
  window.setInterval("getConnections();",30000);
</script>