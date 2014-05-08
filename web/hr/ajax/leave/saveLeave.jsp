<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Leave,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditLeaveUid = checkString(request.getParameter("EditLeaveUid")),
           sPersonId      = checkString(request.getParameter("PersonId"));

    String sBegin       = checkString(request.getParameter("begin")),
           sEnd         = checkString(request.getParameter("end")),
           sDuration    = checkString(request.getParameter("duration")),
           sType        = checkString(request.getParameter("type")),
           sRequestDate       = checkString(request.getParameter("requestDate")),
           sAuthorizationDate = checkString(request.getParameter("authorizationDate")),
           sAuthorizedBy      = checkString(request.getParameter("authorizedBy")),
           sEpisodeCode       = checkString(request.getParameter("episodeCode")),
           sComment           = checkString(request.getParameter("comment"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** saveLeave.jsp ******************");
        Debug.println("sEditLeaveUid : "+sEditLeaveUid);
        Debug.println("sPersonId     : "+sPersonId);
        Debug.println("sBegin        : "+sBegin);
        Debug.println("sEnd          : "+sEnd);
        Debug.println("sDuration     : "+sDuration);
        Debug.println("sType         : "+sType);
        Debug.println("sRequestDate       : "+sRequestDate);
        Debug.println("sAuthorizationDate : "+sAuthorizationDate);
        Debug.println("sAuthorizedBy      : "+sAuthorizedBy);
        Debug.println("sEpisodeCode       : "+sEpisodeCode);
        Debug.println("sComment           : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    Leave leave = new Leave();
    leave.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditLeaveUid.length() > 0){
        leave.setUid(sEditLeaveUid);
    }
    else{
        leave.setUid("-1");
        leave.setCreateDateTime(getSQLTime());
    }

    if(sBegin.length() > 0){
        leave.begin = ScreenHelper.parseDate(sBegin);
    }
    if(sEnd.length() > 0){
        leave.end = ScreenHelper.parseDate(sEnd);
    }    
    if(sDuration.length() > 0){
        leave.duration = Double.parseDouble(sDuration);
    }
    leave.type = sType;
    if(sRequestDate.length() > 0){
        leave.requestDate = ScreenHelper.parseDate(sRequestDate);
    }
    if(sAuthorizationDate.length() > 0){
        leave.authorizationDate = ScreenHelper.parseDate(sAuthorizationDate);
    }
    leave.authorizedBy = sAuthorizedBy;
    leave.episodeCode = sEpisodeCode;
    leave.comment = sComment;
    leave.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    leave.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = leave.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=leave.getUid()%>"
}