
//-- REMOVE TR INDEXES --
function removeTRIndexes(sTableArrayString){
  var oneRow, sArrayString = "";
    
  while(sTableArrayString.indexOf("$") > -1){
    oneRow = sTableArrayString.substring(0,sTableArrayString.indexOf("$"));
    oneRow = oneRow.substring(oneRow.indexOf("=")+1); // trim off index
    
    sTableArrayString = sTableArrayString.substring(sTableArrayString.indexOf("$")+1);
    sArrayString+= oneRow+"$";
  }

  return sArrayString;
}
 
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

//-- UPDATE ROW STYLES --
function updateRowStyles(){
  if(document.getElementById("searchresults")!=null){
    for(var i=1; i<searchresults.rows.length; i++){
      searchresults.rows[i].className = "";
      searchresults.rows[i].style.cursor = "hand";
    }

    for(var i=1; i<searchresults.rows.length; i++){
      setRowStyle(searchresults.rows[i],i);
    }
  }
}