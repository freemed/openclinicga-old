/**
 * This source file is subject to version 2.1 of the GNU Lesser
 * General Public License (LPGL), found in the file LICENSE that is
 * included with this package, and is also available at http://www.gnu.org/copyleft/lesser.html.
 * @package     Javascript
 * @author      Dieter Raber <dieter@dieterraber.net>
 * @copyright   2004-12-27
 * @version     1.0
 * @license     http://www.gnu.org/copyleft/lesser.html
 */

/**
 * hex2rgb
 * Convert hexadecimal color triplets to RGB
 * Expects an hexadecimal color triplet (case insensitive)
 * Returns an array containing the decimal values for r, g and b.
 *
 * example:
 *   test = 'ff0033'
 *   test.hex2rgb() // returns (255,00,51)
 */
String.prototype.hex2rgb = function(){
  var red, green, blue;
  var triplet = this.toLowerCase().replace(/#/,'');
  var rgbArr = new Array();

  if(triplet.length==6){
    rgbArr[0] = parseInt(triplet.substr(0,2),16)
    rgbArr[1] = parseInt(triplet.substr(2,2),16)
    rgbArr[2] = parseInt(triplet.substr(4,2),16)
    return rgbArr;
  }
  else if(triplet.length==3){
    rgbArr[0] = parseInt((triplet.substr(0,1)+triplet.substr(0,1)),16);
    rgbArr[1] = parseInt((triplet.substr(1,1)+triplet.substr(1,1)),16);
    rgbArr[2] = parseInt((triplet.substr(2,2)+triplet.substr(2,2)),16);
    return rgbArr;
  }
  else{
    throw triplet + ' is not a valid color triplet.';
  }
}

/**
 * htmlEntities : Convert all applicable characters to HTML entities
 * example:
 *   test = 'äöü'
 *   test.htmlEntities() // returns '&auml;&ouml;&uuml;'
 */ 
 var Base64 = {		 
	// private property
	_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
 
	// public method for encoding
	encode : function(input){
		var output = "";
		var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = Base64._utf8_encode(input); 
		while(i < input.length){ 
			chr1 = input.charCodeAt(i++);
			chr2 = input.charCodeAt(i++);
			chr3 = input.charCodeAt(i++);
 
			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;
 
			if(isNaN(chr2)) enc3 = enc4 = 64;
			else if(isNaN(chr3)) enc4 = 64;
 
			output = output +
			this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2)+
			this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4); 
		}
 
		return output;
	},
 
	// public method for decoding
	decode : function (input){
		var output = "";
		var chr1, chr2, chr3;
		var enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = input.replace(/[^A-Za-z0-9\+\/\=]/g, ""); 
		while(i < input.length){ 
			enc1 = this._keyStr.indexOf(input.charAt(i++));
			enc2 = this._keyStr.indexOf(input.charAt(i++));
			enc3 = this._keyStr.indexOf(input.charAt(i++));
			enc4 = this._keyStr.indexOf(input.charAt(i++));
 
			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;
 
			output+= String.fromCharCode(chr1);
 
			if(enc3 != 64){
				output+= String.fromCharCode(chr2);
			}
			if(enc4 != 64){
				output+= String.fromCharCode(chr3);
			}
 
		}
 
		output = Base64._utf8_decode(output); 
		return output; 
	},
 
	// private method for UTF-8 encoding
	_utf8_encode : function (string){
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";
 
		for(var n=0; n<string.length; n++){ 
			var c = string.charCodeAt(n);
 
			if(c < 128){
				utftext+= String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)){
				utftext+= String.fromCharCode((c >> 6) | 192);
				utftext+= String.fromCharCode((c & 63) | 128);
			}
			else{
				utftext+= String.fromCharCode((c >> 12) | 224);
				utftext+= String.fromCharCode(((c >> 6) & 63) | 128);
				utftext+= String.fromCharCode((c & 63) | 128);
			} 
		}
 
		return utftext;
	},
 
	// private method for UTF-8 decoding
	_utf8_decode : function (utftext){
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;
 
		while(i< utftext.length){ 
			c = utftext.charCodeAt(i);
 
			if(c < 128){
				string += String.fromCharCode(c);
				i++;
			}
			else if((c > 191) && (c < 224)){
				c2 = utftext.charCodeAt(i+1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i+= 2;
			}
			else{
				c2 = utftext.charCodeAt(i+1);
				c3 = utftext.charCodeAt(i+2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i+= 3;
			} 
		}
 
		return string;
	} 
}	
 
String.prototype.htmlEntities = function(){
  var chars = new Array ('&','à','á','â','ã','ä','å','æ','ç','è','é',
                         'ê','ë','ì','í','î','ï','ð','ñ','ò','ó','ô',
                         'õ','ö','ø','ù','ú','û','ü','ý','þ','ÿ','À',
                         'Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë',
                         'Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ','Ö',
                         'Ø','Ù','Ú','Û','Ü','Ý','Þ','€','\"','ß','<',
                         '>','¢','£','¤','¥','¦','§','¨','©','ª','«',
                         '¬','­','®','¯','°','±','²','³','´','µ','¶',
                         '·','¸','¹','º','»','¼','½','¾');

  var entities = new Array ('amp','agrave','aacute','acirc','atilde','auml','aring',
                            'aelig','ccedil','egrave','eacute','ecirc','euml','igrave',
                            'iacute','icirc','iuml','eth','ntilde','ograve','oacute',
                            'ocirc','otilde','ouml','oslash','ugrave','uacute','ucirc',
                            'uuml','yacute','thorn','yuml','Agrave','Aacute','Acirc',
                            'Atilde','Auml','Aring','AElig','Ccedil','Egrave','Eacute',
                            'Ecirc','Euml','Igrave','Iacute','Icirc','Iuml','ETH','Ntilde',
                            'Ograve','Oacute','Ocirc','Otilde','Ouml','Oslash','Ugrave',
                            'Uacute','Ucirc','Uuml','Yacute','THORN','euro','quot','szlig',
                            'lt','gt','cent','pound','curren','yen','brvbar','sect','uml',
                            'copy','ordf','laquo','not','shy','reg','macr','deg','plusmn',
                            'sup2','sup3','acute','micro','para','middot','cedil','sup1',
                            'ordm','raquo','frac14','frac12','frac34');

  var newString = this;
  for(var i=0; i<entities.length; i++){
    myRegExp = new RegExp();
    myRegExp.compile('&'+entities[i]+';','g')
    newString = newString.replace (myRegExp, chars[i]);
  }  
  return newString;
}

/**
 * unhtmlEntities : Convert all applicable HTML entities to characters
 * example:
 *   test = '&auml;&ouml;&uuml;'
 *   test.htmlEntities() // returns 'äöü'
 */
String.prototype.unhtmlEntities = function(){
  var chars = new Array ('&','à','á','â','ã','ä','å','æ','ç','è','é',
                         'ê','ë','ì','í','î','ï','ð','ñ','ò','ó','ô',
                         'õ','ö','ø','ù','ú','û','ü','ý','þ','ÿ','À',
                         'Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë',
                         'Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ','Ö',
                         'Ø','Ù','Ú','Û','Ü','Ý','Þ','€','\"','ß','<',
                         '>','¢','£','¤','¥','¦','§','¨','©','ª','«',
                         '¬','­','®','¯','°','±','²','³','´','µ','¶',
                         '·','¸','¹','º','»','¼','½','¾');

  var entities = new Array ('amp','agrave','aacute','acirc','atilde','auml','aring',
                            'aelig','ccedil','egrave','eacute','ecirc','euml','igrave',
                            'iacute','icirc','iuml','eth','ntilde','ograve','oacute',
                            'ocirc','otilde','ouml','oslash','ugrave','uacute','ucirc',
                            'uuml','yacute','thorn','yuml','Agrave','Aacute','Acirc',
                            'Atilde','Auml','Aring','AElig','Ccedil','Egrave','Eacute',
                            'Ecirc','Euml','Igrave','Iacute','Icirc','Iuml','ETH','Ntilde',
                            'Ograve','Oacute','Ocirc','Otilde','Ouml','Oslash','Ugrave',
                            'Uacute','Ucirc','Uuml','Yacute','THORN','euro','quot','szlig',
                            'lt','gt','cent','pound','curren','yen','brvbar','sect','uml',
                            'copy','ordf','laquo','not','shy','reg','macr','deg','plusmn',
                            'sup2','sup3','acute','micro','para','middot','cedil','sup1',
                            'ordm','raquo','frac14','frac12','frac34');

  var newString = this;
  for(var i=0; i<entities.length; i++){
    newString = replaceAll(newString,"&"+entities[i]+";",chars[i]);
  }
  return newString;
}

/**
 * numericEntities : Convert all applicable characters to numeric entities
 * example:
 *   test = 'äöü'
 *   test.numericEntities() //returns '&#228;&#246;&#252;'
 */
String.prototype.numericEntities = function(){
  var i;
  var chars = new Array ('&','à','á','â','ã','ä','å','æ','ç','è','é',
                         'ê','ë','ì','í','î','ï','ð','ñ','ò','ó','ô',
                         'õ','ö','ø','ù','ú','û','ü','ý','þ','ÿ','À',
                         'Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë',
                         'Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ','Ö',
                         'Ø','Ù','Ú','Û','Ü','Ý','Þ','€','\"','ß','<',
                         '>','¢','£','¤','¥','¦','§','¨','©','ª','«',
                         '¬','­','®','¯','°','±','²','³','´','µ','¶',
                         '·','¸','¹','º','»','¼','½','¾');

  var entities = new Array()
  for(i=0; i<chars.length; i++){
    entities[i] = chars[i].charCodeAt(0);
  }

  var newString = this;
  for(i=0; i<chars.length; i++){
    newString = replaceAll(newString,chars[i],"&#"+entities[i]+";");
  }
  return newString;
}


/**
 * trim : Strip whitespace from the beginning and end of a string
 * example:
 *   test = '\nsomestring\n\t\0'
 *   test.trim()  //returns 'somestring'
 */
String.prototype.trim = function(){
  return this.replace(/^\s*([^ ]*)\s*$/, "$1");
}


/**
 * ucfirst
 *
 * Returns a string with the first character capitalized,
 * if that character is alphabetic.
 *
 * example:
 *   test = 'john'
 *   test.ucfirst() //returns 'John'
 */
String.prototype.ucfirst = function(){
  var firstLetter = this.charCodeAt(0);

  if((firstLetter >= 97 && firstLetter <= 122)
     || (firstLetter >= 224 && firstLetter <= 246)
     || (firstLetter >= 249 && firstLetter <= 254)){
    firstLetter = firstLetter - 32;
  }

  return String.fromCharCode(firstLetter) + this.substr(1,this.length -1)
}

/**
 * strPad : returns the input string padded on the left, the right, or both sides
 * examples:
 *  var input = 'foo';
 *  input.strPad(9);                      // returns "foo      "
 *  input.strPad(9, "*+", STR_PAD_LEFT);  // returns "*+*+*+foo"
 *  input.strPad(9, "*", STR_PAD_BOTH);   // returns "***foo***"
 *  input.strPad(9 , "*********");        // returns "foo******"
 */
var STR_PAD_LEFT  = 0;
var STR_PAD_RIGHT = 1;
var STR_PAD_BOTH  = 2;

String.prototype.strPad = function(pad_length, pad_string, pad_type){
  var num_pad_chars = pad_length - this.length;
  var result = '';
  var pad_str_val = ' ';
  var pad_str_len = 1;
  var pad_type_val = STR_PAD_RIGHT;
  var i = 0;
  var left_pad = 0;
  var right_pad = 0;
  var error = false;
  var error_msg = '';
  var output = this;

  if(arguments.length < 2 || arguments.length > 4){
    error = true;
    error_msg = "Wrong parameter count.";
  }
  else if(isNaN(arguments[0])==true){
    error = true;
    error_msg = "Padding length must be an integer.";
  }

  if(arguments.length > 2){
    if(pad_string.length==0){
      error = true;
      error_msg = "Padding string cannot be empty.";
    }
    pad_str_val = pad_string;
    pad_str_len = pad_string.length;

    if(arguments.length > 3){
      pad_type_val = pad_type;
      if(pad_type_val < STR_PAD_LEFT || pad_type_val > STR_PAD_BOTH){
        error = true;
        error_msg = "Padding type has to be STR_PAD_LEFT, STR_PAD_RIGHT, or STR_PAD_BOTH."
      }
    }
  }

  if(error) throw error_msg;

  if(num_pad_chars > 0 && !error){
    switch (pad_type_val){
      case STR_PAD_RIGHT:
        left_pad  = 0;
        right_pad = num_pad_chars;
        break;

      case STR_PAD_LEFT:
        left_pad  = num_pad_chars;
        right_pad = 0;
        break;

      case STR_PAD_BOTH:
        left_pad  = Math.floor(num_pad_chars / 2);
        right_pad = num_pad_chars - left_pad;
        break;
    }

    for(i=0; i<left_pad; i++){
      output = pad_str_val.substr(0,num_pad_chars) + output;
    }

    for(i=0; i<right_pad; i++){
      output+= pad_str_val.substr(0,num_pad_chars);
    }
  }

  return output;
}