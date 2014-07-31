/*
  based on : javascript for Bubble Tooltips by Alessandro Fulciniti
  http://pro.html.it
*/

function enableTooltip(id){
  if(!document.getElementById || !document.getElementsByTagName) return;
  var tooltip = document.createElement("span");
  tooltip.id = "tooltip";
  tooltip.style.position = "absolute";
  document.getElementsByTagName("body")[0].appendChild(tooltip);

  createTooltip(document.getElementById(id));
}

function createTooltip(elem){
  var ttTitle = elem.getAttribute("tooltiptitle");
  elem.removeAttribute("tooltiptitle");

  var ttText = elem.getAttribute("tooltiptext");
  elem.removeAttribute("tooltiptext");

  // set layout
  var span = document.createElement("span");
  span.style.display = "block";
  span.style.background = "#ffee99";
  span.style.padding = "5px";
  span.style.border = "1px solid #aaa";
  span.style.width = "300px";
  span.style.fontSize = "11px";

  // add title in bold, if any specified
  if(ttTitle!=null){
    var boldTitle = document.createElement("b");
    boldTitle.appendChild(document.createTextNode(ttTitle));
    span.appendChild(boldTitle);

    var br = document.createElement("br");
    span.appendChild(br);
  }

  // replace newlines by BR
  var sentences = ttText.split("\r\n");
  for(var i=0; i<sentences.length; i++){
    span.appendChild(document.createTextNode(sentences[i]));

    var br = document.createElement("br");
    span.appendChild(br);
  }
  
  //setOpacity(span,80);
  elem.tooltip = span;
  elem.onmouseover = showTooltip;
  elem.onmouseout = hideTooltip;
  elem.onmousemove = positionAtCursor;
}

function showTooltip(e){
  hideSelects();
  document.getElementById("tooltip").appendChild(this.tooltip);
  positionAtCursor(e);
}

function hideTooltip(e){
  var tooltip = document.getElementById("tooltip");
  if(tooltip.childNodes.length > 0){
    tooltip.removeChild(tooltip.firstChild);
  }

  unhideSelects();
}

function setOpacity(elem,percentage){
  elem.style.filter = "alpha(opacity:"+percentage+")";
  elem.style.KHTMLOpacity = ""+(percentage/100);
  elem.style.MozOpacity = ""+(percentage/100);
  elem.style.opacity = ""+(percentage/100);
}

function positionAtCursor(e){
  var rightedge, bottomedge, xoffset, yoffset;

  if(e){
    rightedge = window.innerWidth - e.clientX;
    bottomedge = window.innerHeight - e.clientY;
    xoffset = window.pageXOffset;
    yoffset = window.pageYOffset;
  }
  else{
    e = window.event;
    rightedge = document.body.clientWidth - e.clientX;
    bottomedge = document.body.clientHeight - e.clientY;
    xoffset = document.body.scrollLeft;
    yoffset = document.body.scrollTop;
  }

  var tooltipElem = document.getElementById("tooltip");

  if(rightedge < tooltipElem.offsetWidth){
    tooltipElem.style.left = document.body.scrollLeft + e.clientX - tooltipElem.offsetWidth - 15;

    if(bottomedge < tooltipElem.offsetHeight){
      tooltipElem.style.top = document.body.scrollTop + e.clientY - tooltipElem.offsetHeight - 5;
    }
    else{
      tooltipElem.style.top = document.body.scrollTop + e.clientY - 5;
    }
  }
  else{
    tooltipElem.style.left = document.body.scrollLeft + e.clientX + 15;

    if(bottomedge < tooltipElem.offsetHeight){
      tooltipElem.style.top = document.body.scrollTop + e.clientY - tooltipElem.offsetHeight - 5;
    }
    else{
      tooltipElem.style.top = document.body.scrollTop + e.clientY - 5;
    }
  }
}