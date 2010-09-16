<%@include file="/includes/validateUser.jsp"%>
<%
    if(request.getParameter("serverid")!=null && request.getParameter("transactionid")!=null){
        TransactionVO tran = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
        int healthRecordId=tran.getHealthrecordId();
        int personid=MedwanQuery.getInstance().getPersonIdFromHealthrecordId(healthRecordId);
        //Now initialize the new patient context
      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        AdminPerson adminPerson = AdminPerson.getAdminPerson(ad_conn,personid+"");
        ad_conn.close();
        activePatient=adminPerson;
        session.setAttribute("activePatient",activePatient);
        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        sessionContainerWO.init(activePatient.personid);
        
%>
<script type="text/javascript">
    window.location.href="<c:url value="/healthrecord/editTransaction.do"/>?be.mxs.healthrecord.createTransaction.transactionType=<%=tran.getTransactionType()%>&be.mxs.healthrecord.transaction_id=<%=tran.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=tran.getServerId()%>";
</script>
<%

    }
%>
