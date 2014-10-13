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
    	Debug.println("\n**************** statistics/issuedInsurerInvoiceList.jsp ***************");
    	Debug.println("sStart : "+sStart);
    	Debug.println("sEnd   : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
    String sTitle = getTran("web","statistics.issuedinsurerinvoices",sWebLanguage)+"&nbsp;&nbsp;&nbsp;<i>["+sStart+" - "+sEnd+"]</i>";
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage," closeWindow()")%>
<div style="padding-top:5px;"/>

<table width="100%" cellpadding="0" cellspacing="1" class="list">
    <%-- HEADER --%>
	<tr class="admin">
		<td width="90"><%=getTran("web","date",sWebLanguage)%></td>
		<td width="120"><%=getTran("web","invoicenumber",sWebLanguage)%></td>
		<td width="250"><%=getTran("web","insurar",sWebLanguage)%></td>
		<td width="*"><%=getTran("web","amount",sWebLanguage)%></td>
	</tr>
	
<%
	Vector invoices = InsurarInvoice.searchInvoices(sStart,sEnd,"","","");
    String sClass = "1";
    
    // show in reverse order
	for(int n=invoices.size()-1; n>=0; n--){
		InsurarInvoice invoice = (InsurarInvoice)invoices.elementAt(n);
		if(invoice!=null){
			// alternate row-style
			if(sClass.length()==0) sClass = "1";
			else                   sClass = "";
			
			out.print("<tr class='list"+sClass+"'>");
			 out.print("<td>"+ScreenHelper.formatDate(invoice.getDate())+"</td>");
			 out.print("<td>"+invoice.getUid()+"</td>");
			 out.print("<td>"+(invoice.getInsurar()!=null?invoice.getInsurar().getName():"?")+"</td>");
			 out.print("<td>"+deci.format(invoice.getAmount())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
			out.print("</tr>");
		}
	}
%>
</table>

<%=getTran("web","invoices",sWebLanguage)%>: <%=invoices.size()%><br>

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