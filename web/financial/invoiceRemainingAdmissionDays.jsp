<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	try{
	Encounter encounter = Encounter.get(request.getParameter("encounteruid"));
	Insurance insurance = Insurance.get(request.getParameter("insuranceuid"));
	if(encounter!=null  && encounter.getType().equalsIgnoreCase("admission") && Encounter.getAccountedAccomodationDays(encounter.getUid())<encounter.getDurationInDays()){
  		Prestation pStay=null;
        if (encounter.getService()!=null && encounter.getService().stayprestationuid!=null) {
        	pStay = Prestation.get(encounter.getService().stayprestationuid);
        	Debet debet = new Debet();
        	debet.setQuantity(encounter.getDurationInDays()-Encounter.getAccountedAccomodationDays(encounter.getUid()));
            double patientAmount=0,insurarAmount=0;
            double dPrice = pStay.getPrice(insurance.getType());
            if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==1){
            	dPrice+=pStay.getSupplement();
            }
            double dInsuranceMaxPrice = pStay.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
            if(pStay.getMfpAdmissionPercentage()>0){
            	dInsuranceMaxPrice = pStay.getInsuranceTariff(insurance.getInsurar().getUid(),"*H");
            }
            String sShare=checkString(pStay.getPatientShare(insurance)+"");
            if (sShare.length()>0){
            	patientAmount = debet.getQuantity() * dPrice * Double.parseDouble(sShare) / 100;
                insurarAmount = debet.getQuantity() * dPrice - patientAmount;
                if(dInsuranceMaxPrice>=0){
                	insurarAmount=debet.getQuantity() * dInsuranceMaxPrice;
               		patientAmount=debet.getQuantity() * dPrice - insurarAmount;
                }
                if(insurance.getInsurar()!=null && insurance.getInsurar().getNoSupplements()==0 && insurance.getInsurar().getCoverSupplements()==0){
                	patientAmount+=debet.getQuantity()*pStay.getSupplement();
                }
            }

            
            debet.setAmount(patientAmount);
            debet.setInsurarAmount(insurarAmount);
            debet.setPrestationUid(pStay.getUid());
            debet.setInsuranceUid(insurance.getUid());
            debet.setDate(new java.util.Date());
            debet.setEncounterUid(encounter.getUid());
            debet.setCreateDateTime(new java.util.Date());
            debet.setUpdateDateTime(new java.util.Date());
            debet.setUpdateUser(activeUser.userid);
            debet.setServiceUid(encounter.getServiceUID());
            debet.store();
        }
	}
	}
catch(Exception e){
	e.printStackTrace();
}
%>