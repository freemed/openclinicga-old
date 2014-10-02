<%@page import="org.jnp.interfaces.java.javaURLContextFactory"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	java.util.Date start = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("start"))+" 00:00");
	java.util.Date end = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("end"))+" 23:59");
%>
<form name="transactionForm" method="post">
<table width="100%">
	<tr class='admin'>
		<td colspan='6'><%=getTran("Web","statistics.incomeVentilationPerPerformer",sWebLanguage)+"  "+checkString(request.getParameter("start"))+" - "+checkString(request.getParameter("end")) %></td><td> 
		<%if(request.getParameter("showdetails")==null){ %>
		<input type="submit" class="button" name="showdetails" value="<%=getTranNoLink("web","showdetails",sWebLanguage)%>"/></td></tr>
		<%
		}
		else {
		%>
		<input type="submit" class="button" name="hidedetails" value="<%=getTranNoLink("web","hidedetails",sWebLanguage)%>"/></td></tr>
		<tr class='admin'>
			<td><%=getTran("web","date",sWebLanguage) %></td>
			<td><%=getTran("web","patient",sWebLanguage) %></td>
			<td><%=getTran("web","dateofbirth",sWebLanguage) %></td>
			<td><%=getTran("web","prestation",sWebLanguage) %></td>
			<td><%=getTran("web","price",sWebLanguage) %></td>
			<td><%=getTran("web","careproviderfee",sWebLanguage) %></td>
			<td><%=getTran("web","reason",sWebLanguage) %></td>
		</tr>
		<%
		}
		%>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select d.lastname,d.firstname,d.dateofbirth,b.OC_DEBETFEE_PERFORMERUID,a.OC_DEBET_DATE,a.OC_DEBET_PRESTATIONUID,e.OC_PRESTATION_DESCRIPTION,a.OC_DEBET_AMOUNT+a.OC_DEBET_INSURARAMOUNT+a.OC_DEBET_EXTRAINSURARAMOUNT total,b.* "+
			" from OC_DEBETS a,OC_DEBETFEES b,OC_ENCOUNTERS c, AdminView d,OC_PRESTATIONS e"+ 
			" where a.OC_DEBET_OBJECTID=replace(b.OC_DEBETFEE_DEBETUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and "+
			" a.OC_DEBET_DATE>=? and a.OC_DEBET_DATE<=? and "+
			" c.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and "+
			" c.OC_ENCOUNTER_PATIENTUID=d.personid and "+
			" e.OC_PRESTATION_OBJECTID=replace(a.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') "+
			"order by b.OC_DEBETFEE_PERFORMERUID,a.OC_DEBET_DATE";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	String s,reason,activeuser="",u;
	String[] r;
	double useramount=0,a=0;
	java.sql.Date debetDate,dateofbirth;
	String feeReason;
	while(rs.next()){
		u=rs.getString("OC_DEBETFEE_PERFORMERUID");
		if(activeuser.length()>0 && !u.equalsIgnoreCase(activeuser)){
			User user = User.get(Integer.parseInt(activeuser));
			s="<tr class='admin'><td colspan='5'>"+getTran("web","totalfor",sWebLanguage)+" "+user.person.lastname.toUpperCase()+", "+user.person.firstname+"</td><td colspan='2'>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(useramount)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td></tr><tr><td colspan='7'><hr/></td></tr>";
			out.println(s);
			useramount=0;
		}
		activeuser=u;
		debetDate=rs.getDate("OC_DEBET_DATE");
		s="<tr><td class='admin'>"+(debetDate==null?"":ScreenHelper.stdDateFormat.format(debetDate))+"</td>";
		s+="<td class='admin2'>"+rs.getString("lastname").toUpperCase()+", "+rs.getString("firstname")+"</td>";
		dateofbirth=rs.getDate("dateofbirth");
		s+="<td class='admin2'>°"+(dateofbirth==null?"":ScreenHelper.stdDateFormat.format(dateofbirth))+"</td>";
		s+="<td class='admin2'>"+rs.getString("OC_PRESTATION_DESCRIPTION")+"</td>";
		s+="<td class='admin2'>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(rs.getFloat("total"))+"</td>";
		a=rs.getFloat("OC_DEBETFEE_AMOUNT");
		useramount+=a;
		s+="<td class='admin2'>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(a)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>";
		r=checkString(rs.getString("OC_DEBETFEE_REASON")).split(";");
		reason="";
		if(r[0].equalsIgnoreCase("0")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage);
			if(r.length>1){
				User originalUser = User.get(Integer.parseInt(r[1]));
				reason+=" ("+getTran("web","redirected.to",sWebLanguage)+": <b>"+originalUser.person.lastname.toUpperCase()+", "+originalUser.person.firstname+"</b>)";
			}
		}
		else if(r[0].equalsIgnoreCase("1")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+rs.getString("OC_DEBETFEE_CALCULATION");
			if(r.length>1){
				User originalUser = User.get(Integer.parseInt(r[1]));
				reason+=" - "+getTran("web","encoded.for",sWebLanguage)+": <b>"+originalUser.person.lastname.toUpperCase()+", "+originalUser.person.firstname+"</b>";
			}
			reason+=")";
		}
		else if(r[0].equalsIgnoreCase("2")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+getTran("prestation.type",r[1],sWebLanguage)+" - "+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("3")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+r[1]+" - "+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("4")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("5")){
			reason=getTran("careproviderfee.reasons",r[0],sWebLanguage);
		}

		s+="<td class='admin2'>"+reason+"</td></tr>";
		if(request.getParameter("showdetails")!=null){
			out.println(s);
		}
	}
	if(activeuser.length()>0){
		User user = User.get(Integer.parseInt(activeuser));
		s="<tr class='admin'><td colspan='5'>"+getTran("web","totalfor",sWebLanguage)+" "+user.person.lastname.toUpperCase()+", "+user.person.firstname+"</td><td colspan='2'>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(useramount)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td></tr><tr><td colspan='7'><hr/></td></tr>";
		out.println(s);
	}
%>
</table>
</form>