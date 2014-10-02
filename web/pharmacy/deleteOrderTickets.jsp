<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFOrderTicketsGenerator"%>

<%
    String sOrderUids = checkString(request.getParameter("OrderUids"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************** pharmacy/deleteOderTickets.jsp *******************");
		Debug.println("sOrderUids : "+sOrderUids+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = null;
	
	StringTokenizer tokenizer = new StringTokenizer(sOrderUids,"$");
	String orderIdentifier;
	
	while(tokenizer.hasMoreTokens()){
	    orderIdentifier = tokenizer.nextToken();
	    
	    if(orderIdentifier.split("£").length>=1){
	        String orderUid = orderIdentifier.split("£")[0];
			ps = conn.prepareStatement("delete from OC_PRODUCTORDERS where OC_ORDER_OBJECTID=?");
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