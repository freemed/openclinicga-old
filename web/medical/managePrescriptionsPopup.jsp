<%@page import="java.text.SimpleDateFormat,
                be.openclinic.pharmacy.Product,
                be.openclinic.medical.Prescription,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.common.KeyValue,
                be.openclinic.pharmacy.PrescriptionSchema,
                be.openclinic.pharmacy.ProductSchema,
                java.util.Vector" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<script>
  function reloadOpener(){
    if(isModified && window.opener.document.getElementById('patientmedicationsummary')!=undefined){
      window.opener.location.reload();
    }
  }
</script>

<body onbeforeunload="reloadOpener()">
<script>var isModified = false;</script>
<%=checkPermissionPopup("prescriptions.drugs", "select", activeUser)%>
<%=sJSSORTTABLE%>
<%=sJSDROPDOWNMENU%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage, User activeUser){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sDateBeginFormatted, sDateEndFormatted, sProductName = "", sProductUid,
                sPreviousProductUid = "", sTimeUnit, sTimeUnitCount, sUnitsPerTimeUnit, sPrescrRule = "",
                sProductUnit, timeUnitTran, sSupplyingServiceName, sSupplyingServiceUid,
                sServiceStockUid, sServiceStockName;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        Product product = null;
        java.util.Date tmpDate;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
               deleteTran  = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found prescriptions
        Prescription prescr;
        for (int i = 0; i < objects.size(); i++){
            prescr = (Prescription) objects.get(i);

            // format date begin
            tmpDate = prescr.getBegin();
            if(tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format date end
            tmpDate = prescr.getEnd();
            if(tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescr.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = Product.get(sProductUid);

                if(product != null){
                    sProductName = product.getName();
                } 
                else {
                    sProductName = "<font color='red'>"+getTran("web", "nonexistingproduct", sWebLanguage)+"</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescr.getTimeUnit();
            sTimeUnitCount = prescr.getTimeUnitCount()+"";
            sUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";

            // only compose prescriptio-rule if all data is available
            if(!sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0") && product != null){
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));

                // productunits
                if(Double.parseDouble(sUnitsPerTimeUnit) == 1){
                    sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                }
                else {
                    sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if(Integer.parseInt(sTimeUnitCount) == 1){
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
                }
                else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            // supplying service name
            sSupplyingServiceUid = checkString(prescr.getSupplyingServiceUid());
            if(sSupplyingServiceUid.length() > 0){
                sSupplyingServiceName = getTran("service", sSupplyingServiceUid, sWebLanguage);
            }
            else {
                sSupplyingServiceName = "";
            }

            // service stock name
            sServiceStockUid = prescr.getServiceStockUid();
            ServiceStock serviceStock = ServiceStock.get(sServiceStockUid);
            if(sServiceStockUid.length() > 0 && serviceStock != null){
                sServiceStockName = serviceStock.getName();
            }
            else{
                sServiceStockName = "";
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";
			
            boolean available = Product.isInStock(prescr.getProductUid(), prescr.getServiceStockUid());
            double openQuantity = prescr.getRequiredPackages() - prescr.getDeliveredQuantity();
            if(prescr.getEnd() != null && prescr.getEnd().before(new java.util.Date())){
                openQuantity = 0;
            }

            //*** display prescription in one row ***
            html.append("<tr class='list"+sClass+"'  title='"+detailsTran+"'>")
                 .append("<td align='center'>"+(((prescr == null || (prescr != null && prescr.getDeliveredQuantity() == 0))) && (activeUser.getAccessRight("prescriptions.drugs.delete")) ? "<img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' border='0' title='"+deleteTran+"' onclick=\"doDelete('"+prescr.getUid()+"');\">" : "")+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\"><b>"+sProductName+"</b></td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateBeginFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateEndFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sPrescrRule.toLowerCase()+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+prescr.getDeliveredQuantity()+"</td>")
                 .append("<td "+(!available && openQuantity > 0 ? " class='strike'" : "")+(openQuantity > 0 ? " bgcolor='#ff9999'" : "")+">"+(available && openQuantity > 0 ? "<a title='"+getTran("web", "deliver", sWebLanguage)+"' href=\"javascript:doDeliverMedication('"+prescr.getUid()+"');\"><font style='color: black;'>" : "<font style='color: black; text-decoration: line-through;'>")+openQuantity+"</font></a></td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortCol = "OC_PRESCR_BEGIN",
           sDefaultSortDir = "DESC";

    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditPrescrUid = checkString(request.getParameter("EditPrescrUid")),
           sEditPrescriberUid = checkString(request.getParameter("EditPrescriberUid")),
           sEditProductUid = checkString(request.getParameter("EditProductUid")),
           sEditDateBegin = checkString(request.getParameter("EditDateBegin")),
           sEditDateEnd = checkString(request.getParameter("EditDateEnd")),
           sEditTimeUnit = checkString(request.getParameter("EditTimeUnit")),
           sEditTimeUnitCount = checkString(request.getParameter("EditTimeUnitCount")),
           sEditUnitsPerTimeUnit = checkString(request.getParameter("EditUnitsPerTimeUnit")),
           sEditSupplyingServiceUid = checkString(request.getParameter("EditSupplyingServiceUid")),
           sEditServiceStockUid = checkString(request.getParameter("EditServiceStockUid")),
           sEditRequiredPackages = checkString(request.getParameter("EditRequiredPackages"));
    
    if(activePatient == null && sEditPrescrUid.length() > 0){
        activePatient = Prescription.get(sEditPrescrUid).getPatient();
    }

    String sTime1 = checkString(request.getParameter("time1")),
           sTime2 = checkString(request.getParameter("time2")),
           sTime3 = checkString(request.getParameter("time3")),
           sTime4 = checkString(request.getParameter("time4")),
           sTime5 = checkString(request.getParameter("time5")),
           sTime6 = checkString(request.getParameter("time6"));

    String sQuantity1 = checkString(request.getParameter("quantity1")),
           sQuantity2 = checkString(request.getParameter("quantity2")),
           sQuantity3 = checkString(request.getParameter("quantity3")),
           sQuantity4 = checkString(request.getParameter("quantity4")),
           sQuantity5 = checkString(request.getParameter("quantity5")),
           sQuantity6 = checkString(request.getParameter("quantity6"));

    PrescriptionSchema prescriptionSchema = new PrescriptionSchema();
    if(sTime1.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime1, sQuantity1));
    }
    if(sTime2.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime2, sQuantity2));
    }
    if(sTime3.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime3, sQuantity3));
    }
    if(sTime4.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime4, sQuantity4));
    }
    if(sTime5.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime5, sQuantity5));
    }
    if(sTime6.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime6, sQuantity6));
    }

    // afgeleide data
    String sEditPatientFullName      = checkString(request.getParameter("EditPatientFullName")),
           sEditPrescriberFullName   = checkString(request.getParameter("EditPrescriberFullName")),
           sEditProductName          = checkString(request.getParameter("EditProductName")),
           sEditSupplyingServiceName = checkString(request.getParameter("EditSupplyingServiceName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** medical/managePrescriptionsPopup.jsp *****************");
        Debug.println("sAction                   : "+sAction);
        Debug.println("sEditPrescrUid            : "+sEditPrescrUid);
        Debug.println("sEditPrescriberUid        : "+sEditPrescriberUid);
        Debug.println("sEditProductUid           : "+sEditProductUid);
        Debug.println("sEditDateBegin            : "+sEditDateBegin);
        Debug.println("sEditDateEnd              : "+sEditDateEnd);
        Debug.println("sEditTimeUnit             : "+sEditTimeUnit);
        Debug.println("sEditTimeUnitCount        : "+sEditTimeUnitCount);
        Debug.println("sEditUnitsPerTimeUnit     : "+sEditUnitsPerTimeUnit);
        Debug.println("sEditSupplyingServiceUid  : "+sEditSupplyingServiceUid);
        Debug.println("sEditServiceStockUid      : "+sEditServiceStockUid);
        Debug.println("sEditPatientFullName      : "+sEditPatientFullName);
        Debug.println("sEditPrescriberFullName   : "+sEditPrescriberFullName);
        Debug.println("sEditProductName          : "+sEditProductName);
        Debug.println("sEditSupplyingServiceName : "+sEditSupplyingServiceName);
        Debug.println("sEditRequiredPackages     : "+sEditRequiredPackages+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sSelectedPrescriberUid = "", sSelectedProductUid = "",
            sSelectedDateBegin = "", sSelectedDateEnd = "", sSelectedTimeUnit = "", sSelectedTimeUnitCount = "",
            sSelectedUnitsPerTimeUnit = "", sSelectedSupplyingServiceUid = "", sSelectedProductUnit = "",
            sSelectedPrescriberFullName = "", sSelectedProductName = "", sSelectedSupplyingServiceName = "",
            sSelectedServiceStockUid = "", sSelectedServiceStockName = "", sSelectedRequiredPackages = "";

    // variables
    int foundPrescrCount;
    StringBuffer prescriptionsHtml;
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    //boolean patientIsHospitalized = (activePatient!=null && activePatient.isHospitalized());
    boolean displayEditFields = false;

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length() == 0) sSortCol = sDefaultSortCol;

    // sortdir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditPrescrUid.length() > 0){
        out.println("<script>isModified=true;</script>");
        
        // create prescription
        Prescription prescr = new Prescription();
        prescr.setUid(sEditPrescrUid);
        prescr.setPatientUid(activePatient.personid);
        prescr.setPrescriberUid(sEditPrescriberUid);
        prescr.setProductUid(sEditProductUid);
        prescr.setTimeUnit(sEditTimeUnit);
        if(sEditDateBegin.length() > 0) prescr.setBegin(stdDateFormat.parse(sEditDateBegin));
        if(sEditDateEnd.length() > 0) prescr.setEnd(stdDateFormat.parse(sEditDateEnd));
        if(sEditTimeUnitCount.length() > 0) prescr.setTimeUnitCount(Integer.parseInt(sEditTimeUnitCount));
        if(sEditUnitsPerTimeUnit.length() > 0) prescr.setUnitsPerTimeUnit(Double.parseDouble(sEditUnitsPerTimeUnit));
        if(sEditRequiredPackages.length() > 0) prescr.setRequiredPackages(Integer.parseInt(sEditRequiredPackages));
        prescr.setUpdateUser(activeUser.userid);

        // if no service stock (and so no supplying service) specified :
        Debug.println("*** activeUser.activeService.code                   = '"+activeUser.activeService.code+"'");/////////// todo
        Debug.println("*** activeUser.activeService.defaultServiceStockUid = '"+activeUser.activeService.defaultServiceStockUid+"'");/////////// todo

        if(sEditServiceStockUid.length()==0){
            if(activePatient.isHospitalized()){
                // * for hospitalized patient : active users' active services' default service stock
                sEditServiceStockUid = activeUser.activeService.defaultServiceStockUid;
                if(sEditServiceStockUid.length()==0){
                    sEditServiceStockUid = MedwanQuery.getInstance().getConfigString("centralPharmacyServiceStockCode");
                    Debug.println("*********** hospitalized, no def serv stock for serv --> centralPharmacyServiceStockCode");/////////////    todo
                } 
                else {
                    Debug.println("*********** hospitalized --> activeUser.activeService.defaultServiceStockUid");///////////// todo
                }
            } 
            else {
                // * for NON-hospitalized patient : service stock specified for centralPharmacy
                sEditServiceStockUid = MedwanQuery.getInstance().getConfigString("centralPharmacyServiceStockCode");
                Debug.println("*********** NOT hospitalized --> centralPharmacyServiceStockCode");/////////////    todo
            }
        }
        prescr.setServiceStockUid(sEditServiceStockUid);

        // supplying service uid
        if(sEditSupplyingServiceUid.length()==0){
            ServiceStock serviceStock = ServiceStock.get(sEditServiceStockUid);
            if(serviceStock != null){
                sEditSupplyingServiceUid = serviceStock.getService().code;
            }
        }
        prescr.setSupplyingServiceUid(sEditSupplyingServiceUid);

        Debug.println("*********** SAVE PRESCRIPTION from popup : ");
        Debug.println("              sEditServiceStockUid     = "+sEditServiceStockUid);///////////// todo
        Debug.println("              sEditSupplyingServiceUid = "+sEditSupplyingServiceUid);///////////// todo

        String existingPrescrUid = prescr.exists();
        boolean prescrExists = existingPrescrUid.length() > 0;
        if(sEditPrescrUid.equals("-1")){
            //***** insert new prescription *****
            if(true || !prescrExists){
                prescr.store(false);
                prescriptionSchema.setPrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject new addition *****
            else {
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>"+getTran("web.manage", "prescriptionexists", sWebLanguage)+"</font>";
            }
        } else {
            //***** update existing record *****
            if(true || !prescrExists){
                prescr.store(false);
                prescriptionSchema.setPrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject double record thru update *****
            else {
                if(sEditPrescrUid.equals(existingPrescrUid)){
                    // nothing : just updating a record with its own data
                    if(prescr.changed()){
                        prescr.store(false);
                        msg = getTran("web", "dataissaved", sWebLanguage);
                    }

                    prescriptionSchema.setPrescriptionUid(prescr.getUid());
                    prescriptionSchema.store();
                } else {
                    // tried to update one prescription with exact the same data as an other prescription
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>"+getTran("web.manage", "prescriptionexists", sWebLanguage)+"</font>";
                }
            }
        }

        sEditPrescrUid = prescr.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditPrescrUid.length() > 0){
        Prescription.delete(sEditPrescrUid);
        PrescriptionSchema prescriptionSchemaToDelete = PrescriptionSchema.getPrescriptionSchema(sEditPrescrUid);
        prescriptionSchemaToDelete.delete();
        msg = getTran("web", "dataisdeleted", sWebLanguage);
        out.println("<script>isModified=true;</script>");
    }

    //--- SORT ------------------------------------------------------------------------------------
    if(sAction.equals("sort")){
        displayEditFields = false;
        sAction = "find";
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            Prescription prescr = Prescription.get(sEditPrescrUid);

            if(prescr != null){
                if(prescr.getProduct() != null){
                    sSelectedProductUid = prescr.getProductUid();
                }

                // format begin date
                java.util.Date tmpDate = prescr.getBegin();
                if(tmpDate != null) sSelectedDateBegin = stdDateFormat.format(tmpDate);

                // format end date
                tmpDate = prescr.getEnd();
                if(tmpDate != null) sSelectedDateEnd = stdDateFormat.format(tmpDate);

                sSelectedTimeUnit = checkString(prescr.getTimeUnit());
                sSelectedTimeUnitCount = prescr.getTimeUnitCount()+"";
                sSelectedUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";
                sSelectedSupplyingServiceUid = checkString(prescr.getSupplyingServiceUid());
                sSelectedServiceStockUid = checkString(prescr.getServiceStockUid());
                sSelectedRequiredPackages = prescr.getRequiredPackages()+"";
                sSelectedPrescriberUid = prescr.getPrescriberUid();

                // afgeleide data
	          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                sSelectedPrescriberFullName = ScreenHelper.getFullUserName(sSelectedPrescriberUid, ad_conn);
                ad_conn.close();
                // supplying service name
                if(sSelectedSupplyingServiceUid.length() > 0){
                    sSelectedSupplyingServiceName = getTranNoLink("Service", sSelectedSupplyingServiceUid, sWebLanguage);
                }

                // service stock name
                if(sSelectedServiceStockUid.length() > 0){
                    ServiceStock serviceStock = prescr.getServiceStock();
                    if(serviceStock != null){
                        sSelectedServiceStockName = serviceStock.getName();
                    }
                }

                // product
                Product product = Product.get(sSelectedProductUid);
                if(product != null){
                    sSelectedProductUnit = product.getUnit();
                    sSelectedProductName = product.getName();

                    if(sSelectedProductName.length()==0){
                        sSelectedProductName = "<font color='red'>"+getTran("web", "nonexistingproduct", sWebLanguage)+"</font>";
                    }
                }
            }

            prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescr.getUid());
        } 
        else if(sAction.equals("showDetailsAfterAddReject")){
            // do not get data from DB, but show data that were allready on form
            sSelectedPrescriberUid = sEditPrescriberUid;
            sSelectedProductUid = sEditProductUid;
            sSelectedDateBegin = sEditDateBegin;
            sSelectedDateEnd = sEditDateEnd;
            sSelectedTimeUnit = sEditTimeUnit;
            sSelectedTimeUnitCount = sEditTimeUnitCount;
            sSelectedUnitsPerTimeUnit = sEditUnitsPerTimeUnit;
            sSelectedSupplyingServiceUid = sEditSupplyingServiceUid;
            sSelectedServiceStockUid = sEditServiceStockUid;
            sSelectedRequiredPackages = sEditRequiredPackages;

            // afgeleide data
            sSelectedPrescriberFullName = sEditPrescriberFullName;
            sSelectedProductName = sEditProductName;
            sSelectedProductUnit = "";
            sSelectedSupplyingServiceName = sEditSupplyingServiceName;
        } 
        else {
            // showDetailsNew : set default values
            sSelectedPrescriberUid = activeUser.userid;
            sSelectedPrescriberFullName = activeUser.person.lastname+" "+activeUser.person.firstname;
            sSelectedDateBegin = stdDateFormat.format(new java.util.Date());
            sSelectedTimeUnit = "type2day";
            sSelectedTimeUnitCount = "1";
        }
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown = "";
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSave();}\"";
    }
    
    // only editable by prescriber
    boolean editableByPrescriber = false;
    if(activeUser.isAdmin()){
    	editableByPrescriber = true; // always editable by administrator
    }
    else if(sEditPrescrUid.length() > 0){
    	if(sSelectedPrescriberUid.equals(activeUser.userid)){
    		editableByPrescriber = true;
    	}
    }
    Debug.println("--> editableByPrescriber : "+editableByPrescriber);  
