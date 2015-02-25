<%@ page import="be.mxs.common.util.system.*,java.awt.image.*,java.awt.geom.*,java.awt.*,javax.imageio.*,java.util.*,java.io.*,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("select personid from admin");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String personid = rs.getString("personid");
		AdminPerson person = AdminPerson.getAdminPerson(personid);
		Encounter firstEncounter = Encounter.getFirstEncounter(personid);
		java.util.Date cd = person.getCreationDate();
		if(cd==null && firstEncounter!=null && firstEncounter.getBegin()!=null){
        	AccessLog.insert(activeUser.userid,"C."+personid,firstEncounter.getBegin());
		}
		else if(firstEncounter!=null && firstEncounter.getBegin()!=null && cd.after(firstEncounter.getBegin())){
			person.setCreationDate(firstEncounter.getBegin());
		}
	}

%>
