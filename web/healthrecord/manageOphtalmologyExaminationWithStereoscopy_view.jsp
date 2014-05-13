<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occupophtalmology","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS" property="itemId"/>]>.value" value='<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS" translate="false" property="value"/>'/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS" translate="false"  property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_PERI_RAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_PERI_RAS" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS" translate="false" property="value"/>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/occupationalmedicine/managePeriodicExaminations.do?ts=<%=getTs()%>"/>
    <input type="hidden" name="subClass" value="GENERAL"/>

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

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage,activeUser)%>

    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="30%">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("web.occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("web","date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- AV --%>
        <tr>
            <td class="admin">
                <a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyAV_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%></a>
            </td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- STEREO --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyStereo_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.stereoscopie",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- COLOR --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyColor_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.couleurs",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- PERI --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyPeri_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.vision-peripherique",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_PERI_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- MESO --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyMeso_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.vision-mesopique",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- SCREEN --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page=manageOphtalmologyScreen_view.jsp&ts=<%=getTs()%>');"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.workers-on-screen",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <p align="right">
        <%
            if(activeUser.hasAccessRight("occupophtalmology.add") || activeUser.hasAccessRight("occupophtalmology.edit")){
                %><input class="button" type="button" name="saveButton" onClick="doSubmit();" value="<%=getTranNoLink("web","save",sWebLanguage)%>"><%
            }
        %>
        <input class="button" type="button" value="<%=getTranNoLink("web","Back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/occupationalmedicine/managePeriodicExaminations.do'/>?ts=<%=getTs()%>'">
        <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
    </p>

    <%=contextFooter(request)%>
</form>

<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.println(takeOverTransaction(sessionContainerWO, activeUser,"transactionForm.submit();"));
    %>
  }

  function subScreen(screenName){
    document.all['be.mxs.healthrecord.updateTransaction.actionForwardKey'].value=screenName;
    transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","document.all['save']")%>
