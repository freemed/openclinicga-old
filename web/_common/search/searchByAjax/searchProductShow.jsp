<%@page import="be.openclinic.pharmacy.ProductStock,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.Product,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSearchProductName     = HTMLEntities.unhtmlentities(checkString(request.getParameter("SearchProductName"))),
           sSearchSupplierUid     = checkString(request.getParameter("SearchSupplierUid")),
           sSearchProductSubGroup = HTMLEntities.unhtmlentities(checkString(request.getParameter("SearchProductSubGroup"))),
           sSearchProductGroup    = HTMLEntities.unhtmlentities(checkString(request.getParameter("SearchProductGroup")));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** _common/search/searchByAjax/searchProductShow.jsp **********");
        Debug.println("sSearchProductName     : "+sSearchProductName);
        Debug.println("sSearchSupplierUid     : "+sSearchSupplierUid);
        Debug.println("sSearchProductSubGroup : "+sSearchProductSubGroup);
        Debug.println("sSearchProductGroup    : "+sSearchProductGroup+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    StringBuffer sHtml = new StringBuffer();
    int iMaxRecordsToShow = MedwanQuery.getInstance().getConfigInt("maxRecordsToShow",100);

    // variables
    String sClass = "1", sSupplierUid, sSupplierName, sUnitTran, sUnitPrice, 
           sUnitsPerTimeUnit, sProductGroup, sProductName, sProductSubGroup;
    DecimalFormat priceDeci = new DecimalFormat("0.00"),
                  unitCountDeci = new DecimalFormat("#.#");

    // frequently used translations
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€"),
           chooseTran = getTranNoLink("web","choose",sWebLanguage);

    // header
    sHtml.append("<tr class='admin'>")
          .append("<td nowrap>"+getTranNoLink("web","product",sWebLanguage)+"</td>")
          .append("<td>"+getTranNoLink("web","unit",sWebLanguage)+"</td>")
          .append("<td>"+getTranNoLink("web","unitprice",sWebLanguage)+"</td>")
          .append("<td>"+getTranNoLink("web","supplier",sWebLanguage)+"</td>")
          .append("<td>"+getTranNoLink("web","productGroup",sWebLanguage)+"</td>")
          .append("<td>"+getTranNoLink("web","category",sWebLanguage)+"</td>")
         .append("</tr>");

    // tbody
    sHtml.append("<tbody class='hand'>");
    
    Vector products = new Vector();
    if(sSearchProductName.length() > 0 || sSearchSupplierUid.length() > 0 || sSearchProductGroup.length() > 0 || sSearchProductSubGroup.length() > 0){
        products = Product.find(sSearchProductName,"","","","","",sSearchSupplierUid,sSearchProductGroup,sSearchProductSubGroup,"OC_PRODUCT_NAME","ASC");
    }
    
    // run through found products
    Product product;
    int iTotal = 0;
    for(int i=0; i<products.size() && i<iMaxRecordsToShow; i++){
        product = (Product) products.get(i);

        // units per time unit
        sUnitsPerTimeUnit = product.getUnitsPerTimeUnit()+"";
        if(sUnitsPerTimeUnit.length() > 0){
            sUnitsPerTimeUnit = unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit));
        }

        // translate unit
        sUnitTran = getTranNoLink("product.unit",product.getUnit(),sWebLanguage);

        // line unit price out
        sUnitPrice = priceDeci.format(product.getUnitPrice());

        // supplier
        sSupplierUid = checkString(product.getSupplierUid());
        if(sSupplierUid.length() > 0) sSupplierName = getTranNoLink("service",sSupplierUid,sWebLanguage);
        else                          sSupplierName = "";

        // productGroup
        sProductGroup = checkString(product.getProductGroup());
        if(sProductGroup.length() > 0){
            sProductGroup = getTranNoLink("product.productgroup",sProductGroup,sWebLanguage);
        }

        // alternate row-style
        if(sClass.length()==0) sClass = "1";
        else                   sClass = "";

        boolean inStock = product.isInServiceStock(sSearchSupplierUid);
        if(MedwanQuery.getInstance().getConfigInt("assumeStock",0)==1){
        	inStock = true;
        }

        sProductName = checkString(product.getName());
        sProductName = sProductName.replaceAll("'","");
        sProductSubGroup = getTranNoLink("drug.category",checkString(product.getProductSubGroup()),sWebLanguage);

        //*** display product in one row ***
        sHtml.append("<tr title='").append(chooseTran).append("' class='list"+sClass+"' onClick=\"selectProduct('"+product.getUid()+"','"+sProductName+"','"+product.getUnit()+"','"+sUnitsPerTimeUnit+"','"+sSupplierUid+"','"+sSupplierName+"','"+product.getPackageUnits()+"');\">")
              .append("<td nowrap "+(inStock?"":" class='strikeonly'")+">"+sProductName+"</td>")
              .append("<td"+(inStock?"":" class='strikeonly'")+">"+sUnitTran+"</td>")
              .append("<td align='right'"+(inStock?"":" class='strikeonly'")+">"+sUnitPrice+" "+sCurrency+"&nbsp;</td>")
              .append("<td"+(inStock?"":" class='strikeonly'")+">"+sSupplierName+"</td>")
              .append("<td"+(inStock?"":" class='strikeonly'")+">"+sProductGroup+"</td>")
              .append("<td"+(inStock?"":" class='strikeonly'")+">"+sProductSubGroup+"</td>")
             .append("</tr>");

        iTotal++;
    }

    sHtml.append("</tbody>");

    // display search results
    if(iTotal==0){
        %><%=HTMLEntities.htmlentities(getTranNoLink("web","noRecordsfound",sWebLanguage))%><%
	}
	else{
	    String html = HTMLEntities.unhtmlentities(sHtml.toString());
	    html = HTMLEntities.htmlentities(html);

		%>
		<table width="100%" class="sortable" id="searchresults" cellpadding="0" cellspacing="1">
		    <%=html.toString()%>
		</table>   
		     
		<%=iTotal%> <%=HTMLEntities.htmlentities(getTranNoLink("web","recordsFound",sWebLanguage))%>
		<%
    }
%>

<script>var setMax = setMaxRows;</script>