<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery" %>
<table width='100%'>
<%
	try{
		String serverid=request.getParameter("serverid");
		java.util.Vector services = DatacenterHelper.getBedoccupancy(Integer.parseInt(serverid));
		for(int n=0;n<services.size();n++){
			String diag=(String)services.elementAt(n);
			double val = Double.parseDouble(diag.split(";")[3]);
			String color="lightgreen";
			if (val>=100){
				val=100;
				color="red";
			}
			else if( val>=70){
				color="orange";
			}
			else if( val>=50){
				color="yellow";
			}
			out.print("<tr><td class='admin'>"+diag.split(";")[0].toUpperCase()+"</td><td class='admin'>"+diag.split(";")[1].toUpperCase()+"</td><td width='20%'><table width='100%'><tr><td bgcolor='"+color+"' width='"+val+"%'>&nbsp;</td><td bgcolor='white' width='"+(100-val)+"%'/></tr></table></td><td class='admin2'><a href='javascript:occupancyGraph(\""+diag.split(";")[0]+"\")'>"+diag.split(";")[2]+" ("+diag.split(";")[3]+"%)"+"</a></td></tr>");
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
</table>