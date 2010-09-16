<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
    Collection colTrans = sessionContainerWO.getHealthRecordVO().getTransactions();
    Iterator iterator = colTrans.iterator();
    Hashtable hTrans = new Hashtable();
    TransactionVO transaction, newTransaction;
    String sTransTranslation;
    SortedSet set = new TreeSet();

    while (iterator.hasNext()) {
        transaction = (TransactionVO) iterator.next();
        sTransTranslation = getTran("Web.occup", transaction.getTransactionType(), sWebLanguage);
        newTransaction = (TransactionVO) hTrans.get(sTransTranslation);

        if (newTransaction == null) {
            hTrans.put(sTransTranslation, transaction);
            set.add(sTransTranslation);
        } else if (newTransaction.getCreationDate().compareTo(transaction.getUpdateTime()) < 0) {
            hTrans.put(sTransTranslation, transaction);
            set.add(sTransTranslation);
        }
    }
%>
<html>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSSORTTABLE%>
</head>
<body class="Geenscroll">
<form name="searchForm" method="POST">
  <table width='100%' border='0' cellspacing='0' cellpadding='0' class='list'>
    <%-- SEARCH RESULTS --%>
    <tr>
      <td class="white" valign="top">
        <div class="search" style="width:570">
          <table width="100%" cellspacing="0" cellpadding="0" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' class="sortable" id="searchresults">
            <tr class="admin">
                <td><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                <td><%=getTran("Web.Occup","medwan.common.contacttype",sWebLanguage)%></td>
            </tr>
            <%
                if (hTrans!=null){
                    Iterator it = set.iterator();
                    Object element;
                    String sClass="", sForward;

                    while (it.hasNext()) {
                        element = it.next();
                        transaction = (TransactionVO) hTrans.get(element.toString());
                        sForward = MedwanQuery.getInstance().getForward(transaction.getTransactionType());

                        if (sForward!=null){
                            if(sForward.indexOf("template.jsp")>-1){
                                sForward = sForward.substring(0,sForward.indexOf("template.jsp"))+"viewLastTransaction.jsp"+sForward.substring(sForward.indexOf("template.jsp")+12);
                            }
                            if (sClass.equals("")) sClass = "1";
                            else                   sClass = "";
                            %>
                            <a href="<%=sCONTEXTPATH+sForward%>?be.mxs.healthrecord.createTransaction.transactionType=<%=transaction.getTransactionType()%>&be.mxs.healthrecord.transaction_id=<%=transaction.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transaction.getServerId()%>&ts=<%=getTs()%>&useTemplate=no" onMouseOver="window.status='';return true;">
                                <tr height="18px" class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>'">
                                    <td><%=new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())%></td>
                                    <td><%=getTran("Web.occup",transaction.getTransactionType(),sWebLanguage)%></td>
                                </tr>
                            </a>
                            <%
                        }
                    }
                }
            %>
          </table>
        </div>
      </td>
    </tr>
  </table>
  <br>
  <%-- CLOSE BUTTON --%>
  <center>
      <input type="button" name="buttonclose" class="button" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
  </center>
  <script>
    window.resizeTo(582,450);
  </script>
</form>
</body>
</html>