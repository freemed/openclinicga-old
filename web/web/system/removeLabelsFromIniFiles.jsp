<%@page import="java.io.*,java.util.Properties,java.util.Enumeration,java.util.StringTokenizer,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- CONTAINS KEY ----------------------------------------------------------------------------
    // a properties object is case sensitive; this function makes it INsensitive.
    public boolean containsKey(Properties properties, String key) {
        Enumeration keys = properties.keys();
        String iniKey = null;

        while (keys.hasMoreElements()) {
            iniKey = (String) keys.nextElement();
            if (iniKey.equalsIgnoreCase(key)) {
                return true;
            }
        }

        return false;
    }

    //--- GET PROPERTY FILE -----------------------------------------------------------------------
    private Properties getPropertyFile(String sFilename) throws Exception {
        Properties iniProps = new Properties();
        FileInputStream iniIs = new FileInputStream(sAPPFULLDIR + sFilename);
        iniProps.load(iniIs);
        iniIs.close();

        return iniProps;
    }
%>
<%
    String action = checkString(request.getParameter("action"));

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";

    // get data from form
    String sFindLabelValue = checkString(request.getParameter("FindLabelValue"));
    String sFindLabelType  = checkString(request.getParameter("FindLabelType"));
    String sFindLabelID    = checkString(request.getParameter("FindLabelID"));
    String sFindLeaderLang = checkString(request.getParameter("FindLeaderLang"));

    // leader file is first supported language if no leader is specified
    if(sFindLeaderLang.length() == 0){
        sFindLeaderLang = supportedLanguages.substring(0,2);
    }

    // what ini-file to use
    String INIFILENAME = "/_common/xml/Labels.xx.ini";
    if(sFindLeaderLang.length() > 0){
        if(sFindLeaderLang.length() == 2){
            INIFILENAME = INIFILENAME.replaceAll("xx",sFindLeaderLang);
        }
        else{
            throw new Exception("Country must be written in a 2-digit format.");
        }
    }

    // excluded label types
    String excludedLabelTypes = MedwanQuery.getInstance().getConfigString("excludedLabelTypes");
    if(excludedLabelTypes.length() == 0){
        excludedLabelTypes = "labanalysis,labprofiles,activitycodes,worktime"; // default
    }
    excludedLabelTypes = excludedLabelTypes.toLowerCase();
