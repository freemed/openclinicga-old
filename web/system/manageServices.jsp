<%@page import="java.util.Enumeration,
                be.openclinic.pharmacy.ServiceStock,java.util.*,be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.manageservices","all",activeUser)%>

<%
    String sAction             = checkString(request.getParameter("Action")),
           sFindServiceCode    = checkString(request.getParameter("FindServiceCode")),
           sFindServiceText    = checkString(request.getParameter("FindServiceText")),
           sEditOldServiceCode = checkString(request.getParameter("EditOldServiceCode"));

    // DEBUG ////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n### mngServices #############################################");
        Debug.println("# sAction             : " + sAction);
        Debug.println("# sFindServiceCode    : " + sFindServiceCode);
        Debug.println("# sFindServiceText    : " + sFindServiceText);
        Debug.println("# sEditOldServiceCode : " + sEditOldServiceCode + "\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    String tmpLang;

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    // get all params starting with 'EditLabelValueXX', representing labels in different languages
    Hashtable labelValues = new Hashtable();
    Enumeration paramEnum = request.getParameterNames();
    String tmpParamName, tmpParamValue;

    if (sAction.equals("save")) {
        while (paramEnum.hasMoreElements()) {
            tmpParamName = (String) paramEnum.nextElement();

            if (tmpParamName.startsWith("EditLabelValue")) {
                tmpParamValue = request.getParameter(tmpParamName);
                labelValues.put(tmpParamName.substring(14), tmpParamValue); // language, value
            }
        }
    }
    else if (sAction.equals("edit")) {
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            labelValues.put(tmpLang, getTranDb("service", sFindServiceCode, tmpLang)); // language, value
        }
    }

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") && sEditOldServiceCode.length() > 0) {
        String sEditServiceCode = checkString(request.getParameter("EditServiceCode")),
                sEditServiceAddress = checkString(request.getParameter("EditServiceAddress")),
                sEditServiceCity = checkString(request.getParameter("EditServiceCity")),
                sEditServiceZipcode = checkString(request.getParameter("EditServiceZipcode")),
                sEditServiceCountry = checkString(request.getParameter("EditServiceCountry")),
                sEditServiceTelephone = checkString(request.getParameter("EditServiceTelephone")),
                sEditServiceFax = checkString(request.getParameter("EditServiceFax")),
                sEditServiceComment = checkString(request.getParameter("EditServiceComment")),
                sEditServiceEmail = checkString(request.getParameter("EditServiceEmail")),
                sEditServiceParentID = checkString(request.getParameter("EditServiceParentCode")),
                sEditServiceInscode = checkString(request.getParameter("EditServiceInscode")),
                sEditServiceShowOrder = checkString(request.getParameter("EditServiceShowOrder")),
                sEditServiceLanguage = checkString(request.getParameter("EditServiceLanguage")),
                sEditServiceContract = checkString(request.getParameter("EditServiceContract")),
                sEditServiceContractType = checkString(request.getParameter("EditServiceContractType")),
                sEditServiceContactPerson = checkString(request.getParameter("EditServiceContactPerson")),
                sEditServiceContractDate = checkString(request.getParameter("EditServiceContractDate")),
                sEditServiceDefaultContext = checkString(request.getParameter("EditServiceDefaultContext")),
                sEditDefaultServiceStockUid = checkString(request.getParameter("EditDefaultServiceStockUid")),
                sEditTotalBeds = checkString(request.getParameter("EditTotalBeds")),
                sEditServiceWicket = checkString(request.getParameter("EditServiceWicket")),
                sEditServiceCostcenter = checkString(request.getParameter("EditServiceCostcenter")),
                sEditServiceAcceptsVisits = checkString(request.getParameter("EditServiceAcceptsVisits")),
                sEditCareProvider = checkString(request.getParameter("EditCareProvider")),
                sEditStayPrestationUid = checkString(request.getParameter("EditStayPrestationUid")),
                sEditServiceInactive =checkString(request.getParameter("EditServiceInactive"));

        // codes
        String //sEditServiceCode1 = checkString(request.getParameter("EditServiceCode1")),
                //sEditServiceCode2 = checkString(request.getParameter("EditServiceCode2")),
                sEditServiceCode3 = checkString(request.getParameter("EditServiceCode3")), // NACE
                //sEditServiceCode4 = checkString(request.getParameter("EditServiceCode4")),
                sEditServiceCode5 = checkString(request.getParameter("EditServiceCode5"));

        // contact data ('post-adres')
        String sEditContactAddress = checkString(request.getParameter("EditContactAddress")),
                sEditContactZipcode = checkString(request.getParameter("EditContactZipcode")),
                sEditContactCity = checkString(request.getParameter("EditContactCity")),
                sEditContactCountry = checkString(request.getParameter("EditContactCountry")),
                sEditContactTelephone = checkString(request.getParameter("EditContactTelephone")),
                sEditContactFax = checkString(request.getParameter("EditContactFax")),
                sEditContactEmail = checkString(request.getParameter("EditContactEmail"));

        boolean isExternalService = Service.isExternalService(sEditServiceCode);

        // new
        if (sEditOldServiceCode.equals("-1")) {
            //*** INSERT SERVICE ******************************************************************
            Hashtable hServiceInfo = new Hashtable();
            hServiceInfo.put("serviceid",sEditServiceCode.toUpperCase());
            hServiceInfo.put("address",sEditServiceAddress);
            hServiceInfo.put("city",sEditServiceCity);
            hServiceInfo.put("zipcode",sEditServiceZipcode);
            hServiceInfo.put("country",sEditServiceCountry);
            hServiceInfo.put("telephone",sEditServiceTelephone);
            hServiceInfo.put("fax",sEditServiceFax);
            hServiceInfo.put("comment",sEditServiceComment);
            hServiceInfo.put("updatetime",getSQLTime());
            hServiceInfo.put("email",sEditServiceEmail);
            hServiceInfo.put("serviceparentid",sEditServiceParentID);
            hServiceInfo.put("inscode",sEditServiceInscode);
            hServiceInfo.put("serviceorder",sEditServiceShowOrder);
            hServiceInfo.put("servicelanguage",sEditServiceLanguage);
            hServiceInfo.put("updateuserid",activeUser.userid);
            hServiceInfo.put("contract",sEditServiceContract);
            hServiceInfo.put("contracttype",sEditServiceContractType);
            hServiceInfo.put("contactperson",sEditServiceContactPerson);
            hServiceInfo.put("contractdate",sEditServiceContractDate);
            hServiceInfo.put("defaultcontext",sEditServiceDefaultContext);
            hServiceInfo.put("defaultservicestockuid",sEditDefaultServiceStockUid);
            hServiceInfo.put("contactaddress",sEditContactAddress);
            hServiceInfo.put("contactzipcode",sEditContactZipcode);
            hServiceInfo.put("contactcity",sEditContactCity);
            hServiceInfo.put("contactcountry",sEditContactCountry);
            hServiceInfo.put("contacttelephone",sEditContactTelephone);
            hServiceInfo.put("contactfax",sEditContactFax);
            hServiceInfo.put("contactemail",sEditContactEmail);
            hServiceInfo.put("costcenter",sEditServiceCostcenter);
            hServiceInfo.put("performeruid",sEditCareProvider);
            hServiceInfo.put("stayprestationuid",sEditStayPrestationUid);
            try{
                hServiceInfo.put("totalbeds",new Integer(sEditTotalBeds));
            }
            catch(Exception a){
                hServiceInfo.put("totalbeds",new Integer(0));
            }
            // codes
            hServiceInfo.put("code3",sEditServiceCode3);
            hServiceInfo.put("code5",sEditServiceCode5);
            if (sEditServiceWicket.equals("on")) {
                hServiceInfo.put("wicket",new Integer(1));
            } else {
                hServiceInfo.put("wicket",new Integer(0));
            }
            if (sEditServiceAcceptsVisits.equals("on")) {
                hServiceInfo.put("acceptsVisits",new Integer(1));
            } else {
                hServiceInfo.put("acceptsVisits",new Integer(0));
            }
            if (sEditServiceInactive.equals("on")) {
                hServiceInfo.put("inactive",new Integer(1));
            } else {
                hServiceInfo.put("inactive",new Integer(0));
            }

            Service.manageServiceSave(hServiceInfo);

            Label objLabel;
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                objLabel = new Label();
                objLabel.type = "Service";
                objLabel.id = sEditServiceCode;
                objLabel.language = tmpLang;
                objLabel.value = checkString((String) labelValues.get(tmpLang));
                objLabel.showLink = "0";
                objLabel.updateUserId = activeUser.userid;

                objLabel.saveToDB();

                if(isExternalService){
                    MedwanQuery.getInstance().removeLabelFromCache("externalService", sEditServiceCode, tmpLang);
                    MedwanQuery.getInstance().getLabel("externalService", sEditServiceCode, tmpLang);
                }
                else{
                    MedwanQuery.getInstance().removeLabelFromCache("service", sEditServiceCode, tmpLang);
                    MedwanQuery.getInstance().getLabel("service", sEditServiceCode, tmpLang);
                }
            }
        }
        //*** UPDATE SERVICE **********************************************************************
        else {
            Hashtable hServiceInfo = new Hashtable();
            hServiceInfo.put("serviceid",sEditServiceCode);
            hServiceInfo.put("address",sEditServiceAddress);
            hServiceInfo.put("city",sEditServiceCity);
            hServiceInfo.put("zipcode",sEditServiceZipcode);
            hServiceInfo.put("country",sEditServiceCountry);
            hServiceInfo.put("telephone",sEditServiceTelephone);
            hServiceInfo.put("fax",sEditServiceFax);
            hServiceInfo.put("comment",sEditServiceComment);
            hServiceInfo.put("updatetime",getSQLTime());
            hServiceInfo.put("email",sEditServiceEmail);
            hServiceInfo.put("serviceparentid",sEditServiceParentID);
            hServiceInfo.put("inscode",sEditServiceInscode);
            hServiceInfo.put("serviceorder",sEditServiceShowOrder);
            hServiceInfo.put("servicelanguage",sEditServiceLanguage);
            hServiceInfo.put("updateuserid",activeUser.userid);
            hServiceInfo.put("contract",sEditServiceContract);
            hServiceInfo.put("contracttype",sEditServiceContractType);
            hServiceInfo.put("contactperson",sEditServiceContactPerson);
            hServiceInfo.put("contractdate",sEditServiceContractDate);
            hServiceInfo.put("defaultcontext",sEditServiceDefaultContext);
            hServiceInfo.put("defaultservicestockuid",sEditDefaultServiceStockUid);

            hServiceInfo.put("contactaddress",sEditContactAddress);
            hServiceInfo.put("contactzipcode",sEditContactZipcode);
            hServiceInfo.put("contactcity",sEditContactCity);
            hServiceInfo.put("contactcountry",sEditContactCountry);
            hServiceInfo.put("contacttelephone",sEditContactTelephone);
            hServiceInfo.put("contactfax",sEditContactFax);
            hServiceInfo.put("contactemail",sEditContactEmail);
            hServiceInfo.put("totalbeds",sEditTotalBeds);
            hServiceInfo.put("costcenter",sEditServiceCostcenter);
            hServiceInfo.put("performeruid",sEditCareProvider);
            hServiceInfo.put("stayprestationuid",sEditStayPrestationUid);

            hServiceInfo.put("code3",sEditServiceCode3);// NACE
            hServiceInfo.put("code5",sEditServiceCode5);// MED CENTRE
            if (sEditServiceAcceptsVisits.equals("on")) {
                hServiceInfo.put("acceptsVisits",new Integer(1));
            } else {
                hServiceInfo.put("acceptsVisits",new Integer(0));
            }
            if (sEditServiceWicket.equals("on")) {
                hServiceInfo.put("wicket",new Integer(1));
            } else {
                hServiceInfo.put("wicket",new Integer(0));
            }
            if (sEditServiceInactive.equals("on")) {
                hServiceInfo.put("inactive",new Integer(1));
            } else {
                hServiceInfo.put("inactive",new Integer(0));
            }
            hServiceInfo.put("oldserviceid",sEditOldServiceCode);

            Service.manageServiceUpdate(hServiceInfo);

            //***** update labels for all supported languages *****

            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            Label objLabel;
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                objLabel = new Label();
                objLabel.type = "Service";
                objLabel.id = sEditServiceCode;
                objLabel.language = tmpLang;
                objLabel.value = checkString((String) labelValues.get(tmpLang));
                objLabel.showLink = "0";
                objLabel.updateUserId = activeUser.userid;

                objLabel.saveToDB();

                MedwanQuery.getInstance().removeLabelFromCache("service", sEditServiceCode, tmpLang);
                MedwanQuery.getInstance().getLabel("service", sEditServiceCode, tmpLang);
            }
        }

        reloadSingleton(session);

        sFindServiceCode = sEditServiceCode;
        if (sFindServiceCode.length() > 0) {
            sFindServiceText = getTranNoLink("service", sEditServiceCode, sWebLanguage);
        }
        MedwanQuery.getInstance().removeServiceExaminations(sEditServiceCode);
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete")) {
        //*** delete service **********************************************************************
        try {
            if (sFindServiceCode.length() > 0) {
                Service service = Service.getService(sFindServiceCode);
                if (service != null) {
                  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    service.delete(ad_conn);
                    ad_conn.close();
                    MedwanQuery.getInstance().removeServiceExaminations(sFindServiceCode);
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        //*** delete label ************************************************************************
        try {
            if (sFindServiceCode.length() > 0) {
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                while (tokenizer.hasMoreTokens()) {
                    tmpLang = tokenizer.nextToken();
                    Label.delete("service", sFindServiceCode, tmpLang);
                }
                labelValues = new Hashtable();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        sAction = "";
        sFindServiceCode = "";
        sFindServiceText = "";
    }
%>
<%=sJSEMAIL%>
<form name="transactionForm" id="transactionForm" method="post">
<input type="hidden" name="Action">
<%-- SEARCH FIELDS ------------------------------------------------------------------------------%>
<%
    // only display header when not editing the data
    if(sAction.equals("") || sAction.equals("save")){
        %>
            <%=writeTableHeader("Web.manage","ManageServices",sWebLanguage," doBackToMenu();")%>

            <table width="100%" class="menu" cellspacing="0">
                <tr>
                    <td class="menu">
                        &nbsp;<%=getTran("Web","Unit",sWebLanguage)%>
                        <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">
                        <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('FindServiceCode','FindServiceText');">
                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceCode.value='';transactionForm.FindServiceText.value='';">
                        <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;
                        <%-- BUTTONS --%>
                        <input type="button" class="button" name="editButton" value="<%=getTranNoLink("Web","Edit",sWebLanguage)%>" onclick="doEdit(transactionForm.FindServiceCode.value);">
                        <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields();">
                        <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                        <input type="button" class="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete(transactionForm.FindServiceCode.value);">
                        <input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" OnClick="doBackToMenu();">
                    </td>
                </tr>
            </table>
        <%
    }
%>

<script>
  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField+"&SearchExternalServices=true&SearchInternalServices=true");
  }

  <%-- DO EDIT --%>
  function doEdit(serviceId){
    if(serviceId.length > 0){
      transactionForm.Action.value = "edit";
      transactionForm.submit();
    }
  }

  <%-- DO DELETE --%>
  function doDelete(serviceId){
    if(serviceId.length > 0){
      if(yesnoDialog("Web","areYouSureToDelete")){
        transactionForm.Action.value = "delete";
        transactionForm.submit();
      }
    }
  }

  <%-- DO BACK --%>
  function doBackToMenu(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/manageServices.jsp";
  }

  <%-- DO NEW --%>
  function doNew(){
    clearFields();

    transactionForm.Action.value = "new";
    transactionForm.submit();
  }

  <%-- CLEAR FIELDS --%>
  function clearFields() {
    transactionForm.FindServiceCode.value = "";
    transactionForm.FindServiceText.value = "";
  }
</script>
<%
    if(sAction.equals("new")){
        sFindServiceCode = "-1";
        sAction = "edit";
    }

    //--- DISPLAY SPECIFIED SERVICE ---------------------------------------------------------------
    if(sAction.equals("edit") && sFindServiceCode.length() > 0){
        String sServiceParentCodeText = "", sServiceCountryText = "", sContactCountryText = "";
        Label label = new Label();
        Service service;

        service = Service.getService(sFindServiceCode);
        if(service!=null){
            // translate
                if(service.parentcode.trim().length()>0) {
                    sServiceParentCodeText = getTran("service",service.parentcode,sWebLanguage);
                }
                if(service.country.trim().length()>0) {
                    sServiceCountryText = getTran("Country",service.country,sWebLanguage);
                }
                if(service.contactcountry.trim().length()>0) {
                    sContactCountryText = getTran("Country",service.contactcountry,sWebLanguage);
                }
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
            Label objLabel;
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                objLabel = new Label();
                Label.get("service",service.code,tmpLang);
                service.labels.add(objLabel);
                service.labels.add(label);
            }
        }else{
            service = new Service();
        }
        %>
            <input type="hidden" name="EditOldServiceCode" value="<%=sFindServiceCode%>">
            <%-- page title --%>
            <%=writeTableHeader("Web.manage","ManageServices",sWebLanguage," doBackToMenu();")%>
            <%-- SERVICE DETAILS ----------------------------------------------------------------%>
            <table width="100%" class="list" cellspacing="1">
                <%-- Service --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"> <%=getTran("Web.Manage.Service","ID",sWebLanguage)%> *</td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceCode" value="<%=service.code%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- ParentID --%>
                <tr>
                    <td class="admin"> <%=getTran("Web.Manage.Service","ParentID",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text readonly class="text" name="EditServiceParentCode" value="<%=service.parentcode%>"> <input type="text" readonly class="text" name="EditServiceParentText" value="<%=sServiceParentCodeText%>" size="<%=sTextWidth%>">
                        <%=ScreenHelper.writeServiceButton("buttonService","EditServiceParentCode","EditServiceParentText",sWebLanguage,sCONTEXTPATH)%>
                    </td>
                </tr>
                <%-- ShowOrder --%>
                <tr>
                    <td class="admin"> <%=getTran("Web.manage.Service","ShowOrder",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceShowOrder" value="<%=service.showOrder%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Language --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Language",sWebLanguage)%></td>
                    <td class="admin2">
                        <select name="EditServiceLanguage" select-one class="text">
                            <%
                                StringTokenizer stokenizer = new StringTokenizer(supportedLanguages,",");
                                while(stokenizer.hasMoreTokens()){
                                    tmpLang = stokenizer.nextToken();

                                    %><option value='<%=tmpLang%>' <%=(service.language.equalsIgnoreCase(tmpLang)?"SELECTED":"")%>><%=getTran("Web.Language",tmpLang,sWebLanguage)%></option><%
                                }
                            %>
                        </select>
                    </td>
                </tr>
                <%-- Inscode --%>
                <tr>
                    <td class="admin"> <%=getTran("Web.Manage.Service","Inscode",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceInscode" value="<%=service.inscode%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%
                    // display input field for each of the supported languages
                    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                    while(tokenizer.hasMoreTokens()){
                        tmpLang = tokenizer.nextToken();

                        %>
                            <tr>
                                <td class="admin"> <%=getTran("Web","Description",sWebLanguage)%> <%=tmpLang%> *</td>
                                <td class="admin2">
                                    <input type="text" class="text" name="EditLabelValue<%=tmpLang%>" value="<%=checkString((String)labelValues.get(tmpLang))%>" size="<%=sTextWidth%>">
                                </td>
                            </tr>
                        <%
                    }
                %>
                <%-- Address --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Address",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceAddress" value="<%=service.address%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Zipcode --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Zipcode",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceZipcode" value="<%=service.zipcode%>" size="<%=sTextWidth%>" onblur="limitLength(this);findZipcodeLanguageSpecified(EditServiceZipcode,EditServiceCity,'buttonServiceZipcode','<%=service.language%>');">
                        <%=ScreenHelper.writeZipcodeButton("buttonServiceZipcode","EditServiceZipcode","EditServiceCity",sWebLanguage,service.language,sCONTEXTPATH)%>
                    </td>
                </tr>
                <%-- City --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","City",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceCity" value="<%=service.city%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Country --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Country",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" readonly class="text" name="EditServiceCountryText" value="<%=sServiceCountryText%>" size="<%=sTextWidth%>">
                        <%=ScreenHelper.writeSearchButton("buttonCountry","Country", "EditServiceCountry", "EditServiceCountryText", "",sWebLanguage,sCONTEXTPATH)%>
                        <input type="hidden" name="EditServiceCountry" value="<%=service.country%>">
                    </td>
                </tr>
                <%-- Telephone --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Telephone",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceTelephone" value="<%=service.telephone%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Fax --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Fax",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceFax" value="<%=service.fax%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Email --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Email",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceEmail" value="<%=service.email%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- contract --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","contract",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceContract" value="<%=service.contract%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- contracttype --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","contracttype",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceContractType" value="<%=service.contracttype%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- contractdate --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","contractdate",sWebLanguage)%></td>
                    <td class="admin2"><%=writeDateField("EditServiceContractDate","transactionForm",checkString(service.contractdate),sWebLanguage)%></td>
                </tr>
                <%-- contactperson --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","contactperson",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceContactPerson" value="<%=service.contactperson%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- NACE (code3) --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","nacecode",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceCode3" value="<%=service.code3%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- Total beds --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","totalbeds",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditTotalBeds" value="<%=service.totalbeds%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- MEDICAL CENTRE (code5) --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","medicalcentre",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceCode5" value="<%=service.code5%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <tr>
                    <td class="admin"> <%=getTran("Web","stayprestation",sWebLanguage)%></td>
                    <td class="admin2">
		                <select class="text" name="EditStayPrestationUid" style="vertical-align:top;">
		                	<option value=''></option>
		                    <%
		                        Vector prestations = Prestation.getPrestationsByClass("stay");
		                        for (int n=0;n<prestations.size();n++){
		                            Prestation prestation = (Prestation)prestations.elementAt(n);
		                            if(prestation!=null){
		                                out.println("<option value='"+prestation.getUid()+"' "+(checkString(service.stayprestationuid).equalsIgnoreCase(prestation.getUid())?"selected":"")+">"+prestation.getCode()+": "+prestation.getDescription()+"</option>");
		                            }
		                        }
		                    %>
		                </select>
                    </td>
                </tr>
                
	            <tr>
		            <td class='admin'><%=getTran("web","invoicingcareprovider",sWebLanguage)%></td>
		            <td class='admin2'>
		            	<select class='text' name='EditCareProvider' id='EditCareProvider'>
		            		<option value=''></option>
				            <%
				            	Vector users = UserParameter.getUserIds("invoicingcareprovider", "on");
				            	SortedMap usernames = new TreeMap();
				            	for(int n=0;n<users.size();n++){
				            		User user = User.get(Integer.parseInt((String)users.elementAt(n)));
				            		usernames.put(user.person.lastname.toUpperCase()+", "+user.person.firstname,user.userid);
				            	}
			            		String sSelectedValue=checkString(service.performeruid);
				            	Iterator i = usernames.keySet().iterator();
				            	while(i.hasNext()){
				            		String username=(String)i.next();
				            		out.println("<option value='"+usernames.get(username)+"'"+(sSelectedValue.equals(usernames.get(username))?" selected":"")+">"+username+"</option>");
				            	}
				            %>
		            	</select>
		            </td>
		        </tr>
                
                <%-- Costcenter --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","costcenter",sWebLanguage)%></td>
                    <td class="admin2">
                    	<select name="EditServiceCostcenter" class="text">
                    	<option value=''/>
                    	<%=ScreenHelper.writeSelect("costcenter",checkString(service.costcenter),sWebLanguage,false,true) %>
                    	</select>
                    </td>
                </tr>
                <%--- for internal services only (exclude external services) --------------------%>
                <%
                    if(!Service.isExternalService(service.code)){
                        %>
                            <%-- DEFAULT CONTEXT --%>
                            <tr>
                                <td class="admin"> <%=getTran("Web","defaultcontext",sWebLanguage)%></td>
                                <td class="admin2">
                                    <select name="EditServiceDefaultContext" select-one class="text">
                                        <option value="">
                                        <%
                                            // list possible contexts from XML-file
                                            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"contexts.xml";
                                            if (sDoc.length()>0){
                                                SAXReader reader = new SAXReader(false);
                                                Document document = reader.read(new URL(sDoc));
                                                Iterator elements = document.getRootElement().elementIterator("context");

                                                Element element;
                                                while (elements.hasNext()){
                                                    element = (Element)elements.next();
                                                    out.println("<option value='"+element.attribute("id").getValue()+"' "+(element.attribute("id").getValue().equalsIgnoreCase(service.defaultContext)?"selected":"")+"/>"+getTran("Web.Occup",element.attribute("id").getValue(),sWebLanguage));
                                                }
                                            }
                                        %>
                                    </select>
                                </td>
                            </tr>
                            <%-- Default ServiceStock --%>
                            <%
                                String serviceStockName = "";
                                if(service.defaultServiceStockUid.length() > 0){
                                    ServiceStock serviceStock = ServiceStock.get(service.defaultServiceStockUid);
                                    if(serviceStock!=null){
                                        serviceStockName = serviceStock.getName();
                                    }
                                }
                            %>
                            <tr>
                                <td class="admin" nowrap><%=getTran("Web","defaultServiceStock",sWebLanguage)%>&nbsp;</td>
                                <td class="admin2">
                                    <input type="hidden" name="EditDefaultServiceStockUid" value="<%=service.defaultServiceStockUid%>">
                                    <input class="text" type="text" name="EditDefaultServiceStockName" readonly size="<%=sTextWidth%>" value="<%=serviceStockName%>">

                                    <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('EditDefaultServiceStockUid','EditDefaultServiceStockName');">
                                    <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDefaultServiceStockUid.value='';transactionForm.EditDefaultServiceStockName.value='';">
                                </td>
                            </tr>
                        <%
                    }
                %>
                <%-- WICKET --%>
                <%
                    String sChecked = "";

                    if(service.wicket.equals("1")){
                        sChecked = " checked";
                    }
                %>
                <tr>
                    <td class="admin"><%=getTran("web","wicket",sWebLanguage)%></td>
                    <td class="admin2">
                        <input class="text" type="checkbox" name="EditServiceWicket" <%=sChecked%>/>
                    </td>
                </tr>
                <%
	                sChecked = "";
                    if(checkString(service.acceptsVisits).equals("1")){
                        sChecked = " checked";
                    }
                %>
                <tr>
                    <td class="admin"> <%=getTran("Web","acceptsvisits",sWebLanguage)%></td>
                    <td class="admin2">
                        <input class="text" type="checkbox" name="EditServiceAcceptsVisits" <%=sChecked%>/>
                    </td>
                </tr>
                <%-- INACTIVE --%>
                <%
                    sChecked = "";
                    if(service.inactive.equals("1")){
                        sChecked = " checked";
                    }
                %>
                <tr>
                    <td class="admin"><%=getTran("web","inactive",sWebLanguage)%></td>
                    <td class="admin2">
                        <input class="text" type="checkbox" name="EditServiceInactive" <%=sChecked%>/>
                    </td>
                </tr>
                <%-- COMMENT --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Comment",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditServiceComment" value="<%=service.comment%>" size="<%=sTextWidth%>">
                        <BR/><%=getTran("web","noexams",sWebLanguage) %>
                    </td>
                </tr>
                <%-- spacer --%>
                <tr><td colspan="2">&nbsp;</td></tr>

                <%-- contact-section ------------------------------------------------------------%>
                <tr>
                    <td colspan="2" class="admin" height="22"><%=getTran("web","service.contactaddress",sWebLanguage)%></td>
                </tr>
                <%-- ContactAddress --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","address",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactAddress" value="<%=service.contactaddress%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                    </td>
                </tr>
                <%-- ContactZipcode --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","zipcode",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactZipcode" value="<%=service.contactzipcode%>" size="<%=sTextWidth%>" onblur="limitLength(this);findZipcodeLanguageSpecified(EditContactZipcode,EditContactCity,'buttonContactZipcode','<%=service.language%>');">
                        <%=ScreenHelper.writeZipcodeButton("buttonContactZipcode","EditContactZipcode","EditContactCity",sWebLanguage,service.language,sCONTEXTPATH)%>
                    </td>
                </tr>
                <%-- ContactCity --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","city",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactCity" value="<%=service.contactcity%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                    </td>
                </tr>
                <%-- ContactCountry --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","Country",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" readonly class="text" name="EditContactCountryText" value="<%=sContactCountryText%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                        <%=ScreenHelper.writeSearchButton("buttonContactCountry", "Country", "EditContactCountry", "EditContactCountryText", "",sWebLanguage,sCONTEXTPATH)%>
                        <input type="hidden" name="EditContactCountry" value="<%=service.contactcountry%>">
                    </td>
                </tr>
                <%-- ContactTelephone --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","telephone",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactTelephone" value="<%=service.contacttelephone%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                    </td>
                </tr>
                <%-- ContactFax --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","fax",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactFax" value="<%=service.contactfax%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                    </td>
                </tr>
                <%-- ContactEmail --%>
                <tr>
                    <td class="admin"> <%=getTran("Web","email",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditContactEmail" value="<%=service.contactemail%>" size="<%=sTextWidth%>" onblur="limitLength(this);">
                    </td>
                </tr>
            </table>
            <%-- indication of obligated fields --%>
            <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%-- EDIT BUTTONS --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","Save",sWebLanguage)%>' onclick="doSave();">
                <input type="button" class="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete(transactionForm.EditServiceCode.value);">
                <input class="button" type="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' OnClick='doBack();'>
            <%=ScreenHelper.alignButtonsStop()%>
            <script>
              transactionForm.EditServiceCode.focus();

              <%-- DO SAVE --%>
              function doSave(){
                var maySubmit = true;

                if(maySubmit){
                  <%-- check for valid email --%>
                  if(transactionForm.EditServiceEmail.value.length > 0){
                    if(!validEmailAddress(transactionForm.EditServiceEmail.value)){
                      maySubmit = false;

                      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=invalidemailaddress";
                      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","invalidemailaddress",sWebLanguage)%>");

                      transactionForm.EditServiceEmail.focus();
                    }
                  }
                }

                if(maySubmit){
                  <%-- check for valid contact-email --%>
                  if(transactionForm.EditContactEmail.value.length > 0){
                    if(!validEmailAddress(transactionForm.EditContactEmail.value)){
                      maySubmit = false;

                      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=invalidemailaddress";
                      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","invalidemailaddress",sWebLanguage)%>");

                      transactionForm.EditContactEmail.focus();
                    }
                  }
                }

                if(maySubmit){
                  if(transactionForm.EditServiceCode.value.length>0){
                    var allLabelsHaveAValue = true;
                    var emptyLabelField = "";

                    <%
                        tokenizer = new StringTokenizer(supportedLanguages,",");
                        while(tokenizer.hasMoreTokens()){
                            tmpLang = tokenizer.nextToken();

                            %>
                                transactionForm.EditLabelValue<%=tmpLang%>.value = trim(transactionForm.EditLabelValue<%=tmpLang%>.value);

                                if(allLabelsHaveAValue){
                                  if(transactionForm.EditLabelValue<%=tmpLang%>.value.length == 0){
                                    allLabelsHaveAValue = false;
                                    emptyLabelField = transactionForm.EditLabelValue<%=tmpLang%>;
                                  }
                                }
                            <%
                        }
                    %>

                    if(allLabelsHaveAValue){
                      transactionForm.saveButton.disabled = true;
                      transactionForm.Action.value = "save";
                      transactionForm.submit();
                    }
                    else{
                        alertDialog("web.manage","datamissing");
                        emptyLabelField.focus();
                    }
                  }
                  else{
                    alertDialog("web.manage","datamissing");
                    
                    if(transactionForm.EditServiceCode.value.length == 0){
                      transactionForm.EditServiceCode.focus();
                    }
                    <%
                        tokenizer = new StringTokenizer(supportedLanguages,",");
                        while(tokenizer.hasMoreTokens()){
                            tmpLang = tokenizer.nextToken();

                            %>
                              else if(transactionForm.EditLabelValue<%=tmpLang%>.value.length == 0){
                                transactionForm.EditLabelValue<%=tmpLang%>.focus();
                              }
                            <%
                        }
                    %>
                  }
                }
              }

              <%-- FIND ZIPCODE LANGUAGE SPECIFIED --%>
              function findZipcodeLanguageSpecified(oZipcode, oCity, buttonId, sDisplayLang){
                if (oZipcode.value.length==0) {
                  oCity.value = "";
                }
                else {
                  oCity.value = "";
                  openPopup("/_common/search/blurZipcode.jsp&ZipcodeValue="+oZipcode.value+"&CityName="+oCity.name+"&CityValue="+oCity.value+"&DisplayLang="+sDisplayLang+"&VarButton="+buttonId);
                }
              }

              <%-- popup : search service stock --%>
              function searchServiceStock(serviceStockUidField,serviceStockNameField){
                openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceStockUidField+"&ReturnServiceStockNameField="+serviceStockNameField);
              }

              <%-- display city in saved service language --%>
              if(document.getElementsByName('EditServiceCity')[0].value.length==0){
                findZipcodeLanguageSpecified(document.getElementsByName('EditServiceZipcode')[0],document.getElementsByName('EditServiceCity')[0],'buttonServiceZipcode','<%=service.language%>');
              }

              if(document.getElementsByName('EditContactCity')[0].value.length==0){
                findZipcodeLanguageSpecified(document.getElementsByName('EditContactZipcode')[0],document.getElementsByName('EditContactCity')[0],'buttonContactZipcode','<%=service.language%>');
              }
            </script>
        <%
    }
%>
</form>