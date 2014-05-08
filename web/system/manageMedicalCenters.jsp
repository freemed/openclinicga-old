<%@ page import="net.admin.system.MedicalCenter,java.util.Vector" %>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%=sJSEMAIL%>
<%=sJSSORTTABLE%>
<%
    String sAction = checkString(request.getParameter("Action"));
    // retreive form data
    String sFindCenterCode      = checkString(request.getParameter("FindCenterCode")),
           sEditCenterCode      = checkString(request.getParameter("EditCenterCode")),
           sEditCenterName      = checkString(request.getParameter("EditCenterName")),
           sEditCenterAddress   = checkString(request.getParameter("EditCenterAddress")),
           sEditCenterZipcode   = checkString(request.getParameter("EditCenterZipcode")),
           sEditCenterCity      = checkString(request.getParameter("EditCenterCity")),
           sEditCenterCountry   = checkString(request.getParameter("EditCenterCountry")),
           sEditCenterTelephone = checkString(request.getParameter("EditCenterTelephone")),
           sEditCenterEmail     = checkString(request.getParameter("EditCenterEmail")),
           sEditCenterFax       = checkString(request.getParameter("EditCenterFax")),
           sEditCenterComment   = checkString(request.getParameter("EditCenterComment"));

    String msg = "";
    int foundCenterCount = 0;

    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = "code"; // default


    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditCenterCode.length()>0 && sEditCenterName.length()>0){
        //***** check existence *****
        boolean bCenterExists = false;
        bCenterExists = MedicalCenter.exists(sEditCenterCode);
        //***** insert *****
        if(!bCenterExists){
            MedicalCenter objMC = new MedicalCenter();
            objMC.setCode(sEditCenterCode);
            objMC.setName(sEditCenterName);
            objMC.setUpdatetime(getSQLTime()); // now
            objMC.setAddress(sEditCenterAddress);
            objMC.setZipcode(sEditCenterZipcode);
            objMC.setCity(sEditCenterCity);
            objMC.setCountry(sEditCenterCountry);
            objMC.setTelephone(sEditCenterTelephone);
            objMC.setEmail(sEditCenterEmail);
            objMC.setFax(sEditCenterFax);
            objMC.setComment(sEditCenterComment);

            MedicalCenter.addMedicalCenter(objMC);

            // show saved data
            sAction = "showDetails";
            msg = getTran("web","dataissaved",sWebLanguage);
            sFindCenterCode = sEditCenterCode;
        }
        //***** update existing record *****
        else{
            if(!sFindCenterCode.equals("-1") && !sFindCenterCode.equals("")){
                MedicalCenter objMC = new MedicalCenter();

                objMC.setCode(sEditCenterCode);
                objMC.setName(sEditCenterName);
                objMC.setUpdatetime(getSQLTime()); // now
                objMC.setAddress(sEditCenterAddress);
                objMC.setZipcode(sEditCenterZipcode);
                objMC.setCity(sEditCenterCity);
                objMC.setCountry(sEditCenterCountry);
                objMC.setTelephone(sEditCenterTelephone);
                objMC.setEmail(sEditCenterEmail);
                objMC.setFax(sEditCenterFax);
                objMC.setComment(sEditCenterComment);

                MedicalCenter.saveMedicalCenter(objMC);

                // show saved data
                sAction = "showDetails";
                msg = getTran("web","dataissaved",sWebLanguage);
                sFindCenterCode = sEditCenterCode;
            }
            //***** reject new addition *****
            else{
                // show saved data
                sAction = "showDetailsAfterReject";
                msg = "<font color='red'>"+getTran("web.manage","centerexists",sWebLanguage)+"</font>";
            }
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditCenterCode.length()>0){
        MedicalCenter.deleteMedicalCenter(sEditCenterCode);
        sFindCenterCode = "";
        msg = getTran("web","dataisdeleted",sWebLanguage);
    }
%>
<form name="transactionForm" method="post"
    <%
        if(sAction.startsWith("showDetails")){
            %>onKeyDown="if(enterEvent(event,13)){doSave();}"<%
        }
        else{
            %>onKeyDown="if(enterEvent(event,13)){doSearch('code');}"<%
        }
    %>
    >

    <%-- SEARCH FIELDS --------------------------------------------------------------------------%>
    <%
        String sFindCenterName    = checkString(request.getParameter("FindCenterName")),
               sFindCenterAddress = checkString(request.getParameter("FindCenterAddress")),
               sFindCenterZipcode = checkString(request.getParameter("FindCenterZipcode")),
               sFindCenterCity    = checkString(request.getParameter("FindCenterCity"));

        if(sAction.equals("find") || sAction.equals("")){
    %>
    <%=writeTableHeader("Web.manage","ManageMedicalCenters",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" border="0">
        <%-- row 1 --%>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web","code",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCenterCode" size="<%=sTextWidth%>" maxLength="5" value="<%=(sFindCenterCode.equals("-1")?"":sFindCenterCode)%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","name",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCenterName" size="<%=sTextWidth%>" maxLength="255" value="<%=sFindCenterName%>">
            </td>
        </tr>
        <%-- row 2 --%>
        <tr>
            <td><%=getTran("Web","address",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCenterAddress" size="<%=sTextWidth%>" maxLength="255" value="<%=sFindCenterAddress%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","zipcode",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCenterZipcode" size="<%=sTextWidth%>" maxLength="5" value="<%=sFindCenterZipcode%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","city",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCenterCity" size="<%=sTextWidth%>" maxLength="255" value="<%=sFindCenterCity%>">
            </td>
        </tr>
       <tr>
           <td/>
           <td>
               <input type="button" class="button" name="searchButton" value="<%=getTran("Web","search",sWebLanguage)%>" onclick="doSearch('code');">&nbsp;
               <input type="button" class="button" name="clearButton" value="<%=getTran("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
               <input type="button" class="button" name="newButton" value="<%=getTran("Web.Occup","medwan.common.create-new",sWebLanguage)%>" onclick="doNew();">&nbsp;
               <input type="button" class="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
           </td>
       </tr>
    </table>
    <br/>
    <%
        }
    %>
    <%
        //-- FIND ---------------------------------------------------------------------------------
        if (sAction.equals("find")) {
            Vector vMC = MedicalCenter.selectMedicalCenters(sFindCenterCode, sFindCenterName, sFindCenterAddress, sFindCenterZipcode, sFindCenterCity, sSortCol);
            Iterator iter = vMC.iterator();

            MedicalCenter objMC;

            StringBuffer centers = new StringBuffer();
            String sClass = "1", sCode = "";
            String detailsTran = getTran("web.occup", "medwan.common.show-details", sWebLanguage);
            SimpleDateFormat hourDateFormat = ScreenHelper.fullDateFormat;

            while (iter.hasNext()) {
                objMC = (MedicalCenter) iter.next();
                foundCenterCount++;

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                sCode = objMC.getCode();

                // display center in row
                centers.append("<tr class='list" + sClass + "'  onclick=\"doShowDetails('" + sCode + "');\" title='" + detailsTran + "'>")
                        .append(" <td>" + sCode + "</td>")
                        .append(" <td>" + objMC.getName() + "</td>")
                        .append(" <td>" + objMC.getAddress() + "</td>")
                        .append(" <td>" + objMC.getZipcode() + "</td>")
                        .append(" <td>" + objMC.getCity() + "</td>")
                        .append(" <td>" + hourDateFormat.format(objMC.getUpdatetime()) + "</td>")
                        .append("</tr>");
            }

            if (foundCenterCount == 1) {
                sAction = "showDetails";
                sEditCenterCode = sCode;
            } else if (foundCenterCount > 0) {
    %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="list" id="searchresults">
                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>

                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="10%"><a href="#" class="underlined" onClick="doSearch('code');"><%=getTran("Web","code",sWebLanguage)%></a></td>
                            <td width="25%"><a href="#" class="underlined" onClick="doSearch('name');"><%=getTran("Web","name",sWebLanguage)%></a></td>
                            <td width="20%"><a href="#" class="underlined" onClick="doSearch('address');"><%=getTran("Web","address",sWebLanguage)%></a></td>
                            <td width="10%"><a href="#" class="underlined" onClick="doSearch('zipcode');"><%=getTran("Web","zipcode",sWebLanguage)%></a></td>
                            <td width="20%"><a href="#" class="underlined" onClick="doSearch('city');"><%=getTran("Web","city",sWebLanguage)%></a></td>
                            <td width="15%"><a href="#" class="underlined" onClick="doSearch('updatetime');"><%=getTran("Web","updatetime",sWebLanguage)%></a></td>
                        </tr>

                        <%=centers%>
                    </table>

                    <%-- number of records found --%>
                    <%=foundCenterCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                <%
            }
            else{
                // no records found
                %><%=getTran("web","norecordsfound",sWebLanguage)%><%
            }

            if(foundCenterCount > 20){
                // link to top of page
                %>
                    <p align="right">
                        <a href="#topp" class="topbutton">&nbsp;</a>&nbsp;
                    </p>
                <%
            }

        }

        //--- SHOW DETAILS ------------------------------------------------------------------------
        if(sAction.startsWith("showDetails")){
            String sSelectedCenterCode = "", sSelectedCenterName = "", sSelectedCenterAddress = "",
                   sSelectedCenterZipcode = "", sSelectedCenterCity = "", sSelectedCenterCountry = "",
                   sSelectedCenterTelephone = "", sSelectedCenterFax = "", sSelectedCenterEmail = "",
                   sSelectedCenterComment = "";

            // get specified record
            if(sAction.equals("showDetails")){
                MedicalCenter objMC = MedicalCenter.showDetails(sEditCenterCode);

                if(objMC != null){
                    sSelectedCenterCode      = objMC.getCode();
                    sSelectedCenterName      = objMC.getName();
                    sSelectedCenterAddress   = objMC.getAddress();
                    sSelectedCenterZipcode   = objMC.getZipcode();
                    sSelectedCenterCity      = objMC.getCity();
                    sSelectedCenterCountry   = objMC.getCountry();
                    sSelectedCenterTelephone = objMC.getTelephone();
                    sSelectedCenterFax       = objMC.getFax();
                    sSelectedCenterEmail     = objMC.getEmail();
                    sSelectedCenterComment   = objMC.getComment();
                }
            }
            else if(sAction.equals("showDetailsAfterReject")){
                // do not get data from DB, but show data that were allready on form
                sSelectedCenterCode      = sEditCenterCode;
                sSelectedCenterName      = sEditCenterName;
                sSelectedCenterAddress   = sEditCenterAddress;
                sSelectedCenterZipcode   = sEditCenterZipcode;
                sSelectedCenterCity      = sEditCenterCity;
                sSelectedCenterCountry   = sEditCenterCountry;
                sSelectedCenterTelephone = sEditCenterTelephone;
                sSelectedCenterFax       = sEditCenterFax;
                sSelectedCenterEmail     = sEditCenterEmail;
                sSelectedCenterComment   = sEditCenterComment;
            }

            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- title --%>
                    <tr>
                        <td colspan="2"><%=writeTableHeader("Web.manage","ManageMedicalCenters",sWebLanguage," doBack();")%></td>
                    </tr>
                    <%-- center code --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","code",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditCenterCode" value="<%=sSelectedCenterCode%>" size="5" maxLength="5">
                        </td>
                    </tr>
                    <%-- center name --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","name",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterName" value="<%=sSelectedCenterName%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%-- center address --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","address",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterAddress" value="<%=sSelectedCenterAddress%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%-- center city --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","city",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterCity" value="<%=sSelectedCenterCity%>" size="<%=sTextWidth%>" maxLength="255" READONLY>
                        </td>
                    </tr>
                    <%-- center country --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","country",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterCountryText" value="<%=getTranNoLink("Country",sSelectedCenterCountry,sWebLanguage)%>" size="50" maxLength="255">
                            <%=ScreenHelper.writeSearchButton("buttonCountry","Country","EditCenterCountry","EditCenterCountryText","",sWebLanguage,sCONTEXTPATH)%>
                            <input type="hidden" name="EditCenterCountry" value="<%=sSelectedCenterCountry%>">
                        </td>
                    </tr>
                    <%-- center telephone --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","telephone",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterTelephone" value="<%=sSelectedCenterTelephone%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%-- center fax --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","fax",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterFax" value="<%=sSelectedCenterFax%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%-- center email --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","email",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterEmail" value="<%=sSelectedCenterEmail%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%-- center comment --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","Comment",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCenterComment" value="<%=sSelectedCenterComment%>" size="50" maxLength="255">
                        </td>
                    </tr>
                    <%=ScreenHelper.setFormButtonsStart()%>
                    <%
                        if(sAction.equals("showDetailsAfterReject") || sAction.equals("showDetailsNew")){
                            // new center : display saveButton with add-label + do not display delete button
                            %>
                            <input class="button" type="button" name="saveButton" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="doSave();">
                            <%
                        }
                        else if(sAction.equals("showDetails")){
                            // existing center : display saveButton with save-label
                            %>
                            <input class="button" type="button" name="saveButton" value="<%=getTran("Web","save",sWebLanguage)%>" onclick="doSave();">
                            <input class="button" type="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete();">
                            <%
                        }
                        else if(foundCenterCount > 20){
                            // link to top of page
                            %><a href="#topp" class="topbutton">&nbsp;</a>&nbsp;<%
                        }

                        // allways show back button
                        %><input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBackToSearch();"><%
                    %>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%
        }
    %>
    <%-- display message --%>
    <%=msg%>
    <%
        // hidden fields
        %>
        <input type="hidden" name="Action">
        <input type="hidden" name="SortCol" value="<%=sSortCol%>">
        <%

        if(!sAction.startsWith("showDetails")){
            %><input type="hidden" name="EditCenterCode" value="<%=sEditCenterCode%>"><%
        }
    %>
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(sAction.startsWith("showDetails")){
          %>transactionForm.EditCenterCode.focus();<%
      }
      else{
          %>transactionForm.FindCenterCode.focus();<%
      }
  %>

  <%-- DO ADD --%>
  function doAdd(){
    if(checkData()){
      transactionForm.saveButton.disabled = true;
      transactionForm.FindCenterCode.value = "-1";
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditCenterCode.value.length==0 || transactionForm.EditCenterCode.value.length < 5){
         transactionForm.EditCenterCode.focus();
      }
      else{
         transactionForm.EditCenterName.focus();
      }
    }
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkData()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditCenterCode.value.length==0 || transactionForm.EditCenterCode.value.length < 5){
         transactionForm.EditCenterCode.focus();
      }
      else{
         transactionForm.EditCenterName.focus();
      }
    }
  }

  <%-- CHECK DATA --%>
  function checkData(){
    <%-- 2 required fields --%>
    if(!transactionForm.EditCenterCode.value.length==0 && !transactionForm.EditCenterName.value.length==0){
      var maySubmit = true;

      <%-- check center code --%>
      if(maySubmit){
        if(transactionForm.EditCenterCode.value.length < 5){
          var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.errors&labelID=error.medical-center-needs-5-characters";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.errors","error.medical-center-needs-5-characters",sWebLanguage)%>");

          transactionForm.EditCenterCode.focus();
          maySubmit = false;
        }
      }

      <%-- check for valid email --%>
      if(maySubmit){
        if(transactionForm.EditCenterEmail.value.length > 0){
          if(!validEmailAddress(transactionForm.EditCenterEmail.value)){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=invalidemailaddress";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","invalidemailaddress",sWebLanguage)%>");

            transactionForm.EditCenterEmail.focus();
            maySubmit = false;
          }
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
  function doDelete() {
	if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.saveButton.disabled = true;
      transactionForm.deleteButton.disabled = true;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO NEW --%>
  function doNew(){
    <%
        if(sAction.equals("showDetails")){
            %>clearCenterFields();<%
        }
    %>

    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.FindCenterCode.value = "-1";
    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(centerCode){
    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.EditCenterCode.value = centerCode;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindCenterCode.value = "";
    transactionForm.FindCenterName.value = "";
    transactionForm.FindCenterAddress.value = "";
    transactionForm.FindCenterZipcode.value = "";
    transactionForm.FindCenterCity.value = "";
  }

  <%-- CLEAR CENTER FIELDS --%>
  function clearCenterFields(){
    transactionForm.EditCenterCode.value = "";
    transactionForm.EditCenterName.value = "";
    transactionForm.EditCenterAddress.value = "";
    transactionForm.EditCenterZipcode.value = "";
    transactionForm.EditCenterCity.value = "";
    transactionForm.EditCenterCountry.value = "";
    transactionForm.EditCenterTelephone.value = "";
    transactionForm.EditCenterEmail.value = "";
    transactionForm.EditCenterFax.value = "";
    transactionForm.EditCenterComment.value = "";
  }

  <%-- DO SEARCH --%>
  function doSearch(sortCol){
    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "find";
    transactionForm.SortCol.value = sortCol;
    transactionForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  <%-- DO BACK TO SEARCH --%>
  function doBackToSearch(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/manageMedicalCenters.jsp";
  }
</script>