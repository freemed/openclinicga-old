var calculationWidth;
var actualCalculationId;
var el_x, el_y, elWidth;
var currentZIndex = 20000;
var dayPositionArray = new Array();
var sackObjects = new Array();
var calculations = new Array();
var dateStartOfMonth = false;
var monthScheduler_days = false;

/* INIT MONTH SCHEDULER */
function initMonthScheduler(){  
  monthScheduler_days = document.getElementById("monthScheduler_days");
  var dayDivs = monthScheduler_days.getElementsByTagName("DIV");
  for(var i=0; i<dayDivs.length; i++){
    if(dayDivs[i].className=="monthScheduler_day" || dayDivs[i].className=="monthScheduler_future"){
      dayPositionArray[dayPositionArray.length] = dayDivs[i].offsetLeft;
    }
  }
    
  calculationWidth = dayDivs[0].style.width.substring(0,dayDivs[0].style.width.indexOf("px"));
  
  updateDays(dateStartOfMonth);
  updateHeader(dateStartOfMonth);

  if(externalSourceFile_items){
    getItemsFromServer();
  }
}

/* CREATE CALCULATION DIV */
function createCalculationDiv(calculationUID,leftPos,topPos,width,height,source,type,contentHTML,
                              totalDurationHours,totalDurationDays,dayOfCalculationIdx){  
  var div = document.createElement("DIV");
  div.title = calculationDivTitle;
  div.ondblclick = editCalculation;
  div.className = "calculation";
  div.calculationUID = calculationUID;
  div.style.cursor = "pointer"; // IE : hand
  div.style.left = leftPos+"px";
  div.style.top = topPos+"px";
  div.style.width = width+"px";
  if(height && height > 0){
    div.style.height = height+"px";
  }
    
  /* header */
  var header = document.createElement("DIV");
  
  if(type=="leave"){
    header.className = "calHeaderLeave";
    div.style.border = "1px solid #dd4444"; // red        
  }
  else{
    header.className = "calHeaderWorkschedule";
  }
  
  header.innerHTML = "<span class='calHeaderDuration'>"+totalDurationHours+hourShortTran+"</span>";

  if(source!="script"){
    header.innerHTML+= " <span class='calHeaderScriptNotice' title='"+manuallyEditedTran+"'><i>manual</i></span>";    
  }
  
  var info = document.createElement("DIV");
  info.className = "deleteIcon";
  info.onmousedown = function(e){deleteCalculation(e);}
  info.title = deleteTran;
  info.calculationUID = calculationUID;
  header.appendChild(info);   
  
  div.appendChild(header);
    
  /* body */
  var span = document.createElement("DIV");
  span.innerHTML = contentHTML;
  span.className = "dayBody";
  span.id = "dayBody";
  div.appendChild(span);
        
  if(monthScheduler_days){
    monthScheduler_days.appendChild(div);
  }
    
  return div;
}

/* EDIT CALCULATION */
function editCalculation(){  
  actualCalculationId = this.id;
  openCalculation(actualCalculationId);
}

/* GET ITEMS FROM SERVER */
function getItemsFromServer(){
  $("wait").style.display = "inline";
    
  var ajaxIndex = sackObjects.length;
  sackObjects[ajaxIndex] = new sack();
  sackObjects[ajaxIndex].requestFile = externalSourceFile_items+ 
                                       "&PersonId="+$F("PersonId")+ 
                                       "&Month="+$F("DisplayedMonth");

  sackObjects[ajaxIndex].onCompletion = function(){
    parseItemsFromServer(ajaxIndex);
  };     
  sackObjects[ajaxIndex].runAJAX();
}

