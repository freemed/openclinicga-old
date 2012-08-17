<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Hashtable h = (Hashtable)((Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase())).get(request.getParameter("labeltype"));
	if(h!=null){
		SortedMap map = new TreeMap();
		Enumeration e = h.elements();
		String sValues="";
		while(e.hasMoreElements()){
			net.admin.Label label = (net.admin.Label)e.nextElement();
			map.put(label.value,label.id+"£"+label.value);
		}
		Iterator it = map.keySet().iterator();
		String v;
		while (it.hasNext()){
			v = (String)it.next();
			if(sValues.length()>0){
				sValues+="$";
			}
			sValues+=map.get(v);
		}
		out.print(sValues);
	}
%>
