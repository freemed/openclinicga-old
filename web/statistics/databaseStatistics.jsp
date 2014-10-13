<%@page import="java.util.*,java.text.*,net.admin.User,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog,uk.org.primrose.pool.core.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    DecimalFormat deci = new DecimalFormat("#,###");

	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("select count(*) total from Admin");
	ResultSet rs = ps.executeQuery();
	rs.next();
	int totalpatients = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_ENCOUNTERS where oc_encounter_type='visit'");
	rs = ps.executeQuery();
	rs.next();
	int totalvisits = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_ENCOUNTERS where oc_encounter_type='admission'");
	rs = ps.executeQuery();
	rs.next();
	int totaladmissions = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_DEBETS");
	rs = ps.executeQuery();
	rs.next();
	int totaldebets = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_PATIENTINVOICES");
	rs = ps.executeQuery();
	rs.next();
	int totalpatientinvoices = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_PATIENTCREDITS");
	rs = ps.executeQuery();
	rs.next();
	int totalpatientcredits = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_INSURARINVOICES");
	rs = ps.executeQuery();
	rs.next();
	int totalinsurarinvoices = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_EXTRAINSURARINVOICES");
	rs = ps.executeQuery();
	rs.next();
	int totalextrainsurarinvoices = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_INSURARS");
	rs = ps.executeQuery();
	rs.next();
	int totalinsurars = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_PRESTATIONS");
	rs = ps.executeQuery();
	rs.next();
	int totalprestations = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_DIAGNOSES");
	rs = ps.executeQuery();
	rs.next();
	int totaldiagnoses = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_RFE");
	rs = ps.executeQuery();
	rs.next();
	int totalrfe = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from OC_BEDS");
	rs = ps.executeQuery();
	rs.next();
	int totalbeds = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from RequestedLabanalyses");
	rs = ps.executeQuery();
	rs.next();
	int totalrequestedlabanalyses = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from oc_antibiograms");
	rs = ps.executeQuery();
	rs.next();
	int totalantibiograms = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from Transactions");
	rs = ps.executeQuery();
	rs.next();
	int totaltransactions = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select count(*) total from Items");
	rs = ps.executeQuery();
	rs.next();
	int totalitems = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getOpenclinicConnection();
	ps = conn.prepareStatement("select sum(oc_debet_amount) patientamount,sum(oc_debet_insuraramount) insuraramount,sum(oc_debet_extrainsuraramount) extrainsuraramount from oc_debets");
	rs = ps.executeQuery();
	rs.next();
	double totalpatientamount = rs.getDouble("patientamount");
	double totalinsuraramount = rs.getDouble("insuraramount");
	double totalextrainsuraramount = rs.getDouble("extrainsuraramount");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getAdminConnection();
	ps = conn.prepareStatement("select count(*) total from AccessLogs");
	rs = ps.executeQuery();
	rs.next();
	int totalaccesslogs = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getAdminConnection();
	ps = conn.prepareStatement("select count(*) total from Services");
	rs = ps.executeQuery();
	rs.next();
	int totalservices = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
	
	conn = MedwanQuery.getInstance().getAdminConnection();
	ps = conn.prepareStatement("select count(*) total from Users u, Admin a where u.personid = a.personid and u.stop is null");
	rs = ps.executeQuery();
	rs.next();
	int totalusers = rs.getInt("total");
	rs.close();
	ps.close();
	conn.close();
%>

<table width="100%" class="list" cellspacing="1" cellpadding="0">
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patients",sWebLanguage)%>: <b><%=deci.format(totalpatients)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_visits",sWebLanguage)%>: <b><%=deci.format(totalvisits)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_admissions",sWebLanguage)%>: <b><%=deci.format(totaladmissions)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_encounters",sWebLanguage)%>: <b><%=deci.format(totalvisits+totaladmissions)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_debets",sWebLanguage)%>: <b><%=deci.format(totaldebets)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patientinvoices",sWebLanguage)%>: <b><%=deci.format(totalpatientinvoices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insurarinvoices",sWebLanguage)%>: <b><%=deci.format(totalinsurarinvoices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_extrainsurarinvoices",sWebLanguage)%>: <b><%=deci.format(totalextrainsurarinvoices)%></b></center></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_prestations",sWebLanguage)%>: <b><%=deci.format(totalprestations)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patientamount",sWebLanguage)%>: <b><%=deci.format(totalpatientamount)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insuraramount",sWebLanguage)%>: <b><%=deci.format(totalinsuraramount)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_extrainsuraramount",sWebLanguage)%>: <b><%=deci.format(totalextrainsuraramount)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_diagnoses",sWebLanguage)%>: <b><%=deci.format(totaldiagnoses)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_fre",sWebLanguage)%>: <b><%=deci.format(totalrfe)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_transactions",sWebLanguage)%>: <b><%=deci.format(totaltransactions)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_items",sWebLanguage)%>: <b><%=deci.format(totalitems)%></b></center></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_requestedlabanalyses",sWebLanguage)%>: <b><%=deci.format(totalrequestedlabanalyses)%></b></center></td>
	<td class='admin2' colspan="3"><center><%=getTran("web","total_antibiograms",sWebLanguage)%>: <b><%=deci.format(totalantibiograms)%></b></center></td>
</tr>
<tr>
	<td colspan='10'><hr/></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_insurars",sWebLanguage)%>: <b><%=deci.format(totalinsurars)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_users",sWebLanguage)%>: <b><%=deci.format(totalusers)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_services",sWebLanguage)%>: <b><%=deci.format(totalservices)%></b></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_beds",sWebLanguage)%>: <b><%=deci.format(totalbeds)%></b></center></td>
</tr>
</table>
	
<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();"/>
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
</script>