/* PARSE ITEMS FROM SERVER */
function parseItemsFromServer(ajaxIndex){
  $("calculationFormByAjax").hide();
  
  var itemsToBeCreated = new Array();
  var items = sackObjects[ajaxIndex].response.split(/<item>/g);
  sackObjects[ajaxIndex] = false;

  for(var i=1; i<items.length; i++){
    var lines = items[i];
    lines = trim(lines);
    lines = lines.split(/\n/g);
    itemsToBeCreated[i] = new Array();
  
    for(var j=0; j<lines.length; j++){
      var key = lines[j].replace(/<([^>]+)>.*/g,'$1');
      if(key) key = trim(key);
      
      var pattern = new RegExp("<\/?"+key+">","g");      
      var value = lines[j].replace(pattern,"");
      value = trim(value);      
      if(key=="begin" || key=="end"){
        value = new Date(value);
      }
      
      itemsToBeCreated[i][key] = value;
    }
    
    if(itemsToBeCreated[i]["id"]){         
      if(itemsToBeCreated[i]["begin"].getMonth()==dateStartOfMonth.getMonth()){
        var dayDivs = $("monthScheduler_days").getElementsByClassName("monthScheduler_day");
        dayDivs.concat($("monthScheduler_days").getElementsByClassName("monthScheduler_future"));
        
        /* display the calculation-div */
        var monthBeginDayIdx = dateStartOfMonth.getDay();
        var yDayPos = getWeekIdx(monthBeginDayIdx,itemsToBeCreated[i]["begin"]);   
        var dayInWeek = itemsToBeCreated[i]["begin"].getDay();
        if(dayInWeek==6) dayInWeek = -1; // sunday == 0
        var xDayPos = (yDayPos==0?0:1)+(dayInWeek%6);     
        var leftPxPos = dayDivs[yDayPos>0?0:1].offsetLeft+(xDayPos*calculationWidth)+(xDayPos*2*1); // 2 times 1px margin
        var elHeight = Math.round((1 * itemRowHeight) - 17);
        var topPxPos = (yDayPos*(elHeight+15+3))+15; // add margins
          
        currentCalculationDiv = createCalculationDiv(itemsToBeCreated[i]["id"],
                                                     leftPxPos,topPxPos,calculationWidth,elHeight,
                                                     itemsToBeCreated[i]["source"],
                                                     itemsToBeCreated[i]["type"],
                                                     itemsToBeCreated[i]["codes"],
                                                     itemsToBeCreated[i]["totalDurationHours"],
                                                     itemsToBeCreated[i]["totalDurationDays"],1);
        currentCalculationDiv.id = itemsToBeCreated[i]["id"];
        currentCalculationDiv.style.zIndex = ++currentZIndex;  
        currentCalculationDiv.style.visibility = "visible";
        
        var calculation = new Array();
        calculation["id"] = itemsToBeCreated[i]["id"];
        calculation["source"] = itemsToBeCreated[i]["source"];
        calculation["type"] = itemsToBeCreated[i]["type"];
        calculation["codes"] = itemsToBeCreated[i]["codes"];
        calculation["begin"] = itemsToBeCreated[i]["begin"];
        calculation["end"] = itemsToBeCreated[i]["end"];
        calculation["object"] = currentCalculationDiv;
        calculations[itemsToBeCreated[i]["id"]] = calculation;
      }        
    }    
  }
    
  $("wait").hide();
}

/* CLEAR CALCULATIONS */
function clearCalculations(){
  /* remove objects */
  for(var calculId in calculations){
    if(document.getElementById(calculId)){
      var obj = document.getElementById(calculId);
      obj.parentNode.removeChild(obj);
    }
  }

  /* remove divs */
  var calculationDivs = $("monthScheduler_days").getElementsByClassName("calculation");
  for(var i=0; i<calculationDivs.length; i++){
    $("monthScheduler_days").removeChild(calculationDivs[i]);
  }
}

/* GET WEEK IDX */
function getWeekIdx(monthBeginDayIdx,dayDate){
  if(monthBeginDayIdx==6) monthBeginDayIdx = -1; // sunday = 0
  return parseInt(""+((monthBeginDayIdx+dayDate.getDate())/7)); // weekIdx = 0 to 5
}

/* DISPLAY MONTH */
function displayMonth(date){
  dateStartOfMonth = new Date(date.getFullYear(),date.getMonth(),1);

  updateDays(date);
  updateHeader(date);
  
  clearCalculations();
  getItemsFromServer();
}

/* HIDE CALCULATION (after delete, instead of loading the whole month) */
function hideCalculation(calculationUID){   
  ((calculations[calculationUID])["object"]).style.visibility = "hidden";
      
  var obj = document.getElementById(calculationUID);
  obj.parentNode.removeChild(obj);
}

/* RESET SCHEDULER DAYS */
function resetSchedulerDays(){
  //var dayDivs = $("monthScheduler_days").childNodes; // IE-only
  var dayDivs = $("monthScheduler_days").getElementsByTagName("div");
  
  for(var i=0; i<dayDivs.length; i++){
    dayDivs[i].className = "monthScheduler_day";
    dayDivs[i].style.backgroundcolor = "#fff";
    dayDivs[i].style.backgroundimage = "none";
    dayDivs[i].style.cursor = "";
    
    if(dayDivs[i].getElementsByTagName("SPAN").length > 0){
      dayDivs[i].getElementsByTagName("SPAN")[0].innerHTML = "";
      dayDivs[i].getElementsByTagName("SPAN")[0].className = ""; 
      dayDivs[i].getElementsByTagName("SPAN")[0].style.backgroundcolor = "#ccc";
    }
    
    dayDivs[i].date = "";
  }

  resetHeader();
}

/* RESET HEADER */
function resetHeader(){
  var headerDivs = document.getElementById("monthScheduler_dayHeaders").getElementsByTagName("DIV");
  
  for(var i=0; i<headerDivs.length; i++){
    headerDivs[i].className = "";
    headerDivs[i].style.backgroundcolor = "#fff";
  }    
}

