function pageResize(){
  if(ie){
    var rcts = document.getElementById("Juist").getClientRects();
    var headerH = rcts[0].top;
    document.getElementById("Juist").style.height = document.body.clientHeight - headerH;
    if(hasScrollbar()){
      document.getElementById("holder").style.width = document.body.clientWidth - 1;
      document.getElementById("Juist").style.width = document.body.clientWidth - 2;
      document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth - 17;
    }
    else{
      document.getElementById("holder").style.width = document.body.clientWidth - 1;
      document.getElementById("Juist").style.width = document.body.clientWidth - 2;
      document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth;
    }
  }
  else{
    var divHeight = document.getElementById("body").offsetHeight - (document.getElementById("menu").offsetHeight+document.getElementById("header").offsetHeight+5);
    document.getElementById("Juist").style.height = divHeight+"px";
  }
    
  resizeSearchFields();
}

function resizeAllTextareas(maxRows){
  var elems = document.getElementsByTagName("textarea");
  for(var i=0; i<elems.length; i++){
    resizeTextarea(elems[i],maxRows);
  }
}

function resizeTextarea(ta,maxRows){
  if(ta.innerHTML.length > 0){
    if(ta.style.visibility=="hidden"){
      ta.style.visibility = "block";
    }
  }

  var string = trim(ta.value);
  var lines = ta.value.split("\n");
  var counter = 0;
  
  for(var i=0; i<lines.length; i++){
    if(lines[i].length >= ta.cols){
      counter+= Math.ceil(lines[i].length/ta.cols);
    }
  }
  counter+= lines.length;

  if(counter > ta.rows){
    if(counter <= maxRows){
      ta.rows = counter;
    }
    else{
      ta.rows = maxRows;
    }
  }
}

function checkDropdown(evt){
  if(!dropDownChecked){
    if(window.myButton){
      if(ns6){
        lastEvent = evt;
        if(lastEvent.target.id.indexOf("menu") > -1 || lastEvent.target.id.indexOf("ddIcon") > -1){
          if(!bSaveHasNotChanged){
            dropDownChecked = true;
            if(checkSaveButton()){
              lastEvent.target.click();
            }
          }
        }
      }
      else{
        lastEvent = window.event;
        if(lastEvent.srcElement.id.indexOf("menu") > -1 || lastEvent.srcElement.id.indexOf("ddIcon") > -1){
          if(!bSaveHasNotChanged){
            dropDownChecked = true;
            if(checkSaveButton()){
              lastEvent.srcElement.click();
            }
          }
        }
      }
    }
  }
  else{
    if(ns6){
      lastEvent = evt;
      lastEvent.target.click;
    }
    else{
      lastEvent = window.event;
      lastEvent.srcElement.click();
    }
  }
}
  
function changeInputColor(){
  var tabInput = document.getElementsByTagName("input");
  var tabTextArea = document.getElementsByTagName("textarea");
  var tabCheck = new Array();
   
  for(i=0; i<tabInput.length; i++){
    if((tabInput[i].type.toLowerCase()=="text" || tabInput[i].type.toLowerCase()=="password") && tabInput[i].className!="combo"){
      tabCheck.push(tabInput[i]);
    }
  }
  for(i=0; i<tabTextArea.length; i++){
    if(tabTextArea[i].type.include("textarea")){
      tabCheck.push(tabTextArea[i]);
    }
  }
  for(j=0; j<tabCheck.length; j++){
    Event.observe(tabCheck[j],"focus",function(event){
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
    
    Event.observe(tabCheck[j],"blur",function(event){
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