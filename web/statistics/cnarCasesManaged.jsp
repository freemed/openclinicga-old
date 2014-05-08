<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total from (select distinct oc_encounter_patientuid,substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1) from oc_debets d,oc_encounters e, oc_prestations p where p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1)>0 and d.oc_debet_date>=? and	d.oc_debet_date<=?) a";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	int total = 0;
	if(rs.next()){
		total = rs.getInt("total");
	}
	rs.close();
	ps.close();
%>
	<table width="100%">
		<tr class='admin'><td colspan='2'><%=getTran("cnar","statistics.case.management.title1",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%= getTran("web","total",sWebLanguage) %></td>
			<td class='admin'><%= total %></td>
		</tr>
	</table>
<%
sQuery="select count(*) total,oc_debet_serviceuid from (select distinct oc_encounter_patientuid,substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1),oc_debet_serviceuid from oc_debets d,oc_encounters e, oc_prestations p where p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1)>0 and d.oc_debet_date>=? and	d.oc_debet_date<=?) a group by oc_debet_serviceuid";
ps = conn.prepareStatement(sQuery);
ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
rs = ps.executeQuery();
SortedMap services = new TreeMap();
total=0;
while(rs.next()){
	String serviceuid=rs.getString("oc_debet_serviceuid");
	if(serviceuid==null || serviceuid.length()==0){
		serviceuid="?";
	}
	int count = rs.getInt("total");
	total+=count;
	services.put(serviceuid,count);
}
rs.close();
ps.close();
%>
	<br/><hr/><br/>
<table width="100%">
	<tr class='admin'><td colspan='3'><%=getTran("cnar","statistics.case.management.title2",sWebLanguage) %></td></tr>
	<tr class='admin'>
		<td rowspan="2"><%=getTran("cnar","statistics.service.treatment",sWebLanguage) %></td>
		<td colspan="2"><%=getTran("web","total",sWebLanguage) %></td>
	</tr>
	<tr class='admin'>
		<td><%=getTran("web","numberofcases",sWebLanguage) %></td>
		<td>%</td>
	</tr>
<%
	Iterator i = services.keySet().iterator();
	while(i.hasNext()){
		String serviceuid=(String)i.next();
		String servicename="?";
		Service service = Service.getService(serviceuid);
		if(service!=null){
			servicename=service.getLabel(sWebLanguage);
		}
		out.println("<tr><td class='admin'>"+serviceuid+": "+servicename+"</td><td class='admin2'>"+services.get(serviceuid)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double((Integer)services.get(serviceuid)))*100/total)+"</td></tr>");
	}
%>
	<tr class='admin'><td><%=getTran("web","total",sWebLanguage) %></td><td><%=total %></td><td>100%</td></tr>
</table>
<%
	conn.close();
%>