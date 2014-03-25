<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.text.*,be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	try{
		String sNewInvoiceUid="";
		String sOldInvoiceUid=checkString(request.getParameter("invoiceuid"));
		PatientInvoice oldInvoice = PatientInvoice.get(sOldInvoiceUid);
		if(oldInvoice!=null && oldInvoice.getUid()!=null && oldInvoice.getUid().split("\\.").length==2){
			//First store new invoice
			PatientInvoice newInvoice= PatientInvoice.get(sOldInvoiceUid);
			newInvoice.setAcceptationDate("");
			newInvoice.setAcceptationUid("");
			newInvoice.setDerivedFrom(sOldInvoiceUid);
			newInvoice.setStatus("open");
			newInvoice.setUid("");
			Vector debets = newInvoice.getDebets();
			//Create new debets
			for(int n=0; n<debets.size();n++){
				Debet debet = (Debet)debets.elementAt(n);
	            debet.setUid("");
	            debet.store();
			}
			newInvoice.store();
			sNewInvoiceUid=newInvoice.getUid();
			//Link to existing invoice
			if(Pointer.getPointer("DERIVED."+sNewInvoiceUid).length()==0){
				Pointer.storePointer("DERIVED."+sNewInvoiceUid, sOldInvoiceUid);
			}
			if(Pointer.getPointer("FOLLOW."+sOldInvoiceUid).length()==0){
				Pointer.storePointer("FOLLOW."+sOldInvoiceUid,sNewInvoiceUid );
			}
			
			//Cancel existing invoice
			oldInvoice.setStatus("canceled");
			debets = oldInvoice.getDebets();
			//Cancel debets
			for(int n=0; n<debets.size();n++){
				Debet debet = (Debet)debets.elementAt(n);
	            debet.setAmount(0);
	            debet.setInsurarAmount(0);
	            debet.setCredited(1);
	            debet.store();
			}
			//Remove patientcredits
			oldInvoice.setCredits(new Vector());
			oldInvoice.store();
		}
		
		out.print("{\"invoiceuid\":\""+sNewInvoiceUid+"\"}");
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>