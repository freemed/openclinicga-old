<%@page import="java.text.DecimalFormat,
                be.openclinic.pharmacy.Product,
                be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.UserProduct,
                java.util.Vector,
                java.util.Collections,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
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
            if(sSearchProductGroup.length() == 0) {
                productGroupOK = true;
            } 
            else {
                if(userProduct.getProduct() != null) {
                    productGroupOK = (checkString(userProduct.getProduct().getProductGroup()).equals(sSearchProductGroup));
                }
            }

            // only display products complying the searched productName AND/OR the searched productGroup
            if(userProduct.getProduct() != null) {
                if(userProduct.getProduct().getName().toLowerCase().startsWith(sSearchProductName.toLowerCase()) && productGroupOK) {
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
            if(sUnit.length() > 0) {
                sUnit = getTran("product.unit", sUnit, sWebLanguage);
            }

            // line unit price out
            sUnitPrice = product.getUnitPrice()+"";
            if(sUnitPrice.length() > 0) {
                dUnitPrice = Double.parseDouble(sUnitPrice);
                sUnitPrice = deci.format(dUnitPrice);
            }

            //*** supplier ***
            sProductStockUid = checkString(userProduct.getProductStockUid());
            if(sProductStockUid.length() > 0) {
                // processing product from product-catalog, productStock available
                productStock = ProductStock.get(sProductStockUid);
                sSupplierUid = checkString(product.getSupplierUid());

                if(sSupplierUid.length() > 0) {
                    sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                } 
                else {
                    sSupplierUid = checkString(product.getSupplierUid());
                    if(sSupplierUid.length() > 0) {
                        sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                    }
                    else {
                        sSupplierUid = checkString(productStock.getServiceStock().getDefaultSupplierUid());
                        if(sSupplierUid.length() > 0) {
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
                if(sSupplierUid.length() > 0) {
                    sSupplierName = getTran("service", sSupplierUid, sWebLanguage);
                } 
                else {
                    sSupplierName = "";
                }
            }

            // productGroup
            sProductGroup = checkString(product.getProductGroup());
            if(sProductGroup.length() > 0) {
                sProductGroup = getTran("product.productgroup", sProductGroup, sWebLanguage);
            }

            // units per time unit
            sUnitsPerTimeUnit = unitCountDeci.format(product.getUnitsPerTimeUnit());

            // supplyingService & serviceStock
            if(productStock != null) {
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

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            //*** display product in one row ***
            html.append("<tr title='"+chooseTran+"' class='list"+sClass+"' onClick=\"selectProduct('"+product.getUid()+"','"+product.getName()+"','"+product.getUnit()+"','"+sUnitsPerTimeUnit+"','"+supplyingServiceUid+"','"+supplyingServiceName+"','"+sSupplierUid+"','"+sSupplierName+"','"+product.getPackageUnits()+"','"+sProductStockUid+"','"+serviceStockUid+"','"+serviceStockName+"');\">")
                 .append("<td>"+product.getName()+"</td>")
                 .append("<td>"+sUnit+"</td>")
                 .append("<td style='text-align:right;'>"+sUnitPrice+" "+sCurrency+" </td>")
                 .append("<td>"+sSupplierName+"</td>")
                 .append("<td>"+(productStock == null ? "" : productStock.getServiceStock().getName())+"</td>")
                 .append("<td>"+sProductGroup+" </td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length() == 0) sAction = "find"; // default action

    String sOpenerAction = checkString(request.getParameter("OpenerAction"));

    // get data from form
    String sSearchProductName  = checkString(request.getParameter("SearchProductName")).replaceAll("%", ""),
           sSearchProductGroup = checkString(request.getParameter("SearchProductGroup")),
           sSelectProductUid   = checkString(request.getParameter("SelectProductUid"));

    // get data from calling url or hidden fields in form
    String sReturnProductUidField       = checkString(request.getParameter("ReturnProductUidField")),
           sReturnProductNameField      = checkString(request.getParameter("ReturnProductNameField")),
           sReturnProductUnitField      = checkString(request.getParameter("ReturnProductUnitField")),
           sReturnUnitsPerPackageField  = checkString(request.getParameter("ReturnUnitsPerPackageField")),
           sReturnUnitsPerTimeUnitField = checkString(request.getParameter("ReturnUnitsPerTimeUnitField")),
           sReturnSupplierUidField      = checkString(request.getParameter("ReturnSupplierUidField")),
           sReturnSupplierNameField     = checkString(request.getParameter("ReturnSupplierNameField")),
           sReturnProductStockUidField  = checkString(request.getParameter("ReturnProductStockUidField"));

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           centralPharmacyName = getTran("Service", centralPharmacyCode, sWebLanguage);

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled) {
        Debug.println("\n##################### searchUserProductShow.jsp ##################");
        Debug.println("sAction             : "+sAction);
        Debug.println("sSearchProductName  : "+sSearchProductName);
        Debug.println("sSearchProductGroup : "+sSearchProductGroup);
        Debug.println("sOpenerAction       : "+sOpenerAction);
        Debug.println("sSelectProductUid   : "+sSelectProductUid+"\n");

        Debug.println("sReturnUnitsPerPackageField  : "+sReturnUnitsPerPackageField);
        Debug.println("sReturnProductUidField       : "+sReturnProductUidField);
        Debug.println("sReturnProductNameField      : "+sReturnProductNameField);
        Debug.println("sReturnProductUnitField      : "+sReturnProductUnitField);
        Debug.println("sReturnUnitsPerTimeUnitField : "+sReturnUnitsPerTimeUnitField);
        Debug.println("sReturnSupplierUidField      : "+sReturnSupplierUidField);
        Debug.println("sReturnSupplierNameField     : "+sReturnSupplierNameField);
        Debug.println("sReturnProductStockUidField  : "+sReturnProductStockUidField+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    int foundProductCount = 0;
    StringBuffer productsHtml = null;

    //--- FIND ------------------------------------------------------------------------------------
    Vector userProducts = null;
    if(sAction.equals("find")){
        userProducts = UserProduct.find(activeUser.userid);
        productsHtml = objectsToHtml(userProducts,sSearchProductName,sSearchProductGroup,sWebLanguage);
        foundProductCount = userProducts.size();
    }
%>

<%
    // display search results
    if(sAction.equals("find")){
        if(foundProductCount == 0){
            %><%=HTMLEntities.htmlentities(getTran("web","norecordsfound",sWebLanguage))%><%
     }
     else{
			%>
<table width="100%" class="sortable" id="searchresults">
    <%-- header --%>
	<tr class="admin">
	    <td><%=HTMLEntities.htmlentities(getTran("web","product",sWebLanguage))%></td>
	    <td><%=HTMLEntities.htmlentities(getTran("web","unit",sWebLanguage))%></td>
	    <td><%=HTMLEntities.htmlentities(getTran("web","unitprice",sWebLanguage))%></td>
	    <td><%=HTMLEntities.htmlentities(getTran("web","supplier",sWebLanguage))%></td>
	    <td><%=HTMLEntities.htmlentities(getTran("Web","ServiceStock",sWebLanguage))%></td>
	    <td><%=HTMLEntities.htmlentities(getTran("web","productGroup",sWebLanguage))%></td>
	</tr>

	<tbody onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';">
	    <%=HTMLEntities.htmlentities(productsHtml.toString())%>
    </tbody>
</table>
    			<%
        }
    }
%>