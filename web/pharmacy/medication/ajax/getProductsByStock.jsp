<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ProductStockOperation,
                java.util.Vector" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
 <%@include file="/includes/validateUser.jsp"%>
<%String sFindStockId = checkString(request.getParameter("FindStockId"));
    String sFindProductName = checkString(request.getParameter("FindProductName"));
    session.setAttribute("FindStockId", sFindStockId);
    Vector v = ProductStock.getProducts(sFindStockId,sFindProductName);
    if (v.size() > 0) {
        %>
  <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin" width="100%">
                            <td width="22"><%=getTran("Web","level",sWebLanguage)%></td>
                            <td width="100%"><%=getTran("Web","productName",sWebLanguage)%></td>
                            <td/>
                        </tr>

<%

        Iterator it = v.iterator();
        int i = 0;

        while (it.hasNext()) {
         String sClass = ((i%2)==0)?"list":"list1";

            ProductStock p = (ProductStock) it.next();

            if(p.getLevel()==0){
            sClass = "strikelist";
}
            out.write("<tr class='"+sClass+"' onClick=\"deliverProduct('"+p.getUid()+"','"+HTMLEntities.htmlentities(p.getProduct().getName())+"','"+p.getLevel()+"');\"><td width='22' align='center'>"+p.getLevel()+"</td><td width='100%'>"+ HTMLEntities.htmlentities(p.getProduct().getName())+"</td></tr>");
            i++;
        }
    out.write("</table>");
        %>
           
                                <%

    } else {
        out.write("no results");
    }%>
<script>
    sortables_init();
</script>