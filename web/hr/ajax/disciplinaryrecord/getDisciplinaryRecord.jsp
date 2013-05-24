<%@page import="be.openclinic.hr.DisciplinaryRecord,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sDiscRecUid = checkString(request.getParameter("DisRecUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* getDisciplinaryRecord.jsp ************");
        Debug.println("sDiscRecUid : "+sDiscRecUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    DisciplinaryRecord disiplinaryRecord = DisciplinaryRecord.get(sDiscRecUid);    
%>

{
  "date":"<%=(disiplinaryRecord.date!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(disiplinaryRecord.date)):"")%>",
  "title":"<%=HTMLEntities.htmlentities(disiplinaryRecord.title)%>",
  "description":"<%=HTMLEntities.htmlentities(disiplinaryRecord.description.replaceAll("\r\n","<br>"))%>",
  "decision":"<%=HTMLEntities.htmlentities(disiplinaryRecord.decision)%>",
  "duration":"<%=disiplinaryRecord.duration%>",
  "decisionBy":"<%=HTMLEntities.htmlentities(disiplinaryRecord.decisionBy)%>",
  "followUp":"<%=HTMLEntities.htmlentities(disiplinaryRecord.followUp.replaceAll("\r\n","<br>"))%>"
}