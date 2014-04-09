<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.kinesitherapy.consultation.treatment","select",activeUser)%>
<%!
    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    private StringBuffer addSeance(int iTotal,String sDate,String sHour,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowSeance"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='#' onclick='deleteSeance(rowSeance"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='#' onclick='editSeance(rowSeance"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sDate + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sHour + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <%
        StringBuffer sDivSeances   = new StringBuffer();
        StringBuffer sSeances      = new StringBuffer();
        String[] sAct              = new String[9];
        String sActAutre           = "";
        String sDiagnosisCode      = "";
        String sDiagnosisCodeType  = "";
        String sDiagnosisCodeLabel = "";
        String sStartDate          = "";
        String sEndDate            = "";

        int iSeancesTotal = 0;

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                sSeances.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1"));
                sSeances.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2"));
                sSeances.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3"));
                sSeances.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4"));
                sSeances.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5"));

                sAct[0] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT1");
                sAct[1] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT2");
                sAct[2] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT3");
                sAct[3] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT4");
                sAct[4] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT5");
                sAct[5] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT6");
                sAct[6] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT7");
                sAct[7] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT8");
                sAct[8] = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT9");
                sActAutre = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE");

                sDiagnosisCode = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS_CODE");
                if(sDiagnosisCode.length() > 1){
                    String sSplit[] = sDiagnosisCode.split("£");
                    sDiagnosisCode = sSplit[0];
                    sDiagnosisCodeType = sSplit[1];
                }

                sStartDate = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE");
                sEndDate   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE");
            }
        }

        if(sDiagnosisCode.length() > 0 && sDiagnosisCodeType.length() > 0){
            sDiagnosisCodeLabel = checkString(MedwanQuery.getInstance().getCodeTran(sDiagnosisCodeType + "code" + sDiagnosisCode, sWebLanguage));
        }

        iSeancesTotal = 1;

        if (sSeances.indexOf("£")>-1){
            StringBuffer sTmpSeances = sSeances;
            String sTmpDate,sTmpHeure;
            sSeances = new StringBuffer();

            while (sTmpSeances.toString().toLowerCase().indexOf("$")>-1) {
                sTmpDate  = "";
                sTmpHeure = "";

                if (sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSeances.toString().toLowerCase().indexOf("$")>-1){
                    sTmpHeure = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("$"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("$")+1));
                }

                sSeances.append("rowSeance"+iSeancesTotal+"="+sTmpDate+"£"+sTmpHeure+"$");
                sDivSeances.append(addSeance(iSeancesTotal, sTmpDate, sTmpHeure, sWebLanguage));
                iSeancesTotal++;
            }
        }
    %>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="5">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","context",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input id="rbcontextconsultation" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT")%>  onDblClick="uncheckRadio(this);"type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT;value=kine.treatment.consultation" property="value" outputString="checked"/> value="kine.treatment.consultation"/>
                &nbsp;<%=getLabel("web.occup","kine.treatment.consultation",sWebLanguage,"rbcontextconsultation")%>
                &nbsp;<input id="rbcontexthospitalized" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT")%>  onDblClick="uncheckRadio(this);"type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT;value=kine.treatment.hospitalized" property="value" outputString="checked"/> value="kine.treatment.hospitalized"/>
                &nbsp;<%=getLabel("web.occup","kine.treatment.hospitalized",sWebLanguage,"rbcontexthospitalized")%>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","diagnosis",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS"property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS" property="value"/></textarea>
                <br/>
                <%=getTran("openclinic.chuk","diagnosis.code",sWebLanguage)%>
                <input class="text" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS_CODE")%> type="text" name="DiagnosisCodeLabel" value="<%=sDiagnosisCode%> <%=sDiagnosisCodeLabel%>" readonly size="100">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('transactionForm.DiagnosisCode','transactionForm.DiagnosisCodeLabel','transactionForm.DiagnosisCodeType');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.DiagnosisCode.value='';transactionForm.DiagnosisCodeLabel.value='';transactionForm.DiagnosisCodeType.value='';">
                <input type="hidden" name="DiagnosisCode" value="<%=sDiagnosisCode%>">
                <input type="hidden" name="DiagnosisCodeType" value="<%=sDiagnosisCodeType%>">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS_CODE" property="itemId"/>]>.value"/>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","treatment",sWebLanguage)%>
            </td>
            <td class="admin2">
                <table class="list" cellspacing="1" cellpadding="0" width="50%">
                    <tr>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT1")%> type="checkbox" id="acte1"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT1;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte1">acte1</label></td>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT6")%> type="checkbox" id="acte6"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT6;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte6">acte6</label></td>
                    </tr>
                    <tr>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT2")%> type="checkbox" id="acte2"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT2;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte2">acte2</label></td>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT7")%> type="checkbox" id="acte7"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT7;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte7">acte7</label></td>
                    </tr>
                    <tr>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT3")%> type="checkbox" id="acte3"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT3;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte3">acte3</label></td>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT8")%> type="checkbox" id="acte8"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT8;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte8">acte8</label></td>
                    </tr>
                    <tr>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT4")%> type="checkbox" id="acte4"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT4;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte4">acte4</label></td>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT9")%> type="checkbox" id="acte9"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT9" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT9;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte9">acte9</label></td>
                    </tr>
                    <tr>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT5")%> type="checkbox" id="acte5"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT5;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="acte5">acte5</label></td>
                        <td class="admin2"><input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE")%> type="checkbox" id="autre"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="autre">autre</label></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","nr.of.meetings",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","startdate",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE")%> type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE" property="itemId"/>]>.value" value="<%=sStartDate%>" id="startdate" OnBlur='checkDate(this)'>
                <script>writeMyDate("startdate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","date.seances",sWebLanguage)%>
            </td>
            <td class="admin2">
                <table class="list" cellspacing="1" cellpadding="0" width="50%" id="tblSeances">
                    <tr>
                        <td class="admin" width="40px"/>
                        <td class="admin"><%=getTran("Web.occup","medwan.common.date",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin"></td>
                        <td/>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="text" class="text" size="12" maxLength="10" name="seanceDate" value="" OnBlur='checkDate(this)'>
                            <script>writeMyDate("seanceDate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="5" name="seanceHour" value="" onblur="checkTime(this);">
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddSeance" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSeance();">
                            <input type="button" class="button" name="ButtonUpdateSeance" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateSeance();">
                        </td>
                    </tr>
                    <%=sDivSeances%>
                </table>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5" property="itemId"/>]>.value">
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","enddate",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE")%> type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE" property="itemId"/>]>.value" value="<%=sEndDate%>" id="enddate" OnBlur='checkDate(this)'>
                <script>writeMyDate("enddate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","conclusion",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","reference",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input id="rbrefyes" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE")%>  onDblClick="uncheckRadio(this);" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"/>
                &nbsp;<%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"rbrefyes")%>
                &nbsp;<input id="rbrefno" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"/>
                &nbsp;<%=getLabel("web.occup","medwan.common.no",sWebLanguage,"rbrefno")%>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","remarks",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%-- BUTTONS --%>
                <%
                  if (activeUser.getAccessRight("occup.kinesitherapy.consultation.treatment.add") || activeUser.getAccessRight("occup.kinesitherapy.consultation.treatment.edit")){
                %>
                            <INPUT class="button" type="button" name="saveButton" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
                <%
                  }
                %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton())){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>

</form>
<script>
var iSeancesIndex = <%=iSeancesTotal%>;
var sSeances = "<%=sSeances%>";
var editSeancesRowid = "";

<%
    for(int i = 0; i <9; i++){
        %>
        if("<%=sAct[i]%>" == "medwan.true"){
            transactionForm.acte<%=i+1%>.checked = true;
        }
        <%
    }
%>
    if("<%=sActAutre%>" == "medwan.true"){
        transactionForm.autre.checked = true;
    }

<!-- SEANCES -->

function addSeance(){
  if(isAtLeastOneSeanceFieldFilled()){
      iSeancesIndex++;

      sSeances+="rowSeance"+iSeancesIndex+"="+transactionForm.seanceDate.value+"£"
                                             +transactionForm.seanceHour.value+"$";
      var tr;
      tr = tblSeances.insertRow(tblSeances.rows.length);
      tr.id = "rowSeance"+iSeancesIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='#' onclick='deleteSeance(rowSeance"+iSeancesIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='#' onclick='editSeance(rowSeance"+iSeancesIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.seanceDate.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.seanceHour.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSeanceFields()
      transactionForm.ButtonUpdateSeance.disabled = true;
  }
  return true;
}

function updateSeance(){
  if(isAtLeastOneSeanceFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
      
    newRow = editSeancesRowid.id+"="+transactionForm.seanceDate.value+"£"
                                    +transactionForm.seanceHour.value;

    //alert("Before replace: " + sSeances);
    //alert("newRow: " + newRow);
    sSeances = replaceRowInArrayString(sSeances,newRow,editSeancesRowid.id);
    //alert("After replace: " + sSeances);
    //alert("editTeethRowid: " + editSeancesRowid.id);

//      sSeances = replaceRowInArrayString(sSeances,newRow,editSeancesRowid.id);

    <%-- update table object --%>
    var row = tblSeances.rows[editSeancesRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteSeance("+editSeancesRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editSeance("+editSeancesRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.seanceDate.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.seanceHour.value;

    setCellStyle(row);
    <%-- reset --%>
    clearSeanceFields();
    transactionForm.ButtonUpdateSeance.disabled = true;
  }
}

function isAtLeastOneSeanceFieldFilled(){
  if(transactionForm.seanceDate.value != "")       return true;
  if(transactionForm.seanceHour.value != "")        return true;
  return false;
}

function clearSeanceFields(){
  transactionForm.seanceDate.value = "";
  transactionForm.seanceHour.value = "";
}

function deleteSeance(rowid){
  var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
  var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

  var answer;
  if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,'',modalitiesIE);
  }else{
      answer = window.confirm("<%=getTran("web","areyousuretodelete",sWebLanguage)%>");
  }

  if(answer==1){
    sSeances = deleteRowFromArrayString(sSeances,rowid.id);
    tblSeances.deleteRow(rowid.rowIndex);
    clearSeanceFields();
  }
}

function editSeance(rowid){
  var row = getRowFromArrayString(sSeances,rowid.id);
  transactionForm.seanceDate.value = getCelFromRowString(row,0);
  transactionForm.seanceHour.value = getCelFromRowString(row,1);

  editSeancesRowid = rowid;
  transactionForm.ButtonUpdateSeance.disabled = false;
}

<!-- GENERAL FUNCTIONS -->
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
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
    //alert("1: " + array);
    var result = array.join("$");
    //alert("2: " + array);
    return result;//.substring(0, result.length - 1);
}

