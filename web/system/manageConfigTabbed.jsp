<%@page import="be.openclinic.system.Config"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Enumeration" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%!
    //--- GET VALUE FROM DB ------------------------------------------------------------------------
    private String[] getValueFromDB(String keyName){
        Config objConfig = Config.getConfig(keyName);
        if(objConfig.getOc_value()!= null && objConfig.getDefaultvalue() != null){
            String sValue = checkString(objConfig.getOc_value().toString());
            String sStdvalue = objConfig.getDefaultvalue();

            return new String[]{sValue,sStdvalue};
        }else{
            return null;
        }
    }

    //--- WRITE HEADER -----------------------------------------------------------------------------
    private String writeHeader(String sWebLanguage){
        StringBuffer out = new StringBuffer();

        out.append("<tr class='admin'>")
           .append(" <td nowrap>"+getTran("web.manage.config","Key",sWebLanguage)+"</td>")
           .append(" <td >"+getTran("web","value",sWebLanguage)+"</td>")
           .append(" <td >"+getTran("web.manage.config","defaultvalue",sWebLanguage)+"</td>")
           .append("</tr>");

        return out.toString();
    }

    //--- WRITE TEXTFIELD --------------------------------------------------------------------------
    private String writeTextfield(String keyName){
        StringBuffer out = new StringBuffer();
        String values[] = getValueFromDB(keyName);
        if(values != null){
            out.append("<tr>")
               .append(" <td class='admin'>"+keyName+"&nbsp;</td>")
               .append(" <td class='admin2'>")
               .append("  <input type='text' class='text' name='value_"+keyName+"' size='80' onKeyUp='limitChars(this,255);' value='"+values[0]+"'>")
               .append(" </td>")
               .append(" <td class='admin2'>").append(values[1]).append("</td>")
               .append("</tr>");
        }
        return out.toString();
    }

    //--- WRITE TEXTFIELD --------------------------------------------------------------------------
    private String writeTextfield(String keyName, String defaultValue){
        StringBuffer out = new StringBuffer();
        String values[] = getValueFromDB(keyName);
        if(values == null){
        	values=new String[2];
        	values[0]="";
        	values[1]=defaultValue;
        }
        out.append("<tr>")
           .append(" <td class='admin'>"+keyName+"&nbsp;</td>")
           .append(" <td class='admin2'>")
           .append("  <input type='text' class='text' name='value_"+keyName+"' size='80' onKeyUp='limitChars(this,255);' value='"+values[0]+"'>")
           .append(" </td>")
           .append(" <td class='admin2'>").append(values[1]).append("</td>")
           .append("</tr>");
        return out.toString();
    }

    //--- WRITE NUMBERFIELD ------------------------------------------------------------------------
    private String writeNumberfield(String keyName){
        StringBuffer out = new StringBuffer();
        String values[] = getValueFromDB(keyName);

        out.append("<tr>")
           //.append("  <td class='admin'><a href=\"javascript:showDetails('"+keyName+"');\">"+keyName+"</a></td>")
           .append("  <td class='admin'>"+keyName+"&nbsp;</td>")
           .append("  <td class='admin2'>")
           .append("    <input type='text' class='text' name='value_"+keyName+"' size='5' maxLength='5' onBlur='isNumber(this);' value='"+values[0]+"'>")
           .append("  </td>")
           .append("  <td class='admin2'>").append(values[1]).append("</td>")
           .append("</tr>");

        return out.toString();
    }

    //--- WRITE RADIO ------------------------------------------------------------------------------
    private String writeRadio(String keyName, String triggerValueOn, String triggerValueOff, String sWebLanguage){
        String values[] = getValueFromDB(keyName);

        StringBuffer out = new StringBuffer();
        out.append("<tr>")
           .append(" <td class='admin'>"+keyName+"&nbsp;</td>")
           .append(" <td class='admin2'>")
           .append("  <input type='radio' class='radio' name='value_"+keyName+"' id='"+keyName+"_on'  value='"+triggerValueOn+"' "+(values[0].equalsIgnoreCase(triggerValueOn)?"CHECKED":"")+">").append(getLabel("web","yes",sWebLanguage,keyName+"_on"))
           .append("  <input type='radio' class='radio' name='value_"+keyName+"' id='"+keyName+"_off' value='"+triggerValueOff+"' "+(values[0].equalsIgnoreCase(triggerValueOn)?"":"CHECKED")+">").append(getLabel("web","no",sWebLanguage,keyName+"_off"))
           .append("  &nbsp;("+values[0]+")")
           .append(" </td>")
           .append(" <td class='admin2'>").append(values[1]).append("</td>")
           .append("</tr>");

        return out.toString();
    }
