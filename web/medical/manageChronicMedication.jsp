<%@page import="be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.medical.ChronicMedication,
                java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("chronicmedication","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sMedicationUid, sDateBeginFormatted = "", sProductName = "",
               sProductUid, sPreviousProductUid = "", sTimeUnit, sTimeUnitCount = "",
               sUnitsPerTimeUnit, timeUnitTran, sPrescrRule = "", sProductUnit, sPrescriberFullName = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
        java.util.Date tmpBeginDate;
        Product product = null;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
                deleteTran = getTranNoLink("Web","delete",sWebLanguage);

        // run thru found medication
        ChronicMedication medication;
        for(int i=0; i<objects.size(); i++){
            medication = (ChronicMedication)objects.get(i);
            sMedicationUid = medication.getUid();

            // format date begin
            tmpBeginDate = medication.getBegin();
            if(tmpBeginDate!=null) sDateBeginFormatted = stdDateFormat.format(tmpBeginDate);
            else                   sDateBeginFormatted = "";

            // only search product-name when different product-UID
            sProductUid = medication.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = Product.get(sProductUid);

                if(product!=null){
                    sProductName = product.getName();
                }
                else{
                    sProductName = "<font color='red'>"+getTran("web","nonExistingProduct",sWebLanguage)+"</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = medication.getTimeUnit();
            sTimeUnitCount = medication.getTimeUnitCount()+"";
            sUnitsPerTimeUnit = medication.getUnitsPerTimeUnit()+"";

            // only compose prescription-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));

                // productunit
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                } else {
                    sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunitCount
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
                } else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            // prescriber
            if (checkString(medication.getPrescriberUid()).length() > 0) {
               	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                sPrescriberFullName = ScreenHelper.getFullUserName(medication.getPrescriberUid(), ad_conn);
                try{
                	ad_conn.close();
                }
                catch(Exception e){
                	e.printStackTrace();
                }
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display medication in one row ***
            html.append("<tr class='list"+sClass+"'  title='"+detailsTran+"'>")
                 .append("<td align='center'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' alt='"+deleteTran+"' onclick=\"doDelete('"+sMedicationUid+"');\">")
                 .append("<td onclick=\"doShowDetails('"+sMedicationUid+"');\">"+sPrescriberFullName+"</td>")
                 .append("<td onclick=\"doShowDetails('"+sMedicationUid+"');\">"+sProductName+"</td>")
                 .append("<td onclick=\"doShowDetails('"+sMedicationUid+"');\">"+sDateBeginFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+sMedicationUid+"');\">"+sPrescrRule.toLowerCase()+"</td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortCol = "OC_CHRONICMED_BEGIN",
           sDefaultSortDir = "DESC";

    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "find";

    // retreive form data
    String sEditMedicationUid    = checkString(request.getParameter("EditMedicationUid")),
           sEditPrescriberUid    = checkString(request.getParameter("EditPrescriberUid")),
           sEditProductUid       = checkString(request.getParameter("EditProductUid")),
           sEditDateBegin        = checkString(request.getParameter("EditDateBegin")),
           sEditTimeUnit         = checkString(request.getParameter("EditTimeUnit")),
           sEditTimeUnitCount    = checkString(request.getParameter("EditTimeUnitCount")),
           sEditUnitsPerTimeUnit = checkString(request.getParameter("EditUnitsPerTimeUnit")),
           sEditComment          = checkString(request.getParameter("EditComment"));

    // afgeleide data
    String sEditPatientFullName    = checkString(request.getParameter("EditPatientFullName")),
           sEditPrescriberFullName = checkString(request.getParameter("EditPrescriberFullName")),
           sEditProductName        = checkString(request.getParameter("EditProductName")),
           sEditProductUnit        = checkString(request.getParameter("EditProductUnit"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** medical/manageChronicMedication.jsp ***************");
        Debug.println("sAction                 : "+sAction);
        Debug.println("sEditMedicationUid      : "+sEditMedicationUid);
        Debug.println("sEditPrescriberUid      : "+sEditPrescriberUid);
        Debug.println("sEditProductUid         : "+sEditProductUid);
        Debug.println("sEditProductUnit        : "+sEditProductUnit);
        Debug.println("sEditDateBegin          : "+sEditDateBegin);
        Debug.println("sEditTimeUnit           : "+sEditTimeUnit);
        Debug.println("sEditTimeUnitCount      : "+sEditTimeUnitCount);
        Debug.println("sEditUnitsPerTimeUnit   : "+sEditUnitsPerTimeUnit);
        Debug.println("sEditPatientFullName    : "+sEditPatientFullName);
        Debug.println("sEditPrescriberFullName : "+sEditPrescriberFullName);
        Debug.println("sEditProductName        : "+sEditProductName);
        Debug.println("sEditComment            : "+sEditComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sFindPatientUid, sFindPrescriberUid, sFindProductUid, sFindDateBegin,
           sSelectedPrescriberUid = "", sSelectedProductUid = "", sSelectedDateBegin = "",
           sSelectedTimeUnit = "", sSelectedTimeUnitCount = "", sSelectedUnitsPerTimeUnit = "",
           sSelectedProductUnit = "", sSelectedPrescriberFullName = "",
           sSelectedProductName = "", sSelectedComment = "";

    // only work with active user
    sFindPatientUid = activePatient.personid;

    // get data from form
    sFindPrescriberUid = checkString(request.getParameter("FindPrescriberUid"));
    sFindProductUid    = checkString(request.getParameter("FindProductUid"));
    sFindDateBegin     = checkString(request.getParameter("FindDateBegin"));

    // variables
    int foundMedicationCount = 0;
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
    StringBuffer medications = null;
    boolean patientIsHospitalized = activePatient.isHospitalized();

    // display options
    boolean displayEditFields = false, displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "false"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    Debug.println("@@@ displaySearchFields : "+displaySearchFields);

    // search medication written by active user by default
    if(sAction.length()==0){
        sFindPrescriberUid = activeUser.person.personid;
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
    if(sAction.equals("save") && sEditMedicationUid.length()>0){
        // create medication
        ChronicMedication medication = new ChronicMedication();
        medication.setUid(sEditMedicationUid);
        medication.setPatientUid(activePatient.personid);
        medication.setPrescriberUid(sEditPrescriberUid);
        medication.setProductUid(sEditProductUid);
        medication.setTimeUnit(sEditTimeUnit);
        medication.setComment(sEditComment);
        if(sEditDateBegin.length() > 0) medication.setBegin(ScreenHelper.parseDate(sEditDateBegin));
        if(sEditTimeUnitCount.length() > 0) medication.setTimeUnitCount(Integer.parseInt(sEditTimeUnitCount));
        if(sEditUnitsPerTimeUnit.length() > 0) medication.setUnitsPerTimeUnit(Double.parseDouble(sEditUnitsPerTimeUnit));
        medication.setUpdateUser(activeUser.userid);

        String existingMedicationUid = medication.exists();
        boolean medicationExists = existingMedicationUid.length()>0;

        if(sEditMedicationUid.equals("-1")){
            //***** insert new medication *****
            if(!medicationExists){
                medication.store(false);

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject new addition *****
            else{
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>"+getTran("web.manage","chronicmedicationexists",sWebLanguage)+"</font>";
            }
        }
        else{
            //***** update existing record *****
            if(!medicationExists){
                medication.store(false);

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject double record thru update *****
            else{
                if(sEditMedicationUid.equals(existingMedicationUid)){
                    // nothing : just updating a record with its own data
                    if(medication.changed()){
                        medication.store(false);
                        msg = getTran("web","dataissaved",sWebLanguage);
                    }
                    sAction = "findShowOverview"; // showDetails
                }
                else{
                    // tried to update one medication with exact the same data as an other medication
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>"+getTran("web.manage","chronicmedicationexists",sWebLanguage)+"</font>";
                }
            }
        }

        sEditMedicationUid = medication.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditMedicationUid.length()>0){
        ChronicMedication.delete(sEditMedicationUid);
        msg = getTran("web","dataisdeleted",sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if(sAction.equals("sort")){
        displayEditFields = false;
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        displaySearchFields = true;
        displayFoundRecords = true;
        displayEditFields = false;

        Vector chronicMedications = ChronicMedication.find(sFindPatientUid,sFindPrescriberUid,sFindProductUid,
                                                           sFindDateBegin,sSortCol,sSortDir);
        medications = objectsToHtml(chronicMedications,sWebLanguage);
        foundMedicationCount = chronicMedications.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ChronicMedication medication = ChronicMedication.get(sEditMedicationUid);

            if(medication!=null){
                sSelectedProductUid    = medication.getProductUid();
                sSelectedComment       = checkString(medication.getComment());

                // prescriber
                sSelectedPrescriberUid = ScreenHelper.checkDbString(medication.getPrescriberUid());
                if(sSelectedPrescriberUid.length() > 0){
                   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    sSelectedPrescriberFullName = ScreenHelper.getFullUserName(sSelectedPrescriberUid,ad_conn);
                    ad_conn.close();
                }

                // format begin date
                java.util.Date tmpDate = medication.getBegin();
                if(tmpDate!=null) sSelectedDateBegin = stdDateFormat.format(tmpDate);

                // prescription rule
                sSelectedTimeUnit         = medication.getTimeUnit();
                sSelectedTimeUnitCount    = (medication.getTimeUnitCount()<0?"":medication.getTimeUnitCount()+"");
                sSelectedUnitsPerTimeUnit = (medication.getUnitsPerTimeUnit()<0?"":medication.getUnitsPerTimeUnit()+"");

                // product
                Product product = medication.getProduct();
                if(product!=null){
                    sSelectedProductName = product.getName();
                    sSelectedProductUnit = product.getUnit();

                    if(sSelectedProductName.length()==0){
                        sSelectedProductName = getTran("web","nonexistingproduct",sWebLanguage);
                    }
                }
            }
        }
        else if(sAction.equals("showDetailsAfterAddReject")){
            // do not get data from DB, but show data that were allready on form
            sSelectedPrescriberUid    = sEditPrescriberUid;
            sSelectedProductUid       = sEditProductUid;
            sSelectedDateBegin        = sEditDateBegin;
            sSelectedTimeUnit         = sEditTimeUnit;
            sSelectedTimeUnitCount    = sEditTimeUnitCount;
            sSelectedUnitsPerTimeUnit = sEditUnitsPerTimeUnit;
            sSelectedComment          = sEditComment;

            // afgeleide data
            sSelectedPrescriberFullName = sEditPrescriberFullName;
            sSelectedProductName        = sEditProductName;
            sSelectedProductUnit        = sEditProductUnit;
        }
        else{
            // showDetailsNew : set default values
            sSelectedPrescriberUid      = activeUser.userid;
            sSelectedPrescriberFullName = activeUser.person.lastname+" "+activeUser.person.firstname;
            sSelectedDateBegin          = stdDateFormat.format(new java.util.Date());
            sSelectedTimeUnit           = "type2day";
            sSelectedTimeUnitCount      = "1";
        }
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown = "";
    if(!sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch('"+sDefaultSortCol+"');}\"";
    }
%>
<form name="transactionForm" method="post" <%=sOnKeyDown%> <%=(displaySearchFields?"onClick=\"clearMessage();\"":"onClick=\"clearMessage();\"")%>>
    <%
        // back-arrow only when applicable : in edit-screen
        if(displaySearchFields){
            %><%=writeTableHeader("Web.manage","ManageChronicMedication",sWebLanguage)%><%
        }
        else{
            %><%=writeTableHeader("Web.manage","ManageChronicMedication",sWebLanguage," doBack();")%><%
        }

        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        // see bottom of page

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            DecimalFormat doubleFormat = new DecimalFormat("#.#");
            
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- product --%>
                    <%
                        String onClick;
                        if(patientIsHospitalized){
                            onClick = "onclick=\"searchProductInServiceStock('EditProductUid','EditProductName','EditProductUnit','EditUnitsPerTimeUnit');\"";
                        }
                        else{
                            onClick = "onclick=\"searchProduct('EditProductUid','EditProductName','EditProductUnit','EditUnitsPerTimeUnit');\"";
                        }
                    %>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","product",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductUid" value="<%=sSelectedProductUid%>">
                            <input type="hidden" name="EditProductUnit" value="<%=sSelectedProductUnit%>">
                            <input class="text" type="text" name="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" <%=onClick%>>
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductName.value='';transactionForm.EditProductUid.value='';">
                        </td>
                    </tr>
                    
                    <%-- ***** prescription-rule ***** --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","prescriptionrule",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <%-- Units Per Time Unit --%>
                            <input type="text" class="text" style="vertical-align:-1px;" name="EditUnitsPerTimeUnit" value="<%=(sSelectedUnitsPerTimeUnit.length()>0?(doubleFormat.format(Double.parseDouble(sSelectedUnitsPerTimeUnit))).replaceAll(",","."):"")%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                            <span id="EditUnitsPerTimeUnitLabel"></span>

                            <%-- Time Unit Count --%>
                            &nbsp;<%=getTran("web","per",sWebLanguage)%>
                            <input type="text" class="text" style="vertical-align:-1px;" name="EditTimeUnitCount" value="<%=sSelectedTimeUnitCount%>" size="5" maxLength="5">

                            <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
                            <select class="text" name="EditTimeUnit" onChange="setEditUnitsPerTimeUnitLabel();setEditTimeUnitCount();" style="vertical-align:-3px;">
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
                            <input type="text" maxlength="10" class="text" name="EditDateBegin" value="<%=sSelectedDateBegin%>" size="12" onblur="if(!checkDate(this)){alertDialog('Web.Occup','date.error');this.value='';}">
                            <img name="popcal" class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_agenda.gif" alt="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="gfPop1.fPopCalendar(document.transactionForm.all['EditDateBegin']);return false;">
                            <img class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_compose.gif" alt="<%=getTranNoLink("Web","PutToday",sWebLanguage)%>" onclick="getToday(document.transactionForm.all['EditDateBegin']);">
                        </td>
                    </tr>
                    <%-- prescriber --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","prescriber",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="hidden" name="EditPrescriberUid" value="<%=sSelectedPrescriberUid%>">
                            <input class="text" type="text" name="EditPrescriberFullName" readonly size="<%=sTextWidth%>" value="<%=sSelectedPrescriberFullName%>">

                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrescriber('EditPrescriberUid','EditPrescriberFullName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditPrescriberUid.value='';transactionForm.EditPrescriberFullName.value='';">
                        </td>
                    </tr>
                    <%-- comment --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","comment",sWebLanguage)%></td>
                        <td class="admin2">
                            <textarea name="EditComment" cols="80" rows="2" onKeyup="resizeTextarea(this,10);limitLength(this);" class="text"><%=sSelectedComment%></textarea>
                        </td>
                    </tr>
                    
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin"/>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                    // existing medication : display saveButton with save-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                                        <input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditMedicationUid%>');">
                                        <input class="button" type="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();">
                                    <%
                                }
                                else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                    // new medication : display saveButton with add-label + do not display delete button
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
                <br><br>
                
                <script>
                  setEditUnitsPerTimeUnitLabel();

                  <%-- set editUnitsPerTimeUnitLabel --%>
                  function setEditUnitsPerTimeUnitLabel(){
                    var unitTran;

                    if(transactionForm.EditProductUid.value.length==0){
                      unitTran = '<%=getTranNoLink("web","units",sWebLanguage)%>';
                    }
                    else{
                      <%
                          Vector unitTypes = ScreenHelper.getProductUnitTypes(sWebLanguage);

                          for(int i=0; i<unitTypes.size(); i++){
                              %>
                                var unitTran<%=(i+1)%> = "<%=getTranNoLink("product.unit",(String)unitTypes.get(i),sWebLanguage).toLowerCase()%>"
                                if(transactionForm.EditProductUnit.value=="<%=unitTypes.get(i)%>") unitTran = unitTran<%=(i+1)%>;
                              <%
                          }
                      %>
                    }

                    document.getElementById("EditUnitsPerTimeUnitLabel").innerHTML = unitTran;
                  }

                  <%-- set setEditTimeUnitCount --%>
                  function setEditTimeUnitCount(){
                    if(transactionForm.EditTimeUnit.selectedIndex > 0){
                      if(transactionForm.EditTimeUnitCount.value.length == 0){
                        transactionForm.EditTimeUnitCount.value = "1";
                      }
                    }
                  }

                  <%-- clear description rule --%>
                  function clearDescriptionRule(){
                    transactionForm.EditUnitsPerTimeUnit.value = '';
                    transactionForm.EditTimeUnitCount.value = '';
                    transactionForm.EditTimeUnit.value = '';
                  }
                </script>
            <%
        }

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(displayFoundRecords){
            if(foundMedicationCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr>
                            <td class="admin" width="22" nowrap>&nbsp;</td>
                            <td class="admin" width="25%"><%=getTran("Web","prescriber",sWebLanguage)%></td>
                            <td class="admin" width="20%"><%=getTran("Web","productName",sWebLanguage)%></td>
                            <td class="admin" width="10%"><%=getTran("Web","begindate",sWebLanguage)%></td>
                            <td class="admin" width="45%"><%=getTran("Web","prescriptionrule",sWebLanguage)%></td>
                        </tr>
                        <tbody class="hand">
                            <%=medications%>
                        </tbody>
                    </table>
                    
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundMedicationCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    
                    <%
                        if(foundMedicationCount > 20){
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
                // no records found
                %>
                    <%=getTran("web","norecordsfound",sWebLanguage)%>
                    <br><br>
                <%
            }
        }

        //-- SEARCH FIELDS ------------------------------------------------------------------------
        if(displaySearchFields){
            %>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditMedicationUid" value="<%=sEditMedicationUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  if(document.getElementById("popuptbl")!=null){
    window.resizeTo(900,380);
    window.moveTo(self.screen.width/25,self.screen.height/7);
  }

  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditPrescriberFullName.focus();<%
      }
  %>

  <%-- DO ADD --%>
  function doAdd(){
    transactionForm.EditMedicationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkMedicationFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.returnButton.disabled = true;

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
    }
  }

  <%-- CHECK MEDICATION FIELDS --%>
  function checkMedicationFields(){
    var maySubmit = false;

    <%-- required fields --%>
    if(!transactionForm.EditProductUid.value.length==0 &&
       !transactionForm.EditDateBegin.value.length==0 &&
       !transactionForm.EditTimeUnit.value.length==0 &&
       !transactionForm.EditTimeUnitCount.value.length==0 &&
       !transactionForm.EditUnitsPerTimeUnit.value.length==0){
      if(transactionForm.EditPrescriberUid.value.length==0 && transactionForm.EditComment.value.length==0){
        alertDialog("web.manage","prescriberorcommentneeded");
        
             if(transactionForm.EditPrescriberUid.value.length==0) transactionForm.EditPrescriberFullName.focus();
        else if(transactionForm.EditComment.value.length==0)       transactionForm.EditComment.focus();

        maySubmit = false;
      }
      else{
        maySubmit = true;
      }
    }
    else{
      maySubmit = false;
      alertDialog("web.manage","datamissing");
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(medicationUid){
	if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.EditMedicationUid.value = medicationUid;
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

    if(transactionForm.clearButton!=undefined)  transactionForm.clearButton.disabled = true;
    if(transactionForm.returnButton!=undefined) transactionForm.returnButton.disabled = true;
    if(transactionForm.saveButton!=undefined)   transactionForm.saveButton.disabled = true;
    if(transactionForm.deleteButton!=undefined) transactionForm.deleteButton.disabled = true;
    if(transactionForm.newButton!=undefined)    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(medicationUid){
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined)   transactionForm.newButton.disabled = true;

    transactionForm.EditMedicationUid.value = medicationUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditPrescriberUid.value = "";
    transactionForm.EditPrescriberFullName.value = "";

    transactionForm.EditProductUid.value = "";
    transactionForm.EditProductName.value = "";

    transactionForm.EditDateBegin.value = "";
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

  <%-- DO SEARCH --%>
  function doSearch(sortCol){
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "find";
    transactionForm.SortCol.value = sortCol;
    openSearchInProgressPopup();
    transactionForm.submit();
  }

  <%-- popup : search prescriber --%>
  function searchPrescriber(prescriberUidField,prescriberNameField){
	var url = "/_common/search/searchUser.jsp&ts=<%=getTs()%>"+
	          "&ReturnUserID="+prescriberUidField+
	          "&ReturnName="+prescriberNameField+
	          "&displayImmatNew=no";
    openPopup(url);
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
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

    openPopup(url);
  }

  <%-- popup : search userProduct --%>
  function searchUserProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchUserProduct.jsp&ts=<%=getTs()%>"+
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

    openPopup(url);
  }

  <%-- popup : search product in service stock --%>
  function searchProductInServiceStock(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>"+
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
      transactionForm.Action.value = "";
      transactionForm.DisplaySearchFields.value = "false";
      transactionForm.submit();
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    if(document.getElementById("popuptbl") == null){
      window.location.href = "<c:url value="/main.do"/>?Page=medical/manageChronicMedication.jsp&ts=<%=getTs()%>";
    }
    else{
      window.close();
    }
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>