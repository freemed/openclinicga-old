<%@page import="be.dpms.medwan.common.model.vo.administration.PersonVO"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String barcode = checkString(request.getParameter("barcode"));

    //--- BARCODE AVAILABLE ------------------------------------------------------------------------
    if (barcode.length() > 0) {
        boolean bFound = false;
        boolean bError = false;
        String msg = "";

        if (barcode.length() > 0) {
            TransactionVO transaction = null;
            if (barcode.startsWith("4")) {
                transaction = MedwanQuery.getInstance().getTransactionForItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_IDENTIFICATION_RX", barcode);
                if (transaction == null) {
                    transaction = MedwanQuery.getInstance().getTransactionForItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_IDENTIFICATION_RX", barcode);
                }
            }
            else if (barcode.startsWith("5")){
                transaction = MedwanQuery.getInstance().getTransactionForItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_IDENTIFICATION_NUMBER", barcode);
            }
            if (transaction != null) {
                // First we set the activepatient to the appropriate person
                int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transaction.getHealthrecordId());
                SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());

                PersonVO person = MedwanQuery.getInstance().getPerson(personid + "");
                sessionContainerWO.setPersonVO(person);
                sessionContainerWO.setHealthRecordVO(MedwanQuery.getInstance().loadHealthRecord(person, null, sessionContainerWO));
                sessionContainerWO.setUserVO(MedwanQuery.getInstance().getUser(activeUser.userid));

                activePatient = new AdminPerson();
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                activePatient.initialize(ad_conn, personid + "");
                ad_conn.close();
                session.setAttribute("activePatient", activePatient);

                // Then we open the document
%>
                    <script>
                      window.opener.location.href='<c:url value="/healthrecord/editTransaction.do"/>?be.mxs.healthrecord.createTransaction.transactionType=<%=transaction.getTransactionType()%>&be.mxs.healthrecord.transaction_id=<%=transaction.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transaction.getServerId()%>&ts=<%=getTs()%>';
                      window.close();
                    </script>
                <%

                bFound = true;
            }
        }
    }
%>
<script>
  window.close();
</script>
