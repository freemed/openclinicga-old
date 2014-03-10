<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<link type="text/css" rel="stylesheet" href='<c:url value="/" />_common/_css/meals.css'/>
<%=checkPermission("manage.meals", "all", activeUser)%><%=writeTableHeader("Web", "manageNutricients", sWebLanguage)%>
<table width="100%" cellspacing="1" class="list" onKeyDown='if(event.keyCode==13){searchNutricientItems();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <%=getTran("meals", "nutricientItemName", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" id="FindNutricientName" name="FindNutricientName" size="<%=sTextWidth%>" maxLength="255">
            &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchNutricientItems();"> &nbsp;&nbsp;<input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="openNutricientItem('-1');">
        </td>
    </tr>
</table>
<div id="nutricientItemsResultsByAjax">&nbsp;</div>
<script>
    function searchNutricientItems() {
        var id = "nutricientItemsResultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = "FindNutricientName=" + $F("FindNutricientName");
        if ($("FindNutricientNameWindow")) {
            params += "&FindNutricientNameWindow=" + $F("FindNutricientNameWindow") + "&withSearchFields=1";
        }
        var url = "<c:url value="/meals/ajax/getNutricientItems.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    openNutricientItem = function(id) {
        var params = "nutricientItemId=" + id;
        var url = "<c:url value="/meals/ajax/getNutricientItem.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","nutricientitem",sWebLanguage)%>",params:params});
    }
    setNutricientItem = function () {
        var params = "action=save&nutricientItemId=" + $F("nutricientItemId") + "&nutricientItemUnit=" + encodeURI($("nutricientItemUnit").value) + "&nutricientItemName=" + $F("nutricientItemName");
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setNutricientItem.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    var itemuid = "";
    deleteNutricientItem = function(id) {
        itemuid = id;
        yesOrNo("deleteNutricientItemNext()", "<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }
    deleteNutricientItemNext = function() {
        if (itemuid.length > 0) {
            var id = "operationByAjax";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var url = "<c:url value="/meals/ajax/setNutricientItem.jsp" />?action=delete&nutricientItemId=" + itemuid + "&ts=" + new Date().getTime();
            new Ajax.Updater(id, url,
            {
                evalScripts: true
            });
        }
    }
    refreshNutricientItems = function() {
        searchNutricientItems();
    }
</script>

