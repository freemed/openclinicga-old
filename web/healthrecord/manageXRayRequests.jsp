<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("xrays.request.view","select",activeUser)%>
<%=writeTableHeader("Web","openXRayRequest",sWebLanguage," doBack();")%>
<table class='list' width='100%' cellspacing="1" cellpadding="0">
    <tr class='admin'>
        <td><%=getTran("web","date",sWebLanguage)%></td>
        <td><%=getTran("web","id",sWebLanguage)%></td>
        <td><%=getTran("web","type",sWebLanguage)%></td>
        <td><%=getTran("web","protocol",sWebLanguage)%></td>
    </tr>
<%
    String sQuery = "SELECT t.*,a.firstname,a.lastname,a.personid " +
            " FROM Transactions t, Healthrecord h, AdminView a" +
            " WHERE t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2'" +
            " AND t.healthRecordId=h.healthRecordId" +
            " AND h.personid=a.personid" +
            " AND h.personid=?" +
            " ORDER BY t.updateTime DESC,t.transactionId";
	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    ps.setInt(1, Integer.parseInt(activePatient.personid));
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        //We stellen nu alle transacties samen
        TransactionVO transactionVO=MedwanQuery.getInstance().loadTransaction(rs.getInt("serverid"),rs.getInt("transactionId"));
        ItemVO type=transactionVO.getItem(sPREFIX+"ITEM_TYPE_MIR2_TYPE");
        ItemVO id=transactionVO.getItem(sPREFIX+"ITEM_TYPE_MIR2_IDENTIFICATION_RX");
        ItemVO protocol=transactionVO.getItem(sPREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALIDATION");
        out.print("<tr><td class='admin2'><a href='javascript:selectTran("+transactionVO.getServerId()+","+transactionVO.getTransactionId()+")'><b>"
                +ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+"</b></a></td>" +
                "<td class='admin2'>"+(id!=null?id.getValue():"?")+"</td>" +
                "<td class='admin2'><b>"+(type!=null && !type.getValue().equalsIgnoreCase("0") && !type.getValue().equalsIgnoreCase("")?getTran("mir_type",type.getValue(),sWebLanguage):"?")+"</b></td>" +
                "<td class='admin2'>"+(protocol!=null?getTran("web","yes",sWebLanguage):getTran("web","no",sWebLanguage))+"</td></tr>");
    }
    rs.close();
    ps.close();
    oc_conn.close();
%>
</table>
<script>
    function selectTran(serverid,transactionid){
        window.location.href="<c:url value="/main.do"/>?Page=util/quickSelectTransaction.jsp&serverid="+serverid+"&transactionid="+transactionid;
    }

    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=xrays/index.jsp";
    }
</script>