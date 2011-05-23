<%@ page import="be.openclinic.pharmacy.Product" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindProduct =  checkString(request.getParameter("findproduct"));
    String sPrescriptionInfo =  checkString(request.getParameter("prescriptioninfo"));
    if(sFindProduct.length()>0){
    	Product product = new Product();
		product.setName(sFindProduct);
		product.setUpdateUser(activeUser.userid);
		product.setPrescriptionInfo(sPrescriptionInfo);
		product.setCreateDateTime(new java.util.Date());
		product.setVersion(1);
		product.setUid("-1");
		product.setUnit("");
		product.store();
    }
%>
