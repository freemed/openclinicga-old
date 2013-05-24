<%@page import="be.openclinic.hr.Training,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sTrainingUid = checkString(request.getParameter("TrainingUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** getTraining.jsp ******************");
        Debug.println("sTrainingUid : "+sTrainingUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    Training training = Training.get(sTrainingUid);
%>

{
  "begin":"<%=(training.begin!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(training.begin)):"")%>",
  "end":"<%=(training.end!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(training.end)):"")%>",
  "institute":"<%=HTMLEntities.htmlentities(training.institute)%>",
  "type":"<%=HTMLEntities.htmlentities(training.type)%>",
  "level":"<%=HTMLEntities.htmlentities(training.level)%>",
  "diploma":"<%=HTMLEntities.htmlentities(training.diploma)%>",
  "diplomaDate":"<%=(training.diplomaDate!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(training.diplomaDate)):"")%>",
  "diplomaCode1":"<%=HTMLEntities.htmlentities(training.diplomaCode1)%>",
  "diplomaCode2":"<%=HTMLEntities.htmlentities(training.diplomaCode2)%>",
  "diplomaCode3":"<%=HTMLEntities.htmlentities(training.diplomaCode3)%>",
  "comment":"<%=HTMLEntities.htmlentities(training.comment.replaceAll("\r\n","<br>"))%>"
}