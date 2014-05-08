<%@ page import="be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
<tr class='admin'>
	<td><%=getTran("web","invoicenumber",sWebLanguage) %></td>
	<td><%=getTran("web","date",sWebLanguage) %></td>
	<td><%=getTran("web","patient",sWebLanguage) %></td>
	<td><%=getTran("web","insurar",sWebLanguage) %></td>
</tr>
<%
	String start = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	String serviceid = checkString(request.getParameter("serviceid"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
String sSql = 	"select distinct OC_PATIENTINVOICE_OBJECTID,OC_PATIENTINVOICE_DATE,OC_INSURAR_NAME,lastname,firstname from OC_DEBETS a,OC_PATIENTINVOICES b,OC_INSURANCES c,OC_INSURARS d, AdminView e"+
					" where"+
					" OC_PATIENTINVOICE_OBJECTID=replace(OC_DEBET_PATIENTINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
					" AND OC_INSURANCE_OBJECTID=replace(OC_DEBET_INSURANCEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
					" AND OC_INSURAR_OBJECTID=replace(OC_INSURANCE_INSURARUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
					" AND OC_INSURAR_MODIFIERS LIKE '%;%;%;1;%'"+
					" AND e.personid=OC_PATIENTINVOICE_PATIENTUID"+
					" AND (OC_PATIENTINVOICE_ACCEPTATIONUID is null OR OC_PATIENTINVOICE_ACCEPTATIONUID='')"+
					" AND OC_DEBET_DATE >=?"+
					" AND OC_DEBET_DATE <=?"+
					(serviceid.length()>0?" AND OC_DEBET_SERVICEUID like ?":"")+
					" ORDER BY OC_INSURAR_NAME,OC_PATIENTINVOICE_DATE";
	System.out.println(sSql);
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(start).getTime()));
	ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(end).getTime()));
	if(serviceid.length()>0){
		ps.setString(3,serviceid+"%");
	}
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String invoiceid=rs.getString("OC_PATIENTINVOICE_OBJECTID");
		out.println("<tr><td class='admin'><a href='javascript:showPatientInvoice("+invoiceid+")'>"+invoiceid+"</a> <label class='labelred' id='label."+invoiceid+"'></label></td><td class='admin2'>"+ScreenHelper.stdDateFormat.format(rs.getDate("OC_PATIENTINVOICE_DATE"))+"</td><td class='admin2'>"+checkString(rs.getString("lastname")).toUpperCase()+", "+rs.getString("firstname")+"</td><td class='admin2'>"+rs.getString("OC_INSURAR_NAME")+"</td></tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>
<center><input type='button' name='button' value='<%=getTran("web","close",sWebLanguage) %>' onclick='window.close();'/></center>

<script>
	function showPatientInvoice(sInvoiceId){
		openPopup("/financial/patientInvoiceEdit.jsp&ts=<%=getTs()%>&PopupWidth=800&PopupHeight=600&externalvalidationcode=window.opener.validate("+sInvoiceId+");&FindPatientInvoiceUID="+sInvoiceId);
	}
	
	function validate(sInvoiceId){
		document.getElementById('label.'+sInvoiceId).innerHTML=' (<%=getTranNoLink("web","validated",sWebLanguage)%>)';
	}
</script>