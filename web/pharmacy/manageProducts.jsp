<%@page import="be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.ProductSchema,
                be.openclinic.common.KeyValue,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.manageproducts","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sProductUid, sUnit, sUnitPrice, sSupplierUid, sSupplierName, sProductGroup;
        DecimalFormat deci = new DecimalFormat("0.00");
        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found products
        Product product;
        for (int i = 0; i < objects.size(); i++) {
            product = (Product) objects.get(i);
            sProductUid = product.getUid();

            // translate unit
            sUnit = getTran("product.unit", product.getUnit(), sWebLanguage);

            // line unit price out
            sUnitPrice = deci.format(product.getUnitPrice());

            // supplier
            sSupplierUid = checkString(product.getSupplierUid());
            if (sSupplierUid.length() > 0) sSupplierName = getTranNoLink("service", sSupplierUid, sWebLanguage);
            else sSupplierName = "";

            // productGroup
            sProductGroup = checkString(product.getProductGroup());
            if (sProductGroup.length() > 0) {
                sProductGroup = getTran("product.productgroup", sProductGroup, sWebLanguage);
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display product in one row ***
            html.append("<tr class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\" title='" + detailsTran + "'>")
                    .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' class='link' title='" + deleteTran + "' onclick=\"doDeleteProduct('" + sProductUid + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + product.getName() + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + sUnit + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + sUnitPrice.replaceAll(",", ".") + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + sCurrency + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + sSupplierName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sProductUid + "');\">" + sProductGroup + "</td>")
                    .append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortCol = "OC_PRODUCT_NAME",
           sDefaultSortDir = "ASC";

    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditProductUid = checkString(request.getParameter("EditProductUid")),
            sEditProductName = checkString(request.getParameter("EditProductName")),
            sEditUnit = checkString(request.getParameter("EditUnit")),
            sEditUnitPrice = checkString(request.getParameter("EditUnitPrice")),
            sEditPackageUnits = checkString(request.getParameter("EditPackageUnits")),
            sEditMinOrderPackages = checkString(request.getParameter("EditMinOrderPackages")),
            sEditSupplierUid = checkString(request.getParameter("EditSupplierUid")),
            sEditTimeUnit = checkString(request.getParameter("EditTimeUnit")),
            sEditTimeUnitCount = checkString(request.getParameter("EditTimeUnitCount")),
            sEditUnitsPerTimeUnit = checkString(request.getParameter("EditUnitsPerTimeUnit")),
            sEditBarcode = checkString(request.getParameter("EditBarcode")),
            sEditPrestationCode = checkString(request.getParameter("EditPrestationCode")),
            sEditPrestationQuantity = checkString(request.getParameter("EditPrestationQuantity")),
            sEditProductGroup = checkString(request.getParameter("EditProductGroup"));

    String  sTime1 = checkString(request.getParameter("time1")),
            sTime2 = checkString(request.getParameter("time2")),
            sTime3 = checkString(request.getParameter("time3")),
            sTime4 = checkString(request.getParameter("time4")),
            sTime5 = checkString(request.getParameter("time5")),
            sTime6 = checkString(request.getParameter("time6"));

    String  sQuantity1 = checkString(request.getParameter("quantity1")),
            sQuantity2 = checkString(request.getParameter("quantity2")),
            sQuantity3 = checkString(request.getParameter("quantity3")),
            sQuantity4 = checkString(request.getParameter("quantity4")),
            sQuantity5 = checkString(request.getParameter("quantity5")),
            sQuantity6 = checkString(request.getParameter("quantity6"));

    ProductSchema productSchema = new ProductSchema();
    if (sTime1.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime1,sQuantity1));
    }
    if (sTime2.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime2,sQuantity2));
    }
    if (sTime3.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime3,sQuantity3));
    }
    if (sTime4.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime4,sQuantity4));
    }
    if (sTime5.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime5,sQuantity5));
    }
    if (sTime6.length() > 0) {
        productSchema.getTimequantities().add(new KeyValue(sTime6,sQuantity6));
    }

    // afgeleide data
    String sEditSupplierName = checkString(request.getParameter("EditSupplierName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("\n\n################## sAction : " + sAction + " ############################");
        Debug.println("* sEditProductUid       : " + sEditProductUid);
        Debug.println("* sEditProductName      : " + sEditProductName);
        Debug.println("* sEditUnit             : " + sEditUnit);
        Debug.println("* sEditUnitPrice        : " + sEditUnitPrice);
        Debug.println("* sEditPackageUnits     : " + sEditPackageUnits);
        Debug.println("* sEditMinOrderPackages : " + sEditMinOrderPackages);
        Debug.println("* sEditSupplierUid      : " + sEditSupplierUid);
        Debug.println("* sEditTimeUnit         : " + sEditTimeUnit);
        Debug.println("* sEditTimeUnitCount    : " + sEditTimeUnitCount);
        Debug.println("* sEditUnitsPerTimeUnit : " + sEditUnitsPerTimeUnit);
        Debug.println("* sEditProductGroup     : " + sEditProductGroup + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sFindProductName, sFindUnit, sFindUnitPriceMin,
            sFindProductGroup, sFindUnitPriceMax, sFindPackageUnits, sFindMinOrderPackages = "",
            sFindSupplierUid, sSelectedProductName = "", sSelectedUnit = "", sSelectedUnitPrice = "",
            sSelectedPackageUnits = "", sSelectedMinOrderPackages = "", sSelectedSupplierUid = "",
            sSelectedTimeUnit = "", sFindSupplierName, sSelectedTimeUnitCount = "",
            sSelectedUnitsPerTimeUnit = "", sSelectedSupplierName = "", sSelectedProductGroup = "", sSelectedBarcode="",
            sSelectedPrestationCode="",sSelectedPrestationQuantity="";

    // get data from form
    sFindProductName = checkString(request.getParameter("FindProductName"));
    sFindUnit = checkString(request.getParameter("FindUnit"));
    sFindUnitPriceMin = checkString(request.getParameter("FindUnitPriceMin"));
    sFindUnitPriceMax = checkString(request.getParameter("FindUnitPriceMax"));
    sFindPackageUnits = checkString(request.getParameter("FindPackageUnits"));
    sFindMinOrderPackages = checkString(request.getParameter("FindMinOrderPackages"));
    sFindSupplierUid = checkString(request.getParameter("FindSupplierUid"));
    sFindSupplierName = checkString(request.getParameter("FindSupplierName"));
    sFindProductGroup = checkString(request.getParameter("FindProductGroup"));

    int foundProductCount = 0;
    StringBuffer productsHtml = null;

    // display options
    boolean displayEditFields = false, displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if (sDisplaySearchFields.length() == 0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    if (Debug.enabled) Debug.println("@@@ displaySearchFields : " + displaySearchFields);

    // sortCol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if (sSortCol.length() == 0) sSortCol = sDefaultSortCol;

    // sortDir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") && sEditProductUid.length() > 0) {
        // create product
        Product product = new Product();
        product.setUid(sEditProductUid);
        product.setName(sEditProductName);
        product.setUnit(sEditUnit);
        product.setSupplierUid(sEditSupplierUid);
        product.setTimeUnit(sEditTimeUnit);
        product.setUpdateUser(activeUser.userid);
        product.setProductGroup(sEditProductGroup);
        product.setBarcode(sEditBarcode);
        product.setPrestationcode(sEditPrestationCode);
        if (sEditUnitPrice.length() > 0) product.setUnitPrice(Double.parseDouble(sEditUnitPrice));
        if (sEditPackageUnits.length() > 0) product.setPackageUnits(Integer.parseInt(sEditPackageUnits));
        if (sEditMinOrderPackages.length() > 0) product.setMinimumOrderPackages(Integer.parseInt(sEditMinOrderPackages));
        if (sEditPrestationQuantity.length() > 0) product.setPrestationquantity(Integer.parseInt(sEditPrestationQuantity));
        if (sEditTimeUnitCount.length() > 0) product.setTimeUnitCount(Integer.parseInt(sEditTimeUnitCount));
        if (sEditUnitsPerTimeUnit.length() > 0) product.setUnitsPerTimeUnit(Double.parseDouble(sEditUnitsPerTimeUnit));

        // does product exist ?
        String existingProductUid = product.exists();
        boolean productExists = existingProductUid.length() > 0;

        if (sEditProductUid.equals("-1")) {
            //***** insert new product *****
            if (!productExists) {
                product.store();

                // save schema
                productSchema.setProductuid(product.getUid());
                productSchema.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject new addition thru update *****
            else {
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>" + getTran("web.manage", "productexists", sWebLanguage) + "</font>";
            }
        }
        else {
            //***** update existing product *****
            if (!productExists) {
                product.store(false);

                // save schema
                productSchema.setProductuid(product.getUid());
                productSchema.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject double record thru update *****
            else {
                if (sEditProductUid.equals(existingProductUid)) {
                    // save schema
                    productSchema.setProductuid(product.getUid());
                    productSchema.store();

                    product.store(false);
                    msg = getTran("web", "dataissaved", sWebLanguage);

                    sAction = "findShowOverview"; // showDetails
                }
                else {
                    // tried to update one product with exact the same data as an other product
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>" + getTran("web.manage", "productexists", sWebLanguage) + "</font>";
                }
            }
        }

        sEditProductUid = product.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete") && sEditProductUid.length() > 0) {
        Product.delete(sEditProductUid);
        ProductSchema productSchemaToDelete = ProductSchema.getSingleProductSchema(sEditProductUid);
        productSchemaToDelete.delete();

        msg = getTran("web", "dataisdeleted", sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if (sAction.equals("sort")) {
        displayEditFields = false;
        sAction = "find";
    }

    //-- FIND -------------------------------------------------------------------------------------
    if (sAction.startsWith("find")) {
        displaySearchFields = true;
        displayFoundRecords = true;

        if (sAction.equals("findShowOverview")) {
            displayEditFields = false;

            sFindProductName = "";
            sFindUnit = "";
            sFindUnitPriceMin = "";
            sFindUnitPriceMax = "";
            sFindPackageUnits = "";
            sFindMinOrderPackages = "";
            sFindSupplierUid = "";
            sFindProductGroup = "";
        }

        Vector products = Product.find(sFindProductName, sFindUnit, sFindUnitPriceMin, sFindUnitPriceMax, sFindPackageUnits,
               sFindMinOrderPackages, sFindSupplierUid, sFindProductGroup, sSortCol, sSortDir);
        productsHtml = objectsToHtml(products, sWebLanguage);
        foundProductCount = products.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if (sAction.startsWith("showDetails")) {
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if (sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")) {
            Product product = Product.get(sEditProductUid);

            if (product != null) {
                sSelectedProductName = checkString(product.getName());
                sSelectedUnit = checkString(product.getUnit());
                sSelectedUnitPrice = (product.getUnitPrice() < 0 ? "" : product.getUnitPrice() + "");
                sSelectedPackageUnits = (product.getPackageUnits() <= 0 ? "" : product.getPackageUnits() + "");
                sSelectedMinOrderPackages = (product.getMinimumOrderPackages() < 0 ? "" : product.getMinimumOrderPackages() + "");
                sSelectedSupplierUid = checkString(product.getSupplierUid());
                sSelectedTimeUnit = checkString(product.getTimeUnit());
                sSelectedTimeUnitCount = (product.getTimeUnitCount() < 0 ? "" : product.getTimeUnitCount() + "");
                sSelectedUnitsPerTimeUnit = (product.getUnitsPerTimeUnit() < 0 ? "" : product.getUnitsPerTimeUnit() + "");
                sSelectedProductGroup = checkString(product.getProductGroup());
                sSelectedSupplierName = getTranNoLink("Service", sSelectedSupplierUid, sWebLanguage);
                sSelectedBarcode = checkString(product.getBarcode());
                sSelectedPrestationCode = checkString(product.getPrestationcode());
                sSelectedPrestationQuantity = product.getPrestationquantity()+"";
            }

            productSchema = ProductSchema.getSingleProductSchema(product.getUid());
        }
        else if (sAction.equals("showDetailsAfterAddReject")) {
            // do not get data from DB, but show data that were allready on form
            sSelectedProductName = sEditProductName;
            sSelectedUnit = sEditUnit;
            sSelectedUnitPrice = sEditUnitPrice;
            sSelectedPackageUnits = sEditPackageUnits;
            sSelectedMinOrderPackages = sEditMinOrderPackages;
            sSelectedSupplierUid = sEditSupplierUid;
            sSelectedTimeUnit = sEditTimeUnit;
            sSelectedTimeUnitCount = sEditTimeUnitCount;
            sSelectedUnitsPerTimeUnit = sEditUnitsPerTimeUnit;
            sSelectedProductGroup = sEditProductGroup;
            sSelectedSupplierName = sEditSupplierName;
            sSelectedBarcode = sEditBarcode;
            sSelectedPrestationCode = sEditPrestationCode;
            sSelectedPrestationQuantity = sEditPrestationQuantity;
        }
        else {
            // do not get data from DB, but show data that were allready in the search-form
            sSelectedProductName = sFindProductName;
            sSelectedUnit = sFindUnit;
            sSelectedUnitPrice = "";
            sSelectedPackageUnits = sFindPackageUnits;
            sSelectedMinOrderPackages = sFindMinOrderPackages;
            sSelectedSupplierUid = sFindSupplierUid;
            sSelectedTimeUnit = "";
            sSelectedTimeUnitCount = "";
            sSelectedUnitsPerTimeUnit = "";
            sSelectedBarcode = "";
            sSelectedPrestationCode = "";
            sSelectedPrestationQuantity = "0";

            sSelectedProductGroup = sFindProductGroup;
            sSelectedSupplierName = sFindSupplierName;
        }
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown;
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSaveProduct();}\"";
    }
    else{
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearchProduct('"+sDefaultSortCol+"');}\"";
    }
%>
<form name="transactionForm" id="transactionForm" method="post" <%=sOnKeyDown%> <%=(displaySearchFields?"onClick=\"clearMessage();\"":"onClick=\"setSaveButton();clearMessage();\" onKeyUp=\"setSaveButton();\"")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","ManageProducts",sWebLanguage," doBack();")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        if(displaySearchFields){
            %>
                <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(enterEvent(event,13)){doSearchProduct(\'<%=sDefaultSortCol%>\');}';" onKeyDown="if(enterEvent(event,13)){doSearchProduct('<%=sDefaultSortCol%>');}">
                    <%-- product name --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","productName",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindProductName" size="<%=sTextWidth%>" maxLength="255" value="<%=sFindProductName%>">
                        </td>
                    </tr>
                    <%-- unit --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","unit",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="FindUnit"  >
                                <option value=""></option>
                                <%=ScreenHelper.writeSelect("product.unit",sFindUnit,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- UnitPrice --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","UnitPrice",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=getTran("web","from",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindUnitPriceMin" size="5" maxLength="5" value="<%=sFindUnitPriceMin%>" onKeyUp="isNumber(this);">
                            <%=getTran("web","till",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindUnitPriceMax" size="5" maxLength="5" value="<%=sFindUnitPriceMax%>" onKeyUp="isNumber(this);">
                            <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
                        </td>
                    </tr>
                    <%-- PackageUnits --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","PackageUnits",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindPackageUnits" size="5" maxLength="5" value="<%=sFindPackageUnits%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- MinOrderPackages (long translation, so force widths) --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","MinOrderPackages",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2" width="100%">
                            <input class="text" type="text" name="FindMinOrderPackages" size="5" maxLength="5" value="<%=sFindMinOrderPackages%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>

                    <%-- supplier --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindSupplierUid" value="<%=sFindSupplierUid%>">
                            <input class="text" type="text" name="FindSupplierName" readonly size="<%=sTextWidth%>" value="<%=sFindSupplierName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('FindSupplierUid','FindSupplierName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindSupplierUid.value='';transactionForm.FindSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- productGroup --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","productgroup",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="FindProductGroup">
                                <option value=""></option>
                                <%=ScreenHelper.writeSelect("product.productgroup",sSelectedProductGroup,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearchProduct('<%=sDefaultSortCol%>');">
                            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                            <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNewProduct();">
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                <br>
            <%
        }
        else{
            //*** search fields as hidden fields to be able to revert to the overview ***
            %>
                <input type="hidden" name="FindProductName" value="<%=sFindProductName%>">
                <input type="hidden" name="FindUnit" value="<%=sFindUnit%>">
                <input type="hidden" name="FindUnitPriceMin" value="<%=sFindUnitPriceMin%>">
                <input type="hidden" name="FindUnitPriceMax" value="<%=sFindUnitPriceMax%>">
                <input type="hidden" name="FindPackageUnits" value="<%=sFindPackageUnits%>">
                <input type="hidden" name="FindMinOrderPackages" value="<%=sFindMinOrderPackages%>">
                <input type="hidden" name="FindSupplierUid" value="<%=sFindSupplierUid%>">
                <input type="hidden" name="FindSupplierName" value="<%=sFindSupplierName%>">
                <input type="hidden" name="FindProductGroup" value="<%=sFindProductGroup%>">
            <%
        }

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(displayFoundRecords){
            if(foundProductCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="22">&nbsp;</td>
                            <td width="25%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_PRODUCT_NAME');"><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_NAME")?"<"+sSortDir+">":"")%><%=getTran("Web","productName",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_NAME")?"</"+sSortDir+">":"")%></a></td>
                            <td width="15%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_PRODUCT_UNIT');"><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_UNIT")?"<"+sSortDir+">":"")%><%=getTran("Web","Unit",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_UNIT")?"</"+sSortDir+">":"")%></a></td>
                            <td width="1%"><a href="#" title="<%=sortTran%>" class="underlined"><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_UNITPRICE")?"<"+sSortDir+">":"")%><%=getTran("Web","unitprice",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_UNITPRICE")?"</"+sSortDir+">":"")%></a></td>
                            <td/>
                            <td width="28%"><%=getTran("Web","supplier",sWebLanguage)%></td>
                            <td width="20%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_PRODUCT_PRODUCTGROUP');"><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_PRODUCTGROUP")?"<"+sSortDir+">":"")%><%=getTran("Web","productGroup",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_PRODUCT_PRODUCTGROUP")?"</"+sSortDir+">":"")%></a></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=productsHtml%>
                        </tbody>
                    </table>
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundProductCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundProductCount > 20){
                            // link to top of page
                            %>
                                <span style="width:51%;text-align:right;">
                                    <a href="#topp" class="topbutton">&nbsp;</a>
                                </span>
                                <br>
                            <%
                        }
                    %>
                <%
            }
            else{
                // no records found
                %>
                <%=getTran("web","norecordsfound",sWebLanguage)%>
                <%
            }
        }

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            DecimalFormat doubleFormat = new DecimalFormat("#.#");
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- product name --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","productName",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditProductName" size="<%=sTextWidth%>" maxLength="255" value="<%=sSelectedProductName%>">
                        </td>
                    </tr>
                    <%-- unit --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","unit",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <select class="text" name="EditUnit" onChange="setEditUnitsPerTimeUnitLabel();">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelect("product.unit",sSelectedUnit,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- UnitPrice --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","UnitPrice",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitPrice" size="5" maxLength="5" value="<%=sSelectedUnitPrice%>" onKeyUp="isNumber(this);">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
                        </td>
                    </tr>
                    <%-- PackageUnits --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","PackageUnits",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditPackageUnits" size="5" maxLength="5" value="<%=sSelectedPackageUnits%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- MinOrderPackages (long translation, so force widths) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","MinOrderPackages",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2" width="100%">
                            <input class="text" type="text" name="EditMinOrderPackages" size="5" maxLength="5" value="<%=sSelectedMinOrderPackages%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- supplier --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditSupplierUid" value="<%=sSelectedSupplierUid%>">
                            <input class="text" type="text" name="EditSupplierName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSupplierName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('EditSupplierUid','EditSupplierName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditSupplierUid.value='';transactionForm.EditSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- productGroup --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","productGroup",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <select class="text" name="EditProductGroup">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelect("product.productgroup",sSelectedProductGroup,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- prescription-rule --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","prescriptionrule",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%-- Units Per Time Unit --%>
                            <input type="text" class="text" style="vertical-align:-1px;" name="EditUnitsPerTimeUnit" value="<%=(sSelectedUnitsPerTimeUnit.length()>0?(doubleFormat.format(Double.parseDouble(sSelectedUnitsPerTimeUnit))).replaceAll(",","."):"")%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                            <span id="EditUnitsPerTimeUnitLabel"></span>
                            <%-- Time Unit Count --%>
                            &nbsp;<%=getTran("web","per",sWebLanguage)%>
                            <input type="text" class="text" style="vertical-align:-1px;" name="EditTimeUnitCount" value="<%=sSelectedTimeUnitCount%>" size="5" maxLength="5" onKeyUp="isInteger(this);"/>
                            <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
                            <select class="text" name="EditTimeUnit" onChange="setEditUnitsPerTimeUnitLabel();setEditTimeUnitCount();" style="vertical-align:-3px;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("prescription.timeunit",sSelectedTimeUnit,sWebLanguage)%>
                            </select>
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" style="vertical-align:-4px;" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearDescriptionRule();">
                        </td>
                    </tr>
                    <%-- schema --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","schema",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <table>
                                <tr>
                                    <td><input class="text" type="text" name="time1" value="<%=productSchema.getTimeQuantity(0).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                    <td><input class="text" type="text" name="time2" value="<%=productSchema.getTimeQuantity(1).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                    <td><input class="text" type="text" name="time3" value="<%=productSchema.getTimeQuantity(2).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                    <td><input class="text" type="text" name="time4" value="<%=productSchema.getTimeQuantity(3).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                    <td><input class="text" type="text" name="time5" value="<%=productSchema.getTimeQuantity(4).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                    <td><input class="text" type="text" name="time6" value="<%=productSchema.getTimeQuantity(5).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                </tr>
                                <tr>
                                    <td><input class="text" type="text" name="quantity1" value="<%=productSchema.getTimeQuantity(0).getValue()%>" size="2">#</td>
                                    <td><input class="text" type="text" name="quantity2" value="<%=productSchema.getTimeQuantity(1).getValue()%>" size="2">#</td>
                                    <td><input class="text" type="text" name="quantity3" value="<%=productSchema.getTimeQuantity(2).getValue()%>" size="2">#</td>
                                    <td><input class="text" type="text" name="quantity4" value="<%=productSchema.getTimeQuantity(3).getValue()%>" size="2">#</td>
                                    <td><input class="text" type="text" name="quantity5" value="<%=productSchema.getTimeQuantity(4).getValue()%>" size="2">#</td>
                                    <td><input class="text" type="text" name="quantity6" value="<%=productSchema.getTimeQuantity(5).getValue()%>" size="2">#</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <%-- Barcode --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","barcode",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditBarcode" size="50" maxLength="50" value="<%=sSelectedBarcode%>" >
                        </td>
                    </tr>
                    <%-- PrestationCode --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","prestation",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditPrestationCode" size="10" maxLength="50" value="<%=sSelectedPrestationCode%>" > x <input class="text" type="text" name="EditPrestationQuantity" size="3" maxLength="10" value="<%=sSelectedPrestationQuantity%>" >
                        </td>
                    </tr>
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                    // existing product : display saveButton with save-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSaveProduct();">
                                        <input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDeleteProduct('<%=sEditProductUid%>');">
                                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();">
                                    <%
                                }
                                else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                    // new product : display saveButton with add-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAddProduct();">
                                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();">
                                    <%
                                }
                            %>
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                <script>
                  setEditUnitsPerTimeUnitLabel();

                  <%-- set editUnitsPerTimeUnitLabel --%>
                  function setEditUnitsPerTimeUnitLabel(){
                    var unitTran;

                    if(transactionForm.EditUnit.value.length==0){
                      unitTran = '<%=getTran("web","units",sWebLanguage)%>';
                    }
                    else{
                      <%
                          Vector unitTypes = ScreenHelper.getProductUnitTypes(sWebLanguage);

                          for(int i=0; i<unitTypes.size(); i++){
                              %>
                                  var unitTran<%=(i+1)%> = "<%=getTran("product.units",(String)unitTypes.get(i),sWebLanguage).toLowerCase()%>"
                                  if(transactionForm.EditUnit.value=="<%=unitTypes.get(i)%>") unitTran = unitTran<%=(i+1)%>;
                              <%
                          }
                      %>
                    }
                    document.getElementById("EditUnitsPerTimeUnitLabel").innerHTML = unitTran;
                  }

                  <%-- set setEditTimeUnitCount --%>
                  function setEditTimeUnitCount(){
                    if(transactionForm.EditTimeUnit.selectedIndex > 0){
                      if(transactionForm.EditTimeUnitCount.value.length == 0){
                        transactionForm.EditTimeUnitCount.value = "1";
                      }
                    }
                  }

                  <%-- clear description rule --%>
                  function clearDescriptionRule(){
                    transactionForm.EditUnitsPerTimeUnit.value = '';
                    transactionForm.EditTimeUnitCount.value = '';
                    transactionForm.EditTimeUnit.value = '';
                  }
                </script>

                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditProductUid" value="<%=sEditProductUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditProductName.focus();<%
      }

      if(displaySearchFields){
          %>transactionForm.FindProductName.focus();<%
      }
  %>

  <%-- DO ADD PRODUCT --%>
  function doAddProduct(){
    transactionForm.EditProductUid.value = "-1";
    doSaveProduct();
  }

  <%-- DO SAVE PRODUCT --%>
  function doSaveProduct(){
    if(checkProductFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditProductName.value.length==0){
        transactionForm.EditProductName.focus();
      }
      else if(transactionForm.EditUnit.value.length==0){
        transactionForm.EditUnit.focus();
      }
      else if(transactionForm.EditUnitPrice.value.length==0){
        transactionForm.EditUnitPrice.focus();
      }
      else if(transactionForm.EditPackageUnits.value.length==0){
        transactionForm.EditPackageUnits.focus();
      }
      else if(transactionForm.EditProductGroup.value.length==0){
        transactionForm.EditProductGroup.focus();
      }
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkProductFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditProductName.value.length>0 ||
       !transactionForm.EditUnit.value.length>0 ||
       !transactionForm.EditUnitPrice.value.length>0 ||
       !transactionForm.EditPackageUnits.value.length>0 ||
       !transactionForm.EditProductGroup.value.length>0){
      maySubmit = false;

      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }

    <%-- one rule-field specified -> all rule-fields specified --%>
    if(transactionForm.EditUnitsPerTimeUnit.value.length > 0 ||
       transactionForm.EditTimeUnitCount.value.length > 0 ||
       transactionForm.EditTimeUnit.value.length > 0){
      if(!transactionForm.EditUnitsPerTimeUnit.value.length > 0 ||
         !transactionForm.EditTimeUnitCount.value.length > 0 ||
         !transactionForm.EditTimeUnit.value.length > 0){
        maySubmit = false;

        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");

        if(transactionForm.EditUnitsPerTimeUnit.value.length == 0){
          transactionForm.EditUnitsPerTimeUnit.focus();
        }
        else if(transactionForm.EditTimeUnitCount.value.length == 0){
          transactionForm.EditTimeUnitCount.focus();
        }
        else{
          transactionForm.EditTimeUnit.focus();
        }
      }
    }

    return maySubmit;
  }

  <%-- DO DELETE PRODUCT --%>
  function doDeleteProduct(productUid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");


    if(answer==1){
      transactionForm.EditProductUid.value = productUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO NEW PRODUCT --%>
  function doNewProduct(){
    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(productUid){
    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;

    transactionForm.EditProductUid.value = productUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.DisplaySearchFields.value = "true";
    transactionForm.submit();
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindProductName.value = "";
    transactionForm.FindUnit.value = "";
    transactionForm.FindUnitPriceMin.value = "";
    transactionForm.FindUnitPriceMax.value = "";
    transactionForm.FindPackageUnits.value = "";
    transactionForm.FindMinOrderPackages.value = "";
    transactionForm.FindProductGroup.value = "";

    transactionForm.FindSupplierUid.value = "";
    transactionForm.FindSupplierName.value = "";
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditProductName.value = "";
    transactionForm.EditUnit.value = "";
    transactionForm.EditUnitPrice.value = "";
    transactionForm.EditPackageUnits.value = "";
    transactionForm.EditMinOrderPackages.value = "";

    transactionForm.EditSupplierUid.value = "";
    transactionForm.EditSupplierName.value = "";

    transactionForm.EditTimeUnit.value = "";
    transactionForm.EditTimeUnitCount.value = "";
    transactionForm.EditUnitsPerTimeUnit.value = "";
    transactionForm.EditProductGroup.value = "";
  }

  <%-- DO SORT --%>
  function doSort(sortCol){
    transactionForm.Action.value = "sort";
    transactionForm.SortCol.value = sortCol;

    if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
    else                                       transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- DO SEARCH PRODUCT --%>
  function doSearchProduct(sortCol){
    if(transactionForm.FindProductName.value.length>0 ||
       transactionForm.FindUnit.value.length>0 ||
       transactionForm.FindUnitPriceMin.value.length>0 ||
       transactionForm.FindUnitPriceMax.value.length>0 ||
       transactionForm.FindPackageUnits.value.length>0 ||
       transactionForm.FindMinOrderPackages.value.length>0 ||
       transactionForm.FindSupplierUid.value.length>0 ||
       transactionForm.FindProductGroup.value.length>0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.newButton.disabled = true;

      transactionForm.Action.value = "find";
      transactionForm.SortCol.value = sortCol;
      openSearchInProgressPopup();
      transactionForm.submit();
    }
    else{
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }
  }

  <%-- popup : search supplier --%>
  function searchSupplier(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&SearchExternalServices=true&VarCode="+serviceUidField+"&VarText="+serviceNameField+"&FindParentCode=<%=checkString(MedwanQuery.getInstance().getConfigString("serviceGroupProviders"))%>");
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK TO OVERVIEW --%>
  function doBackToOverview(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web","areyousuretodiscard",sWebLanguage)%>')){
      transactionForm.Action.value = "find";
      transactionForm.DisplaySearchFields.value = "true";
      transactionForm.submit();
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    <%
        // close if this window is a popup
        if(checkString(request.getParameter("Close")).length() > 0){
            out.print("window.close();");
        }
    %>
    window.location.href = "<c:url value="/main.do"/>?Page=pharmacy/manageProducts.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>

<%=writeJSButtons("transactionForm","saveButton")%>