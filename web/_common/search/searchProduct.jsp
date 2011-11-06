<%@ page import="be.openclinic.pharmacy.Product,
                 java.util.Vector,
                 be.openclinic.adt.Encounter,
                 be.openclinic.pharmacy.ServiceStock" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%=sJSSTRINGFUNCTIONS%>
<%=sJSPROTOTYPE%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if (sAction.length() == 0) sAction = "find"; // default action

    String sOpenerAction = checkString(request.getParameter("OpenerAction"));

    // get data from form
    String sSearchProductName = checkString(request.getParameter("SearchProductName")),
            sSearchSupplierUid = checkString(request.getParameter("SearchSupplierUid")),
            sSearchSupplierName = checkString(request.getParameter("SearchSupplierName")),
            sSearchProductGroup = checkString(request.getParameter("SearchProductGroup")),
            sSelectProductUid = checkString(request.getParameter("SelectProductUid"));

    // get data from calling url or hidden fields in form
    String sReturnProductUidField = checkString(request.getParameter("ReturnProductUidField")),
            sReturnProductNameField = checkString(request.getParameter("ReturnProductNameField")),
            sReturnProductUnitField = checkString(request.getParameter("ReturnProductUnitField")),
            sReturnUnitsPerPackageField = checkString(request.getParameter("ReturnUnitsPerPackageField")),
            sReturnUnitsPerTimeUnitField = checkString(request.getParameter("ReturnUnitsPerTimeUnitField")),
            sReturnSupplierUidField = checkString(request.getParameter("ReturnSupplierUidField")),
            sReturnSupplierNameField = checkString(request.getParameter("ReturnSupplierNameField")),
            sReturnProductStockUidField = checkString(request.getParameter("ReturnProductStockUidField"));

    // display options
    String sDisplaySearchUserProductsLink = checkString(request.getParameter("DisplaySearchUserProductsLink"));
    boolean displaySearchUserProductsLink = true;
    if (sDisplaySearchUserProductsLink.equalsIgnoreCase("false")) {
        displaySearchUserProductsLink = false;
    }

    String sDisplaySearchProductInStockLink = checkString(request.getParameter("DisplaySearchProductInStockLink"));
    boolean displaySearchProductInStockLink = false;
    if (sDisplaySearchProductInStockLink.equalsIgnoreCase("true")) {
        displaySearchProductInStockLink = true;
    }

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode", "PHA.PHA"),
            centralPharmacyName = getTran("Service", centralPharmacyCode, sWebLanguage);

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## searchProduct : " + sAction + " ##################");
        System.out.println("* sSearchProductName  : " + sSearchProductName);
        System.out.println("* sSearchSupplierUid  : " + sSearchSupplierUid);
        System.out.println("* sSearchSupplierName : " + sSearchSupplierName);
        System.out.println("* sSearchProductGroup : " + sSearchProductGroup);
        System.out.println("* sOpenerAction       : " + sOpenerAction);
        System.out.println("* sSelectProductUid   : " + sSelectProductUid + "\n");

        System.out.println("* sReturnUnitsPerPackageField  : " + sReturnUnitsPerPackageField);
        System.out.println("* sReturnProductUidField       : " + sReturnProductUidField);
        System.out.println("* sReturnProductNameField      : " + sReturnProductNameField);
        System.out.println("* sReturnProductUnitField      : " + sReturnProductUnitField);
        System.out.println("* sReturnUnitsPerTimeUnitField : " + sReturnUnitsPerTimeUnitField);
        System.out.println("* sReturnSupplierUidField      : " + sReturnSupplierUidField);
        System.out.println("* sReturnSupplierNameField     : " + sReturnSupplierNameField);
        System.out.println("* sReturnProductStockUidField  : " + sReturnProductStockUidField + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////
%>

<form name="productForm" method="POST" onkeydown="if(enterEvent(event,13)){doFind();}" onsubmit="return false;">
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnProductUidField" value="<%=sReturnProductUidField%>">
    <input type="hidden" name="ReturnProductNameField" value="<%=sReturnProductNameField%>">
    <input type="hidden" name="ReturnProductUnitField" value="<%=sReturnProductUnitField%>">
    <input type="hidden" name="ReturnUnitsPerTimeUnitField" value="<%=sReturnUnitsPerTimeUnitField%>">

    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="7"><%=getTran("web.manage", "searchinproductcatalog", sWebLanguage)%>
            </td>
        </tr>

        <%-- SEARCH FIELDS --%>
        <tr height="25">
            <%-- productname --%>
            <td>&nbsp;<%=getTran("Web", "product", sWebLanguage)%>&nbsp;</td>
            <td>
                <input type="text" id="SearchProductName" name="SearchProductName" class="text"
                       value="<%=sSearchProductName%>" size="30" onkeyup="delayedSearch();">&nbsp;
            </td>

            <%-- supplier --%>
            <td><%=getTran("Web", "supplier", sWebLanguage)%>&nbsp;</td>
            <td nowrap>
                <input type="hidden" name="SearchSupplierUid" id="SearchSupplierUid" value="<%=sSearchSupplierUid%>">
                <input type="text" name="SearchSupplierName" class="text" value="<%=sSearchSupplierName%>" size="30"
                       READONLY onchange="delayedSearch();">

                <img src="<c:url value="/_img/icon_search.gif"/>" class="link"
                     alt="<%=getTran("Web","select",sWebLanguage)%>"
                     onclick="searchSupplier('SearchSupplierUid','SearchSupplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
                     alt="<%=getTran("Web","clear",sWebLanguage)%>"
                     onclick="productForm.SearchSupplierUid.value='';productForm.SearchSupplierName.value='';">&nbsp;
            </td>

            <%-- product group --%>
            <td><%=getTran("Web", "productgroup", sWebLanguage)%>&nbsp;</td>
            <td>
                <select class="text" name="SearchProductGroup" id="SearchProductGroup" onChange="delayedSearch();">
                    <option value=""></option>
                    <%
                        Vector groups = Product.getProductGroups();
                        for (int n = 0; n < groups.size(); n++) {
                            out.println("<option value='" + groups.elementAt(n) + "' " + (sSearchProductGroup.equalsIgnoreCase((String) groups.elementAt(n)) ? "selected" : "") + ">" + groups.elementAt(n) + "</option>");
                        }
                    %>
                </select>&nbsp;
            </td>

            <%-- BUTTONS --%>
            <td style="text-align:right;" nowrap>
                <input class="button" type="button" onClick="doFind();" name="findButton"
                       value="<%=getTran("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>


        <%-- SEARCH RESULTS --%>
        <tr>
            <td class="white" valign="top" colspan="7">

            </td>
        </tr>
    </table>

    <div id="divFindRecords">
    </div>

    <br>

    <%-- link to searchProductInStock popup --%>
    <%
        if (displaySearchProductInStockLink) {
    %>
    <div>
        <a href="javascript:searchProductInStock('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=
            getTran("web.manage", "searchInProductStock", sWebLanguage)%>
        </a>
    </div>
    <%
        }
    %>

    <%-- link to searchUserProduct popup --%>
    <%
        if (displaySearchUserProductsLink) {
    %>
    <div>
        <a href="javascript:searchUserProduct('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=
            getTran("web.manage", "searchInUserProducts", sWebLanguage)%>
        </a>
    </div>
    <%
        }
    %>

    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value="<%=getTran("Web","close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>

<script>
window.resizeTo(1000, 540);

var timerId = 0;
var activeSearch = "", lastSearch = "";

var setMaxRows = function setMaxRows() {
    var foundRecs = $("searchresults").rows.length - 1;
    if (foundRecs > 0) {
        var maxRecsToShow = <%=MedwanQuery.getInstance().getConfigInt("maxRecordsToShow",100)%>;
        if (foundRecs == maxRecsToShow) {
            $("divFindRecords").innerHTML += ">" + foundRecs + " <%=getTranNoLink("web","recordsFound",sWebLanguage)%>";
        }
        else {
            $("divFindRecords").innerHTML += foundRecs + " <%=getTranNoLink("web","recordsFound",sWebLanguage)%>";
        }
    }

}
<%-- SELECT PRODUCT --%>
function selectProduct(productUid, productName, productUnit, unitsPerTimeUnit, productSupplierUid, productSupplierName, unitsPerPackage, productStockUid) {
    var closeWindow = true;

    window.opener.document.all["<%=sReturnProductUidField%>"].value = productUid;
    window.opener.document.all["<%=sReturnProductNameField%>"].value = productName;
	<%
	// set ProductUnit
	if(sReturnProductUnitField.length() > 0){
	%>
	    if (productUnit.length > 0) {
	        window.opener.document.all["<%=sReturnProductUnitField%>"].value = productUnit;
	        if (window.opener.setEditUnitsPerTimeUnitLabel != null) {
	            window.opener.setEditUnitsPerTimeUnitLabel(productUid);
	        }
	    }
	    else {
	        openEditProductUnitPopup(productUid);
	        closeWindow = false;
	    }
	<%
	}

	// Set ServiceStock
	//Is patient admitted?
	String serviceStockUid="";
	String serviceStockName="";
	Service service = Service.getService(centralPharmacyCode);
	Vector stocks;
	if(service !=null){
		stocks=ServiceStock.find(service.code);
		for(int n=0;n<stocks.size();n++){
		    ServiceStock serviceStock=(ServiceStock)stocks.elementAt(n);
		    if(serviceStock.isActive()){
		        serviceStockUid=serviceStock.getUid();
		        serviceStockName=serviceStock.getName();
		        break;
		    }
		}
	}
	if(activePatient!=null){
		Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
		if(encounter!=null && encounter.getType().equalsIgnoreCase("admission") && encounter.getService()!=null){
		    service=encounter.getService();
		    stocks = ServiceStock.find(service.code);
		    for(int n=0;n<stocks.size();n++){
		        ServiceStock serviceStock=(ServiceStock)stocks.elementAt(n);
		        if(serviceStock.isActive()){
		            serviceStockUid=serviceStock.getUid();
		            serviceStockName=serviceStock.getName();
		            break;
		        }
		    }
		}
	}

	if(!"false".equalsIgnoreCase(request.getParameter("resetServiceStockUid"))){
		%>
	    if (window.opener.document.all["EditServiceStockUid"] != undefined) {
	        window.opener.document.all["EditServiceStockUid"].value = "<%=serviceStockUid%>";
	    }
	    if (window.opener.document.all["EditServiceStockName"] != undefined) {
	        window.opener.document.all["EditServiceStockName"].value = "<%=serviceStockName%>";
	    }
		<%
	}

	// CLEAR SupplyingService
	%>
    var suppServUidField = window.opener.document.all["EditSupplyingServiceUid"];
    var suppServNameField = window.opener.document.all["EditSupplyingServiceUid"];

    if (suppServUidField != undefined && suppServNameField != undefined) {
        window.opener.document.all["EditSupplyingServiceUid"].value = "";
        window.opener.document.all["EditSupplyingServiceName"].value = "";
    }
<%

// set productSupplier
if(sReturnSupplierUidField.length() > 0 && sReturnSupplierNameField.length() > 0){
%>
    if (productSupplierUid.length == 0) {
        productSupplierUid = "<%=centralPharmacyCode%>";
        productSupplierName = "<%=centralPharmacyName%>";
    }

    window.opener.document.all["<%=sReturnSupplierUidField%>"].value = productSupplierUid;
    window.opener.document.all["<%=sReturnSupplierNameField%>"].value = productSupplierName;
<%
}

// set unitsPerTimeUnit
if(sReturnUnitsPerTimeUnitField.length() > 0){
%>
    if (unitsPerTimeUnit < 0) {
        window.opener.document.all["<%=sReturnUnitsPerTimeUnitField%>"].value = "";
    }
    else {
        window.opener.document.all["<%=sReturnUnitsPerTimeUnitField%>"].value = unitsPerTimeUnit;
        isNumber(window.opener.document.all["<%=sReturnUnitsPerTimeUnitField%>"]);
    }
<%
}

// set unitsPerPackage
if(sReturnUnitsPerPackageField.length() > 0){
%>
    if (unitsPerPackage == 0) unitsPerPackage = 1;

    window.opener.document.all["<%=sReturnUnitsPerPackageField%>"].value = unitsPerPackage;
    isNumber(window.opener.document.all["<%=sReturnUnitsPerTimeUnitField%>"]);

    if (window.opener.calculatePackagesNeeded != null) {
        window.opener.calculatePackagesNeeded();
    }
    if (window.opener.calculatePrescriptionPeriod != null) {
        window.opener.calculatePrescriptionPeriod();
    }
<%
}

// set productStockUid
if(sReturnProductStockUidField.length() > 0){
%>
    if (productStockUid != undefined && productStockUid.length > 0) {
        window.opener.document.all["<%=sReturnProductStockUidField%>"].value = productStockUid;
    }
    else {
        window.opener.document.all["<%=sReturnProductStockUidField%>"].value = "";
    }
<%
    }
%>

    if ("true" == "<%=checkString(request.getParameter("loadschema"))%>") {
        window.opener.loadSchema();
    }

    if (closeWindow) window.close();
}

<%-- popup : search supplier --%>
//function searchSupplier(serviceUidField, serviceNameField) {
//    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode=" + serviceUidField + "&VarText=" + serviceNameField);
//}

<%-- popup : search supplier --%>
function searchSupplier(serviceUidField, serviceNameField) {
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=" + serviceUidField + "&ReturnServiceStockNameField=" + serviceNameField);
}

<%-- popup : search userProduct --%>
function searchUserProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage, productStockUidField) {
    window.opener.searchUserProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage, productStockUidField);
    window.close();
}

