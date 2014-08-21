<%@page import="be.mxs.common.util.system.SessionMessage"%>
<%@page import="java.io.ByteArrayOutputStream,java.io.PrintWriter,java.text.*"%><%@ page import="be.openclinic.sync.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	if(request.getParameter("submit")!=null){
		session.setAttribute("messages", new SessionMessage());
		OpenclinicSlaveExporter exporter = new OpenclinicSlaveExporter((SessionMessage)session.getAttribute("messages"));
		exporter.start();
	}
%>
<form name='exportForm' method='post'>
	<table>
		<tr><td><input class='button' type='submit' name='submit' value='<%=getTran("web","export",sWebLanguage) %>'/></td></tr>
		<tr><td><div id='divMessage'/></td></tr>
		<tr><td><div id='log'/></td></tr>
	</table>
	
</form>

<%
	if(request.getParameter("submit")!=null){
%>
<script>
	function pollMessage(){
	    var today = new Date();
	    var url= '<c:url value="/util/pollMessage.jsp"/>?ts='+today;
		new Ajax.Request(url,{
		  method: "GET",
	      parameters: '',
	      onSuccess: function(resp){
	    	  	$('log').innerHTML=$('log').innerHTML+resp.responseText;
			    document.getElementById('divMessage').innerHTML = "";
			    if(!resp.responseText.endsWith(".")){
			    	window.setTimeout("pollMessage();",200);
			    }
			    else {
				    document.getElementById('divMessage').innerHTML = "";
			    }
		      },
	    onFailure: function(resp){
	      }
		});
	}
	document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
	window.setTimeout("pollMessage();",200);
	
</script>
<%
	}
%>