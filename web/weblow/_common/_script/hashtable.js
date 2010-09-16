/**

                    Contructor(s):
                     Hashtable()
                              Creates a new, empty hashtable

                    Method(s):
                     void clear()
                              Clears this hashtable so that it contains no keys.
                     boolean containsKey(String key)
                              Tests if the specified object is a key in this hashtable.
                     boolean containsValue(Object value)
                              Returns true if this Hashtable maps one or more keys to this value.
                     Object get(String key)
                              Returns the value to which the specified key is mapped in this hashtable.
                     boolean isEmpty()
                              Tests if this hashtable maps no keys to values.
                     Array keys()
                              Returns an array of the keys in this hashtable.
                     void put(String key, Object value)
                              Maps the specified key to the specified value in this hashtable. A NullPointerException is thrown is the key or value is null.
                     Object remove(String key)
                              Removes the key (and its corresponding value) from this hashtable. Returns the value of the key that was removed
                     int size()
                              Returns the number of keys in this hashtable.
                     String toString()
                              Returns a string representation of this Hashtable object in the form of a set of entries, enclosed in braces and separated by the ASCII characters ", " (comma and space).
                     Array values()
                              Returns a array view of the values contained in this Hashtable.
                     Array entrySet()
                              Returns a reference to the internal array that stores the data. The Set is backed by the Hashtable, so changes to the Hashtable are reflected in the Set, and vice-versa.

                */
                function Hashtable(){
                    this.hashtable = new Array();
                }

                /* privileged functions */

                Hashtable.prototype.clear = function(){
                    this.hashtable = new Array();
                }
                Hashtable.prototype.containsKey = function(key){
                    var exists = false;
                    for (var i in this.hashtable) {
                        if (i == key && this.hashtable[i] != null) {
                            exists = true;
                            break;
                        }
                    }
                    return exists;
                }
                Hashtable.prototype.containsValue = function(value){
                    var contains = false;
                    if (value != null) {
                        for (var i in this.hashtable) {
                            if (this.hashtable[i] == value) {
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
                    for (var i in this.hashtable) {
                        if (this.hashtable[i] != null)
                            keys.push(i);
                    }
                    return keys;
                }
                Hashtable.prototype.put = function(key, value){
                    if (key == null || value == null) {
                        throw "NullPointerException {" + key + "},{" + value + "}";
                    }else{
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
                    for (var i in this.hashtable) {
                        if (this.hashtable[i] != null)
                            size ++;
                    }
                    return size;
                }
                Hashtable.prototype.toString = function(){
                    var result = "";
                    for (var i in this.hashtable)
                    {
                        if (this.hashtable[i] != null)
                            result += "{" + i + "},{" + this.hashtable[i] + "}\n";
                    }
                    return result;
                }
                Hashtable.prototype.values = function(){
                    var values = new Array();
                    for (var i in this.hashtable) {
                        if (this.hashtable[i] != null)
                            values.push(this.hashtable[i]);
                    }
                    return values;
                }
                Hashtable.prototype.entrySet = function(){
                    return this.hashtable;
                }
