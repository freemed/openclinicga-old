addEvent(window,"load",sortables_init);

var SORT_COLUMN_INDEX;
var INITIAL_SORT_DIR = "up";

function sortables_init(){
  // Find all tables with class 'sortable' and make them sortable
  if(!document.getElementsByTagName) return;

  var tbls = document.getElementsByTagName("table");
  var thisTbl;
  for(var i=0; i<tbls.length; i++){
    thisTbl = tbls[i];
    if(((thisTbl.className).indexOf("sortable")!=-1) && (thisTbl.id)){
      ts_makeSortable(thisTbl);
    }
  }
}

function ts_makeSortable(table){
  var headerRowCount = table.getAttribute("headerRowCount");
  if(!headerRowCount || (headerRowCount && headerRowCount.length==0)){
    headerRowCount = 1;
  }
  
  var bottomRowCount = table.getAttribute("bottomRowCount");
  if(!bottomRowCount || (bottomRowCount && bottomRowCount.length==0)){
	bottomRowCount = 0;
  }

  var firstRow;
  if(table.rows && table.rows.length > 0){
    firstRow = table.rows[0];
  }
  if(!firstRow) return;
  
  // We have a first row: make its contents clickable links
  for(var i=0;i<firstRow.cells.length;i++){
    var cell = firstRow.cells[i];
    
    if(cell.innerHTML.toLowerCase().indexOf("<select ") < 0){
      var txt = ts_getInnerText(cell);
      txt = trim(txt);
      
      var lastValidCharIdx = getLastValidCharIdx(txt);
      if(lastValidCharIdx > -1){
    	txt = txt.substring(0,lastValidCharIdx+1);
      }
      
      // type to use for sorting the colum might be specified, so try to fetch it
      var sortType = "";
      if(cell.innerHTML.indexOf("<SORTTYPE:") > -1){
        sortType = cell.innerHTML.substring(cell.innerHTML.indexOf("<SORTTYPE:")+10,cell.innerHTML.indexOf(">"));
      }

      // indicate column that is sorted on pageload
      var sortedASC = false, sortedDESC = false;
      
      var ARROW = "";
      if(cell.innerHTML.indexOf("<ASC>") > -1){
        sortedASC = true;
        ARROW = "&uarr;";
        INITIAL_SORT_DIR = "up";
      }
      if(cell.innerHTML.indexOf("<DESC>") > -1){
        sortedDESC = true;
        ARROW = "&darr;";
        INITIAL_SORT_DIR = "down";
      }

      if(cell.innerHTML.indexOf("<NOSORT>") < 0){
        var content;
        if(cell.style.textAlign=="right"){
          content = "<a href='#' id='"+table.id+"_lnk"+i+"' class='sortheader' onclick=\"ts_resortTable(this,"+i+",true,"+headerRowCount+","+bottomRowCount+",'"+sortType+"');return false;\">"+
                    "<span id='span"+i+"' class='sortarrow'>"+ARROW+"</span>"+txt+"</a>";
        }
        else{
          content = "<a href='#' id='"+table.id+"_lnk"+i+"' class='sortheader' onclick=\"ts_resortTable(this,"+i+",true,"+headerRowCount+","+bottomRowCount+",'"+sortType+"');return false;\">"+
                    txt+"<span id='span"+i+"' class='sortarrow'>"+ARROW+"</span></a>";
        } 
  
        cell.innerHTML = content;

        var span = document.getElementById("span"+i);
        if(sortedDESC) span.setAttribute("sortdir","down");
        if(sortedASC)  span.setAttribute("sortdir","up");

        if(cell.style.textAlign=="right"){
          cell.innerHTML = "&nbsp;&nbsp;"+cell.innerHTML;
        }
      }
    }
  }
  
  if(typeof initialSort!="undefined"){
    initialSort();
  }
}

