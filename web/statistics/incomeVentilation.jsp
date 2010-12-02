<%@ page import="java.util.*,java.text.*" %>
<%@include file="/includes/validateUser.jsp" %>
<table width='100%'>
	<tr><td class='admin' colspan='5'><%=getTran("Web","statistics.incomeVentilation",sWebLanguage)+": "+request.getParameter("start")+" "+getTran("web","to",sWebLanguage)+" "+request.getParameter("end")%></td></tr>
	<tr>
		<td class='admin'><%=getTran("web","invoice.category",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","total.amount",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","patient.amount",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","insurar.amount",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","extrainsurar.amount",sWebLanguage) %></td>
	</tr>
<%
	java.util.Date start = new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(checkString(request.getParameter("start"))+" 23:59");
	java.util.Date end = new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(checkString(request.getParameter("end"))+" 23:59");
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select oc_prestation_reftype,sum(oc_debet_amount) as patientamount,sum(oc_debet_insuraramount) as insuraramount,sum(oc_debet_extrainsuraramount) as extrainsuraramount"+
				" from oc_debets a,oc_prestations b"+
				" where"+
				" oc_prestation_objectid=replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
				" oc_debet_date between ? and ? and"+
				" oc_debet_patientinvoiceuid is not null and"+
				" oc_debet_patientinvoiceuid <> ''"+
				" group by oc_prestation_reftype"+
				" order by sum(oc_debet_amount)+sum(oc_debet_insuraramount)+sum(oc_debet_extrainsuraramount) desc";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	String priceFormat=MedwanQuery.getInstance().getConfigString("priceFormatExtended","#,##0.00");
	String currency=" "+MedwanQuery.getInstance().getConfigString("currency","");
	double totalpatient=0,totalinsurar=0,totalextrainsurar=0;
	while(rs.next()){
		double patientamount=rs.getDouble("patientamount");
		double insuraramount=rs.getDouble("insuraramount");
		double extrainsuraramount=rs.getDouble("extrainsuraramount");
		totalpatient+=patientamount;
		totalinsurar+=insuraramount;
		totalextrainsurar+=extrainsuraramount;
		String group=checkString(rs.getString("oc_prestation_reftype"));
		out.println("<tr><td class='admin2'>"+(group.length()>0?group:"?")+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(patientamount+insuraramount+extrainsuraramount)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(patientamount)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(insuraramount)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(extrainsuraramount)+currency+"</td></tr>");
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin2' colspan='5'><hr/></td></tr><tr><td class='admin2'>"+getTran("Web","total",sWebLanguage)+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalpatient+totalinsurar+totalextrainsurar)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalpatient)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalinsurar)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalextrainsurar)+currency+"</td></tr>");
	conn.close();
%>
</table>