<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
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
			pars+=labanalysis+"£"+name.split("\\.")[1]+"."+name.split("\\.")[2];
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
					<td class='admin2' width='1%' nowrap>
						<input name="anal.<%=i%>.<%=n%>" id="anal.<%=i%>.<%=n%>" type="text" class="text" value="<%=getItemValue(sLabAnalyses,i,n)%>"/>
						<img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchLabAnalysis('<%=i+"."+n%>');">
					</td>
			<%
					String val=getItemValue(sLabAnalyses,i,n);
					if(val.length()>0){
						if(val.startsWith("$")){
							out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin'>"+val.substring(1)+"<hr/></td>");
						}
						else {
							LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(val);
							if(labAnalysis!=null && LabAnalysis.labelForCode(val, sWebLanguage)!=null){
								out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'>"+LabAnalysis.labelForCode(val, sWebLanguage)+"</td>");
							}
							else {
								out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'><font color='red'>Code not found</font></td>");
							}
						}
					}
					else {
						out.println("<td id='analysisname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'>&nbsp;</td>");
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
	document.getElementById('analysisname.'+id).value='';
    openPopup("/_common/search/searchLabAnalysis.jsp&ts=<%=getTs()%>&VarCode=anal."+id+"&VarTextHtml=analysisname."+id);
}
</script>
