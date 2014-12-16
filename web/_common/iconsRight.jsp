<%@page import="be.openclinic.id.FingerPrint,
                be.mxs.common.util.system.Picture,
                be.openclinic.id.Barcode,
                java.io.StringReader"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET MENU ELEMENT ------------------------------------------------------------------------
    private Element getMenuElement(HttpSession session, String sMenuPath) throws Exception {
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
    String sIconsDir = sAPPFULLDIR+"/_img/shortcutIcons";
    Vector userParameters = activeUser.getUserParametersByType(activeUser.userid,"usershortcut$");

    Element menuElem;
    String sLongLabelId, sIconName, sIconOnClick, sIconText = "", sLabelType, sShortcutTitle;
    UserParameter userParameter;

    //Debug.println("\n***** userShortcuts (userid:"+activeUser.userid+") : "+userParameters.size()+" *****");
    for(int i=0; i<userParameters.size(); i++){
        userParameter = (UserParameter)userParameters.get(i);
        //Debug.println("\nuserShortcut : "+userParameter.getParameter());
        
        sLongLabelId = userParameter.getParameter().substring("usershortcut$".length());

        // parse 'parameter' of parameter
       	String[] iconTypes = userParameter.getParameter().split("\\$");
        String sSubtype = "";
        if(iconTypes.length>=3){
        	sSubtype = iconTypes[2]; 
        }
        
        // parse value of parameter
       	String[] iconValues = userParameter.getValue().split("\\$");
        sIconName = iconValues[0];
        sIconOnClick = iconValues[1].replaceAll("\"","'"); // javascript-related
       	if(iconValues.length > 2){
            sIconText = iconValues[2];
       	}

        /*
        /// DEBUG /////////////////////////////////////////////////////////////
       	if(Debug.enabled){
       		Debug.println("  sSubtype     : "+sSubtype);
       		Debug.println("  sIconName    : "+sIconName);
       		Debug.println("  sIconOnClick : "+sIconOnClick);
       		Debug.println("  sIconText    : "+sIconText);
       	}
        ///////////////////////////////////////////////////////////////////////
       	*/
       	
       	// for links containing a regular url, add an open command
       	if(!sIconOnClick.toLowerCase().startsWith("javascript")){
      		sIconOnClick = "javascript:clickMenuItem('"+sCONTEXTPATH+"/"+sIconOnClick+"&ts="+getTs()+"');";
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
           	//Debug.println("accessrights : "+checkString(menuElem.attributeValue("accessrights")));
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
           		//Debug.println("sPatientSelectedRequired : "+sPatientSelectedRequired); 
           		
		        if(sPatientSelectedRequired.equalsIgnoreCase("true")){
		        	boolean patientSelected = (activePatient!=null && activePatient.personid.length() > 0);
	           		//Debug.println("patientSelected : "+patientSelected);
	                okToDisplayIcon = patientSelected;
	            }
       		}

            // continue checking requirements
       		if(okToDisplayIcon){
	       		// check wether employee is selected when the xml-menu-item demands it
	       		String sEmployeeSelectedRequired = checkString(menuElem.attributeValue("employeeselected"));
           		//Debug.println("sEmployeeSelectedRequired : "+sEmployeeSelectedRequired);
           		
		        if(sEmployeeSelectedRequired.equalsIgnoreCase("true")){
	                boolean employeeSelected = activePatient.isEmployee();
	           		//Debug.println("employeeSelected : "+employeeSelected);
	                okToDisplayIcon = employeeSelected;
		    	}
       		}
       	}
       	else{
       		//Debug.println("menuElem '"+sLongLabelId+"' not found in menu.xml");
       	}

   		//Debug.println("--> okToDisplayIcon : "+okToDisplayIcon);
       	if(okToDisplayIcon){
            %><img class="link" src="<%=sCONTEXTPATH%>/_img/shortcutIcons/<%=sIconName%>" onClick="<%=sIconOnClick%>" title="<%=sIconText%>" style="width:16px;height:16px;"/>&nbsp;<%
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
        %>
            <input type="text" id="barcode" name="barcode" size="8" class="text" style="{visibility:hidden;color:#FFFFFF;background:#EEEEEE;background-color:#EEEEEE;border-style:none;}" onKeyDown="if(enterEvent(event,13)){if(checkSaveButton())readBarcode2(this.value);}"/>
            <script>document.getElementsByName('barcode')[0].style.visibility = "hidden";</script>
        <%
                
        String sTmpPersonid = checkString(request.getParameter("personid"));
        if(sTmpPersonid.length()==0){
            sTmpPersonid = checkString(request.getParameter("PersonID"));
        }
        
        if(sTmpPersonid.length() > 0){
            boolean bFingerPrint = FingerPrint.exists(Integer.parseInt(sTmpPersonid));
            boolean bPicture = Picture.exists(Integer.parseInt(sTmpPersonid)),
                    bBarcode = Barcode.exists(Integer.parseInt(sTmpPersonid));
            
            if(!bFingerPrint){
                %> <img class="link" onclick="enrollFingerPrint();" border="0" src="<c:url value='/_img/icons/icon_fingerprint_enroll.png'/>" alt="<%=getTranNoLink("web","enrollFingerPrint",sWebLanguage)%>"/><%
            }
            if(!bBarcode){
                %> <img class="link" onclick="printPatientCard();"  border='0' src="<c:url value='/_img/icons/icon_barcode.gif'/>" alt="<%=getTranNoLink("web","printPatientCard",sWebLanguage)%>"/><%
            }
            if(!bPicture){
                %> <img class="link" onclick="storePicture();"  border='0' src="<c:url value='/_img/icons/icon_camera.png'/>" alt="<%=getTranNoLink("web","loadPicture",sWebLanguage)%>"/><%
            }
        }
        
        if(activePatient!=null && activePatient.personid!=null && activePatient.personid.length()>0 && MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("openpharmacy")){
            %><img class="link" onclick="showdrugsoutbarcode();"  border='0' src="<c:url value='/_img/icons/icon_pharma.png'/>" alt="<%=getTranNoLink("web","drugsoutbarcode",sWebLanguage)%>"/><%
        }
        %>
        
        <script>
          function mobilecheck(){
         	var check = false;
        	(function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
        	return check;
          }
       	
          function initBarcode2(){
        	if(mobilecheck()){
        	  window.open("zxing://scan/?ret=<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(), "") %>/main.do\?Page=curative/index.jsp%26PersonID={CODE}")
        	}
        	else{
        	  initBarcode();
        	}
          }
        
          function openImageHub(){
        	openPopup('xrays/ih_getstudies.jsp',600,400);
          }
        </script>
        
        <img class="link" onclick="initBarcode2();" border='0' src="<c:url value='/_img/icons/icon_barcode.gif'/>" title="<%=getTranNoLink("web","barcode",sWebLanguage)%>"/>
        <%
			if(activePatient!=null && activePatient.personid!=null && activePatient.personid.length()>0){
				if(MedwanQuery.getInstance().getConfigInt("enableImageHub",0)==1){
                    %><img class="link" onclick="openImageHub()" border='0' src="<c:url value='/_img/icons/icon_imagehub.png'/>" title="<%=getTranNoLink("web","imagehub",sWebLanguage)%>"/><%
				}
		        %><img class="link" onclick="clickMenuItem('<c:url value="/mobile/patientMenu.jsp"/>');" border='0' src="<c:url value='/_img/icons/icon_mobile.gif'/>" title="<%=getTranNoLink("web","mobile.interface",sWebLanguage)%>"/>&nbsp;<%
			}
			else{
                %><img class="link" onclick="clickMenuItem('<c:url value="/mobile/searchPatient.jsp"/>');" border='0' src="<c:url value='/_img/icons/icon_mobile.gif'/>" title="<%=getTranNoLink("web","mobile.interface",sWebLanguage)%>"/>&nbsp;<%
			}
        
        if(activeUser.getAccessRight("labos.patientlaboresults.select") && activePatient!=null && activePatient.personid.length()>0 && activePatient.hasLabRequests()){
            %><img class="link" onclick="clickMenuItem('javascript:searchLab();');" title="<%=getTranNoLink("Web","labresults",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_labo.png'/>"/><%
        }
        if(bMenu && activeUser.getAccessRight("labos.fastresults.select")){
            %><img class="link" onclick="clickMenuItem('javascript:showLabResultsEdit();');" title="<%=getTranNoLink("Web","fastresultsedit",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_labo_insert.png'/>"/><%
        }
        if(bMenu && activeUser.getAccessRight("patient.administration.select")){
            %><img class="link" onclick="clickMenuItem('javascript:showAdminPopup();');" style="padding:2px" title="<%=getTranNoLink("Web","Administration",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_admin.gif'/>"/><%
        }
    
        %><img class="link" onclick="clickMenuItem('javascript:searchMyHospitalized();');" alt="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>" title="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_bed.gif'/>"/><%
  
        if(1==1){ // activeUser.getAccessRight("manage.meals.select") /////////////////////////////////////////////////////////!!!!!!!!!!
            %>&nbsp;<img class="link" onclick="clickMenuItem('<c:url value="/main.do" />?Page=meals/index.jsp&ts='+new Date().getTime());" alt="<%=getTranNoLink("web","meals",sWebLanguage)%>" title="<%=getTranNoLink("web","meals",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_meals.png'/>"/><%
        }
        
        %>
            <img class="link" onclick="clickMenuItem('javascript:searchMyVisits();');" title="<%=getTranNoLink("Web","my_on_visit_patients",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_visits.png'/>"/>
            <img class="link" onclick="doPrint();" title="<%=getTranNoLink("Web","Print",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_print.gif'/>" />
            <img class="link" id="ddIconAgenda" onclick="clickMenuItem('<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&ts='+new Date().getTime());" title="<%=getTranNoLink("Web","Planning",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_calendar.gif'/>"/>
        <%
        
        String sHelp = MedwanQuery.getInstance().getConfigString("HelpFile");
        if(sHelp.length() > 0){
            %><img id="ddIconHelp" src="<c:url value='/_img/icons/icon_help.gif'/>" height="16" width="16" border="0" alt="Help" onclick="showmanual();" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'><%
        }
        
        %><img class="link" id="ddIconFingerprint" onclick="readFingerprint();" title="<%=getTranNoLink("Web","Read_fingerprint",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_fingerprint.gif'/>"/><%
    }
%>

<img class="link" id="ddIconLogoff" onclick="clickMenuItem('javascript:confirmLogout();');" title="<%=getTranNoLink("Web","LogOff",sWebLanguage)%>" src="<c:url value='/_img/icons/icon_logout.png'/>"/>
&nbsp;   