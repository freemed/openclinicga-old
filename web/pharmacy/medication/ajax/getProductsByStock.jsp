<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ProductStockOperation,
                be.mxs.common.util.system.HTMLEntities,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
 
<%
    String sFindStockId     = checkString(request.getParameter("FindStockId")),
           sFindProductName = checkString(request.getParameter("FindProductName"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********** pharmacy/medication/ajax/getProductsByStock.jsp ************");
    	Debug.println("sFindStockId     : "+sFindStockId);
    	Debug.println("sFindProductName : "+sFindProductName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    session.setAttribute("FindStockId",sFindStockId);
    
    Vector vProducts = ProductStock.getProducts(sFindStockId,sFindProductName);
    if(vProducts.size() > 0){
        %>
  			<table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                <%-- header --%>
                <tr class="admin" width="100%">
                    <td width="22"><%=getTran("Web","level",sWebLanguage)%></td>
                    <td width="100%"><%=getTran("Web","productName",sWebLanguage)%></td>
                </tr>
		<%

        Iterator iter = vProducts.iterator();
        int i = 0;
        
        ProductStock stock;
        while(iter.hasNext()){
            String sClass = (i%2==0?"list":"list1");
            stock = (ProductStock)iter.next();
            if(stock.getLevel()==0) sClass = "strikelist";
            
            out.write("<tr class='"+sClass+"' onClick=\"deliverProduct('"+stock.getUid()+"','"+HTMLEntities.htmlentities(stock.getProduct().getName())+"','"+stock.getLevel()+"');\">"+
                       "<td width='22' align='center'>"+stock.getLevel()+"</td>"+
                       "<td width='100%'>"+HTMLEntities.htmlentities(stock.getProduct().getName())+"</td>"+
                      "</tr>");
            i++;
        }
         
        out.write("</table>");
    }
    else{
        out.write("no results");
    }
%>
<script>sortables_init();</script>