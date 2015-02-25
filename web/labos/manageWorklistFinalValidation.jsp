<%@page import="be.openclinic.medical.ResultsProfile,
                java.util.*,
                be.openclinic.medical.LabRequest,
                be.openclinic.medical.RequestedLabAnalysis,
                be.openclinic.medical.LabAnalysis"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getComplexARVResult(String id, String arvs, String sWebLanguage,java.util.Date validationDate) {
	    String sReturn = "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexARVResult(document.getElementById(\"store."+id+"\").value,\""+id+"\")'>"+getTranNoLink("web", "openAntivirogramresult", sWebLanguage)+"</a>";
	    return sReturn;
	}
	public String getComplexResult(String id, Map map, String sWebLanguage,java.util.Date validationDate) {
	    String sReturn = "<input type='hidden' name='result."+id+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ1' name='resultAntibio."+id+".germ1' value='"+checkString((String) map.get("germ1"))+"'/>";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ2' name='resultAntibio."+id+".germ2' value='"+checkString((String) map.get("germ2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ3' name='resultAntibio."+id+".germ3' value='"+checkString((String) map.get("germ3"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio1' name='resultAntibio."+id+".ANTIBIOGRAMME1' value='"+checkString((String) map.get("ANTIBIOGRAMME1"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio2' name='resultAntibio."+id+".ANTIBIOGRAMME2' value='"+checkString((String) map.get("ANTIBIOGRAMME2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio3' name='resultAntibio."+id+".ANTIBIOGRAMME3' value='"+checkString((String) map.get("ANTIBIOGRAMME3"))+"' />";
	    sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResult(\""+id+"\")'>"+getTranNoLink("web", "openAntibiogrameresult", sWebLanguage)+"</a>";
	    return sReturn;
	}
	public String getComplexResultNew(String id, Map map, String sWebLanguage,java.util.Date validationDate) {
	    String sReturn = "<input type='hidden' name='result."+id+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ1' name='resultAntibio."+id+".germ1' value='"+checkString((String) map.get("germ1"))+"'/>";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ2' name='resultAntibio."+id+".germ2' value='"+checkString((String) map.get("germ2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".germ3' name='resultAntibio."+id+".germ3' value='"+checkString((String) map.get("germ3"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio1' name='resultAntibio."+id+".ANTIBIOGRAMME1' value='"+checkString((String) map.get("ANTIBIOGRAMME1"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio2' name='resultAntibio."+id+".ANTIBIOGRAMME2' value='"+checkString((String) map.get("ANTIBIOGRAMME2"))+"' />";
	    sReturn += "<input type='hidden' id='resultAntibio."+id+".antibio3' name='resultAntibio."+id+".ANTIBIOGRAMME3' value='"+checkString((String) map.get("ANTIBIOGRAMME3"))+"' />";
	    sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResultNew(\""+id+"\")'>"+getTranNoLink("web", "openAntibiogrameresult", sWebLanguage)+"</a>";
	    return sReturn;
	}

%>
<%=checkPermission("labos.biologicvalidationbyworklist","select",activeUser)%>
<script>
    function showresultparts(item){
    	partlineprefix = item.name.replace("store.","resultcommentpartline.");
    	parts=item.options[item.selectedIndex].id.split(";");
    	//First clear all resultcommentpartlines
    	var x = document.getElementsByTagName("TR");
    	for(n=0;n<x.length;n++){
    		if(x[n].id && x[n].id.indexOf(partlineprefix)>-1){
    			x[n].style.display='none';
    		}
    	}
    	for(n=0;n<parts.length;n++){
        	if(document.getElementById(partlineprefix+"."+parts[n])){
         		document.getElementById(partlineprefix+"."+parts[n]).style.display='';
        	}
    	}
    	partlineprefix = item.name.replace("store.","resultcommentpart.");
    	x = document.getElementsByTagName("INPUT");
    	for(n=0;n<x.length;n++){
    		if(x[n].id && x[n].id.indexOf(partlineprefix)>-1){
   	        	if(document.getElementById(x[n].id.replace("resultcommentpart","resultcommentpartline")).style.display=='none'){
  	    			x[n].value='';
   	        	}
    		}
    	}
    }
</script>
<%
    String activeProfile = checkString(request.getParameter("activeProfile"));

    if(request.getParameter("save")!=null){
        // Save the data
        Hashtable resultcomments = new Hashtable();
        Hashtable composedResults = new Hashtable();
        Enumeration parameters = request.getParameterNames();
        while(parameters.hasMoreElements()){
            String name = (String)parameters.nextElement();
            String fields[] = name.split("\\.");
            if(fields[0].equalsIgnoreCase("store")){
				if(fields.length>4 && fields[4].equalsIgnoreCase("validated")){
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
            Vector profileAnalysis = ResultsProfile.searchLabProfilesDataByProfileID(activeProfile,sWebLanguage);
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
                out.print("<td><a href='javascript:showRequest(" + labRequest.getServerid() + "," + labRequest.getTransactionid() + ")'><b>" + labRequest.getTransactionid() + "</b></a><br/>" + ScreenHelper.stdDateFormat.format(labRequest.getRequestdate()) + "</td>");
                out.print("<td><a href='javascript:readBarcode3(\"0" + labRequest.getPersonid() + "\");'><b>" + labRequest.getPatientname() + "</b></a> (°" + (labRequest.getPatientdateofbirth() != null ? ScreenHelper.stdDateFormat.format(labRequest.getPatientdateofbirth()) : "") + " - " + labRequest.getPatientgender() + ")<br/><i>" + labRequest.getServicename() + " - " + MedwanQuery.getInstance().getUserName(labRequest.getUserid()) + "</i></td>");
                //Add all analysis results/requests
                for (int i = 0; i < profileAnalysis.size(); i++) {
                    Hashtable analysis = (Hashtable) profileAnalysis.elementAt(i);
                    RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(analysis.get("labcode"));
                    if (requestedLabAnalysis != null) {
                        String sColor="white";
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
                        LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(requestedLabAnalysis.getAnalysisCode());
                        if(labAnalysis.getEditor().equalsIgnoreCase("antivirogram")){
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print("<input type='hidden' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' id='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + requestedLabAnalysis.getResultValue() + "'/>");
                        	out.print(getComplexARVResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), requestedLabAnalysis.getResultValue(), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime()));
                        }
                        else if(labAnalysis.getEditor().equalsIgnoreCase("antibiogram")){
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print("<input type='hidden' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' id='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='1'/>");
                        	out.print(getComplexResult(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime()));                        	
                        }
                        else if(labAnalysis.getEditor().equalsIgnoreCase("antibiogramnew")) {
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print("<input type='hidden' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' id='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='1'/>");
                        	out.print(getComplexResultNew(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime()));                        	
                        }
                        else if (labAnalysis.getEditor().equals("listbox")){
                        	HashSet resultcommentparts = new HashSet();
							String result="<select disabled class='text' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' id='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' onchange='showresultparts(this)'>";
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key.split("\\$")[0];
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								String activeparts="";
								if(key.split("\\$").length>1){
									for(int j=1;j<key.split("\\$").length;j++){
										if(j>1){
											activeparts+=";";
										}
										resultcommentparts.add(key.split("\\$")[j]);
										activeparts+=key.split("\\$")[j];
									}
								}
								result+="<option id='"+activeparts+"' value='"+key.split("\\$")[0]+"' "+(key.split("\\$")[0].equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
							}
							result+="</select>";
							Iterator it = resultcommentparts.iterator();
							if(it.hasNext()){
								result+="<table>";
								while(it.hasNext()){
									String part = (String)it.next();
									result+="<tr style='display: none' id='resultcommentpartline."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' name='resultcommentpartline."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"'><td>"+part+"</td><td><input readonly type='text' name='resultcommentpart."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' id='resultcommentpart."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+part+"' value='"+requestedLabAnalysis.getResultCommentPart(part)+"' class='text'/></td></tr>";
								}
								result+="</table><script>showresultparts(document.getElementById('store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"'))</script>";
							}
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else if (labAnalysis.getEditor().equals("listboxcomment")){
							String result="<select disabled class='text' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"'>";
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key;
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								result+="<option value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
							}
							result+="</select>";
							result+="<br/><input readonly type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else if (labAnalysis.getEditor().equals("radiobutton")){
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							String result ="";
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key;
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								result+="<input disabled type='radio' ondblclick='this.checked=!this.checked' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
							}
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else if (labAnalysis.getEditor().equals("radiobuttoncomment")){
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							String result ="";
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key;
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								result+="<input disabled type='radio' ondblclick='this.checked=!this.checked' name='store."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
							}
							result+="<br/><input readonly type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else if (labAnalysis.getEditor().equals("checkbox")){
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							String result ="";
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key;
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								result+="<input disabled type='checkbox' ondblclick='this.checked=!this.checked' name='resultmultiple."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+n+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
							}
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else if (labAnalysis.getEditor().equals("checkboxcomment")){
							String[] options = labAnalysis.getEditorparametersParameter("OP").split(",");
							String result ="";
							for(int o=0;o<options.length;o++){
								String key=options[o];
								String label=key;
								if(key.split("\\|").length>1){
									label=key.split("\\|")[1];
									key=key.split("\\|")[0];
								}
								result+="<input disabled type='checkbox' name='resultmultiple."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"."+o+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
							}
							result+="<br/><input readonly type='text' name='resultcomment."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
                        	out.print("<td style='background-color: "+sColor+"' width='1%' nowrap>");
                        	out.print(result);                        	
                        }
                        else {
                        	out.print("<td><input readonly style='background: "+sColor+"' readonly class='text' type='text' size='5' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + requestedLabAnalysis.getResultValue() + "'>");
                        }
                    } else {
                        out.print("<td>X</td>");
                    }
                    if (requestedLabAnalysis != null && requestedLabAnalysis.getFinalvalidation() == 0) {
                     	out.print("<input class='checkbox' type='checkbox' name='store." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + ".validated'/></td>");
                    }
                }
                out.print("<td><input class='checkbox' type='checkbox' onclick='setChecks(\""+labRequest.getServerid()+"."+labRequest.getTransactionid()+"\",this.checked)'/></td>");
                out.print("<td></td>");
                out.print("</tr>");
            }
            out.print("<tr><td colspan='" + (profileAnalysis.size() + 4) + "'><hr/></td></tr>");
            out.print("<tr><td colspan='2'><input readonly style='background: yellow' class='text' type='text' size='5'/> = " + MedwanQuery.getInstance().getLabel("web", "notechnicalvalidation", sWebLanguage)+"<br/><input readonly style='background: #ff9999' class='text' type='text' size='5'/> = "+MedwanQuery.getInstance().getLabel("web","higherthanalertvalue",sWebLanguage)+"</td><td><input class='button' type='submit' name='save' value='" + getTran("web", "save", sWebLanguage) + "'/></tr>");
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
          openComplexARVResult = function(arvs,id) {
              var params = "antivirogramuid="+id+"&editable=false&arvs="+arvs;
              var url = "<c:url value="/labos/ajax/getComplexARVResult.jsp" />?ts="+new Date().getTime();
              Modalbox.show(url, {title:"<%=getTranNoLink("web","antivirogram",sWebLanguage)%>",params:params,width:650,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
          }
          openComplexResult = function(id) {
              var params = "antibiogramuid="+id+"&editable=false";
              var url = "<c:url value="/labos/ajax/getComplexResult.jsp" />?ts="+new Date().getTime();
              Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:650,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
          }
          openComplexResultNew = function(id) {
              var params = "antibiogramuid="+id+"&editable=false";
              var url = "<c:url value="/labos/ajax/getComplexResultNew.jsp" />?ts="+new Date().getTime();
              Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:650,height:<%=MedwanQuery.getInstance().getConfigInt("antibiogramHeight",600)%>});
          }

        	function saveAntiviroGramme(id){
        		var s ='';
        		var x = document.getElementsByTagName("SELECT");
        		for(n=0;n<x.length;n++){
        			if(x[n].id.indexOf("arv")>-1 && x[n].selectedIndex>0){
        				if(s.length>0){
        					s+=";";
        				}
        				s+=x[n].id.substring(3)+"="+x[n].value;
        			}
        		}
        		document.getElementById('store.'+id).value=s;
        	    Modalbox.hide();
        	}

          <%-- VALIDATE ALERT --%>
          function validateAlert(o,analysis){
            if(document.getElementsByName('alert.'+analysis)[0]!=undefined){
              if(o.value>document.getElementsByName('alert.'+analysis)[0].value*1){
                o.style.backgroundColor = '#ff9999';
              }
              else{
                o.style.backgroundColor = 'yellow';
              }
            }
          }
          addObserversToAntibiogram = function(id) {
              $("germ1").value = $F("resultAntibio."+id+".germ1");
              $("germ2").value = $F("resultAntibio."+id+".germ2");
              $("germ3").value = $F("resultAntibio."+id+".germ3");
              setCheckBoxValues(id, $F("resultAntibio."+id+".antibio1").split(","), 1);
              setCheckBoxValues(id, $F("resultAntibio."+id+".antibio2").split(","), 2);
              setCheckBoxValues(id, $F("resultAntibio."+id+".antibio3").split(","), 3);
              $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
                  e.parentNode.observe('click', function(event) {
                      //alert(Event.element(event));
                      var elem = Event.element(event);
                      if (elem.tagName == "TD") {
                          if (elem.firstChild.checked) {
                              elem.firstChild.checked = false;
                          } else {
                              elem.firstChild.checked = true;
                              new Effect.Highlight(elem, { startcolor: '#FFE7DA'});
                          }
                      } else {
                          new Effect.Highlight(elem.parentNode, { startcolor: '#FFE7DA'});
                      }
                  });
              });

          }
          setCheckBoxValues = function(id, tab, nb) {
              tab.each(function(anti) {
                  if (anti.length > 0) {
                      var tAnti = anti.split("=");
                      try {
                          $(tAnti[0]+"_radio_"+nb+"_"+tAnti[1]).checked = true;
                      } catch(e) {
                          alertDialog(tAnti[0]+"_radio_"+nb+"_"+tAnti[1]);
                      }
                  }
              });
          }
          setAntibiogram = function (id) {
              var s = "";
              $("resultAntibio."+id+".germ1").value = $F("germ1");
              $("resultAntibio."+id+".germ2").value = $F("germ2");
              $("resultAntibio."+id+".germ3").value = $F("germ3");
              $("resultAntibio."+id+".antibio1").value = "";
              $("resultAntibio."+id+".antibio2").value = "";
              $("resultAntibio."+id+".antibio3").value = "";
              $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
                  if (e.checked) {
                      s += "\n"+e.name+" -  "+e.value;
                      var tab = e.name.split("_");
                      $("resultAntibio."+id+".antibio"+tab[2]).value = $F("resultAntibio."+id+".antibio"+tab[2])+","+tab[0]+"="+e.value;
                  }
              });
              Modalbox.hide();
          }
        </script>
        <%
    }
%>
</form>