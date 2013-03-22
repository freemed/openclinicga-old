<%@ page import="be.openclinic.finance.PatientInvoice,
                 java.util.Vector,
                 java.text.DecimalFormat,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String invid= checkString(request.getParameter("invid"));
	if(request.getParameter("submit")!=null && invid.length()>0){
		if(invid.split("\\.").length<2){
			invid="1."+invid;
		}
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from oc_patientinvoices where oc_patientinvoice_objectid=?");
		ps.setInt(1, Integer.parseInt(invid.split("\\.")[1]));
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("delete from oc_debets where oc_debet_patientinvoiceuid=?");
		ps.setString(1, invid);
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("delete from oc_wicket_credits where oc_wicket_credit_invoiceuid=?");
		ps.setString(1, invid);
		ps.execute();
		ps.close();
		conn.close();
		out.println(invid+" successfully removed</br>");
	}
%>
<form method='post'>
	ID: <input type='text' name='invid'/> <input type='submit' name='submit' value='remove'/>
</form>