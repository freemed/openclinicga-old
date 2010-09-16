<%@ page import="java.text.DecimalFormat,
                 be.openclinic.pharmacy.Product,
                 be.openclinic.pharmacy.ProductStock,
                 be.openclinic.pharmacy.UserProduct,
                 java.util.Vector,
                 java.util.Collections" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sSearchProductName, String sSearchProductGroup, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sUnit, sUnitPrice, sSupplierUid, sSupplierName,
                sProductGroup, sProductStockUid, sUnitsPerTimeUnit, supplyingServiceUid,
                supplyingServiceName, serviceStockUid, serviceStockName;
        DecimalFormat deci = new DecimalFormat("0.00"),
                unitCountDeci = new DecimalFormat("#.#");
        Vector foundProducts = new Vector();
        ProductStock productStock;
        double dUnitPrice;

        // frequently used translations
        String chooseTran = getTranNoLink("web", "choose", sWebLanguage);
        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");

        // add found products in vector
        UserProduct userProduct;
        for (int i = 0; i < objects.size(); i++) {
            userProduct = (UserProduct) objects.get(i);

            // filter out products depending on their productGroup ?
            boolean productGroupOK = false;
            if (sSearchProductGroup.length() == 0) {
                productGroupOK = true;
            } else {
                if (userProduct.getProduct() != null) {
                    productGroupOK = (checkString(userProduct.getProduct().getProductGroup()).equals(sSearchProductGroup));
                }
            }

            // only display products complying the searched productName AND/OR the searched productGroup
            if (userProduct.getProduct() != null) {
                if (userProduct.getProduct().getName().toLowerCase().startsWith(sSearchProductName.toLowerCase()) && productGroupOK) {
                    foundProducts.add(userProduct);
                }
            }
        }

        // sort found products (on name)
        Collections.sort(foundProducts);

        // run thru sorted found products
        Product product;
        for (int i = 0; i < foundProducts.size(); i++) {
            userProduct = ((UserProduct) foundProducts.get(i));
            product = userProduct.getProduct();

            // translate unit
            sUnit = checkString(product.getUnit());
            if (sUnit.length() > 0) {
                sUnit = getTran("product.unit", sUnit, sWebLanguage);
            }

            // line unit price out
            sUnitPrice = product.getUnitPrice() + "";
            if (sUnitPrice.length() > 0) {
                dUnitPrice = Double.parseDouble(sUnitPrice);
                sUnitPrice = deci.format(dUnitPrice);
            }

            //*** supplier ***
            sProductStockUid = checkString(userProduct.getProductStockUid());
            if (sProductStockUid.length() > 0) {
                // processing product from product-catalog, productStock available
                productStock = ProductStock.get(sProductStockUid);
                sSupplierUid = checkString(product.getSupplierUid());

                if (sSupplierUid.length() > 0) {
                    sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                } else {
                    sSupplierUid = checkString(product.getSupplierUid());
                    if (sSupplierUid.length() > 0) {
                        sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                    } else {
                        sSupplierUid = checkString(productStock.getServiceStock().getDefaultSupplierUid());
                        if (sSupplierUid.length() > 0) {
                            sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                        } else {
                            sSupplierName = "";
                        }
                    }
                }
            } else {
                // processing product from product-catalog, NO productStock available
                productStock = null;

                sSupplierUid = checkString(product.getSupplierUid());
                if (sSupplierUid.length() > 0) {
                    sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                } else {
                    sSupplierName = "";
                }
            }

            // productGroup
            sProductGroup = checkString(product.getProductGroup());
            if (sProductGroup.length() > 0) {
                sProductGroup = getTran("product.productgroup", sProductGroup, sWebLanguage);
            }

            // units per time unit
            sUnitsPerTimeUnit = unitCountDeci.format(product.getUnitsPerTimeUnit());

            // supplyingService & serviceStock
            if (productStock != null) {
                supplyingServiceUid = productStock.getSupplierUid();
                supplyingServiceName = getTranNoLink("service", supplyingServiceUid, sWebLanguage);

                serviceStockUid = productStock.getServiceStockUid();
                serviceStockName = productStock.getServiceStock().getName();
            } else {
                supplyingServiceUid = "";
                supplyingServiceName = "";

                serviceStockUid = "";
                serviceStockName = "";
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display product in one row ***
            html.append("<tr title='" + chooseTran + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\" class='list" + sClass + "' onClick=\"selectProduct('" + product.getUid() + "','" + product.getName() + "','" + product.getUnit() + "','" + sUnitsPerTimeUnit + "','" + supplyingServiceUid + "','" + supplyingServiceName + "','" + sSupplierUid + "','" + sSupplierName + "','" + product.getPackageUnits() + "','" + sProductStockUid + "','" + serviceStockUid + "','" + serviceStockName + "');\">")
                    .append(" <td>" + product.getName() + "</td>")
                    .append(" <td>" + sUnit + "</td>")
                    .append(" <td style='text-align:right;'>" + sUnitPrice + "&nbsp;" + sCurrency + "&nbsp;</td>")
                    .append(" <td>" + sSupplierName + "</td>")
                    .append(" <td>" + (productStock == null ? "" : productStock.getServiceStock().getName()) + "</td>")
                    .append(" <td>" + sProductGroup + "&nbsp;</td>")
                    .append("</tr>");
        }

        return html;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if (sAction.length() == 0) sAction = "find"; // default action

    String sOpenerAction = checkString(request.getParameter("OpenerAction"));

    // get data from form
    String sSearchProductName = checkString(request.getParameter("SearchProductName")).replaceAll("%", ""),
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

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
            centralPharmacyName = getTran("Service", centralPharmacyCode, sWebLanguage);

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## searchUserProduct : " + sAction + " ###############");
        System.out.println("* sSearchProductName  : " + sSearchProductName);
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

    int foundProductCount = 0;
    StringBuffer productsHtml = null;

    //#############################################################################################
    //### ACTIONS #################################################################################
    //#############################################################################################
    //--- FIND ------------------------------------------------------------------------------------
    Vector userProducts = null;
    if (sAction.equals("find")) {
        userProducts = UserProduct.find(activeUser.userid);

        productsHtml = objectsToHtml(userProducts, sSearchProductName, sSearchProductGroup, sWebLanguage);
        foundProductCount = userProducts.size();
    }
%>

<form name="productForm" method="POST" onkeydown="if(enterEvent(event,13)){doFind();}">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="7"><%=getTran("web", "searchuserproduct", sWebLanguage)%>
            </td>
        </tr>

        <%-- SEARCH FIELDS --%>
        <tr height="25">
            <%-- productname --%>
            <td nowrap>&nbsp;<%=getTran("Web", "product", sWebLanguage)%>&nbsp;</td>
            <td nowrap>
                <input type="text" name="SearchProductName" class="text" value="<%=sSearchProductName%>" size="30">&nbsp;
            </td>

            <%-- supplier
            <td><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
            <td>
                <input type="hidden" name="SearchSupplierUid" value="<%=sSearchSupplierUid%>">
                <input type="text" name="SearchSupplierName" class="text" value="<%=sSearchSupplierName%>" size="50" READONLY>

                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchSupplier('SearchSupplierUid','SearchSupplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="productForm.SearchSupplierUid.value='';productForm.SearchSupplierName.value='';">&nbsp;&nbsp;&nbsp;
            </td>
            --%>

            <%-- productgroup --%>
            <td nowrap><%=getTran("Web", "productgroup", sWebLanguage)%>&nbsp;</td>
            <td>
                <select class="text" name="SearchProductGroup">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("product.productgroup", sSearchProductGroup, sWebLanguage)%>
                </select>
            </td>

            <%-- BUTTONS --%>
            <td style="text-align:right;width:520px;">
                <input class="button" type="button" onClick="doFind();" name="findButton"
                       value="<%=getTran("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>

        <%-- SEARCH RESULTS --%>
        <tr>
            <td class="white" valign="top" colspan="7">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>

    <%
        // records found messsage
        if (sAction.equals("find")) {
            if (foundProductCount > 0) {
    %>
    <div><%=foundProductCount%> <%=getTran("web", "recordsfound", sWebLanguage)%>
    </div>
    <%
            }
        }
    %>

    <br>

    <%-- link to searchProductInStock popup
    <div>
        <a href="javascript:searchProductInStock('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>');"><%=getTran("web.manage","searchInProductStock",sWebLanguage)%></a>
    </div>
    --%>

    <%-- link to searchProduct popup --%>
    <div>
        <a href="javascript:searchProduct('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>');"><%=getTran("web.manage", "searchInProductCatalog", sWebLanguage)%>
        </a>
    </div>

    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>'
               onclick='window.close();'>
    </center>

    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnProductUidField" value="<%=sReturnProductUidField%>">
    <input type="hidden" name="ReturnProductNameField" value="<%=sReturnProductNameField%>">
    <input type="hidden" name="ReturnProductUnitField" value="<%=sReturnProductUnitField%>">
    <input type="hidden" name="ReturnUnitsPerTimeUnitField" value="<%=sReturnUnitsPerTimeUnitField%>">
    <input type="hidden" name="ReturnProductStockUidField" value="<%=sReturnProductStockUidField%>">
</form>

<script>
window.resizeTo(1000, 550);
document.productForm.SearchProductName.focus();
doFind();
<%-- select product --%>
function selectProduct(productUid, productName, productUnit, unitsPerTimeUnit, supplyingServiceUid, supplyingServiceName,
                       productSupplierUid, productSupplierName, unitsPerPackage, productStockUid, serviceStockUid, serviceStockName) {
    var closeWindow = true;

    window.opener.document.all['<%=sReturnProductUidField%>'].value = productUid;
    window.opener.document.all['<%=sReturnProductNameField%>'].value = productName;
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

// set ServiceStock
%>
    var serviceStockUidField = window.opener.document.all['EditServiceStockUid'];
    var serviceStockNameField = window.opener.document.all['EditServiceStockName'];

    if (serviceStockUidField != undefined && serviceStockNameField != undefined) {
        window.opener.document.all['EditServiceStockUid'].value = serviceStockUid;
        window.opener.document.all['EditServiceStockName'].value = serviceStockName;
    }
<%

// set SupplyingService
%>
    var suppServUidField = window.opener.document.all['EditSupplyingServiceUid'];
    var suppServNameField = window.opener.document.all['EditSupplyingServiceName'];

    if (suppServUidField != undefined && suppServNameField != undefined) {
        window.opener.document.all['EditSupplyingServiceUid'].value = supplyingServiceUid;
        window.opener.document.all['EditSupplyingServiceName'].value = supplyingServiceName;
    }
<%

// set productSupplier
if(sReturnSupplierUidField.length() > 0 && sReturnSupplierNameField.length() > 0){
%>
    if (productSupplierUid.length == 0) {
        productSupplierUid = "<%=centralPharmacyCode%>";
        productSupplierName = "<%=centralPharmacyName%>";
    }

    window.opener.document.all['<%=sReturnSupplierUidField%>'].value = productSupplierUid;
    window.opener.document.all['<%=sReturnSupplierNameField%>'].value = productSupplierName;
<%
}

// set unitsPerTimeUnit
if(sReturnUnitsPerTimeUnitField.length() > 0){
%>
    if (unitsPerTimeUnit < 0) {
        window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>'].value = "";
    }
    else {
        window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>'].value = unitsPerTimeUnit;
        isNumber(window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>']);
    }
<%
}

// set unitsPerPackage
if(sReturnUnitsPerPackageField.length() > 0){
%>
    if (unitsPerPackage == 0) unitsPerPackage = 1;

    window.opener.document.all['<%=sReturnUnitsPerPackageField%>'].value = unitsPerPackage;
    isNumber(window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>']);

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
        window.opener.document.all['<%=sReturnProductStockUidField%>'].value = productStockUid;
    }
    else {
        window.opener.document.all['<%=sReturnProductStockUidField%>'].value = "";
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
function searchSupplier(serviceUidField, serviceNameField) {
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode=" + serviceUidField + "&VarText=" + serviceNameField);
}

<%-- popup : search product --%>
function searchProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage) {
    window.opener.searchProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage);
    window.close();
}

<%-- popup : search product in stock --%>
function searchProductInStock(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage) {
    window.opener.searchProductInServiceStock(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackage);
    window.close();
}

<%-- do find --%>
function doFind() {
    productForm.Action.value = "find";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchUserProductShow.jsp', productForm);
}

<%-- clear search fields --%>
function clearSearchFields() {
    productForm.SearchProductName.value = '';
    productForm.SearchProductGroup.value = '';
}

<%-- open edit product unit popup --%>
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
if(userProducts!=null){
if(sOpenerAction.equals("selectProduct")){
// add found products in vector
UserProduct userProduct = null;
for (int i = 0; i < userProducts.size(); i++) {
userProduct = (UserProduct) userProducts.get(i);
if(userProduct.getProduct().getUid().equals(sSelectProductUid)){
    break;
}
}

if(userProduct!=null){
Product product = userProduct.getProduct();
ProductStock productStock;
String sSupplierUid;

//*** supplier ***
String sProductStockUid = checkString(userProduct.getProductStockUid());
String sSupplierName;
if (sProductStockUid.length() > 0) {
    // processing product from product-catalog, productStock available
    productStock = ProductStock.get(sProductStockUid);
    sSupplierUid = checkString(product.getSupplierUid());

    if (sSupplierUid.length() > 0) {
        sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
    }
    else {
        sSupplierUid = checkString(product.getSupplierUid());
        if (sSupplierUid.length() > 0) {
            sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
        }
        else {
            sSupplierUid = checkString(productStock.getServiceStock().getDefaultSupplierUid());
            if (sSupplierUid.length() > 0) {
                sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
            }
            else {
                sSupplierName = "";
            }
        }
    }
}
else {
    // processing product from product-catalog, NO productStock available
    productStock = null;

    sSupplierUid = checkString(product.getSupplierUid());
    if (sSupplierUid.length() > 0) {
        sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
    }
    else {
        sSupplierName = "";
    }
}

// supplyingService & serviceStock
String supplyingServiceUid, supplyingServiceName, serviceStockUid, serviceStockName;
if (productStock != null) {
    supplyingServiceUid = productStock.getSupplierUid();
    supplyingServiceName = getTranNoLink("service", supplyingServiceUid, sWebLanguage);

    serviceStockUid = productStock.getServiceStockUid();
    serviceStockName = productStock.getServiceStock().getName();
}
else {
    supplyingServiceUid = "";
    supplyingServiceName = "";

    serviceStockUid = "";
    serviceStockName = "";
}

%>
selectProduct("<%=product.getUid()%>", "<%=checkString(product.getName())%>", "<%=checkString(product.getUnit())%>", "<%=product.getUnitsPerTimeUnit()%>", "<%=supplyingServiceUid%>", "<%=supplyingServiceName%>", "<%=sSupplierUid%>", "<%=sSupplierName%>", "<%=product.getPackageUnits()%>", "<%=sProductStockUid%>", "<%=serviceStockUid%>", "<%=serviceStockName%>");
<%
            }
        }
    }
%>
</script>
