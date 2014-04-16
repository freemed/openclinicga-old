<%@page import="be.openclinic.medical.Diagnosis"%>
<%@ page import="be.openclinic.adt.Encounter" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("diagnoses.patientdiagnoses","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- WRITE SELECT FROM CONFIG ----------------------------------------------------------------
    public static String writeSelectFromConfig(String config, String selected, String name,String language){
        String sConfigValue = MedwanQuery.getInstance().getConfigString(config,"");
        String sValues[] = sConfigValue.split("\\;");

        String sOutput = "<select class='text' name='" + name + "'><option value=''>" + ScreenHelper.getTranDb("web","choose",language) + "</option>";

        for(int i = 0;i < sValues.length; i++){
            sOutput += "<option value='" + sValues[i] + "' ";
            if(sValues[i].equals(selected)){
                sOutput += " selected";
            }
            sOutput += ">" + sValues[i] + "</option>";
        }
        sOutput += "</select>";
        return sOutput;
    }
%>

<%
    if (activePatient != null && activePatient.personid.length() > 0) {
        try{

        String sDefaultSortDir = "ASC";
        String sSortDir = checkString(request.getParameter("SortDir"));
        if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

        String sAction = checkString(request.getParameter("Action"));

        if (Debug.enabled) {
            Debug.println("\nAction : " + sAction);
        }

        //String sFindDiagnosisUID         = checkString(request.getParameter("FindDiagnosisUID"));
        String sFindDiagnosisFromDate = checkString(request.getParameter("FindDiagnosisFromDate"));
        String sFindDiagnosisToDate = checkString(request.getParameter("FindDiagnosisToDate"));
        String sFindDiagnosisCode = checkString(request.getParameter("FindDiagnosisCode"));
        String sFindDiagnosisCodeType = checkString(request.getParameter("FindDiagnosisCodeType"));
        String sFindDiagnosisCodeLabel = checkString(request.getParameter("FindDiagnosisCodeLabel"));
        String sFindDiagnosisFromCertainty = checkString(request.getParameter("FindDiagnosisFromCertainty"));
        String sFindDiagnosisToCertainty = checkString(request.getParameter("FindDiagnosisToCertainty"));
        String sFindDiagnosisFromGravity = checkString(request.getParameter("FindDiagnosisFromGravity"));
        String sFindDiagnosisToGravity = checkString(request.getParameter("FindDiagnosisToGravity"));
        String sFindDiagnosisEncounter = checkString(request.getParameter("FindDiagnosisEncounter"));
        String sFindDiagnosisEncounterName = checkString(request.getParameter("FindDiagnosisEncounterName"));
        String sFindDiagnosisAuthor = checkString(request.getParameter("FindDiagnosisAuthor"));
        String sFindDiagnosisAuthorName = checkString(request.getParameter("FindDiagnosisAuthorName"));

        if (sAction.equals("")) {
            sAction = "SEARCH";
            //sFindDiagnosisEncounter = "%";
        }

        if (Debug.enabled) {
            Debug.println("\n#######################################################" +
                    "\nFindDiagnosisFromDate      : " + sFindDiagnosisFromDate +
                    "\nFindDiagnosisToDate        : " + sFindDiagnosisToDate +
                    "\nFindDiagnosisCode          : " + sFindDiagnosisCode +
                    "\nFindDiagnosisCodeType      : " + sFindDiagnosisCodeType +
                    "\nFindDiagnosisCodeLabel     : " + sFindDiagnosisCodeLabel +
                    "\nFindDiagnosisCertainty     : " + sFindDiagnosisFromCertainty +
                    "\nFindDiagnosisCertainty     : " + sFindDiagnosisToCertainty +
                    "\nFindDiagnosisGravity       : " + sFindDiagnosisFromGravity +
                    "\nFindDiagnosisGravity       : " + sFindDiagnosisToGravity +
                    "\nFindDiagnosisEncounter     : " + sFindDiagnosisEncounter +
                    "\nFindDiagnosisEncounterName : " + sFindDiagnosisEncounterName +
                    "\nFindDiagnosisAuthor        : " + sFindDiagnosisAuthor +
                    "\nFindDiagnosisAuthorName    : " + sFindDiagnosisAuthorName +
                    "\n#######################################################");
        }

        String sEditDiagnosisUID = checkString(request.getParameter("EditDiagnosisUID"));
        String sEditDiagnosisDate = checkString(request.getParameter("EditDiagnosisDate"));
        String sEditDiagnosisEndDate = checkString(request.getParameter("EditDiagnosisEndDate"));
        String sEditDiagnosisCode = checkString(request.getParameter("EditDiagnosisCode"));
        String sEditDiagnosisCodeType = checkString(request.getParameter("EditDiagnosisCodeType"));
        String sEditDiagnosisCodeLabel = checkString(request.getParameter("EditDiagnosisCodeLabel"));
        String sEditDiagnosisCertainty = checkString(request.getParameter("EditDiagnosisCertainty"));
        String sEditDiagnosisGravity = checkString(request.getParameter("EditDiagnosisGravity"));
        String sEditDiagnosisEncounter = checkString(request.getParameter("EditDiagnosisEncounter"));
        String sEditDiagnosisEncounterName = checkString(request.getParameter("EditDiagnosisEncounterName"));
        String sEditDiagnosisAuthor = checkString(request.getParameter("EditDiagnosisAuthor"));
        String sEditDiagnosisAuthorName = checkString(request.getParameter("EditDiagnosisAuthorName"));
        String sEditDiagnosisLateralisation = checkString(request.getParameter("EditDiagnosisLateralisation"));

        if (Debug.enabled) {
            Debug.println("\n#######################################################" +
                    "\nEditDiagnosisUID           : " + sEditDiagnosisUID +
                    "\nEditDiagnosisToDate        : " + sEditDiagnosisDate +
                    "\nEditDiagnosisEndDate       : " + sEditDiagnosisEndDate +
                    "\nEditDiagnosisCode          : " + sEditDiagnosisCode +
                    "\nEditDiagnosisCodeLabel     : " + sEditDiagnosisCodeLabel +
                    "\nEditDiagnosisCertainty     : " + sEditDiagnosisCertainty +
                    "\nEditDiagnosisGravity       : " + sEditDiagnosisGravity +
                    "\nEditDiagnosisEncounter     : " + sEditDiagnosisEncounter +
                    "\nEditDiagnosisEncounterName : " + sEditDiagnosisEncounterName +
                    "\nEditDiagnosisAuthor        : " + sEditDiagnosisAuthor +
                    "\nEditDiagnosisAuthorName    : " + sEditDiagnosisAuthorName +
                    "\nEditDiagnosisLateralisation: " + sEditDiagnosisLateralisation +
                    "\n#######################################################");
        }

        if (sAction.equals("SAVE")) {
            Diagnosis tmpDiagnosis = new Diagnosis();
            if (sEditDiagnosisUID.length() > 0) {
                tmpDiagnosis = Diagnosis.get(sEditDiagnosisUID);
            } else {
                tmpDiagnosis.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
                tmpDiagnosis.setReferenceType("");
                tmpDiagnosis.setReferenceUID("");
            }
            if (sEditDiagnosisDate.length() > 0) {
                tmpDiagnosis.setDate(ScreenHelper.getSQLDate(sEditDiagnosisDate));
            }
            if (sEditDiagnosisEndDate.length() > 0) {
                tmpDiagnosis.setEndDate(new Timestamp(ScreenHelper.getSQLDate(sEditDiagnosisEndDate).getTime()));
            }
            tmpDiagnosis.setCode(sEditDiagnosisCode);
            tmpDiagnosis.setCodeType(sEditDiagnosisCodeType);
            if (sEditDiagnosisCertainty.length() > 0) {
                tmpDiagnosis.setCertainty(Integer.parseInt(sEditDiagnosisCertainty));
            }
            if (sEditDiagnosisGravity.length() > 0) {
                tmpDiagnosis.setGravity(Integer.parseInt(sEditDiagnosisGravity));
            }
            if (sEditDiagnosisEncounter.length() > 0) {
                Encounter tmpEncounter = Encounter.get(sEditDiagnosisEncounter);
                tmpDiagnosis.setEncounter(tmpEncounter);
            } else {
                tmpDiagnosis.setEncounter(new Encounter());
            }
            tmpDiagnosis.setLateralisation(new StringBuffer(sEditDiagnosisLateralisation));
            if (sEditDiagnosisAuthor.length() > 0) {
                User tmpUser = new User();
                tmpUser.initialize(Integer.parseInt(sEditDiagnosisAuthor));
                tmpDiagnosis.setAuthor(tmpUser);
            } else {
                tmpDiagnosis.setAuthor(new User());
            }

            tmpDiagnosis.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
            tmpDiagnosis.setUpdateUser(activeUser.userid);
            tmpDiagnosis.store();
            sEditDiagnosisUID = tmpDiagnosis.getUid();
        }
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();

        if (sEditDiagnosisUID.length() > 0) {
            Diagnosis tmpDiagnosis = Diagnosis.get(sEditDiagnosisUID);
            //sEditDiagnosisDate          = tmpDiagnosis.getDate().toString();
            sEditDiagnosisDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(tmpDiagnosis.getDate()));
            if (tmpDiagnosis.getEndDate() != null) {
                sEditDiagnosisEndDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(tmpDiagnosis.getEndDate()));
            } else {
                sEditDiagnosisEndDate = "";
            }
            sEditDiagnosisCode = tmpDiagnosis.getCode();
            sEditDiagnosisCodeType = tmpDiagnosis.getCodeType();
            sEditDiagnosisCodeLabel = tmpDiagnosis.getCode() + ": " + MedwanQuery.getInstance().getCodeTran(sEditDiagnosisCodeType + "code" + sEditDiagnosisCode, sWebLanguage);
            sEditDiagnosisCertainty = Integer.toString(tmpDiagnosis.getCertainty());
            sEditDiagnosisGravity = Integer.toString(tmpDiagnosis.getGravity());
            sEditDiagnosisAuthor = tmpDiagnosis.getAuthor().userid;
            sEditDiagnosisAuthorName = ScreenHelper.getFullUserName(tmpDiagnosis.getAuthor().userid, ad_conn);
            sEditDiagnosisEncounter = tmpDiagnosis.getEncounter().getUid();
            sEditDiagnosisEncounterName = tmpDiagnosis.getEncounter().getEncounterDisplayName(sWebLanguage);
            sEditDiagnosisLateralisation = tmpDiagnosis.getLateralisation().toString();
        }


        if (sEditDiagnosisDate.length() == 0) {
            sEditDiagnosisDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(ScreenHelper.getSQLDate(getDate())));
        }
        if (sEditDiagnosisEncounter.length() == 0) {
            Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
            if (encounter != null) {
                sEditDiagnosisEncounter = encounter.getUid();
                sEditDiagnosisEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
            }
        }

        if (sEditDiagnosisAuthor.length() == 0) {
            sEditDiagnosisAuthor = activeUser.userid;
            sEditDiagnosisAuthorName = ScreenHelper.getFullUserName(activeUser.userid, ad_conn);
        }
        ad_conn.close();
