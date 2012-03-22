<%@ page import="be.openclinic.finance.Insurance,be.openclinic.finance.InsuranceCategory" %>
<%@include file="/includes/validateUser.jsp"%>
<script>
    function searchInsuranceCategory(){
        openPopup("/_common/search/searchInsuranceCategory.jsp&ts=<%=getTs()%>&VarCode=EditInsuranceCategoryLetter&VarText=EditInsuranceInsurarName&VarCat=EditInsuranceCategory&VarCompUID=EditInsurarUID&VarTyp=EditInsuranceType&VarTypName=EditInsuranceTypeName");
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    function doSave(){
            EditInsuranceForm.EditSaveButton.disabled = true;
            EditInsuranceForm.Action.value = "SAVE";
            EditInsuranceForm.submit();
    }
</script>

<%=checkPermission("financial.insurance","edit",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sEditInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
    String sEditInsurarUID = checkString(request.getParameter("EditInsurarUID"));
    String sEditInsuranceNr = checkString(request.getParameter("EditInsuranceNr"));
    String sEditInsuranceType = checkString(request.getParameter("EditInsuranceType"));
    String sEditInsuranceMember = checkString(request.getParameter("EditInsuranceMember"));
    String sEditInsuranceMemberImmat = checkString(request.getParameter("EditInsuranceMemberImmat"));
    String sEditInsuranceMemberEmployer = checkString(request.getParameter("EditInsuranceMemberEmployer"));
    String sEditInsuranceStatus = checkString(request.getParameter("EditInsuranceStatus"));
    String sEditInsuranceStart = checkString(request.getParameter("EditInsuranceStart"));
    if(sEditInsuranceStart.length()==0){
        sEditInsuranceStart=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    }
    String sEditInsuranceStop = checkString(request.getParameter("EditInsuranceStop"));
    String sEditInsuranceCategoryLetter = checkString(request.getParameter("EditInsuranceCategoryLetter"));
    String sEditInsuranceCategory = "";
    String sEditInsuranceInsurarName = "";
    String sEditInsuranceComment = checkString(request.getParameter("EditInsuranceComment"));

    if (sAction.equals("SAVE")) {
        if(sEditInsuranceCategoryLetter.length()==0){
            sEditInsurarUID="";
        }
        Insurance insurance = new Insurance();
        if (sEditInsuranceUID.length() > 0) {
            insurance = Insurance.get(sEditInsuranceUID);
        } else {
            insurance.setCreateDateTime(getSQLTime());
        }

        if (sEditInsuranceStart.length() > 0) {
            insurance.setStart(new Timestamp(ScreenHelper.getSQLDate(sEditInsuranceStart).getTime()));
        }
        if (sEditInsuranceStop.length() > 0) {
            insurance.setStop(new Timestamp(ScreenHelper.getSQLDate(sEditInsuranceStop).getTime()));
        }
        insurance.setInsuranceNr(sEditInsuranceNr);
        insurance.setType(sEditInsuranceType);
        insurance.setMember(sEditInsuranceMember);
        insurance.setMemberImmat(sEditInsuranceMemberImmat);
        insurance.setMemberEmployer(sEditInsuranceMemberEmployer);
        insurance.setStatus(sEditInsuranceStatus);
        insurance.setInsuranceCategoryLetter(sEditInsuranceCategoryLetter);
        insurance.setComment(new StringBuffer(sEditInsuranceComment));
        insurance.setUpdateDateTime(getSQLTime());
        insurance.setUpdateUser(activeUser.userid);
        insurance.setPatientUID(activePatient.personid);
        insurance.setInsurarUid(sEditInsurarUID);
        insurance.store();
        out.println("<script>doSearchBack();</script>");
        out.flush();
    }

    if (sEditInsuranceUID.length() > 0) {
        Insurance insurance = Insurance.get(sEditInsuranceUID);

        sEditInsuranceNr = insurance.getInsuranceNr();
        sEditInsuranceType = insurance.getType();
        sEditInsuranceMember = insurance.getMember();
        sEditInsuranceMemberImmat = insurance.getMemberImmat();
        sEditInsuranceMemberEmployer = insurance.getMemberEmployer();
        sEditInsuranceStatus = insurance.getStatus();
        sEditInsuranceCategoryLetter = insurance.getInsuranceCategoryLetter();
        sEditInsurarUID = insurance.getInsurarUid();
        InsuranceCategory insuranceCategory = InsuranceCategory.get(insurance.getInsurarUid(),sEditInsuranceCategoryLetter);
        if(insuranceCategory.getLabel().length()>0){
            sEditInsuranceInsurarName = insuranceCategory.getInsurar().getName();
            sEditInsuranceCategory = insuranceCategory.getCategory()+": "+insuranceCategory.getLabel();
        }
        if (insurance.getStart() != null) {
            sEditInsuranceStart = new SimpleDateFormat("dd/MM/yyyy").format(insurance.getStart());
        } else {
            sEditInsuranceStart = "";
        }
        if (insurance.getStop() != null) {
            sEditInsuranceStop = new SimpleDateFormat("dd/MM/yyyy").format(insurance.getStop());
        } else {
            sEditInsuranceStop = "";
        }

        sEditInsuranceComment = insurance.getComment().toString();
    }
%>
<form name="EditInsuranceForm" id="EditInsuranceForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/insurance/editInsurance.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="EditInsuranceUID" value="<%=sEditInsuranceUID%>"/>
    <%=writeTableHeader("insurance","manageInsurance",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- insurancenr --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("insurance","insurancenr",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="EditInsuranceNr" value="<%=sEditInsuranceNr%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
            <%-- member --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("insurance","status",sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class="text" name="EditInsuranceStatus" id="EditInsuranceStatus" onchange="setStatus();">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("insurance.status",sEditInsuranceStatus,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("insurance","member",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="EditInsuranceMember" id="EditInsuranceMember" value="<%=sEditInsuranceMember%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("insurance","memberimmat",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="EditInsuranceMemberImmat" id="EditInsuranceMemberImmat" value="<%=sEditInsuranceMemberImmat%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("insurance","memberemployer",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="EditInsuranceMemberEmployer" value="<%=sEditInsuranceMemberEmployer%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        <%-- company --%>
            <tr>
                <td class="admin">
                    <%=getTran("web","company",sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input type="hidden" name="EditInsurarUID" value="<%=sEditInsurarUID%>"/>
                    <input class="text" type="text" readonly name="EditInsuranceInsurarName" value="<%=sEditInsuranceInsurarName%>" size="<%=sTextWidth%>"/>
                    <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsuranceCategory();">
                    <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditInsuranceForm.EditInsuranceInsurarName.value='';EditInsuranceForm.EditInsuranceCategory.value='';EditInsuranceForm.EditInsuranceCategoryLetter.value='';">
                </td>
            </tr>
            <tr>
                <td class="admin">
                    <%=getTran("web","category",sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input type="hidden" name="EditInsuranceCategoryLetter" value="<%=sEditInsuranceCategoryLetter%>"/>
                    <input class="text" type="text" readonly name="EditInsuranceCategory" value="<%=sEditInsuranceCategory%>" size="<%=sTextWidth%>"/>
                </td>
            </tr>
        <%-- type --%>
        <tr>
            <td class="admin">
                <%=getTran("web","tariff",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="hidden" name="EditInsuranceType" value="<%=sEditInsuranceType%>"/>
                <input class="text" type="text" readonly name="EditInsuranceTypeName" value="<%=sEditInsuranceType.length()>0?getTran("insurance.types",sEditInsuranceType,sWebLanguage):""%>" size="<%=sTextWidth%>" readonly/>
            </td>
        </tr>
        <%-- start --%>
        <tr>
            <td class="admin">
                <%=getTran("web","start",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=writeDateField("EditInsuranceStart","EditInsuranceForm",sEditInsuranceStart,sWebLanguage)%>
            </td>
        </tr>
        <%-- stop --%>
        <tr>
            <td class="admin">
                <%=getTran("web","stop",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=writeDateField("EditInsuranceStop","EditInsuranceForm",sEditInsuranceStop,sWebLanguage)%>
            </td>
        </tr>
        <%-- comment --%>
        <tr>
            <td class="admin">
                <%=getTran("web","comment",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=writeTextarea("EditInsuranceComment","69","4","",sEditInsuranceComment)%>
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class='button' type="button" name="EditSaveButton" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doSearchBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <input type="hidden" name="Action" value="">
</form>
<script>
	function setStatus(){
    	if(document.getElementById("EditInsuranceStatus").value=="affiliate"){
        	document.getElementById("EditInsuranceMember").value="<%=activePatient.firstname+" "+activePatient.lastname.toUpperCase()%>";
        	document.getElementById("EditInsuranceMemberImmat").value="<%=activePatient.getID("immatnew")%>";
    	}
	}
</script>

