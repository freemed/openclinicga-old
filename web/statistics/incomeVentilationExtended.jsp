<%@ page import="java.util.*,java.text.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%!
	class Income{
		public double patient;
		public double insurar;
		public double extrainsurar;
		
		public double getTotal(){
			return patient+insurar+extrainsurar;
		}
	}
%>
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
	String sQuery="select oc_debet_objectid,oc_prestation_invoicegroup,oc_encounter_serviceuid,oc_debet_amount,oc_debet_insuraramount,oc_debet_extrainsuraramount"+
				" from oc_debets a,oc_prestations b,oc_encounter_services c"+
				" where"+
				" oc_prestation_objectid=replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
				" oc_encounter_objectid=replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
				" oc_debet_date between ? and ? and"+
				" oc_debet_patientinvoiceuid is not null and"+
				" oc_debet_patientinvoiceuid <> ''"+
				" order by oc_debet_objectid";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	String priceFormat=MedwanQuery.getInstance().getConfigString("priceFormatExtended","#,##0.00");
	String currency=" "+MedwanQuery.getInstance().getConfigString("currency","");
	double totalpatient=0,totalinsurar=0,totalextrainsurar=0,patientamount,insuraramount,extrainsuraramount;
	Hashtable debets = new Hashtable();
	SortedMap incomes = new TreeMap();
	String group,debetid,serviceuid;
	Income income = null;
	while(rs.next()){
		debetid=rs.getString("oc_debet_objectid");
		if(debets.get(debetid)==null){
			group=checkString(rs.getString("oc_prestation_invoicegroup"));
			if(group.length()==0){
				serviceuid=rs.getString("oc_encounter_serviceuid");
				group=serviceuid+" "+checkString(getTranDb("service",serviceuid,sWebLanguage));
				if(group.length()==0){
					group="?";
				}
				group="S: "+group;
			}
			else {
				group="C: "+group;
			}
			income=(Income)incomes.get(group);
			if(income==null){
				income=new Income();
			}
			income.patient+=rs.getDouble("oc_debet_amount");
			income.insurar+=rs.getDouble("oc_debet_insuraramount");
			income.extrainsurar+=rs.getDouble("oc_debet_extrainsuraramount");
			incomes.put(group,income);
			debets.put(debetid,"");
		}
	}
	rs.close();
	ps.close();
	Iterator i = incomes.keySet().iterator();
	while(i.hasNext()){
		group = (String)i.next();
		income = (Income)incomes.get(group);
		totalpatient+=income.patient;
		totalinsurar+=income.insurar;
		totalextrainsurar+=income.extrainsurar;
		out.println("<tr><td class='admin2'>"+group+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(income.getTotal())+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(income.patient)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(income.insurar)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(income.extrainsurar)+currency+"</td></tr>");
	}
	conn.close();
	out.println("<tr><td class='admin2' colspan='5'><hr/></td></tr><tr><td class='admin2'>"+getTran("Web","total",sWebLanguage)+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalpatient+totalinsurar+totalextrainsurar)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalpatient)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalinsurar)+currency+"</td><td class='admin2'>"+new DecimalFormat(priceFormat).format(totalextrainsurar)+currency+"</td></tr>");
%>
</table>