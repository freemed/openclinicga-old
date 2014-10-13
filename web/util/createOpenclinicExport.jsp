<%@page import="be.mxs.common.util.system.Base64Coder"%>
<%@page import="be.mxs.common.util.system.SessionMessage"%>
<%@page import="java.io.ByteArrayOutputStream,java.io.PrintWriter,java.text.*"%><%@ page import="be.openclinic.sync.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	if(request.getParameter("submit")!=null && checkString(request.getParameter("remotelogin")).length()>0 && checkString(request.getParameter("remotepassword")).length()>0){
		session.setAttribute("messages", new SessionMessage());
		String remotepassword=checkString(request.getParameter("remotepassword"));
		byte[] encryptedpassword = User.encrypt(remotepassword);
		OpenclinicSlaveExporter exporter = new OpenclinicSlaveExporter(checkString(request.getParameter("remotelogin")),new String(Base64Coder.encode(encryptedpassword)),(SessionMessage)session.getAttribute("messages"),sWebLanguage);
		exporter.start();
	}
%>
<form name='exportForm' method='post'>
	<table>
		<tr><td><%=getTran("web","remote.login",sWebLanguage)%></td><td><input type='text' class='text' name='remotelogin'/></td></tr>
		<tr><td><%=getTran("web","remote.password",sWebLanguage)%></td><td><input type='password' class='text' name='remotepassword'/></td></tr>
		<tr><td colspan='2'><div id='divMessage'/></td></tr>
		<tr><td><input class='button' type='submit' name='submit' value='<%=getTran("web","export",sWebLanguage)%>'/></td></tr>
		<tr><td colspan='2'><div id='divMessage'/></td></tr>
		<tr><td colspan='2'><div id='log'/></td></tr>
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