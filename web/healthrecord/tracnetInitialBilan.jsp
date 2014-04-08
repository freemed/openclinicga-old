<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.tracnet.initial.bilan","select",activeUser)%>
<%!
    //--- ADD SUPERVISION -------------------------------------------------------------------------
    private StringBuffer addOther(int iTotal,String sName,String sValue,String sUnit, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();

        sTmp.append("<tr id='rowOther"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteOther(rowOther"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editOther(rowOther"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sName + "</td>")
             .append("<td class='admin2'>&nbsp;" +sValue + "</td>")
             .append("<td class='admin2'>&nbsp;" + sUnit + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }
%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
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
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.cd4",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_CD4")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_CD4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_CD4" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.cellspermm3",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.cv",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_CV")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_CV" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_CV" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.cppermm3",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.hb",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_HB")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_HB" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_HB" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.gperl",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.htc",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_HTC")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_HTC" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_HTC" property="value"/>" onblur="isNumber(this);"/>
                %
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.gb",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_GB")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_GB" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_GB" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.cellspermm3",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.neutro",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_NEUTRO")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_NEUTRO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_NEUTRO" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.cellspermm3",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.lympho",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_LYMPHO")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_LYMPHO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_LYMPHO" property="value"/>" onblur="isNumber(this);"/>
                <%=getTran("openclinic.chuk","tracnet.cellspermm3",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.plaquettes",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_PLAQUETTES")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_PLAQUETTES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_PLAQUETTES" property="value"/>" onblur="isNumber(this);"/>
                10E3/mm3
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.alat",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_ALAT")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_ALAT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_ALAT" property="value"/>" onblur="isNumber(this);"/>
                IU/l
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.other",sWebLanguage)%></td>
            <td class="admin2">
                <table class="list" cellspacing="1" cellpadding="0" id="tblOther">
                    <tr>
                        <td class="admin" width="40"/>
                        <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.other.name",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.other.value",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.other.unit",sWebLanguage)%></td>
                        <td class="admin"/>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2"><input type="text" class="text" name="otherName" size="50"></td>
                        <td class="admin2"><input type="text" class="text" name="otherValue" size="5"></td>
                        <td class="admin2"><input type="text" class="text" name="otherUnit" size="5"></td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddOther" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addOther();">
                            <input type="button" class="button" name="ButtonUpdateOther" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateOther();">
                        </td>
                    </tr>
                    <%
        StringBuffer sDivOther = new StringBuffer(),
                     sOther    = new StringBuffer();
        int iOtherTotal = 0;

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                sOther.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER1"));
                sOther.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER2"));
                sOther.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER3"));
                sOther.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER4"));
                sOther.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER5"));
            }

            iOtherTotal = 1;

            if (sOther.indexOf("£")>-1){
                StringBuffer sTmpOther = sOther;
                String sTmpName, sTmpValue, sTmpUnit;
                sOther = new StringBuffer();

                while (sTmpOther.toString().toLowerCase().indexOf("$")>-1) {
                    sTmpName = "";
                    sTmpValue = "";
                    sTmpUnit = "";

                    if (sTmpOther.toString().toLowerCase().indexOf("£")>-1){
                        sTmpName = sTmpOther.substring(0,sTmpOther.toString().toLowerCase().indexOf("£"));
                        sTmpOther = new StringBuffer(sTmpOther.substring(sTmpOther.toString().toLowerCase().indexOf("£")+1));
                    }

                    if (sTmpOther.toString().toLowerCase().indexOf("£")>-1){
                        sTmpValue = sTmpOther.substring(0,sTmpOther.toString().toLowerCase().indexOf("£"));
                        sTmpOther = new StringBuffer(sTmpOther.substring(sTmpOther.toString().toLowerCase().indexOf("£")+1));
                    }

                    if (sTmpOther.toString().toLowerCase().indexOf("$")>-1){
                        sTmpUnit = sTmpOther.substring(0,sTmpOther.toString().toLowerCase().indexOf("$"));
                        sTmpOther = new StringBuffer(sTmpOther.substring(sTmpOther.toString().toLowerCase().indexOf("$")+1));
                    }

                    sOther.append("rowOther"+iOtherTotal+"="+sTmpName+"£"+sTmpValue+"£"+sTmpUnit+"$");
                    sDivOther.append(addOther(iOtherTotal, sTmpName, sTmpValue, sTmpUnit, sWebLanguage));
                    iOtherTotal++;
                }
            }
        }
    %>
                    <%=sDivOther%>
                </table>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER5" property="itemId"/>]>.value">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.initial.bilan.other.examinations",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER_EXAMINATIONS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER_EXAMINATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER_EXAMINATIONS" property="value"/></textarea>
            </td>
        </tr>
