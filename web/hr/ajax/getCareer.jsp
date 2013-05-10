<%@page import="be.openclinic.hr.Career,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sCareerUid = checkString(request.getParameter("CareerUid"));

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("");
	    Debug.println("******************* getCareer.jsp ********************");
	    Debug.println("sCareerUid : "+sCareerUid);
	    Debug.println("");
	}
	///////////////////////////////////////////////////////////////////////////

    Career career = Career.get(sCareerUid);
	
	String sServiceName = "";
	if(checkString(career.serviceUid).length() > 0){
		sServiceName = getTran("service",career.serviceUid,sWebLanguage);	
	}
%>

{
  "begin":"<%=HTMLEntities.htmlentities(ScreenHelper.getSQLDate(career.begin))%>",
  "end":"<%=HTMLEntities.htmlentities(ScreenHelper.getSQLDate(career.end))%>",
  "position":"<%=HTMLEntities.htmlentities(career.position)%>",
  "serviceUid":"<%=HTMLEntities.htmlentities(career.serviceUid)%>",
  "serviceName":"<%=HTMLEntities.htmlentities(sServiceName)%>",
  "grade":"<%=HTMLEntities.htmlentities(career.grade)%>",
  "status":"<%=HTMLEntities.htmlentities(career.status)%>",
  "comment":"<%=HTMLEntities.htmlentities(career.comment)%>"
}