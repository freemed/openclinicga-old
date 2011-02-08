<%@ page import="be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getItemValue(String[] prestations,int column, int row){
		for(int n=0;n<prestations.length;n++){
			if(prestations[n].split("\\.").length==3 && Integer.parseInt(prestations[n].split("\\.")[1])==column && Integer.parseInt(prestations[n].split("\\.")[2])==row){
				return prestations[n].split("\\.")[0];
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
						sLine+="<td width='"+(100/cols)+"%' class='admin2'><input type='checkbox' name='prest."+prestation.getUid()+"' id='prest."+prestation.getUid()+"'/><input type='text' class='text' name='quant."+prestation.getUid()+"' id='quant."+prestation.getUid()+"' value='1' size='1'/>"+prestation.getDescription()+"</td>";
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
	<input type="button" name="submit" value="<%=getTran("web","save",sWebLanguage)%>" class="button" onclick="savePrestations()"/>
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
		window.opener.changeQuicklistPrestations(selectedPrestations);
		window.close();
	}
	
</script>