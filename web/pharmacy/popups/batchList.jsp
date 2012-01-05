<%@ page import="be.openclinic.pharmacy.ServiceStock,
                 be.openclinic.pharmacy.Batch,
                 java.util.Vector,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.pharmacy.ProductStock" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<form name="transactionForm" id="transactionForm" method="post">
	<%
		String productStockUid=checkString(request.getParameter("EditProductStockUid"));
		ProductStock productStock=ProductStock.get(productStockUid);
		Vector batches = Batch.getAllBatches(productStockUid);
		StringBuffer sActiveBatches = new StringBuffer();
		StringBuffer sExpiredBatches = new StringBuffer();
		StringBuffer sUsedBatches = new StringBuffer();
		int totalStock=productStock.getLevel();
		int totalActive=0;
		int totalUsed=0;
		int totalExpired=0;
		for(int n=0;n<batches.size();n++){
			Batch batch = (Batch)batches.elementAt(n);
			if(batch.getLevel()>0 && (batch.getEnd()==null || !batch.getEnd().before(new java.util.Date()))){
				sActiveBatches.append("<tr><td class='admin2'><a href='javascript:showBatchOperations("+batch.getUid()+");'>"+batch.getBatchNumber()+"</a></td><td class='admin2right'>"+batch.getLevel()+"</td><td class='admin2'>"+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+"</td><td class='admin2'>"+batch.getComment()+"</td></tr>");
				totalActive+=batch.getLevel();
			}
			else if(batch.getLevel()<=0){
				sUsedBatches.append("<tr><td class='admin2'><a href='javascript:showBatchOperations("+batch.getUid()+");'>"+batch.getBatchNumber()+"</a></td><td class='admin2right'>"+batch.getLevel()+"</td><td class='admin2'>"+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+"</td><td class='admin2'>"+batch.getComment()+"</td></tr>");
				totalUsed+=batch.getLevel();
			}
			else {
				sExpiredBatches.append("<tr><td class='admin2'><a href='javascript:showBatchOperations("+batch.getUid()+");'>"+batch.getBatchNumber()+"</a></td><td class='admin2right'>"+batch.getLevel()+"</td><td class='admin2'>"+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+"</td><td class='admin2'>"+batch.getComment()+"</td></tr>");
				totalExpired+=batch.getLevel();
			}
			totalStock-=batch.getLevel();
		}
		if(totalActive>0){
			out.println(getTran("web","active.batches",sWebLanguage)+":");
			out.println("<table width='100%'><tr class='admin'><th>"+getTran("web","batchnumber",sWebLanguage)+"</th><th>"+getTran("web","level",sWebLanguage)+"</th><th>"+
					getTran("web","expires",sWebLanguage)+"</th><th>"+getTran("web","comment",sWebLanguage)+"</th></tr>");
			out.println(sActiveBatches.toString());
			out.println("<tr><td class='admin2'><i>?</i></td><td class='admin2right'><i>"+totalStock+"</i></td></tr>");
			out.println("<tr><td>"+getTran("web","total",sWebLanguage)+"</td><td class='admin2right'><b>"+(totalActive+totalStock)+"</b></td></tr>");
			out.println("</table><hr/>");
		}
		if(sExpiredBatches.length()>0){
			out.println(getTran("web","expired.batches",sWebLanguage)+":");
			out.println("<table width='100%'><tr class='admin'><th>"+getTran("web","batchnumber",sWebLanguage)+"</th><th>"+getTran("web","level",sWebLanguage)+"</th><th>"+
					getTran("web","expires",sWebLanguage)+"</th><th>"+getTran("web","comment",sWebLanguage)+"</th></tr>");
			out.println(sExpiredBatches.toString());
			out.println("<tr><td>"+getTran("web","total",sWebLanguage)+"</td><td class='admin2right'><b>"+totalExpired+"</b></td></tr>");
			out.println("</table><hr/>");
		}
		if(request.getParameter("showused")!=null && sUsedBatches.length()>0){
			out.println(getTran("web","used.batches",sWebLanguage)+":");
			out.println("<table width='100%'><tr class='admin'><th>"+getTran("web","batchnumber",sWebLanguage)+"</th><th>"+getTran("web","level",sWebLanguage)+"</th><th>"+
					getTran("web","expires",sWebLanguage)+"</th><th>"+getTran("web","comment",sWebLanguage)+"</th></tr>");
			out.println(sUsedBatches.toString());
			if(totalUsed!=0){
				out.println("<tr><td>"+getTran("web","total",sWebLanguage)+"</td><td class='admin2right'><b>"+totalUsed+"</b></td></tr>");
			}
			out.println("</table><hr/>");
		}
		else if (sUsedBatches.length()>0){
			out.println("<a href='javascript:showUsedBatches();'/>"+getTran("web","show.used",sWebLanguage)+"</a>");
		}
	%>
	<input type='hidden' name='showused' id='showused' value=''/>	
</form>
<script>
	function showUsedBatches(){
		document.getElementById("showused").value="true";
		document.getElementById("transactionForm").submit();
	}

	function showBatchOperations(batchUid){
	    openPopup("pharmacy/popups/batchOperationList.jsp&batchUid="+batchUid+"&productStockUid=<%=productStockUid%>&ts=<%=getTs()%>",800,400);
	}
</script>