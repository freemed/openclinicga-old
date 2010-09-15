<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("occup.leprosyend","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=contextHeader(request,sWebLanguage)%>

    <table width="100%" cellspacing="1" class="list">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- NERVES -----------------------------------------------------------------------------%>
        <tr>
            <td class="admin"><%=getTran("leprosy","nerves",sWebLanguage)%></td>
            <td>
                <table width="100%" cellspacing="1" class="list">
                    <%-- header --%>
                    <tr>
                        <td width="20%">&nbsp;</td>
                        <td class="admin" width="26%" colspan="2" style="text-align:center;"><%=getTran("leprosy","median",sWebLanguage)%></td>
                        <td class="admin" width="26%" colspan="2" style="text-align:center;"><%=getTran("leprosy","cubital",sWebLanguage)%></td>
                        <td class="admin" width="28%" colspan="2" style="text-align:center;"><%=getTran("leprosy","SciatiquePopliteExterne",sWebLanguage)%></td>
                    </tr>

                    <%-- sub header --%>
                    <tr>
                        <td>&nbsp;</td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                    </tr>

                    <%-- row 1 : epaissis --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","epaissis",sWebLanguage)%>
                        </td>

                        <%-- median --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_epaissis")%>
                        </td>

                        <%-- cubital --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r5_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r6_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r7_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r7_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r8_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r8_epaissis")%>
                        </td>

                        <%-- SciatiquePopliteExterne --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r9_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r9_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r10_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r10_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r11_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r11_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r12_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r12_epaissis")%>
                        </td>
                    </tr>

                    <%-- row 2 : douloureux --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","douloureux",sWebLanguage)%>
                        </td>

                        <%-- median --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_douloureux")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_douloureux")%>
                        </td>

                        <%-- cubital --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r5_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r6_douloureux")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r7_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r7_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r8_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r8_douloureux")%>
                        </td>

                        <%-- Sciatique Poplite Externe --%>
                        <td class="admin2" nowrap>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r9_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r9_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r10_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r10_douloureux")%>
                        </td>
                        <td class="admin2" nowrap>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r11_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r11_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r12_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r12_douloureux")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- MUSCULAR FORCE -----------------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin"><%=getTran("leprosy","muscularforce",sWebLanguage)%></td>
            <td>
                <table width="100%" cellspacing="1" class="list">
                    <%-- header --%>
                    <tr>
                        <td width="20%">&nbsp;</td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                    </tr>

                    <%-- row 1 : occlusion occulaire --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","occlusionocculaire",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_occlusion")%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_occlusion")%>
                        </td>
                    </tr>

                    <%-- row 2 : fente en mm --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","fente",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_RIGHT")%> type="text" class="text" size="5" id="fenteRight" maxLength="3" onBlur="isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_RIGHT" property="value"/>">
                        </td>

                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_LEFT")%> type="text" class="text" size="5" id="fenteLeft" maxLength="3"onBlur="isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_LEFT" property="value"/>">
                        </td>
                    </tr>

                    <%-- row 3 : cinquième doigt --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","cinquiemedoigt",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_doigt")%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_doigt")%>
                        </td>
                    </tr>

                    <%-- row 4 : pouce en haut --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","pouceenhaut",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_pouce")%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_pouce")%>
                        </td>
                    </tr>

                    <%-- row 5 : pied en haut --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","piedenhaut",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_pied")%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_pied")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- YEUX -------------------------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin"><%=getTran("leprosy","yeux",sWebLanguage)%></td>
            <td>
                <table width="100%" cellspacing="1" class="list">
                    <%-- header --%>
                    <tr>
                        <td width="20%">&nbsp;</td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                    </tr>

                    <%-- row 1 : acuité visuelle --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","acuitevisuelle",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_acuitevisuelle")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_acuitevisuelle")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_acuitevisuelle")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_acuitevisuelle")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- COTATION DES INFIRMITES ------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin"><%=getTran("leprosy","cotationdesinfirmites",sWebLanguage)%></td>
            <td>
                <table width="100%" cellspacing="1" class="list">
                    <%-- header --%>
                    <tr>
                        <td width="20%">&nbsp;</td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","right",sWebLanguage)%></td>
                        <td class="admin" width="40%" style="text-align:center;"><%=getTran("web","left",sWebLanguage)%></td>
                    </tr>

                    <%-- row 1 : Oeil --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","oeil",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" id="r1_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","oeil_cotation0",sWebLanguage,"r1_cotoeil")%><br>
                            <input type="radio" id="r2_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","oeil_cotation2",sWebLanguage,"r2_cotoeil")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r3_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","oeil_cotation0",sWebLanguage,"r3_cotoeil")%><br>
                            <input type="radio" id="r4_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_OEIL_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","oeil_cotation2",sWebLanguage,"r4_cotoeil")%>
                        </td>
                    </tr>

                    <%-- row 2 : Main --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","main",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" id="r1_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation0",sWebLanguage,"r1_cotmain")%><br>
                            <input type="radio" id="r2_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation1",sWebLanguage,"r2_cotmain")%><br>
                            <input type="radio" id="r3_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation2",sWebLanguage,"r3_cotmain")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r4_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation0",sWebLanguage,"r4_cotmain")%><br>
                            <input type="radio" id="r5_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation1",sWebLanguage,"r5_cotmain")%><br>
                            <input type="radio" id="r6_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation2",sWebLanguage,"r6_cotmain")%>
                        </td>
                    </tr>

                    <%-- row 3 : Pied --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("leprosy","pied",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            <input type="radio" id="r1_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation0",sWebLanguage,"r1_cotpied")%><br>
                            <input type="radio" id="r2_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation1",sWebLanguage,"r2_cotpied")%><br>
                            <input type="radio" id="r3_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation2",sWebLanguage,"r3_cotpied")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r4_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation0",sWebLanguage,"r4_cotpied")%><br>
                            <input type="radio" id="r5_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation1",sWebLanguage,"r5_cotpied")%><br>
                            <input type="radio" id="r6_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation2",sWebLanguage,"r6_cotpied")%>
                        </td>
                    </tr>

                    <%-- row 4 : totals --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("web","total",sWebLanguage)%>
                        </td>

                        <td class="admin2">
                            &nbsp;<input type="text" class="text" size="1" style="color:black;" id="cotationTotalRight" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_RIGHT" property="value"/>" READONLY>
                        </td>
                        <td class="admin2">
                            &nbsp;<input type="text" class="text" size="1" style="color:black;" id="cotationTotalLeft" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_LEFT" property="value"/>" READONLY>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- TREATMENT RESULT --%>
        <tr>
            <td class="admin"><%=getTran("leprosy","treatmentresult",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="c1_result" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TT" property="itemId"/>]>.value" value="tt" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TT;value=tt" property="value" outputString="checked"/>><%=getLabel("leprosy","tt",sWebLanguage,"c1_result")%>&nbsp;
                <input type="checkbox" id="c2_result" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_THT" property="itemId"/>]>.value" value="tht" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_THT;value=tht" property="value" outputString="checked"/>><%=getLabel("leprosy","tht",sWebLanguage,"c2_result")%>&nbsp;
                <input type="checkbox" id="c3_result" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_DCD" property="itemId"/>]>.value" value="dcd" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_DCD;value=dcd" property="value" outputString="checked"/>><%=getLabel("leprosy","dcd",sWebLanguage,"c3_result")%>&nbsp;
                <input type="checkbox" id="c4_result" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TRANSFUSION" property="itemId"/>]>.value" value="transfusion" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TRANSFUSION;value=transfusion" property="value" outputString="checked"/>><%=getLabel("leprosy","transfusion",sWebLanguage,"c4_result")%>
            </td>
        </tr>

        <%-- COMMENT ----------------------------------------------------------------------------%>
        <tr>
            <td class="admin"><%=getTran("Web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" id="comment" class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYEND_COMMENT" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.leprosyend",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- CALCULATE TOTAL --%>
  function calculateTotal(totalFieldId){
    var total = 0;
    var noItemsChecked = true;

    if(totalFieldId=="cotationTotalRight"){
      if(document.getElementById("r1_cotoeil").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r2_cotoeil").checked){ total+= 2; noItemsChecked = false; }

      if(document.getElementById("r1_cotmain").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r2_cotmain").checked){ total+= 1; noItemsChecked = false; }
      if(document.getElementById("r3_cotmain").checked){ total+= 2; noItemsChecked = false; }

      if(document.getElementById("r1_cotpied").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r2_cotpied").checked){ total+= 1; noItemsChecked = false; }
      if(document.getElementById("r3_cotpied").checked){ total+= 2; noItemsChecked = false; }
    }
    else if(totalFieldId=="cotationTotalLeft"){
      if(document.getElementById("r3_cotoeil").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r4_cotoeil").checked){ total+= 2; noItemsChecked = false; }

      if(document.getElementById("r4_cotmain").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r5_cotmain").checked){ total+= 1; noItemsChecked = false; }
      if(document.getElementById("r6_cotmain").checked){ total+= 2; noItemsChecked = false; }

      if(document.getElementById("r4_cotpied").checked){ total+= 0; noItemsChecked = false; }
      if(document.getElementById("r5_cotpied").checked){ total+= 1; noItemsChecked = false; }
      if(document.getElementById("r6_cotpied").checked){ total+= 2; noItemsChecked = false; }
    }

    if(noItemsChecked) total = "";
    document.getElementById(totalFieldId).value = total;
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.saveButton.style.visibility = "hidden";
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>