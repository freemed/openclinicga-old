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
	String sql = "select personid,firstname,lastname,dateofbirth,oc_encounter_begindate,oc_encounter_serviceuid,oc_encounter_objectid,(select max(oc_insurance_insuraruid)"+
				" from oc_insurances where oc_insurance_patientuid=a.personid and (oc_insurance_stop is null or oc_insurance_stop>?)) as oc_insurance_insuraruid"+
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
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()));
	ps.setDate(2,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = new SimpleDateFormat("dd/MM/yyyy").parse(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(3,new java.sql.Timestamp(e.getTime()));
	ps.setString(4,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	int counter=0;
	int encounteruid=0;
	String service="";
	java.util.Date activedate=null;
	StringBuffer sOut = new StringBuffer();
	sOut.append("<tr class='admin'><td colspan='1'><b>").append(getTran("web","visits",sWebLanguage)).append("</b></td><td colspan='3'><b>")
	.append(getTran("web","period",sWebLanguage)).append(": ").append(sBegin).append(" - ").append(sEnd).append("</b></td></tr>");
	sOut.append("</table><table width='100%' border='0' class='sortable' id='searchresults'>");
	sOut.append("<tr><th><a href='#' class='underlined'>"+getTran("web","encounterid",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","name",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","dateofbirth",sWebLanguage)+
	"</a></th><th><a href='#' class='underlined'>"+getTran("web","date",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","service",sWebLanguage)+"</a></th><th><a href='#' class='underlined'>"+getTran("web","assureur",sWebLanguage)+"</a></th></tr>");
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
			String sInsurar="", sInsurarUid=rs.getString("OC_INSURANCE_INSURARUID");
			if(sInsurarUid !=null){
				if(insurars.get(sInsurarUid)==null){
					Insurar insurar = Insurar.get(sInsurarUid);
					if(insurar!=null && insurar.getName()!=null){
						insurars.put(sInsurarUid,insurar.getName());
						sInsurar=(String)insurars.get(sInsurarUid);
					}
				}
				else{
					sInsurar=(String)insurars.get(sInsurarUid);
				}
			}
			sOut.append("<tr  onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts=").append(getTs()).append("&PersonID=").append(rs.getString("personid")).append("\";' class='list1' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list1';\"><td>#"+i).append("</td><td>"+rs.getString("lastname")).append(" ").append(rs.getString("firstname")).append("</td><td>").append((d==null?"":new SimpleDateFormat("dd/MM/yyyy").format(d))).append("</td><td>")
			.append((d2==null?"":new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("oc_encounter_begindate")))).append("</td><td>"+getTranNoLink("service",s,sWebLanguage)).append("</td><td>"+sInsurar).append("</td></tr>");
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
