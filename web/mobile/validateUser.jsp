<%@page import="net.admin.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,java.util.*,be.openclinic.adt.*,java.text.*,be.openclinic.medical.*,be.mxs.common.model.vo.healthrecord.*" %>

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
	
	User activeUser = (User)session.getAttribute("activeuser");
	if(activeUser==null){
		out.println("<script>window.location.href='login.jsp';</script>");	
		out.flush();
	}
%>