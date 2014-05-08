function isFutureDate(d){
  var dateParts = d.split("/");
  var date = new Date(dateParts[2],(dateParts[1]-1),dateParts[0]);
  return date>new Date();
}

function before(dateStr1,dateStr2){
  if(dateStr1.length==4){
    if(!isNaN(dateStr1)){
      if(isValidYear(dateStr1)){
        dateStr1 = "01/01/"+dateStr1;
      }
    }
  }

  if(dateStr2.length==4){
    if(!isNaN(dateStr2)){
      if(isValidYear(dateStr2)){
        dateStr2 = "01/01/"+dateStr2;
      }
    }
  }

  var date1 = makeDate(dateStr1);
  var date2 = makeDate(dateStr2);

  if(date1.getTime() < date2.getTime()){
    return true;
  }
  else{
    return false;
  }
}

function after(dateStr1,dateStr2){
  if(dateStr1.length == 4){
    if(!isNaN(dateStr1)){
      if(isValidYear(dateStr1)){
        dateStr1 = "01/01/"+dateStr1;
      }
    }
  }

  if(dateStr2.length == 4){
    if(!isNaN(dateStr2)){
      if(isValidYear(dateStr2)){
        dateStr2 = "01/01/"+dateStr2;
      }
    }
  }
  
  var date1 = makeDate(dateStr1);
  var date2 = makeDate(dateStr2);

  if(date1.getTime() > date2.getTime()){ // only difference with function before
    return true;
  }
  else{
    return false;
  }
}

function isValidYear(yearStr){
  if(yearStr*1 < 2100 && yearStr*1 > 1900) return true;
  return false;
}

function normaliseDate(dateStr){
  // should only be used for valid (partial) dates
  var dateStr = dateStr.replace("-","/");

  if(dateStr.indexOf("/") > -1){
    if(dateStr.length==6 || dateStr.length==7){
      dateStr = "01/"+dateStr;
    }
  }
  else{
    if(dateStr.length==4){
      dateStr = "01/01/"+dateStr;
    }
  }

  return dateStr;
}

function makeDate(fulldateStr){
  fulldateStr = fulldateStr.replace("-","/");
  var year, month, day;
  
  if(dateFormat=="dd/MM/yyyy"){
    year = fulldateStr.substring(fulldateStr.lastIndexOf("/")+1);
    month = fulldateStr.substring(fulldateStr.indexOf("/")+1,fulldateStr.lastIndexOf("/"));
    day = fulldateStr.substring(0,fulldateStr.indexOf("/"));
  }
  else{
    year = fulldateStr.substring(fulldateStr.lastIndexOf("/")+1);
    day = fulldateStr.substring(fulldateStr.indexOf("/")+1,fulldateStr.lastIndexOf("/"));
    month = fulldateStr.substring(0,fulldateStr.indexOf("/"));
  }

  if(isDate(day,month,year)){
    return new Date(year,month-1,day,0,0,0);
  }
}

function checkDateOnlyMonthAndYearAllowed(sobject){
  var sdateStr = sobject.value.replace("-","/");

  // route function call to right function
  if(sdateStr.length!=6 && sdateStr.length!=7){
    if(sdateStr.length==4 || sdateStr.length==5){
      if(sdateStr.length==4 && !sdateStr.indexOf("/")){
        return checkDateOnlyYearAllowed(sobject);
      }
    }
    else{
      return checkDate(sobject);
    }
  }

  var month = sdateStr.substring(0,sdateStr.indexOf("/"));
  var year = sdateStr.substring(sdateStr.lastIndexOf("/")+1);

  var monthOK = 0, yearOK = 0;

  // check month
  if(month.length==0) month = "1";
  month = parseInt(month); // remove leading zeroes

  if(!isNaN(month)){
    if(month*1 <= 12 && month*1 >= 1){
      if(month<10) month = "0"+month;
      monthOK = 1;
    }
  }

  if(monthOK==1){
    // check year
    if(year.length!=4) year = "20"+year;
    if(year.length==4){
      if(!isNaN(year)){
        if(isValidYear(year)){
          yearOK = 1;
        }
      }
    }
  }

  if(monthOK==1 && yearOK==1){
    sobject.value = month+"/"+year;
    return true;
  }
  else{
    return checkDate(sobject);
  }
}

