<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manage.meals","all",activeUser)%>
<%=sJSSORTTABLE%>
<%=sCSSGNOOCALENDAR%>
<%=sJSGNOOCALENDAR%>

<%!
    //--- WRITE TAB -------------------------------------------------------------------------------
	public String writeTab(String sTabId, String sLabelId, String sLanguage){
	    return "<script>sTabs+= ',"+sTabId+"';</script>"+
               "<td class='tabs' width='5'>&nbsp;</td>"+
	           "<td class='tabunselected' width='1%' onclick='activateTab(\""+sTabId+"\")' id='tab"+sTabId+"' nowrap><b>"+getTranNoLink("meals",sLabelId,sLanguage)+"</b></td>";
	}

    //--- WRITE TAB BEGIN -------------------------------------------------------------------------
    public String writeTabBegin(String sTabId){
        return "<tr id='tr"+sTabId+"' style='display:none'><td>";
    }
    
    //--- WRITE TAB END ---------------------------------------------------------------------------
    public String writeTabEnd(){
        return "</td></tr>";
    }
%>

<script>
  var sTabs = "";
  var activeTab = "";
</script>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************************** meals/index.jsp ***************************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>


<table id="tabHeaders" width="100%" cellspacing="0" cellpadding="0">
    <tr> 
        <%
            if(activePatient!=null){
                %><%=writeTab("patientMeals","patientMeals",sWebLanguage)%><%
            }
    
            if(activeUser.getAccessRight("manage.meals")){
                %>
	                <%=writeTab("mealprofiles","profiles",sWebLanguage)%>
	                <%=writeTab("meal","meals",sWebLanguage)%>
	                <%=writeTab("mealsitems","ingredients",sWebLanguage)%>
	                <%=writeTab("nutricientitems","nutrients",sWebLanguage)%>
                <%
            }
        %>
        <td class="tabs" width="*">&nbsp;</td>
    </tr>
</table>

<table id="tabsTable" width="100%" cellspacing="1" cellpadding="0">
    <%
        if(activePatient!=null){
            %>
                <%=writeTabBegin("patientMeals")%>
                <% ScreenHelper.setIncludePage(customerInclude("meals/managePatientMeals.jsp"),pageContext); %>
                <%=writeTabEnd()%>
            <%
        }
    %>

    <%
        if(activeUser.getAccessRight("manage.meals")){
            %>            
            <%=writeTabBegin("mealprofiles")%>
            
            <% ScreenHelper.setIncludePage(customerInclude("meals/manageProfiles.jsp"),pageContext); %><%=writeTabEnd()%><%=writeTabBegin("meal")%>
            <% ScreenHelper.setIncludePage(customerInclude("meals/manageMeals.jsp"),pageContext); %><%=writeTabEnd()%><%=writeTabBegin("mealsitems")%>
            <% ScreenHelper.setIncludePage(customerInclude("meals/manageMealItems.jsp"),pageContext); %><%=writeTabEnd()%><%=writeTabBegin("nutricientitems")%>
            <% ScreenHelper.setIncludePage(customerInclude("meals/manageNutricientItems.jsp"),pageContext); %><%=writeTabEnd()%>
            <%
        }
    %>
</table>

<div id="resultsByAjax">&nbsp;</div>

<script>
  var aTabs = sTabs.split(",");
    
  <%-- ACTIVATE TAB --%>
  function activateTab(sTab,initialize){
    for(var i=0; i<aTabs.length; i++){
      sTmp = aTabs[i];
      if(sTmp.length > 0){
        $("tr"+sTmp).style.display = "none";
        $("tab"+sTmp).className = "tabunselected";
      }
    }
    $("tr"+sTab).style.display = "";
    $("tab"+sTab).className = "tabselected";
  }
    
  window.onload = function(){ 
    <%
        if(activePatient!=null){
            %>activateTab("patientMeals",true);<%
        }
        else{
            if(activeUser.getAccessRight("manage.meals")){
                %>activateTab("mealprofiles",true);<%
            }	
        }
    %>
    if($("datechoosed")){
      initCalendar();
    }
  }
</script>

<div id="operationByAjax">&nbsp;</div>