<%@ page import="be.openclinic.system.Transaction,
                 be.openclinic.system.Counter,
                 be.openclinic.system.Item,
                 be.openclinic.system.Healthrecord"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sFindServerId = checkString(request.getParameter("FindServerId"));

    if (sFindServerId.length()>0){
        int iMaxId;
//UPDATE COUNTERS
        String sMaxId = Transaction.selectMaxTransactionIdByServer(sFindServerId);
        Counter objCounter = new Counter();

        if(sMaxId.length() > 0){
            iMaxId = Integer.parseInt(sMaxId) + 10000;
            objCounter.setName("TransactionID");
            objCounter.setCounter(iMaxId);
            Counter.saveCounter(objCounter,"occupdb");
        }
        sMaxId = Item.selectMaxItemIdByServer(sFindServerId);

        objCounter = new Counter();

        if(sMaxId.length()  > 0){
            iMaxId = Integer.parseInt(sMaxId) + 10000;
            objCounter.setName("ItemID");
            objCounter.setCounter(iMaxId);
            Counter.saveCounter(objCounter,"occupdb");
        }

//HEALTHRECORD
        Healthrecord.updateServerId(sFindServerId);

        MedwanQuery.getInstance().setConfigString("serverId",sFindServerId);
        MedwanQuery.getInstance().reloadConfigValues();
    }
%>
<form name="transactionForm" method="post">
    <table border="0" width='100%' align='center' cellspacing="1" class="list">
        <tr>
            <td colspan="2">
                <%=writeTableHeader("Web.manage","ManageServerId",sWebLanguage,"main.do?Page=system/menu.jsp")%>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("Web.Manage","ServerID",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="FindServerId" value="<%=MedwanQuery.getInstance().getConfigString("serverId")%>" size="<%=sTextWidth%>">
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class='button' type="button" name="SaveButton" value='<%=getTran("Web","Save",sWebLanguage)%>' onclick="transactionForm.submit();">&nbsp;
            <input class='button' type="button" name="backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick='javascript:window.location.href="main.do?Page=system/menu.jsp"'>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <script>
      transactionForm.FindServerId.focus();
    </script>
</form>