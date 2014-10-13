<%@page import="java.util.*,
                java.text.*" %>
<%@include file="/includes/validateUser.jsp"%>

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

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************* statistics/incomeVentilation.jsp *******************");
		Debug.println("sStart : "+sStart);
		Debug.println("sEnd   : "+sEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	String sTitle = getTranNoLink("Web","statistics.incomeVentilationPerCategoryAndService",sWebLanguage)+": <i>"+sStart+" "+getTran("web","to",sWebLanguage)+" "+sEnd+"</i>";
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage," window.close()")%>
	
<table width="100%" class="sortable" id="searchresults" cellspacing="1" bottomRowCount="1" cellpadding="0">
	<%-- HEADER --%>
	<tr class="gray">
		<td width="100"><%=getTran("web","invoice.category",sWebLanguage)%></td>
		<td width="100"><%=getTran("web","total.amount",sWebLanguage)%></td>
		<td width="100"><%=getTran("web","patient.amount",sWebLanguage)%></td>
		<td width="100"><%=getTran("web","insurar.amount",sWebLanguage)%></td>
		<td width="*"><%=getTran("web","extrainsurar.amount",sWebLanguage)%></td>
	</tr>
	
<%
	java.util.Date start = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("start"))+" 00:00"),
	               end   = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("end"))+" 23:59");

	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery = "select oc_debet_objectid, oc_prestation_invoicegroup, oc_debet_serviceuid,"+
	                "  oc_debet_amount, oc_debet_insuraramount, oc_debet_extrainsuraramount"+
			    	" from oc_debets a, oc_prestations b"+
				    "  where oc_prestation_objectid = replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
				    "   and oc_debet_date between ? and ?"+
				    "   and oc_debet_patientinvoiceuid is not null"+
			        "   and oc_debet_patientinvoiceuid <> ''"+
				    "  order by oc_debet_objectid";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	
	String priceFormat = MedwanQuery.getInstance().getConfigString("priceFormatExtended","#,##0.00");
	String currency = " "+MedwanQuery.getInstance().getConfigString("currency","");
	double totalpatient = 0, totalinsurar = 0, totalextrainsurar = 0, patientamount, insuraramount, extrainsuraramount;
	Hashtable debets = new Hashtable();
	SortedMap incomes = new TreeMap();
	String group, debetid, serviceuid, servicename;
	DecimalFormat deci = new DecimalFormat(priceFormat);
	Income income = null;
	Service service;
	
	while(rs.next()){
		debetid = rs.getString("oc_debet_objectid");
		group = checkString(rs.getString("oc_prestation_invoicegroup"));
		
		if(group.length()==0){
			serviceuid = rs.getString("oc_debet_serviceuid");
			servicename = "";
			service = Service.getService(serviceuid);
			if(service!=null){
				servicename = service.getLabel(sWebLanguage);
				group = "S: "+serviceuid+" "+servicename;
			}
			else{
				group = "?";
			}
		}
		else{
			group = "C: "+group;
		}
		
		income = (Income)incomes.get(group);
		if(income==null){
			income = new Income();
		}
		income.patient+= rs.getDouble("oc_debet_amount");
		income.insurar+= rs.getDouble("oc_debet_insuraramount");
		income.extrainsurar+= rs.getDouble("oc_debet_extrainsuraramount");
		incomes.put(group,income);
		debets.put(debetid,"");
	}
	rs.close();
	ps.close();
	conn.close();
	
	Iterator iter = incomes.keySet().iterator();
	String sClass = "1";
	int recordCount = 0;
	while(iter.hasNext()){
		recordCount++;
	
		group = (String)iter.next();
		income = (Income)incomes.get(group);
		
		totalpatient+= income.patient;
		totalinsurar+= income.insurar;
		totalextrainsurar+= income.extrainsurar;

		// alternate row-style
   		if(sClass.length()==0) sClass = "1";
   		else                   sClass = "";
		
		out.print("<tr class='"+sClass+"'>"+
		           "<td>"+group+"</td>"+
		           "<td>"+deci.format(income.getTotal())+currency+"</td>"+
		           "<td>"+deci.format(income.patient)+currency+"</td>"+
		           "<td>"+deci.format(income.insurar)+currency+"</td>"+
		           "<td>"+deci.format(income.extrainsurar)+currency+"</td>"+
		          "</tr>");
	}
	
	// total
	out.print("<tr class='admin'>"+
	           "<td>"+getTran("Web","total",sWebLanguage)+"</td>"+
	           "<td>"+deci.format(totalpatient+totalinsurar+totalextrainsurar)+currency+"</td>"+
	           "<td>"+deci.format(totalpatient)+currency+"</td>"+
	           "<td>"+deci.format(totalinsurar)+currency+"</td>"+
	           "<td>"+deci.format(totalextrainsurar)+currency+"</td>"+
	          "</tr>");
%>
</table>
    
<%
	if(recordCount > 0){
		%><%=recordCount%> <%=getTran("web","recordsFound",sWebLanguage)%><%
	}
	else{
		%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>