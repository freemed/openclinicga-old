<%@ page import="be.openclinic.finance.*,be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	SortedMap insurarcredits = new TreeMap();
	SortedMap insurardebets = new TreeMap();
	Hashtable insurars = new Hashtable();
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_insurarinvoices where oc_insurarinvoice_date>=? and oc_insurarinvoice_date<=?");
	ps.setDate(1,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(begin).getTime()));
	ps.setDate(2,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(end).getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		//We doorlopen elke factuur en zoeken de bijhorende betalingen op
		String invoiceuid = rs.getString("OC_INSURARINVOICE_SERVERID")+"."+rs.getString("OC_INSURARINVOICE_OBJECTID");
		double debetvalue=InsurarInvoice.getDebetAmount(invoiceuid);
		double creditvalue=InsurarInvoice.getCreditAmount(invoiceuid);
		String month=new SimpleDateFormat("MM/yyyy").format(rs.getDate("oc_insurarinvoice_date"));
		String insurar=rs.getString("oc_insurarinvoice_insuraruid");
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
	
	out.println("<table width='100%'>");
	//We hebben nu voor elke maand de lijst van verzekeraars met hun bedragen
	String month="";
	Iterator iCredits = insurarcredits.keySet().iterator();
	double totalmonthdebets=0,totalmonthcredits=0,totalperioddebets=0,totalperiodcredits=0;
	while(iCredits.hasNext()){
		String id = (String)iCredits.next();
		if(!month.equalsIgnoreCase(id.split("\\|")[0])){
			if(!month.equals("")){
				out.println("<tr><td class='admin'>"+getTran("web","total",sWebLanguage)+" "+month+"</td><td class='admin'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalmonthdebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalmonthcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin'>"+new DecimalFormat("#.##").format(totalmonthcredits*100/totalmonthdebets)+"%</td></tr>");
				totalmonthdebets=0;
				totalmonthcredits=0;
			}
			month=id.split("\\|")[0];
			out.println("<tr class='admin'><td colspan='4'>"+month+"</td></tr>");
		}
		out.println("<tr><td class='admin'>"+insurars.get(id.split("\\|")[1])+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(insurardebets.get(id))+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(insurarcredits.get(id))+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin2'>"+new DecimalFormat("#.##").format(((Double)insurarcredits.get(id))*100/((Double)insurardebets.get(id)))+"%</td></tr>");
		totalmonthdebets+=(Double)insurardebets.get(id);
		totalmonthcredits+=(Double)insurarcredits.get(id);
		totalperioddebets+=(Double)insurardebets.get(id);
		totalperiodcredits+=(Double)insurarcredits.get(id);
	}
	if(!month.equals("")){
		out.println("<tr><td class='admin'>"+getTran("web","total",sWebLanguage)+" "+month+"</td><td class='admin'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalmonthdebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalmonthcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td class='admin'>"+new DecimalFormat("#.##").format(totalmonthcredits*100/totalmonthdebets)+"%</td></tr>");
	}
	out.println("<tr class='admin'><td>"+getTran("web","totalperiod",sWebLanguage)+"</td><td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalperioddebets)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#")).format(totalperiodcredits)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td><td>"+new DecimalFormat("#.##").format(totalperiodcredits*100/totalperioddebets)+"%</td></tr>");
	out.println("</table>");
%>