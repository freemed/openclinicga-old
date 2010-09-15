<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.protocol.images.stomatology","select",activeUser)%>
<%!
    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    private StringBuffer addImagesInformation(int iTotal,String sTmpInfo, String sNomenclature,String sResultsRx,String sWebLanguage){
        if (sTmpInfo.length()>0){
            sTmpInfo = getTran("web.occup",sTmpInfo,sWebLanguage);
        }
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowImagesInformation"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='#' onclick='deleteImagesInformation(rowImagesInformation"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='#' onclick='editImagesInformation(rowImagesInformation"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sTmpInfo + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sNomenclature + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sResultsRx + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <%
        StringBuffer sImagesInformation = new StringBuffer();
        StringBuffer sDivImagesInformation = new StringBuffer();
        int iImagesInformationTotal;

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                sImagesInformation.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION1"));
                sImagesInformation.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION2"));
                sImagesInformation.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION3"));
                sImagesInformation.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION4"));
                sImagesInformation.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION5"));
            }
        }

        iImagesInformationTotal = 1;

        if (sImagesInformation.indexOf("£")>-1){
            StringBuffer sTmpImagesInformation = sImagesInformation;
            String sTmpNomenclature,sTmpResultsRx, sTmpInfo;
            sImagesInformation = new StringBuffer();

            while (sTmpImagesInformation.toString().toLowerCase().indexOf("$")>-1) {
                sTmpInfo = "";
                sTmpNomenclature  = "";
                sTmpResultsRx = "";

                if (sTmpImagesInformation.toString().toLowerCase().indexOf("£")>-1){
                    sTmpInfo = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("£"));
                    sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpImagesInformation.toString().toLowerCase().indexOf("£")>-1){
                    sTmpNomenclature = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("£"));
                    sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpImagesInformation.toString().toLowerCase().indexOf("$")>-1){
                    sTmpResultsRx = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("$"));
                    sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("$")+1));
                }

                sImagesInformation.append("rowImagesInformation"+iImagesInformationTotal+"="+sTmpInfo+"£"+sTmpNomenclature+"£"+sTmpResultsRx+"$");
                sDivImagesInformation.append(addImagesInformation(iImagesInformationTotal, sTmpInfo, sTmpNomenclature, sTmpResultsRx, sWebLanguage));
                iImagesInformationTotal++;
            }
        }
    %>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td>
                <table cellspacing="1" cellpadding="0" width="100%" id="tblImagesInformation">
                    <tr>
                        <td class="admin" width="40px"/>
                        <td class="admin" width="40px"/>
                        <td class="admin" width="50px"><%=getTran("openclinic.chuk","nomenclatue",sWebLanguage)%></td>
                        <td class="admin" width="250px"><%=getTran("openclinic.chuk","results_rx",sWebLanguage)%></td>
                        <td class="admin" width="*"/>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input id="rbinfocliche" onDblClick="uncheckRadio(this);"type="radio" name="rbinfo" value="image.information.cliche"/>
                            <%=getLabel("web.occup","image.information.cliche",sWebLanguage,"rbinfocliche")%>

                            <input id="rbinfopano" onDblClick="uncheckRadio(this);"type="radio" name="rbinfo" value="image.information.pano"/>
                            <%=getLabel("web.occup","image.information.pano",sWebLanguage,"rbinfopano")%>
                        </td>
                        <td class="admin2" valign="top">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="nomenclature"></textarea>
                        </td>
                        <td class="admin2" valign="top">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="resultsrx"></textarea>
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddImagesInformation" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addImagesInformation();">
                            <input type="button" class="button" name="ButtonUpdateImagesInformation" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateImagesInformation();">
                        </td>
                    </tr>

                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION1" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION2" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION3" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION4" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION5" property="itemId"/>]>.value">
                    <%=sDivImagesInformation%>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_CONCLUSION")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.protocol.images.stomatology.add") || activeUser.getAccessRight("occup.protocol.images.stomatology.edit")){
    %>
                <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm();"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>

</form>
<script type="text/javascript">
var iImagesInformationIndex = <%=iImagesInformationTotal%>;
var sImagesInformation = "<%=sImagesInformation%>";
var editImagesInformationRowid = "";
<!-- IMAGESINFORMATION -->

function addImagesInformation(){
  if(isAtLeastOneImagesInformationFieldFilled()){
      iImagesInformationIndex++;
      var sInfo = "";
      var sTmpInfo = "";
      if (document.getElementById("rbinfocliche").checked){
          sInfo = "<%=getTran("web.occup","image.information.cliche",sWebLanguage)%>";
          sTmpInfo = "image.information.cliche";
      }
      else if (document.getElementById("rbinfopano").checked){
          sInfo = "<%=getTran("web.occup","image.information.pano",sWebLanguage)%>";
          sTmpInfo = "image.information.pano";
      }

      sImagesInformation+="rowImagesInformation"+iImagesInformationIndex+"="+sTmpInfo+"£"+transactionForm.nomenclature.value+"£"
                         +transactionForm.resultsrx.value+"$";
      var tr;
      tr = tblImagesInformation.insertRow(tblImagesInformation.rows.length);
      tr.id = "rowImagesInformation"+iImagesInformationIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='#' onclick='deleteImagesInformation(rowImagesInformation"+iImagesInformationIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='#' onclick='editImagesInformation(rowImagesInformation"+iImagesInformationIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+sInfo;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.nomenclature.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.resultsrx.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearImagesInformationFields()
      transactionForm.ButtonUpdateImagesInformation.disabled = true;
  }
  return true;
}

function updateImagesInformation(){
  if(isAtLeastOneImagesInformationFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;

      var sInfo = "";
      var sTmpInfo = "";
      if (document.getElementById("rbinfocliche").checked){
          sInfo = "<%=getTran("web.occup","image.information.cliche",sWebLanguage)%>";
          sTmpInfo = "image.information.cliche";
      }
      else if (document.getElementById("rbinfopano").checked){
          sInfo = "<%=getTran("web.occup","image.information.pano",sWebLanguage)%>";
          sTmpInfo = "image.information.pano";
      }
    newRow = editImagesInformationRowid.id+"="+sTmpInfo+"£"+transactionForm.nomenclature.value+"£"
                                    +transactionForm.resultsrx.value;

    sImagesInformation = replaceRowInArrayString(sImagesInformation,newRow,editImagesInformationRowid.id);

    <%-- update table object --%>
    row = tblImagesInformation.rows[editImagesInformationRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteImagesInformation("+editImagesInformationRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editImagesInformation("+editImagesInformationRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+sInfo;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.nomenclature.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.resultsrx.value;

    setCellStyle(row);
    <%-- reset --%>
    clearImagesInformationFields();
    transactionForm.ButtonUpdateImagesInformation.disabled = true;
  }
}

function isAtLeastOneImagesInformationFieldFilled(){
  if(transactionForm.nomenclature.value != "") return true;
  if(transactionForm.resultsrx.value != "") return true;
  return false;
}

function clearImagesInformationFields(){
  document.getElementById("rbinfocliche").checked = false;
  document.getElementById("rbinfopano").checked = false;
  transactionForm.nomenclature.value = "";
  transactionForm.resultsrx.value = "";
}

function deleteImagesInformation(rowid){
  var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
  var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
  var answer;

  if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,'',modalitiesIE);
  }else{
      answer = window.confirm("<%=getTran("web","areyousuretodelete",sWebLanguage)%>");
  }

  if(answer==1){
    sImagesInformation = deleteRowFromArrayString(sImagesInformation,rowid.id);
    tblImagesInformation.deleteRow(rowid.rowIndex);
    clearImagesInformationFields();
  }
}

function editImagesInformation(rowid){
  var row = getRowFromArrayString(sImagesInformation,rowid.id);
  if (getCelFromRowString(row,0) == "image.information.cliche"){
      document.getElementById("rbinfocliche").checked = true;
  }
  else if (getCelFromRowString(row,0) == "image.information.pano"){
      document.getElementById("rbinfopano").checked = true;
  }
  transactionForm.nomenclature.value = getCelFromRowString(row,1);
  transactionForm.resultsrx.value = getCelFromRowString(row,2);

  editImagesInformationRowid = rowid;
  transactionForm.ButtonUpdateImagesInformation.disabled = false;
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
    //alert("1: " + array);
    var result = array.join("$");
    //alert("2: " + array);
    return result;//.substring(0, result.length - 1);
}

function submitForm() {
    var maySubmit = true;

    if (isAtLeastOneImagesInformationFieldFilled()) {
        if (maySubmit) {
            if (!addImagesInformation()) {
                maySubmit = false;
            }
        }
    }

    var sTmpBegin;
    var sTmpEnd;

    while (sImagesInformation.indexOf("rowImagesInformation") > -1) {
        sTmpBegin = sImagesInformation.substring(sImagesInformation.indexOf("rowImagesInformation"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sImagesInformation = sImagesInformation.substring(0, sImagesInformation.indexOf("rowImagesInformation")) + sTmpEnd;
    }

    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION1" property="itemId"/>]>.value"].value = sImagesInformation.substring(0,254);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION2" property="itemId"/>]>.value"].value = sImagesInformation.substring(254,508);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION3" property="itemId"/>]>.value"].value = sImagesInformation.substring(508,762);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION4" property="itemId"/>]>.value"].value = sImagesInformation.substring(762,1016);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION5" property="itemId"/>]>.value"].value = sImagesInformation.substring(1016, 1270);

    if(maySubmit){
      document.transactionForm.save.disabled = true;
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
}

function setCellStyle(row){
    for(var i =0;i<row.cells.length;i++){
        row.cells[i].style.color = "#333333";
        row.cells[i].style.fontFamily = "Verdana";
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
</script>
<%=writeJSButtons("transactionForm","save")%>