<%@page import="net.admin.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,java.util.*,be.openclinic.adt.*,java.text.*,be.openclinic.medical.*,be.mxs.common.model.vo.healthrecord.*" %>
<meta name="viewport" content="width=device-width, initial-scale=1">
<%
	User activeUser = (User)session.getAttribute("activeUser");
	String pid="";	
	if(session.getAttribute("activePatient")!=null){
		pid=((AdminPerson)session.getAttribute("activePatient")).personid;
	}
%>
<script>
	function initBarcode2(){
		window.open("zxing://scan/?ret=<%="http://" + request.getServerName()+":"+request.getServerPort() + request.getRequestURI().replaceAll(request.getServletPath(), "") %>/mobile/searchPatient.jsp\?search=1%26patientpersonid={CODE}")
	}
</script>

<%!
	String getTran(String labelType,String labelId,User activeUser){
		return MedwanQuery.getInstance().getLabel(labelType,labelId,activeUser.person.language);
	}
%>
<%
	response.setHeader("Content-Type", "text/html; charset=ISO-8859-1");
	response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");
	response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
	response.addHeader("Cache-Control", "post-check=0, pre-check=0");
	response.setHeader("Pragma", "no-cache");
	
	if(activeUser==null){
		out.println("<script>window.location.href='login.jsp';</script>");	
		out.flush();
	}
%>

<img class="link" onclick="initBarcode2();"  border='0' src="<%="http://" + request.getServerName()+":"+request.getServerPort() + request.getRequestURI().replaceAll(request.getServletPath(), "") %>/_img/androidbarcode.png" alt="<%=MedwanQuery.getInstance().getLabel("web","barcode",activeUser.person.language)%>"/>
&nbsp;<a href='<%="http://" + request.getServerName()+":"+request.getServerPort() + request.getRequestURI().replaceAll(request.getServletPath(), "") %>/main.do?Page=curative/index.jsp&PersonID=<%=pid%>&ts=<%=new java.util.Date().getTime()+""%>'><%=MedwanQuery.getInstance().getLabel("web","desktop.interface",activeUser.person.language)%></a>
<br/>