%>

<!-- FIND BLOCK -->
<%
    if(sAction.equals("SEARCH") || sAction.equals("")){
%>
<form name="FindDiagnosisForm" id="FindDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doBack();")%>
    <table class='list' width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){doFind();return false;}else{return true;}'>
        <!-- date -->
        <tr>
            <td class="admin2" width='<%=sTDAdminWidth%>'>
                <%=getTran("medical.diagnosis","period",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%
                    String sFromDate = "";
                    if(sFindDiagnosisFromDate.length() > 0){
                        sFromDate = new SimpleDateFormat("dd/MM/yyyy").format(ScreenHelper.getSQLDate(sFindDiagnosisFromDate));
                    }
                    out.print(writeDateField("FindDiagnosisFromDate","FindDiagnosisForm",sFromDate,sWebLanguage));
                %>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%
                    String sToDate = "";
                    if(sFindDiagnosisToDate.length() > 0){
                        sToDate = new SimpleDateFormat("dd/MM/yyyy").format(ScreenHelper.getSQLDate(sFindDiagnosisToDate));
                    }
                    out.print(writeDateField("FindDiagnosisToDate","FindDiagnosisForm",sToDate,sWebLanguage));
                %>&nbsp;
            </td>
        </tr>
        <!-- code -->
        <tr>
            <td class="admin2">
                <%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="FindDiagnosisCodeLabel" id="FindDiagnosisCodeLabel" value="<%=sFindDiagnosisCodeLabel%>" size="<%=sTextWidth%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('FindDiagnosisCode','FindDiagnosisCodeLabel','FindDiagnosisCodeType');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisCode.value='';FindDiagnosisForm.FindDiagnosisCodeLabel.value='';FindDiagnosisForm.FindDiagnosisCodeType.value='';">
            </td>
            <input type="hidden" name="FindDiagnosisCode" id="FindDiagnosisCode" value="<%=sFindDiagnosisCode%>">
            <input type="hidden" name="FindDiagnosisCodeType" id="FindDiagnosisCodeType" value="<%=sFindDiagnosisCodeType%>">
        </tr>
        <!-- certainty -->
        <tr>
            <td class="admin2">
                <%=getTran("medical.diagnosis","certainty",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.certainty",sFindDiagnosisFromCertainty,"FindDiagnosisFromCertainty",sWebLanguage));
                %>
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.certainty",sFindDiagnosisToCertainty,"FindDiagnosisToCertainty",sWebLanguage));
                %>
            </td>
        </tr>
        <!-- gravity -->
        <tr>
            <td class="admin2">
                <%=getTran("medical.diagnosis","gravity",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.gravity",sFindDiagnosisFromGravity,"FindDiagnosisFromGravity",sWebLanguage));
                %>
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.gravity",sFindDiagnosisToGravity,"FindDiagnosisToGravity",sWebLanguage));
                %>
            </td>
        </tr>

        <!-- encounter -->

        <tr>
            <td class="admin2">
                <%=getTran("web","encounter",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="hidden" name="FindDiagnosisEncounter" value="<%=sFindDiagnosisEncounter%>">
                <input class="text" type="text" name="FindDiagnosisEncounterName" readonly size="<%=sTextWidth%>" value="<%=sFindDiagnosisEncounterName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('FindDiagnosisEncounter','FindDiagnosisEncounterName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisEncounter.value='';FindDiagnosisForm.FindDiagnosisEncounterName.value='';">
            </td>
        </tr>
        <!-- author -->
        <tr>
            <td class="admin2">
                <%=getTran("medical.diagnosis","author",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="hidden" name="FindDiagnosisAuthor" value="<%=sFindDiagnosisAuthor%>">
                <input class="text" type="text" name="FindDiagnosisAuthorName" readonly size="<%=sTextWidth%>" value="<%=sFindDiagnosisAuthorName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthor('FindDiagnosisAuthor','FindDiagnosisAuthorName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisAuthor.value='';FindDiagnosisForm.FindDiagnosisAuthorName.value='';">
            </td>
        </tr>
        <input type="hidden" name="Action" value="">
        <input type="hidden" name="FindSortColumn" value="">
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input class="button" type="button" name="EmptyButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="empty();">&nbsp;
                <input class="button" type="button" name="NewButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
                <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">&nbsp;
                <input class="button" type="button" name="closButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="doClose();">&nbsp;
            </td>
        </tr>
    </table>
</form>
<script>
    FindDiagnosisForm.FindDiagnosisFromDate.focus();
</script>
<!-- END FIND BLOCK -->
<%
    }
%>

<!-- RESULTS BLOCK -->
<%
    if(sAction.equals("SEARCH")){
%>
<%
    StringBuffer sbResuslts = new StringBuffer();
    Vector vDiagnoses = new Vector();
    Vector vEncounters = new Vector();

    int iCountResults = 0;


    try {
        String sSearchCode = "";
        if (sFindDiagnosisCode.length() > 0) {
            sSearchCode = sFindDiagnosisCode;
        } else {
            sSearchCode = sFindDiagnosisCodeLabel;
            sFindDiagnosisCodeType = "";
        }
        if (sFindDiagnosisEncounter.length() == 0) {
            vEncounters = Encounter.selectEncountersUnique("", "", "", "", "", "", "", "", activePatient.personid, "");
        } else {
            vEncounters.add(Encounter.get(sFindDiagnosisEncounter));
        }
        String sClass = "";

        String sEncounterUID = "";
        String sEncounterName = "";
        //String sPatientName = "";

        String sAuthorUID = "";
        String sAuthorName = "";

        String sCode = "";
        String sCodeType = "";
        String sCodeLabel = "";

        Iterator iter = vEncounters.iterator();
        Iterator iter2;

        Diagnosis dTmp;
        Encounter tempEncounter;
        Hashtable encountersdone=new Hashtable();
        while (iter.hasNext()) {
            tempEncounter = (Encounter) iter.next();
            if(encountersdone.get(tempEncounter.getUid())==null){
                encountersdone.put(tempEncounter.getUid(),"1");
                vDiagnoses = Diagnosis.selectDiagnoses("", "", tempEncounter.getUid(), sFindDiagnosisAuthor, sFindDiagnosisFromGravity, sFindDiagnosisToGravity, sFindDiagnosisFromCertainty, sFindDiagnosisToCertainty,
                        sSearchCode, sFindDiagnosisFromDate, sFindDiagnosisToDate, sFindDiagnosisCodeType, "");
                iter2 = vDiagnoses.iterator();
                while (iter2.hasNext()) {
                    dTmp = (Diagnosis) iter2.next();
                    iCountResults++;
                    if (sClass.equals("")) {
                        sClass = "1";
                    } else {
                        sClass = "";
                    }

                    sCode = checkString(checkString(dTmp.getCode()));
                    sCodeType = checkString(checkString(dTmp.getCodeType()));
                    if (sCode.length() > 0) {
                        sCodeLabel = MedwanQuery.getInstance().getCodeTran(sCodeType + "code" + sCode, sWebLanguage);
                    } else {
                        sCodeLabel = "";
                    }

                    sEncounterUID = checkString(dTmp.getEncounterUID());
                    if (checkString(sEncounterUID).length() > 0) {
                        Encounter eTmp = Encounter.get(sEncounterUID);
                        sEncounterName = eTmp.getEncounterDisplayName(sWebLanguage);
                    } else {
                        sEncounterName = "";
                    }

                    sAuthorUID = checkString(dTmp.getAuthorUID());
                    if (sAuthorUID.length() > 0) {
                       	ad_conn = MedwanQuery.getInstance().getAdminConnection();
                        sAuthorName = ScreenHelper.getFullUserName(sAuthorUID, ad_conn);
                        ad_conn.close();
                    } else {
                        sAuthorName = "";
                    }

                    String sEnddate = "";
                    if (dTmp.getEndDate() != null) {
                        sEnddate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(dTmp.getEndDate()));
                    }
                    sbResuslts.append("<tr class=\"list" + sClass + "\"" +
                            " onmouseover=\"this.style.cursor='hand';\"" +
                            " onmouseout=\"this.style.cursor='default';\"" +
                            " onclick=\"doSelect('" + dTmp.getUid() + "');\">" +
                            //        "   <td nowrap>" + sPatientName + "</td>" +
                            "   <td>" + checkString(new SimpleDateFormat("dd/MM/yyyy").format(dTmp.getDate())) + "</td>" +
                            "   <td>" + sEnddate + "</td>" +
                            "   <td>" + sCodeType.toUpperCase() + "</td>" +
                            "   <td>" + sCode + ": " + sCodeLabel + "</td>" +
                            "   <td>" + dTmp.getCertainty() + "</td>" +
                            "   <td>" + dTmp.getGravity() + "</td>" +
                            "   <td>" + sEncounterName + "</td>" +
                            "   <td>" + sAuthorName + "</td>" +
                            "</tr>");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String sortTran = getTran("web", "clicktosort", sWebLanguage);
%>
    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <tr class="admin">

            <td ><a href="#" class="underlined" title="<%=sortTran%>"><<%=sSortDir%>><%=getTranNoLink("web","date",sWebLanguage)%></<%=sSortDir%>></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("web","enddate",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("web","codetype",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","diagnosiscode",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","certainty",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","gravity",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("web","encounter",sWebLanguage)%></a></td>
            <td ><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","author",sWebLanguage)%></a></td>
        </tr>
        <%=sbResuslts%>
    </table>
    <%
        if(sbResuslts.length() == 0 ){
            out.print(getTran("web","norecordsfound",sWebLanguage));
        }else{
            out.print(iCountResults + " " + getTran("web","recordsfound",sWebLanguage));
        }
    %>
<!-- END RESULTS BLOCK -->

<%
    }
%>

<%
    if(sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")){
%>
<!-- EDIT BLOCK -->
<form name="EditDiagnosisForm" id="EditDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>">
    <!-- UID -->
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doSearchBack();")%>
    <input type="hidden" name="EditDiagnosisUID" value="<%=sEditDiagnosisUID%>">
    <table class="list" width="100%" cellspacing="1">
        <!-- date -->
        <tr>
            <td class="admin" width='<%=sTDAdminWidth%>'>
                <%=getTran("web","date",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <%=writeDateField("EditDiagnosisDate","EditDiagnosisForm",sEditDiagnosisDate,sWebLanguage)%>
            </td>
        </tr>
        <!-- enddate -->
        <tr>
            <td class="admin" width='<%=sTDAdminWidth%>'>
                <%=getTran("web","enddate",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <%=writeDateField("EditDiagnosisEndDate","EditDiagnosisForm",sEditDiagnosisEndDate,sWebLanguage)%>
            </td>
        </tr>
        <!-- code -->
        <tr>
            <td class="admin">
                <%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <input class="text" type="text" name="EditDiagnosisCodeLabel" id="EditDiagnosisCodeLabel" value="<%=sEditDiagnosisCodeLabel%>" readonly size="<%=sTextWidth%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('EditDiagnosisCode','EditDiagnosisCodeLabel','EditDiagnosisCodeType');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisCode.value='';EditDiagnosisForm.EditDiagnosisCodeLabel.value='';EditDiagnosisForm.EditDiagnosisCodeType.value='';">
            </td>
            <input type="hidden" name="EditDiagnosisCode" id="EditDiagnosisCode" value="<%=sEditDiagnosisCode%>">
            <input type="hidden" name="EditDiagnosisCodeType" id="EditDiagnosisCodeType" value="<%=sEditDiagnosisCodeType%>">
        </tr>
        <!-- certainty -->
        <tr>
            <td class="admin">
                <%=getTran("medical.diagnosis","certainty",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.certainty",sEditDiagnosisCertainty,"EditDiagnosisCertainty",sWebLanguage));
                %>
            </td>
        </tr>
        <!-- gravity -->
        <tr>
            <td class="admin">
                <%=getTran("medical.diagnosis","gravity",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.gravity",sEditDiagnosisGravity,"EditDiagnosisGravity",sWebLanguage));
                %>
            </td>
        </tr>
        <!-- encounter -->
        <tr>
            <td class="admin">
                <%=getTran("web","encounter",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <input type="hidden" name="EditDiagnosisEncounter" value="<%=sEditDiagnosisEncounter%>">
                <input class="text" type="text" name="EditDiagnosisEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditDiagnosisEncounterName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditDiagnosisEncounter','EditDiagnosisEncounterName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisEncounter.value='';EditDiagnosisForm.EditDiagnosisEncounterName.value='';">
            </td>
        </tr>
        <!-- author -->
        <tr>
            <td class="admin">
                <%=getTran("medical.diagnosis","author",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <input type="hidden" name="EditDiagnosisAuthor" value="<%=sEditDiagnosisAuthor%>">
                <input class="text" type="text" name="EditDiagnosisAuthorName" readonly size="<%=sTextWidth%>" value="<%=sEditDiagnosisAuthorName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthor('EditDiagnosisAuthor','EditDiagnosisAuthorName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisAuthor.value='';EditDiagnosisForm.EditDiagnosisAuthorName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("medical.diagnosis","lateralisation",sWebLanguage)%> *
            </td>
            <td class="admin2">
                <%=writeTextarea("EditDiagnosisLateralisation","","","",sEditDiagnosisLateralisation)%>
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
                <input class="button" type="button" name="EditSaveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
                <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doSearchBack();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <!-- action -->
    <input type="hidden" name="Action" value="">
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<script>
    EditDiagnosisForm.EditDiagnosisDate.focus();
</script>
<!-- END EDIT BLOCK -->
<%
    }
%>
<script>
    function doFind(){
        if(FindDiagnosisForm.FindDiagnosisFromDate.value == ""
        && FindDiagnosisForm.FindDiagnosisToDate.value == ""
        && FindDiagnosisForm.FindDiagnosisCode.value == ""
        && FindDiagnosisForm.FindDiagnosisCodeType.value == ""
        && FindDiagnosisForm.FindDiagnosisCodeLabel.value == ""
        && FindDiagnosisForm.FindDiagnosisFromCertainty.value == ""
        && FindDiagnosisForm.FindDiagnosisToCertainty.value == ""
        && FindDiagnosisForm.FindDiagnosisFromGravity.value == ""
        && FindDiagnosisForm.FindDiagnosisToGravity.value == ""
        && FindDiagnosisForm.FindDiagnosisEncounter.value == ""
        && FindDiagnosisForm.FindDiagnosisEncounterName.value == ""
        && FindDiagnosisForm.FindDiagnosisAuthor.value == ""
        && FindDiagnosisForm.FindDiagnosisAuthorName.value == ""){
            alertDialog("web.manage","datamissing");
        }else{
            FindDiagnosisForm.FindButton.disabled = true;
            FindDiagnosisForm.Action.value = "SEARCH";
            FindDiagnosisForm.submit();
        }
    }

    function doNew(){
        FindDiagnosisForm.NewButton.disabled = true;
        FindDiagnosisForm.Action.value = "NEW";
        FindDiagnosisForm.submit();
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        window.location.href="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>";
    }

    function isNumber(val){
        if (isNaN(val)){
            return false;
        }else{
            return true;
        }
    }

    function doSave(){
        if(EditDiagnosisForm.EditDiagnosisDate.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_date";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_date",sWebLanguage)%>");
        }else if(EditDiagnosisForm.EditDiagnosisCode.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_code";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_code",sWebLanguage)%>");
        }else if(EditDiagnosisForm.EditDiagnosisCertainty.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_certainty";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_certainty",sWebLanguage)%>");
        }else if(!isNumber(EditDiagnosisForm.EditDiagnosisCertainty.value)){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=cert_no_valid_input";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","cert_no_valid_input",sWebLanguage)%>");
        }else if(EditDiagnosisForm.EditDiagnosisGravity.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_gravity";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_gravity",sWebLanguage)%>");
        }else if(!isNumber(EditDiagnosisForm.EditDiagnosisGravity.value)){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=grav_no_valid_input";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","grav_no_valid_input",sWebLanguage)%>");
        }else if(EditDiagnosisForm.EditDiagnosisEncounter.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_encounter";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>");
        }else if(EditDiagnosisForm.EditDiagnosisAuthor.value == ""){
            var popupUrl = "<<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical&labelID=no_author";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical","no_author",sWebLanguage)%>");
        }else{
            EditDiagnosisForm.EditSaveButton.disabled = true;
            EditDiagnosisForm.Action.value = "SAVE";
            EditDiagnosisForm.submit();
        }
    }

    function searchEncounter(encounterUidField,encounterNameField){
        openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=activePatient.personid%>");
    }

    function searchAuthor(authorUidField,authorNameField){
        openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+authorUidField+"&ReturnName="+authorNameField+"&displayImmatNew=no");
    }

    function doSelect(diagnosis){
        window.location = "<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&Action=SELECT&EditDiagnosisUID=" + diagnosis + "&ts=<%=getTs()%>";
    }

    function searchICPC(code,codelabel,codetype){
        openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField=" + code + "&returnField2=" + codelabel + "&returnField3=" + codetype + "&ListChoice=TRUE");
    }

    function empty(){
        FindDiagnosisForm.FindDiagnosisFromDate.value = "";
        FindDiagnosisForm.FindDiagnosisToDate.value = "";
        FindDiagnosisForm.FindDiagnosisCode.value = "";
        FindDiagnosisForm.FindDiagnosisCodeLabel.value = "";
        FindDiagnosisForm.FindDiagnosisCodeType.value = "";
        FindDiagnosisForm.FindDiagnosisFromCertainty.value = "";
        FindDiagnosisForm.FindDiagnosisToCertainty.value = "";
        FindDiagnosisForm.FindDiagnosisFromGravity.value = "";
        FindDiagnosisForm.FindDiagnosisToGravity.value = "";
        FindDiagnosisForm.FindDiagnosisEncounter.value = "";
        FindDiagnosisForm.FindDiagnosisEncounterName.value = "";
        FindDiagnosisForm.FindDiagnosisAuthor.value = "";
        FindDiagnosisForm.FindDiagnosisAuthorName.value = "";
    }
</script>
<%
    }
    catch(Exception e){
        e.printStackTrace();
    }
    }else{
%>
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doBack();")%>
    <table class='list' width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){doFind();return false;}else{return true;}'>
        <tr>
            <td colspan="2"><%=getTranNoLink("web","nopatientselected",sWebLanguage)%></td>
        </tr>
    </table>
    <script>
        function doBack(){
            window.location.href="<c:url value='/main.do'/>?Page=medical/index.jsp&ts=<%=getTs()%>";
        }
        function doClose(){
            var URL = unescape(window.opener.location);
            window.opener.location.href = URL;
            window.close();
        }

    </script>
<%
    }
%>