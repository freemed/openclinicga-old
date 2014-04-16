<%@ page import="be.openclinic.adt.Encounter" %>
<%@ page import="java.awt.*" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.Diagnosis" %>
<%@ page import="be.mxs.webapp.wl.servlet.http.RequestParameterParser" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private void saveDiagnosesToTable(Hashtable ICPCCodes, Hashtable ICD10Codes, String sTransactionUID, SessionContainerWO sessionContainerWO) {

        Enumeration enumeration;
        String code;

        enumeration = ICPCCodes.keys();
        while (enumeration.hasMoreElements()) {
            code = (String) enumeration.nextElement();
            if (code.indexOf("ICPCCode") == 0) {
                if (ScreenHelper.checkString((String) ICPCCodes.get("Gravity" + code)).length() > 0 && ScreenHelper.checkString((String) ICPCCodes.get("Certainty" + code)).length() > 0) {
                    Diagnosis.saveTransactionDiagnosis(code,
                            ScreenHelper.checkString((String) ICPCCodes.get(code)),
                            ScreenHelper.checkString((String) ICPCCodes.get("Gravity" + code)),
                            ScreenHelper.checkString((String) ICPCCodes.get("Certainty" + code)),
                            sessionContainerWO.getPersonVO().personId.toString(),
                            "ICPCCode",
                            "icpc",
                            ScreenHelper.getSQLTime(),
                            sTransactionUID,
                            sessionContainerWO.getUserVO().getUserId().intValue()
                    );
                }
            }
        }
        // ICD10Codes toevoegen
        enumeration = ICD10Codes.keys();

        while (enumeration.hasMoreElements()) {
            code = (String) enumeration.nextElement();
            if (code.indexOf("ICD10Code") == 0) {
                if (ScreenHelper.checkString((String) ICD10Codes.get("Gravity" + code)).length() > 0 && ScreenHelper.checkString((String) ICD10Codes.get("Certainty" + code)).length() > 0) {
                    Diagnosis.saveTransactionDiagnosis(code,
                            ScreenHelper.checkString((String) ICD10Codes.get(code)),
                            ScreenHelper.checkString((String) ICD10Codes.get("Gravity" + code)),
                            ScreenHelper.checkString((String) ICD10Codes.get("Certainty" + code)),
                            sessionContainerWO.getPersonVO().personId.toString(),
                            "ICD10Code",
                            "icd10",
                            ScreenHelper.getSQLTime(),
                            sTransactionUID,
                            sessionContainerWO.getUserVO().getUserId().intValue()
                    );
                }
            }
        }
    }
