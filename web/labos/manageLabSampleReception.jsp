<%@ page import="be.openclinic.medical.LabRequest,be.openclinic.medical.LabSample" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.samplereception","select",activeUser)%>
<%
    String labrequestid=checkString(request.getParameter("labrequestid"));
    int serverid=0;
    int transactionid=0;
    Enumeration parameters = request.getParameterNames();
    if(parameters!=null){
        while (parameters.hasMoreElements()) {
            String name = (String) parameters.nextElement();
            String fields[] = name.split("\\.");
            if (fields[0].equalsIgnoreCase("receive") && fields.length == 4) {
                serverid=Integer.parseInt(fields[1]);
                transactionid=Integer.parseInt(fields[2]);
                LabRequest.setSampleReceived(serverid, transactionid, fields[3]);
                labrequestid="";
            }
        }
    }
%>
<form name="frmSampleReception" method="post" action="<c:url value="/main.do"/>?Page=labos/manageLabSampleReception.jsp">
    <%=writeTableHeader("Web","sampleReception",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <%=getTran("web","labrequestid",sWebLanguage)%>
                <input type="text" size="16" class="text" name="labrequestid" value="<%=labrequestid%>"/>
                <input type="submit" class="button" name="find" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" cellspacing="0" cellpadding="0">
<%
    boolean bInitialized = false;
    if(request.getParameter("find")!=null){
        if (labrequestid.length() > 0 || transactionid>0) {
            try{
                if(labrequestid.length() > 0){
                    if (labrequestid.indexOf(".") == -1) {
                        labrequestid = "1." + labrequestid;
                    }
                    serverid = Integer.parseInt(labrequestid.split("\\.")[0]);
                    transactionid = Integer.parseInt(labrequestid.split("\\.")[1]);
                }
                LabRequest labRequest = LabRequest.getUnsampledRequest(serverid, transactionid, sWebLanguage);
                if (labRequest != null) {
                    out.print("<tr>");
                    out.print("<td colspan='2'>" + (labRequest.getRequestdate()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate()):"") + "<BR/><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a></td>");
                    out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                    out.print("</tr>");
                    Hashtable allsamples=labRequest.findAllSamples(sWebLanguage);
                    Hashtable unreceived = labRequest.findUnreceivedSamples(sWebLanguage);
                    Enumeration enumeration = allsamples.elements();
                    while (enumeration.hasMoreElements()) {
                        LabSample labSample=(LabSample)enumeration.nextElement();
                        out.print("<tr><td><center>");
                        if(unreceived.get(labSample.type)!=null){
                            out.print("<input type='checkbox' name='receive." + serverid + "." + transactionid + "." +labSample.type+"'/>");
                            bInitialized=true;
                        }
                        else {
                            %>
                            <img src="<c:url value='/_img/check.gif'/>"/>
                            <%
                        }
                        out.print("</center></td><td colspan='2'>"+MedwanQuery.getInstance().getLabel("labanalysis.monster",labSample.type,sWebLanguage)+"</td></tr>");
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        else {
            Vector unsampledRequests = LabRequest.findUnreceivedRequests(sWebLanguage);
            for(int n=0;n<unsampledRequests.size();n++){
                LabRequest labRequest = (LabRequest)unsampledRequests.elementAt(n);
                if(labRequest!=null && labRequest.getRequestdate()!=null) {
                    out.print("<tr><td class='admin2'><b><a href='javascript:selectRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+");'>"+new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getRequestdate())+"</a> "+labRequest.getPatientname()+" </b></td><td class='admin2'> "+labRequest.getPatientgender()+" </td>"+
                            "<td class='admin2'> "+new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth())+" </td><td class='admin2'><i> "+labRequest.getServicename()+"</i></td></tr>");
                }
            }
        }
    }
%>
    </table>
<%
    if (bInitialized){
    %>
        <input type="submit" class="button" name="receive" value="<%=getTran("web","receive",sWebLanguage)%>"/>
    <%
    }
%>
    <div id="sampleReceiver"/>
</form>
<script type="text/javascript">
    document.all['labrequestid'].focus();
    function selectRequest(serverid,transactionid){
        window.location.href="<c:url value="/main.do"/>?Page=labos/manageLabSampleReception.jsp&find=1&labrequestid="+serverid+"."+transactionid;
    }
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/labos/manageLabResult_view.jsp'/>?ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>