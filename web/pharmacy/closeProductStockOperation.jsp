<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String operationuid = checkString(request.getParameter("operationuid"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n**************** pharmacy/closeProductStockOperation.jsp **************");
		Debug.println("operationuid : "+operationuid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("update OC_PRODUCTSTOCKOPERATIONS"+
	                                             " set OC_OPERATION_UNITSCHANGED=OC_OPERATION_UNITSRECEIVED"+
	                                             "  where OC_OPERATION_SERVERID=? and OC_OPERATION_OBJECTID=?");
	ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
	ps.setInt(2,Integer.parseInt(operationuid.split("\\.")[1]));
	ps.execute();
	ps.close();
	conn.close();
%>