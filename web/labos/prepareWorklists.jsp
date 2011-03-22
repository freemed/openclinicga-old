<%@ page import="be.openclinic.medical.ResultsProfile,java.util.*,be.openclinic.medical.LabRequest,be.openclinic.medical.RequestedLabAnalysis" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.prepareworklists","select",activeUser)%>
<%
    String activeProfile=checkString(request.getParameter("activeProfile"));

    if(request.getParameter("save")!=null){
        //Save the data
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name=(String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("store")){
                if(fields[3].equalsIgnoreCase("worklisted")){
                    RequestedLabAnalysis.setWorklisted(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),request.getParameter("worklistAnalyses"));
                }
            }
        }
    }

%>
<form name="frmWorkLists" method="post">
    <%=writeTableHeader("Web","prepareWorklists",sWebLanguage," doBack();")%>
    <table width="100%" cellspacing="0" cellpadding="1" class="menu">
        <tr>
            <td>
                <%=getTran("web","worklist",sWebLanguage)%>
                <select class="text" name="activeProfile">
                    <%
                        Hashtable profiles = ResultsProfile.getProfiles(sWebLanguage);
                        if(profiles.size()>0){
                            Enumeration enumeration = profiles.keys();
                            while(enumeration.hasMoreElements()){
                                String label = (String)enumeration.nextElement();
                                ResultsProfile resultsProfile = (ResultsProfile)profiles.get(label);
                                out.print("<option value='" +resultsProfile.getProfileID()+"'"+(activeProfile.equalsIgnoreCase(""+resultsProfile.getProfileID())?" selected ":"")+">"+label+"</option>");
                            }
                        }
                    %>
                </select>
                <input class="button" type="submit" name="submit" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>

<%
    if (!activeProfile.equalsIgnoreCase("")) {
        //START OF WORKLIST HEADER
        %>
        <br>
        <table width="100%" cellspacing="1" cellpadding="0">
            <tr class="admin">
                <th><%=getTran("web","ID",sWebLanguage)%><br/><%=getTran("web","date",sWebLanguage)%></th>
                <th><%=getTran("web","patient",sWebLanguage)%><br/><%=getTran("web","service",sWebLanguage)%></th>
        <%
            //Show the selected worklist
            //First find all the analysis that are part of the active profile
            Vector profileAnalysis = ResultsProfile.searchLabProfilesDataByProfileID(activeProfile);
            //Construct the results header
            String worklistAnalyses = "";
            for (int n = 0; n < profileAnalysis.size(); n++) {
                Hashtable analysis = (Hashtable) profileAnalysis.elementAt(n);
                out.print("<th>" + analysis.get("mnemonic") + "<BR/>" + checkString((String) analysis.get("unit")) + "</th>");
                if (n > 0) {
                    worklistAnalyses += ",";
                }
                worklistAnalyses += "'" + analysis.get("labcode") + "'";
            }
            out.print("<th>" + getTran("web", "lab.setworklist", sWebLanguage) + "</th>");
            out.print("<th>" + getTran("web", "comment", sWebLanguage) + "</th></tr>");

            //END OF WORKLIST HEADER
            //Now let's find all lab requests for this worklist

            Vector results = new Vector();
            results = LabRequest.findNotOnWorklistRequests(worklistAnalyses, sWebLanguage);
            for (int n = 0; n < results.size(); n++) {
                LabRequest labRequest = (LabRequest) results.elementAt(n);
                out.print("<tr>");
                out.print("<td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a><br/>"+new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getRequestdate())+"</td>");
                out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                //Add all analysis results/requests
                for (int i = 0; i < profileAnalysis.size(); i++) {
                    Hashtable analysis = (Hashtable) profileAnalysis.elementAt(i);
                    RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(analysis.get("labcode"));
                    if (requestedLabAnalysis != null) {
                        out.print("<td>X</td>");
                    } else {
                        out.print("<td></td>");
                    }
                }
                out.print("<td><input class='checkbox' type='checkbox' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + ".worklisted'}'/></td>");
                out.print("</tr>");
            }
        %>
        </table>
        <input class="button" type="submit" name="save" value="<%=getTran("web","save",sWebLanguage)%>"/>
        <input type="hidden" name="worklistAnalyses" value="<%=worklistAnalyses%>"/>
        <%
    }
%>
</form>
<script type="text/javascript">
    function showRequest(serverid,transactionid){
        window.open("<c:url value="/popup.jsp"/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }

    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>