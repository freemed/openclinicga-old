<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=ScreenHelper.writeTblHeader(getTran("web","labos",sWebLanguage),sCONTEXTPATH)%>
<%
    if (activePatient!=null){
        out.print("<tr><td colspan='2' class='admin'>"+getTran("web","patient",sWebLanguage)+"</td></tr>");
        if(activeUser.getAccessRight("labos.patientlaboresults.select")) out.print(writeTblChild("main.do?Page=labos/showLabRequestList.jsp",getTran("Web","patientLaboResults",sWebLanguage)));
        if(activeUser.getAccessRight("labos.openpatientlaboresults.select")) out.print(writeTblChild("main.do?Page=labos/manageLaboResults.jsp&type=patient&open=true&Action=find",getTran("Web","openPatientLaboResults",sWebLanguage)));
        out.print("<tr><td colspan='2'><hr/></td></tr>");
    }
    out.print("<tr><td colspan='2' class='admin'>"+getTran("web","user",sWebLanguage)+"</td></tr>");
    if(activeUser.getAccessRight("labos.userlaboresults.select")) out.print(writeTblChild("main.do?Page=labos/manageLaboUserResults.jsp&type=user&resultsOnly=true&Action=find",getTran("Web","userLaboResults",sWebLanguage)));
    if(activeUser.getAccessRight("labos.openuserlaboresults.select"))out.print(writeTblChild("main.do?Page=labos/manageLaboUserOpenResults.jsp&type=user&open=true&Action=find",getTran("Web","openUserLaboResults",sWebLanguage)));
    if(activeUser.getAccessRight("labos.servicelaboresults.select"))out.print(writeTblChild("main.do?Page=labos/manageLaboServiceResults.jsp&type=user&open=true&Action=find",getTran("web","serviceLaboResults",sWebLanguage)));
    if(activeUser.getAccessRight("labos.requestswithoutsamples.select"))out.print(writeTblChild("main.do?Page=labos/manageUnsampledLabRequests.jsp&type=patient&open=true&Action=find",getTran("web","unsampledRequests",sWebLanguage)));
    out.print("<tr><td colspan='2'><hr/></td></tr>");
    out.print("<tr><td colspan='2' class='admin'>"+getTran("web","laboratory",sWebLanguage)+"</td></tr>");
    if(activeUser.getAccessRight("labos.samplereception.select"))out.print(writeTblChild("main.do?Page=labos/manageLabSampleReception.jsp&open=true&Action=find",getTran("web","sampleReception",sWebLanguage)));
    if(activeUser.getAccessRight("labos.prepareworklists.select"))out.print(writeTblChild("main.do?Page=labos/prepareWorklists.jsp&open=true&Action=find",getTran("web","prepareWorklists",sWebLanguage)));
    if(activeUser.getAccessRight("labos.worklists.select"))out.print(writeTblChild("main.do?Page=labos/manageWorklists.jsp&open=true&Action=find",getTran("web","workLists",sWebLanguage)));
    if(activeUser.getAccessRight("labos.biologicvalidationbyworklist.select"))out.print(writeTblChild("main.do?Page=labos/manageWorklistFinalValidation.jsp&open=true&Action=find",getTran("web","workListFinalValidation",sWebLanguage)));
    if(activeUser.getAccessRight("labos.biologicvalidationbyrequest.select"))out.print(writeTblChild("main.do?Page=labos/manageRequestFinalValidation.jsp&open=true&Action=find",getTran("web","requestFinalValidation",sWebLanguage)));
    if(activeUser.getAccessRight("labos.printnewresults.select"))out.print(writeTblChild("main.do?Page=labos/manageLaboPrintResults.jsp&open=true&Action=find",getTran("web","printnewlabresults",sWebLanguage)));
    if(activeUser.getAccessRight("labos.openpatientlaboresults.select"))out.print(writeTblChild("main.do?Page=labos/manageLaboResultsEdit.jsp&type=patient&open=true&Action=find",getTran("web","fastresultsedit",sWebLanguage)));
    out.print("<tr><td colspan='2' class='admin'>WHONet</td></tr>");
    out.print(writeTblChild("main.do?Page=system/exportToWHONet.jsp",getTran("Web.Manage","exporttowhonet",sWebLanguage)));
    out.print(ScreenHelper.writeTblFooter());
%>

