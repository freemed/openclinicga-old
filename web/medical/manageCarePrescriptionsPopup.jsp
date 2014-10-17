<%@page import="java.text.SimpleDateFormat,
                be.openclinic.medical.CarePrescription,
                be.openclinic.medical.CarePrescriptionSchema,
                java.util.*,
                java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermissionPopup("prescriptions.care","select",activeUser)%>
<%=sJSSORTTABLE%>
<%=sJSDROPDOWNMENU%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sDateBeginFormatted, sDateEndFormatted, sCareDescr = "",
        	   sCareUid, sPreviousCareUid = "", sPrescriber;
        java.util.Date tmpDate;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran = getTranNoLink("Web","delete",sWebLanguage);

        // run thru found prescriptions
        CarePrescription prescr;
        for(int i=0; i<objects.size(); i++){
            prescr = (CarePrescription)objects.get(i);

            // prescriber
            sPrescriber = User.getFullUserName(prescr.getPrescriberUid());
            
            // format date begin
            tmpDate = prescr.getBegin();
            if(tmpDate!=null) sDateBeginFormatted = ScreenHelper.stdDateFormat.format(tmpDate);
            else              sDateBeginFormatted = "";

            // format date end
            tmpDate = prescr.getEnd();
            if(tmpDate!=null) sDateEndFormatted = ScreenHelper.stdDateFormat.format(tmpDate);
            else              sDateEndFormatted = "";

            // only search product-name when different product-UID
            sCareUid = prescr.getCareUid();
            if(!sCareUid.equals(sPreviousCareUid)){
                sPreviousCareUid = sCareUid;

                if(sCareUid!=null) {
                    sCareDescr = getTran("care_type",sCareUid,sWebLanguage);
                }
                else{
                    sCareDescr = "<font color='red'>"+getTran("web","nonexistingcare",sWebLanguage)+"</font>";
                }
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            //*** display prescription in one row ***
            html.append("<tr class='list"+sClass+"' onmouseover=\"this.style.cursor='pointer';\" onmouseout=\"this.style.cursor='default';\" title='"+detailsTran+"'>")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' title='"+deleteTran+"' onclick=\"doDelete('"+prescr.getUid()+"');\">")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sCareDescr+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sPrescriber+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateBeginFormatted+"</td>")
                 .append("<td onclick=\"doShowDetails('"+prescr.getUid()+"');\">"+sDateEndFormatted+"</td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sEditPrescrUid = checkString(request.getParameter("EditPrescrUid"));
    
    String msg = "";
    int foundPrescrCount;
    StringBuffer prescriptionsHtml;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************
    if(sAction.equals("delete") && sEditPrescrUid.length() > 0){
        CarePrescription.delete(sEditPrescrUid);
        CarePrescriptionSchema prescriptionSchemaToDelete = CarePrescriptionSchema.getCarePrescriptionSchema(sEditPrescrUid);
        prescriptionSchemaToDelete.delete();

        msg = getTran("web","dataisdeleted",sWebLanguage);
    }
    
    String sTitle = getTran("Web.manage","ManagePatientCarePrescriptions",sWebLanguage)+"&nbsp;"+activePatient.lastname+" "+activePatient.firstname;
%>
<form name="transactionForm" id="transactionForm" method="post" onClick='setSaveButton(event);clearMessage();' onKeyUp='setSaveButton(event);'>
    <%=writeTableHeaderDirectText(sTitle,sWebLanguage," window.close();")%>
    <%
        if(activePatient==null){
            // display message
            %><%=getTran("web","firstselectaperson",sWebLanguage)%><%
        }
        else{
            //--- DISPLAY ACTIVE PRESCRIPTIONS (for activePatient) --------------------------------
            if(!sAction.startsWith("showDetails")){
                Vector activePrescrs = CarePrescription.findActive(activePatient.personid,"","",ScreenHelper.formatDate(ScreenHelper.getDate(new Date(new Date().getTime()-48*60*60000))),"","","OC_CAREPRESCR_BEGIN","DESC");
                prescriptionsHtml = objectsToHtml(activePrescrs,sWebLanguage);
                foundPrescrCount = activePrescrs.size();

                if(foundPrescrCount > 0 || !"1".equals(request.getParameter("skipEmpty"))){
                %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <%-- header --%>
                    <tr class="gray">
                        <td width="20" nowrap>&nbsp;</td>
                        <td><%=getTran("Web","care_type",sWebLanguage)%></td>
                        <td width="120"><%=getTran("Web","prescriber",sWebLanguage)%></td>
                        <td width="80"><SORTTYPE:DATE><%=getTran("Web","begindate",sWebLanguage)%></SORTTYPE:DATE></td>
                        <td width="80"><SORTTYPE:DATE><%=getTran("Web","enddate",sWebLanguage)%></SORTTYPE:DATE></td>
                    </tr>
                    <tbody class="hand"><%=prescriptionsHtml%></tbody>
                </table>
                
                <%-- number of records found --%>
                <span style="width:49%;text-align:left;">&nbsp;<%=foundPrescrCount%> <%=getTran("web","activecareprescriptionsfound",sWebLanguage)%></span>
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
                    %><script>window.location.href="<c:url value='/popup.jsp'/>?Page=medical/manageCarePrescriptionsPopupEdit.jsp&Close=true&ts=<%=getTs()%>&PopupHeight=400&PopupWidth=900";</script><%
                }

                %>
                    <%-- display message --%>
                    <br><span id="msgArea">&nbsp;<%=msg%></span>
                    
                    <%-- NEW BUTTON --%>
                    <%=ScreenHelper.alignButtonsStart()%>
	                    <%
	                        if(activeUser.getAccessRight("prescriptions.care.add")){
	                            %><input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doShowDetails('');"><%
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
    <input type="hidden" name="EditPrescrUid">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>              
  <%-- DO DELETE --%>
  function doDelete(prescriptionUid){
	if(yesnoDialog("Web","areYouSureToDelete")){
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

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,
		                 unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>&loadschema=true&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
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
</script>