<%@ page import="be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.Prestation,be.openclinic.finance.Insurance,java.util.Vector,be.openclinic.finance.InsuranceCategory" %>
<%@ page import="java.text.DecimalFormat" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    double dPatientAmount=0,dInsurarAmount=0,dPatientAmount2=0,dInsurarAmount2=0;
	String sPrestationUIDs = checkString(request.getParameter("PrestationUIDs"));
	String sPrestationUID = checkString(request.getParameter("PrestationUID"));
	String sPrestationGroupUID = checkString(request.getParameter("PrestationGroupUID"));
    String sInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
    String sQuantity = checkString(request.getParameter("EditQuantity"));
    String sCoverageInsurance = checkString(request.getParameter("CoverageInsurance"));
    String prestationcontent="",pa="",pi="";
    if(sQuantity.length()==0){
        sQuantity="0";
    }
    int quantity=Integer.parseInt(sQuantity);
    Insurance bestInsurance = null;

    if(sPrestationUIDs.length()>0){
        String type="";
        Insurance insurance=null;
        if(sInsuranceUID.length()==0){
            insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
        }
        else {
            insurance = Insurance.get(sInsuranceUID);
        }
		String[] prestations = sPrestationUIDs.split(";");
        prestationcontent ="<table width='100%'>";
        prestationcontent+="<tr><td width='50%'><b>"+getTran("web","prestation",sWebLanguage)+
        "</b></td><td width='16%'><b>"+getTran("web","quantity",sWebLanguage)+
        "</b></td><td width='16%'><b>"+getTran("web.finance","amount.patient",sWebLanguage)+
        "</b></td><td><b>"+getTran("web.finance","amount.insurar",sWebLanguage)+"</b></td></tr>";
		for(int n=0;n<prestations.length;n++){
	        Prestation prestation = Prestation.get(prestations[n].split("=")[0]);
	        quantity=Integer.parseInt(prestations[n].split("=")[1]);
	        if (insurance != null) {
	            bestInsurance=insurance;
	            type = insurance.getType();

	            if (prestation != null) {
	                double dPrice = prestation.getPrice(type);
	                double dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
	                String sShare=checkString(prestation.getPatientShare(insurance)+"");
	                if (sShare.length()>0){
	                    dPatientAmount2 = quantity * dPrice * Double.parseDouble(sShare) / 100;
	                    dInsurarAmount2 = quantity * dPrice - dPatientAmount2;
	                    if(dInsuranceMaxPrice>-1 && quantity * dInsuranceMaxPrice<dInsurarAmount2){
	                    	dInsurarAmount2=quantity * dInsuranceMaxPrice;
	                   		dPatientAmount2=quantity * dPrice - dInsurarAmount2;
	                    }
	                    dPatientAmount2+=quantity*prestation.getSupplement();
	                    dPatientAmount+=dPatientAmount2;
	                    dInsurarAmount+=dInsurarAmount2;
	                }
	            }
	        }
	        else {
	            dPatientAmount2=quantity * (prestation.getPrice("C")+prestation.getSupplement());
                dPatientAmount+=dPatientAmount2;
	            dInsurarAmount2= 0;
	        }
	        dPatientAmount2+=prestation.getSupplement();
	      	pa=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount2);
	      	pi=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount2);
	        prestationcontent+="<tr>";
	        prestationcontent+="<td><input type='hidden' name='PPC_"+prestation.getUid()+"'/>"+prestation.getDescription()+"</td>";
	        prestationcontent+="<td><input type='hidden' name='PPQ_"+prestation.getUid()+"' value='"+quantity+"'/>"+quantity+"</td>";
	        prestationcontent+="<td "+(sCoverageInsurance.length()>0?"class='strikeonly'":"")+"><input type='hidden' name='PPP_"+prestation.getUid()+"' value='"+pa+"'/>"+pa+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
	        prestationcontent+="<td><input type='hidden' name='PPI_"+prestation.getUid()+"' value='"+pi+"'/>"+pi+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
	        prestationcontent+="</tr>";
		}
        prestationcontent+="</table>";
    }
    else if (sPrestationUID.length() > 0) {
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
                    if(dInsuranceMaxPrice>-1 && quantity * dInsuranceMaxPrice<dInsurarAmount){
                    	dInsurarAmount=quantity * dInsuranceMaxPrice;
                   		dPatientAmount=quantity * dPrice - dInsurarAmount;
                    }
                    dPatientAmount+=quantity * prestation.getSupplement();
                }
            }
        }
        else {
            dPatientAmount=quantity * (prestation.getPrice("C")+prestation.getSupplement());
            dInsurarAmount = 0;
        }
      	pa=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount);
      	pi=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount);
        prestationcontent ="<table width='100%' id='mytable'>";
        prestationcontent+="<tr><td width='50%'><b>"+getTran("web","prestation",sWebLanguage)+
        "</b></td><td width='25%'><b>"+getTran("web.finance","amount.patient",sWebLanguage)+
        "</b></td><td><b>"+getTran("web.finance","amount.insurar",sWebLanguage)+"</b></td></tr>";
        prestationcontent+="<tr>";
        prestationcontent+="<td><input type='hidden' name='PPC_"+prestation.getUid()+"'/>"+prestation.getDescription()+"</td>";
        prestationcontent+="<td "+(sCoverageInsurance.length()>0?"class='strikeonly'":"")+"><input type='hidden' name='PPP_"+prestation.getUid()+"' value='"+pa+"'/>"+pa+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
        prestationcontent+="<td><input type='hidden' name='PPI_"+prestation.getUid()+"' value='"+pi+"'/>"+pi+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
        prestationcontent+="</tr>";
        prestationcontent+="</table>";
    }
    else if(sPrestationGroupUID.length()>0){
        String type="";
        Insurance insurance=null;
        if(sInsuranceUID.length()==0){
            insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
        }
        else {
            insurance = Insurance.get(sInsuranceUID);
        }
        String sSql="select * from oc_prestationgroups_prestations where oc_prestationgroup_groupuid=?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=oc_conn.prepareStatement(sSql);
		ps.setString(1,sPrestationGroupUID);
		ResultSet rs = ps.executeQuery();
        prestationcontent ="<table width='100%'>";
        prestationcontent+="<tr><td width='50%'><b>"+getTran("web","prestation",sWebLanguage)+
        "</b></td><td width='25%'><b>"+getTran("web.finance","amount.patient",sWebLanguage)+
        "</b></td><td><b>"+getTran("web.finance","amount.insurar",sWebLanguage)+"</b></td></tr>";
		while(rs.next()){
	        Prestation prestation = Prestation.get(rs.getString("oc_prestationgroup_prestationuid"));
	        if (insurance != null) {
	            bestInsurance=insurance;
	            type = insurance.getType();

	            if (prestation != null) {
	                double dPrice = prestation.getPrice(type);
	                double dInsuranceMaxPrice = prestation.getInsuranceTariff(insurance.getInsurar().getUid(),insurance.getInsuranceCategoryLetter());
	                String sShare=checkString(prestation.getPatientShare(insurance)+"");
	                if (sShare.length()>0){
	                    dPatientAmount2 = quantity * dPrice * Double.parseDouble(sShare) / 100;
	                    dInsurarAmount2 = quantity * dPrice - dPatientAmount2;
	                    if(dInsuranceMaxPrice>-1 && quantity * dInsuranceMaxPrice<dInsurarAmount2){
	                    	dInsurarAmount2=quantity * dInsuranceMaxPrice;
	                   		dPatientAmount2=quantity * dPrice - dInsurarAmount2;
	                    }
	                    dPatientAmount2+=quantity*prestation.getSupplement();
	                    dPatientAmount+=dPatientAmount2;
	                    dInsurarAmount+=dInsurarAmount2;
	                }
	            }
	        }
	        else {
	            dPatientAmount2=quantity * (prestation.getPrice("C")+prestation.getSupplement());
                dPatientAmount+=dPatientAmount2;
	            dInsurarAmount2= 0;
	        }
	      	pa=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dPatientAmount2);
	      	pi=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(dInsurarAmount2);
	        prestationcontent+="<tr>";
	        prestationcontent+="<td><input type='hidden' name='PPC_"+prestation.getUid()+"'/>"+prestation.getDescription()+"</td>";
	        prestationcontent+="<td "+(sCoverageInsurance.length()>0?"class='strikeonly'":"")+"><input type='hidden' name='PPP_"+prestation.getUid()+"' value='"+pa+"'/>"+pa+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
	        prestationcontent+="<td><input type='hidden' name='PPI_"+prestation.getUid()+"' value='"+pi+"'/>"+pi+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
	        prestationcontent+="</tr>";
		}
        rs.close();
        ps.close();
        oc_conn.close();
        prestationcontent+="</table>";
    }
%>
{
"PrestationContent":"<%=prestationcontent%>",
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
