<%@ page import="be.openclinic.finance.Insurance,be.openclinic.finance.InsuranceCategory,be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<script>
	function searchInsuranceCategory(){
	    openPopup("/_common/search/searchInsuranceCategory.jsp&ts=<%=getTs()%>&VarCode=EditInsuranceCategoryLetter&VarText=EditInsuranceInsurarName&VarCat=EditInsuranceCategory&VarCompUID=EditInsurarUID&VarTyp=EditInsuranceType&VarTypName=EditInsuranceTypeName&VarFunction=checkInsuranceAuthorization()");
	}
	
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    function doSave(){
    	if("<%=MedwanQuery.getInstance().getConfigString("InsuranceAgentAuthorizationNeededFor","$$").replaceAll("\\*","")%>"==document.getElementById('EditInsurarUID').value && document.getElementById('EditInsuranceNr').value==''){
    		alert("<%=getTranNoLink("web","insurancenr.mandatory",sWebLanguage)%>");
    	}
    	else if("<%=MedwanQuery.getInstance().getConfigString("InsuranceAgentAuthorizationNeededFor","$$").replaceAll("\\*","")%>"==document.getElementById('EditInsurarUID').value && document.getElementById('EditInsuranceStatus').value==''){
    		alert("<%=getTranNoLink("web","insurancestatus.mandatory",sWebLanguage)%>");
    	}
    	else {
            EditInsuranceForm.EditSaveButton.disabled = true;
            EditInsuranceForm.Action.value = "SAVE";
            EditInsuranceForm.submit();
        }
    }
</script>

<%=checkPermission("financial.insurance","edit",activeUser)%>

<%
	
    String sAction = checkString(request.getParameter("Action"));

	String sEditInsuranceUID = checkString(request.getParameter("EditInsuranceUID"));
    String sEditInsurarUID = checkString(request.getParameter("EditInsurarUID"));
	String sEditExtraInsurarUID = checkString(request.getParameter("EditExtraInsurarUID"));
	String sEditExtraInsurarUID2 = checkString(request.getParameter("EditExtraInsurarUID2"));
    String sEditInsuranceNr = checkString(request.getParameter("EditInsuranceNr"));
    String sEditInsuranceType = checkString(request.getParameter("EditInsuranceType"));
    String sEditInsuranceMember = checkString(request.getParameter("EditInsuranceMember"));
    String sEditInsuranceMemberImmat = checkString(request.getParameter("EditInsuranceMemberImmat"));
    String sEditInsuranceMemberEmployer = checkString(request.getParameter("EditInsuranceMemberEmployer"));
    String sEditInsuranceStatus = checkString(request.getParameter("EditInsuranceStatus"));
    String sEditAuthorization = checkString(request.getParameter("EditAuthorization"));
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
        insurance.setExtraInsurarUid(sEditExtraInsurarUID);
        insurance.setExtraInsurarUid2(sEditExtraInsurarUID2);
        insurance.store();
        if(sEditAuthorization.length()>0){
        	Pointer.storePointer("AUTH."+sEditInsurarUID+"."+activePatient.personid+"."+new SimpleDateFormat("yyyyMM").format(new java.util.Date()), new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date(new java.util.Date().getTime()+24*3600*1000))+";"+activeUser.userid);
        }
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
        sEditExtraInsurarUID = insurance.getExtraInsurarUid();
        sEditExtraInsurarUID2 = insurance.getExtraInsurarUid2();
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
                <input class="text" type="text" name="EditInsuranceNr" id="EditInsuranceNr" value="<%=sEditInsuranceNr%>" size="<%=sTextWidth%>"/>
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
<%
	if(MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("openpharmacy")||MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("openinsurance")){
%>
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
 <%
	}
 %>
        <%-- company --%>
            <tr>
                <td class="admin">
                    <%=getTran("web","company",sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input type="hidden" name="EditInsurarUID" id="EditInsurarUID" value="<%=sEditInsurarUID%>"/>
                    <input class="text" type="text" readonly name="EditInsuranceInsurarName" value="<%=sEditInsuranceInsurarName%>" size="<%=sTextWidth%>"/>
                    <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsuranceCategory();">
                    <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditInsuranceForm.EditInsuranceInsurarName.value='';EditInsuranceForm.EditInsuranceCategory.value='';EditInsuranceForm.EditInsuranceCategoryLetter.value='';checkInsuranceAuthorization()">
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
        <tr>
            <td class="admin">
                <%=getTran("web","complementarycoverage",sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class="text" name="EditExtraInsurarUID" id="EditExtraInsurarUID">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("patientsharecoverageinsurance",sEditExtraInsurarUID,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%
        	if(MedwanQuery.getInstance().getConfigInt("enableComplementaryInsurance2",0)==1){
        %>
        <tr>
            <td class="admin">
                <%=getTran("web","complementarycoverage2",sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class="text" name="EditExtraInsurarUID2" id="EditExtraInsurarUID2">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("patientsharecoverageinsurance2",sEditExtraInsurarUID2,sWebLanguage)%>
                </select>
            </td>
        </tr>
		<%
        	}
		%>        
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
        <tr id='authorization'></tr>
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
	
	function checkInsuranceAuthorization(){
        var params = "insuraruid=" + EditInsuranceForm.EditInsurarUID.value
              +"&personid=<%=activePatient.personid%>"
              +"&language=<%=sWebLanguage%>"
              +"&userid=<%=activeUser.userid%>";
        var today = new Date();
        var url= '<c:url value="/financial/checkInsuranceAuthorization.jsp"/>?ts='+today;
		new Ajax.Request(url,{
				method: "POST",
                parameters: params,
                onSuccess: function(resp){
                    $('authorization').innerHTML=resp.responseText;
                },
				onFailure: function(){
					alert('error');
                }
			}
		);
	}

	checkInsuranceAuthorization();

</script>

