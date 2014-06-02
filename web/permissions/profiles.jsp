<%@page import="org.dom4j.DocumentException,java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- WRITE PERMISSION ------------------------------------------------------------------------
    public String writePermission(String sLabel, String sScreenID, String sUserProfileID, int idx, int categoryIdx){
        String sSelect = "", sAdd = "", sEdit = "", sDelete = "", sPermission;
        
	    if(sUserProfileID.trim().length() > 0){
	        Vector vPermissions = UserProfilePermission.getActiveUserProfilePermissions(sUserProfileID, sScreenID.toLowerCase());
	        Iterator iter = vPermissions.iterator();
	        while(iter.hasNext()){
	            sPermission = (String) iter.next();
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
	            "<td><input type='checkbox' onclick=\"checkRow("+categoryIdx+",'"+sScreenID+"',this.checked);\" name='cat"+categoryIdx+"$"+sScreenID+"'></td>"+
	            "<td><input type='checkbox' onClick=\"uncheckRowSelector("+categoryIdx+",'"+sScreenID+"');applyPolicy1(this,"+categoryIdx+",'"+sScreenID+"');\" name='cat"+categoryIdx+"$"+sScreenID+".Select' "+sSelect+"></td>"+
	            "<td><input type='checkbox' onClick=\"uncheckRowSelector("+categoryIdx+",'"+sScreenID+"');applyPolicy2(this,"+categoryIdx+",'"+sScreenID+"');\" name='cat"+categoryIdx+"$"+sScreenID+".Add' "+sAdd+"></td>"+
	            "<td><input type='checkbox' onClick=\"uncheckRowSelector("+categoryIdx+",'"+sScreenID+"');applyPolicy2(this,"+categoryIdx+",'"+sScreenID+"');\" name='cat"+categoryIdx+"$"+sScreenID+".Edit' "+sEdit+"></td>"+
	            "<td colspan='2'><input type='checkbox' onClick=\"uncheckRowSelector("+categoryIdx+",'"+sScreenID+"');applyPolicy2(this,"+categoryIdx+",'"+sScreenID+"');\" name='cat"+categoryIdx+"$"+sScreenID+".Delete' "+sDelete+"></td>"+
	           "</tr>";
	}

    //--- WRITE HEADER ----------------------------------------------------------------------------
    public String writeHeader(String sHeader, int headerIdx, boolean displaySection,String sWebLanguage){
        return (headerIdx==0?"":"<br>")+
                "<input type='hidden' name='cat"+headerIdx+"_selected' value='1'>"+
                "<table width='100%' cellspacing='0' class='list'>"+
                 "<tr class='admin'>"+
                  "<td width='2%'>"+
                   "<a href='#'><img id='Input_"+headerIdx+"_S' name='Input_"+headerIdx+"_S' border='0' src='"+sCONTEXTPATH+"/_img/plus.png' OnClick='showD(\"Input_"+headerIdx+"\",\"Input_"+headerIdx+"_S\",\"Input_"+headerIdx+"_H\")' style='display:none'></a>"+
                   "<a href='#'><img id='Input_"+headerIdx+"_H' name='Input_"+headerIdx+"_H' border='0' src='"+sCONTEXTPATH+"/_img/minus.png' OnClick='hideD(\"Input_"+headerIdx+"\",\"Input_"+headerIdx+"_S\", \"Input_"+headerIdx+"_H\")'></a>"+
                  "</td>"+
                  "<td>"+sHeader+"</td>"+
                  "<td>Permission</td>"+
                "<td width='8%'>&nbsp;<a href='javascript:togglePermissions("+headerIdx+");'>"+getTran("web","all",sWebLanguage)+"</a></td>"+
                "<td width='8%'>&nbsp;"+getTran("web","view",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","add",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","edit",sWebLanguage)+"</td>"+
                "<td width='8%'>&nbsp;"+getTran("web","delete",sWebLanguage)+"</td>"+
                "<td align='right'><a href=\"#topp\" class=\"topbutton\">&nbsp;</a></td>"+
               "</tr>"+
               "<tbody id='Input_"+headerIdx+"' name='Input_"+headerIdx+"'>";
    }
    
    public String writeFooter(){
        return " </tbody>"+
               "</table>";
    }
    
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

    //*** SAVE ***
    if(request.getParameter("saveButton")!=null){
        sUserProfileID = checkString(request.getParameter("UserProfileID"));
        sUserProfileName = checkString(request.getParameter("UserProfileName"));
        UserProfile userProfile;
        UserProfilePermission userProfilePermission;

        //*** INSERT PROFILE ***
        if(sUserProfileID.length()==0){
            sUserProfileID = MedwanQuery.getInstance().getNewResultCounterValue("UserProfileID");
            userProfile = new UserProfile();
            userProfile.setUserprofileid(Integer.parseInt(sUserProfileID));
            userProfile.setUserprofilename(sUserProfileName);
            userProfile.setUpdatetime(getSQLTime());
            userProfile.insert();
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
        String sTmpName, sTmpValue, sTmpScreenID, sTmpPermission;
        Enumeration e = request.getParameterNames();
        while(e.hasMoreElements()){
            sTmpName = (String)e.nextElement();
            
            if(sTmpName.toLowerCase().endsWith(".select") ||
               sTmpName.toLowerCase().endsWith(".add") ||
               sTmpName.toLowerCase().endsWith(".edit") ||
               sTmpName.toLowerCase().endsWith(".delete")){
                sTmpScreenID = sTmpName.substring(sTmpName.indexOf("$")+1,sTmpName.lastIndexOf(".")).toLowerCase();
                sTmpPermission = sTmpName.substring(sTmpName.lastIndexOf(".")+1).toLowerCase();
                
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
            // default page
            else if(sTmpName.equalsIgnoreCase("defaultpage")){
                sTmpValue = checkString(request.getParameter(sTmpName));
                if(sTmpValue.length() > 0){
                    userProfilePermission = new UserProfilePermission();
                    userProfilePermission.setUserprofileid(Integer.parseInt(sUserProfileID));
                    userProfilePermission.setScreenid("defaultpage");
                    userProfilePermission.deleteByScreenAndId();
                    userProfilePermission.setPermission(sTmpValue.toLowerCase());
                    userProfilePermission.setUpdatetime(getSQLTime());
                    userProfilePermission.insert();
                }
            }
        }

        // reload permissions in user-object
        activeUser.initialize(Integer.parseInt(activeUser.userid));
        session.setAttribute("activeUser",activeUser);
    }
    else{
        //*** DELETE USER PERMISSION ***
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

<form name="profileForm" id="profileForm" method="post" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
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
                <input type="submit" class="button" name="NewUserProfile" value="<%=getTran("Web","new",sWebLanguage)%>">
                <%if (sUserProfileID.trim().length() > 0) {%>
                <input type="button" class="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete('<%=sUserProfileID%>','<%=sUserProfileName%>');">
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
                    <input type="button" class="button" value="<%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%>" onClick="checkAll(true);">
                    <input type="button" class="button" value="<%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%>" onClick="checkAll(false);">
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
                    
            		<%=writeHeader(getTran("web","other",sWebLanguage),headerIdx,true,sWebLanguage)%>                    
			            <tr height="22" class="list">
			                <td/>
			                <td><%=getTran("Web.UserProfile","DefaultPage",sWebLanguage)%></td>
			                <td colspan="11">
			                    <select name="DefaultPage" class="text">
			                        <option/>
			                        <%
			                            String sSelected = sDefaultPage;
			                            xmlReader = new SAXReader();
			                            String sDefaultPageXML = MedwanQuery.getInstance().getConfigString("templateSource")+"defaultPages.xml";
			                            String sType, setSelected = "";
			                            
			                            try{
			                                Document document = xmlReader.read(new URL(sDefaultPageXML));
			                                if(document!=null){
			                                    Element root = document.getRootElement();
			                                    if(root!=null){
			                                        Iterator elements = root.elementIterator("defaultPage");
			                                        Element ePage;
			                                        
			                                        while(elements.hasNext()){
			                                            ePage = (Element)elements.next();
			                                            sType = checkString(ePage.attributeValue("type")).toLowerCase();
			                                        
			                                            if(sType.equals(sSelected)) setSelected = " selected";
			                                            else                        setSelected = "";
			                                            
			                                            out.print("<option value=\""+sType+"\""+setSelected+">"+getTranNoLink("defaultPage",sType,sWebLanguage)+"</option>");
			                                        }
			                                    }
			                                }
			                                else{
			                                    out.print("<option value='administration'"+setSelected+">"+getTranNoLink("defaultPage","administratioon",sWebLanguage)+"</option>");
			                                }
			                            }
			                            catch(DocumentException e){
			                                out.print("<option value='administration'"+setSelected+">"+getTranNoLink("defaultPage","administratioon",sWebLanguage)+"</option>");
			                            }
			                        %>
			                    </select>
			                </td>
			            </tr>
                    <%=writeFooter()%>
                </td>
            </tr>
        </table>
    </div>
    
    <%=ScreenHelper.alignButtonsStart()%>
	    <input type="submit" class="button" name="saveButton" id="saveButton" value="<%=getTran("Web","Save",sWebLanguage)%>">&nbsp;
	    <input type="button" class="button" name="printButton" value="<%=getTran("Web","print",sWebLanguage)%>" onclick="doPrint();">&nbsp;
	    <input type="button" class="button" name="backButton" Value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick="doBack();">
	    <%
	    	if(sUserProfileID.trim().length() > 0){
	    	    %><input type="button" class="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete('<%=sUserProfileID%>','<%=sUserProfileName%>');"><%
	    	}
	    %>
    <%=ScreenHelper.alignButtonsStop()%>
    
    <input type="hidden" name="UserProfileID" value="<%=sUserProfileID%>">
</form>

<script>
  profileForm.UserProfileName.focus();
  
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
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
    
    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type=="checkbox"){
        profileForm.elements[i].checked = setchecked;
      }
    }
  }
  
  <%-- CHECK ROW --%>
  function checkRow(categoryIdx,screenID,setChecked){
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Select')[0]").checked = setChecked;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Add')[0]").checked = setChecked;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Edit')[0]").checked = setChecked;
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+".Delete')[0]").checked = setChecked;
  }
  
  <%-- UNCHECK ROW SELECTOR --%>
  function uncheckRowSelector(categoryIdx,screenID){
    eval("document.getElementsByName('cat"+categoryIdx+"$"+screenID+"')[0]").checked = false;
  }
  
  <%-- TOGGLE PERMISSIONS --%>
  function togglePermissions(headerIdx){
    var isChecked = (document.getElementsByName('cat'+headerIdx+'_selected')[0].value==1);
    if(isChecked) document.getElementsByName('cat'+headerIdx+'_selected')[0].value = 0;
    else          document.getElementsByName('cat'+headerIdx+'_selected')[0].value = 1;
 
    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type=="checkbox"){
        if(profileForm.elements[i].name.indexOf("cat"+headerIdx+"$")==0){
          profileForm.elements[i].checked = isChecked;
        }
      }
    }
  }
  
  <%-- APPLY POLICY 1 --%>
  function applyPolicy1(checkBox,categoryIdx,screenId){
    if(!checkBox.checked){
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Add")[0].checked = false;
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Edit")[0].checked = false;
      document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Delete")[0].checked = false;
    }
  }

  <%-- APPLY POLICY 2 --%>
  function applyPolicy2(checkBox,categoryIdx,screenId){
    var selectCB = document.getElementsByName("cat"+categoryIdx+"$"+screenId+".Select")[0];
    if(checkBox.checked) selectCB.checked = true;
  }
    
  <%-- DO DELETE --%>
  function doDelete(profileId,profileName){
    if(yesnoDialog("Web","areYouSureToDelete")){
      document.location.href = "<%=sCONTEXTPATH%>/main.do?Page=permissions/profiles.jsp&DeletePermissionID="+profileId+"&ts=<%=getTs()%>";
    }
  }
</script>

<%=writeJSButtons("profileForm","saveButton")%>