%>
<%
    boolean isNew = checkString(request.getParameter("new")).length() > 0;
    boolean isFind = checkString(request.getParameter("find")).length() > 0;
    boolean isSave = checkString(request.getParameter("saveButtonEncounter")).length() > 0;
    String sPatientLastname = checkString(request.getParameter("patientLastname"));
    String sPatientFirstname = checkString(request.getParameter("patientFirstname"));
    String sPatientDateOfBirth = checkString(request.getParameter("patientDateOfBirth"));
    String sPatientGender = checkString(request.getParameter("patientGender"));
    String sPatientUID = "";
    if (isFind || isNew || checkString(request.getParameter("EditEncounterUID")).length() > 0) {
        sPatientUID = checkString(request.getParameter("PatientUID"));
    }
    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
    String sEditEncounterType = checkString(request.getParameter("EditEncounterType"));
    String sEditEncounterBegin = checkString(request.getParameter("EditEncounterBegin"));
    String sEditEncounterEnd = checkString(request.getParameter("EditEncounterEnd"));
    String sEditEncounterService = checkString(request.getParameter("EditEncounterService"));
    String sEditEncounterServiceName = checkString(request.getParameter("EditEncounterServiceName"));
    String sEditEncounterOutcome = checkString(request.getParameter("EditEncounterOutcome"));
    if (isNew) {
        sEditEncounterUID = "";
        sEditEncounterType = "";
        sEditEncounterBegin = "";
        sEditEncounterEnd = "";
        sEditEncounterService = "";
        sEditEncounterServiceName = "";
        sEditEncounterOutcome = "";
    }
    if (isSave) {
        sPatientUID=checkString(request.getParameter("PatientUID"));
        if(sPatientUID.length()==0){
            AdminPerson patient = new AdminPerson();
            patient.dateOfBirth=checkString(request.getParameter("ap3"));
            patient.lastname=checkString(request.getParameter("ap1"));
            patient.firstname=checkString(request.getParameter("ap2"));
            patient.gender=checkString(request.getParameter("ap4"));
            patient.language = "F";
            patient.nativeCountry="RW";
            patient.sourceid="4";
            patient.updateuserid="4";
          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            patient.saveToDB(ad_conn);
            ad_conn.close();
            sPatientUID=patient.personid;
        }
        Encounter encounter = new Encounter();
        encounter.setManagerUID("4");
        encounter.setPatientUID(sPatientUID);
        encounter.setType(sEditEncounterType);
        try {
            encounter.setBegin(new SimpleDateFormat("dd/MM/yyyy").parse(sEditEncounterBegin));
        }
        catch (Exception e) {

        }
        try {
            encounter.setEnd(new SimpleDateFormat("dd/MM/yyyy").parse(sEditEncounterEnd));
        }
        catch (Exception e) {

        }
        encounter.setServiceUID(sEditEncounterService);
        encounter.setOutcome(sEditEncounterOutcome);
        encounter.setCreateDateTime(new java.util.Date());
        encounter.setUpdateDateTime(new java.util.Date());
        encounter.setVersion(1);
        encounter.setUpdateUser(activeUser.userid);
        encounter.setTransferDate(encounter.getBegin());
        encounter.store();
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
        saveDiagnosesToTable(RequestParameterParser.getInstance().parseRequestParameters(request, "ICPCCode"), RequestParameterParser.getInstance().parseRequestParameters(request, "ICD10Code"), "", sessionContainerWO);
        sEditEncounterUID = encounter.getUid();
    }
    if (sEditEncounterUID.length() > 0) {
        Encounter encounter = Encounter.get(sEditEncounterUID);
        sEditEncounterType = encounter.getType();
        try {
            sEditEncounterBegin = new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin());
            sEditEncounterEnd = new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd());
        }
        catch (Exception e) {

        }
        sEditEncounterService = encounter.getServiceUID();
        sEditEncounterServiceName = encounter.getService().getLabel(sWebLanguage);
        sEditEncounterOutcome = encounter.getOutcome();

    }
%>
<form name='EditPatientForm' id='EditPatientForm' method='post' action="<c:url value='/'/>popup.jsp?Page=statistics/quickFile.jsp&PopupHeight=600&PopupWidth=800">
    <table class='list' border='0' width='100%' cellspacing='1'>
        <tr>
            <td class="admin"><%=getTran("web","name",sWebLanguage)%></td><td class="admin2"><input type="bold" class="text" name="patientLastname" value="<%=sPatientLastname%>" size="25"/></td>
            <td class="admin"><%=getTran("web","firstname",sWebLanguage)%></td><td class="admin2"><input type="text" class="text" name="patientFirstname" value="<%=sPatientFirstname%>" size="15"/></td>
            <td class="admin"><%=getTran("web","dateofbirth",sWebLanguage)%></td><td class="admin2"><input type="text" class="text" name="patientDateOfBirth" value="<%=sPatientDateOfBirth%>" size="12" maxlength="10" OnBlur='checkDate(this)'/></td>
            <td class="admin"><%=getTran("web","gender",sWebLanguage)%></td><td class="admin2">
                <select class="text" name="patientGender">
                    <option value="M" <%=sPatientGender.equalsIgnoreCase("M")?"selected":""%>>M</option>
                    <option value="F" <%=sPatientGender.equalsIgnoreCase("F")?"selected":""%>>F</option>
                </select>
            </td>
            <td class="admin2"><input type="button" class="text" name="findButton" value="<%=getTran("web","find",sWebLanguage)%>" size="1" onclick="EditPatientForm.document.all['new'].value='';EditPatientForm.document.all['find'].value='1';EditPatientForm.submit();"/></td>
            <td class="admin2"><input type="button" class="text" name="newButton" value="<%=getTran("web","new",sWebLanguage)%>" size="1" onclick="EditPatientForm.document.all['new'].value='1';EditPatientForm.document.all['find'].value='';EditPatientForm.submit();"/></td>
        </tr>
    </table>
    <input type='hidden' name='PatientUID' value='<%=sPatientUID%>'/>
    <input type='hidden' name='find' value=''/>
    <input type='hidden' name='new' value=''/>
