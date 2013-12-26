<%@ page import="be.mxs.common.util.system.*,java.util.*,be.openclinic.pharmacy.*" %>
<%
	try{
		String parentsstring="";
		Vector parents = DrugCategory.getParentIdsNoReverse(request.getParameter("code"));
		for(int n=0;n<parents.size();n++){
			parentsstring+=(String)parents.elementAt(n)+" "+HTMLEntities.htmlentities(ScreenHelper.getTranNoLink("drug.category", (String)parents.elementAt(n), request.getParameter("language")))+"<br/>";
		}
		out.println(parentsstring);
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>