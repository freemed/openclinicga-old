<%@ page
 import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	Hashtable maleages = new Hashtable();
	Hashtable femaleages = new Hashtable();
	double max=0;
	double totalfemale=0;
	double totalmale=0;
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String serverid = MedwanQuery.getInstance().getConfigString("serverId");
	String sSelect="select count(*) total,floor(datediff(b.oc_encounter_begindate,dateofbirth)/(365*5))*5 age from adminview a,oc_encounters b where b.oc_encounter_patientuid=a.personid and b.oc_encounter_begindate>=? and b.oc_encounter_begindate<=? and gender='m' group by floor(datediff(b.oc_encounter_begindate,dateofbirth)/(365*5))*5";
	if(conn.getMetaData().getDatabaseProductName().equalsIgnoreCase("Microsoft SQL Server")){
		sSelect="select count(*) total,floor(datediff(dd,dateofbirth,b.oc_encounter_begindate)/(365*5))*5 age from adminview a,oc_encounters b where b.oc_encounter_patientuid=a.personid and b.oc_encounter_begindate>=? and b.oc_encounter_begindate<=? and gender='m' group by floor(datediff(dd,dateofbirth,b.oc_encounter_begindate)/(365*5))*5";
	}
	PreparedStatement ps = conn.prepareStatement(sSelect);
	ps.setTimestamp(1,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(end+" 23:59").getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		try{
			int total=rs.getInt("total");
			int age=rs.getInt("age");
			if(age<5){
				age=0;
			}
			else if(age<15){
				age=1;
			}
			else {
				age=2;
			}
			if(total>max){
				max=total;
			}
			totalmale+=total;
			if(maleages.get(age)!=null){
				maleages.put(age,(Integer)maleages.get(age)+total);
			}
			else {
				maleages.put(age,total);
			}
		}
		catch(Exception e){}
	}
	rs.close();
	ps.close();
	sSelect="select count(*) total,floor(datediff(b.oc_encounter_begindate,dateofbirth)/(365*5))*5 age from adminview a,oc_encounters b where b.oc_encounter_patientuid=a.personid and b.oc_encounter_begindate>=? and b.oc_encounter_begindate<=? and gender='f' group by floor(datediff(b.oc_encounter_begindate,dateofbirth)/(365*5))*5";
	if(conn.getMetaData().getDatabaseProductName().equalsIgnoreCase("Microsoft SQL Server")){
		sSelect="select count(*) total,floor(datediff(dd,dateofbirth,b.oc_encounter_begindate)/(365*5))*5 age from adminview a,oc_encounters b where b.oc_encounter_patientuid=a.personid and b.oc_encounter_begindate>=? and b.oc_encounter_begindate<=? and gender='f' group by floor(datediff(dd,dateofbirth,b.oc_encounter_begindate)/(365*5))*5";
	}
	ps = conn.prepareStatement(sSelect);
	ps.setTimestamp(1,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(end+" 23:59").getTime()));
	rs = ps.executeQuery();
	while(rs.next()){
		try{
			int total=rs.getInt("total");
			int age=rs.getInt("age");
			if(age<5){
				age=0;
			}
			else if(age<15){
				age=1;
			}
			else {
				age=2;
			}
			if(total>max){
				max=total;
			}
			totalfemale+=total;
			if(femaleages.get(age)!=null){
				femaleages.put(age,(Integer)femaleages.get(age)+total);
			}
			else {
				femaleages.put(age,total);
			}
		}
		catch(Exception e){}
	}
	rs.close();
	ps.close();
	conn.close();
%>

<table width='100%'>
	<tr class='admin'><td colspan='5'><%=getTran("web","statistics.agedistribution",sWebLanguage) %> <%=begin%> - <%=end %></td></tr>
	<tr class='admin'>
		<td width='35%'></td>
		<td><center><%=getTran("web","female",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","age",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","male",sWebLanguage) %></center></td>
		<td width='35%'></td>
	</tr>
	<%
		for(int n=0;n<3;n++){
			int malevalue=maleages.get(n)!=null?(Integer)maleages.get(n):0;
			int femalevalue=femaleages.get(n)!=null?(Integer)femaleages.get(n):0;
	%>
	<tr class='admin2'>
		<td>
			<table width='100%'>
				<tr>
					<td width="<%=(max-femalevalue)*100/max %>%" >&nbsp;</td>
					<td width="<%=femalevalue*100/max %>%" class='red'>&nbsp;</td>
				</tr>
			</table>
		</td>
		<td class='admin2' width='10%' nowrap><center><%=femalevalue %></center></td>
		<td class='admin' width='10%' nowrap><center><%=n<2?n*5+" - "+(n*5+5):">=15" %></center></td>
		<td class='admin2' width='10%' nowrap><center><%=malevalue %></center></td>
		<td>
			<table width='100%'>
				<tr>
					<td width="<%=malevalue*100/max %>%" class='red'>&nbsp;</td>
					<td width="<%=(max-malevalue)*100/max %>%" >&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<%
		}
	%>
	<tr><td colspan='5'><hr/></td></tr>
	<tr class='admin'>
		<td colspan='2'><center><%=totalfemale %> (<%=new java.text.DecimalFormat("###.00").format(totalfemale*100/(totalfemale+totalmale)) %>%)</center></td>
		<td></td>
		<td colspan='2'><center><%=totalmale %> (<%=new java.text.DecimalFormat("###.00").format(totalmale*100/(totalfemale+totalmale)) %>%)</center></td>
	</tr>
</table>