 
//-- SET ROW STYLE --
function setRowStyle(row,rowIdx){
  if(rowIdx%2==0){
    for(var i=0; i<row.cells.length; i++){
      row.cells[i].style.font = "10px arial #333333";
      row.cells[i].style.padding = "5px 1px 1px 1px";
      row.cells[i].style.backgroundColor = "#E0EBF2";
    }
  }
  else{
    for(var i=0; i<row.cells.length; i++){
      row.cells[i].style.font = "10px arial #333333";
      row.cells[i].style.padding = "5px 1px 1px 1px";
      row.cells[i].style.backgroundColor = "#E9EEFF";
    }
  }
}

//-- UPDATE ROW STYLES SPECIFIC TABLE --
function updateRowStylesSpecificTable(tableId,headerRowCount){
  var tbl = document.getElementById(tableId);
  
  for(var i=headerRowCount; i<tbl.rows.length; i++){
    setRowStyle(tbl.rows[i],i);
  }
}

//-- REMOVE TR INDEXES --
function removeTRIndexes(sRows){
  var rows = sRows.split("$");
  sRows = "";
    
  for(var i=0; i<rows.length-1; i++){
    sRows+= rows[i].split("=")[1]+"$";
  }      
    
  return sRows;
}

//-- DELETE ROW FROM ARRAY STRING --
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
    
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
    }
  }
    
  return array.join("$");
}

//-- GET CELL FROM ROW STRING --
function getCelFromRowString(sRow,celid){
  var row = sRow.split("|");
  return row[celid];
}

//-- GET ROW FROM ARRAY STRING --
function getRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  var row = "";
    
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      row = array[i].substring(array[i].indexOf("=")+1);
      break;
    }
  }
    
  return row;
}

//-- REPLACE ROW IN ARRAY STRING --
function replaceRowInArrayString(sArray,newRow,rowid){
  var array = sArray.split("$");
    
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1,newRow);
      break;
    }
  }

  return array.join("$");
}

//-- ADD DAYS --
function addDays(date,days){  
  var iDaysInMinutes = days*24*60-1;
  return new Date(date.getTime()+(iDaysInMinutes*60*1000));
}

//-- REMOVE TRAILING ZEROS (except the first) --
function removeTrailingZeros(textField){
  while(textField.value.startsWith("00")){
    textField.value = textField.value.substring(1); 
  }
}

//-- ENTER EVENT --
function enterEvent(e,targetKey){
  var eventKey = e.which?e.which:window.event.keyCode;
  return (eventKey==targetKey);
}
