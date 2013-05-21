<%@page import="be.openclinic.hr.Skill,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sPersonId = checkString(request.getParameter("PersonId"));

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n****************** getSkill.jsp *******************");
	    Debug.println("sPersonId : "+sPersonId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////

    Skill skill = Skill.get(sPersonId);
	
	if(skill!=null){
        %>    
{
  "skillUid":"<%=skill.getUid()%>",
  "languages":"<%=HTMLEntities.htmlentities(skill.languages)%>",
  "drivingLicense":"<%=HTMLEntities.htmlentities(skill.drivingLicense)%>",
  "itOffice":"<%=HTMLEntities.htmlentities(skill.itOffice)%>",
  "itInternet":"<%=HTMLEntities.htmlentities(skill.itInternet)%>",
  "itOther":"<%=HTMLEntities.htmlentities(skill.itOther.replaceAll("\r\n","<br>"))%>",
  "communicationSkills":"<%=HTMLEntities.htmlentities(skill.communicationSkills)%>",
  "stressResistance":"<%=HTMLEntities.htmlentities(skill.stressResistance)%>",
  "comment":"<%=HTMLEntities.htmlentities(skill.comment.replaceAll("\r\n","<br>"))%>"
}
        <%
    }
	else{
        %>    
{
  "skillUid":"-1",
  "languages":"",
  "drivingLicense":"",
  "itOffice":"",
  "itInternet":"",
  "itOther":"",
  "communicationSkills":"",
  "stressResistance":"",
  "comment":""
}
        <%
	}
%>