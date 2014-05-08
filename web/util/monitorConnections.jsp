<%@page import="java.util.*,net.admin.User,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="includes/helper.jsp"%>
<table width='100%'>
<%
	Hashtable sessions = MedwanQuery.getSessions();
	SortedMap sortedSessions = new TreeMap();
	Enumeration e = sessions.keys();
	while(e.hasMoreElements()){
		HttpSession s = (HttpSession)e.nextElement();
		if(s!=null){
			User user = (User)sessions.get(s);
			if(user!=null && user.person!=null){
				sortedSessions.put(new Long(s.getLastAccessedTime()),user.userid+": "+user.person.lastname+", "+user.person.firstname);
			}
		}
	}
	Iterator iterator = sortedSessions.keySet().iterator();
	while(iterator.hasNext()){
		Long k = (Long)iterator.next();
		String u = (String)sortedSessions.get(k));		
		out.print("<tr><td>"+ScreenHelper.fullDateFormatSS.format(new Date(k.longValue()))+"</td><td>"+u+"</td></tr>");		
	}
%>
</table>