%>

<form name="transactionForm" id="transactionForm" method="post" action="<c:url value='/'/>/popup.jsp?Page=medical/managePrescriptionsPopup.jsp&PopupHeight=400&PopupWidth=900" <%=sOnKeyDown%> onClick='setSaveButton(event);clearMessage();' onKeyUp='setSaveButton(event);'>
<%-- page title --%>
<table width="100%" cellspacing="0">
    <tr class="admin">
        <td>
            &nbsp;&nbsp;<%="true".equalsIgnoreCase(request.getParameter("ServicePrescriptions")) ? getTran("Web.manage", "ManageServicePrescriptions", sWebLanguage)+"&nbsp;"+activeUser.activeService.getLabel(sWebLanguage) : getTran("Web.manage", "ManagePatientPrescriptions", sWebLanguage)+"&nbsp;"+activePatient.lastname+" "+activePatient.firstname%>
        </td>
        <td align="right">
            <%
                if(sAction.startsWith("showDetails")){
            %><img onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';"
                   onClick="doBackToOverview();" style='vertical-align:middle;' border='0'
                   src='<%=sCONTEXTPATH%>/_img/arrow.jpg' alt='<%=getTran("Web","Back",sWebLanguage)%>'><%
            }
        %>
        </td>
    </tr>
