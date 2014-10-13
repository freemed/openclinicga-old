<%@page import="be.openclinic.finance.Wicket,
                java.util.Vector,
                be.openclinic.finance.Insurar,
                be.openclinic.finance.InsuranceCategory"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindInsurarName = checkString(request.getParameter("FindInsurarName")),
           sFunction        = checkString(request.getParameter("doFunction"));

    String sVarCode      = checkString(request.getParameter("VarCode")),
		   sVarText      = checkString(request.getParameter("VarText")),
		   sVarCat       = checkString(request.getParameter("VarCat")),
		   sVarCatLetter = checkString(request.getParameter("VarCatLetter"));
    
    String sVarTyp     = checkString(request.getParameter("VarTyp")),
           sVarTypName = checkString(request.getParameter("VarTypName")),
           sVarCompUID = checkString(request.getParameter("VarCompUID"));
 
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** _common/search/searchCoveragePlan.jsp ****************");
    	Debug.println("sFindInsurarName : "+sFindInsurarName);
    	Debug.println("sFunction        : "+sFunction);
    	Debug.println("sVarCode         : "+sVarCode);
    	Debug.println("sVarText         : "+sVarText);
    	Debug.println("sVarCat          : "+sVarCat);
    	Debug.println("sVarCatLetter    : "+sVarCatLetter);
    	Debug.println("sVarTyp          : "+sVarTyp);
    	Debug.println("sVarTypName      : "+sVarTypName);
    	Debug.println("sVarCompUID      : "+sVarCompUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

%>
<form name="SearchForm" method="POST">
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="VarCat" value="<%=sVarCat%>">
    <input type="hidden" name="VarCatLetter" value="<%=sVarCatLetter%>">
    
    <table width='100%' cellspacing='0' cellpadding='0' class='menu'>
        <%-- search fields row 1 --%>
        <%-- service --%>
        <%
            if(!"false".equalsIgnoreCase(request.getParameter("header"))){
        %>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","coverageplan",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="FindInsurarName" size="<%=sTextWidth%>" value="<%=sFindInsurarName%>">
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr height="25">
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
        <%
            }
        %>
        
        <%-- SEARCH RESULTS --%>
        <tr>
            <td style="vertical-align:top;" colspan="3" align="center" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>

    <%-- CLOSE BUTTON --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  window.resizeTo(500,510);

  <%-- CLEAR FIELDS --%>
  function clearFields(){
    SearchForm.FindInsurarName.value = "";
  }

  <%-- DO FIND --%>
  function doFind(){
    ajaxChangeSearchResults('_common/search/searchByAjax/searchCoveragePlanShow.jsp',SearchForm);
  }

  <%-- SET INSURANCE CATEGORY --%>
  function setInsuranceCategory(sInsuranceCategoryLetter,sInsurarUID,sInsurarName,sInsuranceCategoryName,sInsuranceType,sInsuranceTypeName){
   if('<%=sVarCode%>'!=""){
     window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sInsuranceCategoryLetter;
   }
   if('<%=sVarText%>'!=""){
     window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sInsurarName;
   }
   if('<%=sVarCat%>'!=""){
     window.opener.document.getElementsByName('<%=sVarCat%>')[0].value = sInsuranceCategoryName;
   } 
   if('<%=sVarCompUID%>'!=""){
     window.opener.document.getElementsByName('<%=sVarCompUID%>')[0].value = sInsurarUID;
   }
   if('<%=sVarTyp%>'!=""){
     window.opener.document.getElementsByName('<%=sVarTyp%>')[0].value = sInsuranceType;
   }
   if('<%=sVarTypName%>'!=""){
     window.opener.document.getElementsByName('<%=sVarTypName%>')[0].value = sInsuranceTypeName;
   }

   <%
       if(sFunction.length() > 0){
           out.print("window.opener."+sFunction+";");
       }
   %>

    window.close();
  }
   
  window.setTimeout("SearchForm.FindInsurarName.focus();",100);
  doFind();
</script>