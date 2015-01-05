function isFutureDate(d){
  var dateParts = d.split("/");
  var date;
  if(dateFormat=="dd/MM/yyyy"){
    date = new Date(dateParts[2],(dateParts[1]-1),dateParts[0]);
  }
  else{
	date = new Date(dateParts[2],(dateParts[0]-1),dateParts[1]);
  }
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

function checkDate(sobject){
  var sDate = sobject.value;
  if(sDate.length==0) return true;
  sDate = stripDate(sDate);

  var sDay = "01", sMonth = "01", sYear = new Date().getYear();

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
      sobject.select();
      sobject.focus();
      alertDialog("web","invalidDate");
        
      return false;
    }
  }  
  else{
    sobject.select();
    sobject.focus();
    alertDialog("web","invalidDate");
    
    return false;
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
      sobject.value = sMonth+"/"+sDay+"/"+sYear;
	}
    else{
	  // default : EU
	  sobject.value = sDay+"/"+sMonth+"/"+sYear;
	}

    return true;
  }
  else{
    sobject.select();
    sobject.focus();
    alertDialog("web","invalidDate");
    
    return false;
  }
  
  return true;
}

function y2k(year){
  if(year*1 >= 1900) return year; // OK, already 19xx or 20xx
  
  // make 19xx or 20xx from xx
  var actualYear = new Date().getFullYear().toString().substr(2,2)*1;
  return (year*1 > actualYear+5) ? year*1+1900 : year*1+2000;
}

function isDate(day,month,year){
  day*= 1;
  month*= 1;
  year*= 1;
	  
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
  document.getElementById(element).style.display='';
  document.getElementById(imgH).style.display='';
  document.getElementById(imgS).style.display='none';
}

function hideD(element,imgS,imgH){
  document.getElementById(element).style.display='none';
  document.getElementById(imgH).style.display='none';
  document.getElementById(imgS).style.display='';
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