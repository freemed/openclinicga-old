<%@page import="be.openclinic.hr.Career,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sCareerUid = checkString(request.getParameter("CareerUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getCareer.jsp *******************");
        Debug.println("sCareerUid : "+sCareerUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    Career career = Career.get(sCareerUid);

    String sServiceName = "";
    if(checkString(career.serviceUid).length() > 0){
        sServiceName = getTran("service",career.serviceUid,sWebLanguage);    
    }
    
    // contractName == contractId (not uid)
    String sContractName = "";
    if(checkString(career.contractUid).length() > 0){
        //sContractName = getTranNoLink("contract",career.contractUid,sWebLanguage);
        sContractName = career.contractUid.substring(career.contractUid.indexOf(".")+1);
    }
%>

{
  "begin":"<%=(career.begin!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(career.begin)):"")%>",
  "end":"<%=(career.end!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(career.end)):"")%>",
  "contractUid":"<%=HTMLEntities.htmlentities(career.contractUid)%>",
  "contractName":"<%=HTMLEntities.htmlentities(sContractName)%>",
  "position":"<%=HTMLEntities.htmlentities(career.position)%>",
  "serviceUid":"<%=HTMLEntities.htmlentities(career.serviceUid)%>",
  "serviceName":"<%=HTMLEntities.htmlentities(sServiceName)%>",
  "grade":"<%=HTMLEntities.htmlentities(career.grade)%>",
  "status":"<%=HTMLEntities.htmlentities(career.status)%>",
  "comment":"<%=HTMLEntities.htmlentities(career.comment.replaceAll("\r\n","<br>"))%>"
}