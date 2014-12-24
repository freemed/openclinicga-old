<%@ page import="be.openclinic.finance.Wicket,be.openclinic.finance.WicketCredit,java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran("web","version",sWebLanguage)%></td>
		<td><%=getTran("web","updatetime",sWebLanguage)%></td>
		<td><%=getTran("web","wicket",sWebLanguage)%></td>
		<td><%=getTran("web","amount",sWebLanguage)%></td>
		<td><%=getTran("web","type",sWebLanguage)%></td>
		<td><%=getTran("web","comment",sWebLanguage)%></td>
		<td><%=getTran("web","user",sWebLanguage)%></td>
	</tr>
<%
	WicketCredit credit = WicketCredit.get(request.getParameter("uid"));
	out.println("<tr>");
	out.println("<td class='admin'>"+credit.getVersion()+"</td>");
	out.println("<td class='admin'>"+ScreenHelper.getSQLTimeStamp(new java.sql.Timestamp(credit.getUpdateDateTime().getTime()))+"</td>");
	out.println("<td class='admin'>"+Wicket.getWicketName(credit.getWicketUID())+"</td>");
	out.println("<td class='admin'>"+credit.getAmount()+"</td>");
	out.println("<td class='admin'>"+getTranNoLink("credit.type",credit.getOperationType(),sWebLanguage)+"</td>");
	out.println("<td class='admin'>"+credit.getComment()+"</td>");
	out.println("<td class='admin'>"+User.getFullUserName(credit.getUpdateUser())+"</td>");
	out.println("</tr>");
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_wicket_credits_history where oc_wicket_credit_serverid=? and oc_wicket_credit_objectid=? order by oc_wicket_credit_version desc");
	ps.setInt(1,Integer.parseInt(request.getParameter("uid").split("\\.")[0]));
	ps.setInt(2,Integer.parseInt(request.getParameter("uid").split("\\.")[1]));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		out.println("<tr>");
		out.println("<td class='admin2'>"+rs.getInt("oc_wicket_credit_version")+"</td>");
		out.println("<td class='admin2'>"+ScreenHelper.getSQLTimeStamp(rs.getTimestamp("oc_wicket_credit_updatetime"))+"</td>");
		out.println("<td class='admin2'>"+Wicket.getWicketName(rs.getString("oc_wicket_credit_wicketuid"))+"</td>");
		out.println("<td class='admin2'>"+rs.getDouble("oc_wicket_credit_amount")+"</td>");
		out.println("<td class='admin2'>"+getTranNoLink("credit.type",rs.getString("oc_wicket_credit_type"),sWebLanguage)+"</td>");
		out.println("<td class='admin2'>"+rs.getString("oc_wicket_credit_comment")+"</td>");
		out.println("<td class='admin2'>"+User.getFullUserName(rs.getString("oc_wicket_credit_updateuid"))+"</td>");
		out.println("</tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>