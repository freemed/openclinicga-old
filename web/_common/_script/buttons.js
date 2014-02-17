var bSaveHasNotChanged = true;
var sFormBeginStatus = myForm.innerHTML;
var dropDownChecked = false;

function setSaveButton(evt){
  if(window.myButton){
	var clickedElement = getClickedElement(evt);
	
	try{
	  // Any input-element that needs to be saved has a name. Exclude buttons
	  if(clickedElement.type!=null && clickedElement.type!="button" && 
	     clickedElement.name!=null && clickedElement.name!="PrintLanguage"){
	    bSaveHasNotChanged = false;
	    dropDownChecked = false;
	  }
	}
	catch(err){
	  /* 'attribute type does not exist' */	
	}	
  }
}