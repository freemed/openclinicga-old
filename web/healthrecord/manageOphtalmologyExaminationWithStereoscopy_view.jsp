<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.ophtalmology","select",activeUser)%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

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

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
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
    <%=contextHeader(request,sWebLanguage)%>

    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="30%">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- AV --%>
        <tr>
            <td class="admin">
                <a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyAV_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%></a>
            </td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_AV_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- STEREO --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyStereo_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.stereoscopie",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_STEREO_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- COLOR --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyColor_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.couleurs",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_COLOR_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- PERI --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyPeri_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.vision-peripherique",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_PERI_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- MESO --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyMeso_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.vision-mesopique",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>

        <%-- SCREEN --%>
        <tr>
            <td class="admin"><a href="javascript:subScreen('/main.do?Page=healthrecord/manageOphtalmologyScreen_view.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.workers-on-screen",sWebLanguage)%></a></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.not-executed",sWebLanguage)%>&nbsp;<input disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_SCREEN_RAS;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>
    </table>

    <%-- BUTTONS ---------------------------------------------------------------------------------%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%
            if(activeUser.accessRights.get("occup?ophtalmology.add")!=null || activeUser.accessRights.get("occup.ophtalmology.edit")!=null) {
            %>
                <INPUT class="button" type="button" name="save" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
            <%
            }
        %>
        <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>'">
        <%=writeResetButton("transactionForm",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function doSubmit(){
    document.transactionForm.save.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  function subScreen(screenName){
    document.all['be.mxs.healthrecord.updateTransaction.actionForwardKey'].value=screenName;
    document.transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","document.all['save']")%>
