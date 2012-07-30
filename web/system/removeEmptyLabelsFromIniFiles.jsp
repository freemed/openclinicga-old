<%@page import="java.io.*,java.util.Properties,java.util.Enumeration,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
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
    private Properties getPropertyFile(String sFilename) {
        FileInputStream iniIs = null;
        Properties iniProps = new Properties();

        // create ini file if they do not exist
        try {
            iniIs = new FileInputStream(sAPPFULLDIR + sFilename);
            iniProps.load(iniIs);
            iniIs.close();
        }
        catch (FileNotFoundException e) {
            // create the file
            try {
                new FileOutputStream(sAPPFULLDIR + sFilename);
            }
            catch (Exception e1) {
                if (Debug.enabled) Debug.println(e1.getMessage());
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }

        return iniProps;
    }
%>
<%
  final String INIFILENAMENL = "/_common/xml/Labels.nl.ini";
  final String INIFILENAMEFR = "/_common/xml/Labels.fr.ini";

  String action         = checkString(request.getParameter("action"));
  String sLeaderIniFile = checkString(request.getParameter("LeaderIniFile"));
  if(sLeaderIniFile.length() == 0) sLeaderIniFile = "nl";

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
<%=writeTableHeader("Web.manage","removeSingleLabelsFromIniFiles",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<table width="100%" class="menu" cellspacing="1">
    <%-- LEADER INI FILE --%>
    <tr>
        <td>&nbsp;<%=getTran("Web.Translations","leaderinifile",sWebLanguage)%></td>
        <td>
            <input type="radio" name="LeaderIniFile" id="rbNL" value="nl" <%=sLeaderIniFile.equalsIgnoreCase("nl")?"checked":""%>><label for="rbNL">NL</label>
            <input type="radio" name="LeaderIniFile" id="rbFR" value="fr" <%=sLeaderIniFile.equalsIgnoreCase("fr")?"checked":""%>><label for="rbFR">FR</label>
            &nbsp;&nbsp;&nbsp;
            <%-- buttons --%>
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
        Vector recsToBeDeleted = new Vector();
        String paramName, paramValue;
        String labelTypeAndID = null;

        // PUT ASIDE RECORDS SPECIFIED FOR DELETION IN REQUEST
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            paramName = (String) e.nextElement();
            paramValue = checkString(request.getParameter(paramName));

            if (paramName.startsWith("checkbox$") && paramValue.equals("on")) {
                labelTypeAndID = paramName.substring(9);
                labelTypeAndID = labelTypeAndID.toLowerCase();

                recsToBeDeleted.add(labelTypeAndID);
            }
        }

        // DELETE FROM INI FILES
        Properties iniPropsNL = getPropertyFile(INIFILENAMENL);
        Properties iniPropsFR = getPropertyFile(INIFILENAMEFR);

        // remove specified labels
        String label;
        for (int i = 0; i < recsToBeDeleted.size(); i++) {
            label = (String) recsToBeDeleted.get(i);

            iniPropsNL.remove(label);
            iniPropsFR.remove(label);
        }

        // write NL labels to ini file
        FileOutputStream outputStreamNL = new FileOutputStream(sAPPFULLDIR + INIFILENAMENL);
        iniPropsNL.store(outputStreamNL, "Labels.nl.ini");
        outputStreamNL.close();

        // write FR labels to ini file
        FileOutputStream outputStreamFR = new FileOutputStream(sAPPFULLDIR + INIFILENAMEFR);
        iniPropsFR.store(outputStreamFR, "Labels.fr.ini");
        outputStreamFR.close();

%>
        <br>
        <%=getTran("Web","DataIsDeleted",sWebLanguage)%>
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
        <tr><td width="16"></td><td></td><td width="99%"></td></tr>

        <%
            String sLabelTypeAndID, sLabelType, sLabelID, style = "", checked;
            int labelCount = 0, validLabelCount = 0, invalidLabelCount = 0, excludedLabelCount = 0;

            // load property-objects from ini-files
            Properties iniPropsNL = getPropertyFile(INIFILENAMENL);
            Properties iniPropsFR = getPropertyFile(INIFILENAMEFR);

            // invalid key chars
            String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
            if(invalidLabelKeyChars.length() == 0){
                invalidLabelKeyChars = " /:"; // default
            }

            // select ini file to search on (=leader)
            Enumeration labelEnum;
            if(sLeaderIniFile.equals("fr")) labelEnum = iniPropsFR.propertyNames();
            else                            labelEnum = iniPropsNL.propertyNames();

            // run thru labels in ini file
            while(labelEnum.hasMoreElements()){
                labelCount++;
                sLabelTypeAndID = checkString((String)labelEnum.nextElement());
                //Debug.println("sLabelTypeAndID : "+sLabelTypeAndID);

                // only process labels with a valid id
                if(sLabelTypeAndID.indexOf("$")>0){
                    sLabelType = sLabelTypeAndID.substring(0,sLabelTypeAndID.indexOf("$"));

                    // only process not-excluded labels
                    if(excludedLabelTypes.indexOf(sLabelType.toLowerCase()) < 0){
                        String sLabelTextNL = iniPropsNL.getProperty(sLabelTypeAndID);
                        String sLabelTextFR = iniPropsFR.getProperty(sLabelTypeAndID);

                        if(sLabelTextNL==null) sLabelTextNL = "NULL";
                        if(sLabelTextFR==null) sLabelTextFR = "NULL";

                        // display label row if no label-text found
                        String sLabelText;
                        if(sLeaderIniFile.equals("fr")) sLabelText = sLabelTextNL;
                        else                            sLabelText = sLabelTextFR;

                        if(sLabelText.length()==0 || sLabelText.equals("NULL")){
                            validLabelCount++;

                            // orange background if label only occurs in one of both ini's
                            if(sLabelText.equals("NULL")){
                                style = " style='background:#F88017';"; // orange
                            }

                            // alternate row style (unless orange)
                            if(style.length()==0){
                                style = (validLabelCount%2==0?" class='list1'":" class='list'");
                            }

                            // red background for invalid key-names
                            checked = "checked";
                            for(int i=0; i<invalidLabelKeyChars.length(); i++){
                                if(sLabelTypeAndID.indexOf(invalidLabelKeyChars.charAt(i)) > -1){
                                    style = " style='background:#ff6666';";
                                    invalidLabelCount++;
                                    checked = "";
                                    break;
                                }
                            }

                            sLabelID = sLabelTypeAndID.substring(sLabelTypeAndID.indexOf("$")+1);

                            %>
                                <tr <%=style%> >
                                    <td>
                                        <input type="checkbox" id="cb<%=labelCount%>" name="checkbox$<%=sLabelTypeAndID%>" <%=checked%>>
                                    </td>
                                    <td onclick="setCB('cb<%=labelCount%>');">
                                        TYPE&nbsp;<br>
                                        ID&nbsp;<br>
                                        NL&nbsp;<br>
                                        FR&nbsp;
                                    </td>
                                    <td onclick="setCB('cb<%=labelCount%>');">
                                        <%=sLabelType%><br>
                                        <b><%=sLabelID%></b><br>
                                        <%=(sLabelTextNL.length()==0?"<font color='red'><i>EMPTY</i></font>":sLabelTextNL)%><br>
                                        <%=(sLabelTextFR.length()==0?"<font color='red'><i>EMPTY</i></font>":sLabelTextFR)%>
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
                    Debug.println("\nInvalid type and ID : "+sLabelTypeAndID);

                    String sLabelTextNL = iniPropsNL.getProperty(sLabelTypeAndID);
                    String sLabelTextFR = iniPropsFR.getProperty(sLabelTypeAndID);

                    Debug.println("* NL : "+sLabelTextNL);
                    Debug.println("* FR : "+sLabelTextFR);

                    sLabelTextNL = iniPropsNL.getProperty(sLabelTypeAndID);
                    sLabelTextFR = iniPropsFR.getProperty(sLabelTypeAndID);

                    labelCount++;
                    invalidLabelCount++;

                    // red background for invalid key-names
                    style = " style='background:#ff6666';";

                    // display label row : checked by default
                    %>
                        <tr <%=style%> >
                            <td>
                                <input type="checkbox" id="cb<%=labelCount%>" name="checkbox$<%=sLabelTypeAndID%>" CHECKED>
                            </td>
                            <td onclick="setCB('cb<%=labelCount%>');">
                                TYPE&nbsp;<br>
                                ID&nbsp;<br>
                                NL&nbsp;<br>
                                FR&nbsp;
                            </td>
                            <td onclick="setCB('cb<%=labelCount%>');">
                                <%=sLabelTypeAndID%><br>
                                <b>erroneous labelID !</b><br>
                                <%=sLabelTextNL%><br>
                                <%=sLabelTextFR%>
                            </td>
                        </tr>
                    <%
                }
            }
        %>
    </table>
    <script>
      function setCB(id){
        var cb = document.getElementById(id);
        if(cb.checked==true) cb.checked = false;
        else                 cb.checked = true;
      }
    </script>
    <%-- BUTTONS at BOTTOM -----------------------------------------------------------------------%>
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
    <a class="menuItem" href="<c:url value='/main.do'/>?Page=system/manageTranslations.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web","managetranslations",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>
<a name="bottom"/>
<%-- SCRIPTS -------------------------------------------------------------------------------------%>
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