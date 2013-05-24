<%@page import="be.openclinic.hr.Leave,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sLeaveUid = checkString(request.getParameter("LeaveUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getLeave.jsp *******************");
        Debug.println("sLeaveUid : "+sLeaveUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    Leave leave = Leave.get(sLeaveUid);

    DecimalFormat deci = new DecimalFormat("0.##");
%>

{
  "begin":"<%=(leave.begin!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(leave.begin)):"")%>",
  "end":"<%=(leave.end!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(leave.end)):"")%>",
  "duration":"<%=deci.format(leave.duration).replaceAll(",",".")%>",
  "type":"<%=HTMLEntities.htmlentities(leave.type)%>",
  "requestDate":"<%=(leave.requestDate!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(leave.requestDate)):"")%>",
  "authorizationDate":"<%=(leave.authorizationDate!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(leave.authorizationDate)):"")%>",
  "authorizedBy":"<%=HTMLEntities.htmlentities(leave.authorizedBy)%>",
  "episodeCode":"<%=HTMLEntities.htmlentities(leave.episodeCode)%>",
  "comment":"<%=HTMLEntities.htmlentities(leave.comment.replaceAll("\r\n","<br>"))%>"
}