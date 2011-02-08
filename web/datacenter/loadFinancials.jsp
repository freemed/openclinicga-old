<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery" %>
<%!
	public String format(String serverid,String sFormat,String parameterid,String period){
		String value = DatacenterHelper.getFinancialValue(Integer.parseInt(serverid),parameterid,period);
		if(!value.equalsIgnoreCase("?")){
			return new java.text.DecimalFormat(sFormat).format(Double.parseDouble(value));
		}
		return value;
	}
%>
<%
	String serverid=request.getParameter("serverid");
	String period=request.getParameter("period");
	String sFormat=MedwanQuery.getInstance().getConfigString("datacenterCurrencyFormat."+serverid,"#,000.#");
	String sCurrency=MedwanQuery.getInstance().getConfigString("datacenterCurrency."+serverid,"RWF");
%>
<table width='100%'>
	<tr>
		<td/>
		<td class='admin'><%=getTran("web","total",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","admissions",sWebLanguage) %></td>
		<td class='admin'><%=getTran("web","visits",sWebLanguage) %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("datacenter","patients.revenue",sWebLanguage) %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.1",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.1.1",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.1.2",period)+" "+sCurrency %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("datacenter","insurers.revenue",sWebLanguage) %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.2",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.2.1",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.2.2",period)+" "+sCurrency %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("datacenter","extrainsurers.revenue",sWebLanguage) %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.3",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.3.1",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.3.2",period)+" "+sCurrency %></td>
	</tr>
	<tr>
		<td ><%=getTran("datacenter","total.revenue",sWebLanguage) %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.0",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.0.1",period)+" "+sCurrency %></td>
		<td class='admin2'><%=format(serverid,sFormat,"financial.0.2",period)+" "+sCurrency %></td>
	</tr>
	<tr><td colspan="4"><hr/></td></tr>

<%
	java.util.Vector financials = DatacenterHelper.getFinancials(Integer.parseInt(serverid),period);
	for(int n=0;n<financials.size();n++){
		String financial=(String)financials.elementAt(n);
		String cls = financial.split(";")[0].toUpperCase();
		if(cls==null || cls.length()==0){
			cls="?";
		}
		out.print("<tr><td class='admin'>"+cls+"</td><td class='admin2' colspan='3'><a href='javascript:financialGraph(\""+cls+"\",\""+period+"\")'>"+new java.text.DecimalFormat(sFormat).format(Double.parseDouble(financial.split(";")[1]))+" "+sCurrency+"</a></td></tr>");
	}
%>
</table>