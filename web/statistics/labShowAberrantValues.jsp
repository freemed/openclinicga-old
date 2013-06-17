<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
	<tr class='admin'>
		<td><%=getTran("web","personid",sWebLanguage) %></td>
		<td><%=getTran("web","patient",sWebLanguage) %></td>
		<td><%=getTran("web","date",sWebLanguage) %></td>
		<td><%=getTran("web","code",sWebLanguage) %></td>
		<td><%=getTran("web","value",sWebLanguage) %></td>
	</tr>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="";
	String limitvalue="";
	sQuery="select * from requestedlabanalyses,adminview where patientid=personid and  finalvalidationdatetime is not null and analysiscode=? and resultdate between ? and ? order by resultdate";
	if(request.getParameter("greaterthan")!=null){
		limitvalue=request.getParameter("greaterthan");
	}
	else if(request.getParameter("lowerthan")!=null){
		limitvalue=request.getParameter("lowerthan");
	}
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setString(1,request.getParameter("labcode"));
	ps.setDate(2,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("start")).getTime()));
	ps.setDate(3,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("end")).getTime()+24*3600*1000));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		try{
			double resultvalue = Double.parseDouble(rs.getString("resultvalue"));
			if((request.getParameter("greaterthan")!=null && resultvalue>Double.parseDouble(limitvalue)) || (request.getParameter("lowerthan")!=null && resultvalue<Double.parseDouble(limitvalue))){
				out.println("<tr><td class='admin'>"+rs.getString("personid")+"</td><td class='admin'>"+checkString(rs.getString("lastname")).toUpperCase()+", "+checkString(rs.getString("lastname"))+"</td><td class='admin2'>"+new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("resultdate"))+"</td><td class='admin2'>"+request.getParameter("labcode")+"</td><td class='red'>"+rs.getString("resultvalue")+"</td></tr>");
			}
		}
		catch(Exception e){
			
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>