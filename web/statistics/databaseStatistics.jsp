<%@page import="java.util.*,java.text.*,net.admin.User,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog,uk.org.primrose.pool.core.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn=MedwanQuery.getInstance().getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("select count(*) total from Admin");
	ResultSet rs=ps.executeQuery();
	rs.next();
	int totalpatients=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_ENCOUNTERS where oc_encounter_type='visit'");
	rs=ps.executeQuery();
	rs.next();
	int totalvisits=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_ENCOUNTERS where oc_encounter_type='admission'");
	rs=ps.executeQuery();
	rs.next();
	int totaladmissions=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_DEBETS");
	rs=ps.executeQuery();
	rs.next();
	int totaldebets=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_PATIENTINVOICES");
	rs=ps.executeQuery();
	rs.next();
	int totalpatientinvoices=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_PATIENTCREDITS");
	rs=ps.executeQuery();
	rs.next();
	int totalpatientcredits=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_INSURARINVOICES");
	rs=ps.executeQuery();
	rs.next();
	int totalinsurarinvoices=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_EXTRAINSURARINVOICES");
	rs=ps.executeQuery();
	rs.next();
	int totalextrainsurarinvoices=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_INSURARS");
	rs=ps.executeQuery();
	rs.next();
	int totalinsurars=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_PRESTATIONS");
	rs=ps.executeQuery();
	rs.next();
	int totalprestations=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_DIAGNOSES");
	rs=ps.executeQuery();
	rs.next();
	int totaldiagnoses=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_RFE");
	rs=ps.executeQuery();
	rs.next();
	int totalrfe=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from OC_BEDS");
	rs=ps.executeQuery();
	rs.next();
	int totalbeds=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from RequestedLabanalyses");
	rs=ps.executeQuery();
	rs.next();
	int totalrequestedlabanalyses=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from oc_antibiograms");
	rs=ps.executeQuery();
	rs.next();
	int totalantibiograms=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from Transactions");
	rs=ps.executeQuery();
	rs.next();
	int totaltransactions=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select count(*) total from Items");
	rs=ps.executeQuery();
	rs.next();
	int totalitems=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getOpenclinicConnection();
	ps=conn.prepareStatement("select sum(oc_debet_amount) patientamount,sum(oc_debet_insuraramount) insuraramount,sum(oc_debet_extrainsuraramount) extrainsuraramount from oc_debets");
	rs=ps.executeQuery();
	rs.next();
	double totalpatientamount=rs.getDouble("patientamount");
	double totalinsuraramount=rs.getDouble("insuraramount");
	double totalextrainsuraramount=rs.getDouble("extrainsuraramount");
	rs.close();
	ps.close();
	conn.close();
	
	conn=MedwanQuery.getInstance().getAdminConnection();
	ps=conn.prepareStatement("select count(*) total from AccessLogs");
	rs=ps.executeQuery();
	rs.next();
	int totalaccesslogs=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getAdminConnection();
	ps=conn.prepareStatement("select count(*) total from Services");
	rs=ps.executeQuery();
	rs.next();
	int totalservices=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	conn=MedwanQuery.getInstance().getAdminConnection();
	ps=conn.prepareStatement("select count(*) total from Users u, Admin a where u.personid=a.personid and u.stop is null");
	rs=ps.executeQuery();
	rs.next();
	int totalusers=rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();

%>

<table width='100%'>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patients",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalpatients)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_visits",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalvisits)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_admissions",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totaladmissions)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_encounters",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalvisits+totaladmissions)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_debets",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totaldebets)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patientinvoices",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalpatientinvoices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insurarinvoices",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalinsurarinvoices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_extrainsurarinvoices",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalextrainsurarinvoices)%></b></center></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_prestations",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalprestations)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patientamount",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalpatientamount)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insuraramount",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalinsuraramount)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_extrainsuraramount",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalextrainsuraramount)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_diagnoses",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totaldiagnoses)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_fre",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalrfe)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_transactions",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totaltransactions)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_items",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalitems)%></b></center></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_requestedlabanalyses",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalrequestedlabanalyses)%></b></center></td>
	<td class='admin2' colspan="3"><center><%=getTran("web","total_antibiograms",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalantibiograms)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insurars",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalinsurars)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_users",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalusers)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_services",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalservices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_beds",sWebLanguage)%>: <b><%=new DecimalFormat("#,###").format(totalbeds)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
</table>
