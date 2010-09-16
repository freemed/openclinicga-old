<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.pediatry.delivery","select",activeUser)%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
<input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
<input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
<input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
<input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
<input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
<%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
<%=contextHeader(request,sWebLanguage)%>
<%
    TransactionVO tran = (TransactionVO) transaction;

    if ((tran != null)&&(tran.getTransactionId().intValue()>0)) {
        String sTransactionId = getItemType(tran.getItems(), sPREFIX+"ITEM_TYPE_TRANSACTIONID");
        String sServerId = getItemType(tran.getItems(), sPREFIX+"ITEM_TYPE_SERVERID");
        tran = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerId),Integer.parseInt(sTransactionId));

        if (tran!=null){
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            sessionContainerWO.setCurrentTransactionVO(tran);

            //ScreenHelper.setIncludePage("/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&be.mxs.healthrecord.transaction_id="+sTransactionId+"&be.mxs.healthrecord.server_id="+sServerId+"&ts="+getTs(), pageContext);
            //pageContext.include("/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&be.mxs.healthrecord.transaction_id="+sTransactionId+"&be.mxs.healthrecord.server_id="+sServerId+"&ts="+getTs());
            %>
            <script>
                window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id=<%=sTransactionId%>&be.mxs.healthrecord.server_id=<%=sServerId%>&readonly=true&ts=<%=getTs()%>";
            </script>
            <%
        }

    }
    else {
        out.print(getTran("web","nodataavailable",sWebLanguage));
    }
%>