function ts_getInnerText(el){
  var str = "";
  if(el!=undefined){
    if(typeof el=="string") return el;
    if(typeof el=="undefined") return el;
    if(el.innerText) return el.innerText;
    var cs = el.childNodes;

    var l = cs.length;
    for(var i=0; i<l; i++){
      switch(cs[i].nodeType){
        case 1: str+= ts_getInnerText(cs[i]);
                break;
        case 3: str+= cs[i].nodeValue;
                break;
      }
    }
  }

  return trim(str);
}

function ts_resortTable(lnk,clid,changeDirection,headerRowCount,bottomRowCount,sortType){
  if(changeDirection==undefined) changeDirection = true;
  if(headerRowCount==undefined) headerRowCount = 1;
  if(bottomRowCount==undefined) bottomRowCount = 0;
  if(sortType==undefined) sortType = "";
    	  
  var span;
  for(var ci=0;ci<lnk.childNodes.length;ci++){
    if(lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase()=="span"){
      span = lnk.childNodes[ci];
    }
  }
  var td = lnk.parentNode;
  var column = clid || td.cellIndex;
  var table = getParent(td,"TABLE");

  var bottomRows = new Array(bottomRowCount);
  for(var i=0; i<bottomRows.length; i++){
    var bottomRow = table.rows[table.rows.length-1];
    bottomRows[i] = bottomRow;
    table.tBodies[0].removeChild(bottomRow);
  }
    
  if(table.rows.length <= 1) return;

  var sortfn;
  if(sortType.length > 0){
         if(sortType=="TEXT") sortfn = ts_sort_caseinsensitive;
    else if(sortType=="DATE") sortfn = ts_sort_date;
    else if(sortType=="NUM")  sortfn = ts_sort_numeric;
    else if(sortType=="CURR") sortfn = ts_sort_currency;
  }
  else{
    var itm = ts_getInnerText(table.rows[1].cells[column]);
    itm = trim(itm);

    sortfn = ts_sort_caseinsensitive;
    if(itm.match(/^\d\d[\/-]\d\d[\/-]\d\d\d\d$/)) sortfn = ts_sort_date;
    if(itm.match(/^\d\d[\/-]\d\d[\/-]\d\d$/)) sortfn = ts_sort_date;
    if(itm.match(/^[£$]/)) sortfn = ts_sort_currency;
    if(itm.match(/^[\d\.]+$/)) sortfn = ts_sort_numeric;
  }

  SORT_COLUMN_INDEX = column;
  var firstRow = new Array();
  for(var i=0; i<table.rows[headerRowCount-1].length; i++){
    firstRow[i] = table.rows[headerRowCount-1][i];
  }
  var rowCount = parseInt(table.rows.length);

  var newRows = new Array();
  var idx = 0;
  var endIdx = (bottomRowCount>0?(rowCount-bottomRowCount+1):(rowCount-bottomRowCount));
  for(var j=headerRowCount; j<endIdx; j++){
    newRows[idx++] = table.rows[j];
  }

  newRows.sort(sortfn);

  var sortDir = span.getAttribute("sortdir");
  if(sortDir==null){
    sortDir = INITIAL_SORT_DIR;
  }

  var ARROW;
  if(sortDir=="up"){
    ARROW = "&darr;";
    if(changeDirection==true){
      newRows.reverse();
      span.setAttribute("sortdir","down");
    }
  }
  else if(sortDir=="down"){
    ARROW = "&uarr;";
    if(changeDirection==true){
      span.setAttribute("sortdir","up");
    }
    else{
      newRows.reverse();
    }
  }

  for(var i=0; i<newRows.length; i++){
    table.tBodies[0].appendChild(newRows[i]);
  }
  
  for(var i=bottomRows.length-1; i>=0; i--){
    table.tBodies[0].appendChild(bottomRows[i]);
  }
  
  for(var i=0; i<newRows.length; i++){
    if(newRows[i].className && (newRows[i].className.indexOf("sortbottom")!=-1)){
      table.tBodies[0].appendChild(newRows[i]);
    }
  }

  var allspans = document.getElementsByTagName("span");
  for(var ci=0; ci<allspans.length; ci++){
    if(allspans[ci].className=="sortarrow"){
      if(getParent(allspans[ci],"table")==getParent(lnk,"table")){
        allspans[ci].innerHTML = "";
      }
    }
  }

  span.innerHTML = ARROW;

  if(updateRowStyles!=null){
    updateRowStyles(headerRowCount);
  }
}

