function isFutureDate(dateObj,allowFutureDate){
  if(allowFutureDate==null) allowFutureDate = true;

  var sDate = dateObj.value;
  sDate = sDate.replace("-","/");
  sDate = sDate.replace(".","/");
  
  var dateParts = sDate.split("/");
  var dDate;
  if(dateFormat=="dd/MM/yyyy"){
	  dDate = new Date(dateParts[2],(dateParts[1]-1),dateParts[0]);
  }
  else{
	  dDate = new Date(dateParts[2],(dateParts[0]-1),dateParts[1]);
  }
  
  if(dDate > new Date()){
	if(!allowFutureDate){
      alertDialog("web","futureDatesNotAllowed");
	  dateObj.select();
	}
    
    return true;
  }
  
  return false;
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

  if(date1.getTime() > date2.getTime()){ // only difference with function 'before'
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
  dateStr = dateStr.replace("-","/");
  dateStr = dateStr.replace(".","/");

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
  fulldateStr = fulldateStr.replace(".","/");
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

function stripDate(sDate){
  sDate = replaceAll(sDate,"-","");
  sDate = replaceAll(sDate,".","");
  sDate = replaceAll(sDate,"/","");
  
  var validChars = "0123456789";	      
  for(var i=0; i<sDate.length; i++){
    if(validChars.indexOf(sDate.charAt(i)) < 0){
      sDate = sDate.substring(0,i)+sDate.substring(i+1,sDate.length);
    }
  }
     
  return sDate;
}

function checkDate(dateObj){
  var sDate = dateObj.value;
  if(sDate.length==0) return true;
  sDate = replaceAll(sDate,"-","/");
  sDate = replaceAll(sDate,".","/");

  var sDay = "01", sMonth = "01", sYear = new Date().getYear();
  
  if(sDate.indexOf("/") > 0){
    if(dateFormat=="dd/MM/yyyy"){
      sDay = sDate.substring(0,sDate.indexOf("/"));
      if(sDay.length < 2) sDay = "0"+sDay;
     
      sMonth = sDate.substring(sDate.indexOf("/")+1,sDate.lastIndexOf("/"));
      if(sMonth.length < 2) sMonth = "0"+sMonth;	
    }
    else{
  	  sMonth = sDate.substring(0,sDate.indexOf("/"));
      if(sMonth.length < 2) sMonth = "0"+sMonth;
      
      sDay = sDate.substring(sDate.indexOf("/")+1,sDate.lastIndexOf("/"));
      if(sDay.length < 2) sDay = "0"+sDay;
    }
    
    sYear = sDate.substring(sDate.lastIndexOf("/")+1);
    sYear = y2k(sYear);
  }
  else{
    sDate = stripDate(sDate);

    if(sDate.length==8){    
      if(dateFormat=="dd/MM/yyyy"){	
        sDay = sDate.substring(0,2);
        sMonth = sDate.substring(2,4);
        sYear = sDate.substring(4,8);
      }
      else{
        sMonth = sDate.substring(0,2);
        sDay = sDate.substring(2,4);
        sYear = sDate.substring(4,8);
      }
    }  
    else if(sDate.length==6){
      // "MMYYYY" or "DDMMYY" ?    	
      // 1 : try MMYYYY
      sYear = sDate.substring(2,sDate.length);
      sYear = y2k(sYear);
      
      if(sYear >= 1900 && sYear < 2100){
        // year ok
        if(dateFormat=="dd/MM/yyyy"){
          sDay = sDate.substring(0,1);
          sMonth = sDate.substring(1,2);
        }
        else{
          sDay = sDate.substring(1,2);
          sMonth = sDate.substring(0,1);
        }
      }
      else{
        // 2 : try DDMMYY
        var sYear = sDate.substring(4,sDate.length);
        sYear = y2k(sYear);

        if(sYear >= 1900 && sYear < 2100){
          if(dateFormat=="dd/MM/yyyy"){
            sDay = sDate.substring(0,2);
            sMonth = sDate.substring(2,4);
          }
          else{
            sDay = sDate.substring(2,4);
            sMonth = sDate.substring(0,2);
          }
        }
      }	
    }  
    else if(sDate.length==4){
      // "DMYY" ?    	
      sYear = sDate.substring(2,sDate.length);
      sYear = y2k(sYear);
      
      if(sYear >= 1900 && sYear < 2100){
        // year ok
        if(dateFormat=="dd/MM/yyyy"){
          sDay = sDate.substring(0,1);
          sMonth = sDate.substring(1,2);
        }
        else{
          sDay = sDate.substring(1,2);
          sMonth = sDate.substring(0,1);
        }
      }
      else{
        alertDialog("web","invalidDate");
    	dateObj.select();
        
        return false;
      }
    }  
    else{
      alertDialog("web","invalidDate");
      dateObj.select();
    
      return false;
    }
  }

  sDay = sDay*1;
  sMonth = sMonth*1;
  sYear = sYear*1;

  if(sDay.length>2) sDay = sDay.substring(0,2);
  if(sMonth.length>2) sMonth = sMonth.substring(0,2);
  if(sYear.length>4) sYear = sYear.substring(0,4);

  if(isDate(sDay,sMonth,sYear)){
    if(sDay<10) sDay = "0"+sDay;
    if(sMonth<10) sMonth = "0"+sMonth;
	  
    if(dateFormat.startsWith("MM")){
      // US
      dateObj.value = sMonth+"/"+sDay+"/"+sYear;
    }
    else{
      // default : EU
      dateObj.value = sDay+"/"+sMonth+"/"+sYear;
    }

    return true;
  }
  else{
    alertDialog("web","invalidDate");
    dateObj.select();
  
    return false;
  }
  
  return true;
}

function checkDateMonthAndYearAllowed(dateObj){
  var sDate = dateObj.value;
  if(sDate.length==0) return true;
  sDate = stripDate(sDate);
  
  if(sDate.length==6){
    var year = sDate.substring(2,6);
    if(year > 1900){
      /*-- 102010 --> 10/2010 --*/
	  return checkDateMonthAndYearAllowed2(dateObj);  
    }
    else{
      /*-- 101010 --> 10/10/2010 --*/
  	  return !checkDate(dateObj);  
    }
  }
  
  return checkDateMonthAndYearAllowed2(dateObj);
}

function checkDateMonthAndYearAllowed2(dateObj){	
  var sDate = dateObj.value;
  if(sDate.length==0) return true;
  sDate = stripDate(sDate);
    
  // full date
  if(sDate.length==8){
    dateObj.value = sDate;
    return checkDate(dateObj);
  }
  // month and year
  else if(sDate.length==6){    
    // continue below
  }
  // year
  else if(sDate.length==4){
    return checkDate(dateObj);
  }

  // assume MMyyyy
  var month = sDate.substring(0,2);
  var year = sDate.substring(2,6);
  
  if(!isValidYear(year)){
	// assume ddMMyy    
    if(dateFormat=="dd/MM/yyyy"){
      sDay = sDate.substring(0,2);
      sMonth = sDate.substring(2,4);
    }
    else{
      sDay = sDate.substring(2,4);
      sMonth = sDate.substring(0,2);
    }
    
    year = sDate.substring(4,6);
  }

  var monthOK = 0;
  var yearOK = 0;

  // check month
  if(month.length==0) month = "1";
  month = parseInt(month*1); // remove leading zeroes

  if(month*1 <= 12 && month*1 >= 1){
    if(month<10) month = "0"+month;
    monthOK = 1;
  }

  if(monthOK==1){
    // check year
    if(isValidYear(year)){
      yearOK = 1;
    }
  }

  if(monthOK==1 && yearOK==1){
    dateObj.value = month+"/"+year;
    return true;
  }
  else{
    return checkDate(dateObj);
  }
}

function checkDateOnlyYearAllowed(dateObj){
  var sDate = dateObj.value;

  if(sDate.length == 4){
    if(!isNaN(sDate)){
      if(isValidYear(sDate)){
        return true;
      }
    }
  }

  return checkDate(dateObj);
}

function y2k(year){
  if(year*1 >= 1900) return year; // OK, already 19xx or 20xx
  if(year*1 > 99) return year; // ERR, eg 215
	  
  // make 19xx or 20xx from xx
  var actualYear = new Date().getFullYear().toString().substr(2,2)*1;
  return (year*1 > actualYear+5) ? year*1+1900 : year*1+2000;
}

function isDate(day,month,year){
  year*= 1;
  if(year < 1900 || year > 2099){ 
	  return false;
  }

  month*= 1;
  if(month < 1 || month > 12){ 
	  return false;
  }

  day*= 1;
  if(day < 1 || day > 31){
	  return false;
  }

  if((month==4 || month==6 || month==9 || month==11) && day==31){
	  return false;
  }

  if(month==2){ // check for february 29th
    var isleap = (year%4==0 && (year%100!=0 || year%400==0));
    if(day > 29 || (day==29 && !isleap)){
    	return false;
    }
  }
  
  return true;
}

function getToday(dateObj){
  var today = new Date();
  var sDay = today.getDate()+"";
  if(sDay.length < 2) sDay = "0"+sDay;
  var sMonth = (today.getMonth()+1)+"";
  if(sMonth.length < 2) sMonth = "0"+sMonth;
  if(dateFormat.startsWith("MM")){
    // US
    dateObj.value = (sMonth+"/"+sDay+"/"+today.getFullYear());
  }
  else{
    // default : EU
    dateObj.value = (sDay+"/"+sMonth+"/"+today.getFullYear());
  }
  
  try{
    dateObj.focus();
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
  document.getElementById(element).style.display='';
  document.getElementById(imgH).style.display='';
  document.getElementById(imgS).style.display='none';
}

function hideD(element,imgS,imgH){
  document.getElementById(element).style.display='none';
  document.getElementById(imgH).style.display='none';
  document.getElementById(imgS).style.display='';
}

function addDays(sDate1,sbetween){
  if((sDate1.length>0)&&(sbetween.length>0)){
    var iDaydate1 = sDate1.substring(0,sDate1.indexOf("/"));
    var iMonthdate1 = sDate1.substring(sDate1.indexOf("/")+1,sDate1.lastIndexOf("/"));
    var iYeardate1 = sDate1.substring(sDate1.lastIndexOf("/")+1,sDate1.length);
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

function checkTime(dateObj){
  var sDate = dateObj.value;
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
      sDate+= ":";
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
    dateObj.value = sReturn;
  }
}

function putTime(dateObj){
  var today = new Date();
  iHour = today.getHours();
  iMinutes = today.getMinutes();
  var sReturn = '00:00';
  if((iHour>-1)&&(iHour<25)&&(iMinutes>-1)&&(iMinutes<60)){
    if(iHour<10) iHour = "0"+iHour;
    if(iMinutes<10) iMinutes = "0"+iMinutes;
    sReturn = iHour+":"+iMinutes;
  }
  dateObj.value = sReturn;
}

function getTime(dateObj){
  var today = new Date();
  iHour = today.getHours();
  iMinutes = today.getMinutes();
 
  var sReturn = '00:00';
  if((iHour>-1)&&(iHour<25)&&(iMinutes>-1)&&(iMinutes<60)){
    if(iHour<10) iHour = "0"+iHour;
    if(iMinutes<10) iMinutes = "0"+iMinutes;
    sReturn = iHour+":"+iMinutes;
  }
  dateObj.value = sReturn;
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