function checkDateOnlyYearAllowed(sobject){
  var sdate = sobject.value;

  if(sdate.length == 4){
    if(!isNaN(sdate)){
      if(isValidYear(sdate)){
        return true;
      }
    }
  }

  return checkDate(sobject);
}

function checkDate(sobject){
  var sdate = sobject.value;

  if(sdate.length<=0){
    return true;
  }
  else{
    var vnumber = '0123456789/';
    var today = new Date();
    var sDay = "01", sMonth = "01", sYear = today.getYear();

    for(var i=0; i< sdate.length; i++){
      if(vnumber.indexOf(sdate.charAt(i)) == -1){
        sdate = sdate.substring(0,i)+"/"+sdate.substring(i+1,sdate.length);
      }
    }

    if(sdate.indexOf("/")>0){
      if(dateFormat=="dd/MM/yyyy"){
        sDay = sdate.substring(0,sdate.indexOf("/"));
        if(sDay.length < 2) sDay = "0"+sDay;
        sMonth = sdate.substring(sdate.indexOf("/")+1,sdate.lastIndexOf("/"));
        if(sMonth.length < 2) sMonth = "0"+sMonth;	
      }
      else{
    	sMonth = sdate.substring(0,sdate.indexOf("/"));
        if(sMonth.length < 2) sMonth = "0"+sMonth;
        sDay = sdate.substring(sdate.indexOf("/")+1,sdate.lastIndexOf("/"));
        if(sDay.length < 2) sDay = "0"+sDay;
      }
    }
    else if((sdate.length==8)&&(sdate.indexOf("/")<1)){
      if(dateFormat=="dd/MM/yyyy"){	
        sDay = sdate.substring(0,2);
        sMonth = sdate.substring(2,4);
        sYear = sdate.substring(4,8);
      }
      else{
        sMonth = sdate.substring(0,2);
        sDay = sdate.substring(2,4);
        sYear = sdate.substring(4,8);
      }
    }

    if(sDay.length>2) sDay = sDay.substring(0,2);
    if(sMonth.length>2) sMonth = sMonth.substring(0,2);
    if(sYear.length>4) sYear = sYear.substring(0,4);

    if(sdate.lastIndexOf("/")>0){
      sYear = sdate.substring(sdate.lastIndexOf("/")+1,sdate.length);
      if(sYear.length != 4){
        sYear = "20"+sYear.substring(0,2);
      }
    }
    if(isDate(sDay,sMonth,sYear)){  
	  if(dateFormat.startsWith("MM")){
		// US
        sobject.value = sMonth+"/"+sDay+"/"+sYear;
	  }
	  else{
		// default : EU
	    sobject.value = sDay+"/"+sMonth+"/"+sYear;
	  }
      return true;
    }
    else{
      return false;
    }
  }
  return true;
}

