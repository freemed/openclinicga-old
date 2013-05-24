<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Training,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditTrainingUid = checkString(request.getParameter("EditTrainingUid")),
           sPersonId        = checkString(request.getParameter("PersonId"));

    String sBegin        = checkString(request.getParameter("begin")),
           sEnd          = checkString(request.getParameter("end")),
           sInstitute    = checkString(request.getParameter("institute")),
           sType         = checkString(request.getParameter("type")),
           sLevel        = checkString(request.getParameter("level")),
           sDiploma      = checkString(request.getParameter("diploma")),
           sDiplomaDate  = checkString(request.getParameter("diplomaDate")),
           sDiplomaCode1 = checkString(request.getParameter("diplomaCode1")),
           sDiplomaCode2 = checkString(request.getParameter("diplomaCode2")),
           sDiplomaCode3 = checkString(request.getParameter("diplomaCode3")),
           sComment      = checkString(request.getParameter("comment"));


    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** saveTraining.jsp *****************");
        Debug.println("sEditTrainingUid : "+sEditTrainingUid);
        Debug.println("sPersonId     : "+sPersonId);
        Debug.println("sBegin        : "+sBegin);
        Debug.println("sEnd          : "+sEnd);
        Debug.println("sInstitute    : "+sInstitute);
        Debug.println("sType         : "+sType);
        Debug.println("sLevel        : "+sLevel);
        Debug.println("sDiploma      : "+sDiploma);
        Debug.println("sDiplomaDate  : "+sDiplomaDate);
        Debug.println("sDiplomaCode1 : "+sDiplomaCode1);
        Debug.println("sDiplomaCode2 : "+sDiplomaCode2);
        Debug.println("sDiplomaCode3 : "+sDiplomaCode3);
        Debug.println("sComment      : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    Training training = new Training();
    training.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditTrainingUid.length() > 0){
        training.setUid(sEditTrainingUid);
    }
    else{
        training.setUid("-1");
        training.setCreateDateTime(getSQLTime());
    }

    if(sBegin.length() > 0){
        training.begin = ScreenHelper.stdDateFormat.parse(sBegin);
    }
    if(sEnd.length() > 0){
        training.end = ScreenHelper.stdDateFormat.parse(sEnd);
    }

    training.institute = sInstitute;
    training.type = sType;
    training.level = sLevel;
    training.diploma = sDiploma;
    
    if(sDiplomaDate.length() > 0){
        training.diplomaDate = ScreenHelper.stdDateFormat.parse(sDiplomaDate);
    }
    
    training.diplomaCode1 = sDiplomaCode1;
    training.diplomaCode2 = sDiplomaCode2;
    training.diplomaCode3 = sDiplomaCode3;
    training.comment = sComment;
    training.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    training.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = training.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=training.getUid()%>"
}