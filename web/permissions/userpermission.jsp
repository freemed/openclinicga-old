<%@page import="be.openclinic.finance.Wicket,
                org.dom4j.DocumentException,java.sql.Connection" %>
<%@page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>


<%!
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public String writeRow(String sScreenID, String sPermission, String sValue, Connection dbConnection, String sMyProfile) {
        String sClass = "";

        //try {
        if (sMyProfile.trim().length() > 0) {
            boolean bActive = UserProfilePermission.activeUserProfilePermissions(sMyProfile, sScreenID.toLowerCase(), sPermission.toLowerCase());
            if (bActive) {
                sClass = " style='background-color:" + sBackgroundColor + "'";
            }
        }

        String sReturn = "<td" + sClass;
        if (sPermission.equalsIgnoreCase("motivation")) {
            sReturn += " colspan='2'";
        }

        return sReturn + "><input type='checkbox' name='" + sScreenID + "." + sPermission + "' " + sValue + " onClick=\"uncheckRowSelector('" + sScreenID + "');\"></td>";
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    private String writeMyCheckbox(String sLabel, String sName, String sPermission, User thisUser) {
        String sChecked = "";

        if (sPermission.trim().length() > 0) {
            String sValue = thisUser.getParameter(sPermission);
            if (sValue.length() > 0) {
                sChecked = " checked";
            }
        }

        return "<tr><td class='admin'>" + sLabel + "</td><td class='admin2'><input type='checkbox' name='" + sName + "'" + sChecked + "></td></tr>";
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    private String writeDefaultWicket(String sDefaultWicket, String sWebLanguage) {
        String sTmp;
        Vector vWickets = Wicket.selectWickets();
        Iterator iter = vWickets.iterator();

        StringBuffer sOut = new StringBuffer();
        Wicket wicket;
        while (iter.hasNext()) {
            wicket = (Wicket) iter.next();
            if (sDefaultWicket.equals(wicket.getUid())) {
                sTmp = " selected";
            } else {
                sTmp = "";
            }
            sOut.append("<option value='" + wicket.getUid() + "'" + sTmp + ">" + wicket.getUid() + "&nbsp;" + getTran("service", wicket.getServiceUID(), sWebLanguage));
        }

        return sOut.toString();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    private String writeMyInput(String sLabel, String sName, User thisUser) {
        String sValue = " value='" + thisUser.getParameter(sName.substring(4)).trim() + "'";

        return "<tr>" +
                " <td class='admin'>" + sLabel + "</td>" +
                " <td class='admin2'>" +
                "  <input type='text' class='text' name='" + sName + "'" + sValue + ">" +
                " </td>" +
                "</tr>";
    }
%>

<%
    String sDefaultPage, sDefaultWicket, sMyProfile, sProfiles = "", sTmpProfileID, sTmpProfileName,
           sPasswordString = "", sMyProjects = "", sTmpProject;
    String sProjectAccessAllSites = MedwanQuery.getInstance().getConfigString("ProjectAccessAllSites");
    String sAction = checkString(request.getParameter("Action"));

    /*
    String sSearchProfileID = checkString(request.getParameter("EditUserProfileID"));
    if (request.getParameter("EditresetPage")!=null && request.getParameter("EditresetPage").equalsIgnoreCase("yes")){
        sSearchProfileID = "";
    }
    */

    String sSearchProject = checkString(request.getParameter("EditUserProject"));
    if (sSearchProject.length() == 0) {
        sSearchProject = sAPPTITLE;
    }

    // initialize user
    User thisUser = new User();
    Vector vUsers = User.getUsersByPersonId(activePatient.personid);
    Iterator iter = vUsers.iterator();

    User user;
    String sss=null;;
    while (iter.hasNext()) {
        user = (User) iter.next();

        sTmpProject = checkString(user.project);
        sMyProjects += sTmpProject + ",";

        if ((sTmpProject.equalsIgnoreCase(sSearchProject)) || (sTmpProject.equalsIgnoreCase(sProjectAccessAllSites))) {
            thisUser.personid = activePatient.personid;
            thisUser.userid = checkString(user.userid);
            thisUser.password = user.password;
            thisUser.start = user.start;
            thisUser.stop = user.stop;
            thisUser.project = sTmpProject;

          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            thisUser.initialize(ad_conn, thisUser.userid, thisUser.password);
            ad_conn.close();
        }
    }

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save")) {
        thisUser.clearAccessRights();
        String sDefaultPassword = sSearchProject.toLowerCase();
        Enumeration e = request.getParameterNames();
        Parameter parameter;
        String sName, sValue;
        Vector vOtherUserParams = new Vector();

        // first keep only the user parameters that are not managed on this page
        for (int i = 0; i < thisUser.parameters.size(); i++) {
            parameter = (Parameter) thisUser.parameters.elementAt(i);

            // these are the user parameters that are managed on this page
            if ((parameter.parameter.equalsIgnoreCase("mailuser"))
                || (parameter.parameter.equalsIgnoreCase("mailpassword"))
                || (parameter.parameter.equalsIgnoreCase("defaultpage"))
                || (parameter.parameter.equalsIgnoreCase("defaultwicket"))
                || (parameter.parameter.equalsIgnoreCase("organisationid"))
                || (parameter.parameter.equalsIgnoreCase("medicalcentercode"))
                || (parameter.parameter.equalsIgnoreCase("defaultserviceid"))
                || (parameter.parameter.equalsIgnoreCase("userprofileid"))
                || (parameter.parameter.equalsIgnoreCase("stop"))
                || (parameter.parameter.equalsIgnoreCase("sa"))
                || (parameter.parameter.equalsIgnoreCase("clearpassword"))
                || (parameter.parameter.equalsIgnoreCase("invoicingcareprovider"))
                || (parameter.parameter.equalsIgnoreCase("computernumber"))) {
                // nothing
            }
            // user parameters that are not managed on this page
            else {
                vOtherUserParams.add(parameter);
            }
        }

        thisUser.parameters.clear();
        thisUser.parameters = vOtherUserParams;

        // add the user parameters managed on this page if they are specified
        while (e.hasMoreElements()) {
            sName = checkString((String) e.nextElement());
            sValue = checkString(request.getParameter(sName)).toLowerCase();
            sName = sName.toLowerCase();

            if ((sValue.length() > 0) && (sName.startsWith("edit"))) {
                parameter = new Parameter(sName.substring(4), sValue);
                thisUser.parameters.add(parameter);
            }
        }

        // stop
        if (thisUser.getParameter("stop").length() > 0) {
            thisUser.password = null;
            thisUser.stop = getDate();
        }
        else {
            if ((thisUser.userid.trim().length() > 0) && (thisUser.password != null) && (thisUser.password.length > 0)) {
                // everything is ok
            }
            else {
                thisUser.password = thisUser.encrypt(sDefaultPassword);
                thisUser.start = getDate();
                thisUser.stop = "";
                sPasswordString = " Password = " + sDefaultPassword;
                if (!thisUser.project.equals(sProjectAccessAllSites)) {
                    thisUser.project = sSearchProject;
                }
            }
        }

        // clearpassword
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        if (thisUser.getParameter("clearpassword").length() > 0) {
            thisUser.password = thisUser.encrypt(sDefaultPassword);
            sPasswordString = "Password = " + sDefaultPassword;
            thisUser.removeParameter("clearpassword", ad_conn);
        }

        // save
        if (thisUser.personid == null || thisUser.personid.length() == 0) {
            thisUser.personid = activePatient.personid;
        }
        activePatient.language=request.getParameter("ChangeLanguage");
        activePatient.store();

        // SAVE TO DB
        if (thisUser.saveToDB(ad_conn)) {
            if (thisUser.userid.equals(activeUser.userid)) {
                session.setAttribute("activeUser", thisUser);
            }

            if (sPasswordString.trim().length() > 0) {
                %>
                    <br>
                    Login = <%=thisUser.userid%>
                    <br>
                    <%=sPasswordString%>
                    <br>
                    Project = <%=sSearchProject%>
                    <br><br>
                    <input type="button" class="button" value=" OK " onclick="window.location.href='main.do?Page=permissions/index.jsp'">
                <%
            }
            else {
                ScreenHelper.setIncludePage("index.jsp", pageContext);
            }
        }
        ad_conn.close();
    }
    //--- ANY OTHER ACTION ------------------------------------------------------------------------
    else {
        sMyProfile = thisUser.getParameter("userprofileid");
        String sMyProfileDescription = "";

        // populate profiles
        Vector vProfiles = UserProfile.getUserProfiles();
        Iterator iterator = vProfiles.iterator();

        UserProfile userProfile;
        while(iterator.hasNext()){
            userProfile = (UserProfile)iterator.next();
            sTmpProfileID = Integer.toString(userProfile.getUserprofileid());
            sTmpProfileName = userProfile.getUserprofilename();

            sProfiles += "<option value='" + sTmpProfileID + "'";
            if (sMyProfile.equals(sTmpProfileID)) {
                sProfiles += " selected style='background-color:" + sBackgroundColor + "' ";
            }

            if (sMyProfile.equals(sTmpProfileID)) {
                sMyProfileDescription = "(" + sTmpProfileName + ")";
            }

            sProfiles += ">" + sTmpProfileName + "</option>";
        }

        // Defaultpage
        sDefaultPage = checkString(thisUser.getParameter("defaultpage"));
        sDefaultWicket = checkString(thisUser.getParameter("defaultwicket"));

        // Projects
        String sAvailabelProjects = MedwanQuery.getInstance().getConfigString("availableProjects");
        String sProjects = "";
        if ((sAvailabelProjects == null) || (sAvailabelProjects.trim().length() == 0)) {
            sProjects = sSearchProject;
        }
        else {
            String[] aProjects = sAvailabelProjects.split(",");
            SortedSet set = new TreeSet();

            for (int i = 0; i < aProjects.length; i++) {
                set.add(aProjects[i]);
            }

            Iterator it = set.iterator();
            while (it.hasNext()) {
                sTmpProject = (String) it.next();
                sProjects += "<option value='" + sTmpProject + "'";

                if (sTmpProject.equalsIgnoreCase(sSearchProject)) {
                    sProjects += " selected";
                }

                if (sMyProjects.toLowerCase().indexOf(sTmpProject.toLowerCase()) > -1) {
                    sProjects += " style='background-color:" + sBackgroundColor + "' ";
                }

                sProjects += ">" + sTmpProject + "</option>";
            }

            if (sAvailabelProjects.toLowerCase().indexOf(sProjectAccessAllSites.toLowerCase()) < 0 && sProjectAccessAllSites.toLowerCase().equals(thisUser.project.toLowerCase())) {
                sProjects = "<option value='" + sProjectAccessAllSites + "' selected>" + sProjectAccessAllSites + "</option>";
            }
        }

    %>
        <form name="transactionForm" id="transactionForm" method="post" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
            <input type="hidden" name="resetPage" value="no"/>
            <input type="hidden" name="Action"/>

            <%-- SEARCH TABLE -------------------------------------------------------------------%>
            <table width='100%' class="menu" cellspacing="1" cellpadding="0">
                <tr class="admin">
                    <td colspan="2">
                        <table width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                                <td><%=(getTran("Web.Permissions","PermissionsFor",sWebLanguage)+" "+activePatient.lastname+" "+activePatient.firstname+" &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Login: "+thisUser.userid+" "+sPasswordString)%></td>
                                <td align="right">
                                    <img onmouseover="this.style.cursor='hand'" onmouseout="this.style.cursor='default'" onClick="doBack();" style="vertical-align:-2px;" border="0" src="<%=sCONTEXTPATH%>/_img/arrow.jpg" alt="<%=getTran("Web","Back",sWebLanguage)%>">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <%-- user project --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Applications",sWebLanguage)%></td>
                    <td class="admin2">
                        <select name="EditUserProject" class="text"><%=sProjects%></select>
                        <%=sMyProfileDescription%>
                    </td>
                </tr>

                <%-- profile id --%>
                <tr>
                    <td class="admin"><%=getTran("Web.UserProfile","UserProfile",sWebLanguage)%></td>
                    <td class="admin2">
                        <select name="EditUserProfileID" class="text"><%=sProfiles%></select>
                    </td>
                </tr>

                <%-- default page --%>
                <tr>
                    <td class="admin"><%=getTran("Web.UserProfile","DefaultPage",sWebLanguage)%></td>
                    <td class="admin2">
                        <select name='EditDefaultPage' class="text">
                            <option/>
                            <%
                                String sSelected = sDefaultPage;

                                SAXReader xmlReader = new SAXReader();
                                String sDefaultPageXML = MedwanQuery.getInstance().getConfigString("templateSource")+ "defaultPages.xml";
                                Document documentPages;

                                String sType, setSelected = "";

                                try {
                                    documentPages = xmlReader.read(new URL(sDefaultPageXML));
                                    if (documentPages != null) {
                                        Element root = documentPages.getRootElement();
                                        if (root != null) {
                                            Element ePage;
                                            Iterator elements = root.elementIterator("defaultPage");

                                            while (elements.hasNext()) {
                                                ePage = (Element) elements.next();
                                                sType = checkString(ePage.attributeValue("type")).toLowerCase();

                                                if (sType.equals(sSelected)) {
                                                    setSelected = " selected";
                                                }
                                                else {
                                                    setSelected = "";
                                                }

                                                out.print("<option value=\"" + sType + "\"" + setSelected + ">" + getTranNoLink("defaultPage", sType, sWebLanguage) + "</option>");
                                            }
                                        }
                                    }
                                    else {
                                        out.print("<option value='administration'" + setSelected + ">" + getTranNoLink("defaultPage", "administratioon", sWebLanguage) + "</option>");
                                    }
                                }
                                catch (DocumentException e) {
                                    out.print("<option value='administration'" + setSelected + ">" + getTranNoLink("defaultPage", "administratioon", sWebLanguage) + "</option>");
                                    //e.printStackTrace();
                                }
                            %>
                        </select>
                    </td>
                </tr>

                <%-- default wicket --%>
                <tr>
                    <td class="admin"><%=getTran("Web.UserProfile","DefaultWicket",sWebLanguage)%></td>
                    <td class="admin2">
                        <select name='EditDefaultWicket' class='text'>
                            <option/>
                            <%=writeDefaultWicket(sDefaultWicket,sWebLanguage)%>
                        </select>
                    </td>
                </tr>

                <%=writeMyCheckbox(getTran("Web.Permissions","SA",sWebLanguage),"EditSA", "sa", thisUser)%>
                <%=writeMyCheckbox(getTran("Web.Permissions","ClearPassword",sWebLanguage),"EditClearPassword", "", thisUser)%>
                <%=writeMyInput(getTran("Web.UserProfile","organisationId",sWebLanguage),"Editorganisationid", thisUser)%>

                <%-- medicalCenterCode --%>
                <tr>
                    <td class="admin"><%=getTran("Web.UserProfile","medicalCenterCode",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type='text' class='text' name='Editmedicalcentercode' value='<%=thisUser.getParameter("medicalcentercode").trim()%>' onKeyUp='isNumberLimited(this,0,99999);lookupMedicalCenter();' onBlur="checkMedicalCenterLength();">
                        <span id="medicalCenterMsg"></span>
                    </td>
                </tr>
                <tr>
                    <td class="admin">
                        <%=getTran("web","service",sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <%
                            String serviceText="";
                            if(thisUser.getParameter("defaultserviceid").length()>0){
                                serviceText=MedwanQuery.getInstance().getService(thisUser.getParameter("defaultserviceid")).getLabel(sWebLanguage);
                            }
                        %>
                        <input class='text' TYPE="text" NAME="serviceText" readonly size="49" TITLE="<%=serviceText%>" VALUE="<%=serviceText%>" onkeydown="window.event.keyCode = '';return true;">
                        <%
                            if(thisUser.getParameter("defaultserviceid").length()>0){
                                %>
                                    <img src="<c:url value='/_img/icon_info.gif'/>" class="link" alt="<%=getTran("Web","Information",sWebLanguage)%>" onclick='searchInfoService(transactionForm.EditDefaultServiceid)'/>
                                <%
                            }
                        %>
                        <%=ScreenHelper.writeServiceButton("buttonUnit", "EditDefaultServiceid", "serviceText", sWebLanguage, sCONTEXTPATH)%>
                        <input TYPE="hidden" NAME="EditDefaultServiceid" VALUE="<%=thisUser.getParameter("defaultserviceid")%>">
                    </td>
                </tr>
                 <tr>
                     <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("Web","language",sWebLanguage)%></td>
                     <td class="admin2">
                         <select name="ChangeLanguage" class="text">
                             <%
                                 // supported languages
                                 String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                                 if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";

                                 String tmpLang;
                                 StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                                 while (tokenizer.hasMoreTokens()) {
                                     tmpLang = tokenizer.nextToken();

                             %><option value="<%=tmpLang%>" <%=(activePatient.language.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                                 }
                             %>
                         </select>
                     </td>
                    </tr>
                <%=writeMyInput(getTran("Web.UserProfile","computerNumber",sWebLanguage),"Editcomputernumber", thisUser)%>
                <%=writeMyCheckbox(getTran("web","isinvoicingcareprovider",sWebLanguage),"EditInvoicingCareProvider", "invoicingcareprovider", thisUser)%>
                <%=writeMyCheckbox("Stop","EditStop", "stop", thisUser)%>
            </table>

            <%-- BUTTONS --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" name="saveButton" id="saveButton" value="<%=getTran("Web","Save",sWebLanguage)%>" onClick="doSave();">&nbsp;
                <input type="button" class="button" value='<%=getTran("Web","Back",sWebLanguage)%>' onClick='doBack();'>
            <%=ScreenHelper.alignButtonsStop()%>
        </form>

        <script>
          function searchInfoService(sObject){
              if(sObject.value.length > 0){
                openPopup("/_common/search/serviceInformation.jsp&ServiceID="+sObject.value);
              }
          }          <%-- DO SAVE --%>

          function doSave(){
            var medicalCenterOK = checkMedicalCenterLength();

            if(medicalCenterOK){
              transactionForm.Action.value = "save";
              transactionForm.submit();
            }
            else{
              transactionForm.Editmedicalcentercode.focus();
            }
          }

          <%-- LOOK UP MEDICAL CENTER --%>
          function lookupMedicalCenter(){
            if(transactionForm.Editmedicalcentercode.value.length == 5){
              openPopup("/_common/search/blurMedicalCenter.jsp&SearchCode="+transactionForm.Editmedicalcentercode.value+"&SourceVar=medicalcentercode&MsgVar=medicalCenterMsg");
            }
          }

          <%-- CHECK MEDICAL CENTER LENGTH --%>
          function checkMedicalCenterLength(){
            if(transactionForm.Editmedicalcentercode.value.length > 0){
              if(transactionForm.Editmedicalcentercode.value.length == 5){
                return true;
              }
              else{
                transactionForm.Editmedicalcentercode.focus();
                document.getElementById('medicalCenterMsg').innerHTML = '<%=getTran("web.manage","invalidmedicalcentercode",sWebLanguage)%>';
                document.getElementById('medicalCenterMsg').style.color = 'red';
                return false;
              }
            }
            document.getElementById('medicalCenterMsg').innerHTML = '';
            return true;
          }

          if(transactionForm.Editmedicalcentercode.value.length > 0){
            lookupMedicalCenter();
          }

          <%-- DO BACK  --%>
          function doBack(){
            if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
              window.location.href = "./main.do?Page=permissions/index.jsp";
            }
          }
        </script>

        <%=writeJSButtons("transactionForm","saveButton")%>
        <%
    }
%>