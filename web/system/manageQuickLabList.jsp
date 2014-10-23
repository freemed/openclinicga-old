<%@page import="be.openclinic.medical.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //-- GET ITEM VALUE ---------------------------------------------------------------------------
	public String getItemValue(String[] labanalyses, int column, int row){
		if(labanalyses!=null){
			for(int n=0; n<labanalyses.length; n++){
				if(labanalyses[n].split("£").length>=2 && labanalyses[n].split("£")[1].split("_").length==2 && 
				   Integer.parseInt(labanalyses[n].split("£")[1].split("_")[0])==column &&
				   Integer.parseInt(labanalyses[n].split("£")[1].split("_")[1])==row){
					return labanalyses[n].split("£")[0]; // 0
				}
			}
		}
		return "";
	}

    //--- GET ITEM COLOR --------------------------------------------------------------------------
	public String getItemColor(String[] labanalyses, int column, int row, boolean asHtml){
		if(labanalyses!=null){
			for(int n=0; n<labanalyses.length; n++){
				if(labanalyses[n].split("£").length>=3 && labanalyses[n].split("£")[2].split("_").length>0 &&
				   Integer.parseInt(labanalyses[n].split("£")[1].split("_")[0])==column &&
				   Integer.parseInt(labanalyses[n].split("£")[1].split("_")[1])==row){
					if(asHtml){
						if(labanalyses[n].split("£")[2].length() > 0){
						    return " style='background-color:#"+labanalyses[n].split("£")[2]+"'";
						}
						else{
							return ""; // empty
						}
					}
					else{
					    return labanalyses[n].split("£")[2]; // 2
					}
				}
			}
		}
		return "";
	}
