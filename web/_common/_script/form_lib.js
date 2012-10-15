function submit_form(_form, _action) {

  //alert('submit_form - form.name = ' + _form.name);
  //alert('submit_form - action = '+ _action);
  _form.action = _action;
  _form.method = 'POST';
  _form.submit();

}

function setValue(element, newValue) {

    document.getElementsByName(element)[0].value = newValue;
}



