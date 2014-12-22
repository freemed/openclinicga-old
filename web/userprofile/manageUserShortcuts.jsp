<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>
<%@page import="java.io.*"%>
<%@page import="be.openclinic.common.IconsFilter"%>

<%=checkPermission("userprofile.manageUserShortcuts","all",activeUser)%>

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
    String sAction = checkString(request.getParameter("Action"));

    String sShortcutType     = checkString(request.getParameter("ShortcutType")),
           sShortcutSubtype  = checkString(request.getParameter("ShortcutSubtype")),
           sShortcutIcon     = checkString(request.getParameter("ShortcutIcon")),
           sShortcutIconText = checkString(request.getParameter("ShortcutIconText"));

    String sIconsDir = MedwanQuery.getInstance().getConfigString("localProjectPath")+"/_img/shortcutIcons";
    
    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** userprofile/manageUserShortcuts.jsp **********");
        Debug.println("sAction           : "+sAction);
        Debug.println("sShortcutType     : "+sShortcutType);
        Debug.println("sShortcutSubtype  : "+sShortcutSubtype);
        Debug.println("sShortcutIcon     : "+sShortcutIcon);
        Debug.println("sShortcutIconText : "+sShortcutIconText);
        Debug.println("sIconsDir         : "+sIconsDir+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////
          
    String sMsg = "";
%>
    
<%=writeTableHeader("web.userProfile","manageUserShortcuts",sWebLanguage," doBack();")%>
<input type="hidden" id="EditMode" value="">

<%-- ############################ USER DEFINED ICONS ########################### --%>
<table width="100%" cellspacing="1" cellpadding="0" class="list">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.userProfile","savedShortcuts",sWebLanguage)%></td>
        <td class="admin2" id="savedShortcutsTD">
            <%-- ajax --%>
        </td>
    </tr>
</table>    
&nbsp;<%=getTran("web.userProfile","clickAnIconToEditIt",sWebLanguage)%>
<br><br>

<%-- ################################ ADD/EDIT ROW ############################# --%>
<table width="100%" cellspacing="1" cellpadding="0" class="list">
    <%-- SHORTCUT TYPE ----------------------------------%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","type",sWebLanguage)%>&nbsp;*&nbsp;</td>
        <td class="admin2">
            <select name="ShortcutType" id="ShortcutType" class="text" onchange="getSubtypes(this);">
                <option value="-1"><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                <%
                    /*
                        <Menu labelid="applications">
                            <Menu labelid="prescriptions" accessrights="prescription.select" patientselected="false">
                                <Menu labelid="medications" accessrights="prescriptions.drugs.select" patientselected="true" url="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');"/>
                                ...
                            </Menu>
                        </Menu> 
                    */
                    
                    Vector shortcuts = new Vector(); // paths to menu in menu.xml
                    shortcuts.add("applications.prescriptions.medications");       // voorschrift geneesmiddelen
                    shortcuts.add("applications.prescriptions.careprescriptions"); // voorschrift zorgen
                    shortcuts.add("applications.financial.patientCreditEdit");     // facturen raadplegen
                    shortcuts.add("applications.financial.patientInvoiceEdit");    // prestaties invoeren
                    shortcuts.add("hidden.actualrfe");                             // reason for encounter (RFE)
                    shortcuts.add("hidden.clinicalDocuments");                     // subtype : type of documents
                          
                    String sLongLabelId, sLabelType, sShortcutTitle;
                    Element menuElem;
                    for(int i=0; i<shortcuts.size(); i++){
                        sLongLabelId = (String)shortcuts.get(i);
                        menuElem = getMenuElement(session,sLongLabelId);

                        // check permissions
                        if((checkString(menuElem.attributeValue("accessrights")).length() > 0 && activeUser.getAccessRight(menuElem.attributeValue("accessrights"))) ||
                           checkString(menuElem.attributeValue("accessrights")).length()==0){
	                        // labelType ?
		                    sLabelType = "web"; // default
		                    if(menuElem.attributeValue("labeltype")!=null){
		                        sLabelType = (String)menuElem.attributeValue("labeltype");
		                    }		                    
		                        
		                    sShortcutTitle = getTranNoLink(sLabelType,menuElem.attributeValue("labelid"),sWebLanguage);
		                      
		                    %><option value="<%=sLongLabelId%>"><%=sShortcutTitle%></option><%
                    	}	                        		
                    }
                %>
            </select>
        </td>
    </tr>
        
    <%-- SHORTCUT SUB-TYPE (hidden) --%>
    <tr id="shortcutSubtypeTR" style="display: none">
        <td class="admin"><%=getTran("web","subtype",sWebLanguage)%>&nbsp;*&nbsp;</td>
        <td class="admin2" id="shortcutSubtypeTD">
            <%-- ajax --%>
        </td>
    </tr>

    <%-- SHORTCUT ICON --%>
    <tr>
        <td class="admin"><%=getTran("web","icon",sWebLanguage)%>&nbsp;*&nbsp;</td>
        <td class="admin2">
            <input type="hidden" id="ShortcutIcon" name="ShortcutIcon" value="">
            
            <div id="iconsDiv">
                <%                        
                    File iconsDir = new File(sIconsDir); // c:/projects/openclinic/web
                    if(iconsDir.exists() && iconsDir.isDirectory()){ 
                        FileFilter iconsFilter = new IconsFilter();
                        File[] icons = iconsDir.listFiles(iconsFilter);
                        Debug.println("Found "+icons.length+" icons");
                        
                        File icon;
                        for(int i=0; i<icons.length; i++){
                            icon = (File)icons[i];
                                                            
                            if(i%15==0){
                                %><br><%
                            }
                            
                            %><img class="link" id="icon_<%=i%>" src="<%=sCONTEXTPATH%>/_img/shortcutIcons/<%=icon.getName()%>" onClick="selectIcon(this);" style="border:2px solid white;width:20px;height:20px;" name="<%=icon.getName()%>" title="<%=icon.getName()%>"/>&nbsp;&nbsp;<%
                        }
                    }
                    else{
                        %><font color="red"><%=(getTran("web.userprofile","directoryNotFound",sWebLanguage)+" : '"+sIconsDir+"' (--> localProjectPath)")%></font><%
                    }
                %>
            </div>
        </td>
    </tr>
    
    <%-- SHORTCUT ICON TEXT --%>
    <tr>
        <td class="admin"><%=getTran("web","iconText",sWebLanguage)%>&nbsp;*&nbsp;</td>
        <td class="admin2">
            <input type="text" name="ShortcutIconText" id="ShortcutIconText" value="<%=sShortcutIconText%>" size="40" maxLength="50">
        </td>
    </tr>
                
    <%-- BUTTONS --%>
    <tr>     
        <td class="admin"/>
        <td class="admin2" colspan="2">
            <input type="button" class="button" name="saveButton" id="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" style="visibility:visible" onclick="saveShortcut();">
            <input type="button" class="button" name="deleteButton" id="deleteButton" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" style="visibility:hidden;" onclick="deleteShortcut();"/>
            <input type="button" class="button" name="newButton" id="newButton" value="<%=getTranNoLink("web","new",sWebLanguage)%>" style="visibility:hidden;" onclick="newShortcut();"/>
            <input type="button" class="button" name="backButton" id="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" style="visibility:visible;" OnClick="doBack();">
        </td>
    </tr>
</table>    
&nbsp;<%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%>

<%-- display message --%>
<br><br><span id="msgDiv">&nbsp;<%=sMsg%></span>

<script>
  document.getElementById("msgDiv").innerHTML = "<%=getTran("web","maxIcons",sWebLanguage)%>:&nbsp;<%=MedwanQuery.getInstance().getConfigString("maxUserDefinedShortcuts","5")%>";

  var selectedShortcuts = new Array();
  var clickedIcon, editedIcon, prevFullShortcutType = "";
  var numberOfSavedShortcuts = 0;
  
  loadSavedShortcuts();
  
  <%-- APPEND SELECTED SHORTCUTS --%>
  function appendSelectedShortcuts(shortcutType){
    selectedShortcuts.push(shortcutType);
  }
  
  <%-- LOAD SAVED SHORTCUTS --%>
  function loadSavedShortcuts(){
	document.getElementById("savedShortcutsTD").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";     
    var url = "<c:url value='/userprofile/ajax/loadSavedShortcuts.jsp'/>?ts="+new Date().getTime();
    var params = "UserId=<%=activeUser.userid%>";
    
    new Ajax.Updater("savedShortcutsTD",url,{ 
      method: "GET",
      evalScripts: true,
      parameters: params,
      onComplete: function(resp){
        numberOfSavedShortcuts = document.getElementById("savedShortcutsTD").getElementsByTagName("img").length;
      },
      onFailure: function(resp){
        $("msgDiv").innerHTML = "Error in 'userprofile/ajax/loadSavedShortcuts.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- SELECT ICON --%>
  function selectIcon(icon){
	clickedIcon = icon;
	
    <%-- deselect all icons --%>
    var icons = document.getElementById("iconsDiv").getElementsByTagName("img");
    for(var i=0; i<icons.length; i++){
      icons[i].style.border = "2px solid white";
    }
    
    <%-- clear previous selected icon --%>
    document.getElementById("ShortcutIcon").value = "";
    if(clickedIcon!=null){
      <%-- visually mark selected icon --%>
      if(clickedIcon.style.border=="2px solid white"){
        clickedIcon.style.border = "2px solid darkblue";
      }
      else{
        clickedIcon.style.border = "2px solid white";
      }
    
      <%-- keep track of id of selected icon --%>
      document.getElementById("ShortcutIcon").value = clickedIcon.name;
      var typeSelect = document.getElementById("ShortcutType");
      if(typeSelect.selectedIndex > 0){
        document.getElementById("ShortcutIconText").value = typeSelect.options[typeSelect.selectedIndex].text;
      }
      
      var subTypeSelect = document.getElementById("ShortcutSubtype");
      if(subTypeSelect!=null){
        if(subTypeSelect.selectedIndex > 0){
          document.getElementById("ShortcutIconText").value = subTypeSelect.options[subTypeSelect.selectedIndex].text;
        }
      }
    }
  }
  
  <%-- GET shortcut SUBTYPES --%>
  var tmpSubtype;
  
  function getSubtypes(select,subtypeToSelect){
	tmpSubtype = subtypeToSelect;
	
    if(select.selectedIndex > 0){
      var url = "<c:url value='/userprofile/ajax/getShortcutSubtypes.jsp'/>?ts="+new Date().getTime();
      var params = "ShortcutType="+select.options[select.selectedIndex].value;

      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){
          var html = trim(resp.responseText);
          
          if(html.length > 0){
            document.getElementById("shortcutSubtypeTR").style.display = "";
          }
          else{
            document.getElementById("shortcutSubtypeTR").style.display = "none";
          }
          
          document.getElementById("shortcutSubtypeTD").innerHTML = resp.responseText;

          <%-- select the right subtype --%>
          if(tmpSubtype.length > 0){
        	var subTypes = document.getElementById("ShortcutSubtype").options;
        	for(var i=0; i<subTypes.length; i++){
              if(subTypes[i].value==tmpSubtype){
                document.getElementById("ShortcutSubtype").selectedIndex = i;
            	tmpSubtype = "";
                break;
              }
        	}
          }

          <%-- prevFullShortcutType --%>
          prevFullShortcutType = getFullShortcutType();
        }
      });
    }
  }

  <%-- SAVE SHORTCUT --%>  
  function saveShortcut(){
    var okToSave = true;
    var fullShortcutType;
    var maxNumberOfShortcuts = "<%=MedwanQuery.getInstance().getConfigString("maxUserDefinedShortcuts","5")%>";
    if((numberOfSavedShortcuts < maxNumberOfShortcuts) || document.getElementById("EditMode").value=="true"){
      <%-- type --%>
      if(okToSave){
        if(document.getElementById("ShortcutType").selectedIndex < 1){
          document.getElementById("ShortcutType").focus();
          window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
          okToSave = false;
        }
      }  

      <%-- subtype --%>
      if(okToSave){
        if(document.getElementById("shortcutSubtypeTR").style.display==""){
          if(document.getElementById("ShortcutSubtype").selectedIndex < 1){
            document.getElementById("ShortcutSubtype").focus();
            window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
            okToSave = false;
          }
        }
      }

      <%-- type already selected ? --%>
      if(okToSave){
        if(document.getElementById("ShortcutType").selectedIndex > 0){
          var shortcutType = document.getElementById("ShortcutType").options[document.getElementById("ShortcutType").selectedIndex].value;
          fullShortcutType = getFullShortcutType();
        
          if(document.getElementById("EditMode").value!="true"){ 
            for(var i=0; i<selectedShortcuts.length; i++){
              if(selectedShortcuts[i]==fullShortcutType){
                if(shortcutType!="hidden.clinicalDocuments"){
                  document.getElementById("ShortcutType").focus();
                  alertDialog("web.userProfile","shortcutTypeAlreadySelected");
                }
                else{
                  document.getElementById("ShortcutSubtype").focus();
                  alertDialog("web.userProfile","shortcutSubtypeAlreadySelected");
                }
            
                okToSave = false;
                break;
              }
            }
          }
        }
      }
    
      <%-- icon --%>
      if(okToSave){
        if(document.getElementById("ShortcutIcon").value.length==0){
          alertDialog("web.userprofile","chooseAnIcon");
          okToSave = false;
        }
      }
    
      <%-- description --%>
      if(okToSave){
        if(document.getElementById("ShortcutIconText").value.length==0){
          document.getElementById("ShortcutIconText").focus();
                    window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
          okToSave = false;
        }
      }
    
      if(okToSave){
        disableButtons();

        if(prevFullShortcutType.length==0){
          prevFullShortcutType = fullShortcutType;
        }
	    var url = "<c:url value='/userprofile/ajax/saveShortcut.jsp'/>?ts="+new Date().getTime();
        var params = "UserId=<%=activeUser.userid%>"+
				     "&PrevShortcutId="+prevFullShortcutType+
				     "&ShortcutId="+fullShortcutType+
                     "&IconName="+document.getElementById("ShortcutIcon").value+
                     "&IconText="+document.getElementById("ShortcutIconText").value;
        new Ajax.Request(url,{
          parameters: params,
          onComplete: function(resp){ 
            var data = eval("("+resp.responseText+")");
     	    document.getElementById("msgDiv").innerHTML = data.msg;
    	    loadSavedShortcuts();
    	    clearEditFields();
    	    enableButtons();
          }
        });
      }
    }
    else{
      alertDialog("web.userProfile","maxNumberOfUserDefinedShortcutsReached");
    }
  }
  
  <%-- GET FULL  SHORTCUT TYPE --%>
  function getFullShortcutType(){
    var type = document.getElementById("ShortcutType").options[document.getElementById("ShortcutType").selectedIndex].value;
    var fullType = type;
  
    <%-- add subtype, if any (only for documents) --%>
    if(document.getElementById("shortcutSubtypeTR").style.display==""){       
      if(document.getElementById("ShortcutSubtype").selectedIndex > 0){
        var subtype = document.getElementById("ShortcutSubtype").options[document.getElementById("ShortcutSubtype").selectedIndex].value;
        fullType+= "$"+subtype;
      }
    }  	
    
    return fullType;
  }
  
  <%-- EDIT SHORTCUT --%>
  function editShortcut(icon,shortcutId){
    editedIcon = icon;    
    
    <%-- deselect all saved shortcut icons --%>
    var icons = document.getElementById("savedShortcutsTD").getElementsByTagName("img");
    for(var i=0; i<icons.length; i++){
      icons[i].style.border = "2px solid white";
    }
        
    <%-- visually mark edited shortcut icon --%>
    if(editedIcon.style.border=="white 2px solid"){
      editedIcon.style.border = "2px solid darkblue";
    }
    else{
      editedIcon.style.border = "2px solid white";
    }
        
	document.getElementById("EditMode").value = "true";
	disableButtons();
	    
	var url = "<c:url value='/userprofile/ajax/getShortcut.jsp'/>?ts="+new Date().getTime();
    var params = "UserId=<%=activeUser.userid%>"+
                 "&ShortcutId="+shortcutId;

    new Ajax.Request(url,{
      parameters: params,
      onComplete: function(resp){
        document.getElementById("deleteButton").style.visibility = "visible";
        document.getElementById("newButton").style.visibility = "visible";
        enableButtons();
        
        var data = eval("("+resp.responseText+")");

        if(data.msg=="dataFound"){
          document.getElementById("ShortcutType").value = data.shortcutType;
          getSubtypes(document.getElementById("ShortcutType"),data.shortcutSubtype);
         
          <%-- select the right icon --%>
          var icons = document.getElementById("iconsDiv").getElementsByTagName("img");
          for(var i=0; i<icons.length; i++){
            if(icons[i].name==data.iconName){
              selectIcon(icons[i]);
              break;
            }
          }

          document.getElementById("ShortcutIconText").value = data.iconText;
        }
      }
    });
  }
  
  <%-- DELETE SHORTCUT --%>
  function deleteShortcut(){
      if(yesnoDeleteDialog()){
      disableButtons();
     
      var select = document.getElementById("ShortcutType");
      var url = "<c:url value='/userprofile/ajax/deleteShortcut.jsp'/>?ts="+new Date().getTime();
      var params = "UserId=<%=activeUser.userid%>"+
                   "&ShortcutId="+getFullShortcutType();

      new Ajax.Request(url,{
        parameters: params,
        onComplete: function(resp){
          var data = eval("("+resp.responseText+")");
          document.getElementById("msgDiv").innerHTML = data.msg;
  	      loadSavedShortcuts();
  	      clearEditFields();
  	      enableButtons();
        }
      });
    }
  }
  
  <%-- NEW SHORTCUT --%>
  function newShortcut(){
    clearEditFields();  
  }
  
  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    if(document.getElementById("saveButton")!=undefined){
      document.getElementById("saveButton").disabled = true;
    }
    if(document.getElementById("deleteButton")!=undefined && document.getElementById("deleteButton").style.visibility=="visible"){
      document.getElementById("deleteButton").disabled = true;
    }
    if(document.getElementById("newButton")!=undefined && document.getElementById("newButton").style.visibility=="visible"){
      document.getElementById("newButton").disabled = true;
    }
    if(document.getElementById("backButton")!=undefined){
      document.getElementById("backButton").disabled = true;
    }
  }
  
  <%-- ENABLE BUTTONS --%>
  function enableButtons(){
    if(document.getElementById("saveButton")!=undefined){
      document.getElementById("saveButton").disabled = false;
    }
    if(document.getElementById("deleteButton")!=undefined && document.getElementById("deleteButton").style.visibility=="visible"){
      document.getElementById("deleteButton").disabled = false;
    }
    if(document.getElementById("newButton")!=undefined && document.getElementById("newButton").style.visibility=="visible"){
      document.getElementById("newButton").disabled = false;
    }
    if(document.getElementById("backButton")!=undefined){
      document.getElementById("backButton").disabled = false;
    }
  }
  
  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    document.getElementById("deleteButton").style.visibility = "hidden";
    prevFullShortcutType = "";
    fullShortcutType = "";
    
    clickedIcon = null;
    editedIcon = null;
    
    document.getElementById("EditMode").value = "";    
    document.getElementById("ShortcutType").selectedIndex = 0;
    if(document.getElementById("ShortcutSubtype")!=null){
      document.getElementById("ShortcutSubtype").selectedIndex = 0;
    }
    document.getElementById("shortcutSubtypeTR").style.display = "none";
    document.getElementById("ShortcutIconText").value = "";

    if(document.getElementById("deleteButton")!=undefined){
      document.getElementById("deleteButton").style.visibility = "hidden";
    }
    selectIcon();   
     
    <%-- deselect all saved shortcut icons --%>
    var icons = document.getElementById("savedShortcutsTD").getElementsByTagName("img");
    for(var i=0; i<icons.length; i++){
      icons[i].style.border = "2px solid white";
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>