<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.leprosybegin","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    
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
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- LEPROSY TYPE --%>
        <tr>
            <td class="admin"><%=getTran("leprosy","leprosyType",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%--
                <input type="radio" onDblClick="uncheckRadio(this);" id="r_pb" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE" property="itemId"/>]>.value" value="pb" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE;value=pb" property="value" outputString="checked"/>><%=getLabel("leprosy","pb",sWebLanguage,"r_pb")%>&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r_mb" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE" property="itemId"/>]>.value" value="mb" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE;value=mb" property="value" outputString="checked"/>><%=getLabel("leprosy","mb",sWebLanguage,"r_mb")%>
                --%>
                <input type="checkbox" id="c1_type" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE_PB" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE_PB;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","pb",sWebLanguage,"c1_type")%>
                <input type="checkbox" id="c2_type" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE_MB" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_LEPROSY_TYPE_MB;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","mb",sWebLanguage,"c2_type")%>
            </td>
        </tr>

        <%-- PATIENT CATEGORY --%>
        <tr>
            <td class="admin"><%=getTran("leprosy","patientCategory",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%--
                <input type="radio" onDblClick="uncheckRadio(this);" id="r1_patcat" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY" property="itemId"/>]>.value" value="new" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY;value=new" property="value" outputString="checked"/>><%=getLabel("leprosy","new",sWebLanguage,"r1_patcat")%>&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r2_patcat" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY" property="itemId"/>]>.value" value="transfusion" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY;value=transfusion" property="value" outputString="checked"/>><%=getLabel("leprosy","transfusion",sWebLanguage,"r2_patcat")%>&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r3_patcat" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY" property="itemId"/>]>.value" value="relapse" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY;value=relapse" property="value" outputString="checked"/>><%=getLabel("leprosy","relapse",sWebLanguage,"r3_patcat")%>&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r4_patcat" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY" property="itemId"/>]>.value" value="raa" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY;value=raa" property="value" outputString="checked"/>><%=getLabel("leprosy","raa",sWebLanguage,"r4_patcat")%>
                --%>
                <input type="checkbox" id="c1_category" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_NEW" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_NEW;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","new",sWebLanguage,"c1_category")%>
                <input type="checkbox" id="c2_category" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_TRANSFUSION" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_TRANSFUSION;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","transfusion",sWebLanguage,"c2_category")%>
                <input type="checkbox" id="c3_category" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_RELAPSE" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_RELAPSE;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","relapse",sWebLanguage,"c3_category")%>
                <input type="checkbox" id="c4_category" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_RAA" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_PATIENT_CATEGORY_RAA;value=true" property="value" outputString="checked"/>><%=getLabel("leprosy","raa",sWebLanguage,"c4_category")%>
            </td>
        </tr>

        <%-- BACTERIOLOGICAL INDEX --%>
        <tr>
            <td class="admin"><%=getTran("leprosy","bacteriologicalIndex",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="r1_bactidx" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX" property="itemId"/>]>.value" value="pos" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX;value=pos" property="value" outputString="checked"/> onClick="document.getElementById('positiveComment').focus();"><%=getLabel("web","positive",sWebLanguage,"r1_bactidx")%>&nbsp;:
                <input <%=setRightClick("ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX_POS_COMMENT")%> type="text" class="text" size="20" id="positiveComment" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX_POS_COMMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX_POS_COMMENT" property="value"/>">&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r2_bactidx" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX" property="itemId"/>]>.value" value="neg" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX;value=neg" property="value" outputString="checked"/> onClick="document.getElementById('positiveComment').value='';"><%=getLabel("web","negative",sWebLanguage,"r2_bactidx")%>&nbsp;
                <input type="radio" onDblClick="uncheckRadio(this);" id="r3_bactidx" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX" property="itemId"/>]>.value" value="notdone" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_BACTERIOLOGICAL_INDEX;value=notdone" property="value" outputString="checked"/>><%=getLabel("web","notdone",sWebLanguage,"r3_bactidx")%>
            </td>
        </tr>

        <%-- NERVES -----------------------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran("leprosy","nerves",sWebLanguage)%></td>
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
                        <td class="admin"><%=getTran("leprosy","epaissis",sWebLanguage)%></td>

                        <%-- median --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_MEDIAN_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_epaissis")%>
                        </td>

                        <%-- cubital --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r5_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r6_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r7_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r7_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r8_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_CUBITAL_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r8_epaissis")%>
                        </td>

                        <%-- SciatiquePopliteExterne --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r9_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r9_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r10_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r10_epaissis")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r11_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r11_epaissis")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r12_epaissis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_EPAISSIS_SQIATIQUE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r12_epaissis")%>
                        </td>
                    </tr>

                    <%-- row 2 : douloureux --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","douloureux",sWebLanguage)%></td>
                        
                        <%-- median --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_douloureux")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_MEDIAN_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_douloureux")%>
                        </td>

                        <%-- cubital --%>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r5_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r6_douloureux")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r7_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r7_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r8_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_CUBITAL_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r8_douloureux")%>
                        </td>

                        <%-- Sciatique Poplite Externe --%>
                        <td class="admin2" nowrap>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r9_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r9_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r10_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r10_douloureux")%>
                        </td>
                        <td class="admin2" nowrap>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r11_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r11_douloureux")%>
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r12_douloureux" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_NERVES_DOULOUREUX_SQIATIQUE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r12_douloureux")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- MUSCULAR FORCE ---------------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran("leprosy","muscularforce",sWebLanguage)%></td>
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
                        <td class="admin"><%=getTran("leprosy","occlusionocculaire",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_occlusion")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_occlusion")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_occlusion" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_OCCLUSION_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_occlusion")%>
                        </td>
                    </tr>

                    <%-- row 2 : fente en mm --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","fente",sWebLanguage)%></td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_RIGHT")%> type="text" class="text" size="5" id="fenteRight" maxLength="3" onBlur="isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_RIGHT" property="value"/>">
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_LEFT")%> type="text" class="text" size="5" id="fenteLeft" maxLength="3" onBlur="isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_FENTE_LEFT" property="value"/>">
                        </td>
                    </tr>

                    <%-- row 3 : cinquième doigt --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","cinquiemedoigt",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_doigt")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_doigt")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_doigt" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_DOIGT_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_doigt")%>
                        </td>
                    </tr>

                    <%-- row 4 : pouce en haut --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","pouceenhaut",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_pouce")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_pouce")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_pouce" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_POUCE_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_pouce")%>
                        </td>
                    </tr>

                    <%-- row 5 : pied en haut --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","piedenhaut",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r1_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r2_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_RIGHT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r3_pied")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT;value=strong" property="value" outputString="checked"/>><%=getLabel("web","strong",sWebLanguage,"r4_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r5_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="decreased" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT;value=decreased" property="value" outputString="checked"/>><%=getLabel("web","decreased",sWebLanguage,"r5_pied")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r6_pied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT" property="itemId"/>]>.value" value="paralysed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_MUSCULARFORCE_PIED_LEFT;value=paralysed" property="value" outputString="checked"/>><%=getLabel("web","paralysed",sWebLanguage,"r6_pied")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- YEUX -------------------------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran("leprosy","yeux",sWebLanguage)%></td>
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
                        <td class="admin"><%=getTran("leprosy","acuitevisuelle",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r1_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_RIGHT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_RIGHT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r1_acuitevisuelle")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r2_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_RIGHT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_RIGHT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r2_acuitevisuelle")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r3_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_LEFT" property="itemId"/>]>.value" value="yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_LEFT;value=yes" property="value" outputString="checked"/>><%=getLabel("web","yes",sWebLanguage,"r3_acuitevisuelle")%>&nbsp;
                            <input type="radio" onDblClick="uncheckRadio(this);" id="r4_acuitevisuelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_LEFT" property="itemId"/>]>.value" value="no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_YEUX_AQUITEVISUELLE_LEFT;value=no" property="value" outputString="checked"/>><%=getLabel("web","no",sWebLanguage,"r4_acuitevisuelle")%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- COTATION DES INFIRMITES ------------------------------------------------------------%>
        <tr class="gray">
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran("leprosy","cotationdesinfirmites",sWebLanguage)%></td>
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
                        <td class="admin"><%=getTran("leprosy","oeil",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" id="r1_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","oeil_cotation0",sWebLanguage,"r1_cotoeil")%><br>
                            <input type="radio" id="r2_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","oeil_cotation2",sWebLanguage,"r2_cotoeil")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r3_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","oeil_cotation0",sWebLanguage,"r3_cotoeil")%><br>
                            <input type="radio" id="r4_cotoeil" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_OEIL_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","oeil_cotation2",sWebLanguage,"r4_cotoeil")%>
                        </td>
                    </tr>

                    <%-- row 2 : Main --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","main",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" id="r1_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation0",sWebLanguage,"r1_cotmain")%><br>
                            <input type="radio" id="r2_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation1",sWebLanguage,"r2_cotmain")%><br>
                            <input type="radio" id="r3_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","main_cotation2",sWebLanguage,"r3_cotmain")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r4_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation0",sWebLanguage,"r4_cotmain")%><br>
                            <input type="radio" id="r5_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation1",sWebLanguage,"r5_cotmain")%><br>
                            <input type="radio" id="r6_cotmain" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_MAIN_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","main_cotation2",sWebLanguage,"r6_cotmain")%>
                        </td>
                    </tr>

                    <%-- row 3 : Pied --%>
                    <tr>
                        <td class="admin"><%=getTran("leprosy","pied",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="radio" id="r1_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation0",sWebLanguage,"r1_cotpied")%><br>
                            <input type="radio" id="r2_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation1",sWebLanguage,"r2_cotpied")%><br>
                            <input type="radio" id="r3_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_RIGHT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalRight');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalRight');"><%=getLabel("leprosy","pied_cotation2",sWebLanguage,"r3_cotpied")%>
                        </td>
                        <td class="admin2">
                            <input type="radio" id="r4_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT;value=cotation0" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation0",sWebLanguage,"r4_cotpied")%><br>
                            <input type="radio" id="r5_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT;value=cotation1" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation1",sWebLanguage,"r5_cotpied")%><br>
                            <input type="radio" id="r6_cotpied" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT" property="itemId"/>]>.value" value="cotation2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_PIED_LEFT;value=cotation2" property="value" outputString="checked"/> onClick="calculateTotal('cotationTotalLeft');" onDblClick="uncheckRadio(this);calculateTotal('cotationTotalLeft');"><%=getLabel("leprosy","pied_cotation2",sWebLanguage,"r6_cotpied")%>
                        </td>
                    </tr>

                    <%-- row 4 : totals --%>
                    <tr>
                        <td class="admin"><%=getTran("web","total",sWebLanguage)%></td>
                        <td class="admin2">
                            &nbsp;<input type="text" class="text" size="1" style="color:black;" id="cotationTotalRight" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_TOTAL_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_TOTAL_RIGHT" property="value"/>" READONLY>
                        </td>
                        <td class="admin2">
                            &nbsp;<input type="text" class="text" size="1" style="color:black;" id="cotationTotalLeft" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_TOTAL_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COTATION_TOTAL_LEFT" property="value"/>" READONLY>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("Web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" id="comment" class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LEPROSYBEGIN_COMMENT" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.leprosybegin",sWebLanguage)%>
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
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>