%>

<%
    String sActiveTab = checkString(request.getParameter("ActiveTab"));
    if (sActiveTab.length() == 0) sActiveTab = "tab0";

    String sAction = checkString(request.getParameter("Action"));

    Vector focusFields = new Vector();

    //--- SAVE -------------------------------------------------------------------------------------
    if (sAction.equals("Save")) {
        // save parameters which name is starting with "value_"
        Enumeration e = request.getParameterNames();
        String sParamName;

        while (e.hasMoreElements()) {
            sParamName = (String) e.nextElement();
            if (sParamName.startsWith("value_")) {

                // check existence
                boolean bExist = Config.exists(sParamName.substring(6));

                //*** INSERT ****************************************
                if (!bExist) {
                    Config objConfig = new Config();
                    objConfig.setOc_key(sParamName.substring(6));
                    objConfig.setOc_value(new StringBuffer(request.getParameter(sParamName)));
                    objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
                    objConfig.setUpdatetime(getSQLTime());
                    objConfig.setComment(new StringBuffer(""));
                    objConfig.setDefaultvalue("");
                    objConfig.setOverride(1);
                    objConfig.setSql_value(new StringBuffer(""));
                    objConfig.setDeletetime(null);


                    Config.addConfig(objConfig);
                }
                //*** UPDATE ****************************************
                else {
                    Config objConfig = Config.getConfig(sParamName.substring(6));

                    objConfig.setOc_value(new StringBuffer(ScreenHelper.checkString(request.getParameter(sParamName))));
                    objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
                    objConfig.setUpdatetime(ScreenHelper.getSQLTime());

                    Config.saveConfig(objConfig);
                }
            }
        }
        MedwanQuery.getInstance().reloadConfigValues();
    }
%>

