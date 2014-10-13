<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE %>

<%
    String sBegin = checkString(request.getParameter("start"));
    if(sBegin.length()==0){
        sBegin = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    
    String sEnd = checkString(request.getParameter("end"));
    if(sEnd.length()==0){
        //sEnd = ScreenHelper.stdDateFormat.format(new java.util.Date()); // now
        
	    if(ScreenHelper.stdDateFormat.toPattern().equals("dd/MM/yyyy")){
            sEnd = "31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
	    }
	    else{
            sEnd = "12/31/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
	    }
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************ datacenterstatistics/patientslistadmissions.jsp ***********");
    	Debug.println("sBegin : "+sBegin);
    	Debug.println("sEnd   : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    

    String sql = "select firstname,lastname,dateofbirth,oc_begindate,oc_serviceuid,oc_encounteruid,personid,oc_insurar"+
				 " from adminview a, UPDATESTATS1 b"+
				 "  where a.personid = b.oc_patientuid"+
				 "   and oc_begindate >= ?"+
				 "   and oc_begindate <= ?"+
				 "   and oc_type='admission'"+
				 "   and oc_serviceuid like ?"+
				 " order by oc_encounteruid";
	Hashtable insurars = new Hashtable();
	Connection conn = MedwanQuery.getInstance().getStatsConnection();
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = ScreenHelper.parseDate(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(e.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	int counter = 0;
	int encounteruid = 0;
	String service = "";
	java.util.Date activedate = null;
	
	StringBuffer sOut = new StringBuffer();
	sOut.append("<table width='100%' class='list' cellpadding='0' cellspacing='1'>")
	     .append("<tr class='admin'>")
	      .append("<td colspan='1'><b>").append(getTran("web","admissions",sWebLanguage)).append("</b></td>")
	      .append("<td colspan='3'><b>").append(getTran("web","period",sWebLanguage)).append(": ").append(sBegin).append("- ").append(sEnd).append("</b></td>")
	    .append("</tr>")
	    .append("</table>");
	
	sOut.append("<table width='100%' border='0' class='sortable' id='searchresults'>")
         .append("<tr>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","encounterid",sWebLanguage)+"</a></td>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","name",sWebLanguage)+"</a></td>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","dateofbirth",sWebLanguage)+"</a></td>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","date",sWebLanguage)+"</a></td>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","service",sWebLanguage)+"</a></td>")
          .append("<td><a href='#' class='underlined'>"+getTran("web","assureur",sWebLanguage)+"</a></td>")
         .append("</tr>");
	
	while(rs.next()){
		java.util.Date d1 = rs.getDate("dateofbirth"),
		               d2 = rs.getDate("oc_begindate");
		String s = checkString(rs.getString("oc_serviceuid"));
		int i = Integer.parseInt(rs.getString("oc_encounteruid").split("\\.")[1]);
		if(encounteruid!=i || !s.equalsIgnoreCase(service)){
			counter++;
			
			if(activedate==null){
				activedate = d2;
			}
			else if(activedate.before(d2)){
				activedate = d2;
			}
			
			String sInsurar = rs.getString("OC_INSURAR");
			sOut.append("<tr onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts=").append(getTs()).append("&PersonID=").append(rs.getString("personid")).append("\";' class='list1'>")
			     .append("<td>#"+i).append("</td>")
			     .append("<td>"+rs.getString("lastname")).append(rs.getString("firstname")).append("</td>")
			     .append("<td>").append((d1==null?"":ScreenHelper.stdDateFormat.format(d1))).append("</td>")
			     .append("<td>").append((d2==null?"":ScreenHelper.stdDateFormat.format(d2))).append("</td>")
			     .append("<td>"+getTranNoLink("service",s,sWebLanguage)).append("</td>")
			     .append("<td>"+sInsurar).append("</td>")
			    .append("</tr>");
		}
		service = s;
		encounteruid = i;
	}
	sOut.append("</table>");
	
	rs.close();
	ps.close();
	conn.close();
	
	// total
	sOut.append("<table>")
	     .append("<tr>")
	      .append("<td colspan='6'><b>").append(getTran("web","totalpatients",sWebLanguage)).append(": ").append(counter).append("</b></td>")
	     .append("</tr>")
	    .append("</table>");
	
	out.print(sOut);
%>