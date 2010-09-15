<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="subClass" value="COLOR"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" name="trandate">

<script>
  function setTrue(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.false";
  }
</script>

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.couleurs",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("Web.Occup","medwan.common.not-executed",sWebLanguage,"moc_c1")%>&nbsp;<input name="visus-ras" type="checkbox" id="moc_c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('visus-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS" property="itemId"/>'); } else {show('visus-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#topp" class="topbutton">&nbsp;</a></td>
    </tr>
    <tr id="visus-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr>
                    <td class="admin" width="15%">
                        TEST
                    </td>
                    <td class="admin" width="5%">
                       <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%>
                    </td>
                    <td class="admin"></td>
                </tr>
                <tr>
                    <td class="admin" >
                       <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.couleurs",sWebLanguage)%>
                    </td>
                    <td class="admin">9</td>

                    <td class="admin2">
                        <table>
                            <tr>
                                <td>Essilor</td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR;value=medwan.healthrecord.ophtalmology.Normal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Normal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage,"moc_r1")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR;value=medwan.healthrecord.ophtalmology.Abnormal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Abnormal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage,"moc_r2")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR;value=medwan.healthrecord.ophtalmology.Not-executed" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Not-executed"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Not-executed",sWebLanguage,"moc_r3")%></td>
                            </tr>
                            <tr>
                                <td>Farnsworth</td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH;value=medwan.healthrecord.ophtalmology.Normal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Normal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage,"moc_r4")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH;value=medwan.healthrecord.ophtalmology.Abnormal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Abnormal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage,"moc_r5")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH;value=medwan.healthrecord.ophtalmology.Not-executed" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Not-executed"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Not-executed",sWebLanguage,"moc_r6")%></td>
                            </tr>
                            <tr>
                                <td>Ishihara</td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA;value=medwan.healthrecord.ophtalmology.Normal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Normal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage,"moc_r7")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA;value=medwan.healthrecord.ophtalmology.Abnormal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Abnormal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage,"moc_r8")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA;value=medwan.healthrecord.ophtalmology.Not-executed" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Not-executed"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Not-executed",sWebLanguage,"moc_r9")%></td>
                            </tr>
                            <tr>
                                <td>Carte de couleur</td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR;value=medwan.healthrecord.ophtalmology.Normal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Normal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage,"moc_r10")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR;value=medwan.healthrecord.ophtalmology.Abnormal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Abnormal"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage,"moc_r11")%></td>
                                <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR;value=medwan.healthrecord.ophtalmology.Not-executed" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Not-executed"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.Not-executed",sWebLanguage,"moc_r12")%></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.correction",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class='admin2'>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION")%> type="radio" onDblClick="uncheckRadio(this);" id="moc_r13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.avec-correction"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage,"moc_r13")%>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION")%>type="radio" onDblClick="uncheckRadio(this);" id="moc_r14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.sans-correction"><%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage,"moc_r14")%>
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class='admin2'>
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_COLOR_REMARK")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_COLOR_REMARK" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <INPUT class="button" type="button" name="save" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
    <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>'}">
    <%=writeResetButton("transactionForm",sWebLanguage)%>
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function doSubmit(){
    document.transactionForm.save.disabled = true;
    document.transactionForm.submit();
  }

  document.all['visus-ras'].onclick();
</script>

</form>
<%=writeJSButtons("transactionForm", "document.all['save']")%>