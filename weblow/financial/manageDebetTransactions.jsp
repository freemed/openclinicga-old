<%@ page import="be.openclinic.finance.DebetTransaction,
                 be.openclinic.finance.Balance,
                 be.openclinic.adt.Encounter,
                 be.openclinic.finance.Prestation,
                 be.openclinic.common.ObjectReference"%>
<%@ page import="be.openclinic.system.Examination" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@ page import="be.openclinic.pharmacy.ProductStockOperation" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("financial.debettransaction","edit",activeUser)%>

<%
    String sEditDebetBalanceUID     = checkString(request.getParameter("EditDebetBalanceUID"));
    String sAction = checkString(request.getParameter("Action"));

    String sEditDebetAmount         = checkString(request.getParameter("EditDebetAmount"));
    String sEditDebetDate           = checkString(request.getParameter("EditDebetDate"));
    String sEditDebetDescription    = checkString(request.getParameter("EditDebetDescription"));
    String sEditDebetEncounterUID   = checkString(request.getParameter("EditDebetEncounterUID"));
    String sEditDebetEncounterName;
    String sEditDebetPrestationUID  = checkString(request.getParameter("EditDebetPrestationUID"));
    String sEditDebetPrestationName;
    String sEditDebetSupplierUID    = checkString(request.getParameter("EditDebetSupplierUID"));
    String sEditDebetSupplierName;
    String sEditDebetSupplierType   = checkString(request.getParameter("EditDebetSupplierType"));
    String sEditDebetRefUID         = checkString(request.getParameter("EditDebetRefUID"));
    String sEditDebetRefName;
    String sEditDebetRefType        = checkString(request.getParameter("EditDebetRefType"));
    String sEditDebetUID            = checkString(request.getParameter("EditDebetUID"));
    String sEditCheckTransaction = "";
    String sEditCheckPrescription = "";

    if(sAction.equals("SAVE")){
        Encounter encounter = Encounter.get(sEditDebetEncounterUID);
        DebetTransaction debet= new DebetTransaction();

        if(sEditDebetUID.length() > 0){
            debet = DebetTransaction.get(sEditDebetUID);
        }else{
            debet.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        debet.setAmount(Double.parseDouble(sEditDebetAmount));
        debet.setDescription(sEditDebetDescription);
        debet.setDate(ScreenHelper.getSQLDate(sEditDebetDate));
        debet.setBalance(Balance.get(sEditDebetBalanceUID));
        debet.setEncounter(encounter);
        debet.setPrestation(Prestation.get(sEditDebetPrestationUID));

        ObjectReference or = new ObjectReference();
        or.setObjectType(sEditDebetSupplierType);
        or.setObjectUid(sEditDebetSupplierUID);
        debet.setSupplier(or);

        ObjectReference or1 = new ObjectReference();
        or1.setObjectType(sEditDebetRefType);
        or1.setObjectUid(sEditDebetRefUID);
        debet.setReferenceObject(or1);
        debet.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        debet.setUpdateUser(activeUser.userid);
        debet.store();
        %>
        <script>
            window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
        </script>
        <%
    }

    Encounter encounter;
    Prestation prestation;
    if (sEditDebetUID.length() > 0) {
        DebetTransaction debet = DebetTransaction.get(sEditDebetUID);
        sEditDebetAmount = checkString(Double.toString(debet.getAmount()));
        sEditDebetBalanceUID = checkString(debet.getBalance().getUid());
        sEditDebetDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()));
        sEditDebetDescription = checkString(debet.getDescription());
        sEditDebetEncounterUID = "";
        sEditDebetEncounterName = "";
        sEditDebetPrestationName="";
        prestation = debet.getPrestation();
        if (prestation != null) {
            sEditDebetPrestationName = prestation.getDescription();
        } else {
            sEditDebetPrestationName = "";
        }
        sEditDebetSupplierUID = checkString(debet.getSupplier().getObjectUid());
        sEditDebetSupplierType = checkString(debet.getSupplier().getObjectType());
        sEditDebetSupplierName = getObjectReferenceName(debet.getSupplier(), sWebLanguage);
        sEditDebetRefUID = checkString(debet.getReferenceObject().getObjectUid());
        sEditDebetRefName = checkString(debet.getReferenceObject().getObjectUid());
        sEditDebetRefType = checkString(debet.getReferenceObject().getObjectType());
        if (sEditDebetRefType.equalsIgnoreCase("Transaction")) {
            sEditCheckTransaction = " checked";
        } else if (sEditDebetRefType.equalsIgnoreCase("MedicationDelivery")) {
            sEditCheckPrescription = " checked";
            sEditDebetRefName = ProductStockOperation.get(debet.getReferenceObject().getObjectUid()).getProductStock().getProduct().getName();
        }

        encounter = debet.getEncounter();
    } else {

        if (sEditDebetBalanceUID.length() == 0) {
            sEditDebetBalanceUID = Balance.getActiveBalance(activePatient.personid).getUid();
        }
        sEditDebetAmount = "";
        sEditDebetDate = getDate();
        sEditDebetDescription = "";
        sEditDebetEncounterUID = "";
        sEditDebetEncounterName = "";
        sEditDebetPrestationUID = "";
        sEditDebetPrestationName = "";
        sEditDebetSupplierUID = "";
        sEditDebetSupplierType = "";
        sEditDebetSupplierName = "";
        sEditDebetRefUID = "";
        sEditDebetRefName = "";
        sEditDebetRefType = "";

        encounter = Encounter.getActiveEncounter(activePatient.personid);

        if (encounter==null){
            encounter = new Encounter();
        }
        prestation = null;
    }

    if (checkString(sEditDebetBalanceUID).length()>0) {
        if (encounter!=null) {
            sEditDebetEncounterUID = checkString(encounter.getUid());
            String sType = "", sBegin = "", sEnd = "";

            if (checkString(encounter.getType()).length() > 0) {
                sType = ", " + getTran("encountertype", encounter.getType(), sWebLanguage);
            }

            if (encounter.getBegin() != null) {
                sBegin = ", " + getSQLTimeStamp(new Timestamp(encounter.getBegin().getTime()));
            }

            if (encounter.getEnd() != null) {
                sEnd = ", " + getSQLTimeStamp(new Timestamp(encounter.getEnd().getTime()));
            }
            sEditDebetEncounterName = sEditDebetEncounterUID + sBegin + sEnd + sType;
        }
%>
<%ScreenHelper.setIncludePage(customerInclude("curative/financialStatus.jsp"),pageContext);%>
<form name='EditForm' id="EditForm" method='POST' action="<c:url value='/main.do'/>?Page=financial/manageDebetTransactions.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("balance","edit_debet",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- date --%>
        <tr>
            <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%> *</td>
            <td class='admin2'><%=writeDateField("EditDebetDate","EditForm",sEditDebetDate,sWebLanguage)%></td>
        </tr>
        <%-- amount --%>
        <tr>
            <td class='admin'><%=getTran("web","amount",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input class='text' type='text' name='EditDebetAmount' value='<%=sEditDebetAmount%>' size='20' onblur="isNumberNegAndPos(this)"> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        <%-- prestation --%>
        <tr>
            <td class='admin'>
               <%=getTran("web","prestation",sWebLanguage)%>
            </td>
            <td class='admin2'>
                <input type="hidden" name="EditDebetPrestationUID" value="<%=sEditDebetPrestationUID%>">
                <input class="text" type="text" name="EditDebetPrestationName" readonly size="<%=sTextWidth%>" value="<%=sEditDebetPrestationName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation('EditDebetPrestationUID','EditDebetPrestationName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditForm.EditDebetPrestationUID.value='';EditForm.EditDebetPrestationName.value='';">
            </td>
        </tr>
        <%-- description --%>
        <tr>
            <td class='admin'><%=getTran("web","description",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditDebetDescription","","","",sEditDebetDescription)%></td>
        </tr>
        <%-- encounter --%>
        <tr>
            <td class='admin'><%=getTran("web","encounter",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="EditDebetEncounterUID" value="<%=sEditDebetEncounterUID%>">
                <input class="text" type="text" name="EditDebetEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditDebetEncounterName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditDebetEncounterUID','EditDebetEncounterName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditForm.EditDebetEncounterUID.value='';EditForm.EditDebetEncounterName.value='';">
            </td>
        </tr>

        <%-- suppliertype --%>
        <tr>
            <td class='admin'><%=getTran("web","suppliertype",sWebLanguage)%></td>
            <td class='admin2'>
                <%
                    String sEditCheckPerson  = "";
                    String sEditCheckService = "";
                    if(sEditDebetSupplierType.equalsIgnoreCase("person")){
                        sEditCheckPerson = " checked";
                    }else if(sEditDebetSupplierType.equalsIgnoreCase("service")){
                        sEditCheckService = " checked";
                    }
                %>
                <input type='radio' name='EditDebetSupplierType' id='Editperson' value='Person' onclick='changeEditType();' <%=sEditCheckPerson%>><label for='Editperson'><%=getTran("web","person",sWebLanguage)%></label>
                <input type='radio' name='EditDebetSupplierType' id='Editservice' value='Service' onclick='changeEditType();' <%=sEditCheckService%>><label for='Editservice'><%=getTran("web","service",sWebLanguage)%></label>
            </td>
        </tr>
        <%-- supplier --%>
        <tr>
            <td class='admin'>
                <div id='EditTypeLabel'/>
            </td>
            <td class='admin2'>
                <input type="hidden" name="EditDebetSupplierUID" value="<%=sEditDebetSupplierUID%>">
                <input class="text" type="text" name="EditDebetSupplierName" readonly size="<%=sTextWidth%>" value="<%=sEditDebetSupplierName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchSupplier('EditDebetSupplierUID','EditDebetSupplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditForm.EditDebetSupplierUID.value='';EditForm.EditDebetSupplierName.value='';">
            </td>
        </tr>

        <%
            if (sEditDebetRefName.length()>0){
        %>
        <tr>
            <td class='admin'><%=getTran("web","reftype",sWebLanguage)%></td>
            <td class='admin2'>

                <input onclick="setRefCheck();" type='radio' name='EditDebetRefType' id='EditReftransaction' readonly value='Transaction' <%=sEditCheckTransaction%>><label for='EditReftransaction'><%=getTran("web","transaction",sWebLanguage)%></label>
                <input onclick="setRefCheck();" type='radio' name='EditDebetRefType' id='EditRefprescription' readonly value='MedicationDelivery' <%=sEditCheckPrescription%>><label for='EditRefprescription'><%=getTran("web","prescription",sWebLanguage)%></label>
                <script type="text/javascript">
                    function setRefCheck(){
                        if('<%=sEditCheckTransaction.length()%>'.length>0){
                            document.all['EditReftransaction'].checked=true;
                        }
                        else {
                            document.all['EditRefprescription'].checked=true;
                        }
                    }
                </script>
            </td>
        </tr>
        <%-- Reference --%>
        <tr>
            <td class='admin'>
                <div id='EditRefTypeLabel'/>
            </td>
            <td class='admin2'>
                <input type="hidden" name="EditDebetRefUID" value="<%=sEditDebetRefUID%>">
                <input class="text" type="text" name="EditDebetRefName" readonly size="<%=sTextWidth%>" value="<%=sEditDebetRefName%>">
            </td>
        </tr>
        <script>
             if(EditForm.EditDebetRefName.value == ""){
                document.getElementById("EditReftransaction").checked = true;
                document.getElementById("EditRefTypeLabel").innerText = "<%=getTran("Web","transaction",sWebLanguage)%>";
            }else{
                if(document.getElementById("EditReftransaction").checked == true){
                    document.getElementById("EditRefTypeLabel").innerText = "<%=getTran("Web","transaction",sWebLanguage)%>";
                }else{
                    document.getElementById("EditRefTypeLabel").innerText = "<%=getTran("Web","prescription",sWebLanguage)%>";
                }
            }
        </script>
        <%
            }
        %>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%-- Buttons --%>
                <input class='button' type="button" name="buttonSave" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                <input class='button' type="button" name="buttonBack" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>.
    <input type='hidden' name='Action' value=''>
    <input type='hidden' name='EditDebetUID' value='<%=sEditDebetUID%>'>
    <input type='hidden' name='EditDebetBalanceUID' value='<%=sEditDebetBalanceUID%>'>
</form>
<script>

    EditForm.EditDebetDate.focus();
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
    }

    function doSave(){
        if ((EditForm.EditDebetDate.value.length>0)&&(EditForm.EditDebetAmount.value.length>0)){
            EditForm.buttonSave.disabled = true;
            EditForm.Action.value = "SAVE";
            EditForm.submit();
        }
        else {
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
        }
    }

    function searchEncounter(encounterUidField,encounterNameField){
        openPopup("/_common/search/searchEncounter.jsp&FindEncounterPatient=<%=activePatient.personid%>&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField);
    }

    function changeEditType(){
        if(document.getElementById("Editperson").checked == true){
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }else{
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
        }
        EditForm.EditDebetSupplierUID.value = "";
        EditForm.EditDebetSupplierName.value = "";
    }

    function changeEditRefType(){
        if(document.getElementById("EditRefperson").checked){
             document.getElementById("EditRefTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }else{
             document.getElementById("EditRefTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
        }
        EditForm.EditDebetRefUID.value = "";
        EditForm.EditDebetRefName.value = "";
    }

    function searchSupplier(supplierUidField,supplierNameField){
        if(document.getElementById("Editperson").checked == true){
            openPopup("/financial/searchFinancialPerson.jsp&ts=<%=getTs()%>&ReturnPersonID="+supplierUidField+"&ReturnName="+supplierNameField+"&activeBalanceID=<%=sEditDebetBalanceUID%>");
        }else if(document.getElementById("Editservice").checked == true){
            openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+supplierUidField+"&VarText="+supplierNameField);
        }
    }

    if(EditForm.EditDebetSupplierName.value == ""){
        document.getElementById("Editperson").checked = true;
        document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
    }else{
        if(document.getElementById("Editperson").checked == true){
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }else{
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
        }
    }

    function searchPrestation(prestationUidField,prestationNameField){
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid="+prestationUidField+"&ReturnFieldDescr="+prestationNameField);
    }

    function changePrestationType(){
        EditForm.EditDebetPrestationUID.value = "";
        EditForm.EditDebetPrestationName.value = "";
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