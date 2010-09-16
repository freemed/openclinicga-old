function validEmailAddress(emailStr){
  var emailPat = /^(.+)@(.+)$/
  var specialChars = "\\(\\)<>@,;:\\\\\\\"\\.\\[\\]"
  var validChars = "\[^\\s" + specialChars + "\]"
  var quotedUser = "(\"[^\"]*\")"
  var ipDomainPat = /^\[(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\]$/
  var atom = validChars + '+';
  var word = "(" + atom + "|" + quotedUser + ")";
  var userPat = new RegExp("^" + word + "(\\." + word + ")*$");
  var domainPat = new RegExp("^" + atom + "(\\." + atom +")*$");

  // figure out if the supplied address is valid
  var matchArray = emailStr.match(emailPat);
  if(matchArray==null){
   	return false;
  }

  var user = matchArray[1];
  var domain = matchArray[2];

  // See if "user" is valid
  if(user.match(userPat)==null){
    return false;
  }

  var IPArray = domain.match(ipDomainPat);
  if(IPArray!=null){
    for(var i=1; i<=4; i++){
	  if(IPArray[i]>255){
		return false;
	  }
    }
    return true;
  }

  // Domain is symbolic name
  var domainArray = domain.match(domainPat);
  if(domainArray==null){
    return false;
  }

  /*
   domain name seems valid, but now make sure that it ends in a
   three-letter word (like com, edu, gov) or a two-letter word,
   representing country (uk, nl), and that there's a hostname preceding
   the domain or country.
  */

  var atomPat = new RegExp(atom,"g");
  var domArr = domain.match(atomPat);
  var len = domArr.length;

  if(domArr[domArr.length-1].length<2 || domArr[domArr.length-1].length>3){
    return false;
  }

  // Make sure there's a host name preceding the domain.
  if(len<2){
    return false;
  }

  return true;
}