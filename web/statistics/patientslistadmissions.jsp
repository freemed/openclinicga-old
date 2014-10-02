<%@page errorPage="/includes/error.jsp"%>
<%@ page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
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
	String sql = "select personid,firstname,lastname,dateofbirth,oc_encounter_begindate,oc_encounter_serviceuid,oc_encounter_objectid"+
				" from adminview a,oc_encounters_view b "+
				" where "+
				" a.personid=b.oc_encounter_patientuid and "+
				" oc_encounter_begindate >=? and "+
				" oc_encounter_begindate <=? and "+
				" oc_encounter_type='admission' and"+
				" oc_encounter_serviceuid like ?"+
				" order by oc_encounter_objectid";
	Hashtable insurars = new Hashtable();
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = oc_conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = ScreenHelper.parseDate(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(e.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	int counter=0;
	int encounteruid=0;
	String service="",sLastInvoice="",sColor="";
	java.util.Date activedate=null;
	StringBuffer sOut = new StringBuffer();
	sOut.append("<tr class='admin'><td colspan='1'><b>").append(getTran("web","visits",sWebLanguage)).append("</b></td><td colspan='3'><b>")
	.append(getTran("web","period",sWebLanguage)).append(": ").append(sBegin).append("- ").append(sEnd).append("</b></td></tr>");
	sOut.append("</table><table width='100%' border='0' class='sortable' id='searchresults'>");
	sOut.append("<tr><th><a href='#' class='underlined'>"+getTran("web","encounterid",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","name",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","dateofbirth",sWebLanguage)+
	"</a></th><th><a href='#' class='underlined'>"+getTran("web","date",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","service",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","assureur",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","lastinvoice",sWebLanguage)+"</a></th></tr>");
	while(rs.next()){
		java.util.Date d=rs.getDate("dateofbirth");
		java.util.Date d2=rs.getDate("oc_encounter_begindate");
		String s=checkString(rs.getString("oc_encounter_serviceuid"));
		int i = rs.getInt("oc_encounter_objectid");
		if(encounteruid!=i || !s.equalsIgnoreCase(service)){
			counter++;
			if (activedate==null){
				activedate=d2;
			}
			else if(activedate.before(d2)){
				activedate=d2;
				//sOut.append("<tr><td colspan='4'><hr/></td></tr>");
			}
			sColor="";
			java.util.Date dLastInvoice=null;
			PreparedStatement ps2=oc_conn.prepareStatement("select max(oc_patientinvoice_date) as lastinvoice from oc_patientinvoices where oc_patientinvoice_patientuid="+rs.getString("personid"));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				dLastInvoice=rs2.getDate("lastinvoice");
			}
			rs2.close();
			ps2.close();
			String sInsurar="";
			ps2=oc_conn.prepareStatement("select max(b.oc_insurar_name) as insurarname from oc_insurances a,oc_insurars b where b.oc_insurar_objectid=replace(a.oc_insurance_insuraruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_insurance_patientuid="+rs.getString("personid")+" and (oc_insurance_stop is null or oc_insurance_stop>?)");
			ps2.setDate(1,new java.sql.Date(new java.util.Date().getTime()));
			rs2 = ps2.executeQuery();
			if(rs2.next()){
				sInsurar=checkString(rs2.getString("insurarname"));
			}
			rs2.close();
			ps2.close();
			if(dLastInvoice!=null){
				sLastInvoice=ScreenHelper.stdDateFormat.format(dLastInvoice);
				if(d2!=null && d2.after(dLastInvoice)){
					sColor=" color='red' ";
				}
			}
			else {
				sLastInvoice="-";
			}
			sOut.append("<tr  onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts=").append(getTs()).append("&PersonID=").append(rs.getString("personid")).append("\";' class='list1' ><td>#"+i).append("</td><td>"+rs.getString("lastname")).append("").append(rs.getString("firstname")).append("</td><td>").append((d==null?"":ScreenHelper.stdDateFormat.format(d))).append("</td><td>")
			.append((d2==null?"":ScreenHelper.stdDateFormat.format(d2))).append("</td><td>"+getTranNoLink("service",s,sWebLanguage)).append("</td><td>"+sInsurar).append("</td><td><font "+sColor+">"+sLastInvoice).append("</font></td></tr>");
		}
		service=s;
		encounteruid=i;
	}
	sOut.append("</table><table><tr><td colspan='4'><b>").append(getTran("web","totalpatients",sWebLanguage)).append(": ").append(counter).append("</b></td></tr></table>");
	rs.close();
	ps.close();
	oc_conn.close();
	out.println(sOut);
%>
</table>
