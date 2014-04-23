var gk = window.Event ? 1 : 0;

function enterEvent(e,desKey){
  var key = gk ? Event.which : window.event.keyCode;
  if(key==desKey) return true;
  else            return false;
}

function escBackSpace(){
  if(window.event && enterEvent(event,8)){
	window.event.keyCode = 123; // F12
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