function submitForm() {
    var maySubmit = true;

    if (isAtLeastOneSeanceFieldFilled()) {
        if (maySubmit) {
            if (!addSeance()) {
                maySubmit = false;
            }
        }
    }

    var sTmpBegin;
    var sTmpEnd;

    while (sSeances.indexOf("rowSeance") > -1) {
        sTmpBegin = sSeances.substring(sSeances.indexOf("rowSeance"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sSeances = sSeances.substring(0, sSeances.indexOf("rowSeance")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1" property="itemId"/>]>.value")[0].value = sSeances.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2" property="itemId"/>]>.value")[0].value = sSeances.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3" property="itemId"/>]>.value")[0].value = sSeances.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4" property="itemId"/>]>.value")[0].value = sSeances.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5" property="itemId"/>]>.value")[0].value = sSeances.substring(1016, 1270);

    if(transactionForm.DiagnosisCode.value.length > 0 && transactionForm.DiagnosisCodeType.value.length >0){
        document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_DIAGNOSIS_CODE" property="itemId"/>]>.value")[0].value = transactionForm.DiagnosisCode.value + "£" + transactionForm.DiagnosisCodeType.value;
    }

    if(maySubmit){
      transactionForm.saveButton.disabled = true;
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
}

function setCellStyle(row){
    for(var i =0;i<row.cells.length;i++){
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

function searchICPC(code,codelabel,codetype){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField=" + code + "&returnField2=" + codelabel + "&returnField3=" + codetype + "&ListChoice=FALSE");
}
</script>