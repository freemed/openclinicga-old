<%@page errorPage="/includes/error.jsp"%>
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
	String sql = "select firstname,lastname,dateofbirth,oc_encounter_begindate,oc_encounter_serviceuid,oc_encounter_objectid,personid,"+
				"(select max(oc_insurar_name) from oc_insurars c,oc_insurances d where d.oc_insurance_patientuid=a.personid and c.oc_insurar_objectid=replace(d.oc_insurance_insuraruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')) as insurar"+
				" from adminview a,oc_encounters_view b "+
				" where "+
				" a.personid=b.oc_encounter_patientuid and "+
				" oc_encounter_begindate >=? and "+
				" oc_encounter_begindate <=? and "+
				" oc_encounter_serviceuid like ? and"+
				" oc_encounter_type='visit'"+
				" order by oc_encounter_serviceuid,insurar";
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = oc_conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = new SimpleDateFormat("dd/MM/yyyy").parse(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(e.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	int counter=0;
	int encounteruid=0;
	String service="";
	java.util.Date activedate=null;
	out.println("<tr class='admin'><td colspan='1'><b>"+getTran("web","visits",sWebLanguage)+"</b></td><td colspan='4'><b>"+
			getTran("web","period",sWebLanguage)+": "+sBegin+" - "+sEnd+"</b></td></tr>");
	while(rs.next()){
		java.util.Date d=rs.getDate("dateofbirth");
		java.util.Date d2=rs.getDate("oc_encounter_begindate");
		String s=checkString(rs.getString("oc_encounter_serviceuid"));
		String insurar = checkString(rs.getString("insurar"));
		int i = rs.getInt("oc_encounter_objectid");
		if(encounteruid!=i || !s.equalsIgnoreCase(service)){
			counter++;
			if (activedate==null){
				activedate=d2;
			}
			else if(activedate.before(d2)){
				activedate=d2;
				out.println("<tr><td colspan='4'><hr/></td></tr>");
			}
			out.println("<tr  onClick='window.location.href=\"main.do?Page=curative/index.jsp&ts="+getTs()+"&PersonID="+rs.getInt("personid")+"\";' class='list1' ><td>#"+i+": "+rs.getString("lastname")+" "+rs.getString("firstname")+"</td><td>"+(d==null?"":new SimpleDateFormat("dd/MM/yyyy").format(d))+"</td><td>"+
					(d2==null?"":new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("oc_encounter_begindate")))+"</td><td>"+getTranNoLink("service",s,sWebLanguage)+"</td><td>"+insurar+"</td></tr>");
		}
		service=s;
		encounteruid=i;
	}
	out.println("<tr><td colspan='5'><hr/></td></tr>");
	out.println("<tr><td colspan='5'><b>"+getTran("web","totalpatients",sWebLanguage)+": "+counter+"</b></td></tr>");
	rs.close();
	ps.close();
	oc_conn.close();
%>
</table>
