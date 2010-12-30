<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<%	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from DC_SERVERGROUPS order by DC_SERVERGROUP_ID,DC_SERVERGROUP_SERVERID");
	ResultSet rs = ps.executeQuery();
	String activeGroup="";
	String group,server;
	String colspan="8";
	while(rs.next()){
		group=rs.getString("DC_SERVERGROUP_ID");
		server=rs.getString("DC_SERVERGROUP_SERVERID");
		if(!activeGroup.equalsIgnoreCase(group)){
			if(activeGroup.length()>0){
				out.println("<tr><td colspan='"+colspan+"' class='admin2'><hr/></td></tr>");
			}
			out.print("<tr><td class='admin'>"+getTran("datacenterservergroup",group,sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","patients",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","users",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","admissions",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","visits",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","transactions",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","diagnoses",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","debets",sWebLanguage)+"</td>"
					+"</tr>");
			activeGroup=group;
		}
		out.print("<tr><td class='admin2'><a href='javascript:openserverdetail("+server+")'>"+getTran("datacenterserver",server,sWebLanguage)+"</a></td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.1")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.2")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.4.1")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.4.2")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.6")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.8.1")+"</td>");
		out.print("<td class='admin2'>"+DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),"core.5")+"</td>");
		out.print("</tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>

<script>
	function openserverdetail(serverid){
		alert(serverid);
	}
</script>