<%@ page import="java.util.*,be.openclinic.finance.InsurarInvoice,be.openclinic.finance.Insurar,be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.text.DecimalFormat" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00"));
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
    Vector vOpenInsurarInvoices = InsurarInvoice.getInsurarInvoicesWhereDifferentStatus("'closed','canceled'");
    String sReturn = "", sInsurar;
    Hashtable hSort = new Hashtable();
    InsurarInvoice insurarInvoice;
    Insurar insurar;

    for (int i = 0; i < vOpenInsurarInvoices.size(); i++) {
        insurarInvoice = (InsurarInvoice) vOpenInsurarInvoices.elementAt(i);

        if (insurarInvoice != null) {
            sInsurar = "";
            if (checkString(insurarInvoice.getInsurarUid()).length() > 0) {
                insurar = Insurar.get(insurarInvoice.getInsurarUid());

                if (insurar != null) {
                    sInsurar = checkString(insurar.getName());
                }
            }
            hSort.put(insurarInvoice.getDate().getTime() + "=" + insurarInvoice.getUid(), " onclick=\"setInsurarInvoice('" + insurarInvoice.getInvoiceUid() + "');\">"
                    + "<td>" + ScreenHelper.getSQLDate(insurarInvoice.getDate()) + "</td>"
                    + "<td>" + insurarInvoice.getInvoiceUid() + "</td>"
                    + "<td style='text-align:right;'>" + priceFormat.format(insurarInvoice.getBalance()) + "&nbsp;</td>"
                    + "<td>" + HTMLEntities.htmlentities(sInsurar) + "</td>"
                    + "<td>" + getTran("finance.patientinvoice.status", insurarInvoice.getStatus(), sWebLanguage) + "</td></tr>");
        }
    }

    Vector keys = new Vector(hSort.keySet());
    Collections.sort(keys);
    Collections.reverse(keys);
    Iterator it = keys.iterator();
    String sClass = "";
    while (it.hasNext()) {
        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }
        sReturn += "<tr class='list" + sClass
                + "' " + hSort.get(it.next());
    }
%>
<table width="100%" cellspacing="0">
    <tr class="admin">
        <td width="80" nowrap><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td width="120" nowrap><%=HTMLEntities.htmlentities(getTran("web","invoicenumber",sWebLanguage))%></td>
        <td width="150" nowrap style="text-align:right;"><%=HTMLEntities.htmlentities(getTran("web","balance",sWebLanguage))%>&nbsp;<%=sCurrency%></td>
        <td><%=HTMLEntities.htmlentities(getTran("medical.accident","insurancecompany",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("Web.finance","patientinvoice.status",sWebLanguage))%></td>
    </tr>
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table>