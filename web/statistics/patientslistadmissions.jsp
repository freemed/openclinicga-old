<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>

<%
    //##### ADMISSIONS #####
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end")); 
     
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** statistics/patientslistsadmissions.jsp ***************");
    	Debug.println("sStart : "+sStart);
    	Debug.println("sEnd   : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    if(sStart.length()==0){
        sStart = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }    
    if(sEnd.length()==0){
        sEnd = "31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());

    	// US-date
        if(ScreenHelper.stdDateFormat.toPattern().equals("MM/dd/yyyy")){
            sEnd = "12/31/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
        }
    }
    
	String sql = "select firstname,lastname,dateofbirth,oc_encounter_begindate,"+
	             "  oc_encounter_serviceuid,oc_encounter_objectid,personid"+
				 " from adminview a, oc_encounters_view b"+
				 "  where a.personid = b.oc_encounter_patientuid"+
				 "   and oc_encounter_begindate >= ?"+
				 "   and oc_encounter_begindate <= ?"+
				 "   and oc_encounter_type = 'admission'"+ // difference
				 "   and oc_encounter_serviceuid like ?"+
				 "  order by oc_encounter_objectid";
    Debug.println("sql : "+sql);
	Hashtable insurars = new Hashtable();
    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = oc_conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sStart).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date endDate = ScreenHelper.parseDate(sEnd);
	endDate.setTime(endDate.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(endDate.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	
	int counter = 0, encounteruid = 0;
	String service = "", sLastInvoice = "", sColor = "";
	java.util.Date activedate = null;
	
	StringBuffer sOut = new StringBuffer();

	// title
	String sTitle = getTran("Web","statistics.patientslist.admissions",sWebLanguage)+
	                " &nbsp;&nbsp;[<i>"+getTran("web","period",sWebLanguage)+": "+sStart+" - "+sEnd+"</i>]";
	sOut.append(writeTableHeaderDirectText(sTitle,sWebLanguage," window.close()"));
	
	sOut.append("<table width='100%' class='sortable' id='searchresults' cellpadding='0' cellspacing='1'>");
	
	while(rs.next()){
		java.util.Date d1 = rs.getDate("dateofbirth"),
		               d2 = rs.getDate("oc_encounter_begindate");
		
		String sServiceUid = checkString(rs.getString("oc_encounter_serviceuid"));
		int objectId = rs.getInt("oc_encounter_objectid");
		
		if(encounteruid!=objectId || !sServiceUid.equalsIgnoreCase(service)){
			if(counter==0){
		        sOut.append("<tr class='gray'>")
			         .append("<td>"+getTran("web","encounterid",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","name",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","dateofbirth",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","date",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","service",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","assureur",sWebLanguage)+"</td>"+
			                 "<td>"+getTran("web","lastinvoice",sWebLanguage)+"</td>")
			        .append("</tr>");
			}
			counter++;
			
			if(activedate==null){
				activedate = d2;
			}
			else if(activedate.before(d2)){
				activedate = d2;
			}
			
			sColor = "";
			java.util.Date dLastInvoice = null;
			PreparedStatement ps2 = oc_conn.prepareStatement("select max(oc_patientinvoice_date) as lastinvoice"+
			                                                 " from oc_patientinvoices"+
					                                         "  where oc_patientinvoice_patientuid = "+rs.getString("personid"));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				dLastInvoice = rs2.getDate("lastinvoice");
			}
			rs2.close();
			ps2.close();
			
			String sInsurar = "";
			ps2 = oc_conn.prepareStatement("select max(b.oc_insurar_name) as insurarname"+
			                               " from oc_insurances a, oc_insurars b"+
			                               "  where b.oc_insurar_objectid = replace(a.oc_insurance_insuraruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
			                               "   and oc_insurance_patientuid = "+rs.getString("personid")+
			                               "   and (oc_insurance_stop is null or oc_insurance_stop>?)");
			ps2.setDate(1,new java.sql.Date(new java.util.Date().getTime())); // now
			rs2 = ps2.executeQuery();
			if(rs2.next()){
				sInsurar = checkString(rs2.getString("insurarname"));
			}
			rs2.close();
			ps2.close();
			
			if(dLastInvoice!=null){
				sLastInvoice = ScreenHelper.stdDateFormat.format(dLastInvoice);
				if(d2!=null && d2.after(dLastInvoice)){
					sColor = " color='red' ";
				}
			}
			else{
				sLastInvoice = "-";
			}
			
			sOut.append("<tr onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts=").append(getTs()).append("&PersonID=").append(rs.getString("personid")).append("\";' class='list1'>")
			     .append("<td>#"+objectId).append("</td>")
			     .append("<td>"+rs.getString("lastname")).append(" ").append(rs.getString("firstname")).append("</td>")
			     .append("<td>").append((d1==null?"":ScreenHelper.stdDateFormat.format(d1))).append("</td>")
			     .append("<td>").append((d2==null?"":ScreenHelper.stdDateFormat.format(d2))).append("</td>")
			     .append("<td>").append(getTranNoLink("service",sServiceUid,sWebLanguage)).append("</td>")
			     .append("<td>").append(sInsurar).append("</td>")
			     .append("<td><font "+sColor+">"+sLastInvoice).append("</font></td>")
			    .append("</tr>");
			}
		
		service = sServiceUid;
		encounteruid = objectId;
	}
	
	rs.close();
	ps.close();
	oc_conn.close();
	
	sOut.append("</table>");
	
	// total patients
	if(counter > 0){
		sOut.append("<table class='list' cellpadding='0' cellspacing='1' width='100%' style='border-top:none;'>"+
		             "<tr class='gray'>"+
				      "<td colspan='6'><b>").append(getTran("web","totalpatients",sWebLanguage)).append(": ").append(counter).append("</b></td>"+
		             "</tr>"+
				    "</table>");
	}
	else{
	    sOut.append(getTran("web","noRecordsFound",sWebLanguage));	
	}
	
	out.print(sOut);
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>