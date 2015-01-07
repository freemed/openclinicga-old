<%@page import="java.util.Vector,
                java.util.Hashtable"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindLastname    = checkString(request.getParameter("FindLastname")),
           sFindFirstname   = checkString(request.getParameter("FindFirstname")),
           sFindGender      = checkString(request.getParameter("FindGender")),
           sFindDOB         = checkString(request.getParameter("FindDOB")),
           sFindInsuranceMember         = checkString(request.getParameter("VarCode")),
           sFindInsuranceMemberName     = checkString(request.getParameter("VarText")),
           sFindInsuranceMemberEmployer = checkString(request.getParameter("VarEmp")),
           sFindInsuranceMemberImmat    = checkString(request.getParameter("VarImmat")),
           sFindInsuranceNr = checkString(request.getParameter("EditInsuranceNr")),
           sExclude         = checkString(request.getParameter("exclude")),
		   sFindInsurarUID  = checkString(request.getParameter("EditInsurarUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********************** search/searchAffiliate.jsp **********************");
        Debug.println("sFindLastname    : "+sFindLastname);
        Debug.println("sFindFirstname   : "+sFindFirstname);
        Debug.println("sFindGender      : "+sFindGender);
        Debug.println("sFindDOB         : "+sFindDOB);
        Debug.println("sFindInsuranceMember         : "+sFindInsuranceMember);
        Debug.println("sFindInsuranceMemberEmployer : "+sFindInsuranceMemberEmployer);
        Debug.println("sFindInsuranceMemberEmployer : "+sFindInsuranceMemberEmployer);
        Debug.println("sFindInsuranceMemberImmat    : "+sFindInsuranceMemberImmat);
        Debug.println("sFindInsuranceNr : "+sFindInsuranceNr);
        Debug.println("sExclude         : "+sExclude);
        Debug.println("sFindInsurarUID  : "+sFindInsurarUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="SearchForm" method="POST" onsubmit="doFind();return false;"  onkeydown="if(enterEvent(event,13)){doFind();}">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- search fields row 1 --%>
        <tr height="25">
            <td nowrap>&nbsp;<%=getTran("Web","name",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindLastname" class="text" value="<%=sFindLastname%>" onblur="limitLength(this);" >
            </td>
            <td nowrap>&nbsp;<%=getTran("Web", "firstname",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindFirstname" class="text" value="<%=sFindFirstname%>" onblur="limitLength(this);">
            </td>
        </tr>
        
        <%-- search fields row 2 --%>
        <tr>
            <td height="25" nowrap>&nbsp;<%=getTran("Web","dateofbirth", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindDOB" class="text" value="<%=sFindDOB%>" onblur="checkDate(this);">
            </td>
            <td nowrap>&nbsp;<%=getTran("Web","gender",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <select class="text" name="FindGender">
                    <option/>
                    <option value="M"<%=(sFindGender.equalsIgnoreCase("m")?" selected":"")%>>M</option>
                    <option value="F"<%=(sFindGender.equalsIgnoreCase("f")?" selected":"")%>>F</option>
                </select>&nbsp;
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td>&nbsp;</td>
            <td height="25">
                <input class="button" type="button" name="buttonfind" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                <input class="button" type="button" name="buttonclear" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearFields();">
            </td>
        </tr>
    </table>
    <br>
    
    <div id="divFindRecords"></div>

    <%-- hidden fields --%>
    <input type="hidden" name="displayImmatNew" value="<%=checkString(request.getParameter("displayImmatNew"))%>">
    <input type="hidden" name="EditInsurarUID" value="<%=sFindInsurarUID%>">
    <input type="hidden" name="EditInsuranceNr" value="<%=sFindInsuranceNr%>">
    <input type="hidden" name="exclude" value="<%=sExclude%>">
    <br>
    
    <%-- CLOSE BUTTON --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" class="button" name="buttonclose" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  window.resizeTo(500,540);

  <%-- CLEAR FIELDS --%>
  function clearFields(){
    SearchForm.FindLastname.value = "";
    SearchForm.FindFirstname.value = "";
    SearchForm.FindDOB.value = "";
    SearchForm.FindGender.selectedIndex = -1;
    SearchForm.FindLastname.focus();
  }

  <%-- DO FIND --%>
  function doFind(){
    ajaxChangeSearchResults('_common/search/searchByAjax/searchAffiliateShow.jsp',SearchForm);
  }

  <%-- SET PERSON --%>
  function setPerson(sPersonID,sName,sEmployer,sImmat){
    if("<%=sFindInsuranceMember%>" != ""){
      window.opener.document.getElementsByName("<%=sFindInsuranceMember%>")[0].value = sPersonID;
    }
    if("<%=sFindInsuranceMemberName%>" != ""){
      window.opener.document.getElementsByName("<%=sFindInsuranceMemberName%>")[0].value = sName;
    }
    if("<%=sFindInsuranceMemberEmployer%>" != ""){
      window.opener.document.getElementsByName("<%=sFindInsuranceMemberEmployer%>")[0].value = sEmployer;
    }
    if("<%=sFindInsuranceMemberImmat%>" != ""){
      window.opener.document.getElementsByName("<%=sFindInsuranceMemberImmat%>")[0].value = sImmat;
    }

    window.close();
  }

  function addPerson(){
    if(($("FindLastname").value.length>0)&&($("FindFirstname").value.length>0)&&($("FindDOB").value.length>0)&&($("FindGender").value.length>0)){
      ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientAdd.jsp', SearchForm);
    }
    else{
      alertDialog("web","somefieldsareempty");
    }
  }
    
  SearchForm.FindLastname.focus();
  doFind();
</script>