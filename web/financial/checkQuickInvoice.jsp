<%@ page import="be.openclinic.finance.Debet,be.mxs.common.util.db.*" %>
<%
	if(MedwanQuery.getInstance().getConfigInt("enableQuickInvoicing",0)==1 && Debet.getUnassignedPatientDebets(request.getParameter("personid")).size()>0){
		out.println("<OK>");
	}
%>