<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.*,be.mxs.common.util.db.*,be.openclinic.datacenter.DatacenterHelper" %>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFAMCPatientCardsGenerator"%>
<%@page errorPage="/includes/error.jsp"%>
<%
		StringBuffer recordsProcessed = new StringBuffer();
		Enumeration pars = request.getParameterNames();
		String parameter="";
		while(pars.hasMoreElements()){
			parameter=(String)pars.nextElement();
			if(parameter.startsWith("cbp.")){
				DatacenterHelper.setPatientRecordProcessed(parameter.substring(4));
			}
		}
%>
<script>
	window.opener.location.reload();
	window.close();
</script>