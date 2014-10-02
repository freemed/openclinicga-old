<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=sCSSGNOOCALENDAR%><%=sJSGNOOCALENDAR%>
<%=checkPermission("manage.meals", "all", activeUser)%>
<%=writeTableHeader("Web", "managePatientItems", sWebLanguage)%>
<table width="100%">
    <tr width="100%" style="background:#DDEDFF;">
        <td rowspan="2" width="200" style="vertical-align:top;" style="padding:3px 0px 0px 20px;">
            <%=getTran("meals", "chooseaday", sWebLanguage)%>
            <div id="gnoocalendar" style="_margin-top:-10px">&nbsp;</div>
        </td>
        <td width="*" style="vertical-align:top;" style="padding:11px 0px 5px 20px;_padding:5px 0 0 20px;height:25px">
            <input type="button" style="padding:0 5px 0 5px" class="button" value="<" onclick="addDays($F('datechoosed'),-1);"/>
            <input type="text" style="width:100px;text-align:center" id="datechoosed" value="9/08/2009" class="text" disabled="true"/>
            <input type="button" style="padding:0 5px 0 5px" class="button" value=">" onclick="addDays($F('datechoosed'),+1);"/>
            <input type="button" class="button" value="<%=getTranNoLink("web","add",sWebLanguage)%> <%=getTranNoLink("meals","meal",sWebLanguage)%>" onclick="getMeals();"/> &nbsp;
            <input type="button" class="button" value="<%=getTranNoLink("web","add",sWebLanguage)%> <%=getTranNoLink("meals","profil",sWebLanguage)%>" onclick="getProfiles();"/>
             <a href="javascript:void(0)" id="mealnutricientsbutton" class="link down" onclick="getNutricientsIntoPatientMeals(false);"><span><%=getTranNoLink("meals", "seenutricients", sWebLanguage).toLowerCase()%></span></a>
             <ul id="patientMealsNutricientsList" class="items" style="width:370px;float:none;"></ul>
        </td>
    </tr>
    <tr style="background:#DDEDFF;">
        <td width="*" style="vertical-align:top;">

            <div id="contentblock" style="margin-top:-2px;float:left;width:100%">&nbsp;</div>
        </td>
    </tr>
