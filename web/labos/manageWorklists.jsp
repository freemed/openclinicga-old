<%@ page import="be.openclinic.medical.ResultsProfile,java.util.*,be.openclinic.medical.LabRequest,
be.openclinic.medical.RequestedLabAnalysis,java.util.Date,be.openclinic.medical.LabAnalysis" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.worklists","select",activeUser)%>
<%
    String activeProfile=checkString(request.getParameter("activeProfile"));
    String worklistType=checkString(request.getParameter("worklistType"));
    if(worklistType.length()==0){
        worklistType="incomplete";
    }

    if(request.getParameter("save")!=null){
        //Save the data
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name=(String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("store")){
                if(fields[3].equalsIgnoreCase("comment")){
                }
                else if(fields[3].equalsIgnoreCase("confirmed")){
                    RequestedLabAnalysis.setConfirmed(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),request.getParameter(name).equalsIgnoreCase("1"),request.getParameter("worklistAnalyses"));
                }
                else {
                    RequestedLabAnalysis.updateValue(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),fields[3],request.getParameter(name));
                }
            }
        }
        parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name=(String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("store")){
                if(fields[3].equalsIgnoreCase("technicalvalidation") && request.getParameter(name).equalsIgnoreCase("1")){
                    RequestedLabAnalysis.setTechnicalValidation(Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),Integer.parseInt(activeUser.userid),request.getParameter("worklistAnalyses"));
                }
            }
        }
    }

%>
<form name="frmWorkLists" method="post">
    <!-- Header: choose the apropriate worklist -->
    <%=writeTableHeader("Web","workLists",sWebLanguage," doBack();")%>
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
                <input type="radio" name="worklistType" value="incomplete" <%=worklistType.equalsIgnoreCase("incomplete")?"checked":""%>><%=getTran("web","incomplete",sWebLanguage)%>
                <input type="radio" name="worklistType" value="today" <%=worklistType.equalsIgnoreCase("today")?"checked":""%>><%=getTran("web","today",sWebLanguage)%>
                <input class="button" type="submit" name="submit" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>

<%
    if (!activeProfile.equalsIgnoreCase("")) {
        //START OF WORKLIST HEADER
        %>
        <br>
        <table width="100%" cellspacing="1" cellpadding="0" class="list">
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
                out.print("<th>" + analysis.get("mnemonic") + "<BR/>" + checkString((String) analysis.get("unit"))+ "&nbsp;</th>");
                if (n > 0) {
                    worklistAnalyses += ",";
                }
                worklistAnalyses += "'" + analysis.get("labcode") + "'";
            }
            out.print("<th>" + getTran("web", "lab.technicalvalidation", sWebLanguage) + "</th>");
            out.print("<th>" + getTran("web", "comment", sWebLanguage) + "</th></tr>");

            //END OF WORKLIST HEADER
            //Now let's find all lab requests for this worklist
            Hashtable alertValues=new Hashtable();
            String[] allAnalysis = worklistAnalyses.replaceAll("'", "").split(",");
            for (int n = 0; n < allAnalysis.length; n++) {
                LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(allAnalysis[n]);
                if (labAnalysis != null && checkString(labAnalysis.getAlertvalue()).length() > 0) {
                    try {
                        alertValues.put(allAnalysis[n],new Double(labAnalysis.getAlertvalue()));
                        out.print("<input type='hidden' name='alert."+allAnalysis[n]+"' value='"+Double.parseDouble(labAnalysis.getAlertvalue())+"'/>");
                    }
                    catch (Exception e) {
                    }
                }
            }

            Vector results = new Vector();
            if (worklistType.equalsIgnoreCase("incomplete")) {
                results = LabRequest.findOpenRequests(worklistAnalyses, sWebLanguage);
            } else if (worklistType.equalsIgnoreCase("today")) {
                results = LabRequest.findRequestsSince(worklistAnalyses, new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())), sWebLanguage);
            }
            boolean bTechnicallyValidated=true;
            for (int n = 0; n < results.size(); n++) {
                LabRequest labRequest = (LabRequest) results.elementAt(n);
                out.print("<tr>");
                out.print("<td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a><br/>"+new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getRequestdate())+"</td>");
                out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                //Add all analysis results/requests
                for (int i = 0; i < profileAnalysis.size(); i++) {
                    Hashtable analysis = (Hashtable) profileAnalysis.elementAt(i);
                    RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(analysis.get("labcode"));
                    if (requestedLabAnalysis != null && requestedLabAnalysis.getFinalvalidation()==0) {
                        bTechnicallyValidated = bTechnicallyValidated && requestedLabAnalysis.getTechnicalvalidation()>0;
                        String sColor="lightgreen";
                        if(requestedLabAnalysis.getTechnicalvalidation()==0){
                            sColor="yellow";
                        }
                        if(alertValues.get(requestedLabAnalysis.getAnalysisCode())!=null){
                            try{
                                if(Double.parseDouble(requestedLabAnalysis.getResultValue())>((Double)alertValues.get(requestedLabAnalysis.getAnalysisCode())).doubleValue()){
                                    sColor="#ff9999";
                                }
                            }
                            catch(Exception e){}
                        }
                        out.print("<td><input style='{background: "+sColor+"}' class='text' type='text' size='5' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + requestedLabAnalysis.getResultValue() + "' onchange='validateAlert(this,\""+requestedLabAnalysis.getAnalysisCode()+"\");'></td>");
                    } else {
                        if(requestedLabAnalysis !=null){
                            out.print("<td><b>"+requestedLabAnalysis.getResultValue()+"</b></td>");
                        }
                        else {
                            out.print("<td>X</td>");
                        }
                    }
                }
                out.print("<td><input type='hidden' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + ".technicalvalidation' value='" + (bTechnicallyValidated ? "1" : "0") + "'><input class='checkbox' type='checkbox' " + (bTechnicallyValidated ? "checked onclick='return false;'" : "onchange='if(this.checked){document.getElementsByName(\"store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + ".technicalvalidation\")[0].value=\"1\"}else{document.getElementsByName(\"store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + ".technicalvalidation\")[0].value=\"0\"}'")+"/></td>");
                out.print("<td><input class='text' type='text' size='20' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + ".comment'/></td>");
                out.print("</tr>");
            }
            out.print("<tr><td colspan='"+(profileAnalysis.size()+4)+"'><hr/></td></tr>");
            out.print("<tr><td colspan='2'><input readonly style='{background: yellow}' class='text' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","notechnicalvalidation",sWebLanguage)+"<br/><input readonly style='{background: #ff9999}' class='text' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","higherthanalertvalue",sWebLanguage)+"</td><td colspan='"+(allAnalysis.length+1)+"'><input class='button' type='submit' name='save' value='"+getTran("web","save",sWebLanguage)+"'/></tr>");
        %>
        </table>
        <input type="hidden" name="worklistAnalyses" value="<%=worklistAnalyses%>"/>
        <%
            }
        %>
</form>
<script>
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }

    function validateAlert(o,analysis){
        if(document.getElementsByName('alert.'+analysis)[0]!=undefined){
            if(o.value>document.getElementsByName('alert.'+analysis)[0].value*1){
                o.style.backgroundColor='#ff9999';
            }
            else {
                o.style.backgroundColor='yellow';
            }
        }
    }

    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>