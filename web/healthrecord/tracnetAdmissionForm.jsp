<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.tracnet.admission.form", "select",activeUser)%>
<script>
  function activateTab(iTab){
    document.getElementById('tr1-view').style.display = 'none';
    document.getElementById('tr2-view').style.display = 'none';
    document.getElementById('tr3-view').style.display = 'none';
    document.getElementById('tr4-view').style.display = 'none';

    td1.className="tabunselected";
    td2.className="tabunselected";
    td3.className="tabunselected";
    td4.className="tabunselected";

    if (iTab==1){
      document.getElementById('tr1-view').style.display = '';
      td1.className="tabselected";
    }
    else if (iTab==2){
      document.getElementById('tr2-view').style.display = '';
      td2.className="tabselected";
    }
    else if (iTab==3){
      document.getElementById('tr3-view').style.display = '';
      td3.className="tabselected";
    }
    else if (iTab==4){
      document.getElementById('tr4-view').style.display = '';
      td4.className="tabselected";
    }
  }

  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }

  function getCelFromRowString(sRow,celid){
    var row = sRow.split("£");
    return row[celid];
  }

  function replaceRowInArrayString(sArray,newRow,rowid){
    var array = sArray.split("$");
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        array.splice(i,1,newRow);
        break;
      }
    }
    return array.join("$");
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
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'  onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="subClass" value="GENERAL"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <br>
    <%-- TABS --%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(1)" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.admission.form.tab1",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(2)" id="td2" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.admission.form.tab2",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(3)" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.admission.form.tab3",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(4)" id="td4" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.admission.form.tab4",sWebLanguage)%></b>&nbsp;</td>
            <td width="*" class='tabs'>&nbsp;</td>
        </tr>
    </table>

    <%-- HIDEABLE --%>
    <table width="100%" border="0" cellspacing="0">
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetAdmissionFormTab1.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr2-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetAdmissionFormTab2.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetAdmissionFormTab3.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr4-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetAdmissionFormTab4.jsp"),pageContext);%></td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnet.admission.form",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

<script>
  activateTab(1);
  var maySubmit = true;

  function submitForm(){
    maySubmit = true;
    submitTab1();
      
    if(maySubmit){
        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
        document.getElementById("buttonsDiv").style.visibility = "hidden";
        document.transactionForm.submit();
    }
  }

</script>

<%=writeJSButtons("transactionForm","saveButton")%>
<%=ScreenHelper.contextFooter(request)%>

</form>