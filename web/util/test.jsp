<%@ page import="be.mxs.common.util.system.*,java.awt.image.*,java.awt.geom.*,java.awt.*,javax.imageio.*,java.util.*,java.io.*,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Hashtable parameters = new Hashtable();
	parameters.put("@par@", "100.0");
%>

<%= Evaluate.evaluate("5+log10(@par@)", parameters)%>