<%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2"><%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnet.initial.bilan",sWebLanguage)%></td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  var iOtherIndex = <%=iOtherTotal%>;
  var sOther = "<%=sOther%>";
  var editOtherRowid = "";

  function submitForm(){
      var maySubmit = true;

    if (isAtLeastOneOtherFieldFilled()) {
      if (maySubmit) {
        if (!addOther()) {
          maySubmit = false;
        }
      }
    }

    var sTmpBegin, sTmpEnd;
    while (sOther.indexOf("rowOther") > -1) {
      sTmpBegin = sOther.substring(sOther.indexOf("rowOther"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
      sOther = sOther.substring(0, sOther.indexOf("rowOther")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER1" property="itemId"/>]>.value")[0].value = sOther.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER2" property="itemId"/>]>.value")[0].value = sOther.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER3" property="itemId"/>]>.value")[0].value = sOther.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER4" property="itemId"/>]>.value")[0].value = sOther.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_INITIAL_BILAN_OTHER5" property="itemId"/>]>.value")[0].value = sOther.substring(1016,1270);

    if(maySubmit){
        document.getElementById("buttonsDiv").style.visibility = "hidden";
        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
        document.transactionForm.submit();
    }
  }

  function addOther(){
    if(isAtLeastOneOtherFieldFilled()){
      iOtherIndex++;

      sOther+="rowOther"+iOtherIndex+"="+transactionForm.otherName.value+"£"
                               +transactionForm.otherValue.value+"£"
                               +transactionForm.otherUnit.value+"$";
      var tr;
      tr = tblOther.insertRow(tblOther.rows.length);
      tr.id = "rowOther"+iOtherIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteOther(rowOther"+iOtherIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editOther(rowOther"+iOtherIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.otherName.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.otherValue.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.otherUnit.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearOtherFields()
      transactionForm.ButtonUpdateOther.disabled = true;
    }
    return true;
  }

  function updateOther(){
    if(isAtLeastOneOtherFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editOtherRowid.id+"="+transactionForm.otherName.value+"£"
                                 +transactionForm.otherValue.value+"£"
                                 +transactionForm.otherUnit.value;

      sOther = replaceRowInArrayString(sOther,newRow,editOtherRowid.id);

      <%-- update table object --%>
      row = tblOther.rows[editOtherRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteOther("+editOtherRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editOther("+editOtherRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.otherName.value;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.otherValue.value;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.otherUnit.value;

      setCellStyle(row);

      <%-- reset --%>
      clearOtherFields();
      transactionForm.ButtonUpdateOther.disabled = true;
    }
  }

  function isAtLeastOneOtherFieldFilled(){
    if(transactionForm.otherName.value != "")        return true;
    if(transactionForm.otherValue.value != "")       return true;
    return false;
  }

  function clearOtherFields(){
    transactionForm.otherName.value = "";
    transactionForm.otherValue.value = "";
    transactionForm.otherUnit.value = "";
  }

  function deleteOther(rowid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    var answer;
    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,"",modalitiesIE);
    }
    else{
      answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      sOther = deleteRowFromArrayString(sOther,rowid.id);
      tblOther.deleteRow(rowid.rowIndex);
      clearOtherFields();
    }
  }

  function editOther(rowid){
    var row = getRowFromArrayString(sOther,rowid.id);
    transactionForm.otherName.value = getCelFromRowString(row,0);
    transactionForm.otherValue.value = getCelFromRowString(row,1);
    transactionForm.otherUnit.value = getCelFromRowString(row,2);

    editOtherRowid = rowid;
    transactionForm.ButtonUpdateOther.disabled = false;
  }

<%-- SET CELL STYLE --%>
  function setCellStyle(row){
    for(var i=0; i<row.cells.length; i++){
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

  <%-- GENERAL FUNCTIONS ------------------------------------------------------------------------%>
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

    return array.join("$");
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>
