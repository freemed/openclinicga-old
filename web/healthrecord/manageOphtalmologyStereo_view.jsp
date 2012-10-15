<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="subClass" value="STEREO"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" name="trandate">

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.stereoscopie",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("web.occup","medwan.common.not-executed",sWebLanguage,"mos_c1")%>&nbsp;<input name="visus-ras" type="checkbox" id="mos_c1" value="medwan.common.true" onclick="if(this.checked == true){hide('visus-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS" property="itemId"/>'); } else{show('visus-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top"><img class="link" src='<c:url value="/_img/top.jpg"/>'></a></td>
    </tr>

    <tr id="visus-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr>
                    <td class="admin" width="15%">
                        TEST
                    </td>
                    <td class="admin" width="5%">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%>
                    </td>
                    <td class="admin"colspan="2"></td>
                </tr>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.stereoscopie",sWebLanguage)%>
                    </td>
                    <td class="admin">6</td>
                    <td class="admin2" colspan="2">
                        <table>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                               <%=getTran("web.occup","medwan.healthrecord.ophtalmology.plus-pres",sWebLanguage)%>
                                            </td>
                                            <td>
                                                <img class="link" src='<c:url value="/_img/top.jpg"/>'>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%=getTran("web.occup","medwan.healthrecord.ophtalmology.plus-loin",sWebLanguage)%>
                                            </td>
                                            <td>
                                                <img class="link" src='<c:url value="/_img/bottom.jpg"/>'>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>
                                    <table class="list" cellspacing="1">
                                        <tr>
                                            <td id="line-1.col-1">&nbsp;1&nbsp;<input id="r11" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('1','1')"></td>
                                            <td id="line-1.col-2">&nbsp;2&nbsp;<input id="r12" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('1','2')"></td>
                                            <td id="line-1.col-3">&nbsp;3&nbsp;<input id="r13" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('1','3')"></td>
                                            <td id="line-1.col-4">&nbsp;4&nbsp;<input id="r14" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('1','4')"></td>
                                            <td id="line-1.col-5">&nbsp;5&nbsp;<input id="r15" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('1','5')"></td>
                                        </tr>
                                        <tr>
                                            <td id="line-2.col-1">&nbsp;1&nbsp;<input id="r21" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('2','1')"></td>
                                            <td id="line-2.col-2">&nbsp;2&nbsp;<input id="r22" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('2','2')"></td>
                                            <td id="line-2.col-3">&nbsp;3&nbsp;<input id="r23" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('2','3')"></td>
                                            <td id="line-2.col-4">&nbsp;4&nbsp;<input id="r24" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('2','4')"></td>
                                            <td id="line-2.col-5">&nbsp;5&nbsp;<input id="r25" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('2','5')"></td>
                                        </tr>
                                        <tr>
                                            <td id="line-3.col-1">&nbsp;1&nbsp;<input id="r31" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('3','1')"></td>
                                            <td id="line-3.col-2">&nbsp;2&nbsp;<input id="r32" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('3','2')"></td>
                                            <td id="line-3.col-3">&nbsp;3&nbsp;<input id="r33" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('3','3')"></td>
                                            <td id="line-3.col-4">&nbsp;4&nbsp;<input id="r34" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('3','4')"></td>
                                            <td id="line-3.col-5">&nbsp;5&nbsp;<input id="r35" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('3','5')"></td>
                                        </tr>
                                        <tr>
                                            <td id="line-4.col-1">&nbsp;1&nbsp;<input id="r41" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('4','1')"></td>
                                            <td id="line-4.col-2">&nbsp;2&nbsp;<input id="r42" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('4','2')"></td>
                                            <td id="line-4.col-3">&nbsp;3&nbsp;<input id="r43" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('4','3')"></td>
                                            <td id="line-4.col-4">&nbsp;4&nbsp;<input id="r44" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('4','4')"></td>
                                            <td id="line-4.col-5">&nbsp;5&nbsp;<input id="r45" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('4','5')"> </td>
                                        </tr>
                                        <tr>
                                            <td id="line-5.col-1">&nbsp;1&nbsp;<input id="r51" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('5','1')"></td>
                                            <td id="line-5.col-2">&nbsp;2&nbsp;<input id="r52" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('5','2')"></td>
                                            <td id="line-5.col-3">&nbsp;3&nbsp;<input id="r53" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('5','3')"></td>
                                            <td id="line-5.col-4">&nbsp;4&nbsp;<input id="r54" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('5','4')"></td>
                                            <td id="line-5.col-5">&nbsp;5&nbsp;<input id="r55" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('5','5')"></td>
                                        </tr>
                                    </table>
                                </td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>
                                    <table>
                                        <tr>
                                            <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL")%> id="stereoNormal" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL;value=medwan.healthrecord.ophtalmology.Normal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Normal"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage,"stereoNormal")%>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL")%> id="stereoAbnormal" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL;value=medwan.healthrecord.ophtalmology.Abnormal" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.Abnormal"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage,"stereoAbnormal")%>&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr>
                    <td class='admin'><%=getTran("web.occup","medwan.healthrecord.ophtalmology.correction",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td colspan="2" class='admin2'>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION")%> type="radio" onDblClick="uncheckRadio(this);" id="mos_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.avec-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage,"mos_r1")%>
                        <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION")%> type="radio" onDblClick="uncheckRadio(this);" id="mos_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.sans-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage,"mos_r2")%>
                    </td>
                </tr>

                <tr>
                    <td class='admin'><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td colspan="2" class='admin2'>
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<p align="right">
    <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="doSubmit();">
    <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","Back",sWebLanguage)%>" onclick="doBack();">
    <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
