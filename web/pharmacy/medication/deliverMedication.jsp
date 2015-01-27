<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.medical.Prescription,
                be.openclinic.finance.DebetTransaction,
                be.openclinic.finance.Balance,
                be.openclinic.finance.Prestation,
                java.util.Hashtable,
                java.util.Vector,
                java.util.Enumeration,
                be.openclinic.adt.Encounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationdelivery","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sUserId, sUserName = "", sDescriptionType,
               sDescription = "", productStockUid, sProductName;
        Hashtable usersHash = new Hashtable(),
                  descrTypeTranHash = new Hashtable(),
                  productStockHash = new Hashtable();
        ProductStock productStock;
        AdminPerson user;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage);

        // iterate found operations
        ProductStockOperation operation;
        for(int i=0; i<objects.size(); i++){
            operation = (ProductStockOperation)objects.get(i);

            // productStock
            productStockUid = operation.getProductStockUid();
            productStock = (ProductStock)productStockHash.get(productStockUid);
            if(productStock==null){
                // get productStock from DB
                productStock = ProductStock.get(productStockUid);
                if(productStock!=null){
                    productStockHash.put(productStockUid,productStock);
                }
            }
            
            // user who did the medication-delivery
            sUserId = checkString(operation.getUpdateUser());
            user = (AdminPerson)usersHash.get(sUserId);
            if(user==null){
                user = AdminPerson.getAdminPerson(sUserId);
                usersHash.put(sUserId,user);
                if(user!=null){
                    sUserName = user.firstname+" "+user.lastname;
                }
            }

            // description
            sDescriptionType = checkString(operation.getDescription());
            if(sDescriptionType.length() > 0){
                sDescription = checkString((String)descrTypeTranHash.get(sDescriptionType));
                if(sDescription.length()==0){
                    sDescription = getTran("productstockoperation.patientmedicationdelivery",sDescriptionType,sWebLanguage);
                    descrTypeTranHash.put(sDescriptionType,sDescription);
                }
            }

            // product name
            productStock = operation.getProductStock();
            if(productStock!=null && productStock.getProduct()!=null){
                sProductName = operation.getProductStock().getProduct().getName();
            } 
            else{
                sProductName = "<font color='red'>"+getTran("web.manage","unexistingproduct",sWebLanguage)+"</font>";
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            Prescription prescription = operation.getPrescription();

            //*** display operation in one row ***
            html.append("<tr class='list"+sClass+"' onclick=\"doShowDetailsDelivery('"+operation.getUid()+"');\" title='"+detailsTran+"'>")
                 .append("<td>"+sDescription+(prescription!=null?" ("+prescription.getPrescriber().firstname+" "+prescription.getPrescriber().lastname+")":"")+"</td>")
                 .append("<td>"+(operation.getDate()==null?"":ScreenHelper.formatDate(operation.getDate()))+"</td>")
                 .append("<td>"+operation.getProductStock().getServiceStock().getName()+"</td>")
                 .append("<td><b>"+sProductName+"</b></td>")
                 .append("<td>"+Math.abs(operation.getUnitsChanged())+"</td>")
                 .append("<td>"+sUserName+"</td>")
                .append("</tr>");
        }

        return html;
    }

    //--- GET REMAINING PACKAGES NEEDED -----------------------------------------------------------
    private int getRemainingPackagesNeeded(Prescription prescription){
        // unit-stuff
        String timeUnit = prescription.getTimeUnit();
        int timeUnitCount = prescription.getTimeUnitCount();
        double unitsPerTimeUnit = prescription.getUnitsPerTimeUnit();
        int unitsPerPackage = prescription.getProduct().getPackageUnits();

        java.util.Date now = new java.util.Date(); // now
        java.util.Date prescrEnd = prescription.getEnd();

        long remainingDurationInMillis = prescrEnd.getTime() - now.getTime();
        long remainingDurationInTimeUnits = 0;
        if(timeUnit.equalsIgnoreCase("type1hour")){
            remainingDurationInTimeUnits = remainingDurationInMillis / (3600*1000);
        }
        else if(timeUnit.equalsIgnoreCase("type2day")){
            remainingDurationInTimeUnits = remainingDurationInMillis / (24*3600*1000);
        }
        else if(timeUnit.equalsIgnoreCase("type3week")){
            remainingDurationInTimeUnits = remainingDurationInMillis / (7*24*3600*1000);
        }
        else if(timeUnit.equalsIgnoreCase("type4month")){
            remainingDurationInTimeUnits = remainingDurationInMillis / ((long)31*24*3600*1000);
        }
    
        double unitsNeeded = Math.ceil((remainingDurationInTimeUnits * unitsPerTimeUnit) / timeUnitCount);
        int packagesNeeded = (int)Math.ceil(unitsNeeded / unitsPerPackage);

        return packagesNeeded;
    }
