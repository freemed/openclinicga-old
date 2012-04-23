<%@ page import="be.openclinic.finance.*" %>
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
        String sEditInsuranceInvoiceUID = checkString(request.getParameter("EditInsuranceInvoiceUID"));
        String sEditComment = checkString(request.getParameter("EditComment"));
        String sEditCredit = checkString(request.getParameter("EditCredit"));
        String sEditQuantity = checkString(request.getParameter("EditQuantity"));
		boolean bSuccess=true;
        Enumeration e = request.getParameterNames();
        while(e.hasMoreElements()){
        	String parameterName = (String)e.nextElement();
        	if(parameterName.startsWith("PPC_")){
        		String sPrestationUid=parameterName.split("_")[1];
        		String sPatientAmount = request.getParameter("PPP_"+sPrestationUid);
        		String sInsurarAmount = request.getParameter("PPI_"+sPrestationUid);
		        PrestationDebet debet = new PrestationDebet();
		        debet.setInsurarAmount(Double.parseDouble(sInsurarAmount.replaceAll(",",".")));
		        debet.setComment(sEditComment);
		
		        if ((!sEditDebetUID.equals(("-1")))&&(sEditDebetUID.length()>0)) {
		            PrestationDebet oldDebet = PrestationDebet.get(sEditDebetUID);
		            debet.setCreateDateTime(oldDebet.getCreateDateTime());
		        } else {
		            debet.setCreateDateTime(getSQLTime());
		        }
		        if(request.getParameter("PPQ_"+sPrestationUid)!=null){
		        	sEditQuantity=checkString(request.getParameter("PPQ_"+sPrestationUid));
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
		        debet.setPrestationUid(sPrestationUid);
		        debet.setUid(sEditDebetUID);
		        debet.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
		        debet.setUpdateUser(activeUser.userid);
	            debet.setAmount(Double.parseDouble(sPatientAmount.replaceAll(",",".")));
	            debet.setExtraInsurarAmount(0);
	            if(!debet.store()){
		        	bSuccess=false;
		        	debet.setUid("-1");
		        }
        	}
        }
        String sMessage;
        if (bSuccess) {
            sMessage = getTran("web", "dataissaved", sWebLanguage);
        } else {
            sMessage = getTran("web.control","dberror",sWebLanguage);
        }
%>
{
"Message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}