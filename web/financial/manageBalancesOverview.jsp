<%@ page import="be.openclinic.finance.Balance,
                 be.openclinic.common.ObjectReference"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Collections" %>
<%@ page import="be.openclinic.finance.DebetTransaction" %>
<%@ page import="be.openclinic.finance.CreditTransaction" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("financial.balance","",activeUser)%>

<%!
    private class ResultRow{
        public String type;
        public Timestamp timestamp;
        public String description;
        public String amount;
        public String uid;

        public ResultRow(){
            this.type = "";
            this.timestamp = null;
            this.description = "";
            this.amount = "";
            this.uid = "";
        }
    }

%>
<%

    String sBalanceUID = checkString(request.getParameter("EditBalanceUID"));
    Balance balance = new Balance();
    if(sBalanceUID.length() > 0){
        balance = Balance.get(sBalanceUID);
    }
%>
    <%=writeTableHeader("Web.manage","managebalancebverview",sWebLanguage," doBack();")%>
    <table class='menu' border='0' width='100%' cellspacing='0'>
        <%-- owner --%>
        <%
            ObjectReference or = balance.getOwner();
            String sType = "";
            String sName = "";
            if(or != null){
                sType = or.getObjectType();
                if(sType.equalsIgnoreCase("person")){
                    sName = ScreenHelper.getFullUserName(or.getObjectUid());
                }else if(sType.equalsIgnoreCase("service")){
                    sName = getTran("Service",or.getObjectUid(),sWebLanguage);
                }
            }
        %>
        <tr>
            <td><%=getTran("web","owner",sWebLanguage)%></td>
            <td><%=sName%></td>
        </tr>
        <%-- balance --%>
        <tr>
            <td><%=getTran("web","balance",sWebLanguage)%></td>
            <td><%=checkString(Double.toString(balance.getBalance()))%></td>
        </tr>
        <%
            String sDate = "";
            if(balance.getDate() != null){
                sDate = ScreenHelper.stdDateFormat.format(balance.getDate());
            }
        %>
        <%-- date --%>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","date",sWebLanguage)%></td>
            <td><%=sDate%></td>
        </tr>
        <%-- max balance --%>
        <tr>
            <td><%=getTran("web","maxbalance",sWebLanguage)%></td>
            <td><%=balance.getMaximumBalance()%></td>
        </tr>
        <%-- min balance --%>
        <tr>
            <td><%=getTran("web","minbalance",sWebLanguage)%></td>
            <td><%=balance.getMinimumBalance()%></td>
        </tr>
        <%-- remarks --%>
        <tr>
            <td><%=getTran("web","comment",sWebLanguage)%></td>
            <td><%=checkString(balance.getRemarks())%></td>
        </tr>
    </table>
