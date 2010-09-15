<%@ page import="java.util.*" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=checkPermission("system.management", "select", activeUser)%>
<%!
    private String sortMenu(Hashtable hMenu) {
        Vector keys = new Vector(hMenu.keySet());
        Collections.sort(keys);
        Iterator it = keys.iterator();

        // to html
        String sLabel, sLink, sOut = "";
        while (it.hasNext()) {
            sLabel = (String) it.next();
            sLink = (String) hMenu.get(sLabel);
            sOut += writeTblChild(sLink, sLabel);
        }

        return sOut;
    }
%>
<table width="100%" cellpadding="0" cellspacing="0">
<tr>
<td width="50%" valign="top">
    <%-- MANAGEMENT --%>
    <table width="100%">
        <tr>
            <td>
                <%
                    Hashtable hMenu = new Hashtable();
                    hMenu.put(getTran("Web.Manage", "ManageCategories", sWebLanguage), "main.do?Page=system/manageCategories.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageServices", sWebLanguage), "main.do?Page=system/manageServices.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageWickets", sWebLanguage), "main.do?Page=system/manageWickets.jsp");
                    hMenu.put(getTran("Web", "ManageBeds", sWebLanguage), "main.do?Page=system/manageBeds.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageExaminations", sWebLanguage), "main.do?Page=system/manageExaminations.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageServiceExaminations", sWebLanguage), "main.do?Page=system/manageServiceExaminations.jsp");
                    hMenu.put(getTran("Web.Manage", "ManagePassword", sWebLanguage), "main.do?Page=system/managePassword.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageServers", sWebLanguage), "main.do?Page=system/manageServers.jsp");
                    hMenu.put(getTran("Web.Manage", "obligatory_fields", sWebLanguage), "main.do?Page=system/manageObligatoryFields.jsp");
                    hMenu.put(getTran("Web.Manage", "intrusionmanagement", sWebLanguage), "main.do?Page=system/manageIntrusions.jsp");
                    hMenu.put(getTran("Web.Manage", "prestations", sWebLanguage), "main.do?Page=system/managePrestations.jsp");
                    hMenu.put(getTran("Web.Manage", "prestationgroups", sWebLanguage), "main.do?Page=system/managePrestationGroups.jsp");
                    hMenu.put(getTran("Web.Manage", "tariffs", sWebLanguage), "main.do?Page=system/manageTariffs.jsp");
                  //  hMenu.put(getTran("Web.Manage", "prestationcodes", sWebLanguage), "main.do?Page=system/managePrestationCodes.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageMedicalCenters", sWebLanguage), "main.do?Page=system/manageMedicalCenters.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageLabAnalyses", sWebLanguage), "main.do?Page=system/manageLabAnalyses.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageLabProfiles", sWebLanguage), "main.do?Page=system/manageLabProfiles.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageResultProfiles", sWebLanguage), "main.do?Page=system/manageResultProfiles.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageLastItemGroups", sWebLanguage), "main.do?Page=system/manageLastItemGroups.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageCarePrescriptions", sWebLanguage), "main.do?Page=system/manageCarePrescriptions.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageInsurars", sWebLanguage), "main.do?Page=system/manageInsurars.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageAutoCompletion", sWebLanguage), "main.do?Page=system/manageAutoCompletionItems.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageAutoCompletionValues", sWebLanguage), "main.do?Page=system/manageAutoCompletionItemsValues.jsp");
                    hMenu.put(getTran("Web.Manage", "ManagePrintableDocuments", sWebLanguage), "main.do?Page=system/managePrintableDocuments.jsp");
                    hMenu.put(getTran("Web.Manage", "ManageServiceDiagnoses", sWebLanguage), "main.do?Page=medical/manageServiceDiagnoses.jsp");
                    out.print(ScreenHelper.writeTblHeader(getTran("Web", "Manage", sWebLanguage), sCONTEXTPATH)
                            + sortMenu(hMenu)
                            + ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    <div style="height:12px;">
        <%-- DATABASE --%>
        <table width="100%">
            <tr>
                <td>
                    <%
                        hMenu = new Hashtable();
                        hMenu.put(getTran("Web.Occup", "medwan.common.execute-sql", sWebLanguage), "main.do?Page=system/executeSQL.jsp");
                        hMenu.put(getTran("Web.Manage", "MonitorConnections", sWebLanguage), "main.do?Page=system/monitorConnections.jsp");
                        hMenu.put(getTran("Web.Manage", "MonitorAccess", sWebLanguage), "main.do?Page=system/monitorAccess.jsp");
                        hMenu.put(getTran("Web", "monitorservices", sWebLanguage), "main.do?Page=system/monitorServices.jsp");
                        hMenu.put(getTran("Web.Manage", "ViewErrors", sWebLanguage), "main.do?Page=system/monitorErrors.jsp");
                        hMenu.put(getTran("Web.Manage", "processUpdateQueries", sWebLanguage), "main.do?Page=system/processUpdateQueries.jsp");
                        if (MedwanQuery.getInstance().getConfigString("serverId").equals("1")) {
                            hMenu.put(getTran("Web.Manage", "merge_persons", sWebLanguage), "main.do?Page=system/mergePersons.jsp");
                        }

                        hMenu.put(getTran("Web.manage", "archiveActiveFile", sWebLanguage), "main.do?Page=system/archiveActiveFile.jsp");
                        hMenu.put(getTran("Web.manage", "reactivateArchivedFile", sWebLanguage), "main.do?Page=system/reactivateArchivedFile.jsp");

                        out.print(ScreenHelper.writeTblHeader(getTran("Web.Manage", "Database", sWebLanguage), sCONTEXTPATH)
                                + sortMenu(hMenu)
                                + ScreenHelper.writeTblFooter());
                    %>
                </td>
            </tr>
        </table>
</td>
<td width="50%" valign="top">
    <%-- SYNCHRONISATIE --%>
    <table width="100%">
        <tr>
            <td>
                <%
                    hMenu = new Hashtable();
                    hMenu.put(getTran("Web.Occup", "medwan.common.messages", sWebLanguage), "main.do?Page=system/readMessage.jsp");
                    hMenu.put(getTran("Web.Manage", "SynchronizeLabelsWithIni", sWebLanguage), "main.do?Page=system/syncLabelsWithIni.jsp");
                    hMenu.put(getTran("Web.Manage", "Synchronization", sWebLanguage), "main.do?Page=system/incrementalSynchronization.jsp");
                    hMenu.put(getTran("Web.Manage", "SynchronizeTransactionItemsWithIni", sWebLanguage), "main.do?Page=system/syncTransactionItemsWithIni.jsp");
                    hMenu.put(getTran("Web.Manage", "Import_Export_Table", sWebLanguage), "main.do?Page=system/importExportTable.jsp");
                    hMenu.put(getTran("Web.Manage", "synchronization.of.counters", sWebLanguage), "main.do?Page=system/countersSync.jsp");

                    out.print(ScreenHelper.writeTblHeader(getTran("web.manage", "Synchronization", sWebLanguage), sCONTEXTPATH)
                            + sortMenu(hMenu)
                            + ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    <div style="height:12px;">
        <%-- TRANSLATIONS --%>
        <table width="100%">
            <tr>
                <td>
                    <%
                        hMenu = new Hashtable();
                        hMenu.put(getTran("Web", "ManageTranslations", sWebLanguage), "main.do?Page=system/manageTranslations.jsp");
                        hMenu.put(getTran("Web", "ManageTranslationsBulk", sWebLanguage), "main.do?Page=system/manageTranslationsBulk.jsp");
                        hMenu.put(getTran("Web.Manage", "Translations", sWebLanguage), "main.do?Page=system/reloadTranslations.jsp");

                        out.print(ScreenHelper.writeTblHeader(getTran("Web", "Translations", sWebLanguage), sCONTEXTPATH)
                                + sortMenu(hMenu)
                                + ScreenHelper.writeTblFooter());
                    %>
                </td>
            </tr>
        </table>
        <div style="height:12px;">
            <%-- SETUP --%>
            <table width="100%">
                <tr>
                    <td>
                        <%
                            hMenu = new Hashtable();
                            hMenu.put(getTran("Web.Occup", "medwan.common.db-management", sWebLanguage), "main.do?Page=system/checkDB.jsp");
                            hMenu.put(getTran("Web.Manage", "ManageConfiguration", sWebLanguage), "main.do?Page=system/manageConfig.jsp");
                            hMenu.put(getTran("Web.Manage", "ManageConfigurationTabbed", sWebLanguage), "main.do?Page=system/manageConfigTabbed.jsp");
                            hMenu.put(getTran("Web.Manage", "manageTransactionItems", sWebLanguage), "main.do?Page=system/manageTransactionItems.jsp");
                            hMenu.put(getTran("Web.Manage", "Counters", sWebLanguage), "main.do?Page=system/manageCounters.jsp");
                  //          hMenu.put(getTran("Web.Manage", "UpdateCounters", sWebLanguage), "main.do?Page=system/updateCounters.jsp");
                            hMenu.put(getTran("Web.Manage", "ManageServerId", sWebLanguage), "main.do?Page=system/manageServerId.jsp");
                            hMenu.put(getTran("Web.Manage", "applications", sWebLanguage), "main.do?Page=system/manageApplications.jsp");
                            hMenu.put(getTran("Web.Manage", "manageSiteLabels", sWebLanguage), "main.do?Page=system/manageSiteLabels.jsp");

                            out.print(ScreenHelper.writeTblHeader(getTran("web.manage", "setup", sWebLanguage), sCONTEXTPATH)
                                    + sortMenu(hMenu)
                                    + ScreenHelper.writeTblFooter());
                        %>
                    </td>
                </tr>
            </table>
            <div style="height:12px;">
                <%-- OTHER --%>
                <table width="100%">
                    <tr>
                        <td>
                            <%
                                hMenu = new Hashtable();
                                hMenu.put(getTran("Web.manage", "diagnostics", sWebLanguage), "main.do?Page=system/diagnostics.jsp");
                                hMenu.put(getTran("Web.manage", "macro", sWebLanguage), "main.do?Page=system/macro.jsp");
                                hMenu.put(getTran("Web.manage", "resetdebet", sWebLanguage), "main.do?Page=system/resetDebet.jsp");

                                out.print(ScreenHelper.writeTblHeader(getTran("web.occup", "medwan.common.other", sWebLanguage), sCONTEXTPATH)
                                        + sortMenu(hMenu)
                                        + writeTblChildWithCode("javascript:printUserCard()", getTran("Web.manage", "createusercard", sWebLanguage))
                                        + ScreenHelper.writeTblFooter());
                            %>
                        </td>
                    </tr>
                </table>
</td>
</tr>
</table>
<script>
    function printUserCard() {
        window.open("<c:url value='/userprofile/createUserCardPdf.jsp'/>?ts=<%=getTs()%>", "Popup" + new Date().getTime(), "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=400, height=300, menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);
    }
</script>