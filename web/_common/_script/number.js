function format_number(p,d){
  return p.toFixed(d);
  //var r;
  //if(p<0){p=-p;r=format_number2(p,d);r="-"+r;}
  //else   {r=format_number2(p,d);}
  //return r;
}

function format_number2(pnumber,decimals){
  var strNumber = new String(pnumber);
  var arrParts = strNumber.split('.');
  var intWholePart = parseInt(arrParts[0],10);
  var strResult = '';
  if (isNaN(intWholePart))
    intWholePart = '0';
  if(arrParts.length > 1){
    var decDecimalPart = new String(arrParts[1]);
    var i = 0;
    var intZeroCount = 0;
     while ( i < String(arrParts[1]).length ){
       if( parseInt(String(arrParts[1]).charAt(i),10) == 0 ){
         intZeroCount += 1;
         i += 1;
       }
       else
         break;
    }
    decDecimalPart = parseInt(decDecimalPart,10)/Math.pow(10,parseInt(decDecimalPart.length-decimals-1));
    Math.round(decDecimalPart);
    decDecimalPart = parseInt(decDecimalPart)/10;
    decDecimalPart = Math.round(decDecimalPart);

    //If the number was rounded up from 9 to 10, and it was for 1 'decimal'
    //then we need to add 1 to the 'intWholePart' and set the decDecimalPart to 0.

    if(decDecimalPart==Math.pow(10, parseInt(decimals))){
      intWholePart+=1;
      decDecimalPart="0";
    }
    var stringOfZeros = new String('');
    i=0;
    if( decDecimalPart > 0 ){
      while( i < intZeroCount){
        stringOfZeros += '0';
        i += 1;
      }
    }
    decDecimalPart = String(intWholePart) + "." + stringOfZeros + String(decDecimalPart);
    var dot = decDecimalPart.indexOf('.');
    if(dot == -1){
      decDecimalPart += '.';
      dot = decDecimalPart.indexOf('.');
    }
    var l=parseInt(dot)+parseInt(decimals);
    while(decDecimalPart.length <= l){
      decDecimalPart += '0';
    }
    strResult = decDecimalPart;
  }
  else{
    var dot;
    var decDecimalPart = new String(intWholePart);

    decDecimalPart += '.';
    dot = decDecimalPart.indexOf('.');
    var l=parseInt(dot)+parseInt(decimals);
    while(decDecimalPart.length <= l){
      decDecimalPart += '0';
    }
    strResult = decDecimalPart;
  }
  return strResult;
}