</table>
<script>
    getPatientMeals = function() {
        var id = "contentblock";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var params = "FindMealByDay=" + $F("datechoosed");
        var url = "<c:url value="/meals/ajax/getPatientMeals.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true,
            asynchronous:false

        });
    }
    getPatientMeal = function(id, update,patientmealid) {
        var params = "mealId=" + id + "&ts=" + new Date().getTime() + "&FindMealByDay=" + $F("datechoosed");
        if(!patientmealid){
            patientmealid="-1";
        }

        params+="&patientmealId="+patientmealid;
        var url = "<c:url value="/meals/ajax/getPatientMeal.jsp" />";
        if (update) {
            Modalbox.show(url, {title:"<%=getTranNoLink("meals","updatepatientmeal",sWebLanguage)%> " + $F("datechoosed"),params:params,width:530});
        }
        else {
            Modalbox.show(url, {title:"<%=getTranNoLink("meals","addpatientmeal",sWebLanguage)%> " + $F("datechoosed"),params:params,width:530});
        }
    }
    getPatientMealProfile = function(id) {
        var params = "mealProfileId=" + id + "&ts=" + new Date().getTime() + "&FindMealByDay=" + $F("datechoosed");
        var url = "<c:url value="/meals/ajax/getPatientMealProfil.jsp" />";
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","addpatientmealprofile",sWebLanguage)%> " + $F("datechoosed"),params:params,width:530});
    }
    getMeals = function() {
        var params = "withSearchFields=1&ts=" + new Date().getTime();
        var url = "<c:url value="/meals/ajax/getMeals.jsp" />";
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","searchmeals",sWebLanguage)%> ",params:params,width:530});
    }
    getProfiles = function() {
        var params = "withSearchFields=1&ts=" + new Date().getTime();
        var url = "<c:url value="/meals/ajax/getMealsProfiles.jsp" />";
        Modalbox.show(url, {title:"<%=getTranNoLink("meals","searchmealsprofiles",sWebLanguage)%> ",params:params,width:530});
    }
    setPatientMeal = function(id) {
        var params = "patientMealId="+$("patientMealId").value+"&action=save&mealId=" + id + "&choosedDate=" + encodeURI($("datechoosed").value) + "&mealHour=" + $("mealHour").value + "&mealMin=" + $("mealMin").value + "&mealtakenyes=" + $("mealtakenyes").checked;
        var id = "operationByAjax";

        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setPatientMeal.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    setPatientProfil = function(id) {
        var params = "action=save&mealProfileId=" + id + "&choosedDate=" + encodeURI($("datechoosed").value);
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setPatientProfil.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    refreshPatientMeals = function() {
        getPatientMeals();
    }
    var mealuid = "";
    deleteMealFromPatient = function(id) {
        mealuid = id;
        yesOrNo("deleteMealFromPatientNext()", "<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }
    deleteMealFromPatientNext = function() {
        var params = "action=delete&mealId=" + mealuid + "&choosedDate=" + encodeURI($("datechoosed").value);
        var id = "operationByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/meals/ajax/setPatientMeal.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
    setMealTaken = function(mealid, taken) {
        var id = "operationByAjax";
        var params = "mealId=" + mealid + "&taken=" + taken + "&ts=" + new Date().getTime() + "&choosedDate=" + encodeURI($("datechoosed").value);
        var url = "<c:url value="/meals/ajax/setMealTaken.jsp" />";
        new Ajax.Updater(id, url,
        {  method:'post', parameters:params,
            evalScripts: true

        });
    }
     getNutricientsIntoPatientMeals = function(notoogle) {
        var id = "patientMealsNutricientsList";
        if ((!notoogle && $(id).childElements().length > 0) || !$("patientmeals")) {
            $(id).innerHTML = "";
            if ($("mealnutricientsbutton").hasClassName("up")) {
                $("mealnutricientsbutton").removeClassName("up");
                $("mealnutricientsbutton").addClassName("down");
            }
        } else {
            if ($("mealnutricientsbutton").hasClassName("down")) {
                $("mealnutricientsbutton").removeClassName("down");
                $("mealnutricientsbutton").addClassName("up");
            }
            if ($("mealnutricientsrefresh"))$("mealnutricientsrefresh").style.display = "inline";
            $(id).update("<div id='wait'>&nbsp;</div>");
            var params = "ts=" + new Date().getTime();
           var elements = $('patientmeals').getElementsBySelector("TR");
            var reg = new RegExp("[_]+", "g");
            var items = "&meals=";
            elements.each(function(s) {
                if(s.id.length>0){
                    var t = s.id.split(reg);
                   items += t[1]+ ",";
                }
            });
            params += items;
            var url = "<c:url value="/meals/ajax/getProfileNutricients.jsp" />";
            new Ajax.Updater(id, url,
            {   parameters:params,
                evalScripts: true

            });
        }
     }


    var CL = null;
    initCalendar = function() {
            getToday($("datechoosed"));
            addDays($F('datechoosed'), 0);

    }
    addDays = function(d, j)
    {
        try {
            var _date = new Date(makeDate(d).getTime() + (1000 * 60 * 60 * 24 * j));
            if (_date)$('datechoosed').value = (((_date.getDate() > 9) ? "" : "0") + _date.getDate()) + "/" + ((_date.getMonth() > 8) ? "" : "0") + (_date.getMonth() + 1) + "/" + y2k(_date.getYear());
        //    $("gnoocalendar").update(_date);
            CL = new GnooCalendar("CL", 20, 10, null, _date);
            CL.change("gnoocalendar", $("datechoosed"), _date);
            CL.show();
            CL.setTitle("");
        } catch(e) {
            alert(e);
        }
        getPatientMeals();
    }
    executeDate = function() {
        getPatientMeals();
    }
</script>
