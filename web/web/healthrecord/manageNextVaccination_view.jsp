<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' focus='type'>
    <bean:define id="vaccinationInfo" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO"/>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.itemId" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>"/>
    <input id="vaccination-type" type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value" translate="false"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/showVaccinationSummary.do?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>">

    <script>
      function submitForm(){
        if (document.all['vaccination-type'].value=='be.mxs.healthrecord.vaccination.Intradermo'){
          document.all['vaccination-remarktext'].value = document.all['posneg'].value;
        }

        document.all['currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime'].value=document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value'].value;
        document.transactionForm.save.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
        %>
      }
    </script>
    <%=writeTableHeader("Web.Occup","be.mxs.healthrecord.vaccination.Vaccination",sWebLanguage,"showWelcomePage.do?ts="+getTs())%>
    <table border='0' width='100%' class='list' cellspacing="1">
        <tr>
            <td class='admin' width="30%"><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input type="text" readonly class='text' size='20' name="item-type" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value"/>" onblur="validateText(this);limitLength(this);"/></td>
        </tr>
        <tr id="vaccination-name" style="display:none">
            <td class='admin'>&nbsp;</td>
            <td class='admin2'><input type="text" class='text' size='20' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME" property="value"/>" onblur="validateText(this);limitLength(this);"/></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.current-status",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input type="text" readonly class="text" size="20" name="old-status" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="value"/>" onblur="validateText(this);limitLength(this);"/></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.comment",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><logic:present name="vaccinationInfo" property="comment"><mxs:propertyAccessorI18N name="vaccinationInfo" scope="page" property="comment"/></logic:present></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.new-status",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="itemId"/>]>.value" class="text">
                    <logic:iterate id="vaccinationStatus" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO.valueList">
                        <option value="<bean:write name="vaccinationStatus"/>" <c:if test="${ pageScope.vaccinationInfo.nextStatus == pageScope.vaccinationStatus }">selected</c:if> ><mxs:beanTranslator name="vaccinationStatus" scope="page"/>
                    </logic:iterate>
                </select>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'/><script>writeMyDate("trandate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.next-date",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="nextdate" onBlur='if(checkDate(this)){ checkBefore("trandate",this); }'/>
                <script>writeMyDate("nextdate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <input type="button" class="button" name="calculate" value="<%=getTran("Web.Occup","Calculate",sWebLanguage)%>" onclick="calculateNextDate();">
            </td>
        </tr>
        <%-- REMARK --%>
        <tr id="vaccination-remark" style="display:none">
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" id="vaccination-remarktext" class="text" cols="110" rows="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="value"/></textarea>
            </td>
        </tr>
        <%-- POS/NEG --%>
        <tr id="vaccination-positive-negative" style="display:none">
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select name="posneg" class="text">
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT;value=medwan.common.negative" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="medwan.common.positive" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT;value=medwan.common.positive" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.common.positive",sWebLanguage)%>
                </select>
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <INPUT class="button" type="button" name="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
        <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="window.location.href='<c:url value="/healthrecord/showVaccinationSummary.do"/>?ts=<%=getTs()%>'">
    <%=ScreenHelper.alignButtonsStop()%>
    <script>
      if (document.all['vaccination-type'].value=='be.mxs.healthrecord.vaccination.Other'){
        show('vaccination-name');
      }
      if (document.all['vaccination-type'].value=='be.mxs.healthrecord.vaccination.Intradermo'){
        show('vaccination-positive-negative');
      }
      else{
        show('vaccination-remark');
      }

      function calculateNextDate(){
        vaccinationType = document.all['vaccination-type'].value;
        vaccinationSubType= document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="itemId"/>]>.value'].value;
        vaccinationDate = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value'].value;
        sourceField = 'currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="itemId"/>]>.value';
        openPopup("/util/getCalculatedValues.jsp&valueType=nextVaccinationDate&vaccinationType="+vaccinationType+"&vaccinationSubType="+vaccinationSubType+"&vaccinationDate="+vaccinationDate+"&sourceField="+sourceField);
      }
    </script>
</form>
