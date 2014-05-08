<%@include file="../includes/validateUser.jsp"%>
<%
    boolean bToExecute = checkString(request.getParameter("toexecute")).equalsIgnoreCase("true");
    boolean bToValidate = checkString(request.getParameter("tovalidate")).equalsIgnoreCase("true");
%>
<%=checkPermission("rx.openxrayrequests","select",activeUser)%>
<%=writeTableHeader("Web","openXRayRequest",sWebLanguage," doBack();")%>
<table class='list' width='100%' cellspacing="1" cellpadding="0">
    <tr class='admin'>
        <td><%=getTran("web","date",sWebLanguage)%></td>
        <td><%=getTran("web","id",sWebLanguage)%></td>
        <td><%=getTran("web","type",sWebLanguage)%></td>
        <td><%=getTran("web","patient",sWebLanguage)%></td>
    </tr>
<%
    if(bToExecute || bToValidate){
        // variables
        String sQuery;
        if(bToExecute){
            sQuery = "select t.*,a.firstname,a.lastname,a.personid " +
                    " from Transactions t, Healthrecord h, AdminView a" +
                    " where " +
                    " t.transactionType like 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR%'" +
                    " and t.healthRecordId=h.healthRecordId" +
                    " and not exists (select * from Items i where t.serverid=i.serverid" +
                    " and t.transactionId=i.transactionId" +
                    " and i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION')" +
                    " and h.personid=a.personid" +
                    " order by t.updateTime,t.transactionId";
        }
        else {
            sQuery = "select t.*,a.firstname,a.lastname,a.personid " +
                    " from Transactions t, Items i1,Healthrecord h, AdminView a" +
                    " where " +
                    " t.transactionType like 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR%'" +
                    " and t.healthRecordId=h.healthRecordId" +
                    " and t.serverid=i1.serverid" +
                    " and t.transactionId=i1.transactionId" +
                    " and i1.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION'" +
                    " and not exists (select * from Items i where t.serverid=i.serverid" +
                    " and t.transactionId=i.transactionId" +
                    " and i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALIDATION')" +
                    " and h.personid=a.personid" +
                    " order by t.updateTime,t.transactionId";
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            //We stellen nu alle transacties samen
            TransactionVO transactionVO=MedwanQuery.getInstance().loadTransaction(rs.getInt("serverid"),rs.getInt("transactionId"));
            if(transactionVO!=null){
                ItemVO type=transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
                ItemVO id=transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_IDENTIFICATION_RX");
                out.println("<tr><td class='admin2'><a href='javascript:selectTran("+transactionVO.getServerId()+","+transactionVO.getTransactionId()+")'><b>"+ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+"</b></a></td>" +
                        "<td class='admin2'>"+(id!=null?id.getValue():"?")+"</td>" +
                        "<td class='admin2'><b>"+(type!=null && !type.getValue().equalsIgnoreCase("0") && !type.getValue().equalsIgnoreCase("")?getTran("mir_type",type.getValue(),sWebLanguage):"?")+"</b></td>" +
                        "<td class='admin2'><b>"+rs.getString("firstname")+" "+rs.getString("lastname")+"</b></td></tr>");
            }
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }
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