<%@ page import="be.mxs.common.util.system.HTMLEntities,java.util.*,be.openclinic.finance.CoveragePlanInvoice" %>
<%@ page import="be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sEditCoveragePlanInvoiceUID = checkString(request.getParameter("EditCoveragePlanInvoiceUID"));
    String sEditDate = checkString(request.getParameter("EditDate"));
    String sEditInsurarUID = checkString(request.getParameter("EditInsurarUID"));
    String sEditInvoiceUID = checkString(request.getParameter("EditInvoiceUID"));
    String sEditStatus = checkString(request.getParameter("EditStatus"));
    String sEditBalance = checkString(request.getParameter("EditBalance"));
    String sEditCBs = checkString(request.getParameter("EditCBs"));

    CoveragePlanInvoice coveragePlanInvoice = new CoveragePlanInvoice();
    coveragePlanInvoice.setBalance(Double.parseDouble(sEditBalance.replace(",",".")));


    if (sEditCoveragePlanInvoiceUID.length() > 0) {
        CoveragePlanInvoice oldpatientinvoice = CoveragePlanInvoice.get(sEditCoveragePlanInvoiceUID);
        coveragePlanInvoice.setCreateDateTime(oldpatientinvoice.getCreateDateTime());
    } else {
        coveragePlanInvoice.setCreateDateTime(getSQLTime());
    }

    coveragePlanInvoice.setStatus(sEditStatus);
    coveragePlanInvoice.setInsurarUid(sEditInsurarUID);
    coveragePlanInvoice.setInvoiceUid(sEditInvoiceUID);
    coveragePlanInvoice.setDate(ScreenHelper.getSQLDate(sEditDate));
    coveragePlanInvoice.setUid(sEditCoveragePlanInvoiceUID);
    coveragePlanInvoice.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    coveragePlanInvoice.setUpdateUser(activeUser.userid);

    coveragePlanInvoice.setDebets(new Vector());
    coveragePlanInvoice.setCredits(new Vector());

    if (sEditCBs.length() > 0) {
        String[] aCBs = sEditCBs.split(",");
        String sID;
        for (int i = 0; i < aCBs.length; i++) {
            if (checkString(aCBs[i]).length() > 0) {
                PrestationDebet debet = new PrestationDebet();
                if (checkString(aCBs[i]).startsWith("d")) {
                    sID = aCBs[i].substring(1);
                    debet.setUid(sID);
                    coveragePlanInvoice.getDebets().add(debet);
                } else if (checkString(aCBs[i]).startsWith("c")) {
                    sID = aCBs[i].substring(1);
                    coveragePlanInvoice.getCredits().add(sID);
                }
            }
        }
    }

    String sMessage;
    if (coveragePlanInvoice.store()) {
        sMessage = getTran("web", "dataissaved", sWebLanguage);
    } else {
        sMessage = getTran("web.control", "dberror", sWebLanguage);
    }
%>
{
"Message":"<%=HTMLEntities.htmlentities(sMessage)%>",
"EditCoveragePlanInvoiceUID":"<%=coveragePlanInvoice.getUid()%>",
"EditInvoiceUID":"<%=coveragePlanInvoice.getInvoiceUid()%>"
}