<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=sJSSORTTABLE%><%=sCSSGNOOCALENDAR%><%=sJSGNOOCALENDAR%>
<%!
    //--- WRITE TAB -------------------------------------------------------------------------------
public String writeTab(String sId, String sFocusField, String sLanguage) {
    return "<script>sTabs+= '," + sId + "';</script>" +
            "<td style='border-bottom:1px solid #000;width:10px'>&nbsp;</td>" +
            "<td class='tabunselected' width='1%' style='padding:2px 4px;text-align:center;' onclick='activateTab(\"" + sId + "\")' id='tab" + sId + "' nowrap><b>" + getTran("meals", sId, sLanguage) + "</b></td>";
}
    //--- WRITE TAB BEGIN -------------------------------------------------------------------------
    public String writeTabBegin(String sId) {
        return "<tr id='tr" + sId + "' style='display:none'><td>";
    }
    //--- WRITE TAB END ---------------------------------------------------------------------------
    public String writeTabEnd() {
        return "</td></tr>";
    }
%>
<script type="text/javascript">
    var sTabs = "";
    var activeTab = "";
</script>
<%=checkPermission("manage.meals", "all", activeUser)%>
<table style="margin:0;padding:0;" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <%=writeTab("patientMeals", "meals", sWebLanguage)%><% if (activeUser.getAccessRight("manage.meals")) {%><%=writeTab("mealprofiles", "meals", sWebLanguage)%><%=writeTab("meal", "meals", sWebLanguage)%><%=writeTab("mealsitems", "meals", sWebLanguage)%><%=writeTab("nutricientitems", "meals", sWebLanguage)%><% } %>
        <td width="*">&nbsp;</td>
    </tr>
</table>
<table id="tabsTable" width="100%" style="margin:0;padding:0;" cellspacing="0" cellpadding="0">

    <%=writeTabBegin("patientMeals")%>
     <% if(activePatient!=null){%><%ScreenHelper.setIncludePage(customerInclude("meals/managePatientMeals.jsp"), pageContext);%>
     <% } %><%=writeTabEnd()%>

    <% if (activeUser.getAccessRight("manage.meals")) {%><%=writeTabBegin("mealprofiles")%><%
    ScreenHelper.setIncludePage(customerInclude("meals/manageMealProfiles.jsp"), pageContext);%><%=writeTabEnd()%><%=writeTabBegin("meal")%><%
    ScreenHelper.setIncludePage(customerInclude("meals/manageMeal.jsp"), pageContext);%><%=writeTabEnd()%><%=writeTabBegin("mealsitems")%><%
    ScreenHelper.setIncludePage(customerInclude("meals/manageMealsItems.jsp"), pageContext);%><%=writeTabEnd()%><%=writeTabBegin("nutricientitems")%><%
    ScreenHelper.setIncludePage(customerInclude("meals/manageNutricientItems.jsp"), pageContext);%><%=writeTabEnd()%><%}%>
</table>
<div id="resultsByAjax">&nbsp;</div>
<script type="text/javascript">
    var aTabs = sTabs.split(',');
    <%-- ACTIVATE TAB -----------------------------------------------------------------------------%>
    function activateTab(sTab, initialize) {
        for (var i = 0; i < aTabs.length; i++) {
            sTmp = aTabs[i];
            if (sTmp.length > 0) {
                $("tr" + sTmp).style.display = "none";
                $("tab" + sTmp).className = "tabunselected";
            }
        }
        $("tr" + sTab).style.display = "";
        $("tab" + sTab).className = "tabselected";
    }
    window.onload = function() {
        activateTab("patientMeals", true);
         if($("datechoosed")){
              initCalendar();
         }
        searchMealProfiles();
        searchMeals();
        searchMealItems();
        searchNutricientItems();
    }
</script>
<div id="operationByAjax">&nbsp;</div>
  
