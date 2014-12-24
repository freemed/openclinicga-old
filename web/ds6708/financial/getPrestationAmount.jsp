<%@ page import="be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.Prestation,be.openclinic.finance.Insurance,java.util.Vector,be.openclinic.finance.InsuranceCategory" %>
<%@ page import="java.text.DecimalFormat" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    double dPatientAmount=0,dInsurarAmount=0;
    String sPrestationUID = checkString(request.getParameter("PrestationUID"));
    String sInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
    String sQuantity = checkString(request.getParameter("EditQuantity"));
    if(sQuantity.length()==0){
        sQuantity="1";
    }
    int quantity=Integer.parseInt(sQuantity);
    Insurance bestInsurance = null;

    if (sPrestationUID.length() > 0) {
        String type="";
        Insurance insurance=null;
        if(sInsuranceUID.length()==0){
            insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
        }
        else {
            insurance = Insurance.get(sInsuranceUID);
        }
        Prestation prestation = Prestation.get(sPrestationUID);
        if (insurance != null) {
            bestInsurance=insurance;
            type = insurance.getType();

            if (prestation != null) {
                double dPrice = prestation.getPrice(type);
                double dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
                String sShare=checkString(prestation.getPatientShare(insurance)+"");
                if (sShare.length()>0){
                    dPatientAmount = quantity * dPrice * Double.parseDouble(sShare) / 100;
                    dInsurarAmount = quantity * dPrice - dPatientAmount;
                    if(dInsuranceMaxPrice>-1 && dInsuranceMaxPrice<dInsurarAmount){
                    	dInsurarAmount=dInsuranceMaxPrice;
                   		dPatientAmount=quantity * dPrice - dInsurarAmount;
                    }
                }
            }
        }
        else {
            dPatientAmount=quantity * prestation.getPrice("C");
            dInsurarAmount = 0;
        }
    }
%>
{
"EditAmount":"<%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount)%>",
"EditInsurarAmount":"<%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount)%>"
<%
    if (sInsuranceUID.length()==0 && bestInsurance!=null){
        %>
        ,"EditInsuranceUID":"<%=HTMLEntities.htmlentities(bestInsurance.getUid())%>"
        ,"EditInsuranceName":"<%=HTMLEntities.htmlentities(bestInsurance.getInsurar().getName())%>"
        <%
    }
%>
}
