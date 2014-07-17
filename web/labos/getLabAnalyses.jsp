<%@ page import="be.openclinic.medical.*,java.util.*,be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	String[] newanalyses=checkString(request.getParameter("newanalyses")).split(";");
	String existinganalyses=checkString(request.getParameter("existinganalyses"));
	
	String sOutput="";
	try{
		for(int n=0;n<newanalyses.length;n++){
			//Eerst kijken we of het een analyse is of een profiel
			String analysislist = "";
			if(newanalyses[n].startsWith("^")){
				Debug.println("Seeking for profile "+newanalyses[n].substring(1));
				//Dit is een profiel, haal het op
				Vector anals = LabProfile.searchLabProfilesDataByProfileCode(newanalyses[n].substring(1));
				for(int i=0;i<anals.size();i++){
					if(analysislist.length()>0){
						analysislist+=";";
					}
					analysislist+=(String)((Hashtable)anals.elementAt(i)).get("labID");
				}
			}
			else if(!newanalyses[n].startsWith("$")){
				analysislist=newanalyses[n];
			}
			String[] allanalyses = analysislist.split(";");
			for(int i=0;i<allanalyses.length;i++){
				if(allanalyses[i].length()>0 && (";"+existinganalyses+";").indexOf(";"+allanalyses[i]+";")<0){
					//Toevoegen
					existinganalyses+=allanalyses[i]+";";
					LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabID(allanalyses[i]);
					if(labAnalysis!=null){
						//Deze row outputten
						if(sOutput.length()>0){
							sOutput+="£";
						}
						sOutput+=labAnalysis.getLabcode()+"$"+labAnalysis.getLabtype()+"$"+getTranNoLink("labanalysis",labAnalysis.getLabId()+"",sWebLanguage)+"$"+labAnalysis.getComment()+"$"+labAnalysis.getMonster();
					}
				}
			}
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
	
{
	"analyses":"<%=sOutput%>"
}
