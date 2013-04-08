<%@ page import="be.openclinic.finance.Balance,
                java.text.DecimalFormat" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    Debug.println("financial start");
    Balance balance = Balance.getActiveBalance(activePatient.personid);
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
    double saldo = Balance.getPatientBalance(activePatient.personid);
%>
<table width="100%" cellpadding="0" cellspacing="0" class="list">
    <tr class="admin">
        <td width="200">
            <%=getTran("curative","financial.status.title",sWebLanguage)%>&nbsp;
            <a href="<c:url value='/main.do'/>?Page=financial/editBalance.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/icon_edit.gif'/>" class="link" title="<%=getTran("web","editBalance",sWebLanguage)%>" style="vertical-align:-4px;"></a>
            <a href="<c:url value='/main.do'/>?Page=financial/debetEdit.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/money.gif'/>" class="link" title="<%=getTran("web","debetEdit",sWebLanguage)%>" style="vertical-align:-4px;"></a>
            <a href="<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/invoice.gif'/>" class="link" title="<%=getTranNoLink("web.finance","patientinvoice",sWebLanguage)%>" style="vertical-align:-4px;"></a>
        </td>
        <td <%=saldo<balance.getMinimumBalance()?" class='letterred'":""%>><%=getTran("balance","balance",sWebLanguage)%>:
        <%=new DecimalFormat("#0.00").format(saldo)+" "+sCurrency%></td>
        <td><%=getTran("balance","out_of_balance_since",sWebLanguage)%>:
        <%=ScreenHelper.getSQLDate(balance.getCreateDateTime())%></td>
    </tr>
</table>
<%
    Debug.println("financial stop");
%>