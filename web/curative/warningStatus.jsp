<%@page import="be.mxs.common.model.vo.healthrecord.IConstants,
                java.util.Collection"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td>
            <%=getTran("curative","warning.status.title",sWebLanguage)%>&nbsp;
            <a href="<c:url value='/healthrecord/manageAlertsPage.do'/>?ts=<%=getTs()%>"><img src="<c:url value='/_img/icons/icon_new.gif'/>" class="link" alt="<%=getTranNoLink("web","managealerts",sWebLanguage)%>" style="vertical-align:-4px;"></a>
        </td>
    </tr>

    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        sessionContainerWO.init(activePatient.personid);
        if(sessionContainerWO.getHealthRecordVO()!=null){
            Collection altertTransactions = MedwanQuery.getInstance().getTransactionsByType(sessionContainerWO.getHealthRecordVO(),IConstants.TRANSACTION_TYPE_ALERT);
            sessionContainerWO.setAlerts(altertTransactions);

            if(sessionContainerWO.getActiveAlerts().size() > 0){
                // list alerts
                Collection colActiveAlerts = sessionContainerWO.getActiveAlerts();
                Iterator iteratorActiveAlerts = colActiveAlerts.iterator();
                TransactionVO transactionVO;
                String sLabel, sComment;
                ItemVO itemVO;

                while(iteratorActiveAlerts.hasNext()){
                    transactionVO = (TransactionVO) iteratorActiveAlerts.next();
                    sLabel = "";
                    sComment = "";

                    itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_LABEL");
                    if(itemVO!=null){
                        sLabel = checkString(itemVO.getValue());
                    }

                    itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_DESCRIPTION");
                    if(itemVO!=null){
                        sComment = checkString(itemVO.getValue());
                        if(sComment.length() > 0){
                            sComment = " ("+sComment+")";
                        }
                    }

                    %>
                        <tr>
                            <td width='*'>
                                <img src="<c:url value='/_img/icons/icon_warning.gif'/>" onClick="editWarning('<%=transactionVO.getServerId()%>','<%=transactionVO.getTransactionId()%>');" class="link" style="vertical-align:-4px;" alt="<%=getTranNoLink("web","edit",sWebLanguage)%>">
                                <a href="javascript:editWarning('<%=transactionVO.getServerId()%>','<%=transactionVO.getTransactionId()%>');" onMouseOver="window.status='';return true;"><b><%=sLabel%></b></a><i><%=sComment%></i>
                            </td>
                        </tr>
                    <%
                }
            }
        }
    %>
    <tr height="99%"><td/></tr>
</table>

<script>
  <%-- EDIT WARNING --%>
  function editWarning(serverId,transactionId){
    window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ALERT"+
    		               "&ts=<%=getTs()%>"+
    		               "&be.mxs.healthrecord.server_id="+serverId+
    		               "&be.mxs.healthrecord.transaction_id="+transactionId;
  }
</script>