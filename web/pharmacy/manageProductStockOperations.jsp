<%@page import="be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.common.ObjectReference,
                be.openclinic.pharmacy.ProductStock,
                java.util.Vector" %>
<%@ page import="be.openclinic.pharmacy.ServiceStock" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.manageproductstockoperations","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- GET FOUND OPERATIONS FROM RS ------------------------------------------------------------
    private Vector getFoundOperationsFromRs(StringBuffer operations, Vector vOperations, String sWebLanguage) throws SQLException {
        Vector idsVector = new Vector();
        String sClass = "1", sOperationUid, srcDestType = "", srcDestUid, srcDestTypeTran = "",
                srcDestName = "", sOperationDescr, labelType, sProductName;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        java.util.Date operationDate;
        ProductStock productStock;
        Iterator iter = vOperations.iterator();

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found operations
        ProductStockOperation operation;
        while (iter.hasNext()) {

            operation = (ProductStockOperation) iter.next();

            // operation UID
            sOperationUid = operation.getUid();
            idsVector.add(sOperationUid);

            // ProductStock
            productStock = ProductStock.get(operation.getProductStockUid());

            // operationDate
            operationDate = operation.getDate();

            // sourceDestination (patient|medic|service)
            srcDestType = operation.getSourceDestination().getObjectType();
            srcDestUid = operation.getSourceDestination().getObjectUid();

            if (srcDestType.equals("patient")) {
              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                srcDestName = ScreenHelper.getFullPersonName(srcDestUid, ad_conn);
                ad_conn.close();
            } else if (srcDestType.equals("servicestock")) {
                ServiceStock serviceStock =ServiceStock.get(srcDestUid);
                if(serviceStock!=null){
                    srcDestName = serviceStock.getName();
                }
            }

            srcDestTypeTran = getTran("productstockoperation.sourcedestinationtype", srcDestType, sWebLanguage);

            // translate description
            sOperationDescr = operation.getDescription();
            labelType = "productstockoperation." + sOperationDescr.substring(0, sOperationDescr.indexOf("."));
            sOperationDescr = getTranNoLink(labelType, sOperationDescr, sWebLanguage);

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display operation in one row ***
            operations.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\" align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' class='link' alt='" + deleteTran + "' onclick=\"doDelete('" + sOperationUid + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + sOperationDescr + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + (productStock != null ? productStock.getProduct().getName() : "") + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + srcDestTypeTran + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + srcDestName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + (operationDate == null ? "" : stdDateFormat.format(operationDate)) + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sOperationUid + "');\">" + operation.getUnitsChanged() + "</td>")
                    .append("</tr>");
        }
        return idsVector;
    }
%>

