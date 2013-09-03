<%@page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String[] sLabs = checkString(request.getParameter("SelectedLabAnalyses")).split(";");
String sSelectedLabAnalyses="";
	for(int n=0;n<sLabs.length;n++){
		LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabID(sLabs[n]);
		if(labAnalysis!=null){
			if(sSelectedLabAnalyses.length()>0){
				sSelectedLabAnalyses+="$";
			}
			sSelectedLabAnalyses+=labAnalysis.getLabcode()+";"+labAnalysis.getLabtype()+";"+LabAnalysis.labelForCode(labAnalysis.getLabcode(), sWebLanguage)+";"+labAnalysis.getComment()+";"+getTranNoLink("labanalysis.monster",labAnalysis.getMonster(),sWebLanguage);
		}
	}
%>
{
"SelectedLabAnalyses":"<%=sSelectedLabAnalyses%>"
}