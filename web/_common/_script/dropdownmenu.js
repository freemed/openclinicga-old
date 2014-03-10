var changeInputColor = function(){
  // fonction to change inputs color //
  var tabInput = document.getElementsByTagName('input');
  //var tabSelect = document.getElementsByTagName('select');
  var tabTextArea = document.getElementsByTagName('textarea');
  var tabCheck = new Array();
  for(i = 0; i < tabInput.length; i++){
    if((tabInput[i].type.toLowerCase() == "text" || tabInput[i].type.toLowerCase() == "password") && tabInput[i].className != "combo"){
      tabCheck.push(tabInput[i]);
    }
  }
  for(i = 0; i<tabTextArea.length; i++){
    if(tabTextArea[i].type.include("textarea")){
      tabCheck.push(tabTextArea[i]);
    }
  }
  for(j = 0; j<tabCheck.length; j++){
    Event.observe(tabCheck[j], 'focus', function(event){
      try{
        if(event.target.hasClassName("bold")){
          event.target.removeClassName("bold");
          event.target.addClassName("selected_bold");
        }
        else{
          if(!event.target.hasClassName("bold")){
            event.target.addClassName("selected");
          }
        }
      }
      catch(e){
     	// empty
      }
    });
    
    Event.observe(tabCheck[j], 'blur', function(event){
      try{
        if(event.target.hasClassName("selected_bold")){
          event.target.removeClassName("selected_bold");
          event.target.addClassName("bold");
        }
        else{
          if(!event.target.hasClassName("text")){
            event.target.addClassName("text");
          }
          if(event.target.hasClassName("selected")){
            event.target.removeClassName("selected");  
          }
        }
      }
      catch(e){
        // empty
      }
    });
  }
}
function MM_reloadPage(init){  //reloads the window if Nav4 resized
  if(init == true) with (navigator){
    if((appName == "Netscape") && (parseInt(appVersion) == 4)){
      document.MM_pgW = innerWidth;
      document.MM_pgH = innerHeight;
      onresize = MM_reloadPage;
    }
  }
  else if(innerWidth != document.MM_pgW || innerHeight != document.MM_pgH) location.reload();
}

MM_reloadPage(true);
function MM_findObj(n, d){ //v4.0
  var p,i,x;
  if(!d) d = document;
  if((p = n.indexOf("?")) > 0 && parent.frames.length){
    d = parent.frames[n.substring(p+1)].document;
    n = n.substring(0, p);
  }
  if(!(x = d[n]) && d.all) x = d.all[n];
  for(i = 0; !x && i < d.forms.length; i++) x = d.forms[i][n];
  for(i = 0; !x && d.layers && i < d.layers.length; i++) x = MM_findObj(n, d.layers[i].document);
  if(!x && document.getElementById) x = document.getElementById(n);
  return x;
}
var bShowMenu = false;
function setShowMenu(oObject){
  if(bShowMenu){
    bShowMenu = false;
    oObject.style.visibility = "hidden";
  }
  else{
    bShowMenu = true;
    oObject.style.visibility = "visible";
    var sfSelect = document.getElementsByTagName("SELECT");
    for(var i = 0; i < sfSelect.length; i++){
      sfSelect[i].style.visibility = "hidden";
    }
  }
}
function resizeAllTextareas(maxRows){
  var elems = document.getElementsByTagName("textarea");
  for(i=0; i<elems.length; i++){
    resizeTextarea(elems[i], maxRows);
  }
}
function resizeTextarea(ta, maxRows){
  validateText(ta);
  var string = ta.value;
  lines = ta.value.split('\n');
  counter = lines.length;
  var addLine = true;
  for(var i = 0; i < lines.length; i++){
    if(lines[i].length >= ta.cols){
      counter += Math.floor(lines[i].length / ta.cols);
      if(addLine){
        counter++;
        addLine = false;
      }
    }
  }
  if((addLine) && (ta.rows.length == 0)){
    counter++;
  }
  if(counter != ta.rows){
    if(counter <= maxRows){
      ta.rows = counter;
    }
    else{
      ta.rows = maxRows;
    }
  }
}
function limitChars(textFieldObj, maxCharsAllowed){
  if(textFieldObj.value.length > maxCharsAllowed){
    textFieldObj.value = textFieldObj.value.substring(0, maxCharsAllowed);
  }
}
function uncheckRadio(radioObj){
  // uncheck all radios in the same group. used with onDblClick
  var radioes = document.getElementsByName(radioObj.name);
  for(i = 0; i < radioes.length; i++){
    if(radioes[i].checked){
      radioes[i].checked = false;
    }
  }
}
function showMenu(){
  if(menu){
    menu.showMenu();
  }
}
function hideMenu(){
  if(menu){
    menu.hideMenu();
  }
}
var setWaitMsg = function(div_id){
  $(div_id).update("<div class='wait'>&nbsp;</div>");
  $(div_id).style.display = "block";
}

//****** SET ENTER KEY COMPATIBLE WITH FIREFOX *******//
var gk = window.Event ? 1 : 0;
function enterEvent(e, desKey){
  var key = gk ? e.which : window.event.keyCode;
  //for compatibility FF IE
  if(key==desKey) return true;
  else            return false;
}

function centerPopup(element){
  var height = $(element).offsetHeight;
  var width = $(element).offsetWidth;
  myParent = $(element).parentNode;
  var pHeight = myParent.offsetHeight;
  var pWidth = myParent.offsetWidth;
  var sTop = myParent.scrollTop;
  var sLeft = myParent.scrollLeft;
  var posY = (pHeight / 2) - (height / 2)+sTop;
  var posX = (pWidth / 2) - (width / 2)+sLeft;
  $(element).style.top = posY+"px";
  $(element).style.left = posX+"px";
}