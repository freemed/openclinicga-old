<%@ page import="be.openclinic.pharmacy.ProductSchema" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please..</p>
<script type="text/javascript">
<%
    String sProductUid = checkString(request.getParameter("productuid"));
    ProductSchema productSchema = ProductSchema.getSingleProductSchema(sProductUid);
    out.print("window.opener.document.all['time1'].value='"+productSchema.getTimeQuantity(0).getKey()+"';");
    out.print("window.opener.document.all['quantity1'].value='"+productSchema.getTimeQuantity(0).getValue()+"';");
    out.print("window.opener.document.all['time2'].value='"+productSchema.getTimeQuantity(1).getKey()+"';");
    out.print("window.opener.document.all['quantity2'].value='"+productSchema.getTimeQuantity(1).getValue()+"';");
    out.print("window.opener.document.all['time3'].value='"+productSchema.getTimeQuantity(2).getKey()+"';");
    out.print("window.opener.document.all['quantity3'].value='"+productSchema.getTimeQuantity(2).getValue()+"';");
    out.print("window.opener.document.all['time4'].value='"+productSchema.getTimeQuantity(3).getKey()+"';");
    out.print("window.opener.document.all['quantity4'].value='"+productSchema.getTimeQuantity(3).getValue()+"';");
    out.print("window.opener.document.all['time5'].value='"+productSchema.getTimeQuantity(4).getKey()+"';");
    out.print("window.opener.document.all['quantity5'].value='"+productSchema.getTimeQuantity(4).getValue()+"';");
    out.print("window.opener.document.all['time6'].value='"+productSchema.getTimeQuantity(5).getKey()+"';");
    out.print("window.opener.document.all['quantity6'].value='"+productSchema.getTimeQuantity(5).getValue()+"';");
%>
    window.close();
</script>