%>
<a name="top"/>
<form name="transactionForm" method="POST" onKeyDown="if(window.event.keyCode==13){doSubmit('find');}">
<input type="hidden" name="action">
<%=writeTableHeader("Web.manage","removeLabelsFromIniFiles",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<%-- SELECT ACTION TABLE -------------------------------------------------------------------------%>
<table width="100%" class="menu" cellspacing="1">
    <%-- LABEL TYPE --%>
    <tr>
        <td>&nbsp;<%=getTran("Web","type",sWebLanguage)%></td>
        <td>
            <input type="text" class="text" name="FindLabelType" size="60" value="<%=sFindLabelType%>">
        </td>
    </tr>
    <%-- LABEL ID --%>
    <tr>
        <td>&nbsp;<%=getTran("Web.Translations","labelid",sWebLanguage)%></td>
        <td>
            <input type="text" class="text" name="FindLabelID" size="60" value="<%=sFindLabelID%>">
        </td>
    </tr>
    <%-- LABEL VALUE --%>
    <tr>
        <td>&nbsp;<%=getTran("Web.Translations","label",sWebLanguage)%></td>
        <td>
            <input type="text" class="text" name="FindLabelValue" size="60" value="<%=sFindLabelValue%>">&nbsp;&nbsp;
        </td>
    </tr>
    <%-- LEADER INI FILE --%>
    <tr>
        <td>&nbsp;<%=getTran("Web.Translations","leaderinifile",sWebLanguage)%></td>
        <td>
            <%
                String tmpLang;
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                while (tokenizer.hasMoreTokens()) {
                    tmpLang = tokenizer.nextToken();
            %>
                        <input type="radio" name="FindLeaderLang" id="rb_<%=tmpLang%>" value="<%=tmpLang%>" <%=sFindLeaderLang.equalsIgnoreCase(tmpLang)?"checked":""%>>
                        <label for="rb_<%=tmpLang%>"><%=getTran("web.language",tmpLang,sWebLanguage)%></label>
                    <%
                }
            %>

            <%-- buttons --%>
            &nbsp;&nbsp;&nbsp;
            <input type="button" class="button" name="FindButton" value="<%=getTran("Web","Find",sWebLanguage)%>" onclick="doSubmit('find');">&nbsp;
            <input type="button" class="button" name="ClearButton" value="<%=getTran("Web","Clear",sWebLanguage)%>" onClick="clearFindFields();">
        </td>
    </tr>
    <%-- exclude types --%>
    <tr height="22">
        <td>&nbsp;<%=getTran("web.translations","Excludedtypes",sWebLanguage)%></td>
        <td><%=excludedLabelTypes%></td>
    </tr>
</table>
<%
    //################################################################################################
    //### DELETE #####################################################################################
    //################################################################################################
    if (action.equals("delete")) {
        String deleteMsg = "";

        try {
            Vector recsToBeDeleted = new Vector();
            String paramName, paramValue, labelUniqueKey = null;

            // PUT ASIDE RECORDS SPECIFIED FOR DELETION IN REQUEST
            Enumeration e = request.getParameterNames();
            while (e.hasMoreElements()) {
                paramName = (String) e.nextElement();
                paramValue = checkString(request.getParameter(paramName));

                if (paramName.startsWith("checkbox$") && paramValue.equals("on")) {
                    labelUniqueKey = paramName.substring(9).toLowerCase();
                    recsToBeDeleted.add(labelUniqueKey);
                }
            }

            // DELETE FROM INI FILE
            Properties iniProps = getPropertyFile(INIFILENAME);

            String label;
            for (int i = 0; i < recsToBeDeleted.size(); i++) {
                label = (String) recsToBeDeleted.get(i);
                iniProps.remove(label);
            }

            // write labels to ini file
            FileOutputStream outputStream = new FileOutputStream(sAPPFULLDIR + INIFILENAME);
            iniProps.store(outputStream, "Labels." + sFindLeaderLang + ".ini");
            outputStream.close();

            deleteMsg = getTran("Web", "DataIsDeleted", sWebLanguage);
        }
        catch (Exception e) {
            deleteMsg = "<font color='red'>" + e.getMessage() + "</font>";
        }

%>
          <br>
          <%=deleteMsg%>
      <%
  }
  //################################################################################################
  //### FIND (DISPLAY DIFFERENCES) #################################################################
  //################################################################################################
  else if(action.equals("find")){
    %>
    <br>
    <%-- BUTTONS at TOP --------------------------------------------------------------------------%>
    <table width="100%" cellspacing="1">
        <tr>
            <td>
                <a href="#" onclick="checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                <a href="#" onclick="checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
            </td>
            <td align="right">
                <a href='#bottom'><img src='<c:url value='/_img/bottom.jpg'/>' class='link' border="0"></a>
            </td>
        </tr>
    </table>
    <%-- DISPLAY RECORDS (between buttons) -------------------------------------------------------%>
    <table width="100%" class="list" cellspacing="1" onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
        <%-- spacer --%>
        <tr><td width="16"/><td/><td width="99%"/></tr>
        <%
            String findMsg = "";
            int labelCount = 0, validLabelCount = 0, invalidLabelCount = 0, excludedLabelCount = 0;

            try{
                String labelUniqueKey, sLabelValue, sLabelType, sLabelID, style = null, checked;

                // load property-objects from ini-files
                Properties iniProps = getPropertyFile(INIFILENAME);

                // invalid key chars
                String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
                if(invalidLabelKeyChars.length() == 0){
                    invalidLabelKeyChars = " /:"; // default
                }

                // select ini file to search on (=leader)
                Enumeration labelEnum;
                labelEnum = iniProps.propertyNames();

                while(labelEnum.hasMoreElements()){
                    labelCount++;
                    labelUniqueKey = checkString((String)labelEnum.nextElement());

                    // only process labels with a valid id
                    if(labelUniqueKey.indexOf("$")>0){
                        sLabelType = labelUniqueKey.substring(0,labelUniqueKey.indexOf("$"));

                        // only process not-excluded labels
                        if(excludedLabelTypes.indexOf(sLabelType.toLowerCase()) < 0){
                            sLabelID = labelUniqueKey.substring(labelUniqueKey.indexOf("$")+1,labelUniqueKey.lastIndexOf("$"));

                            sLabelValue = checkString(iniProps.getProperty(labelUniqueKey));

                            // decide wether to display the labelrow.
                            boolean typeFound, idFound, textFound;
                            typeFound = (sFindLabelType.length()>0?sLabelType.indexOf(sFindLabelType.toLowerCase())>-1:false);
                            idFound   = (sFindLabelID.length()>0?sLabelID.indexOf(sFindLabelID.toLowerCase())>-1:false);
                            textFound = (sFindLabelValue.length()>0?sLabelValue.indexOf(sFindLabelValue.toLowerCase())>-1:false);

                            // koppel de 3 velden (1 AND 2 AND 3)
                            boolean displayLabel = false;
                            if(sFindLabelType.length()>0 && sFindLabelID.length()>0){
                                displayLabel = typeFound && idFound;
                            }
                            else if(sFindLabelType.length()>0){
                                displayLabel = typeFound;
                            }
                            else if(sFindLabelID.length()>0){
                                displayLabel = idFound;
                            }

                            // veld 3
                            if(sFindLabelValue.length()>0){
                                displayLabel = displayLabel && textFound;
                            }

                            // display label row
                            if(displayLabel){
                                validLabelCount++;

                                // alternate row style
                                style = (validLabelCount%2==0?" class='list1'":" class='list'");

                                // red background for invalid key-names
                                checked = "checked";
                                for(int i=0; i<invalidLabelKeyChars.length(); i++){
                                    if(labelUniqueKey.indexOf(invalidLabelKeyChars.charAt(i)) > -1){
                                        style = " style='background:#ff6666';";
                                        invalidLabelCount++;
                                        checked = "";
                                        break;
                                    }
                                }

                                %>
                                    <tr <%=style%> onMouseOver="this.className='list_select';" onMouseOut="this.className='<%=(validLabelCount%2==0?"":"list")%>';">
                                        <td>
                                            <input type="checkbox" id="cb<%=labelCount%>" name="checkbox$<%=labelUniqueKey%>" <%=checked%>>
                                        </td>
                                        <td onclick="setCB('cb<%=labelCount%>');">
                                          TYPE&nbsp;<br>
                                          ID&nbsp;<br>
                                          VALUE&nbsp;
                                        </td>
                                        <td onclick="setCB('cb<%=labelCount%>');">
                                          <%=sLabelType%><br>
                                          <b><%=sLabelID%></b><br>
                                          <%=sLabelValue%>
                                        </td>
                                    </tr>
                                <%

                                style = "";
                            }
                        }
                        else{
                            excludedLabelCount++;
                        }
                    }
                    else{
                        // label with invalid id found
                        Debug.println("\nInvalid type and ID : "+labelUniqueKey);

                        sLabelValue = iniProps.getProperty(labelUniqueKey);

                        labelCount++;
                        invalidLabelCount++;

                        // red background for invalid key-names
                        style = " style='background:#ff6666';";

                        // display label row : checked by default
                        %>
                            <tr <%=style%> onMouseOver="this.className='list_select';" onMouseOut="this.className='<%=(labelCount%2==0?"":"list")%>';">
                                <td>
                                    <input type="checkbox" id="cb<%=labelCount%>" name="checkbox$<%=labelUniqueKey%>" CHECKED>
                                </td>
                                <td onclick="setCB('cb<%=labelCount%>');">
                                  TYPE&nbsp;<br>
                                  ID&nbsp;<br>
                                  VALUE&nbsp;
                                </td>
                                <td onclick="setCB('cb<%=labelCount%>');">
                                  <%=labelUniqueKey%><br>
                                  <b>erroneous labelID !</b><br>
                                  <%=sLabelValue%>
                                </td>
                            </tr>
                        <%
                    }
                }
            }
            catch(Exception e){
                findMsg = "<font color='red'>"+e.getMessage()+"</font>";
            }
        %>
    </table>
    <%
        // message
        if(findMsg.length() > 0){
            %><span><%=findMsg%></span><%
        }
    %>
    <script>
      function setCB(id){
        var cb = document.getElementById(id);

        if(cb.checked==true) cb.checked = false;
        else                 cb.checked = true;
      }
    </script>
    <%-- BUTTONS at BOTTOM ----------------------------------------------------------------------%>
    <table width="100%" cellspacing="1">
        <tr>
            <td>
                <a href="#" onclick="checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                <a href="#" onclick="checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
            </td>
            <td align="right">
                <a href="#topp" class="topbutton">&nbsp;</a>
            </td>
        </tr>
        <%-- BUTTON --%>
        <tr>
            <td colspan="2">
               <input type="button" class="button" name="DeleteButton" value="<%=getTran("Web","Delete",sWebLanguage)%>" onclick="doSubmit('delete')">
            </td>
        </tr>
        <%-- NUMBER OF LABELS FOUND --%>
        <tr>
            <td colspan="2">
                <%=labelCount%> <%=getTran("Web.Manage","labelsSearched",sWebLanguage)%><br>
                <%=validLabelCount%> <%=getTran("Web.Manage","validlabelsFound",sWebLanguage)%><br>
                <%=invalidLabelCount%> <%=getTran("Web.Manage","invalidLabelsFound",sWebLanguage)%><br>
                <%=excludedLabelCount%> <%=getTran("Web.Manage","excludedLabelsFound",sWebLanguage)%>
           </td>
        </tr>
    </table>
    <%
  }
%>
</form>
<%-- link to manage translations --%>
<%=ScreenHelper.alignButtonsStart()%>
    <img src='<c:url value="/_img/pijl.gif"/>'>
    <a class="menuItem" href="<c:url value='/main.do?Page=system/manageTranslations.jsp?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web","managetranslations",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>
<a name="bottom"/>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  function doSubmit(action){
    if(action=="delete"){
      for(i=0; i<transactionForm.elements.length; i++){
        if(transactionForm.elements[i].type=="checkbox" && transactionForm.elements[i].name.indexOf("checkbox$")>-1){
          if(transactionForm.elements[i].checked==true){
            var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
            var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            var answer = window.showModalDialog(popupUrl,'',modalities);

            if(answer==1){
              transactionForm.action.value = action;
              transactionForm.submit();
            }

            break;
          }
        }
      }
    }
    else{
      transactionForm.action.value = action;
      transactionForm.submit();
    }
  }

  function checkAll(setchecked){
    for(i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        transactionForm.elements[i].checked = setchecked;
      }
    }
  }

  function clearFindFields(){
    transactionForm.FindLabelType.value = "";
    transactionForm.FindLabelID.value = "";
    transactionForm.FindLabelText.value = "";
  }
</script>