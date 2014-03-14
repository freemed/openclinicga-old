<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%!
	class Etiology{
		String name;
		int	male;
		int female;
		int i0to5;
		int i5to15;
		int i15plus;
	}
%>
<%
	int maxdiseases=MedwanQuery.getInstance().getConfigInt("cnarMaxDiseases",20);
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = new SimpleDateFormat("dd/MM/yyyy").parse(begin);
	java.util.Date dEnd = new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse(end).getTime()+24*3600*1000-1);
	
	
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="SELECT count(*) total,l.code,l.label"+sWebLanguage+" FROM oc_diagnoses d, oc_diagnosis_groups g, icd10 l, oc_encounters e, adminview a where g.oc_diagnosis_codetype='icd10' and d.oc_diagnosis_codetype='icd10' and d.oc_diagnosis_date>=? and oc_diagnosis_date<=? and d.oc_diagnosis_code>=g.oc_diagnosis_codestart and e.oc_encounter_objectid=d.oc_diagnosis_encounterobjectid and e.oc_encounter_patientuid=a.personid and d.oc_diagnosis_code<=g.oc_diagnosis_codeend and g.oc_diagnosis_groupcode=l.code group by l.code,l.labelnl order by count(*) desc";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	SortedMap etiologies=new TreeMap();
	SortedMap sortedetiologies=new TreeMap();
	HashSet etiologyset = new HashSet();
	String etiology="";
	double total = 0, count=0;
	int counter=0;
	while(rs.next() && counter<maxdiseases){
		counter++;
		count = rs.getInt("total");
		total+=count;
		etiology = checkString(new DecimalFormat("0000000").format(9999999-count)+";"+rs.getString("code")+";"+rs.getString("label"+sWebLanguage));
		if(etiology.length()==0){
			etiology="?";
		}
		sortedetiologies.put(etiology,count);
		etiologyset.add(rs.getString("code")+";"+rs.getString("label"+sWebLanguage));
	}
	rs.close();
	ps.close();
	
%>
	<table width="800px">
		<tr class='admin'><td colspan='4'><%=getTran("cnar","statistics.disease.title1",sWebLanguage) %> (Top <%=maxdiseases %>)</td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.code",sWebLanguage) %></td>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.disease",sWebLanguage) %></td>
			<td colspan='2'><%= getTran("web","total",sWebLanguage) %></td></tr>
		<tr class='admin'>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
		</tr>
			<%
				Iterator i = sortedetiologies.keySet().iterator();
				while(i.hasNext()){
					etiology=(String)i.next();
					count=(Double)sortedetiologies.get(etiology);
					out.println("<tr><td class='admin'>"+etiology.split(";")[1].toUpperCase()+"</td><td class='admin'>"+etiology.split(";")[2]+"</td><td class='admin2'>"+new Double(count).intValue()+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(count*100/total)+"%</td></tr>");
				}
			%>
		<tr class='admin'>
			<td colspan='2'><%=getTran("web","totals",sWebLanguage) %></td>
			<td><%=new Double(total).intValue()+"" %></td>
			<td>100%</td>
		</tr>
	</table>
<%
	sQuery="SELECT count(*) total,l.code,l.label"+sWebLanguage+",gender FROM oc_diagnoses d, oc_diagnosis_groups g, icd10 l, oc_encounters e, adminview a where g.oc_diagnosis_codetype='icd10' and d.oc_diagnosis_codetype='icd10' and e.oc_encounter_objectid=d.oc_diagnosis_encounterobjectid and e.oc_encounter_patientuid=a.personid and d.oc_diagnosis_date>=? and oc_diagnosis_date<=? and d.oc_diagnosis_code>=g.oc_diagnosis_codestart and d.oc_diagnosis_code<=g.oc_diagnosis_codeend and g.oc_diagnosis_groupcode=l.code group by l.code,l.labelnl order by count(*) desc";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	etiologies=new TreeMap();
	int totalfemale = 0, totalmale=0;
	while(rs.next()){
		count = rs.getInt("total");
		etiology = checkString(rs.getString("code")+";"+rs.getString("label"+sWebLanguage));
		if(etiologyset.contains(etiology)){
			Etiology e = new Etiology();
			if(etiologies.get(etiology)!=null){
				e=(Etiology)etiologies.get(etiology);
			}
			if("fv".indexOf(checkString(rs.getString("gender")).toLowerCase())>-1){
				e.female+=count;
				totalfemale+=count;
			}
			else {
				e.male+=count;
				totalmale+=count;
			}
			etiologies.put(etiology,e);
		}
	}
	rs.close();
	ps.close();
