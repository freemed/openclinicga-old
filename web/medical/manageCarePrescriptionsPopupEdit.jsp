<%@page import="java.text.SimpleDateFormat,
                be.openclinic.medical.CarePrescription,
                java.text.DecimalFormat,
                be.openclinic.common.KeyValue,
                be.openclinic.medical.CarePrescriptionSchema"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermissionPopup("prescriptions.care","select",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditPrescrUid     = checkString(request.getParameter("EditPrescrUid")),
           sEditPrescriberUid = checkString(request.getParameter("EditPrescriberUid")),
           sEditCareUid       = checkString(request.getParameter("EditCareUid")),
           sEditDateBegin     = checkString(request.getParameter("EditDateBegin")),
           sEditDateEnd       = checkString(request.getParameter("EditDateEnd")),
           sEditTimeUnit      = checkString(request.getParameter("EditTimeUnit")),
           sEditTimeUnitCount = checkString(request.getParameter("EditTimeUnitCount")),
           sEditUnitsPerTimeUnit = checkString(request.getParameter("EditUnitsPerTimeUnit"));

    String  sTime1 = checkString(request.getParameter("time1")),
            sTime2 = checkString(request.getParameter("time2")),
            sTime3 = checkString(request.getParameter("time3")),
            sTime4 = checkString(request.getParameter("time4")),
            sTime5 = checkString(request.getParameter("time5")),
            sTime6 = checkString(request.getParameter("time6"));

    String  sQuantity1 = checkString(request.getParameter("quantity1")),
            sQuantity2 = checkString(request.getParameter("quantity2")),
            sQuantity3 = checkString(request.getParameter("quantity3")),
            sQuantity4 = checkString(request.getParameter("quantity4")),
            sQuantity5 = checkString(request.getParameter("quantity5")),
            sQuantity6 = checkString(request.getParameter("quantity6"));

    CarePrescriptionSchema prescriptionSchema = new CarePrescriptionSchema();
    if(sTime1.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime1,sQuantity1));
    }
    if(sTime2.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime2,sQuantity2));
    }
    if(sTime3.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime3,sQuantity3));
    }
    if(sTime4.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime4,sQuantity4));
    }
    if(sTime5.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime5,sQuantity5));
    }
    if(sTime6.length() > 0){
        prescriptionSchema.getTimequantities().add(new KeyValue(sTime6,sQuantity6));
    }

    String sEditPrescriberFullName = checkString(request.getParameter("EditPrescriberFullName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* medical/manageCarePrescriptionsPopupEdit.jsp *************");
        Debug.println("sAction                 : "+sAction);
        Debug.println("sEditPrescrUid          : "+sEditPrescrUid);
        Debug.println("sEditPrescriberUid      : "+sEditPrescriberUid);
        Debug.println("sEditCareUid            : "+sEditCareUid);
        Debug.println("sEditDateBegin          : "+sEditDateBegin);
        Debug.println("sEditDateEnd            : "+sEditDateEnd);
        Debug.println("sEditTimeUnit           : "+sEditTimeUnit);
        Debug.println("sEditTimeUnitCount      : "+sEditTimeUnitCount);
        Debug.println("sEditPrescriberFullName : "+sEditPrescriberFullName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sSelectedPrescriberUid = "", sSelectedCareUid = "",
           sSelectedDateBegin = "", sSelectedDateEnd = "", sSelectedTimeUnit = "",
           sSelectedTimeUnitCount = "", sSelectedUnitsPerTimeUnit = "", 
           sSelectedPrescriberFullName = "";
    
    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        // create prescription
        if(sEditPrescrUid.length()==0) sEditPrescrUid = "-1";
        CarePrescription prescr = new CarePrescription();
        prescr.setUid(sEditPrescrUid);
        prescr.setPatientUid(activePatient.personid);
        prescr.setPrescriberUid(sEditPrescriberUid);
        prescr.setCareUid(sEditCareUid);
        prescr.setTimeUnit(sEditTimeUnit);
        if(sEditDateBegin.length() > 0) prescr.setBegin(ScreenHelper.parseDate(sEditDateBegin));
        if(sEditDateEnd.length() > 0) prescr.setEnd(ScreenHelper.parseDate(sEditDateEnd));
        if(sEditTimeUnitCount.length() > 0) prescr.setTimeUnitCount(Integer.parseInt(sEditTimeUnitCount));
        if(sEditUnitsPerTimeUnit.length() > 0) prescr.setUnitsPerTimeUnit(Double.parseDouble(sEditUnitsPerTimeUnit));
        prescr.setUpdateUser(activeUser.userid);

        String existingPrescrUid = prescr.exists();
        boolean prescrExists = existingPrescrUid.length() > 0;

        if(sEditPrescrUid.equals("-1")){
            //***** insert new prescription *****
            if(!prescrExists){
                prescr.store(false);
                prescriptionSchema.setCarePrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject new addition *****
            else{
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>"+getTran("web.manage", "prescriptionexists", sWebLanguage)+"</font>";
            }
        }
        else{
            //***** update existing record *****
            if(!prescrExists){
                prescr.store(false);
                prescriptionSchema.setCarePrescriptionUid(prescr.getUid());
                prescriptionSchema.store();

                msg = getTran("web", "dataissaved", sWebLanguage);
            }
            //***** reject double record thru update *****
            else{
                if(sEditPrescrUid.equals(existingPrescrUid)){
                    // nothing : just updating a record with its own data
                    prescr.store(false);
                    msg = getTran("web", "dataissaved", sWebLanguage);
                   
                    prescriptionSchema.setCarePrescriptionUid(prescr.getUid());
                    prescriptionSchema.store();
                }
                else{
                    // tried to update one prescription with exact the same data as an other prescription
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>"+getTran("web.manage", "prescriptionexists", sWebLanguage)+"</font>";
                }
            }
        }

        sEditPrescrUid = prescr.getUid();
        sSelectedTimeUnit = checkString(prescr.getTimeUnit());
        sSelectedTimeUnitCount = prescr.getTimeUnitCount()+"";
        sSelectedUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";
        sSelectedPrescriberUid = prescr.getPrescriberUid();
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        sSelectedPrescriberFullName = ScreenHelper.getFullUserName(sSelectedPrescriberUid, ad_conn);
        ad_conn.close();

        // do not get data from DB, but show data that were allready on form
        sSelectedPrescriberUid = sEditPrescriberUid;
        sSelectedCareUid = sEditCareUid;
        sSelectedDateBegin = sEditDateBegin;
        sSelectedDateEnd = sEditDateEnd;
        sSelectedTimeUnit = sEditTimeUnit;
        sSelectedTimeUnitCount = sEditTimeUnitCount;
        sSelectedUnitsPerTimeUnit = sEditUnitsPerTimeUnit;

        // afgeleide data
        sSelectedPrescriberFullName = sEditPrescriberFullName;
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditPrescrUid.length() > 0){
        CarePrescription.delete(sEditPrescrUid);
        CarePrescriptionSchema prescriptionSchemaToDelete = CarePrescriptionSchema.getCarePrescriptionSchema(sEditPrescrUid);
        prescriptionSchemaToDelete.delete();

        msg = getTran("web", "dataisdeleted", sWebLanguage);
    }

    // get specified record
    if((sAction.equals("")) && sEditPrescrUid.length()>0){
        CarePrescription prescr = CarePrescription.get(sEditPrescrUid);
        if(prescr != null){
            if(checkString(prescr.getCareUid()) != null){
                sSelectedCareUid = prescr.getCareUid();
            }
            
            // format begin date
            java.util.Date tmpDate = prescr.getBegin();
            if(tmpDate != null) sSelectedDateBegin = ScreenHelper.formatDate(tmpDate);

            // format end date
            tmpDate = prescr.getEnd();
            if(tmpDate != null) sSelectedDateEnd = ScreenHelper.formatDate(tmpDate);

            sSelectedTimeUnit = checkString(prescr.getTimeUnit());
            sSelectedTimeUnitCount = prescr.getTimeUnitCount()+"";
            sSelectedUnitsPerTimeUnit = prescr.getUnitsPerTimeUnit()+"";
            sSelectedPrescriberUid = prescr.getPrescriberUid();
            
            // afgeleide data
           	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            sSelectedPrescriberFullName = ScreenHelper.getFullUserName(sSelectedPrescriberUid, ad_conn);
            ad_conn.close();
        }
        prescriptionSchema = CarePrescriptionSchema.getCarePrescriptionSchema(prescr.getUid());
    }
    else if(sAction.equals("")){
        // showDetailsNew : set default values
        sSelectedPrescriberUid = activeUser.userid;
        sSelectedPrescriberFullName = activeUser.person.lastname+" "+activeUser.person.firstname;
        sSelectedDateBegin = ScreenHelper.formatDate(new java.util.Date()); // now
        sSelectedTimeUnit = "type2day";
        sSelectedTimeUnitCount = "1";
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
    
    
    String sTitle = getTran("Web.manage","ManagePatientCarePrescriptions",sWebLanguage)+"&nbsp;"+activePatient.lastname+" "+activePatient.firstname;
    
    String sCloseAction = "window.close();";
    if(sAction.length()==0 || sAction.startsWith("showDetails")){
        sCloseAction = "doBack();";
    }
%>
<form name="transactionForm" id="transactionForm" method="post">
    <%=writeTableHeaderDirectText(sTitle,sWebLanguage,sCloseAction)%>
    <%
        if(activePatient==null){
            // display message
            %><%=getTran("web","firstSelectAPerson",sWebLanguage)%><%
        }
        else{
            //*************************************************************************************
            //*** process display options *********************************************************
            //*************************************************************************************
            DecimalFormat doubleFormat = new DecimalFormat("#.#");
            %>
            <table class="list" width="100%" cellspacing="1">
                <tr>
                    <td class="admin"><%=getTran("Web","care_type",sWebLanguage)%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <select class="text" name="EditCareUid" onchange="doChangeCareUID()">
                            <option/>
                            <%=ScreenHelper.writeSelect("care_type",sSelectedCareUid,sWebLanguage,false,true)%>
                        </select>
                    </td>
                </tr>
                <%-- ***** prescription-rule ***** --%>
                <tr>
                    <td class="admin"><%=getTran("Web","frequency",sWebLanguage)%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <%-- Units Per Time Unit --%>
                        <input type="text" class="text" name="EditUnitsPerTimeUnit" value="<%=(sSelectedUnitsPerTimeUnit.length()>0?(doubleFormat.format(Double.parseDouble(sSelectedUnitsPerTimeUnit))).replaceAll(",","."):"")%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                        <%=getTran("web","times",sWebLanguage).toLowerCase()%>

                        <%-- Time Unit Count --%>
                        &nbsp;<%=getTran("web","per",sWebLanguage)%>
                        <input type="text" class="text" name="EditTimeUnitCount" value="<%=sSelectedTimeUnitCount%>" size="5" maxLength="5">

                        <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
                        <select class="text" name="EditTimeUnit" onChange="setEditTimeUnitCount();">
                            <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                            <%=ScreenHelper.writeSelectUnsorted("prescription.timeunit",sSelectedTimeUnit,sWebLanguage)%>
                        </select>

                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearDescriptionRule();">
                    </td>
                </tr>
                <%-- date begin --%>
                <tr>
                    <td class="admin"><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <input type="text" maxlength="10" class="text" id="EditDateBegin" name="EditDateBegin" value="<%=sSelectedDateBegin%>" size="12" onblur="if(!checkDate(this)){alert('Web.Occup','date.error');this.value='';}">
                        <img name="popcal" class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_agenda.gif" alt="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="gfPop1.fPopCalendar(document.getElementById('EditDateBegin'));return false;">
                        <img class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_compose.gif" alt="<%=getTranNoLink("Web","PutToday",sWebLanguage)%>" onclick="getToday(document.getElementById('EditDateBegin'));">
                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDateBegin.value='';">
                    </td>
                </tr>
                <%-- date end --%>
                <tr>
                    <td class="admin"><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <input type="text" maxlength="10" class="text" id="EditDateEnd" name="EditDateEnd" value="<%=sSelectedDateEnd%>" size="12" onblur="if(!checkDate(this)){alert('Web.Occup','date.error');this.value='';}">
                        <img name="popcal" class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_agenda.gif" alt="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="gfPop1.fPopCalendar(document.getElementById('EditDateEnd'));return false;">
                        <img class="link" src="<%=sCONTEXTPATH%>/_img/icons/icon_compose.gif" alt="<%=getTranNoLink("Web","PutToday",sWebLanguage)%>" onclick="getToday(document.getElementById('EditDateEnd'));">
                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDateEnd.value='';">
                    </td>
                </tr>
                <%-- prescriber --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","prescriber",sWebLanguage)%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <input type="hidden" name="EditPrescriberUid" value="<%=sSelectedPrescriberUid%>">
                        <input class="text" type="text" name="EditPrescriberFullName" readonly size="<%=sTextWidth%>" value="<%=sSelectedPrescriberFullName%>">

                        <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrescriber('EditPrescriberUid','EditPrescriberFullName');">
                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditPrescriberUid.value='';transactionForm.EditPrescriberFullName.value='';">
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
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                        <%
                            if(editableByPrescriber){
		                        if(activeUser.getAccessRight("prescriptions.care.add") || activeUser.getAccessRight("prescriptions.care.edit")){
		                            %><input class="button" type="button" name="saveButton" id="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;<%
		                        }
		                        if((activeUser.getAccessRight("prescriptions.care.delete"))&&(sEditPrescrUid.length()>0)){
		                            %><input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditPrescrUid%>');">&nbsp;<%
		                        }
                            }
                            else{
                            	%><font color="red"><%=getTran("web.occup","onlyEditableByPrescriber",sWebLanguage)%></font><%
                            }
                        %>
                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBack();">
                    </td>
                </tr>
            </table>
            
            <%-- indication of obligated fields --%>
            <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%-- display message --%>
            <br><span id="msgArea">&nbsp;<%=msg%></span>
    <%
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditPrescrUid" value="<%=sEditPrescrUid%>">
    <input type="hidden" name="PopupHeight" value="400">
    <input type="hidden" name="PopupWidth" value="900">
</form>
 
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  transactionForm.EditPrescriberFullName.focus();
  var path = '<c:url value="/"/>';

  function doChangeCareUID(){
    if(document.getElementById('EditCareUid').value.length>0){
      var params = 'EditCareUid='+document.getElementById('EditCareUid').value;
      var url = path+'/medical/blurCareType.jsp?ts='+new Date();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('EditUnitsPerTimeUnit').value=label.EditUnitsPerTimeUnit;
          $('EditTimeUnitCount').value=label.EditTimeUnitCount;
          $('EditTimeUnit').value=label.EditTimeUnit;
          $('time1').value=label.time1;
          $('time2').value=label.time2;
          $('time3').value=label.time3;
          $('time4').value=label.time4;
          $('time5').value=label.time5;
          $('time6').value=label.time6;
          $('quantity1').value=label.quantity1;
          $('quantity2').value=label.quantity2;
          $('quantity3').value=label.quantity3;
          $('quantity4').value=label.quantity4;
          $('quantity5').value=label.quantity5;
          $('quantity6').value=label.quantity6;
        }
      });
    }
  }
  <%--DISPLAY ALERT --%>
  function displayAlert(){
    if(transactionForm.EditDateEnd.value.length>0){
      alertDiaog("web.Occup","endMustComeAfterBegin");
      transactionForm.EditDateEnd.focus();
    }
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

  <%-- IS VALID DATE --%>
  function isValidDate(dateObj){
    if(dateObj.value.length==10){
      return checkDate(dateObj);
    }
    return false;
  }

  <%-- IS ENDDATE AFTER BEGINDATE --%>
  function isEndDateAfterBeginDate(){
    if(transactionForm.EditDateBegin.value.length > 0 && transactionForm.EditDateEnd.value.length > 0){
      if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
        var dateBegin = transactionForm.EditDateBegin.value,
            dateEnd   = transactionForm.EditDateEnd.value;

        return !before(dateEnd,dateBegin);
      }
      return false;
    }
    return true;
  }

  <%-- DO ADD --%>
  function doAdd(){
    transactionForm.EditPrescrUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkPrescriptionFields()){
      if(transactionForm.returnButton!=undefined) transactionForm.returnButton.disabled = true;
      if(transactionForm.saveButton!=undefined) transactionForm.saveButton.disabled = true;
      if(transactionForm.deleteButton!=undefined) transactionForm.deleteButton.disabled = true;

      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditUnitsPerTimeUnit.value.length==0){
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
      else if(transactionForm.EditPrescriberUid.value.length==0){
        transactionForm.EditPrescriberFullName.focus();
      }
    }
  }

  <%-- CHECK PRESCRIPTION FIELDS --%>
  function checkPrescriptionFields(){
    var maySubmit = false;

    <%-- required fields --%>
    if(!transactionForm.EditPrescriberUid.value.length==0 &&
       !transactionForm.EditCareUid.value.length==0 &&
       !transactionForm.EditTimeUnit.value.length==0 &&
       !transactionForm.EditDateBegin.value.length==0 &&
       !transactionForm.EditDateEnd.value.length==0 &&
       !transactionForm.EditTimeUnitCount.value.length==0 &&
       !transactionForm.EditUnitsPerTimeUnit.value.length==0){

       <%-- check dates --%>
       if(isValidDate(transactionForm.EditDateBegin) && isValidDate(transactionForm.EditDateEnd)){
         if(isEndDateAfterBeginDate()){
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
                alertDialog("web.manage","dataMissing");
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(prescriptionUid){
      if(yesnoDeleteDialog()){
      transactionForm.EditPrescrUid.value = prescriptionUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
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
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,unitsPerPackageField,productStockUidField,serviceStockUidField){
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

  <%-- popup : search prescriber --%>
  function searchPrescriber(prescriberUidField,prescriberNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+prescriberUidField+"&ReturnName="+prescriberNameField+"&displayImmatNew=no");
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href="<c:url value='/popup.jsp'/>?Page=medical/manageCarePrescriptionsPopup.jsp&ts="+new Date();
    }
  }
  
  <%-- The following script is used to hide the calendar whenever you click the document. --%>
  <%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
  document.onmousedown = function(e){
    var n = !e?self.event.srcElement.name:e.target.name;

    if(document.layers){
      with(gfPop) var l = pageX, t = pageY, r = l+clip.width, b = t+clip.height;
      if(n!="popcal" && (e.pageX > r || e.pageX < l || e.pageY > b || e.pageY < t)){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
      }
      return routeEvent(e);
    }
    else if(n!="popcal"){
      gfPop1.fHideCal();
      gfPop2.fHideCal();
      gfPop3.fHideCal();
    }
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>