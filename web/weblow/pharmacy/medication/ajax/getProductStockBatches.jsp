<%@ page import="be.openclinic.pharmacy.ServiceStock,
                 be.openclinic.pharmacy.Batch,
                 java.util.Vector,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.pharmacy.ProductStock" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	String 	destinationproductstockuid=checkString(request.getParameter("destinationproductstockuid")),
	sourceservicestockuid=checkString(request.getParameter("sourceservicestockuid"));

	ProductStock destinationProductStock = ProductStock.get(destinationproductstockuid);
	Vector sourceProductStocks = ProductStock.find(sourceservicestockuid,destinationProductStock.getProductUid(),"","","","","","","","","","OC_STOCK_OBJECTID","");
	if(sourceProductStocks.size()>0){
		ProductStock sourceProductStock = (ProductStock)sourceProductStocks.elementAt(0);
		Vector batches = Batch.getBatches(sourceProductStock.getUid());
		int totalQuantity=sourceProductStock.getLevel();
		int expired=0;
		for(int n=0;n<batches.size();n++){
			Batch batch =(Batch)batches.elementAt(n);
			if(batch.getEnd()==null || !batch.getEnd().before(new java.util.Date())){
				out.print("<input onclick='setMaxQuantityValue("+batch.getLevel()+");' type='radio' name='EditBatchUid' value='"+batch.getUid()+"' ");
				out.print((n==0?"checked":"")+"/>"+batch.getBatchNumber()+" ("+batch.getLevel()+" - exp. "+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+")<br/>");
			}
			else {
				expired+=batch.getLevel();
			}
			totalQuantity-=batch.getLevel();
		}
		if(totalQuantity>0){
			out.print("<input onclick='if(setMaxQuantityValue){setMaxQuantityValue("+totalQuantity+");}' type='radio' name='EditBatchUid' id='EditBatchUid' value='' ");
			out.print((batches.size()==0?"checked":"")+"/>? ("+totalQuantity+")<br/>");
		}
		if(expired>0){
			out.print("<br/><hr/><font color='red'>"+HTMLEntities.htmlentities(getTran("web","expired",sWebLanguage))+": "+expired+"</font><br/>");
		}
	}
%>