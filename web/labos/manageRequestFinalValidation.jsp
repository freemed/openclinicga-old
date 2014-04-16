<%@ page import="java.util.*,be.openclinic.medical.LabRequest,be.openclinic.medical.RequestedLabAnalysis" %>
<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.biologicvalidationbyrequest","select",activeUser)%>
<%
    if(request.getParameter("save")!=null){
        //Save the data
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name=(String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("store")){
                if(fields.length>3 && fields[3].equalsIgnoreCase("comment")){
                }
                else if(fields.length>4 && fields[4].equalsIgnoreCase("validated")){
                    RequestedLabAnalysis.setFinalValidation(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),Integer.parseInt(activeUser.userid),"'"+fields[3]+"'");
                }
            }
        }
    }

%>
<form name="frmWorkLists" method="post">
<%
    %>
    <%=writeTableHeader("Web","requestFinalValidation",sWebLanguage," doBack();")%>
    <table width="100%" class='list' cellspacing="1" cellpadding="0">
        <tr class="admin">
            <th><%=getTran("web","ID",sWebLanguage)%><br/><%=getTran("web","date",sWebLanguage)%></th>
            <th><%=getTran("web","patient",sWebLanguage)%><br/><%=getTran("web","service",sWebLanguage)%></th>
    <%
        String worklistAnalyses = RequestedLabAnalysis.findUnvalidatedAnalyses();
        String[] profileAnalysis = worklistAnalyses.split(",");
        for (int n = 0; n < profileAnalysis.length; n++) {
            String c = profileAnalysis[n].replaceAll("'","");
            LabAnalysis l = LabAnalysis.getLabAnalysisByLabcode(profileAnalysis[n].replaceAll("'",""));
            if(l!=null && ScreenHelper.checkString(l.getMedidoccode()).length()>0){
                c= l.getMedidoccode();
            }
            out.print("<th>" + c + "</th>");
        }
        out.print("<th>" + getTran("web", "lab.validated", sWebLanguage) + "</th>");
        out.print("<th>" + getTran("web", "comment", sWebLanguage) + "</th></tr>");

        //END OF WORKLIST HEADER
        //Now let's find all lab requests for this worklist

        if(worklistAnalyses.length()>0){
            Vector results = new Vector();
            results = LabRequest.findUnvalidatedRequests(worklistAnalyses, sWebLanguage,1);
            for (int n = 0; n < results.size(); n++) {
                LabRequest labRequest = (LabRequest) results.elementAt(n);
                out.print("<tr>");
                out.print("<td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a><br/>"+new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getRequestdate())+"</td>");
                out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                //Add all analysis results/requests
                for (int i = 0; i < profileAnalysis.length; i++) {
                    RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(profileAnalysis[i].replaceAll("'",""));
                    if (requestedLabAnalysis != null && requestedLabAnalysis.getFinalvalidation()==0 && checkString(requestedLabAnalysis.getResultValue()).length()>0 ) {
                        out.print("<td><input readonly class='text" + (requestedLabAnalysis.getTechnicalvalidation()>0 ? "" : "yellow") + "' type='text' size='5' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + requestedLabAnalysis.getResultValue() + "'>" +
                                "<input class='checkbox' type='checkbox' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "."+requestedLabAnalysis.getAnalysisCode()+".validated'/></td>");
                    } else {
                        if(requestedLabAnalysis !=null){
                            out.print("<td><b>"+(checkString(requestedLabAnalysis.getResultValue()).length()>0?requestedLabAnalysis.getResultValue():"?")+"</b></td>");
                        }
                        else {
                            out.print("<td></td>");
                        }
                    }
                }
                out.print("<td><input class='checkbox' type='checkbox' onclick='setChecks(\""+labRequest.getServerid() + "." + labRequest.getTransactionid()+"\",this.checked)'/></td>");
                out.print("<td></td>");
                out.print("</tr>");
            }
            out.print("<tr><td colspan='"+(profileAnalysis.length+4)+"'><hr/></td></tr>");
            out.print("<tr><td colspan='2'><input readonly class='textyellow' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","notechnicalvalidation",sWebLanguage)+"</td><td><input class='button' type='submit' name='save' value='"+getTran("web","save",sWebLanguage)+"'/></tr>");
        }
    %>
    </table>
    <input type="hidden" name="worklistAnalyses" value="<%=worklistAnalyses%>"/>
    <script>
        function setChecks(lineId,bValue){
            <%
                String[] analysis=worklistAnalyses.split(",");
                for(int n=0;n<analysis.length;n++){
                    out.println("if(document.getElementsByName('store.'+lineId+'."+analysis[n].replaceAll("'","")+".validated')[0]!=undefined){document.getElementsByName('store.'+lineId+'."+analysis[n].replaceAll("'","")+".validated')[0].checked=bValue};");
                }
            %>
        }
        function showRequest(serverid,transactionid){
            window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
        }
        function doBack(){
            window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
        }
    </script>
</form>