</table>

<%
    if(!"true".equalsIgnoreCase(request.getParameter("ServicePrescriptions")) && activePatient == null){
        // display message
        %><%=getTran("web", "firstselectaperson", sWebLanguage)%><%
    } 
    else {
    //*************************************************************************************
    //*** process display options *********************************************************
    //*************************************************************************************

    //--- EDIT FIELDS ---------------------------------------------------------------------
    if(displayEditFields){
        DecimalFormat doubleFormat = new DecimalFormat("#.#");
%>
<table class="list" width="100%" cellspacing="1">
<%-- product --%>
<%
    String onClick = "onclick=\"searchProduct('EditProductUid','EditProductName','ProductUnit','EditUnitsPerTimeUnit','UnitsPerPackage',null,'EditServiceStockUid');\"";
%>
<tr>
    <td class="admin"><%=getTran("Web", "product", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <input type="hidden" name="EditProductUid" value="<%=sSelectedProductUid%>">
        <input type="hidden" name="ProductUnit" value="<%=sSelectedProductUnit%>">
        <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>"
               value="<%=sSelectedProductName%>">

        <img id="findProduct" src="<c:url value="/_img/icon_search.gif"/>" class="link"
             alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" <%=onClick%>>
        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
             alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>"
             onclick="transactionForm.EditProductName.value='';transactionForm.EditProductUid.value='';">
    </td>
</tr>
<%-- ***** prescription-rule (dosage) ***** --%>
<tr>
    <td class="admin"><%=getTran("Web", "prescriptionrule", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <%-- Units Per Time Unit --%>
        <input type="text" class="text" style="vertical-align:-1px;" name="EditUnitsPerTimeUnit"
               value="<%=(sSelectedUnitsPerTimeUnit.length()>0?(doubleFormat.format(Double.parseDouble(sSelectedUnitsPerTimeUnit))).replaceAll(",","."):"")%>"
               size="5" maxLength="5" onKeyUp="isNumber(this);calculatePackagesNeeded();">
        <span id="EditUnitsPerTimeUnitLabel"></span>

        <%-- Time Unit Count --%>
        &nbsp;<%=getTran("web", "per", sWebLanguage)%>
        <input type="text" class="text" style="vertical-align:-1px;" name="EditTimeUnitCount"
               value="<%=sSelectedTimeUnitCount%>" size="5" maxLength="5" onKeyUp="calculatePackagesNeeded();">

        <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
        <select class="text" name="EditTimeUnit"
                onChange="setEditUnitsPerTimeUnitLabel();setEditTimeUnitCount();calculatePackagesNeeded();"
                style="vertical-align:-3px;">
            <option value=""><%=getTran("web", "choose", sWebLanguage)%>
            </option>
            <%=ScreenHelper.writeSelectUnsorted("prescription.timeunit", sSelectedTimeUnit, sWebLanguage)%>
        </select>

        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" style="vertical-align:-4px;"
             alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearDescriptionRule();">
    </td>
</tr>
<%-- date begin --%>
<tr>
    <td class="admin"><%=getTran("Web", "begindate", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <input type="text" maxlength="10" class="text" id="EditDateBegin" name="EditDateBegin" value="<%=sSelectedDateBegin%>" size="12"
               onblur="if(!checkDate(this)){alertDialog('Web.Occup','date.error');this.value='';}else{calculatePackagesNeeded(false);}if(isEndDateBeforeBeginDate()){displayEndBeforeBeginAlert();}"
               onKeyUp="if(this.value.length==10){calculatePackagesNeeded(false);}else{transactionForm.EditRequiredPackages.value='';}">
        <img name="popcal" class="link" src="<%=sCONTEXTPATH%>/_img/icon_agenda.gif"
             alt="<%=getTran("Web","Select",sWebLanguage)%>"
             onclick="gfPop1.fPopCalendar(document.getElementById('EditDateBegin'));return false;">
        <img class="link" src="<%=sCONTEXTPATH%>/_img/icon_compose.gif"
             alt="<%=getTran("Web","PutToday",sWebLanguage)%>"
             onclick="getToday(document.getElementById('EditDateBegin'));calculatePackagesNeeded(false);">
        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
             alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDateBegin.value='';">
    </td>
</tr>
<%-- date end --%>
<tr>
    <td class="admin"><%=getTran("Web", "enddate", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <input type="text" maxlength="10" class="text" id="EditDateEnd" name="EditDateEnd" value="<%=sSelectedDateEnd%>" size="12"
               onblur="if(!checkDate(this)){alertDialog('Web.Occup','date.error');this.value='';}else{calculatePackagesNeeded(false);}if(isEndDateBeforeBeginDate()){displayEndBeforeBeginAlert();}"
               onKeyUp="if(this.value.length==10){calculatePackagesNeeded(false);}else{transactionForm.EditRequiredPackages.value='';}">
        <img name="popcal" class="link" src="<%=sCONTEXTPATH%>/_img/icon_agenda.gif"
             alt="<%=getTran("Web","Select",sWebLanguage)%>"
             onclick="gfPop1.fPopCalendar(document.getElementById('EditDateEnd'));return false;">
        <img class="link" src="<%=sCONTEXTPATH%>/_img/icon_compose.gif"
             alt="<%=getTran("Web","PutToday",sWebLanguage)%>"
             onclick="getToday(document.getElementById('EditDateEnd'));calculatePackagesNeeded(false);">
        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link"
             alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDateEnd.value='';">
    </td>
</tr>
<%-- number of packages needed for this prescription --%>
<%
    // units per package
    String sUnitsPerPackage = "";
    Prescription prescr = null;
    if(sEditPrescrUid.length() > 0 && !sEditPrescrUid.equals("-1")){
        prescr = Prescription.get(sEditPrescrUid);
        if(prescr != null && prescr.getProduct() != null){
            sUnitsPerPackage = prescr.getProduct().getPackageUnits()+"";
            if(prescriptionSchema.getTimequantities().size()==0){
                prescriptionSchema.setTimequantities(ProductSchema.getSingleProductSchema(prescr.getProduct().getUid()).getTimequantities());
            }
        }
    }
%>
<tr>
    <td class="admin"><%=getTran("Web", "packages", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <input class="text" type="text" name="EditRequiredPackages" size="5" maxLength="5" value="<%=sSelectedRequiredPackages%>" onKeyUp="if(isInteger(this)){calculatePrescriptionPeriod();}">
        &nbsp;(<input type="text" class="text" name="UnitsPerPackage" value="<%=sUnitsPerPackage%>" size="3" readonly style="border:none;background:transparent;text-align:right;vertical-align:-4px;">&nbsp;<%=getTran("web", "packageunits", sWebLanguage).toLowerCase()%>)
    </td>
</tr>
<%-- prescriber --%>
<tr>
    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web", "prescriber", sWebLanguage)%>&nbsp;*&nbsp;</td>
    <td class="admin2">
        <input type="hidden" name="EditPrescriberUid" value="<%=sSelectedPrescriberUid%>">
        <input class="text" type="text" name="EditPrescriberFullName" readonly size="<%=sTextWidth%>" value="<%=sSelectedPrescriberFullName%>">

        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrescriber('EditPrescriberUid','EditPrescriberFullName');">
        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditPrescriberUid.value='';transactionForm.EditPrescriberFullName.value='';">
    </td>
</tr>
<%-- Service Stock --%>
<tr>
    <td class="admin"><%=getTran("Web", "servicestock", sWebLanguage)%>&nbsp;</td>
    <td class="admin2">
        <input type="hidden" name="EditServiceStockUid" value="<%=sSelectedServiceStockUid%>">
        <input class="text" type="text" name="EditServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sSelectedServiceStockName%>">

        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('EditServiceStockUid','EditServiceStockName');">
        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditServiceStockUid.value='';transactionForm.EditServiceStockName.value='';transactionForm.EditSupplyingServiceUid.value='';transactionForm.EditSupplyingServiceName.value='';">
    </td>
</tr>
<%-- Supplying Service --%>
<tr>
    <td class="admin" nowrap><%=getTran("Web", "supplyingservice", sWebLanguage)%>&nbsp;</td>
    <td class="admin2">
        <input type="hidden" name="EditSupplyingServiceUid" value="<%=sSelectedSupplyingServiceUid%>">
        <input class="text" type="text" name="EditSupplyingServiceName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSupplyingServiceName%>">
    </td>
</tr>
<%-- schema --%>
<tr>
    <td class="admin" nowrap><%=getTran("Web", "schema", sWebLanguage)%>&nbsp;</td>
    <td class="admin2">
        <table>
            <tr>
                <td><input class="text" type="text" name="time1" value="<%=prescriptionSchema.getTimeQuantity(0).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><input class="text" type="text" name="time2" value="<%=prescriptionSchema.getTimeQuantity(1).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><input class="text" type="text" name="time3" value="<%=prescriptionSchema.getTimeQuantity(2).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><input class="text" type="text" name="time4" value="<%=prescriptionSchema.getTimeQuantity(3).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><input class="text" type="text" name="time5" value="<%=prescriptionSchema.getTimeQuantity(4).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><input class="text" type="text" name="time6" value="<%=prescriptionSchema.getTimeQuantity(5).getKey()%>" size="2"><%=getTran("web", "abbreviation.hour", sWebLanguage)%></td>
                <td><a href="javascript:loadSchema();"><img class="link" src="<c:url value="/_img/icon_search.gif"/>" alt="Search schema"/></a></td>
            </tr>
            <tr>
                <td><input class="text" type="text" name="quantity1" value="<%=(prescriptionSchema.getTimeQuantity(0).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(0).getValue())%>" size="2">#</td>
                <td><input class="text" type="text" name="quantity2" value="<%=(prescriptionSchema.getTimeQuantity(1).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(1).getValue())%>" size="2">#</td>
                <td><input class="text" type="text" name="quantity3" value="<%=(prescriptionSchema.getTimeQuantity(2).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(2).getValue())%>" size="2">#</td>
                <td><input class="text" type="text" name="quantity4" value="<%=(prescriptionSchema.getTimeQuantity(3).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(3).getValue())%>" size="2">#</td>
                <td><input class="text" type="text" name="quantity5" value="<%=(prescriptionSchema.getTimeQuantity(4).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(4).getValue())%>" size="2">#</td>
                <td><input class="text" type="text" name="quantity6" value="<%=(prescriptionSchema.getTimeQuantity(5).getValue().equals("-1")?"":prescriptionSchema.getTimeQuantity(5).getValue())%>" size="2">#</td>
                <td/>
            </tr>
        </table>
    </td>
</tr>
</table>

<%-- indication of obligated fields --%>
<%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

<%-- display message --%>
<br><span id="msgArea">&nbsp;<%=msg%></span>

<%-- EDIT BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
	    if(editableByPrescriber){
	        // existing prescription : display saveButton with save-label
	        if((prescr == null || (prescr != null && prescr.getDeliveredQuantity() == 0)) && (activeUser.getAccessRight("prescriptions.drugs.add") || activeUser.getAccessRight("prescriptions.drugs.edit"))){
	            %><input class="button" type="button" name="saveButton" id="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;<%
	        }
	        if((prescr == null || (prescr != null && prescr.getDeliveredQuantity() == 0)) && activeUser.getAccessRight("prescriptions.drugs.delete")){
				%><input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditPrescrUid%>');">&nbsp;<%
	    	}
        }
        else{
        	%><font color="red"><%=getTran("web.occup","onlyEditableByPrescriber",sWebLanguage)%><br></font><%
        }
	    
		%><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();"><%
	}
    else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
	    // new prescription : display saveButton with add-label+do not display delete button
	    if(activeUser.getAccessRight("prescriptions.drugs.add") || activeUser.getAccessRight("prescriptions.drugs.edit")){
			%><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAdd();">&nbsp;<%
    	}
	    
		%><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();"><%
    }
%>
<%=ScreenHelper.alignButtonsStop()%>

<script>
function reloadOpener(){
  if(isModified && window.opener.document.getElementById('patientmedicationsummary')!=undefined){
    window.opener.location.reload();
  }
}

setEditUnitsPerTimeUnitLabel();

<%-- CALCULATE PRESCRIPTION PERIOD --%>
function calculatePrescriptionPeriod(){
  var packages = transactionForm.EditRequiredPackages.value;
  var beginDateStr = transactionForm.EditDateBegin.value;
  var endDateStr = transactionForm.EditDateEnd.value;

  if(packages.length > 0){
    var unitsPerPackage = transactionForm.UnitsPerPackage.value;
    var unitsPerTimeUnit = transactionForm.EditUnitsPerTimeUnit.value;
    var timeUnitCount = transactionForm.EditTimeUnitCount.value;
    var timeUnit = transactionForm.EditTimeUnit.value;

    if(unitsPerPackage.length > 0 && unitsPerTimeUnit.length > 0 && timeUnitCount.length > 0 && timeUnit.length > 0){
      var totalUnits = packages * unitsPerPackage;

      var millisInTimeUnit;
      if(timeUnit=="type1hour"){
        millisInTimeUnit = 3600 * 1000;
      }
      else if(timeUnit=="type2day"){
        millisInTimeUnit = 24 * 3600 * 1000;
      }
      else if(timeUnit == "type3week"){
        millisInTimeUnit = 7 * 24 * 3600 * 1000;
      }
      else if(timeUnit == "type4month"){
        millisInTimeUnit = 31 * 24 * 3600 * 1000;
      }

      var unitsPerMilli = unitsPerTimeUnit / millisInTimeUnit / timeUnitCount;
      var periodInMillis = totalUnits / unitsPerMilli;
      var millisPerDay = 24 * 60 * 60 * 1000;
      var periodInDays = Math.floor(periodInMillis / millisPerDay - 1);

      <%-- calculate beginDate : subtract days from endDate --%>
      if(beginDateStr.length==0){
        var beginDateInMillis = makeDate(endDateStr).getTime() - (periodInDays * (24 * 3600 * 1000));
        var beginDate = new Date();
        beginDate.setTime(beginDateInMillis);

        var day = beginDate.getDate();
        if(day < 10) day = "0"+day;

        var month = beginDate.getMonth()+1;
        if(month < 10) month = "0"+month;

        transactionForm.EditDateBegin.value = day+"/"+month+"/"+beginDate.getFullYear();
      }
      <%-- calculate endDate : add days to beginDate --%>
      else{
        var beginDate = makeDate(beginDateStr);
        var endDateInMillis = makeDate(beginDateStr).getTime()+(periodInDays * (24 * 3600 * 1000));
        var endDate = new Date();
        endDate.setTime(endDateInMillis);
        if(endDate.getTime() < beginDate.getTime()){
          endDate = beginDate;
        }
        var day = endDate.getDate();
        if(day < 10) day = "0"+day;
        var month = endDate.getMonth()+1;
        if(month < 10) month = "0"+month;

        transactionForm.EditDateEnd.value = day+"/"+month+"/"+endDate.getFullYear();
      }
    }
  }
}

<%-- CALCULATE PACKAGES NEEDED --%>
function calculatePackagesNeeded(displayAlert){
  if(transactionForm.UnitsPerPackage.value.length > 0 && transactionForm.UnitsPerPackage.value != "0"){
    var dateBegin = transactionForm.EditDateBegin.value;
    var dateEnd = transactionForm.EditDateEnd.value;

    if(dateBegin.length > 0 && dateEnd.length > 0){
      if(!isEndDateBeforeBeginDate()){
        var unitsPerPackage = transactionForm.UnitsPerPackage.value;
        var unitsPerTimeUnit = transactionForm.EditUnitsPerTimeUnit.value;
        var timeUnitCount = transactionForm.EditTimeUnitCount.value;
        var timeUnit = transactionForm.EditTimeUnit.value;

        if(unitsPerPackage.length > 0 && unitsPerTimeUnit.length > 0 && timeUnitCount.length > 0 && timeUnit.length > 0){
          var beginDate = transactionForm.EditDateBegin.value;
          var endDate = transactionForm.EditDateEnd.value;
          var periodInMillis = makeDate(endDate).getTime()+24 * 3600 * 1000 - makeDate(beginDate).getTime();

          var millisInTimeUnit;
          if(timeUnit == "type1hour"){
            millisInTimeUnit = 3600 * 1000;
          }
          else if(timeUnit == "type2day"){
            millisInTimeUnit = 24 * 3600 * 1000;
          }
          else if(timeUnit == "type3week"){
            millisInTimeUnit = 7 * 24 * 3600 * 1000;
          }
          else if(timeUnit == "type4month"){
            millisInTimeUnit = 31 * 24 * 3600 * 1000;
          }

          var unitsPerMilli = unitsPerTimeUnit / millisInTimeUnit / timeUnitCount;
          var daysInPeriod = periodInMillis / (24 * 3600 * 1000);
          var unitsNeeded = periodInMillis * unitsPerMilli;
          var packagesNeeded = Math.ceil(unitsNeeded / unitsPerPackage);

          transactionForm.EditRequiredPackages.value = packagesNeeded;
        }
        else {
          transactionForm.EditRequiredPackages.value = "";
        }
      }
      else {
        if(displayAlert == undefined){
          displayAlert = true;
        }

        if(displayAlert == true){
          var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.Occup&labelID=endMustComeAfterBegin";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,"Popup",modalities):window.confirm("<%=getTranNoLink("web.Occup","endMustComeAfterBegin",sWebLanguage)%>");
          transactionForm.EditDateEnd.focus();
        }

        transactionForm.EditRequiredPackages.value = "";
      }
    }
  }
}

<%-- DISPLAY "END BEFORE BEGIN" ALERT --%>
function displayEndBeforeBeginAlert(){
  if(transactionForm.EditDateEnd.value.length > 0){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.Occup&labelID=endMustComeAfterBegin";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    (window.showModalDialog)?window.showModalDialog(popupUrl,"Popup",modalities):window.confirm("<%=getTranNoLink("web.Occup","endMustComeAfterBegin",sWebLanguage)%>");
  }
}

<%-- set editUnitsPerTimeUnitLabel --%>
function setEditUnitsPerTimeUnitLabel(productUid){
  var unitTran = "";

  if(transactionForm.EditProductUid.value.length==0){
    unitTran = '<%=getTranNoLink("web","units",sWebLanguage)%>';
  }
  else {
    <%
Vector unitTypes = ScreenHelper.getProductUnitTypes(sWebLanguage);

for(int i=0; i<unitTypes.size(); i++){
    %>
        var unitTran<%=(i+1)%> = "<%=getTranNoLink("product.unit",(String)unitTypes.get(i),sWebLanguage).toLowerCase()%>"
        if(transactionForm.ProductUnit.value == "<%=unitTypes.get(i)%>") unitTran = unitTran<%=(i+1)%>;
    <%
        }
    %>
  }

  if(unitTran.length==0){
    openEditProductUnitPopup(productUid);
  }
  else {
    document.getElementById("EditUnitsPerTimeUnitLabel").innerHTML = unitTran;
  }
}

<%-- open edit product unit popup --%>
function openEditProductUnitPopup(productUid){
  var url = "pharmacy/popups/editProductUnit.jsp" +
            "&EditProductUid="+productUid +
            "&ts=<%=getTs()%>";
  openPopup(url);
}

<%-- set setEditTimeUnitCount --%>
function setEditTimeUnitCount(){
  if(transactionForm.EditTimeUnit.selectedIndex > 0){
    if(transactionForm.EditTimeUnitCount.value.length==0){
      transactionForm.EditTimeUnitCount.value = "1";
    }
  }
}

<%-- clear description rule --%>
function clearDescriptionRule(){
  transactionForm.EditUnitsPerTimeUnit.value = "";
  transactionForm.EditTimeUnitCount.value = "";
  transactionForm.EditTimeUnit.value = "";
}

<%-- IS VALID DATE --%>
function isValidDate(dateObj){
  if(dateObj.value.length == 10){
    return checkDate(dateObj);
  }
  return false;
}

<%-- IS ENDDATE BEFORE BEGINDATE --%>
function isEndDateBeforeBeginDate(){
  if(transactionForm.EditDateBegin.value.length > 0 && transactionForm.EditDateEnd.value.length > 0){
    if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
      var dateBegin = transactionForm.EditDateBegin.value;
      var dateEnd = transactionForm.EditDateEnd.value;

      return before(dateEnd, dateBegin);
    }
    return false;
  }
  return true;
}
</script>
<%
    }

    //--- DISPLAY ACTIVE PRESCRIPTIONS (for activePatient) --------------------------------
    if(!sAction.startsWith("showDetails")){
        if("true".equalsIgnoreCase(request.getParameter("ServicePrescriptions"))){
            String sortTran = getTran("web", "clicktosort", sWebLanguage);

%>
<table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
    <%-- clickable header --%>
    <tr>
        <td class="admin" width="22" nowrap>&nbsp;</td>
        <td class="admin"><%=getTran("Web", "product", sWebLanguage)%>
        </td>
        <td class="admin"><SORTTYPE:DATE><%=getTran("Web", "begindate", sWebLanguage)%></SORTTYPE:DATE></td>
        <td class="admin"><SORTTYPE:DATE><%=getTran("Web", "enddate", sWebLanguage)%></SORTTYPE:DATE></td>
        <td class="admin"><%=getTran("Web", "prescriptionrule", sWebLanguage)%></td>
        <td class="admin" nowrap><%=getTran("Web", "delivered.quantity", sWebLanguage)%></td>
        <td class="admin" nowrap><%=getTran("Web", "tobedelivered.quantity", sWebLanguage)%></td>
    </tr>

    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%
            foundPrescrCount = 0;
            Vector services = Service.getChildIds(activeUser.activeService.code);
            services.add(activeUser.activeService.code);
            Vector activePatients;
            for (int s = 0; s < services.size(); s++){
                activePatients = AdminPerson.getPatientsAdmittedInService((String) services.elementAt(s));
                for (int n = 0; n < activePatients.size(); n++){
                    String patient = (String) activePatients.elementAt(n);
                    Vector activePrescrs = Prescription.findActive(patient, "", "", "", "", "", sSortCol, sSortDir);
                    foundPrescrCount += activePrescrs.size();
                    if(activePrescrs.size() > 0){
                      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                        AdminPerson p = AdminPerson.getAdminPerson(ad_conn, patient);
                        ad_conn.close();
                        out.print("<tr class='admin'><td colspan='25'>"+getTran("Web.manage", "ManagePatientPrescriptions", sWebLanguage)+"&nbsp;"+p.lastname+" "+p.firstname+"</td>");
                        out.print(objectsToHtml(activePrescrs, sWebLanguage, activeUser));
                    }
                }
            }
        %>
    </tbody>
</table>

<%-- number of records found --%>
<span style="width:49%;text-align:left;">
    &nbsp;<%=foundPrescrCount%> <%=getTran("web", "activeprescriptionsfound", sWebLanguage)%>
</span>

<%
    if(foundPrescrCount > 20){
        // link to top of page
%>
<span style="width:51%;text-align:right;">
    <a href="#topp" class="topbutton">&nbsp;</a>
</span>
<br>
<%
    }
}
else {
    Vector activePrescrs = Prescription.findActive(activePatient.personid, "", "", "", "", "", sSortCol, sSortDir);
    prescriptionsHtml = objectsToHtml(activePrescrs, sWebLanguage, activeUser);
    foundPrescrCount = activePrescrs.size();

    if(foundPrescrCount > 0 || !"1".equals(request.getParameter("skipEmpty"))){
        String sortTran = getTran("web", "clicktosort", sWebLanguage);
%>
<table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
    <%-- clickable header --%>
    <tr>
        <td class="admin" width="22" nowrap>&nbsp;</td>
        <td class="admin"><%=getTran("Web", "product", sWebLanguage)%></td>
        <td class="admin"><SORTTYPE:DATE><%=getTran("Web", "begindate", sWebLanguage)%></SORTTYPE:DATE></td>
        <td class="admin"><SORTTYPE:DATE><%=getTran("Web", "enddate", sWebLanguage)%></SORTTYPE:DATE></td>
        <td class="admin"><%=getTran("Web", "prescriptionrule", sWebLanguage)%></td>
        <td class="admin" nowrap><%=getTran("Web", "delivered.quantity", sWebLanguage)%></td>
        <td class="admin" nowrap><%=getTran("Web", "tobedelivered.quantity", sWebLanguage)%></td>
    </tr>

    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=prescriptionsHtml%>
    </tbody>
</table>

<%-- number of records found --%>
<span style="width:49%;text-align:left;">
    &nbsp;<%=foundPrescrCount%> <%=
    getTran("web", "activeprescriptionsfound", sWebLanguage)%>
</span>

<%
    if(foundPrescrCount > 20){
        // link to top of page
%>
<span style="width:51%;text-align:right;">
    <a href="#topp" class="topbutton">&nbsp;</a>
</span>
<br>
<%
    }
} 
else {
    // no records found
%>
<script>window.location.href = "<c:url value='/popup.jsp'/>?Page=medical/managePrescriptionsPopup.jsp&Action=showDetailsNew&Close=true&findProduct=true&ts=<%=getTs()%>&PopupHeight=400&PopupWidth=900";</script>
<%
        }
    }

%>
<%-- display message --%>
<br><span id="msgArea">&nbsp;<%=msg%></span>

<%-- NEW BUTTON --%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    if(!"true".equalsIgnoreCase(request.getParameter("ServicePrescriptions")) && activeUser.getAccessRight("prescriptions.drugs.add")){
%>
<input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>"
       onclick="doNew();">
<%
    }
%>
<input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>"
       onclick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>
<%
        }
    }
%>

<%-- hidden fields --%>
<input type="hidden" name="Action" id="ActionElement">
<input type="hidden" name="findProduct" id="findProduct">
<input type="hidden" name="SortCol" value="<%=sSortCol%>">
<input type="hidden" name="SortDir" value="<%=sSortDir%>">
<input type="hidden" name="EditPrescrUid" value="<%=sEditPrescrUid%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
window.resizeTo(900, 380);

<%
    // default focus field
    if(displayEditFields){
        %>transactionForm.EditPrescriberFullName.focus();<%
    }
%>

function loadSchema(){
  openPopup("/_common/search/updatePrescriptionSchema.jsp&productuid="+document.getElementsByName("EditProductUid")[0].value);
}

<%-- DO ADD --%>
function doAdd(){
  transactionForm.EditPrescrUid.value = "-1";
  doSave();
}

<%-- DO SAVE --%>
function doSave(){
  calculatePrescriptionPeriod();
  calculatePackagesNeeded();

  if(checkPrescriptionFields()){
    if(transactionForm.returnButton != undefined) transactionForm.returnButton.disabled = true;
    if(transactionForm.saveButton != undefined) transactionForm.saveButton.disabled = true;
    if(transactionForm.deleteButton != undefined) transactionForm.deleteButton.disabled = true;

    transactionForm.ActionElement.value = "save";
    transactionForm.submit();
  }
  else {
    if(transactionForm.EditProductUid.value.length==0){
      transactionForm.EditProductName.focus();
    }
    else if(transactionForm.EditUnitsPerTimeUnit.value.length==0){
      transactionForm.EditUnitsPerTimeUnit.focus();
    }
    else if(transactionForm.EditTimeUnitCount.value.length==0){
      transactionForm.EditTimeUnitCount.focus();
    }
    else if(transactionForm.EditTimeUnit.value.length==0){
      transactionForm.EditTimeUnit.focus();
    }
    else if(transactionForm.EditDateBegin.value.length==0){
      transactionForm.EditDateBegin.focus();
    }
    else if(transactionForm.EditDateEnd.value.length==0){
      transactionForm.EditDateEnd.focus();
    }
    else if(transactionForm.UnitsPerPackage.value.length==0){
      transactionForm.UnitsPerPackage.focus();
    }
    else if(transactionForm.EditPrescriberUid.value.length==0){
      transactionForm.EditPrescriberFullName.focus();
    }
    else if(transactionForm.EditRequiredPackages.value.length==0){
      transactionForm.EditRequiredPackages.focus();
    }
  }
}

<%-- CHECK PRESCRIPTION FIELDS --%>
function checkPrescriptionFields(){
  var maySubmit = false;

  <%-- required fields --%>
  if(!transactionForm.EditPrescriberUid.value.length == 0 &&
     !transactionForm.EditProductUid.value.length == 0 &&
     !transactionForm.EditTimeUnit.value.length == 0 &&
     !transactionForm.EditDateBegin.value.length == 0 &&
     !transactionForm.EditDateEnd.value.length == 0 &&
     !transactionForm.UnitsPerPackage.value.length == 0 &&
     !transactionForm.EditTimeUnitCount.value.length == 0 &&
     !transactionForm.EditUnitsPerTimeUnit.value.length == 0 &&
     !transactionForm.EditRequiredPackages.value.length==0){

    <%-- check dates --%>
    if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
      if(!isEndDateBeforeBeginDate()){
        maySubmit = true;
      }
      else{
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.Occup&labelID=endMustComeAfterBegin";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"Popup",modalities):window.confirm("<%=getTranNoLink("web.Occup","endMustComeAfterBegin",sWebLanguage)%>");
        transactionForm.EditDateEnd.focus();
      }
    }
  }
  else{
    maySubmit = false;

    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
  }

  return maySubmit;
}

<%-- DO DELETE --%>
function doDelete(prescriptionUid){
  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
  var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

  if(answer==1){
    transactionForm.EditPrescrUid.value = prescriptionUid;
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
  %>

  transactionForm.Action.value = "showDetailsNew";
  transactionForm.findProduct.value = "true";
  transactionForm.submit();
}

<%-- DO SHOW DETAILS --%>
function doShowDetails(prescriptionUid){
  transactionForm.EditPrescrUid.value = prescriptionUid;
  transactionForm.Action.value = "showDetails";
  transactionForm.submit();
}

<%-- CLEAR EDIT FIELDS --%>
function clearEditFields(){
  transactionForm.EditPrescriberUid.value = "";
  transactionForm.EditPrescriberFullName.value = "";

  transactionForm.EditProductUid.value = "";
  transactionForm.EditProductName.value = "";

  transactionForm.EditSupplyingServiceUid.value = "";
  transactionForm.EditSupplyingServiceName.value = "";

  transactionForm.EditDateBegin.value = "";
  transactionForm.EditDateEnd.value = "";
  transactionForm.EditTimeUnit.value = "";
  transactionForm.EditTimeUnitCount.value = "";
  transactionForm.EditUnitsPerTimeUnit.value = "";
}

<%-- DO SORT --%>
function doSort(sortCol){
  transactionForm.Action.value = "sort";
  transactionForm.SortCol.value = sortCol;

  if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
  else                                       transactionForm.SortDir.value = "ASC";

  transactionForm.submit();
}

<%-- popup : search product --%>
function searchProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackageField, productStockUidField, serviceStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>" +
              "&loadschema=true" +
              "&ReturnProductUidField="+productUidField +
              "&ReturnProductNameField="+productNameField +
              "&ReturnSupplierUidField=EditSupplyingServiceUid" +
              "&ReturnSupplierNameField=EditSupplyingServiceName";

    if(productUnitField != undefined){
        url += "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField != undefined){
        url += "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField != undefined){
        url += "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField != undefined){
        url += "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField != undefined){
        url += "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
}

<%-- popup : deliver medication --%>
function doDeliverMedication(prescrUID){
    var url = "/pharmacy/medication/popups/deliverMedicationPopup.jsp&ts=<%=getTs()%>&EditPrescriptionUid="+prescrUID+"&EditSrcDestType=patient&EditSrcDestName=<%=activePatient.firstname+" "+activePatient.lastname%>";
    openPopup(url);
}

<%-- popup : search userProduct --%>
function searchUserProduct(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackageField, productStockUidField, serviceStockUidField){
    var url = "/_common/search/searchUserProduct.jsp&ts=<%=getTs()%>&loadschema=true&ReturnProductUidField="+productUidField+"&ReturnProductNameField="+productNameField;

    if(productUnitField != undefined){
        url += "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField != undefined){
        url += "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField != undefined){
        url += "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField != undefined){
        url += "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField != undefined){
        url += "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
}

<%-- popup : search product in service stock --%>
function searchProductInServiceStock(productUidField, productNameField, productUnitField, unitsPerTimeUnitField, unitsPerPackageField, productStockUidField, serviceStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>&loadschema=true&DisplayProductsOfPatientService=true" +
              "&ReturnProductUidField="+productUidField+"&ReturnProductNameField="+productNameField;

    if(productUnitField != undefined){
        url += "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField != undefined){
        url += "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField != undefined){
        url += "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField != undefined){
        url += "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField != undefined){
        url += "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
}

<%-- popup : search supplying service --%>
function searchSupplyingService(serviceUidField, serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
}

<%-- popup : search service stock --%>
function searchServiceStock(serviceStockUidField, serviceStockNameField){
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceStockUidField+"&ReturnServiceStockNameField="+serviceStockNameField);
}

<%-- popup : search prescriber --%>
function searchPrescriber(prescriberUidField, prescriberNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+prescriberUidField+"&ReturnName="+prescriberNameField+"&displayImmatNew=no");
}

<%-- CLEAR MESSAGE --%>
function clearMessage(){
<%
if(msg.length() > 0){
%>
    document.getElementById('msgArea').innerHTML = "";
<%
    }
%>
}

<%-- CHECK SAVE BUTTON --%>
function checkSaveButton(contextpath, sQuestion){
  var bReturn = true;

  if(false && myButton != null){
    if(bSaveHasNotChanged == false){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=999999999&labelValue="+sQuestion;
      var modalitiesIE = "dialogWidth:300px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

      if(window.showModalDialog){
        answer = window.showModalDialog(popupUrl, '', modalitiesIE);
      }
      else {
        answer = window.confirm(sQuestion);
      }

      if(!answer == 1){
        bReturn = false;
      }
    }
  }
  else if(sFormBeginStatus != myForm.innerHTML){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=999999999&labelValue="+sQuestion;
    var modalitiesIE = "dialogWidth:300px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl, '', modalitiesIE);
    }
    else {
      answer = window.confirm(sQuestion);
    }

    if(!answer == 1){
      bReturn = false;
    }
  }

  return bReturn;
}

<%-- DO BACK TO OVERVIEW --%>
function doBackToOverview(){
  if(checkSaveButton('<%=sCONTEXTPATH%>', "<%=getTranNoLink("Web", "areyousuretodiscard",sWebLanguage)%>")){
    doBack();
  }
}

<%-- DO BACK --%>
function doBack(){
  var ie = (navigator.appName=="Microsoft Internet Explorer")?0:1;// for ie ff compatibility
  if(window.history.length > ie){
  <%
      if(checkString(request.getParameter("Close")).length()==0){
          out.print("window.history.go(-1);return false;");
      }
      else{
          out.print("window.close();");
      }
  %>
  }
  else {
      window.close();
  }
}

<%-- The following script is used to hide the calendar whenever you click the document. --%>
<%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
document.onmousedown = function(e){
    var n = !e?self.event.srcElement.name:e.target.name;

    if(document.layers){
        with (gfPop) var l = pageX, t = pageY, r = l+clip.width, b = t+clip.height;
        if(n != "popcal" && (e.pageX > r || e.pageX < l || e.pageY > b || e.pageY < t)){
            gfPop1.fHideCal();
            gfPop2.fHideCal();
            gfPop3.fHideCal();
        }
        return routeEvent(e);
    }
    else if(n != "popcal"){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
    }
}
</script>
<script for="window" event="onunload">
	reloadOpener();
</script>

<iframe width=174 height=189 name="gToday:normal1:agenda.js:gfPop1" id="gToday:normal1:agenda.js:gfPop1"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal2:agenda.js:gfPop2" id="gToday:normal2:agenda.js:gfPop2"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal3:agenda.js:gfPop3" id="gToday:normal3:agenda.js:gfPop3"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
</iframe>

<%=writeJSButtons("transactionForm", "saveButton")%>

<%
    if("true".equalsIgnoreCase(request.getParameter("findProduct"))){
        //out.print("<script>transactionForm.document.getElementById('findProduct').onclick;</script>");
    }
%>

</body>