function getParent(el,pTagName){
  if(el == null) return null;
  else if(el.nodeType==1 && el.tagName.toLowerCase()==pTagName.toLowerCase())
    return el;
  else
    return getParent(el.parentNode,pTagName);
}

function ts_sort_date(a,b){
  var dt1, dt2;
  var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
  var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
  if(aa.length == 10){
    dt1 = aa.substr(6,4)+aa.substr(3,2)+aa.substr(0,2);
  }
  else{
    var yr = aa.substr(8,2);
    if(parseInt(yr) < 50){ yr = '20'+yr; } else{ yr = '19'+yr; }
    dt1 = yr+aa.substr(3,2)+aa.substr(0,2);
  }

  if(bb.length == 10){
    dt2 = bb.substr(6,4)+bb.substr(3,2)+bb.substr(0,2);
  }
  else{
    var yr = bb.substr(8,2);
    if(parseInt(yr) < 50){ yr = '20'+yr; } else{ yr = '19'+yr; }
    dt2 = yr+bb.substr(3,2)+bb.substr(0,2);
  }

  if(dt1==dt2) return 0;
  if(dt1<dt2) return -1;
  return 1;
}

function ts_sort_currency(a,b){
  var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
  var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
  return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b){
  var aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
  if(isNaN(aa)) aa = 0;
  var bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]));
  if(isNaN(bb)) bb = 0;
  return aa-bb;
}

function ts_sort_caseinsensitive(a,b){
  var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
  var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();

  if(aa==bb) return 0;
  if(aa<bb) return -1;
  return 1;
}

function ts_sort_default(a,b){
  var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
  var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);

  if(aa==bb) return 0;
  if(aa<bb) return -1;
  return 1;
}

function addEvent(elm,evType,fn,useCapture){
  if(elm.addEventListener){
    elm.addEventListener(evType,fn,useCapture);
    return true;
  }
  else if(elm.attachEvent){
    return elm.attachEvent("on"+evType,fn);
  }
  else{
    alert("Handler could not be removed");
  }
}

// UPDATE ROW STYLES (after sorting)
function updateRowStyles(headerRowCount){
  var searchresults = document.getElementById("searchresults");

  if(searchresults!=null){
    for(var i=headerRowCount; i<searchresults.rows.length; i++){
      if(searchresults.rows[i].className.indexOf("strike")==-1){
        searchresults.rows[i].className = "";
      }
      searchresults.rows[i].style.cursor = "pointer";
    }

    for(var i=headerRowCount; i<searchresults.rows.length; i++){
      if(i%2==0){
        if(searchresults.rows[i].className.indexOf("strike")>-1){
          searchresults.rows[i].className = "strikelist";
          searchresults.rows[i].onmouseout = function(){
            this.className = "strikelist";
          }
        }
        else{
          searchresults.rows[i].className = "list";
          searchresults.rows[i].onmouseout = function(){
            this.className = "list";
          }
        }
      }
      else{
        if(searchresults.rows[i].className.indexOf("strike")>-1){
          searchresults.rows[i].className = "strike";
          searchresults.rows[i].onmouseout = function(){
            this.className = "strike";
          }
        }
        else{
          searchresults.rows[i].className = "list1";
          searchresults.rows[i].onmouseout = function(){
            this.className = "list1";
          }
        }
      }
    }
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

// remove existing arrows to prevent build-up of arrows when table is reused by ajax
function getLastValidCharIdx(txt){
  txt = txt.trim();
  txt = txt.toLowerCase();
  
  var validChars = "abcdefghijklmnopqrstuvwxyz* ";
  var lastValidCharIdx = -1;
  
  for(var i=0; i<txt.length; i++){
    if(validChars.indexOf(txt.charAt(i))==-1){
      break;	
    }	  
    else{
      lastValidCharIdx = i;
    }
  }
  
  return lastValidCharIdx;
}