<form name="configForm" method="post">
    <input type="hidden" name="Action">
    <input type="hidden" name="ActiveTab" value="<%=sActiveTab%>">

    <div>
        <%-- HEADER WITH TABS-LINKS --------------------------------------------------------------%>
        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td style='border-bottom:1px solid black;' width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab0')" id="tab0-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.miscelaneous",sWebLanguage)%></b>&nbsp;</td>
                <td style='border-bottom:1px solid black;' width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab1')" id="tab1-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.devices",sWebLanguage)%></b>&nbsp;</td>
                <td style='border-bottom:1px solid black;' width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab2')" id="tab2-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.email",sWebLanguage)%></b>&nbsp;</td>
                <td style="border-bottom:1px solid black;" width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab3')" id="tab3-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.pwd",sWebLanguage)%></b>&nbsp;</td>
                <td style="border-bottom:1px solid black;" width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab4')" id="tab4-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.fusion",sWebLanguage)%></b>&nbsp;</td>
                <td style="border-bottom:1px solid black;" width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab5')" id="tab5-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.intrusion",sWebLanguage)%></b>&nbsp;</td>
                <td style="border-bottom:1px solid black;" width="1%">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab('tab6')" id="tab6-selector" nowrap>&nbsp;<b><%=getTran("web.config","tab.notifier",sWebLanguage)%></b>&nbsp;</td>
                <td style="border-bottom:1px solid black;" width="*">&nbsp;</td>
                <% int numberOfTabs = 7; %>
            </tr>
        </table>

        <%-- TAB_BODIES --------------------------------------------------------------------------%>
        <table style="vertical-align:top;" width="100%" border="0" cellspacing="0">
            <tr id="tab0-body" style="display:none">
                <td>
                    <%-- MISCELANEOUS --------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeTextfield("admindbName")%>
                        <%=writeTextfield("availableProjects")%>
                        <%=writeRadio("BackButtonDisabled","true","",sWebLanguage)%>
                        <%=writeTextfield("checkLinks")%>
                        <%=writeTextfield("control_Input_A_days")%>
                        <%=writeTextfield("ControlCertificateDiagnoses")%>
                        <%=writeTextfield("dateColumn")%>
                        <%=writeRadio("Debug","on","",sWebLanguage)%>
                        <%=writeTextfield("DefaultCountry")%>
                        <%=writeTextfield("DefaultSupportService")%>
                        <%=writeNumberfield("DefaultTimeOutInSeconds")%>
                        <%=writeNumberfield("MinimumTimeoutInSeconds")%>
                        <%=writeNumberfield("MaximumTimeoutInSeconds")%>
                        <%=writeTextfield("DocumentsFolder")%>
                        <%=writeRadio("doNotAskForContext","on","",sWebLanguage)%>
                        <%=writeRadio("doNotSyncDataToClient","1","",sWebLanguage)%>
                        <%=writeRadio("enableICD10","1","",sWebLanguage)%>
                        <%=writeTextfield("excludedLabelTypes")%>
                        <%=writeTextfield("exportDirectory")%>
                        <%=writeRadio("exportEnabled","1","",sWebLanguage)%>
                        <%=writeRadio("fillUpSearchScreens","on","",sWebLanguage)%>
                        <%=writeRadio("fillUpSearchServiceScreens","on","",sWebLanguage)%>
                        <%=writeTextfield("HelpFile")%>
                        <%=writeTextfield("importProgramDirectory")%>
                        <%=writeTextfield("importProgramExecutable")%>
                        <%=writeTextfield("invalidLabelKeyChars")%>
                        <%=writeTextfield("lowerCompare")%>
                        <%=writeRadio("masterEnabled","1","0",sWebLanguage)%>
                        <%=writeRadio("enableProductionWarning","1","0",sWebLanguage)%>
                        <%=writeNumberfield("maxSelectedLabAnalyses")%>
                        <%=writeNumberfield("maxValueY_respi")%>
                        <%=writeTextfield("MenuXMLFile")%>
                        <%=writeRadio("MER_CheckPeriod","on","",sWebLanguage)%>
                        <%=writeNumberfield("numberOfTransToListInSummary")%>
                        <%=writeTextfield("otherVaccinations")%>
                        <%=writeTextfield("PatientEditSourceID")%>
                        <%=writeRadio("printImmatOldOnMER","on","",sWebLanguage)%>
                        <%=writeTextfield("ProjectAccessAllSites")%>
                        <%=writeTextfield("securePorts")%>
                        <%=writeTextfield("serverId")%>
                        <%=writeRadio("showAdminInTitleBar","on","",sWebLanguage)%>
                        <%=writeRadio("showChildServices","true","",sWebLanguage)%>
                        <%=writeRadio("showLinkNoTranslation","on","",sWebLanguage)%>
                        <%=writeRadio("showServiceInPatientList","on","",sWebLanguage)%>
                        <%=writeTextfield("showUnitID")%>
                        <%=writeTextfield("templateSource")%>
                        <%=writeTextfield("templateDirectory")%>
                        <%=writeRadio("TestEdition","1","",sWebLanguage)%>
                        <%=writeTextfield("timeStamp")%>
                        <%=writeTextfield("valueColumn")%>
                        <%=writeTextfield("supportedLanguages")%>
                        <%=writeTextfield("mxsref")%>

                        <% focusFields.add("admindbName"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab1-body" style="display:none">
                <td>
                    <%-- DEVICES -------------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeTextfield("spiroBankDirectory")%>
                        <%=writeRadio("spiroBankEnabled","1","",sWebLanguage)%>
                        <%=writeTextfield("spiroBankExecutable")%>
                        <%=writeTextfield("spiroBankIn")%>
                        <%=writeTextfield("spiroBankOut")%>

                        <% focusFields.add("spiroBankDirectory"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab2-body" style="display:none">
                <td>
                    <%-- EMAIL ---------------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeTextfield("ControlCertificateDiagnosesEmail")%>
                        <%=writeTextfield("DefaultFromMailAddress")%>
                        <%=writeTextfield("DefaultMailServerAddress")%>
                        <%=writeTextfield("MailProgram")%>
                        <%=writeTextfield("PatientEdit.MailAddressee")%>
                        <%=writeTextfield("PatientEdit.MailSender")%>
                        <%=writeTextfield("PatientEdit.MailServer")%>
                        <%=writeTextfield("Recruitment.ExaminationCertificate.MailAddressee")%>
                        <%=writeTextfield("spdSendMailCommand")%>

                        <% focusFields.add("ControlCertificateDiagnosesEmail"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab3-body" style="display:none">
                <td>
                    <%-- PWD -----------------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeNumberfield("PasswordAvailability")%>
                        <%=writeNumberfield("PasswordMinimumCharacters")%>
                        <%=writeNumberfield("PasswordNoticeTime")%>
                        <%=writeNumberfield("PasswordNotReusablePasswords")%>
                        
                        <%=writeRadio("PasswordObligedLetters","on","",sWebLanguage)%>
                        <%=writeRadio("PasswordObligedLowerCase","on","",sWebLanguage)%>
                        <%=writeRadio("PasswordObligedNumbers","on","",sWebLanguage)%>
                        <%=writeRadio("PasswordObligedUppercase","on","",sWebLanguage)%>
                        <%=writeRadio("PasswordObligedAlfanumerics","on","",sWebLanguage)%>

                        <% focusFields.add("PasswordAvailability"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab4-body" style="display:none">
                <td>
                    <%-- FUSION --------------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeTextfield("tmpDir")%>
                        <%=writeTextfield("tmpDirectory")%>

                        <% focusFields.add("tmpDir"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab5-body" style="display:none">
                <td>
                    <%-- INTRUSION -----------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeNumberfield("IPIntrusion_MaxIntrusionsAllowedAtLevel1")%>
                        <%=writeNumberfield("IPIntrusion_MaxIntrusionsAllowedAtLevel2")%>
                        <%=writeNumberfield("IPIntrusion_MaxIntrusionsAllowedAtLevel3")%>
                        <%=writeNumberfield("IPIntrusion_BlockTimeLevel1")%>
                        <%=writeNumberfield("IPIntrusion_BlockTimeLevel2")%>

                        <%=writeNumberfield("LoginIntrusion_MaxIntrusionsAllowedAtLevel1")%>
                        <%=writeNumberfield("LoginIntrusion_MaxIntrusionsAllowedAtLevel2")%>
                        <%=writeNumberfield("LoginIntrusion_MaxIntrusionsAllowedAtLevel3")%>
                        <%=writeNumberfield("LoginIntrusion_BlockTimeLevel1")%>
                        <%=writeNumberfield("LoginIntrusion_BlockTimeLevel2")%>

                        <%=writeTextfield("Intrusion_BlockPage")%>

                        <% focusFields.add("IPIntrusion_MaxIntrusionsAllowedAtLevel1"); %>
                    </table>
                </td>
            </tr>

            <tr id="tab6-body" style="display:none">
                <td>
                    <%-- INTRUSION -----------------------------------------------%>
                    <table width="100%" cellspacing="1" class="list">
                        <%=writeHeader(sWebLanguage)%>

                        <%=writeTextfield("lastNotifiedLabResult","")%>
                        <%=writeTextfield("defaultBrokerLanguage",sWebLanguage)%>
                        <%=writeTextfield("labNotifierEmailSender","frank.verbeke@mxs.be")%>
                        <%=writeTextfield("smsPincode","0000")%>
                        <%=writeTextfield("smsDevicePort","COM1")%>
                        <%=writeTextfield("smsBaudrate","115200")%>
                        <%=writeTextfield("smsPolling","false")%>

                        <% focusFields.add("lastNotifiedLabResult"); %>
                    </table>
                </td>
            </tr>
        </table>

        <%-- JAVASCRIPT --------------------------------------------------------------------------%>
        <script>
          var firstFieldPerTabArray = new Array();
          <%
              for(int i=0; i<focusFields.size(); i++){
                 %>firstFieldPerTabArray[<%=i%>] = "value_<%=focusFields.get(i)%>";<%
              }
          %>

          function activateTab(sTab){
            for(var i=0; i<<%=numberOfTabs%>; i++){
              if(sTab==('tab'+i)){
                eval("document.getElementById('tab"+i+"-body').style.display = '';");
                eval("document.getElementById('tab"+i+"-selector').className = 'tabselected';");

                configForm.ActiveTab.value = sTab;
                eval("document.getElementById('"+firstFieldPerTabArray[sTab.substring(sTab.length-1,sTab.length)]+"')[0].focus();");
              }
              else{
                eval("document.getElementById('tab"+i+"-body').style.display = 'none';");
                eval("document.getElementById('tab"+i+"-selector').className = 'tabunselected';");
              }
            }
          }

          <%-- default selected tab --%>
          activateTab('<%=sActiveTab%>');
        </script>

        <script>
          function doBack(){
            if(checkSaveButton()){
              window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
            }
          }

          function doSave(){
            configForm.Action.value = 'Save';
            configForm.submit();
          }
        </script>
    </div>

    <%-- BUTTONS ---------------------------------------------------------------------------------%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class='button' type="button" name="SaveButton" value='<%=getTran("Web","Save",sWebLanguage)%>' onclick="doSave();">&nbsp;
        <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>

    <%-- link to manageConfig --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <img src='<c:url value="/_img/pijl.gif"/>'>
        <a  href="<c:url value='/main.do'/>?Page=system/manageConfig.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Manage","manageConfiguration",sWebLanguage)%></a>&nbsp;
    <%=ScreenHelper.alignButtonsStop()%>
</form>