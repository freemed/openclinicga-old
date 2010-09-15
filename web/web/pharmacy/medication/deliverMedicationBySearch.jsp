<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.medical.Prescription,
                be.openclinic.finance.DebetTransaction,
                be.openclinic.finance.Balance,
                be.openclinic.finance.Prestation,java.util.Hashtable,java.util.Vector,java.util.Enumeration" %>
<%@ page import="be.openclinic.adt.Encounter" %>
<%@ page import="be.openclinic.pharmacy.ServiceStock" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationdelivery","all",activeUser)%>
<%=sJSSORTTABLE%>
 <%=writeTableHeader("Web.manage","medicationdelivery",sWebLanguage,"")%>
<%!
    public static String getStocks(String userId,HttpSession session){
        String sReturn = "";
        Vector v = ServiceStock.getStocksByUser(userId);
        Iterator it = v.iterator();
        String selectedId = (session.getAttribute("FindStockId")!=null?(String)session.getAttribute("FindStockId"):"");
        while (it.hasNext()){
            ServiceStock s = (ServiceStock) it.next();
            sReturn += "<option value='"+s.getUid()+"' "+(selectedId.equals(s.getUid())?"selected=selected":"")+">"+s.getName()+"</option>";
        }         
        return sReturn;
    }
%>
<form name="transactionForm" id="transactionForm" method="post" >
    <table class="list" width="100%" cellspacing="1">
                       <%-- description --%>
       <tr>
           <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Stock",sWebLanguage)%> *</td>
           <td class="admin2">
               <select class="text" name="FindStockId" style="vertical-align:-2px;">
                   <%=getStocks(activeUser.userid,session)%>
               </select>
           </td>
       </tr>
         <tr>
           <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Name",sWebLanguage)%></td>
           <td class="admin2">
               <input type="text" class="text" name="FindProductName" size="<%=sTextWidth%>" maxLength="255" >

           </td>
       </tr>
        <tr>
           <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
           <td class="admin2">
               <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchService();">
           </td>
        </tr>
    </table>

</form>
<div id="resultsByAjax" >&nbsp;</div>
<script type="text/javascript">
    function searchService(){
        var id = "resultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = $("transactionForm").serialize();
        var url = "<c:url value="/pharmacy/medication/ajax/getProductsByStock.jsp" />";
         new Ajax.Updater(id,url,
                {   parameters:params,
                    evalScripts: true

                });
    }
    <%-- popup : deliver product --%>
  function deliverProduct(productStockUid,productName,stockLevel){
     if(stockLevel=="0"){
         alert("<%=getTranNoLink("web","productstockoperation.insufficient.sourceproductstock",sWebLanguage)%>");
     }
      openPopup("pharmacy/medication/popups/deliverMedicationPopup.jsp&EditProductStockUid="+productStockUid+"&EditProductName="+productName+"&ts=<%=getTs()%>",750,400);
  }
  window.onload = function(){
    searchService();  
  }
</script>