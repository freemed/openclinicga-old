<%@ page import="java.util.Hashtable,java.util.Enumeration,java.util.StringTokenizer,be.openclinic.medical.LabProfile,be.openclinic.medical.LabProfileAnalysis" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%=sJSSORTTABLE%>
<%
    final String sLabelType = "labprofiles";
    boolean recordExists = false;

    String sAction = checkString(request.getParameter("Action"));

    String sLabID = checkString(request.getParameter("LabID")),
           sProfileID = checkString(request.getParameter("ProfileID")),
           sFindProfileCode = checkString(request.getParameter("FindProfileCode")),
           sEditProfileCode = checkString(request.getParameter("EditProfileCode")),
           sOldProfileCode = checkString(request.getParameter("OldProfileCode"));

    // DEBUG ////////////////////////////////////////////////////////////////////////////
    Debug.println("### ACTION = "+sAction+" ####################################");
    Debug.println("### sLabID           = "+sLabID);
    Debug.println("### sProfileID       = "+sProfileID);
    Debug.println("### sFindProfileCode = "+sFindProfileCode);
    Debug.println("### sEditProfileCode = "+sEditProfileCode);
    Debug.println("### sOldProfileCode  = "+sOldProfileCode+"\n\n");
    /////////////////////////////////////////////////////////////////////////////////////

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    // get all params starting with 'EditLabelValueXX', representing labels in different languages
    Hashtable labelValues = new Hashtable();
    Enumeration paramEnum = request.getParameterNames();
    String tmpParamName, tmpParamValue, tmpLang;

    if (sAction.equals("save") || sAction.equals("new") || sAction.equals("addLab") || sAction.equals("remLab")) {
        while (paramEnum.hasMoreElements()) {
            tmpParamName = (String) paramEnum.nextElement();

            if (tmpParamName.startsWith("EditLabelValue")) {
                tmpParamValue = request.getParameter(tmpParamName);
                labelValues.put(tmpParamName.substring(14), tmpParamValue); // language, value
            }
        }
    } else if (sAction.equals("details")) {
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            labelValues.put(tmpLang, getTranNoLink(sLabelType, sProfileID, tmpLang));
        }
    }

    if (sOldProfileCode.equals("")) sOldProfileCode = sFindProfileCode;

    String sComment = "";
%>
<%-- SEARCHFORM ---------------------------------------------------------------------------------%>
<form name="searchForm" method="post">
  <input type="hidden" name="Action" value="find"/>
  <input type="hidden" name="ProfileID" value="<%=sProfileID%>"/>
<%=writeTableHeader("Web.Occup","medwan.system-related-actions.manage-labProfiles",sWebLanguage,"doBack();")%>
<table width="100%" class="menu" cellspacing="0" cellpadding="1">
  <%-- INPUT & BUTTONS --%>
  <tr>
    <td class="menu" width="<%=sTDAdminWidth%>">
      &nbsp;<%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%>
    </td>
    <td>
      <input type="text" name="FindProfileCode" class="text" size="20" value="<%=(sAction.equals("details")?"":sFindProfileCode)%>" onblur="limitLength(this);">
      &nbsp;
      <input class="button" type="submit" name="findButton" value="<%=getTran("Web","find",sWebLanguage)%>" onclick="searchForm.Action.value='find';"/>&nbsp;
      <input class="button" type="button" name="clearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClear();">&nbsp;
      <input class="button" type="button" name="createButton" value="<%=getTran("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
      <input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
    </td>
  </tr>
</table>
<script>
  searchForm.FindProfileCode.focus();

  function doClear(){
    searchForm.FindProfileCode.value = '';
    searchForm.FindProfileCode.focus();
  }

  function doNew(){
    searchForm.FindProfileCode.value = '';
    searchForm.Action.value = 'new';
    searchForm.ProfileID.value = '';
    searchForm.submit();
  }

  function doBack(){
    window.location.href = '<c:url value="/main.do"/>?Page=system/menu.jsp&ts=<%=getTs()%>';
  }
