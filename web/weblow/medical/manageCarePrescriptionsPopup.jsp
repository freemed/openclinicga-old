<%@page import="java.text.SimpleDateFormat,
                be.openclinic.medical.CarePrescription,
                be.openclinic.medical.CarePrescriptionSchema, java.util.*,java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermissionPopup("prescriptions.care","select",activeUser)%>
<%=sJSSORTTABLE%>
<%=sJSDROPDOWNMENU%>
<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass = "1", sDateBeginFormatted, sDateEndFormatted, sCareDescr = "", sCareUid,
                sPreviousCareUid = "";
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
        java.util.Date tmpDate;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);

        // run thru found prescriptions
        CarePrescription prescr;
        for (int i = 0; i < objects.size(); i++) {
            prescr = (CarePrescription) objects.get(i);

            // format date begin
            tmpDate = prescr.getBegin();
            if (tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format date end
            tmpDate = prescr.getEnd();
            if (tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sCareUid = prescr.getCareUid();
            if (!sCareUid.equals(sPreviousCareUid)) {
                sPreviousCareUid = sCareUid;

                if (sCareUid != null) {
                    sCareDescr = getTran("care_type",sCareUid, sWebLanguage);
                } else {
                    sCareDescr = "<font color='red'>" + getTran("web", "nonexistingcare", sWebLanguage) + "</font>";
                }
            }

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display prescription in one row ***
            html.append("<tr class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\" title='" + detailsTran + "'>")
                    .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + prescr.getUid() + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + prescr.getUid() + "');\">" + sCareDescr + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + prescr.getUid() + "');\">" + sDateBeginFormatted + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + prescr.getUid() + "');\">" + sDateEndFormatted + "</td>")
                    .append("</tr>");
        }

        return html;
    }
%>
<%
    String sDefaultSortCol = "OC_CAREPRESCR_BEGIN",
           sDefaultSortDir = "DESC",
           sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditPrescrUid = checkString(request.getParameter("EditPrescrUid"));
    String msg = "";

    // variables
    int foundPrescrCount;
    StringBuffer prescriptionsHtml;

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if (sSortCol.length() == 0) sSortCol = sDefaultSortCol;

    // sortdir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    if (sAction.equals("delete") && sEditPrescrUid.length() > 0) {
        CarePrescription.delete(sEditPrescrUid);
        CarePrescriptionSchema prescriptionSchemaToDelete = CarePrescriptionSchema.getCarePrescriptionSchema(sEditPrescrUid);
        prescriptionSchemaToDelete.delete();

        msg = getTran("web", "dataisdeleted", sWebLanguage);
    }

    //--- SORT ------------------------------------------------------------------------------------
    if (sAction.equals("sort")) {
        sAction = "find";
    }
