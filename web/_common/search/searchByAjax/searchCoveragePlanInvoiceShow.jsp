<%@page import="be.openclinic.finance.*,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoiceDate       = checkString(request.getParameter("FindInvoiceDate")),
           sFindInvoiceNr         = checkString(request.getParameter("FindInvoiceNr")),
           sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
           sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
           sFindInvoiceInsurarUID = checkString(request.getParameter("FindInvoiceInsurarUID")),
           sFindInvoiceStatus     = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid     = checkString(request.getParameter("ReturnFieldInvoiceUid")),
           sReturnFieldInvoiceNr      = checkString(request.getParameter("ReturnFieldInvoiceNr")),
           sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
           sReturnFieldInvoiceStatus  = checkString(request.getParameter("ReturnFieldInvoiceStatus")),
           sReturnFieldInsurarUid     = checkString(request.getParameter("ReturnFieldInsurarUid")),
           sReturnFieldInsurarName    = checkString(request.getParameter("ReturnFieldInsurarName"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** searchByAjax/searchCoveragePlanInvoiceShow.jsp ****************");
        Debug.println("sAction                    : "+sAction);
        Debug.println("sFindInvoiceInsurarUID     : "+sFindInvoiceInsurarUID);
        Debug.println("sFindInvoiceDate           : "+sFindInvoiceDate);
        Debug.println("sFindInvoiceNr             : "+sFindInvoiceNr);
        Debug.println("sFindInvoiceType (static ) : I");
        Debug.println("sFunction                  : "+sFunction+"\n");
        Debug.println("sFindInvoiceBalanceMin     : "+sFindInvoiceBalanceMin);
        Debug.println("sFindInvoiceBalanceMax     : "+sFindInvoiceBalanceMax);
        Debug.println("sFindInvoiceStatus         : "+sFindInvoiceStatus+"\n");
        Debug.println("sReturnFieldInvoiceUid     : "+sReturnFieldInvoiceUid);
        Debug.println("sReturnFieldInvoiceNr      : "+sReturnFieldInvoiceNr);
        Debug.println("sReturnFieldInvoiceBalance : "+sReturnFieldInvoiceBalance);
        Debug.println("sReturnFieldInvoiceStatus  : "+sReturnFieldInvoiceStatus);
        Debug.println("sReturnFieldInsurarUid     : "+sReturnFieldInsurarUid);
        Debug.println("sReturnFieldInsurarName    : "+sReturnFieldInsurarName+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));

    //*** SEARCH **********************************************************************************
    if(sAction.equals("search")){
        Vector vInvoices = CoveragePlanInvoice.searchInvoices(sFindInvoiceDate,sFindInvoiceNr,sFindInvoiceInsurarUID,
        		                                              sFindInvoiceStatus,sFindInvoiceBalanceMin,sFindInvoiceBalanceMax);
        int recCount = 0;
        StringBuffer sHtml = new StringBuffer();
        String sClass = "1", sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceStatus, sInsurarUid, sInsurarName;
        CoveragePlanInvoice invoice;

        Iterator iter = vInvoices.iterator();
        while(iter.hasNext()){
            invoice = (CoveragePlanInvoice)iter.next();
            sInvoiceUid = invoice.getUid();
            recCount++;

            sInvoiceNr = invoice.getInvoiceUid();
            sInvoiceStatus = getTranNoLink("finance.patientinvoice.status",invoice.getStatus(),sWebLanguage);

            // date
            if(invoice.getDate()!=null){
                sInvoiceDate = ScreenHelper.formatDate(invoice.getDate());
            }
            else{
                sInvoiceDate = "";
            }

            // insurar
            sInsurarUid = "";
            sInsurarName = "";
            if(invoice.getInsurar()!=null){
                sInsurarUid = invoice.getInsurar().getUid();
                sInsurarName = invoice.getInsurar().getName();
            }
            
            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            sHtml.append("<tr class='list"+sClass+"' onclick=\"selectInvoice('"+sInvoiceUid+"','"+sInvoiceDate+"','"+sInvoiceNr+"','"+invoice.getBalance()+"','"+sInvoiceStatus+"','"+sInsurarUid+"','"+sInsurarName+"');\">")
                  .append("<td>"+sInsurarName+"</td>")
                  .append("<td>"+sInvoiceDate+"</td>")
                  .append("<td>"+sInvoiceNr+"</td>")
                  .append("<td style='text-align:right;'>"+priceFormat.format(invoice.getBalance())+" </td>")
                  .append("<td>"+sInvoiceStatus+"</td>");
        }

        if(recCount > 0){
		    %>
			    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0" style="border:1px solid #ccc;">
			        <%-- header --%>
			        <tr class="admin">
			            <td width="200" nowrap><%=HTMLEntities.htmlentities(getTran("web","coverageplan",sWebLanguage))%></td>
			            <td width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
			            <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("web","number",sWebLanguage))%></td>
			            <td width="130" nowrap style="text-align:right;"><%=HTMLEntities.htmlentities(getTran("web","balance",sWebLanguage))%> <%=HTMLEntities.htmlentities((sCurrency))%></td>
			            <td width="120" nowrap><%=HTMLEntities.htmlentities(getTran("web.finance","reimbursementdocument.status",sWebLanguage))%></td>
			        </tr>
			
			        <tbody class="hand"><%=HTMLEntities.htmlentities(sHtml.toString())%></tbody>
			    </table>
			   
                <%=recCount%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
		        <script>sortables_init();</script>
		    <%
	    }
	    else{
	        %><%=HTMLEntities.htmlentities(getTran("web","norecordsfound",sWebLanguage))%><%
	    }
	}
%>