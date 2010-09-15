<%@page import="be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.UserProduct,
                java.util.Vector,
                java.util.Collections" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.manageuserproducts","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sUnit = "", sUnitPrice = "", sSupplierUid, sSupplierName = "",
                sProductGroup = "", sProductStockUid, sProductName;
        DecimalFormat deci = new DecimalFormat("0.00");
        UserProduct userProduct;
        Product product;
        double dUnitPrice;

        // frequently used translations
        String deleteTran = getTranNoLink("Web", "delete", sWebLanguage);
        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");

        // run thru objects
        for (int i = 0; i < objects.size(); i++) {
            userProduct = (UserProduct) objects.get(i);
            product = userProduct.getProduct();

            if (product != null) {
                sProductName = product.getName();

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
                            sSupplierUid = checkString(userProduct.getProductStock().getServiceStock().getDefaultSupplierUid());
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
                    sSupplierUid = checkString(product.getSupplierUid());
                    if (sSupplierUid.length() > 0) {
                        sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                    }
                    else {
                        sSupplierName = "";
                    }
                }

                // product group
                sProductGroup = checkString(product.getProductGroup());
                if (sProductGroup.length() > 0) {
                    sProductGroup = getTran("product.productgroup", sProductGroup, sWebLanguage);
                }
            }
            else {
                sProductName = "<font color='red'>" + getTran("web.manage", "unexistingproduct", sWebLanguage) + "</font>";
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else                   sClass = "";

            //*** display product in one row ***
            html.append("<tr class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\">")
                .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' class='link' title='" + deleteTran + "' onclick=\"doDeleteProduct('" + userProduct.getProductUid() + "');\">")
                .append(" <td>" + sProductName + "</td>")
                .append(" <td>" + sUnit + "</td>")
                .append(" <td style='text-align:right;'>" + sUnitPrice + "&nbsp;" + sCurrency + "&nbsp;</td>")
                .append(" <td>" + sSupplierName + "</td>")
                .append(" <td>" + (userProduct.getProductStock() == null ? "" : userProduct.getProductStock().getServiceStock().getName()) + "</td>")
                .append(" <td>" + sProductGroup + "</td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortDir = "DESC";

    String sAction = checkString(request.getParameter("Action"));
    if (sAction.length() == 0) sAction = "find"; // display all userproducts by default

    // retreive form data
    String sEditProductUid = checkString(request.getParameter("EditProductUid")),
            sEditProductName = checkString(request.getParameter("EditProductName")),
            sEditProductStockUid = checkString(request.getParameter("EditProductStockUid"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("\n################## mngUserProducts : " + sAction + " ################");
        Debug.println("* sEditProductUid      : " + sEditProductUid);
        Debug.println("* sEditProductName     : " + sEditProductName);
        Debug.println("* sEditProductStockUid : " + sEditProductStockUid + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String saveMsg = "", searchMsg = "", sSelectedProductName = "", sSelectedProductUid = "",
            sSelectedProductStockUid = "";
    int foundProductCount = 0;
    StringBuffer userProductsHtml = null;

    // sortDir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") && sEditProductUid.length() > 0) {
        // create new userProduct
        UserProduct userProduct = new UserProduct();
        userProduct.setUserId(activeUser.userid);
        userProduct.setProductUid(sEditProductUid);
        userProduct.setProductStockUid(sEditProductStockUid);

        // does userProduct exist ?
        String existingUserProductUid = userProduct.exists();
        boolean userProductExists = existingUserProductUid.length() > 0;

        //***** update existing product *****
        if (!userProductExists) {
            userProduct.store(false);

            // show saved data
            sAction = "findShowOverview";
            saveMsg = getTran("web", "dataissaved", sWebLanguage);
        } else {
            // store anyway, to update productStockUid that might not be saved yet.
            userProduct.store();

            // display product exists-message
            sAction = "findShowOverview";
            saveMsg = getTran("web.manage", "productexists", sWebLanguage);

            sSelectedProductUid = sEditProductUid;
            sSelectedProductName = sEditProductName;
            sSelectedProductStockUid = sEditProductStockUid;
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete") && sEditProductUid.length() > 0) {
        UserProduct.delete(activeUser.userid, sEditProductUid);

        saveMsg = getTran("web", "dataisdeleted", sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if (sAction.equals("sort")) {
        sAction = "find";
    }

    //-- FIND -------------------------------------------------------------------------------------
    if (sAction.startsWith("find")) {
        Vector userProducts = UserProduct.find(activeUser.userid);
        Collections.sort(userProducts);
        if (sSortDir.equals("ASC")) Collections.reverse(userProducts);
        userProductsHtml = objectsToHtml(userProducts, sWebLanguage);
        foundProductCount = userProducts.size();
    }
%>

<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doAddProduct();return false;}" onClick="clearMessage();">
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","ManageUserProducts",sWebLanguage,"")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(foundProductCount > 0){
            String sortTran = getTran("web","clicktosort",sWebLanguage);
            
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%-- clickable header --%>
                    <tr class="admin">
                        <td width="22"/>
                        <td width="25%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort();"><<%=sSortDir%>><%=getTran("Web","productName",sWebLanguage)%></<%=sSortDir%>></a></td>
                        <td width="10%"><%=getTran("Web","Unit",sWebLanguage)%></td>
                        <td width="10%" style="text-align:right;"><%=getTran("Web","unitprice",sWebLanguage)%>&nbsp;</td>
                        <td width="20%"><%=getTran("Web","supplier",sWebLanguage)%></td>
                        <td width="20%"><%=getTran("Web","ServiceStock",sWebLanguage)%></td>
                        <td width="15%"><%=getTran("Web","productGroup",sWebLanguage)%></td>
                    </tr>
                    <%=userProductsHtml%>
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
                <br><br>
            <%
        }
        else{
            // no records found
            %>
                <%=getTran("web","norecordsfound",sWebLanguage)%>
                <br><br>
            <%
        }
    %>
    <%-- ADD PRODUCT FIELD ----------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- sub-title --%>
        <tr class="admin">
            <td colspan="2">&nbsp;&nbsp;<%=getTran("web.manage","AddUserProducts",sWebLanguage)%></td>
        </tr>
        <%-- product --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="EditProductUid" value="<%=sSelectedProductUid%>">
                <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                <%-- buttons --%>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductInServiceStock('EditProductUid','EditProductName','','','','EditProductStockUid');">
                <img src="<c:url value="/_img/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doAddProduct();">
            </td>
        </tr>
    </table>
    <%-- display message --%>
    <span id="saveMsgArea"><%=saveMsg%></span>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%-- DO ADD PRODUCT --%>
  function doAddProduct(){
    if(checkProductFields()){
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      transactionForm.EditProductName.focus();
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkProductFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditProductUid.value.length>0 || !transactionForm.EditProductName.value.length>0){
      maySubmit = false;

      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
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

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditProductUid.value = "";
    transactionForm.EditProductName.value = "";
  }

  <%-- DO SORT --%>
  function doSort(){
    transactionForm.Action.value = "sort";

    if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
    else                                       transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(searchMsg.length() > 0){
            %>document.getElementById('searchMsgArea').innerHTML = "";<%
        }

        if(saveMsg.length() > 0){
            %>document.getElementById('saveMsgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value="/main.do"/>?Page=pharmacy/manageUserProducts.jsp&ts=<%=getTs()%>";
  }

  <%-- popup : search product in service stock --%>
  function searchProductInServiceStock(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField+
              "&DisplaySearchUserProductsLink=false"+
              "&DisplayProductsOfDoctorService=true"+
              "&DisplayProductsOfPatientService=false";

    if(productUnitField!=undefined){
      url = url+"&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url = url+"&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url = url+"&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url = url+"&ReturnProductStockUidField="+productStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField+
              "&DisplaySearchProductInStockLink=true"+
              "&DisplaySearchUserProductsLink=false";

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    openPopup(url);
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>