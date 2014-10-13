<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/occupationalmedicine/managePeriodicExaminations.do?ts=<%=getTs()%>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST" property="itemId"/>]>.value" value="medwan.common.true"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" name="subClass" value="VISIOTEST"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
<table width="100%" cellspacing="1" border="0" class="list">
    <%-- MAIN TITLE --%>
    <tr class="admin" height="22">
        <td colspan="4">
            <%=writeTableHeader("Web.Occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage," doBack();",activeUser)%>
        </td>
    </tr>
    <%-- DATE --%>
    <tr>
        <td class="admin">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2" colspan="3">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='if(!checkDate(this)){this.focus();alertDialog("Web.Occup","date.error");}'>
            <script>writeTranDate();</script>
        </td>
    </tr>
   <%-- VOORGESCHREVEN CORRECTIE --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","healthrecord.ophtalmology.correction-prescribe",sWebLanguage)%></td>
        <td rowspan="3" colspan="3" class='admin2'>
            <table width="100%">
                <tr>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES")%> type="checkbox" id="mov_c1" tabindex="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES;value=medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes">
                        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes",sWebLanguage,"mov_c1")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT")%> type="checkbox" id="mov_c2" tabindex="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT;value=medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact">
                        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact",sWebLanguage,"mov_c2")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_CLOSE")%> type="checkbox" id="mov_c3" tabindex="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_CLOSE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_CLOSE;value=delhaize.healthrecord.ophtalmology.av.nabijzicht" property="value" outputString="checked"/> value="delhaize.healthrecord.ophtalmology.av.nabijzicht">
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage,"mov_c3")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_FAR")%> type="checkbox" id="mov_c4" tabindex="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_FAR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_VISION_FAR;value=delhaize.healthrecord.ophtalmology.av.vertezicht" property="value" outputString="checked"/> value="delhaize.healthrecord.ophtalmology.av.vertezicht">
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage,"mov_c4")%>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PERMANENT")%> type="checkbox" id="mov_c5" tabindex="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PERMANENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PERMANENT;value=healthrecord.ophtalmology.permanent" property="value" outputString="checked"/> value="healthrecord.ophtalmology.permanent">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.permanent",sWebLanguage,"mov_c5")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LECTURE")%> type="checkbox" id="mov_c6" tabindex="6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LECTURE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LECTURE;value=healthrecord.ophtalmology.lecture" property="value" outputString="checked"/> value="healthrecord.ophtalmology.lecture">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.lecture",sWebLanguage,"mov_c6")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_SCREEN")%> type="checkbox" id="mov_c7" tabindex="7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_SCREEN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_SCREEN;value=healthrecord.ophtalmology.screen" property="value" outputString="checked"/> value="healthrecord.ophtalmology.screen">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.screen",sWebLanguage,"mov_c7")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_CAR_DRIVING")%> type="checkbox" id="mov_c8" tabindex="8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_CAR_DRIVING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_CAR_DRIVING;value=healthrecord.ophtalmology.car-driving" property="value" outputString="checked"/> value="healthrecord.ophtalmology.car-driving">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.car-driving",sWebLanguage,"mov_c8")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_OTHER")%> type="checkbox" id="mov_c9" tabindex="9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_OTHER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_OTHER;value=healthrecord.ophtalmology.other" property="value" outputString="checked"/> value="healthrecord.ophtalmology.other">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.other",sWebLanguage,"mov_c9")%>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_UNIFOCAL")%> type="checkbox" id="mov_c10" tabindex="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_UNIFOCAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_UNIFOCAL;value=healthrecord.ophtalmology.unifocal" property="value" outputString="checked"/> value="healthrecord.ophtalmology.unifocal">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.unifocal",sWebLanguage,"mov_c10")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_BIFOCAL")%> type="checkbox" id="mov_c11" tabindex="11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_BIFOCAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_BIFOCAL;value=healthrecord.ophtalmology.bifocal" property="value" outputString="checked"/> value="healthrecord.ophtalmology.bifocal">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.bifocal",sWebLanguage,"mov_c11")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_TRIFOCAL")%> type="checkbox" id="mov_c12" tabindex="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_TRIFOCAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_TRIFOCAL;value=healthrecord.ophtalmology.trifocal" property="value" outputString="checked"/> value="healthrecord.ophtalmology.trifocal">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.trifocal",sWebLanguage,"mov_c12")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_HALF_MOONS")%> type="checkbox" id="mov_c13" tabindex="13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_HALF_MOONS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_HALF_MOONS;value=healthrecord.ophtalmology.half-moons" property="value" outputString="checked"/> value="healthrecord.ophtalmology.half-moons">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.half-moons",sWebLanguage,"mov_c13")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PROGRESSIF")%> type="checkbox" id="mov_c14" tabindex="14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PROGRESSIF" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_PROGRESSIF;value=healthrecord.ophtalmology.progressif" property="value" outputString="checked"/> value="healthrecord.ophtalmology.progressif">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.progressif",sWebLanguage,"mov_c14")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LENSES")%> type="checkbox" id="mov_c15" tabindex="15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LENSES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST_LENSES;value=healthrecord.ophtalmology.lenses" property="value" outputString="checked"/> value="healthrecord.ophtalmology.lenses">
                        <%=getLabel("web.occup","healthrecord.ophtalmology.lenses",sWebLanguage,"mov_c15")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY")%> type="checkbox" id="mov_c16" tabindex="16" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY;value=medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie">
                        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie",sWebLanguage,"mov_c16")%>
                    </td>
                    <td>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK")%> type="checkbox" id="mov_c17" tabindex="17" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK;value=medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK">
                        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK",sWebLanguage,"mov_c17")%>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web.occup","healthrecord.ophtalmology.correction-porter",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web.occup","healthrecord.ophtalmology.correction-type",sWebLanguage)%></td>
    </tr>
    <%--- rechter oog ----------------------------------------------------------------------------%>
    <tr class="label">
        <td width="20%"><%=getTran("web.occup","rightEye",sWebLanguage)%></td>
        <td width="20%"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage)%></td>
        <td width="20%"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zicht_in_tussenafstand",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage)%></td>
    </tr>
    <%-- ZICHTSCHERPTE MONOCULAIR --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zichtscherpte_monoculair",sWebLanguage)%></td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES")%> type="text" tabindex="18" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES")%> type="text" tabindex="19" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_WITHOUT_GLASSES")%> type="text" tabindex="38" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_GLASSES")%> type="text" tabindex="39" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_INTER_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITHOUT_GLASSES")%> type="text" tabindex="54" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITH_GLASSES")%> type="text" tabindex="55" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OD_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
    </tr>
    <%-- ASTIGMATISME --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.astigmatisme",sWebLanguage)%></td>
        <td class="admin2" colspan="3">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.lijnen_gelijk",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r1" tabindex="20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r1")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r2" tabindex="21" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_EQUAL;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r2")%>
        </td>
    </tr>
    <%-- VOORZETLENZEN --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.voorzetlensen",sWebLanguage)%></td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.latente_hypermetropie",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r3" tabindex="22" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r3")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r4" tabindex="23" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_LATENT;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r4")%>
        </td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.verbetering",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r5" tabindex="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r5")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r6" tabindex="41" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_BETTER;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r6")%>
        </td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.verbetering",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r7" tabindex="56" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r7")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r8" tabindex="57" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_CLOSE_WITH_BETTER;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r8")%>
        </td>
    </tr>
    <%-- 3 REMARKS --%>
    <tr>
        <td class='admin'><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_FAR")%> class="text" cols="40" rows="2" tabindex="24" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_FAR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_FAR" property="value"/></textarea>
        </td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_MIDDLE")%> class="text" cols="40" rows="2" tabindex="42" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_MIDDLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_MIDDLE" property="value"/></textarea>
        </td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_CLOSE")%> class="text" cols="40" rows="2" tabindex="58" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_CLOSE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OD_CLOSE" property="value"/></textarea>
        </td>
    </tr>
    <%--- linker oog -----------------------------------------------------------------------------%>
    <tr class="label">
        <td><%=getTran("web.occup","leftEye",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zicht_in_tussenafstand",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage)%></td>
    </tr>
    <%-- ZICHTSCHERPTE MONOCULAIR --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zichtscherpte_monoculair",sWebLanguage)%></td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES")%> type="text" tabindex="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES")%> type="text" tabindex="26" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_WITHOUT_GLASSES")%> type="text" tabindex="43" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_GLASSES")%> type="text" tabindex="44" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_INTER_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITHOUT_GLASSES")%> type="text" tabindex="59" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITH_GLASSES")%> type="text" tabindex="60" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_OG_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
    </tr>
    <%-- ASTIGMATISME --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.astigmatisme",sWebLanguage)%></td>
        <td class="admin2" colspan="3">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.lijnen_gelijk",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r9" tabindex="27" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r9")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r10" tabindex="28" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_EQUAL;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r10")%>
        </td>
    </tr>
    <%-- VOORZETLENZEN --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.voorzetlensen",sWebLanguage)%></td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.latente_hypermetropie",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r11" tabindex="29" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r11")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r12" tabindex="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_LATENT;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r12")%>
        </td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.verbetering",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r13" tabindex="45" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r13")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r14" tabindex="46" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_BETTER;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r14")%>
        </td>
        <td class="admin2">
            <%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.verbetering",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r15" tabindex="61" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER;value=1" property="value" outputString="checked"/> value="1">
            <%=getLabel("Web","yes",sWebLanguage,"movi_r15")%>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r16" tabindex="62" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_CLOSE_WITH_BETTER;value=0" property="value" outputString="checked"/> value="0">
            <%=getLabel("Web","no",sWebLanguage,"movi_r16")%>
        </td>
   </tr>
   <%-- 3 REMARKS --%>
   <tr>
       <td class="admin"><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" style="vertical-align:top;">
           <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_FAR")%> class="text" cols="40" rows="2" tabindex="31" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_FAR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_FAR" property="value"/></textarea>
       </td>
        <td class="admin2" style="vertical-align:top;">
           <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_MIDDLE")%> class="text" cols="40" rows="2" tabindex="47" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_MIDDLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_MIDDLE" property="value"/></textarea>
       </td>
        <td class="admin2" style="vertical-align:top;">
           <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_CLOSE")%> class="text" cols="40" rows="2" tabindex="63" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_CLOSE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK_OG_CLOSE" property="value"/></textarea>
       </td>
   </tr>
    <%--- binoculair -----------------------------------------------------------------------------%>
    <tr class="label">
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.binoculair",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zicht_in_tussenafstand",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin">&nbsp;</td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")%> type="text" tabindex="32" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")%> type="text" tabindex="33" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_WITHOUT_GLASSES")%> type="text" tabindex="48" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_GLASSES")%> type="text" tabindex="49" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_INTER_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITHOUT_GLASSES")%> type="text" tabindex="64" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITH_GLASSES")%> type="text" tabindex="65" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CLOSE_BONI_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
            &#47;10
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%>
        </td>
    </tr>
    <%-- STEREOSCOPIE ----------------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.stereoscopie",sWebLanguage)%></td>
        <td colspan="3">
            <table width="100%" cellspacing="1">
                <%-- HEADER --%>
                <tr>
                    <td class="admin" width="40">1</td>
                    <td class="admin" width="40">2</td>
                    <td class="admin" width="40">3</td>
                    <td class="admin" width="40">4</td>
                    <td class="admin" width="40">5</td>
                    <td class="admin" width="40">6</td>
                    <td class="admin" width="40">7</td>
                    <td class="admin" width="40">8</td>
                    <td class="admin"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.test_uitgevoerd",sWebLanguage)%></td>
                </tr>
                <%-- A --%>
                <tr>
                    <td id="r1A"><input id="radio1A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=A" property="value" outputString="checked"/> onclick="toggleColor('1','A')"> A</td>
                    <td id="r2A"><input id="radio2A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=A" property="value" outputString="checked"/> onclick="toggleColor('2','A')"> A</td>
                    <td id="r3A"><input id="radio3A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=A" property="value" outputString="checked"/> onclick="toggleColor('3','A')"> A</td>
                    <td id="r4A"><input id="radio4A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=A" property="value" outputString="checked"/> onclick="toggleColor('4','A')"> A</td>
                    <td id="r5A"><input id="radio5A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=A" property="value" outputString="checked"/> onclick="toggleColor('5','A')"> A</td>
                    <td id="r6A"><input id="radio6A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6;value=A" property="value" outputString="checked"/> onclick="toggleColor('6','A')"> A</td>
                    <td id="r7A"><input id="radio7A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7;value=A" property="value" outputString="checked"/> onclick="toggleColor('7','A')"> A</td>
                    <td id="r8A"><input id="radio8A" type="radio" value="A" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8;value=A" property="value" outputString="checked"/> onclick="toggleColor('8','A')"> A</td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="radio9A" value="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION;value=1" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_ver",sWebLanguage,"radio9A")%>
                    </td>
                </tr>
                <%-- B --%>
                <tr>
                    <td id="r1B"><input id="radio1B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=B" property="value" outputString="checked"/> onclick="toggleColor('1','B')"> B</td>
                    <td id="r2B"><input id="radio2B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=B" property="value" outputString="checked"/> onclick="toggleColor('2','B')"> B</td>
                    <td id="r3B"><input id="radio3B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=B" property="value" outputString="checked"/> onclick="toggleColor('3','B')"> B</td>
                    <td id="r4B"><input id="radio4B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=B" property="value" outputString="checked"/> onclick="toggleColor('4','B')"> B</td>
                    <td id="r5B"><input id="radio5B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=B" property="value" outputString="checked"/> onclick="toggleColor('5','B')"> B</td>
                    <td id="r6B"><input id="radio6B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6;value=B" property="value" outputString="checked"/> onclick="toggleColor('6','B')"> B</td>
                    <td id="r7B"><input id="radio7B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7;value=B" property="value" outputString="checked"/> onclick="toggleColor('7','B')"> B</td>
                    <td id="r8B"><input id="radio8B" type="radio" value="B" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8;value=B" property="value" outputString="checked"/> onclick="toggleColor('8','B')"> B</td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="radio9B" value="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION;value=2" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.tussenafstand",sWebLanguage,"radio9B")%>
                    </td>
                </tr>
                <%-- C --%>
                <tr>
                    <td id="r1C"><input id="radio1C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=C" property="value" outputString="checked"/> onclick="toggleColor('1','C')"> C</td>
                    <td id="r2C"><input id="radio2C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=C" property="value" outputString="checked"/> onclick="toggleColor('2','C')"> C</td>
                    <td id="r3C"><input id="radio3C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=C" property="value" outputString="checked"/> onclick="toggleColor('3','C')"> C</td>
                    <td id="r4C"><input id="radio4C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=C" property="value" outputString="checked"/> onclick="toggleColor('4','C')"> C</td>
                    <td id="r5C"><input id="radio5C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=C" property="value" outputString="checked"/> onclick="toggleColor('5','C')"> C</td>
                    <td id="r6C"><input id="radio6C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_6;value=C" property="value" outputString="checked"/> onclick="toggleColor('6','C')"> C</td>
                    <td id="r7C"><input id="radio7C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_7;value=C" property="value" outputString="checked"/> onclick="toggleColor('7','C')"> C</td>
                    <td id="r8C"><input id="radio8C" type="radio" value="C" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_8;value=C" property="value" outputString="checked"/> onclick="toggleColor('8','C')"> C</td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="radio9C" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION;value=3" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_nabij",sWebLanguage,"radio9C")%>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- 3 REMARKS --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_FAR")%> class="text" cols="40" rows="2" tabindex="34" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_FAR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_FAR" property="value"/></textarea>
        </td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_MIDDLE")%> class="text" cols="40" rows="2" tabindex="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_MIDDLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_MIDDLE" property="value"/></textarea>
        </td>
        <td class='admin2' style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_CLOSE")%> class="text" cols="40" rows="2" tabindex="66" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_CLOSE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK_CLOSE" property="value"/></textarea>
        </td>
    </tr>
    <%--- ametropie ------------------------------------------------------------------------------%>
    <tr class="label">
        <td><%=getTran("web.occup","healthrecord.ophtalmology.ametropie",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.zicht_in_tussenafstand",sWebLanguage)%></td>
        <td><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage)%></td>
    </tr>
    <%-- AMETROPIE --%>
    <tr>
        <td class="admin">&nbsp;</td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r17" value="1" tabindex="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR;value=1" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.red",sWebLanguage,"movi_r17")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_MIDDLE")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r18" value="2" tabindex="36" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR;value=2" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","healthrecord.ophtalmology.balance",sWebLanguage,"movi_r18")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r19" value="3" tabindex="37" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR;value=3" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.green",sWebLanguage,"movi_r19")%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r20" value="1" tabindex="51" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER;value=1" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.red",sWebLanguage,"movi_r20")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r21" value="2" tabindex="52" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER;value=2" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","healthrecord.ophtalmology.balance",sWebLanguage,"movi_r21")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r22" value="3" tabindex="53" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER;value=3" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.green",sWebLanguage,"movi_r22")%>
        </td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_FAR")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r23" value="1" tabindex="67" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE;value=1" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.red",sWebLanguage,"movi_r23")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_INTER")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r24" value="2" tabindex="68" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE;value=2" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","healthrecord.ophtalmology.balance",sWebLanguage,"movi_r24")%>
            <br>
            <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE")%> type="radio" onDblClick="uncheckRadio(this);" id="movi_r25" value="3" tabindex="69" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_AMETROPIE_CLOSE;value=3" property="value" outputString="checked"/>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.green",sWebLanguage,"movi_r25")%>
        </td>
    </tr>
    <%-- phories / vertezicht --------------------------------------------------------------------%>
    <tr class="label">
        <td><%=getTran("web.occup","healthrecord.ophtalmology.phories",sWebLanguage)%></td>
        <td colspan="3"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.vertezicht",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin" rowspan="5">&nbsp;</td>
        <td colspan="3" class="admin2">
            <table cellspacing="1" border="1">
                <%-- HEADER --%>
                <tr>
                    <td/>
                    <td align="center">A</td>
                    <td align="center">B</td>
                    <td align="center">C</td>
                    <td align="center">D</td>
                    <td align="center">E</td>
                    <td align="center">F</td>
                    <td align="center">G</td>
                    <td align="center">H</td>
                    <td align="center">I</td>
                    <td align="center">J</td>
                    <td align="center">K</td>
                    <td align="center">L</td>
                    <td align="center">M</td>
                    <td align="center">N</td>
                    <td align="center">O</td>
                </tr>
                <%-- row 1 --%>
                <tr>
                    <td>1</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" tabindex="70" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=1" property="value" outputString="checked"/> value="1"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=2" property="value" outputString="checked"/> value="2"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=3" property="value" outputString="checked"/> value="3"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=4" property="value" outputString="checked"/> value="4"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=5" property="value" outputString="checked"/> value="5"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=6" property="value" outputString="checked"/> value="6"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=7" property="value" outputString="checked"/> value="7"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=8" property="value" outputString="checked"/> value="8"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=9" property="value" outputString="checked"/> value="9"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=10" property="value" outputString="checked"/> value="10"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=11" property="value" outputString="checked"/> value="11"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=12" property="value" outputString="checked"/> value="12"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=13" property="value" outputString="checked"/> value="13"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=14" property="value" outputString="checked"/> value="14"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=15" property="value" outputString="checked"/> value="15"></td>
                </tr>
                <%-- row 2 --%>
                <tr>
                    <td>2</td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=16" property="value" outputString="checked"/> value="16"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=17" property="value" outputString="checked"/> value="17"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=18" property="value" outputString="checked"/> value="18"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=19" property="value" outputString="checked"/> value="19"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=20" property="value" outputString="checked"/> value="20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=21" property="value" outputString="checked"/> value="21"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=22" property="value" outputString="checked"/> value="22"></td>
                    <td bgcolor="#333333"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=23" property="value" outputString="checked"/> value="23"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=24" property="value" outputString="checked"/> value="24"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=25" property="value" outputString="checked"/> value="25"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=26" property="value" outputString="checked"/> value="26"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=27" property="value" outputString="checked"/> value="27"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=28" property="value" outputString="checked"/> value="28"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=29" property="value" outputString="checked"/> value="29"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=30" property="value" outputString="checked"/> value="30"></td>
                </tr>
                <%-- row 3 --%>
                <tr>
                    <td>3</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=31" property="value" outputString="checked"/> value="31"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=32" property="value" outputString="checked"/> value="32"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=33" property="value" outputString="checked"/> value="33"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=34" property="value" outputString="checked"/> value="34"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=35" property="value" outputString="checked"/> value="35"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=36" property="value" outputString="checked"/> value="36"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=37" property="value" outputString="checked"/> value="37"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=38" property="value" outputString="checked"/> value="38"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=39" property="value" outputString="checked"/> value="39"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=40" property="value" outputString="checked"/> value="40"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=41" property="value" outputString="checked"/> value="41"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=42" property="value" outputString="checked"/> value="42"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=43" property="value" outputString="checked"/> value="43"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=44" property="value" outputString="checked"/> value="44"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_FAR;value=45" property="value" outputString="checked"/> value="45"></td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- MOVEMENT --%>
    <tr>
        <td class="admin2" colspan="3">
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement",sWebLanguage)%>:
            <select tabindex="71" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT" property="itemId"/>]>.value" class="text">
                <option/>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.stable" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.stable" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.stable",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.arise_left" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.arise_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.arise_right" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.arise_right",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.no_vision" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.no_vision" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.no_vision",sWebLanguage)%></option>
            </select>
        </td>
    </tr>
    <%-- nabijzicht ------------------------------------------------------------------------------%>
    <tr class="label">
        <td colspan="3"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.nabijzicht",sWebLanguage)%></td>
    </tr>
    <tr>
        <td colspan="3" class="admin2">
            <table cellspacing="1" border="1">
                <%-- HEADER --%>
                <tr>
                    <td/>
                    <td align="center">A</td>
                    <td align="center">B</td>
                    <td align="center">C</td>
                    <td align="center">D</td>
                    <td align="center">E</td>
                    <td align="center">F</td>
                    <td align="center">G</td>
                    <td align="center">H</td>
                    <td align="center">I</td>
                    <td align="center">J</td>
                    <td align="center">K</td>
                    <td align="center">L</td>
                    <td align="center">M</td>
                    <td align="center">N</td>
                    <td align="center">O</td>
                </tr>
                <%-- row 1 --%>
                <tr>
                    <td>1</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" tabindex="72" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=1" property="value" outputString="checked"/> value="1"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=2" property="value" outputString="checked"/> value="2"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=3" property="value" outputString="checked"/> value="3"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=4" property="value" outputString="checked"/> value="4"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=5" property="value" outputString="checked"/> value="5"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=6" property="value" outputString="checked"/> value="6"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=7" property="value" outputString="checked"/> value="7"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=8" property="value" outputString="checked"/> value="8"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=9" property="value" outputString="checked"/> value="9"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=10" property="value" outputString="checked"/> value="10"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=11" property="value" outputString="checked"/> value="11"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=12" property="value" outputString="checked"/> value="12"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=13" property="value" outputString="checked"/> value="13"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=14" property="value" outputString="checked"/> value="14"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=15" property="value" outputString="checked"/> value="15"></td>
                </tr>
                <%-- row 2 --%>
                <tr>
                    <td>2</td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=16" property="value" outputString="checked"/> value="16"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=17" property="value" outputString="checked"/> value="17"></td>
                    <td bgcolor="#333333"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=18" property="value" outputString="checked"/> value="18"></td>
                    <td bgcolor="#333333"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=19" property="value" outputString="checked"/> value="19"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=20" property="value" outputString="checked"/> value="20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=21" property="value" outputString="checked"/> value="21"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=22" property="value" outputString="checked"/> value="22"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=23" property="value" outputString="checked"/> value="23"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=24" property="value" outputString="checked"/> value="24"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=25" property="value" outputString="checked"/> value="25"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=26" property="value" outputString="checked"/> value="26"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=27" property="value" outputString="checked"/> value="27"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=28" property="value" outputString="checked"/> value="28"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=29" property="value" outputString="checked"/> value="29"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=30" property="value" outputString="checked"/> value="30"></td>
                </tr>
                <%-- row 3 --%>
                <tr>
                    <td>3</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=31" property="value" outputString="checked"/> value="31"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=32" property="value" outputString="checked"/> value="32"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=33" property="value" outputString="checked"/> value="33"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=34" property="value" outputString="checked"/> value="34"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=35" property="value" outputString="checked"/> value="35"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=36" property="value" outputString="checked"/> value="36"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=37" property="value" outputString="checked"/> value="37"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=38" property="value" outputString="checked"/> value="38"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=39" property="value" outputString="checked"/> value="39"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=40" property="value" outputString="checked"/> value="40"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=41" property="value" outputString="checked"/> value="41"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=42" property="value" outputString="checked"/> value="42"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=43" property="value" outputString="checked"/> value="43"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=44" property="value" outputString="checked"/> value="44"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_CLOSE;value=45" property="value" outputString="checked"/> value="45"></td>
                </tr>
            </table>
        </td>
    </tr>

    <%-- MOVEMENT --%>
    <tr>
        <td class="admin2" colspan="3">
            <%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement",sWebLanguage)%>:
            <select tabindex="73" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE" property="itemId"/>]>.value" class="text">
                <option/>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.stable" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.stable" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.stable",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.arise_left" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.arise_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.arise_right" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.arise_right",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.no_vision" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHORIES_MOVEMENT_CLOSE;value=medwan.healthrecord.ophtalmology.phories.movement.no_vision" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.healthrecord.ophtalmology.phories.movement.no_vision",sWebLanguage)%></option>
            </select>
        </td>
    </tr>

    <%--- KLEURGEVOELIGHEID ----------------------------------------------------------------------%>
    <tr class="label">
        <td><%=getTran("web.occup","healthrecord.ophtalmology.color-sens",sWebLanguage)%></td>
        <td colspan="3">
            <input type="radio" onDblClick="uncheckRadio(this);showModel(1);" value="1" id="model1Header" tabindex="74" onclick="showModel(1);document.getElementById('m1_co1').focus();" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_MODEL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_MODEL;value=1" property="value" outputString="checked"/>><%=getLabel("web.occup","healthrecord.ophtalmology.model",sWebLanguage,"model1Header")%>&nbsp;I&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" onDblClick="uncheckRadio(this);showModel(2);" value="2" id="model2" tabindex="75" onclick="showModel(2);document.getElementById('m2_co1').focus();" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_MODEL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_MODEL;value=2" property="value" outputString="checked"/>><%=getLabel("web.occup","healthrecord.ophtalmology.model",sWebLanguage,"model2")%>&nbsp;II
        </td>
    </tr>

    <%-- MODEL 1 ---------------------------------------------------------------------------------%>
    <tr id="model_1" style="display:none">
        <td class="admin">&nbsp;</td>
        <td colspan="3">
            <table width="100%" cellspacing="1">
                <%-- HEADER --%>
                <tr>
                    <td/>
                    <td class="admin" width="40">57</td>
                    <td class="admin" width="40">74</td>
                    <td class="admin" width="40"><%=getTran("web.occup","healthrecord.ophtalmology.nothing",sWebLanguage)%></td>
                    <td class="admin" width="40">96</td>
                    <td class="admin" rowspan="4">&nbsp;</td>
                    <td class="admin" width="30%"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.test_uitgevoerd",sWebLanguage)%></td>
                </tr>

                <%-- CORRECT --%>
                <tr>
                    <td class="admin2">
                        <a href="javascript:checkAllCorrectModel1();"><%=getTran("web.occup","healthrecord.ophtalmology.correct",sWebLanguage)%></a>
                    </td>
                    <td class="admin2">
                        <input id="m1_co1" type="radio" onDblClick="uncheckRadio(this);" tabindex="76" value="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57;value=1" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m1_value1'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m1_co3" type="radio" onDblClick="uncheckRadio(this);" tabindex="79" value="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74;value=1" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m1_value3'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m1_co4" type="radio" onDblClick="uncheckRadio(this);" tabindex="82" value="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING;value=1" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m1_value4'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m1_co2" type="radio" onDblClick="uncheckRadio(this);" tabindex="85" value="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96;value=1" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m1_value2'].value='';}">
                    </td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="1" tabindex="88" id="movi_26" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=1" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_ver",sWebLanguage,"movi_26")%>
                    </td>
                </tr>

                <script>
                  <%-- CHECK ALL CORRECT MODEL 1 --%>
                  function checkAllCorrectModel1(){
                    checkElementById("m1_co1");
                    checkElementById("m1_co2");
                    checkElementById("m1_co3");
                    checkElementById("m1_co4");

                    <%-- clear value fields of incorrect-section --%>
                    document.all["m1_value1"].value = "";
                    document.all["m1_value2"].value = "";
                    document.all["m1_value3"].value = "";
                    document.all["m1_value4"].value = "";
                  }
                </script>

                <%-- NOT CORRECT --%>
                <tr>
                    <td class="admin2">
                        <a href="javascript:checkAllIncorrectModel1();"><%=getTran("web.occup","healthrecord.ophtalmology.not-correct",sWebLanguage)%> - <%=getTran("web.occup","healthrecord.ophtalmology.value-read",sWebLanguage)%></a>
                    </td>
                    <td class="admin2">
                        <input id="m1_notco1" type="radio" onDblClick="uncheckRadio(this);" tabindex="77" value="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57;value=2" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m1_value1" type="text" tabindex="78" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57_VALUE" property="value"/>" class="text" size="1" onclick="document.all['m1_notco1'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m1_notco3" type="radio" onDblClick="uncheckRadio(this);" tabindex="80" value="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74;value=2" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m1_value3" type="text" tabindex="81" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74_VALUE" property="value"/>" class="text" size="1" onclick="document.all['m1_notco3'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m1_notco4" type="radio" onDblClick="uncheckRadio(this);" tabindex="83" value="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING;value=2" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m1_value4" type="text" tabindex="84" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING_VALUE" property="value"/>" class="text" size="1" onclick="document.all['m1_notco4'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m1_notco2" type="radio" onDblClick="uncheckRadio(this);" tabindex="86" value="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96;value=2" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m1_value2" type="text" tabindex="87" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96_VALUE" property="value"/>" class="text" size="1" onclick="document.all['m1_notco2'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="2" tabindex="89" id="movi_27" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=2" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.tussenafstand",sWebLanguage,"movi_27")%>
                    </td>
                </tr>

                <script>
                  <%-- CHECL ALL INCORRECT MODEL 1 --%>
                  function checkAllIncorrectModel1(){
                    checkElementById("m1_notco1");
                    checkElementById("m1_notco2");
                    checkElementById("m1_notco3");
                    checkElementById("m1_notco4");
                  }
                </script>

                <%-- VAN NABIJ --%>
                <tr>
                    <td class="admin2" colspan="5"></td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="3" tabindex="90" id="movi_28" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=3" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_nabij",sWebLanguage,"movi_28")%>
                    </td>
                </tr>
            </table>
        </td>
    <tr>

    <%-- MODEL 2 ---------------------------------------------------------------------------------%>
    <tr id="model_2" style="display:none">
        <td class="admin">&nbsp;</td>
        <td colspan="3">
            <table width="100%" cellspacing="1">
                <%-- HEADER --%>
                <tr>
                    <td/>
                    <td class="admin" width="40">57</td>
                    <td class="admin" width="40">74</td>
                    <td class="admin" width="40">97</td>
                    <td class="admin" width="40">16</td>
                    <td class="admin" width="40"><%=getTran("web.occup","healthrecord.ophtalmology.nothing",sWebLanguage)%></td>
                    <td class="admin" width="40">96</td>
                    <td class="admin" rowspan="4">&nbsp;</td>
                    <td class="admin" width="20%"><%=getTran("web.occup","delhaize.healthrecord.ophtalmology.av.test_uitgevoerd",sWebLanguage)%></td>
                </tr>

                <%-- CORRECT --%>
                <tr>
                    <td class="admin2">
                        <a href="javascript:checkAllCorrectModel2();"><%=getTran("web.occup","healthrecord.ophtalmology.correct",sWebLanguage)%></a>
                    </td>
                    <td class="admin2">
                        <input id="m2_co1" type="radio" onDblClick="uncheckRadio(this);" tabindex="91" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII1'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m2_co3" type="radio" onDblClick="uncheckRadio(this);" tabindex="94" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII3'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m2_co6" type="radio" onDblClick="uncheckRadio(this);" tabindex="97" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII6'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m2_co5" type="radio" onDblClick="uncheckRadio(this);" tabindex="100" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII5'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m2_co4" type="radio" onDblClick="uncheckRadio(this);" tabindex="103" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII4'].value='';}">
                    </td>
                    <td class="admin2">
                        <input id="m2_co2" type="radio" onDblClick="uncheckRadio(this);" tabindex="106" value="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96;value=3" property="value" outputString="checked"/> onclick="if(this.checked){document.all['m2_valueII2'].value='';}">
                    </td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="4" tabindex="109" id="movi_29" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=4" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_ver",sWebLanguage,"movi_29")%>
                    </td>
                </tr>

                <script>
                  <%-- CHECK ALL CORRECT MODEL 2 --%>
                  function checkAllCorrectModel2(){
                    checkElementById("m2_co1");
                    checkElementById("m2_co2");
                    checkElementById("m2_co3");
                    checkElementById("m2_co4");
                    checkElementById("m2_co5");
                    checkElementById("m2_co6");

                    <%-- clear value fields of incorrect-section --%>
                    document.all["m2_valueII1"].value = "";
                    document.all["m2_valueII2"].value = "";
                    document.all["m2_valueII3"].value = "";
                    document.all["m2_valueII4"].value = "";
                    document.all["m2_valueII5"].value = "";
                    document.all["m2_valueII6"].value = "";
                  }
                </script>

                <%-- NOT CORRECT --%>
                <tr>
                    <td class="admin2">
                        <a href="javascript:checkAllIncorrectModel2();"><%=getTran("web.occup","healthrecord.ophtalmology.not-correct",sWebLanguage)%> - <%=getTran("web.occup","healthrecord.ophtalmology.value-read",sWebLanguage)%></a>
                    </td>
                    <td class="admin2">
                       <input id="m2_notcoII1" type="radio" onDblClick="uncheckRadio(this);" tabindex="92" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                       <input id="m2_valueII1" type="text" tabindex="93" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_57_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII1'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m2_notcoII3" type="radio" onDblClick="uncheckRadio(this);" tabindex="95" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m2_valueII3" type="text" tabindex="96" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_74_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII3'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m2_notcoII6" type="radio" onDblClick="uncheckRadio(this);" tabindex="98" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m2_valueII6" type="text" tabindex="99" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_97_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII6'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m2_notcoII5" type="radio" onDblClick="uncheckRadio(this);" tabindex="101" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m2_valueII5" type="text" tabindex="102" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_16_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII5'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m2_notcoII4" type="radio" onDblClick="uncheckRadio(this);" tabindex="104" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m2_valueII4" type="text" tabindex="105" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_NOTHING_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII4'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input id="m2_notcoII2" type="radio" onDblClick="uncheckRadio(this);" tabindex="107" value="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96;value=4" property="value" outputString="checked"/>>&nbsp;-&nbsp;
                        <input id="m2_valueII2" type="text" tabindex="108" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96_VALUE_II" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_96_VALUE_II" property="value"/>" class="text" size="1" onclick="document.all['m2_notcoII2'].checked = true;">
                    </td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="5" tabindex="110" id="movi_30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=5" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.tussenafstand",sWebLanguage,"movi_30")%>
                    </td>
                </tr>

                <script>
                  <%-- CHECK ALL INCORRECT MODEL 2 --%>
                  function checkAllIncorrectModel2(){
                    checkElementById("m2_notcoII1");
                    checkElementById("m2_notcoII2");
                    checkElementById("m2_notcoII3");
                    checkElementById("m2_notcoII4");
                    checkElementById("m2_notcoII5");
                    checkElementById("m2_notcoII6");
                  }
                </script>

                <%-- VAN NABIJ --%>
                <tr>
                    <td class="admin2" colspan="7"></td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" value="6" tabindex="111" id="movi_31" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_COLOR_SENS_TEST;value=6" property="value" outputString="checked"/>>
                        <%=getLabel("web.occup","delhaize.healthrecord.ophtalmology.av.van_nabij",sWebLanguage,"movi_31")%>
                    </td>
                </tr>
            </table>
        </td>
    <tr>

    <%-- LAST VISIT ------------------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","last.visit.ophtalmologist",sWebLanguage)%></td>
        <td class="admin2" colspan="3" style="vertical-align:top;">
            <%=writeLooseDateFieldMonth("currentTransactionVO.items.<ItemVO[hashCode="+getCurrentItem(request,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST").getItemId()+"]>.value", "transactionForm",checkString(getLastItem(request,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST").getValue()),sWebLanguage)%>
        </td>
    </tr>

    <%-- LAST VISIT COMMENT ----------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
        <td class="admin2"  colspan="3" style="vertical-align:top;">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,1000);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT3" property="value"/></textarea>
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT3" property="itemId"/>]>.value">
        </td>
    </tr>

    <%-- PRESTATION TYPE (check visio by default) --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_opthalmology_type_prestation",sWebLanguage)%></td>
        <td class="admin2" colspan="3">
            <input type="radio" id="rTypeVisiotest" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.visiotest" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.visiotest" <%=(((TransactionVO)transaction).getTransactionId().intValue()<0?" checked":"")%>>
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage,"rTypeVisiotest")%>&nbsp;

            <input type="radio" id="rTypeNoPrestation" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.noprestation" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.noprestation">
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.noprestation",sWebLanguage,"rTypeNoPrestation")%>&nbsp;

            <input type="radio" id="rTypeFullVisionTest" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.fullvisiontest" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.fullvisiontest">
            <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.fullvisiontest",sWebLanguage,"rTypeFullVisionTest")%>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<p align="right">
    <%
        if(!dossierBlocked){
            %>
                <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="submitForm(true);"></button>
                <button class="button" name="ButtonSave" onclick="submitForm(true);"><%=getTran("accesskey","save",sWebLanguage)%></button>
                <input class="button" type="button" name="ButtonSaveClose" value="<%=getTranNoLink("Web","save_and_close",sWebLanguage)%>" onclick="submitForm(false);"/>
            <%
        }
        else{
            // display "dossier blocked"
            %>
                <font color="red"><%=getTran("Web.admin","fileBlocked",sWebLanguage)%></font>
                <button class="button" name="ButtonSave" style="display:none;">hidden</button>
            <%
        }
    %>
    <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
    <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
