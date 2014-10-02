<%@page import="be.openclinic.medical.ResultsProfile,
                java.util.*,
                be.openclinic.medical.LabRequest,
                be.openclinic.medical.RequestedLabAnalysis,
                be.openclinic.medical.LabAnalysis"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.biologicvalidationbyworklist","select",activeUser)%>
<%
    String activeProfile = checkString(request.getParameter("activeProfile"));

    if(request.getParameter("save")!=null){
        // Save the data
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name = (String)parameters.nextElement();
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
    <!-- Header: choose the apropriate worklist -->
    <%=writeTableHeader("Web","workListFinalValidation",sWebLanguage," doBack();")%>
    <table width="100%" cellspacing="0" cellpadding="1" class="menu">
        <tr>
            <td class="admin" width=<%=sTDAdminWidth%>"><%=getTran("web","worklist",sWebLanguage)%></td>
            <td class="admin2">
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
                
                <input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
    
    <script>
      function doBack(){
        window.location.href = "<c:url value="/main.do"/>?Page=labos/index.jsp";
      }
    </script>
<%
    if(!activeProfile.equalsIgnoreCase("")){
        // START OF WORKLIST HEADER
        %>
        <br>
        <table width="100%" class="list" cellspacing="1" cellpadding="0">
            <tr class="admin">
                <th><%=getTran("web","ID",sWebLanguage)%><br/><%=getTran("web","date",sWebLanguage)%></th>
                <th><%=getTran("web","patient",sWebLanguage)%><br/><%=getTran("web","service",sWebLanguage)%></th>
        <%
            // Show the selected worklist
            // find all the analysis that are part of the active profile
            Vector profileAnalysis = ResultsProfile.searchLabProfilesDataByProfileID(activeProfile);
            //Construct the results header
            String worklistAnalyses = "";
            for(int n=0; n<profileAnalysis.size(); n++){
                Hashtable analysis = (Hashtable) profileAnalysis.elementAt(n);
                out.print("<th>"+analysis.get("mnemonic")+"<BR/>"+checkString((String)analysis.get("unit"))+"</th>");
                if(n > 0){
                    worklistAnalyses+= ",";
                }
                worklistAnalyses+= "'"+analysis.get("labcode")+"'";
            }
            out.print("<th>"+getTran("web","lab.validated",sWebLanguage)+"</th>");
            out.print("<th>"+getTran("web","comment",sWebLanguage)+"</th></tr>");

            // find all lab requests for this worklist
            Vector results = new Vector();
            		
            // generate all configured alertvalues
            Hashtable alertValues = new Hashtable();
            String[] allAnalysis = worklistAnalyses.replaceAll("'", "").split(",");
            for(int n=0; n<allAnalysis.length; n++){
                LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(allAnalysis[n]);
                if(labAnalysis!=null && checkString(labAnalysis.getAlertvalue()).length() > 0){
                    try{
                        alertValues.put(allAnalysis[n],new Double(labAnalysis.getAlertvalue()));
                    }
                    catch(Exception e){
                    	// empty
                    }
                }
            }

            results = LabRequest.findUnvalidatedRequests(worklistAnalyses,sWebLanguage,1);
            for(int n=0; n<results.size(); n++){
                LabRequest labRequest = (LabRequest) results.elementAt(n);
                out.print("<tr>");
                out.print("<td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>"+labRequest.getTransactionid()+"</b></a><br/>"+ScreenHelper.formatDate(labRequest.getRequestdate())+"</td>");
                out.print("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>"+labRequest.getPatientname()+"</b></a> (°"+(labRequest.getPatientdateofbirth() != null ? ScreenHelper.formatDate(labRequest.getPatientdateofbirth()) : "")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
                
                // Add all analysis results/requests
                for(int i=0; i<profileAnalysis.size(); i++){
                    Hashtable analysis = (Hashtable)profileAnalysis.elementAt(i);
                    RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)labRequest.getAnalyses().get(analysis.get("labcode"));
                    if(requestedLabAnalysis!=null && requestedLabAnalysis.getFinalvalidation()==0){
                        String sColor = "lightgreen";
                        if(requestedLabAnalysis.getTechnicalvalidation()==0){
                            sColor = "yellow";
                        }
                        
                        if(alertValues.get(requestedLabAnalysis.getAnalysisCode())!=null){
                            try{
                                if(Double.parseDouble(requestedLabAnalysis.getResultValue())>((Double)alertValues.get(requestedLabAnalysis.getAnalysisCode())).doubleValue()){
                                    sColor = "#ff9999";
                                }
                            }
                            catch(Exception e){
                            	// empty
                            }
                        }
                        out.print("<td><input style='{background: "+sColor+"}' readonly class='text' type='text' size='5' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultValue()+"'>" +
                                  "<input class='checkbox' type='checkbox' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+".validated'/></td>");
                    }
                    else{
                        if(requestedLabAnalysis!=null){
                            out.print("<td><b>"+requestedLabAnalysis.getResultValue()+"</b></td>");
                        }
                        else{
                            out.print("<td>X</td>");
                        }
                    }
                }
                out.print("<td><input class='checkbox' type='checkbox' onclick='setChecks(\""+labRequest.getServerid()+"."+labRequest.getTransactionid()+"\",this.checked)'/></td>");
                out.print("<td></td>");
                out.print("</tr>");
            }
            
            out.print("<tr><td colspan='"+(profileAnalysis.size()+4)+"'><hr/></td></tr>");
            out.print("<tr>"+
                       "<td colspan='2'><input readonly style='{background: yellow}' class='text' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","notechnicalvalidation",sWebLanguage)+"<br/>"+
                                       "<input readonly style='{background: #ff9999}' class='text' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","higherthanalertvalue",sWebLanguage)+"</td>"+
                       "<td><input class='button' type='submit' name='save' value='"+getTranNoLink("web","save",sWebLanguage)+"'/>"+
                      "</tr>");
        %>
        </table>
        <input type="hidden" name="worklistAnalyses" value="<%=worklistAnalyses%>"/>
        
        <script>
          function setChecks(lineId,bValue){
            <%
              String[] analysis = worklistAnalyses.split(",");
              for(int n=0; n<analysis.length; n++){
                out.print("if(document.getElementsByName('store.'+lineId+'."+analysis[n].replaceAll("'","")+".validated')[0]!=undefined){document.getElementsByName('store.'+lineId+'."+analysis[n].replaceAll("'","")+".validated')[0].checked=bValue};");
              }
            %>
          }
          
          function showRequest(serverid,transactionid){
            window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
          }
        </script>
        <%
    }
%>
</form>