<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = new SimpleDateFormat("dd/MM/yyyy").parse(begin);
	java.util.Date dEnd = new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse(end).getTime()+24*3600*1000-1);
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total,extendvalue from oc_encounters e, adminview a, "+MedwanQuery.getInstance().getConfigString("admindbName","ocadmin_dbo")+".adminextends x where e.oc_encounter_patientuid=a.personid and a.personid=x.personid and x.labelid='centerreasons' and e.oc_encounter_begindate>=? and e.oc_encounter_begindate<=? group by extendvalue";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	SortedMap prestations = new TreeMap();
	int total=0;
	while(rs.next()){
		String prestation=rs.getString("extendvalue");
		String[] prests = prestation.split(";");
		int count = rs.getInt("total");
		for(int n=0;n<prests.length;n++){
			total+=count;
			int existing=0;
			if(prestations.get(prests[n])!=null){
				existing=(Integer)prestations.get(prests[n]);
			}
			prestations.put(prests[n],count+existing);
		}
	}
	rs.close();
	ps.close();
%>
	<table width="100%">
		<tr class='admin'><td colspan='3'><%=getTran("cnar","statistics.education.title1",sWebLanguage) %></td></tr>
		<tr class='admin'>
			<td rowspan="2"><%=getTran("cnar","statistics.education.name",sWebLanguage) %></td>
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
			out.println("<tr><td class='admin'>"+getTran("centerreasons",prestation,sWebLanguage)+"</td><td class='admin2'>"+prestations.get(prestation)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double((Integer)prestations.get(prestation)))*100/total)+"</td></tr>");
		}
	%>
		<tr class='admin'><td><%=getTran("web","total",sWebLanguage) %></td><td><%=total %></td><td>100%</td></tr>
	</table>
	<br/><hr/><br/>
<%
	sQuery="select count(*) total,district from oc_encounters e, privateview a where e.oc_encounter_patientuid=a.personid and e.oc_encounter_begindate>=? and e.oc_encounter_begindate<=? group by district";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	prestations = new TreeMap();
	total=0;
	while(rs.next()){
		String prestation=rs.getString("district");
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
			<td rowspan="2"><%=getTran("cnar","statistics.education.province",sWebLanguage) %></td>
			<td colspan="2"><%=getTran("web","total",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran("web","numberofcases",sWebLanguage) %></td>
			<td>%</td>
		</tr>
	<%
		i = prestations.keySet().iterator();
		while(i.hasNext()){
			String prestation=(String)i.next();
			String province=prestation;
			if(!province.equals("?")){
				province="<a href='javascript:cnareducationdetail(\""+province+"\");'>"+province+"</a>";
			}
			out.println("<tr><td class='admin'>"+province+"</td><td class='admin2'>"+prestations.get(prestation)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double((Integer)prestations.get(prestation)))*100/total)+"</td></tr>");
		}
	%>
		<tr class='admin'><td><%=getTran("web","total",sWebLanguage) %></td><td><%=total %></td><td>100%</td></tr>
	</table>
	<p/>
	<center><input type='button' class='button' value='<%=getTran("web","close",sWebLanguage) %>' onclick='window.close();'/></center>
<%
	conn.close();
%>
<script>
	function cnareducationdetail(province){
		var URL = "statistics/cnarEducationDetail.jsp&start=<%=begin%>&end=<%=end%>&ts=<%=getTs()%>&province="+province;
		openPopup(URL,800,600,"CNAR-Detail");
	}

</script>