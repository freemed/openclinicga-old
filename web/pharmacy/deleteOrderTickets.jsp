<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFOrderTicketsGenerator"%>

<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = null;
	String sOrderUids = checkString(request.getParameter("OrderUids"));
	StringTokenizer tokenizer = new StringTokenizer(sOrderUids,"$");
	while(tokenizer.hasMoreTokens()){
	    String orderIdentifier = tokenizer.nextToken();
	    if(orderIdentifier.split("£").length>=1){
	        String orderUid   = orderIdentifier.split("£")[0];
			ps=conn.prepareStatement("delete from OC_PRODUCTORDERS where OC_ORDER_OBJECTID=?");
			ps.setInt(1,Integer.parseInt(orderUid.split("\\.")[1]));
			ps.execute();
			ps.close();
	    }
	}
	conn.close();
%>

<script>
	window.opener.location.reload();
	window.close();
</script>