<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.Item" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<%
    TransactionVO tran = (TransactionVO) transaction;
    String sITEM_TYPE_OBREPORT_LMP = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LMP"),
            sITEM_TYPE_OBREPORT_EDD = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_EDD"),
            sITEM_TYPE_OBREPORT_GA = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_GA"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2"),
            sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3"),
            sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1"),
            sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2"),
            sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2"),
            sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2"),
            sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2"),
            sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2"),
            sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3 = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3"),
            sITEM_TYPE_OBREPORT_CALC_FL_BPD = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_CALC_FL_BPD"),
            sITEM_TYPE_OBREPORT_CALC_HC_AC = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_CALC_HC_AC"),
            sITEM_TYPE_OBREPORT_CALC_FL_HC = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_CALC_FL_HC"),
            sITEM_TYPE_OBREPORT_CALC_FL_AC = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_CALC_FL_AC"),
            sITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD = getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD");
%><%----------------------------------------   TAB 2  ----------------------------------------------------------%>

            <table cellspacing="1" cellpadding="0" width="100%" border="0" id="fetalDescription" class="list">
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk", "obreport.lmp", sWebLanguage)%>
                    </td>
                    <td class="admin2" width="<%=sTDAdminWidth%>">
                        <input id="ac_ITEM_TYPE_OBREPORT_LMP" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LMP")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LMP" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LMP%>">
                        <div id="ITEM_TYPE_OBREPORT_LMP_update" style="display:none;border:1px solid black;background-color:white;"></div>
                    </td>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk", "obreport.edd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_EDD" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_EDD")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_EDD" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_EDD%>">
                        <div id="ITEM_TYPE_OBREPORT_EDD_update" style="display:none;border:1px solid black;background-color:white;"></div>
                    </td>
                </tr>
                <tr>
                    <td class="admin" ><%=getTran("openclinic.chuk", "obreport.ga", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_GA" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_GA")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_GA" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_GA%>">
                        <div id="ITEM_TYPE_OBREPORT_GA_update" style="display:none;border:1px solid black;background-color:white;"></div>
                    </td>
                    <td class="admin" colspan="1"/>
                    <td class="admin2" colspan="1"/>
                </tr>
                <%--                            FETAL BIOMETRY dates                          --%>
                <tr class="admin">
                    <td>
                    </td>
                    <td>
                        <%=getTran("web.occup", "be.mxs.common.model.vo.healthrecord.iconstants.item_type_date", sWebLanguage)%> 1
                    </td>
                    <td>
                        <%=getTran("web.occup", "be.mxs.common.model.vo.healthrecord.iconstants.item_type_date", sWebLanguage)%> 2
                    </td>
                    <td>
                        <%=getTran("web.occup", "be.mxs.common.model.vo.healthrecord.iconstants.item_type_date", sWebLanguage)%> 3
                    </td>
                </tr>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup", "be.mxs.common.model.vo.healthrecord.iconstants.item_type_date", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1%>">
                        <script>writeMyDate("ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE1", "<c:url value="/_img/icons/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2%>">
                        <script>writeMyDate("ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE2", "<c:url value="/_img/icons/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3%>">
                        <script>writeMyDate("ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_DATE3", "<c:url value="/_img/icons/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                    </td>
                </tr>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.fetal.biometry", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY BPD                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.bpd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_BPD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY HC                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.hc", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_HC3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY AC                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.ac", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_AC3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY CRL                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.crl", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_CRL3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY FL                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.fl", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_FL3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY APTD                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.aptd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_APTD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                            FETAL BIOMETRY TAD                          --%>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.tad", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_BIOMETRY_TAD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                               UMBILICAL ARTERY                          --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.umbilical.artery", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.umbilical.artery.ri", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_UMBILICAL_ARTERY_RI3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                               LEFT UTERINE ARTERY                          --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.left.uterine.artery", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.left.uterine.artery.ri", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_RI3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.left.uterine.artery.sd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_UTERINE_ARTERY_SD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                               RIGHT UTERINE ARTERY                          --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.right.uterine.artery", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.right.uterine.artery.ri", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_RI3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.right.uterine.artery.sd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_UTERINE_ARTERY_SD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                               RIGHT FETAL CAROTIS                          --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.right.fetal.carotis", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.right.fetal.carotis.ri", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_RI3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.right.fetal.carotis.sd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_FETAL_CAROTIS_SD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                                           DUCTUS VENOSUS                             --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.ductus.venosus", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.ductus.venosus.ri", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_RI3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.ductus.venosus.sd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD1%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD2%>" onblur="isNumber(this);">
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_DUCTUS_VENOSUS_SD3%>" onblur="isNumber(this);">
                    </td>
                </tr>
                <%--                                            CALC                               --%>
                <tr class="admin">
                    <td colspan="4"><%=getTran("openclinic.chuk", "obreport.calc", sWebLanguage).toUpperCase()%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.calc.fl.bpd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_CALC_FL_BPD" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CALC_FL_BPD")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CALC_FL_BPD" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CALC_FL_BPD%>" onblur="isNumber(this);"> %
                    </td>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.calc.hc.ac", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_CALC_HC_AC" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CALC_HC_AC")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CALC_HC_AC" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CALC_HC_AC%>" onblur="isNumber(this);"> %
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.calc.fl.hc", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_CALC_FL_HC" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CALC_FL_HC")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CALC_FL_HC" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CALC_FL_HC%>" onblur="isNumber(this);"> %
                    </td>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.calc.fl.ac", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_CALC_FL_AC" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CALC_FL_AC")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CALC_FL_AC" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CALC_FL_AC%>" onblur="isNumber(this);"> %
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk", "obreport.calc.ci.bpd.ofd", sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input id="ac_ITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CALC_CI_BPD_OFD%>" onblur="isNumber(this);"> %
                    </td>
                     <td class="admin" colspan="1"/>
                    <td class="admin2" colspan="1"/>
                </tr>
            </table>