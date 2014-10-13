<%@page import="java.util.*"%>
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

    while(iterator.hasNext()){
        transaction = (TransactionVO)iterator.next();
        sTransTranslation = getTran("Web.occup",transaction.getTransactionType(),sWebLanguage);
        newTransaction = (TransactionVO)hTrans.get(sTransTranslation);

        if(newTransaction==null){
            hTrans.put(sTransTranslation,transaction);
            set.add(sTransTranslation);
        } 
        else if(newTransaction.getCreationDate().compareTo(transaction.getUpdateTime()) < 0){
            hTrans.put(sTransTranslation,transaction);
            set.add(sTransTranslation);
        }
    }
%>
<html>
<head>
    <title><%=getTran("web.occup","medwan.occupational-medicine.showlasttransactions",sWebLanguage)%></title>
    <%=sCSSNORMAL%>
    <%=sJSSORTTABLE%>
</head>

<body style="padding:2px;">
    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <%-- header --%>
        <tr class="admin">
            <td width="80"><SORTTYPE:DATE><DESC><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></DESC></SORTTYPE:DATE></td>
            <td><%=getTran("Web.Occup","medwan.common.contacttype",sWebLanguage)%></td>
        </tr>
       
        <tbody class="hand">
        <%
            if(hTrans!=null){
                Iterator it = set.iterator();
                Object element;
                String sClass="", sForward;

                while(it.hasNext()){
                    element = it.next();
                    transaction = (TransactionVO) hTrans.get(element.toString());
                    sForward = MedwanQuery.getInstance().getForward(transaction.getTransactionType());

                    if(sForward!=null){
                        if(sForward.indexOf("template.jsp")>-1){
                            sForward = sForward.substring(0,sForward.indexOf("template.jsp"))+"viewLastTransaction.jsp"+sForward.substring(sForward.indexOf("template.jsp")+12);
                        }
                       
                        // alternate row-style
                        if(sClass.equals("")) sClass = "1";
                        else                  sClass = "";
                       
                        %>
                            <tr height="18px" class="list<%=sClass%>" onMouseOver="this.className='list_select'" onMouseOut="this.className='list<%=sClass%>'">
                                <td>&nbsp;<%=ScreenHelper.stdDateFormat.format(transaction.getUpdateTime())%></td>
                                <td>
                                    &nbsp;<a href="<%=sCONTEXTPATH+sForward%>&be.mxs.healthrecord.transaction_id=<%=transaction.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transaction.getServerId()%>&ts=<%=getTs()%>&useTemplate=no" onMouseOver="window.status='';return true;"><%=getTran("Web.occup",transaction.getTransactionType(),sWebLanguage)%></a>
                                </td>
                            </tr>
                        <%
                    }
                }
            }
        %>
        </tbody>
    </table>
    <br>
  
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" name="buttonclose" class="button" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
    </center>
  
  <script>  
    if(window.opener.document.getElementById('ie5menu')){
	  window.opener.document.getElementById('ie5menu').style.visibility = 'hidden';
 	}
    
    window.resizeTo(582,450);

    setTimeout("sortTransactions()",300);
    
    <%-- SORT TRANSACTIONS --%>
    function sortTransactions(){
      var sortLink = document.getElementById("searchresults_lnk0");
      if(sortLink!=null){
        ts_resortTable(sortLink,0,false);
      }
    }
  </script>
</body>
</html>