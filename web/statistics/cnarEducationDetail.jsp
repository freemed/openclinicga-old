<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	String province=checkString(request.getParameter("province"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();

	String sQuery="select count(*) total,sector from oc_encounters e, privateview a where e.oc_encounter_patientuid=a.personid and a.district='"+province+"' and e.oc_encounter_begindate>=? and e.oc_encounter_begindate<=? group by sector";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	TreeMap prestations = new TreeMap();
	int total=0;
	while(rs.next()){
		String prestation=rs.getString("sector");
		if(prestation==null || prestation.length()==0){
			prestation="?";
		}
		int count = rs.getInt("total");
		total+=count;
		prestations.put(prestation,count);
	}
	rs.close();
	ps.close();
%>
	<table width="100%">
		<tr class='admin'><td colspan='3'><%=getTran("cnar","statistics.education.title2",sWebLanguage) %></td></tr>
		<tr class='admin'>
			<td rowspan="2"><%=getTran("cnar","statistics.education.town",sWebLanguage) %> (<%=getTran("cnar","province",sWebLanguage)%>: <%=province %>)</td>
			<td colspan="2"><%=getTran("web","total",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran("web","numberofcases",sWebLanguage) %></td>
			<td>%</td>
		</tr>
	<%
		Iterator i = prestations.keySet().iterator();
		while(i.hasNext()){
			String prestation=(String)i.next();
			out.println("<tr><td class='admin'>"+prestation+"</td><td class='admin2'>"+prestations.get(prestation)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double((Integer)prestations.get(prestation)))*100/total)+"</td></tr>");
		}
	%>
		<tr class='admin'><td><%=getTran("web","total",sWebLanguage) %></td><td><%=total %></td><td>100%</td></tr>
	</table>
	<p/>
	<center><input type='button' class='button' value='<%=getTranNoLink("web","close",sWebLanguage) %>' onclick='window.close();'/></center>
<%
	conn.close();
%>
