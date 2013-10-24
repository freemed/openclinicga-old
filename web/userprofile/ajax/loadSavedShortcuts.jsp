<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.io.*"%>

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
	String sUserId = checkString(request.getParameter("UserId"));	       
	
	/// DEBUG //////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******** userprofile/ajax/loadSavedShortcuts.jsp ********");
		Debug.println("sUserId : "+sUserId+"\n");
	}
	////////////////////////////////////////////////////////////////////////////////

    Vector userParameters = activeUser.getUserParametersByType(activeUser.userid,"usershortcut$");

    Element menuElem;
    String sLongLabelId, sIconName, sIconOnClick, sIconText = "", sLabelType, sShortcutTitle;
     
    if(userParameters.size() > 0){
        UserParameter userParameter;
     
        Debug.println("\n***** userShortcuts (userid:"+activeUser.userid+") : "+userParameters.size()+" *****");
        for(int i=0; i<userParameters.size(); i++){
            userParameter = (UserParameter)userParameters.get(i);
            Debug.println("\n["+i+"] userShortcut : "+userParameter.getParameter());
             
            sLongLabelId = userParameter.getParameter().substring("usershortcut$".length());
     
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
     
            //*** fetch extra data from xml (accessrights and such) ***
            boolean okToDisplayIcon = false;
            menuElem = getMenuElement(session,sLongLabelId);
     
            if(menuElem!=null){
                // look for required permissions
                Debug.println("accessrights : "+checkString(menuElem.attributeValue("accessrights")));
                if(activeUser.getAccessRight(checkString(menuElem.attributeValue("accessrights"))) || 
                   checkString(menuElem.attributeValue("accessrights")).length()==0){
                    okToDisplayIcon = true;
                }
                                  
                %><script>appendSelectedShortcuts("<%=sLongLabelId%>");</script><%
            }
            else{
                Debug.println("menuElem '"+sLongLabelId+"' not found in menu.xml");
            }
     
            Debug.println("--> okToDisplayIcon : "+okToDisplayIcon);
            if(okToDisplayIcon){
            	// labelType ?
                sLabelType = "web"; // default
                if(menuElem.attributeValue("labeltype")!=null){
                    sLabelType = (String)menuElem.attributeValue("labeltype");
                }
                 
                sShortcutTitle = getTranNoLink(sLabelType,menuElem.attributeValue("labelid"),sWebLanguage);

                // isolate the subtype (docType) from the 'parameter' and add it to the translation
                if(userParameter.getParameter().indexOf("$") > -1){
                    String[] iconTypeParts = userParameter.getParameter().split("\\$");
                    if(iconTypeParts.length==3){
                	    //sShortcutTitle+= " - "+getTranNoLink("web.occup",iconTypeParts[2],sWebLanguage);
                	    sShortcutTitle = getTranNoLink("web.occup",iconTypeParts[2],sWebLanguage);
                    }
                }
                
                %><img class="link" src="<%=sCONTEXTPATH%>/_img/shortcutIcons/<%=sIconName%>" onClick="editShortcut(this,'<%=sLongLabelId%>');" style="border:2px solid white;vertical-align:-4px;" link="<%=menuElem.attributeValue("url")%>" title="<%=sIconText%>"/>&nbsp;<%=sShortcutTitle%><br><%
            }
        }
    }
    else{
        %><%=getTran("web.userProfile","noShortcutsDefined",sWebLanguage)%><%
    }
%>
