<%@ page import="be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String listuid=checkString(request.getParameter("listuid"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps=null;
	ps=conn.prepareStatement("select * from oc_drugsoutlist where OC_LIST_PATIENTUID=? order by OC_LIST_PRODUCTSTOCKUID");
	ps.setString(1,activePatient.personid);
	ResultSet rs = ps.executeQuery();
	int count=0;
	while(rs.next()){
		//Create stock operation
		ProductStockOperation operation = new ProductStockOperation();
		operation.setUid("-1");
		operation.setBatchUid(rs.getString("OC_LIST_BATCHUID"));
		operation.setDate(new java.util.Date());
		operation.setDescription(MedwanQuery.getInstance().getConfigString("medicationDeliveryToPatientDescription","medicationdelivery.1"));
		operation.setProductStockUid(rs.getString("OC_LIST_PRODUCTSTOCKUID"));
		operation.setSourceDestination(new ObjectReference("patient",activePatient.personid));
		operation.setUnitsChanged(rs.getInt("OC_LIST_QUANTITY"));
		operation.setUpdateDateTime(new java.util.Date());
		operation.setUpdateUser(activeUser.userid);
		operation.setVersion(1);
		operation.store();
		//Delete list
		PreparedStatement ps2 = conn.prepareStatement("delete from OC_DRUGSOUTLIST where OC_LIST_SERVERID=? and OC_LIST_OBJECTID=?");
		ps2.setInt(1,rs.getInt("OC_LIST_SERVERID"));
		ps2.setInt(2,rs.getInt("OC_LIST_OBJECTID"));
		ps2.execute();
		ps2.close();
	}
	rs.close();
	ps.close();
	conn.close();
	out.print("{\"drugs\":\"\"}");
%>
