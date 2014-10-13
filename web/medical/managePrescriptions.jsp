<%@page import="java.text.SimpleDateFormat,
                be.openclinic.pharmacy.Product,
                be.openclinic.medical.Prescription,
                java.text.DecimalFormat,
                be.openclinic.pharmacy.ServiceStock,
                be.openclinic.common.KeyValue,
                be.openclinic.pharmacy.PrescriptionSchema,
                be.openclinic.pharmacy.ProductSchema,
                java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medical.managecareprescriptionspopup","select",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage,User activeUser){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sDateBeginFormatted, sDateEndFormatted = "",
               sProductName = "", sProductUid, sPreviousProductUid = "";
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
        java.util.Date tmpDate;
        Product product;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran  = getTranNoLink("Web","delete",sWebLanguage);

        // run thru found prescriptions
        Prescription prescr;
        for(int i=0; i<objects.size(); i++){
            prescr = (Prescription) objects.get(i);

            // format date begin
            tmpDate = prescr.getBegin();
            if(tmpDate!=null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else              sDateBeginFormatted = "";

            // format date end
            tmpDate = prescr.getEnd();
            if(tmpDate!=null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else              sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescr.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = Product.get(sProductUid);

                if(product!=null){
                    sProductName = product.getName();
                }
                else {
                    sProductName = "<font color='red'>"+getTran("web", "nonexistingproduct", sWebLanguage)+"</font>";
                }
            }

            /*
            // active ?
            if(tmpEndDate==null || tmpEndDate.after(new java.util.Date())) isActivePrescr = true;
            else                                                           isActivePrescr = false;
            */

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            //*** display prescription in one row ***
          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            html.append("<tr class='list"+sClass+"' title='"+detailsTran+"'>")
                 .append("<td align='center'>"+(((prescr==null || (prescr!=null && prescr.getDeliveredQuantity()==0)) ||(activeUser.getAccessRight("sa"))) && (activeUser.getAccessRight("prescriptions.drugs.delete"))?"<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' border='0' title='"+deleteTran+"' onclick=\"doDelete('"+prescr.getUid()+"');\">":"")+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+ScreenHelper.getFullUserName(prescr.getPrescriberUid(), ad_conn)+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sProductName+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateBeginFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateEndFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+(prescr.getSupplyingServiceUid()!=null?getTranNoLink("Service", prescr.getSupplyingServiceUid(), sWebLanguage):"")+"</td>")
                .append("</tr>");
            
            try{
            	ad_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }

        return html;
    }

    //--- ACTIVE PRESCRIPTIONS TO HTML ------------------------------------------------------------
    private StringBuffer activePrescriptionsToHtml(Vector objects, String sWebLanguage,User activeUser){
        StringBuffer html = new StringBuffer();
        Product product = null;
        String sClass = "1", sDateBeginFormatted, sDateEndFormatted, sProductName = "",
               sProductUid, sPreviousProductUid = "", sTimeUnit, sTimeUnitCount = "",
               sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        java.util.Date tmpDate;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran = getTranNoLink("Web","delete",sWebLanguage);

        Prescription prescr;
        for (int i = 0; i < objects.size(); i++){
            prescr = (Prescription) objects.get(i);

            // format date begin
            tmpDate = prescr.getBegin();
            if(tmpDate!=null) sDateBeginFormatted = ScreenHelper.formatDate(tmpDate);
            else              sDateBeginFormatted = "";

            // format date end
            tmpDate = prescr.getEnd();
            if(tmpDate!=null) sDateEndFormatted = ScreenHelper.formatDate(tmpDate);
            else              sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescr.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = Product.get(sProductUid);

                if(product!=null){
                    sProductName = product.getName();
                } 
                else {
                    sProductName = "<font color='red'>"+getTran("web","nonexistingproduct",sWebLanguage)+"</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescr.getTimeUnit();
            sTimeUnitCount = prescr.getTimeUnitCount()+"";
            sUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";

            // only compose prescriptio-rule if all data is available
            if(!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0") && product!=null){
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule",sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#",unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));

                // productunits
                if(Double.parseDouble(sUnitsPerTimeUnit)==1){
                    sProductUnit = getTran("product.unit",product.getUnit(),sWebLanguage);
                }
                else{
                    sProductUnit = getTran("product.unit",product.getUnit(),sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#",sProductUnit.toLowerCase());

                // timeunits
                if(Integer.parseInt(sTimeUnitCount)==1){
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#","");
                    timeUnitTran = getTran("prescription.timeunit",sTimeUnit,sWebLanguage);
                }
                else{
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#",sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits",sTimeUnit,sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#",timeUnitTran.toLowerCase());
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            //*** display prescription in one row ***
            html.append("<tr class='list"+sClass+"' onmouseover=\"this.style.cursor='pointer';\" onmouseout=\"this.style.cursor='default';\" title='"+detailsTran+"'>")
                 .append("<td align='center'>"+((prescr==null || (prescr!=null && prescr.getDeliveredQuantity()==0)) && (activeUser.getAccessRight("prescriptions.drugs.delete"))?"<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' border='0' title='"+deleteTran+"' onclick=\"doDelete('"+prescr.getUid()+"');\">":"")+"</td>")
                 .append("<td onclick=\"doShowDetailsActive('"+prescr.getUid()+"');\">"+ScreenHelper.getFullUserName(prescr.getPrescriberUid(), ad_conn)+"</td>")
                 .append("<td onclick=\"doShowDetailsActive('"+prescr.getUid()+"');\">"+sProductName+"</td>")
                 .append("<td onclick=\"doShowDetailsActive('"+prescr.getUid()+"');\">"+sDateBeginFormatted+"</td>")
                 .append("<td onclick=\"doShowDetailsActive('"+prescr.getUid()+"');\">"+sDateEndFormatted+"</td>")
                 .append("<td onclick=\"doShowDetailsActive('"+prescr.getUid()+"');\">"+sPrescrRule.toLowerCase()+"</td>")
                .append("</tr>");
            try{
            	ad_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
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
    String sEditPatientFullName       = checkString(request.getParameter("EditPatientFullName")),
            sEditPrescriberFullName   = checkString(request.getParameter("EditPrescriberFullName")),
            sEditProductName          = checkString(request.getParameter("EditProductName")),
            sEditSupplyingServiceName = checkString(request.getParameter("EditSupplyingServiceName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** medical/managePrescriptions.jsp ****************");
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

    String msg = "", sFindPatientUid, sFindPrescriberUid, sFindProductUid, sFindDateBegin, sFindDateEnd,
           sFindSupplyingServiceUid, sSelectedDateEnd = "", sSelectedPrescriberUid = "",
           sSelectedProductUid = "", sSelectedDateBegin = "", sSelectedTimeUnit = "",
           sSelectedTimeUnitCount = "", sSelectedUnitsPerTimeUnit = "", sSelectedSupplyingServiceUid = "",
           sSelectedProductUnit = "", sSelectedPrescriberFullName = "", sSelectedProductName = "",
           sSelectedSupplyingServiceName = "", sFindPrescriberFullName, sFindProductName,
           sFindSupplyingServiceName, sSelectedRequiredPackages = "", sSelectedServiceStockUid = "",
           sSelectedServiceStockName = "";

    // only work with active user
    sFindPatientUid = activePatient.personid;

    // get data from form
    sFindPrescriberUid = checkString(request.getParameter("FindPrescriberUid"));
    sFindProductUid = checkString(request.getParameter("FindProductUid"));
    sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
    sFindDateEnd = checkString(request.getParameter("FindDateEnd"));
    sFindSupplyingServiceUid = checkString(request.getParameter("FindSupplyingServiceUid"));
    sFindPrescriberFullName = checkString(request.getParameter("FindPrescriberFullName"));
    sFindProductName = checkString(request.getParameter("FindProductName"));
    sFindSupplyingServiceName = checkString(request.getParameter("FindSupplyingServiceName"));

    // variables
    int foundPrescrCount = 0;
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
    StringBuffer prescriptionsHtml = null;
    boolean patientIsHospitalized = activePatient.isHospitalized();

    // display options
    boolean displayEditFields = false, displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    Debug.println("@@@ displaySearchFields : "+displaySearchFields);

    String sDisplayActivePrescr = checkString(request.getParameter("DisplayActivePrescriptions"));
    if(sDisplayActivePrescr.length()==0) sDisplayActivePrescr = "true"; // default
    boolean displayActivePrescr = sDisplayActivePrescr.equalsIgnoreCase("true");
    Debug.println("@@@ displayActivePrescr : "+displayActivePrescr);

    String sIsActivePrescr = checkString(request.getParameter("IsActivePrescr"));
    if(sIsActivePrescr.length()==0) sIsActivePrescr = "false"; // default
    boolean isActivePrescr = sIsActivePrescr.equalsIgnoreCase("true");
    Debug.println("@@@ isActivePrescr : "+isActivePrescr);

    // search prescriptions written by active user by default
    if(sAction.length()==0){
        sFindPrescriberUid = "";
        sFindPrescriberFullName = "";
    }

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = sDefaultSortCol;

    // sortdir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditPrescrUid.length() > 0){
        // create prescription
        Prescription prescr = new Prescription();
        prescr.setUid(sEditPrescrUid);
        prescr.setPatientUid(activePatient.personid);
        prescr.setPrescriberUid(sEditPrescriberUid);
        prescr.setProductUid(sEditProductUid);
        prescr.setTimeUnit(sEditTimeUnit);
        if(sEditDateBegin.length() > 0) prescr.setBegin(ScreenHelper.parseDate(sEditDateBegin));
        if(sEditDateEnd.length() > 0) prescr.setEnd(ScreenHelper.parseDate(sEditDateEnd));
        if(sEditTimeUnitCount.length() > 0) prescr.setTimeUnitCount(Integer.parseInt(sEditTimeUnitCount));
        if(sEditUnitsPerTimeUnit.length() > 0) prescr.setUnitsPerTimeUnit(Double.parseDouble(sEditUnitsPerTimeUnit));
        if(sEditRequiredPackages.length() > 0) prescr.setRequiredPackages(Integer.parseInt(sEditRequiredPackages));
        prescr.setSupplyingServiceUid(sEditSupplyingServiceUid);
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
            if(serviceStock!=null){
                sEditSupplyingServiceUid = serviceStock.getService().code;
            }
        }
        prescr.setSupplyingServiceUid(sEditSupplyingServiceUid);

        Debug.println("*********** SAVE PRESCRIPTION from popup : ");
        Debug.println("  sEditServiceStockUid     = "+sEditServiceStockUid);///////////// todo
        Debug.println("  sEditSupplyingServiceUid = "+sEditSupplyingServiceUid);///////////// todo

        String existingPrescrUid = prescr.exists();
        boolean prescrExists = existingPrescrUid.length() > 0;

        if(sEditPrescrUid.equals("-1")){
            //***** insert new prescription *****
            if(!prescrExists){
                prescr.store(false);
                prescriptionSchema.setPrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject new addition *****
            else{
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>"+getTran("web.manage","prescriptionexists",sWebLanguage)+"</font>";
            }
        }
        else{
            //***** update existing record *****
            if(!prescrExists){
                prescr.store(false);
                prescriptionSchema.setPrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject double record thru update *****
            else{
                if(sEditPrescrUid.equals(existingPrescrUid)){
                    // nothing : just updating a record with its own data
                    //if(prescr.changed()){
                        prescr.store(false);
                        prescriptionSchema.setPrescriptionUid(prescr.getUid());
                        prescriptionSchema.store();
                        msg = getTran("web","dataissaved",sWebLanguage);
                    //}
                    sAction = "findShowOverview"; // showDetails
                }
                else{
                    // tried to update one prescription with exact the same data as an other prescription
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>"+getTran("web.manage","prescriptionexists",sWebLanguage)+"</font>";
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
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if(sAction.equals("sort")){
        displayEditFields = false;
        displayActivePrescr = true;
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        if(sAction.equals("find")) displayActivePrescr = false;

        displayFoundRecords = !displayActivePrescr;
        displaySearchFields = true;
        displayEditFields = false;

        Vector prescriptions = Prescription.find(sFindPatientUid, sFindPrescriberUid, sFindProductUid, sFindDateBegin,
               sFindDateEnd, sFindSupplyingServiceUid, sSortCol, sSortDir);
        prescriptionsHtml = objectsToHtml(prescriptions, sWebLanguage,activeUser);
        foundPrescrCount = prescriptions.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            Prescription prescr = Prescription.get(sEditPrescrUid);

            if(prescr!=null){
                sSelectedPrescriberUid = prescr.getPrescriberUid();
                if(prescr.getProduct()!=null){
                    sSelectedProductUid = prescr.getProductUid();
                }

                // format begin date
                java.util.Date tmpDate = prescr.getBegin();
                if(tmpDate!=null) sSelectedDateBegin = stdDateFormat.format(tmpDate);

                // format end date
                tmpDate = prescr.getEnd();
                if(tmpDate!=null) sSelectedDateEnd = stdDateFormat.format(tmpDate);

                sSelectedTimeUnit = checkString(prescr.getTimeUnit());
                sSelectedTimeUnitCount = prescr.getTimeUnitCount()+"";
                sSelectedUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";
                sSelectedSupplyingServiceUid = checkString(prescr.getSupplyingServiceUid());
                sSelectedServiceStockUid = checkString(prescr.getServiceStockUid());
                sSelectedRequiredPackages = prescr.getRequiredPackages()+"";

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
                    sSelectedServiceStockName = prescr.getServiceStock().getName();
                }

                // product
                Product product = Product.get(sSelectedProductUid);
                if(product!=null){
                    sSelectedProductUnit = product.getUnit();
                    sSelectedProductName = product.getName();

                    if(sSelectedProductName.length()==0){
                        sSelectedProductName = "<font color='red'>"+getTran("web", "nonexistingproduct", sWebLanguage)+"</font>";
                    }
                }
                prescriptionSchema = PrescriptionSchema.getPrescriptionSchema(prescr.getUid());
            }
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
        else{
            // showDetailsNew : set default values
            sSelectedPrescriberUid = activeUser.userid;
            sSelectedPrescriberFullName = activeUser.person.lastname+" "+activeUser.person.firstname;
            sSelectedDateBegin = stdDateFormat.format(new java.util.Date());
            sSelectedTimeUnit = "type2day";
            sSelectedTimeUnitCount = "1";
        }
    }
%>

<%
    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown;
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSave();}\"";
    }
    else{
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch('"+sDefaultSortCol+"');}\"";
    }
%>
<form name="transactionForm" id="transactionForm" method="post" <%=sOnKeyDown%> <%=(displaySearchFields?"onClick=\"clearMessage();\"":"onClick=\"setSaveButton(event);clearMessage();\" onKeyUp=\"setSaveButton(event);\"")%>>
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","ManagePrescriptions",sWebLanguage," doBack();")%>
    <%
        if(activePatient==null){
            // display message
            %><%=getTran("web","firstselectaperson",sWebLanguage)%><%
        }
        else{
            //*************************************************************************************
            //*** process display options *********************************************************
            //*************************************************************************************

            //-- SEARCH FIELDS --------------------------------------------------------------------
            if(displaySearchFields){
                %>
                    <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(enterEvent(event,13)){doSearch(\'<%=sDefaultSortCol%>\');}';" onKeyDown="if(enterEvent(event,13)){doSearch('<%=sDefaultSortCol%>');}">
                        <%-- prescriber --%>
                        <tr>
                            <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","prescriber",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="FindPrescriberUid" value="<%=sFindPrescriberUid%>">
                                <input class="text" type="text" name="FindPrescriberFullName" readonly size="<%=sTextWidth%>" value="<%=sFindPrescriberFullName%>">

                                <img src="<c:url value='/_img/icons/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrescriber('FindPrescriberUid','FindPrescriberFullName');">
                                <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindPrescriberUid.value='';transactionForm.FindPrescriberFullName.value='';">
                            </td>
                        </tr>

                        <%-- product --%>
                        <tr>
                            <td class="admin2" nowrap><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="FindProductUid" value="<%=sFindProductUid%>">
                                <input class="text" type="text" name="FindProductName" readonly size="<%=sTextWidth%>" value="<%=sFindProductName%>">

                                <img src="<c:url value='/_img/icons/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProduct('FindProductUid','FindProductName');">
                                <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindProductUid.value='';transactionForm.FindProductName.value='';">
                            </td>
                        </tr>

                        <%-- supplying service --%>
                        <tr>
                            <td class="admin2" nowrap><%=getTran("Web","supplyingservice",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="FindSupplyingServiceUid" value="<%=sFindSupplyingServiceUid%>">
                                <input class="text" type="text" name="FindSupplyingServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindSupplyingServiceName%>">

                                <img src="<c:url value='/_img/icons/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplyingService('FindSupplyingServiceUid','FindSupplyingServiceName');">
                                <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindSupplyingServiceUid.value='';transactionForm.FindSupplyingServiceName.value='';">
                            </td>
                        </tr>

                        <%-- date begin --%>
                        <tr>
                            <td class="admin2" nowrap><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=writeDateField("FindDateBegin","transactionForm",sFindDateBegin,sWebLanguage)%></td>
                        </tr>

                        <%-- date end --%>
                        <tr>
                            <td class="admin2" nowrap><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2"><%=writeDateField("FindDateEnd","transactionForm",sFindDateEnd,sWebLanguage)%></td>
                        </tr>

                        <%-- SEARCH BUTTONS --%>
                        <tr>
                            <td class="admin2">&nbsp;</td>
                            <td class="admin2">
                                <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch('<%=sDefaultSortCol%>');">
                                <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                                <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                                
                                <%
                                    if(!displayActivePrescr){
                                        %><input type="button" class="button" name="searchActivePrescrButton" value="<%=getTranNoLink("Web.manage","activePrescriptions",sWebLanguage)%>" onclick="doSearchInActivePrescriptions();">&nbsp;<%
                                    }
                                    else{
                                    	%><input type="hidden" name="searchActivePrescrButton"><%
                                    }
                                %>

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
                    <input type="hidden" name="FindPrescriberUid" value="<%=sFindPrescriberUid%>">
                    <input type="hidden" name="FindPrescriberFullName" value="<%=sFindPrescriberFullName%>">
                    <input type="hidden" name="FindProductUid" value="<%=sFindProductUid%>">
                    <input type="hidden" name="FindProductName" value="<%=sFindProductName%>">
                    <input type="hidden" name="FindDateBegin" value="<%=sFindDateBegin%>">
                    <input type="hidden" name="FindDateEnd" value="<%=sFindDateEnd%>">
                    <input type="hidden" name="FindSupplyingServiceUid" value="<%=sFindSupplyingServiceUid%>">
                    <input type="hidden" name="FindSupplyingServiceName" value="<%=sFindSupplyingServiceName%>">
                <%
            }

            //--- EDIT FIELDS ---------------------------------------------------------------------
            if(displayEditFields){
                DecimalFormat doubleFormat = new DecimalFormat("#.#");
                %>
                    <table class="list" width="100%" cellspacing="1">
                        <%-- product --%>
                        <%
                            String onClick;
                            if(patientIsHospitalized){
                                onClick = "onclick=\"searchProductInServiceStock('EditProductUid','EditProductName','ProductUnit','EditUnitsPerTimeUnit','UnitsPerPackage',null,'EditServiceStockUid');\"";
                            }
                            else{
                                onClick = "onclick=\"searchProduct('EditProductUid','EditProductName','ProductUnit','EditUnitsPerTimeUnit','UnitsPerPackage',null,'EditServiceStockUid');\"";
                            }
                        %>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","product",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="EditProductUid" value="<%=sSelectedProductUid%>">
                                <input type="hidden" name="ProductUnit" value="<%=sSelectedProductUnit%>">
                                <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" <%=onClick%>>
                                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductName.value='';transactionForm.EditProductUid.value='';">
                            </td>
                        </tr>

                        <%-- ***** prescription-rule (dosage) ***** --%>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","prescriptionrule",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <%-- Units Per Time Unit --%>
                                <input type="text" class="text" style="vertical-align:-1px;" name="EditUnitsPerTimeUnit" value="<%=(sSelectedUnitsPerTimeUnit.length()>0?(doubleFormat.format(Double.parseDouble(sSelectedUnitsPerTimeUnit))).replaceAll(",","."):"")%>" size="5" maxLength="5" onKeyUp="isNumber(this);calculatePackagesNeeded();">
                                <span id="EditUnitsPerTimeUnitLabel"></span>

                                <%-- Time Unit Count --%>
                                &nbsp;<%=getTran("web","per",sWebLanguage)%>
                                <input type="text" class="text" style="vertical-align:-1px;" name="EditTimeUnitCount" value="<%=sSelectedTimeUnitCount%>" size="5" maxLength="5" onKeyUp="calculatePackagesNeeded();">

                                <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
                                <select class="text" name="EditTimeUnit" onChange="setEditUnitsPerTimeUnitLabel();setEditTimeUnitCount();calculatePackagesNeeded();" style="vertical-align:-3px;">
                                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                    <%=ScreenHelper.writeSelectUnsorted("prescription.timeunit",sSelectedTimeUnit,sWebLanguage)%>
                                </select>
                                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" style="vertical-align:-4px;" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearDescriptionRule();">
                            </td>
                        </tr>
                        <%-- date begin --%>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <input type="text" maxlength="10" class="text" name="EditDateBegin" value="<%=sSelectedDateBegin%>" size="12" onblur="if(!checkDate(this)){alertDialog('Web.Occup','date.error');this.value='';}else{calculatePackagesNeeded(false);}if(isEndDateBeforeBeginDate()){displayEndBeforeBeginAlert();}" onKeyUp="if(this.value.length==10){calculatePackagesNeeded(false);}else{transactionForm.EditRequiredPackages.value='';}">
                                <img class="link" name="popcal" src="<%=sCONTEXTPATH%>/_img/icons/icon_agenda.gif" alt="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="gfPop1.fPopCalendar(document.transactionForm.all['EditDateBegin']);return false;">
                                <img class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_compose.gif" alt="<%=getTranNoLink("Web","PutToday",sWebLanguage)%>" onclick="getToday(document.transactionForm.all['EditDateBegin']);calculatePackagesNeeded(false);">
                            </td>
                        </tr>
                        <%-- date end --%>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <input type="text" maxlength="10" class="text" name="EditDateEnd" value="<%=sSelectedDateEnd%>" size="12" onblur="if(!checkDate(this)){alertDialog('Web.Occup','date.error');this.value='';}else{calculatePackagesNeeded(false);}if(isEndDateBeforeBeginDate()){displayEndBeforeBeginAlert();}" onKeyUp="if(this.value.length==10){calculatePackagesNeeded(false);}else{transactionForm.EditRequiredPackages.value='';}">
                                <img class="link" name="popcal" src="<%=sCONTEXTPATH%>/_img/icons/icon_agenda.gif" alt="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="gfPop1.fPopCalendar(document.transactionForm.all['EditDateEnd']);return false;">
                                <img class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_compose.gif" alt="<%=getTranNoLink("Web","PutToday",sWebLanguage)%>" onclick="getToday(document.transactionForm.all['EditDateEnd']);calculatePackagesNeeded(false);">
                            </td>
                        </tr>
                        <%-- number of packages needed for this prescription --%>
                        <%
                            // units per package
                            String sUnitsPerPackage = "";
                            Prescription prescr = null;
                            if(sEditPrescrUid.length() > 0 && !sEditPrescrUid.equals("-1")){
                                prescr = Prescription.get(sEditPrescrUid);
                                if(prescr!=null && prescr.getProduct()!=null){
                                    sUnitsPerPackage = prescr.getProduct().getPackageUnits()+"";
                                    if(prescriptionSchema.getTimequantities().size()==0){
                                        prescriptionSchema.setTimequantities(ProductSchema.getSingleProductSchema(prescr.getProduct().getUid()).getTimequantities());
                                    }
                                }
                            }
                        %>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","packages",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <input class="text" type="text" name="EditRequiredPackages" size="5" maxLength="5" value="<%=sSelectedRequiredPackages%>" onKeyUp="if(isInteger(this)){calculatePrescriptionPeriod();}">
                                &nbsp;(<input type="text" class="text" name="UnitsPerPackage" value="<%=sUnitsPerPackage%>" size="3" readonly style="border:0;background:transparent;text-align:right;">&nbsp;<%=getTran("web","packageunits",sWebLanguage).toLowerCase()%>)
                            </td>
                        </tr>
                        <%-- prescriber --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","prescriber",sWebLanguage)%>&nbsp;*&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="EditPrescriberUid" value="<%=sSelectedPrescriberUid%>">
                                <input class="text" type="text" name="EditPrescriberFullName" readonly size="<%=sTextWidth%>" value="<%=sSelectedPrescriberFullName%>">

                                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrescriber('EditPrescriberUid','EditPrescriberFullName');">
                                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditPrescriberUid.value='';transactionForm.EditPrescriberFullName.value='';">
                            </td>
                        </tr>
                        <%-- Service Stock --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","servicestock",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="EditServiceStockUid" value="<%=sSelectedServiceStockUid%>">
                                <input class="text" type="text" name="EditServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sSelectedServiceStockName%>">

                                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('EditServiceStockUid','EditServiceStockName');">
                                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditServiceStockUid.value='';transactionForm.EditServiceStockName.value='';transactionForm.EditSupplyingServiceUid.value='';transactionForm.EditSupplyingServiceName.value='';">
                            </td>
                        </tr>
                        <%-- Supplying Service --%>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","supplyingservice",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <input type="hidden" name="EditSupplyingServiceUid" value="<%=sSelectedSupplyingServiceUid%>">
                                <input class="text" type="text" name="EditSupplyingServiceName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSupplyingServiceName%>">
                            </td>
                        </tr>
                        <%-- schema --%>
                        <tr>
                            <td class="admin" nowrap><%=getTran("Web","schema",sWebLanguage)%>&nbsp;</td>
                            <td class="admin2">
                                <table>
                                    <tr>
                                        <td><input class="text" type="text" name="time1" value="<%=prescriptionSchema.getTimeQuantity(0).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><input class="text" type="text" name="time2" value="<%=prescriptionSchema.getTimeQuantity(1).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><input class="text" type="text" name="time3" value="<%=prescriptionSchema.getTimeQuantity(2).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><input class="text" type="text" name="time4" value="<%=prescriptionSchema.getTimeQuantity(3).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><input class="text" type="text" name="time5" value="<%=prescriptionSchema.getTimeQuantity(4).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><input class="text" type="text" name="time6" value="<%=prescriptionSchema.getTimeQuantity(5).getKey()%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                                        <td><a href="javascript:loadSchema();"><img class="link" src="<c:url value="/_img/icons/icon_search.gif"/>" alt="Search schema"/></a></td>
                                    </tr>
                                    <tr>
                                        <td><input class="text" type="text" name="quantity1" value="<%=prescriptionSchema.getTimeQuantity(0).getValue()%>" size="2">#</td>
                                        <td><input class="text" type="text" name="quantity2" value="<%=prescriptionSchema.getTimeQuantity(1).getValue()%>" size="2">#</td>
                                        <td><input class="text" type="text" name="quantity3" value="<%=prescriptionSchema.getTimeQuantity(2).getValue()%>" size="2">#</td>
                                        <td><input class="text" type="text" name="quantity4" value="<%=prescriptionSchema.getTimeQuantity(3).getValue()%>" size="2">#</td>
                                        <td><input class="text" type="text" name="quantity5" value="<%=prescriptionSchema.getTimeQuantity(4).getValue()%>" size="2">#</td>
                                        <td><input class="text" type="text" name="quantity6" value="<%=prescriptionSchema.getTimeQuantity(5).getValue()%>" size="2">#</td>
                                        <td/>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <%-- EDIT BUTTONS --%>
                        <tr>
                            <td class="admin2">&nbsp;</td>
                            <td class="admin2">
                                <%
                                    if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                        // existing prescription : display saveButton with save-label
                                        if(((prescr==null || (prescr!=null && prescr.getDeliveredQuantity()==0)) && (activeUser.getAccessRight("prescriptions.drugs.add")))||activeUser.getAccessRight("sa")){
                                        %>
                                            <input class="button" type="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                                            <input class="button" type="button" name="saveButton" id="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                                        <%
                                        }
                                        if((prescr==null || (prescr!=null && prescr.getDeliveredQuantity()==0)) && (activeUser.getAccessRight("prescriptions.drugs.delete"))){
                                            %><input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditPrescrUid%>');"><%
                                        }
                                        %><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();"><%
                                    }
                                    else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                        // new prescription : display saveButton with add-label+do not display delete button
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
                    <%=getTran("Web","asterisk_fields_are_obligate",sWebLanguage)%>
                    <br><br>

                    <script>
                      setEditUnitsPerTimeUnitLabel();

                      <%-- CALCULATE PRESCRIPTION PERIOD --%>
                      function calculatePrescriptionPeriod(){
                        var packages     = transactionForm.EditRequiredPackages.value;
                        var beginDateStr = transactionForm.EditDateBegin.value;
                        var endDateStr   = transactionForm.EditDateEnd.value;

                        if(packages.length>0){
                          var unitsPerPackage  = transactionForm.UnitsPerPackage.value;
                          var unitsPerTimeUnit = transactionForm.EditUnitsPerTimeUnit.value;
                          var timeUnitCount    = transactionForm.EditTimeUnitCount.value;
                          var timeUnit         = transactionForm.EditTimeUnit.value;

                          if(unitsPerPackage.length>0 && unitsPerTimeUnit.length>0 && timeUnitCount.length>0 && timeUnit.length>0){
                            var totalUnits = packages*unitsPerPackage;

                            var millisInTimeUnit;
                                 if(timeUnit=="type1hour")  millisInTimeUnit = 3600*1000;
                            else if(timeUnit=="type2day")   millisInTimeUnit = 24*3600*1000;
                            else if(timeUnit=="type3week")  millisInTimeUnit = 7*24*3600*1000;
                            else if(timeUnit=="type4month") millisInTimeUnit = 31*24*3600*1000;

                            var unitsPerMilli = unitsPerTimeUnit/millisInTimeUnit/timeUnitCount;
                            var periodInMillis = totalUnits/unitsPerMilli;
                            var millisPerDay = 24*60*60*1000;
                            var periodInDays = Math.floor(periodInMillis/millisPerDay);

                            //alert("*** calculatePrescriptionPeriod ***\n\npackages : "+packages+"\nunitsPerPackage : "+unitsPerPackage+"\ntotalUnits : "+totalUnits+"\nunitsPerTimeUnit : "+unitsPerTimeUnit+"\ntimeUnitCount : "+timeUnitCount+"\ntimeUnit : "+timeUnit+"\n\nperiodInDays = "+periodInDays);///////////

                            <%-- calculate beginDate : subtract days from endDate --%>
                            if(beginDateStr.length==0){
                              var beginDateInMillis = makeDate(endDateStr).getTime()-(periodInDays*(24*3600*1000));
                              var beginDate = new Date();
                              beginDate.setTime(beginDateInMillis);

                              var day = beginDate.getDate();
                              if(day<10) day = "0"+day;

                              var month = beginDate.getMonth()+1;
                              if(month<10) month = "0"+month;

                              transactionForm.EditDateBegin.value = day+"/"+month+"/"+beginDate.getFullYear();
                            }
                            <%-- calculate endDate : add days to beginDate --%>
                            else{
                              var endDateInMillis = makeDate(beginDateStr).getTime()+(periodInDays*(24*3600*1000));
                              var endDate = new Date();
                              endDate.setTime(endDateInMillis);

                              var day = endDate.getDate();
                              if(day<10) day = "0"+day;

                              var month = endDate.getMonth()+1;
                              if(month<10) month = "0"+month;

                              transactionForm.EditDateEnd.value = day+"/"+month+"/"+endDate.getFullYear();
                            }
                          }
                        }
                      }

                      <%-- CALCULATE PACKAGES NEEDED --%>
                      function calculatePackagesNeeded(displayAlert){
                        if(transactionForm.UnitsPerPackage.value.length > 0 && transactionForm.UnitsPerPackage.value!="0"){
                          var dateBegin = transactionForm.EditDateBegin.value,
                              dateEnd   = transactionForm.EditDateEnd.value;

                          if(dateBegin.length>0 && dateEnd.length>0){
                            if(!isEndDateBeforeBeginDate()){
                              var unitsPerPackage  = transactionForm.UnitsPerPackage.value;
                              var unitsPerTimeUnit = transactionForm.EditUnitsPerTimeUnit.value;
                              var timeUnitCount    = transactionForm.EditTimeUnitCount.value;
                              var timeUnit         = transactionForm.EditTimeUnit.value;

                              if(unitsPerPackage.length>0 && unitsPerTimeUnit.length>0 && timeUnitCount.length>0 && timeUnit.length>0){
                                var beginDate = transactionForm.EditDateBegin.value,
                                    endDate   = transactionForm.EditDateEnd.value;
                                var periodInMillis = makeDate(endDate).getTime()-makeDate(beginDate).getTime();

                                var millisInTimeUnit;
                                     if(timeUnit=="type1hour")  millisInTimeUnit = 3600*1000;
                                else if(timeUnit=="type2day")   millisInTimeUnit = 24*3600*1000;
                                else if(timeUnit=="type3week")  millisInTimeUnit = 7*24*3600*1000;
                                else if(timeUnit=="type4month") millisInTimeUnit = 31*24*3600*1000;

                                var unitsPerMilli = unitsPerTimeUnit/millisInTimeUnit/timeUnitCount;
                                var daysInPeriod = periodInMillis/(24*3600*1000);
                                var unitsNeeded = periodInMillis*unitsPerMilli;
                                var packagesNeeded = Math.ceil(unitsNeeded/unitsPerPackage);

                                //alert("*** calculatePackagesNeeded ***\n\ndaysInPeriod : "+daysInPeriod+"\nunitsPerPackage : "+unitsPerPackage+"\nunitsPerTimeUnit : "+unitsPerTimeUnit+"\ntimeUnitCount : "+timeUnitCount+"\ntimeUnit : "+timeUnit+"\nunitsNeeded : "+unitsNeeded+"\n\npackagesNeeded : "+packagesNeeded);///////////

                                transactionForm.EditRequiredPackages.value = packagesNeeded;
                              }
                              else{
                                transactionForm.EditRequiredPackages.value = "";
                              }
                            }
                            else{
                              if(displayAlert==undefined){
                                displayAlert = true;
                              }

                              if(displayAlert==true){
                                alertDialog("web.Occup","endMustComeAfterBegin");
                                transactionForm.EditDateEnd.focus();
                              }

                              transactionForm.EditRequiredPackages.value = "";
                            }
                          }
                        }
                      }

                      <%-- DISPLAY END BEFORE BEGIN ALERT --%>
                      function displayEndBeforeBeginAlert(){
                        if(transactionForm.EditDateEnd.value.length>0){
                          alertDialog("web.Occup","endMustComeAfterBegin");
                        }
                      }

                      <%-- set editUnitsPerTimeUnitLabel --%>
                      function setEditUnitsPerTimeUnitLabel(productUid){
                        var unitTran = "";

                        if(transactionForm.EditProductUid.value.length==0){
                          unitTran = '<%=getTranNoLink("web","units",sWebLanguage)%>';
                        }
                        else{
                          <%
                              Vector unitTypes = ScreenHelper.getProductUnitTypes(sWebLanguage);
                              for(int i=0; i<unitTypes.size(); i++){
                                  %>
                                    var unitTran<%=(i+1)%> = "<%=getTranNoLink("product.unit",(String)unitTypes.get(i),sWebLanguage).toLowerCase()%>"
                                    if(transactionForm.ProductUnit.value=="<%=unitTypes.get(i)%>") unitTran = unitTran<%=(i+1)%>;
                                  <%
                              }
                          %>
                        }

                        if(unitTran.length==0){
                          openEditProductUnitPopup(productUid);
                        }
                        else{
                          document.getElementById("EditUnitsPerTimeUnitLabel").innerHTML = unitTran;
                        }
                      }

                      <%-- open edit product unit popup --%>
                      function openEditProductUnitPopup(productUid){
                        var url = "pharmacy/popups/editProductUnit.jsp"+
                                  "&EditProductUid="+productUid+
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
                        if(dateObj.value.length==10){
                          return checkDate(dateObj);
                        }
                        return false;
                      }

                      <%-- IS ENDDATE BEFORE BEGINDATE --%>
                      function isEndDateBeforeBeginDate(){
                        if(transactionForm.EditDateBegin.value.length > 0 && transactionForm.EditDateEnd.value.length > 0){
                          if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
                            var dateBegin = transactionForm.EditDateBegin.value,
                                dateEnd   = transactionForm.EditDateEnd.value;

                            return before(dateEnd,dateBegin);
                          }
                          return false;
                        }
                        return true;
                      }
                    </script>
                <%
            }

            //--- SEARCH RESULTS ------------------------------------------------------------------
            if(displayFoundRecords){
                if(foundPrescrCount > 0){
                    String sortTran = getTran("web","clicktosort",sWebLanguage);
                    %>
                        <%-- title --%>
                        <table width="100%" cellspacing="0">
                            <tr>
                                <td class="titleadmin">&nbsp;<%=getTran("Web.manage","PrescriptionsForActivepatient",sWebLanguage)%>&nbsp;<%=activePatient.lastname+" "+activePatient.firstname%></td>
                            </tr>
                        </table>
                        <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                            <%-- clickable header --%>
                            <tr class="admin">
                                <td width="22" nowrap>&nbsp;</td>
                                <td width="25%"><%=getTran("Web","prescriber",sWebLanguage)%></td>
                                <td width="20%"><%=getTran("Web","product",sWebLanguage)%></td>
                                <td width="10%"><%=getTran("Web","begindate",sWebLanguage)%></td>
                                <td width="10%"><%=getTran("Web","enddate",sWebLanguage)%></td>
                                <td width="35%"><%=getTran("Web","supplyingservice",sWebLanguage)%></td>
                            </tr>
                            <tbody class="hand">
                                <%=prescriptionsHtml%>
                            </tbody>
                        </table>
                        
                        <%-- number of records found --%>
                        <span style="width:49%;text-align:left;">
                            <%=foundPrescrCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
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
                        %>
                    <%
                }
                else{
                    %><%=getTran("web","norecordsfound",sWebLanguage)%><br><br><%
                }
            }

            //--- DISPLAY ACTIVE PRESCRIPTIONS (of activePatient) ---------------------------------
            if(displayActivePrescr && !sAction.equals("showDetails")){
                Vector activePrescrs = Prescription.findActive(sFindPatientUid,sFindPrescriberUid,sFindProductUid,sFindDateBegin,sFindDateEnd,sFindSupplyingServiceUid,sSortCol,sSortDir);
                prescriptionsHtml = activePrescriptionsToHtml(activePrescrs,sWebLanguage,activeUser);
                foundPrescrCount = activePrescrs.size();

                %>
                    <%-- sub title --%>
                    <table width="100%" cellspacing="0">
                        <tr>
                            <td class="titleadmin">&nbsp;<%=getTran("Web.manage","ActivePrescriptionsForActivepatient",sWebLanguage)%>&nbsp;<%=activePatient.lastname+" "+activePatient.firstname%></td>
                        </tr>
                    </table>
                <%

                if(foundPrescrCount > 0){
                    String sortTran = getTran("web","clicktosort",sWebLanguage);
                    %>
                        <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                            <%-- clickable header --%>
                            <tr class="admin">
                                <td width="22" nowrap>&nbsp;</td>
                                <td width="25%"><%=getTran("Web","prescriber",sWebLanguage)%></td>
                                <td width="20%"><%=getTran("Web","product",sWebLanguage)%></td>
                                <td width="10%"><%=getTran("Web","begindate",sWebLanguage)%></td>
                                <td width="10%"><%=getTran("Web","enddate",sWebLanguage)%></td>
                                <td width="35%"><%=getTran("Web","prescriptionrule",sWebLanguage)%></td>
                            </tr>

                            <tbody class="hand">
                                <%=prescriptionsHtml%>
                            </tbody>
                        </table>

                        <%-- number of records found --%>
                        <span style="width:49%;text-align:left;">
                            <%=foundPrescrCount%> <%=getTran("web","activeprescriptionsfound",sWebLanguage)%>
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
                        %>
                    <%
                }
                else{
                    // no active records found
                    %><%=getTran("web","noactiveprescriptionsfound",sWebLanguage)%><br><%
                }
            }
        }
    %>

    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditPrescrUid" value="<%=sEditPrescrUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
    <input type="hidden" name="DisplayActivePrescriptions" value="<%=displayActivePrescr%>">
    <input type="hidden" name="IsActivePrescr" value="<%=isActivePrescr%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditPrescriberFullName.focus();<%
      }

      if(displaySearchFields){
          %>transactionForm.FindPrescriberFullName.focus();<%
      }
  %>

  <%-- LOAD SCHEMA --%>
  function loadSchema(){
    if(document.getElementsByName("EditProductUid")[0]!=null){
      openPopup("/_common/search/updatePrescriptionSchema.jsp&productuid="+document.getElementsByName("EditProductUid")[0].value);
    }
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
      if(transactionForm.returnButton!=undefined) transactionForm.returnButton.disabled = true;
      if(transactionForm.saveButton!=undefined) transactionForm.saveButton.disabled = true;
      if(transactionForm.deleteButton!=undefined) transactionForm.deleteButton.disabled = true;
      if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;

      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
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
    if(!transactionForm.EditPrescriberUid.value.length==0 &&
       !transactionForm.EditProductUid.value.length==0 &&
       !transactionForm.EditTimeUnit.value.length==0 &&
       !transactionForm.EditDateBegin.value.length==0 &&
       !transactionForm.EditDateEnd.value.length==0 &&
       !transactionForm.UnitsPerPackage.value.length==0 &&
       !transactionForm.EditTimeUnitCount.value.length==0 &&
       !transactionForm.EditUnitsPerTimeUnit.value.length==0 &&
       !transactionForm.EditRequiredPackages.value.length==0){

       <%-- check dates --%>
       if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
         if(!isEndDateBeforeBeginDate()){
           maySubmit = true;
         }
         else{
           alertDialog("web.Occup","endMustComeAfterBegin");           
           transactionForm.EditDateEnd.focus();
         }
       }
    }
    else{
      maySubmit = false;
      alertDialog("web.manage","datamissing");
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(prescriptionUid){
	if(yesnoDialog("Web","areYouSureToDelete")){
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

        if(displaySearchFields){
            %>clearSearchFields();<%
        }
    %>

    if(transactionForm.searchButton!=undefined)  transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined)   transactionForm.clearButton.disabled = true;
    if(transactionForm.returnButton!=undefined)  transactionForm.returnButton.disabled = true;
    if(transactionForm.saveButton!=undefined)    transactionForm.saveButton.disabled = true;
    if(transactionForm.deleteButton!=undefined)  transactionForm.deleteButton.disabled = true;
    if(transactionForm.newButton!=undefined)     transactionForm.newButton.disabled = true;
    if(transactionForm.searchActivePrescrButton!=undefined) transactionForm.searchActivePrescrButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(prescriptionUid){
    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;
    if(transactionForm.searchActivePrescrButton!=undefined) transactionForm.searchActivePrescrButton.disabled = true;

    transactionForm.EditPrescrUid.value = prescriptionUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS ACTIVE PRESCR --%>
  function doShowDetailsActive(prescriptionUid){
    transactionForm.IsActivePrescr.value = "true";
    doShowDetails(prescriptionUid);
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindPrescriberUid.value = "";
    transactionForm.FindPrescriberFullName.value = "";

    transactionForm.FindProductUid.value = "";
    transactionForm.FindProductName.value = "";

    transactionForm.FindSupplyingServiceUid.value = "";
    transactionForm.FindSupplyingServiceName.value = "";

    transactionForm.FindDateBegin.value = "";
    transactionForm.FindDateEnd.value = "";
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

    if(transactionForm.SortDir.value=="ASC") transactionForm.SortDir.value = "DESC";
    else                                     transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- DO SEARCH --%>
  function doSearch(sortCol){
    if(transactionForm.FindPrescriberUid.value.length>0 ||
       transactionForm.FindProductUid.value.length>0 ||
       transactionForm.FindDateBegin.value.length>0 ||
       transactionForm.FindDateEnd.value.length>0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.newButton.disabled = true;
      transactionForm.searchActivePrescrButton.disabled = true;

      transactionForm.Action.value = "find";
      transactionForm.SortCol.value = sortCol;
      openSearchInProgressPopup();
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","datamissing");
    }
  }

  <%-- DO SEARCH IN ACTIVE PRESCRIPTIONS --%>
  function doSearchInActivePrescriptions(){
    transactionForm.DisplayActivePrescriptions.value = true;

    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;
    transactionForm.searchActivePrescrButton.disabled = true;

    transactionForm.submit();
  }

  <%-- DO DEFAULT PAGE LOAD --%>
  function doDefaultPageLoad(){
    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;
    transactionForm.searchActivePrescrButton.disabled = true;

    openSearchInProgressPopup();
    window.location.href = "<c:url value="/main.do"/>?Page=medical/managePrescriptions.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,
		                 unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
              "&loadschema=true&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search userProduct --%>
  function searchUserProduct(productUidField,productNameField,productUnitField,
		                     unitsPerTimeUnitField,unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "<%=sCONTEXTPATH%>/_common/search/searchUserProduct.jsp?ts=<%=getTs()%>"+
    		  "&loadschema=true"+
    		  "&ReturnProductUidField="+productUidField+
    		  "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search product in service stock --%>
  function searchProductInServiceStock(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,
		                               unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>"+
              "&loadschema=true"+
              "&DisplayProductsOfPatientService=true"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search supplying service --%>
  function searchSupplyingService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search service stock --%>
  function searchServiceStock(serviceStockUidField,serviceStockNameField){
	var url = "/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>"+
	          "&ReturnServiceStockUidField="+serviceStockUidField+
	          "&ReturnServiceStockNameField="+serviceStockNameField;
    openPopup(url);
  }

  <%-- popup : search prescriber --%>
  function searchPrescriber(prescriberUidField,prescriberNameField){
	var url = "/_common/search/searchUser.jsp&ts=<%=getTs()%>"+
	          "&ReturnUserID="+prescriberUidField+
	          "&ReturnName="+prescriberNameField+
	          "&displayImmatNew=no";
    openPopup(url);
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
          if(displayActivePrescr){
              %>
                transactionForm.DisplayActivePrescriptions.value = "true";
                transactionForm.Action.value = "";
              <%
          }
          else{
              %>
                transactionForm.DisplayActivePrescriptions.value = "false";
                transactionForm.Action.value = "find";
              <%
          }
      %>
      transactionForm.DisplaySearchFields.value = "true";
      transactionForm.submit();
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    if(document.getElementById("popuptbl")==null){
      window.location.href = "<c:url value="/main.do"/>?Page=medical/managePrescriptions.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
    }
    else{
      window.close();
    }
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>