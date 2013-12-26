<%@page import="be.openclinic.pharmacy.ProductOrder,
                be.openclinic.pharmacy.ProductStock,
                java.util.Vector,
                java.util.Hashtable,
                java.util.Collections" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.viewordertickets","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sSortCol, String sSortDir, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sSupplierUid = "", sPrevSupplierUid = "", sProductStockUid = "",
                sPreviousProductStockUid = "", sDateOrdered = "", sDateDeliveryDue = "", sProductName = "",
                sServiceStockName = "";
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        ProductStock productStock = null;
        java.util.Date tmpDate;

        Hashtable ordersPerSupplier = new Hashtable();
        Vector ordersOfOneSupplier;
        Vector supplierUids = new Vector();
        Hashtable orderData = new Hashtable();

        // frequently used translations
        String selectTran = getTranNoLink("Web", "select", sWebLanguage),
                ordersTran = getTranNoLink("web", "orders", sWebLanguage),
                sortTran = getTranNoLink("web", "clicktosort", sWebLanguage),
                showOrdersTran = getTranNoLink("web.manage", "showOrders", sWebLanguage);

        // run thru found orders
        ProductOrder order;
        for (int i = 0; i < objects.size(); i++) {
            order = (ProductOrder) objects.get(i);

            // Date Ordered
            tmpDate = order.getDateOrdered();
            if (tmpDate != null) sDateOrdered = stdDateFormat.format(tmpDate);
            else sDateOrdered = "";

            // Date DeliveryDue
            tmpDate = order.getDateDeliveryDue();
            if (tmpDate != null) sDateDeliveryDue = stdDateFormat.format(tmpDate);
            else sDateDeliveryDue = "";

            // only search product-name when different productstock-UID
            sProductStockUid = order.getProductStockUid();
            if (sProductStockUid!=null && !sProductStockUid.equals(sPreviousProductStockUid)) {
                sPreviousProductStockUid = sProductStockUid;
                productStock = ProductStock.get(sProductStockUid);

                if (productStock != null && productStock.getProduct()!=null &&  productStock.getServiceStock()!=null) {
                    sProductName = productStock.getProduct().getName();
                    sServiceStockName = productStock.getServiceStock().getName();
                    sSupplierUid = checkString(productStock.getSupplierUid());
                    if (sSupplierUid.length() == 0) {
                        sSupplierUid = checkString(productStock.getProduct().getSupplierUid());
                    }
                    if (sSupplierUid.length() == 0) {
                        sSupplierUid = checkString(productStock.getServiceStock().getDefaultSupplierUid());
                    }
                }
                else {
                	continue;
                }
            }

            if (productStock != null) {
                // Date DeliveryDue
                tmpDate = order.getDateDeliveryDue();
                if (tmpDate != null) sDateDeliveryDue = stdDateFormat.format(tmpDate);
                else sDateDeliveryDue = "";

                //*** add data we need later on to orderData-object *******************************
                orderData.put("orderUid", order.getUid());
                orderData.put("supplierUid", sSupplierUid);
                orderData.put("description", checkString(order.getDescription()));
                orderData.put("serviceStockName", sServiceStockName);
                orderData.put("productName", sProductName);
                orderData.put("packagesOrdered", order.getPackagesOrdered() + "");
                orderData.put("packagesDelivered", order.getPackagesDelivered() + "");
                orderData.put("dateOrdered", sDateOrdered);
                orderData.put("dateDeliveryDue", sDateDeliveryDue);

                //*** GROUP ORDERS PER SUPPLIER ***************************************************
                ordersOfOneSupplier = (Vector) ordersPerSupplier.get(sSupplierUid);
                if (ordersOfOneSupplier == null) {
                    ordersOfOneSupplier = new Vector();
                    ordersPerSupplier.put(sSupplierUid, ordersOfOneSupplier);
                }
                ordersOfOneSupplier.add(orderData);
                orderData = new Hashtable();

                if (!sSupplierUid.equals(sPrevSupplierUid)) {
                    if (!supplierUids.contains(sSupplierUid)) {
                        supplierUids.add(sSupplierUid);
                        sPrevSupplierUid = sSupplierUid;
                    }
                }
            }
        }

        //*** DISPLAY ORDERS PER SUPPLIER *********************************************************
        Collections.sort(supplierUids);

        for (int i = 0; i < supplierUids.size(); i++) {
            sSupplierUid = (String) supplierUids.get(i);
            ordersOfOneSupplier = (Vector) ordersPerSupplier.get(sSupplierUid);
            Service company = Service.getService(sSupplierUid);
            String warning ="";
            if(company==null){
            	warning=" <font color='red'>"+getTran("web","unknownsupplier",sWebLanguage)+"</font>";
            }

            // Supplier sub-title
            html.append("<tr id='headerOfSupplier_" + i + "' title='" + showOrdersTran + "'>")
                    .append(" <td class='titleadmin' width='22' onClick=\"toggleOrdersDiv('" + i + "');\" style='text-align:center;'>&nbsp;<img id='img_" + i + "' src='" + sCONTEXTPATH + "/_img/plus.png' class='link'></td>")
                    .append(" <td class='titleadmin' width='80%' onClick=\"toggleOrdersDiv('" + i + "');\">&nbsp;&nbsp;" + getTran("service", sSupplierUid, sWebLanguage) + " (" + ordersOfOneSupplier.size() + " " + ordersTran + ")"+warning+"</td>")
                    .append(" <td class='titleadmin' width='20%' onClick='' style='font-weight:normal;'>")
                    .append("   <a href=\"javascript:checkAll('" + sSupplierUid + "',true);\">" + getTran("web.manage.checkdb", "CheckAll", sWebLanguage) + "</a>")
                    .append("   <a href=\"javascript:checkAll('" + sSupplierUid + "',false);\">" + getTran("web.manage.checkdb", "UncheckAll", sWebLanguage) + "</a>")
                    .append(" </td>")
                    .append("</tr>");

            html.append("<tr>")
                    .append(" <td colspan='3'>")
                    .append("  <div id='ordersOfSupplier_" + i + "' style='display:none;'>")
                    .append("   <table width='100%' cellpadding='1' cellspacing='0' class='sortable' id='searchresults'>");

            // header
            html.append("<tr class='admin'>")
                    .append(" <td nowrap>&nbsp;</td>")
                    .append(" <td><a href='#' class='underlined' title='" + sortTran + "' onClick=\"doSort('OC_ORDER_DESCRIPTION');\">" + (sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION") ? "<" + sSortDir + ">" : "") + getTran("Web", "description", sWebLanguage) + (sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION") ? "<" + sSortDir + ">" : "") + "</a></td>")
                    .append(" <td>" + getTran("Web", "servicestock", sWebLanguage) + "</td>")
                    .append(" <td>" + getTran("Web", "product", sWebLanguage) + "</td>")
                    .append(" <td><a href='#' class='underlined' title='" + sortTran + "' onClick=\"doSort('OC_ORDER_PACKAGESORDERED');\">" + (sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED") ? "<" + sSortDir + ">" : "") + getTran("Web", "packagesordered", sWebLanguage) + (sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED") ? "<" + sSortDir + ">" : "") + "</a></td>")
                    .append(" <td><a href='#' class='underlined' title='" + sortTran + "' onClick=\"doSort('OC_ORDER_PACKAGESDELIVERED');\">" + (sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESDELIVERED") ? "<" + sSortDir + ">" : "") + getTran("Web", "packagesdelivered", sWebLanguage) + (sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESDELIVERED") ? "<" + sSortDir + ">" : "") + "</a></td>")
                    .append(" <td><a href='#' class='underlined' title='" + sortTran + "' onClick=\"doSort('OC_ORDER_DATEORDERED');\">" + (sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED") ? "<" + sSortDir + ">" : "") + getTran("Web", "dateordered", sWebLanguage) + (sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED") ? "<" + sSortDir + ">" : "") + "</a></td>")
                    .append(" <td><a href='#' class='underlined' title='" + sortTran + "' onClick=\"doSort('OC_ORDER_DATEDELIVERYDUE');\">" + (sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERYDUE") ? "<" + sSortDir + ">" : "") + getTran("Web", "dateDeliveryDue", sWebLanguage) + (sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERYDUE") ? "<" + sSortDir + ">" : "") + "</a></td>")
                    .append("</tr>");

            // run thru orders of this Supplier
            for (int j = 0; j < ordersOfOneSupplier.size(); j++) {
                orderData = (Hashtable) ordersOfOneSupplier.get(j);

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                //*** display order in one row ***
                html.append("<tr class='list" + sClass + "'  title='" + selectTran + "'>")
                        .append(" <td align='center'><input type='checkbox' name='order_" + sSupplierUid + "$" + j + "' value='" + orderData.get("orderUid") + "£" + orderData.get("supplierUid") + "' "+(orderData.get("packagesDelivered").equals("0")?"checked":"")+">")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("description") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("serviceStockName") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("productName") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("packagesOrdered") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("packagesDelivered") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("dateOrdered") + "</td>")
                        .append(" <td onClick=\"selectOrder('" + sSupplierUid + "$" + j + "');\">" + orderData.get("dateDeliveryDue") + "</td>")
                        .append("</tr>");
            }

            html.append("   </table>")
                    .append("  </div>")
                    .append(" </td>")
                    .append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortCol = "OC_ORDER_DATEORDERED",
           sDefaultSortDir = "DESC";

    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditOrderUid        = checkString(request.getParameter("EditOrderUid")),
           sEditDescription     = checkString(request.getParameter("EditDescription")),
           sEditProductStockUid = checkString(request.getParameter("EditProductStockUid")),
           sEditPackagesOrdered = checkString(request.getParameter("EditPackagesOrdered")),
           sEditDateOrdered     = checkString(request.getParameter("EditDateOrdered")),
           sEditDateDeliveryDue = checkString(request.getParameter("EditDateDeliveryDue"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("################## sAction : "+sAction+" ################################");
        Debug.println("* sEditOrderUid        : "+sEditOrderUid);
        Debug.println("* sEditDescription     : "+sEditDescription);
        Debug.println("* sEditProductStockUid : "+sEditProductStockUid);
        Debug.println("* sEditPackagesOrdered : "+sEditPackagesOrdered);
        Debug.println("* sEditDateOrdered     : "+sEditDateOrdered);
        Debug.println("* sEditDateDeliveryDue : "+sEditDateDeliveryDue+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    // variables
    int foundOrderCount = 0;
    StringBuffer ordersHtml = null;

    String msg = "", sFindDescription = "", sFindServiceStockUid = "", sFindServiceUid = "",
           sFindProductStockUid = "", sFindPackagesOrdered = "", sFindDateDeliveryDue = "",
           sFindDateOrdered = "", sFindServiceName = "", sFindServiceStockName = "",
           sFindProductName = "", sFindSupplierName = "", sFindSupplierUid = "";

    // get find-data from form
    sFindDescription     = (checkString(request.getParameter("FindDescription"))+"%").replaceAll("%%", "%");
    sFindSupplierUid     = checkString(request.getParameter("FindSupplierUid"));
    sFindServiceUid      = checkString(request.getParameter("FindServiceUid"));
    sFindServiceStockUid = checkString(request.getParameter("FindServiceStockUid"));
    sFindProductStockUid = checkString(request.getParameter("FindProductStockUid"));
    sFindPackagesOrdered = checkString(request.getParameter("FindPackagesOrdered"));
    sFindDateOrdered     = checkString(request.getParameter("FindDateOrdered"));
    sFindDateDeliveryDue = checkString(request.getParameter("FindDateDeliveryDue"));

    // display options
    boolean displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    if(Debug.enabled) Debug.println("@@@ displaySearchFields : "+displaySearchFields);

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = sDefaultSortCol;
    if(Debug.enabled) Debug.println("@@@ SortCol : "+sSortCol);

    // sortDir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;
    if(Debug.enabled) Debug.println("@@@ SortDir : "+sSortDir);

    // supplier name
    if(sFindSupplierUid.length() > 0){
       sFindSupplierName = getTranNoLink("service",sFindSupplierUid,sWebLanguage);
    }


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SORT ------------------------------------------------------------------------------------
    if(sAction.equals("sort")){
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.length()==0 || sAction.startsWith("find")){
        displaySearchFields = true;
        displayFoundRecords = true;

        Vector orders = ProductOrder.find(false,true, // displayDeliveredOrders,displayUndeliveredOrders
                                          sFindDescription,sFindServiceUid,sFindProductStockUid,
                                          sFindPackagesOrdered,sFindDateDeliveryDue,sFindDateOrdered,
                                          sFindSupplierUid,sFindServiceStockUid,sSortCol,sSortDir);

        ordersHtml = objectsToHtml(orders,sSortCol,sSortDir,sWebLanguage);
        foundOrderCount = orders.size();
    }

    String sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch('"+sDefaultSortCol+"');}\"";
%>
<form name="transactionForm" id="transactionForm" method="post" <%=sOnKeyDown%> <%=(displaySearchFields?"onClick=\"clearMessage();\"":"onClick=\"setSaveButton(event);clearMessage();\" onKeyUp=\"setSaveButton(event);\"")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","viewOrderTickets",sWebLanguage," doBack();")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        // afgeleide data
        sFindServiceStockName = checkString(request.getParameter("FindServiceStockName"));
        sFindProductName      = checkString(request.getParameter("FindProductName"));

        if(displaySearchFields){
            %>
                <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(enterEvent(event,13)){doSearch(\'<%=sDefaultSortCol%>\');}';" onKeyDown="if(enterEvent(event,13)){doSearch('<%=sDefaultSortCol%>');}">
                    <%-- description --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("Web","description",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindDescription" value="<%=sFindDescription%>" size="<%=sTextWidth%>" maxLength="255">
                        </td>
                    </tr>
                    <%-- Supplier --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindSupplierUid" value="<%=sFindSupplierUid%>">
                            <input class="text" type="text" name="FindSupplierName" readonly size="<%=sTextWidth%>" value="<%=sFindSupplierName%>">
                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('FindSupplierUid','FindSupplierName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindSupplierUid.value='';transactionForm.FindSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- Service --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","Service",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceUid" value="<%=sFindServiceUid%>">
                            <input class="text" type="text" name="FindServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceName%>">
                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('FindServiceUid','FindServiceName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceUid.value='';transactionForm.FindServiceName.value='';">
                        </td>
                    </tr>
                    <%-- ServiceStock --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","ServiceStock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceStockUid" value="<%=sFindServiceStockUid%>">
                            <input class="text" type="text" name="FindServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceStockName%>">
                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('FindServiceStockUid','FindServiceStockName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceStockUid.value='';transactionForm.FindServiceStockName.value='';">
                        </td>
                    </tr>
                    <%-- ProductStock --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","ProductStock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindProductStockUid" value="<%=sFindProductStockUid%>">
                            <input class="text" type="text" name="FindProductName" readonly size="<%=sTextWidth%>" value="<%=sFindProductName%>">
                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductStock('FindProductStockUid','FindProductName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindProductStockUid.value='';transactionForm.FindProductName.value='';">
                        </td>
                    </tr>
                    <%-- PackagesOrdered --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","PackagesOrdered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindPackagesOrdered" value="<%=sFindPackagesOrdered%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- DateOrdered --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","DateOrdered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindDateOrdered","transactionForm",sFindDateOrdered,sWebLanguage)%></td>
                    </tr>
                    <%-- DateDeliveryDue --%>
                    <tr>
                        <td class="admin2"><%=getTran("Web","DateDeliveryDue",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindDateDeliveryDue","transactionForm",sFindDateDeliveryDue,sWebLanguage)%></td>
                    </tr>
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch('<%=sDefaultSortCol%>');">
                            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                <br>
            <%
        }

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(displayFoundRecords){
            if(foundOrderCount > 0){
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="list">
                        <%-- header --%>
                        <tr class="admin">
                            <td colspan="3"><%=getTran("Web.manage","orderspersupplier",sWebLanguage)%></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=ordersHtml%>
                        </tbody>
                    </table>
                    <%-- CHECK ALL --%>
                    <a href="javascript:checkAllOrders(true);"><%=getTran("web.manage.checkdb","CheckAll",sWebLanguage)%></a>
                    <a href="javascript:checkAllOrders(false);"><%=getTran("web.manage.checkdb","UncheckAll",sWebLanguage)%></a>
                    <br>
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundOrderCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundOrderCount > 20){
                            // link to top of page
                            %>
                            <span style="width:51%;text-align:right;">
                                <a href="#topp" class="topbutton">&nbsp;</a>
                            </span>
                            <br>
                            <%
                        }
                    %>
                    <%-- PRINT BUTTON --%>
                    <%=ScreenHelper.alignButtonsStart()%>
                        <input type="button" class="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete();">
                        <input type="button" class="button" name="printButton" value="<%=getTranNoLink("Web","print",sWebLanguage)%>" onclick="doPrintPdf();">
                    <%=ScreenHelper.alignButtonsStop()%>
                    <br>
                <%
            }
            else{
                // no records found
                %>
                <%=getTran("web","norecordsfound",sWebLanguage)%>
                <br><br>
                <%
            }
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditOrderUid" value="<%=sEditOrderUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displaySearchFields){
          %>transactionForm.FindDescription.focus();<%
      }
  %>

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindSupplierUid.value = "";
    transactionForm.FindSupplierName.value = "";

    transactionForm.FindServiceUid.value = "";
    transactionForm.FindServiceName.value = "";

    transactionForm.FindServiceStockUid.value = "";
    transactionForm.FindServiceStockName.value = "";

    transactionForm.FindProductStockUid.value = "";
    transactionForm.FindProductName.value = "";

    transactionForm.FindDescription.value = "";
    transactionForm.FindPackagesOrdered.value = "";
    transactionForm.FindDateOrdered.value = "";
    transactionForm.FindDateDeliveryDue.value = "";
  }

  <%-- DO SORT --%>
  function doSort(sortCol){
    transactionForm.Action.value = "sort";
    transactionForm.SortCol.value = sortCol;

    if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
    else                                       transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- DO SEARCH --%>
  function doSearch(sortCol){
    if(!transactionForm.FindProductStockUid.value.length==0 ||
       !transactionForm.FindSupplierUid.value.length==0 ||
       !transactionForm.FindServiceUid.value.length==0 ||
       !transactionForm.FindServiceStockUid.value.length==0 ||
       !transactionForm.FindDescription.value.length==0 ||
       !transactionForm.FindPackagesOrdered.value.length==0 ||
       !transactionForm.FindDateOrdered.value.length==0 ||
       !transactionForm.FindDateDeliveryDue.value.length==0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;

      transactionForm.Action.value = "find";
      transactionForm.SortCol.value = sortCol;
      openSearchInProgressPopup();
      transactionForm.submit();
    }
    else{
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }
  }

  <%-- CHECK ALL ORDERS --%>
  function checkAllOrders(setchecked){
    for(i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        transactionForm.elements[i].checked = setchecked;
      }
    }
  }

  <%-- CHECK ALL --%>
  function checkAll(supplierUid,setchecked){
    for(i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        if(transactionForm.elements[i].name.indexOf('order_'+supplierUid+'$')>-1){
          transactionForm.elements[i].checked = setchecked;
        }
      }
    }
  }

  <%-- popup : search product stock --%>
  function searchProductStock(productStockUidField,productStockNameField){
    openPopup("/_common/search/searchProductStock.jsp&ts=<%=getTs()%>&ReturnProductStockUidField="+productStockUidField+"&ReturnProductStockNameField="+productStockNameField);
  }

  <%-- popup : search service stock --%>
  function searchServiceStock(serviceStockUidField,serviceStockNameField){
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceStockUidField+"&ReturnServiceStockNameField="+serviceStockNameField);
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search supplier --%>
  function searchSupplier(supplierUidField,supplierNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&SearchExternalServices=true&VarCode="+supplierUidField+"&VarText="+supplierNameField);
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- AT LEAST ONE ORDER CHECKED --%>
  function atLeastOneOrderChecked(){
    var inputs = document.getElementsByTagName('input');

    for(var i=0; i<inputs.length; i++){
      if(inputs[i].type=='checkbox'){
        if(inputs[i].checked){
          return true;
        }
      }
    }

    return false;
  }

  <%-- PRINT PDF --%>
  function doPrintPdf(){
	    if(atLeastOneOrderChecked()){
	      <%-- concatenate all selected orderIds --%>
	      var orderUids = "";
	      var inputs = document.getElementsByTagName('input');
	      for(var i=0; i<inputs.length; i++){
	        if(inputs[i].type=="checkbox"){
	          if(inputs[i].name.indexOf("order_")>-1){
	            if(inputs[i].checked){
	              orderUids+= inputs[i].value+"$";
	            }
	          }
	        }
	      }
	      <%-- popup to display pdf in --%>
	      var url = "<c:url value='/pharmacy/createOrderTicketsPdf.jsp'/>?OrderUids="+orderUids+"&ts=<%=getTs()%>";
	      window.open(url,"OrderTicketsPDF<%=new java.util.Date().getTime()%>","height=600, width=845, toolbar=yes, status=no, scrollbars=yes, resizable=yes, menubar=yes");
	    }
	    else{
	      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectatleastoneorder";
	      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","selectatleastoneorder",sWebLanguage)%>");
	    }
	  }

  function doDelete(){
	    if(atLeastOneOrderChecked()){
	        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
	        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	        var answer = window.confirm('<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>');

	        if(answer==1){
		      <%-- concatenate all selected orderIds --%>
		      var orderUids = "";
		      var inputs = document.getElementsByTagName('input');
		      for(var i=0; i<inputs.length; i++){
		        if(inputs[i].type=="checkbox"){
		          if(inputs[i].name.indexOf("order_")>-1){
		            if(inputs[i].checked){
		              orderUids+= inputs[i].value+"$";
		            }
		          }
		        }
		      }
		      <%-- popup to display pdf in --%>
		      var url = "<c:url value='/pharmacy/deleteOrderTickets.jsp'/>?OrderUids="+orderUids+"&ts=<%=getTs()%>";
		      window.open(url,"DeleteOrderTickets<%=new java.util.Date().getTime()%>","height=600, width=845, toolbar=yes, status=no, scrollbars=yes, resizable=yes, menubar=yes");
	        }
	    }
	    else{
	      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectatleastoneorder";
	      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","selectatleastoneorder",sWebLanguage)%>");
	    }
	  }

  <%-- SELECT ORDER --%>
  function selectOrder(orderIdx){
    transactionForm.all['order_'+orderIdx].checked = !transactionForm.all['order_'+orderIdx].checked;
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
    window.location.href = "<c:url value='/main.do'/>?Page=pharmacy/manageProductOrders.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- TOGGLE ORDERS DIV --%>
  <%
      String showOrdersTran  = getTranNoLink("web.manage","showOrders",sWebLanguage),
             hideOrdersTran  = getTranNoLink("web.manage","hideOrders",sWebLanguage);
  %>
  function toggleOrdersDiv(supplierIdx){
    var headerObj = document.getElementById('headerOfSupplier_'+supplierIdx);
    var divObj    = document.getElementById('ordersOfSupplier_'+supplierIdx);
    var imgObj    = document.getElementById('img_'+supplierIdx);

    if(divObj.style.display == 'none'){
      divObj.style.display = 'block';
      headerObj.title = "<%=hideOrdersTran%>";
      imgObj.src = "<c:url value='/_img/minus.png'/>";
    }
    else{
      divObj.style.display = 'none';
      headerObj.title = "<%=showOrdersTran%>";
      imgObj.src = "<c:url value='/_img/plus.png'/>";
    }
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>