%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* system/manageQuickLabList.jsp *******************");
    	Debug.println("submit           : "+(request.getParameter("submit")!=null));
    	Debug.println("UserQuickLabList : "+(request.getParameter("UserQuickLabList")!=null)+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    
    
    //*** SAVE ************************************************************************************
	if(request.getParameter("submit")!=null){
		Enumeration parameterNames = request.getParameterNames();
		SortedMap labanalyses = new TreeMap();
		
		while(parameterNames.hasMoreElements()){
			String parameterName = (String)parameterNames.nextElement();
			
			if(parameterName.startsWith("anal_")){
				String parameterValue = request.getParameter(parameterName);

				if(parameterValue.length() > 0){
					if(parameterValue.startsWith("$")){
						labanalyses.put(parameterName,parameterValue);
					}
					else if(parameterValue.startsWith("^")){
						labanalyses.put(parameterName,parameterValue);
					}
					else{
						LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(parameterValue);
						if(labAnalysis!=null && LabAnalysis.labelForCode(parameterValue,sWebLanguage)!=null){
							labanalyses.put(parameterName,parameterValue);
						}
						else{
							Debug.println("WARNING : Could not find labanalysis with code '"+parameterValue+"'");
							sMsg+= "<font color='red'>WARNING : Could not find labanalysis with code '"+parameterValue+"'</font><br>";
						}
					}
			    }
			}
		}
		
		String pars = "";
		Iterator p = labanalyses.keySet().iterator();
		while(p.hasNext()){
			String name = (String)p.next();
			String labanalysis = (String)labanalyses.get(name);
			if(pars.length() > 0){
				pars+= ";";
			}
			pars+= labanalysis+"£"+name.split("_")[1]+"_"+name.split("_")[2]+"£"+
			       checkString(request.getParameter(name.replace("anal_","analysiscolor_")));
		}
		
		if(request.getParameter("UserQuickLabList")!=null){
			MedwanQuery.getInstance().setConfigString("quickLabList_"+activeUser.userid,pars);
			Debug.println("--> SAVE : config 'quickLabList."+activeUser.userid+"' = "+pars);
		}
		else{
			MedwanQuery.getInstance().setConfigString("quickLabList",pars);
			Debug.println("--> SAVE : config 'quickLabList' = "+pars);
		}
		
		sMsg+= getTran("web","dataIsSaved",sWebLanguage);
	}

    //*** fetch saved analyses for display ***
    String sLabAnalyses, labAnalyses[] = null;
    		
    sLabAnalyses = MedwanQuery.getInstance().getConfigString("quickLabList."+activeUser.userid,"");
	if(request.getParameter("UserQuickLabList")!=null && sLabAnalyses.length() > 0){
		Debug.println("--> LOAD : config 'quickLabList."+activeUser.userid+"' = "+sLabAnalyses);		
	}
	else{
		sLabAnalyses = MedwanQuery.getInstance().getConfigString("quickLabList","");
		Debug.println("--> LOAD : config 'quickLabList' = "+sLabAnalyses); 
	}

	if(sLabAnalyses.length() > 0){
		sLabAnalyses = sLabAnalyses.replaceAll("\\.","_");
	    labAnalyses = sLabAnalyses.split(";");
	}
	
	int rows = MedwanQuery.getInstance().getConfigInt("quickLabListRows",20),
	    cols = MedwanQuery.getInstance().getConfigInt("quickLabListCols",2);
%>

<form name="transactionForm" method="post">
    <%=writeTableHeader("Web.UserProfile","ManageQuickLabList",sWebLanguage," doBack();")%>
    <%=getTran("web","click.code.field.to.choose.color",sWebLanguage)%><br><br>
    
	<table width="100%" cellspacing="1" class="list" width="100%">
		<%
			out.print("<tr>");
			for(int n=0; n<cols; n++){
				out.print("<td class='admin'>"+getTran("web","code",sWebLanguage)+"</td>");
				out.print("<td class='admin'>"+getTran("web","description",sWebLanguage)+"</td>");
			}
			out.print("</tr>");
			
			for(int n=0; n<rows; n++){
		        %><tr><%
		        
				for(int i=0; i<cols; i++){   
					//*** 1 - CODE ***
	      			%>
						<td id="td_anal_<%=i%>_<%=n%>" <%=getItemColor(labAnalyses,i,n,true)%> width='1%' nowrap>
							<input name="anal_<%=i%>_<%=n%>" type="text" class="text" value="<%=getItemValue(labAnalyses,i,n)%>" onclick="chooseColor('<%=i%>_<%=n%>');"/>
							<input name="analysiscolor_<%=i%>_<%=n%>" id="analysiscolor_<%=i%>_<%=n%>" type="hidden" value="<%=getItemColor(labAnalyses,i,n,false)%>"/>
							
							<img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchLabAnalysis('<%=i+"_"+n%>');">
						</td>
				    <%
				    
					//*** 2 - DESCRIPTION ***
					String val = getItemValue(labAnalyses,i,n);
					if(val.length() > 0){
						if(val.startsWith("$")){
							out.print("<td id='td_analysisname_"+i+"_"+n+"' "+getItemColor(labAnalyses,i,n,true)+" width='"+(100/cols)+"%' class='admin'>"+val.substring(1)+"<hr/></td>");
						}
						
						if(val.startsWith("^")){
							// Todo: labprofile opzoeken!
							out.print("<td id='td_analysisname_"+i+"_"+n+"' "+getItemColor(labAnalyses,i,n,true)+" width='"+(100/cols)+"%' class='admin2'><img width='16px' src='_img/multiple.gif'/> - "+LabAnalysis.labelForCode(val.substring(1),sWebLanguage)+"</td>");
						}
						else{
							LabAnalysis labAnalysis = LabAnalysis.getLabAnalysisByLabcode(val);
							if(labAnalysis!=null && LabAnalysis.labelForCode(val, sWebLanguage)!=null){
								out.print("<td id='td_analysisname_"+i+"_"+n+"' "+getItemColor(labAnalyses,i,n,true)+" width='"+(100/cols)+"%'>"+LabAnalysis.labelForCode(val,sWebLanguage)+"</td>");
							}
							else{
								out.print("<td id='td_analysisname_"+i+"_"+n+"' width='"+(100/cols)+"%'><font color='red' class='admin2'>Code not found</font></td>");
							}
						}
					}
					else{
						out.print("<td id='td_analysisname_"+i+"_"+n+"' "+getItemColor(labAnalyses,i,n,true)+" width='"+(100/cols)+"%'>&nbsp;</td>");
					}
				}
		        
			    %></tr><%
			}
		%>
	</table>
	
	<%
	    if(sMsg.length() > 0){
	        %><%=sMsg%><br><%
	    }
	%>	
	
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","save",sWebLanguage)%>"/>&nbsp;
	    <input type="button" class="button" name="backbutton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>	
</form>

<script>
  <%-- SEARCH LAB ANALYSIS --%>
  function searchLabAnalysis(id){
	eval("transactionForm.anal_"+id+".value = '';");
	eval("document.getElementById('td_analysisname_"+id+"').innerHTML = '';");
    openPopup("/_common/search/searchLabAnalysisAndGroups.jsp&ts=<%=getTs()%>&VarCode=anal_"+id+"&VarTextHtml=td_analysisname_"+id);
  }

  <%-- CHOOSE COLOR --%>
  function chooseColor(id){
    openPopup("/util/colorPicker.jsp&ts=<%=getTs()%>"+
    		  "&colorfields=td_anal_"+id+";td_analysisname_"+id+
    		  "&valuefield=analysiscolor_"+id+
    		  "&defaultcolor="+document.getElementById("analysiscolor_"+id).value);
  }

  <%-- DO BACK --%>
  function doBack(){
	<%
        if(checkString(request.getParameter("UserQuickLabList")).equals("1")){
	        %>window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";<%
	    }
	    else{
	        %>window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";<%
	    }
	%>
  }
</script>