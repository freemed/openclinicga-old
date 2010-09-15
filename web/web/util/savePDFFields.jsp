<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.dpms.medwan.common.model.vo.authentication.UserVO,
                be.mxs.common.model.vo.healthrecord.ItemContextVO,
                be.mxs.common.model.vo.IdentifierFactory"%>
<%@ page import="java.util.*" %>

<%
    // We gaan een nieuwe transactie samenstellen
    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
    TransactionVO transactionVO = new TransactionVO(new Integer(request.getParameter("transactionId")), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DOCUMENT", new java.util.Date(), new java.util.Date(), 1, sessionContainerWO.getUserVO(), new java.util.Vector());
    ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");

    // Voor elke parameter nu een item opslaan
    String paramName, paramValue, paramValueChunk, paramNameChunk, paramValueOrig;
    Enumeration params = request.getParameterNames();
    while (params.hasMoreElements()) {
        paramName = (String) params.nextElement();
        paramValue = checkString(request.getParameter(paramName));

        // rechte ' worden niet correct weergegeven door Acrobat..
        paramValue = paramValue.replaceAll("'", "´");
        paramValueOrig = paramValue;

        // save value over many items if needed
        int chunkCounter = 0, endIdx;
        while (paramValue.length() > 0) {
            // compute length of chunk
            if (paramValue.length() >= 255) endIdx = 255;
            else endIdx = paramValue.length();

            // take away the first 255 chars from the value
            paramValueChunk = paramValue.substring(0, endIdx); // item
            paramValue = paramValue.substring(paramValueChunk.length()); // remainder

            // when more than one chunk, change name of item by adding a number to it
            if (paramValueOrig.length() > 255) paramNameChunk = paramName + "_#" + chunkCounter;
            else paramNameChunk = paramName;

            transactionVO.getItems().add(new ItemVO(new Integer(-1), paramNameChunk, paramValueChunk, transactionVO.getUpdateTime(), itemContextVO));
            chunkCounter++;
        }
    }

    // extra item om document type aan te duiden
    if (transactionVO.getItem("documentId") != null) {
        transactionVO.getItems().add(new ItemVO(new Integer(-1), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOCUMENT_TYPE", request.getParameter("documentId").replaceAll(".pdf", ""), transactionVO.getUpdateTime(), itemContextVO));
    }

    // De transactie toevoegen of updaten
    MedwanQuery.getInstance().updateTransaction(sessionContainerWO.getPersonVO().personId.intValue(), transactionVO);
%>

<script>
  window.location.href='<c:url value="/util/loadPDFFromDb.jsp?"/>file=base/<%=request.getParameter("documentTemplateId")%>&serverId=<%=transactionVO.getServerId()%>&transactionId=<%=transactionVO.getTransactionId()%>';
</script>