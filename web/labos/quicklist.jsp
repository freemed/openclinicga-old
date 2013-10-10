<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getItemValue(String[] labanalyses,int column, int row){
		for(int n=0;n<labanalyses.length;n++){
			if(labanalyses[n].split("£").length==2 && labanalyses[n].split("£")[1].split("\\.").length==2 && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[1])==row){
				return labanalyses[n].split("£")[0];
			}
		}
		return "";
	}
%>
<form name="transactionForm" id="transactionForm">
	<table width="100%">
	<%
		String sSelectedLabCodes = checkString(request.getParameter("selectedLabCodes"));
		String s = MedwanQuery.getInstance().getConfigString("quickLabList."+activeUser.userid,"");
		if(s.length()==0){
			s=MedwanQuery.getInstance().getConfigString("quickLabList","");
		}
		String[] sLabAnalyses = s.split(";");
		LabAnalysis labAnalysis = null;
		int rows=MedwanQuery.getInstance().getConfigInt("quickLabListRows",20),cols=MedwanQuery.getInstance().getConfigInt("quickLabListCols",2);
		for (int n=0;n<rows;n++){
			String sLine="";
			boolean hasContent=false;
			for(int i=0;i<cols;i++){
				String val=getItemValue(sLabAnalyses,i,n);
				if(val.length()==0){
					sLine+="<td width='"+(100/cols)+"%'/>";
				}
				else if(val.startsWith("$")){
					sLine+="<td class='admin' width='"+(100/cols)+"%'>"+val.substring(1)+"<hr/></td>";
					hasContent=true;
				}
				else if(val.startsWith("^")){
					sLine+="<td class='admin2' width='"+(100/cols)+"%'><input type='checkbox' name='analprof."+val.substring(1)+"' id='analprof."+val.substring(1)+"'/><img width='16px' src='_img/multiple.gif'/> - "+val.substring(1)+"</td>";
					hasContent=true;
				}
				else {
					hasContent=true;
					labAnalysis = LabAnalysis.getLabAnalysisByLabcode(val);
					if(labAnalysis!=null && LabAnalysis.labelForCode(val, sWebLanguage)!=null){
						sLine+="<td width='"+(100/cols)+"%' class='admin2'><input type='checkbox' "+(sSelectedLabCodes.indexOf(val)>-1?"checked":"")+" name='anal."+labAnalysis.getLabId()+"' id='anal."+labAnalysis.getLabId()+"'/><b>"+val+"</b> - "+LabAnalysis.labelForCode(val, sWebLanguage)+"</td>";
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
	<input type="button" name="submit" value="<%=getTran("web","save",sWebLanguage)%>" class="button" onclick="saveLabAnalyses()"/>
</form>

<script>

	function saveLabAnalyses(){
		var selectedLabAnalyses="";
		var allLabAnalyses = document.getElementById("transactionForm").elements;
		for(n=0;n<allLabAnalyses.length;n++){
			if(allLabAnalyses[n].name.indexOf("anal.")==0 && allLabAnalyses[n].checked){
				if(selectedLabAnalyses.length>0){
					selectedLabAnalyses=selectedLabAnalyses+";";
				}
				selectedLabAnalyses=selectedLabAnalyses+allLabAnalyses[n].name.substring(5);
			}
			else if(allLabAnalyses[n].name.indexOf("analprof.")==0 && allLabAnalyses[n].checked){
				if(selectedLabAnalyses.length>0){
					selectedLabAnalyses=selectedLabAnalyses+";";
				}
				selectedLabAnalyses=selectedLabAnalyses+"^"+allLabAnalyses[n].name.substring(9);
			}
		}
		window.opener.addQuickListAnalyses(selectedLabAnalyses);
		window.close();
	}
	
</script>