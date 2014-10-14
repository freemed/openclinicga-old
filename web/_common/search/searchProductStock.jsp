<%@page import="be.openclinic.pharmacy.Product,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.pharmacy.ProductStock,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // get data from form
    String sSearchStockLevel   = checkString(request.getParameter("SearchStockLevel")),
           sSearchProductUid   = checkString(request.getParameter("SearchProductUid")),
           sSearchProductName  = checkString(request.getParameter("SearchProductName")),
           sSearchServiceUid   = checkString(request.getParameter("SearchServiceUid")),
           sSearchProductLevel = checkString(request.getParameter("SearchProductLevel")),
           sSearchServiceName  = checkString(request.getParameter("SearchServiceName"));

    // get data from calling url or hidden fields in form
    String sReturnProductStockUidField   = checkString(request.getParameter("ReturnProductStockUidField")),
           sReturnProductStockNameField  = checkString(request.getParameter("ReturnProductStockNameField")),
           sReturnServiceStockUidField   = checkString(request.getParameter("ReturnServiceStockUidField")),
           sReturnServiceStockNameField  = checkString(request.getParameter("ReturnServiceStockNameField")),
           sReturnProductStockLevelField = checkString(request.getParameter("ReturnProductStockLevelField"));

    // display products of user-service by default
    String sDisplayProductStocksOfActiveUserService = checkString(request.getParameter("DisplayProductStocksOfActiveUserService"));
    boolean displayProductStocksOfActiveUserService = true; // default
    if(sDisplayProductStocksOfActiveUserService.equals("false")){
        displayProductStocksOfActiveUserService = false;
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** _common/search/searchProductStock.jsp ****************");
    	Debug.println("sAction             : "+sAction);
    	Debug.println("sSearchStockLevel   : "+sSearchStockLevel);
    	Debug.println("sSearchProductUid   : "+sSearchProductUid);
    	Debug.println("sSearchProductName  : "+sSearchProductName);
    	Debug.println("sSearchServiceUid   : "+sSearchServiceUid);
    	Debug.println("sSearchProductLevel : "+sSearchProductLevel);
    	Debug.println("sSearchServiceName  : "+sSearchServiceName+"\n");
    	Debug.println("sReturnProductStockUidField   : "+sReturnProductStockUidField);
    	Debug.println("sReturnProductStockNameField  : "+sReturnProductStockNameField);
    	Debug.println("sReturnServiceStockUidField   : "+sReturnServiceStockUidField);
    	Debug.println("sReturnServiceStockNameField  : "+sReturnServiceStockNameField);
    	Debug.println("sReturnProductStockLevelField : "+sReturnProductStockLevelField);
    	Debug.println("displayProductStocksOfActiveUserService : "+displayProductStocksOfActiveUserService+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="productStockForm" method="POST" onSubmit="doFind();return false;" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("web","searchProductStock",sWebLanguage," window.close();")%>
    
    <table width="100%" cellspacing="1" cellpadding="0" class="menu">    
        <%-- SEARCH FIELDS --%>
        <tr>
            <%-- product --%>
            <td class="admin2" width="100"><%=getTran("Web","product",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="SearchProductUid" value="<%=sSearchProductUid%>">
                <input type="text" name="SearchProductName" class="text" value="<%=sSearchProductName%>" size="40" READONLY>

                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProduct('SearchProductUid','SearchProductName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="productStockForm.SearchProductUid.value='';productStockForm.SearchProductName.value='';">
            </td>
        </tr>
        
        <tr>
            <%-- service --%>
            <td class="admin2"><%=getTran("Web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="SearchServiceUid" value="<%=sSearchServiceUid%>">
                <input type="text" name="SearchServiceName" class="text" value="<%=sSearchServiceName%>" size="40" READONLY>
              
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('SearchServiceUid','SearchServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="productStockForm.SearchServiceUid.value='';productStockForm.SearchServiceName.value='';">
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
    </table>

    <div id="divFindRecords" style="padding-top:2px;"></div>
                
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnProductStockUidField" value="<%=sReturnProductStockUidField%>">
    <input type="hidden" name="ReturnProductStockNameField" value="<%=sReturnProductStockNameField%>">
    <input type="hidden" name="ReturnServiceStockUidField" value="<%=sReturnServiceStockUidField%>">
    <input type="hidden" name="ReturnServiceStockNameField" value="<%=sReturnServiceStockNameField%>">
    <input type="hidden" name="ReturnProductStockLevelField" value="<%=sReturnProductStockLevelField%>">
    <input type="hidden" name="DisplayProductStocksOfActiveUserService" value="<%=sDisplayProductStocksOfActiveUserService%>">

    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value='<%=getTranNoLink("Web","close",sWebLanguage)%>' onclick='window.close();'>
    </center>
</form>

<script>
  window.resizeTo(600,540);
  document.productStockForm.SearchProductName.focus();

  <%-- select product stock --%>
  function selectProductStock(productStockUid, productStockName, serviceStockUid, serviceStockName, productStockLevel){
    window.opener.document.getElementsByName('<%=sReturnProductStockUidField%>')[0].value = productStockUid;
    window.opener.document.getElementsByName('<%=sReturnProductStockNameField%>')[0].value = productStockName;

    <%-- set ServiceStock --%>
    var serviceStockUidField = window.opener.document.getElementsByName('<%=sReturnServiceStockUidField%>')[0];
    if(serviceStockUidField != undefined){
      window.opener.document.getElementsByName('<%=sReturnServiceStockUidField%>')[0].value = serviceStockUid;
    }

    var serviceStockNameField = window.opener.document.getElementsByName('<%=sReturnServiceStockNameField%>')[0];
    if(serviceStockNameField != undefined){
      window.opener.document.getElementsByName('<%=sReturnServiceStockNameField%>')[0].value = serviceStockName;
    }

    <%-- set level --%>
    if('<%=sReturnProductStockLevelField%>'.length > 0){
      window.opener.document.getElementsByName('<%=sReturnProductStockLevelField%>')[0].value = productStockLevel;
    }

    if(window.opener.deselectAllPrescriptions!=null){
       window.opener.deselectAllPrescriptions();
    }

    if(window.opener.document.getElementsByName('displayDeliveriesButton')[0] != undefined){
      window.opener.document.getElementsByName('displayDeliveriesButton')[0].style.visibility = 'visible';
    }

    window.close();
  }

  <%-- do find --%>
  function doFind(){
    productStockForm.Action.value = "find";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchProductStockShow.jsp',productStockForm);
  }

  <%-- clear search fields --%>
  function clearSearchFields(){
    productStockForm.SearchProductUid.value = "";
    productStockForm.SearchProductName.value = "";

    productStockForm.SearchServiceUid.value = "";
    productStockForm.SearchServiceName.value = "";
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField){
    openPopup("/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
    		  "&ReturnProductUidField="+productUidField+
    		  "&ReturnProductNameField="+productNameField+
    		  "&DisplaySearchProductInStockLink=false"+
    		  "&DisplaySearchUserProductsLink=false");
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }
</script>