</p>

<script>
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>"+
                             "?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>"+
                             "&be.mxs.healthrecord.transaction_id=currentTransaction"+
                             "&ts=<%=getTs()%>";
    }
  }

  <%-- VERIFY STEREO --%>
  function verifyStereo(){
    if((document.all["r15"].checked==true) && (document.all["r23"].checked==true) && (document.all["r32"].checked==true) &&
        (document.all["r44"].checked==true) && (document.all["r51"].checked==true)){
      document.all['stereoNormal'].checked=true;
    }
    else{
      document.all['stereoAbnormal'].checked=true;
    }
  }

  <%-- TOGGLE COLOR --%>
  function toggleColor(row, col){
    if(document.all['line-' + row + '.col-'+col].className!="admin2"){
        document.all['r'+row+col].checked = false;
        document.all['line-' + row + '.col-'+col].className="admin2";
    }
    else{
        document.all['line-' + row + '.col-1'].className="admin2";
        document.all['line-' + row + '.col-2'].className="admin2";
        document.all['line-' + row + '.col-3'].className="admin2";
        document.all['line-' + row + '.col-4'].className="admin2";
        document.all['line-' + row + '.col-5'].className="admin2";

        element_activated = 'line-' + row + '.col-' + col;
    //    document.all[element_activated].className="menuItemGreen";
        if(((row=='1')&&(col=='5'))
        ||((row=='2')&&(col=='3'))
        ||((row=='3')&&(col=='2'))
        ||((row=='4')&&(col=='4'))
        ||((row=='5')&&(col=='1'))
        ){
            document.all['line-'+row+'.col-'+col].className='menuItemGreen';
        }
        else{
            document.all['line-'+row+'.col-'+col].className='menuItemRed';
        }
    }
    verifyStereo();
  }

  function setTrue(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.false";
  }

  for(var i=1; i<6; i++){
    document.all['line-'+i+'.col-1'].className="admin2";
    document.all['line-'+i+'.col-2'].className="admin2";
    document.all['line-'+i+'.col-3'].className="admin2";
    document.all['line-'+i+'.col-4'].className="admin2";
    document.all['line-'+i+'.col-5'].className="admin2";

         if(document.all["r"+i+"1"].checked == true){ toggleColor(i,'1'); }
    else if(document.all["r"+i+"2"].checked == true){ toggleColor(i,'2'); }
    else if(document.all["r"+i+"3"].checked == true){ toggleColor(i,'3'); }
    else if(document.all["r"+i+"4"].checked == true){ toggleColor(i,'4'); }
    else if(document.all["r"+i+"5"].checked == true){ toggleColor(i,'5'); }
  }

  <%-- DO SUBMIT --%>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    transactionForm.submit();
  }

  document.all["visus-ras"].onclick();
</script>
</form>

<%=writeJSButtons("transactionForm", "document.all['saveButton']")%>