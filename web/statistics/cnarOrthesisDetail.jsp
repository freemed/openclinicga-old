<%@page import="sun.print.resources.serviceui"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%!
	class Equipment{
		int	male;
		int female;
		int i0to5;
		int i5to15;
		int i15plus;
	}
%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	
	java.util.Date dBegin = ScreenHelper.parseDate(begin);
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(end).getTime()+24*3600*1000-1);
	
	Hashtable prestations = new Hashtable();
	Hashtable groups = new Hashtable();
	String group;
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total,oc_prestation_objectid,oc_prestation_invoicegroup from oc_debets d,oc_encounters e, oc_prestations p where p.oc_prestation_objectid=replace(d.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and e.oc_encounter_objectid=replace(d.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarOrthopedicEquipment","orth")+"' and d.oc_debet_date>=? and d.oc_debet_date<=? group by oc_prestation_objectid,oc_prestation_invoicegroup";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(dBegin.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(dEnd.getTime()));
	ResultSet rs = ps.executeQuery();
	int total = 0;
	int prestationobjectid=0;
	while(rs.next()){
		total = rs.getInt("total");
		prestationobjectid=rs.getInt("oc_prestation_objectid");
		group=rs.getString("oc_prestation_invoicegroup");
		if(groups.get(group)==null){
			groups.put(group,0);
		}
		groups.put(group,(Integer)groups.get(group)+total);
		prestations.put(prestationobjectid,total);
	}
	rs.close();
	ps.close();
	
	sQuery="select * from oc_prestations where oc_prestation_class='"+MedwanQuery.getInstance().getConfigString("cnarOrthopedicEquipment","orth")+"' order by oc_prestation_invoicegroup,oc_prestation_description";
	ps = conn.prepareStatement(sQuery);
	rs = ps.executeQuery();
	%>
	<table width="100%">
		<tr class='admin'><td colspan='2'><%=getTran("cnar","statistics.ortho.equipment.detail",sWebLanguage)%></td></tr>
		<%
			String activegroup="";
			while(rs.next()){
				group = rs.getString("oc_prestation_invoicegroup");
				String description = rs.getString("oc_prestation_description");
				prestationobjectid=rs.getInt("oc_prestation_objectid");
				if(!group.equalsIgnoreCase(activegroup)){
					out.println("<tr class='admin'><td>"+getTran("cnar.equipmentgroup",group,sWebLanguage)+"</td><td>"+(groups.get(group)!=null?groups.get(group):0)+"</td></tr>");
					activegroup=group;
				}
				out.println("<tr><td  class='admin'>"+description+"</td><td  class='admin'>"+(prestations.get(prestationobjectid)==null?"0":prestations.get(prestationobjectid))+"</td></tr>");
			}
			
		%>
	</table>
	<%
	rs.close();
	ps.close();
	conn.close();
%>