</script>
</form>
<%
    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") || sAction.equals("new")) {
        if (sEditProfileCode.length() > 0) {
            sComment = checkString(request.getParameter("EditComment"));
            boolean bInsert = false;
            boolean bUpdate = false;
            //--- NEW LAB PROFILE --------------------------------------------------
            if (sAction.equals("new")) {
                // check if profileCode exists
                sProfileID = MedwanQuery.getInstance().getOpenclinicCounter("LabProfileID")+"";
                boolean deletedRecordFound = false;
                boolean unDeletedRecordFound = false;
                boolean[] recordsFound = LabProfile.existsByProfileCode(sOldProfileCode);

                // check delete time
                deletedRecordFound = recordsFound[0];
                unDeletedRecordFound = recordsFound[1];
                if ((!deletedRecordFound && !unDeletedRecordFound) || (deletedRecordFound && !unDeletedRecordFound)) {
                    bInsert = true;
                }
                //--- NEW ANALYSIS BUT IT ALLREADY EXISTS ---
                else if (unDeletedRecordFound) {
                    recordExists = true;
                }
            }
            //--- UPDATE LAB PROFILE -----------------------------------------------
            else {
                bUpdate = true;
            }

            // execute query
            if (!recordExists) {
                LabProfile labProfile = new LabProfile();
                labProfile.setProfileID(Integer.parseInt(sProfileID));
                labProfile.setProfilecode(sEditProfileCode);
                labProfile.setComment(sComment);
                labProfile.setUpdateuserid(Integer.parseInt(activeUser.userid));
                labProfile.setUpdatetime(getSQLTime());
                labProfile.setDeletetime(null);
                if (bInsert) {
                    labProfile.insert();
                } else if (bUpdate) {
                    labProfile.update(Integer.parseInt(sProfileID));
                }
            }

            //--- SAVE LABEL ----------------------------------------------------------------------
            // check if label exists for each of the supported languages

            Label label;

            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                //--- check if label exists ---
                label = new Label();
                label.type = sLabelType;
                label.id = sProfileID;
                label.language = tmpLang;
                label.value = checkString((String) labelValues.get(tmpLang));
                label.showLink = "0";
                label.updateUserId = activeUser.userid;

                label.saveToDB();

                MedwanQuery.getInstance().removeLabelFromCache(sLabelType, sEditProfileCode, tmpLang);
                MedwanQuery.getInstance().getLabel(sLabelType, sEditProfileCode, tmpLang);
            }

            reloadSingleton(session);

            // message
            if (recordExists) {
                out.print(getTran("Web.Occup", "labprofiles.profile", sWebLanguage) + " '" + sEditProfileCode + "' " + getTran("Web", "exists", sWebLanguage));
            } else {
                out.print(getTran("Web", "dataissaved", sWebLanguage));
                sAction = "save";
            }
        }
    }

    //--- DELETE ----------------------------------------------------------------------------------
    if (sAction.equals("delete")) {
        // set deletetime and updatetime of labprofile to now
        LabProfile labProfile = new LabProfile();
        labProfile.setProfileID(Integer.parseInt(sProfileID));
        labProfile.delete();
        // also delete all records in LabprofileAnalysis
        LabProfileAnalysis.deleteByProfileID(Integer.parseInt(sProfileID));
        // message
        out.print(getTran("Web.Occup", "labprofiles.profile", sWebLanguage) + " '" + sEditProfileCode + "' " + getTran("Web", "deleted", sWebLanguage));
    }

    //--- ADD LABANALYSIS -------------------------------------------------------------------------
    if (sAction.equals("addLab")) {
        // get values from request
        String sLabCode = checkString(request.getParameter("LabCode")),
               sLabCodeOther = checkString(request.getParameter("LabCodeOther")),
               sLabComment = checkString(request.getParameter("LabComment"));

        // compose query
        boolean connected = LabProfile.checkLabProfileLabAnalysisConnection(sLabCodeOther,sLabComment,sLabID,sProfileID,sLabCode);

        if (!connected) {
            LabProfileAnalysis labProfAnalysis = new LabProfileAnalysis();
            labProfAnalysis.setProfileID(Integer.parseInt(sProfileID));
            labProfAnalysis.setLabID(Integer.parseInt(sLabID));
            labProfAnalysis.setUpdateuserid(Integer.parseInt(activeUser.userid));
            labProfAnalysis.setComment(sLabComment);
            labProfAnalysis.insert();

            // set updatetime of labprofile to now
            LabProfile.updateUpdateTime(Integer.parseInt(sProfileID));

            // message
            if (sLabCodeOther.equals("1")) {
                out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + " (" + sLabComment + ")' " + getTran("Web", "added", sWebLanguage));
            } else {
                out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + "' " + getTran("Web", "added", sWebLanguage));
            }
        } else {
            // message
            if (sLabCodeOther.equals("1")) {
                out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + " (" + sLabComment + ")' " + getTran("Web", "exists", sWebLanguage));
            } else {
                out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + "' " + getTran("Web", "exists", sWebLanguage));
            }
        }
    }

    //--- REMOVE LABANALYSIS ----------------------------------------------------------------------
    if (sAction.equals("remLab")) {
        // get values from request
        String sLabCode = checkString(request.getParameter("LabCode")),
                sLabCodeOther = checkString(request.getParameter("LabCodeOther")),
                sLabComment = checkString(request.getParameter("LabComment"));

        LabProfileAnalysis.deleteByProfileIDLabID(Integer.parseInt(sProfileID),Integer.parseInt(sLabID));
        // set updatetime of labprofile to now
        LabProfile.updateUpdateTime(Integer.parseInt(sProfileID));
        // message
        if (sLabCodeOther.equals("1")) {
            out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + " (" + sLabComment + ")' " + getTran("Web", "removed", sWebLanguage));
        } else {
            out.print(getTran("Web.Occup", "labanalysis.analysis", sWebLanguage) + " '" + sLabCode + "' " + getTran("Web", "removed", sWebLanguage));
        }
    }

    //--- SEARCH ----------------------------------------------------------------------------------
    int iTotal = 0;
    if (sAction.equals("find")) {
        //--- FIND HEADER ---
%>
        <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
          <tr class="admin">
            <td width='15%'>&nbsp;<%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%></td>
            <td width='30%'>&nbsp;<%=getTran("Web","description",sWebLanguage)%></td>
            <td width='*%'>&nbsp;<%=getTran("Web.manage","labprofiles.cols.comment",sWebLanguage)%></td>
          </tr>

          <tbody onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
        <%

        //--- compose search-select ---
        Vector vLabProfiles = LabProfile.getActiveLabProfilesByProfileCode(sFindProfileCode);
        Iterator iter = vLabProfiles.iterator();

        String sClass;

        //--- display found records ---
        LabProfile labProfile;
        while(iter.hasNext()){
            labProfile = (LabProfile)iter.next();
            iTotal++;

            // get data from RS
            sProfileID       = Integer.toString(labProfile.getProfileID());
            sEditProfileCode = ScreenHelper.checkString(labProfile.getProfilecode());
            sComment         = ScreenHelper.checkString(labProfile.getComment());

            // alternate rows
            if((iTotal%2)==0) sClass = "1";
	        else              sClass = "";

            %>
                <tr class="list<%=sClass%>"  >
                  <td class="hand" onClick="showDetails('<%=sEditProfileCode%>','<%=sProfileID%>');"><%=sEditProfileCode%></td>
                  <td class="hand" onClick="showDetails('<%=sEditProfileCode%>','<%=sProfileID%>');"><%=getTran(sLabelType,sProfileID,sWebLanguage)%></td>
                  <td class="hand" onClick="showDetails('<%=sEditProfileCode%>','<%=sProfileID%>');" ><%=sComment%></td>
                </tr>
            <%
        }

        out.print("</table>");
        %>
          </tbody>

          <%-- MESSAGE --%>
          <table border="0" width="100%">
            <tr height="30">
              <td><%=iTotal%> <%=getTran("Web","recordsFound",sWebLanguage)%></td>

              <%-- link --%>
              <td align="right">
                <img src='<c:url value="/_img/pijl.gif"/>'>
                <a  href="<c:url value="/main.do"/>?Page=system/manageLabAnalyses.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labAnalysis",sWebLanguage)%></a>&nbsp;
              </td>
            </tr>
          </table>
        <%
    }
    %>

    <script>
      function showDetails(code,id){
        searchForm.Action.value = 'details';
        searchForm.FindProfileCode.value = code;
        searchForm.ProfileID.value = id;
        searchForm.submit();
      }
    </script>
    <%

    // show details after "save"
    if(sAction.equals("save") || sAction.equals("addLab") || sAction.equals("remLab")){
        sAction = "details";
        sFindProfileCode = sEditProfileCode;
    }

    //--- EDIT/ADD FIELDS -------------------------------------------------------------------------
    if(sAction.equals("new") || sAction.equals("details")){
        iTotal = 0;
        if(sFindProfileCode.equals("")) sFindProfileCode = sEditProfileCode;

        //--- check if ProfileCode exists; details are shown if it exists, else values will be blank ---
        if(sFindProfileCode.length() > 0){
            LabProfile labProfile = LabProfile.getProfilesByProfileIDLabID(sFindProfileCode,Integer.parseInt(sProfileID));
            if(labProfile!=null){
                iTotal++;

                // get data from RS
                sEditProfileCode = labProfile.getProfilecode();
                sComment         = labProfile.getComment();
            }
        }
    %>

<%-- EDIT/ADD FROM ------------------------------------------------------------------------------%>
<form name="editForm" id="editForm" method="post" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
  <input type="hidden" name="Action" value="<%=(sAction.equals("new")?sAction:"save")%>"/>
  <input type="hidden" name="LabID" value="<%=sLabID%>"/>
  <input type="hidden" name="LabCodeOther" value=""/>
  <input type="hidden" name="ProfileID" value="<%=sProfileID%>"/>
  <input type="hidden" name="OldProfileCode" value="<%=sOldProfileCode%>"/>

<table border="0" width="100%" class="list" cellspacing="1" cellpadding="0">

  <%-- EDIT/ADD HEADER --%>
  <tr class="admin">
    <td colspan="2">
        <%
            if(iTotal > 0) out.print(getTran("Web","edit",sWebLanguage));
            else           out.print(getTran("Web","new",sWebLanguage));
        %>
    </td>
  </tr>
  <%-- PROFILE CODE --%>
  <tr>
    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%></td>
    <td class="admin2">
        <input type="text" name="EditProfileCode" tabindex="1" class="text" value="<%=sEditProfileCode%>" size="20" onblur="limitLength(this);">
    </td>
  </tr>
  <%-- LABEL --%>
  <%
      // display input field for each of the supported languages
      StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
      while(tokenizer.hasMoreTokens()){
          tmpLang = tokenizer.nextToken();

          %>
              <tr>
                  <td class="admin"> <%=getTran("Web","Description",sWebLanguage)%> <%=tmpLang%> *</td>
                  <td class="admin2">
                      <input type="text" class="text" name="EditLabelValue<%=tmpLang%>" value="<%=checkString((String)labelValues.get(tmpLang))%>" size="<%=sTextWidth%>">
                  </td>
              </tr>
          <%
      }
  %>
  <%-- LABANALYSIS LINKED TO THIS LABPROFILE ----------------------------------------------------%>
  <%
      if(!sAction.equals("new")){
          %>
            <tr>
              <td class="admin"><%=getTran("Web.manage","labprofiles.analyse",sWebLanguage)%></td>
              <td class="admin2">
                <table border="0" class="list" cellspacing="0" cellpadding="0">
                  <%-- HEADER --%>
                  <tr class="admin">
                    <td><%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></td>
                    <td><%=getTran("web.manage","labanalysis.cols.type",sWebLanguage)%></td>
                    <td><%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%></td>
                    <td><%=getTran("web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
                    <td width="16">&nbsp;</td>
                  </tr>
                  <%-- LABCODE CHOOSER --%>
                  <tr class="list1">
                    <td>
                      <input type="text" name="LabCode" tabindex="4" class="text" size="18" onBlur='blurLabAnalysis();'>
                    </td>
                    <td>
                      <input type="text" name="LabType" class="text" size="10" READONLY>
                    </td>
                    <td>
                      <input type="text" name="LabLabel" class="text" size="30" READONLY>
                    </td>
                    <td>
                      <input type="text" name="LabComment" class="text" size="20" onblur="limitLength(this);">
                    </td>
                    <td>
                      <input type="button" class="button" tabindex="5" name="LabChooseButton" value="<%=getTran("Web","choose",sWebLanguage)%>" onclick="searchLabAnalysis();">&nbsp;
                      <input type="button" class="button" tabindex="6" name="LabAddButton"    value="<%=getTran("Web","add",sWebLanguage)%>" onClick="addLabAnalysis();">
                    </td>
                  </tr>
                  <%
                      // compose search-select
                      Vector vLabProfilesData = LabProfile.searchLabProfilesDataByProfileID(sProfileID);
                      Iterator iter = vLabProfilesData.iterator();
                      String sClass, sLabCode, sLabType, sLabCodeOther, sLabComment;
                      iTotal = 0;

                      //--- display found records ---
                      Hashtable hLabProfileData;
                      while(iter.hasNext()){
                          hLabProfileData = (Hashtable)iter.next();
                          iTotal++;

                          // get data from RS
                          sLabID        = (String)hLabProfileData.get("labID");
                          sLabCode      = (String)hLabProfileData.get("labcode");
                          sLabType      = (String)hLabProfileData.get("labtype");
                          sLabCodeOther = (String)hLabProfileData.get("labcodeother");
                          sLabComment   = (String)hLabProfileData.get("comment");

                          // translate labtype
                               if(sLabType.equals("1")) sLabType = getTran("Web.occup","labanalysis.type.blood",sWebLanguage);
                          else if(sLabType.equals("2")) sLabType = getTran("Web.occup","labanalysis.type.urine",sWebLanguage);
                          else if(sLabType.equals("3")) sLabType = getTran("Web.occup","labanalysis.type.other",sWebLanguage);
                          else if(sLabType.equals("4")) sLabType = getTran("Web.occup","labanalysis.type.stool",sWebLanguage);
                          else if(sLabType.equals("5")) sLabType = getTran("Web.occup","labanalysis.type.sputum",sWebLanguage);
                          else if(sLabType.equals("6")) sLabType = getTran("Web.occup","labanalysis.type.smear",sWebLanguage);
                          else if(sLabType.equals("7")) sLabType = getTran("Web.occup","labanalysis.type.liquid",sWebLanguage);

                          // alternate row-style
                          if((iTotal%2)==0) sClass = "1";
                          else              sClass = "";

                          %>
                              <tr class="list<%=sClass%>">
                                <td><%=sLabCode%></td>
                                <td><%=sLabType%></td>
                                <td><%=getTran("labanalysis",sLabID,sWebLanguage)%></td>
                                <%
                                    if(sLabCodeOther.equals("1")){
                                        %><td>&nbsp;<%=sLabComment%></td><%
                                    }
                                    else{
                                        %><td>&nbsp;</td><%
                                    }
                                %>
                                <td>
                                  <img src='<c:url value="/_img/icon_delete.gif"/>' border='0' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="removeLabAnalysis('<%=sLabID%>','<%=sLabComment%>','<%=sLabCodeOther%>','<%=sLabCode%>');" onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
                                </td>
                              </tr>
                          <%
                      }
                      // message if no records found
                      if(iTotal == 0){
                          %>
                              <tr class="list">
                                <td colspan="5"><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                              </tr>
                          <%
                      }
                    %>
                  </table>
                </td>
              </tr>
              <script>
                <%-- BLUR LABANALYSIS --%>
                function blurLabAnalysis(inputObj){
                  if(inputObj.value.length > 0){
                    openPopup("/_common/search/blurLabAnalysis.jsp&SearchCode="+inputObj.value+"&VarID=LabID&VarType=LabType&VarCode=LabCode&VarText=LabLabel");
                  }
                }

                <%-- SEARCH LABANALYSIS --%>
                function searchLabAnalysis(){
                  openPopup("/_common/search/searchLabAnalysis.jsp&VarID=LabID&VarType=LabType&VarCode=LabCode&VarText=LabLabel");
                }

                <%-- ADD LABANALYSIS --%>
                function addLabAnalysis(){
                  if(editForm.LabCodeOther.value=="1"){
                    if(editForm.LabCode.value!="" && editForm.LabLabel.value!=""){
                      if(editForm.LabComment.value!=""){
                        editForm.Action.value = 'addLab';
                        editForm.submit();
                      }
                      else{
                        editForm.LabComment.focus();
                      }
                    }
                  }
                  else{
                    if(editForm.LabCode.value!="" && editForm.LabLabel.value!=""){
                      editForm.Action.value = 'addLab';
                      editForm.submit();
                    }
                    else{
                      editForm.LabCode.focus();
                    }
                  }
                }

                <%-- REMOVE LABANALYSIS --%>
                function removeLabAnalysis(labid,comment,labCodeOther,labCode){
                  if(yesnoDialog("Web","areYouSureToDelete")){
                    editForm.LabID.value = labid;
                    editForm.Action.value = 'remLab';
                    editForm.LabComment.value = comment;
                    editForm.LabCodeOther.value = labCodeOther;
                    editForm.LabCode.value = labCode;
                    editForm.submit();
                  }
                }
              </script>
          <%
      }
  %>
  <%-- COMMENT TEXTAREA --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labprofiles.cols.comment",sWebLanguage)%></td>
    <td class="admin2">
      <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" tabindex="7" class="text" cols="80" rows="2" name="EditComment"><%=sComment%></textarea>
    </td>
  </tr>
  <tr>
      <td class="admin"/>
      <td class="admin2">
          <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=getTran("web","record",sWebLanguage)%>" onClick="checkSave();"/>&nbsp;
            <script>
              function checkSave(){
                <%
                  if(!sAction.equals("new")){
                %>
                  addLabAnalysis();
                <%
                }
                %>
                if(editForm.EditProfileCode.value.length == 0
                  <%
                      // check input field of each supported language for content
                      tokenizer = new StringTokenizer(supportedLanguages,",");
                      while(tokenizer.hasMoreTokens()){
                          tmpLang = tokenizer.nextToken();

                          %>|| editForm.EditLabelValue<%=tmpLang%>.value.length==0<%
                      }
                  %>
                ){
                  alertDialog("web.manage","datamissing");

                       if(editForm.EditProfileCode.value.length == 0){ editForm.EditProfileCode.focus(); }
                  <%
                      // check input field of each supported language for content
                      tokenizer = new StringTokenizer(supportedLanguages,",");
                      while(tokenizer.hasMoreTokens()){
                          tmpLang = tokenizer.nextToken();

                          out.print("else if(editForm.EditLabelValue"+tmpLang+".value.length==0){ editForm.EditLabelValue"+tmpLang+".focus(); }");
                      }
                  %>
                }
                else{
                  editForm.submit();
                }
              }
            </script>
            <%
              if(!sAction.equals("new")){
                %>
                  <input class="button" type="button" value="<%=getTran("web","delete",sWebLanguage)%>" onClick="checkDelete();"/>&nbsp;
                  <script>
                    function checkDelete(){
                      if(editForm.EditProfileCode.value.length > 0){
                  	    if(yesnoDialog("Web","areYouSureToDelete")){
                          editForm.Action.value = 'delete';
                          editForm.submit();
                        }
                      }
                    }
                  </script>
                <%
              }
            %>
            <input class="button" type="button" value="<%=getTran("web","back",sWebLanguage)%>" onclick="showOverview();">&nbsp;

            <%-- link to labanalyses --%>
            <img src='<c:url value="/_img/pijl.gif"/>'>
            <a  href="<c:url value="/main.do"/>?Page=system/manageLabAnalyses.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labAnalysis",sWebLanguage)%></a>&nbsp;
      </td>
  </tr>
</table>
<script>
  editForm.EditProfileCode.focus();

  function showOverview(){
    window.location.href = '<c:url value="/main.do"/>?Page=system/manageLabProfiles.jsp&ts=<%=getTs()%>';
  }
</script>
</form>

        <%=writeJSButtons("editForm","SaveButton")%>
        <%
    }
%>