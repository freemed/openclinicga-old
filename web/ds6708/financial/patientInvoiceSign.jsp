<%@ page import="be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String invoiceuid = request.getParameter("EditInvoiceUID");
	Pointer.storeUniquePointer("INVSIGN."+invoiceuid, activeUser.person.lastname.toUpperCase()+" "+activeUser.person.firstname+" ("+activeUser.userid+")", new java.util.Date());
%>