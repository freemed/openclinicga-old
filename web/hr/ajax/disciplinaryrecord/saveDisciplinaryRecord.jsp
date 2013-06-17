<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.DisciplinaryRecord"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditDisRecUid = checkString(request.getParameter("EditDisRecUid")),
           sPersonId      = checkString(request.getParameter("PersonId"));

    String sDate        = checkString(request.getParameter("date")),
           sTitle       = checkString(request.getParameter("title")),
           sDescription = checkString(request.getParameter("description")),
           sDecision    = checkString(request.getParameter("decision")),
           sDuration    = checkString(request.getParameter("duration")),
           sDecisionBy  = checkString(request.getParameter("decisionBy")),
           sFollowUp    = checkString(request.getParameter("followUp"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************ saveDisciplinaryRecord.jsp ***********");
        Debug.println("sEditDisRecUid : "+sEditDisRecUid);
        Debug.println("sPersonId      : "+sPersonId);
        Debug.println("sDate          : "+sDate);
        Debug.println("sTitle         : "+sTitle);
        Debug.println("sDescription   : "+sDescription);
        Debug.println("sDecision      : "+sDecision);
        Debug.println("sDuration      : "+sDuration);
        Debug.println("sDecisionBy    : "+sDecisionBy);
        Debug.println("sFollowUp      : "+sFollowUp+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    DisciplinaryRecord disRec = new DisciplinaryRecord();
    disRec.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditDisRecUid.length() > 0){
        disRec.setUid(sEditDisRecUid);
    }
    else{
        disRec.setUid("-1");
        disRec.setCreateDateTime(getSQLTime());
    }

    if(sDate.length() > 0){
        disRec.date = ScreenHelper.stdDateFormat.parse(sDate);
    }
    
    disRec.title = sTitle;
    disRec.description = sDescription;
    disRec.decision = sDecision;
    if(sDuration.length() > 0){
        disRec.duration = Integer.parseInt(sDuration);
    }
    disRec.decisionBy = sDecisionBy;
    disRec.followUp = sFollowUp;
    disRec.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    disRec.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = disRec.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTranNoLink("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=disRec.getUid()%>"
}