<%@page import="be.openclinic.pharmacy.ServiceStock,
                java.util.Vector,
                be.openclinic.pharmacy.ProductStock"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "find"; // default action

    // get data from form
    String sSearchServiceStockName = checkString(request.getParameter("SearchServiceStockName")),
           sSearchServiceUid       = checkString(request.getParameter("SearchServiceUid")),
           sSearchServiceName      = checkString(request.getParameter("SearchServiceName")),
           sExcludeServiceStockUid = checkString(request.getParameter("ExcludeServiceStockUid")),
           sSearchProductUid       = checkString(request.getParameter("SearchProductUid")),
           sSearchProductLevel     = checkString(request.getParameter("SearchProductLevel")),
           sSearchManagerUid       = checkString(request.getParameter("SearchManagerUid")),
           sSearchManagerName      = checkString(request.getParameter("SearchManagerName"));

    // get data from calling url or hidden fields in form
    String sReturnServiceStockUidField  = checkString(request.getParameter("ReturnServiceStockUidField")),
           sReturnServiceStockNameField = checkString(request.getParameter("ReturnServiceStockNameField"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********** _common/search/searchServiceStock.jsp ***********");
    	Debug.println("sAction : "+sAction);
    	Debug.println("sSearchServiceStockName : "+sSearchServiceStockName);
    	Debug.println("sSearchServiceUid       : "+sSearchServiceUid);
    	Debug.println("sSearchServiceName      : "+sSearchServiceName);
    	Debug.println("sExcludeServiceStockUid : "+sExcludeServiceStockUid);
    	Debug.println("sSearchProductUid       : "+sSearchProductUid);
    	Debug.println("sSearchProductLevel     : "+sSearchProductLevel);
    	Debug.println("sSearchManagerUid       : "+sSearchManagerUid);
    	Debug.println("sSearchManagerName      : "+sSearchManagerName+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>
<form name="serviceStockForm" method="POST" onkeydown="if(enterEvent(event,13)){doFind();}">    
    <%=writeTableHeader("web","searchServiceStock",sWebLanguage," window.close();")%>

    <%-- SEARCH FIELDS --%>
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <tr height="23">
            <%-- servicestock name --%>
            <td class="admin2">&nbsp;<%=getTran("Web","name",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" name='SearchServiceStockName' class="text" value="<%=sSearchServiceStockName%>" size="20">
            </td>

            <%-- service --%>
            <td class="admin2"><%=getTran("Web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="SearchServiceUid" value="<%=sSearchServiceUid%>">
                <input type="text" name='SearchServiceName' class="text" value="<%=sSearchServiceName%>" size="40" READONLY>

                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('SearchServiceUid','SearchServiceName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="serviceStockForm.SearchServiceUid.value='';serviceStockForm.SearchServiceName.value='';">
            </td>
        </tr>

        <tr height="23">
            <%-- manager --%>
            <td class="admin2">&nbsp;<%=getTran("Web", "manager", sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="SearchManagerUid" value="<%=sSearchManagerUid%>">
                <input type="text" name='SearchManagerName' class="text" value="<%=sSearchManagerName%>" size="40" READONLY>

                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchManager('SearchManagerUid','SearchManagerName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="serviceStockForm.SearchManagerUid.value='';serviceStockForm.SearchManagerName.value='';">&nbsp;&nbsp;&nbsp;
            </td>

            <%-- BUTTONS --%>
            <td class="admin2" colspan="2" style="text-align:left;">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
    </table>

    <%-- SEARCH RESULTS --%>
    <div id="divFindRecords" style="padding-top:2px;"></div>

    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnServiceStockUidField" value="<%=sReturnServiceStockUidField%>">
    <input type="hidden" name="ReturnServiceStockNameField" value="<%=sReturnServiceStockNameField%>">
    <input type="hidden" name="SearchProductUid" value="<%=sSearchProductUid%>">
    <input type="hidden" name="SearchProductLevel" value="<%=sSearchProductLevel%>">
    <input type="hidden" name="ExcludeServiceStockUid" value="<%=sExcludeServiceStockUid%>">
    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value='<%=getTranNoLink("Web","close",sWebLanguage)%>' onclick='window.close();'>
    </center>
</form>

<script>
  window.resizeTo(830,530);
  document.serviceStockForm.SearchServiceStockName.focus();

  <%-- select service stock --%>
  function selectServiceStock(serviceStockUid, serviceStockName, supplyingServiceUid, supplyingServiceName){
    window.opener.document.getElementsByName('<%=sReturnServiceStockUidField%>')[0].value = serviceStockUid;
    window.opener.document.getElementsByName('<%=sReturnServiceStockNameField%>')[0].value = serviceStockName;
    if(window.opener.document.getElementsByName('<%=sReturnServiceStockNameField%>')[0].onchange){
      window.opener.document.getElementsByName('<%=sReturnServiceStockNameField%>')[0].onchange();
    }
    
    <%-- set SupplyingService --%>
    var suppServUidField = window.opener.document.getElementsByName('EditSupplyingServiceUid')[0];
    var suppServNameField = window.opener.document.getElementsByName('EditSupplyingServiceName')[0];

    if(suppServUidField!=undefined && suppServNameField!=undefined){
      window.opener.document.getElementsByName('EditSupplyingServiceUid')[0].value = supplyingServiceUid;
      window.opener.document.getElementsByName('EditSupplyingServiceName')[0].value = supplyingServiceName;
    }

    window.close();
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search manager --%>
  function searchManager(managerUidField,managerNameField){
	var url = "/_common/search/searchUser.jsp&ts=<%=getTs()%>"+
	          "&ReturnUserID="+managerUidField+
	          "&ReturnName="+managerNameField+
	          "&displayImmatNew=no";
    openPopup(url);
  }

  <%-- do find --%>
  function doFind(){
    serviceStockForm.Action.value = "find";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchServiceStockShow.jsp', serviceStockForm);
  }
  
  <%-- clear search fields --%>
  function clearSearchFields(){
    serviceStockForm.SearchServiceStockName.value = '';
    serviceStockForm.SearchServiceName.value = '';
    serviceStockForm.SearchServiceUid.value = '';
    serviceStockForm.SearchManagerName.value = '';
    serviceStockForm.SearchManagerUid.value = '';
  }
 
  doFind();
</script>