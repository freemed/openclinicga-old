<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Skill,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditSkillUid = checkString(request.getParameter("EditSkillUid")),
           sPersonId     = checkString(request.getParameter("PersonId"));

    String sLanguages           = checkString(request.getParameter("languages")),
           sDrivingLicense      = checkString(request.getParameter("drivingLicense")),
           sItOffice            = checkString(request.getParameter("itOffice")),
           sItInternet          = checkString(request.getParameter("itInternet")),
           sItOther             = checkString(request.getParameter("itOther")),
           sCommunicationSkills = checkString(request.getParameter("communicationSkills")),
           sStressResistance    = checkString(request.getParameter("stressResistance")),
           sComment             = checkString(request.getParameter("comment"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** saveSkill.jsp ******************");
        Debug.println("sEditSkillUid        : "+sEditSkillUid);
        Debug.println("sPersonId            : "+sPersonId);
        Debug.println("sLanguages           : "+sLanguages);
        Debug.println("sDrivingLicense      : "+sDrivingLicense);
        Debug.println("sItOffice            : "+sItOffice);
        Debug.println("sItInternet          : "+sItInternet);
        Debug.println("sItOther             : "+sItOther);
        Debug.println("sCommunicationSkills : "+sCommunicationSkills);
        Debug.println("sStressResistance    : "+sStressResistance);
        Debug.println("sComment             : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

	
	    Skill skill = new Skill();
	    skill.personId = Integer.parseInt(sPersonId);
	    String sMessage = "";
	    
	    if(sEditSkillUid.length() > 0){
	        skill.setUid(sEditSkillUid);
	    }
	    else{
	        skill.setUid("-1");
	        skill.setCreateDateTime(getSQLTime());
	    }
	
	    skill.languages = sLanguages;
	    skill.drivingLicense = sDrivingLicense;
	    skill.itOffice = sItOffice;
	    skill.itInternet = sItInternet;
	    skill.itOther = sItOther;
	    skill.communicationSkills = sCommunicationSkills;
	    skill.stressResistance = sStressResistance;
	    skill.comment = sComment;
	    skill.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
	    skill.setUpdateUser(activeUser.userid);
	    
	    boolean errorOccurred = skill.store(activeUser.userid);
	    
	    if(!errorOccurred){
	        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
	    }
	    else{
	        sMessage = getTran("web","error",sWebLanguage);
	    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=skill.getUid()%>"
}