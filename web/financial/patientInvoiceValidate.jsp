<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.text.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String invoiceuid = request.getParameter("EditInvoiceUID");
	PatientInvoice invoice = PatientInvoice.get(invoiceuid);
	if(invoice!=null){
		invoice.setAcceptationUid(activeUser.userid);
		invoice.store();
	}
%>