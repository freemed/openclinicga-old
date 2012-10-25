<%@page import="java.util.*" %>
<%@ page import="be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.manageproductorders","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- ORDERS TO HTML --------------------------------------------------------------------------
    private StringBuffer ordersToHtml(Vector orders, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sProductStockUid = "", sPreviousProductStockUid = "", sImportance = "",
                sDateOrdered = "", sDateDelivered = "", sProductName = "", sServiceStockName = "";
        java.util.Date tmpDate;
        ProductStock productStock;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found orders
        ProductOrder order;
        for (int i = 0; i < orders.size(); i++) {
            order = (ProductOrder) orders.get(i);

            // Date Ordered
            tmpDate = order.getDateOrdered();
            if (tmpDate != null) sDateOrdered = stdDateFormat.format(tmpDate);
            else sDateOrdered = "";

            // Date Delivered
            tmpDate = order.getDateDelivered();
            if (tmpDate != null) sDateDelivered = stdDateFormat.format(tmpDate);
            else sDateDelivered = "";

            // only search product-name when different productstock-UID
            sProductStockUid = order.getProductStockUid();
            if (!sProductStockUid.equals(sPreviousProductStockUid)) {
                sPreviousProductStockUid = sProductStockUid;
                productStock = ProductStock.get(sProductStockUid);
                sProductName = productStock.getProduct().getName();
                sServiceStockName = productStock.getServiceStock().getName();
            }

            // translate importance
            sImportance = checkString(order.getImportance());
            if (sImportance.length() > 0) {
                sImportance = getTran("productorder.importance", sImportance, sWebLanguage);
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display order in one row ***
            html.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + order.getUid() + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + checkString(order.getDescription()) + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sServiceStockName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sProductName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + order.getPackagesOrdered() + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sDateOrdered + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sDateDelivered + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sImportance + "</td>")
                    .append("</tr>");
        }

        return html;
    }

    //--- UNDELIVERED ORDERS TO HTML --------------------------------------------------------------
    private StringBuffer undeliveredOrdersToHtml(Vector orders, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sProductStockUid = "", sPreviousProductStockUid = "", sImportance = "",
                sDateOrdered = "", sDateDeliveryDue = "", sProductName = "", sServiceStockName = "";
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        ProductStock productStock;
        java.util.Date tmpDate;
        ServiceStock serviceStock;
        Product product;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found orders
        ProductOrder order;
        for (int i = 0; i < orders.size(); i++) {
            order = (ProductOrder) orders.get(i);

            // Date Ordered
            tmpDate = order.getDateOrdered();
            if (tmpDate != null) sDateOrdered = stdDateFormat.format(tmpDate);
            else sDateOrdered = "";

            // Date DeliveryDue
            tmpDate = order.getDateDeliveryDue();
            if (tmpDate != null) sDateDeliveryDue = stdDateFormat.format(tmpDate);
            else sDateDeliveryDue = "";

            // only search product-name ans serviceStock-name when different productstock-UID
            sProductStockUid = order.getProductStockUid();
            if (!sProductStockUid.equals(sPreviousProductStockUid)) {
                sPreviousProductStockUid = sProductStockUid;
                productStock = ProductStock.get(sProductStockUid);

                if (productStock != null) {
                    // product
                    product = productStock.getProduct();
                    if (product != null) {
                        sProductName = product.getName();
                    } else {
                        sProductName = "<font color='red'>" + getTran("web.manage", "unexistingproduct", sWebLanguage) + "</font>";
                    }

                    // service stock
                    serviceStock = productStock.getServiceStock();
                    if (serviceStock != null) {
                        sServiceStockName = serviceStock.getName();
                    } else {
                        sServiceStockName = "<font color='red'>" + getTran("web.manage", "unexistingservicestock", sWebLanguage) + "</font>";
                    }
                } else {
                    sProductName = "<font color='red'>" + getTran("web.manage", "unexistingproduct", sWebLanguage) + "</font>";
                    sServiceStockName = "<font color='red'>" + getTran("web.manage", "unexistingservicestock", sWebLanguage) + "</font>";
                }
            }

            // translate importance
            sImportance = checkString(order.getImportance());
            if (sImportance.length() > 0) {
                sImportance = getTran("productorder.importance", sImportance, sWebLanguage);
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display order in one row ***
            html.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + order.getUid() + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + checkString(order.getDescription()) + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sServiceStockName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sProductName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + order.getPackagesOrdered() + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sDateOrdered + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sDateDeliveryDue + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + order.getUid() + "');\">" + sImportance + "</td>")
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
    String sEditOrderUid = checkString(request.getParameter("EditOrderUid")),
            sEditDescription = checkString(request.getParameter("EditDescription")),
            sEditSupplierUid = checkString(request.getParameter("EditSupplierUid")),
            sEditProductStockUid = checkString(request.getParameter("EditProductStockUid")),
            sEditPackagesOrdered = checkString(request.getParameter("EditPackagesOrdered")),
            sEditPackagesDelivered = checkString(request.getParameter("EditPackagesDelivered")),
            sEditDateOrdered = checkString(request.getParameter("EditDateOrdered")),
            sEditDateDeliveryDue = checkString(request.getParameter("EditDateDeliveryDue")),
            sEditDateDelivered = checkString(request.getParameter("EditDateDelivered")),
            sEditBatchUid = checkString(request.getParameter("EditBatchUid")),
            sEditBatchExpire = checkString(request.getParameter("EditBatchExpire")),
            sEditProductStockDocumentUid = checkString(request.getParameter("EditProductStockDocumentUid")),
            sEditProductStockDocumentUidText = "",
            sEditImportance = checkString(request.getParameter("EditImportance")); // (native|high|low)

            if(sEditProductStockDocumentUid.length()>0){
            	sEditProductStockDocumentUidText=getTran("operationdocumenttypes",OperationDocument.get(sEditProductStockDocumentUid).getType(),sWebLanguage);
            }
    // afgeleide data
    String sEditProductName = checkString(request.getParameter("EditProductName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("################## sAction : " + sAction + " ################################");
        Debug.println("* sEditOrderUid          : " + sEditOrderUid);
        Debug.println("* sEditDescription       : " + sEditDescription);
        Debug.println("* sEditSupplierUid       : " + sEditSupplierUid);
        Debug.println("* sEditProductStockUid   : " + sEditProductStockUid);
        Debug.println("* sEditPackagesOrdered   : " + sEditPackagesOrdered);
        Debug.println("* sEditPackagesDelivered : " + sEditPackagesDelivered);
        Debug.println("* sEditDateOrdered       : " + sEditDateOrdered);
        Debug.println("* sEditDateDeliveryDue   : " + sEditDateDeliveryDue);
        Debug.println("* sEditDateDelivered     : " + sEditDateDelivered);
        Debug.println("* sEditImportance        : " + sEditImportance);
        Debug.println("** sEditProductName      : " + sEditProductName + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sFindDescription = "", sFindServiceStockUid = "", sFindServiceUid = "",
            sFindProductStockUid = "", sFindPackagesOrdered = "", sFindPackagesDelivered = "",
            sFindDateOrdered = "", sFindDateDeliveryDue = "", sFindDateDelivered = "", sFindImportance = "",
            sSelectedProductStockUid = "", sSelectedDescription = "", sSelectedPackagesOrdered = "",
            sSelectedPackagesDelivered = "", sSelectedDateOrdered = "", sSelectedDateDeliveryDue = "",
            sSelectedDateDelivered = "", sSelectedImportance = "", sSelectedProductName = "",
            sFindServiceName = "", sFindServiceStockName = "", sFindProductName = "",
            sFindSupplierUid = "", sFindSupplierName = "", sFindDateDeliveredSince = "";

    // get find-data from form
    sFindDescription = (checkString(request.getParameter("FindDescription"))+"%").replaceAll("%%", "%");
    sFindSupplierUid = checkString(request.getParameter("FindSupplierUid"));
    sFindServiceUid = checkString(request.getParameter("FindServiceUid"));
    sFindServiceStockUid = checkString(request.getParameter("FindServiceStockUid"));
    sFindProductStockUid = checkString(request.getParameter("FindProductStockUid"));
    sFindPackagesOrdered = checkString(request.getParameter("FindPackagesOrdered"));
    sFindPackagesDelivered = checkString(request.getParameter("FindPackagesDelivered"));
    sFindDateOrdered = checkString(request.getParameter("FindDateOrdered"));
    sFindDateDeliveryDue = checkString(request.getParameter("FindDateDeliveryDue"));
    sFindDateDelivered = checkString(request.getParameter("FindDateDelivered"));
    sFindDateDeliveredSince = checkString(request.getParameter("FindDateDeliveredSince"));
    sFindImportance = checkString(request.getParameter("FindImportance")); // (native|high|low)

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("* sFindDescription        : " + sFindDescription);
        Debug.println("* sFindSupplierUid        : " + sFindSupplierUid);
        Debug.println("* sFindServiceUid         : " + sFindServiceUid);
        Debug.println("* sFindServiceStockUid    : " + sFindServiceStockUid);
        Debug.println("* sFindProductStockUid    : " + sFindProductStockUid);
        Debug.println("* sFindPackagesOrdered    : " + sFindPackagesOrdered);
        Debug.println("* sFindPackagesDelivered  : " + sFindPackagesDelivered);
        Debug.println("* sFindDateOrdered        : " + sFindDateOrdered);
        Debug.println("* sFindDateDeliveryDue    : " + sFindDateDeliveryDue);
        Debug.println("* sFindDateDeliveryDue    : " + sFindDateDeliveryDue);
        Debug.println("* sFindImportance         : " + sFindImportance);
        Debug.println("* sFindDateDeliveredSince : " + sFindDateDeliveredSince + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////
    int foundOrderCount = 0;
    StringBuffer ordersHtml = null;
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    boolean orderIsClosed = false;

    // display options
    boolean displayEditFields = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if (sDisplaySearchFields.length() == 0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    String sDisplayDeliveredOrders = checkString(request.getParameter("DisplayDeliveredOrders"));
    if (sDisplayDeliveredOrders.length() == 0) sDisplayDeliveredOrders = "false"; // default
    boolean displayDeliveredOrders = sDisplayDeliveredOrders.equalsIgnoreCase("true");

    String sDisplayUndeliveredOrders = checkString(request.getParameter("DisplayUndeliveredOrders"));
    if (sDisplayUndeliveredOrders.length() == 0) sDisplayUndeliveredOrders = "true"; // default
    boolean displayUndeliveredOrders = sDisplayUndeliveredOrders.equalsIgnoreCase("true");

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if (sSortCol.length() == 0) sSortCol = sDefaultSortCol;

    // sortDir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    // default since-date is one week ago
    if (sFindDateDeliveredSince.length() == 0) {
        Calendar oneWeekAgo = new GregorianCalendar();
        String sShowDeliveriesSince = MedwanQuery.getInstance().getConfigString("ShowDeliveriesSinceInDays");
        if (sShowDeliveriesSince.length() > 0) {
            oneWeekAgo.add(Calendar.DATE, -(Integer.parseInt(sShowDeliveriesSince)));
        } else {
            oneWeekAgo.add(Calendar.DATE, -7); // default one week
        }
        sFindDateDeliveredSince = new SimpleDateFormat("dd/MM/yyyy").format(oneWeekAgo.getTime());
    }

    // supplier name
    if (sFindSupplierUid.length() > 0) {
        sFindSupplierName = getTranNoLink("service", sFindSupplierUid, sWebLanguage);
    }

    //*** is order closed ? ***
    java.util.Date dPrevDateDelivered = null;
    if (sEditOrderUid.length() > 0 && !sEditOrderUid.equals("-1")) {
        // get ordered-date (if one)
        ProductOrder existingOrder = ProductOrder.get(sEditOrderUid);
        if (existingOrder != null) {
            dPrevDateDelivered = existingOrder.getDateDelivered();
        }

        if (dPrevDateDelivered == null) orderIsClosed = false;
        else orderIsClosed = true;
    }

    if (sAction.length() == 0) sAction = "find"; // default action

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
   	 int nPackagesDelivered=0;
   	 try{
   		nPackagesDelivered=Integer.parseInt(sEditPackagesDelivered);
   	 }
   	 catch(Exception e){}
	 
   	 if (sAction.equals("save") && sEditOrderUid.length() > 0) {
        String sPrevUsedDocument = checkString((String) session.getAttribute("PrevUsedDocument"));
        if (!sPrevUsedDocument.equals(sEditProductStockDocumentUid)) {
            session.setAttribute("PrevUsedDocument", sEditProductStockDocumentUid);
        }
        // create order
        ProductOrder order = new ProductOrder();
        order.setUid(sEditOrderUid);
        order.setDescription(sEditDescription);
        order.setProductStockUid(sEditProductStockUid);
        order.setImportance(sEditImportance); // (native|high|low)
        order.setUpdateUser(activeUser.userid);
        if (sEditPackagesOrdered.length() > 0) order.setPackagesOrdered(Integer.parseInt(sEditPackagesOrdered));
        if (sEditPackagesDelivered.length() > 0) order.setPackagesDelivered(Integer.parseInt(sEditPackagesDelivered));
        if (sEditDateOrdered.length() > 0) order.setDateOrdered(stdDateFormat.parse(sEditDateOrdered));
        if (sEditDateDeliveryDue.length() > 0) order.setDateDeliveryDue(stdDateFormat.parse(sEditDateDeliveryDue));
        if (sEditDateDelivered.length() > 0) order.setDateDelivered(stdDateFormat.parse(sEditDateDelivered));
		if(order.getPackagesOrdered()>=order.getPackagesDelivered()){
			order.setPackagesOrdered(order.getPackagesOrdered()-order.getPackagesDelivered());
	        String existingOrderUid = order.exists();
	        boolean orderExists = existingOrderUid.length() > 0;
	
		   	
	        // only update product-stock if order is not allready delivered
	        //if (!(sEditOrderUid.equals("-1") && orderExists) && !(!sEditOrderUid.equals("-1") && orderExists && !sEditOrderUid.equals(existingOrderUid)) && dPrevDateDelivered == null) {
	            //Create a productstockoperation that does the work for you
	            ProductStockOperation operation = new ProductStockOperation();
	            operation.setUid("-1");
	            operation.setCreateDateTime(new java.util.Date());
	            operation.setDate(new java.util.Date());
	            operation.setDescription(MedwanQuery.getInstance().getConfigString("pharmacyOrderReceptionDescription","medicationreceipt.4"));
	            operation.setProductStockUid(sEditProductStockUid);
	            operation.setBatchNumber(sEditBatchUid);
	            try{
	            	operation.setBatchEnd(new SimpleDateFormat("dd/MM/yyyy").parse(sEditBatchExpire));
	            }
	            catch(Exception e){}
	            ProductStock productStock = ProductStock.get(sEditProductStockUid);
	            ObjectReference sd=new ObjectReference("servicestock","");
	            if (productStock.getSupplier() != null && productStock.getSupplier().defaultServiceStockUid != null && productStock.getSupplier().defaultServiceStockUid.length() > 0) {
	                sd = new ObjectReference("servicestock",productStock.getSupplier().defaultServiceStockUid);
	            }
	            operation.setSourceDestination(sd);
	            operation.setDocumentUID(sEditProductStockDocumentUid);
	            if(sEditPackagesDelivered.length()>0) { operation.setUnitsChanged(Integer.parseInt(sEditPackagesDelivered));}
	            operation.setUpdateDateTime(new java.util.Date());
	            operation.setUpdateUser(activeUser.userid);
	            // add number of packages that were actualy delivered
	            String sResult=operation.store();
	            if(sResult==null){
	                if (sEditOrderUid.equals("-1")) {
	                    //***** insert new order *****
	                    if (!orderExists) {
	                        order.store(false);
	
	                        // show saved data
	                        sAction = "find"; // showDetails
	                        msg = getTran("web", "dataissaved", sWebLanguage);
	                    }
	                    //***** reject new addition *****
	                    else {
	                        // show rejected data
	                        sAction = "showDetailsAfterAddReject";
	                        msg = "<font color='red'>" + getTran("web.manage", "orderexists", sWebLanguage) + "</font>";
	                    }
	                } else {
	                    //***** update existing record *****
	                    if (!orderExists) {
	                        // store the edited data
	                        order.store(false);
	
	                        // show saved data
	                        sAction = "find"; // showDetails
	                        msg = getTran("web", "dataissaved", sWebLanguage);
	                    }
	                    //***** reject double record thru update *****
	                    else {
	                        if (sEditOrderUid.equals(existingOrderUid)) {
	                            // nothing : just updating a record with its own data
	                            if (order.changed()) {
	                                order.store(false);
	                                msg = getTran("web", "dataissaved", sWebLanguage);
	                            }
	                            sAction = "find"; // showDetails
	                        } else {
	                            // tried to update one order with exact the same data as an other order
	                            // show rejected data
	                            sAction = "showDetailsAfterUpdateReject";
	                            msg = "<font color='red'>" + getTran("web.manage", "orderexists", sWebLanguage) + "</font>";
	                        }
	                    }
	                }
	                orderIsClosed = true;
	                // reload opener to see the change in level
	                displayUndeliveredOrders=true;
	                displayDeliveredOrders=false;
	            }
	            else {
	                %>
	                <script>
	                    alert('<%=getTranNoLink("web",sResult,sWebLanguage)%>');
	                </script>
	                <%
	                displayUndeliveredOrders=false;
	                displayDeliveredOrders=false;
	                sAction = "showDetailsAfterUpdateReject";
	                msg = "<font color='red'>" + getTranNoLink("web",sResult,sWebLanguage) + "</font>";
	            }
	        //}
	        //else {
	        //        sAction = "showDetailsAfterUpdateReject";
	        //        msg = "<font color='red'>" + getTran("web.manage", "orderexists", sWebLanguage) + "</font>";
	        //}
		}
        if (Debug.enabled) Debug.println("*** orderIsClosed : " + orderIsClosed);

        sEditOrderUid = order.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete") && sEditOrderUid.length() > 0) {
        ProductOrder.delete(sEditOrderUid);
        msg = getTran("web", "dataisdeleted", sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if (sAction.equals("sort")) {
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if (sAction.startsWith("find")) {
        displaySearchFields = true;
        if (sAction.equals("findShowOverview")) displayEditFields = false;

        Vector orders = ProductOrder.find(displayDeliveredOrders, displayUndeliveredOrders,
                sFindDescription, sFindServiceUid, sFindProductStockUid,
                sFindPackagesOrdered, sFindDateDeliveryDue, sFindDateOrdered,
                sFindSupplierUid, sFindServiceStockUid, sSortCol, sSortDir,sFindDateDeliveredSince);

        if (displayDeliveredOrders) ordersHtml = ordersToHtml(orders, sWebLanguage);
        if (displayUndeliveredOrders) ordersHtml = undeliveredOrdersToHtml(orders, sWebLanguage);
        foundOrderCount = orders.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if (sAction.startsWith("showDetails")) {
        displayEditFields = true;
        displaySearchFields = false;
        String sPrevUsedDocument = checkString((String) session.getAttribute("PrevUsedDocument"));
        if(sEditProductStockDocumentUid.length() == 0 && sPrevUsedDocument.length() > 0) {
        	sEditProductStockDocumentUid = sPrevUsedDocument;
        }
        if(sEditProductStockDocumentUid.length()>0){
        	sEditProductStockDocumentUidText=getTran("operationdocumenttypes",OperationDocument.get(sEditProductStockDocumentUid).getType(),sWebLanguage);
        }

        // get specified record
        if ((sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")) && sEditOrderUid.length()>0) {
            ProductOrder order = ProductOrder.get(sEditOrderUid);

            sSelectedProductStockUid = order.getProductStockUid();
            sSelectedDescription = checkString(order.getDescription());
            sSelectedPackagesOrdered = (order.getPackagesOrdered() < 0 ? "" : order.getPackagesOrdered() + "");
            sSelectedPackagesDelivered = (order.getPackagesDelivered() < 0 ? "" : order.getPackagesDelivered() + "");
            sSelectedImportance = checkString(order.getImportance());

            // format date ordered
            java.util.Date tmpDate = order.getDateOrdered();
            if (tmpDate != null) sSelectedDateOrdered = stdDateFormat.format(tmpDate);

            // format date delivery due
            tmpDate = order.getDateDeliveryDue();
            if (tmpDate != null) sSelectedDateDeliveryDue = stdDateFormat.format(tmpDate);

            // format date delivered
            tmpDate = order.getDateDelivered();
            if (tmpDate != null) sSelectedDateDelivered = stdDateFormat.format(tmpDate);

            // afgeleide data
            ProductStock productStock = ProductStock.get(sSelectedProductStockUid);
            sSelectedProductName = productStock.getProduct().getName();
        } else if (sAction.equals("showDetailsAfterAddReject")) {
            // do not get data from DB, but show data that were allready on form
            sSelectedProductStockUid = sEditProductStockUid;
            sSelectedDescription = sEditDescription;
            sSelectedPackagesOrdered = sEditPackagesOrdered;
            sSelectedPackagesDelivered = sEditPackagesDelivered;
            sSelectedDateOrdered = sEditDateOrdered;
            sSelectedDateDeliveryDue = sEditDateDeliveryDue;
            sSelectedDateDelivered = sEditDateDelivered;
            sSelectedImportance = sEditImportance;
            sSelectedProductName = sEditProductName;

            // afgeleide data
            sSelectedProductName = sEditProductName;
        } else if (sAction.equals("showDetailsNew")) {
            sSelectedProductStockUid = sEditProductStockUid;
            displayDeliveredOrders = false;
            displayUndeliveredOrders = false;

            // afgeleide data
            sSelectedProductName = sEditProductName;
        }
    }

    // clear 0 if no delivered date
    if (sSelectedDateDelivered.length() == 0) {
        if (sSelectedPackagesDelivered.equals("0")) sSelectedPackagesDelivered = "";
    }
    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown;
    if (sAction.startsWith("showDetails")) {
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSave();}\"";
    } else {
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch(" + displayDeliveredOrders + ",'" + sDefaultSortCol + "');}\"";
    }
%>
<form name="transactionForm" id="transactionForm" method="post" <%=sOnKeyDown%> <%=((displaySearchFields||orderIsClosed)?"onClick=\"clearMessage();\"":"onClick=\"setSaveButton(event);clearMessage();\" onKeyUp=\"setSaveButton(event);\"")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","ManageProductOrders",sWebLanguage," doBack();")%>
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
                <table width="100%" class="list" cellpadding="0" cellspacing="1" onKeyDown="if(enterEvent(event,13)){doSearch(<%=displayDeliveredOrders%>,'<%=sDefaultSortCol%>');}">
                    <%-- description --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","description",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindDescription" value="<%=sFindDescription%>" size="<%=sTextWidth%>" maxLength="255">
                        </td>
                    </tr>
                    <%-- Supplier --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindSupplierUid" value="<%=sFindSupplierUid%>">
                            <input class="text" type="text" name="FindSupplierName" readonly size="<%=sTextWidth%>" value="<%=sFindSupplierName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('FindSupplierUid','FindSupplierName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindSupplierUid.value='';transactionForm.FindSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- Service --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","Service",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceUid" value="<%=sFindServiceUid%>">
                            <input class="text" type="text" name="FindServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('FindServiceUid','FindServiceName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceUid.value='';transactionForm.FindServiceName.value='';">
                        </td>
                    </tr>
                    <%-- ServiceStock --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","ServiceStock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceStockUid" value="<%=sFindServiceStockUid%>">
                            <input class="text" type="text" name="FindServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceStockName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('FindServiceStockUid','FindServiceStockName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceStockUid.value='';transactionForm.FindServiceStockName.value='';">
                        </td>
                    </tr>
                    <%-- ProductStock --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","ProductStock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindProductStockUid" value="<%=sFindProductStockUid%>">
                            <input class="text" type="text" name="FindProductName" readonly size="<%=sTextWidth%>" value="<%=sFindProductName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductStock('FindProductStockUid','FindProductName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindProductStockUid.value='';transactionForm.FindProductName.value='';">
                        </td>
                    </tr>
                    <%-- PackagesOrdered --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","PackagesOrdered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindPackagesOrdered" value="<%=sFindPackagesOrdered%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- PackagesDelivered --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","PackagesDelivered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindPackagesDelivered" value="<%=sFindPackagesDelivered%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- DateOrdered --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","DateOrdered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindDateOrdered","transactionForm",sFindDateOrdered,sWebLanguage)%></td>
                    </tr>
                    <%-- DateDeliveryDue --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","DateDeliveryDue",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindDateDeliveryDue","transactionForm",sFindDateDeliveryDue,sWebLanguage)%></td>
                    </tr>
                    <%-- DateDelivered --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","DateDelivered",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindDateDelivered","transactionForm",sFindDateDelivered,sWebLanguage)%></td>
                    </tr>
                    <%-- importance (dropdown : native|high|low) --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","Importance",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="FindImportance">
                                <option value=""></option>
                                <%=ScreenHelper.writeSelectUnsorted("productorder.importance",sFindImportance,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch(<%=displayDeliveredOrders%>,'<%=sDefaultSortCol%>');">

                            <%-- since 1 --%>
                            <span id="sinceDiv" <%=(displayUndeliveredOrders?"style='display:none;'":"")%>>
                                <%=getTran("Web","since",sWebLanguage)%>&nbsp;<%=ScreenHelper.writeDateField("FindDateDeliveredSince","transactionForm",sFindDateDeliveredSince,true,false,sWebLanguage,sCONTEXTPATH)%>&nbsp;
                            </span>

                            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                            <input type="button" class="button" name="searchComplementButton" value="<%=getTranNoLink("Web.manage",(displayDeliveredOrders?"undeliveredOrders":"deliveredOrders"),sWebLanguage)%>" onclick="doSearch(<%=!displayDeliveredOrders%>,'<%=sSortCol%>');">

                            <%-- since 2 --%>
                            <span id="sinceDiv" <%=(displayDeliveredOrders?"style='display:none;'":"")%>>
                                <%=getTran("Web","since",sWebLanguage)%>&nbsp;<%=ScreenHelper.writeDateField("FindDateDeliveredSince","transactionForm",sFindDateDeliveredSince,true,false,sWebLanguage,sCONTEXTPATH)%>
                            </span>

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
                <input type="hidden" name="FindDescription" value="<%=sFindDescription%>">
                <input type="hidden" name="FindServiceStockUid" value="<%=sFindServiceStockUid%>">
                <input type="hidden" name="FindServiceName" value="<%=sFindServiceName%>">
                <input type="hidden" name="FindServiceUid" value="<%=sFindServiceUid%>">
                <input type="hidden" name="FindServiceStockName" value="<%=sFindServiceStockName%>">
                <input type="hidden" name="FindProductStockUid" value="<%=sFindProductStockUid%>">
                <input type="hidden" name="FindProductName" value="<%=sFindProductName%>">
                <input type="hidden" name="FindPackagesOrdered" value="<%=sFindPackagesOrdered%>">
                <input type="hidden" name="FindPackagesDelivered" value="<%=sFindPackagesDelivered%>">
                <input type="hidden" name="FindDateOrdered" value="<%=sFindDateOrdered%>">
                <input type="hidden" name="FindDateDeliveryDue" value="<%=sFindDateDeliveryDue%>">
                <input type="hidden" name="FindDateDelivered" value="<%=sFindDateDelivered%>">
                <input type="hidden" name="FindImportance" value="<%=sFindImportance%>">
                <input type="hidden" name="FindDateDeliveredSince" value="<%=sFindDateDeliveredSince%>">
            <%
        }

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(!sAction.equals("showDetails")){
            //*** UNDELIVERED ORDERS ***
            if(displayUndeliveredOrders){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <%-- sub title --%>
                    <table width="100%" cellspacing="0">
                        <tr>
                            <td class="titleadmin">&nbsp;
                                <%
                                    if(sFindServiceUid.length() > 0){
                                        %><%=getTran("Web.manage","UndeliveredOrdersFor"+(activePatient==null?"User":"Patient")+"Division",sWebLanguage)%>&nbsp;'<%=getTran("service",sFindServiceUid,sWebLanguage)%>'<%
                                    }
                                    else{
                                        %><%=getTran("Web.manage","UndeliveredOrders",sWebLanguage)%><%
                                    }
                                %>
                            </td>
                        </tr>
                    </table>
                    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="22" nowrap>&nbsp;</td>
                            <td width="20%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_ORDER_DESCRIPTION');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION")?"<"+sSortDir+">":"")%><%=getTran("Web","description",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION")?"<"+sSortDir+">":"")%></a></td>
                            <td width="14%"><%=getTran("Web","servicestock",sWebLanguage)%></td>
                            <td width="20%"><%=getTran("Web","product",sWebLanguage)%></td>
                            <td width="10%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_ORDER_PACKAGESORDERED');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED")?"<"+sSortDir+">":"")%><%=getTran("Web","packagesordered",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED")?"<"+sSortDir+">":"")%></a></td>
                            <td width="10%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_ORDER_DATEORDERED');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED")?"<"+sSortDir+">":"")%><%=getTran("Web","dateordered",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED")?"<"+sSortDir+">":"")%></a></td>
                            <td width="18%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_ORDER_DATEDELIVERYDUE');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERYDUE")?"<"+sSortDir+">":"")%><%=getTran("Web","datedeliverydue",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERYDUE")?"<"+sSortDir+">":"")%></a></td>
                            <td width="*"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_ORDER_IMPORTANCE');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_IMPORTANCE")?"<"+sSortDir+">":"")%><%=getTran("Web","importance",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_IMPORTANCE")?"<"+sSortDir+">":"")%></a></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=ordersHtml%>
                        </tbody>
                    </table>
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
                    <br><br>
                <%
            }

            //*** DELIVERED ORDERS ***
            if(displayDeliveredOrders){
                %>
                    <%-- sub title --%>
                    <table width="100%" cellspacing="0">
                        <tr>
                            <td class="titleadmin">&nbsp;
                                <%
                                    if(sFindServiceUid.length() > 0){
                                        %><%=getTran("Web.manage","DeliveredOrdersFor"+(activePatient==null?"User":"Patient")+"Division",sWebLanguage)%>&nbsp;'<%=getTran("service",sFindServiceUid,sWebLanguage)%>' <%=getTran("web","since",sWebLanguage)%> <%=sFindDateDeliveredSince%><%
                                    }
                                    else{
                                        %><%=getTran("Web.manage","DeliveredOrders",sWebLanguage)%><%
                                    }
                                %>
                            </td>
                        </tr>
                    </table>
                <%

                // display found orders
                if(foundOrderCount > 0){
                    String sortTran = getTran("web","clicktosort",sWebLanguage);
                    %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="22" nowrap>&nbsp;</td>
                            <td width="20%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSearch(<%=displayDeliveredOrders%>,'OC_ORDER_DESCRIPTION');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION")?"<"+sSortDir+">":"")%><%=getTran("Web","description",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DESCRIPTION")?"<"+sSortDir+">":"")%></a></td>
                            <td width="14%"><%=getTran("Web","servicestock",sWebLanguage)%></td>
                            <td width="25%"><%=getTran("Web","product",sWebLanguage)%></td>
                            <td width="10%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSearch(<%=displayDeliveredOrders%>,'OC_ORDER_PACKAGESORDERED');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED")?"<"+sSortDir+">":"")%><%=getTran("Web","packagesordered",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_PACKAGESORDERED")?"<"+sSortDir+">":"")%></a></td>
                            <td width="10%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSearch(<%=displayDeliveredOrders%>,'OC_ORDER_DATEORDERED');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED")?"<"+sSortDir+">":"")%><%=getTran("Web","dateordered",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEORDERED")?"<"+sSortDir+">":"")%></a></td>
                            <td width="10%"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSearch(<%=displayDeliveredOrders%>,'OC_ORDER_DATEDELIVERED');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERED")?"<"+sSortDir+">":"")%><%=getTran("Web","datedelivered",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_DATEDELIVERED")?"<"+sSortDir+">":"")%></a></td>
                            <td width="*"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSearch(<%=displayDeliveredOrders%>,'OC_ORDER_IMPORTANCE');"><%=(sSortCol.equalsIgnoreCase("OC_ORDER_IMPORTANCE")?"<"+sSortDir+">":"")%><%=getTran("Web","importance",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_ORDER_IMPORTANCE")?"<"+sSortDir+">":"")%></a></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=ordersHtml%>
                        </tbody>
                    </table>
                    <%-- number of records found --%>
                    <%=foundOrderCount%> <%=getTran("web","deliveredOrdersFound",sWebLanguage)%>
                    <br>
                    <%
                }
                else{
                    // no records found
                    %>
                    <%=getTran("web","noDeliveredOrdersFound",sWebLanguage)%>
                    <br>
                    <%
                }
            }
        }

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            if(!orderIsClosed){
                %>
                    <table class="list" width="100%" cellspacing="1">
                        <%-- description --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","description",sWebLanguage)%> *</td>
                            <td class="admin2">
                                <input type="text" class="text" name="EditDescription" value="<%=sSelectedDescription%>" size="<%=sTextWidth%>" maxLength="255">
                            </td>
                        </tr>
                        <%-- ProductStock --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","ProductStock",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                                <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                                <%
                                    // only display 'SearchProductStockButton' if order is not closed and thus editable
                                    if(!orderIsClosed){
                                        %>
                                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductStock('EditProductStockUid','EditProductName');">
                                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductStockUid.value='';transactionForm.EditProductName.value='';">
                                        <%
                                    }
                                %>
                            </td>
                        </tr>
                        <%-- PackagesOrdered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","PackagesOrdered",sWebLanguage)%>&nbsp;*</td>
                            <td class="admin2">
                                <input type="text" class="text" name="EditPackagesOrdered" value="<%=sSelectedPackagesOrdered%>" size="5" maxLength="5" onKeyUp="if(!isNumberLimited(this,1,99999)){this.value='';}">
                            </td>
                        </tr>
                        <%-- PackagesDelivered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","PackagesDelivered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="text" class="text" name="EditPackagesDelivered" value="<%=sSelectedPackagesDelivered%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                            </td>
                        </tr>
                        <%-- DateOrdered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateOrdered",sWebLanguage)%>&nbsp;*</td>
                            <td class="admin2">
                                <input type="text" class="text" size="12" maxLength="12" value="<%=sSelectedDateOrdered%>" name="EditDateOrdered" id="EditDateOrdered" onBlur="checkDate(this);">
                                <%
                                    // only display 'EditDateOrdered' if order is not closed and thus editable
                                    if(!orderIsClosed){
                                        %><script>writeMyDate("EditDateOrdered","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script><%

                                        // if new order : set today as default value for date-ordered
                                        if(sAction.equals("showDetailsNew")){
                                            %><script>getToday(document.all['EditDateOrdered']);</script><%
                                        }
                                    }
                                %>
                            </td>
                        </tr>
                        <%-- DateDeliveryDue --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateDeliveryDue",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="text" class="text" size="12" maxLength="12" value="<%=sSelectedDateDeliveryDue%>" name="EditDateDeliveryDue" id="EditDateDeliveryDue" onBlur="checkDate(this);">

                                <%
                                    // only display 'EditDateDeliveryDue' if order is not closed and thus editable
                                    if(!orderIsClosed){
                                        %><script>writeMyDate("EditDateDeliveryDue","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script><%
                                    }
                                %>
                            </td>
                        </tr>
                        <%-- DateDelivered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateDelivered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="text" class="text" size="12" maxLength="12" value="<%=sSelectedDateDelivered%>" name="EditDateDelivered" id="EditDateDelivered" onBlur="checkDate(this);">

                                <%
                                    // only display 'EditDateDelivered' if order is not closed and thus editable
                                    if(!orderIsClosed){
                                        %><script>writeMyDate("EditDateDelivered","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script><%
                                    }
                                %>
                            </td>
                        </tr>
	                    <tr id='documentline'>
	                        <td class="admin"><%=getTran("Web","productstockoperationdocument",sWebLanguage)%></td>
		                    <td class="admin2">
		                    	<input type='text' class='text' name='EditProductStockDocumentUid' id='EditProductStockDocumentUid' size='10' value="<%=sEditProductStockDocumentUid %>" readonly/>
		                    	<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick="searchDocument('EditProductStockDocumentUid','EditProductStockDocumentUidText');">&nbsp;
		                    	<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick="transactionForm.EditProductStockDocumentUid.value='';document.getElementById('EditProductStockDocumentUidText').innerHTML='';">
		                    	<label class='text' name='EditProductStockDocumentUidText' id='EditProductStockDocumentUidText'><%=sEditProductStockDocumentUidText %></label>
		                    </td>
	                    </tr>
                        <%-- importance (dropdown : native|high|low) --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","Importance",sWebLanguage)%>&nbsp;*</td>
                            <td class="admin2">
                                <select class="text" name="EditImportance">
                                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                    <%=ScreenHelper.writeSelectUnsorted("productorder.importance",sSelectedImportance,sWebLanguage)%>
                                </select>
                            </td>
                        </tr>
                        <%-- EDIT BUTTONS --%>
                        <tr>
                            <td class="admin2">&nbsp;</td>
                            <td class="admin2">
                                <%
                                    if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                        // existing order : display saveButton with save-label
                                        %>
                                            <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                                            <input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditOrderUid%>');">
                                            <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();">
                                        <%
                                    }
                                    else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                        // new order : display saveButton with add-label
                                        %>
                                            <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAdd();">
                                            <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();">
                                        <%
                                    }
                                %>
                                <%-- display message --%>
                                <span id="msgArea"><%=msg%></span>
                            </td>
                        </tr>
                    </table>
                    <%-- indication of obligated fields --%>
                    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
                    <br>
                    <br>
                <%
            }
            else{
                // order is not editable
                %>
                    <table class="list" width="100%" cellspacing="1">
                        <%-- description --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","description",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedDescription%></td>
                        </tr>
                        <%-- ProductStock --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","ProductStock",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedProductName%></td>
                        </tr>
                        <%-- PackagesOrdered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","PackagesOrdered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedPackagesOrdered%></td>
                        </tr>
                        <%-- PackagesDelivered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","PackagesDelivered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedPackagesDelivered%></td>
                        </tr>
                        <%-- DateOrdered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateOrdered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedDateOrdered%></td>
                        </tr>
                        <%-- DateDeliveryDue --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateDeliveryDue",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedDateDeliveryDue%></td>
                        </tr>
                        <%-- DateDelivered --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","DateDelivered",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=sSelectedDateDelivered%></td>
                        </tr>
                        <%-- importance (dropdown : native|high|low) --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","Importance",sWebLanguage)%>&nbsp;*</td>
                            <td class="admin2"><%=getTran("productorder.importance",sSelectedImportance,sWebLanguage)%></td>
                        </tr>
                        <%-- display message --%>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2">
                                <span id="msgArea"><%=getTran("web.manage","orderclosedanduneditable",sWebLanguage)%></span>
                            </td>
                        </tr>
                        <%-- EDIT BUTTONS --%>
                        <tr>
                            <td class="admin2"/>
                            <td class="admin2">
                                <%-- BACK TO OVERVIEW --%>
                                <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();">
                                <%-- display message --%>
                                <span id="msgArea"><%=msg%></span>
                            </td>
                        </tr>
                    </table>
                    <br>
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
    <input type="hidden" name="DisplayDeliveredOrders" value="<%=displayDeliveredOrders%>">
    <input type="hidden" name="DisplayUndeliveredOrders" value="<%=displayUndeliveredOrders%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields && !orderIsClosed){
          %>transactionForm.EditDescription.focus();<%
      }

      if(displaySearchFields){
          %>transactionForm.FindDescription.focus();<%
      }
  %>
  <%-- DO ADD --%>
  function doAdd(){
    transactionForm.EditOrderUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkOrderFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditDescription.value.length==0){
        transactionForm.EditDescription.focus();
      }
      else if(transactionForm.EditProductStockUid.value.length==0){
        transactionForm.EditProductName.focus();
      }
      else if(transactionForm.EditPackagesOrdered.value.length==0){
        transactionForm.EditPackagesOrdered.focus();
      }
      else if(transactionForm.EditDateOrdered.value.length==0){
        transactionForm.EditDateOrdered.focus();
      }
      else if(transactionForm.EditImportance.value.length==0){
        transactionForm.EditImportance.focus();
      }
    }
  }

  <%-- CHECK ORDER FIELDS --%>
  function checkOrderFields(){
    var maySubmit = false;

    <%-- required fields --%>
    if(!transactionForm.EditDescription.value.length==0 &&
       !transactionForm.EditProductStockUid.value.length==0 &&
       !transactionForm.EditPackagesOrdered.value.length==0 &&
       !transactionForm.EditDateOrdered.value.length==0 &&
       !transactionForm.EditImportance.value.length==0){
      maySubmit = true;

      <%-- check dates 1 and 2 --%>
      if(maySubmit){
        if(transactionForm.EditDateOrdered.value.length>0 && transactionForm.EditDateDeliveryDue.value.length>0){
          var dateOrdered     = transactionForm.EditDateOrdered.value;
          var dateDeliveryDue = transactionForm.EditDateDeliveryDue.value;

          if(!before(dateDeliveryDue,dateOrdered)){
            maySubmit = true;
          }
          else{
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=DateDeliveryDueMustComeAfterDateOrdered";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","DateDeliveryDueMustComeAfterDateOrdered",sWebLanguage)%>");

            maySubmit = false;
            transactionForm.EditDateDeliveryDue.focus();
          }
        }
        else{
          maySubmit = true;
        }
      }

      <%-- check dates 1 and 3 --%>
      if(maySubmit){
        if(transactionForm.EditDateOrdered.value.length>0 && transactionForm.EditDateDelivered.value.length>0){
          var dateOrdered   = transactionForm.EditDateOrdered.value;
          var dateDelivered = transactionForm.EditDateDelivered.value;

          if(!before(dateDelivered,dateOrdered)){
            maySubmit = true;
          }
          else{
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=DateDeliveredMustComeAfterDateOrdered";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","DateDeliveredMustComeAfterDateOrdered",sWebLanguage)%>");

            maySubmit = false;
            transactionForm.EditDateDelivered.focus();
          }
        }
        else{
          maySubmit = true;
        }
      }

      <%-- check numberOfPackagesDelivered if deliveredDate is specified --%>
      if(maySubmit){
        if(transactionForm.EditPackagesDelivered.value.length>0 && transactionForm.EditDateDelivered.value.length==0){
          var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=PackagesAndDateDeliveredMustBeSpecified";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","PackagesAndDateDeliveredMustBeSpecified",sWebLanguage)%>");

          maySubmit = false;
          transactionForm.EditDateDelivered.focus();
        }
        else if(transactionForm.EditPackagesDelivered.value.length==0 && transactionForm.EditDateDelivered.value.length>0){
          var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=PackagesAndDateDeliveredMustBeSpecified";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","PackagesAndDateDeliveredMustBeSpecified",sWebLanguage)%>");

          maySubmit = false;
          transactionForm.EditPackagesDelivered.focus();
        }
      }
    }
    else{
      maySubmit = false;

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(orderUid){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");


    if(answer==1){
      transactionForm.EditOrderUid.value = orderUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO NEW --%>
  function doNew(){
    <%
        if(displayEditFields){
            %>clearEditFields();<%
        }

        if(displaySearchFields){
            %>clearSearchFields();<%
        }
    %>

    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    if(transactionForm.searchDeliveredOrdersButton!=undefined) transactionForm.searchDeliveredOrdersButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(orderUid){
    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.searchDeliveredOrdersButton!=undefined) transactionForm.searchDeliveredOrdersButton.disabled = true;

    transactionForm.EditOrderUid.value = orderUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

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
    transactionForm.FindPackagesDelivered.value = "";
    transactionForm.FindDateOrdered.value = "";
    transactionForm.FindDateDeliveryDue.value = "";
    transactionForm.FindDateDelivered.value = "";
    transactionForm.FindImportance.value = "";
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditProductStockUid.value = "";
    transactionForm.EditProductName.value = "";

    transactionForm.EditDescription.value = "";
    transactionForm.EditPackagesOrdered.value = "";
    transactionForm.EditPackagesDelivered.value = "";
    transactionForm.EditDateOrdered.value = "";
    transactionForm.EditDateDeliveryDue.value = "";
    transactionForm.EditDateDelivered.value = "";
    transactionForm.EditImportance.value = "";
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
  function doSearch(deliverdOrUndelivered,sortCol){
    if(!transactionForm.FindProductStockUid.value.length==0 ||
       !transactionForm.FindSupplierUid.value.length==0 ||
       !transactionForm.FindServiceUid.value.length==0 ||
       !transactionForm.FindServiceStockUid.value.length==0 ||
       !transactionForm.FindDescription.value.length==0 ||
       !transactionForm.FindPackagesOrdered.value.length==0 ||
       !transactionForm.FindPackagesDelivered.value.length==0 ||
       !transactionForm.FindDateOrdered.value.length==0 ||
       !transactionForm.FindDateDeliveryDue.value.length==0 ||
       !transactionForm.FindDateDelivered.value.length==0 ||
       !transactionForm.FindImportance.value.length==0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;

      transactionForm.searchButton.disabled = true;
      transactionForm.searchComplementButton.disabled = true;
      transactionForm.clearButton.disabled = true;

      transactionForm.DisplayDeliveredOrders.value = deliverdOrUndelivered;
      transactionForm.DisplayUndeliveredOrders.value = !deliverdOrUndelivered;

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

  <%-- DO DEFAULT PAGE LOAD --%>
  function doDefaultPageLoad(){
    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    if(transactionForm.searchDeliveredOrdersButton!=undefined) transactionForm.searchDeliveredOrdersButton.disabled = true;

    openSearchInProgressPopup();
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageProductOrders.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
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

  <%-- DO BACK TO OVERVIEW --%>
  function doBackToOverview(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web","areyousuretodiscard",sWebLanguage)%>')){
      <%
          if(displayDeliveredOrders || displayUndeliveredOrders){
              %>transactionForm.Action.value = "";<%
          }
          else{
              %>transactionForm.Action.value = "find";<%
          }
      %>

      transactionForm.DisplaySearchFields.value = "true";
      transactionForm.returnButton.disabled = true;
      transactionForm.submit();
    }
  }
  <%-- popup : search document --%>
  function searchDocument(documentUidField,documentUidTextField){
	<%
	String sDocumentSource="";
	String sDocumentSourceText="";
	String sFindMinDate="";
		ProductStock productStock = ProductStock.get(sEditProductStockUid);
		if(productStock!=null && productStock.getServiceStockUid()!=null){
			sDocumentSource=productStock.getServiceStockUid();
			sDocumentSourceText=productStock.getServiceStock().getName();
			sFindMinDate=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date().getTime()-7*24*3600*1000);
		}
		
	%>
    openPopup("/_common/search/searchStockOperationDocument.jsp&ts=<%=getTs()%>&documentuid="+document.getElementById("EditProductStockDocumentUid").value+"&finddocumentsource=<%=sDocumentSource%>&finddocumentmindate=<%=sFindMinDate%>&finddocumentsourcetext=<%=sDocumentSourceText%>&ReturnDocumentID="+documentUidField+"&ReturnDocumentName="+documentUidTextField);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageProductOrders.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>