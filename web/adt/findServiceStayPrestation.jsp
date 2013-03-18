<%@ page import="net.admin.*" %><%
	String serviceid=request.getParameter("serviceid");
	if(serviceid!=null){
		Service service = Service.getService(serviceid);
		if(service.stayprestationuid!=null){
			out.print(service.stayprestationuid);
		}
	}
%>