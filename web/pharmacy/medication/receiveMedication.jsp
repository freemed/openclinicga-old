<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.pharmacy.Product,java.util.Hashtable,java.util.Vector,java.util.Calendar,java.util.GregorianCalendar" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("medication.medicationreceipt","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sOperationUid, sUserId, sUserName = "", sDescriptionType,
                sDescription = "", productStockUid, sProductName;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        Hashtable usersHash = new Hashtable(),
                descrTypeTranHash = new Hashtable(),
                productStockHash = new Hashtable();
        ProductStock productStock;
        AdminPerson user = null;
        Product product;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage);

        // run thru found operations
        for (int i = 0; i < objects.size(); i++) {
            ProductStockOperation operation = (ProductStockOperation) objects.get(i);
            sOperationUid = operation.getUid();

            // productStock
            productStockUid = operation.getProductStockUid();
            productStock = (ProductStock) productStockHash.get(productStockUid);
            if (productStock == null) {
                // get productStock from DB
                productStock = ProductStock.get(productStockUid);
                if (productStock != null) {
                    productStockHash.put(productStockUid, productStock);
                }
            }
            if (productStock != null) {

                //  user who did the medication-delivery
                sUserId = operation.getUpdateUser();
                user = (AdminPerson) usersHash.get(sUserId);
                if (user == null) {
                    user = AdminPerson.getAdminPerson(sUserId);
                    usersHash.put(sUserId, user);
                    if (user != null) {
                        sUserName = user.lastname + " " + user.firstname;
                    }
                }

                // description
                sDescriptionType = operation.getDescription();
                if (sDescriptionType.length() > 0) {
                    sDescription = checkString((String) descrTypeTranHash.get(sDescriptionType));
                    if (sDescription.length() == 0) {
                        sDescription = getTran("productstockoperation.patientmedicationreceipt", sDescriptionType, sWebLanguage);
                        descrTypeTranHash.put(sDescriptionType, sDescription);
                    }
                }

                // productName
                product = productStock.getProduct();
                if (product != null) sProductName = product.getName();
                else {
                    sProductName = "<font color='red'>" + getTran("web.manage", "unexistingproduct", sWebLanguage) + "</font>";
                }

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                //*** display operation in one row ***
                html.append("<tr class='list" + sClass + "' onclick=\"doShowDetailsReceipt('" + sOperationUid + "');\"  title='" + detailsTran + "'>")
                        .append(" <td>" + sDescription + "</td>")
                        .append(" <td>" + (operation.getDate() == null ? "" : stdDateFormat.format(operation.getDate())) + "</td>")
                        .append(" <td>" + sProductName + "</td>")
                        .append(" <td>" + Math.abs(operation.getUnitsChanged()) + "</td>")
                        .append(" <td>" + sUserName + "</td>")
                        .append("</tr>");
            }
        }

        return html;
    }
