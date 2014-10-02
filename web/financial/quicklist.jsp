<%@ page import="be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getItemValue(String[] prestations,int column, int row){
		for(int n=0;n<prestations.length;n++){
			if(prestations[n].split("£").length>=2 && prestations[n].split("£")[1].split("\\.").length==2 && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[1])==row){
				return prestations[n].split("£")[0];
			}
		}
		return "";
	}
	public String getItemColor(String[] prestations,int column, int row){
		for(int n=0;n<prestations.length;n++){
			if(prestations[n].split("£").length>=3 && prestations[n].split("£")[2].length()>0 && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[1])==row){
				return prestations[n].split("£")[2];
			}
		}
		return "";
	}
%>
<%
	String sInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
	String sQuantity = checkString(request.getParameter("EditQuantity"));
	String sCoverageInsurance = checkString(request.getParameter("CoverageInsurance"));
	String prestationcontent="",pa="",pi="";
	if(sQuantity.length()==0){
	    sQuantity="0";
	}
	int quantity=Integer.parseInt(sQuantity);
	Insurance bestInsurance = null;
%>
<form name="transactionForm" id="transactionForm">
	<table width="100%">
	<%
		String s = MedwanQuery.getInstance().getConfigString("quickList."+activeUser.userid,"");
		if(s.length()==0){
			s=MedwanQuery.getInstance().getConfigString("quickList","");
		}
		String[] sPrestations = s.split(";");
		Prestation prestation = null;
		int rows=MedwanQuery.getInstance().getConfigInt("quickListRows",20),cols=MedwanQuery.getInstance().getConfigInt("quickListCols",2);
		for (int n=0;n<rows;n++){
			String sLine="";
			boolean hasContent=false;
			for(int i=0;i<cols;i++){
				String val=getItemValue(sPrestations,i,n);
				if(val.length()==0){
					sLine+="<td width='"+(100/cols)+"%'/>";
				}
				else if(val.startsWith("$")){
					sLine+="<td class='admin' width='"+(100/cols)+"%'>"+val.substring(1)+"<hr/></td>";
					hasContent=true;
				}
				else {
					hasContent=true;
					prestation = Prestation.getByCode(val);
					if(prestation!=null && prestation.getDescription()!=null){
						sLine+="<td bgcolor='"+getItemColor(sPrestations,i,n)+"' width='"+(100/cols)+"%'><input type='checkbox' name='prest."+prestation.getUid()+"' id='prest."+prestation.getUid()+"'/><input type='text' class='text' name='quant."+prestation.getUid()+"' id='quant."+prestation.getUid()+"' value='1' size='1'/>"+prestation.getDescription()+"</td>";
					}
					else {
						sLine+="<td width='"+(100/cols)+"%'><font color='red'>Error loading "+val+"</font></td>";
					}
				}
			}
			if(hasContent){
				out.println("<tr>"+sLine+"</tr>");
			}
		}
	%>
	</table>
	<input type="button" name="submit" value="<%=getTranNoLink("web","save",sWebLanguage)%>" class="button" onclick="savePrestations()"/>
	<%if(MedwanQuery.getInstance().getConfigInt("enableQuickInvoicing",0)==1){ %>
	<input type="button" class="redbutton" name="submit" value="<%=getTranNoLink("web","save.and.quickinvoice",sWebLanguage)%>" onclick="savePrestationsAndInvoice()"/>
	<%} %>
</form>

<script>

function savePrestations(){
	var selectedPrestations="";
	var allPrestations = document.getElementById("transactionForm").elements;
	for(n=0;n<allPrestations.length;n++){
		if(allPrestations[n].name.indexOf("prest.")==0 && allPrestations[n].checked){
			//register prestation in window opener
			if(selectedPrestations.length>0){
				selectedPrestations=selectedPrestations+";";
			}
			selectedPrestations=selectedPrestations+allPrestations[n].name.substring(6)+"="+document.getElementById("quant."+allPrestations[n].name.substring(6)).value;
		}
	}
	window.opener.changeQuicklistPrestations(selectedPrestations,false);
	window.close();
}

function savePrestationsAndInvoice(){
	var selectedPrestations="";
	var allPrestations = document.getElementById("transactionForm").elements;
	for(n=0;n<allPrestations.length;n++){
		if(allPrestations[n].name.indexOf("prest.")==0 && allPrestations[n].checked){
			//register prestation in window opener
			if(selectedPrestations.length>0){
				selectedPrestations=selectedPrestations+";";
			}
			selectedPrestations=selectedPrestations+allPrestations[n].name.substring(6)+"="+document.getElementById("quant."+allPrestations[n].name.substring(6)).value;
		}
	}
	window.opener.changeQuicklistPrestations(selectedPrestations,true);
	window.close();
}

</script>