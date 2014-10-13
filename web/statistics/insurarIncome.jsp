<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.print("\n********************* statistics/insurarIncome.jsp *********************");
		Debug.print("sStart : "+sStart);
		Debug.print("sEnd   : "+sEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    SortedMap insurarcredits = new TreeMap(),
	          insurardebets = new TreeMap();
	Hashtable insurars = new Hashtable();
	DecimalFormat deciComma = new DecimalFormat("#.##"),
			      deciPrice = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));

	//*** 1 - INSURAR ****************************************************
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_insurarinvoices"+
	                                             " where oc_insurarinvoice_date>=? and oc_insurarinvoice_date<=?");
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sStart).getTime()));
	ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(sEnd).getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		// doorloope elke factuur en zoek de bijhorende betalingen op
		String invoiceuid = rs.getString("OC_INSURARINVOICE_SERVERID")+"."+rs.getString("OC_INSURARINVOICE_OBJECTID");
		
		double debetvalue = InsurarInvoice.getDebetAmount(invoiceuid),
		       creditvalue = InsurarInvoice.getCreditAmount(invoiceuid);
		
		String month = new SimpleDateFormat("MM/yyyy").format(rs.getDate("oc_insurarinvoice_date"));
		String insurar = rs.getString("oc_insurarinvoice_insuraruid");
		
		if(insurars.get(insurar)==null){
			Insurar insurarObject = Insurar.get(insurar);
			insurars.put(insurar,insurarObject.getName());
		}
		
		if(insurarcredits.get(month+"|"+insurar)==null){
			insurarcredits.put(month+"|"+insurar,creditvalue);
		}
		else{
			insurarcredits.put(month+"|"+insurar,(Double)insurarcredits.get(month+"|"+insurar)+creditvalue);
		}
		
		if(insurardebets.get(month+"|"+insurar)==null){
			insurardebets.put(month+"|"+insurar,debetvalue);
		}
		else{
			insurardebets.put(month+"|"+insurar,(Double)insurardebets.get(month+"|"+insurar)+debetvalue);
		}
	}
	rs.close();
	ps.close();
	
	//*** 2 - EXTRA INSURAR **********************************************
	ps = conn.prepareStatement("select * from oc_extrainsurarinvoices"+
	                           " where oc_insurarinvoice_date>=? and oc_insurarinvoice_date<=?");
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sStart).getTime()));
	ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(sEnd).getTime()));
	rs = ps.executeQuery();
	while(rs.next()){
		// doorloop elke factuur en zoek de bijhorende betalingen op
		String invoiceuid = rs.getString("OC_INSURARINVOICE_SERVERID")+"."+rs.getString("OC_INSURARINVOICE_OBJECTID");
		
		double debetvalue = ExtraInsurarInvoice.getDebetAmount(invoiceuid),
		       creditvalue = ExtraInsurarInvoice.getCreditAmount(invoiceuid);
		
		String month = new SimpleDateFormat("MM/yyyy").format(rs.getDate("oc_insurarinvoice_date"));
		String insurar = rs.getString("oc_insurarinvoice_insuraruid");
		
		if(insurars.get(insurar)==null){
			Insurar insurarObject = Insurar.get(insurar);
			insurars.put(insurar,insurarObject.getName());
		}
		
		if(insurarcredits.get(month+"|"+insurar)==null){
			insurarcredits.put(month+"|"+insurar,creditvalue);
		}
		else{
			insurarcredits.put(month+"|"+insurar,(Double)insurarcredits.get(month+"|"+insurar)+creditvalue);
		}
		
		if(insurardebets.get(month+"|"+insurar)==null){
			insurardebets.put(month+"|"+insurar,debetvalue);
		}
		else{
			insurardebets.put(month+"|"+insurar,(Double)insurardebets.get(month+"|"+insurar)+debetvalue);
		}
	}
	rs.close();
	ps.close();

	//*** 3 - EXTRA INSURAR 2 ********************************************
	ps = conn.prepareStatement("select * from oc_extrainsurarinvoices2"+
	                           " where oc_insurarinvoice_date>=? and oc_insurarinvoice_date<=?");
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sStart).getTime()));
	ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(sEnd).getTime()));
	rs = ps.executeQuery();
	while(rs.next()){
		// doorloop elke factuur en zoek de bijhorende betalingen op
		String invoiceuid = rs.getString("OC_INSURARINVOICE_SERVERID")+"."+rs.getString("OC_INSURARINVOICE_OBJECTID");
		
		double debetvalue = ExtraInsurarInvoice2.getDebetAmount(invoiceuid),
		       creditvalue = ExtraInsurarInvoice2.getCreditAmount(invoiceuid);
		
		String month = new SimpleDateFormat("MM/yyyy").format(rs.getDate("oc_insurarinvoice_date"));
		String insurar = rs.getString("oc_insurarinvoice_insuraruid");
		
		if(insurars.get(insurar)==null){
			Insurar insurarObject = Insurar.get(insurar);
			insurars.put(insurar,insurarObject.getName());
		}
		
		if(insurarcredits.get(month+"|"+insurar)==null){
			insurarcredits.put(month+"|"+insurar,creditvalue);
		}
		else{
			insurarcredits.put(month+"|"+insurar,(Double)insurarcredits.get(month+"|"+insurar)+creditvalue);
		}
		
		if(insurardebets.get(month+"|"+insurar)==null){
			insurardebets.put(month+"|"+insurar,debetvalue);
		}
		else{
			insurardebets.put(month+"|"+insurar,(Double)insurardebets.get(month+"|"+insurar)+debetvalue);
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>

<%=writeTableHeader("Web","statistics.paymentrate",sWebLanguage," window.close()")%>
<%	
	Iterator iCredits = insurarcredits.keySet().iterator();
	if(iCredits.hasNext()){
		// voor elke maand de lijst van verzekeraars met hun bedragen
		out.print("<table width='100%' class='list' cellpadding='0' cellspacing='0'>");

		double totalmonthdebets = 0, totalmonthcredits = 0, totalperioddebets = 0, totalperiodcredits = 0;
    	String month = "";
		
		while(iCredits.hasNext()){
			String id = (String)iCredits.next();
			
			if(!month.equalsIgnoreCase(id.split("\\|")[0])){
				if(month.length() > 0){
					out.print("<tr>"+
				               "<td class='admin'>"+getTran("web","total",sWebLanguage)+" "+month+"</td>"+
				               "<td class='admin'>"+deciPrice.format(totalmonthdebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
				               "<td class='admin'>"+deciPrice.format(totalmonthcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
				               "<td class='admin'>"+deciComma.format(totalmonthcredits*100/totalmonthdebets)+"%</td>"+
				              "</tr>");
					totalmonthdebets = 0;
					totalmonthcredits = 0;
				}
				
				month = id.split("\\|")[0];
				out.print("<tr class='admin'><td colspan='4'>"+month+"</td></tr>");
			}
			out.print("<tr>"+
			           "<td class='admin'>"+insurars.get(id.split("\\|")[1])+"</td>"+
			           "<td class='admin2'>"+deciPrice.format(insurardebets.get(id))+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
			           "<td class='admin2'>"+deciPrice.format(insurarcredits.get(id))+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
			           "<td class='admin2'>"+deciComma.format(((Double)insurarcredits.get(id))*100/((Double)insurardebets.get(id)))+"%</td>"+
			          "</tr>");
			
			// totals
			totalmonthdebets+= (Double)insurardebets.get(id);
			totalmonthcredits+= (Double)insurarcredits.get(id);
			totalperioddebets+= (Double)insurardebets.get(id);
			totalperiodcredits+= (Double)insurarcredits.get(id);
		}
		
		if(month.length() > 0){
			out.print("<tr>"+
		               "<td class='admin'>"+getTran("web","total",sWebLanguage)+" "+month+"</td>"+
			           "<td class='admin'>"+deciPrice.format(totalmonthdebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
		               "<td class='admin'>"+deciPrice.format(totalmonthcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
			           "<td class='admin'>"+deciComma.format(totalmonthcredits*100/totalmonthdebets)+"%</td>"+
		              "</tr>");
		}
		
		// total-footer
		out.print("<tr class='gray'>"+
		           "<td>"+getTran("web","totalperiod",sWebLanguage)+"</td>"+
				   "<td>"+deciPrice.format(totalperioddebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
		           "<td>"+deciPrice.format(totalperiodcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
		           "<td>"+deciComma.format(totalperiodcredits*100/totalperioddebets)+"%</td>"+
		          "</tr>");
		
		out.print("</table>");
	}
	else{
	    %><%=getTran("web","noRecordsFound",sWebLanguage)%><%	
	}
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>