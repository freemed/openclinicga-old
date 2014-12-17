<%@page import="java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","select",activeUser)%>

<%!
    //--- SORT MENU -------------------------------------------------------------------------------
    private String sortMenu(Hashtable hMenu){
        Vector keys = new Vector(hMenu.keySet());
        Collections.sort(keys);
        Iterator iter = keys.iterator();

        // to html
        String sLabel, sLink, sOut = "";
        int rowIdx = 0;
        
        while(iter.hasNext()){
            sLabel = (String)iter.next();
            sLink = (String)hMenu.get(sLabel);
            sOut+= writeTblChild(sLink,sLabel,rowIdx++,true);
        }

        return sOut;
    }
%>

<table width="100%" cellpadding="0" cellspacing="0">
<tr>
<td width="50%" style="vertical-align:top;">
    <%-- MANAGEMENT --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <%
                    Hashtable hMenu = new Hashtable();
	                hMenu.put(getTran("web.manage","ManageCategories",sWebLanguage),"main.do?Page=system/manageCategories.jsp");
	                hMenu.put(getTran("web.manage","ManageDrugCategories",sWebLanguage),"main.do?Page=system/manageDrugCategories.jsp");
                    hMenu.put(getTran("web.manage","ManageServices",sWebLanguage),"main.do?Page=system/manageServices.jsp");
                    hMenu.put(getTran("web.manage","ManageWickets",sWebLanguage),"main.do?Page=system/manageWickets.jsp");
                    hMenu.put(getTran("Web","ManageBeds",sWebLanguage),"main.do?Page=system/manageBeds.jsp");
                    hMenu.put(getTran("web.manage","ManageExaminations",sWebLanguage),"main.do?Page=system/manageExaminations.jsp");
                    hMenu.put(getTran("web.manage","ManageServiceExaminations",sWebLanguage),"main.do?Page=system/manageServiceExaminations.jsp");
                    hMenu.put(getTran("web.manage","ManagePassword",sWebLanguage),"main.do?Page=system/managePassword.jsp");
                    hMenu.put(getTran("web.manage","ManageServers",sWebLanguage),"main.do?Page=system/manageServers.jsp");
                    hMenu.put(getTran("web.manage","obligatory_fields",sWebLanguage),"main.do?Page=system/manageObligatoryFields.jsp");
                    hMenu.put(getTran("web.manage","intrusionmanagement",sWebLanguage),"main.do?Page=system/manageIntrusions.jsp");
                    hMenu.put(getTran("web.manage","prestations",sWebLanguage),"main.do?Page=system/managePrestations.jsp");
                    hMenu.put(getTran("web.manage","prestationgroups",sWebLanguage),"main.do?Page=system/managePrestationGroups.jsp");
                    hMenu.put(getTran("web.manage","tariffs",sWebLanguage),"main.do?Page=system/manageTariffs.jsp");
                    hMenu.put(getTran("web.manage","insurancerules",sWebLanguage),"main.do?Page=system/manageInsuranceRules.jsp");
                  	hMenu.put(getTran("web.manage","managelabprocedures",sWebLanguage),"main.do?Page=system/manageLabProcedures.jsp");
                  	hMenu.put(getTran("web.manage","managelabreagents",sWebLanguage),"main.do?Page=system/manageLabReagents.jsp");
                    hMenu.put(getTran("web.manage","ManageMedicalCenters",sWebLanguage),"main.do?Page=system/manageMedicalCenters.jsp");
                    hMenu.put(getTran("web.manage","ManageLabAnalyses",sWebLanguage),"main.do?Page=system/manageLabAnalyses.jsp");
                    hMenu.put(getTran("web.manage","ManageLabProfiles",sWebLanguage),"main.do?Page=system/manageLabProfiles.jsp");
                    hMenu.put(getTran("web.manage","ManageResultProfiles",sWebLanguage),"main.do?Page=system/manageResultProfiles.jsp");
                    hMenu.put(getTran("web.manage","ManageLastItemGroups",sWebLanguage),"main.do?Page=system/manageLastItemGroups.jsp");
                    hMenu.put(getTran("web.manage","ManageCarePrescriptions",sWebLanguage),"main.do?Page=system/manageCarePrescriptions.jsp");
                    hMenu.put(getTran("web.manage","ManageInsurars",sWebLanguage),"main.do?Page=system/manageInsurars.jsp");
                    hMenu.put(getTran("web.manage","ManageAutoCompletion",sWebLanguage),"main.do?Page=system/manageAutoCompletionItems.jsp");
                    hMenu.put(getTran("web.manage","ManageAutoCompletionValues",sWebLanguage),"main.do?Page=system/manageAutoCompletionItemsValues.jsp");
                    hMenu.put(getTran("web.manage","ManagePrintableDocuments",sWebLanguage),"main.do?Page=system/managePrintableDocuments.jsp");
                    hMenu.put(getTran("web.manage","ManageServiceDiagnoses",sWebLanguage),"main.do?Page=medical/manageServiceDiagnoses.jsp");
                    hMenu.put(getTran("web.manage","ManageActivatedVaccinations",sWebLanguage),"main.do?Page=system/activateVaccinations.jsp");
                    hMenu.put(getTran("web.manage","ManageCareProviderFees",sWebLanguage),"main.do?Page=system/manageCareProviderFees.jsp");
                    hMenu.put(getTran("web.manage","ManageProductMargins",sWebLanguage),"main.do?Page=system/manageProductMargins.jsp");
                    hMenu.put(getTran("web.manage","ManageAssetSuppliers",sWebLanguage),"main.do?Page=assets/manage_suppliers.jsp");
                    hMenu.put(getTran("web.manage","manageHistoryItems",sWebLanguage),"main.do?Page=system/manageHistoryItems.jsp");

                    out.print(ScreenHelper.writeTblHeader(getTran("Web","Manage",sWebLanguage),sCONTEXTPATH)+
                    		  sortMenu(hMenu)+
                    		  ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    
    <div style="height:12px;">
    
    <%-- DATABASE --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <% 
                    hMenu = new Hashtable();
                    hMenu.put(getTran("Web.Occup","medwan.common.execute-sql",sWebLanguage),"main.do?Page=system/executeSQL.jsp");
                    hMenu.put(getTran("web.manage","MonitorConnections",sWebLanguage),"main.do?Page=system/monitorConnections.jsp");
                    hMenu.put(getTran("web.manage","MonitorAccess",sWebLanguage),"main.do?Page=system/monitorAccess.jsp");
                    hMenu.put(getTran("web.manage","ViewErrors",sWebLanguage),"main.do?Page=system/monitorErrors.jsp");
                    hMenu.put(getTran("web.manage","processUpdateQueries",sWebLanguage),"main.do?Page=system/processUpdateQueries.jsp");
                    if(MedwanQuery.getInstance().getConfigString("serverId").equals("1")){
                        hMenu.put(getTran("web.manage","merge_persons",sWebLanguage),"main.do?Page=system/mergePersons.jsp");
                    }

                    out.print(ScreenHelper.writeTblHeader(getTran("web.manage","Database",sWebLanguage),sCONTEXTPATH)+
                    		  sortMenu(hMenu)+
                    		  ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
</td>

<td width="50%" style="vertical-align:top;">
    <%-- SYNCHRONISATIE --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <%
                    hMenu = new Hashtable();
                    hMenu.put(getTran("Web.Occup","medwan.common.messages",sWebLanguage),"main.do?Page=system/readMessage.jsp");
                    hMenu.put(getTran("web.manage","SynchronizeLabelsWithIni",sWebLanguage),"main.do?Page=system/syncLabelsWithIni.jsp");
                    hMenu.put(getTran("web.manage","SynchronizeTransactionItemsWithIni",sWebLanguage),"main.do?Page=system/syncTransactionItemsWithIni.jsp");
                    hMenu.put(getTran("web.manage","synchronization.of.counters",sWebLanguage),"main.do?Page=system/countersSync.jsp");
                    hMenu.put(getTran("web.manage","recalculate.stocklevels",sWebLanguage),"main.do?Page=system/recalculateStockLevels.jsp");
                    hMenu.put(getTran("web.manage","update.all",sWebLanguage),"main.do?Page=util/updateSystem.jsp");
                    hMenu.put(getTran("web.manage","update.examinations",sWebLanguage),"main.do?Page=util/updateExaminations.jsp");
                    hMenu.put(getTran("web.manage","reset.defaults",sWebLanguage),"main.do?Page=system/resetDefaults.jsp");
                    hMenu.put(getTran("web.manage","load.file",sWebLanguage),"main.do?Page=system/loadTable.jsp");
                    hMenu.put(getTran("web.manage","export.labels",sWebLanguage),"main.do?Page=system/exportLabels.jsp");

                    out.print(ScreenHelper.writeTblHeader(getTran("web.manage","Synchronization",sWebLanguage),sCONTEXTPATH)+
                    		  sortMenu(hMenu)+
                    		  ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    
    <div style="height:12px;">
    
    <%-- TRANSLATIONS --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <%
                    hMenu = new Hashtable();
                    hMenu.put(getTran("Web","ManageTranslations",sWebLanguage),"main.do?Page=system/manageTranslations.jsp");
                    hMenu.put(getTran("Web","ManageTranslationsBulk",sWebLanguage),"main.do?Page=system/manageTranslationsBulk.jsp");
                    hMenu.put(getTran("web.manage","Translations",sWebLanguage),"main.do?Page=system/reloadTranslations.jsp");

                    out.print(ScreenHelper.writeTblHeader(getTran("Web","Translations",sWebLanguage),sCONTEXTPATH)+
                              sortMenu(hMenu)+
                              ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    
    <div style="height:12px;">
    
    <%-- SETUP --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <%
                    hMenu = new Hashtable();
                    hMenu.put(getTran("Web.Occup","medwan.common.db-management",sWebLanguage),"main.do?Page=system/checkDB.jsp");
                    hMenu.put(getTran("web.manage","ManageConfiguration",sWebLanguage),"main.do?Page=system/manageConfig.jsp");
                    hMenu.put(getTran("web.manage","ManageConfigurationTabbed",sWebLanguage),"main.do?Page=system/manageConfigTabbed.jsp");
                    hMenu.put(getTran("web.manage","ManageConfigurationPerCategory",sWebLanguage),"main.do?Page=util/configparameters.jsp");
                    hMenu.put(getTran("web.manage","manageTransactionItems",sWebLanguage),"main.do?Page=system/manageTransactionItems.jsp");
                    hMenu.put(getTran("web.manage","ManageServerId",sWebLanguage),"main.do?Page=system/manageServerId.jsp");
                    hMenu.put(getTran("web.manage","applications",sWebLanguage),"main.do?Page=system/manageApplications.jsp");
                    hMenu.put(getTran("web.manage","manageSiteLabels",sWebLanguage),"main.do?Page=system/manageSiteLabels.jsp");
                    hMenu.put(getTran("web.manage","manageSlaveServer",sWebLanguage),"main.do?Page=system/manageSlaveServer.jsp");
                    hMenu.put(getTran("web.manage","manageGglobalhealthbarometerdata",sWebLanguage),"main.do?Page=system/manageGlobalHealthBarometerData.jsp");
                    hMenu.put(getTran("web.manage","manageDatacenterConfig",sWebLanguage),"main.do?Page=system/manageDatacenterConfig.jsp");
                    hMenu.put(getTran("web.manage","manageDateFormat",sWebLanguage),"main.do?Page=system/manageDateFormat.jsp");

	                if(MedwanQuery.getInstance().getConfigInt("enableScreenDesigner",0)==1){
                        hMenu.put(getTran("web.manage","screenDesigner",sWebLanguage),"main.do?Page=system/screenDesigner.jsp");
                    }
                    
                    out.print(ScreenHelper.writeTblHeader(getTran("web.manage","setup",sWebLanguage),sCONTEXTPATH)+
                    		  sortMenu(hMenu)+
                    		  ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
    
    <div style="height:12px;">
    
    <%-- OTHER --%>
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td>
                <%
                    int idx = 0;
                    hMenu = new Hashtable();
	                hMenu.put(getTran("web.manage","memoryprofile",sWebLanguage),"main.do?Page=util/profile.jsp"); idx++;
	                hMenu.put(getTran("web.manage","quicklist",sWebLanguage),"main.do?Page=system/manageQuickList.jsp"); idx++;
	                hMenu.put(getTran("web.manage","quicklablist",sWebLanguage),"main.do?Page=system/manageQuickLabList.jsp"); idx++;
	                hMenu.put(getTran("web.manage","countarchivelabels",sWebLanguage),"main.do?Page=util/countArchiveLabels.jsp"); idx++;
	                if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
	                	hMenu.put(getTran("web.manage","mfptariffs",sWebLanguage),"main.do?Page=util/setMFPTariffs.jsp"); idx++;
	                }
	                hMenu.put(getTran("web.manage","notifiermessages",sWebLanguage),"main.do?Page=system/manageNotifierMessages.jsp"); idx++;
                    hMenu.put(getTran("web.manage","ManageDefaultWeekschedules",sWebLanguage),"main.do?Page=system/manageDefaultWeekschedules.jsp"); idx++;
                    hMenu.put(getTran("web.manage","CreateSalaryCalculationsForWorkschedules",sWebLanguage),"main.do?Page=hr/management/createSalaryCalculationsForWorkschedules.jsp"); idx++;
                    hMenu.put(getTran("web.manage","CreateSalaryCalculationsForLeaves",sWebLanguage),"main.do?Page=hr/management/createSalaryCalculationsForLeaves.jsp"); idx++;
                    hMenu.put(getTran("web.manage","ManageDefaultSalaryCodes",sWebLanguage),"main.do?Page=hr/management/manageDefaultSalaryCodes.jsp"); idx++;
                    hMenu.put(getTran("web.manage","ManageSystemMessage",sWebLanguage),"main.do?Page=system/manageSystemMessage.jsp"); idx++;
                    hMenu.put(getTran("web.manage","exporttowhonet",sWebLanguage),"main.do?Page=system/exportToWHONet.jsp"); idx++;
                    hMenu.put(getTran("web.manage","manageDoubleScannedDocuments",sWebLanguage),"main.do?Page=system/manageDoubleScannedDocuments.jsp"); idx++;
                    hMenu.put(getTran("web.manage","exporttomaster",sWebLanguage),"main.do?Page=util/createOpenclinicExport.jsp"); idx++;

                    out.print(ScreenHelper.writeTblHeader(getTran("web.occup","medwan.common.other",sWebLanguage),sCONTEXTPATH)+
	                          sortMenu(hMenu)+
	                          (activePatient!=null?writeTblChildWithCode("javascript:printUserCard()",getTran("web.manage","createusercard",sWebLanguage),idx++):"")+
	                          ScreenHelper.writeTblFooter());
                %>
            </td>
        </tr>
    </table>
</td>
</tr>
</table>

<script>
  function printUserCard(){
	var url = "<c:url value='/userprofile/createUserCardPdf.jsp'/>"+
	          "?cardtype=<%=MedwanQuery.getInstance().getConfigString("userCardType","default")%>"+
	          "&ts=<%=getTs()%>";
    window.open(url,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }
</script>