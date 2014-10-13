<%@page import="java.text.DecimalFormat,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.Product,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                java.util.Collections"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

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
    String sReturnProductUidField       = checkString(request.getParameter("ReturnProductUidField")),
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
    if(sDisplaySearchUserProductsLink.equals("false")){
        displaySearchUserProductsLink = false;
    }

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           centralPharmacyName = getTranNoLink("Service",centralPharmacyCode,sWebLanguage);

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* _common/search/searchByAjax/searchProductInStockShow.jsp *******");
        Debug.println("sAction             : "+sAction);
        Debug.println("sSearchProductName  : "+sSearchProductName);
        Debug.println("sSearchServiceUid   : "+sSearchServiceUid);
        Debug.println("sSearchServiceName  : "+sSearchServiceName);
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

    // display products of user-service by default (on first page load)
    boolean displayProductsOfDoctorService = checkString(request.getParameter("DisplayProductsOfDoctorService")).equals("true");

    if(sAction.length()==0){
        if(displayProductsOfDoctorService){
            sSearchServiceUid = activeUser.activeService.code;
            sSearchServiceName = getTranNoLink("service",sSearchServiceUid,sWebLanguage);
        }
    }

    // display products of patient-service by default (on first page load)
    boolean displayProductsOfPatientService = checkString(request.getParameter("DisplayProductsOfPatientService")).equals("true");

    if(sAction.length()==0){
        if(displayProductsOfPatientService){
            if(activePatient.isHospitalized()){
                sSearchServiceUid = activePatient.getActiveDivision().code;
                sSearchServiceName = getTranNoLink("service",sSearchServiceUid,sWebLanguage);
            }
            else{
                // search central pharmacy by default if user is not hospitalized
                sSearchServiceUid = centralPharmacyCode;
                sSearchServiceName = centralPharmacyName;
            }
        }
    }

    if(sAction.length()==0) sAction = "find"; // default action

    StringBuffer sOut = new StringBuffer();
    int iTotal = 0;

    //#############################################################################################
    //### ACTIONS #################################################################################
    //#############################################################################################
    
    //--- FIND ------------------------------------------------------------------------------------
    Vector serviceStocks = null;
    if(sAction.equals("find")){
        serviceStocks = Service.getActiveServiceStocks(sSearchServiceUid);

        if(serviceStocks.size() > 0){
	        // run thru found serviceStocks collecting all belonging productStocks
	        Vector allProductStocks = new Vector();
	        ServiceStock serviceStock;
	        for(int i=0; i<serviceStocks.size(); i++){
	            serviceStock = (ServiceStock)serviceStocks.get(i);
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
	        String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€"),
	               chooseTran = getTranNoLink("web","choose",sWebLanguage);
	
	        // header
	        sOut.append("<tr class='admin'>")
	             .append("<td width='20%'>"+getTran("web","product",sWebLanguage)+"</td>")
	             .append("<td width='10%'>"+getTran("web","unit",sWebLanguage)+"</td>")
	             .append("<td width='10%' style='text-align:right;'>"+getTran("web","unitprice",sWebLanguage)+" </td>")
	             .append("<td width='27%'>"+getTran("web","service",sWebLanguage)+"</td>")
	             .append("<td width='12%'>"+getTran("web","servicestock",sWebLanguage)+"</td>")
	             .append("<td align='right' width='6%'>"+getTran("web","level",sWebLanguage)+" </td>")
	             .append("<td width='15%'>"+getTran("web","productGroup",sWebLanguage)+"</td>")
	            .append("</tr>");
	
	        // tbody
	        sOut.append("<tbody onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\">");
	
	        // sort found products on their name
	        Collections.sort(allProductStocks);
	
	        // run thru found productStocks, displaying the product they stock
	        for(int i=0; i<allProductStocks.size(); i++){
	            productStock = (ProductStock) allProductStocks.get(i);
	            product = productStock.getProduct();
	
	            if(product != null){
	                // filter out products depending on their productGroup ?
	                boolean productGroupOK;
	                if(sSearchProductGroup.length() == 0){
	                    productGroupOK = true;
	                }
	                else{
	                    productGroupOK = (checkString(product.getProductGroup()).equals(sSearchProductGroup));
	                }
	
	                // only display products complying the searched productName AND/OR the searched productGroup
	                if(productGroupOK){
	                    if(product.getName().toLowerCase().startsWith(sSearchProductName.toLowerCase()) ||
	                       ScreenHelper.isLike(sSearchProductName,product.getName().toLowerCase())){
		                    serviceStock = productStock.getServiceStock();
		                    sUnitsPerPackage = product.getPackageUnits()+"";
		                    sProductStockUid = productStock.getUid();
		
		                    // translate unit
		                    sUnitTran = getTranNoLink("product.unit",product.getUnit(),sWebLanguage);
		
		                    // supplyingService
		                    supplyingServiceUid = serviceStock.getService().code;
		                    if(supplyingServiceUid.length() > 0) {
		                        supplyingServiceName = getTranNoLink("service",supplyingServiceUid,sWebLanguage);
		                    }
		
		                    // productGroup
		                    sProductGroup = checkString(product.getProductGroup());
		                    if(sProductGroup.length() > 0) {
		                        sProductGroup = getTran("product.productgroup",sProductGroup,sWebLanguage);
		                    }
		
		                    // supplier
		                    sSupplierUid = checkString(product.getSupplierUid());
		                    if(sSupplierUid.length() > 0){
		                        sSupplierName = getTranNoLink("service",sSupplierUid,sWebLanguage);
		                    }
		
		                    // units per time unit
		                    sUnitsPerTimeUnit = unitCountDeci.format(product.getUnitsPerTimeUnit());
		
		                    // alternate row-style
		                    if(sClass.equals("")) sClass = "1";
		                    else                  sClass = "";
		
		                    //*** display product in one row ***
		                    sOut.append("<tr title='"+chooseTran+"' class='list"+sClass+"' onMouseOver=\"this.className='list_select'\" onMouseOut=\"this.className='list"+sClass+"'\" onClick=\"selectProduct('"+product.getUid()+"','"+product.getName()+"','"+product.getUnit()+"','"+sUnitsPerTimeUnit+"','"+supplyingServiceUid+"','"+supplyingServiceName+"','"+sSupplierUid+"','"+sSupplierName+"','"+sUnitsPerPackage+"','"+sProductStockUid+"','"+serviceStock.getUid()+"','"+serviceStock.getName()+"');\">")
		                         .append("<td>"+product.getName()+"</td>")
		                         .append("<td>"+sUnitTran+"</td>")
		                         .append("<td align='right'>"+priceDeci.format(product.getUnitPrice())+" "+sCurrency+" </td>")
		                         .append("<td>"+getTranNoLink("service",serviceStock.getServiceUid(),sWebLanguage)+"</td>")
		                         .append("<td>"+serviceStock.getName()+"</td>")
		                         .append("<td align='right'>"+(productStock.getLevel()<0?"<font color='red'>"+productStock.getLevel()+"</font>":productStock.getLevel()+"")+" </td>")
		                         .append("<td>"+sProductGroup+"</td>")
		                        .append("</tr>");
		
		                    iTotal++;
		                }
	                }
	            }
	        }
	
	        sOut.append("</tbody>");
        }
    }
    
    if(sAction.equals("find")){
        if(iTotal==0){
            %><%=HTMLEntities.htmlentities(getTran("web","noRecordsFound",sWebLanguage))%><%
        }
        else{
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%=HTMLEntities.htmlentities(sOut.toString())%>
                </table>
                <%=iTotal%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
            <%
        }
    }
%>