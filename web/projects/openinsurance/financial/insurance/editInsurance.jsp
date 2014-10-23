<%@page import="be.openclinic.finance.Insurance,
                be.openclinic.finance.InsuranceCategory"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.insurance","edit",activeUser)%>

<script>
  function searchInsuranceCategory(){
    openPopup("/_common/search/searchInsuranceCategory.jsp&ts=<%=getTs()%>"+
    		  "&VarCode=EditInsuranceCategoryLetter&VarText=EditInsuranceInsurarName"+
    		  "&VarCat=EditInsuranceCategory&VarCompUID=EditInsurarUID"+
    		  "&VarTyp=EditInsuranceType&VarTypName=EditInsuranceTypeName");
  }

  function searchAffiliate(){
    openPopup("/_common/search/searchAffiliate.jsp&ts=<%=getTs()%>"+
    		  "&EditInsurarUID="+document.getElementById("EditInsurarUID").value+
    		  "&EditInsuranceNr="+document.getElementById("EditInsuranceNr").value+
    		  "&VarCode=EditInsuranceMember&VarText=EditInsuranceMemberName"+
    		  "&VarImmat=EditInsuranceMemberImmat&VarEmp=EditInsuranceMemberEmployer"+
    		  "&exclude=<%=activePatient.personid%>");
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  function doSearchBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  function doSave(){
    EditInsuranceForm.EditSaveButton.disabled = true;
    EditInsuranceForm.Action.value = "SAVE";
    EditInsuranceForm.submit();
  }
</script>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sEditInsuranceUID    = checkString(request.getParameter("EditInsuranceUID")),
           sEditInsurarUID      = checkString(request.getParameter("EditInsurarUID")),
           sEditInsuranceNr     = checkString(request.getParameter("EditInsuranceNr")),
           sEditInsuranceType   = checkString(request.getParameter("EditInsuranceType")),
           sEditInsuranceStatus = checkString(request.getParameter("EditInsuranceStatus")),
           sEditInsuranceMember         = checkString(request.getParameter("EditInsuranceMember")),
           sEditInsuranceMemberName     = checkString(request.getParameter("EditInsuranceMemberName")),
           sEditInsuranceMemberImmat    = checkString(request.getParameter("EditInsuranceMemberImmat")),
           sEditInsuranceMemberEmployer = checkString(request.getParameter("EditInsuranceMemberEmployer"));
   
    String sEditInsuranceStart = checkString(request.getParameter("EditInsuranceStart"));
    if(sEditInsuranceStart.length()==0){
        sEditInsuranceStart = ScreenHelper.formatDate(new java.util.Date());
    }
    
    String sEditInsuranceStop = checkString(request.getParameter("EditInsuranceStop"));
    String sEditInsuranceCategoryLetter = checkString(request.getParameter("EditInsuranceCategoryLetter"));
    String sEditInsuranceCategory = "";
    String sEditInsuranceInsurarName = "";
    String sEditInsuranceComment = checkString(request.getParameter("EditInsuranceComment"));

    if(sAction.equals("SAVE")){
        if(sEditInsuranceCategoryLetter.length()==0){
            sEditInsurarUID = "";
        }
        
        Insurance insurance = new Insurance();
        if(sEditInsuranceUID.length() > 0){
            insurance = Insurance.get(sEditInsuranceUID);
        }
        else{
            insurance.setCreateDateTime(getSQLTime());
        }

        if(sEditInsuranceStart.length() > 0){
            insurance.setStart(new Timestamp(ScreenHelper.getSQLDate(sEditInsuranceStart).getTime()));
        }
        if(sEditInsuranceStop.length() > 0){
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

    if(sEditInsuranceUID.length() > 0){
        Insurance insurance = Insurance.get(sEditInsuranceUID);

        sEditInsuranceNr = insurance.getInsuranceNr();
        sEditInsuranceType = insurance.getType();
       
        sEditInsuranceMember = insurance.getMember();
        if(sEditInsuranceMember!=null && sEditInsuranceMember.length()>0){
        	AdminPerson p = AdminPerson.getAdminPerson(sEditInsuranceMember);
        	if(p!=null){
        		sEditInsuranceMemberName = p.lastname.toUpperCase()+", "+p.firstname;
        	}
        }
        
        sEditInsuranceMemberImmat = insurance.getMemberImmat();
        sEditInsuranceMemberEmployer = insurance.getMemberEmployer();
        sEditInsuranceStatus = insurance.getStatus();
        sEditInsuranceCategoryLetter = insurance.getInsuranceCategoryLetter();
        sEditInsurarUID = insurance.getInsurarUid();
       
        InsuranceCategory insuranceCategory = InsuranceCategory.get(insurance.getInsurarUid(),sEditInsuranceCategoryLetter);
        if(insuranceCategory.getLabel().length() > 0){
            sEditInsuranceInsurarName = insuranceCategory.getInsurar().getName();
            sEditInsuranceCategory = insuranceCategory.getCategory()+": "+insuranceCategory.getLabel();
        }
        
        if(insurance.getStart()!=null){
            sEditInsuranceStart = ScreenHelper.formatDate(insurance.getStart());
        } 
        else{
            sEditInsuranceStart = "";
        }
        
        if(insurance.getStop()!=null){
            sEditInsuranceStop = ScreenHelper.formatDate(insurance.getStop());
        } 
        else{
            sEditInsuranceStop = "";
        }

        sEditInsuranceComment = insurance.getComment().toString();
    }
%>

<form name="EditInsuranceForm" id="EditInsuranceForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/insurance/editInsurance.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="EditInsuranceUID" value="<%=sEditInsuranceUID%>"/>
    <%=writeTableHeader("insurance","manageInsurance",sWebLanguage," doBack();")%>
   
    <table class='list' width='100%' cellspacing='1'>
        <%-- company --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","company.class",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="EditInsurarUID" id="EditInsurarUID" value="<%=sEditInsurarUID%>"/>
                <input class="text" type="text" readonly name="EditInsuranceInsurarName" value="<%=sEditInsuranceInsurarName%>" size="<%=sTextWidth%>"/>
          
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsuranceCategory();">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearInsuranceFields();">
            </td>
        </tr>
        
        <%-- category --%>
        <tr>
            <td class="admin"><%=getTran("web","category",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="EditInsuranceCategoryLetter" value="<%=sEditInsuranceCategoryLetter%>"/>
                <input class="readonly" type="text" readonly name="EditInsuranceCategory" value="<%=sEditInsuranceCategory%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        
        <%-- type --%>
        <tr>
            <td class="admin"><%=getTran("web","tariff",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="EditInsuranceType" value="<%=sEditInsuranceType%>"/>
                <input class="readonly" type="text" readonly name="EditInsuranceTypeName" value="<%=sEditInsuranceType.length()>0?getTran("insurance.types",sEditInsuranceType,sWebLanguage):""%>" size="<%=sTextWidth%>" readonly/>
            </td>
        </tr>
        
        <%-- start --%>
        <tr>
            <td class="admin"><%=getTran("web","start",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("EditInsuranceStart","EditInsuranceForm",sEditInsuranceStart,sWebLanguage)%>
            </td>
        </tr>
        
        <%-- stop --%>
        <tr>
            <td class="admin"><%=getTran("web","stop",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("EditInsuranceStop","EditInsuranceForm",sEditInsuranceStop,sWebLanguage)%>
            </td>
        </tr>
        
        <%-- insurancenr --%>
        <tr>
            <td class="admin"><%=getTran("insurance","insurancenr",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="EditInsuranceNr" id="EditInsuranceNr" value="<%=sEditInsuranceNr%>" size="<%=sTextWidth%>" onchange="setStatus();"/>
            </td>
        </tr>
        
        <%-- status --%>
        <tr>
            <td class="admin"><%=getTran("insurance","status",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditInsuranceStatus" id="EditInsuranceStatus" onchange="setStatus();">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("insurance.status",sEditInsuranceStatus,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- member --%>
        <tr>
            <td class="admin"><%=getTran("insurance","member",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly class="readonly" type="text" name="EditInsuranceMemberName" id="EditInsuranceMemberName" value="<%=sEditInsuranceMemberName%>" size="<%=sTextWidth%>"/>
                <input type="hidden" name="EditInsuranceMember" id="EditInsuranceMember" value="<%=sEditInsuranceMember%>" />
               
                <img id="img1" src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAffiliate();">
                <img id="img2" src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearAffiliateFields();">
            </td>
        </tr>
        
        <%-- membernumber --%>
        <tr>
            <td class="admin"><%=getTran("insurance","membernumber",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly class="readonly" type="text" name="EditInsuranceMemberImmat" id="EditInsuranceMemberImmat" value="<%=sEditInsuranceMemberImmat%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("insurance","memberemployer",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=sEditInsuranceStatus.equalsIgnoreCase("affiliate")?"":"readonly"%> class="<%=sEditInsuranceStatus.equalsIgnoreCase("affiliate")?"text":"readonly"%>" type="text" name="EditInsuranceMemberEmployer" id="EditInsuranceMemberEmployer" value="<%=sEditInsuranceMemberEmployer%>" size="<%=sTextWidth%>"/>
            </td>
        </tr>
        
        <%-- comment --%>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditInsuranceComment","69","4","",sEditInsuranceComment)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class='button' type="button" name="EditSaveButton" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doSearchBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <input type="hidden" name="Action" value="">
</form>

<%
	Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);

	String sEmployer = "";
	if(insurance!=null){
		sEmployer = insurance.getMemberEmployer();
	}
%>

<script>
  function clearAffiliateFields(){
    EditInsuranceForm.EditInsuranceMemberName.value = '';
    EditInsuranceForm.EditInsuranceMember.value = '';
    EditInsuranceForm.EditInsuranceMemberEmployer.value = '';
    EditInsuranceForm.EditInsuranceMemberImmat.value = '';
    
    EditInsuranceForm.EditInsuranceMemberName.focus();
  }
  
  function clearInsuranceFields(){
    EditInsuranceForm.EditInsuranceInsurarName.value = "";
    EditInsuranceForm.EditInsuranceCategory.value = "";
    EditInsuranceForm.EditInsuranceCategoryLetter.value = "";

    EditInsuranceForm.EditInsuranceInsurarName.focus();
  }
  
  function setStatus(){
   	if(document.getElementById("EditInsuranceStatus").value=="affiliate" || document.getElementById("EditInsuranceStatus").value=="virtual"){
      document.getElementById("EditInsuranceMember").value="<%=activePatient.personid%>";
      document.getElementById("EditInsuranceMemberName").value="<%=activePatient.lastname.toUpperCase()+", "+activePatient.firstname%>";
      document.getElementById("EditInsuranceMemberImmat").value=document.getElementById("EditInsuranceNr").value;
      document.getElementById("EditInsuranceMemberEmployer").value="<%=sEmployer%>";
      document.getElementById("EditInsuranceMemberEmployer").readOnly=false;
      document.getElementById("EditInsuranceMemberEmployer").className="text";
      document.getElementById("img1").style.visibility="hidden";
      document.getElementById("img2").style.visibility="hidden";
   	}
   	else{
      document.getElementById("EditInsuranceMemberEmployer").readOnly=true;
      document.getElementById("EditInsuranceMemberEmployer").className="readonly";
      document.getElementById("img1").style.visibility="visible";
      document.getElementById("img2").style.visibility="visible";
   	}
  }
</script>