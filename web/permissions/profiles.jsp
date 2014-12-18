<%@page import="org.dom4j.DocumentException,java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- WRITE PERMISSION ------------------------------------------------------------------------
    public String writePermission(String sLabel, String sScreenID, String sUserProfileID, int idx, int categoryIdx){
        String sSelect = "", sAdd = "", sEdit = "", sDelete = "", sPermission;

	    if(sUserProfileID.trim().length() > 0){
	        Vector vPermissions = UserProfilePermission.getActiveUserProfilePermissions(sUserProfileID,sScreenID.toLowerCase());
	        Iterator iter = vPermissions.iterator();
	        while(iter.hasNext()){
	            sPermission = (String)iter.next();
	                 if(sPermission.equalsIgnoreCase("select")) sSelect = "checked";
	            else if(sPermission.equalsIgnoreCase("add")) sAdd = "checked";
	            else if(sPermission.equalsIgnoreCase("edit")) sEdit = "checked";
	            else if(sPermission.equalsIgnoreCase("delete")) sDelete = "checked";
	        }
	    }
	    
	    return "<tr "+(idx%2==0?"class='list'":"")+">"+
	            "<td></td>"+
	            "<td width='25%'><b>"+sLabel+"</b></td>"+
	            "<td width='25%'>"+sScreenID+"</td>"+
	            "<td><img src='"+sCONTEXTPATH+"/_img/themes/default/uncheck.gif' name='cat"+categoryIdx+"$"+sScreenID+"' class='link' onclick='checkRow(\""+categoryIdx+"\",\""+sScreenID+"\");'></td>"+
	    	    "<td><img src='"+sCONTEXTPATH+"/_img/themes/default/"+(sSelect.equals("checked")?"check.gif":"uncheck.gif")+"' name='cat"+categoryIdx+"$"+sScreenID+".Select' class='link' onclick='uncheckRowSelector(\""+categoryIdx+"\",\""+sScreenID+"\");applyPolicy1(this,"+categoryIdx+",\""+sScreenID+"\");'></td>"+
	    	    "<td><img src='"+sCONTEXTPATH+"/_img/themes/default/"+(sAdd.equals("checked")?"check.gif":"uncheck.gif")+"' name='cat"+categoryIdx+"$"+sScreenID+".Add' class='link' onclick='uncheckRowSelector(\""+categoryIdx+"\",\""+sScreenID+"\");applyPolicy2(this,"+categoryIdx+",\""+sScreenID+"\");'></td>"+
	    	    "<td><img src='"+sCONTEXTPATH+"/_img/themes/default/"+(sEdit.equals("checked")?"check.gif":"uncheck.gif")+"' name='cat"+categoryIdx+"$"+sScreenID+".Edit' class='link' onclick='uncheckRowSelector(\""+categoryIdx+"\",\""+sScreenID+"\");applyPolicy2(this,"+categoryIdx+",\""+sScreenID+"\");'></td>"+
	    	    "<td colspan='2'><img src='"+sCONTEXTPATH+"/_img/themes/default/"+(sDelete.equals("checked")?"check.gif":"uncheck.gif")+"' name='cat"+categoryIdx+"$"+sScreenID+".Delete' class='link' onclick='uncheckRowSelector(\""+categoryIdx+"\",\""+sScreenID+"\");applyPolicy2(this,"+categoryIdx+",\""+sScreenID+"\");'></td>"+
	           "</tr>";
	}

    //--- WRITE HEADER ----------------------------------------------------------------------------
    public String writeHeader(String sHeader, int headerIdx, boolean displaySection,String sWebLanguage){
        return (headerIdx==0?"":"<br>")+
                "<input type='hidden' name='cat"+headerIdx+"_selected' value='1'>"+
                "<table width='100%' cellspacing='0' class='list'>"+
                 "<tr class='admin'>"+
                  "<td width='2%'>"+
                   "<a href='#'><img id='Input_"+headerIdx+"_S' name='Input_"+headerIdx+"_S' border='0' src='"+sCONTEXTPATH+"/_img/icons/icon_plus.png' OnClick='showD(\"Input_"+headerIdx+"\",\"Input_"+headerIdx+"_S\",\"Input_"+headerIdx+"_H\")' style='display:none'></a>"+
                   "<a href='#'><img id='Input_"+headerIdx+"_H' name='Input_"+headerIdx+"_H' border='0' src='"+sCONTEXTPATH+"/_img/icons/icon_minus.png' OnClick='hideD(\"Input_"+headerIdx+"\",\"Input_"+headerIdx+"_S\", \"Input_"+headerIdx+"_H\")'></a>"+
                  "</td>"+
                  "<td>"+sHeader+"</td>"+
                  "<td>Permission</td>"+
                "<td width='8%'>&nbsp;<a href='javascript:selectPermissions("+headerIdx+");'>"+getTran("web","all",sWebLanguage)+"</a></td>"+
                "<td width='8%'>&nbsp;"+getTran("web","view",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","add",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","edit",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","delete",sWebLanguage)+"</td>"+
                "<td align='right'><a href=\"#topp\" class=\"topbutton\">&nbsp;</a></td>"+
               "</tr>"+
               "<tbody id='Input_"+headerIdx+"' name='Input_"+headerIdx+"'>";
    }
    
    //--- WRITE FOOTER ----------------------------------------------------------------------------
    public String writeFooter(){
        return " </tbody>"+
               "</table>";
    }
    
    //--- DISPLAY PERMISSIONS ---------------------------------------------------------------------
    private String displayPermissions(String categoryName, Hashtable permissions, String sUserProfileID,
                                      int categoryIdx, boolean sortPermissions, boolean displaySection, 
                                      String sWebLanguage){
        // sort permissions on translation
        Vector labels = new Vector(permissions.keySet());
        if(sortPermissions) Collections.sort(labels);
        StringBuffer out = new StringBuffer();
        out.append(writeHeader(categoryName,categoryIdx,displaySection,sWebLanguage));
        int counter = 0;
        String label, permissionName;
        for(int i=0; i<labels.size(); i++){
            label = (String)labels.get(i);
            permissionName = (String)permissions.get(label);
            out.append(writePermission(label,permissionName,sUserProfileID,counter++,categoryIdx));
        }
        out.append(writeFooter());
        if(!displaySection){
            out.append("<script>toggleSection('").append(categoryIdx).append("');</script>");
        }
        return out.toString();
    }
%>

<%  
    String sProfiles = "", sTmpProfileID, sTmpProfileName, sUserProfileName = "",
           sUserProfileID = "", sDefaultPage = "";
    String sSearchProfileID = checkString(request.getParameter("SearchUserprofile"));
    Debug.println("sSearchProfileID : "+sSearchProfileID); 

    String sAction = checkString(request.getParameter("Action"));
    Debug.println("sAction : "+sAction); 
    
    //*** SAVE ************************************************************************************
    if(sAction.equals("save")){
        sUserProfileID = checkString(request.getParameter("UserProfileID"));
        sUserProfileName = checkString(request.getParameter("UserProfileName"));
        UserProfile userProfile;
        UserProfilePermission userProfilePermission;
        
		if(sUserProfileName.length() > 0){
	        //*** INSERT PROFILE ***
	        if(sUserProfileID.length()==0){
	        	//First find out if the user profile name does not exist yet
				userProfile = UserProfile.getUserProfileByName(sUserProfileName);
				if(userProfile!=null){
					sUserProfileID=userProfile.getUserprofileid()+"";
					userProfile.setUpdatetime(getSQLTime());
		            userProfile.update();
	
		            // remove all permissions in profile (except 'sa');
		            // they will be added again later
		            userProfile.removePermissions();
				}
				else {
		        	sUserProfileID = MedwanQuery.getInstance().getNewResultCounterValue("UserProfileID");
		            userProfile = new UserProfile();
		            userProfile.setUserprofileid(Integer.parseInt(sUserProfileID));
		            userProfile.setUserprofilename(sUserProfileName);
		            userProfile.setUpdatetime(getSQLTime());
		            userProfile.insert();
				}
	        }
	        //*** UPDATE PROFILE ***
	        else{
	            userProfile = new UserProfile();
	            userProfile.setUserprofileid(Integer.parseInt(sUserProfileID));
	            userProfile.setUserprofilename(sUserProfileName);
	            userProfile.setUpdatetime(getSQLTime());
	            userProfile.update();
	
	            // remove all permissions in profile (except 'sa');
	            // they will be added again later
	            userProfile.removePermissions();
	        }
	        
	        sSearchProfileID = sUserProfileID;

	        //*** REGISTER PERMISSIONS ***
	        String sTmpName, sTmpValue, sTmpScreenID, sTmpPermission;
	        String sCheckedPermissions = checkString(request.getParameter("checkedPermissions"));
	        String[] checkedPermissions = sCheckedPermissions.split(";");
	        Debug.println("checkedPermissions : "+checkedPermissions.length);
	        
	        for(int i=0; i<checkedPermissions.length; i++){
	            if(checkedPermissions[i].toLowerCase().endsWith(".select") ||
	 	           checkedPermissions[i].toLowerCase().endsWith(".add") ||
	 	           checkedPermissions[i].toLowerCase().endsWith(".edit") ||
	 	           checkedPermissions[i].toLowerCase().endsWith(".delete")){	        	
		        	sTmpScreenID = checkedPermissions[i].split("\\$")[1];
		        	sTmpScreenID = sTmpScreenID.substring(0,sTmpScreenID.lastIndexOf(".")).toLowerCase();
		        	sTmpPermission = checkedPermissions[i].substring(checkedPermissions[i].lastIndexOf(".")+1).toLowerCase();
		        		            	        	            
		            userProfilePermission = new UserProfilePermission();
		            userProfilePermission.setUserprofileid(Integer.parseInt(sUserProfileID));
		            userProfilePermission.setScreenid(sTmpScreenID);
		            userProfilePermission.setPermission(sTmpPermission);
		            int updatedRows = userProfilePermission.setActiveProfilePermission();
	
		            // insert if not found
		            if(updatedRows==0){
		                userProfilePermission.setUpdatetime(getSQLTime());
		                userProfilePermission.insert();
		            }
	            }
	        }
	        		
            // default page
            String sDefaultpage = checkString(request.getParameter("defaultpage"));
            if(sDefaultpage.length() > 0){
                userProfilePermission = new UserProfilePermission();
                userProfilePermission.setUserprofileid(Integer.parseInt(sUserProfileID));
                userProfilePermission.setScreenid("defaultpage");
                userProfilePermission.deleteByScreenAndId();
                userProfilePermission.setPermission(sDefaultpage.toLowerCase());
                userProfilePermission.setUpdatetime(getSQLTime());
                userProfilePermission.insert();
            }
	         
	        // reload permissions in user-object
	        activeUser.initialize(Integer.parseInt(activeUser.userid));
	        session.setAttribute("activeUser",activeUser);
		}
    }
    //*** DELETE PROFILE **************************************************************************
    else{
        if(request.getParameter("DeletePermissionID")!=null){
            if(UserProfile.removeUserPermissionByPermissionId(request.getParameter("DeletePermissionID"))==1){
                out.print("<script>document.location.href = \""+sCONTEXTPATH+"/main.do?Page=permissions/profiles.jsp&ts="+getTs()+"\";</script>");
            }
            else{
                out.print("<script>alertDialog('Web.UserProfile','cantDelete');</script>");
            }
        }
    }

    // populate select
    Vector vProfiles = UserProfile.getUserProfiles();
    Iterator iter = vProfiles.iterator();
    UserProfile userProfile;
    while(iter.hasNext()){
        userProfile = (UserProfile)iter.next();
        
        sTmpProfileID = Integer.toString(userProfile.getUserprofileid());
        sTmpProfileName = userProfile.getUserprofilename();
        sProfiles+= "<option value='"+sTmpProfileID+"'";
        if((sSearchProfileID.equals(sTmpProfileID)) && (request.getParameter("NewUserProfile")==null)){
            sProfiles+= " selected";
            sUserProfileID = sTmpProfileID;
            sUserProfileName = sTmpProfileName;
        }
        sProfiles+= ">"+sTmpProfileName+"</option>";
    }

    // Defaultpage
    if(sUserProfileID.trim().length() > 0){
        Vector vUserProfilePermission = UserProfilePermission.getActiveUserProfilePermissions(sUserProfileID,"defaultpage");
        Iterator iterator = vUserProfilePermission.iterator();
        String sPermission;
        if(iterator.hasNext()){
            sPermission = (String)iterator.next();
            sDefaultPage = sPermission;
        }
    }
%>
<script>
  <%-- TOGGLE SECION --%>
  function toggleSection(sectionIdx){
    if($("cat"+sectionIdx+"_selected")){
      var sectionDisplayed = (document.getElementById("cat"+sectionIdx+"_selected").value=="1");
      if(sectionDisplayed){
        hideD(eval("'Input_"+sectionIdx+"'"),eval("'Input_"+sectionIdx+"_S'"),eval("'Input_"+sectionIdx+"_H'"));
      }
      else{
        showD("'Input_"+sectionIdx+"','Input_"+sectionIdx+"_S','Input_"+sectionIdx+"_H'");
      }
    }
  }
</script>

<a name="topp"></a>

<form name="profileForm" id="profileForm" method="post">
    <input type="hidden" name="checkedPermissions" value="">
    <input type="hidden" name="Action" value="">
    
    <%=writeTableHeader("Web.UserProfile","UserProfile",sWebLanguage," doBack();")%>
    
    <table width="100%" class="menu" cellpadding="1" cellspacing="0">
        <%-- PROFILE SELECTOR --%>
        <tr>
            <td width="328">&nbsp;<%=getTran("Web","Select",sWebLanguage)%> <%=getTran("Web.UserProfile","UserProfile",sWebLanguage)%></td>
            <td align="left">
                <select name="SearchUserprofile" class="text" onChange="profileForm.submit();">
                    <option/>
                    <%=sProfiles%>
                </select>
                <input type="submit" class="button" name="NewUserProfile" value="<%=getTranNoLink("Web","new",sWebLanguage)%>">
                <%if (sUserProfileID.trim().length() > 0) {%>
                <input type="button" class="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete('<%=sUserProfileID%>','<%=sUserProfileName%>');">
                <%}%>
            </td>
        </tr>
    </table>
    <br>

    <div id="printtable">
        <table class="list" width="100%" cellpadding="0" cellspacing="0" style="border-bottom:none;">
            <tr class="gray">
                <td width="320"><%=getTran("Web.UserProfile","UserProfile",sWebLanguage)%></td>
                <td>
                    <input type="text" class="text" name="UserProfileName" value="<%=sUserProfileName%>" size="50" maxLength="70">
                    <input type="button" class="button" value="<%=getTranNoLink("Web.Manage.CheckDb","CheckAll",sWebLanguage)%>" onClick="checkAll(true);">
                    <input type="button" class="button" value="<%=getTranNoLink("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%>" onClick="checkAll(false);">
                </td>
            </tr>
        </table>
        
        <table class="list" width="100%" cellpadding="0" cellspacing="2">
            <%-- PERMISSION PER CATEGORY --%>
            <tr>
                <td colspan="2">
                    <%
                        int headerIdx = 0;
                        Hashtable perms = new Hashtable();
                        SAXReader xmlReader = new SAXReader();
                        String sPermissions = MedwanQuery.getInstance().getConfigString("templateSource")+"permissions.xml";
                        String title, sApplicationType, sApplicationId, sApplicationDisplaySection, 
                               sPermissionType, sPermissionId, sPermission;
                        boolean bDisplaySection;

                        try{
                            Document document = xmlReader.read(new URL(sPermissions));
                            if(document!=null){
                                Element root = document.getRootElement();
                                if(root!=null){
                                    Element eApplication, ePermission;
                                    Iterator applications = root.elementIterator("application");

                                    while(applications.hasNext()){
                                        eApplication = (Element)applications.next();
                                        sApplicationType = checkString(eApplication.attributeValue("type"));
                                        sApplicationId = checkString(eApplication.attributeValue("id"));
                                        sApplicationDisplaySection = checkString(eApplication.attributeValue("displaysection"));

                                        title = getTran(sApplicationType,sApplicationId,sWebLanguage);
                                        perms = new Hashtable();

                                        Iterator permissions = eApplication.elementIterator("permission");
                                        while(permissions.hasNext()){
                                            ePermission = (Element)permissions.next();
                                            
                                            sPermissionType = checkString(ePermission.attributeValue("type"));
                                            sPermissionId = checkString(ePermission.attributeValue("id"));
                                            sPermission = checkString(ePermission.getText());

                                            perms.put(getTran(sPermissionType,sPermissionId,sWebLanguage),sPermission);
                                        }

                                        bDisplaySection = !sApplicationDisplaySection.equalsIgnoreCase("false");
                                        out.print(displayPermissions(title,perms,sUserProfileID,headerIdx++,true,bDisplaySection,sWebLanguage));
                                    }
                                }
                            }
                        }
                        catch(DocumentException e){
                        	// empty
                        }
                    %>                    
                </td>
            </tr>
        </table>
    </div>
    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
	    <input type="button" class="button" name="saveButton" id="saveButton" value="<%=getTranNoLink("Web","Save",sWebLanguage)%>" onClick="doSubmit();">&nbsp;
	    <input type="button" class="button" name="printButton" value="<%=getTranNoLink("Web","print",sWebLanguage)%>" onclick="doPrint();">&nbsp;
	    <%
	    	if(sUserProfileID.trim().length() > 0){
	    	    %><input type="button" class="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete('<%=sUserProfileID%>','<%=sUserProfileName%>');">&nbsp;<%
	    	}
	    %>
	    <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' OnClick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
    
    <input type="hidden" name="UserProfileID" value="<%=sUserProfileID%>">
</form>

<script>
  profileForm.UserProfileName.focus();
  
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }
  
  <%-- DO SUBMIT --%>
  function doSubmit(){
	concatPermissions();
	profileForm.Action.value = "save";
	profileForm.submit();
  }
  
  <%-- CONCAT PERMISSIONS --%>
  function concatPermissions(){
    var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].name!=null && imgs[i].name.indexOf("cat")==0){
    	if(!imgs[i].src.endsWith("uncheck.gif")){
          profileForm.checkedPermissions.value+= imgs[i].name+";";
    	}
      }
    }
  }
    
  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton("<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")) {
      window.location.href = "<c:url value='/main.do'/>?Page=permissions/index.jsp";
    }
  }
  
  <%-- CHECK ALL --%>
  function checkAll(setchecked){
    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type == "hidden" && profileForm.elements[i].name.indexOf("_selected") > -1){
        if(setchecked) profileForm.elements[i].value = 0;
        else           profileForm.elements[i].value = 1;
      }
    }
    
    var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].name!=null && imgs[i].name.indexOf("cat")==0){
    	imgs[i].src = (setchecked==true?"<%=sCONTEXTPATH%>/_img/themes/default/check.gif":"<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif");
      }
    }
  }
  
  <%-- CHECK ROW --%>
  function checkRow(categoryIdx,screenID){
    var leaderCheck = eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+"')[0]");
    var leaderChecked = true;
    
    if(leaderCheck.src.endsWith("uncheck.gif")){
      leaderChecked = false;
      leaderCheck.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
    }
    else{
      leaderCheck.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
    }
    
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Select')[0]").src = leaderCheck.src;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Add')[0]").src = leaderCheck.src;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Edit')[0]").src = leaderCheck.src;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Delete')[0]").src = leaderCheck.src;
  }
  
  <%-- UNCHECK ROW SELECTOR --%>
  function uncheckRowSelector(categoryIdx,screenID){
    var leaderCheck = eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+"')[0]");
    leaderCheck.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
  }
  
  <%-- SELECT PERMISSIONS --%>
  function selectPermissions(headerIdx){
    var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].name!=null && imgs[i].name.indexOf("cat")==0){
        if(imgs[i].name.indexOf("cat"+headerIdx+"$")==0){
          imgs[i].src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
        }
      }
    }
  }
  
  <%-- APPLY POLICY 1 --%>
  function applyPolicy1(checkBoxImg,categoryIdx,screenId){
    if(checkBoxImg.src.endsWith("uncheck.gif")){
      checkBoxImg.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
    }
    else{
      checkBoxImg.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
      
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Add")[0].src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Edit")[0].src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Delete")[0].src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
    }
  }

  <%-- APPLY POLICY 2 --%>
  function applyPolicy2(checkBoxImg,categoryIdx,screenId){
    if(checkBoxImg.src.endsWith("uncheck.gif")) checkBoxImg.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
    else                                        checkBoxImg.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
	    
    var selectCB = document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Select")[0];
    if(checkBoxImg.src.endsWith("check.gif")) selectCB.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
  }
    
  <%-- DO DELETE --%>
  function doDelete(profileId,profileName){
    if(yesnoDialog("Web","areYouSureToDelete")){
      document.location.href = "<%=sCONTEXTPATH%>/main.do?Page=permissions/profiles.jsp&DeletePermissionID="+profileId+"&ts=<%=getTs()%>";
    }
  }
</script>

<%=writeJSButtons("profileForm","saveButton")%>