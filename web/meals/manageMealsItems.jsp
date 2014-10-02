<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<link type="text/css" rel="stylesheet" href='<c:url value="/" />_common/_css/meals.css'/>
<%=checkPermission("manage.meals", "all", activeUser)%><%=writeTableHeader("Web", "manageMealsItems", sWebLanguage)%>
<table width="100%" cellspacing="1" class="list" onKeyDown='if(event.keyCode==13){searchMealItems();return false;}'>
    <form name="manageMealsItemsTable" id="manageMealsItemsTable" method="post">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("meals", "mealItemName", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text search" id="FindMealItemName" name="FindMealItemName" size="<%=sTextWidth%>" maxLength="255">
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("meals", "mealItemDescription", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text search" id="FindMealItemDescription" name="FindMealItemDescription" size="<%=sTextWidth%>" maxLength="255"> &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchMealItems();"> &nbsp;&nbsp;<input type="button" class="button iconadd" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="openMealItem('-1');">
            </td>
        </tr>
    </form>
</table>
<div id="mealsItemsResultsByAjax">&nbsp;</div>
<script>
    function searchMealItems() {
        var id = "mealsItemsResultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = "FindMealItemName=" + $F("FindMealItemName") + "&FindMealItemDescription=" + $F("FindMealItemDescription");
        var url = "<c:url value="/meals/ajax/getMealsItems.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    function searchNutricientItemsWindow() {
        $("mealItemEdit").hide();
        var id = "nutricientItemsList";
        var params = "withSearchFields=1";
        if ($("FindNutricientNameWindow")) {
            params += "&FindNutricientNameWindow=" + $F("FindNutricientNameWindow");
        }
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/getNutricientItems.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true

        });
        Modalbox.setTitle("<%=getTranNoLink("meals","searchnutricientitem",sWebLanguage)%>");
    }
    openMealItem = function(id, name) {
        var params = "mealItemId=" + id;
        var url = "<c:url value="/meals/ajax/getMealItem.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","mealitem",sWebLanguage)%>",params:params,width:520});
    }
    setMealItem = function () {
        var params = "action=save&mealItemId=" + $F("mealItemId") + "&mealItemDescription=" + encodeURI($("mealItemDescription").value) + "&mealItemUnit=" + encodeURI($("mealItemUnit").value) + "&mealItemName=" + $F("mealItemName");
        var elements = $('mealItemNutricients').childElements();
        var reg = new RegExp("[_]+", "g");
        var items = "&nutricientItems=";
        elements.each(function(s) {
            var t = s.id.split(reg);
            items += t[1] + "-" + ($("mealitemnutricientqt_" + t[1]) ? $F("mealitemnutricientqt_" + t[1]) : "0") + ",";
        });
        params += items;
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setMealItem.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    var itemuid = "";
    deleteMealItem = function(id) {
        itemuid = id;
        yesOrNo("deleteMealItemNext()", "<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }
    deleteMealItemNext = function() {
        if (itemuid.length > 0) {
            var id = "operationByAjax";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var url = "<c:url value="/meals/ajax/setMealItem.jsp" />?action=delete&mealItemId=" + itemuid + "&ts=" + new Date().getTime();
            new Ajax.Updater(id, url,
            {
                evalScripts: true
            });
        }
    }
    refreshMealItems = function() {
        searchMealItems();
    }
    openBackMealItem = function(name) {
        $("mealItemEdit").show();
        $("nutricientItemsList").update("");
        Modalbox.resizeToContent();
        Modalbox.setTitle("<%=getTranNoLink("meals","mealItem",sWebLanguage)%>");
    }
    removeNutricientItem = function(id) {
        if ($("mealitemnutricient_" + id)) {
            $("mealitemnutricient_" + id).remove();
        }
    }
    insertNutricientItem = function(id, name, unit) {
        var li = document.createElement('LI');
        li.id = "mealitemnutricient_" + id;
        li.innerHTML = "<div style='width:190px'>" + name + "<%="</div><div style='width:150px'><input type='text' size='7' id='mealitemnutricientqt_"%>" + id + "' value='0.0'/> " + unit + "<%="</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' class='link' title='" + (getTranNoLink("web","delete",sWebLanguage)) + "' "%>onclick=\"removeNutricientItem('" + id + "');\"></div>";
        $("mealItemNutricients").insert(li, { position: top });
        openBackMealItem();
    }
</script>

