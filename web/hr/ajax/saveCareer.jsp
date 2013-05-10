<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Career,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditCareerUid = checkString(request.getParameter("EditCareerUid"));

	String sCareerBegin = checkString(request.getParameter("careerBegin")),
	       sCareerEnd   = checkString(request.getParameter("careerEnd")),
	       sPosition    = checkString(request.getParameter("position")),
	       sServiceUid  = checkString(request.getParameter("serviceUid")),
	       sGrade       = checkString(request.getParameter("grade")),
	       sStatus      = checkString(request.getParameter("status")),
	       sComment     = checkString(request.getParameter("comment"));
       
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("");
	    Debug.println("******************* saveCareer.jsp *******************");
	    Debug.println("sEditCareerUid : "+sEditCareerUid);
	    Debug.println("sCareerBegin   : "+sCareerBegin);
	    Debug.println("sCareerEnd     : "+sCareerEnd);
	    Debug.println("sPosition      : "+sPosition);
	    Debug.println("sServiceUid    : "+sServiceUid);
	    Debug.println("sGrade         : "+sGrade);
	    Debug.println("sStatus        : "+sStatus);
	    Debug.println("sComment       : "+sComment);
	    Debug.println("");
	}
	///////////////////////////////////////////////////////////////////////////


    Career career = new Career();
	String sMessage = "";
	
    if(sEditCareerUid.length() > 0){
    	career.setUid(sEditCareerUid);
    }
    else{
    	career.setUid("-1");
        career.setCreateDateTime(getSQLTime());
    }

    if(sCareerBegin.length() > 0){
        career.begin = ScreenHelper.stdDateFormat.parse(sCareerBegin);
    }
    if(sCareerEnd.length() > 0){
        career.end = ScreenHelper.stdDateFormat.parse(sCareerEnd);
    }
    
    career.position = sPosition;
    career.serviceUid = sServiceUid;
    career.grade = sGrade;
    career.status = sStatus;
    career.comment = sComment;
    career.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    career.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = career.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = getTran("web","dataIsSaved",sWebLanguage);
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=career.getUid()%>"
}