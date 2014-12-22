<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("occup.biometricexamination","select",activeUser)%>

<%!
    //--- ADD BIO ---------------------------------------------------------------------------------
    private StringBuffer addBio(int iTotal,String sDate,String sWeight,String sHeight,String sSkull,String sFood,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        if (sFood.length()>0){
            sFood = getTran("biometry_food",sFood,sWebLanguage);
        }

        sTmp.append(
            "<tr id='rowBio"+iTotal+"'>"+
                "<td class=\"admin2\">"+
                "   <a href='javascript:deleteBio(rowBio"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a>"+
                "   <a href='javascript:editBio(rowBio"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>"+
                "</td>" +
                "<td class=\"admin2\">&nbsp;"+sDate+"</td>"+
                "<td class=\"admin2\">&nbsp;"+sWeight+"</td>"+
                "<td class=\"admin2\">&nbsp;"+sHeight+"</td>"+
                "<td class=\"admin2\">&nbsp;"+sSkull+"</td>"+
                "<td class=\"admin2\">&nbsp;"+sFood+"</td>"+
                "<td class=\"admin2\">"+
                "</td>"+
            "</tr>"
        );

        return sTmp;
    }
%>

<script>
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value="/main.do?Page=curative/index.jsp&ts="/><%=getTs()%>";
    }
  }
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
<%
    StringBuffer sDivBio = new StringBuffer();
    StringBuffer sBio    = new StringBuffer();
    int iBioTotal = 0;

    if (transaction != null){
        TransactionVO tran = (TransactionVO)transaction;
        if (tran!=null){
            sBio.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER1"));
            sBio.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER2"));
            sBio.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER3"));
            sBio.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER4"));
            sBio.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER5"));
        }

        iBioTotal = 1;

        if (sBio.indexOf("£")>-1){
            StringBuffer sTmpBio = sBio;
            String sTmpDate, sTmpWeight, sTmpHeight, sTmpSkull, sTmpFood;
            sBio = new StringBuffer();

            while (sTmpBio.toString().toLowerCase().indexOf("$")>-1) {
                sTmpDate = "";
                sTmpWeight = "";
                sTmpHeight = "";
                sTmpSkull = "";
                sTmpFood = "";

                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpDate = ScreenHelper.convertDate(sTmpDate);
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpWeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSkull = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("$")>-1){
                    sTmpFood = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("$"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$")+1));
                }

                sBio.append("rowBio"+iBioTotal+"="+sTmpDate+"£"+sTmpWeight+"£"+sTmpHeight+"£"+sTmpSkull+"£"+sTmpFood+"$");
                sDivBio.append(addBio(iBioTotal, sTmpDate, sTmpWeight, sTmpHeight,sTmpSkull,sTmpFood, sWebLanguage));
                iBioTotal++;
            }
        }
    }
%>
<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td class="admin">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
        </td>
    </tr>

    <tr><td/></tr>

    <tr>
        <td colspan="2">
            <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblBio" class="list">
                <tr>
                    <td class="admin" width="40"/>
                    <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                    <td class='admin' width="120"><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%></td>
                    <td class='admin' width="120"><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%></td>
                    <td class='admin' width="120"><%=getTran("openclinic.chuk","skull",sWebLanguage)%></td>
                    <td class='admin'><%=getTran("openclinic.chuk","food",sWebLanguage)%></td>
                    <td class='admin'/>
                </tr>
                <tr>
                    <td class="admin2"/>
                    <td class="admin2"><%=writeDateField("EditDate","transactionForm",getDate(),sWebLanguage)%></td>
                    <td class='admin2'><input class="text" type="text" size="10" name="EditWeight" onBlur="validateWeight(this);"/></td>
                    <td class='admin2'><input class="text" type="text" size="10" name="EditHeight" onBlur="validateHeight(this);"/></td>
                    <td class='admin2'><input class="text" type="text" size="10" name="EditSkull" onBlur="isNumber(this);"/></td>
                    <td class="admin2">
                        <select class="text" name="EditFood">
                            <option/>
                            <option value="food_phase1"><%=getTran("biometry_food","food_phase1",sWebLanguage)%></option>
                            <option value="food_phase2"><%=getTran("biometry_food","food_phase2",sWebLanguage)%></option>
                            <option value="food_phase3"><%=getTran("biometry_food","food_phase3",sWebLanguage)%></option>
                            <option value="food_good"><%=getTran("biometry_food","food_good",sWebLanguage)%></option>
                        </select>
                    </td>
                    <td class="admin2">
                        <input type="button" class="button" name="ButtonAddBio" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addBio();">
                        <input type="button" class="button" name="ButtonUpdateBio" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateBio();">
                    </td>
                </tr>
                <%=sDivBio%>
            </table>
        </td>
    </tr>

    <tr>
        <td class="admin"/>
        <td class="admin2">
