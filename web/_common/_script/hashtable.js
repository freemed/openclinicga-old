function Hashtable(){
  this.hashtable = new Array();
}

/* privileged functions */
Hashtable.prototype.clear = function(){
  this.hashtable = new Array();
}
Hashtable.prototype.containsKey = function(key){
  var exists = false;
  for(var i in this.hashtable){
    if(i==key && this.hashtable[i] != null){
      exists = true;
      break;
    }
  }
  return exists;
}
Hashtable.prototype.containsValue = function(value){
  var contains = false;
  if(value!=null){
    for(var i in this.hashtable){
      if(this.hashtable[i] == value){
        contains = true;
        break;
      }
    }
  }
  return contains;
}
Hashtable.prototype.get = function(key){
  return this.hashtable[key];
}
Hashtable.prototype.isEmpty = function(){
  return (parseInt(this.size()) == 0) ? true : false;
}
Hashtable.prototype.keys = function(){
  var keys = new Array();
  for(var i in this.hashtable){
    if (this.hashtable[i]!=null) keys.push(i);
  }
  return keys;
}
Hashtable.prototype.put = function(key, value){
  if(key == null || value == null){
    throw "NullPointerException {"+key+"},{"+value+"}";
  }
  else{
    this.hashtable[key] = value;
  }
}
Hashtable.prototype.remove = function(key){
  var rtn = this.hashtable[key];
  this.hashtable[key] = null;
  return rtn;
}
Hashtable.prototype.size = function(){
  var size = 0;
  for(var i in this.hashtable){
    if(this.hashtable[i]!=null) size ++;
  }
  return size;
}
Hashtable.prototype.toString = function(){
  var result = "";
  for(var i in this.hashtable){
    if(this.hashtable[i]!=null)
      result+= "{"+i+"},{"+this.hashtable[i]+"}\n";
  }
  return result;
}
Hashtable.prototype.values = function(){
  var values = new Array();
  for(var i in this.hashtable){
    if(this.hashtable[i]!=null) values.push(this.hashtable[i]);
  }
  return values;
}
Hashtable.prototype.entrySet = function(){
  return this.hashtable;
}