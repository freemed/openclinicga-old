<%@ page import="be.openclinic.finance.PatientInvoice,
                 java.util.Vector,
                 java.text.DecimalFormat,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInvoicePatientId = checkString(request.getParameter("FindInvoicePatientId")),
            sFindInvoiceDate = checkString(request.getParameter("FindInvoiceDate")),
            sFindInvoiceNr = checkString(request.getParameter("FindInvoiceNr")),

            sFindInvoiceBalanceMin = checkString(request.getParameter("FindInvoiceBalanceMin")),
            sFindInvoiceBalanceMax = checkString(request.getParameter("FindInvoiceBalanceMax")),
            sFindInvoiceStatus = checkString(request.getParameter("FindInvoiceStatus"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldInvoiceUid = checkString(request.getParameter("ReturnFieldInvoiceUid")),
            sReturnFieldInvoiceNr = checkString(request.getParameter("ReturnFieldInvoiceNr")),
            sReturnFieldInvoiceBalance = checkString(request.getParameter("ReturnFieldInvoiceBalance")),
            sReturnFieldInvoiceMaxBalance = checkString(request.getParameter("ReturnFieldInvoiceMaxBalance")),
            sReturnFieldInvoiceStatus = checkString(request.getParameter("ReturnFieldInvoiceStatus"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n############### searchPatientInvoice : " + sAction + " ##############");
        System.out.println("* sFindInvoicePatientId     : " + sFindInvoicePatientId);
        System.out.println("* sFindInvoiceDate          : " + sFindInvoiceDate);
        System.out.println("* sFindInvoiceNr            : " + sFindInvoiceNr);
        System.out.println("* sFindInvoiceType (static) : P");
        System.out.println("* sFunction                 : " + sFunction + "\n");
        System.out.println("* sFindInvoiceBalanceMin    : " + sFindInvoiceBalanceMin);
        System.out.println("* sFindInvoiceBalanceMax    : " + sFindInvoiceBalanceMax);
        System.out.println("* sFindInvoiceStatus        : " + sFindInvoiceStatus + "\n");
        System.out.println("* sReturnFieldInvoiceUid        : " + sReturnFieldInvoiceUid);
        System.out.println("* sReturnFieldInvoiceNr         : " + sReturnFieldInvoiceNr);
        System.out.println("* sReturnFieldInvoiceBalance    : " + sReturnFieldInvoiceBalance);
        System.out.println("* sReturnFieldInvoiceMaxBalance : " + sReturnFieldInvoiceMaxBalance);
        System.out.println("* sReturnFieldInvoiceStatus     : " + sReturnFieldInvoiceStatus + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00"));
%>
<div class="search">
    <%
        if (sAction.equals("search")) {
            Vector vInvoices = PatientInvoice.searchInvoices(sFindInvoiceDate, sFindInvoiceNr,
                    sFindInvoicePatientId, sFindInvoiceStatus,
                    sFindInvoiceBalanceMin, sFindInvoiceBalanceMax);

            boolean recsFound = false;
            StringBuffer sHtml = new StringBuffer();
            String sClass = "1", sInvoiceUid, sInvoiceDate, sInvoiceNr, sInvoiceStatus;
            PatientInvoice invoice;
            SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
            Iterator iter = vInvoices.iterator();
            while (iter.hasNext()) {
                invoice = (PatientInvoice) iter.next();
                sInvoiceUid = invoice.getUid();
                recsFound = true;

                sInvoiceNr = sInvoiceUid.substring(sInvoiceUid.indexOf(".") + 1);
                sInvoiceStatus = getTranNoLink("finance.patientinvoice.status", invoice.getStatus(), sWebLanguage);

                // date
                if (invoice.getDate() != null) {
                    sInvoiceDate = stdDateFormat.format(invoice.getDate());
                } else {
                    sInvoiceDate = "";
                }

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";
                sHtml.append("<tr class='list" + sClass + "' " + " onmouseover=\"this.style.cursor='hand';this.className='list_select';\" " + " onmouseout=\"this.style.cursor='default';this.className='list" + sClass + "';\" ")
                        .append(" onclick=\"selectInvoice('" + sInvoiceUid + "','" + sInvoiceDate + "','" + sInvoiceNr + "','" + invoice.getBalance() + "','" + HTMLEntities.htmlentities(sInvoiceStatus) + "');\">")
                        .append(" <td>" + sInvoiceDate + "</td>")
                        .append(" <td>" + sInvoiceNr + "</td>")
                        .append(" <td style='text-align:right;'>" + priceFormat.format(invoice.getBalance()) + " </td>")
                        .append(" <td>" + HTMLEntities.htmlentities(sInvoiceStatus) + "</td></tr>");

            }

            if (recsFound) {
    %>
    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0"
           style="border:1px solid #cccccc;">
        <%-- header --%>
        <tr class="admin">
            <td width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web", "date", sWebLanguage))%>
            </td>
            <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("web", "invoicenumber", sWebLanguage))%>
            </td>
            <td width="120" nowrap style="text-align:right;"><%=
                HTMLEntities.htmlentities(getTran("web", "balance", sWebLanguage))%> <%=
                HTMLEntities.htmlentities(sCurrency)%>
            </td>
            <td width="120" nowrap><%=
                HTMLEntities.htmlentities(getTran("web.finance", "patientinvoice.status", sWebLanguage))%>
            </td>
        </tr>

        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
            <%=sHtml.toString()%>
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
