<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.mxs.common.util.system.ScreenHelper,be.openclinic.medical.LabRequest,java.util.*,be.openclinic.medical.LabSample" %>
<%=checkPermission("labos.requestswithoutsamples","select",activeUser)%>
<%
    String serviceId=checkString(request.getParameter("serviceId"));
    String serviceText=checkString(request.getParameter("serviceText"));
    if(serviceId.length()==0){
        serviceId=activeUser.activeService.code;
        serviceText=activeUser.activeService.getLabel(sWebLanguage);
    }
%>
<form name="samplesForm" method="post">
    <%=writeTableHeader("Web","unsampledRequests",sWebLanguage," doBack();")%>
    <table width="100%" cellspacing="0" cellpadding="1" class="menu">
        <tr>
            <td><%=getTran("web","service",sWebLanguage)%>
                <input class='text' TYPE="text" NAME="serviceText" readonly size="49" TITLE="<%=serviceText%>" VALUE="<%=serviceText%>" onkeydown="window.event.keyCode = '';return true;">
                <%
                    if(serviceId.length()>0){
                        %>
                            <img src="<c:url value='/_img/icon_info.gif'/>" class="link" alt="<%=getTran("Web","Information",sWebLanguage)%>" onclick='searchInfoService(samplesForm.serviceId)'/>
                        <%
                    }
                %>
                <%=ScreenHelper.writeServiceButton("buttonUnit", "serviceId", "serviceText", sWebLanguage, sCONTEXTPATH)%>
                <input TYPE="hidden" NAME="serviceId" VALUE="<%=serviceId%>">
                <input class="button" type="submit" name="findSamples" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
<script type="text/javascript">
    function searchInfoService(sObject){
      if(sObject.value.length > 0){
        openPopup("/_common/search/serviceInformation.jsp&ServiceID="+sObject.value);
      }
    }
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
    function printLabels(){
        var bPrint = false;
        for(var i=0; i<samplesForm.elements.length; i++){
          if(samplesForm.elements[i].type=="checkbox"){
              if (samplesForm.elements[i].checked) {
                  bPrint = true;
              }
          }
        }

        if (bPrint){
            samplesForm.target="_popup";
            samplesForm.action="<c:url value='/healthrecord/createLabSampleLabelPdf.jsp'/>";
            samplesForm.submit();
        }
    }
</script>
<%
    if(request.getParameter("execute")!=null){
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name=(String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("execute") && fields.length==4){
                LabRequest.setSampleTaken(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),fields[3],Integer.parseInt(activeUser.userid));
            }
        }
    }
    if (request.getParameter("findSamples") != null || request.getParameter("execute") != null) {
%>
    <br>
    <table width="100%" class="list" cellspacing="1" cellpadding="0">
        <tr class="admin">
            <td><%=getTran("web","date",sWebLanguage)%></td>
            <td width='20%'><%=getTran("web","patient",sWebLanguage)%></td>
            <td><%=getTran("web","samples",sWebLanguage)%></td>
        </tr>
    <%
        Vector unsampledRequests = LabRequest.findUnsampledRequests(serviceId, sWebLanguage);
        LabRequest labRequest = null;
        for (int n = 0; n < unsampledRequests.size(); n++) {
            labRequest = (LabRequest) unsampledRequests.elementAt(n);
            if(labRequest.getPersonid()>0){
                out.print("<tr>");
                out.print("<td>" + (labRequest.getRequestdate()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate()):"") + "<BR/><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a></td>");
                out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                out.print("<td><table width='100%' cellspacing='1' cellpadding='0'>");
                Hashtable samples = labRequest.findOpenSamples(sWebLanguage);
                Enumeration enumeration = samples.elements();
                while (enumeration.hasMoreElements()) {
                    LabSample labSample = (LabSample)enumeration.nextElement();
                    out.print("<tr><td class='admin2' width='20%'><input type='checkbox' name='execute."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+labSample.type+"'>");
                    out.print(" "+MedwanQuery.getInstance().getLabel("labanalysis.monster",labSample.type,sWebLanguage)+"</td><td class='admin2'>");
                    for(int i=0;i<labSample.analyses.size();i++){
                        if(i>0){
                            out.print(", ");
                        }
                        out.print(MedwanQuery.getInstance().getLabel("labanalysis",(String)labSample.analyses.elementAt(i),sWebLanguage));
                    }
                    out.print("</td></tr>");
                }
                out.print("</table></td></tr>");
            }
        }
    %>
    </table>
    <%
        if (labRequest!=null){
    %>
    <input class="button" type="submit" name="execute" value="<%=getTran("web","save",sWebLanguage)%>"/>
    <input class="button" type="button" name="printlabels" value="<%=getTran("web","printlabels",sWebLanguage)%>" onclick="printLabels();"/>
    <%
        }
    %>
</form>
<%
    }
%>