function checkLongDate(sobject){
  var sdate = sobject.value;
  if(sdate.length>10){
    sdate = sdate.substring(0,10);
  }
  if(sdate.length>0){
    var vnumber = '0123456789/';
    var today = new Date();
    var sDay = "01", sMonth = "01", sYear = today.getYear();
    for(var i=0; i< sdate.length; i++){
      if(vnumber.indexOf(sdate.charAt(i)) == -1){
        sdate = sdate.substring(0,i)+"/"+sdate.substring(i+1,sdate.length);
      }
    }
    if(sdate.indexOf("/")>0){
      sDay = sdate.substring(0,sdate.indexOf("/"));
      if(sDay.length < 2) sDay = "0"+sDay;
      if(sDay>31) sDay = "31";
      sMonth = sdate.substring(sdate.indexOf("/")+1, sdate.lastIndexOf("/"));
      if(sMonth.length < 2){
        sMonth = "0"+sMonth;
      }
    }
    else if((sdate.length==8)&&(sdate.indexOf("/")<1)){
      sDay = sdate.substring(0,2);
      sMonth = sdate.substring(2,4);
      sYear = sdate.substring(4,8);
    }

    if(sDay.length>2) sDay = sDay.substring(0,2);
    if(sMonth.length>2) sMonth = sMonth.substring(0,2);
    if(sYear.length>4) sYear = sYear.substring(0,4);

    if(sdate.lastIndexOf("/")>0){
      sYear = sdate.substring(sdate.lastIndexOf("/")+1,sdate.length);
      if(sYear.length != 4){
        sYear = "20"+sYear.substring(0,2);
      }
    }
    if(isDate(sDay,sMonth,sYear)){
  	  if(dateFormat.startsWith("MM")){
  		// US
 	    sobject.value = sMonth+"/"+sDay+"/"+sYear+sobject.value.substring(10);
  	  }
  	  else{
  		// default : EU
  	    sobject.value = sDay+"/"+sMonth+"/"+sYear+sobject.value.substring(10);
  	  }
      return true;
    }
    else{
      //sobject.value = "";
      sobject.focus();
      return false;
    }
  }
  return true;
}

function y2k(number){ return (number < 1000) ? number + 1900 : number; }

function isDate(day,month,year){
  var datestatus = true;
  if(month < 1 || month > 12){ 
	datestatus = false;
  }
  if(day < 1 || day > 31){
    datestatus = false;
  }

  if((month==4 || month==6 || month==9 || month==11) && day==31){
    datestatus = false;
  }

  if(month==2){ // check for february 29th
    var isleap = (year%4==0 && (year%100!=0 || year%400==0));
    if(day > 29 || (day==29 && !isleap)){
      datestatus = false;
    }
  }
  return datestatus;
}

function getToday(sobject){
  var today = new Date();
  var sDay = today.getDate()+"";
  if(sDay.length < 2) sDay = "0"+sDay;
  var sMonth = (today.getMonth()+1)+"";
  if(sMonth.length < 2) sMonth = "0"+sMonth;
    
  if(dateFormat.startsWith("MM")){
	// US
	sobject.value = (sMonth+"/"+sDay+"/"+today.getFullYear());
  }
  else{
	// default : EU
    sobject.value = (sDay+"/"+sMonth+"/"+today.getFullYear());
  }
  
  try{
     sobject.focus();
  }
  catch(er){}
}

function writeToday(){
  var today = new Date();
  var sDay = today.getDate()+"";
  if(sDay.length < 2) sDay = "0"+sDay;
  var sMonth = (today.getMonth()+1)+"";
  if(sMonth.length < 2) sMonth = "0"+sMonth;
  
  if(dateFormat.startsWith("MM")){
	// US
    document.write(sMonth+"/"+sDay+"/"+today.getYear());
  }
  else{
	// default : EU
	document.write(sDay+"/"+sMonth+"/"+today.getYear());
  }
}

function showD(element,imgS,imgH){
  document.getElementsByName(element)[0].style.display='';
  document.getElementsByName(imgH)[0].style.display='';
  document.getElementsByName(imgS)[0].style.display='none';
}

function hideD(element,imgS,imgH){
  document.getElementsByName(element)[0].style.display='none';
  document.getElementsByName(imgH)[0].style.display='none';
  document.getElementsByName(imgS)[0].style.display='';
}

function addDays(sdate1,sbetween){
  if((sdate1.length>0)&&(sbetween.length>0)){
    var iDaydate1 = sdate1.substring(0,sdate1.indexOf("/"));
    var iMonthdate1 = sdate1.substring(sdate1.indexOf("/")+1,sdate1.lastIndexOf("/"));
    var iYeardate1 = sdate1.substring(sdate1.lastIndexOf("/")+1,sdate1.length);
    var date1 = new Date(iYeardate1, iMonthdate1-1,iDaydate1);
    var iBetween = sbetween*24*60-1;
    var endDate = new Date(date1.getTime()+iBetween*60*1000);
    return endDate.getDate()+"/"+(endDate.getMonth()+1)+"/"+endDate.getFullYear();
  }
  else{
    return "";
  }
}

