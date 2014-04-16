isIE = document.all;
isActive = false;

function MoveInit(e){
  topOne=isIE ? "BODY" : "HTML";
  whichOne=isIE ? document.all.FloatingLayer : document.getElementById("FloatingLayer");
  ActiveOne=isIE ? event.srcElement : e.target;
  while (ActiveOne.id!="titleBar" && ActiveOne.tagName!=topOne){
    ActiveOne=isIE ? ActiveOne.parentElement : ActiveOne.parentNode;
  }

  if(ActiveOne.id=="titleBar"){
    offsetx = isIE ? event.clientX : e.clientX;
    offsety = isIE ? event.clientY : e.clientY;
    nowX = parseInt(whichOne.style.left);
    nowY = parseInt(whichOne.style.top);
    MoveEnabled = true;
    document.onmousemove = Move;
  }
}

function Move(e){
  if(!MoveEnabled) return;
  whichOne.style.left = isIE ? nowX+event.clientX-offsetx : nowX+e.clientX-offsetx;
  whichOne.style.top = isIE ? nowY+event.clientY-offsety : nowY+e.clientY-offsety;
  return false;
}

function ToggleFloatingLayer(DivID,iState){
  if(document.getElementById){
    var obj = document.getElementById(DivID);
    obj.style.visibility = iState ? "visible" : "hidden";

    var objWidth = obj.style.width.substring(0,obj.style.width.length-2);
    var objHeight = obj.style.height.substring(0,obj.style.height.length-2);

    obj.style.left = (window.document.body.offsetWidth-8-objWidth)/2+"px";
    obj.style.top = (window.document.body.offsetHeight-50-objHeight)/2+"px";

  }
}

document.onmousedown = MoveInit;
document.onmouseup = Function("MoveEnabled=false");