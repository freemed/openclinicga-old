<%@page import="be.openclinic.finance.Wicket,
                java.util.Vector,
                be.openclinic.finance.Insurar,
                be.openclinic.finance.InsuranceCategory"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindInsurarName = checkString(request.getParameter("FindInsurarName"));
 
    String sVarCode     = checkString(request.getParameter("VarCode")),
           sVarText     = checkString(request.getParameter("VarText")),
           sVarCat      = checkString(request.getParameter("VarCat")),
           sVarTyp      = checkString(request.getParameter("VarTyp")),
           sVarTypName  = checkString(request.getParameter("VarTypName")),
           sVarCompUID  = checkString(request.getParameter("VarCompUID")),
           sVarFunction = checkString(request.getParameter("VarFunction")),
           sVarActive   = checkString(request.getParameter("Active"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************** _common/search/searchInsuranceCategory.jsp *************");
    	Debug.println("sVarCode     : "+sVarCode);
    	Debug.println("sVarText     : "+sVarText);
    	Debug.println("sVarCat      : "+sVarCat);
    	Debug.println("sVarTyp      : "+sVarTyp);
    	Debug.println("sVarTypName  : "+sVarTypName);
    	Debug.println("sVarCompUID  : "+sVarCompUID);
    	Debug.println("sVarFunction : "+sVarFunction);
    	Debug.println("sVarActive   : "+sVarActive+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

%>
<form name='SearchForm' method="POST" onSubmit="doFind();return false;" onsubmit="doFind();return false;">
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="VarCat" value="<%=sVarCat%>">
    <input type="hidden" name="Active" value="<%=sVarActive%>">
    
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- service --%>
        <%
            if(!"false".equalsIgnoreCase(request.getParameter("header"))){
        %>
        <tr>
            <td class="admin2"><%=getTran("Web","insurar",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="FindInsurarName" size="<%=sTextWidth%>" value="<%=sFindInsurarName%>">
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
        <%
            }
        %>
    </table>
    <br>

    <div id="divFindRecords"></div>
        
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
    ajaxChangeSearchResults('_common/search/searchByAjax/searchInsuranceCategoryShow.jsp',SearchForm);
  }

  <%-- SET BALANCE --%>
  function setInsuranceCategory(sInsuranceCategoryLetter,sInsurarUID,sInsurarName,sInsuranceCategory,sInsuranceType,sInsuranceTypeName){
    window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sInsuranceCategoryLetter;

    if('<%=sVarText%>'!=''){
      window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sInsurarName;
    }

    if('<%=sVarCompUID%>'!=''){
        window.opener.document.getElementsByName('<%=sVarCompUID%>')[0].value = sInsurarUID;
    }

    if('<%=sVarCat%>'!=''){
        window.opener.document.getElementsByName('<%=sVarCat%>')[0].value = sInsuranceCategory;
    }

    if('<%=sVarTyp%>'!=''){
        window.opener.document.getElementsByName('<%=sVarTyp%>')[0].value = sInsuranceType;
    }

    if('<%=sVarTypName%>'!=''){
        window.opener.document.getElementsByName('<%=sVarTypName%>')[0].value = sInsuranceTypeName;
    }
	<% 	
	    if(sVarFunction.length() > 0){
	        out.print("window.opener."+sVarFunction+";");
        }
	%>
    window.close();
  }
    
  searchForm.FindInsurarName.focus();
</script>