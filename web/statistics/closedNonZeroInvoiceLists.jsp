<%@page import="be.openclinic.finance.*,
                java.util.Hashtable,
                java.util.Vector,
                java.util.Collections,
                java.text.DecimalFormat"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************* statistics/closedNonZeroInvoiceLists.jsp.jsp ************");
    	Debug.println("sStart : "+sStart);
    	Debug.println("sEnd   : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
    String sTitle = getTran("web","statistics.closedNonZeroInvoiceLists",sWebLanguage)+"&nbsp;&nbsp;&nbsp;<i>["+sStart+" - "+sEnd+"]</i>";
%>
     
<%=writeTableHeaderDirectText(sTitle,sWebLanguage," closeWindow()")%>
<div style="padding-top:5px;"/>

<table width="100%" class="list" cellspacing="1" cellpadding="0">
<%
	String activeuser = "";
    int dossierCount = 0, invoiceCount = 0;

    // list closed invoices
	Vector invoices = PatientInvoice.searchInvoicesByStatusAndBalance(sStart,sEnd,"closed","1");
    for(int n=0; n<invoices.size(); n++){
    	PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);

    	// other dossier
    	if(!activeuser.equalsIgnoreCase(invoice.getUpdateUser())){
    		activeuser = invoice.getUpdateUser();
    		dossierCount++;
    		
    		out.print("<tr class='gray'>"+
    		           "<td colspan='6'>"+activeuser+" - "+MedwanQuery.getInstance().getUserName(Integer.parseInt(activeuser))+"</td>"+
    		          "</tr>");

    		// header
    		out.print("<tr>");
    		 out.print("<td class='admin2'>"+getTran("web","ID",sWebLanguage)+"</td>");
    		 out.print("<td class='admin2'>"+getTran("web","date",sWebLanguage)+"</td>");
    		 out.print("<td class='admin2'>"+getTran("web","lastupdate",sWebLanguage)+"</td>");
    		 out.print("<td class='admin2'>"+getTran("web","patient",sWebLanguage)+"</td>");
    		 out.print("<td class='admin2'>"+getTran("web","amount",sWebLanguage)+"</td>");
    		 out.print("<td class='admin2'>"+getTran("web","balance",sWebLanguage)+"</td>");
    		out.print("</tr>");
    	}
    	
		out.print("<tr>");
		 out.print("<td class='admin2'>"+invoice.getUid()+"</td>");
		 out.print("<td class='admin2'>"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"</td>");
		 out.print("<td class='admin2'>"+ScreenHelper.fullDateFormatSS.format(invoice.getUpdateDateTime())+"</td>");
		 out.print("<td class='admin2'>"+AdminPerson.getAdminPerson(invoice.getPatientUid()).getFullName()+"</td>");
		 out.print("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(invoice.getPatientAmount())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
		 out.print("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
		out.print("</tr>");
    }
%>
</table>

<%=getTran("web","patients",sWebLanguage)%>: <%=dossierCount%><br>
<%=getTran("web","invoices",sWebLanguage)%>: <%=invoiceCount%><br>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="closeWindow();">
<%=ScreenHelper.alignButtonsStop()%>

<script>  
  <%-- CLOSE WINDOW --%>
  function closeWindow(){
    window.opener = null;
    window.close();
  }
</script>