<%@page import="java.text.DecimalFormat,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.Product,
                java.util.Vector,
                java.util.Collections" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%
    String sAction = checkString(request.getParameter("Action"));
    //if(sAction.length()==0) sAction = "find"; // default action

    String sOpenerAction = checkString(request.getParameter("OpenerAction"));
    
    // get data from form
    String sSearchProductName  = checkString(request.getParameter("SearchProductName")),
           sSearchServiceUid   = checkString(request.getParameter("SearchServiceUid")),
           sSearchServiceName  = checkString(request.getParameter("SearchServiceName")),
           sSearchProductGroup = checkString(request.getParameter("SearchProductGroup")),
           sSelectProductUid   = checkString(request.getParameter("SelectProductUid"));

    // get data from calling url or hidden fields in form
    String sReturnProductUidField        = checkString(request.getParameter("ReturnProductUidField")),
            sReturnProductNameField      = checkString(request.getParameter("ReturnProductNameField")),
            sReturnProductUnitField      = checkString(request.getParameter("ReturnProductUnitField")),
            sReturnUnitsPerPackageField  = checkString(request.getParameter("ReturnUnitsPerPackageField")),
            sReturnUnitsPerTimeUnitField = checkString(request.getParameter("ReturnUnitsPerTimeUnitField")),
            sReturnSupplierUidField      = checkString(request.getParameter("ReturnSupplierUidField")),
            sReturnSupplierNameField     = checkString(request.getParameter("ReturnSupplierNameField")),
            sReturnProductStockUidField  = checkString(request.getParameter("ReturnProductStockUidField"));

    // display option
    String sDisplaySearchUserProductsLink = checkString(request.getParameter("DisplaySearchUserProductsLink"));
    boolean displaySearchUserProductsLink = true;
    if (sDisplaySearchUserProductsLink.equals("false")) {
        displaySearchUserProductsLink = false;
    }

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           centralPharmacyName = getTranNoLink("Service", centralPharmacyCode, sWebLanguage);

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## searchProductInStock : " + sAction + " #########");
        System.out.println("* sSearchProductName  : " + sSearchProductName);
        System.out.println("* sSearchServiceUid   : " + sSearchServiceUid);
        System.out.println("* sSearchServiceName  : " + sSearchServiceName);
        System.out.println("* sSearchProductGroup : " + sSearchProductGroup);
        System.out.println("* sOpenerAction       : "+sOpenerAction);
        System.out.println("* sSelectProductUid   : "+sSelectProductUid+"\n");

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

    // display products of user-service by default (on first page load)
    boolean displayProductsOfDoctorService = checkString(request.getParameter("DisplayProductsOfDoctorService")).equals("true");

    if (sAction.length() == 0) {
        if (displayProductsOfDoctorService) {
            sSearchServiceUid = activeUser.activeService.code;
            sSearchServiceName = getTranNoLink("service", sSearchServiceUid, sWebLanguage);
        }
    }

    // display products of patient-service by default (on first page load)
    boolean displayProductsOfPatientService = checkString(request.getParameter("DisplayProductsOfPatientService")).equals("true");

    if (sAction.length() == 0) {
        if (displayProductsOfPatientService) {
            if (activePatient.isHospitalized()) {
                sSearchServiceUid = activePatient.getActiveDivision().code;
                sSearchServiceName = getTranNoLink("service", sSearchServiceUid, sWebLanguage);
            }
            else {
                // search central pharmacy by default if user is not hospitalized
                sSearchServiceUid = centralPharmacyCode;
                sSearchServiceName = centralPharmacyName;
            }
        }
    }

    if (sAction.length() == 0) sAction = "find"; // default action

    StringBuffer sOut = new StringBuffer();
    int iTotal = 0;

    //#############################################################################################
    //### ACTIONS #################################################################################
    //#############################################################################################
    //--- FIND ------------------------------------------------------------------------------------
    Vector serviceStocks = null;
    if (sAction.equals("find")) {
        serviceStocks = Service.getActiveServiceStocks(sSearchServiceUid);

        // run thru found serviceStocks collecting all belonging productStocks
        Vector allProductStocks = new Vector();
        ServiceStock serviceStock;
        for (int i = 0; i < serviceStocks.size(); i++) {
            serviceStock = (ServiceStock) serviceStocks.get(i);
            allProductStocks.addAll(serviceStock.getProductStocks());
        }

        // variables
        String sClass = "1", sUnitTran, supplyingServiceUid, supplyingServiceName = "",
                sProductGroup, sUnitsPerPackage, sSupplierName = "", sSupplierUid,
                sUnitsPerTimeUnit, sProductStockUid;
        DecimalFormat priceDeci = new DecimalFormat("0.00"),
                      unitCountDeci = new DecimalFormat("#.#");
        ProductStock productStock;
        Product product;

        // frequently used translations
        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€"),
               chooseTran = getTranNoLink("web", "choose", sWebLanguage);

        // header
        sOut.append("<tr class='admin'>")
            .append(" <td width='20%'>" + getTran("web", "product", sWebLanguage) + "</td>")
            .append(" <td width='10%'>" + getTran("web", "unit", sWebLanguage) + "</td>")
            .append(" <td width='10%' style='text-align:right;'>" + getTran("web", "unitprice", sWebLanguage) + "&nbsp;</td>")
            .append(" <td width='27%'>" + getTran("web", "service", sWebLanguage) + "</td>")
            .append(" <td width='12%'>" + getTran("web", "servicestock", sWebLanguage) + "</td>")
            .append(" <td align='right' width='6%'>" + getTran("web", "level", sWebLanguage) + "&nbsp;&nbsp;</td>")
            .append(" <td width='15%'>" + getTran("web", "productGroup", sWebLanguage) + "</td>")
            .append("</tr>");

        // tbody
        sOut.append("<tbody onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\">");

        // sort found products on their name
        Collections.sort(allProductStocks);

        // run thru found productStocks, displaying the product they stock
        for (int i = 0; i < allProductStocks.size(); i++) {
            productStock = (ProductStock) allProductStocks.get(i);
            product = productStock.getProduct();

            if (product != null) {
                // filter out products depending on their productGroup ?
                boolean productGroupOK;
                if (sSearchProductGroup.length() == 0) {
                    productGroupOK = true;
                }
                else {
                    productGroupOK = (checkString(product.getProductGroup()).equals(sSearchProductGroup));
                }

                // only display products complying the searched productName AND/OR the searched productGroup
                if (product.getName().toLowerCase().startsWith(sSearchProductName.toLowerCase()) && productGroupOK) {
                    serviceStock = productStock.getServiceStock();
                    sUnitsPerPackage = product.getPackageUnits() + "";
                    sProductStockUid = productStock.getUid();

                    // translate unit
                    sUnitTran = getTranNoLink("product.unit", product.getUnit(), sWebLanguage);

                    // supplyingService
                    supplyingServiceUid = serviceStock.getService().code;
                    if (supplyingServiceUid.length() > 0) {
                        supplyingServiceName = getTranNoLink("service", supplyingServiceUid, sWebLanguage);
                    }

                    // productGroup
                    sProductGroup = checkString(product.getProductGroup());
                    if (sProductGroup.length() > 0) {
                        sProductGroup = getTran("product.productgroup", sProductGroup, sWebLanguage);
                    }

                    // supplier
                    sSupplierUid = checkString(product.getSupplierUid());
                    if (sSupplierUid.length() > 0) {
                        sSupplierName = getTranNoLink("service", sSupplierUid, sWebLanguage);
                    }

                    // units per time unit
                    sUnitsPerTimeUnit = unitCountDeci.format(product.getUnitsPerTimeUnit());

                    // alternate row-style
                    if (sClass.equals("")) sClass = "1";
                    else sClass = "";

                    //*** display product in one row ***
                    sOut.append("<tr title='" + chooseTran + "'  class='list" + sClass + "' onClick=\"selectProduct('" + product.getUid() + "','" + product.getName() + "','" + product.getUnit() + "','" + sUnitsPerTimeUnit + "','" + supplyingServiceUid + "','" + supplyingServiceName + "','" + sSupplierUid + "','" + sSupplierName + "','" + sUnitsPerPackage + "','" + sProductStockUid + "','" + serviceStock.getUid() + "','" + serviceStock.getName() + "');\">")
                        .append(" <td>" + product.getName() + "</td>")
                        .append(" <td>" + sUnitTran + "</td>")
                        .append(" <td align='right'>" + priceDeci.format(product.getUnitPrice()) + "&nbsp;" + sCurrency + "&nbsp;</td>")
                        .append(" <td>" + getTranNoLink("service", serviceStock.getServiceUid(), sWebLanguage) + "</td>")
                        .append(" <td>" + serviceStock.getName() + "</td>")
                        .append(" <td align='right'>" + (productStock.getLevel() < 0 ? "<font color='red'>" + productStock.getLevel() + "</font>" : productStock.getLevel() + "") + "&nbsp;&nbsp;</td>")
                        .append(" <td>" + sProductGroup + "</td>")
                        .append("</tr>");

                    iTotal++;
                }
            }
        }

        sOut.append("</tbody>");
    }
