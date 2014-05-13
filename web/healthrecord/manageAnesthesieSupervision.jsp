<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.surveillance_anesthesie","select",activeUser)%>

<%!
    private StringBuffer addSA(int iTotal,String sHeure,String sSys,String sDias,String sRythme,String sStage,String sFreq,String sSat, String sMedication, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        if (sStage.length()>0){
            sStage = getTran("anesthesie_stage",sStage,sWebLanguage);
        }
        sTmp.append(
                    "<tr id='rowSA"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='#' onclick='deleteSA(rowSA"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='#' onclick='editSA(rowSA"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sHeure + "</td>" +
                        "<td class=\"admin2\">&nbsp;" +sSys + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sDias + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sRythme + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sStage + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sFreq + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sSat + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sMedication + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }
%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
<%
    StringBuffer sDivSA = new StringBuffer();
    StringBuffer sSA    = new StringBuffer();
    int iSATotal = 0;

    if (transaction != null){
        TransactionVO tran = (TransactionVO)transaction;
        if (tran!=null){
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION1"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION2"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION3"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION4"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION5"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION6"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION7"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION8"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION9"));
            sSA.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION10"));
        }

        iSATotal = 1;

        if (sSA.indexOf("£")>-1){
            StringBuffer sTmpSA = sSA;
            String sTmpHeure, sTmpSys, sTmpDias, sTmpRythme, sTmpStage, sTmpFreq,sTmpSat,sTmpMedication;
            sSA = new StringBuffer();

            while (sTmpSA.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpSys = "";
                sTmpDias = "";
                sTmpRythme = "";
                sTmpStage = "";
                sTmpFreq = "";
                sTmpSat = "";
                sTmpMedication = "";

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSys = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDias = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpRythme = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpStage = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpFreq = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSat = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("£"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSA.toString().toLowerCase().indexOf("$")>-1){
                    sTmpMedication = sTmpSA.substring(0,sTmpSA.toString().toLowerCase().indexOf("$"));
                    sTmpSA = new StringBuffer(sTmpSA.substring(sTmpSA.toString().toLowerCase().indexOf("$")+1));
                }

                sSA.append("rowSA"+iSATotal+"="+sTmpHeure+"£"+sTmpSys+"£"+sTmpDias+"£"+sTmpRythme+"£"+sTmpStage+"£"+sTmpFreq+"£"+sTmpSat+"£"+sTmpMedication+"$");
                sDivSA.append(addSA(iSATotal, sTmpHeure, sTmpSys, sTmpDias,sTmpRythme,sTmpStage,sTmpFreq,sTmpSat,sTmpMedication, sWebLanguage));
                iSATotal++;
            }
        }
    }
%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr><td/></tr>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblSA" class="list">
                    <tr>
                        <td class="admin" width="40" rowspan="2"/>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin" width="100" colspan="2"><center><%=getTran("openclinic.chuk","ta",sWebLanguage)%></center></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","heartfrequency",sWebLanguage)%></td>
                        <td class="admin" width="90" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","stage",sWebLanguage)%></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","respiration",sWebLanguage)%></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","sa",sWebLanguage)%> O2</td>
                        <td class="admin" width="150" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","medication",sWebLanguage)%></td>
                        <td class="admin" rowspan="2"/>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("openclinic.chuk","sys",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","dias",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="text" class="text" size="5" name="svheure" value="" onblur="checkTime(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svsys" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svdias" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svrythme" value="" onblur="isNumber(this);"> /min
                        </td>
                        <td class="admin2">
                            <select class="text" name="svstage">
                                <option/>
                                <option value="pre_anesthesie"><%=getTran("anesthesie_stage","pre_anesthesie",sWebLanguage)%></option>
                                <option value="anesthesie"><%=getTran("anesthesie_stage","anesthesie",sWebLanguage)%></option>
                                <option value="post_anesthesie"><%=getTran("anesthesie_stage","post_anesthesie",sWebLanguage)%></option>
                            </select>
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svfreq" value="" onblur="isNumber(this);"> /min
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svsat" value="" onblur="isNumber(this);"> %
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="50" name="svmedication" value="">
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddSA" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSA();">
                            <input type="button" class="button" name="ButtonUpdateSA" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateSA();">
                        </td>
                    </tr>
                    <%=sDivSA%>
                </table>
            </td>
        </tr>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION5" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION6" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION7" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION8" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION9" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION10" property="itemId"/>]>.value">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.surveillance_anesthesie.add") || activeUser.getAccessRight("occup.surveillance_anesthesie.edit")){
    %>
                <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>
<script>
var iSAIndex = <%=iSATotal%>;
var sSA = "<%=sSA%>";
var editSARowid = "";

function addSA(){
  if(isAtLeastOneSAFieldFilled()){
      iSAIndex++;
      if(transactionForm.svheure.value == ""){
        getTime(transactionForm.svheure);
      }
      sSA+="rowSA"+iSAIndex+"="+transactionForm.svheure.value+"£"
                             +transactionForm.svsys.value+"£"
                             +transactionForm.svdias.value+"£"
                             +transactionForm.svrythme.value+"£"
                             +transactionForm.svstage.value+"£"
                             +transactionForm.svfreq.value+"£"
                             +transactionForm.svsat.value+"£"
                             +transactionForm.svmedication.value+"$";
      var tr;
      tr = tblSA.insertRow(tblSA.rows.length);
      tr.id = "rowSA"+iSAIndex;

      var sDescrStage = checkStage();


      var td = tr.insertCell(0);
      td.innerHTML = "<a href='#' onclick='deleteSA(rowSA"+iSAIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='#' onclick='editSA(rowSA"+iSAIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.svheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.svsys.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.svdias.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.svrythme.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+sDescrStage;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;"+transactionForm.svfreq.value;
      tr.appendChild(td);

      td = tr.insertCell(7);
      td.innerHTML = "&nbsp;"+transactionForm.svsat.value;
      tr.appendChild(td);

      td = tr.insertCell(8);
      td.innerHTML = "&nbsp;"+transactionForm.svmedication.value;
      tr.appendChild(td);

      td = tr.insertCell(9);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSAFields()
      transactionForm.ButtonUpdateSA.disabled = true;
  }
  return true;
}

function checkStage(){
      var sDescrStage = "";
      if (transactionForm.svstage.value=="pre_anesthesie"){
          sDescrStage = "<%=getTran("anesthesie_stage","pre_anesthesie",sWebLanguage)%>";
      }
      else if (transactionForm.svstage.value=="anesthesie"){
          sDescrStage = "<%=getTran("anesthesie_stage","anesthesie",sWebLanguage)%>";
      }
      else if (transactionForm.svstage.value=="post_anesthesie"){
          sDescrStage = "<%=getTran("anesthesie_stage","post_anesthesie",sWebLanguage)%>";
      }

    return sDescrStage;
}

function updateSA(){
  if(isAtLeastOneSAFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.svheure.value == ""){
        getTime(transactionForm.svheure);
      }
    newRow = editSARowid.id+"="
                         +transactionForm.svheure.value+"£"
                         +transactionForm.svsys.value+"£"
                         +transactionForm.svdias.value+"£"
                         +transactionForm.svrythme.value+"£"
                         +transactionForm.svstage.value+"£"
                         +transactionForm.svfreq.value+"£"
                         +transactionForm.svsat.value+"£"
                         +transactionForm.svmedication.value;

    sSA = replaceRowInArrayString(sSA,newRow,editSARowid.id);
    var sDescrStage = checkStage();

    <%-- update table object --%>
    row = tblSA.rows[editSARowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteSA("+editSARowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editSA("+editSARowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.svheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.svsys.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.svdias.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.svrythme.value;
    row.cells[5].innerHTML = "&nbsp;"+sDescrStage;
    row.cells[6].innerHTML = "&nbsp;"+transactionForm.svfreq.value;
    row.cells[7].innerHTML = "&nbsp;"+transactionForm.svsat.value;
    row.cells[8].innerHTML = "&nbsp;"+transactionForm.svmedication.value;

    setCellStyle(row);
    <%-- reset --%>
    clearSAFields();
    transactionForm.ButtonUpdateSA.disabled = true;
  }
}

function isAtLeastOneSAFieldFilled(){
  //if(transactionForm.svheure.value != "")       return true;
  if(transactionForm.svsys.value != "")         return true;
  if(transactionForm.svdias.value != "")        return true;
  if(transactionForm.svrythme.value != "")      return true;
  if(transactionForm.svstage.value != "")        return true;
  if(transactionForm.svfreq.value != "")        return true;
  if(transactionForm.svsat.value != "")         return true;
  if(transactionForm.svmedication.value != "") return true;
  return false;
}

function clearSAFields(){
  transactionForm.svheure.value = "";
  transactionForm.svsys.value = "";
  transactionForm.svdias.value = "";
  transactionForm.svrythme.value = "";
  transactionForm.svstage.value = "";
  transactionForm.svfreq.value = "";
  transactionForm.svsat.value = "";
  transactionForm.svmedication.value = "";
}

function deleteSA(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sSA = deleteRowFromArrayString(sSA,rowid.id);
    tblSA.deleteRow(rowid.rowIndex);
    clearSAFields();
  }
}

function editSA(rowid){
  var row = getRowFromArrayString(sSA,rowid.id);
  transactionForm.svheure.value = getCelFromRowString(row,0);
  transactionForm.svsys.value = getCelFromRowString(row,1);
  transactionForm.svdias.value = getCelFromRowString(row,2);
  transactionForm.svrythme.value = getCelFromRowString(row,3);
  transactionForm.svstage.value = getCelFromRowString(row,4);
  transactionForm.svfreq.value = getCelFromRowString(row,5);
  transactionForm.svsat.value = getCelFromRowString(row,6);
  transactionForm.svmedication.value = getCelFromRowString(row,7);

  editSARowid = rowid;
  transactionForm.ButtonUpdateSA.disabled = false;
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

function submitForm() {
    var maySubmit = true;

    if (isAtLeastOneSAFieldFilled()) {
        if (maySubmit) {
            if (!addBio()) {
                maySubmit = false;
            }
        }
    }

    var sTmpBegin;
    var sTmpEnd;
    while (sSA.indexOf("rowSA") > -1) {
        sTmpBegin = sSA.substring(sSA.indexOf("rowSA"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sSA = sSA.substring(0, sSA.indexOf("rowSA")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION1" property="itemId"/>]>.value")[0].value = sSA.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION2" property="itemId"/>]>.value")[0].value = sSA.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION3" property="itemId"/>]>.value")[0].value = sSA.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION4" property="itemId"/>]>.value")[0].value = sSA.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION5" property="itemId"/>]>.value")[0].value = sSA.substring(1016,1270);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION6" property="itemId"/>]>.value")[0].value = sSA.substring(1270,1524);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION7" property="itemId"/>]>.value")[0].value = sSA.substring(1524,1778);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION8" property="itemId"/>]>.value")[0].value = sSA.substring(1778,2032);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION9" property="itemId"/>]>.value")[0].value = sSA.substring(2032,2286);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIE_SUPERVISION10" property="itemId"/>]>.value")[0].value = sSA.substring(2286,2540);
    if(maySubmit){
      transactionForm.saveButton.disabled = true;
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
}

function setCellStyle(row){
    for(i =0;i<row.cells.length;i++){
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
</script>