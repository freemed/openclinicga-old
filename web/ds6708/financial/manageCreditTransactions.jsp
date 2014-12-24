<%@ page import="be.openclinic.finance.CreditTransaction,
                 be.openclinic.finance.Balance,
                 be.openclinic.adt.Encounter,
                 be.openclinic.common.ObjectReference"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.credittransaction","edit",activeUser)%>
<%
    String sEditCreditBalanceUID = checkString(request.getParameter("EditCreditBalanceUID"));
    String sAction = checkString(request.getParameter("Action"));

    String sEditCreditAmount = checkString(request.getParameter("EditCreditAmount"));
    String sEditCreditDescription = checkString(request.getParameter("EditCreditDescription"));
    String sEditCreditType = checkString(request.getParameter("EditCreditType"));
    String sEditCreditDate  = checkString(request.getParameter("EditCreditDate"));
    String sEditCreditEncounterUID = checkString(request.getParameter("EditCreditEncounterUID"));
    String sEditCreditEncounterName;
    String sEditCreditSourceType = checkString(request.getParameter("EditCreditSourceType"));
    String sEditCreditSourceUID = checkString(request.getParameter("EditCreditSourceUID"));
    String sEditCreditSourceName;
    String sEditCreditUID = checkString(request.getParameter("EditCreditUID"));

    if(sAction.equals("SAVE")){
        CreditTransaction credit = new CreditTransaction();
        if(sEditCreditUID.length() > 0){
            credit = CreditTransaction.get(sEditCreditUID);
        }else{
            credit.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        if (sEditCreditAmount.length()==0){
            sEditCreditAmount = "0";
        }
        credit.setAmount(Double.parseDouble(sEditCreditAmount));
        credit.setDate(ScreenHelper.getSQLDate(sEditCreditDate));
        credit.setBalance(Balance.get(sEditCreditBalanceUID));
        credit.setDescription(sEditCreditDescription);
        credit.setType(sEditCreditType);
        credit.setEncounter(Encounter.get(sEditCreditEncounterUID));
        ObjectReference or = new ObjectReference();
        or.setObjectType(sEditCreditSourceType);
        or.setObjectUid(sEditCreditSourceUID);
        credit.setSource(or);
        credit.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        credit.setUpdateUser(activeUser.userid);
        credit.store();
        %>
        <script>
            window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
        </script>
        <%
    }
    Encounter encounter;
    if(sEditCreditUID.length() > 0){
        CreditTransaction credit = CreditTransaction.get(sEditCreditUID);
        sEditCreditUID          = credit.getUid();
        sEditCreditAmount       = Double.toString(credit.getAmount());
        sEditCreditDate         = checkString(ScreenHelper.stdDateFormat.format(credit.getDate()));
        sEditCreditBalanceUID   = credit.getBalance().getUid();
        sEditCreditEncounterUID = "";
        sEditCreditEncounterName= "";
        sEditCreditDescription  = credit.getDescription();
        sEditCreditType         = credit.getType();
        sEditCreditSourceUID    = credit.getSource().getObjectUid();
        sEditCreditSourceType   = credit.getSource().getObjectType();
        sEditCreditSourceName = getObjectReferenceName(credit.getSource(),sWebLanguage);
        encounter = credit.getEncounter();
    }else{
         if (sEditCreditBalanceUID.length()==0){
            sEditCreditBalanceUID = Balance.getActiveBalance(activePatient.personid).getUid();
        }
        sEditCreditUID          = "";
        sEditCreditAmount       = "";
        sEditCreditDate         = getDate();
        sEditCreditEncounterUID = "";
        sEditCreditEncounterName= "";
        sEditCreditDescription  = "";
        sEditCreditType         = "";
        sEditCreditSourceUID    = activePatient.personid;
        sEditCreditSourceType   = "person";
        sEditCreditSourceName   = activePatient.lastname+" "+activePatient.firstname;

        encounter = Encounter.getActiveEncounter(activePatient.personid);
        if (encounter==null){
            encounter = new Encounter();
        }

    }
    if (checkString(sEditCreditBalanceUID).length()>0) {
        if (encounter!=null) {
            sEditCreditEncounterUID = checkString(encounter.getUid());
            String sType = "", sBegin = "", sEnd = "";
            if (checkString(encounter.getType()).length()>0){
                sType = ", "+getTran("encountertype",encounter.getType(),sWebLanguage);
            }

            if (encounter.getBegin()!=null){
                sBegin = ", "+getSQLTimeStamp(new Timestamp(encounter.getBegin().getTime()));
            }

            if (encounter.getEnd()!=null){
                sEnd = ", "+getSQLTimeStamp(new Timestamp(encounter.getEnd().getTime()));
            }
            sEditCreditEncounterName = sEditCreditEncounterUID+sBegin+sEnd+sType;
        }
%>
<%ScreenHelper.setIncludePage(customerInclude("curative/financialStatus.jsp"),pageContext);%>
<form name='EditForm' id="EditForm" method='POST' action="<c:url value='/main.do'/>?Page=financial/manageCreditTransactions.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("balance","edit_credit",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- date --%>
        <tr>
            <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%></td>
            <td class='admin2'><%=writeDateField("EditCreditDate","EditForm",sEditCreditDate,sWebLanguage)%></td>
        </tr>
        <%-- bedrag --%>
        <tr>
            <td class='admin'><%=getTran("web","amount",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditCreditAmount' value='<%=sEditCreditAmount%>' size='20' onblur="isNumberNegAndPos(this)">  <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        <%-- omschrijving --%>
        <tr>
            <td class='admin'><%=getTran("web","description",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditCreditDescription","","","",sEditCreditDescription)%></td>
        </tr>
        <%-- type betaling --%>
        <tr>
            <td class='admin'><%=getTran("web","type",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name='EditCreditType'>
                <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("credit.type",sEditCreditType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%-- encounter --%>
        <tr>
            <td class='admin'><%=getTran("web","encounter",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="EditCreditEncounterUID" value="<%=sEditCreditEncounterUID%>">
                <input class="text" type="text" name="EditCreditEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditCreditEncounterName%>">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditCreditEncounterUID','EditCreditEncounterName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditEncounterUID.value='';EditForm.EditCreditEncounterName.value='';">
            </td>
        </tr>
        <%-- sourcetype --%>
        <tr>
            <td class='admin'><%=getTran("web","sourcetype",sWebLanguage)%></td>
            <td class='admin2'>
                <%
                    String sEditCheckPatient  = "";
                    String sEditCheckService = "";
                    if(sEditCreditSourceType.equalsIgnoreCase("Person")){
                        sEditCheckPatient = " checked";
                    }else if(sEditCreditSourceType.equalsIgnoreCase("Service")){
                        sEditCheckService = " checked";
                    }
                %>
                <input type='radio' name='EditCreditSourceType' id='Editperson' value='Person' onclick='changeEditType();' <%=sEditCheckPatient%>><label for='Editperson'><%=getTran("web","person",sWebLanguage)%></label>
                <input type='radio' name='EditCreditSourceType' id='Editservice' value='Service' onclick='changeEditType();' <%=sEditCheckService%>><label for='Editservice'><%=getTran("web","service",sWebLanguage)%></label>
            </td>
        </tr>
        <%-- source --%>
        <tr>
            <td class='admin'>
                <div id='EditTypeLabel'/>
            </td>
            <td class='admin2'>
                <input type="hidden" name="EditCreditSourceUID" value="<%=sEditCreditSourceUID%>">
                <input class="text" type="text" name="EditCreditSourceName" readonly size="<%=sTextWidth%>" value="<%=sEditCreditSourceName%>">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEditCreditSource('EditCreditSourceUID','EditCreditSourceName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditSourceUID.value='';EditForm.EditCreditSourceName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%-- Buttons --%>
                <input class='button' type="button" name="buttonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                <input class='button' type="button" name="buttonBack" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    <input type='hidden' name='Action' value=''>
    <input type='hidden' name='EditCreditUID' value='<%=sEditCreditUID%>'>
    <input type='hidden' name='EditCreditBalanceUID' value='<%=sEditCreditBalanceUID%>'>
</form>
<script>
    EditForm.EditCreditDate.focus();
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
    }

    function doSave(){
        EditForm.buttonSave.disabled = true;
        EditForm.Action.value = "SAVE";
        EditForm.submit();
    }

    function searchEncounter(encounterUidField,encounterNameField){
        openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=activePatient.personid%>");
    }

    function changeEditType(){
        EditForm.EditCreditSourceUID.value = "";
        EditForm.EditCreditSourceName.value = "";

        if(document.getElementById("Editperson").checked == true){
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
            EditForm.EditCreditSourceUID.value ="<%=activePatient.personid%>";
            EditForm.EditCreditSourceName.value ="<%=activePatient.lastname+" "+activePatient.firstname%>";
        }else{
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
            <%
            Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
            Service service = null;

            if (activeEncounter!=null){
                service = activeEncounter.getService();

                if (service!=null){
                %>
            EditForm.EditCreditSourceUID.value = "<%=service.code%>";
            EditForm.EditCreditSourceName.value = "<%=getTranDb("service",service.code,sWebLanguage)%>";
                <%
                }
            }
            %>
        }
    }

    function searchEditCreditSource(sourceUidField,sourceNameField){
        if(document.getElementById("Editperson").checked == true){
            openPopup("/financial/searchFinancialPerson.jsp&ts=<%=getTs()%>&ReturnPersonID="+sourceUidField+"&ReturnName="+sourceNameField+"&activeBalanceID=<%=sEditCreditBalanceUID%>");
        }else if(document.getElementById("Editservice").checked == true){
            openPopup("/financial/searchFinancialService.jsp&ts=<%=getTs()%>&activeBalanceID=<%=sEditCreditBalanceUID%>&VarCode="+sourceUidField+"&VarText="+sourceNameField);
        }
    }

    if(EditForm.EditCreditSourceName.value == ""){
        document.getElementById("Editperson").checked = true;
        document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
    }else{
        if(document.getElementById("Editperson").checked == true){
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }else{
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
        }
    }

    function isNumberNegAndPos(sObject){
        if(sObject.value==0) return false;
        sObject.value = sObject.value.replace(",",".");
        if(sObject.value.charAt(0) == "-"){
            sObject.value = sObject.value.substring(1,sObject.value.length);
        }
        sObject.value = sObject.value.replace("-","");
        var string = sObject.value;
        var vchar = "01234567890.";
        var dotCount = 0;

        for(var i=0; i < string.length; i++){
            if (vchar.indexOf(string.charAt(i)) == -1)	{
                sObject.value = "";
                //sObject.focus();
                return false;
            }
            else{
                if(string.charAt(i)=="."){
                    dotCount++;
                    if(dotCount > 1){
                        sObject.value = "";
                        //sObject.focus();
                        return false;
                    }
                }
            }
        }

        if(sObject.value.length > 250){
            sObject.value = sObject.value.substring(0,249);
        }

        return true;
    }
</script>
<%
    }
    else {
        ScreenHelper.setIncludePage(customerInclude("/financial/editBalance.jsp"), pageContext);
    }
%>