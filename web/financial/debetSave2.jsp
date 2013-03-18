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
        String sEditExtraInsurarUID2 = checkString(request.getParameter("EditExtraInsurarUID2"));
        String sEditCareProvider = checkString(request.getParameter("EditCareProvider"));
        String sEditServiceUid = checkString(request.getParameter("EditServiceUid"));
        String sEditExtraInsurarAmount="",sEditExtraInsurarAmount2="";
		boolean bSuccess=true;
		Vector debets = new Vector();
        Enumeration e = request.getParameterNames();
        while(e.hasMoreElements()){
        	String parameterName = (String)e.nextElement();
        	if(parameterName.startsWith("PPC_")){
        		String sPrestationUid=parameterName.split("_")[1];
        		String sPatientAmount = request.getParameter("PPP_"+sPrestationUid);
        		String sInsurarAmount = request.getParameter("PPI_"+sPrestationUid);
		        Debet debet = new Debet();
		        debet.setInsurarAmount(Double.parseDouble(sInsurarAmount.replaceAll(",",".")));
		        debet.setComment(sEditComment);
		
		        if ((!sEditDebetUID.equals(("-1")))&&(sEditDebetUID.length()>0)) {
		            Debet oldDebet = Debet.get(sEditDebetUID);
		            debet.setCreateDateTime(oldDebet.getCreateDateTime());
		            debet.setRefUid(oldDebet.getRefUid());
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
		        debet.setInsuranceUid(sEditInsuranceUID);
		        debet.setInsurarInvoiceUid(sEditInsuranceInvoiceUID);
		        debet.setPatientInvoiceUid(sEditPatientInvoiceUID);
		        debet.setPrestationUid(sPrestationUid);
		        debet.setServiceUid(debet.determineServiceUidWithoutEncounterValidation(sEditServiceUid));
		        debet.setEncounterUid(sEditEncounterUID);
		        debet.setSupplierUid(sEditSupplierUID);
		        debet.setUid(sEditDebetUID);
		        debet.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
		        debet.setUpdateUser(activeUser.userid);
		        debet.setExtraInsurarUid(sEditExtraInsurarUID);
		        debet.setPerformeruid(sEditCareProvider);
		        if(request.getParameter("PPE_"+sPrestationUid)!=null){
		        	sEditExtraInsurarAmount=checkString(request.getParameter("PPE_"+sPrestationUid));
		        }
				if(sEditExtraInsurarAmount.length()==0){
					debet.setExtraInsurarAmount(0);
				}
				else {
					debet.setExtraInsurarAmount(Double.parseDouble(sEditExtraInsurarAmount));
				}
				
		        if (sEditExtraInsurarUID2.length()>0){
		            debet.setExtraInsurarUid2(sEditExtraInsurarUID2);
		        }
	            debet.setAmount(Double.parseDouble(sPatientAmount.replaceAll(",",".")));
		        if(!debet.store()){
		        	bSuccess=false;
		        	debet.setUid("-1");
		        }
		        else {
		        	debets.add(debet);
		        }
        	}
        }
        e = request.getParameterNames();
        while(e.hasMoreElements()){
        	String parameterName = (String)e.nextElement();
        	if(parameterName.startsWith("PPU_") && parameterName.split("_").length>1){
        		String sPrestationUid=parameterName.split("_")[1];
        		if(sPrestationUid.split("£").length>1){
	        		String childPrestation = sPrestationUid.split("£")[0];
	        		String parentPrestation = sPrestationUid.split("£")[1];
					for(int n=0;n<debets.size();n++){
						Debet debet = (Debet)debets.elementAt(n);
						if(debet.getPrestationUid().equalsIgnoreCase(parentPrestation)){
							for(int i=0;i<debets.size();i++){
								Debet debet2 = (Debet)debets.elementAt(i);
								if(debet2.getPrestationUid().equalsIgnoreCase(childPrestation)){
									debet.setRefUid(debet2.getUid());
									debet.store();
								}
							}
						}
					}
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