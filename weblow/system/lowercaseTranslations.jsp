<%@page import="java.io.*,java.util.Properties,java.util.Enumeration,java.util.StringTokenizer" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String processMsg = "", findLabelLang = "";
    String sAction = checkString(request.getParameter("action"));

    // get data from form
    boolean processDB = checkString(request.getParameter("processDB")).length() > 0;
    boolean processINI = checkString(request.getParameter("processINI")).length() > 0;
    boolean processFS = checkString(request.getParameter("processFS")).length() > 0;

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";

    //#############################################################################################
    //### PROCESS #################################################################################
    //#############################################################################################
    if (sAction.equals("process")) {
        //*** PROCESS INI FILE ********************************************************************
        if (processINI) {
            // what ini-file to use
            findLabelLang = checkString(request.getParameter("FindLabelLang"));
            String INIFILENAME = "/_common/xml/Labels.xx.ini";
            if (findLabelLang.length() > 0) {
                if (findLabelLang.length() == 2) {
                    INIFILENAME = INIFILENAME.replaceAll("xx", findLabelLang);
                } else {
                    throw new Exception("Country must be written in a 2-digit format.");
                }
            }

            try {
                Properties iniProps = new Properties();
                FileInputStream iniIs = new FileInputStream(sAPPFULLDIR + INIFILENAME);
                iniProps.load(iniIs);
                iniIs.close();

                //*** REWRITE INI FILES ***
                FileWriter csvWriter = new FileWriter(sAPPFULLDIR + INIFILENAME, false);
                String key, label;

                Enumeration keys = iniProps.keys();
                while (keys.hasMoreElements()) {
                    key = (String) (keys.nextElement());

                    label = checkString(iniProps.getProperty(key));
                    csvWriter.write(key.toLowerCase() + "=" + label + "\r\n");
                    csvWriter.flush();
                }

                csvWriter.close();

                reloadSingleton(session);
                processMsg = getTran("web.translations", "functions_and_services_uppercased", sWebLanguage) + "<br>";
            }
            catch (Exception e) {
                processMsg += "<font color='red'>" + e.getMessage() + "</font><br>";
            }
        }

        //*** PROCESS DATABASE ********************************************************************
        if (processDB) {
            String lcaseLabelType = MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_TYPE");
            String lcaseLabelID = MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_ID");
            String lcaseLabelLang = MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE");

            Label.UpdateNonServiceFunctionLabels(lcaseLabelType,lcaseLabelID,lcaseLabelLang,lcaseLabelType);
            processMsg += getTran("web.translations", "TranslationsAreLowercased", sWebLanguage) + "<br>";
        }

        //*** FUNCTIONS & SERVICES ****************************************************************
        if (processFS) {
            // update Functions
            Label.UpdateLabelTypeByType("function","Function");
            // update Services
            Label.UpdateLabelTypeByType("service","Service");
            processMsg += getTran("web.translations", "TranslationsAreLowercased", sWebLanguage) + "<br>";
        }
    } else {
        // default values for checkboxes
        processDB = true;
        processINI = true;
        processFS = false;
    }
%>
<form name="transactionForm" method="POST">
    <input type="hidden" name="action" value="">
    <%=writeTableHeader("Web.manage","lowercaseTranslations",sWebLanguage," doBack();")%>
    <table border="0" width="100%" align="center" cellspacing="0" cellpadding="1" class="menu">
        <%-- DB checkbox --%>
        <tr>
            <td>
                <input type="checkbox" name="processDB" id="cbDB" <%=(processDB?"checked":"")%>>
                <%=getLabel("Web.manage","lowercaselabelsindatabase",sWebLanguage,"cbDB")%>
            </td>
        </tr>
        <%-- INI checkbox + LABEL LANGUAGE --%>
        <tr>
            <td>
                <input type="checkbox" name="processINI" id="cbINI" <%=(processINI?"checked":"")%>>
                <%=getLabel("Web.manage","lowercaselabelsininifiles",sWebLanguage,"cbINI")%>&nbsp;
                <select name="FindLabelLang" class="text">
                    <%
                        String tmpLang;
                        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                        while (tokenizer.hasMoreTokens()) {
                            tmpLang = tokenizer.nextToken();
                    %>
                                <option value="<%=tmpLang%>" <%=(findLabelLang.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option>
                            <%
                        }
                    %>
                </select>
            </td>
        </tr>
        <%-- Functions and Services to first uppercase --%>
        <tr>
            <td>
                <input type="checkbox" name="processFS" id="cbFS" <%=(processFS?"checked":"")%>>
                <%=getLabel("Web.manage","uppercase_func_serv_in_database",sWebLanguage,"cbFS")%>
            </td>
        </tr>
    </table>
    <%-- STATUS MESSAGE --%>
    <%
        if(processMsg.length() > 0){
            %><br><%=processMsg%><%
        }
    %>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" name="perform" onClick="submitForm();" value='<%=getTran("Web","perform",sWebLanguage)%>'>&nbsp;
        <input class="button" type="button" value="<%=getTran("web","back",sWebLanguage)%>" onClick='doBack();'>
    <%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
  function submitForm(){
    if(transactionForm.processDB.checked || transactionForm.processINI.checked || transactionForm.processFS.checked){
      transactionForm.perform.disabled = true;
      transactionForm.action.value = 'process';
      transactionForm.submit();
    }
  }

  function doBack(){
    window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
  }
</script>