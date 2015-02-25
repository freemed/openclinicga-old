<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	String serviceUid = checkString(request.getParameter("serviceuid"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total from (select distinct oc_encounter_patientuid,substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1) from oc_debets d,oc_encounters e, oc_prestations p where p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1)>0 and d.oc_debet_date>=? and	d.oc_debet_date<=? and d.oc_debet_serviceuid like ?) a";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ps.setString(3,serviceUid+"%");
	ResultSet rs = ps.executeQuery();
	int total = 0;
	if(rs.next()){
		total = rs.getInt("total");
	}
	rs.close();
	ps.close();
%>
	<table width="100%">
		<tr class='admin'><td colspan='2'><%=getTran("cnar","statistics.case.management.title1.bis",sWebLanguage)%></td></tr>
		<tr>
			<td class='admin'><%= getTran("web","total",sWebLanguage)%></td>
			<td class='admin'><%= total %></td>
		</tr>
	</table>
<%
HashSet patients = new HashSet();
sQuery="select distinct oc_encounter_patientuid,substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1) type,gender,dateofbirth,oc_encounter_begindate,(select min(oc_encounter_begindate) from oc_encounters where oc_encounter_patientuid=personid) mindate from oc_debets d,oc_encounters e, oc_prestations p,adminview v where v.personid=e.oc_encounter_patientuid and p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and substring_index(substring_index(p.oc_prestation_modifiers,';',-3),';',1)>0 and d.oc_debet_date>=? and	d.oc_debet_date<=? and oc_debet_serviceuid like ?";
ps = conn.prepareStatement(sQuery);
ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
ps.setString(3,serviceUid+"%");
rs = ps.executeQuery();
SortedMap genderages = new TreeMap();
total=0;
long day = 24*3600*1000;
long year = 365 * day;
double minages=0,minagescount=0;
while(rs.next()){
	String gender = rs.getString("gender");
	String type = rs.getString("type");
	String patient = rs.getString("oc_encounter_patientuid");
	java.util.Date dateofbirth=rs.getDate("dateofbirth");
	java.util.Date encounterdate=rs.getDate("oc_encounter_begindate");
	java.util.Date mindate=rs.getDate("mindate");
	if(!patients.contains(type+"."+patient)){
		try{
			int age = new Long((encounterdate.getTime()-dateofbirth.getTime())/year).intValue();
			if(age<5){
				age=0;
			}
			else if (age<15){
				age=5;
			}
			else {
				age=15;
			}
			if("m".equalsIgnoreCase(rs.getString("gender")) || "f".equalsIgnoreCase(rs.getString("gender"))){
				String code =age+"."+gender.toUpperCase();
				total=1;
				if((Integer)genderages.get(code)!=null){
					total=(Integer)genderages.get(code)+1;
				}
				genderages.put(code,total);
				if(age==0){
					minagescount++;
					minages+=new Long((encounterdate.getTime()-dateofbirth.getTime())/day).intValue();
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		patients.add(type+"."+patient);
	}
}
rs.close();
ps.close();
%>
	<br/><hr/><br/>
<table width="100%">
	<tr class='admin'><td colspan='5'><%=getTran("cnar","statistics.case.management.title2.bis",sWebLanguage)%></td></tr>
	<tr class='admin'>
		<td rowspan="2"><%=getTran("cnar","statistics.agecategory",sWebLanguage)%></td>
		<td colspan="4"><%=getTran("web","total",sWebLanguage)%></td>
	</tr>
	<tr class='admin'>
		<td><%=getTran("web","male",sWebLanguage)%></td>
		<td>%</td>
		<td><%=getTran("web","female",sWebLanguage)%></td>
		<td>%</td>
	</tr>
	<%
		int m0 = genderages.get("0.M")!=null?(Integer)genderages.get("0.M"):0;
		int f0 = genderages.get("0.F")!=null?(Integer)genderages.get("0.F"):0;
		int m5 = genderages.get("5.M")!=null?(Integer)genderages.get("5.M"):0;
		int f5 = genderages.get("5.F")!=null?(Integer)genderages.get("5.F"):0;
		int m15 = genderages.get("15.M")!=null?(Integer)genderages.get("15.M"):0;
		int f15 = genderages.get("15.F")!=null?(Integer)genderages.get("15.F"):0;
		total = m0+f0+m5+f5+m15+f15;
		int male = m0+m5+m15;
		int female = f0+f5+f15;
	%>
	<tr>
		<td class='admin' >0 - 5  (<%=getTran("web","firstcontact.at.age.of",sWebLanguage) %> <%=minagescount==0?"?":new DecimalFormat("0.00").format(minages/(minagescount*365)) %> <%=getTran("web","cnar.year",sWebLanguage) %>)</td>
		<td class='admin2'><%=m0 %></td>
		<td class='admin2'><%=total>0?m0*100/(total):0 %>%</td>
		<td class='admin2'><%=f0 %></td>
		<td class='admin2'><%=total>0?f0*100/(total):0 %>%</td>
	</tr>
	<tr>
		<td class='admin' >5 - 15</td>
		<td class='admin2'><%=m5 %></td>
		<td class='admin2'><%=total>0?m5*100/(total):0 %>%</td>
		<td class='admin2'><%=f5 %></td>
		<td class='admin2'><%=total>0?f5*100/(total):0 %>%</td>
	</tr>
	<tr>
		<td class='admin' >15+</td>
		<td class='admin2'><%=m15 %></td>
		<td class='admin2'><%=total>0?m15*100/(total):0 %>%</td>
		<td class='admin2'><%=f15 %></td>
		<td class='admin2'><%=total>0?f15*100/(total):0 %>%</td>
	</tr>
	<tr class='admin'>
		<td><%=getTran("web","total",sWebLanguage)%></td>
		<td><%=male %></td>
		<td><%=total>0?male*100/(total):0 %>%</td>
		<td><%=female %></td>
		<td><%=total>0?female*100/(total):0 %>%</td>
	</tr>
</table>
<%
	conn.close();
%>