/* UPDATE DAYS */
function updateDays(dDate){
  resetSchedulerDays();
  
  var daysInMonth = countDaysInMonth(dDate.getMonth()+1,dDate.getFullYear());  
  var firstDayOfMonth = new Date(dDate.getFullYear(),dDate.getMonth(),1);
  var firstDayIdx = firstDayOfMonth.getDay()+1;
  if(firstDayIdx > 6) firstDayIdx = 0; 

  var dayDivs = $("monthScheduler_days").getElementsByClassName("monthScheduler_day");
  dayDivs.concat($("monthScheduler_days").getElementsByClassName("monthScheduler_future"));
  
  /* days : mark today and monthend */
  var sDate;
  var day = 1;
  var sToday = getTodayString(); 

  for(var i=firstDayIdx; i<daysInMonth+firstDayIdx; i++){
    sDate = day+"/"+(dDate.getMonth()+1)+"/"+dDate.getFullYear();
    sDate = formatDate(sDate);
    day++; // proceed
    
    if(dayDivs[i]!=undefined){
      if(dayDivs[i].getElementsByTagName("SPAN").length > 0){
        dayDivs[i].getElementsByTagName("SPAN")[0].innerHTML = sDate; 
        dayDivs[i].getElementsByTagName("SPAN")[0].className = "notTodayHeader";
      }
        
      dayDivs[i].date = sDate;
      
      if(isInFuture(makeDate(sDate))==true){
        dayDivs[i].className = "monthScheduler_future";
        dayDivs[i].ondblclick = "";
      }
      else{
        dayDivs[i].className = "monthScheduler_day";
        dayDivs[i].style.cursor = "pointer"; // IE : hand
        
        dayDivs[i].ondblclick = function(e){createCalculation(e);}
        
        if(sToday==sDate){
          dayDivs[i].addClassName("today");

          if(dayDivs[i].getElementsByTagName("SPAN").length > 0){
            dayDivs[i].getElementsByTagName("SPAN")[0].className = "todayHeader";
          }
        } 
        
        if(isWeekend(sDate)){
          dayDivs[i].addClassName("weekend");
        }
        else{
          dayDivs[i].addClassName("workday");  
        }
      }
    }
  }

  markToday();
}

/* UPDATE HEADER */
function updateHeader(date){     
  /* header : mark today's name */
  if(date.getMonth()==new Date().getMonth() && date.getFullYear()==new Date().getFullYear()){
    var dayHeaders = document.getElementById("monthScheduler_dayHeaders").getElementsByTagName("DIV");
    dayHeaders[new Date().getDay()+1].className = "todayHeader";
  }
}

/* MARK TODAY */
function markToday(){
  /* days : mark today */  
  var dayDivs = $("monthScheduler_days").getElementsByClassName("monthScheduler_day");
  dayDivs.concat($("monthScheduler_days").getElementsByClassName("monthScheduler_future"));

  var sToday = getTodayString();
  var sDate;
  
  for(var i=0; i<dayDivs.length; i++){
    if(dayDivs[i].getElementsByTagName("SPAN").length > 0){
      sDate = dayDivs[i].getElementsByTagName("SPAN")[0].innerHTML; 
    
      if(sToday==sDate){
        dayDivs[i].addClassName("today");
        dayDivs[i].getElementsByTagName("SPAN")[0].className = "todayHeader";
      }
    } 
  }
}

/* COUNT DAYS IN MONTH */
function countDaysInMonth(month,year){
  return new Date(year,month,0).getDate();
}

/* IS WEEKEND */
function isWeekend(sDate){
  var date = makeDate(sDate);
  return (date.getDay()%6==0);
}

/* IS IN FUTURE */
function isInFuture(date){
  var today = new Date();
  return date.getTime() > today.getTime();
}

/* MAKE DATE */
function makeDate(fulldateStr){
  fulldateStr = fulldateStr.replace("-","/");
  
  var year  = fulldateStr.substring(fulldateStr.lastIndexOf("/")+1);
  var month = fulldateStr.substring(fulldateStr.indexOf("/")+1,fulldateStr.lastIndexOf("/"));
  var day   = fulldateStr.substring(0,fulldateStr.indexOf("/"));

  return new Date(year,month-1,day,0,0,0);
}

/* CLASS : CALCULATION */
var Calculation = Class.create();

Calculation.prototype = {
  initialize: function(id,source,type,begin,end,codes,obj){
    this.id = id;
    this.source = source;
    this.type = type;
    this.begin = begin;
    this.end = end;
    this.codes = codes;
    this.obj = obj;
  }
}

/* GET TODAY STRING */
function getTodayString(){
  var today = new Date();
  
  var sDay = today.getDate()+"";
  if(sDay.length < 2){
    sDay = "0"+sDay;
  }
  
  var sMonth = (today.getMonth()+1)+"";
  if(sMonth.length < 2){
    sMonth = "0"+sMonth;
  }
    
  return (sDay+"/"+sMonth+"/"+today.getFullYear());
}

Event.observe(window,"load",function(){initMonthScheduler();});