<%@page import="be.mxs.common.util.io.messync.Examination,
                be.openclinic.system.ServiceExamination,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.manageserviceexaminations","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindServiceCode = checkString(request.getParameter("FindServiceCode")),
           sFindServiceText = checkString(request.getParameter("FindServiceText"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** system/manageServiceExaminations.jsp *****************");
        Debug.println("sAction          : "+sAction);
        Debug.println("sFindServiceCode : "+sFindServiceCode);
        Debug.println("sFindServiceText : "+sFindServiceText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    

    //--- SAVE ------------------------------------------------------------------------------------
    // delete all examinations for the specified service,
    // then add all selected examinations (those in request)
    if(sAction.equals("save")){
    	MedwanQuery.getInstance().setServiceexaminations(new Hashtable());
    	ServiceExamination.deleteAllExaminationsForService(sFindServiceCode);

        String examId;
		Enumeration params = request.getParameterNames();
		while(params.hasMoreElements()){
			String param = (String)params.nextElement();
			
			if(param.startsWith("cb_")){
				examId = param.substring("cb_".length());
		        examId = examId.substring(examId.indexOf("_")+1);
				
				ServiceExamination serviceExamination = new ServiceExamination();
				serviceExamination.setExaminationid(examId);
				serviceExamination.setServiceid(sFindServiceCode);
				serviceExamination.saveToDB();
			}
		}

		sMsg = getTran("web","dataSaved",sWebLanguage);
		sAction = "edit";
    }
%>

<form id="transactionForm" name="transactionForm" method="post" action="<%=sCONTEXTPATH%>/main.jsp?Page=system/manageServiceExaminations.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" id="Action" value="">
    
    <%=writeTableHeader("Web.manage","ManageServiceExaminations",sWebLanguage," doBack();")%>
    
    <%-- SEARCH SERVICE --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("Web","Unit",sWebLanguage)%></td>
            <td>
                <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">                
                <img src='<%=sCONTEXTPATH%>/_img/icon_search.gif' id='buttonService' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>'
                 onclick="hideServicesTable();openPopup('_common/search/searchService.jsp&VarCode=FindServiceCode&VarText=FindServiceText&onlySelectContractWithDivision=false');">
                 &nbsp;<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick="clearServiceSelection();">
              
                <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;

                <%-- BUTTONS --%>
                <input type="button" class="button" name="editButton" value="<%=getTranNoLink("Web","Edit",sWebLanguage)%>" onclick="doAction('edit');">
            </td>
        </tr>
    </table>
    
    <div id="msgDiv" style="height:20px"><%=sMsg%></div>
    
	<table width="100%" id="servicesTable">
	    <%
	        //--- EDIT FIELDS -------------------------------------------------------------------------
	        if(sAction.equals("edit") && sFindServiceCode.length() > 0){
	        	Vector examinations = ServiceExamination.selectServiceExaminations(sFindServiceCode);
	        	Hashtable hExaminations = new Hashtable();
	        	ServiceExamination examination;
	        	for(int n=0; n<examinations.size(); n++){
	        		examination = (ServiceExamination)examinations.elementAt(n);
	        		hExaminations.put(examination.getExaminationid(),"1");
	        	}
	        	
	        	// Load available examinations and put them in a sorted map
	        	SortedMap exams = new TreeMap();
	    		SAXReader xmlReader = new SAXReader();
		        String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
		        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
		        Debug.println("Reading '"+sMenuXMLUrl+"'");
		        
		        // Check if menu file exists, else use file at templateSource location.
		        Document document = xmlReader.read(new URL(sMenuXMLUrl));
		        if(document!=null){
		            Element root = document.getRootElement();
		            if(root!=null){
		                Iterator elements = root.elementIterator("Row");
		                while(elements.hasNext()){
		                    Element e = (Element) elements.next();
		                    if(e!=null){
			                    String elementClass = "?";
			                    Element eClass = e.element("class");
			                    if(eClass!=null){
			                    	elementClass = eClass.getText();
			                    }
			                    if(exams.get(elementClass)==null){
			                    	exams.put(elementClass,new TreeMap());
			                    }
			                    
			                    SortedMap serviceExams = (TreeMap)exams.get(elementClass);
			                    serviceExams.put(e.element("id").getText(),e.element("id").getText()+";"+e.element("transactiontype").getText());
		                    }
		                }
		            }
		        }
		        
		        // display examinations per service
				Iterator examIter = exams.keySet().iterator();
		        String sServiceId, sServiceName;
		        while(examIter.hasNext()){
		        	sServiceId = (String)examIter.next();
		        	sServiceName = getTran("web",sServiceId,sWebLanguage);
		           
		        	// header
		        	%>
		        	    <tr class="admin">
		        	        <td colspan="5"><b><%=sServiceName%></b>&nbsp;
		        	            <a href="javascript:void(0);" onclick="checkAll(true,'<%=sServiceId%>');"><%=getTran("web.manage.checkDb","checkAll",sWebLanguage)%></a>
	                            <a href="javascript:void(0);" onclick="checkAll(false,'<%=sServiceId%>');"><%=getTran("web.manage.checkDb","uncheckAll",sWebLanguage)%></a>
	                        </td>
	                    </tr>
	                <%
	                
		        	SortedMap serviceExams = (TreeMap)exams.get(sServiceId);
		        	Iterator examsIter = serviceExams.keySet().iterator();
		        	
					int examCounter = 0;	
					String sExamId, sExamName;
		        	while(examsIter.hasNext()){
		        		if(examCounter%5==0){
		        			out.println("<tr>");
		        		}
		        		
		        		sExamId = (String)examsIter.next();
		        		sExamName = getTran("examination",sExamId,sWebLanguage)+" ("+sExamId+")";
		        		
						String screen = MedwanQuery.getInstance().getForward(((String)serviceExams.get(sExamId)).split(";")[1]);
		        		out.println("<td class='admin'><input type='checkbox' name='cb_"+sServiceId+"_"+sExamId+"' id='cb_"+sServiceId+"_"+sExamId+"' "+(hExaminations.get(((String)serviceExams.get(sExamId)).split(";")[0])!=null?"checked":"")+"/><label for='cb_"+sServiceId+"_"+sExamId+"'>"+sExamName+"</label></td>");
		        		examCounter++;
		        		
		        		if(examCounter%5 ==0){
		        			out.println("</tr>");
		        		}
		        	}
		        	
		        	if(examCounter%5!=0){
			        	while(examCounter%5!=0){
			        		out.println("<td class='admin2'/>");
			        		examCounter++;
			        	}
	        			out.println("</tr>");
		        	}
		        }
	        }
	    %>
    
	    <tr>
	        <td colspan="5">
				<a href="javascript:void(0);" onclick="checkAll(true,'all');"><%=getTran("web.manage.checkDb","checkAll",sWebLanguage)%></a>
				<a href="javascript:void(0);" onclick="checkAll(false,'all');"><%=getTran("web.manage.checkDb","uncheckAll",sWebLanguage)%></a>
		    </td>
	    </tr>
	    
	    <%-- BUTTONS --%>
	    <tr>
	        <td colspan="5" style="text-align:center;">
			    <input type="button" class="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doAction('save');">&nbsp;
			    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">	
		    </td>
	    </tr>
    </table>
</form>

<script>
  <%-- CHECK ALL --%> 
  function checkAll(setChecked,sServiceId){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
    	if(sServiceId=="all"){
          transactionForm.elements[i].checked = setChecked;
    	}  
    	else if(transactionForm.elements[i].id.startsWith("cb_"+sServiceId)){
          transactionForm.elements[i].checked = setChecked;
        }
      }
    }
  }

  <%-- SHOW SCREEN --%>
  function showScreen(transactionType){
    openPopup(transactionType);
  }

  <%-- DO ACTION --%>
  function doAction(sAction){
    transactionForm.Action.value = sAction;
    transactionForm.submit();
  }
  
  <%-- HIDE SERVICES TABLE --%>
  function hideServicesTable(){
    document.getElementById("servicesTable").style.display = "none";
    document.getElementById("msgDiv").innerHTML = "";
  }
  
  <%-- CLEAR SERVICE SELECTION --%>
  function clearServiceSelection(){
    document.getElementsByName("FindServiceCode")[0].value = "";
    document.getElementsByName("FindServiceText")[0].value = "";
    document.getElementById("servicesTable").style.display = "none";
    document.getElementById("msgDiv").innerHTML = "";
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>