</p>

<script>
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>";
    }
  }

  <%-- TOGGLE COLOR --%>
  function toggleColor(row,col){
    if(document.all["r"+row+col].className!="admin2"){
      document.all["radio"+row+col].checked = false;
      document.all["r"+row+col].className="admin2";
    }
    else{
      document.all["r"+row+"A"].className="admin2";
      document.all["r"+row+"B"].className="admin2";
      document.all["r"+row+"C"].className="admin2";

      if((row=="1" && col=="B") ||
         (row=="2" && col=="C") ||
         (row=="3" && col=="B") ||
         (row=="4" && col=="A") ||
         (row=="5" && col=="C") ||
         (row=="6" && col=="B") ||
         (row=="7" && col=="C") ||
         (row=="8" && col=="A")){
        document.all["r"+row+col].className="menuItemGreen";
      }
      else{
        document.all["r"+row+col].className="menuItemRed";
      }
    }
  }

  function checkElementById(id){
    document.getElementById(id).checked = true;
  }

  function uncheckElementById(id){
    document.getElementById(id).checked = false;
  }

  function setTrue(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.false";
  }

  document.getElementById("mov_c1").focus();

  for(var i=1; i<9; i++){
    document.all["r"+i+"A"].className="admin2";
    document.all["r"+i+"B"].className="admin2";
    document.all["r"+i+"C"].className="admin2";

         if(document.all["radio"+i+"A"].checked) toggleColor(i,"A");
    else if(document.all["radio"+i+"B"].checked) toggleColor(i,"B");
    else if(document.all["radio"+i+"C"].checked) toggleColor(i,"C");
  }

  <%-- SHOW MODEL --%>
  function showModel(iIndex){
    if(iIndex==1 && document.all["model1"].checked){
      show("model_1");
    }
    else{
      hide("model_1");
    }

    if(iIndex==2 && document.all["model2"].checked){
      show("model_2");
    }
    else{
      hide("model_2");
    }
  }

  if(document.all["model1"].checked) document.all["model_1"].style.display = "block";
  if(document.all["model2"].checked) document.all["model_2"].style.display = "block";

  <%-- SUBMIT FORM --%>
  function submitForm(bReturn){
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT1" property="itemId"/>]>.value"].value = document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"].value.substring(250,500);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT2" property="itemId"/>]>.value"].value = document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"].value.substring(500,750);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT3" property="itemId"/>]>.value"].value = document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"].value.substring(750,1000);
    document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"].value = document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LAST_VISIT_OPHTALMOLOGIST_COMMENT" property="itemId"/>]>.value"].value.substring(0,250);
    <%
        out.print(writeTransactionReturn());
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO,activeUser,"transactionForm.submit();"));
    %>
  }
</script>
</form>

<%=writeJSButtons("transactionForm","ButtonSave")%>