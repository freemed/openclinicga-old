<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=checkPermission("occup.delivery", "select", activeUser)%><%=sJSDIAGRAM%>
<%!
    private String convertTimeToNbForGraph(String s) {
        if (s.equals("15")) {
            s = "25";
        } else if (s.equals("30")) {
            s = "50";
        } else if (s.equals("45")) {
            s = "75";
        }

        return s;
    }
    private StringBuffer addDilatation(int iTotal, String sHour, String sMinutes, String sOpening, String sWebLanguage) {
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                "<tr id='rowDilatation" + iTotal + "'>" +
                        "<td class='admin2'>" +
                        " <a href='javascript:deleteDilatation(rowDilatation" + iTotal + "," + sHour + convertTimeToNbForGraph(sMinutes) + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> " +
                        "</td>" +
                        "<td class='admin2'>&nbsp;" + sHour + ":" + sMinutes + "</td>" +
                        "<td class='admin2'>&nbsp;" + sOpening + "</td>" +
                        "<td class='admin2'><script>setNewDilatation(" + sHour + convertTimeToNbForGraph(sMinutes) + "," + sOpening + ");</script></td>" +
                        "</tr>"
        );
        return sTmp;
    }
    private StringBuffer addEngagement(int iTotal, String sHour, String sMinutes, String sGrade, String sWebLanguage) {
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                "<tr id='rowEngagement" + iTotal + "'>" +
                        "<td class='admin2'>" +
                        " <a href='javascript:deleteEngagement(rowEngagement" + iTotal + "," + sHour + convertTimeToNbForGraph(sMinutes) + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> " +
                        "</td>" +
                        "<td class='admin2'>&nbsp;" + sHour + ":" + sMinutes + "</td>" +
                        "<td class='admin2'>&nbsp;" + sGrade + "</td>" +
                        "<td class='admin2'><script>setNewEngagement(" + sHour + convertTimeToNbForGraph(sMinutes) + "," + sGrade + ");</script></td>" +
                        "</tr>"
        );
        return sTmp;
    }
    private StringBuffer addAction(int iTotal, String sHour, String sMinutes, String sLetter, String sWebLanguage) {
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                "<tr id='rowAction" + iTotal + "'>" +
                        "<td class='admin2'>" +
                        " <a href='javascript:deleteAction(rowAction" + iTotal + ",\"" + sHour + sMinutes + sLetter + "\")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> " +
                        "</td>" +
                        "<td class='admin2'>&nbsp;" + sHour + ":" + sMinutes + "</td>" +
                        "<td class='admin2'>&nbsp;" + sLetter + "</td>" +
                        "<td class='admin2'><script>graphAction.set('" + sHour + sMinutes + sLetter + "'" + ",'" + sLetter + "');</script></td>" +
                        "</tr>"
        );
        return sTmp;
    }
