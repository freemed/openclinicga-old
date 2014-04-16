function submit_form(_form, _action){
  _form.action = _action;
  _form.method = 'POST';
  _form.submit();
}

function setValue(element,newValue){
  document.getElementsByName(element)[0].value = newValue;
}



