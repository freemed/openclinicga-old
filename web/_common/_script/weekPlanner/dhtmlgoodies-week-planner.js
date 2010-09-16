/* User variables */
var headerDateFormat = 'd/m';	// Format of day, month in header, i.e. at the right of days
var instantSave = true;	// Save items to server every time something has been changed (i.e. moved, resized or text changed) - NB! New items are not saved until a description has been written?
var externalSourceFile_items = 'getCalendarItems.jsp';	// File called by ajax when changes are loaded from the server(by Ajax).
var externalSourceFile_save = 'week_schedule_save.php';	// File called by ajax when changes are made to an element
var externalSourceFile_delete = 'week_schedule_delete.php';	// File called by ajax when an element is deleted. Input to this file is the variable "eventToDeleteId=<id>"
var popupWindowUrl = 'edit_event.html';	// Called when double clicking on an event. use false if this option is disabled.
var popupDivId = 'weekSchedulerFormByAjax';
var txt_deleteEvent = 'Click OK to delete this event';	// Text in dialog box - confirm before deleting an event
//var itemRowHeight = 50;
var appointmentMarginSize = 7;	// Margin at the left and right of appointments;
var initTopHour = 0;	// Initially auto scroll scheduler to the position of this hour
var initMinutes = 15;	// Used to auto set start time. Example: 15 = auto set start time to 0,15,30 or 45. It all depends on where the mouse is located ondragstart
var snapToMinutes = 15;	// Snap to minutes, example: 5 = allow minute 0,5,10,15,20,25,30,35,40,45,50,55
//var weekplannerStartHour = 6;	// If you don't want to display all hours from 0, but start later, example: 8am
var initDateToShow = new Date();
var inlineTextAreaEnabled = false;	// Edit events from inline textarea?
var actualAppointmentId;
/* End user variables */
var weekScheduler_container = false;
var weekScheduler_appointments = false;
var newAppointmentCounter = -1;
var moveAppointmentCounter = -1;
var resizeAppointmentCounter = -1;
var resizeAppointmentInitHeight = false;
var el_x;	// x position of element
var el_y;	// y position of element
var mouse_x;
var mouse_y;
var elWidth;
var currentAppointmentDiv = false;
var currentAppointmentContentDiv = false;
var currentTimeDiv = false;
var appointmentsOffsetTop = false;
var appointmentsOffsetLeft = false;
var currentZIndex = 20000;
var dayPositionArray = new Array();
var dayDateArray = new Array();
var weekSchedule_ajaxObjects = new Array();
var dateStartOfWeek = false;
var newAppointmentWidth = false;
var startIdOfNewItems = 500000000;
var contentEditInProgress = false;
var toggleViewCounter = -1;
var objectToToggle = false;
var currentEditableTextArea = false;
var appointments = new Array();
var appointmentProperties = new Array();	// Array holding properties of appointments/events.
var opera = navigator.userAgent.toLowerCase().indexOf('opera') >= 0 ? true : false;
var activeEventObj;	// Reference to element currently active, i.e. with blue header;
function trimString(sInString) {
    sInString = sInString.replace(/^\s+/g, "");
    return sInString.replace(/\s+$/g, "");
}
/* edited by emanuel@mxs.be */
function editEventWindow(e, inputDiv)
{
    if (!inputDiv)inputDiv = this;
    if (!popupWindowUrl)return;
    var url = popupWindowUrl;
    var div = popupDivId;
    actualAppointmentId = inputDiv.id;
    openAppointment();
}
function setElementActive(e, inputDiv)
{
    if (!inputDiv)inputDiv = this;
    var subDivs = inputDiv.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointment_header') {
            subDivs[no].className = 'weekScheduler_appointment_headerActive';
        }
    }
    if (activeEventObj && activeEventObj != inputDiv) {
        setElementInactive(activeEventObj);
    }
    activeEventObj = inputDiv;
}
function setElementInactive(inputDiv)
{
    var subDivs = inputDiv.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointment_headerActive') {
            subDivs[no].className = 'weekScheduler_appointment_header';
        }
    }
}
function parseItemsFromServer(ajaxIndex)
{
    //   if($("weekScheduler_warning_list")){$("weekScheduler_warning_list").innerHTML = ''};
    $("weekScheduler_warning_popup").style.display = "none";
    $('weekSchedulerFormByAjax').hide();
    var s = ""
    var itemsToBeCreated = new Array();
    var items = weekSchedule_ajaxObjects[ajaxIndex].response.split(/<item>/g);
    weekSchedule_ajaxObjects[ajaxIndex] = false;
    for (var no = 1; no < items.length; no++) {
        var lines = items[no].split(/\n/g);
        itemsToBeCreated[no] = new Array();
        for (var no2 = 0; no2 < lines.length; no2++) {
            var key = lines[no2].replace(/<([^>]+)>.*/g, '$1');
            if (key)key = trimString(key);
            var pattern = new RegExp("<\/?" + key + ">", "g");
            var value = lines[no2].replace(pattern, '');
            value = trimString(value);
            if (key == 'eventStartDate' || key == 'eventEndDate') {
                var d = new Date(value);
                value = d;
            }
            itemsToBeCreated[no][key] = value;
        }
        if (itemsToBeCreated[no]['id']) {
            if (itemsToBeCreated[no]['hidden'].length == 0) {
                var dayDiff = itemsToBeCreated[no]['eventStartDate'].getTime() - dateStartOfWeek.getTime();
                dayDiff = Math.floor(dayDiff / (1000 * 60 * 60 * 24));
                el_x = dayPositionArray[dayDiff];
                topPos = getYPositionFromTime(itemsToBeCreated[no]['eventStartDate'].getHours(), itemsToBeCreated[no]['eventStartDate'].getMinutes());
                var elHeight = (itemsToBeCreated[no]['eventEndDate'].getTime() - itemsToBeCreated[no]['eventStartDate'].getTime()) / (60 * 60 * 1000);
                elHeight = Math.round((elHeight * (itemRowHeight + 1)) - 2);
                currentAppointmentDiv = createNewAppointmentDiv((el_x - appointmentsOffsetLeft), topPos, (newAppointmentWidth - (appointmentMarginSize * 2)), itemsToBeCreated[no]['description'], elHeight);
                if(itemsToBeCreated[no]['effective'].length>0){
                   currentAppointmentDiv.className +=" effective";
                  currentAppointmentDiv.firstChild.className +=" effectiveHeader";
                }
                currentAppointmentDiv.id = itemsToBeCreated[no]['id'];
                currentZIndex = currentZIndex + 1;
                currentAppointmentDiv.style.zIndex = currentZIndex;
                currentTimeDiv = getCurrentTimeDiv(currentAppointmentDiv);
                currentTimeDiv.style.display = 'block';
                currentAppointmentDiv.style.marginLeft = itemsToBeCreated[no]['marginleft'] + "px";
                currentAppointmentContentDiv = getCurrentAppointmentContentDiv(currentAppointmentDiv);
                try {
                    currentAppointmentContentDiv.style.height = (elHeight - 20) + 'px';
                } catch(e) {
                }

           // currentTimeDiv.innerHTML = '<span>' + getTime(currentAppointmentDiv) + '</span>';
                autoResizeAppointment();
               // currentAppointmentDiv = false;
                currentTimeDiv = false;
                var newIndex = itemsToBeCreated[no]['id'];
                appointmentProperties[newIndex] = new Array();
                appointmentProperties[newIndex]['id'] = itemsToBeCreated[no]['id'];
                appointmentProperties[newIndex]['description'] = itemsToBeCreated[no]['description'];
                appointmentProperties[newIndex]['eventStartDate'] = itemsToBeCreated[no]['eventStartDate'];
                appointmentProperties[newIndex]['eventEndDate'] = itemsToBeCreated[no]['eventEndDate'];
                appointmentProperties[newIndex]['object'] = currentAppointmentDiv;
                var ap = new Appointment(itemsToBeCreated[no]['id'], itemsToBeCreated[no]['marginleft'], itemsToBeCreated[no]['description'], itemsToBeCreated[no]['effective'], itemsToBeCreated[no]['eventStartDate'], itemsToBeCreated[no]['eventEndDate'], currentAppointmentDiv);
                appointments.push(ap);
            } else {
                $("weekScheduler_warning_list").innerHTML = ($("weekScheduler_warning_list").innerHTML + "<a href='javascript:$(\"weekScheduler_warning_popup\").hide();actualAppointmentId = " + itemsToBeCreated[no]['id'] + ";openAppointment();'>" + itemsToBeCreated[no]['hidden'] + "</a><br />");
            }
        }
    }
   // $("weekScheduler_messages").hide();
    if ($("weekScheduler_warning_list").innerHTML.length == 0) {
        $("weekScheduler_warning").hide();
    } else {
        $("weekScheduler_warning").show();
    }
    currentAppointmentDiv = false;
    $("wait").hide();
}
/* Update date and hour properties for an appointment after move or drag */
function updateAppointmentProperties(id)
{
    var obj = document.getElementById(id);
    var timeArray = getTimeAsArray(obj);
    var startDate = getAppointmentDate(obj);
    var endDate = new Date();
    endDate.setTime(startDate.getTime());
    startDate.setHours(timeArray[0]);
    startDate.setMinutes(timeArray[1]);
    endDate.setHours(timeArray[2]);
    endDate.setMinutes(timeArray[3]);
    /*
     var startDateString = startDate.toGMTString().replace('UTC','GMT');
     var endDateString = endDate.toGMTString().replace('UTC','GMT');
     */
    var appointment = getAppointment(obj.id);
   // alert(getAppointment(obj.id).id+" -> "+appointmentProperties[obj.id].id);
    appointmentProperties[obj.id]['eventStartDate'] = startDate;
    appointmentProperties[obj.id]['eventEndDate'] = endDate;
    appointment.eventStartDate = startDate;
    appointment.eventEndDate = endDate;
    var dateStart = new Date(appointmentProperties[currentAppointmentDiv.id]['eventStartDate'].toGMTString().replace('UTC', 'GMT'));
    var dateEnd = new Date(appointmentProperties[currentAppointmentDiv.id]['eventEndDate'].toGMTString().replace('UTC', 'GMT'));
    var saveString = "&Action=update&AppointmentID=" + appointmentProperties[currentAppointmentDiv.id]["id"]
            + '&appointmentDateDay=' + dateStart.getDate() + "/" + (Number(dateStart.getMonth() + 1)) + "/" + dateStart.getFullYear()
            + '&appointmentDateHour=' + dateStart.getHours()
            + '&appointmentDateMinutes=' + dateStart.getMinutes()
            + '&appointmentDateEndDay=' + dateEnd.getDate() + "/" + (Number(dateEnd.getMonth() + 1)) + "/" + dateEnd.getFullYear()
            + '&appointmentDateEndHour=' + dateEnd.getHours()
            + '&appointmentDateEndMinutes=' + dateEnd.getMinutes() ;
    if (obj.id.indexOf('new_') != 0) {
        updateAppointment(saveString);
    }
   // alert(appointment.eventStartDate);
}
function getYPositionFromTime(hour, minute) {
    return Math.floor((hour - weekplannerStartHour) * (itemRowHeight + 1) + (minute / 60 * (itemRowHeight + 1)));
}
function getItemsFromServer()
{
    $("wait").style.display = "inline";
    var ajaxIndex = weekSchedule_ajaxObjects.length;
    weekSchedule_ajaxObjects[ajaxIndex] = new sack();
    weekSchedule_ajaxObjects[ajaxIndex].requestFile = externalSourceFile_items + '&PatientID=' + $F("PatientID") + '&FindUserUID=' + $F("FindUserUID") + '&year=' + dateStartOfWeek.getFullYear() + '&month=' + (dateStartOfWeek.getMonth() / 1 + 1) + '&day=' + dateStartOfWeek.getDate();	// Specifying which file to get
    weekSchedule_ajaxObjects[ajaxIndex].onCompletion = function() {
        parseItemsFromServer(ajaxIndex);
    };	// Specify function that will be executed after file has been found
    weekSchedule_ajaxObjects[ajaxIndex].runAJAX();		// Execute AJAX function   *
}
function getCurrentTimeDiv(inputObj)
{
    var subDivs = inputObj.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointment_time') {
            return subDivs[no];
        }
    }
}
function getCurrentTextDiv(inputObj)
{
    var subDivs = inputObj.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointment_txt') {
            return subDivs[no];
        }
    }
}
function getCurrentAppointmentContentDiv(inputDiv)
{
    var divs = inputDiv.getElementsByTagName('DIV');
    for (var no = 0; no < divs.length; no++) {
        if (divs[no].className == 'weekScheduler_appointment_txt')return divs[no];
    }
}
function getAppointmentDate(inputObj)
{
    var leftPos = getLeftPos(inputObj);
    var d = new Date();
    var tmpTime = dateStartOfWeek.getTime();
    tmpTime = tmpTime + (1000 * 60 * 60 * 24 * Math.floor((leftPos - appointmentsOffsetLeft) / (dayPositionArray[1] - dayPositionArray[0])));
    d.setTime(tmpTime);
    return d;
}
function getTimeAsArray(inputObj)
{
    var startTime = (getTopPos(inputObj) - appointmentsOffsetTop) / (itemRowHeight + 1) + weekplannerStartHour;
    var startHour = Math.floor(startTime);
    var hourPrefix = "";
    var startMinute = Math.floor((startTime - startHour) * 60);
    while (startMinute % 5) {
        startMinute++;
    }
    if (startMinute == 60) {
        startMinute = 0;
        startHour++;
    }
    var startMinutePrefix = "";
    if (startHour < 10)hourPrefix = "0";
    if (startMinute < 10)startMinutePrefix = "0";
    var endTime = (getTopPos(inputObj) + inputObj.offsetHeight - appointmentsOffsetTop) / (itemRowHeight + 1) + weekplannerStartHour;
    var endHour = Math.floor(endTime);
    var endHourPrefix = "";
    var endMinute = Math.floor((endTime - endHour) * 60);
    while (endMinute % 5) {
        endMinute++;
    }
    if (endMinute == 60) {
        endMinute = 0;
        endHour++;
    }
    var endMinutePrefix = "";
    if (endMinute < 10)endMinutePrefix = "0";
    if (endHour < 10)endHourPrefix = "0";
    return Array(startHour, startMinute, endHour, endMinute);
}
function getTime(inputObj)
{
    var startTime = (getTopPos(inputObj) - appointmentsOffsetTop) / (itemRowHeight + 1) + weekplannerStartHour;
    var startHour = Math.floor(startTime);
    var hourPrefix = "";
    var startMinute = Math.floor((startTime - startHour) * 60);
    while (startMinute % 5) {
        startMinute++;
    }
    if (startMinute == 60) {
        startMinute = 0;
        startHour++;
    }
    var startMinutePrefix = "";
    if (startHour < 10)hourPrefix = "0";
    if (startMinute < 10)startMinutePrefix = "0";
    var endTime = (getTopPos(inputObj) + inputObj.offsetHeight - appointmentsOffsetTop) / (itemRowHeight + 1) + weekplannerStartHour;
    var endHour = Math.floor(endTime);
    var endHourPrefix = "";
    var endMinute = Math.floor((endTime - endHour) * 60);
    while (endMinute % 5) {
        endMinute++;
    }
    if (endMinute == 60) {
        endMinute = 0;
        endHour++;
    }
    var endMinutePrefix = "";
    if (endMinute < 10)endMinutePrefix = "0";
    if (endHour < 10)endHourPrefix = "0";
    return hourPrefix + startHour + ':' + startMinutePrefix + "" + startMinute + ' - ' + endHourPrefix + endHour + ':' + endMinutePrefix + "" + endMinute;
}
function initNewAppointment(e, inputObj) {
    if (document.all && typeof event != "undefined")e = event;
    if (!inputObj)inputObj = this;
    remInfoPopup();
    newAppointmentCounter = 0;
    el_x = getLeftPos(inputObj);
    el_y = getTopPos(inputObj);
    elWidth = inputObj.offsetWidth;
    mouse_x = e.clientX;
    mouse_y = e.clientY;
    timerNewAppointment();
    return false;
}
function timerNewAppointment()
{
    if (newAppointmentCounter >= 0 && newAppointmentCounter < 10) {
        newAppointmentCounter = newAppointmentCounter + 1;
        setTimeout('timerNewAppointment()', 30);
        return;
    }
    if (newAppointmentCounter == 10) {
        if (initMinutes) {
            var topPos = mouse_y - appointmentsOffsetTop + document.documentElement.scrollTop + document.getElementById('weekScheduler_content').scrollTop;
            topPos = topPos - (getMinute(topPos) % initMinutes);
            var rest = (getMinute(topPos) % initMinutes);
            if (rest != 0) {
                topPos = topPos - (getMinute(topPos) % initMinutes);
            }
        } else {
            var topPos = (el_y - appointmentsOffsetTop);
        }
        currentAppointmentDiv = createNewAppointmentDiv((el_x - appointmentsOffsetLeft), topPos, (elWidth - (appointmentMarginSize * 2)), '');
        currentAppointmentDiv.id = 'new_' + startIdOfNewItems;
        appointmentProperties[currentAppointmentDiv.id] = new Array();
        appointmentProperties[currentAppointmentDiv.id]['description'] = "";
        appointmentProperties[currentAppointmentDiv.id]['object'] = currentAppointmentDiv;
        appointmentProperties[currentAppointmentDiv.id]['id'] = currentAppointmentDiv.id;
        startIdOfNewItems++;
        currentAppointmentContentDiv = getCurrentAppointmentContentDiv(currentAppointmentDiv);
        currentAppointmentDiv.style.height = '20px';
        currentTimeDiv = getCurrentTimeDiv(currentAppointmentDiv);
        currentTimeDiv.style.display = 'block';

     //   function(id, margin, description, bgColorCode, eventStartDate, eventEndDate, obj) {
        var appoint = new Appointment(currentAppointmentDiv.id, 0, "", "", "", "", currentAppointmentDiv);
        appoint.eventEndDate = new Date();
        appoint.eventStartDate = new Date();
        appointments.push(appoint);
    }
}
function initResizeAppointment(e)
{
    remInfoPopup();
    if (document.all && typeof event != "undefined")e = event;
    currentAppointmentDiv = this.parentNode;
    currentAppointmentContentDiv = getCurrentAppointmentContentDiv(currentAppointmentDiv);
   //bringToFront(currentAppointmentDiv);
    resizeAppointmentCounter = 0;
    el_x = getLeftPos(currentAppointmentDiv);
    el_y = getTopPos(currentAppointmentDiv);
    mouse_x = e.clientX;
    mouse_y = e.clientY;
    resizeAppointmentInitHeight = currentAppointmentDiv.style.height.replace('px', '') / 1;
    $("viewByAjax").update("init");
    timerResizeAppointment();
    return false;
}
function timerResizeAppointment()
{
    if (resizeAppointmentCounter >= 0 && resizeAppointmentCounter < 10) {
        resizeAppointmentCounter = resizeAppointmentCounter + 1;
        setTimeout('timerResizeAppointment()', 10);
        return;
    }
    if (resizeAppointmentCounter == 10) {
        currentTimeDiv = getCurrentTimeDiv(currentAppointmentDiv);
        currentTimeDiv.style.display = 'block';
    }
}
function initInfoPopup(e, inputObj)
{
    if (document.all && typeof event != "undefined")e = event;
    if (!inputObj)inputObj = this.parentNode.parentNode;
    currentAppointmentDiv = inputObj;
    currentAppointmentContentDiv = getCurrentAppointmentContentDiv(currentAppointmentDiv);
    var evt = e;
    var rightedge = window.innerWidth - evt.clientX;
    var bottomedge = window.innerHeight - evt.clientY;
    if (document.all) {
        rightedge = document.body.offsetWidth - evt.clientX;
        bottomedge = document.body.offsetHeight - evt.clientY;
    }

 //   alert(rightedge+" < "+$("weekScheduler_popup").getWidth()+" -  "+bottomedge);
    if (rightedge < $("weekScheduler_popup").getWidth()) {
        $("weekScheduler_popup").style.left = document.body.scrollLeft + evt.clientX - $("weekScheduler_popup").getWidth();
        if (bottomedge < $("weekScheduler_popup").getHeight()) {
            $("weekScheduler_popup").style.top = document.body.scrollTop + evt.clientY - $("weekScheduler_popup").getHeight();
        }
        else {
            $("weekScheduler_popup").style.top = document.body.scrollTop + evt.clientY;
        }
    } else {
        $("weekScheduler_popup").style.left = document.body.scrollLeft + evt.clientX;
        if (bottomedge < $("weekScheduler_popup").getHeight()) {
            $("weekScheduler_popup").style.top = document.body.scrollTop + evt.clientY - $("weekScheduler_popup").getHeight();
        }
        else {
            $("weekScheduler_popup").style.top = document.body.scrollTop + evt.clientY;
        }
    }
    if (document.all) {
        var topPos = Number($("weekScheduler_popup").style.top.substring(0, $("weekScheduler_popup").style.top.length - 2));
        $("weekScheduler_popup").style.top = topPos - 10;
    }
    currentAppointmentDiv = inputObj;
    $("weekScheduler_popup").style.display = "block";
    $("weekScheduler_popup").style.zIndex = currentAppointmentDiv.style.zIndex * 2;
    actualAppointmentId = (currentAppointmentDiv.id);
  //  initToggleView(e);
    return false;
}
function remInfoPopup() {
    $("weekScheduler_popup").hide();
    $("weekScheduler_warning_popup").hide();
}
function createBeforeAppointment() {
    var dateEnd = new Date(getAppointment(actualAppointmentId).eventStartDate.toGMTString().replace('UTC', 'GMT'));
    var dateStart = new Date(dateEnd);
    dateStart.setMinutes(dateStart.getMinutes() - defaultAppointmentDuration);
    var saveString = "&Action=new&FindUserUID=" + $F('FindUserUID') + "&AppointmentID=-1&inputId=" + actualAppointmentId
            + '&appointmentDateDay=' + dateStart.getDate() + "/" + (Number(dateStart.getMonth() + 1)) + "/" + dateStart.getFullYear()
            + '&appointmentDateHour=' + dateStart.getHours()
            + '&appointmentDateMinutes=' + dateStart.getMinutes()
            + '&appointmentDateEndDay=' + dateEnd.getDate() + "/" + (Number(dateEnd.getMonth() + 1)) + "/" + dateEnd.getFullYear()
            + '&appointmentDateEndHour=' + dateEnd.getHours()
            + '&appointmentDateEndMinutes=' + dateEnd.getMinutes() ;
    if (testIfNewAppointmentPossible(dateStart, dateEnd)) {
        openNewAppointment(saveString);
    } else {
        setInsertImpossibleMsg();
    }
}
function createNextAppointment() {
    var dateStart = new Date(getAppointment(actualAppointmentId).eventEndDate.toGMTString().replace('UTC', 'GMT'));
    var dateEnd = new Date(dateStart);
    dateEnd.setMinutes(dateStart.getMinutes() + defaultAppointmentDuration);
    var saveString = "&Action=new&FindUserUID=" + $F('FindUserUID') + "&AppointmentID=-1&inputId=" + actualAppointmentId
            + '&appointmentDateDay=' + dateStart.getDate() + "/" + (Number(dateStart.getMonth() + 1)) + "/" + dateStart.getFullYear()
            + '&appointmentDateHour=' + dateStart.getHours()
            + '&appointmentDateMinutes=' + dateStart.getMinutes()
            + '&appointmentDateEndDay=' + dateEnd.getDate() + "/" + (Number(dateEnd.getMonth() + 1)) + "/" + dateEnd.getFullYear()
            + '&appointmentDateEndHour=' + dateEnd.getHours()
            + '&appointmentDateEndMinutes=' + dateEnd.getMinutes() ;
    if (testIfNewAppointmentPossible(dateStart, dateEnd)) {
        openNewAppointment(saveString);
    } else {
        setInsertImpossibleMsg();
    }
}
function testIfNewAppointmentPossible(start, stop) {
    var ok = false;
    if (start.getHours() >= weekplannerStartHour && stop.getHours() < weekplannerStopHour + 1) {
        ok = true;
    }
    return ok;
}
function initMoveAppointment(e, inputObj)
{
    remInfoPopup();
    if (document.all && typeof event != "undefined")e = event;
    if (!inputObj)inputObj = this.parentNode;
    currentAppointmentDiv = inputObj;
    currentAppointmentContentDiv = getCurrentAppointmentContentDiv(currentAppointmentDiv);
    moveAppointmentCounter = 0;
    el_x = getLeftPos(inputObj);
    el_y = getTopPos(inputObj);
    elWidth = inputObj.offsetWidth;
    mouse_x = e.clientX;
    mouse_y = e.clientY;
    timerMoveAppointment();
    return false;
}
function timerMoveAppointment()
{
    if (moveAppointmentCounter >= 0 && moveAppointmentCounter < 10) {
        moveAppointmentCounter = moveAppointmentCounter + 1;
        setTimeout('timerMoveAppointment()', 10);
        return;
    }
    if (moveAppointmentCounter == 10) {
        currentTimeDiv = getCurrentTimeDiv(currentAppointmentDiv);
        currentTimeDiv.style.display = 'block';
    }
}
function getMinute(topPos)
{
    var time = (topPos) / (itemRowHeight + 1);
    /* Changed by emanuel@mxs.be */
    //var hour = Math.floor(time);
    var hour = time;
    var minute = Math.floor((time - hour) * 60);
    return minute;
}
function schedulerMouseMove(e)
{
    if (document.all && typeof event != "undefined")e = event;
    if (newAppointmentCounter == 10) {
        if (!currentAppointmentDiv)return;
        var tmpHeight = e.clientY - mouse_y;
        currentAppointmentDiv.style.height = Math.max(20, tmpHeight) + 'px';
        currentTimeDiv.innerHTML = '<span>' + getTime(currentAppointmentDiv) + '</span>';
    }
    if (moveAppointmentCounter == 10) {
        var topPos = (e.clientY - mouse_y + el_y - appointmentsOffsetTop);
        var destinationLeftPos = false;
        for (var no = 0; no < dayPositionArray.length; no++) {
            if (e.clientX > dayPositionArray[no])destinationLeftPos = dayPositionArray[no];
        }
        var time = getTime(currentAppointmentDiv);
        if (topPos < 0) {
            topPos = 0;
        }
        var h = Number(currentAppointmentDiv.style.height.substr(0, currentAppointmentDiv.style.height.length - 2));
        if ((h + topPos) > $("weekScheduler_appointments").offsetHeight) {
            topPos = $("weekScheduler_appointments").offsetHeight - (h);
        }
      //  if((topPos+currentAppointmentContentDiv.offsetHeight)>=($("weekScheduler_content").offsetHeight+$("weekScheduler_content").scrollTop)){$("weekScheduler_content").scrollTop+=topPos=currentAppointmentContentDiv.offsetHeight};
        // $("viewByAjax").update($("weekScheduler_content").scrollTop+"<br />"+topPos+"<br />"+currentAppointmentDiv.offsetHeight+"<br />"+(topPos+currentAppointmentDiv.offsetHeight)+"<br />"+($("weekScheduler_content").scrollTop+(topPos+currentAppointmentDiv.offsetHeight))+"<br />"+"<br />"+ $("weekScheduler_appointments").offsetHeight+" <br />"+$("weekScheduler_content").offsetHeight);
        currentAppointmentDiv.style.top = topPos + 'px';
        currentAppointmentDiv.style.left = (destinationLeftPos + appointmentMarginSize - 2) + 'px';
        currentTimeDiv.innerHTML = '<span>' + time + '</span>';
    }
    if (resizeAppointmentCounter == 10) {
        var topPos = Number(currentAppointmentDiv.style.top.substring(0, currentAppointmentDiv.style.top.length - 2));
        var height = Math.max((resizeAppointmentInitHeight + e.clientY - mouse_y), 10);
        //$("viewByAjax").update($("viewByAjax").innerHTML + "\nresizeAppointmentCounter " + height);
        if ((height + topPos) > $("weekScheduler_appointments").offsetHeight) {
            height = $("weekScheduler_appointments").offsetHeight - (topPos + 4);
        }
        currentAppointmentContentDiv.style.height = ((height) - 8) + 'px';
        currentAppointmentDiv.style.height = height + 'px';
        currentTimeDiv.innerHTML = '<span>' + getTime(currentAppointmentDiv) + '</span>';
    }
}
function repositionFooter(inputDiv)
{
    var subDivs = inputDiv.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointment_footer') {
            subDivs[no].style.bottom = '-1px';
        }
    }
}
/*
This function clears all appointments from the screen - Used when switching from one week to another 
*/
function clearAppointments()
{
    for (var prop in appointmentProperties) {
        if (appointmentProperties[prop]['id']) {
            if (document.getElementById(appointmentProperties[prop]['id'])) {
                var obj = document.getElementById(appointmentProperties[prop]['id']);
                obj.parentNode.removeChild(obj);
            }
            appointmentProperties[prop]['id'] = false;
        }
    }
}
function ffEndEdit(e)
{
    if (!currentEditableTextArea)return;
    if (e.target) source = e.target;
    else if (e.srcElement) source = e.srcElement;
    if (source.nodeType == 3) // defeat Safari bug
        source = source.parentNode;
    if (source.tagName.toLowerCase() != 'textarea')currentEditableTextArea.blur();
}
function initToggleView(e)
{
    if (document.all && typeof event != "undefined")e = event;
    if (e.target)var source = e.target;
    else if (e.srcElement)var source = e.srcElement;
    if (source.className != "weekScheduler_appointment_info") {
        remInfoPopup();
    }
    if (this.id && this.id.length > 0) {
        bringToFront(this);
    }
    toggleViewCounter = 0;
    objectToToggle = this;
    setElementActive(null, this);
    timerToggleView();
}
function timerToggleView()
{
    if (toggleViewCounter >= 0 && toggleViewCounter < 10) {
        toggleViewCounter = toggleViewCounter + 1;
        setTimeout('timerToggleView()', 50);
    }
    if (toggleViewCounter == 10) {
        toggleViewCounter = -1;
    }
}
/* Maked by emanuel@mxs.be */
function bringToFront(obj) {
    currentZIndex = currentZIndex + 1;
    obj.style.zIndex = currentZIndex;
    getMarginForElement(obj);
}
/*
Creating new appointment DIV
*/
function createNewAppointmentDiv(leftPos, topPos, width, contentHTML, height)
{
    var div = document.createElement('DIV');
  //  div.onclick = setElementActive;
    div.ondblclick = editEventWindow;
    div.className = 'weekScheduler_anAppointment';
    div.style.left = leftPos + 'px';
    div.style.top = topPos + 'px';
    div.style.width = width + 'px';
    div.onmousedown = initToggleView;
    if (height && height > 0) {
        div.style.height = height + 'px';
    }
    var header = document.createElement('DIV');
    header.className = 'weekScheduler_appointment_header';
    header.innerHTML = '<span></span>';
    header.onmousedown = initMoveAppointment;
    header.style.cursor = 'move';
    var timeDiv = document.createElement('DIV');
    timeDiv.className = 'weekScheduler_appointment_time';
    timeDiv.innerHTML = '<span></span>';
    header.appendChild(timeDiv);
    div.appendChild(header);
    var span = document.createElement('DIV');
    /*   var innerSpan = document.createElement('SPAN');
innerSpan.innerHTML = '<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;</span>' + contentHTML;
span.appendChild(innerSpan);         */
    span.innerHTML = contentHTML;
    span.className = 'weekScheduler_appointment_txt';
    span.id = 'weekScheduler_appointment_txt';
    var info = document.createElement("DIV");
    info.className = 'weekScheduler_appointment_info';
    info.onmousedown = initInfoPopup;
    info.title = "info";
    span.appendChild(info);
    div.appendChild(span);
    var colorCodeDiv = document.createElement('DIV');
    colorCodeDiv.className = 'weekScheduler_appointment_colorCodes';
    div.appendChild(colorCodeDiv);
    var footerDiv = document.createElement('DIV');
    footerDiv.className = 'weekScheduler_appointment_footer';
    footerDiv.style.cursor = 'n-resize';
    footerDiv.innerHTML = '<span></span>';
    footerDiv.onmousedown = initResizeAppointment;
    div.appendChild(footerDiv);
    if (weekScheduler_appointments) {
        weekScheduler_appointments.appendChild(div);
    }
    return div;
}
function schedulerMouseUp()
{
    if (currentAppointmentDiv && snapToMinutes && (resizeAppointmentCounter == 10 || newAppointmentCounter)) {
        autoResizeAppointment();
        bringToFront(currentAppointmentDiv);
    }
    if (currentAppointmentDiv && !contentEditInProgress) {
        repositionFooter(currentAppointmentDiv);
        updateAppointmentProperties(currentAppointmentDiv.id);
        bringToFront(currentAppointmentDiv);
    }
    if (newAppointmentCounter >= 0) {
        if (newAppointmentCounter == 10) {
            if (!currentAppointmentDiv)return;
            var appointment = getAppointment(currentAppointmentDiv.id);
            var dateStart = new Date(appointment.eventStartDate.toGMTString().replace('UTC', 'GMT'));
            var dateEnd = new Date(appointment.eventEndDate.toGMTString().replace('UTC', 'GMT'));
            if (dateStart < dateEnd) {
                var saveString = "&Action=new&FindUserUID=" + $('FindUserUID').value + "&AppointmentID=-1&inputId=" + currentAppointmentDiv.id
                        + '&appointmentDateDay=' + dateStart.getDate() + "/" + (Number(dateStart.getMonth() + 1)) + "/" + dateStart.getFullYear()
                        + '&appointmentDateHour=' + dateStart.getHours()
                        + '&appointmentDateMinutes=' + dateStart.getMinutes()
                        + '&appointmentDateEndDay=' + dateEnd.getDate() + "/" + (Number(dateEnd.getMonth() + 1)) + "/" + dateEnd.getFullYear()
                        + '&appointmentDateEndHour=' + dateEnd.getHours()
                        + '&appointmentDateEndMinutes=' + dateEnd.getMinutes() ;
              //  createAppointment(saveString);
                openNewAppointment(saveString);
               // new Insertion.Top(getCurrentTextDiv(currentAppointmentDiv),"<span>"+patientName+"</span><hr />");
            }
        }
    }
    currentAppointmentDiv = false;
    currentTimeDiv = false;
    moveAppointmentCounter = -1;
    resizeAppointmentCounter = -1;
    newAppointmentCounter = -1;
    toggleViewCounter = -1;
}
/* maked by emanuel@mxs.be */
function updateObjectProperties(obj, txt, timebegin, timeend, date, width, height) {
    if (getAppointment(obj.id)) {
        // weekScheduler_appointment_txt
        if (txt && txt != "") {
            var txt_content = obj.getElementsByClassName('weekScheduler_appointment_txt')[0];
            txt_content.update("<br />" + txt);
        }
        if (timebegin && timebegin.length > 0 && timeend.length > 0) {
            var hour_content = obj.getElementsByClassName('weekScheduler_appointment_time')[0];
            hour_content.update(timebegin + "-" + timeend);
        }
    }
}
function autoResizeAppointment()
{
    var tmpPos = getTopPos(currentAppointmentDiv) - appointmentsOffsetTop + currentAppointmentDiv.offsetHeight;
    var startPos = tmpPos;
    var minute = getMinute(tmpPos);
    var rest = (minute % snapToMinutes);
    var height = currentAppointmentDiv.style.height.replace('px', '') / 1;
    if (rest > (snapToMinutes / 2)) {
        tmpPos = tmpPos + snapToMinutes - (minute % snapToMinutes);
    } else {
        tmpPos = tmpPos - (minute % snapToMinutes);
    }
    var minute = getMinute(tmpPos);
    if ((minute % snapToMinutes) != 0) {
        tmpPos = tmpPos - (minute % snapToMinutes);
    }
    /* var minute = getMinute(tmpPos);
        if ((minute % snapToMinutes) != 0) {
        tmpPos = tmpPos - (minute % snapToMinutes);
        }
    */
    currentAppointmentDiv.style.height = (height + tmpPos - startPos) + 'px';
    currentTimeDiv.innerHTML = '<span>' + getTime(currentAppointmentDiv) + '</span>';
}
function getTopPos(inputObj)
{
    var returnValue = inputObj.offsetTop;
    while ((inputObj = inputObj.offsetParent) != null) {
        if (inputObj.tagName != 'HTML')returnValue += inputObj.offsetTop;
    }
    return returnValue;
}
function getLeftPos(inputObj)
{
    var returnValue = inputObj.offsetLeft;
    while ((inputObj = inputObj.offsetParent) != null) {
        if (inputObj.tagName != 'HTML')returnValue += inputObj.offsetLeft;
    }
    return returnValue;
}
function cancelSelectionEvent(e)
{
    if (document.all && typeof event != "undefined")e = event;
    if (e.target) source = e.target;
    else if (e.srcElement) source = e.srcElement;
    if (source.nodeType == 3) // defeat Safari bug
        source = source.parentNode;
    if (source.tagName.toLowerCase() == 'input' || source.tagName.toLowerCase() == 'textarea')return true;
    return false;
}
function initWeekScheduler()
{
    weekScheduler_container = $('weekScheduler_container');
    if (!document.all)weekScheduler_container.onclick = ffEndEdit;
    weekScheduler_appointments = document.getElementById('weekScheduler_appointments');
    var subDivs = weekScheduler_appointments.getElementsByTagName('DIV');
    for (var no = 0; no < subDivs.length; no++) {
        if (subDivs[no].className == 'weekScheduler_appointmentHour') {
            subDivs[no].onmousedown = initNewAppointment;
            if (!newAppointmentWidth)newAppointmentWidth = subDivs[no].offsetWidth;
        }
        if (subDivs[no].className == 'weekScheduler_appointments_day') {
            dayPositionArray[dayPositionArray.length] = getLeftPos(subDivs[no]);
        }
    }
    if (initTopHour > weekplannerStartHour)document.getElementById('weekScheduler_content').scrollTop = ((initTopHour - weekplannerStartHour) * (itemRowHeight + 1));
	
	//	initTopHour
    appointmentsOffsetTop = getTopPos(weekScheduler_appointments) - 1;
    appointmentsOffsetLeft = 2 - appointmentMarginSize;
    /* Edited by emanuel@mxs.be */
    $("weekScheduler_container").observe('mouseup', schedulerMouseUp);
    document.documentElement.onmousemove = schedulerMouseMove;
    document.documentElement.onselectstart = cancelSelectionEvent;
	//document.documentElement.onmouseup = schedulerMouseUp;
    /* Edited by emanuel@mxs.be */
    var tmpDate = new Date();
    tmpDate.setFullYear(initDateToShow.getFullYear());
    tmpDate.setDate(initDateToShow.getDate());
    tmpDate.setMonth(initDateToShow.getMonth());
    tmpDate.setHours(1);
    tmpDate.setMinutes(0);
    tmpDate.setSeconds(0);
    var day = tmpDate.getDay();
    if (day == 0)day = 7;
    if (day > 1) {
        var offset = (tmpDate.getDay() + 6) % 7;
        tmpDate = new Date(tmpDate.getFullYear(), tmpDate.getMonth(), tmpDate.getDate() - offset);
    }
    dateStartOfWeek = new Date(tmpDate);
    updateHeaderDates(dateStartOfWeek);
    if (externalSourceFile_items) {
        getItemsFromServer();
    }
}
/* Maked by emanuel mxs.be  */
function getMarginForElement(movedObj) {
    movedObj = getAppointment(movedObj.id);
    // all objects
    if (movedObj) {
        for (var i = 0; i < appointments.size(); i++) {
            //  appointments.each(function(appointment) {
            // test if another object
            var appointment = appointments[i];
            if (appointment.id && appointment.id != movedObj.id) {
                var actualBegin = new Date(movedObj.eventStartDate);
                var actualEnd = new Date(movedObj.eventEndDate);
                var testedBegin = new Date(appointment.eventStartDate);
                var testedEnd = new Date(appointment.eventEndDate);
         // if date actual object sit in existent object
                if ((actualBegin < testedEnd && actualBegin > testedBegin) || (actualEnd > testedBegin && actualEnd < testedEnd)) {
                    var testWidth = appointment.obj.style.width;
                    var testZindex = appointment.obj.style.zIndex;
               // if the same width
                    if (movedObj.obj.style.marginLeft == appointment.obj.style.marginLeft) {
                        if (movedObj.obj.style.marginLeft == "-10px") {
                            movedObj.obj.style.marginLeft = 0 + "px";
                        } else {
                            movedObj.obj.style.marginLeft = -10 + "px";
                        }
                    }
                }
            }
        }
    }
}
function displayWeek(date) {
    var offset = (date.getDay() + 6) % 7;
    var tmpDate = new Date(date.getFullYear(), date.getMonth(), date.getDate() - offset);
    dateStartOfWeek = new Date();
    dateStartOfWeek.setTime(tmpDate);
    clearAppointments();
    updateHeaderDates(date);
    getItemsFromServer();
}
function displayPreviousWeek()
{
    var tmpTime = dateStartOfWeek.getTime();
    tmpTime = tmpTime - (1000 * 60 * 60 * 24 * 7);
    dateStartOfWeek.setTime(tmpTime);
    return dateStartOfWeek.getDate() + "/" + (dateStartOfWeek.getMonth() + 1) + "/" + y2k(dateStartOfWeek.getFullYear());
}
function displayNextWeek()
{
    var tmpTime = dateStartOfWeek.getTime();
    tmpTime = tmpTime + (1000 * 60 * 60 * 24 * 7);
    dateStartOfWeek.setTime(tmpTime);
    return dateStartOfWeek.getDate() + "/" + (dateStartOfWeek.getMonth() + 1) + "/" + y2k(dateStartOfWeek.getFullYear());
}
function updateHeaderDates(beginweek)
{
    var weekScheduler_dayRow = document.getElementById('weekScheduler_dayRow');
    var subDivs = weekScheduler_dayRow.getElementsByTagName('DIV');
    var tmpDate2 = new Date(dateStartOfWeek);
    for (var no = 0; no < subDivs.length; no++) {
        var month = tmpDate2.getMonth() / 1 + 1;
        var date = tmpDate2.getDate();
        var tmpHeaderFormat = " " + headerDateFormat;
        tmpHeaderFormat = tmpHeaderFormat.replace('d', date);
        tmpHeaderFormat = tmpHeaderFormat.replace('m', month);
        subDivs[no].getElementsByTagName('SPAN')[0].innerHTML = tmpHeaderFormat;
        dayDateArray[no] = month + '|' + date;
        var time = tmpDate2.getTime();
        time = time + (1000 * 60 * 60 * 24);
        tmpDate2.setTime(time);
        var endweek = new Date();
        endweek.setDate(beginweek.getDate() + 7);
        var today = new Date();
        if ((today >= beginweek && today < endweek) && (today.getDate() == tmpDate2.getDate() - 1)) {
            subDivs[no].className = "today";
          // alert(today+'>'+beginweek+" || "+today+" < "+endweek);
            var div = $("weekScheduler_appointments").getElementsByClassName("weekScheduler_appointments_day")[no].addClassName("today");
        } else {
            var div = $("weekScheduler_appointments").getElementsByClassName("weekScheduler_appointments_day")[no].className = "weekScheduler_appointments_day";
            subDivs[no].className = "";
        }
    }
}
var Appointment = Class.create();
Appointment.prototype = {


    initialize:function(id, margin, description, effective, eventStartDate, eventEndDate, obj) {
        this.id = id;
        this.margin = margin;
        this.description = description;
        this.eventStartDate = eventStartDate;
        this.eventEndDate = eventEndDate;
        this.effective = effective;
        this.obj = obj;
    }
}
function getAppointment(id) {
    var obj;
    //var s = "";
    for (var i = 0; i < appointments.size(); i++) {
        var appointment = appointments[i];
        // test if another object
        //  s+=appointments[i].id+"\n";
        if (appointments[i].id == id) {
            obj = appointments[i];
        }
       // alert("find "+s+" -> "+id);
    }
    return obj;
}
window.onload = initWeekScheduler;