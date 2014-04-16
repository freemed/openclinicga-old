var menuskin = "skin1";
var display_url = 0;

// popupmenu tonen
function showmenuie5(evt){
  var menuobj = document.getElementById("ie5menu");
  menuobj.style.display = '';
    
  if(evt){
    var rightedge= window.innerWidth-evt.clientX;
    var bottomedge= window.innerHeight-evt.clientY;
        
    if(rightedge<menuobj.offsetWidth)
      menuobj.style.left= window.pageXOffset+evt.clientX-menuobj.offsetWidth;
    else
      menuobj.style.left= window.pageXOffset+evt.clientX;
    
    if(bottomedge < menuobj.offsetHeight)
      menuobj.style.top = window.pageYOffset+evt.clientY-menuobj.offsetHeight;
    else
      menuobj.style.top = window.pageYOffset+evt.clientY;
  }
  else{
    evt = window.event;

    var rightedge = document.body.clientWidth-evt.clientX;
    var bottomedge = document.body.clientHeight-evt.clientY;

    if(rightedge<menuobj.offsetWidth)
      menuobj.style.left = document.body.scrollLeft+evt.clientX-menuobj.offsetWidth;
    else
      menuobj.style.left = document.body.scrollLeft+evt.clientX;

    if(bottomedge<menuobj.offsetHeight)
      menuobj.style.top = document.body.scrollTop+event.clientY-menuobj.offsetHeight;
    else
      menuobj.style.top = document.body.scrollTop+event.clientY;
  }
  menuobj.style.visibility = "visible";
    
  return false;
}

// popupmenu verbergen
function hidemenuie5(){
  if(!bShowMenu){
    if(typeof(ie5menu)!="undefined"){
      ie5menu.style.visibility = "hidden";
    }
    var sfSelect = document.getElementsByTagName("SELECT");
    for(var i=0; i<sfSelect.length; i++){
      sfSelect[i].style.visibility = "";
    }
  }
}

// layout when hoovering a button
function highlightie5(evt){
  if(evt.target){
    if(evt.target.className=="menuitems"){
      evt.target.style.backgroundColor = "#E0EEFF";
      evt.target.style.color = "black";
      evt.target.style.cursor = "pointer";
      if(display_url)
        window.status = evt.target.url;
    }
  }
  else{
    evt = window.event;

    if(evt.srcElement.className=="menuitems"){
      evt.srcElement.style.backgroundColor = "#E0EEFF";
      evt.srcElement.style.color = "black";
      evt.srcElement.style.cursor = "pointer";
      if(display_url)
        window.status = evt.srcElement.url;
    }
  }
}

// layout after hoovering a button
function lowlightie5(evt){
  if(evt.target){
    if(evt.target.className=="menuitems"){
      evt.target.style.backgroundColor = "";
      evt.target.style.color = "";
      window.status = "";
    }
  }
  else{
    evt = window.event;

    if(evt.srcElement.className=="menuitems"){
      evt.srcElement.style.backgroundColor = "";
      evt.srcElement.style.color = "";
      window.status = "";
    }
  }
}

// als men op een item klikt
function jumptoie5(evt){
  if(evt.target){
    if(evt.target.className=="menuitems"){
      if(evt.target.getAttribute("target")!=null)
        window.open(evt.target.getAttribute("url"),evt.target.getAttribute("target"));
      else
        if(evt.target.getAttribute("url")!="null"){
          window.location = evt.target.getAttribute("url");
        }
        else{
          hidemenuie5(evt);
        }
    }
  }
  else{
    evt = window.event;

    if(evt.srcElement.className=="menuitems"){
      if(evt.srcElement.getAttribute("target")!=null)
        window.open(evt.srcElement.url,evt.srcElement.getAttribute("target"));
      else
        if(evt.srcElement.url!="null")
          window.location = evt.srcElement.url;
        else
          hidemenuie5(evt);
    }
  }
}

function setPopup(){}

function getTrue(e){
  return true;
}