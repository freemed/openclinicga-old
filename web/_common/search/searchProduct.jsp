<%@page import="be.openclinic.pharmacy.Product,
                java.util.Vector,
                be.openclinic.adt.Encounter,
                be.openclinic.pharmacy.ServiceStock"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%=sJSSTRINGFUNCTIONS%>
<%=sJSPROTOTYPE%>

<%
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "find"; // default action

    String sOpenerAction = checkString(request.getParameter("OpenerAction"));

    // get data from form
    String sSearchProductName  = checkString(request.getParameter("SearchProductName")),
           sSearchSupplierUid  = checkString(request.getParameter("SearchSupplierUid")),
           sSearchSupplierName = checkString(request.getParameter("SearchSupplierName")),
           sSearchProductGroup = checkString(request.getParameter("SearchProductGroup")),
           sSearchProductSubGroup = checkString(request.getParameter("SearchProductSubGroup")),
           sSelectProductUid   = checkString(request.getParameter("SelectProductUid"));

    // get data from calling url or hidden fields in form
    String sReturnProductUidField   = checkString(request.getParameter("ReturnProductUidField")),
           sReturnProductNameField  = checkString(request.getParameter("ReturnProductNameField")),
           sReturnProductUnitField  = checkString(request.getParameter("ReturnProductUnitField")),
           sReturnUnitsPerPackageField  = checkString(request.getParameter("ReturnUnitsPerPackageField")),
           sReturnUnitsPerTimeUnitField = checkString(request.getParameter("ReturnUnitsPerTimeUnitField")),
           sReturnSupplierUidField  = checkString(request.getParameter("ReturnSupplierUidField")),
           sReturnSupplierNameField = checkString(request.getParameter("ReturnSupplierNameField")),
           sReturnProductStockUidField  = checkString(request.getParameter("ReturnProductStockUidField"));

    // display options
    String sDisplaySearchUserProductsLink = checkString(request.getParameter("DisplaySearchUserProductsLink"));
    boolean displaySearchUserProductsLink = true;
    if(sDisplaySearchUserProductsLink.equalsIgnoreCase("false")){
        displaySearchUserProductsLink = false;
    }

    String sDisplaySearchProductInStockLink = checkString(request.getParameter("DisplaySearchProductInStockLink"));
    boolean displaySearchProductInStockLink = false;
    if(sDisplaySearchProductInStockLink.equalsIgnoreCase("true")){
        displaySearchProductInStockLink = true;
    }

    // central pharmacy
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode","PHA.PHA"),
           centralPharmacyName = getTran("Service",centralPharmacyCode,sWebLanguage);

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* _common/search/searchProduct.jsp *******************");
        Debug.println("sAction             : "+sAction);
        Debug.println("sSearchProductName  : "+sSearchProductName);
        Debug.println("sSearchSupplierUid  : "+sSearchSupplierUid);
        Debug.println("sSearchSupplierName : "+sSearchSupplierName);
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
%>

