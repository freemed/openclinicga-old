<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.pediatry.consultation", "select",activeUser)%>
<script>
  function activateTab(iTab){
    document.all['tr1-view'].style.display = 'none';
    document.all['tr3-view'].style.display = 'none';
    document.all['tr4-view'].style.display = 'none';

    td1.className="tabunselected";
    td3.className="tabunselected";
    td4.className="tabunselected";

    if (iTab==1){
      document.all['tr1-view'].style.display = '';
      td1.className="tabselected";
    }
    else if (iTab==3){
      document.all['tr3-view'].style.display = '';
      td3.className="tabselected";
    }
    else if (iTab==4){
      document.all['tr4-view'].style.display = '';
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
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'  onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
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
    <%
        StringBuffer sbData = new StringBuffer();

        TransactionVO tran = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(activePatient.personid), sPREFIX+"TRANSACTION_TYPE_BIOMETRY");
        if (tran!=null){
            tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId().intValue());
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER1"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER2"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER3"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER4"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER5"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER6"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER7"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER8"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER9"));
            sbData.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER10"));
        }

        String sDate, sWeight, sHeight, sSkull, sArm, sFood;
        sDate = "";
        sWeight = "";
        sHeight = "";
        sSkull = "";
        sArm = "";
        sFood = "";

        if (sbData.indexOf("£") > -1) {
            StringBuffer sTmpBio = sbData;
            String sTmpDate, sTmpWeight, sTmpHeight, sTmpSkull, sTmpArm, sTmpFood;

            while (sTmpBio.indexOf("$") > -1) {
                sTmpDate = "";
                sTmpWeight = "";
                sTmpHeight = "";
                sTmpSkull = "";
                sTmpArm = "";
                sTmpFood = "";

                if (sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                    sTmpDate = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                    sTmpWeight = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                    sTmpHeight = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                    sTmpSkull = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                    sTmpArm = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                }

                if (sTmpBio.toString().toLowerCase().indexOf("$") > -1) {
                    sTmpFood = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("$"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$") + 1));
                }

                if (sDate.length() > 0) {
                    if (ScreenHelper.getSQLDate(sDate).before(ScreenHelper.getSQLDate(sTmpDate))) {
                        sDate = sTmpDate;
                        sWeight = sTmpWeight;
                        sHeight = sTmpHeight;
                        sSkull = sTmpSkull;
                        sArm = sTmpArm;
                        sFood = sTmpFood;
                    }
                } else {
                    sDate = sTmpDate;
                    sWeight = sTmpWeight;
                    sHeight = sTmpHeight;
                    sSkull = sTmpSkull;
                    sArm = sTmpArm;
                    sFood = sTmpFood;
                }
            }
        }
    %>

    <table class="list" width="100%" cellspacing="1" cellpadding="0">
        <tr class="gray">
            <td><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%> <b><%=sDate%></b></td>
            <td><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%> <b><%=sWeight%></b></td>
            <td><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%> <b><%=sHeight%></b></td>
            <td><%=getTran("openclinic.chuk","skull",sWebLanguage)%> <b><%=sSkull%></b></td>
            <td><%=getTran("openclinic.chuk","arm.circumference",sWebLanguage)%> <b><%=sArm%></b></td>
            <td>
                <%=getTran("openclinic.chuk","food",sWebLanguage)%>
                <b><%
                    if (sFood.length()>0){
                        sFood = getTran("biometry_food",sFood,sWebLanguage);
                    }
                    out.print(sFood);
                %></b>
            </td>
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
    <table width="100%" border="0" cellspacing="0">
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/pediatryConsultationSummary.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/pediatryConsultationFamiliaal.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr4-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/pediatryConsultationPersoonlijk.jsp"),pageContext);%></td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
    <%-- PRINTLANGUAGE & PRINT HEIGHT GRAPH BUTTON --%>
        <%
            // age in months
            float iAgeInYears = MedwanQuery.getInstance().getAgeDecimal(Integer.parseInt(activePatient.personid));
            double iAgeInMonths = iAgeInYears * 12.0;

            %>
            <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>
            <%
                String sPrintLanguage = checkString(activePatient.language);
                if (sPrintLanguage.length()==0){
                    sPrintLanguage = sWebLanguage;
                }

                String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("SupportedLanguages");
                if(sSupportedLanguages.length()==0){
                    sSupportedLanguages = "nl,fr";
                }
            %>

            <select class="text" name="PrintLanguage">
                <%
                    String tmpLang;
                    StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                    while (tokenizer.hasMoreTokens()) {
                        tmpLang = tokenizer.nextToken();
                %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                    }
            %>
            </select>

            <input class="button" type="button" name="graphButton" value="<%=getTranNoLink("Web","printGrowthGraph",sWebLanguage)%>" onclick="printGrowthGraph('<%=(int)iAgeInMonths%>','<%=activePatient.gender%>',document.transactionForm.PrintLanguage.value);">

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
    if(document.getElementById('encounteruid').value==''){
		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
		searchEncounter();
	}	
    else {
	    // check familiaal-fields for content
	    if (isAtLeastOneFamiFieldFilled()){
	      if(maySubmit){
	        addFami();
	      }
	    }
	
	    // check persoonlijk-fields for content
	    if (isAtLeastOneChirurgieFieldFilled()){
	      if(maySubmit){
	        if(!addChirurgie()){ maySubmit = false; }
	      }
	    }
	
	    if (isAtLeastOneHeelkundeFieldFilled()){
	      if(maySubmit){
	        if(!addHeelkunde()){ maySubmit = false; }
	      }
	    }
	
	    if (isAtLeastOneLetselsFieldFilled()){
	      if(maySubmit){
	        addLetsels();
	      }
	    }
	
	//Summary
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(250,500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(500,750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(750,1000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(1000,1250);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(1250,1500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(1500,1750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(1750,2000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value'].value.substring(0,250);
	
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(250,500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(500,750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(750,1000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(1000,1250);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(1250,1500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(1500,1750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(1750,2000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value'].value.substring(0,250);
	
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(250,500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(500,750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(750,1000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(1000,1250);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(1250,1500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(1500,1750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(1750,2000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value'].value.substring(0,250);
	
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(250,500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(500,750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(750,1000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(1000,1250);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(1250,1500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(1500,1750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(1750,2000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value'].value.substring(0,250);
	
	//familiaal
	    while (sFami.indexOf("rowFami")>-1){
	      sTmpBegin = sFami.substring(sFami.indexOf("rowFami"));
	      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	      sFami = sFami.substring(0,sFami.indexOf("rowFami"))+sTmpEnd;
	    }
	
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN" property="itemId"/>]>.value"].value = sFami.substring(0,250);
	
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(250,500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(500,750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(750,1000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(1000,1250);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(1250,1500);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(1500,1750);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(1750,2000);
	    document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value'].value.substring(0,250);
	
	//persoonlijk
	    while (sChirurgie.indexOf("rowChirurgie")>-1){
	      sTmpBegin = sChirurgie.substring(sChirurgie.indexOf("rowChirurgie"));
	      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	      sChirurgie = sChirurgie.substring(0,sChirurgie.indexOf("rowChirurgie"))+sTmpEnd;
	    }
	
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN1" property="itemId"/>]>.value"].value = sChirurgie.substring(0,250);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN2" property="itemId"/>]>.value"].value = sChirurgie.substring(250,500);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN3" property="itemId"/>]>.value"].value = sChirurgie.substring(500,750);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN4" property="itemId"/>]>.value"].value = sChirurgie.substring(750,1000);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN5" property="itemId"/>]>.value"].value = sChirurgie.substring(1000,1250);
	
	    while (sLetsels.indexOf("rowLetsels")>-1){
	      sTmpBegin = sLetsels.substring(sLetsels.indexOf("rowLetsels"));
	      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	      sLetsels = sLetsels.substring(0,sLetsels.indexOf("rowLetsels"))+sTmpEnd;
	    }
	
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS1" property="itemId"/>]>.value"].value = sLetsels.substring(0,250);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS2" property="itemId"/>]>.value"].value = sLetsels.substring(250,500);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS3" property="itemId"/>]>.value"].value = sLetsels.substring(500,750);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS4" property="itemId"/>]>.value"].value = sLetsels.substring(750,1000);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS5" property="itemId"/>]>.value"].value = sLetsels.substring(1000,1250);
	
	    while (sHeelkunde.indexOf("rowHeelkunde")>-1){
	      sTmpBegin = sHeelkunde.substring(sHeelkunde.indexOf("rowHeelkunde"));
	      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	      sHeelkunde = sHeelkunde.substring(0,sHeelkunde.indexOf("rowHeelkunde"))+sTmpEnd;
	    }
	
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE1" property="itemId"/>]>.value"].value = sHeelkunde.substring(0,250);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE2" property="itemId"/>]>.value"].value = sHeelkunde.substring(250,500);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE3" property="itemId"/>]>.value"].value = sHeelkunde.substring(500,750);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE4" property="itemId"/>]>.value"].value = sHeelkunde.substring(750,1000);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE5" property="itemId"/>]>.value"].value = sHeelkunde.substring(1000,1250);
	
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(0,250);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT1" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(250,500);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT2" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(500,750);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT3" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(750,1000);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT4" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(1000,1250);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT5" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(1250,1500);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT6" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(1500,1750);
	    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT7" property="itemId"/>]>.value"].value = document.all['PersoonlijkComment'].value.substring(1750,2000);
	
	
	    if(maySubmit){
	      var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	        document.transactionForm.save.style.visibility = "hidden";
	      <%
	          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	      %>
	    }
     }
  }

  function subScreen(screenName){
    document.all['be.mxs.healthrecord.updateTransaction.actionForwardKey'].value = screenName;
    submitForm();
  }
  function searchEncounter(){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(document.getElementById('encounteruid').value==''){
	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	
</script>

<%=writeJSButtons("transactionForm","save")%>
<%=ScreenHelper.contextFooter(request)%>

</form>