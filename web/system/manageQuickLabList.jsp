<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getItemValue(String[] labanalyses,int column, int row){
		for(int n=0;n<labanalyses.length;n++){
			if(labanalyses[n].split("£").length>=2 && labanalyses[n].split("£")[1].split("\\.").length==2 && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[1])==row){
				return labanalyses[n].split("£")[0];
			}
		}
		return "";
	}
	public String getItemColor(String[] labanalyses,int column, int row){
		for(int n=0;n<labanalyses.length;n++){
			if(labanalyses[n].split("£").length>=3 && labanalyses[n].split("£")[2].split("\\.").length>0 && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(labanalyses[n].split("£")[1].split("\\.")[1])==row){
				return labanalyses[n].split("£")[2];
			}
		}
		return "";
	}
%>
<%
	if(request.getParameter("submit")!=null){
		Enumeration parameterNames = request.getParameterNames();
		SortedMap labanalyses = new TreeMap();
		while(parameterNames.hasMoreElements()){
			String parameterName = (String)parameterNames.nextElement();
			if(parameterName.startsWith("anal.")){
				String parameterValue=request.getParameter(parameterName);
				if(parameterValue.startsWith("$")){
					labanalyses.put(parameterName,parameterValue);
				}
				else if(parameterValue.startsWith("^")){
					labanalyses.put(parameterName,parameterValue);
				}
				else {
					LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(parameterValue);
					if (labAnalysis!=null && LabAnalysis.labelForCode(parameterValue, sWebLanguage)!=null){
						labanalyses.put(parameterName,parameterValue);
					}
				}
			}
		}
		String pars = "";
		Iterator p = labanalyses.keySet().iterator();
		while(p.hasNext()){
			String name=(String)p.next();
			String labanalysis = (String)labanalyses.get(name);
			if(pars.length()>0){
				pars+=";";
			}
			pars+=labanalysis+"£"+name.split("\\.")[1]+"."+name.split("\\.")[2]+"£"+checkString(request.getParameter(name.replace("anal.", "analysiscolor.")));
		}
		if(request.getParameter("UserQuickLabList")!=null){
			MedwanQuery.getInstance().setConfigString("quickLabList."+activeUser.userid,pars);
		}
		else {
			MedwanQuery.getInstance().setConfigString("quickLabList",pars);
		}
	}

	String[] sLabAnalyses = MedwanQuery.getInstance().getConfigString("quickLabList","").split(";");
	if(request.getParameter("UserQuickLabList")!=null){
		sLabAnalyses = MedwanQuery.getInstance().getConfigString("quickLabList."+activeUser.userid,"").split(";");
	}
	int rows=MedwanQuery.getInstance().getConfigInt("quickLabListRows",20),cols=MedwanQuery.getInstance().getConfigInt("quickLabListCols",2);
%>
<%=getTran("web","click.code.field.to.choose.color",sWebLanguage) %>

<form name="transactionForm" method="post">
	<table width="100%">
		<%
			out.println("<tr>");
			for(int n=0;n<cols;n++){
				out.println("<td class='admin'>"+getTran("web","code",sWebLanguage)+"</td>");
				out.println("<td class='admin'>"+getTran("web","description",sWebLanguage)+"</td>");
			}
			out.println("</tr>");
			for(int n=0;n<rows;n++){
		%>
				<tr>
			<%
				for(int i=0;i<cols;i++){
			%>
					<td id="anal.<%=i%>.<%=n%>" bgcolor='<%=getItemColor(sLabAnalyses,i,n)%>' width='1%' nowrap>
						<input onclick="chooseColor('<%=i%>.<%=n%>');" name="anal.<%=i%>.<%=n%>" type="text" class="text" value="<%=getItemValue(sLabAnalyses,i,n)%>"/>
						<input name="analysiscolor.<%=i%>.<%=n%>" id="analysiscolor.<%=i%>.<%=n%>" type="hidden" value="<%=getItemColor(sLabAnalyses,i,n)%>"/>
						<img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchLabAnalysis('<%=i+"."+n%>');">
					</td>
			<%
					String val=getItemValue(sLabAnalyses,i,n);
					if(val.length()>0){
						if(val.startsWith("$")){
							out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin'>"+val.substring(1)+"<hr/></td>");
						}
						if(val.startsWith("^")){
							//Todo: labprofile opzoeken!
							out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'><img width='16px' src='_img/multiple.gif'/> - "+val.substring(1)+"</td>");
						}
						else {
							LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(val);
							if(labAnalysis!=null && LabAnalysis.labelForCode(val, sWebLanguage)!=null){
								out.println("<td id='analysisname."+i+"."+n+"' bgcolor='"+getItemColor(sLabAnalyses,i,n)+"' width='"+(100/cols)+"%'>"+LabAnalysis.labelForCode(val, sWebLanguage)+"</td>");
							}
							else {
								out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%'><font color='red' class='admin2'>Code not found</font></td>");
							}
						}
					}
					else {
						out.println("<td id='analysisname."+i+"."+n+"' bgcolor='"+getItemColor(sLabAnalyses,i,n)+"' width='"+(100/cols)+"%'>&nbsp;</td>");
					}
				}
			%>
				</tr>
		<%
			}
		%>
	</table>
	<input type="submit" class="button" name="submit" value="<%=getTran("web","save",sWebLanguage)%>"/>
</form>
<script>
function searchLabAnalysis(id){
	document.getElementById('anal.'+id).value='';
	document.getElementById('analysisname.'+id).innerHTML='';
    openPopup("/_common/search/searchLabAnalysisAndGroups.jsp&ts=<%=getTs()%>&VarCode=anal."+id+"&VarTextHtml=analysisname."+id);
}

function chooseColor(id){
    openPopup("/util/colorPicker.jsp&ts=<%=getTs()%>&colorfields=anal."+id+";analysisname."+id+"&valuefield=analysiscolor."+id+"&defaultcolor="+document.getElementById("analysiscolor."+id).value);
}
</script>
