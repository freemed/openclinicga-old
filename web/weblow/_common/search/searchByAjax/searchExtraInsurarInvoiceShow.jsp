<%@ page import="be.openclinic.finance.InsurarInvoice,
                 java.util.Vector,
                 be.mxs.common.util.system.HTMLEntities,
                 java.text.DecimalFormat" %>
<%@ page import="be.openclinic.finance.ExtraInsurarInvoice" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoiceDate = checkString(request.getParameter("FindInvoiceDate")),
            sFindInvoiceNr = checkString(request.getParameter("FindInvoiceNr")),
            sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
            sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
            sFindInvoiceInsurarUID = checkString(request.getParameter("FindInvoiceInsurarUID")),
            sFindInvoiceStatus = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid = checkString(request.getParameter("ReturnFieldInvoiceUid")),
            sReturnFieldInvoiceNr = checkString(request.getParameter("ReturnFieldInvoiceNr")),
            sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
            sReturnFieldInvoiceStatus = checkString(request.getParameter("ReturnFieldInvoiceStatus")),
            sReturnFieldInsurarUid = checkString(request.getParameter("ReturnFieldInsurarUid")),
            sReturnFieldInsurarName = checkString(request.getParameter("ReturnFieldInsurarName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## searchInsurarInvoice : " + sAction + " ##############");
        System.out.println("* sFindInvoiceInsurarUID     : " + sFindInvoiceInsurarUID);
        System.out.println("* sFindInvoiceDate          : " + sFindInvoiceDate);
        System.out.println("* sFindInvoiceNr            : " + sFindInvoiceNr);
        System.out.println("* sFindInvoiceType (static) : I");
        System.out.println("* sFunction                 : " + sFunction + "\n");
        System.out.println("* sFindInvoiceBalanceMin    : " + sFindInvoiceBalanceMin);
        System.out.println("* sFindInvoiceBalanceMax    : " + sFindInvoiceBalanceMax);
        System.out.println("* sFindInvoiceStatus        : " + sFindInvoiceStatus + "\n");
        System.out.println("* sReturnFieldInvoiceUid     : " + sReturnFieldInvoiceUid);
        System.out.println("* sReturnFieldInvoiceNr      : " + sReturnFieldInvoiceNr);
        System.out.println("* sReturnFieldInvoiceBalance : " + sReturnFieldInvoiceBalance);
        System.out.println("* sReturnFieldInvoiceStatus  : " + sReturnFieldInvoiceStatus);
        System.out.println("* sReturnFieldInsurarUid     : " + sReturnFieldInsurarUid);
        System.out.println("* sReturnFieldInsurarName    : " + sReturnFieldInsurarName + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00"));
%>
<div class="search">
    <%
        if (sAction.equals("search")) {
            Vector vInvoices = ExtraInsurarInvoice.searchInvoices(sFindInvoiceDate, sFindInvoiceNr, sFindInvoiceInsurarUID, sFindInvoiceStatus, sFindInvoiceBalanceMin, sFindInvoiceBalanceMax);

            boolean recsFound = false;
            StringBuffer sHtml = new StringBuffer();
            String sClass = "1", sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceStatus, sInsurarUid, sInsurarName;
            ExtraInsurarInvoice invoice;

            SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
            Iterator iter = vInvoices.iterator();
            while (iter.hasNext()) {
                invoice = (ExtraInsurarInvoice) iter.next();
                sInvoiceUid = invoice.getUid();
                recsFound = true;

                sInvoiceNr = invoice.getInvoiceUid();
                sInvoiceStatus = getTranNoLink("finance.patientinvoice.status", invoice.getStatus(), sWebLanguage);

                // date
                if (invoice.getDate() != null) {
                    sInvoiceDate = stdDateFormat.format(invoice.getDate());
                } else {
                    sInvoiceDate = "";
                }

                // insurar
                sInsurarUid = "";
                sInsurarName = "";
                if (invoice.getInsurar() != null) {
                    sInsurarUid = invoice.getInsurar().getUid();
                    sInsurarName = invoice.getInsurar().getName();
                }
                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                sHtml.append("<tr class='list" + sClass + "' " + " onmouseover=\"this.style.cursor='hand';this.className='list_select';\" " + " onmouseout=\"this.style.cursor='default';this.className='list" + sClass + "';\" ")
                        .append(" onclick=\"selectInvoice('" + sInvoiceUid + "','" + sInvoiceDate + "','" + sInvoiceNr + "','" + invoice.getBalance() + "','" + sInvoiceStatus + "','" + sInsurarUid + "','" + sInsurarName + "');\">")
                        .append(" <td>" + sInsurarName + "</td>")
                        .append(" <td>" + sInvoiceDate + "</td>")
                        .append(" <td>" + sInvoiceNr + "</td>")
                        .append(" <td style='text-align:right;'>" + priceFormat.format(invoice.getBalance()) + "  </td>")
                        .append(" <td>" + sInvoiceStatus + "</td>");

            }


            if (recsFound) {
    %>
    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0"
           style="border:1px solid #cccccc;">
        <%-- header --%>
        <tr class="admin">
            <td width="200" nowrap><%=
                HTMLEntities.htmlentities(getTran("medical.accident", "insurancecompany", sWebLanguage))%>
            </td>
            <td width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web", "date", sWebLanguage))%>
            </td>
            <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("web", "invoicenumber", sWebLanguage))%>
            </td>
            <td width="130" nowrap style="text-align:right;"><%=
                HTMLEntities.htmlentities(getTran("web", "balance", sWebLanguage))%>nbsp;<%=
                HTMLEntities.htmlentities((sCurrency))%>
            </td>
            <td width="120" nowrap><%=
                HTMLEntities.htmlentities(getTran("web.finance", "patientinvoice.status", sWebLanguage))%>
            </td>
        </tr>

        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>

            <%=HTMLEntities.htmlentities(sHtml.toString())%>
        </tbody>
    </table>
    <%
    } else {
        // display 'no results' message
    %><%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><%
        }
    }
%>
</div>
