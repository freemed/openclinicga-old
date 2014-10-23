<%@page import="be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET ITEM VALUE --------------------------------------------------------------------------
	public String getItemValue(String[] prestations,int column, int row){
		if(prestations!=null){
			for(int n=0; n<prestations.length; n++){
				if(prestations[n].split("£").length>=2 && prestations[n].split("£")[1].split("\\.").length==2 &&
				   Integer.parseInt(prestations[n].split("£")[1].split("_")[0])==column &&
				   Integer.parseInt(prestations[n].split("£")[1].split("_")[1])==row){
					return prestations[n].split("£")[0]; // 0
				}
			}
		}
		return "";
	}

    //--- GET ITEM COLOR --------------------------------------------------------------------------
	public String getItemColor(String[] prestations,int column, int row, boolean asHtml){
		if(prestations!=null){
			for(int n=0; n<prestations.length; n++){
				if(prestations[n].split("£").length>=3 && prestations[n].split("£")[2].length()>0 &&
				   Integer.parseInt(prestations[n].split("£")[1].split("_")[0])==column &&
				   Integer.parseInt(prestations[n].split("£")[1].split("_")[1])==row){
					if(asHtml){
						if(prestations[n].split("£")[2].length() > 0){
						    return " style='background-color:#"+prestations[n].split("£")[2]+"'";
						}
						else{
							return ""; // empty
						}
					}
					else{
					    return prestations[n].split("£")[2]; // 2
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
		Debug.println("\n********************** system/manageQuickList.jsp *********************");
		Debug.println("submit        : "+(request.getParameter("submit")!=null));
		Debug.println("UserQuickList : "+(request.getParameter("UserQuickList")!=null)+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
	

    //*** SAVE ************************************************************************************
	if(request.getParameter("submit")!=null){
		Enumeration parameterNames = request.getParameterNames();
		SortedMap prestations = new TreeMap();
		
		while(parameterNames.hasMoreElements()){
			String parameterName = (String)parameterNames.nextElement();
			
			if(parameterName.startsWith("prest_")){
				String parameterValue = request.getParameter(parameterName);
				
				if(parameterValue.startsWith("$")){
					prestations.put(parameterName,parameterValue);
				}
				else if(parameterValue.length() > 0){
					Prestation prestation = Prestation.getByCode(parameterValue);
					if(prestation!=null && prestation.getDescription()!=null){
						prestations.put(parameterName,parameterValue);
					}
					else{
						Debug.println("WARNING : Could not find prestation with code '"+parameterValue+"'");
						sMsg+= "<font color='red'>WARNING : Could not find prestation with code '"+parameterValue+"'</font><br>";
					}
				}
			}
		}
		
		String pars = "";
		Iterator p = prestations.keySet().iterator();
		while(p.hasNext()){
			String name = (String)p.next();
			String prestation = (String)prestations.get(name);
			if(pars.length() > 0){
				pars+= ";";
			}
			pars+= prestation+"£"+name.split("\\.")[1]+"_"+name.split("\\.")[2]+"£"+
			       checkString(request.getParameter(name.replace("prest_","prestcolor_")));
		}
		
		if(request.getParameter("UserQuickList")!=null){
			MedwanQuery.getInstance().setConfigString("quickList_"+activeUser.userid,pars);
			Debug.println("--> SAVE : config 'quickList_"+activeUser.userid+"' = "+pars);
		}
		else{
			MedwanQuery.getInstance().setConfigString("quickList",pars);
			Debug.println("--> SAVE : config 'quickList' = "+pars);
		}
		
		sMsg+= getTran("web","dataIsSaved",sWebLanguage);
	}
	
    //*** fetch saved prestations for display ***
    String sPrestations, prestations[] = null;
    		
    sPrestations = MedwanQuery.getInstance().getConfigString("quickList_"+activeUser.userid,"");
	if(request.getParameter("UserQuickList")!=null && sPrestations.length() > 0){
		Debug.println("--> LOAD : config 'quickList_"+activeUser.userid+"' = "+sPrestations);		
	}
	else{
		sPrestations = MedwanQuery.getInstance().getConfigString("quickList","");
		Debug.println("--> LOAD : config 'quickList' = "+sPrestations); 
	}

	if(sPrestations.length() > 0){
		sPrestations = sPrestations.replaceAll("\\.","_");
		prestations = sPrestations.split(";");
	}
	
	int rows = MedwanQuery.getInstance().getConfigInt("quickListRows",20),
		cols = MedwanQuery.getInstance().getConfigInt("quickListCols",2);
%>

<form name="transactionForm" method="post">
    <%=writeTableHeader("Web.UserProfile","ManageQuickList",sWebLanguage," doBack();")%>
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
				    %>
						<td id="td_prest_<%=i%>_<%=n%>" <%=getItemColor(prestations,i,n,true)%> width='1%' nowrap>
							<input name="prest_<%=i%>_<%=n%>" type="text" class="text" size="10" onclick="chooseColor('<%=i%>_<%=n%>');" value="<%=getItemValue(prestations,i,n)%>"/>
							<input name="prestcolor_<%=i%>_<%=n%>" id="prestcolor_<%=i%>_<%=n%>" class="Multiple" type="hidden" value="<%=getItemColor(prestations,i,n,false)%>"/>
							
							<img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrestation('<%=i+"_"+n%>');">
						</td>
				    <%
				    
					String val = getItemValue(prestations,i,n);
					if(val.length() > 0){
						if(val.startsWith("$")){
							out.print("<td id='td_prestname_"+i+"_"+n+"' "+getItemColor(prestations,i,n,true)+" width='"+(100/cols)+"%' class='admin'>"+val.substring(1)+"<hr/></td>");
						}
						else{
							Prestation prestation = Prestation.getByCode(val);
							if(prestation!=null && prestation.getDescription()!=null){
								out.print("<td id='td_prestname_"+i+"_"+n+"' "+getItemColor(prestations,i,n,true)+" width='"+(100/cols)+"%'>"+prestation.getDescription()+"</td>");
							}
							else{
								out.print("<td id='td_prestname_"+i+"_"+n+"' "+getItemColor(prestations,i,n,true)+" width='"+(100/cols)+"%'><font color='red'>Code not found</font></td>");
							}
						}
					}
					else{
						out.print("<td id='td_prestname_"+i+"_"+n+"' "+getItemColor(prestations,i,n,true)+" width='"+(100/cols)+"%'>&nbsp;</td>");
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
  <%-- SEARCH PRESTATION --%>
  function searchPrestation(id){
	eval("transactionForm.prest_"+id+".value = '';");
	eval("document.getElementById('td_prestname_"+id+"').innerHTML = '';");
    openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldCode=prest_"+id+"&ReturnFieldDescrHtml=prestname_"+id);
  }

  <%-- CHOOSE COLOR --%>
  function chooseColor(id){
    openPopup("/util/colorPicker.jsp&ts=<%=getTs()%>"+
    		  "&colorfields=td_prest_"+id+";td_prestname_"+id+
              "&valuefield=prestcolor_"+id+
              "&defaultcolor="+document.getElementById("prestcolor_"+id).value);
  }
  
  <%-- DO BACK --%>
  function doBack(){
	<%
	    if(checkString(request.getParameter("UserQuickList")).equals("1")){
	        %>window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";<%
	    }
	    else{
	        %>window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";<%
	    }
	%>
  }
</script>