<form name="productForm" method="POST" onkeydown="if(enterEvent(event,13)){doFind();}" onsubmit="return false;">
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="<%=sAction%>">
    <input type="hidden" name="ReturnProductUidField" value="<%=sReturnProductUidField%>">
    <input type="hidden" name="ReturnProductNameField" value="<%=sReturnProductNameField%>">
    <input type="hidden" name="ReturnProductUnitField" value="<%=sReturnProductUnitField%>">
    <input type="hidden" name="ReturnUnitsPerTimeUnitField" value="<%=sReturnUnitsPerTimeUnitField%>">

    <%=writeTableHeader("web.manage","searchinproductcatalog",sWebLanguage," window.close();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <%-- SEARCH FIELDS --%>
        <tr>
	        <td colspan="4">
	        	<table width="100%" cellspacing="0" cellpadding="0">
	        	    <%-- ROW 1 ------------------------------------%>
	        		<tr>
			            <%-- productname --%>
			            <td class="admin2"><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="text" id="SearchProductName" name="SearchProductName" class="text" value="<%=sSearchProductName%>" size="30" onkeyup="delayedSearch();">&nbsp;
			            </td>
			
			            <%-- supplier --%>
			            <td class="admin2"><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" nowrap>
			                <input type="hidden" name="SearchSupplierUid" id="SearchSupplierUid" value="<%=sSearchSupplierUid%>">
			                <input type="text" name="SearchSupplierName" class="text" value="<%=sSearchSupplierName%>" size="30" READONLY onchange="delayedSearch();">
			 
			                <%-- buttons --%>
			                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('SearchSupplierUid','SearchSupplierName');">
			                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="productForm.SearchSupplierUid.value='';productForm.SearchSupplierName.value='';">&nbsp;
			            </td>
					</tr>
					
	        	    <%-- ROW 2 ------------------------------------%>
					<tr height="25">
			            <%-- product group --%>
			            <td class="admin2"><%=getTran("Web","productgroup",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="SearchProductGroup" id="SearchProductGroup" onChange="delayedSearch();">
			                    <option value=""></option>
			                    <%
			                        Vector groups = Product.getProductGroups();
			                        for(int n=0; n<groups.size(); n++){
			                            out.print("<option value='"+groups.elementAt(n)+"' "+(sSearchProductGroup.equalsIgnoreCase((String)groups.elementAt(n)) ? "selected" : "")+">"+getTranNoLink("product.productgroup",(String)groups.elementAt(n),sWebLanguage)+"</option>");
			                        }
			                    %>
			                </select>&nbsp;
			            </td>
			            
			            <%-- category --%>
			            <td class="admin2"><%=getTran("Web","category",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
		                    <div name="drugcategorydiv" id="drugcategorydiv"></div>
		                    <input type="text" readonly class="text" name="SearchProductSubGroupText" value="" size="120">
		                 
			                <%-- buttons --%>
		                    <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchCategory('SearchProductSubGroup','SearchProductSubGroupText');">
		                    <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="SearchProductSubGroup.value='';SearchProductSubGroupText.value='';">
		                   
		                    <input type="hidden" name="SearchProductSubGroup" id="SearchProductSubGroup" value="<%=sSearchProductSubGroup%>" onchange="delayedSearch();">
                        </td>
			        </tr>
				</table>
			</td>
			
            <%-- BUTTONS --%>
            <td nowrap colspan="3" class="admin2" style="text-align:right;">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearSearchFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
        </tr>
    </table>

    <%-- SEARCH RESULTS --%>
    <div id="divFindRecords" style="padding-top:2px;"></div>
    <br>
    
    <%    
        // link to searchProductInStock popup
        if(displaySearchProductInStockLink){
		    %>
		    <div>
		        <a href="javascript:searchProductInStock('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=getTran("web.manage", "searchInProductStock", sWebLanguage)%></a>
		    </div>
		    <%
        }
    
        // link to searchUserProduct popup
        if(displaySearchUserProductsLink){
		    %>
		    <div>
		        <a href="javascript:searchUserProduct('<%=sReturnProductUidField%>','<%=sReturnProductNameField%>','<%=sReturnProductUnitField%>','<%=sReturnUnitsPerTimeUnitField%>','<%=sReturnUnitsPerPackageField%>','<%=sReturnProductStockUidField%>');"><%=getTran("web.manage", "searchInUserProducts", sWebLanguage)%></a>
		    </div>
		    <%
        }
    %>

    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  window.resizeTo(1000,540);

  <%-- SEARCH CATEGORY --%>
  function searchCategory(CategoryUidField,CategoryNameField){
    openPopup("/_common/search/searchDrugCategory.jsp&ts="+new Date()+"&VarCode="+CategoryUidField+"&VarText="+CategoryNameField);
  }

  var timerId = 0;
  var activeSearch = "", lastSearch = "";

  <%-- SET MAX ROWS --%>
  var setMaxRows = function setMaxRows(){
    var foundRecs = $("searchresults").rows.length - 1;
    if(foundRecs > 0){
      var maxRecsToShow = <%=MedwanQuery.getInstance().getConfigInt("maxRecordsToShow",100)%>;
      if(foundRecs==maxRecsToShow){
        $("divFindRecords").innerHTML+= ">"+foundRecs+" <%=getTranNoLink("web","recordsFound",sWebLanguage)%>";
      }
      else{
        $("divFindRecords").innerHTML+= foundRecs+" <%=getTranNoLink("web","recordsFound",sWebLanguage)%>";
      }
    }
  }
  
  <%-- SELECT PRODUCT --%>
  function selectProduct(productUid,productName,productUnit,unitsPerTimeUnit,
		                 productSupplierUid,productSupplierName,unitsPerPackage,productStockUid){
    var closeWindow = true;

    window.opener.document.getElementsByName("<%=sReturnProductUidField%>")[0].value = productUid;
    window.opener.document.getElementsByName("<%=sReturnProductNameField%>")[0].value = productName;
	<%
		// set ProductUnit
		if(sReturnProductUnitField.length() > 0){
			%>
			  if(productUnit.length > 0){
			    window.opener.document.getElementsByName("<%=sReturnProductUnitField%>")[0].value = productUnit;
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
	
		// Set ServiceStock
		// Is patient admitted?
		String serviceStockUid = "", serviceStockName = "";
		Service service = Service.getService(centralPharmacyCode);
		Vector stocks;
		if(service!=null){
			stocks = ServiceStock.find(service.code);
			
			for(int n=0; n<stocks.size(); n++){
			    ServiceStock serviceStock = (ServiceStock)stocks.elementAt(n);
			    if(serviceStock.isActive()){
			        serviceStockUid = serviceStock.getUid();
			        serviceStockName = serviceStock.getName();
			        break;
			    }
			}
		}
		
		if(activePatient!=null){
			Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
			if(encounter!=null && encounter.getType().equalsIgnoreCase("admission") && encounter.getService()!=null){
			    service = encounter.getService();
			    stocks = ServiceStock.find(service.code);
			    
			    for(int n=0; n<stocks.size(); n++){
			        ServiceStock serviceStock = (ServiceStock)stocks.elementAt(n);
			        if(serviceStock.isActive()){
			            serviceStockUid = serviceStock.getUid();
			            serviceStockName = serviceStock.getName();
			            break;
			        }
			    }
			}
		}
	
		if(!"false".equalsIgnoreCase(request.getParameter("resetServiceStockUid"))){
			%>
		    if(window.opener.document.getElementsByName("EditServiceStockUid")[0]!=undefined){
		      window.opener.document.getElementsByName("EditServiceStockUid")[0].value = "<%=serviceStockUid%>";
		    }
		    if(window.opener.document.getElementsByName("EditServiceStockName")[0]!=undefined){
		      window.opener.document.getElementsByName("EditServiceStockName")[0].value = "<%=serviceStockName%>";
		    }
			<%
		}
	%>
	
	// CLEAR SupplyingService
    var suppServUidField  = window.opener.document.getElementsByName("EditSupplyingServiceUid")[0],
        suppServNameField = window.opener.document.getElementsByName("EditSupplyingServiceUid")[0];

    if(suppServUidField!=undefined && suppServNameField!=undefined){
      window.opener.document.getElementsByName("EditSupplyingServiceUid")[0].value = "";
      window.opener.document.getElementsByName("EditSupplyingServiceName")[0].value = "";
    }
<%

// set productSupplier
if(sReturnSupplierUidField.length() > 0 && sReturnSupplierNameField.length() > 0){
	%>
	  if(productSupplierUid.length==0){
	    productSupplierUid = "<%=centralPharmacyCode%>";
	    productSupplierName = "<%=centralPharmacyName%>";
	  }
	
	  window.opener.document.getElementsByName("<%=sReturnSupplierUidField%>")[0].value = productSupplierUid;
	  window.opener.document.getElementsByName("<%=sReturnSupplierNameField%>")[0].value = productSupplierName;
	<%
}

// set unitsPerTimeUnit
if(sReturnUnitsPerTimeUnitField.length() > 0){
	%>
	    if(unitsPerTimeUnit < 0){
	      window.opener.document.getElementsByName("<%=sReturnUnitsPerTimeUnitField%>")[0].value = "";
	    }
	    else{
	      window.opener.document.getElementsByName("<%=sReturnUnitsPerTimeUnitField%>")[0].value = unitsPerTimeUnit;
	      isNumber(window.opener.document.getElementsByName("<%=sReturnUnitsPerTimeUnitField%>")[0]);
	    }
	<%
}

// set unitsPerPackage
if(sReturnUnitsPerPackageField.length() > 0){
	%>
	    if(unitsPerPackage==0) unitsPerPackage = 1;
	
	    window.opener.document.getElementsByName("<%=sReturnUnitsPerPackageField%>")[0].value = unitsPerPackage;
	    isNumber(window.opener.document.getElementsByName("<%=sReturnUnitsPerTimeUnitField%>")[0]);
	
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
	      window.opener.document.getElementsByName("<%=sReturnProductStockUidField%>")[0].value = productStockUid;
	    }
	    else{
	      window.opener.document.getElementsByName("<%=sReturnProductStockUidField%>")[0].value = "";
	    }
	<%
}
%>

    if("true"=="<%=checkString(request.getParameter("loadschema"))%>"){
      window.opener.loadSchema();
    }

    if(closeWindow) window.close();
}

<%-- popup : search supplier --%>
function searchSupplier(serviceUidField, serviceNameField){
  openPopup("/_common/search/searchServiceStock.jsp&ts="+new Date()+"&ReturnServiceStockUidField="+serviceUidField+"&ReturnServiceStockNameField="+serviceNameField);
}

<%-- popup : search userProduct --%>
function searchUserProduct(productUidField,productNameField,productUnitField,
		                   unitsPerTimeUnitField,unitsPerPackage,productStockUidField){
  window.opener.searchUserProduct(productUidField,productNameField,productUnitField,
		                          unitsPerTimeUnitField,unitsPerPackage,productStockUidField);
  window.close();
}

<%-- popup : search product in stock --%>
function searchProductInStock(productUidField,productNameField,productUnitField,
		                      unitsPerTimeUnitField,unitsPerPackage,productStockUidField){
  window.opener.searchProductInServiceStock(productUidField,productNameField,productUnitField,
		                                    unitsPerTimeUnitField,unitsPerPackage,productStockUidField);
  window.close();
}

<%-- CLEAR SEARCH FIELDS --%>
function clearSearchFields(){
  productForm.SearchProductName.value = "";
  productForm.SearchSupplierUid.value = "";
  productForm.SearchSupplierName.value = "";
  productForm.SearchProductGroup.value = "";
  productForm.SearchProductSubGroupText.value = "";

  productForm.SearchProductName.focus();
}

<%-- DELAYED SEARCH --%>
function delayedSearch(){
  if(timerId > 0) clearTimeout(timerId);
  timerId = window.setTimeout("doFind();",<%=MedwanQuery.getInstance().getConfigInt("searchDelay",1000)%>);
}

<%-- DO FIND --%>
function doFind(){
  ajaxChangeSearchResults('_common/search/searchByAjax/searchProductShow.jsp',productForm,"&ts="+new Date().getTime());
}

<%-- OPEN EDIT PRODUCT UNIT POPUP --%>
function openEditProductUnitPopup(productUid){
  var url = "pharmacy/popups/editProductUnit.jsp"+
            "&EditProductUid="+productUid+
            "&ts="+new Date().getTime();

  <%
	  // pass search-parameters to be able to reproduce the same search as you did just now
	  if(sSearchProductName.length() > 0){
		  %>url+= "&SearchProductName=<%=sSearchProductName%>";<%
	  }
	  if(sSearchSupplierUid.length() > 0){
		  %>url+= "&SearchSupplierUid=<%=sSearchSupplierUid%>";<%
	  }
	  if(sSearchSupplierName.length() > 0){
		  %>url+= "&SearchSupplierName=<%=sSearchSupplierName%>";<%
	  }
	  if(sSearchProductSubGroup.length() > 0){
		  %>url+= "&sSearchProductSubGroup=<%=sSearchProductSubGroup%>";<%
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
		Product product = Product.get(sSelectProductUid);
		
		// get supplier name
		String sSupplierUid = checkString(product.getSupplierUid());
		String sSupplierName = "";
		if(sSupplierUid.length() > 0){
		    sSupplierName = getTranNoLink("service",sSupplierUid,sWebLanguage);
		}
	
		%>selectProduct("<%=product.getUid()%>","<%=checkString(product.getName())%>","<%=checkString(product.getUnit())%>","<%=product.getUnitsPerTimeUnit()%>","<%=checkString(product.getSupplierUid())%>","<%=sSupplierName%>","<%=product.getPackageUnits()%>");<%
    }
%>

  window.setTimeout("productForm.SearchProductName.focus();",100);
</script>