<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	System.out.println("sWebLanguage="+sWebLanguage);
	Hashtable h = (Hashtable)((Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase())).get(request.getParameter("labeltype"));
	if(h!=null){
		Enumeration e = h.elements();
		String sValues="";
		while(e.hasMoreElements()){
			if(sValues.length()>0){
				sValues+="$";
			}
			net.admin.Label label = (net.admin.Label)e.nextElement();
			sValues+=label.id+"£"+label.value;
		}
		out.print(sValues);
	}
%>
