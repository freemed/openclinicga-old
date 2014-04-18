<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' focus='type' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="vaccinationInfo" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO"/>
   <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.itemId" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value" translate="false"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/showVaccinationSummary.do?ts=<%=getTs()%>"/>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="white">
      <tr>
        <td align="left" style="vertical-align:top;" class="white">
          <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" class="white">
            <tr>
              <td align="left" style="vertical-align:top;">
                <table width="100%" border="0" cellspacing="2" cellpadding="0" class="white">
                  <tr>
                    <td height='277' align='center' valign='middle'>
                      <table border='0' width='100%' height='100%' >
                        <tr>
                          <td valign='top'>

                            <table border='0' width='100%' align='center'>
                                <tr>
                                    <td>
                                        <table border='0' width='100%' class='list'>
                                            <tr>
                                                <td class='admin' width="*"><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
                                                <td class='admin2' width="80%"><input type="text" readonly class='text' size='20' name="item-type" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value"/>"/></td>
                                            </tr>
                                            <tr>
                                                <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.current-status",sWebLanguage)%>&nbsp;</td>
                                                <td class='admin2'><input type="text" readonly class="text" size="20" name="old-status" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="value"/>"/></td>
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
                                                <td class='admin2'><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'/>
                                                    <script>writeTranDate();</script>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.next-date",sWebLanguage)%>&nbsp;</td>
                                                <td class='admin2'><input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>"/></td>
                                            </tr>
                                            <tr>
                                                <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                                                <td class='admin2'>
                                                    <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="110" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="value"/></textarea>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <%-- SAVE & BACK --%>
                                <tr>
                                    <td>
                                        <table border='0' width='100%'>
                                            <tr>
                                                <td align='center'>
                                                    <INPUT id="save" class="button" type="button" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
                                                    <INPUT class="button" type="button" onclick="doBack();" value="<%=getTran("Web","Back",sWebLanguage)%>">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
</form>

<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    document.transactionForm.submit();
  }

  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/healthrecord/showVaccinationSummary.do"/>?ts=<%=getTs()%>';
    }
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>