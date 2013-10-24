<%@page import="be.openclinic.id.FingerPrint"%>
<%@page import="be.mxs.common.util.system.Picture"%>
<%@page import="be.openclinic.id.Barcode"%>
<%@page import="java.io.StringReader"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET MENU ELEMENT ------------------------------------------------------------------------
    private Element getMenuElement(HttpSession session, String sMenuPath) throws Exception {
    	//Debug.println("\n************ getMenuElement ("+sMenuPath+") ******************");
    	if(sMenuPath.indexOf("$") > -1){
    		// trim off the second part (document-type)
    		sMenuPath = sMenuPath.substring(0,sMenuPath.indexOf("$"));
    	}
    	String[] pathParts = sMenuPath.split("\\.");
    	int menuDepth = 0;
    	Element menuElem = null;
    	
        String sMenuXML = checkString((String)session.getAttribute("MenuXML"));
        SAXReader xmlReader = new SAXReader();
        Document document = xmlReader.read(new StringReader(sMenuXML));
           
        if(document!=null){
            Element root = document.getRootElement();
            
            if(root!=null){
                Iterator menuElems = root.elementIterator("Menu");
                Element tmpMenuElem;
                
                while(menuElems.hasNext()){
                	tmpMenuElem = (Element)menuElems.next();

                	if(checkString(tmpMenuElem.attributeValue("labelid")).equalsIgnoreCase(pathParts[menuDepth])){
                		menuDepth++;
                		
                		if(menuDepth >= pathParts.length){
	                		menuElem = tmpMenuElem;
                		}
                		else{
                			String sNewMenuPath = "";
                			for(int p=menuDepth; p<pathParts.length; p++){
                				sNewMenuPath+= pathParts[p]+".";
                			}
                			if(sNewMenuPath.endsWith(".")){
                			     sNewMenuPath = sNewMenuPath.substring(0,sNewMenuPath.length()-1);
                			}
                			
                			menuElem = getMenuElementRecursive(session,tmpMenuElem,sNewMenuPath);
                		}
                		
                		break;
                	}
                }
            }
        }
        
        return menuElem;
    }
    
    //--- GET MENU ELEMENT RECURSIVE --------------------------------------------------------------
    private Element getMenuElementRecursive(HttpSession session, Element menuElem, String sMenuPath) throws Exception {
    	//Debug.println("*** getMenuElementRecursive ("+sMenuPath+") ***");
    	String[] pathParts = sMenuPath.split("\\.");
    	int menuDepth = 0;
    	
        Iterator menuElems = menuElem.elementIterator("Menu");
        Element tmpMenuElem;
        
        while(menuElems.hasNext()){
        	tmpMenuElem = (Element)menuElems.next();

        	if(checkString(tmpMenuElem.attributeValue("labelid")).equalsIgnoreCase(pathParts[menuDepth])){
        		menuDepth++;
        		
        		if(menuDepth >= pathParts.length){
         		    menuElem = tmpMenuElem;
        		}
        		else{
        			String sNewMenuPath = "";
        			for(int p=menuDepth; p<pathParts.length; p++){
        				sNewMenuPath+= pathParts[p]+".";
        			}
        			if(sNewMenuPath.endsWith(".")){
        			     sNewMenuPath = sNewMenuPath.substring(0,sNewMenuPath.length()-1);
        			}
        			
        			menuElem = getMenuElementRecursive(session,tmpMenuElem,sNewMenuPath);
        		}
        		
        		break;
        	}
        }
        
        return menuElem;
    }
%>

