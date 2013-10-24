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

    //--- GET LINK FROM MENU XML ------------------------------------------------------------------
    private String getLinkFromMenuXML(HttpSession session , String sLongLabelId) throws Exception {
        Element menuElem = getMenuElement(session,sLongLabelId);        
        return menuElem.attributeValue("url");
    }
%>

<%
    String sUserId         = checkString(request.getParameter("UserId")),
           sPrevShortcutId = checkString(request.getParameter("PrevShortcutId")),
           sShortcutId     = checkString(request.getParameter("ShortcutId"));

    String sIconName = checkString(request.getParameter("IconName")),
  		   sIconText = checkString(request.getParameter("IconText"));

    // get onClick from menu.xml
    String sIconOnClick = getLinkFromMenuXML(session,sShortcutId);
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* userprofile/ajax/saveShortcut.jsp ********");
        Debug.println("sUserId          : "+sUserId);
        Debug.println("sShortcutId      : "+sShortcutId);
        Debug.println("sPrevShortcutId  : "+sPrevShortcutId);
        Debug.println("sIconName        : "+sIconName);
        Debug.println("sIconText        : "+sIconText);
        Debug.println("--> sIconOnClick : "+sIconOnClick+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    net.admin.Parameter parameter = new net.admin.Parameter();
    parameter.parameter = "usershortcut$"+sShortcutId;
    parameter.value = sIconName+"$"+sIconOnClick+"$"+sIconText;

    // store in DB and update activeUser    
    activeUser.updateParameter("usershortcut$"+sPrevShortcutId,parameter);
    activeUser = User.get(Integer.parseInt(activeUser.userid)); // reload
    session.setAttribute("activeUser",activeUser);
    
    // compose message
    String sMsg = "<font color='green'>"+getTranNoLink("web","dataSaved",sWebLanguage)+"</font>";
%>

{
  "msg":"<%=HTMLEntities.htmlentities(sMsg)%>"
}