<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.ophtalmology.consultation","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST" translate="false"  property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION" property="itemId"/>]>.value" value='<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION" translate="false" property="value"/>'/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/occupationalmedicine/managePeriodicExaminations.do?ts=<%=getTs()%>"/>
    <input type="hidden" name="subClass" value="GENERAL"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <%
        // use template ? (yes by default)
        String useTemplate = checkString(request.getParameter("useTemplate"));
        if(useTemplate.length() == 0) useTemplate = "yes";
    %>
    <table class="list" width="100%" cellspacing="1">
        <%-- VISIOTEST ---------------------------------------------------------------------------%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
            <%
                String sVisiotest = "";
                TransactionVO transactionVO = (TransactionVO)transaction;
                if (transactionVO!=null){
                    ItemVO itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST");
                    if (itemVO!=null){
                        sVisiotest = checkString(itemVO.getValue());
                    }
                }

                // link
                if(sVisiotest.equalsIgnoreCase("medwan.common.true") || ((transactionVO!=null) && (transactionVO.getTransactionId().intValue()<0))){
                    if(useTemplate.equalsIgnoreCase("yes")){
                    %>
                        <a href="javascript:subScreen('cbVisiotest','/healthrecord/template.jsp?Page=manageOphtalmologyVisiotest.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');">
                            <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage)%>
                        </a>
                    <%
                    }
                    else{
                    %>
                        <a href="javascript:forward('cbVisiotest','/healthrecord/viewTransaction.jsp?Page=manageOphtalmologyVisiotest.jsp&historyBack=2&be.mxs.healthrecord.transaction_id=<%=transactionVO.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transactionVO.getServerId()%>&ts=<%=getTs()%>');">
                            <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage)%>
                        </a>
                    <%
                    }
                }
                // no link
                else {
                %>
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage)%>
                <%
                }
            %>
            </td>
            <%-- executed checkbox --%>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.executed",sWebLanguage)%>
                <input id="cbVisiotest" disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>
        <%-- ERGOVISION --------------------------------------------------------------------------%>
        <tr>
            <td class="admin">
            <%
                String sErgovision = "";
                if (transactionVO!=null){
                    ItemVO itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION");
                    if (itemVO!=null){
                        sErgovision = checkString(itemVO.getValue());
                    }
                }

                // link
                if(sErgovision.equalsIgnoreCase("medwan.common.true") || ((transactionVO!=null) && (transactionVO.getTransactionId().intValue()<0))){
                    if(useTemplate.equalsIgnoreCase("yes")){
                    %>
                        <a href="javascript:subScreen('cbErgovision','/main.do?Page=/healthrecord/manageOphtalmologyErgovision.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');">
                            <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.ergovision",sWebLanguage)%>
                        </a>
                    <%
                    }
                    else{
                    %>
                        <a href="javascript:forward('cbErgovision','/main.do?Page=/healthrecord/manageOphtalmologyErgovision.jsp&historyBack=2&be.mxs.healthrecord.transaction_id=<%=transactionVO.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transactionVO.getServerId()%>&ts=<%=getTs()%>');">
                            <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.ergovision",sWebLanguage)%>
                        </a>
                    <%
                    }
                }
                // no link
                else {
                    %>
                    <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.ergovision",sWebLanguage)%>
                    <%
                }
            %>
            </td>
            <%-- executed checkbox --%>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.common.executed",sWebLanguage)%>
                <input id="cbErgovision" disabled type="checkbox" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION;value=medwan.common.true" property="value" outputString="checked"/> />
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <p align="right">
        <%
        if(activeUser.getAccessRight("occup.ophtalmology.consultation.add") || activeUser.getAccessRight("occup.ophtalmology.consultation.edit")){
            %>
                <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="submitForm(true);"></button>
                <button class="button" name="ButtonSave" onclick="submitForm(true);"><%=getTran("accesskey","save",sWebLanguage)%></button>
                <input class="button" type="button" name="ButtonSaveClose" value="<%=getTranNoLink("Web","save_and_close",sWebLanguage)%>" onclick="submitForm(false);"/>
            <%
        }
        %>
        <input class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/occupationalmedicine/managePeriodicExaminations.do'/>?ts=<%=getTs()%>'">
    </p>
    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  <%-- SUBMIT FORM --%>   
  function submitForm(bReturn){
      document.transactionForm.save.disabled = true;
      document.transactionForm.submit();
  }

  <%-- FORWARD --%>
  function forward(sID,url){
    if ((document.all[sID].checked)||((!document.all['cbVisiotest'].checked)&&(!document.all['cbErgovision'].checked))){
      window.location.href = "<%=sCONTEXTPATH%>"+url;
    }
  }

  <%-- SUB SCREEN --%>
  function subScreen(sID,url){
    if ((document.all[sID].checked)||((!document.all['cbVisiotest'].checked)&&(!document.all['cbErgovision'].checked))){
      document.all['be.mxs.healthrecord.updateTransaction.actionForwardKey'].value = url;
      transactionForm.submit();
    }
  }
</script>
<%=writeJSButtons("transactionForm","document.all['ButtonSave']")%>