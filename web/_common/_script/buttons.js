var dropDownChecked = false;
var sFormBeginStatus = getFormData();

function getFormData(){
  if(!myForm) return "";
  var formValues = "";

  var elems = myForm.getElementsByTagName("input");
  for(var i=0; i<elems.length; i++){
    if(elems[i].type=="radio" || elems[i].type=="checkbox"){
      if(elems[i].checked){
        formValues+= elems[i].value;
      }
    }
    else{
      if(elems[i].type!="button"){
        formValues+= elems[i].value;
      }
    }
  }

  elems = myForm.getElementsByTagName("select");
  for(var i=0; i<elems.length; i++){
    formValues+= elems[i].value;
  }

  elems = myForm.getElementsByTagName("textarea");
  for(var i=0; i<elems.length; i++){
    formValues+= elems[i].innerHTML;
  }

  return formValues.replace(/\s+/,"");
}

function setSaveButton(evt){
  // empty
}
