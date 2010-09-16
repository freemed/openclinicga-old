<%@ page import="be.openclinic.adt.Planning,
                 be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO,
                 java.util.Calendar,
                 java.util.Vector,
                 java.util.Hashtable,
                 java.util.Collections" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("planning.user", "select", activeUser)%>
<%=sJSSTRINGFUNCTIONS%>
<%
    String sClass = "";
    Vector v;
    String sKey;
    String sFindUserDate = checkString(request.getParameter("FindUserDate"));
    if (sFindUserDate.length() == 0) {
        sFindUserDate = checkString(request.getParameter("FindDate"));
        if (sFindUserDate.length() == 0) {
            sFindUserDate = getDate();
        }
    }
    String sFindUserUID = checkString(request.getParameter("FindUserUID"));
    if (sFindUserUID.length() == 0) {
        sFindUserUID = activeUser.userid;
    }
%>
<form name="formFindUser" method="post" action="<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&Tab=user&ts=<%=getTs()%>">
    <%=writeTableHeader("planning", "useropenplanning", sWebLanguage, " doBack();")%>
    <table width="100%" class="list" cellspacing="0" cellpadding="0" style="border:none;" onKeyDown='if(event.keyCode==13){if(checkDate($("beginDate"))){refreshAppointments();}return false;}else{return true;}' >
        <tr style="height:30px;">
            <td width="80" class="admin2"  id="FindUserUID_td"><%=getTran("planning", "user", sWebLanguage)%>
            </td>
            <td class="admin2" width="150">
                <select class="text" id="FindUserUID" name="FindUserUID" onchange="displayWeek(makeDate($('beginDate').value));">
                    <option value="-1"><%=getTran("web.occup", "medwan.common.all.users", sWebLanguage)%></option>
                    <%Hashtable hUsers = Planning.getPlanningPermissionUsers(activeUser.userid);
                        v = new Vector(hUsers.keySet());
                        Collections.sort(v);
                        String sSelected, sUserID;
                        for (int i = 0; i < v.size(); i++) {
                            sKey = (String) v.elementAt(i);
                            sUserID = (String) hUsers.get(sKey);
                            if (sUserID.equals(sFindUserUID)) {
                                sSelected = " selected";
                            } else {
                                sSelected = "";
                            }%>
                    <option value="<%=sUserID%>"<%=sSelected%>><%=sKey%>
                    </option>

                    <%}%>
                </select>
            </td>
             <td class="admin2" width="75"><%=getTran("web.control", "week.of", sWebLanguage)%>
            </td>
            <td class="admin2" width="230">
                <input id="PatientID" type="hidden" value='' />
                <input type="button" class="button" name="buttonPrevious" value=" < " onclick="refreshAppointments(displayPreviousWeek());"/>
                <input id="beginDate" type="text" class="text" name="beginDate" value="<%=sFindUserDate%>"  maxLength="10"/>
                <input type="button" class="button" name="buttonNext" value=" > " onclick="refreshAppointments(displayNextWeek())"/>
                <script>writeMyDate("beginDate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2" width="*"><div style="float:left;height:20px;">
                <input type="button" name="buttonsearch" class="button" value="<%=getTran("web","search",sWebLanguage)%>" onclick="if(checkDate($('beginDate')))refreshAppointments();"/>
                <input type="button" name="buttonNew" class="button" value="<%=getTran("web","new",sWebLanguage)%>" onclick="openNewAppointment(null);"/>
                <input type="button" name="buttonback" class="button"  value="<%=getTran("web","back",sWebLanguage)%>" onclick="doBack()"/>
                </div>
                <div id="wait" style="width:130px;display:none">&nbsp;</div>
            </td>
        </tr>

    </table>
    <%=sJSWEEKPLANNERAJAX%><%
    long iZoom = Math.round(Double.parseDouble((checkString(activeUser.getParameter("PlanningFindZoom"))=="")?"40":checkString(activeUser.getParameter("PlanningFindZoom"))));
    if (iZoom == 0) {
        iZoom = 40;
    }
    String sInterval = checkString(activeUser.getParameter("PlanningExamDuration"));
    if (sInterval.length() == 0) {
        sInterval = 30 + "";
    }
    String sFrom = checkString(activeUser.getParameter("PlanningFindFrom"));
    if (sFrom.length() == 0) {
        sFrom = 8 + "";
    }
    String sUntil = checkString(activeUser.getParameter("PlanningFindUntil"));
    if (sUntil.length() == 0) {
        sUntil = 20 + "";
    }%>
    <script type="text/javascript">
        var weekplannerStartHour = <%=Double.valueOf(Math.floor(Float.parseFloat(sFrom))).intValue()%>;
        var weekplannerStopHour = <%=Double.valueOf(Math.ceil(Float.parseFloat(sUntil))).intValue()%>;
        var itemRowHeight = <%=iZoom%>;
        var defaultAppointmentDuration = <%=sInterval%>;
        var patientName = '<%=(activePatient!=null)?activePatient.lastname+" "+activePatient.firstname:""%>';

        if(document.all){
            var containerWidth = document.body.clientWidth-8;
              var containerHeight = document.body.clientHeight - 265;
        }else{
             var containerWidth = document.body.clientWidth-16;
              var containerHeight = document.body.clientHeight - 251;
        }
    </script>
    <%=sJSWEEKPLANNER%><%=sCSSWEEKPLANNER%>
    <script>
        var externalSourceFile_items = '<c:url value='/planning/ajax/getCalendarItems.jsp?ts='/><%=getTs()%>';
        var externalSourceFile_save = '';
        var popupWindowUrl = '<c:url value='/planning/ajax/editPlanning.jsp?ts='/><%=getTs()%>';
    </script>
    <%
        User userSelected = new User();
        userSelected.initialize(Integer.parseInt(sFindUserUID));
        SimpleDateFormat hhmmDateFormat = new SimpleDateFormat("HH:mm");
        Calendar c = Calendar.getInstance();
        int todayNumber = c.getFirstDayOfWeek();
    %>
    <div id="weekScheduler_container">
        <div id="weekScheduler_messages">&nbsp;</div>

        <div id="weekScheduler_top">
            <div class="spacer"><span></span>

                <div id="weekScheduler_warning" onmouseover="$('weekScheduler_warning_popup').show();">&nbsp;</div>
            </div>
            <div class="days" id="weekScheduler_dayRow">
                <div id="top_day_1" class="<%=(todayNumber==1)?"today":""%>"><%=getTran("web", "monday", sWebLanguage)%><span></span></div>
                <div id="top_day_2" class="<%=(todayNumber==2)?"today":""%>"><%=getTran("web", "Tuesday", sWebLanguage)%><span></span></div>
                <div id="top_day_3" class="<%=(todayNumber==3)?"today":""%>"><%=getTran("web", "Wednesday", sWebLanguage)%><span></span></div>
                <div id="top_day_4" class="<%=(todayNumber==4)?"today":""%>"><%=getTran("web", "Thursday", sWebLanguage)%><span></span></div>
                <div id="top_day_5" class="<%=(todayNumber==5)?"today":""%>"><%=getTran("web", "Friday", sWebLanguage)%><span></span></div>
                <div id="top_day_6" class="<%=(todayNumber==6)?"today":""%>"><%=getTran("web", "Saturday", sWebLanguage)%><span></span></div>
                <div id="top_day_0" class="<%=(todayNumber==7)?"today":""%>"><%=getTran("web", "Sunday", sWebLanguage)%><span></span></div>
            </div>
            
        </div>
        <div id="weekScheduler_content">
            <div id="weekScheduler_hours">
                <% int startHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sFrom))).intValue();    // Start hour of week planner
                    int endHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sUntil))).intValue();    // End hour of weekplanner.
                    int endMinOfWeekPlanner = (sUntil.split("\\.").length>1)?Integer.parseInt(sUntil.split("\\.")[1]):0;
                    int iCalendarEnd = (endMinOfWeekPlanner==0)?endHourOfWeekPlanner-1:endHourOfWeekPlanner;


                    Calendar cal = Calendar.getInstance();
                    Date date = cal.getTime();
                    for (int i = startHourOfWeekPlanner; i <= iCalendarEnd; i++) {
                        int hour = i;
                        String suffix = "00"; // Enable this line in case you want to show hours like 08:00 - 23:00
                        String time = hour + "<span class=\"content_hour\" style='line-height:" + iZoom + "px'>" + suffix + "</span>";
                        out.write("<div class='calendarContentTime' style='line-height:" + iZoom + "px;height:" + iZoom + "px'>" + time + "</div>");
                    } %>
            </div>
            <div id="weekScheduler_appointments">
                <% for (int i = 0; i < 7; i++) {    // Looping through the days of a week
                    out.write("<div class='weekScheduler_appointments_day'>");
                    for (int j = startHourOfWeekPlanner; j <= iCalendarEnd; j++) {
                        out.write("<div id='weekScheduler_appointment_hour" + i + "_" + j + "' class='weekScheduler_appointmentHour' style='height:" + iZoom + "px;'><span class='line' style='height:"+((iZoom/2)-2)+"'>&nbsp;</span></div>\n");
                    }
                    out.write("</div>");
                } %>
            </div>
        </div>
    </div>
    <div id="weekScheduler_warning_popup">
        <span class="close" onclick="$('weekScheduler_warning_popup').hide();">x</span>

        <p><%=getTran("Web.UserProfile", "agenda.hidden.appointments", sWebLanguage)%>
        </p>
        <hr/>
        <a href="javascript:activateTab('managePlanning');"><%=getTranNoLink("Web.UserProfile", "changeAgenda", sWebLanguage)%>
        </a>
        <hr/>
        <p><%=getTran("web.occup", "medwan.common.appointment-list", sWebLanguage)%>
        </p>
        <span id="weekScheduler_warning_list" style="display:block"></span>
    </div>
    <div id="responseByAjax" style="display:none;">&nbsp;</div>
    <div id="viewByAjax" style="display:none;">&nbsp;</div>
    <div id="weekScheduler_popup">
        <span class="close" onclick="remInfoPopup();">x</span>
        <ul>
            <li class="open">
                <a href="javascript:openAppointment();remInfoPopup();"><%=getTran("web.occup", "medwan.common.open", sWebLanguage)%>
                </a>
            </li>
            <li class="del">
                <a href="javascript:deleteAppointment2();remInfoPopup();"><%=getTran("web", "delete", sWebLanguage)%>
                </a>
            </li>
            <li class="person">
                <a href="javascript:openDossier();"><%=getTranNoLink("web", "showdossier", sWebLanguage)%>
                </a>
            </li>
            <li class="before">
                <a href="javascript:createBeforeAppointment();remInfoPopup();"><%=getTran("web.control", "insert.appointment.before", sWebLanguage)%>
                </a>
            </li>
            <li style="border:none" class="after">
                <a href="javascript:createNextAppointment();remInfoPopup();"><%=getTran("web.control", "insert.appointment.after", sWebLanguage)%>
                </a>
            </li>

        </ul>
    </div>
    <script>

        function refreshAppointments(_date){
            if(_date)$('beginDate').value=_date;
            displayWeek(makeDate($('beginDate').value));
        }
        <%-- UPDATE APPOINTMENT DATE--%>
        function updateAppointment(params) {
            var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>?ts="+new Date().getTime();
            var div = "responseByAjax";
            new Ajax.Request(url,
            {
                evalScripts: true,
                parameters:params,
                onComplete:
                        function(request) {
                            $(div).update(request.responseText);
                        }
            });
        }
        <%-- OPEN APPOINTMENT --%>
        function createAppointment(params) {

            var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>?ts="+new Date().getTime();
        <%
    // active patient selected by default
        if(activePatient!=null){
            out.write("params+='&PatientId="+activePatient.personid+"';");
            out.write("params+='&PatientName="+((activePatient!=null)?activePatient.lastname+" "+activePatient.firstname:"")+" ("+activePatient.getID("immatnew")+")';");
        }
        %>
            params += "&FindUserUID=" + $("FindUserUID").value + "&EditUserUID=" + $("FindUserUID").value + "&EditPatientUID=<%=(activePatient!=null)?activePatient.personid:""%>";

            Modalbox.show(url, {title: '<%=getTran("web", "planning", sWebLanguage)%>', width: 650,afterHide: function() {refreshAppointments();}}, {evalScripts: true} );
        }
        <%-- OPEN APPOINTMENT --%>
        function openAppointment(id,page) {
            if(id)actualAppointmentId = id;
            var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>" +
                      "?FindUserUID=" + $("FindUserUID").value +
                      "&Date=" + $("beginDate").value + "&FindPlanningUID=" + actualAppointmentId + "&ts="+new Date().getTime();
            if(page)url+="&Page="+page;
            Modalbox.show(url, {title: '<%=getTran("web", "planning", sWebLanguage)%>', width: 650,afterHide: function() {refreshAppointments();}}, {evalScripts: true} );
        }

        <%-- DELETE APPOINTMENT --%>
        function deleteAppointment2(page) {
            if (confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")) {
                var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>?ts="+new Date().getTime();
                var params = "&Action=delete&AppointmentID=" + actualAppointmentId;
                if(page)params+="&Page="+page;
                    var div = "responseByAjax";
                    new Ajax.Request(url,
                    {
                        evalScripts: true,
                        parameters:params,
                        onComplete:
                                function(request) {
                                    $(div).update(request.responseText);
                                }
                    });
            }
        }
        <%-- BACK --%>
        function doClose() {
            if(Modalbox.initialized){
                Modalbox.hide();
            }else
            {
              refreshAppointments();
            }
        }
        function goodTime() {
            if ($("appointmentDateHour").value > $("appointmentDateEndHour").value) {
                return false;
            } else if ($("appointmentDateHour").value == $("appointmentDateEndHour").value && Number($("appointmentDateEndMinutes").value) < (Number($("appointmentDateMinutes").value) + 5)) {
                return false;
            } else {
                return true;
            }
        }
        function openNewAppointment(params){
            if(params==null){
                params = "&Action=new&FindUserUID=" + $F('FindUserUID') + "&AppointmentID=-1&inputId=" + actualAppointmentId
                    + '&appointmentDateDay=' +$("beginDate").value
                    + '&appointmentDateHour=' + <%=sFrom%>
                    + '&appointmentDateMinutes=' + 0
                    + '&appointmentDateEndDay=' + $("beginDate").value
                    + '&appointmentDateEndHour=' + <%=Integer.parseInt(sFrom)+1%>
                    + '&appointmentDateEndMinutes=' + 0;
            }

            var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>?ts="+new Date().getTime();
            Modalbox.show(url, {title: '<%=getTran("web", "planning", sWebLanguage)%>', width: 650,params:params,afterHide: function() {refreshAppointments();}}, {evalScripts: true} );
        }
        <%-- SAVE APPOINTMENT --%>
        function saveAppointment() {
            if($("EditPatientUID").value.length==0 || $F("EditUserUID").length==0 || $F("appointmentDateDay").trim().length==0 ){
                if($("EditPatientUID").value.length==0){
                   $("EditPatientUID").focus();
                }if($F("EditUserUID").length==0){
                   $("EditUserUID").focus();
                }if($F("appointmentDateDay").trim().length==0){
                   $("appointmentDateDay").focus();
                }
                alert("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
            }else if(!goodTime()){
                alert("<%=getTranNoLink("web.errors","appointment.must.5.min.least",sWebLanguage)%>");
            }else{
                var url = "<c:url value='/planning/ajax/editPlanning.jsp'/>?ts="+new Date().getTime();
                var div = "responseByAjax";
                var params = "&EditPlanningUID="+$F("EditPlanningUID")+"&appointmentDateDay="+$("appointmentDateDay").value +"&appointmentDateHour="+$("appointmentDateHour").value+"&appointmentDateMinutes="+
                             $("appointmentDateMinutes").value+"&appointmentDateEndDay="+$("appointmentDateDay").value+"&Action=save"+
                             "&appointmentDateEndHour="+$("appointmentDateEndHour").value+"&appointmentDateEndMinutes="+$("appointmentDateEndMinutes").value+
                             "&EditEffectiveDate="+$("EditEffectiveDate").value+"&EditEffectiveDateTime="+$("EditEffectiveDateTime").value+"&EditCancelationDateTime="+$("EditCancelationDateTime").value+"&EditCancelationDate="+$("EditCancelationDate").value+
                             "&EditUserUID="+$("EditUserUID").value+"&EditPatientUID="+$("EditPatientUID").value+"&EditDescription="+encodeURIComponent($("EditDescription").value)+
                             "&EditContactUID="+$("EditContactUID").value+"&EditContactName="+$("EditContactName").value+"&EditContext="+$("EditContext").value;

                if($("EditTransactionUID")){
                    params+="&EditTransactionUID="+$F("EditTransactionUID");
                }
                if($F("EditPage").length>0)params+="&Page="+$F("EditPage");

                if($("ContactProduct").checked){
                    params+="&EditContactType="+$("ContactProduct").value;
                }else if($("ContactExamination").checked){
                    params+="&EditContactType="+$("ContactExamination").value;
                }
               new Ajax.Request(url,
                {   parameters:params,
                    evalScripts: true,
                    onComplete:function(request) {
                        $(div).update(request.responseText);
                    }
                });
            }
        }
        function doSelectUser(sUid) {
            window.location.href="<c:url value='/main.do'/>?Page=planning/editPlanning.jsp&FindPlanningUID="+sUid+"&FindUserUID="+formFindUser.FindUserUID.value+"&FindDate="+formFindUser.FindUserDate.value+"&Tab=user&ts="+new Date().getTime();
        }
        function doSearchUser() {
            formFindUser.buttonsearch.disabled = true;
            formFindUser.submit();
        }
        function doSelectHourUser(sHour) {
            window.location.href = "<c:url value='/main.do'/>?Page=planning/editPlanning.jsp&FindUserUID=" + formFindUser.FindUserUID.value + "&FindDate=" + formFindUser.FindUserDate.value + "&FindHour=" + sHour + "&Tab=user&ts="+new Date().getTime();
        }
        function setInsertImpossibleMsg() {
            clientMsg.setError("<%=getTranNoLink("web.userprofile","agenda.insert.not.possible",sWebLanguage)%>",null, 6000);
        }
        function searchUser(fieldUID, fieldName) {
            openPopup("/_common/search/searchUser.jsp&ts="+new Date().getTime()+"&ReturnUserID=" + fieldUID + "&ReturnName=" + fieldName + "&displayImmatNew=no");
        }
        function searchMyPatient(fieldUID, fieldName) {
            openPopup("/_common/search/searchPatient.jsp&ts="+new Date().getTime()+"&ReturnPersonID=" + fieldUID + "&ReturnName=" + fieldName + "&displayImmatNew=no");
        }
        function searchPrestation(prestationUidField, prestationNameField) {
            if (document.getElementById("ContactProduct").checked) {
                openPopup("/_common/search/searchProduct.jsp&ts="+new Date().getTime()+"&ReturnProductUidField=" + prestationUidField + "&ReturnProductNameField=" + prestationNameField);
            }
            else if (document.getElementById("ContactExamination").checked) {
                openPopup("/_common/search/searchExamination.jsp&ts="+new Date().getTime()+"&VarCode=" + prestationUidField + "&VarText=" + prestationNameField + "&VarUserID=" + $("EditUserUID").value);
            }
        }
        function changeContactType() {
            checkContext();
            $("EditContactUID").value = "";
            $("EditContactName").value = "";
        }
        function checkContext() {
            if (document.getElementById("ContactExamination").checked) {
                document.getElementById("EditContext").disabled = false;
            }
            else {
                $("EditContext").value = -1;
                document.getElementById("EditContext").disabled = true;
            }
        }
         function resizeSheduler(containerHeight,containerWidth){
            $("weekScheduler_content").style.height = containerHeight + "px";
            $("weekScheduler_container").style.width = containerWidth + "px";
            var divs = $("weekScheduler_content").getElementsByClassName("weekScheduler_appointments_day");
            var divs2 = $("weekScheduler_dayRow").getElementsByTagName("DIV");
            for(i=0;i<divs.length;i++){
                var w = ((containerWidth/7)-11);
                divs[i].style.width =w+"px";
                divs2[i].style.width = w+"px";
            }
         }
         function openDossier(id,setEffectiveDate){
             if(!setEffectiveDate){
                 setEffectiveDate = "";
             }
              var div = "responseByAjax";
             var url = "<c:url value='/planning/ajax/openDossier.jsp'/>?FindPlanningUID="+actualAppointmentId+"&setEffectiveDate="+setEffectiveDate+"&ts="+new Date().getTime();
              new Ajax.Updater(div,url,
                {   evalScripts: true });
         }
        function redirectToDossier(personId){
            if(personId)window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&PersonID="+personId+"&ts="+new Date().getTime();
        }

        <%-- SET SELECT MINUTES OF EDIT FORM --%>
        function setCorrectAppointmentDate(minH,minM,maxH,maxM){
            if($("appointmentDateHour").value==minH){
                setMinuteSelect('appointmentDateMinutes',minM);
            }else if($("appointmentDateHour").value==maxH){
                
                 setMinuteSelect('appointmentDateMinutes',null,(maxM));
            }else{
               setMinuteSelect('appointmentDateMinutes');// set all minutes
            }

            if($("appointmentDateEndHour").value==minH){
                setMinuteSelect('appointmentDateEndMinutes',minM);
            }else if($("appointmentDateEndHour").value>=maxH ){
                if($("appointmentDateEndHour").value==maxH && maxM==0){
                   $("appointmentDateEndMinutes").options.length = 1;
                   $("appointmentDateEndMinutes").options.value = '00';
                   $("appointmentDateEndMinutes").options.text = '00';
                }else{
                   $("appointmentDateEndHour").value=maxH;
                   setMinuteSelect('appointmentDateEndMinutes',null,maxM);
                }
            }else{
               setMinuteSelect('appointmentDateEndMinutes');// set all minutes
            }
        }
        function setMinuteSelect(field,minM,maxM){
            var i = 0;
            var cpt = 0;
            var selected = $(field).value;
            if(minM){
               if(minM>$(field).value)selected = minM;
               $(field).options.length = (55/5)-(minM/5)+1;
                i = minM;
                for(i;i<=55;i=i+5){
                    $(field).options[cpt].text = (i>=10)?i:"0"+i;
                    $(field).options[cpt].value = i;
                    if(selected==i)$(field).options[cpt].selected = true;
                    cpt++;
                }
            }else if(maxM){
               if(maxM<parseInt($(field).value)){
                   selected = maxM;
               }
               $(field).options.length = (55/5)-((55/5)-(maxM/5))+1;

                for(i;i<=maxM;i=i+5){
                    $(field).options[cpt].text = (i>=10)?i:"0"+i;
                    $(field).options[cpt].value = i;
                    if(selected==i){
                        $(field).options[cpt].selected = true;
                    }
                    cpt++;
                }
            }else{
                // to normalize
                 if($(field).options.length<12){
                     $(field).options.length = 12;
                     for(i;i<=55;i=i+5){
                        $(field).options[cpt].text = (i>=10)?i:"0"+i;
                        $(field).options[cpt].value = i;
                        if(selected==i)$(field).options[cpt].selected = true;
                        cpt++;
                    }
                 }
            }
        }

        resizeSheduler(containerHeight,containerWidth);
        clientMsg.setDiv("weekScheduler_messages");
    </script>
</form>
  