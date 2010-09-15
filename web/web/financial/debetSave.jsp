<%@ page import="be.openclinic.finance.Debet" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
        String sEditDate = checkString(request.getParameter("EditDate"));
        String sEditDebetUID = checkString(request.getParameter("EditDebetUID"));
        String sEditInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
        String sEditPrestationUID = checkString(request.getParameter("EditPrestationUID"));
        String sEditPrestationGroupUID = checkString(request.getParameter("EditPrestationGroupUID"));
        String sEditAmount = checkString(request.getParameter("EditAmount"));
        String sEditInsurarAmount = checkString(request.getParameter("EditInsurarAmount"));
        String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
        String sEditSupplierUID = checkString(request.getParameter("EditSupplierUID"));
        String sEditPatientInvoiceUID = checkString(request.getParameter("EditPatientInvoiceUID"));
        String sEditInsuranceInvoiceUID = checkString(request.getParameter("EditInsuranceInvoiceUID"));
        String sEditComment = checkString(request.getParameter("EditComment"));
        String sEditCredit = checkString(request.getParameter("EditCredit"));
        String sEditQuantity = checkString(request.getParameter("EditQuantity"));
        String sEditExtraInsurarUID = checkString(request.getParameter("EditExtraInsurarUID"));

        Debet debet = new Debet();
        debet.setInsurarAmount(Double.parseDouble(sEditInsurarAmount.replaceAll(",",".")));
        debet.setComment(sEditComment);

        if ((!sEditDebetUID.equals(("-1")))&&(sEditDebetUID.length()>0)) {
            Debet oldDebet = Debet.get(sEditDebetUID);
            debet.setCreateDateTime(oldDebet.getCreateDateTime());
        } else {
            debet.setCreateDateTime(getSQLTime());
        }
        if(sEditQuantity.length()==0){
            sEditQuantity="1";
        }
        debet.setQuantity(Integer.parseInt(sEditQuantity));

        debet.setCredited(Integer.parseInt(sEditCredit));
        debet.setDate(ScreenHelper.getSQLDate(sEditDate));
        debet.setEncounterUid(sEditEncounterUID);
        debet.setInsuranceUid(sEditInsuranceUID);
        debet.setInsurarInvoiceUid(sEditInsuranceInvoiceUID);
        debet.setPatientInvoiceUid(sEditPatientInvoiceUID);
        debet.setPrestationUid(sEditPrestationUID);
        debet.setSupplierUid(sEditSupplierUID);
        debet.setUid(sEditDebetUID);
        debet.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        debet.setUpdateUser(activeUser.userid);
        debet.setExtraInsurarUid(sEditExtraInsurarUID);
        if (sEditExtraInsurarUID.length()>0){
            debet.setAmount(0);
            debet.setExtraInsurarAmount(Double.parseDouble(sEditAmount.replaceAll(",",".")));
        }
        else {
            debet.setAmount(Double.parseDouble(sEditAmount.replaceAll(",",".")));
            debet.setExtraInsurarAmount(0);
        }
        String sMessage;
        if (debet.store()) {
            sMessage = getTran("web", "dataissaved", sWebLanguage);
        } else {
            sMessage = getTran("web.control","dberror",sWebLanguage);
            debet.setUid("-1");
        }
%>
{
"Message":"<%=HTMLEntities.htmlentities(sMessage)%>",
"EditDebetUID":"<%=debet.getUid()%>"
}