<%@page import="org.jnp.interfaces.java.javaURLContextFactory"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

    boolean showDetails = (checkString(request.getParameter("showDetails")).equals("true"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************** statistics/incomeVentilationPerformers.jsp **************");
		Debug.println("sStart      : "+sStart);
		Debug.println("sEnd        : "+sEnd);
		Debug.println("showDetails : "+showDetails+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	java.util.Date start = ScreenHelper.parseDate(sStart+" 00:00"),
	               end   = ScreenHelper.parseDate(sEnd+" 23:59");
	
	String sTitle = getTranNoLink("Web","statistics.incomeVentilationPerPerformer",sWebLanguage)+": <i>"+sStart+" "+getTran("web","to",sWebLanguage)+" "+sEnd+"</i>";
%>

<form name="transactionForm" method="post">
    <%=writeTableHeaderDirectText(sTitle,sWebLanguage," window.close()")%>

	<table width="100%" class="sortable" id="searchresults" cellspacing="1" bottomRowCount="1" cellpadding="0">
<%
    String sServerId = MedwanQuery.getInstance().getConfigString("serverId");
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery = "select d.lastname, d.firstname, d.dateofbirth, b.OC_DEBETFEE_PERFORMERUID, a.OC_DEBET_DATE,"+
	                "  a.OC_DEBET_PRESTATIONUID, e.OC_PRESTATION_DESCRIPTION, a.OC_DEBET_AMOUNT+a.OC_DEBET_INSURARAMOUNT+a.OC_DEBET_EXTRAINSURARAMOUNT total, b.*"+
        			" from OC_DEBETS a, OC_DEBETFEES b, OC_ENCOUNTERS c, AdminView d, OC_PRESTATIONS e"+  
			        "  where a.OC_DEBET_OBJECTID = replace(b.OC_DEBETFEE_DEBETUID,'"+sServerId+".','')"+
			        "   and a.OC_DEBET_DATE>=? and a.OC_DEBET_DATE<=?"+
			        "   and c.OC_ENCOUNTER_OBJECTID = replace(a.OC_DEBET_ENCOUNTERUID,'"+sServerId+".','')"+
          	        "   and c.OC_ENCOUNTER_PATIENTUID = d.personid"+
			        "   and e.OC_PRESTATION_OBJECTID = replace(a.OC_DEBET_PRESTATIONUID,'"+sServerId+".','')"+
			        " order by b.OC_DEBETFEE_PERFORMERUID, a.OC_DEBET_DATE";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
	ResultSet rs = ps.executeQuery();
	String s, reason, activeuser = "", u;
	String[] r;
	double useramount = 0, a = 0;
	java.sql.Date debetDate, dateofbirth;
	String feeReason;
	int recordCount = 0;
	DecimalFormat deci = new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
	
	while(rs.next()){
		if(recordCount==0){
			// header for details
		    if(!showDetails){
		        %>
				<tr>
				    <td colspan="7" class="admin2">
				        <input type="checkbox" class="hand" name="showDetails" id="rDetails" value="true" onClick="transactionForm.submit();"><%=getLabel("web","showDetails",sWebLanguage,"rDetails")%>
				    </td>
				</tr>
				<%
            }
		    else{			            
		        %>
				<tr>
				    <td colspan="7" class="admin2">
		                <input type="checkbox" class="hand" name="showDetails" id="rDetails" checked value="false" onClick="transactionForm.submit();"><%=getLabel("web","showDetails",sWebLanguage,"rDetails")%></a>
		            </td>
                </tr>
				<tr class="gray">
					<td width="90"><%=getTran("web","date",sWebLanguage)%>&nbsp;</td>
					<td width="180"><%=getTran("web","patient",sWebLanguage)%>&nbsp;</td>
					<td width="90"><%=getTran("web","dateofbirth",sWebLanguage)%>&nbsp;</td>
					<td width="140"><%=getTran("web","prestation",sWebLanguage)%>&nbsp;</td>
					<td width="80"><%=getTran("web","price",sWebLanguage)%>&nbsp;</td>
					<td width="90"><%=getTran("web","careproviderfee",sWebLanguage)%>&nbsp;</td>
					<td width="*"><%=getTran("web","reason",sWebLanguage)%>&nbsp;</td>
				</tr>		           
		        <%
		    }
		}
		
		u = rs.getString("OC_DEBETFEE_PERFORMERUID");
		recordCount++;
		
		if(activeuser.length()>0 && !u.equalsIgnoreCase(activeuser)){
			User user = User.get(Integer.parseInt(activeuser));
			s = "<tr class='admin'>"+
			     "<td colspan='5'>"+getTran("web","totalfor",sWebLanguage)+" "+user.person.lastname.toUpperCase()+", "+user.person.firstname+"</td>"+
			     "<td colspan='2'>"+deci.format(useramount)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
			    "</tr>"+
			    "<tr><td colspan='7'><hr/></td></tr>";
			out.print(s);
			useramount = 0;
		}
		
		activeuser = u;
		debetDate = rs.getDate("OC_DEBET_DATE");
		s = "<tr><td class='admin'>"+(debetDate==null?"":ScreenHelper.stdDateFormat.format(debetDate))+"</td>";
		s+= "<td class='admin2'>"+rs.getString("lastname").toUpperCase()+", "+rs.getString("firstname")+"</td>";
		dateofbirth = rs.getDate("dateofbirth");
		s+= "<td class='admin2'>°"+(dateofbirth==null?"":ScreenHelper.stdDateFormat.format(dateofbirth))+"</td>";
		s+= "<td class='admin2'>"+rs.getString("OC_PRESTATION_DESCRIPTION")+"</td>";
		s+= "<td class='admin2'>"+deci.format(rs.getFloat("total"))+"</td>";
		a = rs.getFloat("OC_DEBETFEE_AMOUNT");
		useramount+= a;
		s+= "<td class='admin2'>"+deci.format(a)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>";
		r = checkString(rs.getString("OC_DEBETFEE_REASON")).split(";");
		reason = "";
		if(r[0].equalsIgnoreCase("0")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage);
			if(r.length > 1){
				User originalUser = User.get(Integer.parseInt(r[1]));
				reason+=" ("+getTran("web","redirected.to",sWebLanguage)+": <b>"+originalUser.person.lastname.toUpperCase()+", "+originalUser.person.firstname+"</b>)";
			}
		}
		else if(r[0].equalsIgnoreCase("1")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+rs.getString("OC_DEBETFEE_CALCULATION");
			if(r.length > 1){
				User originalUser = User.get(Integer.parseInt(r[1]));
				reason+=" - "+getTran("web","encoded.for",sWebLanguage)+": <b>"+originalUser.person.lastname.toUpperCase()+", "+originalUser.person.firstname+"</b>";
			}
			reason+= ")";
		}
		else if(r[0].equalsIgnoreCase("2")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+getTran("prestation.type",r[1],sWebLanguage)+" - "+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("3")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+r[1]+" - "+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("4")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage)+" ("+rs.getString("OC_DEBETFEE_CALCULATION")+")";
		}
		else if(r[0].equalsIgnoreCase("5")){
			reason = getTran("careproviderfee.reasons",r[0],sWebLanguage);
		}

		s+=  "<td class='admin2'>"+reason+"</td>"+
		    "</tr>";
		
		if(showDetails) out.print(s);
	}
	
	if(activeuser.length() > 0){
		User user = User.get(Integer.parseInt(activeuser));
		s = "<tr class='admin'>"+
		     "<td colspan='5'>"+getTran("web","totalfor",sWebLanguage)+" "+user.person.lastname.toUpperCase()+", "+user.person.firstname+"</td>"+
		     "<td colspan='2'>"+deci.format(useramount)+" "+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
		    "</tr>"+
		    "<tr><td colspan='7'><hr/></td></tr>";
		out.print(s);
	}
%>
</table>
    
<%
	if(recordCount > 0){
		%><%=recordCount%> <%=getTran("web","recordsFound",sWebLanguage)%><%
	}
	else{
		%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>
</form>