%>
<form name="transactionForm" id="transactionForm" method="post" onClick='setSaveButton(event);clearMessage();' onKeyUp='setSaveButton(event);'>
    <%-- page title --%>
    <table width="100%" cellspacing="0">
        <tr class="admin">
            <td>&nbsp;&nbsp;<%=getTran("Web.manage","ManagePatientCarePrescriptions",sWebLanguage)%>&nbsp;<%=activePatient.lastname+" "+activePatient.firstname%></td>
            <td align="right">
               <%
                   if(sAction.startsWith("showDetails")){
                       %><img onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" onClick="doBack();" style='vertical-align:middle;' border='0' src='<%=sCONTEXTPATH%>/_img/arrow.jpg' alt='<%=getTran("Web","Back",sWebLanguage)%>'><%
                   }
               %>
            </td>
        </tr>
    </table>
    <%
        if(activePatient==null){
            // display message
            %><%=getTran("web","firstselectaperson",sWebLanguage)%><%
        }
        else{
            //--- DISPLAY ACTIVE PRESCRIPTIONS (for activePatient) --------------------------------
            if (!sAction.startsWith("showDetails")) {
                Vector activePrescrs = CarePrescription.findActive(activePatient.personid, "", "", new SimpleDateFormat("dd/MM/yyyy").format(ScreenHelper.getDate(new Date(new Date().getTime()-48*60*60000))), "", "", sSortCol, sSortDir);
                prescriptionsHtml = objectsToHtml(activePrescrs, sWebLanguage);
                foundPrescrCount = activePrescrs.size();

                if (foundPrescrCount > 0 || !"1".equals(request.getParameter("skipEmpty"))) {
                    String sortTran = getTran("web", "clicktosort", sWebLanguage);
                %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%-- clickable header --%>
                    <tr class="gray">
                        <td width="22" nowrap>&nbsp;</td>
                        <td><%=getTran("Web","care_type",sWebLanguage)%></td>
                        <td width="100"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_CAREPRESCR_BEGIN');"><%=(sSortCol.equalsIgnoreCase("OC_CAREPRESCR_BEGIN")?"<"+sSortDir+">":"")%><%=getTran("Web","begindate",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_CAREPRESCR_BEGIN")?"</"+sSortDir+">":"")%></a></td>
                        <td width="100"><a href="#" class="underlined" title="<%=sortTran%>" onClick="doSort('OC_CAREPRESCR_END');"><%=(sSortCol.equalsIgnoreCase("OC_CAREPRESCR_END")?"<"+sSortDir+">":"")%><%=getTran("Web","enddate",sWebLanguage)%><%=(sSortCol.equalsIgnoreCase("OC_CAREPRESCR_END")?"<"+sSortDir+">":"")%></a></td>
                    </tr>
                    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%=prescriptionsHtml%>
                    </tbody>
                </table>
                <%-- number of records found --%>
                <span style="width:49%;text-align:left;">
                    &nbsp;<%=foundPrescrCount%> <%=getTran("web","activecareprescriptionsfound",sWebLanguage)%>
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
                else{
                    // no records found
                     %>
                    <script>window.location.href="<c:url value='/popup.jsp'/>?Page=medical/manageCarePrescriptionsPopupEdit.jsp&Close=true&ts=<%=getTs()%>&PopupHeight=400&PopupWidth=900";</script>
                    <%
                }

                %>
                    <%-- display message --%>
                    <br><span id="msgArea">&nbsp;<%=msg%></span>
                    <%-- NEW BUTTON --%>
                    <%=ScreenHelper.alignButtonsStart()%>
                    <%
                        if (activeUser.getAccessRight("prescriptions.care.add")){
                    %>
                        <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doShowDetails('');">
                    <%
                        }
                    %>
                        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
                    <%=ScreenHelper.alignButtonsStop()%>
                <%
            }
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditPrescrUid">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>              
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

  <%-- DO SHOW DETAILS --%>
  function doShowDetails(prescriptionUid){
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;
    if(transactionForm.closeButton!=undefined) transactionForm.closeButton.disabled = true;

    window.location.href="<c:url value='/popup.jsp'/>?Page=medical/manageCarePrescriptionsPopupEdit.jsp&EditPrescrUid="+prescriptionUid+"&ts=<%=getTs()%>&PopupHeight=400&PopupWidth=900";
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditPrescriberUid.value = "";
    transactionForm.EditPrescriberFullName.value = "";
    transactionForm.EditCareUid.value = "";
    transactionForm.EditCareDescr.value = "";
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
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>&loadschema=true&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url = url+"&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url = url+"&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
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

  <%-- CHECK SAVE BUTTON --%>
  function checkSaveButton(contextpath, sQuestion) {
      var bReturn = true;

      if (myButton != null) {
          if (!bSaveHasNotChanged) {
              var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=999999999&labelValue="+sQuestion;
              var modalities = "dialogWidth:300px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
              var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm(sQuestion);

              if (!answer == 1) {
                  bReturn = false;
              }
          }
      }
      else if (sFormBeginStatus != myForm.innerHTML) {
          var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=999999999&labelValue="+sQuestion;
          var modalities = "dialogWidth:300px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm(sQuestion);

          if (!answer == 1) {
              bReturn = false;
          }
      }

      return bReturn;
  }

  <%-- DO BACK --%>
  function doBack(){
    window.close();
  }
</script>
