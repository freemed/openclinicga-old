<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%%>

 <bean:define id="vaccinationInfo" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO"/>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.itemId" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>"/>
    <input type="hidden" id="vaccination-type" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value" translate="false"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/showVaccinationSummary.do?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.creationDate" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="creationDate" formatType="date" format="dd-mm-yyyy"/>">

<%
    String sSelect, sTransaction, sValue, sType;
    SortedMap hVaccins = new TreeMap();
    Hashtable hData = new Hashtable();
    String sVaccinationType = checkString(request.getParameter("VaccinType"));
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    sSelect = "SELECT i2.* FROM Healthrecord h, Transactions t, Items i, Items i2" +
            " WHERE h.personId = " + activePatient.personid +
            "  AND t.healthRecordId = h.healthRecordId" +
            "  AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION'" +
            "  AND i.transactionId = t.transactionId" +
            "  AND i.serverid = t.serverid" +
            "  AND i2.transactionId = t.transactionId" +
            "  AND i2.serverid = t.serverid" +
            "  AND i.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE'" +
            "  AND i.value = '" + sVaccinationType + "'" +
            " ORDER BY i2.transactionId, i2.serverid";

    Connection OccupdbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
    PreparedStatement ps = OccupdbConnection.prepareStatement(sSelect);
    ResultSet rs = ps.executeQuery();
    String activeTransaction = "";
    Integer transactionId, activeTransactionId = null, serverId;

    while (rs.next()) {
        sValue = rs.getString("value");
        sType = rs.getString("type");
        serverId = new Integer(rs.getInt("serverid"));
        transactionId = new Integer(rs.getInt("transactionId"));
        sTransaction = transactionId + "." + serverId;

        if (!activeTransaction.equalsIgnoreCase(sTransaction)) {
            if (activeTransaction.length() > 0) {
                hVaccins.put(new Long(stdDateFormat.parse((String) hData.get("date")).getTime() + activeTransactionId.intValue()), hData);
                if (Debug.enabled) {
                    Debug.println("stored " + stdDateFormat.parse((String) hData.get("date")).getTime() + " + " + activeTransactionId.intValue());
                }
            }

            activeTransaction = sTransaction;
            activeTransactionId = transactionId;
            hData = new Hashtable();
            hData.put("serverid", serverId);
            hData.put("transactionid", transactionId);
        }

        if (sType.equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS")) {
            hData.put("status", sValue);
        }
        if (sType.equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE")) {
            hData.put("date", sValue);
        }
        if (sType.equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE")) {
            hData.put("nextdate", sValue);
        }
        if (sType.equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME")) {
            hData.put("name", sValue);
        }
        if (sType.equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT")) {
            hData.put("comment", sValue);
        }
    }

    if (activeTransaction.length() > 0) {
        hVaccins.put(new Long(stdDateFormat.parse((String) hData.get("date")).getTime() + activeTransactionId.intValue()), hData);
        if (Debug.enabled) {
            Debug.println("stored " + stdDateFormat.parse((String) hData.get("date")).getTime() + " + " + activeTransactionId.intValue());
        }
    }

    rs.close();
    ps.close();
    OccupdbConnection.close();
%>

<table class="list" width="100%" cellspacing="0">
    <%-- PAGE TITLE --%>
    <tr class="admin">
        <td colspan="3"><%=getTran("Web.Occup","history",sWebLanguage)%></td>
        <td align="right"><a href="javascript:history.go(-1);return false;"><img border="0" src='<c:url value="/_img/previous.jpg"/>'></a></td>
    </tr>

    <%-- HEADER --%>
    <tr class="label">
        <td width="25%"><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.status",sWebLanguage).toUpperCase()%></td>
        <td width="25%"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage).toUpperCase()%></td>
        <td width="25%"><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.next-date",sWebLanguage).toUpperCase()%></td>
        <td width="25%"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage).toUpperCase()%></td>
    </tr>

    <%
        String sStatus, sDate, sNextDate, sName, sClass = "", sComment;
        Long lId;
        Iterator e = hVaccins.keySet().iterator();
        while (e.hasNext()) {
            lId = (Long)e.next();
            hData = (Hashtable)hVaccins.get(lId);
            sStatus = checkString((String)hData.get("status"));
            sComment = checkString((String)hData.get("comment"));
            serverId = (Integer)hData.get("serverid");
            transactionId = (Integer)hData.get("transactionid");
            sName = checkString((String)hData.get("name"));

            sDate = checkString((String)hData.get("date"));
            if (sDate.indexOf("-")>0) {
                sDate = sDate.replace('-','/');
            }

            sNextDate = checkString((String)hData.get("nextdate"));
            if (sNextDate.indexOf("-") > 0) {
                sNextDate = sNextDate.replace('-','/');
            }

            // alternate row-style
            if(sClass.equals("")) sClass = " class='list'";
            else                  sClass = "";

            %>
                <tr<%=sClass%>>
                    <td><%=getTran("Web.Occup",sStatus,sWebLanguage)%></td>
                    <td><a href="<c:url value='/healthrecord/manageVaccination.do'/>?be.mxs.healthrecord.transaction_id=<%=transactionId%>&be.mxs.healthrecord.server_id=<%=serverId%>&ts=<%=getTs()%>"><%=sDate%></a></td>
                    <td><%=sNextDate%></td>
                    <td><%=sName%><%=sComment.length()>0?" ("+getTran("Web.Occup",sComment,sWebLanguage)+")":""%></td>
                </tr>
            <%
        }
    %>
</table>

<%-- BUTTONS --%>
<p align="right">
    <input class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.back",sWebLanguage)%>" onclick="history.go(-1);return false;">
</p>

