<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=checkPermission("manage.meals", "all", activeUser)%><%=writeTableHeader("Web", "manageMeals", sWebLanguage)%>
<table width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){searchMeals();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals", "mealName", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" name="FindMealName" id="FindMealName" size="<%=sTextWidth%>" maxLength="255"> &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchMeals();"> &nbsp;&nbsp;<input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="openMeal('-1');">
        </td>
    </tr>
</table>
<div id="mealResultsByAjax">&nbsp;</div>
<script>
    searchMeals = function() {
        var id = "mealResultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = "FindMealName=" + $F("FindMealName");
        var url = "<c:url value="/meals/ajax/getMeals.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    searchMealsWindow = function(bToMakeProfile) {
        var id = "mealsSearchDiv";

        var params = "FindMealName=" + $F("FindMealNameWindow")+"&withSearchFields=1";
         if(bToMakeProfile) params += "&toMakeProfile=1";

        var url = "<c:url value="/meals/ajax/getMeals.jsp" />?ts=" + new Date().getTime();
        $(id).update("<div id='wait'>&nbsp;</div>");
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    openMeal = function(id) {
        var params = "mealId=" + id;
        var url = "<c:url value="/meals/ajax/getMeal.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","meal",sWebLanguage)%>",params:params,width:530});
    }
    setMeal = function () {
        var params = "action=save&mealId=" + $F("mealId") + "&mealName=" + $F("mealName");
        var elements = $('mealmealsitems').childElements();
        var reg = new RegExp("[_]+", "g");
        var items = "&mealmealsitems=";
        elements.each(function(s) {
            var t = s.id.split(reg);
            items += t[1] + "-" + ($("mealmealsitemqt_" + t[1]) ? $F("mealmealsitemqt_" + t[1]) : "0") + ",";
        });
        params += items;
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setMeal.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    var itemuid = "";
    deleteMeal = function(id) {
        itemuid = id;
        yesOrNo("deleteMealNext()", "<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }
    deleteMealNext = function() {
        if (itemuid.length > 0) {
            var id = "operationByAjax";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var url = "<c:url value="/meals/ajax/setMeal.jsp" />?action=delete&mealId=" + itemuid + "&ts=" + new Date().getTime();
            new Ajax.Updater(id, url,
            {
                evalScripts: true
            });
        }
    }
    refreshMeals = function() {
        searchMeals();
    }
    openBackMeal = function(name) {
        $("mealEdit").show();
        $("mealItemsList").update("");
        Modalbox.resizeToContent();
        Modalbox.setTitle("<%=getTranNoLink("meals","meal",sWebLanguage)%>");
    }
    searchMealItem = function() {
        $("mealEdit").hide();
        var id = "mealItemsList";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = $("manageMealsItemsTable").serialize() + "&withSearchFields=1";
        var url = "<c:url value="/meals/ajax/getMealsItems.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true

        });
        Modalbox.setTitle("<%=getTranNoLink("meals","searchmealitem",sWebLanguage)%>");
    }
    removeMealItem = function(id) {
        if ($("mealmealsitem_" + id)) {
            $("mealmealsitem_" + id).remove();
        }
    }
    insertMealItem = function(id, name, unit) {
        var li = document.createElement('LI');
        li.id = "mealmealsitem_" + id;
        li.innerHTML = "<div style='width:190px'>" + name + "<%="</div><div style='width:150px'><input type='text' size='7' id='mealmealsitemqt_"%>" + id + "' value='0.0'/> " + unit + "<%="</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' class='link' title='" + (getTranNoLink("web","delete",sWebLanguage)) + "' "%>onclick=\"removeMealItem('" + id + "');\"></div>";
        $("mealmealsitems").insert(li, { position: top });
        openBackMeal();
    }
    getNutricientsIntoMeal = function(mealid, notoogle) {
        var id = "mealNutricientsList";
        if (!notoogle && $(id).childElements().length > 0) {
            $(id).innerHTML = "";
            Modalbox.resizeToContent();
            if ($("mealnutricientsbutton").hasClassName("up")) {
                $("mealnutricientsbutton").removeClassName("up");
                $("mealnutricientsbutton").addClassName("down");
            }
            if ($("mealnutricientsrefresh"))$("mealnutricientsrefresh").style.display = "none";
        } else {
            if ($("mealnutricientsbutton").hasClassName("down")) {
                $("mealnutricientsbutton").removeClassName("down");
                $("mealnutricientsbutton").addClassName("up");
            }
            if ($("mealnutricientsrefresh"))$("mealnutricientsrefresh").style.display = "inline";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var params = "ts=" + new Date().getTime();
            var elements = $('mealmealsitems').childElements();
            var reg = new RegExp("[_]+", "g");
            var items = "&items=";
            elements.each(function(s) {
                var t = s.id.split(reg);
                items += t[1] + "-" + ($("mealmealsitemqt_" + t[1]) ? $F("mealmealsitemqt_" + t[1]) : "0") + ",";
            });
            params += items;
            var url = "<c:url value="/meals/ajax/getMealNutricients.jsp" />";
            new Ajax.Updater(id, url,
            {   parameters:params,
                evalScripts: true

            });
        }
    }
</script>

