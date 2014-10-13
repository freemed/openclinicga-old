<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","select",activeUser)%>

<%
	String sResult="";
	long day = 24*3600*1000;
	long period = day * MedwanQuery.getInstance().getConfigInt("spoolnotifiermessagesfordays",7);
	String start=ScreenHelper.stdDateFormat.format(new java.util.Date(new java.util.Date().getTime()-period));
	if(request.getParameter("submit")!=null){
		start=checkString(request.getParameter("start"));
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from OC_NOTIFIER where oc_notifier_createdatetime>? and oc_notifier_sentdatetime is null order by oc_notifier_createdatetime");
		ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(start).getTime()));
		ResultSet rs = ps.executeQuery();
		sResult+="<table width='50%'>";
		sResult+="<tr class='admin'><td>"+getTran("web","date",sWebLanguage)+"</td><td>"+getTran("web","patient",sWebLanguage)+"</td><td>"+getTran("web","type",sWebLanguage)+"</td><td>"+getTran("web","destination",sWebLanguage)+"</td></tr>";
		while (rs.next()){
			int transactionId=rs.getInt("OC_NOTIFIER_TRANSACTIONID");
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), transactionId);
			if(transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+transactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), transactionId);
			}
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			String sPatientFirstname = patient.firstname;
			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			String sPatientLastname = patient.lastname.toUpperCase();
			String sCreated = ScreenHelper.fullDateFormatSS.format(rs.getTimestamp("OC_NOTIFIER_CREATEDATETIME"));

			sResult+="<tr class='gray'><td>"+sCreated+"</td><td>"+sPatientLastname+","+sPatientFirstname+"</td><td>"+rs.getString("oc_notifier_transport")+"</td><td>"+rs.getString("oc_notifier_sentto")+"</td></tr>";
		}
		rs.close();
		sResult+="</table>";
		ps.close();
		conn.close();
	}
%>
<form name="transactionForm" method="post">
	<table>
		<tr>
			<td><%=getTran("web","messagessince",sWebLanguage)%></td>
			<td><%=writeDateField("start","transactionForm",start,sWebLanguage)%></td>
			<td><input type='submit' name='submit' value='<%=getTranNoLink("web","find",sWebLanguage)%>'/></td>
		</tr>
	</table>
</form>

<%=sResult%>