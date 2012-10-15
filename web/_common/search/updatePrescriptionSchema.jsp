<%@ page import="be.openclinic.pharmacy.ProductSchema" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please..</p>
<script type="text/javascript">
<%
    String sProductUid = checkString(request.getParameter("productuid"));
    ProductSchema productSchema = ProductSchema.getSingleProductSchema(sProductUid);
    out.print("window.opener.document.getElementsByName('time1')[0].value='"+productSchema.getTimeQuantity(0).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity1')[0].value='"+productSchema.getTimeQuantity(0).getValue()+"';");
    out.print("window.opener.document.getElementsByName('time2')[0].value='"+productSchema.getTimeQuantity(1).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity2')[0].value='"+productSchema.getTimeQuantity(1).getValue()+"';");
    out.print("window.opener.document.getElementsByName('time3')[0].value='"+productSchema.getTimeQuantity(2).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity3')[0].value='"+productSchema.getTimeQuantity(2).getValue()+"';");
    out.print("window.opener.document.getElementsByName('time4')[0].value='"+productSchema.getTimeQuantity(3).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity4')[0].value='"+productSchema.getTimeQuantity(3).getValue()+"';");
    out.print("window.opener.document.getElementsByName('time5')[0].value='"+productSchema.getTimeQuantity(4).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity5')[0].value='"+productSchema.getTimeQuantity(4).getValue()+"';");
    out.print("window.opener.document.getElementsByName('time6')[0].value='"+productSchema.getTimeQuantity(5).getKey()+"';");
    out.print("window.opener.document.getElementsByName('quantity6')[0].value='"+productSchema.getTimeQuantity(5).getValue()+"';");
%>
    window.close();
</script>