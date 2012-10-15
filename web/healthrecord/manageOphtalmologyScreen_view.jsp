<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <input type="hidden" name="subClass" value="SCREEN"/>
    <input type="hidden" name="trandate">

<script>
  function setTrue(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.false";
  }
</script>

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("web.occup","medwan.common.not-executed",sWebLanguage,"mos_c1")%>&nbsp;<input name="visus-ras" type="checkbox" id="mos_c1" value="medwan.common.true" onclick="setScreenRAS(this);">
        </td>
        <td align="right" width ="1%"><a href="#top"><img class="link" src='<c:url value="/_img/top.jpg"/>'></a></td>
    </tr>

    <tr id="visus-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr>
                    <td class="admin" width="15%">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.tests",sWebLanguage)%>
                    </td>
                    <td class="admin" width="10%">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%>
                    </td>
                    <td width="40%" class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>
                    </td>
                    <td width="*" class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>
                    </td>
                </tr>

                <%-- Visus ver-zien --------------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-vision-VL",sWebLanguage)%>
                    </td>
                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>=20<br><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>=21</td>
                    <td width="40%" class="admin2">
                        <table>
                            <tr>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_8;value=8" property="value" outputString="checked"/> value="8"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_10;value=10" property="value" outputString="checked"/> value="10"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_12;value=12" property="value" outputString="checked"/> value="12"></td>
                            </tr>
                            <tr>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                    <td width="*" class="admin2">
                        <table>
                            <tr>
                              <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_8;value=8" property="value" outputString="checked"/> value="8"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_10;value=10" property="value" outputString="checked"/> value="10"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_12;value=12" property="value" outputString="checked"/> value="12"></td>
                            </tr>
                            <tr>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Hypermetropie ---------------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-bonnette",sWebLanguage)%>
                    </td>
                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>=22-1<br><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>=22-2</td>
                    <td class="admin2">
                        <table>
                            <tr>
                                <td width="45%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c2")%></td>
                                <td width="10%">&nbsp;</td>
                                <td width="45%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.less-good",sWebLanguage,"moscr_c3")%></td>
                            </tr>
                            <tr>
                                <td align="center"><input type="checkbox" id="moscr_c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal"></td>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_LESS_GOOD" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_LESS_GOOD;value=medwan.healthrecord.ophtalmology.less-good" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.less-good"></td>
                            </tr>
                        </table>
                    </td>
                    <td class="admin2">
                        <table>
                            <tr>
                                <td align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c4")%></td>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.less-good",sWebLanguage,"moscr_c5")%></td>
                            </tr>
                            <tr>
                                <td align="center"><input type="checkbox" id="moscr_c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal"></td>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_LESS_GOOD" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_LESS_GOOD;value=medwan.healthrecord.ophtalmology.less-good" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.less-good"></td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Rood/Groen test -------------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-RED-GREEN",sWebLanguage)%>
                    </td>

                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>=23-1<br><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>=23-2</td>

                    <td class="admin2">
                        <table>
                            <tr>
                                <td width="33%">&nbsp;</td>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c6")%></td>
                                <td width="33%">&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal"></td>
                                <td width="10%">&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.red",sWebLanguage,"moscr_c7")%></td>
                                <td width="33%">&nbsp;</td>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.green",sWebLanguage,"moscr_c8")%></td>
                            </tr>
                            <tr>
                                <td align="center"><input type="checkbox" id="moscr_c7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_RED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_RED;value=medwan.healthrecord.ophtalmology.red" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.red"></td>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_GREEN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_GREEN;value=medwan.healthrecord.ophtalmology.green" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.green"></td>
                            </tr>
                        </table>
                    </td>

                    <td class="admin2">
                        <table>
                            <tr>
                                <td width="33%">&nbsp;</td>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c9")%></td>
                                <td width="33%">&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal"></td>
                                <td width="10%">&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.red",sWebLanguage,"moscr_c10")%></td>
                                <td width="33%">&nbsp;</td>
                                <td width="33%" align="center"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.green",sWebLanguage,"moscr_c11")%></td>
                            </tr>
                            <tr>
                                <td align="center"><input type="checkbox" id="moscr_c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_RED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_RED;value=medwan.healthrecord.ophtalmology.red" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.red"></td>
                                <td width="10%">&nbsp;</td>
                                <td align="center"><input type="checkbox" id="moscr_c11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_GREEN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_GREEN;value=medwan.healthrecord.ophtalmology.green" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.green"></td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Astigmatisme ----------------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-astigmatisme",sWebLanguage)%>
                    </td>

                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%>=24-1<br><%=getTran("web.occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%>=24-2</td>

                    <td class="admin2">
                        <table background='<c:url value="/_img/lines.gif"/>'>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center">3<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                <td>&nbsp;</td>
                                <td align="center">4<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_5;value=5" property="value" outputString="checked"/> value="5">5</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center">2<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <%--<td align="center">3<input type="checkbox"></td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td align="center"><input type="checkbox">5</td>--%>
                                <td rowspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_6;value=6" property="value" outputString="checked"/> value="6">6</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <%--<td align="center">2<input type="checkbox"></td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td align="center"><input type="checkbox">6</td>--%>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center">1<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                <%--<td>&nbsp;</td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td>&nbsp;</td>--%>
                                <td colspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_7;value=7" property="value" outputString="checked"/> value="7">7</td>
                            </tr>
                            <tr>
                                <td colspan="3" align="right"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c12")%></td>
                                <td colspan="3" align="center">
                                    <input type="checkbox" id="moscr_c12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal">&nbsp;
                                    <input type="checkbox" id="moscr_c13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_BLACK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_BLACK;value=medwan.healthrecord.ophtalmology.workers-on-screen-more-black" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.workers-on-screen-more-black">
                                </td>
                                <td colspan="3" align="left"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-more-black",sWebLanguage,"moscr_c13")%></td>
                            </tr>
                        </table>
                    </td>

                    <td class="admin2">
                        <table background='<c:url value="/_img/lines.gif"/>'>
                           <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center">3<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                <td>&nbsp;</td>
                                <td align="center">4<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_5;value=5" property="value" outputString="checked"/> value="5">5</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td rowspan="2" align="center">2<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <%--<td align="center">3<input type="checkbox"></td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td align="center"><input type="checkbox">5</td>--%>
                                <td rowspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_6;value=6" property="value" outputString="checked"/> value="6">6</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <%--<td align="center">2<input type="checkbox"></td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td align="center"><input type="checkbox">6</td>--%>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center">1<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                <%--<td>&nbsp;</td>--%>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <%--<td>&nbsp;</td>--%>
                                <td colspan="2" align="center"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_7;value=7" property="value" outputString="checked"/> value="7">7</td>
                            </tr>
                            <tr>
                                <td colspan="3" align="right"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.equal",sWebLanguage,"moscr_c14")%></td>
                                <td colspan="3" align="center">
                                    <input type="checkbox" id="moscr_c14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_EQUAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_EQUAL;value=medwan.healthrecord.ophtalmology.equal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.equal">&nbsp;
                                    <input type="checkbox" id="moscr_c15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_BLACK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_BLACK;value=medwan.healthrecord.ophtalmology.workers-on-screen-more-black" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.workers-on-screen-more-black">
                                </td>
                                <td colspan="3" align="left"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-more-black",sWebLanguage,"moscr_c15")%></td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Visus bionoculair nabij -----------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VP",sWebLanguage)%>
                    </td>

                    <td class="admin">26</td>

                    <td colspan="2" class="admin2">
                        <table>
                            <tr>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_8;value=8" property="value" outputString="checked"/> value="8"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_10;value=10" property="value" outputString="checked"/> value="10"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_12;value=12" property="value" outputString="checked"/> value="12"></td>
                            </tr>
                            <tr>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Visus tussenafstand bionoculair ---------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VI",sWebLanguage)%>
                    </td>
                    <td class="admin">1</td>
                    <td class="admin2" colspan="2">
                        <table>
                            <tr>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_8;value=8" property="value" outputString="checked"/> value="8"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_10;value=10" property="value" outputString="checked"/> value="10"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_12;value=12" property="value" outputString="checked"/> value="12"></td>
                            </tr>
                            <tr>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Visus ver-zien bionoculair --------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VL",sWebLanguage)%>
                    </td>
                    <td class="admin">2</td>
                    <td class="admin2" colspan="2">
                        <table>
                            <tr>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_8;value=8" property="value" outputString="checked"/> value="8"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_10;value=10" property="value" outputString="checked"/> value="10"></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_12;value=12" property="value" outputString="checked"/> value="12"></td>
                            </tr>
                            <tr>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Vermoeidheid ----------------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.fatigue",sWebLanguage)%>
                    </td>
                    <td class="admin">3</td>
                    <td class="admin2" colspan="2">
                        <table>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td align="center"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.time-span",sWebLanguage)%></td>
                                        </tr>
                                        <tr>
                                            <td><input type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN" property="value"/>" class="text" size="8" maxLength="255"></td>
                                        </tr>
                                    </table>
                                </td>

                                <td width="1%">
                                    &nbsp;
                                </td>

                                <td>
                                    <table>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>1</td>
                                            <td>&nbsp;</td>
                                            <td>3</td>
                                            <td>&nbsp;</td>
                                            <td>5</td>
                                            <td>&nbsp;</td>
                                            <td>2</td>
                                            <td>&nbsp;</td>
                                            <td>4</td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.far",sWebLanguage)%></td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5;value=5" property="value" outputString="checked"/> value="5"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                            <td>&nbsp;</td>
                                        </tr>

                                        <tr>
                                            <td>&nbsp;</td>
                                            <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.close",sWebLanguage)%></td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                            <td>&nbsp;</td>
                                            <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5;value=5" property="value" outputString="checked"/> value="5"></td>
                                        </tr>

                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>&nbsp;</td>
                                            <td>2</td>
                                            <td>&nbsp;</td>
                                            <td>4</td>
                                            <td>&nbsp;</td>
                                            <td>1</td>
                                            <td>&nbsp;</td>
                                            <td>3</td>
                                            <td>&nbsp;</td>
                                            <td>5</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- Wisselend contrast ----------------------------------------------------------%>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen-vision-contrast",sWebLanguage)%>
                    </td>
                    <td class="admin">10</td>
                    <td class="admin2" colspan="2">
                        <table>
                            <tr>
                                <td>&nbsp;</td>
                                <td>0,6</td>
                                <td>&nbsp;<td>
                                <td>0,4</td>
                                <td>&nbsp;<td>
                                <td>0,2</td>
                            </tr>

                            <tr>
                                <td>4</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06;value=406" property="value" outputString="checked"/> value="406"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04;value=404" property="value" outputString="checked"/> value="404"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02;value=402" property="value" outputString="checked"/> value="402"></td>
                            </tr>

                            <tr>
                                <td>6</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06;value=606" property="value" outputString="checked"/> value="606"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04;value=604" property="value" outputString="checked"/> value="604"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02;value=602" property="value" outputString="checked"/> value="602"></td>
                            </tr>

                            <tr>
                                <td>8</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06;value=806" property="value" outputString="checked"/> value="806"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04;value=804" property="value" outputString="checked"/> value="804"></td>
                                <td>&nbsp;<td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02;value=802" property="value" outputString="checked"/> value="802"></td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr>
                    <td class='admin'><%=getTran("web.occup","medwan.healthrecord.ophtalmology.correction",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class='admin2' colspan="2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="moscr_r1" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.avec-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage,"moscr_r1")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="moscr_r2" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.sans-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage,"moscr_r2")%>
                    </td>
                </tr>

                <tr>
                    <td class='admin'><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class='admin2' colspan="2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_REMARK")%> cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_REMARK" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<p align="right">
    <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="doSubmit();">
    <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","Back",sWebLanguage)%>" onClick="doBack();">
    <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
</p>

<script>
  document.all["visus-ras"].onclick();

  <%-- SET SCREEN RAS --%>
  function setScreenRAS(rasCB){
    if(rasCB.checked){
      hide("visus-details");
      setTrue("<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS" property="itemId"/>");
    }
    else{
        show('visus-details');
        setFalse("<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS" property="itemId"/>");
    }
  }

  <%-- SUBMIT --%>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    transactionForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>";
    }
  }
</script>

</form>
<%=writeJSButtons("transactionForm","document.all['saveButton']")%>