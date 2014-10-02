<%@page import="be.openclinic.assets.MaintenancePlan,
                be.openclinic.assets.Asset,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../assets/includes/commonFunctions.jsp"%>
<%=sJSSORTTABLE%>

<%!
    //--- GET ASSETCODE FROM DB -------------------------------------------------------------------
    private String getAssetCodeFromDB(String sAssetUID){
        return ScreenHelper.checkString(Asset.getCode(sAssetUID));
    }
%>

<body style="padding:5px;">
<%
    String sPlanUid = checkString(request.getParameter("PlanUid"));
    
    String sFunction = checkString(request.getParameter("doFunction"));
        
    // return fields
    String sReturnFieldUid  = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldCode = checkString(request.getParameter("ReturnFieldCode"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** _common/search/searchMaintenancePlan.jsp **************");
        Debug.println("sPlanUid         : "+sPlanUid);
        Debug.println("sFunction        : "+sFunction);
        Debug.println("sReturnFieldUid  : "+sReturnFieldUid);
        Debug.println("sReturnFieldCode : "+sReturnFieldCode+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
        
    // inner search
    String sAction = checkString(request.getParameter("Action"));
    
    String sName            = ScreenHelper.checkString(request.getParameter("searchName")),
           sAssetUID        = ScreenHelper.checkString(request.getParameter("searchAssetUID")),
           sSearchAssetCode = ScreenHelper.checkString(request.getParameter("searchAssetCode")),
           sOperator        = ScreenHelper.checkString(request.getParameter("searchOperator"));

    ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** innerSearch **********");
        Debug.println("sAction          : "+sAction);
        Debug.println("sName            : "+sName);
        Debug.println("sAssetUID        : "+sAssetUID);
        Debug.println("sSearchAssetCode : "+sSearchAssetCode);
        Debug.println("sOperator        : "+sOperator+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    boolean showAllRecordsOnEmptySearch = true;
    String msg = "";    
      
    // search fields 
    %>
        <form name="SearchForm" id="SearchForm" method="POST">          
            <%=writeTableHeader("web","searchMaintenancePlans",sWebLanguage,"")%>
            <input type="hidden" name="Action" value="search">
                            
            <table class="list" border="0" width="100%" cellspacing="1">
                <%-- search NAME --%>
		        <tr>
		            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <input type="text" class="text" id="searchName" name="searchName" size="40" maxLength="50" value="<%=sName%>">
		            </td>
		        </tr>     
		        
		        <%-- search ASSET --%>    
		        <tr>
		            <td class="admin"><%=getTran("web.assets","asset",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <input type="hidden" name="searchAssetUID" id="searchAssetUID" value="<%=sAssetUID%>">
		                <input type="text" class="text" id="searchAssetCode" name="searchAssetCode" size="20" readonly value="<%=sSearchAssetCode%>">
		                                   
		                <%-- buttons --%>
		                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="selectAsset('searchAssetUID','searchAssetCode');">
		                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearAssetSearchFields();">
		            </td>
		        </tr>  
		        
		        <%-- search OPERATOR (person) --%>
		        <tr>
		            <td class="admin"><%=getTran("web","operator",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <input type="text" class="text" id="searchOperator" name="searchOperator" size="40" maxLength="50" value="<%=sOperator%>">
		            </td>
		        </tr>     
                                    
                <%-- search BUTTONS --%>
                <tr>     
                    <td class="admin"/>
                    <td class="admin2" colspan="2">
                        <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchMaintenancePlans();">&nbsp;
                        <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                    </td>
                </tr>
            </table>
        </form>
    <%
    
    List<MaintenancePlan> foundPlans = new LinkedList();
    
    if(sAction.equals("search")){
	    if(sName.length() > 0 || sAssetUID.length() > 0 || sOperator.length() > 0 || showAllRecordsOnEmptySearch){
		    MaintenancePlan findItem = new MaintenancePlan();
		    findItem.name = sName;
		    findItem.assetUID = sAssetUID;
		    findItem.operator = sOperator;
		    
		    foundPlans = MaintenancePlan.getList(findItem);
		    if(foundPlans.size() > 0){
		        %>		            
		            <table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable">
		                <%-- header --%>
		                <tr class="admin">
		                    <td class="admin" style="padding-left:0;" width="20%" nowrap><%=getTran("web.assets","name",sWebLanguage)%></td>
		                    <td class="admin" style="padding-left:0;" width="7%" nowrap><%=getTran("web.assets","asset",sWebLanguage)%></td>
		                    <td class="admin" style="padding-left:0;" width="20%" nowrap><%=getTran("web.assets","operator",sWebLanguage)%></td>
		                </tr>
		                
		                <tbody>
		                    <%
		                        String sClass = "1";
		                        MaintenancePlan plan;
		                        
		                        for(int i=0; i<foundPlans.size(); i++){
		                            plan = (MaintenancePlan)foundPlans.get(i);
		                            
		                            // alternate row-style
		                            if(sClass.length()==0) sClass = "1";
		                            else                   sClass = "";
		                            
		                            %>
		                                <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" onClick="selectMaintenancePlan('<%=plan.getUid()%>','<%=plan.name%>');">
		                                    <td><%=checkString(plan.name)%></td>
		                                    <td><%=getAssetCodeFromDB(plan.assetUID)%></td>
		                                    <td><%=checkString(plan.operator)%></td>
		                                </tr>
		                            <%
		                        }
		                    %>
		                </tbody>
		            </table>
		        <%
		    }
	    }
	    
	    // number of found records
	    if(foundPlans.size() > 0){
	        %><%=foundPlans.size()%> <%=getTran("web","recordsFound",sWebLanguage)%><%
	    }
	    else{
	        %><%=getTran("web","noRecordsFound",sWebLanguage)%><%
	    }
    }
    
    // display message
    if(msg.length() > 0){
        %><%=msg%><%
    }
%>
    
<%-- CLOSE BUTTON --%>
<div style="text-align:center;padding-top:10px;">
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
</div>

<script>
  window.resizeTo(700,500);
  resizeAllTextareas(4);

  <%-- SELECT ASSET --%>
  function selectAsset(uidField,codeField){
    var url = "/_common/search/searchAsset.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid="+uidField+
              "&ReturnFieldCode="+codeField;
    openPopup(url);
    document.getElementById(codeField).focus();
  }  
  
  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchName").value = "";
    clearAssetSearchFields();
    document.getElementById("searchOperator").value = "";
    
    document.getElementById("searchName").focus();
  }

  <%-- CLEAR ASSET SEARCH FIELDS --%>
  function clearAssetSearchFields(){
    document.getElementById("searchAssetUID").value = "";
    document.getElementById("searchAssetCode").value = "";  
  }  
  
  <%-- SEARCH MAINTENANCE PLANS --%>
  function searchMaintenancePlans(){
    var okToSubmit = true;
    
    if(document.getElementById("searchName").value.length > 0 ||
       document.getElementById("searchAssetUid").value.length > 0 ||
       document.getElementById("searchOperator").value.length > 0){
      okToSubmit = true;
    }
        
    if(okToSubmit==true){
      document.getElementById("buttonSearch").disabled = true;
      document.getElementById("buttonClear").disabled = true;
      SearchForm.submit();
    }
  }
  
  <%-- SELECT MAINTENANCE PLAN --%>
  function selectMaintenancePlan(uid,code){
    if("<%=sReturnFieldUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
    }
    if("<%=sReturnFieldCode%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldCode%>")[0].value = code;
    }
    
    <%
        if(sFunction.length() > 0){
            out.print("window.opener."+sFunction+";");
        }
    %>

    window.close();
  }
  
  document.getElementById("searchName").focus();
</script>
</body>