<%
    String sDefaultSortCol = "OC_OPERATION_DATE";
    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditOperationUid    = checkString(request.getParameter("EditOperationUid")),
           sEditOperationDescr  = checkString(request.getParameter("EditOperationDescr")),
           sEditUnitsChanged    = checkString(request.getParameter("EditUnitsChanged")),
           sEditSrcDestType     = checkString(request.getParameter("EditSrcDestType")),
           sEditSrcDestUid      = checkString(request.getParameter("EditSrcDestUid")),
           sEditSrcDestName     = checkString(request.getParameter("EditSrcDestName")),
           sEditProductName     = checkString(request.getParameter("EditProductName")),
           sEditOperationDate   = checkString(request.getParameter("EditOperationDate")),
           sEditProductStockUid = checkString(request.getParameter("EditProductStockUid"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n\n################## sAction : "+sAction+" ############################");
        Debug.println("* sEditOperationUid      : "+sEditOperationUid);
        Debug.println("* sEditOperationDescr    : "+sEditOperationDescr);
        Debug.println("* sEditUnitsChanged      : "+sEditUnitsChanged);
        Debug.println("* sEditSrcDestType       : "+sEditSrcDestType);
        Debug.println("* sEditSrcDestUid        : "+sEditSrcDestUid);
        Debug.println("* sEditSrcDestName       : "+sEditSrcDestName);
        Debug.println("* sEditOperationDate     : "+sEditOperationDate);
        Debug.println("* sEditProductStockUid   : "+sEditProductStockUid+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    // variables
    String msg = "", sFindOperationDescr, sFindSrcDestType = "", sFindOperationDate,
           sFindProductStockUid, sFindUnitsChanged, sSelectedOperationDescr = "",
           sSelectedSrcDestType = "", sSelectedSrcDestUid = "", sSelectedSrcDestName = "",
           sSelectedOperationDate = "", sSelectedProductName = "", sSelectedUnitsChanged = "",
           sSelectedProductStockUid = "";

    
    int foundOperationCount = 0;
    StringBuffer operationsHtml = null;
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // get data from form
    sFindOperationDescr  = checkString(request.getParameter("FindOperationDescr"));
    sFindSrcDestType     = checkString(request.getParameter("FindSrcDestType"));
    sFindOperationDate   = checkString(request.getParameter("FindOperationDate"));
    sFindProductStockUid = checkString(request.getParameter("FindProductStockUid"));
    sFindUnitsChanged    = checkString(request.getParameter("FindUnitsChanged"));

    // display options
    boolean displayEditFields = false, displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    if(Debug.enabled) Debug.println("@@@ displaySearchFields : "+displaySearchFields);

    // frequently used translations
    String clearTran = getTranNoLink("Web","clear",sWebLanguage);

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = sDefaultSortCol;


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditOperationUid.length()>0){
        // create product
        ProductStockOperation operation = new ProductStockOperation();
        operation.setUid(sEditOperationUid);
        operation.setDescription(sEditOperationDescr);

        // sourceDestination
        ObjectReference sourceDestination = new ObjectReference();
        sourceDestination.setObjectType(sEditSrcDestType);
        sourceDestination.setObjectUid(sEditSrcDestUid);
        operation.setSourceDestination(sourceDestination);
        operation.setProductStockUid(sEditProductStockUid);
        operation.setUpdateUser(activeUser.userid);

        if(sEditOperationDate.length() > 0) operation.setDate(stdDateFormat.parse(sEditOperationDate));
        if(sEditUnitsChanged.length() > 0)  operation.setUnitsChanged(Integer.parseInt(sEditUnitsChanged));

        //***** save operation *****
        operation.store();

        // show saved data
        sAction = "showDetails";
        msg = getTran("web","dataissaved",sWebLanguage);

        sEditOperationUid = operation.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditOperationUid.length()>0){
        ProductStockOperation.delete(sEditOperationUid);
        msg = getTran("web","dataisdeleted",sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //-- FIND -------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        displaySearchFields = true;
        displayFoundRecords = true;

        Vector vOperations =  ProductStockOperation.searchProductStockOperations(sFindOperationDescr,sFindSrcDestType,sFindOperationDate,sFindProductStockUid,sFindUnitsChanged,sSortCol);
        operationsHtml = new StringBuffer();
        Vector idsVector = getFoundOperationsFromRs(operationsHtml,vOperations,sWebLanguage);
        foundOperationCount = idsVector.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ProductStockOperation operation = ProductStockOperation.get(sEditOperationUid);

            if(operation!=null){
                sSelectedOperationDescr = operation.getDescription();
                sSelectedOperationDate  = operation.getDate().toString();
                sSelectedUnitsChanged   = Integer.toString(operation.getUnitsChanged());

                // format date
                java.util.Date tmpDate = operation.getDate();
                if(tmpDate!=null) sSelectedOperationDate = stdDateFormat.format(tmpDate);

                // ProductStock
                sSelectedProductStockUid = operation.getProductStockUid();
                ProductStock sSelectedProductStock = ProductStock.get(sSelectedProductStockUid);
                if(sSelectedProductStock!=null){
                    sSelectedProductName = sSelectedProductStock.getProduct().getName();
                }

                // sourceDestination (patient|medic|service)
                sSelectedSrcDestType = operation.getSourceDestination().getObjectType();
                sSelectedSrcDestUid  = operation.getSourceDestination().getObjectUid();

                if(sSelectedSrcDestType.indexOf("patient") > -1 || sSelectedSrcDestType.indexOf("medic") > -1){
                  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    sSelectedSrcDestName = ScreenHelper.getFullPersonName(sSelectedSrcDestUid,ad_conn);
                    ad_conn.close();
                }
                else if(sSelectedSrcDestType.indexOf("service") > -1){
                    sSelectedSrcDestName = getTran("service",sSelectedSrcDestUid,sWebLanguage);
                }
            }
        }
        else if(sAction.equals("showDetailsAfterAddReject")){
            // do not get data from DB, but show data that were allready on form
            sSelectedOperationDescr = sEditOperationDescr;
            sSelectedUnitsChanged   = sEditUnitsChanged;
            sSelectedSrcDestType    = sEditSrcDestType;
            sSelectedSrcDestUid     = sEditSrcDestUid;
            sSelectedSrcDestName    = sEditSrcDestName;
            sSelectedOperationDate  = sEditOperationDate;
            sSelectedProductName    = sEditProductName;
        }
        else{
            // showDetailsNew : empty defaults
            sSelectedSrcDestType = "";
            sSelectedSrcDestUid  = "";
            sSelectedSrcDestName = "";
        }
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown;
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSave();}\"";
    }
    else{
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch('"+sDefaultSortCol+"');}\"";
    }
