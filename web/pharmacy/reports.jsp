<%@ page import="be.openclinic.pharmacy.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="reports">

<%
	String stocks="";
	Vector serviceStocks = ServiceStock.getStocksByUser(activeUser.userid); 
	for(int n=0;n<serviceStocks.size();n++){
		ServiceStock serviceStock = (ServiceStock)serviceStocks.elementAt(n);
		stocks+="<option value='"+serviceStock.getUid()+"'>"+serviceStock.getName()+"</option>";
	}
	String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
	String lastdayPreviousMonth=ScreenHelper.stdDateFormat.format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
	out.print(ScreenHelper.writeTblHeader(getTran("Web","pharmacy.reports",sWebLanguage),sCONTEXTPATH)
	        +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("start","reports",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","reports",lastdayPreviousMonth,sWebLanguage)+"&nbsp;</td></tr>"
	        +"<tr><td>"+getTran("web","servicestock",sWebLanguage)+"</td><td><select name='servicestockuid' id='servicestockuid' class='text'>"+stocks+"</select></td></tr>"
	        +ScreenHelper.writeTblFooter()+"<br>");
    out.print(ScreenHelper.writeTblHeader(getTran("Web","pharmacy.reports.stocks",sWebLanguage),sCONTEXTPATH)
            +ScreenHelper.writeTblFooter()+"<br>");
    out.print(ScreenHelper.writeTblHeader(getTran("Web","pharmacy.reports.products",sWebLanguage),sCONTEXTPATH)
            +writeTblChildWithCode("javascript:openPopup(\"pharmacy/expiredLots.jsp\",800,600,\"quickFile\")",getTran("Web","pharmacy.report.expiring.lots",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    out.print(ScreenHelper.writeTblHeader(getTran("Web","pharmacy.reports.supply",sWebLanguage),sCONTEXTPATH)
            +writeTblChildWithCode("javascript:pharmacyCsvReport(\"supplier.deliveries\")",getTran("Web","pharmacy.report.supplier.deliveries",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    out.print(ScreenHelper.writeTblHeader(getTran("Web","pharmacy.reports.outgoing",sWebLanguage),sCONTEXTPATH)
            +writeTblChildWithCode("javascript:openPopup(\"pharmacy/patientDeliveries.jsp\",800,600,\"quickFile\")",getTran("Web","pharmacy.report.patientdeliveries",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
%>
</form>
<script>
	function pharmacyCsvReport(sType){
		window.open("<c:url value="/"/>pharmacy/pharmacyCsvReport.jsp?type="+sType+"&start="+document.getElementById("start").value+"&end="+document.getElementById("end").value+"&servicestockuid="+document.getElementById("servicestockuid").value,1,1,"pharmacyreport");
	}
</script>