%>
	<br/><hr/><br/>
	<table width="800px">
		<tr class='admin'><td colspan='7'><%=getTran("cnar","statistics.disease.title2",sWebLanguage) %> (Top <%=maxdiseases %>)</td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.code",sWebLanguage) %></td>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.disease",sWebLanguage) %></td>
			<td colspan='2'><%= getTran("web","male",sWebLanguage) %></td><td colspan='2'><%= getTran("web","female",sWebLanguage) %></td><td rowspan='2'><%= getTran("web","total",sWebLanguage) %></td></tr>
		<tr class='admin'>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
		</tr>
			<%
				i = sortedetiologies.keySet().iterator();
				while(i.hasNext()){
					etiology=(String)i.next();
					Etiology e = (Etiology)etiologies.get(etiology.split(";")[1]+";"+etiology.split(";")[2]);
					out.println("<tr><td class='admin'>"+etiology.split(";")[1].toUpperCase()+"</td><td class='admin'>"+etiology.split(";")[2]+"</td><td class='admin2'>"+e.male+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.male*100/(e.male+e.female))+"%</td><td class='admin2'>"+e.female+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.female*100/(e.male+e.female))+"%</td><td class='admin2'>"+(e.male+e.female)+"</tr>");
				}
			%>
		<tr class='admin'>
			<td colspan='2'><%=getTran("web","totals",sWebLanguage) %></td>
			<td><%=new Double(totalmale).intValue()+"" %></td>
			<td><%=totalmale+totalfemale==0?"-":new DecimalFormat("#0.00").format(totalmale*100/(totalmale+totalfemale))%>%</td>
			<td><%=new Double(totalfemale).intValue()+"" %></td>
			<td><%=totalmale+totalfemale==0?"-":new DecimalFormat("#0.00").format(totalfemale*100/(totalmale+totalfemale))%>%</td>
			<td><%=new Double(totalfemale+totalmale).intValue()+"" %></td>
		</tr>
	</table>
<%
	sQuery="SELECT count(*) total,l.code,l.label"+sWebLanguage+",year(now())-year(dateofbirth) as age FROM oc_diagnoses d, oc_diagnosis_groups g, icd10 l, oc_encounters e, adminview a where g.oc_diagnosis_codetype='icd10' and d.oc_diagnosis_codetype='icd10' and e.oc_encounter_objectid=d.oc_diagnosis_encounterobjectid and e.oc_encounter_patientuid=a.personid and d.oc_diagnosis_date>=? and oc_diagnosis_date<=? and d.oc_diagnosis_code>=g.oc_diagnosis_codestart and d.oc_diagnosis_code<=g.oc_diagnosis_codeend and g.oc_diagnosis_groupcode=l.code group by l.code,l.labelnl order by count(*) desc";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	etiologies=new TreeMap();
	double total0to5 = 0, total5to15=0, total15plus=0;
	while(rs.next()){
		count = rs.getInt("total");
		etiology = checkString(rs.getString("code")+";"+rs.getString("label"+sWebLanguage));
		if(etiologyset.contains(etiology)){
			Etiology e = new Etiology();
			if(etiologies.get(etiology)!=null){
				e=(Etiology)etiologies.get(etiology);
			}
			if(rs.getInt("age")<=5){
				e.i0to5+=count;
				total0to5+=count;
			}
			else if(rs.getInt("age")<=15){
				e.i5to15+=count;
				total5to15+=count;
			}
			else {
				e.i15plus+=count;
				total15plus+=count;
			}
			etiologies.put(etiology,e);
		}
	}
	rs.close();
	ps.close();

%>
	<br/><hr/><br/>
	<table width="800px">
		<tr class='admin'><td colspan='9'><%=getTran("cnar","statistics.disease.title3",sWebLanguage) %> (Top <%=maxdiseases %>)</td></tr>
		<tr class='admin'>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.code",sWebLanguage) %></td>
			<td rowspan='2'><%=getTran("cnar","statistics.disease.disease",sWebLanguage) %></td>
			<td colspan='2'><%= getTran("web","0to5",sWebLanguage) %></td><td colspan='2'><%= getTran("web","5to15",sWebLanguage) %></td><td colspan='2'><%= getTran("web","15plus",sWebLanguage) %></td><td rowspan='2'><%= getTran("web","total",sWebLanguage) %></td></tr>
		<tr class='admin'>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
			<td><%= getTran("web","number.of.cases",sWebLanguage) %></td>
			<td>%</td>
		</tr>
			<%
				i = sortedetiologies.keySet().iterator();
				while(i.hasNext()){
					etiology=(String)i.next();
					Etiology e = (Etiology)etiologies.get(etiology.split(";")[1]+";"+etiology.split(";")[2]);
					out.println("<tr><td class='admin'>"+etiology.split(";")[1].toUpperCase()+"</td><td class='admin'>"+etiology.split(";")[2]+"</td><td class='admin2'>"+e.i0to5+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i0to5*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+e.i5to15+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i5to15*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+e.i15plus+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format(e.i15plus*100/(e.i0to5+e.i5to15+e.i15plus))+"%</td><td class='admin2'>"+(e.i0to5+e.i5to15+e.i15plus)+"</tr>");
				}
			%>
		<tr class='admin'>
			<td colspan='2'><%=getTran("web","totals",sWebLanguage) %></td>
			<td><%=new Double(total0to5).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total0to5*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total5to15).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total5to15*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total15plus).intValue()+"" %></td>
			<td><%=total0to5+total5to15+total15plus==0?"-":new DecimalFormat("#0.00").format(total15plus*100/(total0to5+total5to15+total15plus))%>%</td>
			<td><%=new Double(total0to5+total5to15+total15plus).intValue()+"" %></td>
		</tr>
	</table>
