<%@ page import="be.openclinic.finance.InsurarCredit,java.util.Vector,be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private String addDebetCredits(Vector vCredits, String sClass, boolean bChecked, String sWebLanguage) {
        String sReturn = "";

        if (vCredits != null) {
            String sInsurarCreditUID;
            InsurarCredit insurarcredit;
            String sImage = "_img/check.gif";
            if (!bChecked) {
                sImage = " _img/uncheck.gif";
            }

            for (int i = 0; i < vCredits.size(); i++) {
                sInsurarCreditUID = checkString((String) vCredits.elementAt(i));

                if (sInsurarCreditUID.length() > 0) {
                    insurarcredit = InsurarCredit.get(sInsurarCreditUID);

                    if (insurarcredit != null) {
                        if (sClass.equals((""))) {
                            sClass = "1";
                        } else {
                            sClass = "";
                        }

                        sReturn += "<tr class='list" + sClass + "'>"
                                + "<td><img src='"+sImage+"' name='cbCredit" + insurarcredit.getUid() + "=" + insurarcredit.getAmount() + "' onclick='doBalance(this, false)'></td>"
                                + "<td>" + ScreenHelper.getSQLDate(insurarcredit.getDate()) + "</td>"
                                + "<td>" + HTMLEntities.htmlentities(getTran("credit.type", checkString(insurarcredit.getType()), sWebLanguage)+(checkString(insurarcredit.getComment()).length()>0?" ("+insurarcredit.getComment()+")":"")) + "</td>"
                                + "<td>" + insurarcredit.getAmount() + "</td>"
                                + "</tr>";
                    }
                }
            }
        }
        return sReturn;
    }
%>
 <table width="100%" cellspacing="1">
    <tr class="gray">
        <td width="50"/>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td width="50%"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web", "amount", sWebLanguage))%></td>
    </tr>
<%
	String sClass = "";
    
	String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
	InsurarInvoice insurarInvoice = null;
	
	if (sEditInsurarInvoiceUID.length() > 0) {
	    insurarInvoice = InsurarInvoice.getWithoutDebets(sEditInsurarInvoiceUID);
	    Vector vInsurarCredits = insurarInvoice.getCredits();
	    out.print(addDebetCredits(vInsurarCredits, sClass, true, sWebLanguage));
	}
	
    if ((insurarInvoice == null) || (!(checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled")))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        Vector vUnassignedCredits = InsurarCredit.getUnassignedInsurarCredits(sInsurarUid);
        out.print(addDebetCredits(vUnassignedCredits, sClass, false, sWebLanguage));
    }
%>
</table>