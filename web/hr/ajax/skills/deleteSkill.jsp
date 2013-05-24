<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Skill"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSkillUid = checkString(request.getParameter("SkillUid"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** deleteSkill.jsp *****************");
        Debug.println("sSkillUid : "+sSkillUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Skill.delete(sSkillUid);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = getTran("web","dataIsDeleted",sWebLanguage);
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}