<%-- popup : search product in stock --%>
function searchProductInStock(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage, productStockUidField) {
    window.opener.searchProductInServiceStock(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage, productStockUidField);
    window.close();
}

<%-- CLEAR SEARCH FIELDS --%>
function clearSearchFields() {
    productForm.SearchProductName.value = "";
    productForm.SearchSupplierUid.value = "";
    productForm.SearchSupplierName.value = "";
    productForm.SearchProductGroup.value = "";

    productForm.SearchProductName.focus();
}

<%-- DELAYED SEARCH --%>
function delayedSearch() {
    if (timerId > 0) clearTimeout(timerId);
    timerId = window.setTimeout("doFind();", <%=MedwanQuery.getInstance().getConfigInt("searchDelay",1000)%>);
}

<%-- DO FIND --%>
function doFind() {

    ajaxChangeSearchResults('_common/search/searchByAjax/searchProductShow.jsp', productForm, "&ts=" + new Date().getTime());
}
<%-- OPEN EDIT PRODUCT UNIT POPUP --%>
function openEditProductUnitPopup(productUid) {
    var url = "pharmacy/popups/editProductUnit.jsp" +
              "&EditProductUid=" + productUid +
              "&ts=<%=getTs()%>";

<%
// pass search-parameters to be able to reproduce the same search as you did just now
if(sSearchProductName.length() > 0){
%>
    url += "&SearchProductName=<%=sSearchProductName%>";
<%
}
if(sSearchSupplierUid.length() > 0){
%>
    url += "&SearchSupplierUid=<%=sSearchSupplierUid%>";
<%
}
if(sSearchSupplierName.length() > 0){
%>
    url += "&SearchSupplierName=<%=sSearchSupplierName%>";
<%
}
if(sSearchProductGroup.length() > 0){
%>
    url += "&SearchProductGroup=<%=sSearchProductGroup%>";
<%
    }
%>

    url += "&SelectProductUid=" + productUid;

    openPopup(url, "500", "250", "EditProductUnit");
}

<%
// select product specified by "editProductUnit.jsp", which just added some missing data to the product.
if(sOpenerAction.equals("selectProduct")){
Product product = Product.get(sSelectProductUid);

// get supplier name
String sSupplierUid = checkString(product.getSupplierUid());
String sSupplierName = "";
if (sSupplierUid.length() > 0){
    sSupplierName = getTranNoLink("service", sSupplierUid, sWebLanguage);
}

%>
selectProduct("<%=product.getUid()%>", "<%=checkString(product.getName())%>", "<%=checkString(product.getUnit())%>", "<%=product.getUnitsPerTimeUnit()%>", "<%=checkString(product.getSupplierUid())%>", "<%=sSupplierName%>", "<%=product.getPackageUnits()%>");
<%
    }
%>
var globalvar = productForm.SearchProductName;
window.setTimeout("globalvar.focus();", 100);
</script>
     