<%@ page import="java.awt.image.*,java.awt.geom.*,java.awt.*,javax.imageio.*,java.util.*,java.io.*,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	InsuranceRule rule = Prestation.getInsuranceRule("1.0", "1.0");
	boolean bReached = Prestation.checkMaximumReached(activePatient.personid, rule,5);
%>
Maximum reached = <%=bReached%>