<%-- BUTTONS --%>
    <%
        if(activeUser.getAccessRight("occup.biometricexamination.add") || activeUser.getAccessRight("occup.biometricexamination.edit")) {
        %>
            <INPUT class="button" name="saveButton" id="saveButton" type="button" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
        <%
        }
    %>
            <INPUT class="button" type="button" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>

<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER1" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER2" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER3" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER4" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER5" property="itemId"/>]>.value">

<script>
  <%-- VALIDATE WEIGHT --%>
  <%
      int minWeight = 35;
      int maxWeight = 160;

      String weightMsg = getTran("Web.Occup","medwan.healthrecord.biometry.weight.validationerror",sWebLanguage);
      weightMsg = weightMsg.replaceAll("#min#",minWeight+"");
      weightMsg = weightMsg.replaceAll("#max#",maxWeight+"");
  %>
  function validateWeight(weightInput){
    weightInput.value = weightInput.value.replace(",",".");
    if(weightInput.value.length > 0){
      var min = <%=minWeight%>;
      var max = <%=maxWeight%>;

      if (isNaN(weightInput.value) || weightInput.value < min || weightInput.value > max){
    	alertDialogDirectText("<%=weightMsg%>");
        //weightInput.value = "";
        weightInput.focus();
      }
    }
  }

  <%-- VALIDATE HEIGHT --%>
  <%
      int minHeight = 120;
      int maxHeight = 220;

      String heightMsg = getTran("Web.Occup","medwan.healthrecord.biometry.height.validationerror",sWebLanguage);
      heightMsg = heightMsg.replaceAll("#min#",minHeight+"");
      heightMsg = heightMsg.replaceAll("#max#",maxHeight+"");
  %>
  function validateHeight(heightInput){
    heightInput.value = heightInput.value.replace(",",".");
    if(heightInput.value.length > 0){
      var min = <%=minHeight%>;
      var max = <%=maxHeight%>;

      if (isNaN(heightInput.value) || heightInput.value < min || heightInput.value > max){
        alertDialogDirectText("<%=heightMsg%>");
        //heightInput.value = "";
        heightInput.focus();
      }
    }
  }

var iBioIndex = <%=iBioTotal%>;
var sBio = "<%=sBio%>";
var editBioRowid = "";