%>

<form name="searchForm" method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="7"><%=getTran("web.manage","searchinproductstock",sWebLanguage)%></td>
        </tr>

        <%-- SEARCH FIELDS --%>
        <tr height="25">
            <%-- productname --%>
            <td>&nbsp;<%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
            <td>
                <input type="text" name="SearchProductName" class="text" value="<%=sSearchProductName%>" size="30">
            </td>

            <%-- service --%>
            <td>&nbsp;<%=getTran("Web","service",sWebLanguage)%>&nbsp;</td>
            <td>
                <input type="hidden" name="SearchServiceUid" value="<%=sSearchServiceUid%>">
                <input type="text" name="SearchServiceName" class="text" value="<%=sSearchServiceName%>" size="40" READONLY>

                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('SearchServiceUid','SearchServiceName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="searchForm.SearchServiceUid.value='';searchForm.SearchServiceName.value='';">
            </td>

            <%-- productgroup --%>
            <td>&nbsp;<%=getTran("Web","productgroup",sWebLanguage)%>&nbsp;</td>
            <td>
                <select class="text" name="SearchProductGroup">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("product.productgroup",sSearchProductGroup,sWebLanguage)%>
                </select>
            </td>

            <%-- BUTTONS --%>
            <td style="text-align:right">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTran("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
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
        // records found message
        if(sAction.equals("find")){
            if(iTotal > 0){
                %><div><%=iTotal%> <%=getTran("web","recordsfound",sWebLanguage)%></div><%
            }
        }
    %>

    <br>

    <%-- link to searchProduct popup --%>
    <div>
        <a href="javascript:searchProduct('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=getTran("web.manage","searchInProductCatalog",sWebLanguage)%></a>
    </div>

    <%-- link to searchUserProduct popup --%>
    <%
        if(displaySearchUserProductsLink){
            %>
                <div>
                    <a href="javascript:searchUserProduct('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=getTran("web.manage","searchInUserProducts",sWebLanguage)%></a>
                </div>
            <%
        }
    %>

    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>' onclick='window.close();'>
    </center>

    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnProductUidField" value="<%=sReturnProductUidField%>">
    <input type="hidden" name="ReturnProductNameField" value="<%=sReturnProductNameField%>">
    <input type="hidden" name="ReturnProductUnitField" value="<%=sReturnProductUnitField%>">
    <input type="hidden" name="ReturnUnitsPerTimeUnitField" value="<%=sReturnUnitsPerTimeUnitField%>">
    <input type="hidden" name="ReturnUnitsPerPackageField" value="<%=sReturnUnitsPerPackageField%>">
    <input type="hidden" name="ReturnSupplierUidField" value="<%=sReturnSupplierUidField%>">
    <input type="hidden" name="ReturnSupplierNameField" value="<%=sReturnSupplierNameField%>">
    <input type="hidden" name="ReturnProductStockUidField" value="<%=sReturnProductStockUidField%>">

    <input type="hidden" name="DisplayProductsOfDoctorService" value="<%=displayProductsOfDoctorService%>">
    <input type="hidden" name="DisplayProductsOfPatientService" value="<%=displayProductsOfPatientService%>">
</form>

<script>
  window.resizeTo(970,480);
  searchForm.SearchProductName.focus();

  <%-- select product --%>
  function selectProduct(productUid,productName,productUnit,unitsPerTimeUnit,supplyingServiceUid,supplyingServiceName,productSupplierUid,productSupplierName,unitsPerPackage,productStockUid,serviceStockUid,serviceStockName){
    var closeWindow = true;
      
    window.opener.document.all['<%=sReturnProductUidField%>'].value = productUid;
    window.opener.document.all['<%=sReturnProductNameField%>'].value = productName;
    <%
        // set ProductUnit
        if(sReturnProductUnitField.length() > 0){
            %>
              if(productUnit.length > 0){
                window.opener.document.all["<%=sReturnProductUnitField%>"].value = productUnit;
                if(window.opener.setEditUnitsPerTimeUnitLabel!=null){
                  window.opener.setEditUnitsPerTimeUnitLabel(productUid);
                }
              }
              else{
                  openEditProductUnitPopup(productUid);
                  closeWindow = false;
              }
            <%
        }

        // set ServiceStock
        %>
          var serviceStockUidField  = window.opener.document.all['EditServiceStockUid'];
          var serviceStockNameField = window.opener.document.all['EditServiceStockName'];

          if(serviceStockUidField!=undefined && serviceStockNameField!=undefined){
            window.opener.document.all['EditServiceStockUid'].value = serviceStockUid;
            window.opener.document.all['EditServiceStockName'].value = serviceStockName;
          }
        <%

        // set SupplyingService
        %>
          var suppServUidField  = window.opener.document.all['EditSupplyingServiceUid'];
          var suppServNameField = window.opener.document.all['EditSupplyingServiceName'];

          if(suppServUidField!=undefined && suppServNameField!=undefined){
            window.opener.document.all['EditSupplyingServiceUid'].value = supplyingServiceUid;
            window.opener.document.all['EditSupplyingServiceName'].value = supplyingServiceName;
          }
        <%

        // set productSupplier
        if(sReturnSupplierUidField.length() > 0 && sReturnSupplierNameField.length() > 0){
            %>
              if(productSupplierUid.length==0){
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
              if(unitsPerTimeUnit < 0){
                window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>'].value = "";
              }
              else{
                window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>'].value = unitsPerTimeUnit;
                isNumber(window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>']);
              }
            <%
        }

        // set unitsPerPackage
        if(sReturnUnitsPerPackageField.length() > 0){
            %>
              if(unitsPerPackage==0) unitsPerPackage = 1;
      
              window.opener.document.all['<%=sReturnUnitsPerPackageField%>'].value = unitsPerPackage;
              isNumber(window.opener.document.all['<%=sReturnUnitsPerTimeUnitField%>']);

              if(window.opener.calculatePackagesNeeded!=null){
                window.opener.calculatePackagesNeeded();
              }
              if(window.opener.calculatePrescriptionPeriod!=null){
                window.opener.calculatePrescriptionPeriod();
              }
            <%
        }

        // set productStockUid
        if(sReturnProductStockUidField.length() > 0){
            %>
              if(productStockUid!=undefined && productStockUid.length > 0){
                window.opener.document.all['<%=sReturnProductStockUidField%>'].value = productStockUid;
              }
              else{
                window.opener.document.all['<%=sReturnProductStockUidField%>'].value = "";
              }
            <%
        }
    %>

    if("true"=="<%=checkString(request.getParameter("loadschema"))%>"){
      window.opener.loadSchema();
    }

    if(closeWindow) window.close();
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackage,productStockUidField){
    window.opener.searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackage,productStockUidField);
    window.close();
  }

  <%-- popup : search userProduct --%>
  function searchUserProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackage,productStockUidField){
    window.opener.searchUserProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackage,productStockUidField);
    window.close();
  }

  <%-- do find --%>
  function doFind(){

    searchForm.Action.value = "find";
    ajaxChangeSearchResults('_common/search/searchByAjax/searchProductInStockShow.jsp', searchForm);
  }

  <%-- clear search fields --%>
  function clearSearchFields(){
    searchForm.SearchProductName.value = '';
    searchForm.SearchServiceUid.value = '';
    searchForm.SearchServiceName.value = '';
    searchForm.SearchProductGroup.value = '';
  }

  <%-- open edit product unit popup --%>
  function openEditProductUnitPopup(productUid){
    var url = "pharmacy/popups/editProductUnit.jsp"+
              "&EditProductUid="+productUid+
              "&ts=<%=getTs()%>";

    <%
        // pass search-parameters to be able to reproduce the same search as you did just now
        if(sSearchProductName.length() > 0){
            %>url+= "&SearchProductName=<%=sSearchProductName%>";<%
        }
        if(sSearchProductGroup.length() > 0){
            %>url+= "&SearchProductGroup=<%=sSearchProductGroup%>";<%
        }
    %>

    url+= "&SelectProductUid="+productUid;

    openPopup(url,"500","250","EditProductUnit");
  }

  <%
      // select product specified by "editProductUnit.jsp", which just added some missing data to the product.
      if(sOpenerAction.equals("selectProduct")){
          // run thru all serviceStocks collecting all belonging productStocks
          Vector allProductStocks = new Vector();
          ServiceStock serviceStock = null;
          for (int i = 0; i < serviceStocks.size(); i++) {
              serviceStock = (ServiceStock) serviceStocks.get(i);
              allProductStocks.addAll(serviceStock.getProductStocks());
          }

          ProductStock productStock = null;
          Product product = null;
          for (int i = 0; i < allProductStocks.size(); i++) {
              productStock = (ProductStock) allProductStocks.get(i);
              product = productStock.getProduct();
              if(product.getUid().equals(sSelectProductUid)){
                  break;
              }
          }
            
          // supplyingService
          String supplyingServiceUid = serviceStock.getService().code;
          String supplyingServiceName = "";
          if (supplyingServiceUid.length() > 0) {
              supplyingServiceName = getTranNoLink("service", supplyingServiceUid, sWebLanguage);
          }

          // supplier
          String sSupplierUid = checkString(product.getSupplierUid());
          String sSupplierName = "";
          if (sSupplierUid.length() > 0) {
              sSupplierName = getTranNoLink("service", sSupplierUid, sWebLanguage);
          }

          %>selectProduct("<%=product.getUid()%>","<%=checkString(product.getName())%>","<%=checkString(product.getUnit())%>","<%=product.getUnitsPerTimeUnit()%>","<%=supplyingServiceUid%>","<%=supplyingServiceName%>","<%=checkString(product.getSupplierUid())%>","<%=sSupplierName%>","<%=product.getPackageUnits()%>","<%=productStock.getUid()%>","<%=serviceStock.getUid()%>","<%=serviceStock.getName()%>");<%
      }
  %>
</script>
