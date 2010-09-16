<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSPROTOTYPE%>
<div id='connections'></div>
<script>
	function getConnections(){
	    var url = '<c:url value="/system/getConnectedUsers.jsp"/>?ts=<%=getTs()%>';
	    document.getElementById('connections').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
	    new Ajax.Request(url, {
	        method: "POST",
	        postBody: '',
	        onSuccess: function(resp) {
	            $('connections').innerHTML = resp.responseText;
	        },
	        onFailure: function() {
	        }
	    });
	    starttime=new Date().getTime()+3600000;
	}

	function opensession(id){
        openPopup("system/getSessionAttributes.jsp&ts=<%=getTs()%>&sessionid="+id, 400, 300);
	}

	getConnections();
	window.setInterval("getConnections();",30000);
</script>
