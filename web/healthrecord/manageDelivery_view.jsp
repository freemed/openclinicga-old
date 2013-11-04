<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.delivery","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <table class="list" width="100%" cellspacing="1">
        <tr class="admin">
            <td colspan="4"><%=getTran("gynaeco","work",sWebLanguage)%></td>
        </tr>
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
            <td class="admin" rowspan="4"><%=getTran("openclinic.chuk","delivery.type",sWebLanguage)%></td>
            <td rowspan="4" bgcolor="#EBF3F7">
                <table width="100%" cellspacing="1" bgcolor="white">
                    <tr>
                        <td colspan="2" class="admin2"><input onclick="doType()" type="radio" onDblClick="uncheckRadio(this);" id="type_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE" property="itemId"/>]>.value" value="openclinic.common.eutocic" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE;value=openclinic.common.eutocic" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.eutocic",sWebLanguage,"type_r1")%></td>
                    </tr>
                    <tr>
                        <td colspan="2" class="admin2"><input onclick="doType()" type="radio" onDblClick="uncheckRadio(this);" id="type_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE" property="itemId"/>]>.value" value="openclinic.common.dystocic" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE;value=openclinic.common.dystocic" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.dystocic",sWebLanguage,"type_r2")%></td>
                    </tr>
                    <tr id="trtype2">
                        <td width="25" class="admin2"/>
                        <td class="admin2">
                            <table width="100%">
                                <tr>
                                    <td colspan="2"><input <%=setRightClick("ITEM_TYPE_DELIVERY_VENTOUSSE")%> type="checkbox" id="cbventousse" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_VENTOUSSE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_VENTOUSSE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","gynaeco.ventousse",sWebLanguage,"cbventousse")%></td>
                                </tr>
                                <tr>
                                    <td/>
                                    <td>
                                        <table>
                                            <tr>
                                                <td><%=getTran("gynaeco","number_tractions",sWebLanguage)%></td>
                                                <td><input <%=setRightClick("ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS")%> id="ttractions" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr>
                                                <td><%=getTran("gynaeco","number_lachage",sWebLanguage)%></td>
                                                <td><input <%=setRightClick("ITEM_TYPE_DELIVERY_NUMBER_LACHAGE")%> id="tlachage" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_LACHAGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_LACHAGE" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2"><input <%=setRightClick("ITEM_TYPE_DELIVERY_FORCEPS")%> type="checkbox" id="cbforceps" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_FORCEPS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_FORCEPS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco","forceps",sWebLanguage,"cbforceps")%></td>
                                </tr>
                                <tr>
                                    <td colspan="2"><input <%=setRightClick("ITEM_TYPE_DELIVERY_MANOEUVRE")%> type="checkbox" id="cbmanoeuvre" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_MANOEUVRE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_MANOEUVRE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco","manoeuvre",sWebLanguage,"cbmanoeuvre")%></td>
                                </tr>
                                <tr>
                                    <td><%=getTran("gynaeco","cause",sWebLanguage)%></td>
                                    <td>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.maternel" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.maternel" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","maternel",sWebLanguage,"causedystocic_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.fetal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.fetal" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","fetal",sWebLanguage,"causedystocic_r2")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.mixte" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.mixte" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","mixte",sWebLanguage,"causedystocic_r3")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="100"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                                    <td>
                                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK")%> id="tdystoticremark" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK" property="value"/></textarea>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" class="admin2"><input onclick="doType()" type="radio" onDblClick="uncheckRadio(this);" id="type_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE" property="itemId"/>]>.value" value="openclinic.common.caeserian" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE;value=openclinic.common.caeserian" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.caeserian",sWebLanguage,"type_r3")%></td>
                    </tr>
                    <tr id="trtype3">
                        <td class="admin2"/>
                        <td class="admin2">
                            <table width="100%" cellspacing="0">
                                <tr>
                                    <td colspan="2">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN")%> type="radio" onDblClick="uncheckRadio(this);" id="caeserian_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN" property="itemId"/>]>.value" value="gynaeco.caeserian.before" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN;value=gynaeco.caeserian.before" property="value" outputString="checked"/>><%=getLabel("gynaeco.caeserian","before",sWebLanguage,"caeserian_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN")%> type="radio" onDblClick="uncheckRadio(this);" id="caeserian_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN" property="itemId"/>]>.value" value="gynaeco.caeserian.during" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN;value=gynaeco.caeserian.during" property="value" outputString="checked"/>><%=getLabel("gynaeco.caeserian","during",sWebLanguage,"caeserian_r2")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td><%=getTran("gynaeco","cause",sWebLanguage)%></td>
                                    <td>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.maternel" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.maternel" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","maternel",sWebLanguage,"causecaeserian_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.fetal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.fetal" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","fetal",sWebLanguage,"causecaeserian_r2")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.mixte" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.mixte" property="value" outputString="checked"/>><%=getLabel("gynaeco.cause","mixte",sWebLanguage,"causecaeserian_r3")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="100"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                                    <td>
                                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK")%> id="tcaeserianremark" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK" property="value"/></textarea>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("gynaeco","admission",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.urgence" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.urgence" property="value" outputString="checked"/>><%=getLabel("gynaeco.admission","urgence",sWebLanguage,"admission_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.transfer" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.transfer" property="value" outputString="checked"/>><%=getLabel("gynaeco.admission","transfer",sWebLanguage,"admission_r2")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.spontane" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.spontane" property="value" outputString="checked"/>><%=getLabel("gynaeco.admission","spontane",sWebLanguage,"admission_r3")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.other" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.other" property="value" outputString="checked"/>><%=getLabel("gynaeco.admission","other",sWebLanguage,"admission_r4")%>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("gynaeco","start.hour",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_STARTHOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_STARTHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_STARTHOUR" property="value"/>" onblur="checkTime(this)">
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("gynaeco","age.gestationnel",sWebLanguage)%>
            </td>
            <td class="admin2">
                <table>
                    <tr>
                        <td><%=getTran("gynaeco","age.date.dr",sWebLanguage)%></td>
                        <td><input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_DATE_DR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="value"/>" onblur="isNumber(this)"> <%=getTran("web","weeks",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><%=getTran("gynaeco","age.echography",sWebLanguage)%></td>
                        <td><input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="value"/>" onblur="isNumber(this)"> <%=getTran("web","weeks",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><%=getTran("gynaeco","age.trimstre",sWebLanguage)%></td>
                        <td>
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=1" property="value" outputString="checked"/>>1
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=2" property="value" outputString="checked"/>>2
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=3" property="value" outputString="checked"/>>3
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        
        <%-- Delivrance --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("gynaeco","deliverance",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","delivery.hour",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERYHOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYHOUR" property="value"/>" onblur="checkTime(this)">
            </td>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.assistee" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.assistee" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","gynaeco.deliverencetype.assistee",sWebLanguage,"deliverentype_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.spontanee" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.spontanee" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","gynaeco.deliverencetype.spontanee",sWebLanguage,"deliverentype_r2")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.artificielle" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.artificielle" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","gynaeco.deliverencetype.artificielle",sWebLanguage,"deliverentype_r2")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","placenta",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PLACENTA")%> type="radio" onDblClick="uncheckRadio(this);" id="placenta_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA" property="itemId"/>]>.value" value="openclinic.common.complete" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA;value=openclinic.common.complete" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.complete",sWebLanguage,"placenta_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PLACENTA")%> type="radio" onDblClick="uncheckRadio(this);" id="placenta_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA" property="itemId"/>]>.value" value="openclinic.common.incomplete" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA;value=openclinic.common.incomplete" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.incomplete",sWebLanguage,"placenta_r2")%>
            </td>
            <td class="admin"><%=getTran("gynaeco","hemorragie",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE")%> type="radio" onDblClick="uncheckRadio(this);" id="hemorragie_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"hemorragie_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE")%> type="radio" onDblClick="uncheckRadio(this);" id="hemorragie_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"hemorragie_r2")%>
                <br/>
                <%=getTran("gynaeco","hemorragie.intervention",sWebLanguage)%>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco","perinee",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE")%> type="radio" onDblClick="uncheckRadio(this);" id="perinee_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"perinee_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE")%> type="radio" onDblClick="uncheckRadio(this);" id="perinee_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"perinee_r2")%>
                <br/>
                <%=getTran("gynaeco","perinee.degree",sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE_DEGREE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE_DEGREE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE_DEGREE" property="value"/>" onblur="isNumber(this)">
            </td>
            <td class="admin"><%=getTran("gynaeco","episiotomie",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_EPISIOTOMIE")%> type="radio" onDblClick="uncheckRadio(this);" id="episiotomie_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"episiotomie_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_EPISIOTOMIE")%> type="radio" onDblClick="uncheckRadio(this);" id="episiotomie_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"episiotomie_r2")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","observation",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","intervention",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>

        <%-- Enfant --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","child",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco","gender",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_GENDER")%> type="radio" onDblClick="uncheckRadio(this);" id="gender_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER" property="itemId"/>]>.value" value="male" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER;value=male" property="value" outputString="checked"/>><%=getLabel("web.occup","male",sWebLanguage,"gender_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_GENDER")%> type="radio" onDblClick="uncheckRadio(this);" id="gender_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER" property="itemId"/>]>.value" value="female" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER;value=female" property="value" outputString="checked"/>><%=getLabel("web.occup","female",sWebLanguage,"gender_r2")%>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","weight",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDWEIGHT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDWEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDWEIGHT" property="value"/>" onblur="isNumber(this)"> g
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco","height",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDHEIGHT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDHEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDHEIGHT" property="value"/>" onblur="isNumber(this)"> cm
            </td>
            <td class="admin"><%=getTran("gynaeco","cranien",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDCRANIEN")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDCRANIEN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDCRANIEN" property="value"/>" onblur="isNumber(this)"> cm
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td colspan="3" bgcolor="#EBF3F7">
                <table width="100%" cellspacing="1" bgcolor="white">
                    <tr>
                        <td colspan="2" class="admin2"><input onclick="doAlive()" type="radio" onDblClick="uncheckRadio(this);" id="alive_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE" property="itemId"/>]>.value" value="openclinic.common.borndead" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE;value=openclinic.common.borndead" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.borndead",sWebLanguage,"alive_r1")%></td>
                    </tr>
                    <tr id="tralive1">
                        <td width="90" class="admin2"/>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_DEAD_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deadtype_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE" property="itemId"/>]>.value" value="gynaeco.dead_type_frais" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE;value=gynaeco.dead_type_frais" property="value" outputString="checked"/>><%=getLabel("gynaeco.deadtype","frais",sWebLanguage,"deadtype_r1")%>
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_DEAD_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deadtype_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE" property="itemId"/>]>.value" value="gynaeco.dead_type_macere" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE;value=gynaeco.dead_type_macere" property="value" outputString="checked"/>><%=getLabel("gynaeco.deadtype","macere",sWebLanguage,"deadtype_r2")%>                            
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" class="admin2"><input onclick="doAlive()" type="radio" onDblClick="uncheckRadio(this);" id="alive_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE" property="itemId"/>]>.value" value="openclinic.common.bornalive" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE;value=openclinic.common.bornalive" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.bornalive",sWebLanguage,"alive_r2")%></td>
                    </tr>
                    <tr id="tralive2">
                        <td class="admin2" width="90"/>
                        <td bgcolor="#EBF3F7">
                            <table bgcolor="white" cellspacing="1">
                                <tr>
                                    <td class="admin2" colspan="3">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_DEADIN24H")%> type="checkbox" id="cbdead24h" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADIN24H" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADIN24H;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
                                        <%=getLabel("openclinic.chuk","dead.in.24h",sWebLanguage,"cbdead24h")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowspan="7" class="admin2">
                                        <table class="list" cellspacing="1">
                                            <tr class="gray">
                                                <td width="50"><%=getTran("gynaeco","apgar",sWebLanguage)%></td>
                                                <td width="50" align="center">1'</td>
                                                <td width="50" align="center">5'</td>
                                                <td width="50" align="center">10'</td>
                                            </tr>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco","apgar.coeur",sWebLanguage)%></td>
                                                <td><input id="coeur1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COEUR_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="coeur5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COEUR_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="coeur10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COEUR_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco","apgar.resp",sWebLanguage)%></td>
                                                <td><input id="resp1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_RESP_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="resp5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_RESP_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="resp10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_RESP_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco","apgar.tonus",sWebLanguage)%></td>
                                                <td><input id="tonus1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TONUS_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="tonus5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TONUS_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="tonus10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TONUS_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco","apgar.refl",sWebLanguage)%></td>
                                                <td><input id="refl1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_REFL_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="refl5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_REFL_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="refl10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_REFL_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco","apgar.color",sWebLanguage)%></td>
                                                <td><input id="color1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COLOR_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="color5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COLOR_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="color10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_COLOR_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco","apgar.total",sWebLanguage)%></td>
                                                <td><input id="total1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_1" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="total5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_5" property="value"/>" onblur="isNumber(this)"></td>
                                                <td><input id="total10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_10" property="value"/>" onblur="isNumber(this)"></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","reanimation",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <textarea id="reanimation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_REANIMATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_REANIMATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_REANIMATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="admin2"><%=getTran("openclinic.chuk","malformation",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <textarea id="malformation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_MALFORMATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_MALFORMATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_MALFORMATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="admin2"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <textarea id="observation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_OBSERVATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_OBSERVATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="admin2"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <textarea id="treatment" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_TREATMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_TREATMENT" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="admin2"><%=getTran("openclinic.chuk","polio.date",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <input id="polio_date" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDPOLIO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDPOLIO" property="value" formatType="date" format="dd/mm/yyyy"/>">
                                        <script>writeMyDate("polio_date","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="admin2"><%=getTran("openclinic.chuk","bcg.date",sWebLanguage)%></td>
                                    <td class="admin2">
                                        <input id="bcg_date" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDBCG" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDBCG" property="value" formatType="date" format="dd/mm/yyyy"/>">
                                        <script>writeMyDate("bcg_date","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">

<%-- BUTTONS --%>
        <%
            if ((activeUser.getAccessRight("occup.delivery.add")) || (activeUser.getAccessRight("occup.delivery.edit"))){
        %>
            <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
        <%
        }
        %>
            <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
        </td>
    </tr>
</table>
<script>
  function submitForm(){
    document.transactionForm.save.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  function doType(){
      if (document.getElementById("type_r2").checked){
        hideType3();
        document.getElementById("trtype2").style.display = "";
      }
      else if (document.getElementById("type_r3").checked){
        hideType2();
        document.getElementById("trtype3").style.display = "";
      }
      else {
          hideType2();
          hideType3();
      }
  }

  function hideType2(){
      document.getElementById("cbventousse").checked=false;
      document.getElementById("ttractions").value = "";
      document.getElementById("tlachage").value = "";
      document.getElementById("cbforceps").checked=false;
      document.getElementById("cbmanoeuvre").checked=false;
      document.getElementById("causedystocic_r1").checked=false;
      document.getElementById("causedystocic_r2").checked=false;
      document.getElementById("causedystocic_r3").checked=false;
      document.getElementById("tdystoticremark").value = "";
      document.getElementById("trtype2").style.display = "none";
  }

  function hideType3(){
      document.getElementById("caeserian_r1").checked=false;
      document.getElementById("caeserian_r2").checked=false;
      document.getElementById("causecaeserian_r1").checked=false;
      document.getElementById("causecaeserian_r2").checked=false;
      document.getElementById("causecaeserian_r3").checked=false;
      document.getElementById("tcaeserianremark").value = "";
      document.getElementById("trtype3").style.display = "none";
  }

  function doAlive(){
      document.getElementById("tralive1").style.display = "none";
      document.getElementById("tralive2").style.display = "none";

      if (document.getElementById("alive_r1").checked){
          document.getElementById("cbdead24h").checked=false;
          document.getElementById("coeur1").value="";
          document.getElementById("coeur5").value="";
          document.getElementById("coeur10").value="";
          document.getElementById("resp1").value="";
          document.getElementById("resp5").value="";
          document.getElementById("resp10").value="";
          document.getElementById("tonus1").value="";
          document.getElementById("tonus5").value="";
          document.getElementById("tonus10").value="";
          document.getElementById("refl1").value="";
          document.getElementById("refl5").value="";
          document.getElementById("refl10").value="";
          document.getElementById("color1").value="";
          document.getElementById("color5").value="";
          document.getElementById("color10").value="";
          document.getElementById("total1").value="";
          document.getElementById("total5").value="";
          document.getElementById("total10").value="";
          document.getElementById("reanimation").value="";
          document.getElementById("malformation").value="";
          document.getElementById("observation").value="";
          document.getElementById("treatment").value="";
          document.getElementById("polio_date").value="";
          document.getElementById("bcg_date").value="";
          document.getElementById("tralive1").style.display = "";
      }
      else if (document.getElementById("alive_r2").checked){
        document.getElementById("deadtype_r1").checked=false;
        document.getElementById("deadtype_r2").checked=false;
        document.getElementById("tralive2").style.display = "";
      }
  }

  doAlive();
  doType();
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm", "save")%>