function addBio(){
  if(isAtLeastOneBioFieldFilled()){
      iBioIndex++;
      sBio+="rowBio"+iBioIndex+"="+transactionForm.EditDate.value+"£"
                             +transactionForm.EditWeight.value+"£"
                             +transactionForm.EditHeight.value+"£"
                             +transactionForm.EditSkull.value+"£"
                             +transactionForm.EditFood.value+"$";
      var tr;
      tr = tblBio.insertRow(tblBio.rows.length);
      tr.id = "rowBio"+iBioIndex;

      var sDescrFood = checkFood();

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteBio(rowBio"+iBioIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editBio(rowBio"+iBioIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.EditDate.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.EditWeight.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.EditHeight.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.EditSkull.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+sDescrFood;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearBioFields()
      transactionForm.ButtonUpdateBio.disabled = true;
  }
  return true;
}

function checkFood(){
  var sDescrFood = "";
  if (transactionForm.EditFood.value=="food_phase1"){
    sDescrFood = "<%=getTranNoLink("biometry_food","food_phase1",sWebLanguage)%>";
  }
  else if (transactionForm.EditFood.value=="food_phase2"){
    sDescrFood = "<%=getTranNoLink("biometry_food","food_phase2",sWebLanguage)%>";
  }
  else if (transactionForm.EditFood.value=="food_phase3"){
    sDescrFood = "<%=getTranNoLink("biometry_food","food_phase3",sWebLanguage)%>";
  }
  else if (transactionForm.EditFood.value=="food_good"){
    sDescrFood = "<%=getTranNoLink("biometry_food","food_good",sWebLanguage)%>";
  }

  return sDescrFood;
}

function updateBio(){
  if(isAtLeastOneBioFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;

    newRow = editBioRowid.id+"="
                         +transactionForm.EditDate.value+"£"
                         +transactionForm.EditWeight.value+"£"
                         +transactionForm.EditHeight.value+"£"
                         +transactionForm.EditSkull.value+"£"
                         +transactionForm.EditFood.value;

    sBio = replaceRowInArrayString(sBio,newRow,editBioRowid.id);
    var sDescrFood = checkFood();

    <%-- update table object --%>
    row = tblBio.rows[editBioRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteBio("+editBioRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editBio("+editBioRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.EditDate.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.EditWeight.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.EditHeight.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.EditSkull.value;
    row.cells[5].innerHTML = "&nbsp;"+sDescrFood;

    setCellStyle(row);
    <%-- reset --%>
    clearBioFields();
    transactionForm.ButtonUpdateBio.disabled = true;
  }
}

function isAtLeastOneBioFieldFilled(){
  if(transactionForm.EditDate.value != "")         return true;
  if(transactionForm.EditWeight.value != "")        return true;
  if(transactionForm.EditHeight.value != "")      return true;
  if(transactionForm.EditSkull.value != "")        return true;
  if(transactionForm.EditFood.value != "")        return true;
  return false;
}

function clearBioFields(){
  transactionForm.EditDate.value = "";
  transactionForm.EditWeight.value = "";
  transactionForm.EditHeight.value = "";
  transactionForm.EditSkull.value = "";
  transactionForm.EditFood.value = "";
}

function deleteBio(rowid){
    if(yesnoDeleteDialog()){
    sBio = deleteRowFromArrayString(sBio,rowid.id);
    tblBio.deleteRow(rowid.rowIndex);
    clearBioFields();
  }
}

function editBio(rowid){
  var row = getRowFromArrayString(sBio,rowid.id);
  transactionForm.EditDate.value = getCelFromRowString(row,0);
  transactionForm.EditWeight.value = getCelFromRowString(row,1);
  transactionForm.EditHeight.value = getCelFromRowString(row,2);
  transactionForm.EditSkull.value = getCelFromRowString(row,3);
  transactionForm.EditFood.value = getCelFromRowString(row,4);
  editBioRowid = rowid;
  transactionForm.ButtonUpdateBio.disabled = false;
}

<!-- GENERAL FUNCTIONS -->
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
    }
  }
  return array.join("$");
}

function getRowFromArrayString(sArray, rowid) {
    var array = sArray.split("$");
    var row = "";
    for (var i = 0; i < array.length; i++) {
        if (array[i].indexOf(rowid) > -1) {
            row = array[i].substring(array[i].indexOf("=") + 1);
            break;
        }
    }
    return row;
}

function getCelFromRowString(sRow, celid) {
    var row = sRow.split("£");
    return row[celid];
}

function replaceRowInArrayString(sArray, newRow, rowid) {
    var array = sArray.split("$");
    for (var i = 0; i < array.length; i++) {
        if (array[i].indexOf(rowid) > -1) {
            array.splice(i, 1, newRow);
            break;
        }
    }
    var result = array.join("$");
    return result;//.substring(0, result.length - 1);
}

function setCellStyle(row){
    for(var i =0;i<row.cells.length;i++){
        row.cells[i].style.color = "#333333";
        row.cells[i].style.fontFamily = "arial";
        row.cells[i].style.fontSize = "10px";
        row.cells[i].style.fontWeight = "normal";
        row.cells[i].style.textAlign = "left";
        row.cells[i].style.paddingLeft = "5px";
        row.cells[i].style.paddingRight = "1px";
        row.cells[i].style.paddingTop = "1px";
        row.cells[i].style.paddingBottom = "1px";
        row.cells[i].style.backgroundColor = "#E0EBF2";
    }
}

  <%-- SUBMIT FORM --%>
  function submitForm(){
    var maySubmit = true;
    if (isAtLeastOneBioFieldFilled()) {
        if (!addBio()) {
            maySubmit = false;
        }
    }
    transactionForm.saveButton.disabled = true;

    var sTmpBegin;
    var sTmpEnd;
    while (sBio.indexOf("rowBio") > -1) {
        sTmpBegin = sBio.substring(sBio.indexOf("rowBio"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sBio = sBio.substring(0, sBio.indexOf("rowBio")) + sTmpEnd;
    }
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER1" property="itemId"/>]>.value")[0].value = sBio.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER2" property="itemId"/>]>.value")[0].value = sBio.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER3" property="itemId"/>]>.value")[0].value = sBio.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER4" property="itemId"/>]>.value")[0].value = sBio.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_PARAMETER5" property="itemId"/>]>.value")[0].value = sBio.substring(1016,1270);

    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>