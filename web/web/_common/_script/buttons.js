var bSaveHasNotChanged = true;
var sFormBeginStatus = myForm.innerHTML;
var dropDownChecked = false;

function setSaveButton(evt){

  if(window.myButton){
	var clickedElement = getClickedElement(evt);
    // Any input-element that needs to be saved has a name.
    // Exclude buttons (to-do : except those that change an input-value) and the printlanguage-selector
    if(clickedElement.type && clickedElement.type!="button" && (clickedElement.name!=null && clickedElement.name!="PrintLanguage")){
      bSaveHasNotChanged = false;
      dropDownChecked = false;
    }
  }
}