%>

<%
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           sDefaultSrcDestType = "type2patient",
           sDefaultUnitsChanged = "1";

    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "deliverMedication"; // default

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

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** pharmacy/medication/deliverMedication.jsp ************");
        Debug.println("sAction              : "+sAction);
        Debug.println("sEditOperationUid    : "+sEditOperationUid);
        Debug.println("sEditOperationDescr  : "+sEditOperationDescr);
        Debug.println("sEditUnitsChanged    : "+sEditUnitsChanged);
        Debug.println("sEditSrcDestType     : "+sEditSrcDestType);
        Debug.println("sEditSrcDestUid      : "+sEditSrcDestUid);
        Debug.println("sEditSrcDestName     : "+sEditSrcDestName);
        Debug.println("sEditOperationDate   : "+sEditOperationDate);
        Debug.println("sEditProductStockUid : "+sEditProductStockUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sSelectedOperationDescr = "", sSelectedSrcDestType = "", sSelectedSrcDestUid = "",
           sSelectedSrcDestName = "", sSelectedOperationDate = "", sSelectedProductName = "",
           sSelectedUnitsChanged = "", sSelectedProductStockUid = "", sSelectedProductStockLevel = "";

    int foundDeliveryCount;
    StringBuffer deliveriesHtml;

    // display options
    boolean displayEditFields = true;

    String sDisplayPatientDeliveries = checkString(request.getParameter("DisplayPatientDeliveries"));
    if(sDisplayPatientDeliveries.length()==0) sDisplayPatientDeliveries = "true"; // default
    boolean displayPatientDeliveries = sDisplayPatientDeliveries.equalsIgnoreCase("true");
    Debug.println("@@@ displayPatientDeliveries : "+displayPatientDeliveries);

    String sIsPatientDelivery = checkString(request.getParameter("IsPatientDelivery"));
    if(sIsPatientDelivery.length()==0) sIsPatientDelivery = "false"; // default
    boolean isPatientDelivery = sIsPatientDelivery.equalsIgnoreCase("true");
    Debug.println("@@@ isPatientDelivery : "+isPatientDelivery);


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE (deliver) --------------------------------------------------------------------------
    if(sAction.equals("save") && sEditOperationUid.length() > 0){
        // create product
        ProductStockOperation operation = new ProductStockOperation();
        operation.setUid(sEditOperationUid);
        operation.setDescription(sEditOperationDescr);

        // sourceDestination
        ObjectReference sourceDestination = new ObjectReference();
        sourceDestination.setObjectType(sEditSrcDestType);
        sourceDestination.setObjectUid(sEditSrcDestUid);
        operation.setSourceDestination(sourceDestination);

        if(sEditOperationDate.length() > 0) operation.setDate(ScreenHelper.parseDate(sEditOperationDate));
        operation.setProductStockUid(sEditProductStockUid);
        if(sEditUnitsChanged.length() > 0) operation.setUnitsChanged(Integer.parseInt(sEditUnitsChanged));
        operation.setUpdateUser(activeUser.userid);

        //***** save operation *****
        String sResult = operation.store();
        if(sResult==null){
            // create a debet for the delivered expences
            if(sEditOperationDescr.startsWith("medicationdelivery")){
                // calculate debet amount
                ProductStock productStock = ProductStock.get(sEditProductStockUid);
                Product deliveredProduct = productStock.getProduct();
                double packagePrice = deliveredProduct.getUnitPrice() * (double)deliveredProduct.getPackageUnits();
                double debetAmount = Double.parseDouble(sEditUnitsChanged) * packagePrice;

                Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
                Balance activeBalance = Balance.getActiveBalance(activePatient.personid);

                DebetTransaction debet = new DebetTransaction();

                debet.setAmount(debetAmount);
                debet.setDescription("defaultDebetDescription");
                debet.setDate(ScreenHelper.getSQLDate(sEditOperationDate));
                debet.setBalance(activeBalance);
                debet.setEncounter(encounter);
                debet.setPrestation(Prestation.get(MedwanQuery.getInstance().getConfigString("defaultPrestationUid")));

                ObjectReference supplierReference = new ObjectReference();
                supplierReference.setObjectType("Service");
                supplierReference.setObjectUid(productStock.getServiceStock().getServiceUid());
                debet.setSupplier(supplierReference);

                ObjectReference debetReference = new ObjectReference();
                debetReference.setObjectType("MedicationDelivery");
                debetReference.setObjectUid(operation.getUid());
                debet.setReferenceObject(debetReference);

                debet.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
                debet.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
                debet.setUpdateUser(activeUser.userid);

                debet.store();
            }

            // message
            if(sEditOperationUid.equals("-1")){
                msg = getTran("web.manage","medicationdelivered",sWebLanguage);
            }
            else{
                msg = getTran("web","dataissaved",sWebLanguage);
            }

            sEditOperationUid = operation.getUid();
            sAction = "showDetailsNew";
            sEditUnitsChanged = sDefaultUnitsChanged;

	        // reload opener to see the change in level
	        %>
	        <script>
	          window.opener.location.reload();
	          window.close();
	        </script>
        	<%
        }
        else{
	        %><script>alertDialogDirectText('<%=getTranNoLink("web",sResult,sWebLanguage)%>');</script><%
	        sAction = "showDetailsNew";
        }
    }

    //--- DELIVER MEDICATION ----------------------------------------------------------------------
    if(sAction.equals("deliverMedication")){
        // set medication delivery parameters
        sEditOperationDescr = MedwanQuery.getInstance().getConfigString("defaultMedicationDeliveryType","medicationdelivery.typeb1");
        sEditSrcDestType = sDefaultSrcDestType;
        sEditSrcDestUid = activePatient.personid;
        sEditSrcDestName = activePatient.firstname+" "+activePatient.lastname;
        sEditOperationDate = ScreenHelper.formatDate(new java.util.Date()); // now
        sEditUnitsChanged = sDefaultUnitsChanged;

        sAction = "showDetailsNew";
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        if(sAction.equals("showDetailsNew")) displayPatientDeliveries = true;
        else                                 displayPatientDeliveries = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ProductStockOperation operation = ProductStockOperation.get(sEditOperationUid);

            if(operation!=null){
                sSelectedOperationDescr = operation.getDescription();
                sSelectedUnitsChanged = operation.getUnitsChanged()+"";

                // format date
                java.util.Date tmpDate = operation.getDate();
                if(tmpDate!=null) sSelectedOperationDate = ScreenHelper.formatDate(tmpDate);

                // ProductStock
                ProductStock sSelectedProductStock = operation.getProductStock();
                if(sSelectedProductStock!=null){
                    sSelectedProductStockUid = sSelectedProductStock.getUid();
                    sSelectedProductName = sSelectedProductStock.getProduct().getName();
                    sSelectedProductStockLevel = (sSelectedProductStock.getLevel()<0?"":sSelectedProductStock.getLevel()+"");
                }

                // sourceDestination (patient|medic|service)
                sSelectedSrcDestType = operation.getSourceDestination().getObjectType();
                sSelectedSrcDestUid = operation.getSourceDestination().getObjectUid();

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
            sSelectedUnitsChanged = sEditUnitsChanged;
            sSelectedSrcDestType = sEditSrcDestType;
            sSelectedSrcDestUid = sEditSrcDestUid;
            sSelectedSrcDestName = sEditSrcDestName;
            sSelectedOperationDate = sEditOperationDate;
            sSelectedProductName = sEditProductName;
        } 
        else if(sAction.equals("showDetailsNew")){
            sSelectedOperationDescr = sEditOperationDescr;
            sSelectedUnitsChanged = sEditUnitsChanged;
            sSelectedSrcDestType = sEditSrcDestType;
            sSelectedSrcDestUid = sEditSrcDestUid;
            sSelectedSrcDestName = sEditSrcDestName;
            sSelectedOperationDate = sEditOperationDate;
        }
    }
%>

<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/main.do"/>?Page=pharmacy/medication/deliverMedication.jsp&ts=<%=getTs()%>' onKeyDown="if(enterEvent(event,13)){doDeliver();}" <%=(displayEditFields?"onClick='clearMessage();'":"onClick='clearMessage();setSaveButton(event);' onKeyUp='setSaveButton(event);'")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","medicationdelivery",sWebLanguage,"")%>
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
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.patientmedicationdelivery",sSelectedOperationDescr,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    
                    <%-- SourceDestination type --%>
                    <tr height="23">
                        <td class="admin"><%=getTran("web","deliveredto",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" name="EditSrcDestType" onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.patientsourcedestinationtype","patient",sWebLanguage)%>
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
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchDoctor('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
                                                                                          "<img src='<c:url value="/_img/icons/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
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
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
                                                                                          "<img src='<c:url value="/_img/icons/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
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
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icons/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"+
                                                                                          "<img src='<c:url value="/_img/icons/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">&nbsp;";
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
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProductStock('EditProductStockUid','EditProductStockName','ProductStockLevel');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductStockUid.value='';transactionForm.EditProductStockName.value='';">

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
                            <span id="TotalDeliveryPrice"><%-- filled by JS --%></span>
                        </td>
                    </tr>
                    
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetailsNew")){
                                    %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","deliver",sWebLanguage)%>' onclick="doDeliver();"><%
                                }
                                if(sAction.equals("showDetails")){
                                    %><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();"><%
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

        //--- DISPLAY DELIVERIES (to active patient) ----------------------------------------------
        if(displayPatientDeliveries){
            Vector deliveries = ProductStockOperation.getDeliveries(activePatient.personid,null,null,"OC_OPERATION_DATE","DESC");
            deliveriesHtml = objectsToHtml(deliveries,sWebLanguage);
            foundDeliveryCount = deliveries.size();

            %>
                <%-- sub title --%>
                <table width="100%" cellspacing="0">
                    <tr>
                        <td class="titleadmin">&nbsp;<%=getTran("Web.manage","medicationdeliveriesforactivepatient",sWebLanguage)%>&nbsp;<%=activePatient.lastname+" "+activePatient.firstname%></td>
                    </tr>
                </table>
            <%

            if(foundDeliveryCount > 0){
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- header --%>
                        <tr class="admin">
                            <td><%=getTran("Web","description",sWebLanguage)%></td>
                            <td><%=getTran("Web","date",sWebLanguage)%></td>
                            <td><%=getTran("Web","servicestock",sWebLanguage)%></td>
                            <td><%=getTran("Web","product",sWebLanguage)%></td>
                            <td><%=getTran("Web","unitschanged",sWebLanguage)%></td>
                            <td><%=getTran("Web","username",sWebLanguage)%></td>
                        </tr>
                        <tbody class="hand"><%=deliveriesHtml%></tbody>
                    </table>
                    
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundDeliveryCount%> <%=getTran("web","deliveriesfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundDeliveryCount > 20){
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
                %><%=getTran("web.manage","nodeliveriesfound",sWebLanguage)%><br><%
            }
        }
    %>

    <input type="hidden" name="Action">
    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
    <input type="hidden" name="DisplayPatientDeliveries" value="<%=displayPatientDeliveries%>">
    <input type="hidden" name="IsPatientDelivery" value="<%=isPatientDelivery%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }
  %>

  <%-- DO DELIVER --%>
  function doDeliver(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields()){
      if(transactionForm.ProductStockLevel.value > 0){
        transactionForm.saveButton.disabled = true;
        transactionForm.Action.value = "save";
        transactionForm.submit();
      }
      else{
        alertDialog("web.manage","insufficientStock");
      }
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
       !transactionForm.EditUnitsChanged.value.length>0 ||
       !transactionForm.EditSrcDestType.value.length>0 ||
       !transactionForm.EditSrcDestName.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !transactionForm.EditProductStockUid.value.length>0){
      maySubmit = false;
                alertDialog("web.manage","dataMissing");
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

  <%-- DO SHOW DETAILS PATIENT DELIVERY --%>
  function doShowDetailsDelivery(operationUid){
    transactionForm.IsPatientDelivery.value = "true";
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
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>"+
    		  "&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search patient --%>
  function searchPatient(patientUidField,patientNameField){
    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>"+
    		  "&ReturnPersonID="+patientUidField+
    		  "&ReturnName="+patientNameField+
    		  "&displayImmatNew=no&isUser=no");
  }

  <%-- popup : search doctor --%>
  function searchDoctor(doctorUidField,doctorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+
    		  "&ReturnName="+doctorNameField+"&displayImmatNew=no");
  }

  <%-- popup : search product stock --%>
  function searchProductStock(productStockUidField,productStockNameField,productStockLevelField){
    var url = "/_common/search/searchProductStock.jsp&ts=<%=getTs()%>"+
              "&ReturnProductStockUidField="+productStockUidField+
              "&ReturnProductStockNameField="+productStockNameField+
              "&DisplayProductStocksOfActiveUserService=true"+
              "&ReturnProductStockLevelField="+productStockLevelField+
              "&SearchProductLevel="+document.getElementsByName('EditUnitsChanged')[0].value;
    openPopup(url,900,400);
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO SELECT PRODUCTSTOCK --%>
  function doSelectProductStock(alterChecked,productStockUid){
    var rb = document.getElementById("rb_"+productStockUid);

    if(alterChecked==0){
      transactionForm.EditProductStockUid.value = productStockUid;
      transactionForm.EditProductStockName.value = document.getElementById("pstockname_"+productStockUid).value;
      transactionForm.EditUnitsChanged.value = document.getElementById("remainingPackagesNeeded_"+productStockUid).value;
      transactionForm.ProductStockLevel.value = document.getElementById("pstockLevel_"+productStockUid).value;
    }
    else if(!rb.checked){
      rb.checked = true;
      transactionForm.EditProductStockUid.value = productStockUid;
      transactionForm.EditProductStockName.value = document.getElementById("pstockname_"+productStockUid).value;
      transactionForm.EditUnitsChanged.value = document.getElementById("remainingPackagesNeeded_"+productStockUid).value;
      transactionForm.ProductStockLevel.value = document.getElementById("pstockLevel_"+productStockUid).value;
    }
    else{
      rb.checked = false;
      transactionForm.EditProductStockUid.value = "";
      transactionForm.EditProductStockName.value = "";
      transactionForm.EditUnitsChanged.value = "<%=sDefaultUnitsChanged%>";
      transactionForm.ProductStockLevel.value = "";
    }

    <%-- calculate totalDeliveryPrice --%>
    var packagePrice = parseFloat(replaceAll(document.getElementById("packagePrice_"+productStockUid).value,",","."));
    var packages     = parseFloat(transactionForm.EditUnitsChanged.value.replace(",","."));
    document.getElementById('TotalDeliveryPrice').innerHTML = "<%=getTranNoLink("web","totalprice",sWebLanguage)%> : "+(packagePrice*packages).toFixed(2)+" <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>";
  }

  <%-- DESELECT ALL PRESCRIPTIONS --%>
  function deselectAllPrescriptions(){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="radio"){
        if(transactionForm.elements[i].name=="activePrescrRadio"){
          transactionForm.elements[i].checked = false;
        }
      }
    }
  }

  <%-- DO BACK TO OVERVIEW --%>
  function doBackToOverview(){
    if(checkSaveButton()){
      <%
          if(isPatientDelivery){
              %>
                transactionForm.DisplayPatientDeliveries.value = "true";
                transactionForm.Action.value = "deliverMedication";
              <%
          }
          else{
              %>
                transactionForm.DisplayPatientDeliveries.value = "false";
                transactionForm.Action.value = "";
              <%
          }
      %>
      transactionForm.submit();
    }
  }
</script>