<%
    //--- 1 - USER DEFINED ICONS ------------------------------------------------------------------
    String sIconsDir = MedwanQuery.getInstance().getConfigString("localProjectPath")+"/_img/shortcutIcons";
    Vector userParameters = activeUser.getUserParametersByType(activeUser.userid,"usershortcut$");

    Element menuElem;
    String sLongLabelId, sIconName, sIconOnClick, sIconText = "", sLabelType, sShortcutTitle;
    UserParameter userParameter;

    Debug.println("\n***** userShortcuts (userid:"+activeUser.userid+") : "+userParameters.size()+" *****");
    for(int i=0; i<userParameters.size(); i++){
        userParameter = (UserParameter)userParameters.get(i);
        Debug.println("\nuserShortcut : "+userParameter.getParameter());
        
        sLongLabelId = userParameter.getParameter().substring("usershortcut$".length());

        // parse 'parameter' of parameter
       	String[] iconTypes = userParameter.getParameter().split("\\$");
        String sSubtype = "";
        if(iconTypes.length==3){
        	sSubtype = iconTypes[2]; 
        }
        
        // parse value of parameter
       	String[] iconValues = userParameter.getValue().split("\\$");
        sIconName = iconValues[0];
        sIconOnClick = iconValues[1].replaceAll("\"","'"); // javascript-related
       	if(iconValues.length > 2){
            sIconText = iconValues[2];
       	}

       	if(Debug.enabled){
       		Debug.println("  sIconName    : "+sIconName);
       		Debug.println("  sIconOnClick : "+sIconOnClick);
       		Debug.println("  sIconText    : "+sIconText);
       	}
       	
       	// for links containing a regular url, add an open command
       	if(!sIconOnClick.toLowerCase().startsWith("javascript")){
      		sIconOnClick = "window.location.href = '"+sCONTEXTPATH+"/"+sIconOnClick+
       				       "&ts="+getTs()+"';";
   		}
       	
       	// replace placeholders for parameters
       	if(sLongLabelId.startsWith("hidden.clinicalDocuments$")){
       	    sIconOnClick = sIconOnClick.replaceAll("@parameter1@",sSubtype);
       	}

       	//*** fetch extra data from xml (accessrights and such) ***
       	boolean okToDisplayIcon = false;
    	menuElem = getMenuElement(session,sLongLabelId);

       	if(menuElem!=null){
            // look for required permissions
           	Debug.println("accessrights : "+checkString(menuElem.attributeValue("accessrights")));
            if(checkString(menuElem.attributeValue("accessrights")).length() > 0){
	        	if(activeUser.getAccessRight(menuElem.attributeValue("accessrights"))){
	            	okToDisplayIcon = true;
	        	}
            }
            else{
            	// no permission required
            	okToDisplayIcon = true;
            }
            
            // continue checking requirements
       		if(okToDisplayIcon){
           		// check wether patient is selected when the xml-menu-item demands it
	       		String sPatientSelectedRequired = checkString(menuElem.attributeValue("patientselected"));
           		Debug.println("sPatientSelectedRequired : "+sPatientSelectedRequired); 
		        if(sPatientSelectedRequired.equalsIgnoreCase("true")){
		        	boolean patientSelected = (activePatient!=null && activePatient.personid.length() > 0);
	           		Debug.println("patientSelected : "+patientSelected);
	                okToDisplayIcon = patientSelected;
	            }
       		}

            // continue checking requirements
       		if(okToDisplayIcon){
	       		// check wether employee is selected when the xml-menu-item demands it
	       		String sEmployeeSelectedRequired = checkString(menuElem.attributeValue("employeeselected"));
           		Debug.println("sEmployeeSelectedRequired : "+sEmployeeSelectedRequired);
		        if(sEmployeeSelectedRequired.equalsIgnoreCase("true")){
	                boolean employeeSelected = activePatient.isEmployee();
	           		Debug.println("employeeSelected : "+employeeSelected);
	                okToDisplayIcon = employeeSelected;
		    	}
       		}
       	}
       	else{
       		Debug.println("menuElem '"+sLongLabelId+"' not found in menu.xml");
       	}

   		Debug.println("--> okToDisplayIcon : "+okToDisplayIcon);
       	if(okToDisplayIcon){
            %><img class="link" src="<%=sCONTEXTPATH%>/_img/shortcutIcons/<%=sIconName%>" onClick="<%=sIconOnClick%>" title="<%=sIconText%>"/>&nbsp;<%
       	}
    } 

    //--- 2 - DEFAULT SYSTEM ICONS ---------------------------------------------------------------- 
    String sPage = checkString(request.getParameter("Page")).toLowerCase();

    boolean bMenu = false;
    if((activePatient!=null) && (activePatient.lastname!=null) && (activePatient.personid.trim().length()>0)){
        if(!sPage.equals("patientslist.jsp")){
            bMenu = true;
        }
    }
    else{
        activePatient = new AdminPerson();
    }
    
    if(activePatient!=null && "1".equalsIgnoreCase((String)activePatient.adminextends.get("vip")) && !activeUser.getAccessRight("vipaccess.select")){
        // empty
    }
    else{
        %><input type="text" id="barcode" name="barcode" size="8" class="text" style="{visibility: hidden;color: #FFFFFF;background: #EEEEEE; background-color: #EEEEEE;border-style: none;}" onKeyDown="if(enterEvent(event,13)){readBarcode2(this.value);}"/><%
                
        String sTmpPersonid = checkString(request.getParameter("personid"));
        if (sTmpPersonid.length() == 0) {
            sTmpPersonid = checkString(request.getParameter("PersonID"));
        }
        
        if(sTmpPersonid.length() > 0){
            boolean bFingerPrint = FingerPrint.exists(Integer.parseInt(sTmpPersonid));
            boolean bPicture = Picture.exists(Integer.parseInt(sTmpPersonid));
            boolean bBarcode = Barcode.exists(Integer.parseInt(sTmpPersonid));
            
            if(!bFingerPrint){
                %> <img class="link" onclick="enrollFingerPrint();" border="0" src="<c:url value='/_img/icon_fingerprint_enroll.png'/>" alt="<%=getTranNoLink("web","enrollFingerPrint",sWebLanguage)%>"/><%
            }
            if(!bBarcode){
                %> <img class="link" onclick="printPatientCard();"  border='0' src="<c:url value='/_img/icon_barcode.gif'/>" alt="<%=getTranNoLink("web","printPatientCard",sWebLanguage)%>"/><%
            }
            if(!bPicture){
                %> <img class="link" onclick="storePicture();"  border='0' src="<c:url value='/_img/icon_camera.png'/>" alt="<%=getTranNoLink("web","loadPicture",sWebLanguage)%>"/><%
            }
        }
        
        if(activePatient!=null && activePatient.personid!=null && activePatient.personid.length()>0 && MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("openpharmacy")){
            %><img class="link" onclick="showdrugsoutbarcode();"  border='0' src="<c:url value='/_img/icon_pharma.png'/>" alt="<%=getTranNoLink("web","drugsoutbarcode",sWebLanguage)%>"/><%
        }
        if(activeUser.getAccessRight("labos.patientlaboresults.select") && activePatient!=null && activePatient.personid.length()>0 && activePatient.hasLabRequests()){
            %><img class="link" onclick="searchLab();" title="<%=getTranNoLink("Web","labresults",sWebLanguage)%>"  src="<c:url value='/_img/icon_labo.png'/>" /><%
        }
        if(bMenu && activeUser.getAccessRight("labos.fastresults.select")){
            %><img class="link" onclick="showLabResultsEdit();" title="<%=getTranNoLink("Web","fastresultsedit",sWebLanguage)%>"  src="<c:url value='/_img/icon_labo_insert.png'/>" /><%
        }
        if(bMenu && activeUser.getAccessRight("patient.administration.select")){
            %><img class="link" onclick="showAdminPopup();" title="<%=getTranNoLink("Web","Administration",sWebLanguage)%>" src="<c:url value='/_img/icon_admin.png'/>" /><%
        }
    
        %><img class="link" onclick="searchMyHospitalized();" alt="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>" title="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>"  src="<c:url value='/_img/icon_bed.png'/>" /><%
  
        if(activeUser.getAccessRight("manage.meals.select")){
            %><img class="link" onclick="window.location = '<c:url value="/main.do" />?Page=meals/manageMeals.jsp&ts='+new Date().getTime()" alt="<%=getTranNoLink("web","meals",sWebLanguage)%>" title="<%=getTranNoLink("web","meals",sWebLanguage)%>"  src="<c:url value='/_img/icon_meals.png'/>" /><%
        }
        
        %>
            <img class="link" onclick="searchMyVisits();" title="<%=getTranNoLink("Web","my_on_visit_patients",sWebLanguage)%>"  src="<c:url value='/_img/icon_doctor.png'/>" />
            <img class="link" onclick="doPrint();" title="<%=getTranNoLink("Web","Print",sWebLanguage)%>" src="<c:url value='/_img/printer-print.png'/>" />
            <img class="link" id="ddIconAgenda" onclick="window.location='<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&ts='+new Date().getTime()" title="<%=getTranNoLink("Web","Planning",sWebLanguage)%>"  src="<c:url value='/_img/icon_agenda.gif'/>" />
        <%
        
        String sHelp = MedwanQuery.getInstance().getConfigString("HelpFile");
        sHelp = ""; // todo : remove to active icon 
        if(sHelp.length()>0){
            %><img id="ddIconHelp" src="<c:url value='/_img/icon_help.gif'/>" height="16" width="16" border="0" alt="Help" onclick="openHelpFile();" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'><%
        }
        
        %><img class="link" id="ddIconFingerprint" onclick="readFingerprint();" title="<%=getTranNoLink("Web","Read_fingerprint",sWebLanguage)%>"  src="<c:url value='/_img/icon_fingerprint_read.png'/>" /><%
    }
%>

<img class="link" id="ddIconLogoff" onclick="confirmLogout();" title="<%=getTranNoLink("Web","LogOff",sWebLanguage)%>"  src="<c:url value='/_img/icon_logout.png'/>" />
&nbsp;   