%>
<%
	try{
%>
	
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO) transaction).getTransactionType(), sWebLanguage)%><%=contextHeader(request, sWebLanguage)%>
    <%

    StringBuffer sDilatation = new StringBuffer(),
    sDivDilatation = new StringBuffer();
    int iDilatationTotal = 1;
    TransactionVO tran = (TransactionVO) transaction;
    sDilatation.append(getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_DELIVERY_WORK_DILATATION"));
    if (sDilatation.indexOf("£") > -1) {
        StringBuffer sTmpDilatation = sDilatation;
        String sTmpHour, sTmpOpening, sTmpMinutes;
        sDilatation = new StringBuffer();

        while (sTmpDilatation.toString().toLowerCase().indexOf("$") > -1) {
            sTmpHour = "";
            sTmpOpening = "";
            sTmpMinutes = "";
            if (sTmpDilatation.toString().toLowerCase().indexOf("£") > -1) {
                sTmpHour = sTmpDilatation.substring(0, sTmpDilatation.toString().toLowerCase().indexOf("£"));
                sTmpDilatation = new StringBuffer(sTmpDilatation.substring(sTmpDilatation.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpDilatation.toString().toLowerCase().indexOf("£") > -1) {
                sTmpMinutes = sTmpDilatation.substring(0, sTmpDilatation.toString().toLowerCase().indexOf("£"));
                sTmpDilatation = new StringBuffer(sTmpDilatation.substring(sTmpDilatation.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpDilatation.toString().toLowerCase().indexOf("$") > -1) {
                sTmpOpening = sTmpDilatation.substring(0, sTmpDilatation.toString().toLowerCase().indexOf("$"));
                sTmpDilatation = new StringBuffer(sTmpDilatation.substring(sTmpDilatation.toString().toLowerCase().indexOf("$") + 1));
            }
            sDilatation.append("rowDilatation" + iDilatationTotal + "=" + sTmpHour + "£" + sTmpMinutes + "£" + sTmpOpening + "$");
            sDivDilatation.append(addDilatation(iDilatationTotal, sTmpHour, sTmpMinutes, sTmpOpening, sWebLanguage));
            iDilatationTotal++;
        }
    }
    StringBuffer sEngagement = new StringBuffer(),
            sDivEngagement = new StringBuffer();
    int iEngagementTotal = 1;
    sEngagement.append(getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_DELIVERY_WORK_ENGAGEMENT"));
    if (sEngagement.indexOf("£") > -1) {
        StringBuffer sTmpEngagement = sEngagement;
        String sTmpHour, sTmpGrade, sTmpMinutes;
        sEngagement = new StringBuffer();
        while (sTmpEngagement.toString().toLowerCase().indexOf("$") > -1) {
            sTmpHour = "";
            sTmpGrade = "";
            sTmpMinutes = "";
            if (sTmpEngagement.toString().toLowerCase().indexOf("£") > -1) {
                sTmpHour = sTmpEngagement.substring(0, sTmpEngagement.toString().toLowerCase().indexOf("£"));
                sTmpEngagement = new StringBuffer(sTmpEngagement.substring(sTmpEngagement.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpEngagement.toString().toLowerCase().indexOf("£") > -1) {
                sTmpMinutes = sTmpEngagement.substring(0, sTmpEngagement.toString().toLowerCase().indexOf("£"));
                sTmpEngagement = new StringBuffer(sTmpEngagement.substring(sTmpEngagement.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpEngagement.toString().toLowerCase().indexOf("$") > -1) {
                sTmpGrade = sTmpEngagement.substring(0, sTmpEngagement.toString().toLowerCase().indexOf("$"));
                sTmpEngagement = new StringBuffer(sTmpEngagement.substring(sTmpEngagement.toString().toLowerCase().indexOf("$") + 1));
            }
            sEngagement.append("rowEngagement" + iEngagementTotal + "=" + sTmpHour + "£" + sTmpMinutes + "£" + sTmpGrade + "$");
            sDivEngagement.append(addEngagement(iEngagementTotal, sTmpHour, sTmpMinutes, sTmpGrade, sWebLanguage));
            iEngagementTotal++;
        }
    }
    StringBuffer sAction = new StringBuffer(),
            sDivAction = new StringBuffer();
    int iActionTotal = 1;
    sAction.append(getItemType(tran.getItems(), sPREFIX + "ITEM_TYPE_DELIVERY_WORK_ACTION"));
    if (sAction.indexOf("£") > -1) {
        StringBuffer sTmpAction = sAction;
        String sTmpHour, sTmpLetter, sTmpMinutes;
        sAction = new StringBuffer();
        while (sTmpAction.toString().toLowerCase().indexOf("$") > -1) {
            sTmpHour = "";
            sTmpLetter = "";
            sTmpMinutes = "";
            if (sTmpAction.toString().toLowerCase().indexOf("£") > -1) {
                sTmpHour = sTmpAction.substring(0, sTmpAction.toString().toLowerCase().indexOf("£"));
                sTmpAction = new StringBuffer(sTmpAction.substring(sTmpAction.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpAction.toString().toLowerCase().indexOf("£") > -1) {
                sTmpMinutes = sTmpAction.substring(0, sTmpAction.toString().toLowerCase().indexOf("£"));
                sTmpAction = new StringBuffer(sTmpAction.substring(sTmpAction.toString().toLowerCase().indexOf("£") + 1));
            }
            if (sTmpAction.toString().toLowerCase().indexOf("$") > -1) {
                sTmpLetter = sTmpAction.substring(0, sTmpAction.toString().toLowerCase().indexOf("$"));
                sTmpAction = new StringBuffer(sTmpAction.substring(sTmpAction.toString().toLowerCase().indexOf("$") + 1));
            }
            sAction.append("rowAction" + iActionTotal + "=" + sTmpHour + "£" + sTmpMinutes + "£" + sTmpLetter + "$");
            sDivAction.append(addAction(iActionTotal, sTmpHour, sTmpMinutes, sTmpLetter, sWebLanguage));
            iActionTotal++;
        }
    }%>
    <table class="list" width="100%" cellspacing="1">
        <%-- ###################################### WORK ######################################--%> <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;<%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this);calculateGestAge();' onchange='calculateGestAge();' onKeyUp='calculateGestAge()'>
                <script>writeMyDate("trandate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin" rowspan="4"><%=getTran("openclinic.chuk", "delivery.type", sWebLanguage)%></td>
            <td rowspan="4" bgcolor="#EBF3F7">
                <%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_DATE" property="value"/>" id="deliverytypedate" OnBlur='checkDate(this);'>
                <script>writeMyDate("deliverytypedate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <%=getTran("openclinic.chuk", "delivery.hour", sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERYTYPE_HOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_HOUR" property="value"/>" onblur="checkTime(this)" onkeypress="keypressTime(this)">
                <table width="100%" cellspacing="1" bgcolor="white">
                    <%-- EUSTOCIC -----------------------------------------------------%>
                    <tr>
                        <td colspan="2" class="admin2">
                            <input type="checkbox" id="type_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_EUSTOCIC" property="itemId"/>]>.value" value="medwan.common.true"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_EUSTOCIC;value=medwan.common.true"
                                                      property="value"
                                                      outputString="checked"/>><%=getLabel("openclinic.chuk", "openclinic.common.eutocic", sWebLanguage, "type_r1")%>
                        </td>
                    </tr>
                    <%-- DYSTOCIC -----------------------------------------------------%>
                    <tr>
                        <td colspan="2" class="admin2">
                            <input type="checkbox" id="type_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_DYSTOCIC" property="itemId"/>]>.value" value="medwan.common.true"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_DYSTOCIC;value=medwan.common.true"
                                                      property="value"
                                                      outputString="checked"/> onclick="clearType2(this)"><%=getLabel("openclinic.chuk", "openclinic.common.dystocic", sWebLanguage, "type_r2")%>
                        </td>
                    </tr>
                    <tr id="trtype2">
                        <td width="25" class="admin2"/>
                        <td class="admin2">
                            <table width="100%">
                                <tr>
                                    <td colspan="2">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_VENTOUSSE")%> type="checkbox" id="cbventousse" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_VENTOUSSE" property="itemId"/>]>.value"
                                                <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_VENTOUSSE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk", "gynaeco.ventousse", sWebLanguage, "cbventousse")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td/>
                                    <td>
                                        <table>
                                            <tr>
                                                <td><%=getTran("gynaeco", "number_tractions", sWebLanguage)%></td>
                                                <td>
                                                    <input <%=setRightClick("ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS")%> id="ttractions" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_TRACTIONS" property="value"/>" onblur="isNumber(this)">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td><%=getTran("gynaeco", "number_lachage", sWebLanguage)%></td>
                                                <td>
                                                    <input <%=setRightClick("ITEM_TYPE_DELIVERY_NUMBER_LACHAGE")%> id="tlachage" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_LACHAGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_NUMBER_LACHAGE" property="value"/>" onblur="isNumber(this)">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_FORCEPS")%> type="checkbox" id="cbforceps" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_FORCEPS" property="itemId"/>]>.value"
                                                <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_FORCEPS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco", "forceps", sWebLanguage, "cbforceps")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_MANOEUVRE")%> type="checkbox" id="cbmanoeuvre" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_MANOEUVRE" property="itemId"/>]>.value"
                                                <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_MANOEUVRE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco", "manoeuvre", sWebLanguage, "cbmanoeuvre")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td><%=getTran("gynaeco", "cause", sWebLanguage)%></td>
                                    <td>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.maternel"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.maternel"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "maternel", sWebLanguage, "causedystocic_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.fetal"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.fetal"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "fetal", sWebLanguage, "causedystocic_r2")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causedystocic_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.mixte"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DYSTOCIC_CAUSE;value=gynaeco.cause.mixte"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "mixte", sWebLanguage, "causedystocic_r3")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="100"><%=getTran("Web.Occup", "medwan.common.remark", sWebLanguage)%></td>
                                    <td>
                                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK")%> id="tdystoticremark" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_DYSTOCIC_REMARK" property="value"/></textarea>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <%-- CAESERIAN ------------------------------------------%>
                    <tr>
                        <td colspan="2" class="admin2">
                            <input type="checkbox" id="type_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_CAESERIAN" property="itemId"/>]>.value" value="medwan.common.true"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYTYPE_CAESERIAN;value=medwan.common.true"
                                                      property="value"
                                                      outputString="checked"/> onclick="clearType3(this)"><%=getLabel("openclinic.chuk", "openclinic.common.caeserian", sWebLanguage, "type_r3")%>
                        </td>
                    </tr>
                    <tr id="trtype3">
                        <td class="admin2"/>
                        <td class="admin2">
                            <table width="100%" cellspacing="0">
                                <tr>
                                    <td colspan="2">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN")%> type="radio" onDblClick="uncheckRadio(this);" id="caeserian_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN" property="itemId"/>]>.value" value="gynaeco.caeserian.before"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN;value=gynaeco.caeserian.before"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.caeserian", "before", sWebLanguage, "caeserian_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN")%> type="radio" onDblClick="uncheckRadio(this);" id="caeserian_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN" property="itemId"/>]>.value" value="gynaeco.caeserian.during"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN;value=gynaeco.caeserian.during"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.caeserian", "during", sWebLanguage, "caeserian_r2")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td><%=getTran("gynaeco", "cause", sWebLanguage)%></td>
                                    <td>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.maternel"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.maternel"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "maternel", sWebLanguage, "causecaeserian_r1")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.fetal"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.fetal"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "fetal", sWebLanguage, "causecaeserian_r2")%>
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE")%> type="radio" onDblClick="uncheckRadio(this);" id="causecaeserian_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE" property="itemId"/>]>.value" value="gynaeco.cause.mixte"
                                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CAESERIAN_CAUSE;value=gynaeco.cause.mixte"
                                                                  property="value"
                                                                  outputString="checked"/>><%=getLabel("gynaeco.cause", "mixte", sWebLanguage, "causecaeserian_r3")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="100"><%=getTran("Web.Occup", "medwan.common.remark", sWebLanguage)%></td>
                                    <td>
                                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK")%> id="tcaeserianremark" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_REMARK" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td><%=getTran("gynaeco", "caeserian_indication", sWebLanguage)%></td>
                                    <td>
                                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_INDICATION")%> id="tcaeserianindication" class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_INDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_TYPE_CAESERIAN_INDICATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td/>
                                    <td>
                                        <a href="<c:url value="/healthrecord/loadPDF.jsp"/>?file=<%=MedwanQuery.getInstance().getConfigString("gynae.caeserian.url","")%>" target="_new"><%=getTran("gynaeco", "caeserian_url", sWebLanguage)%></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <%-- adminssion --%>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "admission", sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.urgence"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.urgence"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("gynaeco.admission", "urgence", sWebLanguage, "admission_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.transfer"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.transfer"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("gynaeco.admission", "transfer", sWebLanguage, "admission_r2")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.spontane"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.spontane"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("gynaeco.admission", "spontane", sWebLanguage, "admission_r3")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_ADMISSION")%> type="radio" onDblClick="uncheckRadio(this);" id="admission_r4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION" property="itemId"/>]>.value" value="gynaeco.admission.other"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ADMISSION;value=gynaeco.admission.other"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("gynaeco.admission", "other", sWebLanguage, "admission_r4")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "start.hour", sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="beginHourSelect" onchange="setNewTime()">
                    <option/>
                    <%for (int i = 0; i < 24; i++) {%>
                    <option value="<%=i%>"><%=i%></option>
                <%}%>
                </select> :
                <select class="text" id="beginMinutSelect" onchange="setNewTime()">
                    <option value="00" selected="selected">00</option>
                    <option value="15">15</option>
                    <option value="30">30</option>
                    <option value="45">45</option>
                </select>
                <input id="ITEM_TYPE_DELIVERY_STARTHOUR" type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_STARTHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_STARTHOUR" property="value"/>" onblur="checkTime(this)" onkeypress="keypressTime(this)">
                <script type="text/javascript">
                    var setBeginHourIntSelect = function(){

                        var hours = $("beginHourSelect").options;
                        var min = $("beginMinutSelect").options;
                        var hourToTest = parseInt($("ITEM_TYPE_DELIVERY_STARTHOUR").value.split(":")[0]);

                        var minToTest = parseInt($("ITEM_TYPE_DELIVERY_STARTHOUR").value.split(":")[1]);
                          if(minToTest<8){
                            minToTest = 0;
                          }else if(minToTest<22){
                            minToTest = 15;
                          }else if(minToTest<38){
                            minToTest = 30;
                          }else if(minToTest<52){
                            minToTest = 45;
                          }else{
                            minToTest = 0;
                              hourToTest ++;
                          }
                        for(var i=0;i<hours.length;i++){
                           if(hours[i].value==hourToTest){
                                $("beginHourSelect").selectedIndex = i;
                               break;
                            }
                        }
                        for(var i=0;i<min.length;i++){
                           if(min[i].value==minToTest){
                               $("beginMinutSelect").selectedIndex = i;
                               break;
                            }
                        }
                    }
                    setBeginHourIntSelect();
                </script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "age.gestationnel", sWebLanguage)%></td>
            <td class="admin2" nowrap>
                <table>
                    <tr>
                        <td><%=getTran("gynaeco", "date.dr", sWebLanguage)%></td>
                        <td nowrap>
                            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR" property="value" formatType="date" format="dd-mm-yyyy"/>" id="drdate" onBlur='checkDate(this);calculateGestAge();clearDr()' onChange='calculateGestAge();' onKeyUp='calculateGestAge();'/>
                            <script>writeMyDate("drdate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                            <input id="agedatedr" <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_DATE_DR")%> readonly type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="value"/>" onblur="isNumber(this)"> <%=getTran("web", "weeks.abr", sWebLanguage)%> <%=getTran("web", "delivery.date", sWebLanguage)%>:
                            <input id="drdeldate" <%=setRightClick("ITEM_TYPE_DELIVERY_DATE_DR")%> type="text" class="text" size="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_DR" property="value"/>" onblur="checkDate(this);">
                        </td>
                    </tr>
                    <tr>
                        <td><%=getTran("gynaeco", "date.echography", sWebLanguage)%></td>
                        <td nowrap>
                            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO" property="value" formatType="date" format="dd-mm-yyyy"/>" id="echodate" onBlur='checkDate(this);calculateGestAge();' onchange='calculateGestAge();' onkeyup='calculateGestAge();'/>
                            <script>writeMyDate("echodate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="value"/>" id="agedateecho" onblur='isNumber(this);calculateGestAge();' onchange='calculateGestAge();' onkeyup="calculateGestAge();"> <%=getTran("web", "weeks.abr", sWebLanguage)%> <%=getTran("web", "delivery.date", sWebLanguage)%>:
                            <input id="echodeldate" <%=setRightClick("ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY")%> type="text" class="text" size="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY" property="value"/>" onblur="checkDate(this);">
                        </td>
                    </tr>
                    <tr>
                        <td/>
                        <td>
                            <%=getTran("gynaeco", "actual.age", sWebLanguage)%>
                            <input id="ageactualecho" <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_ACTUEL")%> readonly type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ACTUEL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ACTUEL" property="value"/>" onblur="isNumber(this)"> <%=getTran("web", "weeks.abr", sWebLanguage)%>
                        </td>
                    </tr>
                    <tr>
                        <td><%=getTran("gynaeco", "age.trimstre", sWebLanguage)%>
                        </td>
                        <td nowrap>
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="1"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=1"
                                                      property="value" outputString="checked"/>>1
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="2"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=2"
                                                      property="value" outputString="checked"/>>2
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="3"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=3"
                                                      property="value" outputString="checked"/>>3
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("gynaeco", "admission.gyn", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web", "inspection", sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web", "vulva", sWebLanguage)%><br>
                <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_GYNINSPECTION")%> class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION7" property="value"/></textarea>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION5" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION6" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION7" property="itemId"/>]>.value">
            </td>
            <td class="admin"><%=getTran("web", "speculum", sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web", "vaginal.collar", sWebLanguage)%><br>
                <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR")%> class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR7" property="value"/></textarea>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR5" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR6" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR7" property="itemId"/>]>.value">
                <br><%=getTran("web", "vaginal.mucosa", sWebLanguage)%><br>
                <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA")%> class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA7" property="value"/></textarea>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA5" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA6" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA7" property="itemId"/>]>.value">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web", "vaginal.touche", sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE")%> class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE7" property="value"/></textarea>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE5" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE6" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE7" property="itemId"/>]>.value">
            </td>
            <td class="admin"><%=getTran("web", "amnion.liquid", sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_AMNION_LIQUID")%> class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AMNION_LIQUID" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AMNION_LIQUID" property="value"/></textarea>
            </td>
        </tr>
        <%-- #################################### work travail #################################--%>
        <tr class="admin">
            <td colspan="4"><%=getTran("gynaeco", "work", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web", "graphs", sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <div id="glycemyGraph" style="position:relative; left:50px; top:20px; height:420px" style="display:block;"></div>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("gynae", "dilatation.opening", sWebLanguage)%>
            </td>
            <td class="admin2" valign="top">
                <table cellspacing="1" cellpadding="0" width="100%" id="tblDilatation">
                    <%-- header --%>
                    <tr>
                        <td class="admin" width="40px"/>
                        <td class="admin" width="100px"><%=getTran("web.occup", "medwan.common.hour", sWebLanguage)%>
                        </td>
                        <td class="admin" width="50px"><%=getTran("gynae", "dilatation.opening", sWebLanguage)%>
                        </td>
                        <td class="admin" width="*"/>
                    </tr>
                    <%-- ADD-ROW --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <select class="text" id="dilatationHour" name="dilatationHour">
                                <option/>
                                <%for (int i = 0; i < 24; i++) {%>
                                <option value="<%=i%>"><%=i%>
                                </option>
                                <%}%>
                            </select> : <select class="text" id="dilatationMinutes" name="dilatationMinutes">
                            <option value="00" selected="selected">00</option>
                            <option value="15">15</option>
                            <option value="30">30</option>
                            <option value="45">45</option>
                        </select>
                        </td>
                        <td class="admin2" valign="top">
                            <select class="text" name="dilatationOpening">
                                <option/>
                                <%for (int i = 0; i < 11; i++) {%>
                                <option value="<%=i%>"><%=i%>
                                </option>
                                <%}%>
                            </select>
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddDilatation" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addDilatation();">
                        </td>
                    </tr>
                    <%-- hidden fields --%>
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_DILATATION" property="itemId"/>]>.value">
                    <script>
                        //--------------- declare arrays-----------------//

                        var graphDilatation = new Hash();
                        var graphEngagement = new Hash();
                        var graphAction = new Hash();
                        var graphDilatationObjects = new Array();
                        var graphEngagementObjects = new Array();
                        var graphActionObjects = new Array();
                        var earlierBackupTime;
                        var barTop;
                        function setNewEngagement(key, value) {
                            if (!graphEngagement.get(key))graphEngagement.set(key, value);
                        }
                        function setNewDilatation(key, value) {
                            if (!graphDilatation.get(key))graphDilatation.set(key, value);
                        }
                        function getEarlierTime() {

                           /*  if($("ITEM_TYPE_DELIVERY_STARTHOUR").value.length>0 && $("beginHourSelect").value.length>0){
                               setBeginHourIntSelect();
                            }   */
                            var time = ($("beginHourSelect").value) + convertTimeToNbForGraph($("beginMinutSelect").value);
                            if (earlierBackupTime != time) {
                                earlierBackupTime = time;
                                setTopUnits();
                            }
                            /*  var toTestDate = new Date();
                       //   var compareDate = new Date();
                          toTestDate.setHours(time.substring(0, time.length - 2));
                          toTestDate.setMinutes(time.substring(time.length - 2));
                          earlierTime[0] = toTestDate;
                          earlierTime[1] = time;
                         graphDilatation.each(function(index) {
                              compareDate.setHours(index.key.substring(0, index.key.length - 2));
                              compareDate.setMinutes(index.key.substring(index.key.length - 2));
                              if (compare(earlierTime[0], compareDate) == 1) {
                                   earlierTime[0].setDate(compareDate.getDate());
                                   earlierTime[0].setMinutes(compareDate.getMinutes());
                                  earlierTime[0].setHours(compareDate.getHours());
                                  earlierTime[1] = index.key;
                              }
                          });  */

                            return time;
                        }
                        function compare(date_1, date_2) {
                            //   0 if date_1=date_2
                            //   1 if date_1>date_2
                            //  -1 if date_1<date_2
                            diff = date_1.getTime() - date_2.getTime();
                            return (diff == 0 ? diff : diff / Math.abs(diff));
                        }
                    </script>
                    <%=sDivDilatation%>
                </table>
            </td>
            <td class="admin"><%=getTran("gynaeco", "work.engagement", sWebLanguage)%>
            </td>
            <td class="admin2" valign="top">
                <table cellspacing="1" cellpadding="0" width="100%" id="tblEngagement">
                    <%-- header --%>
                    <tr>
                        <td class="admin" width="40px"/>
                        <td class="admin" width="100px"><%=getTran("web.occup", "medwan.common.hour", sWebLanguage)%>
                        </td>
                        <td class="admin" width="50px"><%=getTran("gynae", "engagement.degree", sWebLanguage)%>
                        </td>
                        <td class="admin" width="*"/>
                    </tr>
                    <%-- ADD-ROW --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <select class="text" id="engagementHour" name="engagementHour">
                                <option/>
                                <%for (int i = 0; i < 24; i++) {%>
                                <option value="<%=i%>"><%=i%>
                                </option>
                                <%}%>
                            </select> : <select class="text" id="engagementMinutes" name="engagementMinutes">
                            <option value="00" selected="selected">00</option>
                            <option value="15">15</option>
                            <option value="30">30</option>
                            <option value="45">45</option>
                        </select>
                        </td>
                        <td class="admin2" valign="top">
                            <select class="text" id="engagementDegree" name="engagementDegree">
                                <option/>
                                <%for (int i = -4; i < 5; i++) {%>
                                <option value="<%=i%>"><%=i%>
                                </option>
                                <%}%>
                            </select>
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddEngagement" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addEngagement();">
                        </td>
                    </tr>
                    <%-- hidden fields --%>
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_ENGAGEMENT" property="itemId"/>]>.value">
                    <%=sDivEngagement%>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynae", "action", sWebLanguage)%>
            </td>
            <td class="admin2">
                <table cellspacing="1" cellpadding="0" width="100%" id="tblAction">
                    <%-- header --%>
                    <tr>
                        <td class="admin" width="40px"/>
                        <td class="admin" width="100px"><%=getTran("web.occup", "medwan.common.hour", sWebLanguage)%>
                        </td>
                        <td class="admin" width="50px"><%=getTran("gynae", "action", sWebLanguage)%>
                        </td>
                        <td class="admin" width="*"/>
                    </tr>
                    <%-- ADD-ROW --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <select class="text" id="actionHour" name="actionHour">
                                <option/>
                                <%for (int i = 0; i < 24; i++) {%>
                                <option value="<%=i%>"><%=i%>
                                </option>
                                <%}%>
                            </select> : <select class="text" id="actionMinutes" name="actionMinutes">
                            <option value="00" selected="selected">00</option>
                            <option value="15">15</option>
                            <option value="30">30</option>
                            <option value="45">45</option>
                        </select>
                        </td>
                        <td class="admin2" valign="top">
                            <select class="text" name="actionLetter">
                                <option/>
                                <%=ScreenHelper.writeSelect("gynae_action", "", sWebLanguage, true, false)%>
                            </select>
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddAction" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addAction();">
                        </td>
                    </tr>
                    <%-- hidden fields --%>
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_ACTION" property="itemId"/>]>.value">
                    <%=sDivAction%>
                </table>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk", "anesthesie", sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_ANESTHESIE")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ANESTHESIE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ANESTHESIE" property="value"/></textarea>
                <br>
                <a href="<c:url value="/healthrecord/loadPDF.jsp"/>?file=<%=MedwanQuery.getInstance().getConfigString("gynae.anesthesie.url","")%>" target="_new"><%=getTran("gynaeco", "anesthesie_url", sWebLanguage)%>
                </a>
            </td>
        </tr>
        <%-- #################################### DELIVERANCE #################################--%>
        <tr class="admin">
            <td colspan="4"><%=getTran("gynaeco", "deliverance", sWebLanguage)%>
            </td>
        </tr>
        <%-- delivery.hour / deliverance.type--%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk", "delivery.hour", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERYHOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERYHOUR" property="value"/>" onblur="checkTime(this)" onkeypress="keypressTime(this)">
            </td>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.assistee"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.assistee"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("openclinic.chuk", "gynaeco.deliverencetype.assistee", sWebLanguage, "deliverentype_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.spontanee"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.spontanee"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("openclinic.chuk", "gynaeco.deliverencetype.spontanee", sWebLanguage, "deliverentype_r2")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deliverentype_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE" property="itemId"/>]>.value" value="gynaeco.deliverencetype.artificielle"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DELIVERENCE_TYPE;value=gynaeco.deliverencetype.artificielle"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("openclinic.chuk", "gynaeco.deliverencetype.artificielle", sWebLanguage, "deliverentype_r2")%>
            </td>
        </tr>
        <%-- placenta / hemorragie --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk", "placenta", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PLACENTA")%> type="radio" onDblClick="uncheckRadio(this);" id="placenta_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA" property="itemId"/>]>.value" value="openclinic.common.complete"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA;value=openclinic.common.complete"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("openclinic.chuk", "openclinic.common.complete", sWebLanguage, "placenta_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PLACENTA")%> type="radio" onDblClick="uncheckRadio(this);" id="placenta_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA" property="itemId"/>]>.value" value="openclinic.common.incomplete"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA;value=openclinic.common.incomplete"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("openclinic.chuk", "openclinic.common.incomplete", sWebLanguage, "placenta_r2")%>
                <br/>
                <%=getTran("gynaeco", "placenta.comment", sWebLanguage)%><br>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_PLACENTA_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PLACENTA_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("gynaeco", "hemorragie", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE")%> type="radio" onDblClick="uncheckRadio(this);" id="hemorragie_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE" property="itemId"/>]>.value" value="medwan.common.yes"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE;value=medwan.common.yes"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.yes", sWebLanguage, "hemorragie_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE")%> type="radio" onDblClick="uncheckRadio(this);" id="hemorragie_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE" property="itemId"/>]>.value" value="medwan.common.no"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE;value=medwan.common.no"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.no", sWebLanguage, "hemorragie_r2")%>
                <br/>
                <%=getTran("gynaeco", "hemorragie.intervention", sWebLanguage)%><br>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_HEMORRAGIE_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>
        <%-- perinee / episiotomie --%>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "perinee", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE")%> type="radio" onDblClick="uncheckRadio(this);" id="perinee_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE" property="itemId"/>]>.value" value="medwan.common.yes"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE;value=medwan.common.yes"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.yes", sWebLanguage, "perinee_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE")%> type="radio" onDblClick="uncheckRadio(this);" id="perinee_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE" property="itemId"/>]>.value" value="medwan.common.no"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE;value=medwan.common.no"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.no", sWebLanguage, "perinee_r2")%>
                <br/>
                <%=getTran("gynaeco", "perinee.degree", sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_PERINEE_DEGREE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE_DEGREE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_PERINEE_DEGREE" property="value"/>" onblur="isNumber(this)">
            </td>
            <td class="admin"><%=getTran("gynaeco", "episiotomie", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_EPISIOTOMIE")%> type="radio" onDblClick="uncheckRadio(this);" id="episiotomie_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE" property="itemId"/>]>.value" value="medwan.common.yes"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE;value=medwan.common.yes"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.yes", sWebLanguage, "episiotomie_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_EPISIOTOMIE")%> type="radio" onDblClick="uncheckRadio(this);" id="episiotomie_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE" property="itemId"/>]>.value" value="medwan.common.no"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_EPISIOTOMIE;value=medwan.common.no"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "medwan.common.no", sWebLanguage, "episiotomie_r2")%>
            </td>
        </tr>
        <%-- observation / intervention --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk", "observation", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_OBSERVATION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk", "intervention", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_LABOUR_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>
        <%-- ####################################### ENFANT ###################################--%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk", "reanimation", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_DATE" property="value"/>" id="reanimationdate" OnBlur='checkDate(this);'>
                <script>writeMyDate("reanimationdate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <%=getTran("openclinic.chuk", "delivery.hour", sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_REANIMATION_HOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_HOUR" property="value"/>" onblur="checkTime(this)" onkeypress="keypressTime(this)">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk", "intubation_usi", sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_INTUBATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_INTUBATION_DATE" property="value"/>" id="reanimationintubationdate" OnBlur='checkDate(this);'>
                <script>writeMyDate("reanimationintubationdate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <%=getTran("openclinic.chuk", "delivery.hour", sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_REANIMATION_INTUBATION_HOUR")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_INTUBATION_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_INTUBATION_HOUR" property="value"/>" onblur="checkTime(this)" onkeypress="keypressTime(this)">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk", "adrenaline", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_REANIMATION_ADRENALINE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_ADRENALINE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_ADRENALINE" property="value"/>" onblur="isNumber(this)">
                <%=getTran("web", "prescriptionrule", sWebLanguage)%>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk", "destination.new.baby", sWebLanguage)%>
            </td>
            <td class="admin2">
                <select <%=setRightClick("ITEM_TYPE_DELIVERY_REANIMATION_DESTINATION")%> id="EditReanimationDestination" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_DESTINATION" property="itemId"/>]>.value" class="text">
                    <option/>
                    <%=ScreenHelper.writeSelect("delivery.reanimation.destination", "", sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%-- ####################################### ENFANT ###################################--%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk", "child", sWebLanguage)%>
            </td>
        </tr>
        <%-- gender / weight --%>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "gender", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_GENDER")%> type="radio" onDblClick="uncheckRadio(this);" id="gender_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER" property="itemId"/>]>.value" value="male"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER;value=male"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "male", sWebLanguage, "gender_r1")%>
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_GENDER")%> type="radio" onDblClick="uncheckRadio(this);" id="gender_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER" property="itemId"/>]>.value" value="female"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER;value=female"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web.occup", "female", sWebLanguage, "gender_r2")%>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk", "weight", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDWEIGHT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDWEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDWEIGHT" property="value"/>" onblur="isNumber(this)"> g
            </td>
        </tr>
        <%-- height / cranien --%>
        <tr>
            <td class="admin"><%=getTran("gynaeco", "height", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDHEIGHT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDHEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDHEIGHT" property="value"/>" onblur="isNumber(this)"> cm
            </td>
            <td class="admin"><%=getTran("gynaeco", "cranien", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILDCRANIEN")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDCRANIEN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDCRANIEN" property="value"/>" onblur="isNumber(this)"> cm
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td colspan="3" bgcolor="#EBF3F7">
                <table width="100%" cellspacing="1" bgcolor="white">
                    <%-- BORN DEATH -------------------------------------------------------------%>
                    <tr>
                        <td colspan="2" class="admin2">
                            <input onclick="doAlive()" type="radio" onDblClick="uncheckRadio(this);" id="alive_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE" property="itemId"/>]>.value" value="openclinic.common.borndead"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE;value=openclinic.common.borndead"
                                                      property="value"
                                                      outputString="checked"/>><%=getLabel("openclinic.chuk", "openclinic.common.borndead", sWebLanguage, "alive_r1")%>
                        </td>
                    </tr>
                    <%-- death type --%>
                    <tr id="tralive1">
                        <td width="90" class="admin2"/>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_DEAD_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deadtype_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE" property="itemId"/>]>.value" value="gynaeco.dead_type_frais"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE;value=gynaeco.dead_type_frais"
                                                      property="value"
                                                      outputString="checked"/>><%=getLabel("gynaeco.deadtype", "frais", sWebLanguage, "deadtype_r1")%>
                            <input <%=setRightClick("ITEM_TYPE_DELIVERY_DEAD_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="deadtype_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE" property="itemId"/>]>.value" value="gynaeco.dead_type_macere"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DEAD_TYPE;value=gynaeco.dead_type_macere"
                                                      property="value"
                                                      outputString="checked"/>><%=getLabel("gynaeco.deadtype", "macere", sWebLanguage, "deadtype_r2")%>
                        </td>
                    </tr>
                    <%-- BORN ALIVE -------------------------------------------------------------%>
                    <tr>
                        <td colspan="2" class="admin2">
                            <input onclick="doAlive()" type="radio" onDblClick="uncheckRadio(this);" id="alive_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE" property="itemId"/>]>.value" value="openclinic.common.bornalive"
                            <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                      compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDALIVE;value=openclinic.common.bornalive"
                                                      property="value"
                                                      outputString="checked"/>><%=getLabel("openclinic.chuk", "openclinic.common.bornalive", sWebLanguage, "alive_r2")%>
                        </td>
                    </tr>
                    <tr id="tralive2">
                        <td class="admin2" width="90"/>
                        <td bgcolor="#EBF3F7">
                            <table bgcolor="white" cellspacing="1">
                                <tr>
                                    <td class="admin2" colspan="3">
                                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_DEADIN24H")%> type="checkbox" id="cbdead24h" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADIN24H" property="itemId"/>]>.value"
                                                <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DEADIN24H;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/>
                                        <%=getLabel("openclinic.chuk", "dead.in.24h", sWebLanguage, "cbdead24h")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td rowspan="9" class="admin2">
                                        <table class="list" cellspacing="1">
                                            <%-- apgar header --%>
                                            <tr class="gray">
                                                <td width="50"><%=getTran("gynaeco", "apgar", sWebLanguage)%>
                                                </td>
                                                <td width="50" align="center">1'</td>
                                                <td width="50" align="center">5'</td>
                                                <td width="50" align="center">10'</td>
                                            </tr>
                                            <%-- apgar.coeur --%>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco", "apgar.coeur", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <select class="text" id="coeur1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1;value=1" property="value" outputString="selected"/>>&lt;100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_1;value=2" property="value" outputString="selected"/>>&gt;=100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="coeur5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5;value=1" property="value" outputString="selected"/>>&lt;100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_5;value=2" property="value" outputString="selected"/>>&gt;=100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="coeur10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10;value=1" property="value" outputString="selected"/>>&lt;100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COEUR_10;value=2" property="value" outputString="selected"/>>&gt;=100 <%=getTran("web","bpm",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <%-- apgar.resp --%>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco", "apgar.resp", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <select class="text" id="resp1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1;value=1" property="value" outputString="selected"/>><%=getTran("web","slow_irregular",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_1;value=2" property="value" outputString="selected"/>><%=getTran("web","good_crying",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="resp5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5;value=1" property="value" outputString="selected"/>><%=getTran("web","slow_irregular",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_5;value=2" property="value" outputString="selected"/>><%=getTran("web","good_crying",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="resp10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10;value=1" property="value" outputString="selected"/>><%=getTran("web","slow_irregular",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_RESP_10;value=2" property="value" outputString="selected"/>><%=getTran("web","good_crying",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <%-- apgar.tonus --%>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco", "apgar.tonus", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <select class="text" id="tonus1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1;value=1" property="value" outputString="selected"/>><%=getTran("web","arms_legs_bown",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_1;value=2" property="value" outputString="selected"/>><%=getTran("web","active",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="tonus5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5;value=1" property="value" outputString="selected"/>><%=getTran("web","arms_legs_bown",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_5;value=2" property="value" outputString="selected"/>><%=getTran("web","active",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="tonus10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10;value=1" property="value" outputString="selected"/>><%=getTran("web","arms_legs_bown",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TONUS_10;value=2" property="value" outputString="selected"/>><%=getTran("web","active",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <%-- apgar.refl --%>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco", "apgar.refl", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <select class="text" id="refl1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1;value=1" property="value" outputString="selected"/>><%=getTran("web","grimace",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_1;value=2" property="value" outputString="selected"/>><%=getTran("web","sneezing_coughing",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="refl5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5;value=1" property="value" outputString="selected"/>><%=getTran("web","grimace",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_5;value=2" property="value" outputString="selected"/>><%=getTran("web","sneezing_coughing",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="refl10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10;value=0" property="value" outputString="selected"/>><%=getTran("web","absent",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10;value=1" property="value" outputString="selected"/>><%=getTran("web","grimace",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_REFL_10;value=2" property="value" outputString="selected"/>><%=getTran("web","sneezing_coughing",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <%-- apgar.color --%>
                                            <tr class="list">
                                                <td><%=getTran("gynaeco", "apgar.color", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <select class="text" id="color1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1;value=0" property="value" outputString="selected"/>><%=getTran("web","blue_gray_white",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1;value=1" property="value" outputString="selected"/>><%=getTran("web","normal_except_extremities",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_1;value=2" property="value" outputString="selected"/>><%=getTran("web","normal_whole_body",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="color5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5;value=0" property="value" outputString="selected"/>><%=getTran("web","blue_gray_white",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5;value=1" property="value" outputString="selected"/>><%=getTran("web","normal_except_extremities",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_5;value=2" property="value" outputString="selected"/>><%=getTran("web","normal_whole_body",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="text" id="color10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10" property="itemId"/>]>.value" onclick="calculateapgar();">
                                                        <option value="-1"></option>
                                                        <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10;value=0" property="value" outputString="selected"/>><%=getTran("web","blue_gray_white",sWebLanguage)%></option>
                                                        <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10;value=1" property="value" outputString="selected"/>><%=getTran("web","normal_except_extremities",sWebLanguage)%></option>
                                                        <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_COLOR_10;value=2" property="value" outputString="selected"/>><%=getTran("web","normal_whole_body",sWebLanguage)%></option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <%-- apgar.total --%>
                                            <tr class="list1">
                                                <td><%=getTran("gynaeco", "apgar.total", sWebLanguage)%>
                                                </td>
                                                <td>
                                                    <input id="total1" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_1")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_1" property="value"/>" onblur="isNumber(this)">
                                                </td>
                                                <td>
                                                    <input id="total5" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_5")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_5" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_5" property="value"/>" onblur="isNumber(this)">
                                                </td>
                                                <td>
                                                    <input id="total10" <%=setRightClick("ITEM_TYPE_DELIVERY_APGAR_TOTAL_10")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_10" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_APGAR_TOTAL_10" property="value"/>" onblur="isNumber(this)">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <%-- reanimation --%>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk", "reanimation", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <textarea id="reanimation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_REANIMATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_REANIMATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_REANIMATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <%-- malformation --%>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk", "malformation", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <textarea id="malformation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_MALFORMATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_MALFORMATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_MALFORMATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <%-- observation --%>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk", "observation", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <textarea id="observation" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_OBSERVATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_OBSERVATION" property="value"/></textarea>
                                    </td>
                                </tr>
                                <%-- treatment --%>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk", "treatment", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <textarea id="treatment" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DELIVERY_CHILD_TREATMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_TREATMENT" property="value"/></textarea>
                                    </td>
                                </tr>
                                <%-- polio.date --%>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk", "polio.date", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <input id="polio_date" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDPOLIO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDPOLIO" property="value" formatType="date" format="dd/mm/yyyy"/>">
                                        <script>writeMyDate("polio_date", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                                    </td>
                                </tr>
                                <%-- bcg.date --%>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk", "bcg.date", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <input id="bcg_date" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDBCG" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILDBCG" property="value" formatType="date" format="dd/mm/yyyy"/>">
                                        <script>writeMyDate("bcg_date", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                                    </td>
                                </tr>
                                <%-- lastname --%>
                                <tr>
                                    <td class="admin"><%=getTran("web", "lastname", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_LASTNAME" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_LASTNAME" property="value"/>">
                                    </td>
                                </tr>
                                <%-- firstname --%>
                                <tr>
                                    <td class="admin"><%=getTran("web", "firstname", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_FIRSTNAME" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_FIRSTNAME" property="value"/>">
                                    </td>
                                </tr>
                                <%-- dateofbirth --%>
                                <tr>
                                    <td class="admin"><%=getTran("web", "dateofbirth", sWebLanguage)%>
                                    </td>
                                    <td class="admin2">
                                        <input id="child_dob" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DOB" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DOB" property="value" formatType="date" format="dd/mm/yyyy"/>">
                                        <script>writeMyDate("child_dob", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
                <%=getButtonsHtml(request, activeUser, activePatient, "true".equalsIgnoreCase(request.getParameter("readonly"))?"readonly":"occup.delivery", sWebLanguage)%>
            </td>
        </tr>
    </table>
    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>

    function calculateapgar(){
        if(document.getElementById("coeur1").value=="-1" || document.getElementById("resp1").value=="-1" || document.getElementById("tonus1").value=="-1" || document.getElementById("refl1").value=="-1" || document.getElementById("color1").value=="-1"){
            document.getElementById("total1").value="";
        }
        else {
            document.getElementById("total1").value=1*document.getElementById("coeur1").value+1*document.getElementById("resp1").value+1*document.getElementById("tonus1").value+1*document.getElementById("refl1").value+1*document.getElementById("color1").value;
        }
        if(document.getElementById("coeur5").value=="-1" || document.getElementById("resp5").value=="-1" || document.getElementById("tonus5").value=="-1" || document.getElementById("refl5").value=="-1" || document.getElementById("color5").value=="-1"){
            document.getElementById("total5").value="";
        }
        else {
            document.getElementById("total5").value=1*document.getElementById("coeur5").value+1*document.getElementById("resp5").value+1*document.getElementById("tonus5").value+1*document.getElementById("refl5").value+1*document.getElementById("color5").value;
        }
        if(document.getElementById("coeur10").value=="-1" || document.getElementById("resp10").value=="-1" || document.getElementById("tonus10").value=="-1" || document.getElementById("refl10").value=="-1" || document.getElementById("color10").value=="-1"){
            document.getElementById("total10").value="";
        }
        else {
            document.getElementById("total10").value=1*document.getElementById("coeur10").value+1*document.getElementById("resp10").value+1*document.getElementById("tonus10").value+1*document.getElementById("refl10").value+1*document.getElementById("color10").value;
        }
    }

    function convertTimeToNbForGraph(nb) {
        switch (parseInt(nb)) {
            case 15:
                nb = 25;
                break;
            case 25:
                nb = 15;
                break;
            case 30:
                nb = 50;
                break;
            case 50:
                nb = 30;
                break;
            case 45:
                nb = 75;
                break;
            case 75:
                nb = 45;
                break;
        }
        return nb;
    }
    <%-- SUBMIT FORM --%>
    function submitForm() {
        if(document.getElementById('encounteruid').value==''){
    		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
    		searchEncounter();
    	}	
        else {
	        var maySubmit = true;
	        if (isAtLeastOneDilatationFieldFilled()) {
	            if (maySubmit) {
	                if (!addDilatation()) {
	                    maySubmit = false;
	                }
	            }
	        }
	        var sTmpBegin;
	        var sTmpEnd;
	        while (sDilatation.indexOf("rowDilatation") > -1) {
	            sTmpBegin = sDilatation.substring(sDilatation.indexOf("rowDilatation"));
	            sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
	            sDilatation = sDilatation.substring(0, sDilatation.indexOf("rowDilatation")) + sTmpEnd;
	        }
	        document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_DILATATION" property="itemId"/>]>.value"].value = sDilatation;
	        if (isAtLeastOneEngagementFieldFilled()) {
	            if (maySubmit) {
	                if (!addEngagement()) {
	                    maySubmit = false;
	                }
	            }
	        }
	        while (sEngagement.indexOf("rowEngagement") > -1) {
	            sTmpBegin = sEngagement.substring(sEngagement.indexOf("rowEngagement"));
	            sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
	            sEngagement = sEngagement.substring(0, sEngagement.indexOf("rowEngagement")) + sTmpEnd;
	        }
	        document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_ENGAGEMENT" property="itemId"/>]>.value"].value = sEngagement;
	        if (isAtLeastOneActionFieldFilled()) {
	            if (maySubmit) {
	                if (!addAction()) {
	                    maySubmit = false;
	                }
	            }
	        }
	        while (sAction.indexOf("rowAction") > -1) {
	            sTmpBegin = sAction.substring(sAction.indexOf("rowAction"));
	            sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
	            sAction = sAction.substring(0, sAction.indexOf("rowAction")) + sTmpEnd;
	        }
	        //setBeginHourSelect int hidden field;
	        if($("beginHourSelect").value.length==0) {
	            $("ITEM_TYPE_DELIVERY_STARTHOUR").value = '';
	        }else{
	            $("ITEM_TYPE_DELIVERY_STARTHOUR").value = $("beginHourSelect").value+":"+$("beginMinutSelect").value;
	        }
	
	        document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_WORK_ACTION" property="itemId"/>]>.value"].value = sAction;
	        if (maySubmit) {
	            document.transactionForm.saveButton.style.visibility = "hidden";
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(250, 500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(500, 750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(750, 1000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(1000, 1250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(1250, 1500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(1500, 1750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(1750, 2000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value'].value.substring(0, 250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(250, 500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(500, 750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(750, 1000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(1000, 1250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(1250, 1500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(1500, 1750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(1750, 2000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value'].value.substring(0, 250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(250, 500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(500, 750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(750, 1000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(1000, 1250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(1250, 1500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(1500, 1750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(1750, 2000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_COLLAR" property="itemId"/>]>.value'].value.substring(0, 250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA1" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(250, 500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA2" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(500, 750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA3" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(750, 1000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA4" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(1000, 1250);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA5" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(1250, 1500);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA6" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(1500, 1750);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA7" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(1750, 2000);
	            document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_MUCOSA" property="itemId"/>]>.value'].value.substring(0, 250);
	            var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	        <%
	            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	            out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	        %>
	        }
        }
    }
    function searchEncounter(){
        openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
    }
    if(document.getElementById('encounteruid').value==''){
  	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
  	searchEncounter();
    }	
      
    function clearType2(object) {
        if (!object.checked) {
            if (document.all["trtype2"]) {
                hide("trtype2");
            }
            document.getElementById("cbventousse").checked = false;
            document.getElementById("ttractions").value = "";
            document.getElementById("tlachage").value = "";
            document.getElementById("cbforceps").checked = false;
            document.getElementById("cbmanoeuvre").checked = false;
            document.getElementById("causedystocic_r1").checked = false;
            document.getElementById("causedystocic_r2").checked = false;
            document.getElementById("causedystocic_r3").checked = false;
            document.getElementById("tdystoticremark").value = "";
        }
        else {
            show("trtype2");
        }
    }
    function clearType3(object) {
        if (!object.checked) {
            if (document.all["trtype3"]) {
                hide("trtype3");
            }
            document.getElementById("caeserian_r1").checked = false;
            document.getElementById("caeserian_r2").checked = false;
            document.getElementById("causecaeserian_r1").checked = false;
            document.getElementById("causecaeserian_r2").checked = false;
            document.getElementById("causecaeserian_r3").checked = false;
            document.getElementById("tcaeserianremark").value = "";
            document.getElementById("tcaeserianindication").value = "";
        }
        else {
            show("trtype3");
        }
    }
    function doAlive() {
        document.getElementById("tralive1").style.display = "none";
        document.getElementById("tralive2").style.display = "none";
        if (document.getElementById("alive_r1").checked) {
            document.getElementById("cbdead24h").checked = false;
            document.getElementById("coeur1").value = "";
            document.getElementById("coeur5").value = "";
            document.getElementById("coeur10").value = "";
            document.getElementById("resp1").value = "";
            document.getElementById("resp5").value = "";
            document.getElementById("resp10").value = "";
            document.getElementById("tonus1").value = "";
            document.getElementById("tonus5").value = "";
            document.getElementById("tonus10").value = "";
            document.getElementById("refl1").value = "";
            document.getElementById("refl5").value = "";
            document.getElementById("refl10").value = "";
            document.getElementById("color1").value = "";
            document.getElementById("color5").value = "";
            document.getElementById("color10").value = "";
            document.getElementById("total1").value = "";
            document.getElementById("total5").value = "";
            document.getElementById("total10").value = "";
            document.getElementById("reanimation").value = "";
            document.getElementById("malformation").value = "";
            document.getElementById("observation").value = "";
            document.getElementById("treatment").value = "";
            document.getElementById("polio_date").value = "";
            document.getElementById("bcg_date").value = "";
            document.getElementById("tralive1").style.display = "";
        }
        else if (document.getElementById("alive_r2").checked) {
            document.getElementById("deadtype_r1").checked = false;
            document.getElementById("deadtype_r2").checked = false;
            document.getElementById("tralive2").style.display = "";
        }
    }
    doAlive();
    <%
        tran = sessionContainerWO.getCurrentTransactionVO();
        if(tran!=null){
            tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId().intValue());

            if ((tran!=null)&&(tran.getHealthrecordId() != sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue())){
                out.print("document.transactionForm.saveButton.disabled = true;");
            }
        }
    %>
    function clearDr() {
        if (document.getElementById("drdate").value.length == 0) {
            document.getElementById("agedatedr").value = "";
            document.getElementById("drdeldate").value = "";
        }
    }
    function calculateGestAge() {
        var trandate = new Date();
        var d1 = document.getElementById('trandate').value.split("/");
        if (d1.length == 3) {
            trandate.setDate(d1[0]);
            trandate.setMonth(d1[1] - 1);
            trandate.setFullYear(d1[2]);
            var lmdate = new Date();
            d1 = document.getElementById('drdate').value.split("/");
            if (d1.length == 3) {
                lmdate.setDate(d1[0]);
                lmdate.setMonth(d1[1] - 1);
                lmdate.setFullYear(d1[2]);
                var timeElapsed = trandate.getTime() - lmdate.getTime();
                timeElapsed = timeElapsed / (1000 * 3600 * 24 * 7);
                if (!isNaN(timeElapsed) && timeElapsed > 0 && timeElapsed < 60) {
                    var age = Math.round(timeElapsed * 10) / 10;
                    age = age + "";
                    if (age.indexOf(".") > -1) {
                        var aAge = age.split(".");
                        aAge[1] = Math.round(aAge[1] * 1 * 0.7);
                        age = aAge[0] + " " + aAge[1];
                    }
                    document.getElementById("agedatedr").value = age;
                    var drdeldate = lmdate;
                    drdeldate.setTime(drdeldate.getTime() + 1000 * 3600 * 24 * 280);
                    document.getElementById("drdeldate").value = drdeldate.getDate() + "/" + (drdeldate.getMonth() + 1) + "/" + drdeldate.getFullYear();
                    checkDate(document.getElementById("drdeldate"));
                    if (timeElapsed < 12) {
                        document.getElementById('trimestre_r1').checked = true;
                    }
                    else if (timeElapsed < 24) {
                        document.getElementById('trimestre_r2').checked = true;
                    }
                    else {
                        document.getElementById('trimestre_r3').checked = true;
                    }
                }
                else {
                    document.getElementById("drdeldate").value = '';
                }
            }
            //recalculate actual age based on echography estimation
            var ledate = new Date();
            d1 = document.getElementById('echodate').value.split("/");
            if (d1.length == 3) {
                ledate.setDate(d1[0]);
                ledate.setMonth(d1[1] - 1);
                ledate.setFullYear(d1[2]);
                var timeElapsed = trandate.getTime() - ledate.getTime();
                timeElapsed = timeElapsed / (1000 * 3600 * 24 * 7);
                if (!isNaN(timeElapsed) && document.getElementById("agedateecho").value.length > 0 && !isNaN(document.getElementById("agedateecho").value)) {
                    age = (document.getElementById("agedateecho").value * 1 + Math.round(timeElapsed * 10) / 10)+"";
                    if (age.indexOf(".")>-1){
                        aAge = age.split(".");
                        age = aAge[0]+ " " +aAge[1];
                    }
                    document.getElementById("ageactualecho").value = age;
                }
            }
        }
    }
    //   calculateGestAge();
    if (document.getElementById("transactionId").value.startsWith("-")) {
        <%
            String sAgeDateDr = "";
            ItemVO itemDelAgeDateDr = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR");

            if (itemDelAgeDateDr!=null){
                sAgeDateDr = itemDelAgeDateDr.getValue();
                %>document.getElementById("drdate").value = "<%=sAgeDateDr%>";
        <%
}

ItemVO itemAgeDateEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY");
if (itemAgeDateEcho!=null){
    java.sql.Date dNow = ScreenHelper.getSQLDate(ScreenHelper.getDate());
    long lNow = dNow.getTime()/1000/3600/24/7;
    long lEcho = itemAgeDateEcho.getDate().getTime()/1000/3600/24/7;

    if (lNow-lEcho < 43){
        %>document.getElementById("agedateecho").value = "<%=lNow-lEcho%>";
        <%

    ItemVO itemEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO");
    if (itemEcho!=null){
        %>document.getElementById("echodate").value = "<%=itemEcho.getValue()%>";
        <%
    }

    ItemVO itemDateEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY");
    if (itemEcho!=null){
        %>document.getElementById("echodeldate").value = "<%=itemDateEcho.getValue()%>";
    <%
            }
        }
    }
    %>
        calculateGestAge();

        if (document.getElementById("agedatedr").value.length>0){
            var aDate = document.getElementById("agedatedr").value.split(" ");
            if (aDate[0].length>0){
                if (aDate[0]*1>43){
                    document.getElementById("drdate").value = "";
                    clearDr();
                }
            }
        }

        if (document.getElementById("ageactualecho").value.length>0){
            var aDate = document.getElementById("ageactualecho").value.split(" ");
            if (aDate[0].length>0){
                if (aDate[0]*1>43){
                    document.getElementById("echodate").value = "";
                    document.getElementById("agedateecho").value = "";
                    document.getElementById("echodeldate").value = "";
                    document.getElementById("ageactualecho").value = "";
                }
            }
        }
    }
    else {
        calculateGestAge();
    }

    var iDilatationIndex = <%=iDilatationTotal%>;
    var sDilatation = "<%=sDilatation%>";
    <%-- Dilatation -------------------------------------------------------------------------%>
    function addDilatation() {
        if (isAtLeastOneDilatationFieldFilled()) {
        <%-- set begin time and first time of dilatation the same --%>
  /*          if (iDilatationIndex == 1 && $("beginHourSelect").value == "") {
                $("beginHourSelect").selectedIndex = $("dilatationHour").selectedIndex;
                $("beginMinutSelect").selectedIndex = $("dilatationMinutes").selectedIndex;
                getEarlierTime();
            }   */
            iDilatationIndex++;
            sDilatation += "rowDilatation" + iDilatationIndex + "=" + transactionForm.dilatationHour.value + "£" + transactionForm.dilatationMinutes.value + "£" + transactionForm.dilatationOpening.value + "$";
            var tr;
            tr = tblDilatation.insertRow(tblDilatation.rows.length);
            tr.id = "rowDilatation" + iDilatationIndex;
            var td = tr.insertCell(0);
            td.innerHTML = "<a href='javascript:deleteDilatation(rowDilatation" + iDilatationIndex + "," + transactionForm.dilatationHour.value + convertTimeToNbForGraph(transactionForm.dilatationMinutes.value) + ")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a>";
            tr.appendChild(td);
            td = tr.insertCell(1);
            td.innerHTML = "&nbsp;" + transactionForm.dilatationHour.value + ":" + transactionForm.dilatationMinutes.value;
            tr.appendChild(td);
            td = tr.insertCell(2);
            td.innerHTML = "&nbsp;" + transactionForm.dilatationOpening.value;
            tr.appendChild(td);
            td = tr.insertCell(3);
            td.innerHTML = "&nbsp;";
            tr.appendChild(td);
            setCellStyle(tr);
            setNewDilatation(transactionForm.dilatationHour.value + convertTimeToNbForGraph(transactionForm.dilatationMinutes.value), transactionForm.dilatationOpening.value);
            clearDilatationFields();
            clearGraphDilatation();
            setGraphDilatation();
        }
        return true;
    }
    function isAtLeastOneDilatationFieldFilled() {
        if (transactionForm.dilatationHour.value != "") return true;
        if (transactionForm.dilatationOpening.value != "") return true;
        return false;
    }
    function clearDilatationFields() {
        transactionForm.dilatationHour.selectedIndex = -1;
        //transactionForm.dilatationMinutes.selectedIndex = -1;
        transactionForm.dilatationOpening.selectedIndex = -1;
    }
    function deleteDilatation(rowid, dilatationHours) {
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer;
        if (window.showModalDialog) {
            answer = window.showModalDialog(popupUrl, '', modalitiesIE);
        }
        else {
            answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
        }
        if (answer == 1) {
            sDilatation = deleteRowFromArrayString(sDilatation, rowid.id);
            tblDilatation.deleteRow(rowid.rowIndex);
            graphDilatation.unset(dilatationHours);
            iDilatationIndex--;
            clearDilatationFields();
            clearGraphDilatation();
            setGraphDilatation();
        }
    }
    var iEngagementIndex = <%=iEngagementTotal%>;
    var sEngagement = "<%=sEngagement%>";
    <%-- Engagement -------------------------------------------------------------------------%>
    function addEngagement() {
        if (isAtLeastOneEngagementFieldFilled()) {
            <%-- set begin time and first time of engagment the same --%>
 /*           if (iEngagementIndex == 1 && $("beginHourSelect").value == "") {
                $("beginHourSelect").selectedIndex = $("engagementHour").selectedIndex;
                $("beginMinutSelect").selectedIndex = $("engagementMinutes").selectedIndex;
                getEarlierTime();
            }*/
            iEngagementIndex++;
            sEngagement += "rowEngagement" + iEngagementIndex + "=" + transactionForm.engagementHour.value + "£" + transactionForm.engagementMinutes.value + "£" + transactionForm.engagementDegree.value + "$";
            var tr;
            tr = tblEngagement.insertRow(tblEngagement.rows.length);
            tr.id = "rowEngagement" + iEngagementIndex;
            var td = tr.insertCell(0);
            td.innerHTML = "<a href='javascript:deleteEngagement(rowEngagement" + iEngagementIndex + "," + transactionForm.engagementHour.value + convertTimeToNbForGraph(transactionForm.engagementMinutes.value) + ")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a>";
            tr.appendChild(td);
            td = tr.insertCell(1);
            td.innerHTML = "&nbsp;" + transactionForm.engagementHour.value + ":" + transactionForm.engagementMinutes.value;
            tr.appendChild(td);
            td = tr.insertCell(2);
            td.innerHTML = "&nbsp;" + transactionForm.engagementDegree.value;
            tr.appendChild(td);
            td = tr.insertCell(3);
            td.innerHTML = "&nbsp;";
            tr.appendChild(td);
            setCellStyle(tr);
            setNewEngagement(transactionForm.engagementHour.value + convertTimeToNbForGraph(transactionForm.engagementMinutes.value), transactionForm.engagementDegree.value);
            clearEngagementFields()
        }
        clearGraphEngagement();
        setGraphEngagement();
        return true;
    }
    function isAtLeastOneEngagementFieldFilled() {
        if (transactionForm.engagementHour.value != "") return true;
        if (transactionForm.engagementDegree.value != "") return true;
        return false;
    }
    function clearEngagementFields() {
        transactionForm.engagementHour.selectedIndex = -1;
        //transactionForm.engagementMinutes.selectedIndex = -1;
        transactionForm.engagementDegree.selectedIndex = -1;
    }
    function deleteEngagement(rowid, engagementHour) {
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer;
        if (window.showModalDialog) {
            answer = window.showModalDialog(popupUrl, '', modalitiesIE);
        }
        else {
            answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
        }
        if (answer == 1) {
            sEngagement = deleteRowFromArrayString(sEngagement, rowid.id);
            tblEngagement.deleteRow(rowid.rowIndex);
            graphEngagement.unset(engagementHour);
            iEngagementIndex--;
            clearEngagementFields();
            clearGraphEngagement();
            setGraphEngagement();
        }
    }
    var iActionIndex = <%=iActionTotal%>;
    var sAction = "<%=sAction%>";
    <%-- Action -------------------------------------------------------------------------%>
    function addAction() {
        if (isAtLeastOneActionFieldFilled()) {
              <%-- set begin time and first time of engagment the same --%>
  /*          if (iActionIndex == 1 && $("beginHourSelect").value == "") {
                $("beginHourSelect").selectedIndex = $("actionHour").selectedIndex;
                $("beginMinutSelect").selectedIndex = $("actionMinutes").selectedIndex;
                getEarlierTime();
            } */
            iActionIndex++;
            sAction += "rowAction" + iActionIndex + "=" + transactionForm.actionHour.value + "£" + transactionForm.actionMinutes.value + "£" + transactionForm.actionLetter.value + "$";

            var tr;
            tr = tblAction.insertRow(tblAction.rows.length);
            tr.id = "rowAction" + iActionIndex;
            var td = tr.insertCell(0);
            td.innerHTML = "<a href='javascript:deleteAction(rowAction" + iActionIndex + ",\"" + transactionForm.actionHour.value + transactionForm.actionMinutes.value + transactionForm.actionLetter.value + "\");'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a>";
            tr.appendChild(td);
            td = tr.insertCell(1);
            td.innerHTML = "&nbsp;" + transactionForm.actionHour.value + ":" + transactionForm.actionMinutes.value;
            tr.appendChild(td);
            td = tr.insertCell(2);
            td.innerHTML = "&nbsp;" + transactionForm.actionLetter.value;
            tr.appendChild(td);
            td = tr.insertCell(3);
            td.innerHTML = "&nbsp;";
            tr.appendChild(td);
            setCellStyle(tr);

            var sIndex = transactionForm.actionLetter.value;
            if (sIndex.length==0){
                sIndex = "0";
            }
            graphAction.set(transactionForm.actionHour.value + transactionForm.actionMinutes.value + sIndex, transactionForm.actionLetter.value);
            clearActionFields();
        }
        setGraphAction();
        return true;
    }
    function isAtLeastOneActionFieldFilled() {
        if (transactionForm.actionHour.value != "") return true;
        if (transactionForm.actionLetter.value != "") return true;
        return false;
    }
    function clearActionFields() {
        transactionForm.actionHour.selectedIndex = -1;
        //transactionForm.actionMinutes.selectedIndex = -1;
        transactionForm.actionLetter.selectedIndex = -1;
    }
    function deleteAction(rowid, actionHour) {
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer;
        if (window.showModalDialog) {
            answer = window.showModalDialog(popupUrl, '', modalitiesIE);
        }
        else {
            answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
        }
        if (answer == 1) {
            sAction = deleteRowFromArrayString(sAction, rowid.id);
            tblAction.deleteRow(rowid.rowIndex);
            graphAction.unset(actionHour);
            clearActionFields();
            clearGraphAction();
            setGraphAction();
        }
    }
    <!-- GENERAL FUNCTIONS -->
    function deleteRowFromArrayString(sArray, rowid) {
        var array = sArray.split("$");
        for (var i = 0; i < array.length; i++) {
            if (array[i].indexOf(rowid) > -1) {
                array.splice(i, 1);
            }
        }
        return array.join("$");
    }
    function getRowFromArrayString(sArray, rowid) {
        var array = sArray.split("$");
        var row = "";
        for (var i = 0; i < array.length; i++) {
            if (array[i].indexOf(rowid) > -1) {
                row = array[i].substring(array[i].indexOf("=") + 1);
                break;
            }
        }
        return row;
    }
    function getCelFromRowString(sRow, celid) {
        var row = sRow.split("£");
        return row[celid];
    }
    function replaceRowInArrayString(sArray, newRow, rowid) {
        var array = sArray.split("$");
        for (var i = 0; i < array.length; i++) {
            if (array[i].indexOf(rowid) > -1) {
                array.splice(i, 1, newRow);
                break;
            }
        }
        return array.join("$");
    }
    function setCellStyle(row) {
        for (var i = 0; i < row.cells.length; i++) {
            row.cells[i].style.color = "#333333";
            row.cells[i].style.fontFamily = "arial";
            row.cells[i].style.fontSize = "10px";
            row.cells[i].style.fontWeight = "normal";
            row.cells[i].style.textAlign = "left";
            row.cells[i].style.paddingLeft = "5px";
            row.cells[i].style.paddingRight = "1px";
            row.cells[i].style.paddingTop = "1px";
            row.cells[i].style.paddingBottom = "1px";
            row.cells[i].style.backgroundColor = "#E0EBF2";
        }
    }
    function setRightUnits(vv) {
        var r = "";
        switch (vv) {
            case 1:
                r = "+4";
                break;
            case 3:
                r = "+2";
                break;
            case 5:
                r = "0";
                break;
            case 7:
                r = "-2";
                break;
            case 9:
                r = "-4";
                break;
        }
        return("<nobr>" + r + "</nobr>");
    }
    var D = new Diagram();
    _BFont = "font-family:arial;font-size:8pt;line-height:9pt;";
    D.SetFrame(0, 30, 720, 335);
    D.SetBorder(0, 24, 0, 10);
    D.SetGridColor("#808080", "#CCCCCC");
    var i, j, x, y;
    j = D.ScreenY(0);
    P = new Array(720);
    D.XScale = "h";
    D.YGridDelta = 1;
    D.XGridDelta = 1;
    D.XSubGrids = 4;
    _DivDiagram = 'glycemyGraph';
    D.Draw("#FFEECC", "#663300", false);
    var t, T0, T1;
    D.GetYGrid();
    D.GetXGrid();
    D.XGrid[1] = 0.25;
    //----------------------- SET RIGHT UNITS -----------------//
    for (t = D.YGrid[0]; t <= D.YGrid[2]; t += D.YGrid[1]) {
        new Bar(D.right + 6, D.ScreenY(t) - 8, D.right + 6, D.ScreenY(t) + 8, "", setRightUnits(t), "#663300");
    }
    //------------------------ SET DEFAULT LINES --------------//
    new Line(D.ScreenX(0), D.ScreenY(3), D.ScreenX(8), D.ScreenY(3), "#0a0e70", 2, "<%=getTranNoLink("gynae", "dilatation.opening", sWebLanguage)%>");
    new Line(D.ScreenX(8), D.ScreenY(3), D.ScreenX(15), D.ScreenY(10), "#0a0e70", 2, "<%=getTranNoLink("gynae", "dilatation.opening", sWebLanguage)%>");
    new Line(D.ScreenX(12), D.ScreenY(3), D.ScreenX(19), D.ScreenY(10), "#610202", 2, "<%=getTranNoLink("gynaeco", "work.engagement", sWebLanguage)%>");
    new Line(D.ScreenX(8), D.ScreenY(0), D.ScreenX(8), D.ScreenY(10), "black", 2, "<%=getTranNoLink("gynaeco", "work.engagement", sWebLanguage)%>");
    //------------------------ SET DESCRIPTIONS ---------------//
    new Bar(40, 35, 170, 50, "", "<%=getTranNoLink("gynae", "phase.latente", sWebLanguage)%>", "#000");
    new Bar(225, 35, 360, 50, "", "<%=getTranNoLink("gynaeco", "phase.active", sWebLanguage)%>", "#000");
    //------------------------ SET LEGEND ---------------------//
    new Bar(20, -15, 170, 0, "#0000FF", "<%=getTranNoLink("gynae", "dilatation.opening", sWebLanguage)%>", "#FFFFFF");
    new Bar(190, -15, 360, 0, "#FF0000", "<%=getTranNoLink("gynaeco", "work.engagement", sWebLanguage)%>", "#FFFFFF");
    new Bar(380, -15, 520, 0, "#FFFF00", "<%=getTranNoLink("gynae", "action", sWebLanguage)%>", "#000");
    //---------------------------------------------- DILATATION GRAPH -------------------------------------//
    function sortNumber(a, b) {
        return a - b;
    }
    function convertDilatationYtoDegree(s) {
        y = parseFloat(s);
        t = 5;
        if (y > 0) {
            for (var i = 1; i <= y; i++) {
                t--;
            }
            y = parseFloat(t);
        } else if (y < 0) {
            for (var i = -1; i >= y; i--) {
                t++;
            }
            y = parseFloat(t);
        } else {
            y = parseFloat('5');
        }
        return y;
    }
    function setGraphDilatation() {
        var graphDilatation_keys = graphDilatation.keys();
        if (graphDilatation_keys.length > 1) {
            graphDilatation_keys.sort(sortNumber);
            for (i = 0; i < graphDilatation_keys.length - 1; i++) {
                var p1x = graphDilatation_keys[i] - getEarlierTime();
                var p1y = graphDilatation.get(graphDilatation_keys[i]);
                var p2x = graphDilatation_keys[i + 1] - getEarlierTime();
                var p2y = graphDilatation.get(graphDilatation_keys[i + 1]);
                graphDilatationObjects.push(new Line(D.ScreenX(p1x / 100), D.ScreenY(p1y), D.ScreenX(p2x / 100), D.ScreenY(p2y), "#0000FF", 2, ""));
            }
        } else {
            graphDilatation.each(function(index) {
                var x = index.key - getEarlierTime();
                graphDilatationObjects.push(new Dot(D.ScreenX(x / 100), D.ScreenY(index.value), 7, 18, '#0000FF', "dot"));
            });
        }
    }
    function clearGraphDilatation() {
        graphDilatationObjects.each(function(obj) {
            obj.Delete();
        });
        graphDilatationObjects.clear();
    }
    //------------------------------------------------ ENGAGEMENT GRAPH ---------------------------------------//
    function setGraphEngagement() {
        function sortNumber(a, b) {
            return a - b;
        }
        var graphEngagement_keys = graphEngagement.keys();
        if (graphEngagement_keys.length > 1) {
            graphEngagement_keys.sort(sortNumber);
            for (i = 0; i < graphEngagement_keys.length - 1; i++) {
                var p1x = graphEngagement_keys[i] - getEarlierTime();
                var p1y = graphEngagement.get(graphEngagement_keys[i]);
                var p2x = graphEngagement_keys[i + 1] - getEarlierTime();
                var p2y = graphEngagement.get(graphEngagement_keys[i + 1]);
                graphEngagementObjects.push(new Line(D.ScreenX(p1x / 100), D.ScreenY(convertDilatationYtoDegree(p1y)), D.ScreenX(p2x / 100), D.ScreenY(convertDilatationYtoDegree(p2y)), "#FF0000", 2, ""));
            }
        } else {
            graphEngagement.each(function(index) {
                y = convertDilatationYtoDegree(index.value);
                x = index.key - getEarlierTime();
                graphEngagementObjects.push(new Dot(D.ScreenX(x / 100), D.ScreenY(y), 7, 18, '#FF0000', "dot"));
            });
        }
    }
    function clearGraphEngagement() {
        graphEngagementObjects.each(function(obj) {
            obj.Delete();
        });
        graphEngagementObjects.clear();
    }
    //------------------------------------------------ ACTION GRAPH ---------------------------------------//
    var divHeigth = $('glycemyGraph').style.height;
    function setGraphAction() {
        var graphAction_keys = graphAction.keys();
        var moreHeigth = 0;
        if (graphAction_keys.length > 0) {
            graphAction_keys.sort();
            var y = D.bottom;
            for (i = 0; i < graphAction_keys.length; i++) {
                var x = Math.floor(graphAction_keys[i].substring(0, graphAction_keys[i].length - 1) / 100);
                var l = graphAction.get(graphAction_keys[i]);
                if (i > 0 && Math.floor(graphAction_keys[i - 1].substring(0, graphAction_keys[i - 1].length - 1) / 100) == x) {
                    y = y + 15;
                    if (moreHeigth < y - D.bottom) {
                        moreHeigth = y - D.bottom;
                    }
                } else {
                    y = D.bottom;
                }
                var earlierTime = getEarlierTime();
                x -=(earlierTime.substring(0,earlierTime.length-2));
                graphActionObjects.push(new Bar(D.ScreenX(x + 0.2), y + 30, D.ScreenX(x + 0.8), y + 45, "#FFFF00", l, "#000"));
            }
        }
        $('glycemyGraph').style.height = parseInt(divHeigth.replace("px", "")) + moreHeigth;
    }
    function clearGraphAction() {
        graphActionObjects.each(function(obj) {
            obj.Delete();
        });
        graphActionObjects.clear();
    }

    setGraphAction();
    setGraphDilatation();
    setGraphEngagement();
    clearType2(document.getElementById("type_r2"));
    clearType3(document.getElementById("type_r3"));
    sReanimationDestination = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_REANIMATION_DESTINATION" property="value"/>";
    for (var n = 0; n < transactionForm.EditReanimationDestination.length; n++) {
        if (transactionForm.EditReanimationDestination.options[n].value == sReanimationDestination) {
            transactionForm.EditReanimationDestination.selectedIndex = n;
            break;
        }
    }

    function setTopUnits() {
        _BFont = "font-family:arial;font-size:6pt;font-weight:bold;";
        if (barTop!=undefined){
             barTop.each(function(obj){
               obj.Delete();
            });
        }

        barTop = new Array();
        var time = ($("beginHourSelect").value) + convertTimeToNbForGraph($("beginMinutSelect").value);
        if (earlierBackupTime != time) {
            earlierBackupTime = time;
        }

//        earlierBackupTime = $("ITEM_TYPE_DELIVERY_STARTHOUR").value;
        earlierBackupTime = ($("beginHourSelect").value) +":"+ convertTimeToNbForGraph($("beginMinutSelect").value);

        //----------------------- SET TOP UNITS -----------------//
        for (t = D.XGrid[0]; t <= D.XGrid[2]; t += 1) {
//            var h = parseInt(earlierBackupTime.substring(0, earlierBackupTime.length - 2));
  //          var m = earlierBackupTime.substring(earlierBackupTime.length - 2);

            var h = $("beginHourSelect").value;
            var m = $("beginMinutSelect").value;
//            var m = convertTimeToNbForGraph($("beginMinutSelect").value);

            if (t != D.XGrid[0]) {
                h = h*1+t;
                if (h > 23) {
                    h -= 24;
                }
            }
            barTop.push(new Bar(D.ScreenX(t) - 10, D.top - 20, D.ScreenX(t) + 5, D.top - 10, "", h + ":" + m + " &nbsp |", "#663300"));
        }
    }

    function setNewTime(){
        if (($("beginHourSelect").value.length>0)&&($("beginMinutSelect").value.length>0)){
            setTopUnits();
            clearGraphAction();
            setGraphAction();
            clearGraphDilatation();
            setGraphDilatation();
            clearGraphEngagement();
            setGraphEngagement();
        }
    }
</script>
<%=writeJSButtons("transactionForm", "saveButton")%>
<%
	}
catch(Exception e){
	e.printStackTrace();
}
%>