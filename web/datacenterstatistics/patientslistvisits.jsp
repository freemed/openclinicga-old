<%@page errorPage="/includes/error.jsp"%>
<%@ page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE %>
<table width='100%' border='0'>
<%
    String sBegin = request.getParameter("start");
    if(sBegin==null){
        sBegin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String sEnd = request.getParameter("end");
    if(sEnd==null){
        sEnd="31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }

    String sql = "select firstname,lastname,dateofbirth,oc_begindate,oc_serviceuid,oc_encounteruid,personid,oc_insurar"+
				" from adminview a,UPDATESTATS1 b"+
				" where "+
				" a.personid=b.oc_patientuid and "+
				" oc_begindate >=? and "+
				" oc_begindate <=? and "+
				" oc_type='visit' and "+
				" oc_serviceuid like ?"+
				" order by oc_encounteruid";
	Hashtable insurars = new Hashtable();
	PreparedStatement ps = MedwanQuery.getInstance().getStatsConnection().prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = ScreenHelper.parseDate(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(e.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	int counter=0;
	int encounteruid=0;
	String service="";
	java.util.Date activedate=null;
	StringBuffer sOut = new StringBuffer();
	sOut.append("<tr class='admin'><td colspan='1'><b>").append(getTran("web","visits",sWebLanguage)).append("</b></td><td colspan='3'><b>")
			.append(getTran("web","period",sWebLanguage)).append(": ").append(sBegin).append("- ").append(sEnd).append("</b></td></tr>");
	sOut.append("</table><table width='100%' border='0' class='sortable' id='searchresults'>");
	sOut.append("<tr><th><a href='#' class='underlined'>"+getTran("web","encounterid",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","name",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","dateofbirth",sWebLanguage)+
			"</a></th><th><a href='#' class='underlined'>"+getTran("web","date",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","service",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","assureur",sWebLanguage)+"</a></th></tr>");
	while(rs.next()){
		java.util.Date d=rs.getDate("dateofbirth");
		java.util.Date d2=rs.getDate("oc_begindate");
		String s=checkString(rs.getString("oc_serviceuid"));
		int i = Integer.parseInt(rs.getString("oc_encounteruid").split("\\.")[1]);
		if(encounteruid!=i || !s.equalsIgnoreCase(service)){
			counter++;
			if (activedate==null){
				activedate=d2;
			}
			else if(activedate.before(d2)){
				activedate=d2;
				//sOut.append("<tr><td colspan='4'><hr/></td></tr>");
			}
			String sInsurar=rs.getString("OC_INSURAR");
			sOut.append("<tr  onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts=").append(getTs()).append("&PersonID=").append(rs.getString("personid")).append("\";' class='list1' ><td>#"+i).append("</td><td>"+rs.getString("lastname")).append("").append(rs.getString("firstname")).append("</td><td>").append((d==null?"":ScreenHelper.stdDateFormat.format(d))).append("</td><td>")
			.append((d2==null?"":ScreenHelper.stdDateFormat.format(d2))).append("</td><td>"+getTranNoLink("service",s,sWebLanguage)).append("</td><td>"+sInsurar).append("</td></tr>");
		}
		service=s;
		encounteruid=i;
	}
	sOut.append("</table><table><tr><td colspan='4'><b>").append(getTran("web","totalpatients",sWebLanguage)).append(": ").append(counter).append("</b></td></tr></table>");
	rs.close();
	ps.close();
	out.println(sOut);
%>
</table>