function decimalToTime(textField){
  var decimalValue = textField.value;
  
  if(decimalValue.length > 0){
	decimalValue = replaceAll(decimalValue,".",",");  
    var hourValue = "";

    // hour-part
    var intValue = parseInt(decimalValue);
    if(intValue < 10) hourValue+= "0";
    hourValue+= intValue;

    // minute-part
    if(decimalValue.indexOf(",") > -1){
      hourValue+= ":";
      
      var commaValue = decimalValue.substring(decimalValue.indexOf(",")+1);
      if(commaValue.length==1) commaValue*= 10;
      commaValue = (parseInt(commaValue)/100)*60;
      if(commaValue < 10) hourValue+= "0";
      hourValue+= commaValue;
    }

    textField.value = hourValue;
  }
}

function checkTime(sobject){
  var sDate = sobject.value;
  var sReturn = '00:00';

  if(sDate.length>0){
    var vnumber = '0123456789:';

    for(var i=0; i<sDate.length; i++){
      if(sDate.indexOf(sDate.charAt(i)) == -1){
        return sReturn;
      }
    }
    sDate = sDate.replace(".",":");
    if(sDate.indexOf(":")==-1){
      sDate+=":";
    }
    var aTime = sDate.split(':');
    if(aTime.length == 2){
      iHour = aTime[0]*1;
      iMinutes = aTime[1]*1;

      if((iHour>-1)&&(iHour<25)&&(iMinutes>-1)&&(iMinutes<60)){
        if(iHour<10) iHour = "0"+iHour;
        if(iMinutes<10) iMinutes = "0"+iMinutes;
        sReturn = iHour+":"+iMinutes;
      }
    }
    sobject.value = sReturn;
  }
}

function putTime(sObject){
  var today = new Date();
  iHour = today.getHours();
  iMinutes = today.getMinutes();
  var sReturn = '00:00';
  if((iHour>-1)&&(iHour<25)&&(iMinutes>-1)&&(iMinutes<60)){
    if(iHour<10) iHour = "0"+iHour;
    if(iMinutes<10) iMinutes = "0"+iMinutes;
    sReturn = iHour+":"+iMinutes;
  }
  sObject.value = sReturn;
}

function getTime(sObject){
  var today = new Date();
  iHour = today.getHours();
  iMinutes = today.getMinutes();
 
  var sReturn = '00:00';
  if((iHour>-1)&&(iHour<25)&&(iMinutes>-1)&&(iMinutes<60)){
    if(iHour<10) iHour = "0"+iHour;
    if(iMinutes<10) iMinutes = "0"+iMinutes;
    sReturn = iHour+":"+iMinutes;
  }
  sObject.value = sReturn;
}

function keypressTime(oObject){
  if(window.event.keyCode>47 && window.event.keyCode<58 && oObject.value.length==2){
	if(oObject.value.indexOf(",") < 0 && oObject.value.indexOf(".") < 0){
      if(oObject.value.indexOf(":") < 0){
        oObject.value+= ":";
      }
	}
  }
}

function dateToString(dDate){
  var iDay = dDate.getDate();
  var iMonth = dDate.getMonth()+1;

  if(iDay < 10) iDay = "0"+iDay;
  if(iMonth < 10) iMonth = "0"+iMonth;

  return iDay+"/"+iMonth+"/"+y2k(dDate.getFullYear());
}

function formatDate(sDate){
  var dDate = makeDate(sDate);
  var iDay = dDate.getDate();
  var iMonth = dDate.getMonth()+1;

  if(iDay < 10) iDay = "0"+iDay;
  if(iMonth < 10) iMonth = "0"+iMonth;

  return iDay+"/"+iMonth+"/"+y2k(dDate.getFullYear());
}