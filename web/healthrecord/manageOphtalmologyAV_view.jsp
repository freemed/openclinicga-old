<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="subClass" value="AV"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=healthrecord/manageOphtalmologyExaminationWithStereoscopy_view.jsp&be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>
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
        <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("Web.Occup","medwan.common.not-executed",sWebLanguage,"moav_c1")%>&nbsp;<input name="visus-ras" type="checkbox" id="moav_c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('visus-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS" property="itemId"/>'); } else {show('visus-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top" class="topbutton">&nbsp;</a></td>
    </tr>
    <tr id="visus-details" style="display:none" width="100%">
        <td colspan="3" width="100%">
            <table width="100%" cellspacing="1" border="0">
                <tr>
                    <td class="admin" valign="baseline" colspan="2">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%>&nbsp;
                    </td>
                    <td class="admin2" colspan="2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL")%> type="checkbox" id="moav_c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL;value=medwan.healthrecord.ophtalmology.acuite-visuelle.normale" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.normale" >
                        <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.normale",sWebLanguage,"moav_c2")%>
                          &nbsp;&nbsp;&nbsp;&nbsp;
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES")%> type="checkbox" id="moav_c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES;value=medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes" >
                        <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes",sWebLanguage,"moav_c3")%>
                          &nbsp;&nbsp;&nbsp;&nbsp;
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT")%> type="checkbox" id="moav_c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT;value=medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact" >
                        <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact",sWebLanguage,"moav_c4")%>
                         &nbsp;&nbsp;&nbsp;&nbsp;
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK")%> type="checkbox" id="moav_c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK;value=medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK" >
                        <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK",sWebLanguage,"moav_c5")%>
                          &nbsp;&nbsp;&nbsp;&nbsp;
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY")%> type="checkbox" id="moav_c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY;value=medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie" >
                        <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie",sWebLanguage,"moav_c6")%>

                       </td>
                </tr>

                <tr>
                    <td class="admin" width="15%">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.tests",sWebLanguage)%>
                    </td>
                    <td class="admin" width="5%">
                       <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%>
                    </td>
                    <td class="admin" width="40%">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>
                    </td>
                    <td class="admin" width="40%">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class="admin" rowspan="2">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Acuite-VL",sWebLanguage)%>
                    </td>
                    <td class="admin" nowrap><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.20-OD",sWebLanguage)%></td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres",sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres",sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class="admin" nowrap><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.21-OG",sWebLanguage)%></td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres",sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres",sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class="admin" rowspan="2">
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Acuite-binoculaire-VL",sWebLanguage)%>
                    </td>
                    <td class="admin" rowspan="2">2</td>
                    <td class="admin2" colspan="2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres",sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class="admin2" colspan="2">
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                        &#47;10
                        <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres",sWebLanguage)%>
                    </td>
                </tr>


                <tr>
                    <td class='admin' colspan="2"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                    <td colspan="2" class='admin2'>
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK" property="value"/></textarea>
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