%>

<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/main.do"/>?Page=pharmacy/manageProductStockOperations.jsp&ts=<%=getTs()%>' <%=sOnKeyDown%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","manageproductstockoperations",sWebLanguage," doBack();")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        if(displaySearchFields){
            // afgeleide data
            String sFindProductStockName = checkString(request.getParameter("FindProductStockName"));

            %>
                <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(enterEvent(event,13)){doSearch(\'<%=sDefaultSortCol%>\');}';" onKeyDown="if(enterEvent(event,13)){doSearch('<%=sDefaultSortCol%>');}">
                    <%-- description --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","description",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="FindOperationDescr" style="vertical-align:-2px;">
                                <option value=""></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationdelivery",sFindOperationDescr,sWebLanguage)%>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationreceipt",sFindOperationDescr,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- units changed --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","unitschanged",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindUnitsChanged" size="5" maxLength="5" value="<%=sFindUnitsChanged%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- SourceDestination type --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","sourcedestinationtype",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="FindSrcDestType">
                                <option value=""></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.sourcedestinationtype",sFindSrcDestType,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- operation date --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","date",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindOperationDate","transactionForm",sFindOperationDate,sWebLanguage)%></td>
                    </tr>
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","productstock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindProductStockUid" value="<%=sFindProductStockUid%>">
                            <input class="text" type="text" name="FindProductStockName" readonly size="<%=sTextWidth%>" value="<%=sFindProductStockName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchProductStock('FindProductStockUid','FindProductStockName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindProductStockUid.value='';transactionForm.FindProductStockName.value='';">
                        </td>
                    </tr>
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch('<%=sDefaultSortCol%>');">
                            <input type="button" class="button" name="clearButton" value="<%=clearTran%>" onclick="clearSearchFields();">
                            <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;

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
            if(foundOperationCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="22" nowrap>&nbsp;</td>
                            <td width="20%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSearch('OC_OPERATION_DESCRIPTION');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DESCRIPTION")?"<i>":"")%><%=getTran("Web","description",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DESCRIPTION")?"</i>":"")%></a></td>
                            <td width="20%"><%=getTran("Web","product",sWebLanguage)%></td>
                            <td width="10%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSearch('OC_OPERATION_SRCDESTTYPE');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_SRCDESTTYPE")?"<i>":"")%><%=getTran("Web","sourcedestinationtype",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_SRCDESTTYPE")?"</i>":"")%></a></td>
                            <td width="30%"><%=getTran("Web","sourcedestinationname",sWebLanguage)%></td>
                            <td width="10%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSearch('OC_OPERATION_DATE');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DATE")?"<i>":"")%><%=getTran("Web","date",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DATE")?"</i>":"")%></a></td>
                            <td width="*"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSearch('OC_OPERATION_UNITSCHANGED');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_UNITSCHANGED")?"<i>":"")%><%=getTran("Web","unitschanged",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_UNITSCHANGED")?"</i>":"")%></a></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=operationsHtml%>
                        </tbody>
                    </table>
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundOperationCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundOperationCount > 20){
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
        }

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- description --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","description",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="EditOperationDescr" onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationdelivery",sSelectedOperationDescr,sWebLanguage)%>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationreceipt",sSelectedOperationDescr,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- units changed --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","unitschanged",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" size="5" maxLength="5" value="<%=sSelectedUnitsChanged%>" onKeyUp="isNumber(this);" onBlur="displaySrcDestSelector();">
                        </td>
                    </tr>
                    <%-- SourceDestination type --%>
                    <tr height="23">
                        <td class="admin" nowrap><span id="EditSourceDestinationLabel"></span>&nbsp;*</td>
                        <td class="admin2">
                            <%-- SOURCE DESTINATION TYPE SELECTOR --%>
                            <select class="text" name="EditSrcDestType" onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.sourcedestinationtype",sSelectedSrcDestType,sWebLanguage)%>
                            </select>
                            <%-- SOURCE DESTINATION SELECTOR --%>
                            <span id="SrcDestSelector" style="visibility:hidden;">
                                <input type="hidden" name="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
                                <input class="text" type="text" name="EditSrcDestName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSrcDestName%>">
                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
                            </span>
                        </td>
                    </tr>
                    <script>
                      displaySrcDestSelector();

                      <%-- DISPLAY SOURCE DESTINATION SELECTOR --%>
                      function displaySrcDestSelector(){
                        var srcDestType, srcDestUid, srcDestName, descrType;

                        descrType = transactionForm.EditOperationDescr.value;
                        if(descrType.length == 0){
                          document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","sourcedestination",sWebLanguage)%>";
                        }
                        else{
                          if(descrType.indexOf('delivery') > -1){
                            document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","deliveredto",sWebLanguage)%>";
                          }
                          else if(descrType.indexOf('receipt') > -1){
                            document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","receivedby",sWebLanguage)%>";
                          }
                        }

                        srcDestType = transactionForm.EditSrcDestType.value;

                        if(srcDestType!=undefined && srcDestType.length > 0){
                          document.getElementById('SrcDestSelector').style.visibility = 'visible';

                          <%-- medic --%>
                          if(srcDestType.indexOf('medic')>-1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTran("Web","select",sWebLanguage)%>' onclick=\"searchDoctor('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            transactionForm.EditSrcDestUid.value = "<%=activeUser.userid%>";
                            transactionForm.EditSrcDestName.value = "<%=activeUser.person.firstname+" "+activeUser.person.lastname%>";

                            if(descrType.indexOf('delivery') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","deliveredto",sWebLanguage)%>";
                            }
                            else if(descrType.indexOf('receipt') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","receivedby",sWebLanguage)%>";
                            }
                          }
                          <%-- patient --%>
                          else if(srcDestType.indexOf('patient')>-1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTran("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            transactionForm.EditSrcDestUid.value = "<%=activePatient.personid%>";
                            transactionForm.EditSrcDestName.value = "<%=activePatient.firstname+" "+activePatient.lastname%>";

                            if(descrType.indexOf('delivery') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","deliveredto",sWebLanguage)%>";
                            }
                            else if(descrType.indexOf('receipt') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","receivedby",sWebLanguage)%>";
                            }
                          }
                          <%-- service --%>
                          else if(srcDestType.indexOf('service')>-1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTran("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            <%
                                // get active service of active user
                                String serviceId = "";//MedwanQuery.getInstance().getActiveServiceId(Integer.parseInt(activeUser.userid));
                                Service userService = Service.getService(serviceId);
                            %>

                            if(srcDestUid!=undefined && srcDestName!=undefined){
                              transactionForm.EditSrcDestUid.value = srcDestUid;
                              transactionForm.EditSrcDestName.value = srcDestName;
                            }
                            else{
                              transactionForm.EditSrcDestUid.value = "<%=userService.code%>";
                              transactionForm.EditSrcDestName.value = "<%=getTran("service",userService.code,sWebLanguage)%>";
                            }

                            if(descrType.indexOf('delivery') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","deliveredto",sWebLanguage)%>";
                            }
                            else if(descrType.indexOf('receipt') > -1){
                              document.getElementById('EditSourceDestinationLabel').innerHTML = "<%=getTran("Web","receivedby",sWebLanguage)%>";
                            }
                          }
                        }
                        else{
                          document.getElementById('SrcDestSelector').style.visibility = 'hidden';
                        }
                      }
                    </script>
                    <%-- operation date --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","date",sWebLanguage)%> *</td>
                        <td class="admin2"><%=writeDateField("EditOperationDate","transactionForm",sSelectedOperationDate,sWebLanguage)%></td>
                        <%
                            // if new order : set today as default value for dateOrdered
                            if(sAction.equals("showDetailsNew")){
                                %><script>getToday(document.getElementsByName('EditOperationDate')[0]);</script><%
                            }
                        %>
                    </tr>
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","productstock",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                            <input class="text" type="text" name="EditProductStockName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchProductStock('EditProductStockUid','EditProductStockName');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductStockUid.value='';transactionForm.EditProductStockName.value='';">
                        </td>
                    </tr>
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                    // existing product : display saveButton with save-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                                        <input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditOperationUid%>');">
                                    <%
                                }
                                //else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                else{
                                    // new product : display saveButton with add-label + do not display delete button
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAdd();">
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
                <br><br>
            <%
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }

      if(displaySearchFields){
          %>transactionForm.FindOperationDescr.focus();<%
      }
  %>

  <%-- DO ADD --%>
  function doAdd(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.newButton.disabled = true;

      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditOperationDescr.value.length==0){
        transactionForm.EditOperationDescr.focus();
      }
      else if(transactionForm.EditUnitsChanged.value.length==0){
        transactionForm.EditUnitsChanged.focus();
      }
      else if(transactionForm.EditSrcDestType.value.length==0){
        transactionForm.EditSrcDestType.focus();
      }
      else if(transactionForm.EditSrcDestUid.value.length==0){
        transactionForm.EditSrcDestName.focus();
      }
      else if(transactionForm.EditOperationDate.value.length==0){
        transactionForm.EditOperationDate.focus();
      }
      else if(transactionForm.EditProductStockUid.value.length==0){
        transactionForm.EditProductStockName.focus();
      }
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditOperationDescr.value.length>0 ||
       !transactionForm.EditUnitsChanged.value.length>0 ||
       !transactionForm.EditSrcDestType.value.length>0 ||
       !transactionForm.EditSrcDestName.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !transactionForm.EditProductStockUid.value.length>0){
      maySubmit = false;

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(operationUid){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");


    if(answer==1){
      transactionForm.EditStockUid.value = operationUid;
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
    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(operationUid){
    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;

    transactionForm.EditOperationUid.value = operationUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditOperationDescr.value = "";
    transactionForm.EditUnitsChanged.value = "";
    transactionForm.EditSrcDestName.value = "";
    transactionForm.EditOperationDate.value = "";

    transactionForm.EditProductStockUid.value = "";
    transactionForm.EditProductStockName.value = "";
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindOperationDescr.value = "";
    transactionForm.FindOperationDate.value = "";

    transactionForm.FindProductStockUid.value = "";
    transactionForm.FindProductStockName.value = "";

    transactionForm.FindUnitsChanged.value = "";
  }

  <%-- DO SEARCH --%>
  function doSearch(sortCol){
    if(transactionForm.FindOperationDescr.value.length>0 ||
       transactionForm.FindSrcDestType.value.length>0 ||
       transactionForm.FindOperationDate.value.length>0 ||
       transactionForm.FindProductStockUid.value.length>0 ||
       transactionForm.FindUnitsChanged.value.length>0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.newButton.disabled = true;

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

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search patient --%>
  function searchPatient(patientUidField,patientNameField){
    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnName="+patientNameField+"&displayImmatNew=no&isUser=no");
  }

  <%-- popup : search doctor --%>
  function searchDoctor(doctorUidField,doctorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+"&ReturnName="+doctorNameField+"&displayImmatNew=no");
  }

  <%-- popup : search product stock --%>
  function searchProductStock(productStockUidField,productStockNameField){
    openPopup("/_common/search/searchProductStock.jsp&ts=<%=getTs()%>&ReturnProductStockUidField="+productStockUidField+"&ReturnProductStockNameField="+productStockNameField);
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageProductStockOperations.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>