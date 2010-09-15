<%@ page import="be.openclinic.finance.Balance,be.openclinic.finance.DebetTransaction,
be.openclinic.finance.CreditTransaction,java.util.Vector,java.util.Collections,
be.openclinic.pharmacy.ProductStockOperation" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.balancehistory","select",activeUser)%>
<%=sJSSORTTABLE%>
<%!
    //*** INNER CLASS : RESULT ROW ****************************************************************
    private class ResultRow implements Comparable{
        public String type;
        public Timestamp timestamp;
        public String description;
        public double amount;
        public String uid;

        //--- CONSTRUCTOR -------------------------------------------------------------------------
        public ResultRow(){
            this.type = "";
            this.timestamp = null;
            this.description = "";
            this.amount = 0;
            this.uid = "";
        }

        //--- COMPARE TO --------------------------------------------------------------------------
        public int compareTo(Object o){
            int comp;
            if (o.getClass().isInstance(this)){
                comp = this.timestamp.compareTo(((ResultRow)o).timestamp);
            }
            else {
                throw new ClassCastException();
            }

            return comp;
        }
    }
%>
<%
    String sEditBalanceUID = checkString(request.getParameter("EditBalanceUID"));
    Balance balance;

    if (sEditBalanceUID.length()==0){
        balance = Balance.getActiveBalance(activePatient.personid);
    }
    else {
        balance = Balance.get(sEditBalanceUID);
    }
%>
    <%=writeTableHeader("balance","balance_overview",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- balance --%>
        <tr>
            <td class="admin"><%=getTran("balance","balance",sWebLanguage)%></td>
            <td class="admin2"><b><%=checkString(Double.toString(balance.getBalance()))+" "+MedwanQuery.getInstance().getConfigParam("currency","€")%><b></td>
        </tr>
        <%
            String sDate = "";
            if(balance.getDate() != null){
                sDate = new SimpleDateFormat("dd/MM/yyyy").format(balance.getDate());
            }
        %>
        <%-- date --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","date",sWebLanguage)%></td>
            <td class="admin2"><%=sDate%></td>
        </tr>
        <%-- max balance --%>
        <tr>
            <td class="admin"><%=getTran("balance","maxbalance",sWebLanguage)%></td>
            <td class="admin2"><%=balance.getMaximumBalance()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")%></td>
        </tr>
        <%-- min balance --%>
        <tr>
            <td class="admin"><%=getTran("balance","minbalance",sWebLanguage)%></td>
            <td class="admin2"><%=balance.getMinimumBalance()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")%></td>
        </tr>
        <%-- remarks --%>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2"><%=checkString(balance.getRemarks())%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class='button' type='button' name='buttonEditBalance' value='<%=getTran("balance","editbalance",sWebLanguage)%>' onclick='editBalance();'>&nbsp;
            </td>
        </tr>
    </table>
    <br>

<script>
    function doBack(){
        history.go(-1);
        return false;
    }

    function editBalance(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/editBalance.jsp&ts=<%=getTs()%>";
    }
</script>