<%
	sQuery="SELECT count(*) total,l.code,l.label"+sWebLanguage+",district FROM oc_diagnoses d, oc_diagnosis_groups g, icd10 l, oc_encounters e, privateview a where g.oc_diagnosis_codetype='icd10' and d.oc_diagnosis_codetype='icd10' and e.oc_encounter_objectid=d.oc_diagnosis_encounterobjectid and e.oc_encounter_patientuid=a.personid and d.oc_diagnosis_date>=? and oc_diagnosis_date<=? and d.oc_diagnosis_code>=g.oc_diagnosis_codestart and d.oc_diagnosis_code<=g.oc_diagnosis_codeend and g.oc_diagnosis_groupcode=l.code group by l.code,l.labelnl,district order by count(*) desc";
	ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	rs = ps.executeQuery();
	etiologies=new TreeMap();
	String province="";
	SortedSet allProvinces = new TreeSet();
	while(rs.next()){
		count = rs.getInt("total");
		etiology = checkString(rs.getString("code")+";"+rs.getString("label"+sWebLanguage));
		if(etiologyset.contains(etiology)){
			province=checkString(rs.getString("district"));
			if(province.length()==0){
				province="?";
			}
			if(!allProvinces.contains(province)){
				allProvinces.add(province);
			}
			SortedMap provinces = new TreeMap();
			if(etiologies.get(etiology)!=null){
				provinces=(TreeMap)etiologies.get(etiology);
			}
			
			Etiology e = new Etiology();
			if(provinces.get(province)!=null){
				e=(Etiology)provinces.get(province);
			}
			e.i0to5+=count;
			provinces.put(province,e);
			etiologies.put(etiology,provinces);
		}
	}
	rs.close();
	ps.close();

%>
	<br/><hr/><br/>
	<table width="100%" class="table table-striped table-header-rotated">
		<tr class='admin'><th colspan='<%=(3+allProvinces.size())+""%>'><%=getTran("cnar","statistics.disease.title4",sWebLanguage) %> (Top <%=maxdiseases %>)</th></tr>
		<tr>
			<td class="admin"><%=getTran("cnar","statistics.disease.code",sWebLanguage) %></td>
			<td class='admin'><%=getTran("cnar","statistics.disease.disease",sWebLanguage) %></td>
			<%
				i = allProvinces.iterator();
				while(i.hasNext()){
					out.println("<th class='rotate-45'><div><span>"+i.next()+"</span></div></th>");
				}
			%>
			<th class='rotate-45'><div><span><%= getTran("web","total",sWebLanguage) %></span></div></th></tr>
			<%
				Hashtable provinceTotals = new Hashtable();
				Iterator j = sortedetiologies.keySet().iterator();
				total=0;
				while(j.hasNext()){
					etiology=(String)j.next();
					System.out.println("etiology="+etiology);
					TreeMap provinces = (TreeMap)etiologies.get(etiology.split(";")[1]+";"+etiology.split(";")[2]);
					out.println("<tr><td class='admin'>"+etiology.split(";")[1].toUpperCase()+"</td><td class='admin'>"+etiology.split(";")[2]+"</td>");
					i = allProvinces.iterator();
					while(i.hasNext()){
						province=(String)i.next();
						Etiology e = (Etiology)provinces.get(province);
						count=0;
						if(e!=null){
							count=e.i0to5;
						}
						total+=count;
						if(provinceTotals.get(province)==null){
							provinceTotals.put(province,0);
						}
						provinceTotals.put(province,(Integer)provinceTotals.get(province)+new Double(count).intValue());
						out.println("<td class='admin2'>"+new Double(count).intValue()+"</td>");
					}
					out.println("<td class='admin2'>"+new Double(total).intValue()+"</td></tr>");
				}
				out.println("<tr class='admin'>");
				out.println("<td colspan='2'>"+getTran("web","totals",sWebLanguage)+"</td>");
				i = allProvinces.iterator();
				while(i.hasNext()){
					out.println("<td>"+provinceTotals.get(i.next())+"</td>");
				}
				out.println("<td>"+new Double(total).intValue()+"</td></tr>");
			%>
		
	</table>
<%
	conn.close();
%>