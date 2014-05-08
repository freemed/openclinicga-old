<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.finance.*,
                java.util.Hashtable,
                java.util.Vector,
                java.util.Collections,
                java.text.DecimalFormat"%>
<table width="100%">
<tr><td class='admin' colspan="6"><%=getTran("Web","statistics.openinvoicelists",sWebLanguage) %></td></tr>
<%
	String activeuser="";
	Vector invoices=PatientInvoice.searchInvoicesByStatusAndBalance(request.getParameter("start"),request.getParameter("end"),"open","");
    for(int n=0;n<invoices.size();n++){
    	PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);
    	if(!activeuser.equalsIgnoreCase(invoice.getUpdateUser())){
    		activeuser=invoice.getUpdateUser();
    		out.println("<tr><td colspan='6' class='admin'>"+activeuser+" - "+MedwanQuery.getInstance().getUserName(Integer.parseInt(activeuser))+"</td></tr>");
    		out.println("<tr>");
    		out.println("<td class='admin2'>"+getTran("web","ID",sWebLanguage)+"</td>");
    		out.println("<td class='admin2'>"+getTran("web","date",sWebLanguage)+"</td>");
    		out.println("<td class='admin2'>"+getTran("web","lastupdate",sWebLanguage)+"</td>");
    		out.println("<td class='admin2'>"+getTran("web","patient",sWebLanguage)+"</td>");
    		out.println("<td class='admin2'>"+getTran("web","amount",sWebLanguage)+"</td>");
    		out.println("<td class='admin2'>"+getTran("web","balance",sWebLanguage)+"</td>");
    		out.println("</tr>");
    	}
		out.println("<tr>");
		out.println("<td class='admin2'>"+invoice.getUid()+"</td>");
		out.println("<td class='admin2'>"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"</td>");
		out.println("<td class='admin2'>"+ScreenHelper.fullDateFormatSS.format(invoice.getUpdateDateTime())+"</td>");
		out.println("<td class='admin2'>"+AdminPerson.getAdminPerson(invoice.getPatientUid()).getFullName()+"</td>");
		out.println("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(invoice.getPatientAmount())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
		out.println("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
		out.println("</tr>");
    }
%>
</table>