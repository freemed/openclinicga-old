<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.tracnet.suivi.arv","select",activeUser)%>
<%!
    private StringBuffer addSuivi(int iTotal,String sMolecule,String sDateBegin,String sDateEnd, String sReason, String sComment, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        String sTmpMolecule = "";

        if (sMolecule.length()>0){
            sTmpMolecule = getTran("tracnet.molecules",sMolecule,sWebLanguage);
        }

        String sTmpReason = "";

        if (sReason.length()>0){
            sTmpReason = getTran("tracnet.molecules.exitreasons",sReason,sWebLanguage);
        }
        sTmp.append("<tr id='rowSuivi"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteSuivi(rowSuivi"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editSuivi(rowSuivi"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpMolecule + "</td>")
             .append("<td class='admin2'>&nbsp;" +sDateBegin + "</td>")
             .append("<td class='admin2'>&nbsp;" + sDateEnd + "</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpReason + "</td>")
             .append("<td class='admin2'>&nbsp;" + sComment + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }

    private StringBuffer addSummary(int iTotal,String sMolecule,String sDateBegin,String sDateEnd, String sReason, String sComment, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        String sTmpMolecule = "";

        if (sMolecule.length()>0){
            sTmpMolecule = getTran("tracnet.other.molecules",sMolecule,sWebLanguage);
        }

        String sTmpReason = "";

        if (sReason.length()>0){
            sTmpReason = getTran("tracnet.molecules.exitreasons",sReason,sWebLanguage);
        }
        sTmp.append("<tr id='rowSummary"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteSummary(rowSummary"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editSummary(rowSummary"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpMolecule + "</td>")
             .append("<td class='admin2'>&nbsp;" +sDateBegin + "</td>")
             .append("<td class='admin2'>&nbsp;" + sDateEnd + "</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpReason + "</td>")
             .append("<td class='admin2'>&nbsp;" + sComment + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }
%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" cellspacing="1" cellpadding="0" id="tblSuivi" width="100%">
        <tr>
            <td class="admin" width="40"/>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.molecule.arv",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.date.begin",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.date.end",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.reason",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.comment",sWebLanguage)%></td>
            <td class="admin"/>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <select class="text" name="suiviMolecule">
                    <option/>
                    <%=ScreenHelper.writeSelect("tracnet.molecules","",sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2"><%=writeDateField("suiviDateBegin","transactionForm","",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("suiviDateEnd","transactionForm","",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="suiviReason">
                    <option/>
                    <%=ScreenHelper.writeSelect("tracnet.molecules.exitreasons","",sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="suiviComment"></textarea>
            </td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonAddSuivi" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSuivi();">
                <input type="button" class="button" name="ButtonUpdateSuivi" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateSuivi();">
            </td>
        </tr>
        <%
StringBuffer sDivSuivi = new StringBuffer(),
         sSuivi    = new StringBuffer();
int iSuiviTotal = 0;

if (transaction != null){
TransactionVO tran = (TransactionVO)transaction;
if (tran!=null){
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI1"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI2"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI3"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI4"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI5"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI6"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI7"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI8"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI9"));
    sSuivi.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI10"));
}

iSuiviTotal = 1;

if (sSuivi.indexOf("£")>-1){
    StringBuffer sTmpSuivi = sSuivi;
    String sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpReason, sTmpComment;
    sSuivi = new StringBuffer();

    while (sTmpSuivi.toString().toLowerCase().indexOf("$")>-1) {
        sTmpMolecule = "";
        sTmpDateBegin = "";
        sTmpDateEnd = "";
        sTmpReason = "";
        sTmpComment = "";

        if (sTmpSuivi.toString().toLowerCase().indexOf("£")>-1){
            sTmpMolecule = sTmpSuivi.substring(0,sTmpSuivi.toString().toLowerCase().indexOf("£"));
            sTmpSuivi = new StringBuffer(sTmpSuivi.substring(sTmpSuivi.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpSuivi.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateBegin = sTmpSuivi.substring(0,sTmpSuivi.toString().toLowerCase().indexOf("£"));
            sTmpSuivi = new StringBuffer(sTmpSuivi.substring(sTmpSuivi.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpSuivi.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateEnd = sTmpSuivi.substring(0,sTmpSuivi.toString().toLowerCase().indexOf("£"));
            sTmpSuivi = new StringBuffer(sTmpSuivi.substring(sTmpSuivi.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpSuivi.toString().toLowerCase().indexOf("£")>-1){
            sTmpReason = sTmpSuivi.substring(0,sTmpSuivi.toString().toLowerCase().indexOf("£"));
            sTmpSuivi = new StringBuffer(sTmpSuivi.substring(sTmpSuivi.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpSuivi.toString().toLowerCase().indexOf("$")>-1){
            sTmpComment = sTmpSuivi.substring(0,sTmpSuivi.toString().toLowerCase().indexOf("$"));
            sTmpSuivi = new StringBuffer(sTmpSuivi.substring(sTmpSuivi.toString().toLowerCase().indexOf("$")+1));
        }

        sSuivi.append("rowSuivi"+iSuiviTotal+"="+sTmpMolecule+"£"+sTmpDateBegin+"£"+sTmpDateEnd+"£"+sTmpReason+"£"+sTmpComment+"$");
        sDivSuivi.append(addSuivi(iSuiviTotal, sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpReason, sTmpComment, sWebLanguage));
        iSuiviTotal++;
    }
}
}
%>
        <%=sDivSuivi%>
    </table>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI1" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI2" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI3" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI4" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI5" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI6" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI7" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI8" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI9" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI10" property="itemId"/>]>.value">
    <br>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","tracnet.suivi.arv.program.exit",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DATE" property="value"/>" id="exit_date" OnBlur='checkDate(this)'>
                <script>writeMyDate("exit_date","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <br>
                <b><u><%=getTran("openclinic.chuk","tracnet.suivi.arv.exit.motif",sWebLanguage)%></u></b>
                <br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_TRANSFER")%> type="checkbox" id="cbexittransfer" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_TRANSFER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_TRANSFER;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.suivi.arv.exit.transfer",sWebLanguage,"cbexittransfer")%>
                <input type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_TRANSFER_TO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_TRANSFER_TO" property="value"/>"/>
                <br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DEATH")%> type="checkbox" id="cbexitdeath" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DEATH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DEATH;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.suivi.arv.exit.death",sWebLanguage,"cbexitdeath")%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DEATH_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_DEATH_DATE" property="value"/>" id="exit_death_date" OnBlur='checkDate(this)'>
                <script>writeMyDate("exit_death_date","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_NOT_SEEN")%> type="checkbox" id="cbexitnotseen" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_NOT_SEEN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_NOT_SEEN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.suivi.arv.exit.notseen",sWebLanguage,"cbexitnotseen")%>
                <br/><%=getTran("openclinic.chuk","tracnet.suivi.arv.exit.find.again",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_FIND_AGAIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_EXIT_FIND_AGAIN" property="value"/>" id="exit_find_again" OnBlur='checkDate(this)'>
                <script>writeMyDate("exit_find_again","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" cellspacing="1" cellpadding="0" id="tblSummary" width="100%">
        <tr class="admin">
            <td colspan="7"><%=getTran("openclinic.chuk","tracnet.suivi.arv.summary",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="40"/>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.molecule.arv",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.date.begin",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.date.end",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.summary.reason",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.suivi.arv.comment",sWebLanguage)%></td>
            <td class="admin"/>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2"><%=getTran("openclinic.chuk","tracnet.suivi.arv.molecule.cotrimoxazole",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_DATE_BEGIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_DATE_BEGIN" property="value"/>" id="cotr_date_begin" OnBlur='checkDate(this)'>
                <script>writeMyDate("cotr_date_begin","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_DATE_END" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_DATE_END" property="value"/>" id="cotr_date_end" OnBlur='checkDate(this)'>
                <script>writeMyDate("cotr_date_end","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_REASON" property="itemId"/>]>.value">
                    <option/>
                    <%
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        String sType = checkString(request.getParameter("type"));

                        if(sType.length() == 0){
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_REASON");
                            if (item!=null){
                                sType = checkString(item.getValue());
                            }
                        }
                    %>
                    <%=ScreenHelper.writeSelect("tracnet.molecules.exitreasons",sType,sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_COTRIMOXAZOLE_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin2"/>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2"><%=getTran("openclinic.chuk","tracnet.suivi.arv.molecule.dapsone",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_DATE_BEGIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_DATE_BEGIN" property="value"/>" id="dapsone_date_begin" OnBlur='checkDate(this)'>
                <script>writeMyDate("dapsone_date_begin","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_DATE_END" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_DATE_END" property="value"/>" id="dapsone_date_end" OnBlur='checkDate(this)'>
                <script>writeMyDate("dapsone_date_end","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_REASON" property="itemId"/>]>.value">
                    <option/>
                    <%
                        sType = checkString(request.getParameter("type"));

                        if(sType.length() == 0){
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_REASON");
                            if (item!=null){
                                sType = checkString(item.getValue());
                            }
                        }
                    %>
                    <%=ScreenHelper.writeSelect("tracnet.molecules.exitreasons",sType,sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_DAPSONE_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin2"/>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2"><%=getTran("openclinic.chuk","tracnet.suivi.arv.molecule.fluconazole",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_DATE_BEGIN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_DATE_BEGIN" property="value"/>" id="fluc_date_begin" OnBlur='checkDate(this)'>
                <script>writeMyDate("fluc_date_begin","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_DATE_END" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_DATE_END" property="value"/>" id="fluc_date_end" OnBlur='checkDate(this)'>
                <script>writeMyDate("fluc_date_end","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2">
                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_REASON" property="itemId"/>]>.value">
                    <option/>
                    <%
                        sType = checkString(request.getParameter("type"));

                        if(sType.length() == 0){
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_REASON");
                            if (item!=null){
                                sType = checkString(item.getValue());
                            }
                        }
                    %>
                    <%=ScreenHelper.writeSelect("tracnet.molecules.exitreasons",sType,sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_FLUCONAZOLE_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin2"/>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <select class="text" name="summaryMolecule">
                    <%=ScreenHelper.writeSelect("tracnet.other.molecules","",sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2"><%=writeDateField("summaryDateBegin","transactionForm","",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("summaryDateEnd","transactionForm","",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="summaryReason">
                    <option/>
                    <%=ScreenHelper.writeSelect("tracnet.molecules.exitreasons","",sWebLanguage,false,true)%>
                </select>
            </td>
            <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="summaryComment"></textarea></td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonAddSummary" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSummary();">
                <input type="button" class="button" name="ButtonUpdateSummary" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateSummary();">
            </td>
        </tr>
        <%
StringBuffer sDivSummary = new StringBuffer(),
         sSummary    = new StringBuffer();
int iSummaryTotal = 0;

if (transaction != null){
TransactionVO tran = (TransactionVO)transaction;
if (tran!=null){
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER1"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER2"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER3"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER4"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER5"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER6"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER7"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER8"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER9"));
    sSummary.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER10"));
}

iSummaryTotal = 1;

if (sSummary.indexOf("£")>-1){
    StringBuffer sTmpSummary = sSummary;
    String sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpReason, sTmpComment;
    sSummary = new StringBuffer();

    while (sTmpSummary.toString().toLowerCase().indexOf("$")>-1) {
        sTmpMolecule = "";
        sTmpDateBegin = "";
        sTmpDateEnd = "";
        sTmpReason = "";
        sTmpComment = "";

        if (sTmpSummary.toString().toLowerCase().indexOf("£")>-1){
            sTmpMolecule = sTmpSummary.substring(0,sTmpSummary.toString().toLowerCase().indexOf("£"));
            sTmpSummary = new StringBuffer(sTmpSummary.substring(sTmpSummary.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpSummary.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateBegin = sTmpSummary.substring(0,sTmpSummary.toString().toLowerCase().indexOf("£"));
            sTmpSummary = new StringBuffer(sTmpSummary.substring(sTmpSummary.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpSummary.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateEnd = sTmpSummary.substring(0,sTmpSummary.toString().toLowerCase().indexOf("£"));
            sTmpSummary = new StringBuffer(sTmpSummary.substring(sTmpSummary.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpSummary.toString().toLowerCase().indexOf("£")>-1){
            sTmpReason = sTmpSummary.substring(0,sTmpSummary.toString().toLowerCase().indexOf("£"));
            sTmpSummary = new StringBuffer(sTmpSummary.substring(sTmpSummary.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpSummary.toString().toLowerCase().indexOf("$")>-1){
            sTmpComment = sTmpSummary.substring(0,sTmpSummary.toString().toLowerCase().indexOf("$"));
            sTmpSummary = new StringBuffer(sTmpSummary.substring(sTmpSummary.toString().toLowerCase().indexOf("$")+1));
        }

        sSummary.append("rowSummary"+iSummaryTotal+"="+sTmpMolecule+"£"+sTmpDateBegin+"£"+sTmpDateEnd+"£"+sTmpReason+"£"+sTmpComment+"$");
        sDivSummary.append(addSummary(iSummaryTotal, sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpReason, sTmpComment, sWebLanguage));
        iSummaryTotal++;
    }
}
}
%>
        <%=sDivSummary%>
    </table>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER1" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER2" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER3" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER4" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER5" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER6" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER7" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER8" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER9" property="itemId"/>]>.value">
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER10" property="itemId"/>]>.value">
    <br>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
<%-- BUTTONS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2"><%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnet.suivi.arv",sWebLanguage)%></td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  var iSuiviIndex = <%=iSuiviTotal%>;
  var sSuivi = "<%=sSuivi%>";
  var editSuiviRowid = "";

  var iSummaryIndex = <%=iSummaryTotal%>;
  var sSummary = "<%=sSummary%>";
  var editSummaryRowid = "";

  function submitForm(){
    var maySubmit = true;

    if (isAtLeastOneSuiviFieldFilled()) {
      if (maySubmit) {
        if (!addSuivi()) {
          maySubmit = false;
        }
      }
    }

    var sTmpBegin, sTmpEnd;
    while (sSuivi.indexOf("rowSuivi") > -1) {
      sTmpBegin = sSuivi.substring(sSuivi.indexOf("rowSuivi"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
      sSuivi = sSuivi.substring(0, sSuivi.indexOf("rowSuivi")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI1" property="itemId"/>]>.value")[0].value = sSuivi.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI2" property="itemId"/>]>.value")[0].value = sSuivi.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI3" property="itemId"/>]>.value")[0].value = sSuivi.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI4" property="itemId"/>]>.value")[0].value = sSuivi.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI5" property="itemId"/>]>.value")[0].value = sSuivi.substring(1016,1270);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI6" property="itemId"/>]>.value")[0].value = sSuivi.substring(1270,1524);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI7" property="itemId"/>]>.value")[0].value = sSuivi.substring(1524,1778);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI8" property="itemId"/>]>.value")[0].value = sSuivi.substring(1778,2032);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI9" property="itemId"/>]>.value")[0].value = sSuivi.substring(2032,2286);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUIVI10" property="itemId"/>]>.value")[0].value = sSuivi.substring(2286,2540);

    if (isAtLeastOneSummaryFieldFilled()) {
      if (maySubmit) {
        if (!addSummary()) {
          maySubmit = false;
        }
      }
    }
      while (sSummary.indexOf("rowSummary") > -1) {
        sTmpBegin = sSummary.substring(sSummary.indexOf("rowSummary"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sSummary = sSummary.substring(0, sSummary.indexOf("rowSummary")) + sTmpEnd;
      }

      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER1" property="itemId"/>]>.value")[0].value = sSummary.substring(0,254);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER2" property="itemId"/>]>.value")[0].value = sSummary.substring(254,508);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER3" property="itemId"/>]>.value")[0].value = sSummary.substring(508,762);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER4" property="itemId"/>]>.value")[0].value = sSummary.substring(762,1016);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER5" property="itemId"/>]>.value")[0].value = sSummary.substring(1016,1270);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER6" property="itemId"/>]>.value")[0].value = sSummary.substring(1270,1524);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER7" property="itemId"/>]>.value")[0].value = sSummary.substring(1524,1778);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER8" property="itemId"/>]>.value")[0].value = sSummary.substring(1778,2032);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER9" property="itemId"/>]>.value")[0].value = sSummary.substring(2032,2286);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_SUIVI_ARV_SUMMARY_OTHER10" property="itemId"/>]>.value")[0].value = sSummary.substring(2286,2540);

    if(maySubmit){
         document.transactionForm.saveButton.style.visibility = "hidden";
        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
        document.transactionForm.submit();
    }
  }

  function addSuivi(){
    if(isAtLeastOneSuiviFieldFilled()){
      iSuiviIndex++;

      sSuivi+="rowSuivi"+iSuiviIndex+"="+transactionForm.suiviMolecule.value+"£"
              +transactionForm.suiviDateBegin.value+"£"
              +transactionForm.suiviDateEnd.value+"£"
              +transactionForm.suiviReason.value+"£"
              +transactionForm.suiviComment.value+"$";
      var tr;
      tr = tblSuivi.insertRow(tblSuivi.rows.length);
      tr.id = "rowSuivi"+iSuiviIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteSuivi(rowSuivi"+iSuiviIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editSuivi(rowSuivi"+iSuiviIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.suiviMolecule.options[transactionForm.suiviMolecule.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.suiviDateBegin.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.suiviDateEnd.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.suiviReason.options[transactionForm.suiviReason.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.suiviComment.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSuiviFields()
      transactionForm.ButtonUpdateSuivi.disabled = true;
    }
    return true;
  }

  function updateSuivi(){
    if(isAtLeastOneSuiviFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editSuiviRowid.id+"="+transactionForm.suiviMolecule.value+"£"
               +transactionForm.suiviDateBegin.value+"£"
               +transactionForm.suiviDateEnd.value+"£"
               +transactionForm.suiviReason.value+"£"
               +transactionForm.suiviComment.value;

      sSuivi = replaceRowInArrayString(sSuivi,newRow,editSuiviRowid.id);

      <%-- update table object --%>
      row = tblSuivi.rows[editSuiviRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteSuivi("+editSuiviRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editSuivi("+editSuiviRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.suiviMolecule.options[transactionForm.suiviMolecule.selectedIndex].text;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.suiviDateBegin.value;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.suiviDateEnd.value;
      row.cells[4].innerHTML = "&nbsp;"+transactionForm.suiviReason.options[transactionForm.suiviReason.selectedIndex].text;
      row.cells[5].innerHTML = "&nbsp;"+transactionForm.suiviComment.value;

      setCellStyle(row);

      <%-- reset --%>
      clearSuiviFields();
      transactionForm.ButtonUpdateSuivi.disabled = true;
    }
  }

  function isAtLeastOneSuiviFieldFilled(){
    if(transactionForm.suiviMolecule.value != "")        return true;
    if(transactionForm.suiviDateBegin.value != "")       return true;
    if(transactionForm.suiviDateEnd.value != "")       return true;
    if(transactionForm.suiviReason.value != "")       return true;
    if(transactionForm.suiviComment.value != "")       return true;
    return false;
  }

  function clearSuiviFields(){
    transactionForm.suiviMolecule.selectedIndex = -1;
    transactionForm.suiviDateBegin.value = "";
    transactionForm.suiviDateEnd.value = "";
    transactionForm.suiviReason.selectedIndex = -1;
    transactionForm.suiviComment.value = "";
  }

  function deleteSuivi(rowid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    var answer;
    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,"",modalitiesIE);
    }
    else{
      answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      sSuivi = deleteRowFromArrayString(sSuivi,rowid.id);
      tblSuivi.deleteRow(rowid.rowIndex);
      clearSuiviFields();
    }
  }

  function editSuivi(rowid){
    var row = getRowFromArrayString(sSuivi,rowid.id);
    transactionForm.suiviMolecule.value = getCelFromRowString(row,0);
    transactionForm.suiviDateBegin.value = getCelFromRowString(row,1);
    transactionForm.suiviDateEnd.value = getCelFromRowString(row,2);
    transactionForm.suiviReason.value = getCelFromRowString(row,3);
    transactionForm.suiviComment.value = getCelFromRowString(row,4);

    editSuiviRowid = rowid;
    transactionForm.ButtonUpdateSuivi.disabled = false;
  }




  function addSummary(){
    if(isAtLeastOneSummaryFieldFilled()){
      iSummaryIndex++;

      sSummary+="rowSummary"+iSummaryIndex+"="+transactionForm.summaryMolecule.value+"£"
              +transactionForm.summaryDateBegin.value+"£"
              +transactionForm.summaryDateEnd.value+"£"
              +transactionForm.summaryReason.value+"£"
              +transactionForm.summaryComment.value+"$";
      var tr;
      tr = tblSummary.insertRow(tblSummary.rows.length);
      tr.id = "rowSummary"+iSummaryIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteSummary(rowSummary"+iSummaryIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editSummary(rowSummary"+iSummaryIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.summaryMolecule.options[transactionForm.summaryMolecule.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.summaryDateBegin.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.summaryDateEnd.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.summaryReason.options[transactionForm.summaryReason.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.summaryComment.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSummaryFields()
      transactionForm.ButtonUpdateSummary.disabled = true;
    }
    return true;
  }

  function updateSummary(){
    if(isAtLeastOneSummaryFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editSummaryRowid.id+"="+transactionForm.summaryMolecule.value+"£"
               +transactionForm.summaryDateBegin.value+"£"
               +transactionForm.summaryDateEnd.value+"£"
               +transactionForm.summaryReason.value+"£"
               +transactionForm.summaryComment.value;

      sSummary = replaceRowInArrayString(sSummary,newRow,editSummaryRowid.id);

      <%-- update table object --%>
      row = tblSummary.rows[editSummaryRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteSummary("+editSummaryRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editSummary("+editSummaryRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.summaryMolecule.options[transactionForm.summaryMolecule.selectedIndex].text;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.summaryDateBegin.value;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.summaryDateEnd.value;
      row.cells[4].innerHTML = "&nbsp;"+transactionForm.summaryReason.options[transactionForm.summaryReason.selectedIndex].text;
      row.cells[5].innerHTML = "&nbsp;"+transactionForm.summaryComment.value;

      setCellStyle(row);

      <%-- reset --%>
      clearSummaryFields();
      transactionForm.ButtonUpdateSummary.disabled = true;
    }
  }

  function isAtLeastOneSummaryFieldFilled(){
    if(transactionForm.summaryMolecule.value != "")        return true;
    if(transactionForm.summaryDateBegin.value != "")       return true;
    if(transactionForm.summaryDateEnd.value != "")       return true;
    if(transactionForm.summaryReason.value != "")       return true;
    if(transactionForm.summaryComment.value != "")       return true;
    return false;
  }

  function clearSummaryFields(){
    transactionForm.summaryMolecule.selectedIndex = 0;
    transactionForm.summaryDateBegin.value = "";
    transactionForm.summaryDateEnd.value = "";
    transactionForm.summaryReason.selectedIndex = 0;
    transactionForm.summaryComment.value = "";
  }

  function deleteSummary(rowid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    var answer;
    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,"",modalitiesIE);
    }
    else{
      answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      sSummary = deleteRowFromArrayString(sSummary,rowid.id);
      tblSummary.deleteRow(rowid.rowIndex);
      clearSummaryFields();
    }
  }

  function editSummary(rowid){
    var row = getRowFromArrayString(sSummary,rowid.id);
    transactionForm.summaryMolecule.value = getCelFromRowString(row,0);
    transactionForm.summaryDateBegin.value = getCelFromRowString(row,1);
    transactionForm.summaryDateEnd.value = getCelFromRowString(row,2);
    transactionForm.summaryReason.value = getCelFromRowString(row,3);
    transactionForm.summaryComment.value = getCelFromRowString(row,4);

    editSummaryRowid = rowid;
    transactionForm.ButtonUpdateSummary.disabled = false;
  }

<%-- SET CELL STYLE --%>
  function setCellStyle(row){
    for(var i=0; i<row.cells.length; i++){
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

  <%-- GENERAL FUNCTIONS ------------------------------------------------------------------------%>
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

    return array.join("$");
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>
