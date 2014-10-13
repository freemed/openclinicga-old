<%@page import="java.util.*,
                java.text.*"%>
<%@include file="/includes/validateUser.jsp"%>
               
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
	
	String sTitle = getTranNoLink("Web","statistics.incomeVentilation",sWebLanguage)+": <i>"+sStart+" "+getTran("web","to",sWebLanguage)+" "+sEnd+"</i>";
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
	String sQuery = "select oc_prestation_reftype, sum(oc_debet_amount) as patientamount, sum(oc_debet_insuraramount) as insuraramount,"+
	                "  sum(oc_debet_extrainsuraramount) as extrainsuraramount"+
				    " from oc_debets a,oc_prestations b"+
			        "  where oc_prestation_objectid = replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
				    "   and oc_debet_date between ? and ?"+
				    "   and oc_debet_patientinvoiceuid is not null"+
				    "   and oc_debet_patientinvoiceuid <> ''"+
				    " group by oc_prestation_reftype"+
				    " order by sum(oc_debet_amount)+sum(oc_debet_insuraramount)+sum(oc_debet_extrainsuraramount) desc";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	
	String priceFormat = MedwanQuery.getInstance().getConfigString("priceFormatExtended","#,##0.00");
	String currency = " "+MedwanQuery.getInstance().getConfigString("currency","");
	double totalpatient = 0, totalinsurar = 0, totalextrainsurar = 0;
	DecimalFormat deci = new DecimalFormat(priceFormat);
	int recordCount = 0;
	String sClass = "1";
	
	while(rs.next()){
		recordCount++;
		
		double patientamount = rs.getDouble("patientamount");
		double insuraramount = rs.getDouble("insuraramount");
		double extrainsuraramount = rs.getDouble("extrainsuraramount");
	
		totalpatient+= patientamount;
		totalinsurar+= insuraramount;
		totalextrainsurar+= extrainsuraramount;
		
		String group = checkString(rs.getString("oc_prestation_reftype"));
		
		// alternate row-style
   		if(sClass.length()==0) sClass = "1";
   		else                   sClass = "";
		
		out.print("<tr class='"+sClass+"'>"+
		           "<td>"+(group.length()>0?group:"?")+"</td>"+
		           "<td>"+deci.format(patientamount+insuraramount+extrainsuraramount)+currency+"</td>"+
		           "<td>"+deci.format(patientamount)+currency+"</td>"+
		           "<td>"+deci.format(insuraramount)+currency+"</td>"+
		           "<td>"+deci.format(extrainsuraramount)+currency+"</td>"+
		          "</tr>");
	}
	rs.close();
	ps.close();	
	conn.close();
	
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