</form>
<%

    if (sPatientUID.length()>0 || isFind || isNew) {
        //Eerst kijken of de ingevoerde patiënt wel bestaat
        java.util.List persons = new java.util.Vector();
        if(sPatientUID.length()==0 && !isNew && (sPatientLastname.trim().length()>0 || sPatientFirstname.trim().length()>0 || sPatientDateOfBirth.trim().length()>0)){
            persons = AdminPerson.getAllPatients("","","",sPatientLastname,sPatientFirstname,sPatientDateOfBirth,"","");
        }
        if(sPatientUID.length()>0 || persons.size()>0 || isNew){
            //Indien er 1 bestaat: automatisch selecteren
            if(sPatientUID.length()>0 || persons.size()==1 || isNew){
                AdminPerson activePerson=new AdminPerson();
              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                if(isNew){
                    if(sPatientUID.length()>0){
                        activePerson = AdminPerson.getAdminPerson(ad_conn,sPatientUID);
                        %>
                        <table width="100%" class="list" border="0">
                            <tr><td class="admin2"><b><%=activePerson.personid%></b></td><td class="admin2"><b><%=activePerson.lastname+ " "+activePerson.firstname+"  °"+activePerson.dateOfBirth+" "+activePerson.gender%></b></td></tr>
                        </table>
                        <table width="100%" class="list" border="0">
                        <%
                    }
                }
                else if(sPatientUID.length()>0 || isFind){
                    if(!isFind){
                        activePerson = AdminPerson.getAdminPerson(ad_conn,sPatientUID);
                    }
                    else {
                        activePerson = (AdminPerson)persons.get(0);
                        sPatientUID=activePerson.personid;
                    }
                %>
                <table width="100%" class="list" border="0">
                    <tr><td class="admin2"><b><%=activePerson.personid%></b></td><td class="admin2"><b><%=activePerson.lastname+ " "+activePerson.firstname+"  °"+activePerson.dateOfBirth+" "+activePerson.gender%></b></td></tr>
                </table>
                <table width="100%" class="list" border="0">
                    <%
                        Vector encounters = Encounter.selectEncounters("", "", "", "", "", "", "", "", activePerson.personid, "");
                        for(int n=0;n<encounters.size();n++){
                            Encounter encounter = (Encounter)encounters.elementAt(n);
                    %>
                    <tr><td class="admin2"><b><a href="<c:url value='/'/>popup.jsp?Page=statistics/quickFile.jsp&PopupHeight=600&PopupWidth=800&EditEncounterUID=<%=encounter.getUid()%>&PatientUID=<%=activePerson.personid%>"/><%=new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin())+" -> "+(encounter.getEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd()))%></b></td><td class="admin2"><b><%=encounter.getService().getLabel(sWebLanguage)+(encounter.getOutcome()==null?"":" ("+getTran("encounter.outcome",encounter.getOutcome(),sWebLanguage)+")")%></b></td></tr>
                    <%
                        }
                    %>
                </table>
                <%
                }
                ad_conn.close();
                if(isNew || sEditEncounterUID.length()>0){
                %>
                <hr/>
                <form name='EditEncounterForm' id="EditEncounterForm" method='POST' action="<c:url value='/'/>popup.jsp?Page=statistics/quickFile.jsp&PopupHeight=600&PopupWidth=800">
                    <input type="hidden" name='ActiveEditEncounterUID' value='<%=sEditEncounterUID%>'>
                    <input type="text" id='a1' name='ap1' value=''>
                    <input type="text" id='a2' name='ap2' value=''>
                    <input type="text" id='a3' name='ap3' value=''>
                    <input type="text" id='a4' name='ap4' value=''>
                    <input type="text" name='saveButtonEncounter' value=''>

                    <table class='list' border='0' width='100%' cellspacing='1'>
                        <%-- type --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","type",sWebLanguage)%></td>
                            <td class='admin2'>
                                <select class='text' name='EditEncounterType' onchange="checkEncounterType();">
                                    <%
                                        String sOptions[] = {"admission","visit"};

                                        for(int i=0;i<sOptions.length;i++){
                                            out.print("<option value='" + sOptions[i] + "' ");
                                            if(sEditEncounterType.equalsIgnoreCase(sOptions[i])){
                                                out.print(" selected");
                                            }
                                            out.print(">" + getTran("web",sOptions[i],sWebLanguage) + "</option>");
                                        }

                                    %>

                                </select>
                            </td>
                        </tr>
                        <%-- date begin --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","begindate",sWebLanguage)%></td>
                            <td class="admin2">
                                <%=writeDateField("EditEncounterBegin","EditEncounterForm",sEditEncounterBegin+"' onchange='setTime(\"EditEncounterBeginHour\")",sWebLanguage)%>
                            </td>
                        </tr>

                        <%-- date end --%>
                        <tr>
                            <td class="admin"><%=getTran("Web","enddate",sWebLanguage)%></td>
                            <td class="admin2">
                                <%=writeDateField("EditEncounterEnd","EditEncounterForm",sEditEncounterEnd+"' onchange='setTime(\"EditEncounterEndHour\")",sWebLanguage)%>
                            </td>
                        </tr>
                         <%-- service --%>
                        <tr id="Service">
                            <td class="admin"><%=getTran("Web","service",sWebLanguage)%></td>
                            <td class='admin2'>
                                <input type="hidden" name="EditEncounterService" value="<%=sEditEncounterService%>">
                                <input class="text" type="text" name="EditEncounterServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterServiceName%>" >
                                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('EditEncounterService','EditEncounterServiceName');">
                                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterService.value='';EditEncounterForm.EditEncounterServiceName.value='';">
                            </td>
                        </tr>
                        <%-- outcome --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","outcome",sWebLanguage)%></td>
                            <td class="admin2">
                                <select class="text" name="EditEncounterOutcome" style="vertical-align:-2px;">
                                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                    <%=ScreenHelper.writeSelectUnsorted("encounter.outcome",sEditEncounterOutcome,sWebLanguage)%>
                                </select>
                            </td>
                        </tr>
                            <tr class="admin">
                                <td align="left" colspan="2"><a href="javascript:openPopup('healthrecord/findICPC.jsp&ts=<%=getTs()%>',700,400)"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
                            </tr>
                            <tr>
                                <td id='icpccodes' colspan="2"/>
                            <tr></tr>
                        <%=ScreenHelper.setFormButtonsStart()%>
                            <input class='button' type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                            <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick='clearFields();'>
                        <%=ScreenHelper.setFormButtonsStop()%>
                        <%-- action, uid --%>
                    </table>
                </form>
                <%
                    }
            }
            else {
                //todo:Indien meer dan 1: laten kiezen uit een lijst
                %>
                <table width="100%" class="list" border="0">
                    <%
                        for(int n=0;n<persons.size();n++){
                            AdminPerson activePerson=(AdminPerson)persons.get(n);
                            %>
                            <tr><td class="admin2"><b><a href="<c:url value='/'/>popup.jsp?Page=statistics/quickFile.jsp&PopupHeight=600&PopupWidth=800&PatientUID=<%=activePerson.personid%>"/><%=activePerson.personid%></a></b></td><td class="admin2"><b><%=activePerson.lastname+ " "+activePerson.firstname+"  °"+activePerson.dateOfBirth+" "+activePerson.gender%></b></td></tr>
                            <%
                        }
                    %>
                </table>
                <%
            }
        }
        else {
            //todo:Indien niet: geen probleem, het is een nieuwe
            sPatientUID="";
            %>
            <script>EditPatientForm.document.all['PatientUID']='';</script>
            <%
        }
    }
%>

<script>
    function clearFields(){
        document.all['EditEncounterService'].value='';
        document.all['EditEncounterServiceName'].value='';
        document.all['EditEncounterBegin'].value='';
        document.all['EditEncounterEnd'].value='';
        document.all['EditEncounterOutcome'].value='none';
        document.all['EditEncounterType'].value='none';
    }

    <%-- search service --%>
    function searchService(serviceUidField,serviceNameField){
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.all[serviceNameField].focus();
    }

    function doSave(){
        EditEncounterForm.document.getElementById('a1').value=EditPatientForm.document.all['patientLastname'].value;
        EditEncounterForm.document.getElementById('a2').value=EditPatientForm.document.all['patientFirstname'].value;
        EditEncounterForm.document.getElementById('a3').value=EditPatientForm.document.all['patientDateOfBirth'].value;
        EditEncounterForm.document.getElementById('a4').value=EditPatientForm.document.all['patientGender'].value;
        EditEncounterForm.document.all['saveButtonEncounter'].value='1';
        EditEncounterForm.submit();
    }
    EditPatientForm.document.all['PatientUID'].value='<%=sPatientUID%>';

    
</script>