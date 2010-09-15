<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=checkPermission("manage.meals", "all", activeUser)%><%=writeTableHeader("Web", "manageMealProfiles", sWebLanguage)%>
<table width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){searchMealProfiles();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals", "mealProfileName", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" name="FindMealName" id="FindProfileMealName" size="<%=sTextWidth%>" maxLength="255"> &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchMealProfiles();"> &nbsp;&nbsp;<input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="openMealProfile('-1');">
        </td>
    </tr>
</table>
<div id="mealProfilesResultsByAjax">&nbsp;</div>
<script type="text/javascript">
    searchMealProfiles = function() {
        var id = "mealProfilesResultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = "FindProfileMealName=" + $F("FindProfileMealName");
        var url = "<c:url value="/meals/ajax/getMealsProfiles.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    openMealProfile = function(id) {
        var params = "mealProfileId=" + id;
        var url = "<c:url value="/meals/ajax/getMealProfil.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","mealprofile",sWebLanguage)%>",params:params,width:530});
    }
    setMealProfile = function () {
        var params = "action=save&mealProfileId=" + $F("mealProfileId") + "&mealprofileName=" + $F("mealprofileName");
        var elements = $('mealProfileitems').childElements();
        var reg = new RegExp("[_]+", "g");
        var items = "&mealProfileitems=";
        elements.each(function(s) {
            var t = s.id.split(reg);
            items += t[1] + "-" + ($("mealHour_" + t[1]) ? $("mealHour_" + t[1]).value : "0") + "-" + ($("mealMin_" + t[1]) ? $("mealMin_" + t[1]).value : "0") + ",";
        });
        params += items;
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setMealProfile.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    var mealProfileId = "";
    deleteMealProfile = function(id) {
        mealProfileId = id;
        yesOrNo("deleteMealProfileNext()", "<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }
    deleteMealProfileNext = function() {
        if (mealProfileId.length > 0) {
            var id = "operationByAjax";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var url = "<c:url value="/meals/ajax/setMealProfile.jsp" />?action=delete&mealProfileId=" + mealProfileId + "&ts=" + new Date().getTime();
            new Ajax.Updater(id, url,
            {
                evalScripts: true
            });
        }
    }
    refreshMealsProfils = function() {
        searchMealProfiles();
    }
    openBackMealProfile = function(name) {
        $("mealEdit").show();
        $("mealItemsList").update("");
        Modalbox.resizeToContent();
        Modalbox.setTitle("<%=getTranNoLink("meals","meal",sWebLanguage)%>");
    }
    searchMeal = function() {
        $("mealEdit").hide();
        var id = "mealItemsList";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = $("manageMealsItemsTable").serialize() + "&withSearchFields=1&toMakeProfile=1";
        var url = "<c:url value="/meals/ajax/getMeals.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true

        });
        Modalbox.setTitle("<%=getTranNoLink("meals","searchmealitem",sWebLanguage)%>");
    }
    removeMealfromProfil = function(id) {
        if ($("meal_" + id)) {
            $("meal_" + id).remove();
        }
    }
    insertMealIntoProfile = function(id, name, hour, min) {
        var li = document.createElement('LI');
        li.id = "meal_" + id;
        li.innerHTML = "<div style='width:180px'>" + name + "<%="</div><div style='width:160px'>"%>" + getHoursSelect(id, hour, min) + "<%="</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web","delete",sWebLanguage)) + "' "%>onclick=\"removeMealfromProfil('" + id + "');\"></div>";
        $("mealProfileitems").insert(li, { position: top });
        openBackMealProfile();
    }
    getHoursSelect = function(id, hour, min) {
        var sOut = "<select style='padding:2px;height:auto' id='mealHour_" + id + "' class='text'>";
        for (i = 0; i <= 23; i++) {
            sOut += "<option" + ((hour == i) ? " selected=selected" : "") + " value=" + i + " >" + ((i < 10) ? "0" + i : "" + i) + "</option>";
        }
        sOut += "</select>&nbsp;:&nbsp;<select style='padding:2px;height:auto' id='mealMin_" + id + "' class='text'>";
        for (i = 0; i <= 59; i += 5) {
            sOut += "<option" + ((min == i) ? " selected=selected" : "") + " value=" + i + " >" + ((i < 10) ? "0" + i : "" + i) + "</option>";
        }
        return sOut += "</select>&nbsp;<%=getTran("web.occup", "medwan.common.hour", sWebLanguage)%>";
    }
    getNutricientsIntoProfile = function(mealprofileid,notoogle) {
        var id = "mealprofileNutricientsList";
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
           var elements = $('mealProfileitems').childElements();
            var reg = new RegExp("[_]+", "g");
            var items = "&meals=";
            elements.each(function(s) {
                var t = s.id.split(reg);
                items += t[1]+ ",";
            });
            params += items;
            var url = "<c:url value="/meals/ajax/getProfileNutricients.jsp" />";
            new Ajax.Updater(id, url,
            {   parameters:params,
                evalScripts: true

            });
        }
    }
</script>

