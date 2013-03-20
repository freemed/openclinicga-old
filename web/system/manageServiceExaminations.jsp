<%@page import="be.openclinic.system.ServiceExamination,java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.manageserviceexaminations","all",activeUser)%>
<%=sJSSORTTABLE%>
<%
    String sAction          = checkString(request.getParameter("Action")),
           sFindServiceCode = checkString(request.getParameter("FindServiceCode")),
           sFindServiceText = checkString(request.getParameter("FindServiceText"));

    // DEBUG //////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n### mngServiceExaminations ###");
        Debug.println("# sAction          : "+sAction);
        Debug.println("# sFindServiceCode : "+sFindServiceCode);
        Debug.println("# sFindServiceText : "+sFindServiceText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    //--- SAVE ------------------------------------------------------------------------------------
    // delete all examinations for the specified service,
    // then add all selected examinations (those in request)
    if (sAction.equals("save")) {
        ServiceExamination.deleteAllExaminationsForService(sFindServiceCode);

        String examId;
		Enumeration params = request.getParameterNames();
		while(params.hasMoreElements()){
			String param = (String)params.nextElement();
			if(param.startsWith("cb")){
				String examiniationId = param.substring(2);
				ServiceExamination serviceExamination = new ServiceExamination();
				serviceExamination.setExaminationid(examiniationId);
				serviceExamination.setServiceid(sFindServiceCode);
				serviceExamination.saveToDB();
			}
		}

		MedwanQuery.getInstance().removeServiceExaminations(sFindServiceCode);

        //sAction = "edit";
    }
%>
<form id="transactionForm" name="transactionForm" method="post">
    <input type="hidden" name="Action" id="Action">
    <%=writeTableHeader("Web.manage","ManageServiceExaminations",sWebLanguage," doBackToMenu();")%>
    <%-- SEARCH SERVICE --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("Web","Unit",sWebLanguage)%></td>
            <td>
                <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">
                <%=ScreenHelper.writeServiceButton("buttonService","FindServiceCode","FindServiceText",sWebLanguage,sCONTEXTPATH)%>
                <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;

                <%-- BUTTONS --%>
                <input type="button" class="button" name="editButton" value="<%=getTran("Web","Edit",sWebLanguage)%>" onclick="document.getElementById('Action').value='edit';transactionForm.submit();">
            </td>
        </tr>
    </table>

	<table width='100%'>
    <%
        //--- EDIT FIELDS -------------------------------------------------------------------------
        if (sAction.equals("edit") && sFindServiceCode.length() > 0) {
        	Vector examinations = ServiceExamination.selectServiceExaminations(sFindServiceCode);
        	System.out.println("examinations="+examinations);
        	Hashtable hExaminations = new Hashtable();
        	for(int n=0;n<examinations.size();n++){
        		ServiceExamination examination = (ServiceExamination)examinations.elementAt(n);
        		hExaminations.put(examination.getExaminationid(),"1");
        	}
        	System.out.println("hExaminations="+hExaminations);
        	
        	//Load all available examinations and put them in a sorted map
        	SortedMap exams = new TreeMap();
    		SAXReader xmlReader = new SAXReader();
	        Document document;
	        String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
	        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
	        // Check if menu file exists, else use file at templateSource location.
        	System.out.println("sMenuXMLUrl="+sMenuXMLUrl);
	        document = xmlReader.read(new URL(sMenuXMLUrl));
	        if (document != null) {
	        	System.out.println("document="+document);
	            Element root = document.getRootElement();
	            if (root != null) {
	                Iterator elements = root.elementIterator("Row");
	                while (elements.hasNext()) {
	                    Element e = (Element) elements.next();
	                    if(e!=null){
		                    String elementClass = "?";
		                    Element eClass=e.element("class");
		                    if(eClass!=null){
		                    	elementClass=eClass.getText();
		                    }
		                    if(exams.get(getTran("web",elementClass,sWebLanguage))==null){
		                    	exams.put(getTran("web",elementClass,sWebLanguage),new TreeMap());
		                    }
		                    SortedMap serviceExams = (TreeMap)exams.get(getTran("web",elementClass,sWebLanguage));
		                    serviceExams.put(getTran("examination",e.element("id").getText(),sWebLanguage)+" ("+e.element("id").getText()+")",e.element("id").getText());
	                    }
	                }
	            }
	        }
	        //Now we have all exams, let's show them
			Iterator i = exams.keySet().iterator();
	        while(i.hasNext()){
	        	String key = (String)i.next();
	        	out.println("<tr class='admin'><td colspan='5'>"+key+"</td></tr>");
	        	SortedMap serviceExams = (TreeMap)exams.get(key);
	        	Iterator j = serviceExams.keySet().iterator();
				int examCounter=0;
	        	while(j.hasNext()){
	        		if(examCounter % 5 ==0){
	        			out.println("<tr>");
	        		}
	        		key = (String)j.next();
	        		out.println("<td class='admin'><input type='checkbox' name='cb"+serviceExams.get(key)+"' "+(hExaminations.get(serviceExams.get(key))!=null?"checked":"")+"/>"+key+"</td>");
	        		examCounter++;
	        		if(examCounter % 5 ==0){
	        			out.println("</tr>");
	        		}
	        	}
	        	if(examCounter % 5!=0){
		        	while(examCounter % 5!=0){
		        		out.println("<td class='admin2'/>");
		        		examCounter++;
		        	}
        			out.println("</tr>");
	        	}
	        }

	%>
	    <tr><td><input type="button" class="button" name="saveButton" value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="document.getElementById('Action').value='save';transactionForm.submit();"></td></tr>
	<%
        }
    %>
    
    </table>
</form>