%>
<%
    String sDefaultSortCol = "OC_OPERATION_DATE",
           sDefaultSortDir = "DESC",
           centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           sDefaultSrcDestType = "type2patient";

    // action
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "receiveMedication"; // default

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
        Debug.println("* sEditOperationUid    : "+sEditOperationUid);
        Debug.println("* sEditOperationDescr  : "+sEditOperationDescr);
        Debug.println("* sEditUnitsChanged    : "+sEditUnitsChanged);
        Debug.println("* sEditSrcDestType     : "+sEditSrcDestType);
        Debug.println("* sEditSrcDestUid      : "+sEditSrcDestUid);
        Debug.println("* sEditSrcDestName     : "+sEditSrcDestName);
        Debug.println("* sEditOperationDate   : "+sEditOperationDate);
        Debug.println("* sEditProductStockUid : "+sEditProductStockUid+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sSelectedOperationDescr = "", sSelectedSrcDestType = "", sSelectedSrcDestUid = "",
           sSelectedSrcDestName = "", sSelectedOperationDate = "", sSelectedProductName = "",
           sSelectedUnitsChanged = "", sSelectedProductStockUid = "", sSelectedProductStockLevel = "";

    int foundReceiptCount = 0;
    StringBuffer receiptsHtml = null;
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // display options
    boolean displayEditFields = true;

    String sDisplayDoctorReceipts = checkString(request.getParameter("DisplayDoctorReceipts"));
    if(sDisplayDoctorReceipts.length()==0) sDisplayDoctorReceipts = "true"; // default
    boolean displayDoctorReceipts = sDisplayDoctorReceipts.equalsIgnoreCase("true");
    if(Debug.enabled) Debug.println("@@@ displayDoctorReceipts : "+displayDoctorReceipts);

    String sIsDoctorReceipt = checkString(request.getParameter("IsDoctorReceipt"));
    if(sIsDoctorReceipt.length()==0) sIsDoctorReceipt = "false"; // default
    boolean isDoctorReceipt = sIsDoctorReceipt.equalsIgnoreCase("true");
    if(Debug.enabled) Debug.println("@@@ isDoctorReceipt : "+isDoctorReceipt);

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = sDefaultSortCol;

    // sortdir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE (receive) --------------------------------------------------------------------------
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

        if(sEditOperationDate.length() > 0) operation.setDate(stdDateFormat.parse(sEditOperationDate));
        operation.setProductStockUid(sEditProductStockUid);
        if(sEditUnitsChanged.length() > 0) operation.setUnitsChanged(Integer.parseInt(sEditUnitsChanged));
        operation.setUpdateUser(activeUser.userid);

        //***** save operation *****
        String sResult=operation.store();
        if(sResult==null){
            if(sEditOperationUid.equals("-1")){
                msg = getTran("web.manage","medicationreceived",sWebLanguage);
            }
            else{
                msg = getTran("web","dataissaved",sWebLanguage);
            }

            sEditOperationUid = operation.getUid();
            sAction = "showDetailsNew";

        // reload opener to see the change in level
        %>
        <script>
          window.opener.location.reload();
          window.close();
        </script>
        <%
        }
        else {
        %>
        <script>
            alert('<%=getTranNoLink("web",sResult,sWebLanguage)%>');
        </script>
        <%
        sAction = "showDetailsNew";
        }

    }
    //--- SORT ------------------------------------------------------------------------------------
    else if(sAction.equals("sort")){
        displayDoctorReceipts = true;
    }

    //--- RECEIVE MEDICATION ----------------------------------------------------------------------
    if(sAction.equals("receiveMedication")){
        // set medication receipt parameters
        sEditOperationDescr = "medicationreceipt.type1";
        sEditSrcDestType = sDefaultSrcDestType;
        sEditSrcDestUid = activeUser.userid;
        sEditSrcDestName = activeUser.person.firstname+" "+activeUser.person.lastname;
        sEditOperationDate = stdDateFormat.format(new java.util.Date()); // now
        sEditUnitsChanged = "1";

        sAction = "showDetailsNew";
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        if(sAction.equals("showDetailsNew")) displayDoctorReceipts = true;
        else                                 displayDoctorReceipts = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ProductStockOperation operation = ProductStockOperation.get(sEditOperationUid);

            // get data from DB
            if(operation!=null){
                sSelectedOperationDescr = checkString(operation.getDescription());
                sSelectedUnitsChanged   = operation.getUnitsChanged()+"";

                // format date
                java.util.Date tmpDate = operation.getDate();
                if(tmpDate!=null) sSelectedOperationDate = stdDateFormat.format(tmpDate);

                // ProductStock
                ProductStock selectedProductStock = operation.getProductStock();
                if(selectedProductStock!=null){
                    sSelectedProductStockUid   = selectedProductStock.getUid(); 
                    sSelectedProductStockLevel = (selectedProductStock.getLevel()<0?"":selectedProductStock.getLevel()+"");

                    // product 
                    Product product = selectedProductStock.getProduct();
                    if(product!=null) sSelectedProductName = product.getName();
                    else{
                        sSelectedProductName = selectedProductStock.getProductUid();
                    }
                }

                // reference (patient|medic|service)
                ObjectReference reference = operation.getSourceDestination();
                if(reference!=null){
                    sSelectedSrcDestType = reference.getObjectType();
                    sSelectedSrcDestUid  = reference.getObjectUid();
                }

                // names
                if(sSelectedSrcDestType.indexOf("patient") > -1){
                    sSelectedSrcDestName = ScreenHelper.getFullPersonName(sSelectedSrcDestUid);
                }
                else if(sSelectedSrcDestType.indexOf("medic") > -1){
                    sSelectedSrcDestName = ScreenHelper.getFullUserName(sSelectedSrcDestUid);
                }
                else if(sSelectedSrcDestType.indexOf("service") > -1){
                    sSelectedSrcDestName = getTran("Service",sSelectedSrcDestUid,sWebLanguage);
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
        else if(sAction.equals("showDetailsNew")){
            sSelectedOperationDescr = sEditOperationDescr;
            sSelectedUnitsChanged   = sEditUnitsChanged;
            sSelectedSrcDestType    = sEditSrcDestType;
            sSelectedSrcDestUid     = sEditSrcDestUid;
            sSelectedSrcDestName    = sEditSrcDestName;
            sSelectedOperationDate  = sEditOperationDate;
        }
    }
%>

<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/main.do"/>?Page=pharmacy/medication/receiveMedication.jsp&ts=<%=getTs()%>' onKeyDown="if(enterEvent(event,13)){doReceive();}" <%=(displayEditFields?"onClick='clearMessage();'":"onClick='clearMessage();setSaveButton(event);' onKeyUp='setSaveButton(event);'")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","medicationreceipt",sWebLanguage,"")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- description --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","description",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <select class="text" name="EditOperationDescr" onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.patientmedicationreceipt",sSelectedOperationDescr,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- SourceDestination type --%>
                    <tr height="23">
                        <td class="admin"><%=getTran("web","receivedfrom",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" name="EditSrcDestType" onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.patientsourcedestinationtype","patient",sWebLanguage)%>
                            </select>
                            <%-- SOURCE DESTINATION SELECTOR --%>
                            <span id="SrcDestSelector" style="visibility:hidden;">
                                <input class="text" type="text" name="EditSrcDestName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSrcDestName%>">
                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
                                <input type="hidden" name="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
                            </span>
                        </td>
                    </tr>
                    <script>
                      var prevSrcDestType;
                      displaySrcDestSelector();

                      <%-- DISPLAY SOURCE DESTINATION SELECTOR --%>
                      function displaySrcDestSelector(){
                        var srcDestType, emptyEditSrcDest, srcDestUid, srcDestName;

                        srcDestType = transactionForm.EditSrcDestType.value;
                        if(srcDestType.length > 0){
                          document.getElementById('SrcDestSelector').style.visibility = 'visible';

                          <%-- medic --%>
                          if(srcDestType.indexOf('medic') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchDoctor('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            if(prevSrcDestType!=srcDestType){
                              transactionForm.EditSrcDestUid.value = "<%=activeUser.userid%>";
                              transactionForm.EditSrcDestName.value = "<%=activeUser.person.firstname+" "+activeUser.person.lastname%>";
                            }
                            else{
                              if(transactionForm.EditSrcDestUid.value.length==0){
                                transactionForm.EditSrcDestUid.value = "<%=activeUser.userid%>";
                                transactionForm.EditSrcDestName.value = "<%=activeUser.person.firstname+" "+activeUser.person.lastname%>";
                              }
                            }
                          }
                          <%-- patient --%>
                          else if(srcDestType.indexOf('patient') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            if(prevSrcDestType!=srcDestType){
                              transactionForm.EditSrcDestUid.value = "<%=activePatient.personid%>";
                              transactionForm.EditSrcDestName.value = "<%=activePatient.firstname+" "+activePatient.lastname%>";
                            }
                            else{
                              if(transactionForm.EditSrcDestUid.value.length==0){
                                transactionForm.EditSrcDestUid.value = "<%=activePatient.personid%>";
                                transactionForm.EditSrcDestName.value = "<%=activePatient.firstname+" "+activePatient.lastname%>";
                              }
                            }
                          }
                          <%-- service --%>
                          else if(srcDestType.indexOf('service') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
                            if(prevSrcDestType!=srcDestType){
                              if("<%=centralPharmacyCode%>".length > 0){
                                transactionForm.EditSrcDestUid.value = "<%=centralPharmacyCode%>";
                                transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",centralPharmacyCode,sWebLanguage)%>";
                              }
                              else{
                                transactionForm.EditSrcDestUid.value = "";
                                transactionForm.EditSrcDestName.value = "";
                              }
                            }
                            else{
                              if(transactionForm.EditSrcDestUid.value.length==0){
                                if("<%=centralPharmacyCode%>".length > 0){
                                  transactionForm.EditSrcDestUid.value = "<%=centralPharmacyCode%>";
                                  transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",centralPharmacyCode,sWebLanguage)%>";
                                }
                                else{
                                  transactionForm.EditSrcDestUid.value = "";
                                  transactionForm.EditSrcDestName.value = "";
                                }
                              }
                            }
                          }
                        }
                        else{
                          transactionForm.EditSrcDestType.value = "<%=sDefaultSrcDestType%>";
                          document.getElementById('SrcDestSelector').style.visibility = 'hidden';
                        }

                        prevSrcDestType = srcDestType;
                      }
                    </script>
                    <%-- operation date --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","date",sWebLanguage)%> *</td>
                        <td class="admin2"><%=writeDateField("EditOperationDate","transactionForm",sSelectedOperationDate,sWebLanguage)%></td>
                    </tr>
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","product",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                            <input class="text" type="text" name="EditProductStockName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">
                            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchProductStock('EditProductStockUid','EditProductStockName','ProductStockLevel');">
                            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductStockUid.value='';transactionForm.EditProductStockName.value='';document.getElementById('displayDeliveriesButton').style.visibility='hidden';">&nbsp;
                            <%-- button to display deliveries in popup --%>
                            <span id="displayDeliveriesButton" style="visibility:hidden;">
                                <%
                                    // calculate one year ago
                                    Calendar deliveriesSince = new GregorianCalendar();
                                    deliveriesSince.add(Calendar.YEAR, -1);
                                %>
                                <input type="button" class="button" value="<%=getTranNoLink("web.manage","medicationDeliveries",sWebLanguage)%>" title="<%=getTranNoLink("web.manage","displayDeliveriesForProduct",sWebLanguage)%>" onClick="showDeliveriesPopup('<%=activePatient.personid%>',EditProductStockUid.value,'<%=stdDateFormat.format(deliveriesSince.getTime())%>');">
                            </span>
                        </td>
                    </tr>
                    <%-- current productStock level --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","currentstocklevel",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" size="5" maxLength="5" name="ProductStockLevel" value="<%=sSelectedProductStockLevel%>" READONLY>
                        </td>
                    </tr>
                    <%-- units changed --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","packages",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" size="5" maxLength="5" value="<%=sSelectedUnitsChanged%>" onKeyUp="if(this.value=='0'){this.value='';}isNumber(this);" <%=(sAction.equals("showDetails")?"READONLY":"")%>>
                        </td>
                    </tr>
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetailsNew")){
                                    %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","receive",sWebLanguage)%>' onclick="doReceive();"><%
                                }
                                else{
                                    %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();"><%
                                }
                            %>
                            <%-- BACK TO OVERVIEW --%>
                            <%
                                if(sAction.equals("showDetails")){
                                    %>
                                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();">
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

        //--- DISPLAY RECEIPTS (by active Doctor) -------------------------------------------------
        if(displayDoctorReceipts){
            Vector receipts = ProductStockOperation.getReceipts(activePatient.personid,null,null,sSortCol,sSortDir);
            receiptsHtml = objectsToHtml(receipts,sWebLanguage);
            foundReceiptCount = receipts.size();

            %>
                <%-- sub title --%>
                <table width="100%" cellspacing="0">
                    <tr>
                        <td class="titleadmin">&nbsp;<%=getTran("Web.manage","medicationreceiptstoactivepatient",sWebLanguage)%>&nbsp;<%=activePatient.lastname+" "+activePatient.firstname%></td>
                    </tr>
                </table>
            <%

            if(foundReceiptCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="30%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_OPERATION_DESCRIPTION');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DESCRIPTION")?"<"+sSortDir+">":"")%><%=getTran("Web","description",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DESCRIPTION")?"</"+sSortDir+">":"")%></a></td>
                            <td width="8%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_OPERATION_DATE');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DATE")?"<"+sSortDir+">":"")%><%=getTran("Web","date",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_DATE")?"</"+sSortDir+">":"")%></a></td>
                            <td width="25%"><%=getTran("Web","product",sWebLanguage)%></td>
                            <td width="10%"><a href="#" title="<%=sortTran%>" class="underlined" onClick="doSort('OC_OPERATION_UNITSCHANGED');"><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_UNITSCHANGED")?"<"+sSortDir+">":"")%><%=getTran("Web","unitschanged",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_OPERATION_UNITSCHANGED")?"</"+sSortDir+">":"")%></a></td>
                            <td width="*"><%=getTran("Web","username",sWebLanguage)%></td>
                        </tr>
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                            <%=receiptsHtml%>
                        </tbody>
                    </table>
                   <!--
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundReceiptCount%> <%=getTran("web","receiptsfound",sWebLanguage)%>
                    </span>
                    -->
                    <%
                        if(foundReceiptCount > 20){
                            // link to top of page
                            %>
                            <span style="width:51%;text-align:right;">
                                <a href="#topp" class="topbutton">&nbsp;</a>
                            </span>
                            <br>
                            <%
                        }
                    %>
                    <br>
                <%
            }
            else{
                // no records found
                %>
                <%=getTran("web.manage","noreceiptsfound",sWebLanguage)%>
                <br>
                <%
            }
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
    <input type="hidden" name="DisplayDoctorReceipts" value="<%=displayDoctorReceipts%>">
    <input type="hidden" name="IsDoctorReceipt" value="<%=isDoctorReceipt%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }
  %>

  <%-- DO SORT --%>
  function doSort(sortCol){
    transactionForm.Action.value = "sort";
    transactionForm.SortCol.value = sortCol;

    if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
    else                                       transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- DO RECEIVE --%>
  function doReceive(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditOperationDescr.value.length==0){
        transactionForm.EditOperationDescr.focus();
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
      else if(transactionForm.EditUnitsChanged.value.length==0){
        transactionForm.EditUnitsChanged.focus();
      }
    }
  }

  <%-- CHECK STOCK FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditOperationDescr.value.length>0 ||
       !transactionForm.EditSrcDestType.value.length>0 ||
       !transactionForm.EditSrcDestName.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !transactionForm.EditProductStockUid.value.length>0 ||
       !transactionForm.EditUnitsChanged.value.length>0){
      maySubmit = false;

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }

    return maySubmit;
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(operationUid){
    transactionForm.saveButton.disabled = true;

    transactionForm.EditOperationUid.value = operationUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS RECEIPT --%>
  function doShowDetailsReceipt(operationUid){
    transactionForm.IsDoctorReceipt.value = "true";
    doShowDetails(operationUid);
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
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+"&ReturnName="+doctorNameField+"&displayImmatNew=no&isUser=yes");
  }

  <%-- popup : search product stock --%>
  function searchProductStock(productStockUidField,productStockNameField,productStockLevelField){
    openPopup("/_common/search/searchProductStock.jsp&ts=<%=getTs()%>&ReturnProductStockUidField="+productStockUidField+"&ReturnProductStockNameField="+productStockNameField+"&ReturnProductStockLevelField="+productStockLevelField+"&DisplayProductStocksOfActiveUserService=true");
  }

  <%-- popup : DISPLAY DELIVERIES POPUP --%>
  function showDeliveriesPopup(patientId,productStockUid,sinceDate){
    openPopup("pharmacy/medication/popups/deliveriesPopup.jsp&ts=<%=getTs()%>&PatientId="+patientId+"&ProductStockUid="+productStockUid+"&Since="+sinceDate);
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO SELECT PRESCRIBED PRODUCT --%>
  function doSelectPrescribedProduct(alterChecked,prescribedProductId){
    var rb = document.getElementById("rb_"+prescribedProductId);

    if(alterChecked==0){
      transactionForm.EditProductStockUid.value = document.getElementById("pstockuid_"+prescribedProductId).value;
      transactionForm.EditProductStockName.value = document.getElementById("pstockname_"+prescribedProductId).value;
    }
    else if(!rb.checked){
      rb.checked = true;
      transactionForm.EditProductStockUid.value = document.getElementById("pstockuid_"+prescribedProductId).value;
      transactionForm.EditProductStockName.value = document.getElementById("pstockname_"+prescribedProductId).value;
    }
    else{
      rb.checked = false;
      transactionForm.EditProductStockUid.value = "";
      transactionForm.EditProductStockName.value = "";
    }
  }

  <%-- DESELECT ALL PRESCRIPTIONS --%>
  function deselectAllPrescriptions(){
    for(i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="radio"){
        if(transactionForm.elements[i].name=="activePrescrRadio"){
          transactionForm.elements[i].checked = false;
        }
      }
    }
  }

  <%-- DO BACK TO OVERVIEW --%>
  function doBackToOverview(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTranNoLink("Web","areyousuretodiscard",sWebLanguage)%>')){
      <%
          if(isDoctorReceipt){
              %>
                transactionForm.DisplayDoctorReceipts.value = "true";
                transactionForm.Action.value = "receiveMedication";
              <%
          }
          else{
              %>
                transactionForm.DisplayDoctorReceipts.value = "false";
                transactionForm.Action.value = "";
              <%
          }
      %>
      transactionForm.submit();
    }
  }
</script>