<%
    /*
      Hashtable voor de gevonden Credits en Debets bij te houden
    */
    Hashtable hResults = new Hashtable();
    /*
      StringBuffer die de output van de resultaten bijhoudt
    */
    StringBuffer sbResults = new StringBuffer();
    /*
      Ophalen van Debets voor de gekozen balans
    */

    Vector vDebets = DebetTransaction.getDebetTransactionsForBalance(sBalanceUID);
    Iterator iter = vDebets.iterator();

    String sDebetUID = "";
    Timestamp tsDebetDate;
    String sDebetDescription = "";
    String sDebetAmount = "";

    ResultRow result = new ResultRow();
    DebetTransaction objDebet;

    while (iter.hasNext()) {
        objDebet = (DebetTransaction) iter.next();

        sDebetUID = objDebet.getUid();
        tsDebetDate = new Timestamp(objDebet.getDate().getTime());
        sDebetDescription = objDebet.getDescription();
        sDebetAmount = Double.toString(objDebet.getAmount());

        result.uid = sDebetUID;
        result.timestamp = tsDebetDate;
        result.amount = sDebetAmount;
        result.description = sDebetDescription;
        result.type = "Debet";
        hResults.put(result.timestamp, result);
        result = new ResultRow();
    }

    /*
      Ophalen van Credits voor de gekozen balans
    */

    Vector vCredits = CreditTransaction.getCreditTransactionsForBalance(sBalanceUID);
    Iterator iter2 = vCredits.iterator();

    String sCreditUID = "";
    Timestamp tsCreditDate;
    String sCreditAmount = "";
    String sCreditDescription = "";

    CreditTransaction objCredit;
    while(iter2.hasNext()){
        objCredit = (CreditTransaction)iter2.next();
        sCreditUID = objCredit.getUid();
        tsCreditDate = new Timestamp(objCredit.getDate().getTime());
        sCreditDescription = objCredit.getDescription();
        sCreditAmount = Double.toString(objCredit.getAmount());

        result.uid = sCreditUID;
        result.timestamp = tsCreditDate;
        result.amount = sCreditAmount;
        result.description = sCreditDescription;
        result.type = "Credit";
        hResults.put(result.timestamp, result);
        result = new ResultRow();
    }

    /*
      Vector die we gebruiken om de resultaten te ordenen op datum.
    */
    Vector v = new Vector(hResults.keySet());
    Collections.sort(v);
    Collections.reverse(v);
    Iterator it = v.iterator();
    String sClass = "";
    /*
      Loopen door de vector zodanig dat we results kunnen ophalen uit hashtable en in output kunnen steken(StringBuffer)
    */
    String sOutputDate = "";
    while (it.hasNext()) {
        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }
        Timestamp element = (Timestamp) it.next();
        result = (ResultRow) hResults.get(element);
        if (result.timestamp != null) {
            sOutputDate = new SimpleDateFormat("dd/MM/yyyy   HH:mm ").format(result.timestamp);
        }

        sbResults.append("<tr class='list" + sClass + "'" +
                " onmouseover=\"this.style.cursor='hand';\" " +
                " onmouseout=\"this.style.cursor='default';\" " +
                " onclick=\"doSelect('" + result.uid + "','" + result.type + "','" + sBalanceUID + "');\">" +
                "<td>" + result.type + "</td>" +
                "<td>" + sOutputDate + "</td>" +
                "<td>" + result.description + "</td>" +
                "<td>" + result.amount + "</td>" +
                "</tr>");
    }
%>
<p align='center'>
    <input class='button' type='button' name='addDebetButton' value='Add Debet' onclick='addDebet("<%=sBalanceUID%>");'>&nbsp;
    <input class='button' type='button' name='addCreditButton' value='Add Credit' onclick='addCredit("<%=sBalanceUID%>");'>
</p>
<table class='list'  cellspacing="0" cellpadding="0" width='100%'>
    <tr class='admin'>
        <td width='<%=sTDAdminWidth%>'><%=getTran("web","type",sWebLanguage)%></td>
        <td><%=getTran("web","date",sWebLanguage)%></td>
        <td><%=getTran("web","description",sWebLanguage)%></td>
        <td><%=getTran("web","amount",sWebLanguage)%></td>
    </tr>
    <%=sbResults%>
</table>
<%=ScreenHelper.alignButtonsStart()%>
    <%-- Buttons --%>
    <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>
<script>
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
    }

    function addDebet(uid){
        window.location.href="<c:url value='/main.do'/>?Page=financial/manageDebetTransactions.jsp&EditDebetBalanceUID=" + uid +"&ts=<%=getTs()%>";
    }

    function addCredit(uid){
        window.location.href="<c:url value='/main.do'/>?Page=financial/manageCreditTransactions.jsp&EditCreditBalanceUID=" + uid +"&ts=<%=getTs()%>";
    }

    function doSelect(uid,type,balance){
        if(type == "Credit"){
            window.location.href="<c:url value='/main.do'/>?Page=financial/manageCreditTransactions.jsp&EditCreditBalanceUID=" + balance + "&EditCreditUID=" + uid + "&ts=<%=getTs()%>";
        }else if(type == "Debet"){
            window.location.href="<c:url value='/main.do'/>?Page=financial/manageDebetTransactions.jsp&EditDebetBalanceUID=" + balance + "&EditDebetUID=" + uid + "&ts=<%=getTs()%>";
        }
    }
</script>