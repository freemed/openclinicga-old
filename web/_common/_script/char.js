function validateText(sObject){
    //NIET MEER TERUGZETTEN AUB!!!!!!!!!!!!!!!!!!!!
}

function denySpecialCharacters(inputField){
  var checkChar = inputField.value.charAt(inputField.value.length-1);

  if(checkChar=='É' || checkChar=='é' ||
     checkChar=='È' || checkChar=='è' ||
     checkChar=='Á' || checkChar=='á' ||
     checkChar=='À' || checkChar=='à' ||
     checkChar=='Ú' || checkChar=='ú' ||
     checkChar=='Ù' || checkChar=='ù' ||
     checkChar=='Ó' || checkChar=='ó' ||
     checkChar=='Ò' || checkChar=='ò' ||
     checkChar=='Í' || checkChar=='í' ||
     checkChar=='Ì' || checkChar=='ì' ||
     checkChar=='Ë' || checkChar=='ë' ||
     checkChar=='Ä' || checkChar=='ä' ||
     checkChar=='Ü' || checkChar=='ü' ||
     checkChar=='Ö' || checkChar=='ö' ||
     checkChar=='Ï' || checkChar=='ï'
    ){
    inputField.value = inputField.value.substring(0,inputField.value.length-1);
  }
}

function limitRows(textarea,maxrows){
  var onlyLines = textarea.value.match(/\n+/g);
  var currLines = (onlyLines?onlyLines.length:0);

  if(currLines >= maxrows){
    var lineCounter = 0;
    var strTemp = "";

    for(var i=0; i<textarea.value.length; i++){
      var oneChar = textarea.value.substring(i,i+1);
      if(oneChar == '\r'){
        lineCounter++;
        if(lineCounter==maxrows){
          textarea.value = strTemp;
          break;
        }
      }
      else{
        strTemp+= oneChar;
      }
    }
  }
}

function limitLength(sObject){
  var iMaxLength = 250;
  if (sObject.value.length>iMaxLength) {
    sObject.value = sObject.value.substring(0,iMaxLength);
  }
}

function setLength(sObject, iLength){
  if (sObject.value.length>iLength) {
    sObject.value = sObject.value.substring(0,iLength);
  }
}

function setDecimalLength(sObject, iLength){
  sObject.value = sObject.value.replace(",",".");
  var commaIdx = sObject.value.indexOf(".");

  if(commaIdx > -1){
    var integer  = sObject.value.substring(0,commaIdx);
    var decimals = sObject.value.substring(commaIdx+1);
    if(decimals.length > iLength) {
      decimals = decimals.substring(0,iLength);
    }
    sObject.value = integer+"."+decimals;
  }
  else{
    sObject.value = parseInt(sObject.value);
  }
}

function isNumberLimited(sObject,min,max){
  if(isNumber(sObject) && sObject.value.length>0){
    if(sObject.value*1<min || sObject.value*1>max){
      return false;
    }
    else{
      return true;
    }
  }
  else{
    return false;
  }
}

function isNumber(sObject){
  if(sObject.value.length==0) return false;
  sObject.value = sObject.value.replace(",",".");
  var string = sObject.value;
  var vchar = "01234567890.+-";
  var dotCount = 0;

  for(var i=0; i < string.length; i++){
    if (vchar.indexOf(string.charAt(i)) == -1)	{
      sObject.value = "";
      //sObject.focus();
      return false;
    }
    else{
      if(string.charAt(i)=="."){
        dotCount++;
        if(dotCount > 1){
          sObject.value = "";
          //sObject.focus();
          return false;
        }
      }
    }
  }

  if(sObject.value.length > 250){
    sObject.value = sObject.value.substring(0,249);
  }

  return true;
}

function isInteger(sObject){
  if(sObject.value.length==0) return false;
  sObject.value = sObject.value.replace(",",".");
  var string = sObject.value;
  var vchar = "01234567890";
  var dotCount = 0;

  for(var i=0; i < string.length; i++){
    if(vchar.indexOf(string.charAt(i)) == -1){
      sObject.value = "";
      return false;
    }
  }

  if(sObject.value.length > 250){
    sObject.value = sObject.value.substring(0,249);
  }

  return true;
}

function isIntegerNegativeAllowed(sObject){
  if(sObject.value.length==0) return false;
  sObject.value = sObject.value.replace(",",".");
  var string = sObject.value;
  var vchar = "-01234567890";
  var dotCount = 0;

  for(var i=0; i < string.length; i++){
    if(vchar.indexOf(string.charAt(i)) == -1){
      sObject.value = "";
      return false;
    }
  }

  if(sObject.value.length > 250){
    sObject.value = sObject.value.substring(0,249);
  }

  return true;
}

function isNumberNegativeAllowed(inputField){
  if(inputField.value.length==0) return false;
  var number = inputField.value;
  var vchar = "-1234567890.";
  var dotCount = 0;

  for(var i=0; i < number.length; i++){
    if(vchar.indexOf(number.charAt(i)) == -1){
      inputField.value = "";
      return false;
    }
    else{
      if(number.charAt(i)=="."){
        dotCount++;
        if(dotCount > 1){
          inputField.value = "";
          return false;
        }
      }
    }
  }

  if(inputField.value.length > 250){
    inputField.value = inputField.value.substring(0,249);
  }

  return true;
}

function checkMinMax(iMin, iMax, oObject, iDefault){
  isNumber(oObject);

  if (oObject.value.length>0) {
    if (iMin != "") {
      if (oObject.value < iMin) {
        oObject.value=iDefault;
        oObject.focus();
        return false;
      }
    }

    if (iMax != "") {
      if (oObject.value > iMax) {
        oObject.value=iDefault;
        oObject.focus();
        return false;
      }
    }
  }
  return true;
}

function checkMinMaxOpen(iMin, iMax, oObject){
  if (oObject.value.length>0) {
    if (iMin != "") {
      if (oObject.value < iMin) {
        return false;
      }
    }

    if (iMax != "") {
      if (oObject.value > iMax) {
        return false;
      }
    }
  }
  return true;
}

function textCounter(field,cntfield,maxlimit) {
  if (field.value.length > maxlimit){
    field.value = field.value.substring(0, maxlimit);
  }
  else{
    // update 'characters left' counter
    cntfield.value = maxlimit - field.value.length;
  }
}

function LTrim(value){
  var re = /\s*((\S+\s*)*)/;
  return value.replace(re, "$1");
}

function RTrim(value){
  var re = /((\s*\S+)*)\s*/;
  return value.replace(re, "$1");
}

function trim(value){
  return LTrim(RTrim(value));
}