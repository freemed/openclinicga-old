<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*" %>
<%=sJSEMAIL%>
<%!
    //--- GET PARENT ------------------------------------------------------------------------------
    private String getParent(String sCode, String sWebLanguage) {
        String sReturn = "";
        try {
            if ((sCode != null) && (sCode.trim().length() > 0)) {
                while (sCode.trim().length() < 5) {
                    sCode = "0" + sCode;
                }
                String sLabel = getTran("Service", sCode, sWebLanguage);

                Vector vParentIDs = Service.getParentIds(sCode);
                Iterator iter = vParentIDs.iterator();

                String sParentID;
                while (iter.hasNext()) {
                    sParentID = (String) iter.next();
                    if ((sParentID != null) && (!sParentID.equals("0000")) && (sParentID.trim().length() > 0)) {

                        sReturn = getParent(sParentID, sWebLanguage)
                                + "&nbsp;<img src='" + sCONTEXTPATH + "/_img/themes/default/pijl.gif'>&nbsp;"
                                + "<a href='javascript:populateService(\"" + sCode + "\")' title='" + getTran("Web.Occup", "medwan.common.open", sWebLanguage) + "'>" + sLabel + "</a>";
                    }
                }

                if (sReturn.trim().length() == 0) {
                    sReturn = sReturn + "&nbsp;<img src='" + sCONTEXTPATH + "/_img/themes/default/pijl.gif'>&nbsp;"
                            + "<a href='javascript:populateService(\"" + sCode + "\")' title='" + getTran("Web.Occup", "medwan.common.open", sWebLanguage) + "'>" + sLabel + "</a>";
                }
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println("SearchService: " + e.getMessage());
        }

        return sReturn;
    }

    //--- WRITE MY ROW ----------------------------------------------------------------------------
    private String writeMyRow(String sID, String sLabel, String sWebLanguage, int rowIdx) {
        StringBuffer sReturn = new StringBuffer();

        sReturn.append("<tr>")
                .append("<td width='50'>")
                .append("<input type='checkbox' name='cb_" + rowIdx + "'/>")
                .append("&nbsp;<img src='" + sCONTEXTPATH + "/_img/icons/icon_view.gif' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"' alt='" + getTran("Web", "view", sWebLanguage) + "'" + " onclick='viewService(\"" + sID + "\")'>");

        /*
        // add edit icon if user has the right permissions
        if(activeUser.getAccessRight("system.manageservices.edit")){
            sReturn.append("&nbsp;<img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"' alt='"+getTranNoLink("Web","edit",sWebLanguage)+"'"+" onclick='editService(\""+sID+"\")'>");
        }
        */

        sReturn.append("</td>")
                .append("<td>" + sID + "</td>")
                .append("<td><a href='javascript:checkService(\"cb_" + rowIdx + "\");' title='" + getTran("Web", "select", sWebLanguage) + "'>" + sLabel + "</a></td>")
                .append("</tr>");

        return sReturn.toString();
    }

    //--- GET EPS NAME ----------------------------------------------------------------------------
    private String getEPSName(String sEPSID) {
        return ExternalPreventionService.getEPSName(sEPSID);
    }
%>

<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    String sVarCode = checkString(request.getParameter("VarCode"));
    String sVarText = checkString(request.getParameter("VarText"));
    String sFindText = checkString(request.getParameter("FindText")).toUpperCase();
    String sFindCode = checkString(request.getParameter("FindCode")).toUpperCase();
    String sViewCode = checkString(request.getParameter("ViewCode"));
    String sEditCode = checkString(request.getParameter("EditCode"));
    //String sSaveCode = checkString(request.getParameter("SaveCode"));
    String sRSIndex = checkString(request.getParameter("RSIndex"));

    StringBuffer sOut = new StringBuffer();
    StringBuffer sScript = new StringBuffer();

    int iTotal = 1, iMaxResultSet = 100, iParameterResultSet = 0;
    String sNavigation = "", sSelect, sServiceID;
    Hashtable hLabels = new Hashtable();
    SortedSet set = new TreeSet();

    //*** code ***
    if (sFindCode.length() > 0) {
        iTotal = 0;

        Vector vServiceIDs = Service.getServiceIDsByParentID(sFindCode);
        Iterator iter = vServiceIDs.iterator();

        while ((iter.hasNext()) && (iTotal < iMaxResultSet)) {
            sServiceID = (String) iter.next();
            set.add(sServiceID);
            hLabels.put(sServiceID, getTran("Service", sServiceID, sWebLanguage));
            iTotal++;
        }

        sNavigation = getParent(sFindCode, sWebLanguage);
    }
    //*** text ***
    else if (sFindText.length() > 0) {
        String sOldFindText = ScreenHelper.checkDbString(sFindText);

        Hashtable hServiceIDs = Service.getMultipleServiceIDsByText(sWebLanguage, sOldFindText);
        Enumeration enum = hServiceIDs.keys();

        if (sRSIndex.length() > 0) {
            iParameterResultSet = Integer.parseInt(sRSIndex);
            for (int n = 0; n < iParameterResultSet && enum.hasMoreElements(); n++) {
                // nothing
            }
        }

        while (enum.hasMoreElements() && iTotal < iMaxResultSet) {
            sServiceID = (String) enum.nextElement();
            set.add(sServiceID);
            hLabels.put(sServiceID, hServiceIDs.get(sServiceID));
            iTotal++;
        }
    }
    //*** FILL UP SEARCH SCREEN ***
    else {
        if (MedwanQuery.getInstance().getConfigString("fillUpSearchServiceScreens").equalsIgnoreCase("on")) {
            Vector vServiceIDs = Service.getTopServiceIDs();
            Iterator iter = vServiceIDs.iterator();

            if (sRSIndex.length() > 0) {
                iParameterResultSet = Integer.parseInt(sRSIndex);
                for (int n = 0; n < iParameterResultSet && iter.hasNext(); n++) {
                    // nothing
                }
            }

            while ((iter.hasNext()) && (iTotal < iMaxResultSet)) {
                sServiceID = (String) iter.next();
                set.add(sServiceID);
                hLabels.put(sServiceID, getTran("Service", sServiceID, sWebLanguage));
                iTotal++;
            }
        }
    }

    String sNext = "", sPrevious = "";
    if (iParameterResultSet >= iMaxResultSet) {
        sPrevious = "<input type='button' class='button' name='prevButton' value='" + getTran("Web", "Previous", sWebLanguage) + "'" +
                " onClick=\"doPrev(" + (iParameterResultSet - iMaxResultSet) + ");\">";
    }

    if (iTotal == iMaxResultSet) {
        sNext = "<input type='button' class='button' name='nextButton' value='" + getTran("Web", "Next", sWebLanguage) + "'" +
                " onClick=\"doNext(" + (iParameterResultSet + iMaxResultSet) + ");\">";
    }

    Hashtable labelValues = new Hashtable();
    Enumeration paramEnum = request.getParameterNames();
    String tmpParamName, tmpParamValue;

    while (paramEnum.hasMoreElements()) {
        tmpParamName = (String) paramEnum.nextElement();

        if (tmpParamName.startsWith("EditService")) {
            tmpParamValue = request.getParameter(tmpParamName);
            labelValues.put(tmpParamName.substring(11), tmpParamValue); // language, value
        }
    }
%>

<html>
<head>
    <title><%=sAPPTITLE%></title>
</head>

<script>
  var foundServices = new Array();
  serviceCount = 0;
</script>

<body class="Geenscroll">
    <form name="SearchForm" method="POST" onSubmit="ToggleFloatingLayer('FloatingLayer',1);">
        <input type="hidden" name="RSIndex">

        <table width="100%" cellspacing="0" cellpadding="0" class="menu">
            <tr>
                <td width="100%" height="25">
                    &nbsp;<%=getTran("Web","Find",sWebLanguage)%>&nbsp;&nbsp;
                    <input type="text" NAME="FindText" class="text" value="<%=sFindText%>" size="40" onblur="limitLength(this);">

                    <%-- BUTTONS --%>
                    <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                    <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="doClear();">
                </td>
            </tr>

            <tr><td class="navigation_line" height="1"></td></tr>

            <tr>
                <td height="20" class="menu_bar">
                    &nbsp;<a href="javascript:doHome();">Home</a><%=sNavigation%>
                </td>
            </tr>

            <%-- TABLE WITH SEARCH RESULTS --%>
            <tr>
                <td class="white" style="vertical-align:top;">
                    <div class="search" style="width:636px;height:495px;">
                        <table width="100%" cellspacing="1">
                            <%
                                if ((sViewCode.length()>0)||(iTotal==0)){
                                    if (iTotal==0){
                                        sViewCode = sFindCode;
                                    }

                                    String sLabel = getTran("Service",sViewCode,sWebLanguage);
                                    Service sService = Service.getService(sViewCode);

                                    if (sService!=null) {
                                        String sCountry = checkString(sService.country);
                                        if(sCountry.length() > 0){
                                            sCountry = getTran("Country",sCountry,sWebLanguage);
                                        }

                                        out.print(setRow("Web","Address", checkString(sService.address),sWebLanguage));
                                        out.print(setRow("Web","zipcode", checkString(sService.zipcode),sWebLanguage));
                                        out.print(setRow("Web","city", checkString(sService.city),sWebLanguage));
                                        out.print(setRow("Web","country", sCountry,sWebLanguage));
                                        out.print(setRow("Web","telephone", checkString(sService.telephone),sWebLanguage));
                                        out.print(setRow("Web","fax", checkString(sService.fax),sWebLanguage));
                                        out.print(setRow("Web","contract", checkString(sService.contract),sWebLanguage));
                                        out.print(setRow("Web","contracttype", checkString(sService.contracttype),sWebLanguage));
                                        out.print(setRow("Web","contactperson", checkString(sService.contactperson),sWebLanguage));
                                        out.print(setRow("Web","comment", checkString(sService.comment),sWebLanguage));
                                        out.print(setRow("Web","medicalcentre", checkString(sService.code5),sWebLanguage));

                                        String sServiceEPSID = "", sServiceEPSName = "";
                                        sServiceEPSID = ExternalPreventionService.getEPSID(sViewCode);
                                        if(sServiceEPSID.length() > 0 ){
                                            sServiceEPSName = getEPSName(sServiceEPSID);
                                        }
                                        out.print(setRow("Web.admin","external_prevention_service", checkString(sServiceEPSName),sWebLanguage));

                                        %>
                                            <%-- SPACER --%>
                                            <tr height="1">
                                                <td width="<%=sTDAdminWidth%>">&nbsp;</td>
                                                <td width="*">&nbsp;</td>
                                            </tr>
                                        <%
                                    }
                                }
                                else {
                                    // sort
                                    Iterator it = set.iterator();
                                    String serviceID, serviceDescr;
                                    int rowCounter = 1;
                                    while (it.hasNext()) {
                                        serviceID = it.next().toString();
                                        serviceDescr = (String)hLabels.get(serviceID);

                                        sOut.append(writeMyRow(serviceID,serviceDescr,sWebLanguage,rowCounter++));
                                        sScript.append("addServiceToArray(")
                                               .append("'").append(serviceID).append("',")
                                               .append("'").append(serviceDescr).append("');");
                                    }

                                    // display search results
                                    if(iTotal > 0){
                                        if(iTotal==1 && sFindText.length() > 0){
                                            // display 'no results' message
                                            %>
                                                <tr>
                                                    <td colspan="3"><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                                </tr>
                                            <%
                                        }
                                        else{
                                            %>
                                                <tbody><%=sOut.toString()%></tbody>
                                            <%
                                        }
                                    }
                                }
                            %>
                        </table>
                    </div>
                </td>
            </tr>
        </table>

        <%-- PREV-CLOSE-NEXT BUTTONS --%>
        <table width="100%">
            <tr height="30">
                <td align="left" width="100"><%=sPrevious%></td>

                <td align="center">
                    <input type="button" name="buttonadd"   class="button" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick='addSelectedService();'>&nbsp;
                    <input type="button" name="buttonaddall" class="button" value='<%=getTranNoLink("Web","addall",sWebLanguage)%>' onclick='addAllServices();window.close();'>&nbsp;
                    <input type="button" name="buttonclose" class="button" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close();'>
                </td>

                <td align="right" width="100"><%=sNext%></td>
            </tr>
        </table>

        <%-- hidden fields --%>
        <input type="hidden" name="VarCode" value="<%=sVarCode%>">
        <input type="hidden" name="VarText" value="<%=sVarText%>">
        <input type="hidden" name="FindCode">
        <input type="hidden" name="ViewCode">
        <input type="hidden" name="EditCode">
        <input type="hidden" name="SaveCode" value="<%=sEditCode%>">
    </form>

    <script>
      window.resizeTo(650,600);
      SearchForm.FindText.focus();

      <%-- PREV --%>
      function doPrev(idx){
        ToggleFloatingLayer('FloatingLayer',1);
        if(SearchForm.prevButton!=undefined) SearchForm.prevButton.disabled = true;
        SearchForm.FindButton.disabled = true;
        SearchForm.RSIndex.value = idx;
        SearchForm.submit();
      }

      <%-- NEXT --%>
      function doNext(idx){
        ToggleFloatingLayer('FloatingLayer',1);
        if(SearchForm.nextButton!=undefined) SearchForm.nextButton.disabled = true;
        SearchForm.FindButton.disabled = true;
        SearchForm.RSIndex.value = idx;
        SearchForm.submit();
      }

      <%-- CHECK SERVICE --%>
      function checkService(sCheckBoxName){
        if(eval("SearchForm."+sCheckBoxName).checked){
          eval("SearchForm."+sCheckBoxName).checked = false;
        }
        else{
          eval("SearchForm."+sCheckBoxName).checked = true;
        }
      }

      <%-- ADD SERVICE --%>
      function addService(id,descr){
        window.opener.addService(id,descr);
      }

      <%-- ADD ALL SERVICES --%>
      function addAllServices(){
        for(var i=0; i<foundServices.length; i++){
          addService(foundServices[i][0],foundServices[i][1]);
        }
      }

      <%-- ADD SELECTED SERVICES --%>
      function addSelectedServices(closeWindow){
        var inputs = document.getElementsByTagName('input');

        for(var i=0; i<inputs.length; i++){
          if(inputs[i].type=='checkbox'){
            if(inputs[i].checked){
              var id = inputs[i].name.substring(3)-1;
              addService(foundServices[id][0],foundServices[id][1]);
            }
          }
        }

        if(closeWindow) window.close();
      }

      <%-- ADD SELECTED SERVICE --%>
      function addSelectedService(){
        if(atLeastOneServiceSelected()){
          addSelectedServices(true);
        }
        else{
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web&labelID=selectanitem";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          window.showModalDialog(popupUrl,'',modalities);
        }
      }

      <%-- ADD SERVICE TO ARRAY --%>
      function addServiceToArray(id,descr){
        foundServices[serviceCount] = new Array(id,descr);
        serviceCount++;
      }

      <%-- AT LEAST ONE SERVICE SELECTED --%>
      function atLeastOneServiceSelected(){
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

      function populateService(sID){
        SearchForm.FindCode.value=sID;
        SearchForm.submit();
      }

      function viewService(sID){
        SearchForm.FindCode.value=sID;
        SearchForm.ViewCode.value=sID;
        SearchForm.submit();
      }

      function editService(sID){
        SearchForm.FindCode.value=sID;
        SearchForm.EditCode.value=sID;
        SearchForm.SaveCode.value = "";
        SearchForm.submit();
      }

      function clearFields(){
        SearchForm.FindText.value='';
        SearchForm.FindText.focus();
      }

      function findService() {
        SearchForm.EditCode.value = "";
        SearchForm.SaveCode.value = "";
        SearchForm.submit();
      }

      function doFind(){
        ToggleFloatingLayer('FloatingLayer',1);
        SearchForm.FindButton.disabled = true;
        SearchForm.submit();
      }

      function doHome(){
        doClear();
        SearchForm.EditCode.value = '';
        SearchForm.ViewCode.value = '';
        SearchForm.SaveCode.value = '';
        SearchForm.submit();
      }

      function doClear(){
        SearchForm.all['FindText'].value = '';
        SearchForm.all['FindText'].focus();
      }

      <%=sScript%>
    </script>
</body>
</html>