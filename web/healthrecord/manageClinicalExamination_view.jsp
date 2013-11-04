<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.clinicalexamination", "select",activeUser)%>
<script>
  function activateTab(iTab){
    document.getElementById('tr1-view').style.display = 'none';
    document.getElementById('tr3-view').style.display = 'none';
    document.getElementById('tr4-view').style.display = 'none';

    td1.className="tabunselected";
    td3.className="tabunselected";
    td4.className="tabunselected";

    if (iTab==1){
      document.getElementById('tr1-view').style.display = '';
      td1.className="tabselected";
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
    var result = array.join("$");
    return result;//.substring(0,result.length-1);
  }
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'  onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <mark/><input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="subClass" value="GENERAL"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>

    <%-- TITLE --%>
    <table class="list" width='100%' cellspacing="0" cellpadding="0">
        <tr class="admin">
            <td width="1%" nowrap>
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td width="50%"><%=contextHeader(request,sWebLanguage)%></td>
        </tr>
    </table>
    <br/>
    <%-- TABS --%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(1)" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web.Occup","medwan.healthrecord.tab.summary",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(3)" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web.Occup","Familiaal_Anamnese",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(4)" id="td4" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web.Occup","Persoonlijke_Antecedenten",sWebLanguage)%></b>&nbsp;</td>
            <td width="*" class='tabs'>&nbsp;</td>
        </tr>
    </table>

    <%-- HIDEABLE --%>
    <table valign="top" width="100%" border="0" cellspacing="0">
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/summary.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/familiaal.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr4-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/persoonlijk.jsp"),pageContext);%></td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <INPUT class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.extended",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.do'/>?Page=healthrecord/clinicalExaminationMax.jsp'">
        <%
        if (activeUser.getAccessRight("occup.clinicalexamination.add") || activeUser.getAccessRight("occup.clinicalexamination.edit")){
        %>
        <input class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
        <%
        }
        %>
        <input class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if ('<%=sCONTEXTPATH%>',checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';}">
    <%=ScreenHelper.alignButtonsStop()%>

<script>
  activateTab(1);

  function convertTable(sText){
    aRows = sText.split("</TR>");
    sText = "";
    for (var i=0;i<aRows.length;i++){
      sReturn = "";
      sRow = aRows[i];
      aTds = sRow.split("</TD>");
      for (var y=0;y<aTds.length;y++){
        sTD = aTds[y];
        if ((sTD.indexOf("delete")<0)&&(sTD.indexOf("<TD>")>-1)){
          sReturn += sTD+"</TD>";
        }
      }
      if (sReturn.length>0){
        sText+=("<TR>"+sReturn+"</TR>");
      }
    }
    return sText;
  }

  function submitForm(){
    var maySubmit = true;

    // check familiaal-fields for content
    if (isAtLeastOneKinderenFieldFilled()){
      if(maySubmit){
        if(addKinderen()==false){ maySubmit = false; }
      }
    }

    if (isAtLeastOneFamiFieldFilled()){
      if(maySubmit){
        addFami();
      }
    }

    // check persoonlijk-fields for content
    if (isAtLeastOneChirurgieFieldFilled()){
      if(maySubmit){
        if(addChirurgie()==false){ maySubmit = false; }
      }
    }

    if (isAtLeastOneHeelkundeFieldFilled()){
      if(maySubmit){
        if(addHeelkunde()==false){ maySubmit = false; }
      }
    }

    if (isAtLeastOneLetselsFieldFilled()){
      if(maySubmit){
        addLetsels();
      }
    }

//Summary
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE1" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(250,500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE2" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(500,750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE3" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(750,1000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE4" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1000,1250);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE5" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1250,1500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE6" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1500,1750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE7" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1750,2000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value')[0].value.substring(0,250);

    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE1" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(250,500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE2" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(500,750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE3" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(750,1000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE4" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1000,1250);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE5" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1250,1500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE6" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1500,1750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE7" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(1750,2000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value')[0].value.substring(0,250);

    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION1" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(250,500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION2" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(500,750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION3" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(750,1000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION4" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(1000,1250);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION5" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(1250,1500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION6" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(1500,1750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION7" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(1750,2000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value')[0].value.substring(0,250);

    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(250,500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(500,750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(750,1000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(1000,1250);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(1250,1500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(1500,1750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(1750,2000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value')[0].value.substring(0,250);

//familiaal
    while (sKinderen.indexOf("rowKinderen")>-1){
      sTmpBegin = sKinderen.substring(sKinderen.indexOf("rowKinderen"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sKinderen = sKinderen.substring(0,sKinderen.indexOf("rowKinderen"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_KINDEREN" property="itemId"/>]>.value")[0].value = sKinderen.substring(0,250);

    while (sFami.indexOf("rowFami")>-1){
      sTmpBegin = sFami.substring(sFami.indexOf("rowFami"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sFami = sFami.substring(0,sFami.indexOf("rowFami"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN" property="itemId"/>]>.value")[0].value = sFami.substring(0,250);

    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT1" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(250,500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT2" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(500,750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT3" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(750,1000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT4" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(1000,1250);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT5" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(1250,1500);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT6" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(1500,1750);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT7" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(1750,2000);
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value')[0].value.substring(0,250);

//persoonlijk
    while (sChirurgie.indexOf("rowChirurgie")>-1){
      sTmpBegin = sChirurgie.substring(sChirurgie.indexOf("rowChirurgie"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sChirurgie = sChirurgie.substring(0,sChirurgie.indexOf("rowChirurgie"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN1" property="itemId"/>]>.value")[0].value = sChirurgie.substring(0,250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN2" property="itemId"/>]>.value")[0].value = sChirurgie.substring(250,500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN3" property="itemId"/>]>.value")[0].value = sChirurgie.substring(500,750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN4" property="itemId"/>]>.value")[0].value = sChirurgie.substring(750,1000);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN5" property="itemId"/>]>.value")[0].value = sChirurgie.substring(1000,1250);

    while (sLetsels.indexOf("rowLetsels")>-1){
      sTmpBegin = sLetsels.substring(sLetsels.indexOf("rowLetsels"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sLetsels = sLetsels.substring(0,sLetsels.indexOf("rowLetsels"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS1" property="itemId"/>]>.value")[0].value = sLetsels.substring(0,250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS2" property="itemId"/>]>.value")[0].value = sLetsels.substring(250,500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS3" property="itemId"/>]>.value")[0].value = sLetsels.substring(500,750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS4" property="itemId"/>]>.value")[0].value = sLetsels.substring(750,1000);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS5" property="itemId"/>]>.value")[0].value = sLetsels.substring(1000,1250);

    while (sHeelkunde.indexOf("rowHeelkunde")>-1){
      sTmpBegin = sHeelkunde.substring(sHeelkunde.indexOf("rowHeelkunde"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sHeelkunde = sHeelkunde.substring(0,sHeelkunde.indexOf("rowHeelkunde"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE1" property="itemId"/>]>.value")[0].value = sHeelkunde.substring(0,250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE2" property="itemId"/>]>.value")[0].value = sHeelkunde.substring(250,500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE3" property="itemId"/>]>.value")[0].value = sHeelkunde.substring(500,750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE4" property="itemId"/>]>.value")[0].value = sHeelkunde.substring(750,1000);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE5" property="itemId"/>]>.value")[0].value = sHeelkunde.substring(1000,1250);

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(0,250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT1" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(250,500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT2" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(500,750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT3" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(750,1000);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT4" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(1000,1250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT5" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(1250,1500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT6" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(1500,1750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT7" property="itemId"/>]>.value")[0].value = document.getElementsByName('PersoonlijkComment')[0].value.substring(1750,2000);


    if(maySubmit){
      document.getElementById("transactionForm").save.disabled = true;
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
  }

  function subScreen(screenName){
    document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = screenName;
    submitForm();
  }
</script>

<%=writeJSButtons("transactionForm","save")%>
<%=ScreenHelper.contextFooter(request)%>

</form>