/*
Copyright DHTMLX LTD. http://www.dhtmlx.com
You allowed to use this component or parts of it under GPL terms
To use it on other terms or get Professional edition of the component please contact us at sales@dhtmlx.com
*/
dhtmlx=function(obj){for (var a in obj)dhtmlx[a]=obj[a];return dhtmlx;};dhtmlx.extend_api=function(name,map,ext){var t = window[name];if (!t)return;window[name]=function(obj){if (obj && typeof obj == "object" && !obj.tagName){var that = t.apply(this,(map._init?map._init(obj):arguments));for (var a in dhtmlx)if (map[a])this[map[a]](dhtmlx[a]);for (var a in obj){if (map[a])this[map[a]](obj[a]);else if (a.indexOf("on")==0){this.attachEvent(a,obj[a]);}
 }
 }else
 var that = t.apply(this,arguments);if (map._patch)map._patch(this);return that||this;};window[name].prototype=t.prototype;if (ext)dhtmlXHeir(window[name].prototype,ext);};dhtmlxAjax={get:function(url,callback){var t=new dtmlXMLLoaderObject(true);t.async=(arguments.length<3);t.waitCall=callback;t.loadXML(url)
 return t;},
 post:function(url,post,callback){var t=new dtmlXMLLoaderObject(true);t.async=(arguments.length<4);t.waitCall=callback;t.loadXML(url,true,post)
 return t;},
 getSync:function(url){return this.get(url,null,true)
 },
 postSync:function(url,post){return this.post(url,post,null,true);}
}
function dtmlXMLLoaderObject(funcObject, dhtmlObject, async, rSeed){this.xmlDoc="";if (typeof (async)!= "undefined")
 this.async=async;else
 this.async=true;this.onloadAction=funcObject||null;this.mainObject=dhtmlObject||null;this.waitCall=null;this.rSeed=rSeed||false;return this;};dtmlXMLLoaderObject.count = 0;dtmlXMLLoaderObject.prototype.waitLoadFunction=function(dhtmlObject){var once = true;this.check=function (){if ((dhtmlObject)&&(dhtmlObject.onloadAction != null)){if ((!dhtmlObject.xmlDoc.readyState)||(dhtmlObject.xmlDoc.readyState == 4)){if (!once)return;once=false;dtmlXMLLoaderObject.count++;if (typeof dhtmlObject.onloadAction == "function")dhtmlObject.onloadAction(dhtmlObject.mainObject, null, null, null, dhtmlObject);if (dhtmlObject.waitCall){dhtmlObject.waitCall.call(this,dhtmlObject);dhtmlObject.waitCall=null;}
 }
 }
 };return this.check;};dtmlXMLLoaderObject.prototype.getXMLTopNode=function(tagName, oldObj){if (this.xmlDoc.responseXML){var temp = this.xmlDoc.responseXML.getElementsByTagName(tagName);if(temp.length==0 && tagName.indexOf(":")!=-1)
 var temp = this.xmlDoc.responseXML.getElementsByTagName((tagName.split(":"))[1]);var z = temp[0];}else
 var z = this.xmlDoc.documentElement;if (z){this._retry=false;return z;}
 if (!this._retry&&_isIE){this._retry=true;var oldObj = this.xmlDoc;this.loadXMLString(this.xmlDoc.responseText.replace(/^[\s]+/,""), true);return this.getXMLTopNode(tagName, oldObj);}
 dhtmlxError.throwError("LoadXML", "Incorrect XML", [
 (oldObj||this.xmlDoc),
 this.mainObject
 ]);return document.createElement("DIV");};dtmlXMLLoaderObject.prototype.loadXMLString=function(xmlString, silent){if (!_isIE){var parser = new DOMParser();this.xmlDoc=parser.parseFromString(xmlString, "text/xml");}else {this.xmlDoc=new ActiveXObject("Microsoft.XMLDOM");this.xmlDoc.async=this.async;this.xmlDoc.onreadystatechange = function(){};this.xmlDoc["loadXM"+"L"](xmlString);}
 
 if (silent)return;if (this.onloadAction)this.onloadAction(this.mainObject, null, null, null, this);if (this.waitCall){this.waitCall();this.waitCall=null;}
}
dtmlXMLLoaderObject.prototype.loadXML=function(filePath, postMode, postVars, rpc){if (this.rSeed)filePath+=((filePath.indexOf("?") != -1) ? "&" : "?")+"a_dhx_rSeed="+(new Date()).valueOf();this.filePath=filePath;if ((!_isIE)&&(window.XMLHttpRequest))
 this.xmlDoc=new XMLHttpRequest();else {this.xmlDoc=new ActiveXObject("Microsoft.XMLHTTP");}
 if (this.async)this.xmlDoc.onreadystatechange=new this.waitLoadFunction(this);this.xmlDoc.open(postMode ? "POST" : "GET", filePath, this.async);if (rpc){this.xmlDoc.setRequestHeader("User-Agent", "dhtmlxRPC v0.1 ("+navigator.userAgent+")");this.xmlDoc.setRequestHeader("Content-type", "text/xml");}
 else if (postMode)this.xmlDoc.setRequestHeader('Content-type', (this.contenttype || 'application/x-www-form-urlencoded'));this.xmlDoc.setRequestHeader("X-Requested-With","XMLHttpRequest");this.xmlDoc.send(null||postVars);if (!this.async)(new this.waitLoadFunction(this))();};dtmlXMLLoaderObject.prototype.destructor=function(){this._filterXPath = null;this._getAllNamedChilds = null;this._retry = null;this.async = null;this.rSeed = null;this.filePath = null;this.onloadAction = null;this.mainObject = null;this.xmlDoc = null;this.doXPath = null;this.doXPathOpera = null;this.doXSLTransToObject = null;this.doXSLTransToString = null;this.loadXML = null;this.loadXMLString = null;this.doSerialization = null;this.xmlNodeToJSON = null;this.getXMLTopNode = null;this.setXSLParamValue = null;return null;}
dtmlXMLLoaderObject.prototype.xmlNodeToJSON = function(node){var t={};for (var i=0;i<node.attributes.length;i++)t[node.attributes[i].name]=node.attributes[i].value;t["_tagvalue"]=node.firstChild?node.firstChild.nodeValue:"";for (var i=0;i<node.childNodes.length;i++){var name=node.childNodes[i].tagName;if (name){if (!t[name])t[name]=[];t[name].push(this.xmlNodeToJSON(node.childNodes[i]));}
 }
 return t;}
function callerFunction(funcObject, dhtmlObject){this.handler=function(e){if (!e)e=window.event;funcObject(e, dhtmlObject);return true;};return this.handler;};function getAbsoluteLeft(htmlObject){return getOffset(htmlObject).left;}
function getAbsoluteTop(htmlObject){return getOffset(htmlObject).top;}
function getOffsetSum(elem) {var top=0, left=0;while(elem){top = top + parseInt(elem.offsetTop);left = left + parseInt(elem.offsetLeft);elem = elem.offsetParent;}
 return {top: top, left: left};}
function getOffsetRect(elem) {var box = elem.getBoundingClientRect();var body = document.body;var docElem = document.documentElement;var scrollTop = window.pageYOffset || docElem.scrollTop || body.scrollTop;var scrollLeft = window.pageXOffset || docElem.scrollLeft || body.scrollLeft;var clientTop = docElem.clientTop || body.clientTop || 0;var clientLeft = docElem.clientLeft || body.clientLeft || 0;var top = box.top + scrollTop - clientTop;var left = box.left + scrollLeft - clientLeft;return {top: Math.round(top), left: Math.round(left) };}
function getOffset(elem) {if (elem.getBoundingClientRect){return getOffsetRect(elem);}else {return getOffsetSum(elem);}
}
function convertStringToBoolean(inputString){if (typeof (inputString)== "string")
 inputString=inputString.toLowerCase();switch (inputString){case "1":
 case "true":
 case "yes":
 case "y":
 case 1:
 case true:
 return true;break;default: return false;}
}
function getUrlSymbol(str){if (str.indexOf("?")!= -1)
 return "&"
 else
 return "?"
}
function dhtmlDragAndDropObject(){if (window.dhtmlDragAndDrop)return window.dhtmlDragAndDrop;this.lastLanding=0;this.dragNode=0;this.dragStartNode=0;this.dragStartObject=0;this.tempDOMU=null;this.tempDOMM=null;this.waitDrag=0;window.dhtmlDragAndDrop=this;return this;};dhtmlDragAndDropObject.prototype.removeDraggableItem=function(htmlNode){htmlNode.onmousedown=null;htmlNode.dragStarter=null;htmlNode.dragLanding=null;}
dhtmlDragAndDropObject.prototype.addDraggableItem=function(htmlNode, dhtmlObject){htmlNode.onmousedown=this.preCreateDragCopy;htmlNode.dragStarter=dhtmlObject;this.addDragLanding(htmlNode, dhtmlObject);}
dhtmlDragAndDropObject.prototype.addDragLanding=function(htmlNode, dhtmlObject){htmlNode.dragLanding=dhtmlObject;}
dhtmlDragAndDropObject.prototype.preCreateDragCopy=function(e){if ((e||window.event)&& (e||event).button == 2)
 return;if (window.dhtmlDragAndDrop.waitDrag){window.dhtmlDragAndDrop.waitDrag=0;document.body.onmouseup=window.dhtmlDragAndDrop.tempDOMU;document.body.onmousemove=window.dhtmlDragAndDrop.tempDOMM;return false;}
 
 if (window.dhtmlDragAndDrop.dragNode)window.dhtmlDragAndDrop.stopDrag(e);window.dhtmlDragAndDrop.waitDrag=1;window.dhtmlDragAndDrop.tempDOMU=document.body.onmouseup;window.dhtmlDragAndDrop.tempDOMM=document.body.onmousemove;window.dhtmlDragAndDrop.dragStartNode=this;window.dhtmlDragAndDrop.dragStartObject=this.dragStarter;document.body.onmouseup=window.dhtmlDragAndDrop.preCreateDragCopy;document.body.onmousemove=window.dhtmlDragAndDrop.callDrag;window.dhtmlDragAndDrop.downtime = new Date().valueOf();if ((e)&&(e.preventDefault)){e.preventDefault();return false;}
 return false;};dhtmlDragAndDropObject.prototype.callDrag=function(e){if (!e)e=window.event;dragger=window.dhtmlDragAndDrop;if ((new Date()).valueOf()-dragger.downtime<100) return;if (!dragger.dragNode){if (dragger.waitDrag){dragger.dragNode=dragger.dragStartObject._createDragNode(dragger.dragStartNode, e);if (!dragger.dragNode)return dragger.stopDrag();dragger.dragNode.onselectstart=function(){return false;}
 dragger.gldragNode=dragger.dragNode;document.body.appendChild(dragger.dragNode);document.body.onmouseup=dragger.stopDrag;dragger.waitDrag=0;dragger.dragNode.pWindow=window;dragger.initFrameRoute();}
 else return dragger.stopDrag(e, true);}
 if (dragger.dragNode.parentNode != window.document.body && dragger.gldragNode){var grd = dragger.gldragNode;if (dragger.gldragNode.old)grd=dragger.gldragNode.old;grd.parentNode.removeChild(grd);var oldBody = dragger.dragNode.pWindow;if (grd.pWindow && grd.pWindow.dhtmlDragAndDrop.lastLanding)grd.pWindow.dhtmlDragAndDrop.lastLanding.dragLanding._dragOut(grd.pWindow.dhtmlDragAndDrop.lastLanding);if (_isIE){var div = document.createElement("Div");div.innerHTML=dragger.dragNode.outerHTML;dragger.dragNode=div.childNodes[0];}else
 dragger.dragNode=dragger.dragNode.cloneNode(true);dragger.dragNode.pWindow=window;dragger.gldragNode.old=dragger.dragNode;document.body.appendChild(dragger.dragNode);oldBody.dhtmlDragAndDrop.dragNode=dragger.dragNode;}
 dragger.dragNode.style.left=e.clientX+15+(dragger.fx
 ? dragger.fx*(-1)
 : 0)
 +(document.body.scrollLeft||document.documentElement.scrollLeft)+"px";dragger.dragNode.style.top=e.clientY+3+(dragger.fy
 ? dragger.fy*(-1)
 : 0)
 +(document.body.scrollTop||document.documentElement.scrollTop)+"px";if (!e.srcElement)var z = e.target;else
 z=e.srcElement;dragger.checkLanding(z, e);}
dhtmlDragAndDropObject.prototype.calculateFramePosition=function(n){if (window.name){var el = parent.frames[window.name].frameElement.offsetParent;var fx = 0;var fy = 0;while (el){fx+=el.offsetLeft;fy+=el.offsetTop;el=el.offsetParent;}
 if ((parent.dhtmlDragAndDrop)){var ls = parent.dhtmlDragAndDrop.calculateFramePosition(1);fx+=ls.split('_')[0]*1;fy+=ls.split('_')[1]*1;}
 if (n)return fx+"_"+fy;else
 this.fx=fx;this.fy=fy;}
 return "0_0";}
dhtmlDragAndDropObject.prototype.checkLanding=function(htmlObject, e){if ((htmlObject)&&(htmlObject.dragLanding)){if (this.lastLanding)this.lastLanding.dragLanding._dragOut(this.lastLanding);this.lastLanding=htmlObject;this.lastLanding=this.lastLanding.dragLanding._dragIn(this.lastLanding, this.dragStartNode, e.clientX,
 e.clientY, e);this.lastLanding_scr=(_isIE ? e.srcElement : e.target);}else {if ((htmlObject)&&(htmlObject.tagName != "BODY"))
 this.checkLanding(htmlObject.parentNode, e);else {if (this.lastLanding)this.lastLanding.dragLanding._dragOut(this.lastLanding, e.clientX, e.clientY, e);this.lastLanding=0;if (this._onNotFound)this._onNotFound();}
 }
}
dhtmlDragAndDropObject.prototype.stopDrag=function(e, mode){dragger=window.dhtmlDragAndDrop;if (!mode){dragger.stopFrameRoute();var temp = dragger.lastLanding;dragger.lastLanding=null;if (temp)temp.dragLanding._drag(dragger.dragStartNode, dragger.dragStartObject, temp, (_isIE
 ? event.srcElement
 : e.target));}
 dragger.lastLanding=null;if ((dragger.dragNode)&&(dragger.dragNode.parentNode == document.body))
 dragger.dragNode.parentNode.removeChild(dragger.dragNode);dragger.dragNode=0;dragger.gldragNode=0;dragger.fx=0;dragger.fy=0;dragger.dragStartNode=0;dragger.dragStartObject=0;document.body.onmouseup=dragger.tempDOMU;document.body.onmousemove=dragger.tempDOMM;dragger.tempDOMU=null;dragger.tempDOMM=null;dragger.waitDrag=0;}
dhtmlDragAndDropObject.prototype.stopFrameRoute=function(win){if (win)window.dhtmlDragAndDrop.stopDrag(1, 1);for (var i = 0;i < window.frames.length;i++){try{if ((window.frames[i] != win)&&(window.frames[i].dhtmlDragAndDrop))
 window.frames[i].dhtmlDragAndDrop.stopFrameRoute(window);}catch(e){}
 }
 try{if ((parent.dhtmlDragAndDrop)&&(parent != window)&&(parent != win))
 parent.dhtmlDragAndDrop.stopFrameRoute(window);}catch(e){}
}
dhtmlDragAndDropObject.prototype.initFrameRoute=function(win, mode){if (win){window.dhtmlDragAndDrop.preCreateDragCopy();window.dhtmlDragAndDrop.dragStartNode=win.dhtmlDragAndDrop.dragStartNode;window.dhtmlDragAndDrop.dragStartObject=win.dhtmlDragAndDrop.dragStartObject;window.dhtmlDragAndDrop.dragNode=win.dhtmlDragAndDrop.dragNode;window.dhtmlDragAndDrop.gldragNode=win.dhtmlDragAndDrop.dragNode;window.document.body.onmouseup=window.dhtmlDragAndDrop.stopDrag;window.waitDrag=0;if (((!_isIE)&&(mode))&&((!_isFF)||(_FFrv < 1.8)))
 window.dhtmlDragAndDrop.calculateFramePosition();}
 try{if ((parent.dhtmlDragAndDrop)&&(parent != window)&&(parent != win))
 parent.dhtmlDragAndDrop.initFrameRoute(window);}catch(e){}
 for (var i = 0;i < window.frames.length;i++){try{if ((window.frames[i] != win)&&(window.frames[i].dhtmlDragAndDrop))
 window.frames[i].dhtmlDragAndDrop.initFrameRoute(window, ((!win||mode) ? 1 : 0));}catch(e){}
 }
}
 _isFF = false;_isIE = false;_isOpera = false;_isKHTML = false;_isMacOS = false;_isChrome = false;_FFrv = false;_KHTMLrv = false;_OperaRv = false;if (navigator.userAgent.indexOf('Macintosh')!= -1)
 _isMacOS=true;if (navigator.userAgent.toLowerCase().indexOf('chrome')>-1)
 _isChrome=true;if ((navigator.userAgent.indexOf('Safari')!= -1)||(navigator.userAgent.indexOf('Konqueror') != -1)){_KHTMLrv = parseFloat(navigator.userAgent.substr(navigator.userAgent.indexOf('Safari')+7, 5));if (_KHTMLrv > 525){_isFF=true;_FFrv = 1.9;}else
 _isKHTML=true;}else if (navigator.userAgent.indexOf('Opera')!= -1){_isOpera=true;_OperaRv=parseFloat(navigator.userAgent.substr(navigator.userAgent.indexOf('Opera')+6, 3));}
else if (navigator.appName.indexOf("Microsoft")!= -1){_isIE=true;if ((navigator.appVersion.indexOf("MSIE 8.0")!= -1 || navigator.appVersion.indexOf("MSIE 9.0")!= -1 || navigator.appVersion.indexOf("MSIE 10.0")!= -1 ) && document.compatMode != "BackCompat"){_isIE=8;}
}else {_isFF=true;_FFrv = parseFloat(navigator.userAgent.split("rv:")[1])
}
dtmlXMLLoaderObject.prototype.doXPath=function(xpathExp, docObj, namespace, result_type){if (_isKHTML || (!_isIE && !window.XPathResult))
 return this.doXPathOpera(xpathExp, docObj);if (_isIE){if (!docObj)if (!this.xmlDoc.nodeName)docObj=this.xmlDoc.responseXML
 else
 docObj=this.xmlDoc;if (!docObj)dhtmlxError.throwError("LoadXML", "Incorrect XML", [
 (docObj||this.xmlDoc),
 this.mainObject
 ]);if (namespace != null)docObj.setProperty("SelectionNamespaces", "xmlns:xsl='"+namespace+"'");if (result_type == 'single'){return docObj.selectSingleNode(xpathExp);}
 else {return docObj.selectNodes(xpathExp)||new Array(0);}
 }else {var nodeObj = docObj;if (!docObj){if (!this.xmlDoc.nodeName){docObj=this.xmlDoc.responseXML
 }
 else {docObj=this.xmlDoc;}
 }
 if (!docObj)dhtmlxError.throwError("LoadXML", "Incorrect XML", [
 (docObj||this.xmlDoc),
 this.mainObject
 ]);if (docObj.nodeName.indexOf("document")!= -1){nodeObj=docObj;}
 else {nodeObj=docObj;docObj=docObj.ownerDocument;}
 var retType = XPathResult.ANY_TYPE;if (result_type == 'single')retType=XPathResult.FIRST_ORDERED_NODE_TYPE
 var rowsCol = new Array();var col = docObj.evaluate(xpathExp, nodeObj, function(pref){return namespace
 }, retType, null);if (retType == XPathResult.FIRST_ORDERED_NODE_TYPE){return col.singleNodeValue;}
 var thisColMemb = col.iterateNext();while (thisColMemb){rowsCol[rowsCol.length]=thisColMemb;thisColMemb=col.iterateNext();}
 return rowsCol;}
}
function _dhtmlxError(type, name, params){if (!this.catches)this.catches=new Array();return this;}
_dhtmlxError.prototype.catchError=function(type, func_name){this.catches[type]=func_name;}
_dhtmlxError.prototype.throwError=function(type, name, params){if (this.catches[type])return this.catches[type](type, name, params);if (this.catches["ALL"])return this.catches["ALL"](type, name, params);alert("Error type: "+arguments[0]+"\nDescription: "+arguments[1]);return null;}
window.dhtmlxError=new _dhtmlxError();dtmlXMLLoaderObject.prototype.doXPathOpera=function(xpathExp, docObj){var z = xpathExp.replace(/[\/]+/gi, "/").split('/');var obj = null;var i = 1;if (!z.length)return [];if (z[0] == ".")obj=[docObj];else if (z[0] == ""){obj=(this.xmlDoc.responseXML||this.xmlDoc).getElementsByTagName(z[i].replace(/\[[^\]]*\]/g, ""));i++;}else
 return [];for (i;i < z.length;i++)obj=this._getAllNamedChilds(obj, z[i]);if (z[i-1].indexOf("[")!= -1)
 obj=this._filterXPath(obj, z[i-1]);return obj;}
dtmlXMLLoaderObject.prototype._filterXPath=function(a, b){var c = new Array();var b = b.replace(/[^\[]*\[\@/g, "").replace(/[\[\]\@]*/g, "");for (var i = 0;i < a.length;i++)if (a[i].getAttribute(b))
 c[c.length]=a[i];return c;}
dtmlXMLLoaderObject.prototype._getAllNamedChilds=function(a, b){var c = new Array();if (_isKHTML)b=b.toUpperCase();for (var i = 0;i < a.length;i++)for (var j = 0;j < a[i].childNodes.length;j++){if (_isKHTML){if (a[i].childNodes[j].tagName&&a[i].childNodes[j].tagName.toUpperCase()== b)
 c[c.length]=a[i].childNodes[j];}
 else if (a[i].childNodes[j].tagName == b)c[c.length]=a[i].childNodes[j];}
 return c;}
function dhtmlXHeir(a, b){for (var c in b)if (typeof (b[c])== "function")
 a[c]=b[c];return a;}
function dhtmlxEvent(el, event, handler){if (el.addEventListener)el.addEventListener(event, handler, false);else if (el.attachEvent)el.attachEvent("on"+event, handler);}
dtmlXMLLoaderObject.prototype.xslDoc=null;dtmlXMLLoaderObject.prototype.setXSLParamValue=function(paramName, paramValue, xslDoc){if (!xslDoc)xslDoc=this.xslDoc

 if (xslDoc.responseXML)xslDoc=xslDoc.responseXML;var item =
 this.doXPath("/xsl:stylesheet/xsl:variable[@name='"+paramName+"']", xslDoc,
 "http:/\/www.w3.org/1999/XSL/Transform", "single");if (item != null)item.firstChild.nodeValue=paramValue
}
dtmlXMLLoaderObject.prototype.doXSLTransToObject=function(xslDoc, xmlDoc){if (!xslDoc)xslDoc=this.xslDoc;if (xslDoc.responseXML)xslDoc=xslDoc.responseXML

 if (!xmlDoc)xmlDoc=this.xmlDoc;if (xmlDoc.responseXML)xmlDoc=xmlDoc.responseXML

 
 if (!_isIE){if (!this.XSLProcessor){this.XSLProcessor=new XSLTProcessor();this.XSLProcessor.importStylesheet(xslDoc);}
 var result = this.XSLProcessor.transformToDocument(xmlDoc);}else {var result = new ActiveXObject("Msxml2.DOMDocument.3.0");try{xmlDoc.transformNodeToObject(xslDoc, result);}catch(e){result = xmlDoc.transformNode(xslDoc);}
 }
 return result;}
dtmlXMLLoaderObject.prototype.doXSLTransToString=function(xslDoc, xmlDoc){var res = this.doXSLTransToObject(xslDoc, xmlDoc);if(typeof(res)=="string")
 return res;return this.doSerialization(res);}
dtmlXMLLoaderObject.prototype.doSerialization=function(xmlDoc){if (!xmlDoc)xmlDoc=this.xmlDoc;if (xmlDoc.responseXML)xmlDoc=xmlDoc.responseXML
 if (!_isIE){var xmlSerializer = new XMLSerializer();return xmlSerializer.serializeToString(xmlDoc);}else
 return xmlDoc.xml;}
dhtmlxEventable=function(obj){obj.attachEvent=function(name, catcher, callObj){name='ev_'+name.toLowerCase();if (!this[name])this[name]=new this.eventCatcher(callObj||this);return(name+':'+this[name].addEvent(catcher));}
 obj.callEvent=function(name, arg0){name='ev_'+name.toLowerCase();if (this[name])return this[name].apply(this, arg0);return true;}
 obj.checkEvent=function(name){return (!!this['ev_'+name.toLowerCase()])
 }
 obj.eventCatcher=function(obj){var dhx_catch = [];var z = function(){var res = true;for (var i = 0;i < dhx_catch.length;i++){if (dhx_catch[i] != null){var zr = dhx_catch[i].apply(obj, arguments);res=res&&zr;}
 }
 return res;}
 z.addEvent=function(ev){if (typeof (ev)!= "function")
 ev=eval(ev);if (ev)return dhx_catch.push(ev)-1;return false;}
 z.removeEvent=function(id){dhx_catch[id]=null;}
 return z;}
 obj.detachEvent=function(id){if (id != false){var list = id.split(':');this[list[0]].removeEvent(list[1]);}
 }
 obj.detachAllEvents = function(){for (var name in this){if (name.indexOf("ev_")==0) 
 this[name] = null;}
 }
 obj = null;};function dataProcessor(serverProcessorURL){this.serverProcessor = serverProcessorURL;this.action_param="!nativeeditor_status";this.object = null;this.updatedRows = [];this.autoUpdate = true;this.updateMode = "cell";this._tMode="GET";this.post_delim = "_";this._waitMode=0;this._in_progress={};this._invalid={};this.mandatoryFields=[];this.messages=[];this.styles={updated:"font-weight:bold;",
 inserted:"font-weight:bold;",
 deleted:"text-decoration : line-through;",
 invalid:"background-color:FFE0E0;",
 invalid_cell:"border-bottom:2px solid red;",
 error:"color:red;",
 clear:"font-weight:normal;text-decoration:none;"
 };this.enableUTFencoding(true);dhtmlxEventable(this);return this;}
dataProcessor.prototype={setTransactionMode:function(mode,total){this._tMode=mode;this._tSend=total;},
 escape:function(data){if (this._utf)return encodeURIComponent(data);else
 return escape(data);},
 
 enableUTFencoding:function(mode){this._utf=convertStringToBoolean(mode);},
 
 setDataColumns:function(val){this._columns=(typeof val == "string")?val.split(","):val;},
 
 getSyncState:function(){return !this.updatedRows.length;},
 
 enableDataNames:function(mode){this._endnm=convertStringToBoolean(mode);},
 
 enablePartialDataSend:function(mode){this._changed=convertStringToBoolean(mode);},
 
 setUpdateMode:function(mode,dnd){this.autoUpdate = (mode=="cell");this.updateMode = mode;this.dnd=dnd;},
 ignore:function(code,master){this._silent_mode=true;code.call(master||window);this._silent_mode=false;},
 
 setUpdated:function(rowId,state,mode){if (this._silent_mode)return;var ind=this.findRow(rowId);mode=mode||"updated";var existing = this.obj.getUserData(rowId,this.action_param);if (existing && mode == "updated")mode=existing;if (state){this.set_invalid(rowId,false);this.updatedRows[ind]=rowId;this.obj.setUserData(rowId,this.action_param,mode);if (this._in_progress[rowId])this._in_progress[rowId]="wait";}else{if (!this.is_invalid(rowId)){this.updatedRows.splice(ind,1);this.obj.setUserData(rowId,this.action_param,"");}
 }
 
 if (!state)this._clearUpdateFlag(rowId);this.markRow(rowId,state,mode);if (state && this.autoUpdate)this.sendData(rowId);},
 _clearUpdateFlag:function(id){},
 markRow:function(id,state,mode){var str="";var invalid=this.is_invalid(id);if (invalid){str=this.styles[invalid];state=true;}
 if (this.callEvent("onRowMark",[id,state,mode,invalid])){str=this.styles[state?mode:"clear"]+str;this.obj[this._methods[0]](id,str);if (invalid && invalid.details){str+=this.styles[invalid+"_cell"];for (var i=0;i < invalid.details.length;i++)if (invalid.details[i])this.obj[this._methods[1]](id,i,str);}
 }
 },
 getState:function(id){return this.obj.getUserData(id,this.action_param);},
 is_invalid:function(id){return this._invalid[id];},
 set_invalid:function(id,mode,details){if (details)mode={value:mode, details:details, toString:function(){return this.value.toString();}};this._invalid[id]=mode;},
 
 checkBeforeUpdate:function(rowId){return true;},
 
 sendData:function(rowId){if (this._waitMode && (this.obj.mytype=="tree" || this.obj._h2)) return;if (this.obj.editStop)this.obj.editStop();if(typeof rowId == "undefined" || this._tSend)return this.sendAllData();if (this._in_progress[rowId])return false;this.messages=[];if (!this.checkBeforeUpdate(rowId)&& this.callEvent("onValidationError",[rowId,this.messages])) return false;this._beforeSendData(this._getRowData(rowId),rowId);},
 _beforeSendData:function(data,rowId){if (!this.callEvent("onBeforeUpdate",[rowId,this.getState(rowId),data])) return false;this._sendData(data,rowId);},
 serialize:function(data, id){if (typeof data == "string")return data;if (typeof id != "undefined")return this.serialize_one(data,"");else{var stack = [];var keys = [];for (var key in data)if (data.hasOwnProperty(key)){stack.push(this.serialize_one(data[key],key+this.post_delim));keys.push(key);}
 stack.push("ids="+this.escape(keys.join(",")));if (dhtmlx.security_key)stack.push("dhx_security="+dhtmlx.security_key);return stack.join("&");}
 },
 serialize_one:function(data, pref){if (typeof data == "string")return data;var stack = [];for (var key in data)if (data.hasOwnProperty(key))
 stack.push(this.escape((pref||"")+key)+"="+this.escape(data[key]));return stack.join("&");},
 _sendData:function(a1,rowId){if (!a1)return;if (!this.callEvent("onBeforeDataSending",rowId?[rowId,this.getState(rowId),a1]:[null, null, a1])) return false;if (rowId)this._in_progress[rowId]=(new Date()).valueOf();var a2=new dtmlXMLLoaderObject(this.afterUpdate,this,true);var a3 = this.serverProcessor+(this._user?(getUrlSymbol(this.serverProcessor)+["dhx_user="+this._user,"dhx_version="+this.obj.getUserData(0,"version")].join("&")):"");if (this._tMode!="POST")a2.loadXML(a3+((a3.indexOf("?")!=-1)?"&":"?")+this.serialize(a1,rowId));else
 a2.loadXML(a3,true,this.serialize(a1,rowId));this._waitMode++;},
 sendAllData:function(){if (!this.updatedRows.length)return;this.messages=[];var valid=true;for (var i=0;i<this.updatedRows.length;i++)valid&=this.checkBeforeUpdate(this.updatedRows[i]);if (!valid && !this.callEvent("onValidationError",["",this.messages])) return false;if (this._tSend)this._sendData(this._getAllData());else
 for (var i=0;i<this.updatedRows.length;i++)if (!this._in_progress[this.updatedRows[i]]){if (this.is_invalid(this.updatedRows[i])) continue;this._beforeSendData(this._getRowData(this.updatedRows[i]),this.updatedRows[i]);if (this._waitMode && (this.obj.mytype=="tree" || this.obj._h2)) return;}
 },
 
 
 
 
 
 
 
 
 _getAllData:function(rowId){var out={};var has_one = false;for(var i=0;i<this.updatedRows.length;i++){var id=this.updatedRows[i];if (this._in_progress[id] || this.is_invalid(id)) continue;if (!this.callEvent("onBeforeUpdate",[id,this.getState(id)])) continue;out[id]=this._getRowData(id,id+this.post_delim);has_one = true;this._in_progress[id]=(new Date()).valueOf();}
 return has_one?out:null;},
 
 
 
 setVerificator:function(ind,verifFunction){this.mandatoryFields[ind] = verifFunction||(function(value){return (value!="");});},
 
 clearVerificator:function(ind){this.mandatoryFields[ind] = false;},
 
 
 
 
 
 findRow:function(pattern){var i=0;for(i=0;i<this.updatedRows.length;i++)if(pattern==this.updatedRows[i])break;return i;},

 
 


 





 
 defineAction:function(name,handler){if (!this._uActions)this._uActions=[];this._uActions[name]=handler;},




 
 afterUpdateCallback:function(sid, tid, action, btag) {var marker = sid;var correct=(action!="error" && action!="invalid");if (!correct)this.set_invalid(sid,action);if ((this._uActions)&&(this._uActions[action])&&(!this._uActions[action](btag))) 
 return (delete this._in_progress[marker]);if (this._in_progress[marker]!="wait")this.setUpdated(sid, false);var soid = sid;switch (action) {case "inserted":
 case "insert":
 if (tid != sid){this.obj[this._methods[2]](sid, tid);sid = tid;}
 break;case "delete":
 case "deleted":
 this.obj.setUserData(sid, this.action_param, "true_deleted");this.obj[this._methods[3]](sid);delete this._in_progress[marker];return this.callEvent("onAfterUpdate", [sid, action, tid, btag]);break;}
 
 if (this._in_progress[marker]!="wait"){if (correct)this.obj.setUserData(sid, this.action_param,'');delete this._in_progress[marker];}else {delete this._in_progress[marker];this.setUpdated(tid,true,this.obj.getUserData(sid,this.action_param));}
 
 this.callEvent("onAfterUpdate", [soid, action, tid, btag]);},

 
 afterUpdate:function(that,b,c,d,xml){xml.getXMLTopNode("data");if (!xml.xmlDoc.responseXML)return;var atag=xml.doXPath("//data/action");for (var i=0;i<atag.length;i++){var btag=atag[i];var action = btag.getAttribute("type");var sid = btag.getAttribute("sid");var tid = btag.getAttribute("tid");that.afterUpdateCallback(sid,tid,action,btag);}
 that.finalizeUpdate();},
 finalizeUpdate:function(){if (this._waitMode)this._waitMode--;if ((this.obj.mytype=="tree" || this.obj._h2)&& this.updatedRows.length) 
 this.sendData();this.callEvent("onAfterUpdateFinish",[]);if (!this.updatedRows.length)this.callEvent("onFullSync",[]);},




 
 
 init:function(anObj){this.obj = anObj;if (this.obj._dp_init)this.obj._dp_init(this);},
 
 
 setOnAfterUpdate:function(ev){this.attachEvent("onAfterUpdate",ev);},
 enableDebug:function(mode){},
 setOnBeforeUpdateHandler:function(func){this.attachEvent("onBeforeDataSending",func);},



 
 setAutoUpdate: function(interval, user) {interval = interval || 2000;this._user = user || (new Date()).valueOf();this._need_update = false;this._loader = null;this._update_busy = false;this.attachEvent("onAfterUpdate",function(sid,action,tid,xml_node){this.afterAutoUpdate(sid, action, tid, xml_node);});this.attachEvent("onFullSync",function(){this.fullSync();});var self = this;window.setInterval(function(){self.loadUpdate();}, interval);},


 
 afterAutoUpdate: function(sid, action, tid, xml_node) {if (action == 'collision'){this._need_update = true;return false;}else {return true;}
 },


 
 fullSync: function() {if (this._need_update == true){this._need_update = false;this.loadUpdate();}
 return true;},


 
 getUpdates: function(url,callback){if (this._update_busy)return false;else
 this._update_busy = true;this._loader = this._loader || new dtmlXMLLoaderObject(true);this._loader.async=true;this._loader.waitCall=callback;this._loader.loadXML(url);},


 
 _v: function(node) {if (node.firstChild)return node.firstChild.nodeValue;return "";},


 
 _a: function(arr) {var res = [];for (var i=0;i < arr.length;i++){res[i]=this._v(arr[i]);};return res;},


 
 loadUpdate: function(){var self = this;var version = this.obj.getUserData(0,"version");var url = this.serverProcessor+getUrlSymbol(this.serverProcessor)+["dhx_user="+this._user,"dhx_version="+version].join("&");url = url.replace("editing=true&","");this.getUpdates(url, function(){var vers = self._loader.doXPath("//userdata");self.obj.setUserData(0,"version",self._v(vers[0]));var upds = self._loader.doXPath("//update");if (upds.length){self._silent_mode = true;for (var i=0;i<upds.length;i++){var status = upds[i].getAttribute('status');var id = upds[i].getAttribute('id');var parent = upds[i].getAttribute('parent');switch (status) {case 'inserted':
 self.callEvent("insertCallback",[upds[i], id, parent]);break;case 'updated':
 self.callEvent("updateCallback",[upds[i], id, parent]);break;case 'deleted':
 self.callEvent("deleteCallback",[upds[i], id, parent]);break;}
 }
 
 self._silent_mode = false;}
 
 self._update_busy = false;self = null;});}
};function xmlPointer(data){this.d=data;}
xmlPointer.prototype={text:function(){if (!_isFF)return this.d.xml;var x = new XMLSerializer();return x.serializeToString(this.d);},
 get:function(name){return this.d.getAttribute(name);},
 exists:function(){return !!this.d },
 content:function(){return this.d.firstChild?this.d.firstChild.data:"";}, 
 each:function(name,f,t,i){var a=this.d.childNodes;var c=new xmlPointer();if (a.length)for (i=i||0;i<a.length;i++)if (a[i].tagName==name){c.d=a[i];if(f.apply(t,[c,i])==-1) return;}},
 get_all:function(){var a={};var b=this.d.attributes;for (var i=0;i<b.length;i++)a[b[i].name]=b[i].value;return a;},
 sub:function(name){var a=this.d.childNodes;var c=new xmlPointer();if (a.length)for (var i=0;i<a.length;i++)if (a[i].tagName==name){c.d=a[i];return c;}},
 up:function(name){return new xmlPointer(this.d.parentNode);},
 set:function(name,val){this.d.setAttribute(name,val);},
 clone:function(name){return new xmlPointer(this.d);},
 sub_exists:function(name){var a=this.d.childNodes;if (a.length)for (var i=0;i<a.length;i++)if (a[i].tagName==name)return true;return false;},
 through:function(name,rule,v,f,t){var a=this.d.childNodes;if (a.length)for (var i=0;i<a.length;i++){if (a[i].tagName==name && a[i].getAttribute(rule)!=null && a[i].getAttribute(rule)!="" && (!v || a[i].getAttribute(rule)==v )) {var c=new xmlPointer(a[i]);f.apply(t,[c,i]);}var w=this.d;this.d=a[i];this.through(name,rule,v,f,t);this.d=w;}}
}
function dhtmlXTreeObject(htmlObject, width, height, rootId){if (_isIE)try {document.execCommand("BackgroundImageCache", false, true);}catch (e){}
 if (typeof(htmlObject)!="object")
 this.parentObject=document.getElementById(htmlObject);else
 this.parentObject=htmlObject;this.parentObject.style.overflow="hidden";this._itim_dg=true;this.dlmtr=",";this.dropLower=false;this.enableIEImageFix();this.xmlstate=0;this.mytype="tree";this.smcheck=true;this.width=width;this.height=height;this.rootId=rootId;this.childCalc=null;this.def_img_x="18px";this.def_img_y="18px";this.def_line_img_x="18px";this.def_line_img_y="18px";this._dragged=new Array();this._selected=new Array();this.style_pointer="pointer";this._aimgs=true;this.htmlcA=" [";this.htmlcB="]";this.lWin=window;this.cMenu=0;this.mlitems=0;this.iconURL="";this.dadmode=0;this.slowParse=false;this.autoScroll=true;this.hfMode=0;this.nodeCut=new Array();this.XMLsource=0;this.XMLloadingWarning=0;this._idpull={};this._pullSize=0;this.treeLinesOn=true;this.tscheck=false;this.timgen=true;this.dpcpy=false;this._ld_id=null;this._oie_onXLE=[];this.imPath=window.dhx_globalImgPath||"";this.checkArray=new Array("iconUncheckAll.gif","iconCheckAll.gif","iconCheckGray.gif","iconUncheckDis.gif","iconCheckDis.gif","iconCheckDis.gif");this.radioArray=new Array("radio_off.gif","radio_on.gif","radio_on.gif","radio_off.gif","radio_on.gif","radio_on.gif");this.lineArray=new Array("line2.gif","line3.gif","line4.gif","blank.gif","blank.gif","line1.gif");this.minusArray=new Array("minus2.gif","minus3.gif","minus4.gif","minus.gif","minus5.gif");this.plusArray=new Array("plus2.gif","plus3.gif","plus4.gif","plus.gif","plus5.gif");this.imageArray=new Array("leaf.gif","folderOpen.gif","folderClosed.gif");this.cutImg= new Array(0,0,0);this.cutImage="but_cut.gif";dhtmlxEventable(this);this.dragger= new dhtmlDragAndDropObject();this.htmlNode=new dhtmlXTreeItemObject(this.rootId,"",0,this);this.htmlNode.htmlNode.childNodes[0].childNodes[0].style.display="none";this.htmlNode.htmlNode.childNodes[0].childNodes[0].childNodes[0].className="hiddenRow";this.allTree=this._createSelf();this.allTree.appendChild(this.htmlNode.htmlNode);if (dhtmlx.$customScroll)dhtmlx.CustomScroll.enable(this);if(_isFF){this.allTree.childNodes[0].width="100%";this.allTree.childNodes[0].style.overflow="hidden";}
 var self=this;this.allTree.onselectstart=new Function("return false;");if (_isMacOS)this.allTree.oncontextmenu = function(e){return self._doContClick(e||window.event, true);};this.allTree.onmousedown = function(e){return self._doContClick(e||window.event);};this.XMLLoader=new dtmlXMLLoaderObject(this._parseXMLTree,this,true,this.no_cashe);if (_isIE)this.preventIECashing(true);if (window.addEventListener)window.addEventListener("unload",function(){try{self.destructor();}catch(e){}},false);if (window.attachEvent)window.attachEvent("onunload",function(){try{self.destructor();}catch(e){}});this.setImagesPath=this.setImagePath;this.setIconsPath=this.setIconPath;if (dhtmlx.image_path)this.setImagePath(dhtmlx.image_path);if (dhtmlx.skin)this.setSkin(dhtmlx.skin);return this;};dhtmlXTreeObject.prototype.setDataMode=function(mode){this._datamode=mode;}
 
dhtmlXTreeObject.prototype._doContClick=function(ev, force){if (!force && ev.button!=2){if(this._acMenu){if (this._acMenu.hideContextMenu)this._acMenu.hideContextMenu()
 else
 this.cMenu._contextEnd();}
 return true;}
 
 

 
 var el=(_isIE?ev.srcElement:ev.target);while ((el)&&(el.tagName!="BODY")) {if (el.parentObject)break;el=el.parentNode;}
 
 if ((!el)||(!el.parentObject)) return true;var obj=el.parentObject;if (!this.callEvent("onRightClick",[obj.id,ev]))
 (ev.srcElement||ev.target).oncontextmenu = function(e){(e||event).cancelBubble=true;return false;};this._acMenu=(obj.cMenu||this.cMenu);if (this._acMenu){if (!(this.callEvent("onBeforeContextMenu", [
 obj.id
 ]))) return true;if(!_isMacOS)(ev.srcElement||ev.target).oncontextmenu = function(e){(e||event).cancelBubble=true;return false;};if (this._acMenu.showContextMenu){var dEl0=window.document.documentElement;var dEl1=window.document.body;var corrector = new Array((dEl0.scrollLeft||dEl1.scrollLeft),(dEl0.scrollTop||dEl1.scrollTop));if (_isIE){var x= ev.clientX+corrector[0];var y = ev.clientY+corrector[1];}else {var x= ev.pageX;var y = ev.pageY;}
 
 this._acMenu.showContextMenu(x-1,y-1)
 this.contextID=obj.id;ev.cancelBubble=true;this._acMenu._skip_hide=true;}else {el.contextMenuId=obj.id;el.contextMenu=this._acMenu;el.a=this._acMenu._contextStart;el.a(el, ev);el.a=null;}
 
 return false;}
 return true;}
dhtmlXTreeObject.prototype.enableIEImageFix=function(mode){if (!mode){this._getImg=function(id){return document.createElement((id==this.rootId)?"div":"img");}
 this._setSrc=function(a,b){a.src=b;}
 this._getSrc=function(a){return a.src;}
 }else {this._getImg=function(){var z=document.createElement("DIV");z.innerHTML="&nbsp;";z.className="dhx_bg_img_fix";return z;}
 this._setSrc=function(a,b){a.style.backgroundImage="url("+b+")";}
 this._getSrc=function(a){var z=a.style.backgroundImage;return z.substr(4,z.length-5).replace(/(^")|("$)/g,"");}
 }
}
dhtmlXTreeObject.prototype.destructor=function(){for (var a in this._idpull){var z=this._idpull[a];if (!z)continue;z.parentObject=null;z.treeNod=null;z.childNodes=null;z.span=null;z.tr.nodem=null;z.tr=null;z.htmlNode.objBelong=null;z.htmlNode=null;this._idpull[a]=null;}
 this.parentObject.innerHTML="";if(this.XMLLoader)this.XMLLoader.destructor();this.allTree.onselectstart = null;this.allTree.oncontextmenu = null;this.allTree.onmousedown = null;for(var a in this){this[a]=null;}
}
function cObject(){return this;}
cObject.prototype= new Object;cObject.prototype.clone = function () {function _dummy(){};_dummy.prototype=this;return new _dummy();}
function dhtmlXTreeItemObject(itemId,itemText,parentObject,treeObject,actionHandler,mode){this.htmlNode="";this.acolor="";this.scolor="";this.tr=0;this.childsCount=0;this.tempDOMM=0;this.tempDOMU=0;this.dragSpan=0;this.dragMove=0;this.span=0;this.closeble=1;this.childNodes=new Array();this.userData=new cObject();this.checkstate=0;this.treeNod=treeObject;this.label=itemText;this.parentObject=parentObject;this.actionHandler=actionHandler;this.images=new Array(treeObject.imageArray[0],treeObject.imageArray[1],treeObject.imageArray[2]);this.id=treeObject._globalIdStorageAdd(itemId,this);if (this.treeNod.checkBoxOff )this.htmlNode=this.treeNod._createItem(1,this,mode);else this.htmlNode=this.treeNod._createItem(0,this,mode);this.htmlNode.objBelong=this;return this;};dhtmlXTreeObject.prototype._globalIdStorageAdd=function(itemId,itemObject){if (this._globalIdStorageFind(itemId,1,1)) {itemId=itemId +"_"+(new Date()).valueOf();return this._globalIdStorageAdd(itemId,itemObject);}
 this._idpull[itemId]=itemObject;this._pullSize++;return itemId;};dhtmlXTreeObject.prototype._globalIdStorageSub=function(itemId){if (this._idpull[itemId]){this._unselectItem(this._idpull[itemId]);this._idpull[itemId]=null;this._pullSize--;}
 if ((this._locker)&&(this._locker[itemId])) this._locker[itemId]=false;};dhtmlXTreeObject.prototype._globalIdStorageFind=function(itemId,skipXMLSearch,skipParsing,isreparse){var z=this._idpull[itemId]
 if (z){return z;}
 return null;};dhtmlXTreeObject.prototype._escape=function(str){switch(this.utfesc){case "none":
 return str;break;case "utf8":
 return encodeURIComponent(str);break;default:
 return escape(str);break;}
 }
 dhtmlXTreeObject.prototype._drawNewTr=function(htmlObject,node)
 {var tr =document.createElement('tr');var td1=document.createElement('td');var td2=document.createElement('td');td1.appendChild(document.createTextNode(" "));td2.colSpan=3;td2.appendChild(htmlObject);tr.appendChild(td1);tr.appendChild(td2);return tr;};dhtmlXTreeObject.prototype.loadXMLString=function(xmlString,afterCall){var that=this;if (!this.parsCount)this.callEvent("onXLS",[that,null]);this.xmlstate=1;if (afterCall)this.XMLLoader.waitCall=afterCall;this.XMLLoader.loadXMLString(xmlString);};dhtmlXTreeObject.prototype.loadXML=function(file,afterCall){if (this._datamode && this._datamode!="xml")return this["load"+this._datamode.toUpperCase()](file,afterCall);var that=this;if (!this.parsCount)this.callEvent("onXLS",[that,this._ld_id]);this._ld_id=null;this.xmlstate=1;this.XMLLoader=new dtmlXMLLoaderObject(this._parseXMLTree,this,true,this.no_cashe);if (afterCall)this.XMLLoader.waitCall=afterCall;this.XMLLoader.loadXML(file);};dhtmlXTreeObject.prototype._attachChildNode=function(parentObject,itemId,itemText,itemActionHandler,image1,image2,image3,optionStr,childs,beforeNode,afterNode){if (beforeNode && beforeNode.parentObject)parentObject=beforeNode.parentObject;if (((parentObject.XMLload==0)&&(this.XMLsource))&&(!this.XMLloadingWarning))
 {parentObject.XMLload=1;this._loadDynXML(parentObject.id);}
 var Count=parentObject.childsCount;var Nodes=parentObject.childNodes;if (afterNode && afterNode.tr.previousSibling){if (afterNode.tr.previousSibling.previousSibling){beforeNode=afterNode.tr.previousSibling.nodem;}
 else
 optionStr=optionStr.replace("TOP","")+",TOP";}
 if (beforeNode){var ik,jk;for (ik=0;ik<Count;ik++)if (Nodes[ik]==beforeNode){for (jk=Count;jk!=ik;jk--)Nodes[1+jk]=Nodes[jk];break;}
 ik++;Count=ik;}
 if (optionStr){var tempStr=optionStr.split(",");for (var i=0;i<tempStr.length;i++){switch(tempStr[i])
 {case "TOP": if (parentObject.childsCount>0){beforeNode=new Object;beforeNode.tr=parentObject.childNodes[0].tr.previousSibling;}
 parentObject._has_top=true;for (ik=Count;ik>0;ik--)Nodes[ik]=Nodes[ik-1];Count=0;break;}
 };};var n;if (!(n=this._idpull[itemId])|| n.span!=-1){n=Nodes[Count]=new dhtmlXTreeItemObject(itemId,itemText,parentObject,this,itemActionHandler,1);itemId = Nodes[Count].id;parentObject.childsCount++;}
 
 if(!n.htmlNode){n.label=itemText;n.htmlNode=this._createItem((this.checkBoxOff?1:0),n);n.htmlNode.objBelong=n;}
 if(image1)n.images[0]=image1;if(image2)n.images[1]=image2;if(image3)n.images[2]=image3;var tr=this._drawNewTr(n.htmlNode);if ((this.XMLloadingWarning)||(this._hAdI))
 n.htmlNode.parentNode.parentNode.style.display="none";if ((beforeNode)&&beforeNode.tr&&(beforeNode.tr.nextSibling))
 parentObject.htmlNode.childNodes[0].insertBefore(tr,beforeNode.tr.nextSibling);else
 if (this.parsingOn==parentObject.id){this.parsedArray[this.parsedArray.length]=tr;}
 else
 parentObject.htmlNode.childNodes[0].appendChild(tr);if ((beforeNode)&&(!beforeNode.span)) beforeNode=null;if (this.XMLsource)if ((childs)&&(childs!=0)) n.XMLload=0;else n.XMLload=1;n.tr=tr;tr.nodem=n;if (parentObject.itemId==0)tr.childNodes[0].className="hiddenRow";if ((parentObject._r_logic)||(this._frbtr))
 this._setSrc(n.htmlNode.childNodes[0].childNodes[0].childNodes[1].childNodes[0],this.imPath+this.radioArray[0]);if (optionStr){var tempStr=optionStr.split(",");for (var i=0;i<tempStr.length;i++){switch(tempStr[i])
 {case "SELECT": this.selectItem(itemId,false);break;case "CALL": this.selectItem(itemId,true);break;case "CHILD": n.XMLload=0;break;case "CHECKED":
 if (this.XMLloadingWarning)this.setCheckList+=this.dlmtr+itemId;else
 this.setCheck(itemId,1);break;case "HCHECKED":
 this._setCheck(n,"unsure");break;case "OPEN": n.openMe=1;break;}
 };};if (!this.XMLloadingWarning){if ((this._getOpenState(parentObject)<0)&&(!this._hAdI)) this.openItem(parentObject.id);if (beforeNode){this._correctPlus(beforeNode);this._correctLine(beforeNode);}
 this._correctPlus(parentObject);this._correctLine(parentObject);this._correctPlus(n);if (parentObject.childsCount>=2){this._correctPlus(Nodes[parentObject.childsCount-2]);this._correctLine(Nodes[parentObject.childsCount-2]);}
 if (parentObject.childsCount!=2)this._correctPlus(Nodes[0]);if (this.tscheck)this._correctCheckStates(parentObject);if (this._onradh){if (this.xmlstate==1){var old=this.onXLE;this.onXLE=function(id){this._onradh(itemId);if (old)old(id);}
 }
 else
 this._onradh(itemId);}
 }
 return n;};dhtmlXTreeObject.prototype.insertNewItem=function(parentId,itemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children){var parentObject=this._globalIdStorageFind(parentId);if (!parentObject)return (-1);var nodez=this._attachChildNode(parentObject,itemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children);if(!this._idpull[this.rootId].XMLload)this._idpull[this.rootId].XMLload = 1;return nodez;};dhtmlXTreeObject.prototype.insertNewChild=function(parentId,itemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children){return this.insertNewItem(parentId,itemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children);}

 dhtmlXTreeObject.prototype._parseXMLTree=function(a,b,c,d,xml){var p=new xmlPointer(xml.getXMLTopNode("tree"));a._parse(p);a._p=p;}
 
 dhtmlXTreeObject.prototype._parseItem=function(c,temp,preNode,befNode){var id;if (this._srnd && (!this._idpull[id=c.get("id")] || !this._idpull[id].span))
 {this._addItemSRND(temp.id,id,c);return;}
 
 var a=c.get_all();if ((typeof(this.waitUpdateXML)=="object")&&(!this.waitUpdateXML[a.id])){this._parse(c,a.id,1);return;}


 



 var zST=[];if (a.select)zST.push("SELECT");if (a.top)zST.push("TOP");if (a.call)this.nodeAskingCall=a.id;if (a.checked==-1)zST.push("HCHECKED");else if (a.checked)zST.push("CHECKED");if (a.open)zST.push("OPEN");if (this.waitUpdateXML){if (this._globalIdStorageFind(a.id))
 var newNode=this.updateItem(a.id,a.text,a.im0,a.im1,a.im2,a.checked,a.child);else{if (this.npl==0)zST.push("TOP");else preNode=temp.childNodes[this.npl];var newNode=this._attachChildNode(temp,a.id,a.text,0,a.im0,a.im1,a.im2,zST.join(","),a.child,0,preNode);a.id = newNode.id;preNode=null;}
 }
 else
 var newNode=this._attachChildNode(temp,a.id,a.text,0,a.im0,a.im1,a.im2,zST.join(","),a.child,(befNode||0),preNode);if (a.tooltip)newNode.span.parentNode.parentNode.title=a.tooltip;if (a.style)if (newNode.span.style.cssText)newNode.span.style.cssText+=(";"+a.style);else
 newNode.span.setAttribute("style",newNode.span.getAttribute("style")+";"+a.style);if (a.radio)newNode._r_logic=true;if (a.nocheckbox){var check_node=newNode.span.parentNode.previousSibling.previousSibling;check_node.style.display="none";newNode.nocheckbox=true;}
 if (a.disabled){if (a.checked!=null)this._setCheck(newNode,a.checked);this.disableCheckbox(newNode,1);}
 
 newNode._acc=a.child||0;if (this.parserExtension)this.parserExtension._parseExtension.call(this,c,a,(temp?temp.id:0));this.setItemColor(newNode,a.aCol,a.sCol);if (a.locked=="1")this.lockItem(newNode.id,true,true);if ((a.imwidth)||(a.imheight)) this.setIconSize(a.imwidth,a.imheight,newNode);if ((a.closeable=="0")||(a.closeable=="1")) this.setItemCloseable(newNode,a.closeable);var zcall="";if (a.topoffset)this.setItemTopOffset(newNode,a.topoffset);if ((!this.slowParse)||(typeof(this.waitUpdateXML)=="object")){if (c.sub_exists("item"))
 zcall=this._parse(c,a.id,1);}
 if (zcall!="")this.nodeAskingCall=zcall;c.each("userdata",function(u){this.setUserData(c.get("id"),u.get("name"),u.content());},this)
 
 
 }
 dhtmlXTreeObject.prototype._parse=function(p,parentId,level,start){if (this._srnd && !this.parentObject.offsetHeight){var self=this;return window.setTimeout(function(){self._parse(p,parentId,level,start);},100);}
 if (!p.exists()) return;this.skipLock=true;if (!parentId){parentId=p.get("id");var skey = p.get("dhx_security");if (skey)dhtmlx.security_key = skey;if (p.get("radio"))
 this.htmlNode._r_logic=true;this.parsingOn=parentId;this.parsedArray=new Array();this.setCheckList="";this.nodeAskingCall="";}
 
 var temp=this._globalIdStorageFind(parentId);if (!temp)return dhtmlxError.throwError("DataStructure","XML refers to not existing parent");this.parsCount=this.parsCount?(this.parsCount+1):1;this.XMLloadingWarning=1;if ((temp.childsCount)&&(!start)&&(!this._edsbps)&&(!temp._has_top))
 var preNode=0;else
 var preNode=0;this.npl=0;p.each("item",function(c,i){temp.XMLload=1;this._parseItem(c,temp,0,preNode);this.npl++;},this,start);if (!level){p.each("userdata",function(u){this.setUserData(p.get("id"),u.get("name"),u.content());},this);temp.XMLload=1;if (this.waitUpdateXML){this.waitUpdateXML=false;for (var i=temp.childsCount-1;i>=0;i--)if (temp.childNodes[i]._dmark)this.deleteItem(temp.childNodes[i].id);}
 var parsedNodeTop=this._globalIdStorageFind(this.parsingOn);for (var i=0;i<this.parsedArray.length;i++)temp.htmlNode.childNodes[0].appendChild(this.parsedArray[i]);this.parsedArray = [];this.lastLoadedXMLId=parentId;this.XMLloadingWarning=0;var chArr=this.setCheckList.split(this.dlmtr);for (var n=0;n<chArr.length;n++)if (chArr[n])this.setCheck(chArr[n],1);if ((this.XMLsource)&&(this.tscheck)&&(this.smcheck)&&(temp.id!=this.rootId)){if (temp.checkstate===0)this._setSubChecked(0,temp);else if (temp.checkstate===1)this._setSubChecked(1,temp);}
 this._redrawFrom(this,null,start)
 if (p.get("order")&& p.get("order")!="none")
 this._reorderBranch(temp,p.get("order"),true);if (this.nodeAskingCall!="")this.callEvent("onClick",[this.nodeAskingCall,this.getSelectedItemId()]);if (this._branchUpdate)this._branchUpdateNext(p);}
 if (this.parsCount==1){this.parsingOn=null;if ((!this._edsbps)||(!this._edsbpsA.length)){var that=this;window.setTimeout( function(){that.callEvent("onXLE",[that,parentId]);},1);this.xmlstate=0;}
 this.skipLock=false;}
 this.parsCount--;if (!level && this.onXLE)this.onXLE(this,parentId);return this.nodeAskingCall;};dhtmlXTreeObject.prototype._branchUpdateNext=function(p){p.each("item",function(c){var nid=c.get("id");if (this._idpull[nid] && (!this._idpull[nid].XMLload)) return;this._branchUpdate++;this.smartRefreshItem(c.get("id"),c);},this)
 this._branchUpdate--;}

 dhtmlXTreeObject.prototype.checkUserData=function(node,parentId){if ((node.nodeType==1)&&(node.tagName == "userdata"))
 {var name=node.getAttribute("name");if ((name)&&(node.childNodes[0]))
 this.setUserData(parentId,name,node.childNodes[0].data);}
 }
 dhtmlXTreeObject.prototype._redrawFrom=function(dhtmlObject,itemObject,start,visMode){if (!itemObject){var tempx=dhtmlObject._globalIdStorageFind(dhtmlObject.lastLoadedXMLId);dhtmlObject.lastLoadedXMLId=-1;if (!tempx)return 0;}
 else tempx=itemObject;var acc=0;for (var i=(start?start-1:0);i<tempx.childsCount;i++)
 {if ((!this._branchUpdate)||(this._getOpenState(tempx)==1))
 if ((!itemObject)||(visMode==1)) tempx.childNodes[i].htmlNode.parentNode.parentNode.style.display="";if (tempx.childNodes[i].openMe==1){this._openItem(tempx.childNodes[i]);tempx.childNodes[i].openMe=0;}
 dhtmlObject._redrawFrom(dhtmlObject,tempx.childNodes[i]);};if ((!tempx.unParsed)&&((tempx.XMLload)||(!this.XMLsource)))
 tempx._acc=acc;dhtmlObject._correctLine(tempx);dhtmlObject._correctPlus(tempx);};dhtmlXTreeObject.prototype._createSelf=function(){var div=document.createElement('div');div.className="containerTableStyle";div.style.width=this.width;div.style.height=this.height;this.parentObject.appendChild(div);return div;};dhtmlXTreeObject.prototype._xcloseAll=function(itemObject)
 {if (itemObject.unParsed)return;if (this.rootId!=itemObject.id){if (!itemObject.htmlNode)return;var Nodes=itemObject.htmlNode.childNodes[0].childNodes;var Count=Nodes.length;for (var i=1;i<Count;i++)Nodes[i].style.display="none";this._correctPlus(itemObject);}
 for (var i=0;i<itemObject.childsCount;i++)if (itemObject.childNodes[i].childsCount)this._xcloseAll(itemObject.childNodes[i]);};dhtmlXTreeObject.prototype._xopenAll=function(itemObject)
 {this._HideShow(itemObject,2);for (var i=0;i<itemObject.childsCount;i++)this._xopenAll(itemObject.childNodes[i]);};dhtmlXTreeObject.prototype._correctPlus=function(itemObject){if (!itemObject.htmlNode)return;var imsrc=itemObject.htmlNode.childNodes[0].childNodes[0].childNodes[0].lastChild;var imsrc2=itemObject.htmlNode.childNodes[0].childNodes[0].childNodes[2].childNodes[0];var workArray=this.lineArray;if ((this.XMLsource)&&(!itemObject.XMLload))
 {var workArray=this.plusArray;this._setSrc(imsrc2,this.iconURL+itemObject.images[2]);if (this._txtimg)return (imsrc.innerHTML="[+]");}
 else
 if ((itemObject.childsCount)||(itemObject.unParsed))
 {if ((itemObject.htmlNode.childNodes[0].childNodes[1])&&( itemObject.htmlNode.childNodes[0].childNodes[1].style.display!="none" ))
 {if (!itemObject.wsign)var workArray=this.minusArray;this._setSrc(imsrc2,this.iconURL+itemObject.images[1]);if (this._txtimg)return (imsrc.innerHTML="[-]");}
 else
 {if (!itemObject.wsign)var workArray=this.plusArray;this._setSrc(imsrc2,this.iconURL+itemObject.images[2]);if (this._txtimg)return (imsrc.innerHTML="[+]");}
 }
 else
 {this._setSrc(imsrc2,this.iconURL+itemObject.images[0]);}
 var tempNum=2;if (!itemObject.treeNod.treeLinesOn)this._setSrc(imsrc,this.imPath+workArray[3]);else {if (itemObject.parentObject)tempNum=this._getCountStatus(itemObject.id,itemObject.parentObject);this._setSrc(imsrc,this.imPath+workArray[tempNum]);}
 };dhtmlXTreeObject.prototype._correctLine=function(itemObject){if (!itemObject.htmlNode)return;var sNode=itemObject.parentObject;if (sNode)if ((this._getLineStatus(itemObject.id,sNode)==0)||(!this.treeLinesOn))
 for(var i=1;i<=itemObject.childsCount;i++){if (!itemObject.htmlNode.childNodes[0].childNodes[i])break;itemObject.htmlNode.childNodes[0].childNodes[i].childNodes[0].style.backgroundImage="";itemObject.htmlNode.childNodes[0].childNodes[i].childNodes[0].style.backgroundRepeat="";}
 else
 for(var i=1;i<=itemObject.childsCount;i++){if (!itemObject.htmlNode.childNodes[0].childNodes[i])break;itemObject.htmlNode.childNodes[0].childNodes[i].childNodes[0].style.backgroundImage="url("+this.imPath+this.lineArray[5]+")";itemObject.htmlNode.childNodes[0].childNodes[i].childNodes[0].style.backgroundRepeat="repeat-y";}
 };dhtmlXTreeObject.prototype._getCountStatus=function(itemId,itemObject){if (itemObject.childsCount<=1){if (itemObject.id==this.rootId)return 4;else return 0;}
 if (itemObject.childNodes[0].id==itemId)if (itemObject.id==this.rootId)return 2;else return 1;if (itemObject.childNodes[itemObject.childsCount-1].id==itemId)return 0;return 1;};dhtmlXTreeObject.prototype._getLineStatus =function(itemId,itemObject){if (itemObject.childNodes[itemObject.childsCount-1].id==itemId)return 0;return 1;}
 
 dhtmlXTreeObject.prototype._HideShow=function(itemObject,mode){if ((this.XMLsource)&&(!itemObject.XMLload)) {if (mode==1)return;itemObject.XMLload=1;this._loadDynXML(itemObject.id);return;};var Nodes=itemObject.htmlNode.childNodes[0].childNodes;var Count=Nodes.length;if (Count>1){if ( ( (Nodes[1].style.display!="none")|| (mode==1) ) && (mode!=2) ) {this.allTree.childNodes[0].border = "1";this.allTree.childNodes[0].border = "0";nodestyle="none";}
 else nodestyle="";for (var i=1;i<Count;i++)Nodes[i].style.display=nodestyle;}
 this._correctPlus(itemObject);}
 dhtmlXTreeObject.prototype._getOpenState=function(itemObject){if (!itemObject.htmlNode)return 0;var z=itemObject.htmlNode.childNodes[0].childNodes;if (z.length<=1)return 0;if (z[1].style.display!="none")return 1;else return -1;}
 

 
 dhtmlXTreeObject.prototype.onRowClick2=function(){var that=this.parentObject.treeNod;if (!that.callEvent("onDblClick",[this.parentObject.id,that])) return false;if ((this.parentObject.closeble)&&(this.parentObject.closeble!="0"))
 that._HideShow(this.parentObject);else
 that._HideShow(this.parentObject,2);if (that.checkEvent("onOpenEnd"))
 if (!that.xmlstate)that.callEvent("onOpenEnd",[this.parentObject.id,that._getOpenState(this.parentObject)]);else{that._oie_onXLE.push(that.onXLE);that.onXLE=that._epnFHe;}
 return false;};dhtmlXTreeObject.prototype.onRowClick=function(){var that=this.parentObject.treeNod;if (!that.callEvent("onOpenStart",[this.parentObject.id,that._getOpenState(this.parentObject)])) return 0;if ((this.parentObject.closeble)&&(this.parentObject.closeble!="0"))
 that._HideShow(this.parentObject);else
 that._HideShow(this.parentObject,2);if (that.checkEvent("onOpenEnd"))
 if (!that.xmlstate)that.callEvent("onOpenEnd",[this.parentObject.id,that._getOpenState(this.parentObject)]);else{that._oie_onXLE.push(that.onXLE);that.onXLE=that._epnFHe;}
 };dhtmlXTreeObject.prototype._epnFHe=function(that,id,flag){if (id!=this.rootId)this.callEvent("onOpenEnd",[id,that.getOpenState(id)]);that.onXLE=that._oie_onXLE.pop();if (!flag && !that._oie_onXLE.length)if (that.onXLE)that.onXLE(that,id);}
 dhtmlXTreeObject.prototype.onRowClickDown=function(e){e=e||window.event;var that=this.parentObject.treeNod;that._selectItem(this.parentObject,e);};dhtmlXTreeObject.prototype.getSelectedItemId=function()
 {var str=new Array();for (var i=0;i<this._selected.length;i++)str[i]=this._selected[i].id;return (str.join(this.dlmtr));};dhtmlXTreeObject.prototype._selectItem=function(node,e){if (this.checkEvent("onSelect")) this._onSSCFold=this.getSelectedItemId();this._unselectItems();this._markItem(node);if (this.checkEvent("onSelect")) {var z=this.getSelectedItemId();if (z!=this._onSSCFold)this.callEvent("onSelect",[z]);}
 }
 dhtmlXTreeObject.prototype._markItem=function(node){if (node.scolor)node.span.style.color=node.scolor;node.span.className="selectedTreeRow";node.i_sel=true;this._selected[this._selected.length]=node;}
 dhtmlXTreeObject.prototype.getIndexById=function(itemId){var z=this._globalIdStorageFind(itemId);if (!z)return null;return this._getIndex(z);};dhtmlXTreeObject.prototype._getIndex=function(w){var z=w.parentObject;for (var i=0;i<z.childsCount;i++)if (z.childNodes[i]==w)return i;};dhtmlXTreeObject.prototype._unselectItem=function(node){if ((node)&&(node.i_sel))
 {node.span.className="standartTreeRow";if (node.acolor)node.span.style.color=node.acolor;node.i_sel=false;for (var i=0;i<this._selected.length;i++)if (!this._selected[i].i_sel){this._selected.splice(i,1);break;}
 }
 }
 dhtmlXTreeObject.prototype._unselectItems=function(){for (var i=0;i<this._selected.length;i++){var node=this._selected[i];node.span.className="standartTreeRow";if (node.acolor)node.span.style.color=node.acolor;node.i_sel=false;}
 this._selected=new Array();}
 dhtmlXTreeObject.prototype.onRowSelect=function(e,htmlObject,mode){e=e||window.event;var obj=this.parentObject;if (htmlObject)obj=htmlObject.parentObject;var that=obj.treeNod;var lastId=that.getSelectedItemId();if ((!e)||(!e.skipUnSel))
 that._selectItem(obj,e);if (!mode){if (obj.actionHandler)obj.actionHandler(obj.id,lastId);else that.callEvent("onClick",[obj.id,lastId]);}
 };dhtmlXTreeObject.prototype._correctCheckStates=function(dhtmlObject){if (!this.tscheck)return;if (!dhtmlObject)return;if (dhtmlObject.id==this.rootId)return;var act=dhtmlObject.childNodes;var flag1=0;var flag2=0;if (dhtmlObject.childsCount==0)return;for (var i=0;i<dhtmlObject.childsCount;i++){if (act[i].dscheck)continue;if (act[i].checkstate==0)flag1=1;else if (act[i].checkstate==1)flag2=1;else {flag1=1;flag2=1;break;}
 }
 if ((flag1)&&(flag2)) this._setCheck(dhtmlObject,"unsure");else if (flag1)this._setCheck(dhtmlObject,false);else this._setCheck(dhtmlObject,true);this._correctCheckStates(dhtmlObject.parentObject);}
 
 dhtmlXTreeObject.prototype.onCheckBoxClick=function(e){if (!this.treeNod.callEvent("onBeforeCheck",[this.parentObject.id,this.parentObject.checkstate]))
 return;if (this.parentObject.dscheck)return true;if (this.treeNod.tscheck)if (this.parentObject.checkstate==1)this.treeNod._setSubChecked(false,this.parentObject);else this.treeNod._setSubChecked(true,this.parentObject);else
 if (this.parentObject.checkstate==1)this.treeNod._setCheck(this.parentObject,false);else this.treeNod._setCheck(this.parentObject,true);this.treeNod._correctCheckStates(this.parentObject.parentObject);return this.treeNod.callEvent("onCheck",[this.parentObject.id,this.parentObject.checkstate]);};dhtmlXTreeObject.prototype._createItem=function(acheck,itemObject,mode){var table=document.createElement('table');table.cellSpacing=0;table.cellPadding=0;table.border=0;if(this.hfMode)table.style.tableLayout="fixed";table.style.margin=0;table.style.padding=0;var tbody=document.createElement('tbody');var tr=document.createElement('tr');var td1=document.createElement('td');td1.className="standartTreeImage";if(this._txtimg){var img0=document.createElement("div");td1.appendChild(img0);img0.className="dhx_tree_textSign";}
 else
 {var img0=this._getImg(itemObject.id);img0.border="0";if (img0.tagName=="IMG")img0.align="absmiddle";td1.appendChild(img0);img0.style.padding=0;img0.style.margin=0;img0.style.width=this.def_line_img_x;img0.style.height=this.def_line_img_y;}
 var td11=document.createElement('td');var inp=this._getImg(this.cBROf?this.rootId:itemObject.id);inp.checked=0;this._setSrc(inp,this.imPath+this.checkArray[0]);inp.style.width="16px";inp.style.height="16px";if (!acheck)td11.style.display="none";td11.appendChild(inp);if ((!this.cBROf)&&(inp.tagName=="IMG")) inp.align="absmiddle";inp.onclick=this.onCheckBoxClick;inp.treeNod=this;inp.parentObject=itemObject;if (!window._KHTMLrv)td11.width="20px";else td11.width="16px";var td12=document.createElement('td');td12.className="standartTreeImage";var img=this._getImg(this.timgen?itemObject.id:this.rootId);img.onmousedown=this._preventNsDrag;img.ondragstart=this._preventNsDrag;img.border="0";if (this._aimgs){img.parentObject=itemObject;if (img.tagName=="IMG")img.align="absmiddle";img.onclick=this.onRowSelect;}
 if (!mode)this._setSrc(img,this.iconURL+this.imageArray[0]);td12.appendChild(img);img.style.padding=0;img.style.margin=0;if (this.timgen){td12.style.width=img.style.width=this.def_img_x;img.style.height=this.def_img_y;}
 else
 {img.style.width="0px";img.style.height="0px";if (_isOpera || window._KHTMLrv )td12.style.display="none";}
 var td2=document.createElement('td');td2.className="standartTreeRow";itemObject.span=document.createElement('span');itemObject.span.className="standartTreeRow";if (this.mlitems){itemObject.span.style.width=this.mlitems;itemObject.span.style.display="block";}
 else td2.noWrap=true;if (_isIE && _isIE>7)td2.style.width="999999px";else if (!window._KHTMLrv)td2.style.width="100%";itemObject.span.innerHTML=itemObject.label;td2.appendChild(itemObject.span);td2.parentObject=itemObject;td1.parentObject=itemObject;td2.onclick=this.onRowSelect;td1.onclick=this.onRowClick;td2.ondblclick=this.onRowClick2;if (this.ettip)tr.title=itemObject.label;if (this.dragAndDropOff){if (this._aimgs){this.dragger.addDraggableItem(td12,this);td12.parentObject=itemObject;}
 this.dragger.addDraggableItem(td2,this);}
 itemObject.span.style.paddingLeft="5px";itemObject.span.style.paddingRight="5px";td2.style.verticalAlign="";td2.style.fontSize="10pt";td2.style.cursor=this.style_pointer;tr.appendChild(td1);tr.appendChild(td11);tr.appendChild(td12);tr.appendChild(td2);tbody.appendChild(tr);table.appendChild(tbody);if (this.ehlt || this.checkEvent("onMouseIn")|| this.checkEvent("onMouseOut")){tr.onmousemove=this._itemMouseIn;tr[(_isIE)?"onmouseleave":"onmouseout"]=this._itemMouseOut;}
 return table;};dhtmlXTreeObject.prototype.setImagePath=function( newPath ){this.imPath=newPath;this.iconURL=newPath;};dhtmlXTreeObject.prototype.setIconPath=function(path){this.iconURL=path;}




 dhtmlXTreeObject.prototype.setOnRightClickHandler=function(func){this.attachEvent("onRightClick",func);};dhtmlXTreeObject.prototype.setOnClickHandler=function(func){this.attachEvent("onClick",func);};dhtmlXTreeObject.prototype.setOnSelectStateChange=function(func){this.attachEvent("onSelect",func);};dhtmlXTreeObject.prototype.setXMLAutoLoading=function(filePath){this.XMLsource=filePath;};dhtmlXTreeObject.prototype.setOnCheckHandler=function(func){this.attachEvent("onCheck",func);};dhtmlXTreeObject.prototype.setOnOpenHandler=function(func){this.attachEvent("onOpenStart",func);};dhtmlXTreeObject.prototype.setOnOpenStartHandler=function(func){this.attachEvent("onOpenStart",func);};dhtmlXTreeObject.prototype.setOnOpenEndHandler=function(func){this.attachEvent("onOpenEnd",func);};dhtmlXTreeObject.prototype.setOnDblClickHandler=function(func){this.attachEvent("onDblClick",func);};dhtmlXTreeObject.prototype.openAllItems=function(itemId)
 {var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;this._xopenAll(temp);};dhtmlXTreeObject.prototype.getOpenState=function(itemId){var temp=this._globalIdStorageFind(itemId);if (!temp)return "";return this._getOpenState(temp);};dhtmlXTreeObject.prototype.closeAllItems=function(itemId)
 {if (itemId===window.undefined)itemId=this.rootId;var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;this._xcloseAll(temp);this.allTree.childNodes[0].border = "1";this.allTree.childNodes[0].border = "0";};dhtmlXTreeObject.prototype.setUserData=function(itemId,name,value){var sNode=this._globalIdStorageFind(itemId,0,true);if (!sNode)return;if(name=="hint")sNode.htmlNode.childNodes[0].childNodes[0].title=value;if (typeof(sNode.userData["t_"+name])=="undefined"){if (!sNode._userdatalist)sNode._userdatalist=name;else sNode._userdatalist+=","+name;}
 sNode.userData["t_"+name]=value;};dhtmlXTreeObject.prototype.getUserData=function(itemId,name){var sNode=this._globalIdStorageFind(itemId,0,true);if (!sNode)return;return sNode.userData["t_"+name];};dhtmlXTreeObject.prototype.getItemColor=function(itemId)
 {var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;var res= new Object();if (temp.acolor)res.acolor=temp.acolor;if (temp.scolor)res.scolor=temp.scolor;return res;};dhtmlXTreeObject.prototype.setItemColor=function(itemId,defaultColor,selectedColor)
 {if ((itemId)&&(itemId.span))
 var temp=itemId;else
 var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;else {if (temp.i_sel){if (selectedColor)temp.span.style.color=selectedColor;}
 else
 {if (defaultColor)temp.span.style.color=defaultColor;}
 if (selectedColor)temp.scolor=selectedColor;if (defaultColor)temp.acolor=defaultColor;}
 };dhtmlXTreeObject.prototype.getItemText=function(itemId)
 {var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;return(temp.htmlNode.childNodes[0].childNodes[0].childNodes[3].childNodes[0].innerHTML);};dhtmlXTreeObject.prototype.getParentId=function(itemId)
 {var temp=this._globalIdStorageFind(itemId);if ((!temp)||(!temp.parentObject)) return "";return temp.parentObject.id;};dhtmlXTreeObject.prototype.changeItemId=function(itemId,newItemId)
 {if (itemId==newItemId)return;var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;temp.id=newItemId;temp.span.contextMenuId=newItemId;this._idpull[newItemId]=this._idpull[itemId];delete this._idpull[itemId];};dhtmlXTreeObject.prototype.doCut=function(){if (this.nodeCut)this.clearCut();this.nodeCut=(new Array()).concat(this._selected);for (var i=0;i<this.nodeCut.length;i++){var tempa=this.nodeCut[i];tempa._cimgs=new Array();tempa._cimgs[0]=tempa.images[0];tempa._cimgs[1]=tempa.images[1];tempa._cimgs[2]=tempa.images[2];tempa.images[0]=tempa.images[1]=tempa.images[2]=this.cutImage;this._correctPlus(tempa);}
 };dhtmlXTreeObject.prototype.doPaste=function(itemId){var tobj=this._globalIdStorageFind(itemId);if (!tobj)return 0;for (var i=0;i<this.nodeCut.length;i++){if (this._checkPNodes(tobj,this.nodeCut[i])) continue;this._moveNode(this.nodeCut[i],tobj);}
 this.clearCut();};dhtmlXTreeObject.prototype.clearCut=function(){for (var i=0;i<this.nodeCut.length;i++){var tempa=this.nodeCut[i];tempa.images[0]=tempa._cimgs[0];tempa.images[1]=tempa._cimgs[1];tempa.images[2]=tempa._cimgs[2];this._correctPlus(tempa);}
 this.nodeCut=new Array();};dhtmlXTreeObject.prototype._moveNode=function(itemObject,targetObject){return this._moveNodeTo(itemObject,targetObject);}
 

dhtmlXTreeObject.prototype._fixNodesCollection=function(target,zParent){var flag=0;var icount=0;var Nodes=target.childNodes;var Count=target.childsCount-1;if (zParent==Nodes[Count])return;for (var i=0;i<Count;i++)if (Nodes[i]==Nodes[Count]){Nodes[i]=Nodes[i+1];Nodes[i+1]=Nodes[Count];}
 for (var i=0;i<Count+1;i++){if (flag){var temp=Nodes[i];Nodes[i]=flag;flag=temp;}
 else 
 if (Nodes[i]==zParent){flag=Nodes[i];Nodes[i]=Nodes[Count];}
 }
 };dhtmlXTreeObject.prototype._recreateBranch=function(itemObject,targetObject,beforeNode,level){var i;var st="";if (beforeNode){for (i=0;i<targetObject.childsCount;i++)if (targetObject.childNodes[i]==beforeNode)break;if (i!=0)beforeNode=targetObject.childNodes[i-1];else{st="TOP";beforeNode="";}
 }
 var t2=this._onradh;this._onradh=null;var newNode=this._attachChildNode(targetObject,itemObject.id,itemObject.label,0,itemObject.images[0],itemObject.images[1],itemObject.images[2],st,0,beforeNode);newNode._userdatalist=itemObject._userdatalist;newNode.userData=itemObject.userData.clone();if(itemObject._attrs){newNode._attrs={};for(var attr in itemObject._attrs)newNode._attrs[attr] = itemObject._attrs[attr];}
 newNode.XMLload=itemObject.XMLload;if (t2){this._onradh=t2;this._onradh(newNode.id);}
 for (var i=0;i<itemObject.childsCount;i++)this._recreateBranch(itemObject.childNodes[i],newNode,0,1);return newNode;}
 dhtmlXTreeObject.prototype._moveNodeTo=function(itemObject,targetObject,beforeNode){if (itemObject.treeNod._nonTrivialNode)return itemObject.treeNod._nonTrivialNode(this,targetObject,beforeNode,itemObject);if (this._checkPNodes(targetObject,itemObject))
 return false;if (targetObject.mytype)var framesMove=(itemObject.treeNod.lWin!=targetObject.lWin);else
 var framesMove=(itemObject.treeNod.lWin!=targetObject.treeNod.lWin);if (!this.callEvent("onDrag",[itemObject.id,targetObject.id,(beforeNode?beforeNode.id:null),itemObject.treeNod,targetObject.treeNod])) return false;if ((targetObject.XMLload==0)&&(this.XMLsource))
 {targetObject.XMLload=1;this._loadDynXML(targetObject.id);}
 this.openItem(targetObject.id);var oldTree=itemObject.treeNod;var c=itemObject.parentObject.childsCount;var z=itemObject.parentObject;if ((framesMove)||(oldTree.dpcpy)) {var _otiid=itemObject.id;itemObject=this._recreateBranch(itemObject,targetObject,beforeNode);if (!oldTree.dpcpy)oldTree.deleteItem(_otiid);}
 else
 {var Count=targetObject.childsCount;var Nodes=targetObject.childNodes;if (Count==0)targetObject._open=true;oldTree._unselectItem(itemObject);Nodes[Count]=itemObject;itemObject.treeNod=targetObject.treeNod;targetObject.childsCount++;var tr=this._drawNewTr(Nodes[Count].htmlNode);if (!beforeNode){targetObject.htmlNode.childNodes[0].appendChild(tr);if (this.dadmode==1)this._fixNodesCollection(targetObject,beforeNode);}
 else
 {targetObject.htmlNode.childNodes[0].insertBefore(tr,beforeNode.tr);this._fixNodesCollection(targetObject,beforeNode);Nodes=targetObject.childNodes;}
 
 }
 if ((!oldTree.dpcpy)&&(!framesMove)) {var zir=itemObject.tr;if ((document.all)&&(navigator.appVersion.search(/MSIE\ 5\.0/gi)!=-1))
 {window.setTimeout(function() {zir.parentNode.removeChild(zir);}, 250 );}
 else 

 itemObject.parentObject.htmlNode.childNodes[0].removeChild(itemObject.tr);if ((!beforeNode)||(targetObject!=itemObject.parentObject)){for (var i=0;i<z.childsCount;i++){if (z.childNodes[i].id==itemObject.id){z.childNodes[i]=0;break;}}}
 else z.childNodes[z.childsCount-1]=0;oldTree._compressChildList(z.childsCount,z.childNodes);z.childsCount--;}
 if ((!framesMove)&&(!oldTree.dpcpy)) {itemObject.tr=tr;tr.nodem=itemObject;itemObject.parentObject=targetObject;if (oldTree!=targetObject.treeNod){if(itemObject.treeNod._registerBranch(itemObject,oldTree)) return;this._clearStyles(itemObject);this._redrawFrom(this,itemObject.parentObject);if(this._onradh)this._onradh(itemObject.id);};this._correctPlus(targetObject);this._correctLine(targetObject);this._correctLine(itemObject);this._correctPlus(itemObject);if (beforeNode){this._correctPlus(beforeNode);}
 else 
 if (targetObject.childsCount>=2){this._correctPlus(Nodes[targetObject.childsCount-2]);this._correctLine(Nodes[targetObject.childsCount-2]);}
 
 this._correctPlus(Nodes[targetObject.childsCount-1]);if (this.tscheck)this._correctCheckStates(targetObject);if (oldTree.tscheck)oldTree._correctCheckStates(z);}
 

 if (c>1){oldTree._correctPlus(z.childNodes[c-2]);oldTree._correctLine(z.childNodes[c-2]);}
 oldTree._correctPlus(z);oldTree._correctLine(z);this.callEvent("onDrop",[itemObject.id,targetObject.id,(beforeNode?beforeNode.id:null),oldTree,targetObject.treeNod]);return itemObject.id;};dhtmlXTreeObject.prototype._clearStyles=function(itemObject){if (!itemObject.htmlNode)return;var td1=itemObject.htmlNode.childNodes[0].childNodes[0].childNodes[1];var td3=td1.nextSibling.nextSibling;itemObject.span.innerHTML=itemObject.label;itemObject.i_sel=false;if (itemObject._aimgs)this.dragger.removeDraggableItem(td1.nextSibling);if (this.checkBoxOff){td1.childNodes[0].style.display="";td1.childNodes[0].onclick=this.onCheckBoxClick;this._setSrc(td1.childNodes[0],this.imPath+this.checkArray[itemObject.checkstate]);}
 else td1.childNodes[0].style.display="none";td1.childNodes[0].treeNod=this;this.dragger.removeDraggableItem(td3);if (this.dragAndDropOff)this.dragger.addDraggableItem(td3,this);if (this._aimgs)this.dragger.addDraggableItem(td1.nextSibling,this);td3.childNodes[0].className="standartTreeRow";td3.onclick=this.onRowSelect;td3.ondblclick=this.onRowClick2;td1.previousSibling.onclick=this.onRowClick;this._correctLine(itemObject);this._correctPlus(itemObject);for (var i=0;i<itemObject.childsCount;i++)this._clearStyles(itemObject.childNodes[i]);};dhtmlXTreeObject.prototype._registerBranch=function(itemObject,oldTree){if (oldTree)oldTree._globalIdStorageSub(itemObject.id);itemObject.id=this._globalIdStorageAdd(itemObject.id,itemObject);itemObject.treeNod=this;for (var i=0;i<itemObject.childsCount;i++)this._registerBranch(itemObject.childNodes[i],oldTree);return 0;};dhtmlXTreeObject.prototype.enableThreeStateCheckboxes=function(mode) {this.tscheck=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.setOnMouseInHandler=function(func){this.ehlt=true;this.attachEvent("onMouseIn",func);};dhtmlXTreeObject.prototype.setOnMouseOutHandler=function(func){this.ehlt=true;this.attachEvent("onMouseOut",func);};dhtmlXTreeObject.prototype.enableTreeImages=function(mode) {this.timgen=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.enableFixedMode=function(mode) {this.hfMode=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.enableCheckBoxes=function(mode, hidden){this.checkBoxOff=convertStringToBoolean(mode);this.cBROf=(!(this.checkBoxOff||convertStringToBoolean(hidden)));};dhtmlXTreeObject.prototype.setStdImages=function(image1,image2,image3){this.imageArray[0]=image1;this.imageArray[1]=image2;this.imageArray[2]=image3;};dhtmlXTreeObject.prototype.enableTreeLines=function(mode){this.treeLinesOn=convertStringToBoolean(mode);}
 
 dhtmlXTreeObject.prototype.setImageArrays=function(arrayName,image1,image2,image3,image4,image5){switch(arrayName){case "plus": this.plusArray[0]=image1;this.plusArray[1]=image2;this.plusArray[2]=image3;this.plusArray[3]=image4;this.plusArray[4]=image5;break;case "minus": this.minusArray[0]=image1;this.minusArray[1]=image2;this.minusArray[2]=image3;this.minusArray[3]=image4;this.minusArray[4]=image5;break;}
 };dhtmlXTreeObject.prototype.openItem=function(itemId){var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;else return this._openItem(temp);};dhtmlXTreeObject.prototype._openItem=function(item){var state=this._getOpenState(item);if ((state<0)||(((this.XMLsource)&&(!item.XMLload)))){if (!this.callEvent("onOpenStart",[item.id,state])) return 0;this._HideShow(item,2);if (this.checkEvent("onOpenEnd")){if (this.onXLE==this._epnFHe)this._epnFHe(this,item.id,true);if (!this.xmlstate || !this.XMLsource)this.callEvent("onOpenEnd",[item.id,this._getOpenState(item)]);else{this._oie_onXLE.push(this.onXLE);this.onXLE=this._epnFHe;}
 }
 }else if (this._srnd)this._HideShow(item,2);if (item.parentObject && !this._skip_open_parent)this._openItem(item.parentObject);};dhtmlXTreeObject.prototype.closeItem=function(itemId){if (this.rootId==itemId)return 0;var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;if (temp.closeble)this._HideShow(temp,1);};dhtmlXTreeObject.prototype.getLevel=function(itemId){var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;return this._getNodeLevel(temp,0);};dhtmlXTreeObject.prototype.setItemCloseable=function(itemId,flag)
 {flag=convertStringToBoolean(flag);if ((itemId)&&(itemId.span)) 
 var temp=itemId;else 
 var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;temp.closeble=flag;};dhtmlXTreeObject.prototype._getNodeLevel=function(itemObject,count){if (itemObject.parentObject)return this._getNodeLevel(itemObject.parentObject,count+1);return(count);};dhtmlXTreeObject.prototype.hasChildren=function(itemId){var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;else 
 {if ( (this.XMLsource)&&(!temp.XMLload) ) return true;else 
 return temp.childsCount;};};dhtmlXTreeObject.prototype._getLeafCount=function(itemNode){var a=0;for (var b=0;b<itemNode.childsCount;b++)if (itemNode.childNodes[b].childsCount==0)a++;return a;}
 

 dhtmlXTreeObject.prototype.setItemText=function(itemId,newLabel,newTooltip)
 {var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;temp.label=newLabel;temp.span.innerHTML=newLabel;temp.span.parentNode.parentNode.title=newTooltip||"";};dhtmlXTreeObject.prototype.getItemTooltip=function(itemId){var temp=this._globalIdStorageFind(itemId);if (!temp)return "";return (temp.span.parentNode.parentNode._dhx_title||temp.span.parentNode.parentNode.title||"");};dhtmlXTreeObject.prototype.refreshItem=function(itemId){if (!itemId)itemId=this.rootId;var temp=this._globalIdStorageFind(itemId);this.deleteChildItems(itemId);this._loadDynXML(itemId);};dhtmlXTreeObject.prototype.setItemImage2=function(itemId, image1,image2,image3){var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;temp.images[1]=image2;temp.images[2]=image3;temp.images[0]=image1;this._correctPlus(temp);};dhtmlXTreeObject.prototype.setItemImage=function(itemId,image1,image2)
 {var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;if (image2){temp.images[1]=image1;temp.images[2]=image2;}
 else temp.images[0]=image1;this._correctPlus(temp);};dhtmlXTreeObject.prototype.getSubItems =function(itemId)
 {var temp=this._globalIdStorageFind(itemId,0,1);if (!temp)return 0;var z="";for (i=0;i<temp.childsCount;i++){if (!z)z= ""+temp.childNodes[i].id;else z+=this.dlmtr+temp.childNodes[i].id;}
 return z;};dhtmlXTreeObject.prototype._getAllScraggyItems =function(node)
 {var z="";for (var i=0;i<node.childsCount;i++){if ((node.childNodes[i].unParsed)||(node.childNodes[i].childsCount>0))
 {if (node.childNodes[i].unParsed)var zb=this._getAllScraggyItemsXML(node.childNodes[i].unParsed,1);else
 var zb=this._getAllScraggyItems(node.childNodes[i])

 if (zb)if (z)z+=this.dlmtr+zb;else z=zb;}
 else
 if (!z)z=""+node.childNodes[i].id;else z+=this.dlmtr+node.childNodes[i].id;}
 return z;};dhtmlXTreeObject.prototype._getAllFatItems =function(node)
 {var z="";for (var i=0;i<node.childsCount;i++){if ((node.childNodes[i].unParsed)||(node.childNodes[i].childsCount>0))
 {if (!z)z=""+node.childNodes[i].id;else z+=this.dlmtr+node.childNodes[i].id;if (node.childNodes[i].unParsed)var zb=this._getAllFatItemsXML(node.childNodes[i].unParsed,1);else
 var zb=this._getAllFatItems(node.childNodes[i])

 if (zb)z+=this.dlmtr+zb;}
 }
 return z;};dhtmlXTreeObject.prototype._getAllSubItems =function(itemId,z,node)
 {if (node)temp=node;else {var temp=this._globalIdStorageFind(itemId);};if (!temp)return 0;z="";for (var i=0;i<temp.childsCount;i++){if (!z)z=""+temp.childNodes[i].id;else z+=this.dlmtr+temp.childNodes[i].id;var zb=this._getAllSubItems(0,z,temp.childNodes[i])

 if (zb)z+=this.dlmtr+zb;}
 return z;};dhtmlXTreeObject.prototype.selectItem=function(itemId,mode,preserve){mode=convertStringToBoolean(mode);var temp=this._globalIdStorageFind(itemId);if ((!temp)||(!temp.parentObject)) return 0;if (this.XMLloadingWarning)temp.parentObject.openMe=1;else
 this._openItem(temp.parentObject);var ze=null;if (preserve){ze=new Object;ze.ctrlKey=true;if (temp.i_sel)ze.skipUnSel=true;}
 if (mode)this.onRowSelect(ze,temp.htmlNode.childNodes[0].childNodes[0].childNodes[3],false);else
 this.onRowSelect(ze,temp.htmlNode.childNodes[0].childNodes[0].childNodes[3],true);};dhtmlXTreeObject.prototype.getSelectedItemText=function()
 {var str=new Array();for (var i=0;i<this._selected.length;i++)str[i]=this._selected[i].span.innerHTML;return (str.join(this.dlmtr));};dhtmlXTreeObject.prototype._compressChildList=function(Count,Nodes)
 {Count--;for (var i=0;i<Count;i++){if (Nodes[i]==0){Nodes[i]=Nodes[i+1];Nodes[i+1]=0;}
 };};dhtmlXTreeObject.prototype._deleteNode=function(itemId,htmlObject,skip){if ((!htmlObject)||(!htmlObject.parentObject)) return 0;var tempos=0;var tempos2=0;if (htmlObject.tr.nextSibling)tempos=htmlObject.tr.nextSibling.nodem;if (htmlObject.tr.previousSibling)tempos2=htmlObject.tr.previousSibling.nodem;var sN=htmlObject.parentObject;var Count=sN.childsCount;var Nodes=sN.childNodes;for (var i=0;i<Count;i++){if (Nodes[i].id==itemId){if (!skip)sN.htmlNode.childNodes[0].removeChild(Nodes[i].tr);Nodes[i]=0;break;}
 }
 this._compressChildList(Count,Nodes);if (!skip){sN.childsCount--;}
 if (tempos){this._correctPlus(tempos);this._correctLine(tempos);}
 if (tempos2){this._correctPlus(tempos2);this._correctLine(tempos2);}
 if (this.tscheck)this._correctCheckStates(sN);if (!skip){this._globalIdStorageRecSub(htmlObject);}
 };dhtmlXTreeObject.prototype.setCheck=function(itemId,state){var sNode=this._globalIdStorageFind(itemId,0,1);if (!sNode)return;if (state==="unsure")this._setCheck(sNode,state);else
 {state=convertStringToBoolean(state);if ((this.tscheck)&&(this.smcheck)) this._setSubChecked(state,sNode);else this._setCheck(sNode,state);}
 if (this.smcheck)this._correctCheckStates(sNode.parentObject);};dhtmlXTreeObject.prototype._setCheck=function(sNode,state){if (!sNode)return;if (((sNode.parentObject._r_logic)||(this._frbtr))&&(state))
 if (this._frbtrs){if (this._frbtrL)this.setCheck(this._frbtrL.id,0);this._frbtrL=sNode;}else
 for (var i=0;i<sNode.parentObject.childsCount;i++)this._setCheck(sNode.parentObject.childNodes[i],0);var z=sNode.htmlNode.childNodes[0].childNodes[0].childNodes[1].childNodes[0];if (state=="unsure")sNode.checkstate=2;else if (state)sNode.checkstate=1;else sNode.checkstate=0;if (sNode.dscheck)sNode.checkstate=sNode.dscheck;this._setSrc(z,this.imPath+((sNode.parentObject._r_logic||this._frbtr)?this.radioArray:this.checkArray)[sNode.checkstate]);};dhtmlXTreeObject.prototype.setSubChecked=function(itemId,state){var sNode=this._globalIdStorageFind(itemId);this._setSubChecked(state,sNode);this._correctCheckStates(sNode.parentObject);}
 dhtmlXTreeObject.prototype._setSubChecked=function(state,sNode){state=convertStringToBoolean(state);if (!sNode)return;if (((sNode.parentObject._r_logic)||(this._frbtr))&&(state))
 for (var i=0;i<sNode.parentObject.childsCount;i++)this._setSubChecked(0,sNode.parentObject.childNodes[i]);if (sNode._r_logic||this._frbtr)this._setSubChecked(state,sNode.childNodes[0]);else
 for (var i=0;i<sNode.childsCount;i++){this._setSubChecked(state,sNode.childNodes[i]);};var z=sNode.htmlNode.childNodes[0].childNodes[0].childNodes[1].childNodes[0];if (state)sNode.checkstate=1;else sNode.checkstate=0;if (sNode.dscheck)sNode.checkstate=sNode.dscheck;this._setSrc(z,this.imPath+((sNode.parentObject._r_logic||this._frbtr)?this.radioArray:this.checkArray)[sNode.checkstate]);};dhtmlXTreeObject.prototype.isItemChecked=function(itemId){var sNode=this._globalIdStorageFind(itemId);if (!sNode)return;return sNode.checkstate;};dhtmlXTreeObject.prototype.deleteChildItems=function(itemId)
 {var sNode=this._globalIdStorageFind(itemId);if (!sNode)return;var j=sNode.childsCount;for (var i=0;i<j;i++){this._deleteNode(sNode.childNodes[0].id,sNode.childNodes[0]);};};dhtmlXTreeObject.prototype.deleteItem=function(itemId,selectParent){if ((!this._onrdlh)||(this._onrdlh(itemId))){var z=this._deleteItem(itemId,selectParent);}
 
 this.allTree.childNodes[0].border = "1";this.allTree.childNodes[0].border = "0";}
dhtmlXTreeObject.prototype._deleteItem=function(itemId,selectParent,skip){selectParent=convertStringToBoolean(selectParent);var sNode=this._globalIdStorageFind(itemId);if (!sNode)return;var pid=this.getParentId(itemId);var zTemp=sNode.parentObject;this._deleteNode(itemId,sNode,skip);if(this._editCell&&this._editCell.id==itemId)this._editCell = null;this._correctPlus(zTemp);this._correctLine(zTemp);if ((selectParent)&&(pid!=this.rootId)) this.selectItem(pid,1);return zTemp;};dhtmlXTreeObject.prototype._globalIdStorageRecSub=function(itemObject){for(var i=0;i<itemObject.childsCount;i++){this._globalIdStorageRecSub(itemObject.childNodes[i]);this._globalIdStorageSub(itemObject.childNodes[i].id);};this._globalIdStorageSub(itemObject.id);var z=itemObject;z.span=null;z.tr.nodem=null;z.tr=null;z.htmlNode=null;};dhtmlXTreeObject.prototype.insertNewNext=function(itemId,newItemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children){var sNode=this._globalIdStorageFind(itemId);if ((!sNode)||(!sNode.parentObject)) return (0);var nodez=this._attachChildNode(0,newItemId,itemText,itemActionHandler,image1,image2,image3,optionStr,children,sNode);return nodez;};dhtmlXTreeObject.prototype.getItemIdByIndex=function(itemId,index){var z=this._globalIdStorageFind(itemId);if ((!z)||(index>=z.childsCount)) return null;return z.childNodes[index].id;};dhtmlXTreeObject.prototype.getChildItemIdByIndex=function(itemId,index){var z=this._globalIdStorageFind(itemId);if ((!z)||(index>=z.childsCount)) return null;return z.childNodes[index].id;};dhtmlXTreeObject.prototype.setDragHandler=function(func){this.attachEvent("onDrag",func);};dhtmlXTreeObject.prototype._clearMove=function(){if (this._lastMark){this._lastMark.className=this._lastMark.className.replace(/dragAndDropRow/g,"");this._lastMark=null;}
 this.allTree.className=this.allTree.className.replace(" selectionBox","");};dhtmlXTreeObject.prototype.enableDragAndDrop=function(mode,rmode){if (mode=="temporary_disabled"){this.dADTempOff=false;mode=true;}
 else
 this.dADTempOff=true;this.dragAndDropOff=convertStringToBoolean(mode);if (this.dragAndDropOff)this.dragger.addDragLanding(this.allTree,this);if (arguments.length>1)this._ddronr=(!convertStringToBoolean(rmode));};dhtmlXTreeObject.prototype._setMove=function(htmlNode,x,y){if (htmlNode.parentObject.span){var a1=getAbsoluteTop(htmlNode);var a2=getAbsoluteTop(this.allTree)-this.allTree.scrollTop;this.dadmodec=this.dadmode;this.dadmodefix=0;var zN=htmlNode.parentObject.span;zN.className+=" dragAndDropRow";this._lastMark=zN;this._autoScroll(null,a1,a2);}
 };dhtmlXTreeObject.prototype._autoScroll=function(node,a1,a2){if (this.autoScroll){if (node){a1=getAbsoluteTop(node);a2=getAbsoluteTop(this.allTree)-this.allTree.scrollTop;}
 
 if ( (a1-a2-parseInt(this.allTree.scrollTop))>(parseInt(this.allTree.offsetHeight)-50) )
 this.allTree.scrollTop=parseInt(this.allTree.scrollTop)+20;if ( (a1-a2)<(parseInt(this.allTree.scrollTop)+30) )
 this.allTree.scrollTop=parseInt(this.allTree.scrollTop)-20;}
}
dhtmlXTreeObject.prototype._createDragNode=function(htmlObject,e){if (!this.dADTempOff)return null;var obj=htmlObject.parentObject;if (!this.callEvent("onBeforeDrag",[obj.id, e])) return null;if (!obj.i_sel){this._selectItem(obj,e);}
 var dragSpan=document.createElement('div');var text=new Array();if (this._itim_dg)for (var i=0;i<this._selected.length;i++)text[i]="<table cellspacing='0' cellpadding='0'><tr><td><img width='18px' height='18px' src='"+this._getSrc(this._selected[i].span.parentNode.previousSibling.childNodes[0])+"'></td><td>"+this._selected[i].span.innerHTML+"</td></tr></table>";else
 text=this.getSelectedItemText().split(this.dlmtr);dragSpan.innerHTML=text.join("");dragSpan.style.position="absolute";dragSpan.className="dragSpanDiv";this._dragged=(new Array()).concat(this._selected);return dragSpan;}
dhtmlXTreeObject.prototype._focusNode=function(item){var z=getAbsoluteTop(item.htmlNode)-getAbsoluteTop(this.allTree);if ((z>(this.allTree.offsetHeight-30)) || (z<0))
 this.allTree.scrollTop=z+this.allTree.scrollTop;};dhtmlXTreeObject.prototype._preventNsDrag=function(e){if ((e)&&(e.preventDefault)) {e.preventDefault();return false;}
 return false;}
dhtmlXTreeObject.prototype._drag=function(sourceHtmlObject,dhtmlObject,targetHtmlObject){if (this._autoOpenTimer)clearTimeout(this._autoOpenTimer);if (!targetHtmlObject.parentObject){targetHtmlObject=this.htmlNode.htmlNode.childNodes[0].childNodes[0].childNodes[1].childNodes[0];this.dadmodec=0;}
 this._clearMove();var z=sourceHtmlObject.parentObject.treeNod;if ((z)&&(z._clearMove)) z._clearMove("");if ((!this.dragMove)||(this.dragMove()))
 {if ((!z)||(!z._clearMove)||(!z._dragged)) var col=new Array(sourceHtmlObject.parentObject);else var col=z._dragged;var trg=targetHtmlObject.parentObject;for (var i=0;i<col.length;i++){var newID=this._moveNode(col[i],trg);if ((this.dadmodec)&&(newID!==false)) trg=this._globalIdStorageFind(newID,true,true);if ((newID)&&(!this._sADnD)) this.selectItem(newID,0,1);}
 }
 if (z)z._dragged=new Array();}
dhtmlXTreeObject.prototype._dragIn=function(htmlObject,shtmlObject,x,y){if (!this.dADTempOff)return 0;var fobj=shtmlObject.parentObject;var tobj=htmlObject.parentObject;if ((!tobj)&&(this._ddronr)) return;if (!this.callEvent("onDragIn",[fobj.id,tobj?tobj.id:null,fobj.treeNod,this])){if (tobj)this._autoScroll(htmlObject);return 0;}
 

 if (!tobj)this.allTree.className+=" selectionBox";else
 {if (fobj.childNodes==null){this._setMove(htmlObject,x,y);return htmlObject;}
 var stree=fobj.treeNod;for (var i=0;i<stree._dragged.length;i++)if (this._checkPNodes(tobj,stree._dragged[i])){this._autoScroll(htmlObject);return 0;}
 this._setMove(htmlObject,x,y);if (this._getOpenState(tobj)<=0){this._autoOpenId=tobj.id;this._autoOpenTimer=window.setTimeout(new callerFunction(this._autoOpenItem,this),1000);}
 }
 
 return htmlObject;}
dhtmlXTreeObject.prototype._autoOpenItem=function(e,treeObject){treeObject.openItem(treeObject._autoOpenId);};dhtmlXTreeObject.prototype._dragOut=function(htmlObject){this._clearMove();if (this._autoOpenTimer)clearTimeout(this._autoOpenTimer);}
dhtmlXTreeObject.prototype.moveItem=function(itemId,mode,targetId,targetTree)
{var sNode=this._globalIdStorageFind(itemId);if (!sNode)return (0);switch(mode){case "right": alert('Not supported yet');break;case "item_child":
 var tNode=(targetTree||this)._globalIdStorageFind(targetId);if (!tNode)return (0);(targetTree||this)._moveNodeTo(sNode,tNode,0);break;case "item_sibling":
 var tNode=(targetTree||this)._globalIdStorageFind(targetId);if (!tNode)return (0);(targetTree||this)._moveNodeTo(sNode,tNode.parentObject,tNode);break;case "item_sibling_next":
 var tNode=(targetTree||this)._globalIdStorageFind(targetId);if (!tNode)return (0);if ((tNode.tr)&&(tNode.tr.nextSibling)&&(tNode.tr.nextSibling.nodem))
 (targetTree||this)._moveNodeTo(sNode,tNode.parentObject,tNode.tr.nextSibling.nodem);else
 (targetTree||this)._moveNodeTo(sNode,tNode.parentObject);break;case "left": if (sNode.parentObject.parentObject)this._moveNodeTo(sNode,sNode.parentObject.parentObject,sNode.parentObject);break;case "up": var z=this._getPrevNode(sNode);if ((z==-1)||(!z.parentObject)) return;this._moveNodeTo(sNode,z.parentObject,z);break;case "up_strict": var z=this._getIndex(sNode);if (z!=0)this._moveNodeTo(sNode,sNode.parentObject,sNode.parentObject.childNodes[z-1]);break;case "down_strict": var z=this._getIndex(sNode);var count=sNode.parentObject.childsCount-2;if (z==count)this._moveNodeTo(sNode,sNode.parentObject);else if (z<count)this._moveNodeTo(sNode,sNode.parentObject,sNode.parentObject.childNodes[z+2]);break;case "down": var z=this._getNextNode(this._lastChild(sNode));if ((z==-1)||(!z.parentObject)) return;if (z.parentObject==sNode.parentObject)var z=this._getNextNode(z);if (z==-1){this._moveNodeTo(sNode,sNode.parentObject);}
 else
 {if ((z==-1)||(!z.parentObject)) return;this._moveNodeTo(sNode,z.parentObject,z);}
 break;}
 if (_isIE && _isIE<8){this.allTree.childNodes[0].border = "1";this.allTree.childNodes[0].border = "0";}
}
 dhtmlXTreeObject.prototype._loadDynXML=function(id,src) {src=src||this.XMLsource;var sn=(new Date()).valueOf();this._ld_id=id;this.loadXML(src+getUrlSymbol(src)+"uid="+sn+"&id="+this._escape(id));};dhtmlXTreeObject.prototype._checkPNodes=function(item1,item2){if (this._dcheckf)return false;if (item2==item1)return 1
 if (item1.parentObject)return this._checkPNodes(item1.parentObject,item2);else return 0;};dhtmlXTreeObject.prototype.disableDropCheck = function(mode){this._dcheckf = convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.preventIECaching=function(mode){this.no_cashe = convertStringToBoolean(mode);this.XMLLoader.rSeed=this.no_cashe;}
dhtmlXTreeObject.prototype.preventIECashing=dhtmlXTreeObject.prototype.preventIECaching;dhtmlXTreeObject.prototype.disableCheckbox=function(itemId,mode) {if (typeof(itemId)!="object")
 var sNode=this._globalIdStorageFind(itemId,0,1);else
 var sNode=itemId;if (!sNode)return;sNode.dscheck=convertStringToBoolean(mode)?(((sNode.checkstate||0)%3)+3):((sNode.checkstate>2)?(sNode.checkstate-3):sNode.checkstate);this._setCheck(sNode);if (sNode.dscheck<3)sNode.dscheck=false;};dhtmlXTreeObject.prototype.setEscapingMode=function(mode){this.utfesc=mode;}
 dhtmlXTreeObject.prototype.enableHighlighting=function(mode) {this.ehlt=true;this.ehlta=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype._itemMouseOut=function(){var that=this.childNodes[3].parentObject;var tree=that.treeNod;tree.callEvent("onMouseOut",[that.id]);if (that.id==tree._l_onMSI)tree._l_onMSI=null;if (!tree.ehlta)return;that.span.className=that.span.className.replace("_lor","");}
 dhtmlXTreeObject.prototype._itemMouseIn=function(){var that=this.childNodes[3].parentObject;var tree=that.treeNod;if (tree._l_onMSI!=that.id)tree.callEvent("onMouseIn",[that.id]);tree._l_onMSI=that.id;if (!tree.ehlta)return;that.span.className=that.span.className.replace("_lor","");that.span.className=that.span.className.replace(/((standart|selected)TreeRow)/,"$1_lor");}
 dhtmlXTreeObject.prototype.enableActiveImages=function(mode){this._aimgs=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.focusItem=function(itemId){var sNode=this._globalIdStorageFind(itemId);if (!sNode)return (0);this._focusNode(sNode);};dhtmlXTreeObject.prototype.getAllSubItems =function(itemId){return this._getAllSubItems(itemId);}
 dhtmlXTreeObject.prototype.getAllChildless =function(){return this._getAllScraggyItems(this.htmlNode);}
 dhtmlXTreeObject.prototype.getAllLeafs=dhtmlXTreeObject.prototype.getAllChildless;dhtmlXTreeObject.prototype._getAllScraggyItems =function(node)
 {var z="";for (var i=0;i<node.childsCount;i++){if ((node.childNodes[i].unParsed)||(node.childNodes[i].childsCount>0))
 {if (node.childNodes[i].unParsed)var zb=this._getAllScraggyItemsXML(node.childNodes[i].unParsed,1);else
 var zb=this._getAllScraggyItems(node.childNodes[i])

 if (zb)if (z)z+=this.dlmtr+zb;else z=zb;}
 else
 if (!z)z=""+node.childNodes[i].id;else z+=this.dlmtr+node.childNodes[i].id;}
 return z;};dhtmlXTreeObject.prototype._getAllFatItems =function(node)
 {var z="";for (var i=0;i<node.childsCount;i++){if ((node.childNodes[i].unParsed)||(node.childNodes[i].childsCount>0))
 {if (!z)z=""+node.childNodes[i].id;else z+=this.dlmtr+node.childNodes[i].id;if (node.childNodes[i].unParsed)var zb=this._getAllFatItemsXML(node.childNodes[i].unParsed,1);else
 var zb=this._getAllFatItems(node.childNodes[i])

 if (zb)z+=this.dlmtr+zb;}
 }
 return z;};dhtmlXTreeObject.prototype.getAllItemsWithKids =function(){return this._getAllFatItems(this.htmlNode);}
 dhtmlXTreeObject.prototype.getAllFatItems=dhtmlXTreeObject.prototype.getAllItemsWithKids;dhtmlXTreeObject.prototype.getAllChecked=function(){return this._getAllChecked("","",1);}
 dhtmlXTreeObject.prototype.getAllUnchecked=function(itemId){if (itemId)itemId=this._globalIdStorageFind(itemId);return this._getAllChecked(itemId,"",0);}
 dhtmlXTreeObject.prototype.getAllPartiallyChecked=function(){return this._getAllChecked("","",2);}
 dhtmlXTreeObject.prototype.getAllCheckedBranches=function(){var temp = [this._getAllChecked("","",1)];var second = this._getAllChecked("","",2);if (second)temp.push(second);return temp.join(this.dlmtr);}
 dhtmlXTreeObject.prototype._getAllChecked=function(htmlNode,list,mode){if (!htmlNode)htmlNode=this.htmlNode;if (htmlNode.checkstate==mode)if (!htmlNode.nocheckbox){if (list)list+=this.dlmtr+htmlNode.id;else list=""+htmlNode.id;}
 var j=htmlNode.childsCount;for (var i=0;i<j;i++){list=this._getAllChecked(htmlNode.childNodes[i],list,mode);};if (list)return list;else return "";};dhtmlXTreeObject.prototype.setItemStyle=function(itemId,style_string,resetCss){var resetCss= resetCss|| false;var temp=this._globalIdStorageFind(itemId);if (!temp)return 0;if (!temp.span.style.cssText)temp.span.setAttribute("style",temp.span.getAttribute("style")+";"+style_string);else 
 temp.span.style.cssText = resetCss? style_string : temp.span.style.cssText+";"+style_string;}
dhtmlXTreeObject.prototype.enableImageDrag=function(mode){this._itim_dg=convertStringToBoolean(mode);}
 dhtmlXTreeObject.prototype.setOnDragIn=function(func){this.attachEvent("onDragIn",func);};dhtmlXTreeObject.prototype.enableDragAndDropScrolling=function(mode){this.autoScroll=convertStringToBoolean(mode);};dhtmlXTreeObject.prototype.setSkin=function(name){var tmp = this.parentObject.className.replace(/dhxtree_[^ ]*/gi,"");this.parentObject.className= tmp+" dhxtree_"+name;if (name == "dhx_terrace")this.enableTreeLines(false);};(function(){dhtmlx.extend_api("dhtmlXTreeObject",{_init:function(obj){return [obj.parent,(obj.width||"100%"),(obj.height||"100%"),(obj.root_id||0)];},
 auto_save_selection:"enableAutoSavingSelected",
 auto_tooltip:"enableAutoTooltips",
 checkbox:"enableCheckBoxes",
 checkbox_3_state:"enableThreeStateCheckboxes",
 checkbox_smart:"enableSmartCheckboxes",
 context_menu:"enableContextMenu",
 distributed_parsing:"enableDistributedParsing",
 drag:"enableDragAndDrop",
 drag_copy:"enableMercyDrag",
 drag_image:"enableImageDrag",
 drag_scroll:"enableDragAndDropScrolling",
 editor:"enableItemEditor",
 hover:"enableHighlighting",
 images:"enableTreeImages",
 image_fix:"enableIEImageFix",
 image_path:"setImagePath",
 lines:"enableTreeLines",
 loading_item:"enableLoadingItem",
 multiline:"enableMultiLineItems",
 multiselect:"enableMultiselection",
 navigation:"enableKeyboardNavigation",
 radio:"enableRadioButtons",
 radio_single:"enableSingleRadioMode",
 rtl:"enableRTL",
 search:"enableKeySearch",
 smart_parsing:"enableSmartXMLParsing",
 smart_rendering:"enableSmartRendering",
 text_icons:"enableTextSigns",
 xml:"loadXML",
 skin:"setSkin"
 },{});})();dhtmlXTreeObject.prototype._dp_init=function(dp){dp.attachEvent("insertCallback", function(upd, id, parent) {var data = this._loader.doXPath(".//item",upd);var text = data[0].getAttribute('text');this.obj.insertNewItem(parent, id, text, 0, 0, 0, 0, "CHILD");});dp.attachEvent("updateCallback", function(upd, id, parent) {var data = this._loader.doXPath(".//item",upd);var text = data[0].getAttribute('text');this.obj.setItemText(id, text);if (this.obj.getParentId(id)!= parent) {this.obj.moveItem(id, 'item_child', parent);}
 this.setUpdated(id, true, 'updated');});dp.attachEvent("deleteCallback", function(upd, id, parent) {this.obj.setUserData(id, this.action_param, "true_deleted");this.obj.deleteItem(id, false);});dp._methods=["setItemStyle","","changeItemId","deleteItem"];this.attachEvent("onEdit",function(state,id){if (state==3)dp.setUpdated(id,true)
 return true;});this.attachEvent("onDrop",function(id,id_2,id_3,tree_1,tree_2){if (tree_1==tree_2)dp.setUpdated(id,true);});this._onrdlh=function(rowId){var z=dp.getState(rowId);if (z=="inserted"){dp.set_invalid(rowId,false);dp.setUpdated(rowId,false);return true;}
 if (z=="true_deleted"){dp.setUpdated(rowId,false);return true;}
 dp.setUpdated(rowId,true,"deleted")
 return false;};this._onradh=function(rowId){dp.setUpdated(rowId,true,"inserted")
 };dp._getRowData=function(rowId){var data = {};var z=this.obj._globalIdStorageFind(rowId);var z2=z.parentObject;var i=0;for (i=0;i<z2.childsCount;i++)if (z2.childNodes[i]==z)break;data["tr_id"] = z.id;data["tr_pid"] = z2.id;data["tr_order"] = i;data["tr_text"] = z.span.innerHTML;z2=(z._userdatalist||"").split(",");for (i=0;i<z2.length;i++)data[z2[i]]=z.userData["t_"+z2[i]];return data;};};dhtmlXTreeObject.prototype.makeDraggable=function(obj,func){if (typeof(obj)!="object")
 obj=document.getElementById(obj);dragger=new dhtmlDragAndDropObject();dropper=new dhx_dragSomethingInTree();dragger.addDraggableItem(obj,dropper);obj.dragLanding=null;obj.ondragstart=dropper._preventNsDrag;obj.onselectstart=new Function("return false;");obj.parentObject=new Object;obj.parentObject.img=obj;obj.parentObject.treeNod=dropper;dropper._customDrop=func;}
dhtmlXTreeObject.prototype.makeDragable=dhtmlXTreeObject.prototype.makeDraggable;dhtmlXTreeObject.prototype.makeAllDraggable=function(func){var z=document.getElementsByTagName("div");for (var i=0;i<z.length;i++)if (z[i].getAttribute("dragInDhtmlXTree"))
 this.makeDragable(z[i],func);}
function dhx_dragSomethingInTree(){this.lWin=window;this._createDragNode=function(node){var dragSpan=document.createElement('div');dragSpan.style.position="absolute";dragSpan.innerHTML=(node.innerHTML||node.value);dragSpan.className="dragSpanDiv";return dragSpan;};this._preventNsDrag=function(e){(e||window.event).cancelBubble=true;if ((e)&&(e.preventDefault)) {e.preventDefault();return false;}
 return false;}
 
 
 
 this._nonTrivialNode=function(tree,item,bitem,source){if (this._customDrop)return this._customDrop(tree,source.img.id,item.id,bitem?bitem.id:null);var image=(source.img.getAttribute("image")||"");var id=source.img.id||"new";var text=(source.img.getAttribute("text")||(_isIE?source.img.innerText:source.img.textContent));tree[bitem?"insertNewNext":"insertNewItem"](bitem?bitem.id:item.id,id,text,"",image,image,image);}
}
dhtmlXTreeObject.prototype.enableItemEditor=function(mode){this._eItEd=convertStringToBoolean(mode);if (!this._eItEdFlag){this._edn_click_IE=true;this._edn_dblclick=true;this._ie_aFunc=this.aFunc;this._ie_dblclickFuncHandler=this.dblclickFuncHandler;this.setOnDblClickHandler(function (a,b) {if (this._edn_dblclick)this._editItem(a,b);return true;});this.setOnClickHandler(function (a,b) {this._stopEditItem(a,b);if ((this.ed_hist_clcik==a)&&(this._edn_click_IE))
 this._editItem(a,b);this.ed_hist_clcik=a;return true;});this._eItEdFlag=true;}
 };dhtmlXTreeObject.prototype.setOnEditHandler=function(func){this.attachEvent("onEdit",func);};dhtmlXTreeObject.prototype.setEditStartAction=function(click_IE, dblclick){this._edn_click_IE=convertStringToBoolean(click_IE);this._edn_dblclick=convertStringToBoolean(dblclick);};dhtmlXTreeObject.prototype._stopEdit=function(a,mode){if (this._editCell){this.dADTempOff=this.dADTempOffEd;if (this._editCell.id!=a){var editText=true;if(!mode){editText=this.callEvent("onEdit",[2,this._editCell.id,this,this._editCell.span.childNodes[0].value]);}
 else{editText = false;this.callEvent("onEditCancel",[this._editCell.id,this._editCell._oldValue]);}
 if (editText===true)editText=this._editCell.span.childNodes[0].value;else if (editText===false)editText=this._editCell._oldValue;var changed = (editText!=this._editCell._oldValue);this._editCell.span.innerHTML=editText;this._editCell.label=this._editCell.span.innerHTML;var cSS=this._editCell.i_sel?"selectedTreeRow":"standartTreeRow";this._editCell.span.className=cSS;this._editCell.span.parentNode.className="standartTreeRow";this._editCell.span.style.paddingRight=this._editCell.span.style.paddingLeft='5px';this._editCell.span.onclick=this._editCell.span.ondblclick=function(){};var id=this._editCell.id;if (this.childCalc)this._fixChildCountLabel(this._editCell);this._editCell=null;if(!mode)this.callEvent("onEdit",[3,id,this,changed]);if (this._enblkbrd){this.parentObject.lastChild.focus();this.parentObject.lastChild.focus();}
 }
 }
}
dhtmlXTreeObject.prototype._stopEditItem=function(id,tree){this._stopEdit(id);};dhtmlXTreeObject.prototype.stopEdit=function(mode){if (this._editCell)this._stopEdit(this._editCell.id+"_non",mode);}
dhtmlXTreeObject.prototype.editItem=function(id){this._editItem(id,this);}
dhtmlXTreeObject.prototype._editItem=function(id,tree){if (this._eItEd){this._stopEdit();var temp=this._globalIdStorageFind(id);if (!temp)return;var editText = this.callEvent("onEdit",[0,id,this,temp.span.innerHTML]);if (editText===true)editText = (typeof temp.span.innerText!="undefined"?temp.span.innerText:temp.span.textContent);else if (editText===false)return;this.dADTempOffEd=this.dADTempOff;this.dADTempOff=false;this._editCell=temp;temp._oldValue=editText;temp.span.innerHTML="<input type='text' class='intreeeditRow' />";temp.span.style.paddingRight=temp.span.style.paddingLeft='0px';temp.span.onclick = temp.span.ondblclick= function(e){(e||event).cancelBubble = true;}
 temp.span.childNodes[0].value=editText;temp.span.childNodes[0].onselectstart=function(e){(e||event).cancelBubble=true;return true;}
 temp.span.childNodes[0].onmousedown=function(e){(e||event).cancelBubble=true;return true;}
 temp.span.childNodes[0].focus();temp.span.childNodes[0].focus();temp.span.onclick=function (e){(e||event).cancelBubble=true;return false;};temp.span.className="";temp.span.parentNode.className="";var self=this;temp.span.childNodes[0].onkeydown=function(e){if (!e)e=window.event;if (e.keyCode==13){e.cancelBubble=true;self._stopEdit(window.undefined);}
 else if (e.keyCode==27){self._editCell.span.childNodes[0].value=self._editCell._oldValue;self._stopEdit(window.undefined);}
 (e||event).cancelBubble=true;}
 this.callEvent("onEdit",[1,id,this]);}
};function jsonPointer(data,parent){this.d=data;this.dp=parent;}
jsonPointer.prototype={text:function(){var afff=function(n){var p=[];for(var i=0;i<n.length;i++)p.push("{"+sfff(n[i])+"}");return p.join(",");};var sfff=function(n){var p=[];for (var a in n)if (typeof(n[a])=="object"){if (a.length)p.push('"'+a+'":['+afff(n[a])+"]");else p.push('"'+a+'":{'+sfff(n[a])+"}");}else p.push('"'+a+'":"'+n[a]+'"');return p.join(",");};return "{"+sfff(this.d)+"}";},
 get:function(name){return this.d[name];},
 exists:function(){return !!this.d },
 content:function(){return this.d.content;},
 each:function(name,f,t){var a=this.d[name];var c=new jsonPointer();if (a)for (var i=0;i<a.length;i++){c.d=a[i];f.apply(t,[c,i]);}},
 get_all:function(){return this.d;},
 sub:function(name){return new jsonPointer(this.d[name],this.d) },
 sub_exists:function(name){return !!this.d[name];},
 each_x:function(name,rule,f,t,i){var a=this.d[name];var c=new jsonPointer(0,this.d);if (a)for (i=i||0;i<a.length;i++)if (a[i][rule]){c.d=a[i];if(f.apply(t,[c,i])==-1) return;}},
 up:function(name){return new jsonPointer(this.dp,this.d);},
 set:function(name,val){this.d[name]=val;},
 clone:function(name){return new jsonPointer(this.d,this.dp);},
 through:function(name,rule,v,f,t){var a=this.d[name];if (a.length)for (var i=0;i<a.length;i++){if (a[i][rule]!=null && a[i][rule]!="" && (!v || a[i][rule]==v )) {var c=new jsonPointer(a[i],this.d);f.apply(t,[c,i]);}var w=this.d;this.d=a[i];if (this.sub_exists(name)) this.through(name,rule,v,f,t);this.d=w;}}
}
 dhtmlXTreeObject.prototype.loadJSArrayFile=function(file,afterCall){if (!this.parsCount)this.callEvent("onXLS",[this,this._ld_id]);this._ld_id=null;this.xmlstate=1;var that=this;this.XMLLoader=new dtmlXMLLoaderObject(function(){eval("var z="+arguments[4].xmlDoc.responseText);that.loadJSArray(z);},this,true,this.no_cashe);if (afterCall)this.XMLLoader.waitCall=afterCall;this.XMLLoader.loadXML(file);};dhtmlXTreeObject.prototype.loadCSV=function(file,afterCall){if (!this.parsCount)this.callEvent("onXLS",[this,this._ld_id]);this._ld_id=null;this.xmlstate=1;var that=this;this.XMLLoader=new dtmlXMLLoaderObject(function(){that.loadCSVString(arguments[4].xmlDoc.responseText);},this,true,this.no_cashe);if (afterCall)this.XMLLoader.waitCall=afterCall;this.XMLLoader.loadXML(file);};dhtmlXTreeObject.prototype.loadJSArray=function(ar,afterCall){var z=[];for (var i=0;i<ar.length;i++){if (!z[ar[i][1]])z[ar[i][1]]=[];z[ar[i][1]].push({id:ar[i][0],text:ar[i][2]});}
 
 var top={id: this.rootId};var f=function(top,f){if (z[top.id]){top.item=z[top.id];for (var j=0;j<top.item.length;j++)f(top.item[j],f);}
 }
 f(top,f);this.loadJSONObject(top,afterCall);}
dhtmlXTreeObject.prototype.loadCSVString=function(csv,afterCall){var z=[];var ar=csv.split("\n");for (var i=0;i<ar.length;i++){var t=ar[i].split(",");if (!z[t[1]])z[t[1]]=[];z[t[1]].push({id:t[0],text:t[2]});}
 
 var top={id: this.rootId};var f=function(top,f){if (z[top.id]){top.item=z[top.id];for (var j=0;j<top.item.length;j++)f(top.item[j],f);}
 }
 f(top,f);this.loadJSONObject(top,afterCall);}
 dhtmlXTreeObject.prototype.loadJSONObject=function(json,afterCall){if (!this.parsCount)this.callEvent("onXLS",[this,null]);this.xmlstate=1;var p=new jsonPointer(json);this._parse(p);this._p=p;if (afterCall)afterCall();};dhtmlXTreeObject.prototype.loadJSON=function(file,afterCall){if (!this.parsCount)this.callEvent("onXLS",[this,this._ld_id]);this._ld_id=null;this.xmlstate=1;var that=this;this.XMLLoader=new dtmlXMLLoaderObject(function(){try {eval("var t="+arguments[4].xmlDoc.responseText);}catch(e){dhtmlxError.throwError("LoadXML", "Incorrect JSON", [
 (arguments[4].xmlDoc),
 this
 ]);return;}
 var p=new jsonPointer(t);that._parse(p);that._p=p;},this,true,this.no_cashe);if (afterCall)this.XMLLoader.waitCall=afterCall;this.XMLLoader.loadXML(file);};dhtmlXTreeObject.prototype.serializeTreeToJSON=function(){var out=['{"id":"'+this.rootId+'", "item":['];var p=[];for (var i=0;i<this.htmlNode.childsCount;i++)p.push(this._serializeItemJSON(this.htmlNode.childNodes[i]));out.push(p.join(","));out.push("]}");return out.join("");};dhtmlXTreeObject.prototype._serializeItemJSON=function(itemNode){var out=[];if (itemNode.unParsed)return (itemNode.unParsed.text());if (this._selected.length)var lid=this._selected[0].id;else lid="";var text=itemNode.span.innerHTML;text=text.replace(/\"/g, "\\\"", text);if (!this._xfullXML)out.push('{"id":"'+itemNode.id+'", '+(this._getOpenState(itemNode)==1?' "open":"1", ':'')+(lid==itemNode.id?' "select":"1",':'')+' "text":"'+text+'"'+( ((this.XMLsource)&&(itemNode.XMLload==0))?', "child":"1" ':''));else
 out.push('{"id":"'+itemNode.id+'", '+(this._getOpenState(itemNode)==1?' "open":"1", ':'')+(lid==itemNode.id?' "select":"1",':'')+' "text":"'+text+'", "im0":"'+itemNode.images[0]+'", "im1":"'+itemNode.images[1]+'", "im2":"'+itemNode.images[2]+'" '+(itemNode.acolor?(', "aCol":"'+itemNode.acolor+'" '):'')+(itemNode.scolor?(', "sCol":"'+itemNode.scolor+'" '):'')+(itemNode.checkstate==1?', "checked":"1" ':(itemNode.checkstate==2?', "checked":"-1"':''))+(itemNode.closeable?', "closeable":"1" ':'')+( ((this.XMLsource)&&(itemNode.XMLload==0))?', "child":"1" ':''));if ((this._xuserData)&&(itemNode._userdatalist))
 {out.push(', "userdata":[');var names=itemNode._userdatalist.split(",");var p=[];for (var i=0;i<names.length;i++)p.push('{"name":"'+names[i]+'" , "content":"'+itemNode.userData["t_"+names[i]]+'" }');out.push(p.join(","));out.push("]");}
 
 if (itemNode.childsCount){out.push(', "item":[');var p=[];for (var i=0;i<itemNode.childsCount;i++)p.push(this._serializeItemJSON(itemNode.childNodes[i]));out.push(p.join(","));out.push("]\n");}
 
 out.push("}\n")
 return out.join("");}




function dhtmlXTreeFromHTML(obj){if (typeof(obj)!="object")
 obj=document.getElementById(obj);var n=obj;var id=n.id;var cont="";for (var j=0;j<obj.childNodes.length;j++)if (obj.childNodes[j].nodeType=="1"){if (obj.childNodes[j].tagName=="XMP"){var cHead=obj.childNodes[j];for (var m=0;m<cHead.childNodes.length;m++)cont+=cHead.childNodes[m].data;}
 else if (obj.childNodes[j].tagName.toLowerCase()=="ul")
 cont=dhx_li2trees(obj.childNodes[j],new Array(),0);break;}
 obj.innerHTML="";var t=new dhtmlXTreeObject(obj,"100%","100%",0);var z_all=new Array();for ( b in t )z_all[b.toLowerCase()]=b;var atr=obj.attributes;for (var a=0;a<atr.length;a++)if ((atr[a].name.indexOf("set")==0)||(atr[a].name.indexOf("enable")==0)){var an=atr[a].name;if (!t[an])an=z_all[atr[a].name];t[an].apply(t,atr[a].value.split(","));}
 if (typeof(cont)=="object"){t.XMLloadingWarning=1;for (var i=0;i<cont.length;i++){var n=t.insertNewItem(cont[i][0],cont[i][3],cont[i][1]);if (cont[i][2])t._setCheck(n,cont[i][2]);}
 t.XMLloadingWarning=0;t.lastLoadedXMLId=0;t._redrawFrom(t);}
 else
 t.loadXMLString("<tree id='0'>"+cont+"</tree>");window[id]=t;var oninit = obj.getAttribute("oninit");if (oninit)eval(oninit);return t;}
function dhx_init_trees(){var z=document.getElementsByTagName("div");for (var i=0;i<z.length;i++)if (z[i].className=="dhtmlxTree")dhtmlXTreeFromHTML(z[i])
}
function dhx_li2trees(tag,data,ind){for (var i=0;i<tag.childNodes.length;i++){var z=tag.childNodes[i];if ((z.nodeType==1)&&(z.tagName.toLowerCase()=="li")){var c="";var ul=null;var check=z.getAttribute("checked");for (var j=0;j<z.childNodes.length;j++){var zc=z.childNodes[j];if (zc.nodeType==3)c+=zc.data;else if (zc.tagName.toLowerCase()!="ul") c+=dhx_outer_html(zc);else ul=zc;}
 data[data.length]=[ind,c,check,(z.id||(data.length+1))];if (ul)data=dhx_li2trees(ul,data,(z.id||data.length));}
 }
 return data;}
function dhx_outer_html(node){if (node.outerHTML)return node.outerHTML;var temp=document.createElement("DIV");temp.appendChild(node.cloneNode(true));temp=temp.innerHTML;return temp;}
if (window.addEventListener)window.addEventListener("load",dhx_init_trees,false);else if (window.attachEvent)window.attachEvent("onload",dhx_init_trees);window.dhx||(dhx={});dhx.version="3.0";dhx.codebase="./";dhx.name="Core";dhx.clone=function(a){var b=dhx.clone.xa;b.prototype=a;return new b};dhx.clone.xa=function(){};dhx.extend=function(a,b,c){if(a.q)return dhx.PowerArray.insertAt.call(a.q,b,1),a;for(var d in b)if(!a[d]||c)a[d]=b[d];b.defaults&&dhx.extend(a.defaults,b.defaults);b.$init&&b.$init.call(a);return a};dhx.copy=function(a){if(arguments.length>1)var b=arguments[0],a=arguments[1];else b=dhx.isArray(a)?[]:{};for(var c in a)a[c]&&typeof a[c]=="object"&&!dhx.isDate(a[c])?(b[c]=dhx.isArray(a[c])?[]:{},dhx.copy(b[c],a[c])):b[c]=a[c];return b};dhx.single=function(a){var b=null,c=function(c){b||(b=new a({}));b.Ia&&b.Ia.apply(b,arguments);return b};return c};dhx.protoUI=function(){var a=arguments,b=a[0].name,c=function(a){if(!c)return dhx.ui[b].prototype;var e=c.q;if(e){for(var f=[e[0]],g=1;g<e.length;g++)f[g]=e[g],f[g].q&&(f[g]=f[g].call(dhx,f[g].name)),f[g].prototype&&f[g].prototype.name&&(dhx.ui[f[g].prototype.name]=f[g]);dhx.ui[b]=dhx.proto.apply(dhx,f);if(c.r)for(g=0;g<c.r.length;g++)dhx.Type(dhx.ui[b],c.r[g]);c=e=null}return this!=dhx?new dhx.ui[b](a):dhx.ui[b]};c.q=Array.prototype.slice.call(arguments,0);return dhx.ui[b]=c};dhx.proto=function(){for(var a=arguments,b=a[0],c=!!b.$init,d=[],e=a.length-1;e>0;e--){if(typeof a[e]=="function")a[e]=a[e].prototype;a[e].$init&&d.push(a[e].$init);if(a[e].defaults){var f=a[e].defaults;if(!b.defaults)b.defaults={};for(var g in f)dhx.isUndefined(b.defaults[g])&&(b.defaults[g]=f[g])}if(a[e].type&&b.type)for(g in a[e].type)b.type[g]||(b.type[g]=a[e].type[g]);for(var h in a[e])b[h]||(b[h]=a[e][h])}c&&d.push(b.$init);b.$init=function(){for(var a=0;a<d.length;a++)d[a].apply(this,arguments)};var i=function(a){this.$ready=[];this.$init(a);this.$&&this.$(a,this.defaults);for(var b=0;b<this.$ready.length;b++)this.$ready[b].call(this)};i.prototype=b;b=a=null;return i};dhx.bind=function(a,b){return function(){return a.apply(b,arguments)}};dhx.require=function(a,b,c,d,e){if(typeof a!="string"){var f=a.length||0,g=b;if(f)b=function(){if(f)f--,dhx.require(a[a.length-f-1],b,c);else return g.apply(this,arguments)},b();else{for(var h in a)f++;b=function(){f--;f===0&&g.apply(this,arguments)};for(h in a)dhx.require(h,b,c)}}else if(dhx.i[a]!==!0)if(a.substr(-4)==".css"){var i=dhx.html.create("LINK",{type:"text/css",rel:"stylesheet",href:dhx.codebase+a});document.head.appendChild(i);b&&b.call(c||window)}else{var j=e;b?dhx.i[a]?dhx.i[a].push([b,
c]):(dhx.i[a]=[[b,c]],dhx.ajax(dhx.codebase+a,function(b){dhx.exec(b);var c=dhx.i[a];dhx.i[a]=!0;for(var d=0;d<c.length;d++)c[d][0].call(c[d][1]||window,!d)})):(dhx.exec(dhx.ajax().sync().get(dhx.codebase+a).responseText),dhx.i[a]=!0)}};dhx.i={};dhx.exec=function(a){window.execScript?window.execScript(a):window.eval(a)};dhx.wrap=function(a,b){return!a?b:function(){var c=a.apply(this,arguments);b.apply(this,arguments);return c}};dhx.isUndefined=function(a){return typeof a=="undefined"};dhx.delay=function(a,b,c,d){return window.setTimeout(function(){var d=a.apply(b,c||[]);a=b=c=null;return d},d||1)};dhx.uid=function(){if(!this.R)this.R=(new Date).valueOf();this.R++;return this.R};dhx.toNode=function(a){return typeof a=="string"?document.getElementById(a):a};dhx.toArray=function(a){return dhx.extend(a||[],dhx.PowerArray,!0)};dhx.toFunctor=function(a){return typeof a=="string"?eval(a):a};dhx.isArray=function(a){return Array.isArray?Array.isArray(a):Object.prototype.toString.call(a)==="[object Array]"};dhx.isDate=function(a){return a instanceof Date};dhx.L={};dhx.event=function(a,b,c,d){var a=dhx.toNode(a),e=dhx.uid();d&&(c=dhx.bind(c,d));dhx.L[e]=[a,b,c];a.addEventListener?a.addEventListener(b,c,!1):a.attachEvent&&a.attachEvent("on"+b,c);return e};dhx.eventRemove=function(a){if(a){var b=dhx.L[a];b[0].removeEventListener?b[0].removeEventListener(b[1],b[2],!1):b[0].detachEvent&&b[0].detachEvent("on"+b[1],b[2]);delete this.L[a]}};dhx.EventSystem={$init:function(){if(!this.e)this.e={},this.s={},this.M={}},blockEvent:function(){this.e.T=!0},unblockEvent:function(){this.e.T=!1},mapEvent:function(a){dhx.extend(this.M,a,!0)},on_setter:function(a){if(a)for(var b in a)typeof a[b]=="function"&&this.attachEvent(b,a[b])},callEvent:function(a,b){if(this.e.T)return!0;var a=a.toLowerCase(),c=this.e[a.toLowerCase()],d=!0;if(c)for(var e=0;e<c.length;e++)if(c[e].apply(this,b||[])===!1)d=!1;this.M[a]&&!this.M[a].callEvent(a,b)&&(d=!1);return d},
attachEvent:function(a,b,c){var a=a.toLowerCase(),c=c||dhx.uid(),b=dhx.toFunctor(b),d=this.e[a]||dhx.toArray();d.push(b);this.e[a]=d;this.s[c]={f:b,t:a};return c},detachEvent:function(a){if(this.s[a]){var b=this.s[a].t,c=this.s[a].f,d=this.e[b];d.remove(c);delete this.s[a]}},hasEvent:function(a){a=a.toLowerCase();return this.e[a]?!0:!1}};dhx.extend(dhx,dhx.EventSystem);dhx.PowerArray={removeAt:function(a,b){a>=0&&this.splice(a,b||1)},remove:function(a){this.removeAt(this.find(a))},insertAt:function(a,b){if(!b&&b!==0)this.push(a);else{var c=this.splice(b,this.length-b);this[b]=a;this.push.apply(this,c)}},find:function(a){for(var b=0;b<this.length;b++)if(a==this[b])return b;return-1},each:function(a,b){for(var c=0;c<this.length;c++)a.call(b||this,this[c])},map:function(a,b){for(var c=0;c<this.length;c++)this[c]=a.call(b||this,this[c]);return this},filter:function(a,
b){for(var c=0;c<this.length;c++)a.call(b||this,this[c])||(this.splice(c,1),c--);return this}};dhx.env={};(function(){if(navigator.userAgent.indexOf("Mobile")!=-1)dhx.env.mobile=!0;if(dhx.env.mobile||navigator.userAgent.indexOf("iPad")!=-1||navigator.userAgent.indexOf("Android")!=-1)dhx.env.touch=!0;navigator.userAgent.indexOf("Opera")!=-1?dhx.env.isOpera=!0:(dhx.env.isIE=!!document.all,dhx.env.isFF=!document.all,dhx.env.isWebKit=navigator.userAgent.indexOf("KHTML")!=-1,dhx.env.isSafari=dhx.env.isWebKit&&navigator.userAgent.indexOf("Mac")!=-1);if(navigator.userAgent.toLowerCase().indexOf("android")!=
-1)dhx.env.isAndroid=!0;dhx.env.transform=!1;dhx.env.transition=!1;for(var a={names:["transform","transition"],transform:["transform","WebkitTransform","MozTransform","OTransform","msTransform"],transition:["transition","WebkitTransition","MozTransition","OTransition","msTransition"]},b=document.createElement("DIV"),c=0;c<a.names.length;c++)for(var d=a[a.names[c]],e=0;e<d.length;e++)if(typeof b.style[d[e]]!="undefined"){dhx.env[a.names[c]]=d[e];break}b.style[dhx.env.transform]="translate3d(0,0,0)";dhx.env.translate=b.style[dhx.env.transform]?"translate3d":"translate";var f="",g=!1;dhx.env.isOpera&&(f="-o-",g="O");dhx.env.isFF&&(f="-Moz-");dhx.env.isWebKit&&(f="-webkit-");dhx.env.isIE&&(f="-ms-");dhx.env.transformCSSPrefix=f;dhx.env.transformPrefix=g||dhx.env.transformCSSPrefix.replace(/-/gi,"");dhx.env.transitionEnd=dhx.env.transformCSSPrefix=="-Moz-"?"transitionend":dhx.env.transformPrefix+"TransitionEnd"})();dhx.env.svg=function(){return document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure","1.1")}();dhx.html={v:0,denySelect:function(){if(!dhx.v)dhx.v=document.onselectstart;document.onselectstart=dhx.html.stopEvent},allowSelect:function(){if(dhx.v!==0)document.onselectstart=dhx.v||null;dhx.v=0},index:function(a){for(var b=0;a=a.previousSibling;)b++;return b},ga:{},createCss:function(a){var b="",c;for(c in a)b+=c+":"+a[c]+";";var d=this.ga[b];d||(d="s"+dhx.uid(),this.addStyle("."+d+"{"+b+"}"),this.ga[b]=d);return d},addStyle:function(a){var b=document.createElement("style");b.setAttribute("type",
"text/css");b.setAttribute("media","screen");b.styleSheet?b.styleSheet.cssText=a:b.appendChild(document.createTextNode(a));document.getElementsByTagName("head")[0].appendChild(b)},create:function(a,b,c){var b=b||{},d=document.createElement(a),e;for(e in b)d.setAttribute(e,b[e]);if(b.style)d.style.cssText=b.style;if(b["class"])d.className=b["class"];if(c)d.innerHTML=c;return d},getValue:function(a){a=dhx.toNode(a);return!a?"":dhx.isUndefined(a.value)?a.innerHTML:a.value},remove:function(a){if(a instanceof
Array)for(var b=0;b<a.length;b++)this.remove(a[b]);else a&&a.parentNode&&a.parentNode.removeChild(a)},insertBefore:function(a,b,c){a&&(b&&b.parentNode?b.parentNode.insertBefore(a,b):c.appendChild(a))},locate:function(a,b){if(a.tagName)var c=a;else a=a||event,c=a.target||a.srcElement;for(;c;){if(c.getAttribute){var d=c.getAttribute(b);if(d)return d}c=c.parentNode}return null},offset:function(a){if(a.getBoundingClientRect){var b=a.getBoundingClientRect(),c=document.body,d=document.documentElement,e=
window.pageYOffset||d.scrollTop||c.scrollTop,f=window.pageXOffset||d.scrollLeft||c.scrollLeft,g=d.clientTop||c.clientTop||0,h=d.clientLeft||c.clientLeft||0,i=b.top+e-g,j=b.left+f-h;return{y:Math.round(i),x:Math.round(j)}}else{for(j=i=0;a;)i+=parseInt(a.offsetTop,10),j+=parseInt(a.offsetLeft,10),a=a.offsetParent;return{y:i,x:j}}},posRelative:function(a){a=a||event;return dhx.isUndefined(a.offsetX)?{x:a.layerX,y:a.layerY}:{x:a.offsetX,y:a.offsetY}},pos:function(a){a=a||event;if(a.pageX||a.pageY)return{x:a.pageX,
y:a.pageY};var b=dhx.env.isIE&&document.compatMode!="BackCompat"?document.documentElement:document.body;return{x:a.clientX+b.scrollLeft-b.clientLeft,y:a.clientY+b.scrollTop-b.clientTop}},preventEvent:function(a){a&&a.preventDefault&&a.preventDefault();return dhx.html.stopEvent(a)},stopEvent:function(a){(a||event).cancelBubble=!0;return!1},addCss:function(a,b){a.className+=" "+b},removeCss:function(a,b){a.className=a.className.replace(RegExp(" "+b,"g"),"")}};dhx.ready=function(a){this.Ga?a.call():this.D.push(a)};dhx.D=[];(function(){var a=document.getElementsByTagName("SCRIPT");if(a.length)a=(a[a.length-1].getAttribute("src")||"").split("/"),a.splice(a.length-1,1),dhx.codebase=a.slice(0,a.length).join("/")+"/";dhx.event(window,"load",function(){dhx.callEvent("onReady",[]);dhx.delay(function(){dhx.Ga=!0;for(var a=0;a<dhx.D.length;a++)dhx.D[a].call();dhx.D=[]})})})();dhx.locale=dhx.locale||{};dhx.ready(function(){dhx.event(document.body,"click",function(a){dhx.callEvent("onClick",[a||event])})});(function(){var a={},b=RegExp("(\\r\\n|\\n)","g"),c=RegExp('(\\")',"g");dhx.Template=function(d){if(typeof d=="function")return d;if(a[d])return a[d];d=(d||"").toString();if(d.indexOf("->")!=-1)switch(d=d.split("->"),d[0]){case "html":d=dhx.html.getValue(d[1]);break;case "http":d=(new dhx.ajax).sync().get(d[1],{uid:dhx.uid()}).responseText}d=(d||"").toString();d=d.replace(b,"\\n");d=d.replace(c,'\\"');d=d.replace(/\{obj\.([^}?]+)\?([^:]*):([^}]*)\}/g,'"+(obj.$1?"$2":"$3")+"');d=d.replace(/\{common\.([^}\(]*)\}/g,
"\"+(common.$1||'')+\"");d=d.replace(/\{common\.([^\}\(]*)\(\)\}/g,'"+(common.$1?common.$1.apply(this, arguments):"")+"');d=d.replace(/\{obj\.([^}]*)\}/g,'"+(obj.$1)+"');d=d.replace("{obj}",'"+obj+"');d=d.replace(/#([^#'";, ]+)#/gi,'"+(obj.$1)+"');try{a[d]=Function("obj","common",'return "'+d+'";')}catch(e){}return a[d]};dhx.Template.empty=function(){return""};dhx.Template.bind=function(a){return dhx.bind(dhx.Template(a),this)};dhx.Type=function(a,b){if(a.q){if(!a.r)a.r=[];a.r.push(b)}else{if(typeof a==
"function")a=a.prototype;if(!a.types)a.types={"default":a.type},a.type.name="default";var c=b.name,g=a.type;c&&(g=a.types[c]=dhx.clone(b.baseType?a.types[b.baseType]:a.type));for(var h in b)g[h]=h.indexOf("template")===0?dhx.Template(b[h]):b[h];return c}}})();dhx.Settings={$init:function(){this.a=this.config={}},define:function(a,b){return typeof a=="object"?this.Q(a):this.U(a,b)},U:function(a,b){var c=this[a+"_setter"];return this.a[a]=c?c.call(this,b,a):b},Q:function(a){if(a)for(var b in a)this.U(b,a[b])},$:function(a,b){var c={};b&&(c=dhx.extend(c,b));typeof a=="object"&&!a.tagName&&dhx.extend(c,a,!0);this.Q(c)},Ba:function(a,b){for(var c in b)switch(typeof a[c]){case "object":a[c]=this.Ba(a[c]||{},b[c]);break;case "undefined":a[c]=b[c]}return a}};dhx.ajax=function(a,b,c){if(arguments.length!==0){var d=new dhx.ajax;if(c)d.master=c;return d.get(a,null,b)}return!this.getXHR?new dhx.ajax:this};dhx.ajax.count=0;dhx.ajax.prototype={master:null,getXHR:function(){return dhx.env.isIE?new ActiveXObject("Microsoft.xmlHTTP"):new XMLHttpRequest},send:function(a,b,c){var d=this.getXHR();dhx.isArray(c)||(c=[c]);if(typeof b=="object"){var e=[],f;for(f in b){var g=b[f];if(g===null||g===dhx.undefined)g="";e.push(f+"="+encodeURIComponent(g))}b=e.join("&")}b&&this.request==="GET"&&(a=a+(a.indexOf("?")!=-1?"&":"?")+b,b=null);d.open(this.request,a,!this.Na);this.request==="POST"&&d.setRequestHeader("Content-type","application/x-www-form-urlencoded");var h=this;d.onreadystatechange=function(){if(!d.readyState||d.readyState==4){dhx.ajax.count++;if(c&&h)for(var a=0;a<c.length;a++)if(c[a]){var b=c[a].success||c[a];if(d.status>=400||!d.status&&!d.responseText)b=c[a].error;b&&b.call(h.master||h,d.responseText,d.responseXML,d)}if(h)h.master=null;c=h=null}};d.send(b||null);return d},get:function(a,b,c){arguments.length==2&&(c=b,b=null);this.request="GET";return this.send(a,b,c)},post:function(a,b,c){this.request="POST";return this.send(a,b,c)},put:function(a,
b,c){this.request="PUT";return this.send(a,b,c)},del:function(a,b,c){this.request="DELETE";return this.send(a,b,c)},sync:function(){this.Na=!0;return this},bind:function(a){this.master=a;return this}};dhx.send=function(a,b,c,d){var e=dhx.html.create("FORM",{target:d||"_self",action:a,method:c||"POST"},""),f;for(f in b){var g=dhx.html.create("INPUT",{type:"hidden",name:f,value:b[f]},"");e.appendChild(g)}e.style.display="none";document.body.appendChild(e);e.submit();document.body.removeChild(e)};dhx.AtomDataLoader={$init:function(a){this.data={};if(a)this.a.datatype=a.datatype||"json",this.$ready.push(this.Aa)},Aa:function(){this.aa=!0;this.a.url&&this.url_setter(this.a.url);this.a.data&&this.data_setter(this.a.data)},url_setter:function(a){if(!this.aa)return a;this.load(a,this.a.datatype);return a},data_setter:function(a){if(!this.aa)return a;this.parse(a,this.a.datatype);return!0},load:function(a,b,c){if(a.$proxy)a.load(this,typeof b=="string"?b:"json");else{this.callEvent("onXLS",[]);if(typeof b=="string")this.data.driver=dhx.DataDriver[b],b=c;else if(!this.data.driver)this.data.driver=dhx.DataDriver.json;var d=[{success:this.P,error:this.C}];b&&(dhx.isArray(b)?d.push.apply(d,b):d.push(b));return dhx.ajax(a,d,this)}},parse:function(a,b){this.callEvent("onXLS",[]);this.data.driver=dhx.DataDriver[b||"json"];this.P(a,null)},P:function(a,b,c){var d=this.data.driver,e=d.toObject(a,b);if(e){var f=d.getRecords(e)[0];this.data=d?d.getDetails(f):a}else this.C(a,b,c);this.callEvent("onXLE",
[])},C:function(a,b,c){this.callEvent("onXLE",[]);this.callEvent("onLoadError",arguments);dhx.callEvent("onLoadError",[a,b,c,this])},z:function(a){if(!this.a.dataFeed||this.N||!a)return!0;var b=this.a.dataFeed;if(typeof b=="function")return b.call(this,a.id||a,a);b=b+(b.indexOf("?")==-1?"?":"&")+"action=get&id="+encodeURIComponent(a.id||a);this.callEvent("onXLS",[]);dhx.ajax(b,function(a,b,e){this.N=!0;var f=dhx.DataDriver.toObject(a,b);f?this.setValues(f.getDetails(f.getRecords()[0])):this.C(a,b,
e);this.N=!1;this.callEvent("onXLE",[])},this);return!1}};dhx.DataDriver={};dhx.DataDriver.json={toObject:function(a){a||(a="[]");if(typeof a=="string"){try{eval("dhx.temp="+a)}catch(b){return null}a=dhx.temp}if(a.data){var c=a.data.config={},d;for(d in a)d!="data"&&(c[d]=a[d]);a=a.data}return a},getRecords:function(a){return a&&!dhx.isArray(a)?[a]:a},getDetails:function(a){return typeof a=="string"?{id:dhx.uid(),value:a}:a},getInfo:function(a){var b=a.config;return!b?{}:{n:b.total_count||0,m:b.pos||0,Ea:b.parent||0,K:b.config,O:b.dhx_security}},child:"data"};dhx.DataDriver.html={toObject:function(a){if(typeof a=="string"){var b=null;a.indexOf("<")==-1&&(b=dhx.toNode(a));if(!b)b=document.createElement("DIV"),b.innerHTML=a;return b.getElementsByTagName(this.tag)}return a},getRecords:function(a){for(var b=[],c=0;c<a.childNodes.length;c++){var d=a.childNodes[c];d.nodeType==1&&b.push(d)}return b},getDetails:function(a){return dhx.DataDriver.xml.tagToObject(a)},getInfo:function(){return{n:0,m:0}},tag:"LI"};dhx.DataDriver.jsarray={toObject:function(a){return typeof a=="string"?(eval("dhx.temp="+a),dhx.temp):a},getRecords:function(a){return a},getDetails:function(a){for(var b={},c=0;c<a.length;c++)b["data"+c]=a[c];return b},getInfo:function(){return{n:0,m:0}}};dhx.DataDriver.csv={toObject:function(a){return a},getRecords:function(a){return a.split(this.row)},getDetails:function(a){for(var a=this.stringToArray(a),b={},c=0;c<a.length;c++)b["data"+c]=a[c];return b},getInfo:function(){return{n:0,m:0}},stringToArray:function(a){for(var a=a.split(this.cell),b=0;b<a.length;b++)a[b]=a[b].replace(/^[ \t\n\r]*(\"|)/g,"").replace(/(\"|)[ \t\n\r]*$/g,"");return a},row:"\n",cell:","};dhx.DataDriver.xml={Y:function(a){return!a||!a.documentElement?null:a.getElementsByTagName("parsererror").length?null:a},toObject:function(a){if(this.Y(b))return b;var b=typeof a=="string"?this.fromString(a.replace(/^[\s]+/,"")):a;return this.Y(b)?b:null},getRecords:function(a){return this.xpath(a,this.records)},records:"/*/item",child:"item",config:"/*/config",getDetails:function(a){return this.tagToObject(a,{})},getInfo:function(a){var b=this.xpath(a,this.config),b=b.length?this.assignTypes(this.tagToObject(b[0],
{})):null;return{n:a.documentElement.getAttribute("total_count")||0,m:a.documentElement.getAttribute("pos")||0,Ea:a.documentElement.getAttribute("parent")||0,K:b,O:a.documentElement.getAttribute("dhx_security")||null}},xpath:function(a,b){if(window.XPathResult){var c=a;if(a.nodeName.indexOf("document")==-1)a=a.ownerDocument;for(var d=[],e=a.evaluate(b,c,null,XPathResult.ANY_TYPE,null),f=e.iterateNext();f;)d.push(f),f=e.iterateNext();return d}else{var g=!0;try{typeof a.selectNodes=="undefined"&&(g=
!1)}catch(h){}if(g)return a.selectNodes(b);else{var i=b.split("/").pop();return a.getElementsByTagName(i)}}},assignTypes:function(a){for(var b in a){var c=a[b];typeof c=="object"?this.assignTypes(c):typeof c=="string"&&c!==""&&(c=="true"?a[b]=!0:c=="false"?a[b]=!1:c==c*1&&(a[b]*=1))}return a},tagToObject:function(a,b){var b=b||{},c=!1,d=a.attributes;if(d&&d.length){for(var e=0;e<d.length;e++)b[d[e].name]=d[e].value;c=!0}for(var f=a.childNodes,g={},e=0;e<f.length;e++)if(f[e].nodeType==1){var h=f[e].tagName;typeof b[h]!="undefined"?(dhx.isArray(b[h])||(b[h]=[b[h]]),b[h].push(this.tagToObject(f[e],{}))):b[f[e].tagName]=this.tagToObject(f[e],{});c=!0}if(!c)return this.nodeValue(a);b.value=b.value||this.nodeValue(a);return b},nodeValue:function(a){return a.firstChild?a.firstChild.data:""},fromString:function(a){try{if(window.DOMParser)return(new DOMParser).parseFromString(a,"text/xml");if(window.ActiveXObject){var b=new ActiveXObject("Microsoft.xmlDOM");b.loadXML(a);return b}}catch(c){return null}}};dhx.DataLoader=dhx.proto({$init:function(a){a=a||"";this.o=dhx.toArray();this.data=new dhx.DataStore;this.data.attachEvent("onClearAll",dhx.bind(this.oa,this));this.data.attachEvent("onServerConfig",dhx.bind(this.na,this));this.data.feed=this.sa},sa:function(a,b,c){if(this.u)return this.u=[a,b,c];else this.u=!0;this.W=[a,b];this.ua.call(this,a,b,c)},ua:function(a,b,c){var d=this.data.url;a<0&&(a=0);this.load(d+(d.indexOf("?")==-1?"?":"&")+(this.dataCount()?"continue=true&":"")+"start="+a+"&count="+
b,[this.ta,c])},ta:function(){var a=this.u,b=this.W;this.u=!1;typeof a=="object"&&(a[0]!=b[0]||a[1]!=b[1])&&this.data.feed.apply(this,a)},load:function(a,b){var c=dhx.AtomDataLoader.load.apply(this,arguments);this.o.push(c);if(!this.data.url)this.data.url=a},loadNext:function(a,b,c,d,e){this.a.datathrottle&&!e?(this.ha&&window.clearTimeout(this.ha),this.ha=dhx.delay(function(){this.loadNext(a,b,c,d,!0)},this,0,this.a.datathrottle)):(!b&&b!==0&&(b=this.dataCount()),this.data.url=this.data.url||d,this.callEvent("onDataRequest",
[b,a,c,d])&&this.data.url&&this.data.feed.call(this,b,a,c))},Ra:function(a,b){var c=this.W;return this.u&&c&&c[0]<=b&&c[1]+c[0]>=a+b?!0:!1},P:function(a,b,c){this.o.remove(c);var d=this.data.driver.toObject(a,b);if(d)this.data.Fa(d);else return this.C(a,b,c);this.pa();this.callEvent("onXLE",[])},removeMissed_setter:function(a){return this.data.Ja=a},scheme_setter:function(a){this.data.scheme(a)},dataFeed_setter:function(a){this.data.attachEvent("onBeforeFilter",dhx.bind(function(a,c){if(this.a.dataFeed){var d=
{};if(a||c){if(typeof a=="function"){if(!c)return;a(c,d)}else d={text:c};this.clearAll();var e=this.a.dataFeed,f=[];if(typeof e=="function")return e.call(this,c,d);for(var g in d)f.push("dhx_filter["+g+"]="+encodeURIComponent(d[g]));this.load(e+(e.indexOf("?")<0?"?":"&")+f.join("&"),this.a.datatype);return!1}}},this));return a},pa:function(){if(this.a.ready&&!this.Ha){var a=dhx.toFunctor(this.a.ready);a&&dhx.delay(a,this,arguments);this.Ha=!0}},oa:function(){for(var a=0;a<this.o.length;a++)this.o[a].abort();this.o=dhx.toArray()},na:function(a){this.Q(a)}},dhx.AtomDataLoader);dhx.DataStore=function(){this.name="DataStore";dhx.extend(this,dhx.EventSystem);this.setDriver("json");this.pull={};this.order=dhx.toArray();this.d={}};dhx.DataStore.prototype={setDriver:function(a){this.driver=dhx.DataDriver[a]},Fa:function(a){this.callEvent("onParse",[this.driver,a]);this.c&&this.filter();var b=this.driver.getInfo(a);if(b.O)dhx.securityKey=b.O;b.K&&this.callEvent("onServerConfig",[b.K]);var c=this.driver.getRecords(a);this.za(b,c);this.ba&&this.ya&&this.ya(this.ba);this.da&&(this.blockEvent(),this.sort(this.da),this.unblockEvent());this.callEvent("onStoreLoad",[this.driver,a]);this.refresh()},za:function(a,b){var c=(a.m||0)*1,
d=!0,e=!1;if(c===0&&this.order[0]){if(this.Ja)for(var e={},f=0;f<this.order.length;f++)e[this.order[f]]=!0;d=!1;c=this.order.length}for(var g=0,f=0;f<b.length;f++){var h=this.driver.getDetails(b[f]),i=this.id(h);this.pull[i]?d&&this.order[g+c]&&g++:(this.order[g+c]=i,g++);this.pull[i]?(dhx.extend(this.pull[i],h,!0),this.H&&this.H(this.pull[i]),e&&delete e[i]):(this.pull[i]=h,this.G&&this.G(h))}if(e){this.blockEvent();for(var j in e)this.remove(j);this.unblockEvent()}if(!this.order[a.n-1])this.order[a.n-
1]=dhx.undefined},id:function(a){return a.id||(a.id=dhx.uid())},changeId:function(a,b){this.pull[a]&&(this.pull[b]=this.pull[a]);this.pull[b].id=b;this.order[this.order.find(a)]=b;this.c&&(this.c[this.c.find(a)]=b);this.d[a]&&(this.d[b]=this.d[a],delete this.d[a]);this.callEvent("onIdChange",[a,b]);this.Ka&&this.Ka(a,b);delete this.pull[a]},item:function(a){return this.pull[a]},update:function(a,b){dhx.isUndefined(b)&&(b=this.item(a));this.H&&this.H(b);if(this.callEvent("onBeforeUpdate",[a,b])===
!1)return!1;this.pull[a]=b;this.callEvent("onStoreUpdated",[a,b,"update"])},refresh:function(a){this.fa||(a?this.callEvent("onStoreUpdated",[a,this.pull[a],"paint"]):this.callEvent("onStoreUpdated",[null,null,null]))},silent:function(a,b){this.fa=!0;a.call(b||this);this.fa=!1},getRange:function(a,b){a=a?this.indexById(a):this.$min||this.startOffset||0;b?b=this.indexById(b):(b=Math.min(this.$max||this.endOffset||Infinity,this.dataCount()-1),b<0&&(b=0));if(a>b)var c=b,b=a,a=c;return this.getIndexRange(a,
b)},getIndexRange:function(a,b){for(var b=Math.min(b||Infinity,this.dataCount()-1),c=dhx.toArray(),d=a||0;d<=b;d++)c.push(this.item(this.order[d]));return c},dataCount:function(){return this.order.length},exists:function(a){return!!this.pull[a]},move:function(a,b){var c=this.idByIndex(a),d=this.item(c);this.order.removeAt(a);this.order.insertAt(c,Math.min(this.order.length,b));this.callEvent("onStoreUpdated",[c,d,"move"])},scheme:function(a){this.F={};this.G=a.$init;this.H=a.$update;this.ca=a.$serialize;this.ba=a.$group;this.da=a.$sort;for(var b in a)b.substr(0,1)!="$"&&(this.F[b]=a[b])},sync:function(a,b,c){typeof a=="string"&&(a=$$("source"));typeof b!="function"&&(c=b,b=null);this.I=!1;if(a.name!="DataStore")a.data&&a.data.name=="DataStore"?a=a.data:this.I=!0;var d=dhx.bind(function(d,f,g){if(this.I){if(!d)return;if(d.indexOf("change")===0){if(d=="change")this.pull[f.id]=f.attributes,this.refresh(f.id);return}d=="reset"&&(g=f);this.order=[];this.pull={};this.c=null;for(var h=0;h<g.models.length;h++){var i=
g.models[h].id;this.order.push(i);this.pull[i]=g.models[h].attributes}}else this.c=null,this.order=dhx.toArray([].concat(a.order)),this.pull=a.pull;b&&this.silent(b);this.Z&&this.Z();this.callEvent("onSyncApply",[]);c?c=!1:this.refresh()},this);this.I?a.bind("all",d):this.w=[a.attachEvent("onStoreUpdated",d),a.attachEvent("onIdChange",dhx.bind(function(a,b){this.changeId(a,b)},this))];d()},add:function(a,b,c){if(this.F)for(var d in this.F)dhx.isUndefined(a[d])&&(a[d]=this.F[d]);this.G&&this.G(a);var e=this.id(a),f=c||this.order,g=f.length;if(dhx.isUndefined(b)||b<0)b=g;b>g&&(b=Math.min(f.length,b));if(this.callEvent("onBeforeAdd",[e,a,b])===!1)return!1;this.pull[e]=a;f.insertAt(e,b);if(this.c){var h=this.c.length;!b&&this.order.length&&(h=0);this.c.insertAt(e,h)}this.callEvent("onAfterAdd",[e,b]);this.callEvent("onStoreUpdated",[e,a,"add"]);return e},remove:function(a){if(dhx.isArray(a))for(var b=0;b<a.length;b++)this.remove(a[b]);else{if(this.callEvent("onBeforeDelete",[a])===!1)return!1;var c=this.item(a);this.order.remove(a);this.c&&this.c.remove(a);delete this.pull[a];this.d[a]&&delete this.d[a];this.callEvent("onAfterDelete",[a]);this.callEvent("onStoreUpdated",[a,c,"delete"])}},clearAll:function(){this.pull={};this.order=dhx.toArray();this.c=this.url=null;this.callEvent("onClearAll",[]);this.refresh()},idByIndex:function(a){return this.order[a]},indexById:function(a){var b=this.order.find(a);return b},next:function(a,b){return this.order[this.indexById(a)+(b||1)]},first:function(){return this.order[0]},
last:function(){return this.order[this.order.length-1]},previous:function(a,b){return this.order[this.indexById(a)-(b||1)]},sort:function(a,b,c){var d=a;typeof a=="function"?d={as:a,dir:b}:typeof a=="string"&&(d={by:a.replace(/#/g,""),dir:b,as:c});var e=[d.by,d.dir,d.as];this.callEvent("onBeforeSort",e)&&(this.Ma(d),this.refresh(),this.callEvent("onAfterSort",e))},Ma:function(a){if(this.order.length){var b=this.La.qa(a),c=this.getRange(this.first(),this.last());c.sort(b);this.order=c.map(function(a){return this.id(a)},
this)}},wa:function(a){if(this.c&&!a)this.order=this.c,delete this.c},va:function(a,b,c){for(var d=dhx.toArray(),e=0;e<this.order.length;e++){var f=this.order[e];a(this.item(f),b)&&d.push(f)}if(!c||!this.c)this.c=this.order;this.order=d},filter:function(a,b,c){if(this.callEvent("onBeforeFilter",[a,b])&&(this.wa(c),this.order.length)){if(a){var d=a,b=b||"";typeof a=="string"&&(a=a.replace(/#/g,""),b=b.toString().toLowerCase(),d=function(b,c){return(b[a]||"").toString().toLowerCase().indexOf(c)!=-1});this.va(d,b,c,this.Pa)}this.refresh();this.callEvent("onAfterFilter",[])}},each:function(a,b){for(var c=0;c<this.order.length;c++)a.call(b||this,this.item(this.order[c]))},Ca:function(a,b){return function(){return a[b].apply(a,arguments)}},addMark:function(a,b,c,d){var e=this.d[a]||{};this.d[a]=e;if(!e[b]&&(e[b]=d||!0,c))this.item(a).$css=(this.item(a).$css||"")+" "+b,this.refresh(a);return e[b]},removeMark:function(a,b,c){var d=this.d[a];d&&d[b]&&delete d[b];if(c){var e=this.item(a).$css;if(e)this.item(a).$css=
e.replace(b,""),this.refresh(a)}},hasMark:function(a,b){var c=this.d[a];return c&&c[b]},provideApi:function(a,b){b&&this.mapEvent({onbeforesort:a,onaftersort:a,onbeforeadd:a,onafteradd:a,onbeforedelete:a,onafterdelete:a,onbeforeupdate:a});for(var c="sort,add,remove,exists,idByIndex,indexById,item,update,refresh,dataCount,filter,next,previous,clearAll,first,last,serialize,sync,addMark,removeMark,hasMark".split(","),d=0;d<c.length;d++)a[c[d]]=this.Ca(this,c[d])},serialize:function(){for(var a=this.order,
b=[],c=0;c<a.length;c++){var d=this.pull[a[c]];if(this.ca&&(d=this.ca(d),d===!1))continue;b.push(d)}return b},La:{qa:function(a){return this.ra(a.dir,this.ma(a.by,a.as))},ja:{date:function(a,b){a-=0;b-=0;return a>b?1:a<b?-1:0},"int":function(a,b){a*=1;b*=1;return a>b?1:a<b?-1:0},string_strict:function(a,b){a=a.toString();b=b.toString();return a>b?1:a<b?-1:0},string:function(a,b){if(!b)return 1;if(!a)return-1;a=a.toString().toLowerCase();b=b.toString().toLowerCase();return a>b?1:a<b?-1:0}},ma:function(a,
b){if(!a)return b;typeof b!="function"&&(b=this.ja[b||"string"]);return function(c,d){return b(c[a],d[a])}},ra:function(a,b){return a=="asc"||!a?b:function(a,d){return b(a,d)*-1}}}};dhx.BaseBind={bind:function(a,b,c){typeof a=="string"&&(a=dhx.ui.get(a));a.b&&a.b();this.b&&this.b();a.getBindData||dhx.extend(a,dhx.BindSource);if(!this.ka){var d=this.render;if(this.filter){var e=this.a.id;this.data.Z=function(){a.l[e]=!1}}this.render=function(){if(!this.X){this.X=!0;var a=this.callEvent("onBindRequest");this.X=!1;return d.apply(this,a===!1?arguments:[])}};if(this.getValue||this.getValues)this.save=function(){if(!this.validate||this.validate())a.setBindData(this.getValue?this.getValue:
this.getValues(),this.a.id)};this.ka=!0}a.addBind(this.a.id,b,c);var f=this.a.id;this.attachEvent(this.touchable?"onAfterRender":"onBindRequest",function(){return a.getBindData(f)});!this.a.dataFeed&&this.loadNext&&this.data.attachEvent("onStoreLoad",function(){a.l[f]=!1});this.isVisible(this.a.id)&&this.refresh()},g:function(a){a.removeBind(this.a.id);var b=this.w||(this.data?this.data.w:0);if(b&&a.data)for(var c=0;c<b.length;c++)a.data.detachEvent(b[c])}};dhx.BindSource={$init:function(){this.p={};this.l={};this.A={};this.la(this)},saveBatch:function(a){this.V=!0;a.call(this);this.V=!1;this.k()},setBindData:function(a,b){b&&(this.A[b]=!0);if(this.setValue)this.setValue(a);else if(this.setValues)this.setValues(a);else{var c=this.getCursor();c&&(a=dhx.extend(this.item(c),a,!0),this.update(c,a))}this.callEvent("onBindUpdate",[a,b]);this.save&&this.save();b&&(this.A[b]=!1)},getBindData:function(a,b){if(this.l[a])return!1;var c=dhx.ui.get(a);c.isVisible(c.a.id)&&
(this.l[a]=!0,this.J(c,this.p[a][0],this.p[a][1]),b&&c.filter&&c.refresh())},addBind:function(a,b,c){this.p[a]=[b,c]},removeBind:function(a){delete this.p[a];delete this.l[a];delete this.A[a]},la:function(a){a.filter?dhx.extend(this,dhx.CollectionBind):a.setValue?dhx.extend(this,dhx.ValueBind):dhx.extend(this,dhx.RecordBind)},k:function(){if(!this.V)for(var a in this.p)this.A[a]||(this.l[a]=!1,this.getBindData(a,!0))},S:function(a,b,c){a.setValue?a.setValue(c?c[b]:c):a.filter?a.data.silent(function(){this.filter(b,
c)}):!c&&a.clear?a.clear():a.z(c)&&a.setValues(dhx.clone(c));a.callEvent("onBindApply",[c,b,this])}};dhx.DataValue=dhx.proto({name:"DataValue",isVisible:function(){return!0},$init:function(a){var b=(this.data=a)&&a.id?a.id:dhx.uid();this.a={id:b};dhx.ui.views[b]=this},setValue:function(a){this.data=a;this.callEvent("onChange",[a])},getValue:function(){return this.data},refresh:function(){this.callEvent("onBindRequest")}},dhx.EventSystem,dhx.BaseBind);dhx.DataRecord=dhx.proto({name:"DataRecord",isVisible:function(){return!0},$init:function(a){this.data=a||{};var b=a&&a.id?a.id:dhx.uid();this.a={id:b};dhx.ui.views[b]=this},getValues:function(){return this.data},setValues:function(a){this.data=a;this.callEvent("onChange",[a])},refresh:function(){this.callEvent("onBindRequest")}},dhx.EventSystem,dhx.BaseBind,dhx.AtomDataLoader,dhx.Settings);dhx.DataCollection=dhx.proto({name:"DataCollection",isVisible:function(){return!this.data.order.length&&!this.data.c&&!this.a.dataFeed?!1:!0},$init:function(a){this.data.provideApi(this,!0);var b=a&&a.id?a.id:dhx.uid();this.a.id=b;dhx.ui.views[b]=this;this.data.attachEvent("onStoreLoad",dhx.bind(function(){this.callEvent("onBindRequest",[])},this))},refresh:function(){this.callEvent("onBindRequest",[])}},dhx.DataLoader,dhx.EventSystem,dhx.BaseBind,dhx.Settings);dhx.ValueBind={$init:function(){this.attachEvent("onChange",this.k)},J:function(a,b,c){var d=this.getValue()||"";c&&(d=c(d));if(a.setValue)a.setValue(d);else if(a.filter)a.data.silent(function(){this.filter(b,d)});else{var e={};e[b]=d;a.z(d)&&a.setValues(e)}a.callEvent("onBindApply",[d,b,this])}};dhx.RecordBind={$init:function(){this.attachEvent("onChange",this.k)},J:function(a,b){var c=this.getValues()||null;this.S(a,b,c)}};dhx.CollectionBind={$init:function(){this.h=null;this.attachEvent("onSelectChange",function(){var a=this.getSelected();this.setCursor(a?a.id||a:null)});this.attachEvent("onAfterCursorChange",this.k);this.data.attachEvent("onStoreUpdated",dhx.bind(function(a,b,c){a&&a==this.getCursor()&&c!="paint"&&this.k()},this));this.data.attachEvent("onClearAll",dhx.bind(function(){this.h=null},this));this.data.attachEvent("onIdChange",dhx.bind(function(a,b){if(this.h==a)this.h=b},this))},setCursor:function(a){if(!(a==
this.h||a!==null&&!this.item(a)))this.callEvent("onBeforeCursorChange",[this.h]),this.h=a,this.callEvent("onAfterCursorChange",[a])},getCursor:function(){return this.h},J:function(a,b){var c=this.item(this.getCursor())||this.a.defaultData||null;this.S(a,b,c)}};if(!dhx.ui)dhx.ui={};if(!dhx.ui.views)dhx.ui.views={},dhx.ui.get=function(a){return a.a?a:dhx.ui.views[a]};dhtmlXDataStore=function(a){var b=new dhx.DataCollection(a),c="_dp_init";b[c]=function(a){var b="_methods";a[b]=["dummy","dummy","changeId","dummy"];this.data.Da={add:"inserted",update:"updated","delete":"deleted"};this.data.attachEvent("onStoreUpdated",function(b,c,e){b&&!a.ea&&a.setUpdated(b,!0,this.Da[e])});b="_getRowData";a[b]=function(a){var b=this.obj.data.item(a),c={id:a};c[this.action_param]=this.obj.getUserData(a);if(b)for(var d in b)c[d]=b[d];return c};this.changeId=
function(b,c){this.data.changeId(b,c);a.ea=!0;this.data.callEvent("onStoreUpdated",[c,this.item(c),"update"]);a.ea=!1};b="_clearUpdateFlag";a[b]=function(){};this.ia={}};b.dummy=function(){};b.setUserData=function(a,b,c){this.ia[a]=c};b.getUserData=function(a){return this.ia[a]};b.dataFeed=function(a){this.define("dataFeed",a)};dhx.extend(b,dhx.BindSource);return b};if(window.dhtmlXDataView)dhtmlXDataView.prototype.b=function(){this.isVisible=function(){return!this.data.order.length&&!this.data.c&&!this.a.dataFeed?!1:!0};var a="_settings";this.a=this.a||this[a];if(!this.a.id)this.a.id=dhx.uid();this.unbind=dhx.BaseBind.unbind;this.unsync=dhx.BaseBind.unsync;dhx.ui.views[this.a.id]=this};if(window.dhtmlXChart)dhtmlXChart.prototype.b=function(){this.isVisible=function(){return!this.data.order.length&&!this.data.Qa&&!this.a.dataFeed?!1:!0};var a="_settings";this.a=this.a||this[a];if(!this.a.id)this.a.id=dhx.uid();this.unbind=dhx.BaseBind.unbind;this.unsync=dhx.BaseBind.unsync;dhx.ui.views[this.a.id]=this};dhx.BaseBind.unsync=function(a){return dhx.BaseBind.g.call(this,a)};dhx.BaseBind.unbind=function(a){return dhx.BaseBind.g.call(this,a)};dhx.BaseBind.legacyBind=function(){return dhx.BaseBind.bind.apply(this,arguments)};dhx.BaseBind.legacySync=function(a,b){this.b&&this.b();a.b&&a.b();this.attachEvent("onAfterEditStop",function(a){this.save(a);return!0});this.attachEvent("onDataRequest",function(b,d){for(var e=b;e<b+d;e++)if(!a.data.order[e])return a.loadNext(d,b),!1});this.save=function(b){b||(b=this.getCursor());var d=this.item(b),e=a.item(b),f;for(f in d)f.indexOf("$")!==0&&(e[f]=d[f]);a.refresh(b)};return a&&a.name=="DataCollection"?a.data.sync.apply(this.data,arguments):this.data.sync.apply(this.data,arguments)};if(window.dhtmlXForm)dhtmlXForm.prototype.bind=function(a){dhx.BaseBind.bind.apply(this,arguments);a.getBindData(this.a.id)},dhtmlXForm.prototype.unbind=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXForm.prototype.b=function(){if(dhx.isUndefined(this.a))this.a={id:dhx.uid(),dataFeed:this.j},dhx.ui.views[this.a.id]=this},dhtmlXForm.prototype.z=function(a){if(!this.a.dataFeed||this.N||!a)return!0;var b=this.a.dataFeed;if(typeof b=="function")return b.call(this,a.id||a,a);b=b+(b.indexOf("?")==-1?"?":
"&")+"action=get&id="+encodeURIComponent(a.id||a);this.load(b);return!1},dhtmlXForm.prototype.setValues=dhtmlXForm.prototype.setFormData,dhtmlXForm.prototype.getValues=function(){return this.getFormData(!1,!0)},dhtmlXForm.prototype.dataFeed=function(a){this.a?this.a.dataFeed=a:this.j=a},dhtmlXForm.prototype.refresh=dhtmlXForm.prototype.isVisible=function(){return!0};if(window.scheduler){if(!window.Scheduler)window.Scheduler={};Scheduler.$syncFactory=function(a){a.sync=function(b,c){this.b&&this.b();b.b&&b.b();var d="_process_loading",e=function(){a.clearAll();for(var e=b.data.order,g=b.data.pull,h=[],i=0;i<e.length;i++)h[i]=c&&c.copy?dhx.clone(g[e[i]]):g[e[i]];a[d](h)};this.save=function(a){a||(a=this.getCursor());var c=this.item(a),d=b.item(a);this.callEvent("onStoreSave",[a,c,d])&&(dhx.extend(b.item(a),c,!0),b.update(a))};this.item=function(a){return this.getEvent(a)};this.w=[b.data.attachEvent("onStoreUpdated",function(){e.call(this)}),b.data.attachEvent("onIdChange",function(a,b){combo.changeOptionId(a,b)})];this.attachEvent("onEventChanged",function(a){this.save(a)});this.attachEvent("onEventAdded",function(a,c){b.data.pull[a]||b.add(c)});this.attachEvent("onEventDeleted",function(a){b.data.pull[a]&&b.remove(a)});e()};a.unsync=function(a){dhx.BaseBind.g.call(this,a)};a.b=function(){if(!this.a)this.a={id:dhx.uid()}}};Scheduler.$syncFactory(window.scheduler)}
if(window.dhtmlXCombo)dhtmlXCombo.prototype.bind=function(){dhx.BaseBind.bind.apply(this,arguments)},dhtmlXCombo.unbind=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXCombo.unsync=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXCombo.prototype.dataFeed=function(a){this.a?this.a.dataFeed=a:this.j=a},dhtmlXCombo.prototype.sync=function(a){this.b&&this.b();a.b&&a.b();var b=this,c=function(){b.clearAll();b.addOption(this.serialize())};this.w=[a.data.attachEvent("onStoreUpdated",function(){c.call(this)}),
a.data.attachEvent("onIdChange",function(a,c){b.changeOptionId(a,c)})];c.call(a)},dhtmlXCombo.prototype.b=function(){if(dhx.isUndefined(this.a))this.a={id:dhx.uid(),dataFeed:this.j},dhx.ui.views[this.a.id]=this,this.data={silent:dhx.bind(function(a){a.call(this)},this)},dhtmlxEventable(this.data),this.attachEvent("onChange",function(){this.callEvent("onSelectChange",[this.getSelectedValue()])}),this.attachEvent("onXLE",function(){this.callEvent("onBindRequest",[])})},dhtmlXCombo.prototype.item=function(id){return this.getOption(id)},
dhtmlXCombo.prototype.getSelected=function(){return this.getSelectedValue()},dhtmlXCombo.prototype.isVisible=function(){return!this.optionsArr.length&&!this.a.dataFeed?!1:!0},dhtmlXCombo.prototype.refresh=function(){this.render(!0)},dhtmlXCombo.prototype.filter=function(){alert("not implemented")};if(window.dhtmlXGridObject)dhtmlXGridObject.prototype.bind=function(a,b,c){dhx.BaseBind.bind.apply(this,arguments)},dhtmlXGridObject.prototype.unbind=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXGridObject.prototype.unsync=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXGridObject.prototype.dataFeed=function(a){this.a?this.a.dataFeed=a:this.j=a},dhtmlXGridObject.prototype.sync=function(a,b){this.b&&this.b();a.b&&a.b();var c=this,d="_parsing",e="_parser",f="_locator",g="_process_store_row",h="_get_store_data";this.save=function(b){b||(b=this.getCursor());dhx.extend(a.item(b),this.item(b),!0);a.update(b)};var i=function(){var a=c.getCursor?c.getCursor():null,b=0;c.B?(b=c.B,c.B=!1):c.clearAll();var i=this.dataCount();if(i){c[d]=!0;for(var k=b;k<i;k++){var l=this.order[k];if(l&&(!b||!c.rowsBuffer[k]))c.rowsBuffer[k]={idd:l,data:this.pull[l]},c.rowsBuffer[k][e]=c[g],c.rowsBuffer[k][f]=c[h],c.rowsAr[l]=this.pull[l]}if(!c.rowsBuffer[i-1])c.rowsBuffer[i-1]=dhtmlx.undefined,c.xmlFileUrl=c.xmlFileUrl||this.url;c.pagingOn?c.changePage():c.Ta&&c.Oa?c.Ua():(c.render_dataset(),c.callEvent("onXLE",[]));c[d]=!1}a&&c.setCursor&&c.setCursor(c.rowsAr[a]?a:null)};this.w=[a.data.attachEvent("onStoreUpdated",function(a,b,d){d=="delete"?(c.deleteRow(a),c.data.callEvent("onStoreUpdated",[a,b,d])):d=="update"?(c.callEvent("onSyncUpdate",[b,d]),c.update(a,b),c.data.callEvent("onStoreUpdated",[a,b,d])):d=="add"?(c.callEvent("onSyncUpdate",[b,d]),c.add(a,b,this.indexById(a)),c.data.callEvent("onStoreUpdated",[a,b,d])):i.call(this)}),
a.data.attachEvent("onStoreLoad",function(b,d){c.xmlFileUrl=a.data.url;c.B=b.getInfo(d).m}),a.data.attachEvent("onIdChange",function(a,b){c.changeRowId(a,b)})];c.attachEvent("onDynXLS",function(b,d){for(var e=b;e<b+d;e++)if(!a.data.order[e])return a.loadNext(d,b),!1;c.B=b;i.call(a.data)});i.call(a.data);c.attachEvent("onEditCell",function(a,b){a==2&&this.save(b);return!0});c.attachEvent("onClearAll",function(){var a="_f_rowsBuffer";this[a]=null});b&&b.sort&&c.attachEvent("onBeforeSorting",function(b,
d,e){if(d=="connector")return!1;var f=this.getColumnId(b);a.sort("#"+f+"#",e=="asc"?"asc":"desc",d=="int"?d:"string");c.setSortImgState(!0,b,e);return!1});if(b&&b.filter)c.attachEvent("onFilterStart",function(b,d){var e="_con_f_used";if(c[e]&&c[e].length)return!1;a.data.silent(function(){a.filter();for(var e=0;e<b.length;e++)if(d[e]!=""){var f=c.getColumnId(b[e]);a.filter("#"+f+"#",d[e],e!=0)}});a.refresh();return!1}),c.collectValues=function(b){var c=this.getColumnId(b);return function(a){var b=
[],c={};this.data.each(function(d){var e=d[a];c[e]||(c[e]=!0,b.push(e))});return b}.call(a,c)};b&&b.select&&c.attachEvent("onRowSelect",function(b){a.setCursor(b)});c.clearAndLoad=function(b){a.clearAll();a.load(b)}},dhtmlXGridObject.prototype.b=function(){if(dhx.isUndefined(this.a)){this.a={id:dhx.uid(),dataFeed:this.j};dhx.ui.views[this.a.id]=this;this.data={silent:dhx.bind(function(a){a.call(this)},this)};dhtmlxEventable(this.data);for(var a="_cCount",b=0;b<this[a];b++)this.columnIds[b]||(this.columnIds[b]=
"cell"+b);this.attachEvent("onSelectStateChanged",function(a){this.callEvent("onSelectChange",[a])});this.attachEvent("onSelectionCleared",function(){this.callEvent("onSelectChange",[null])});this.attachEvent("onEditCell",function(a,b){a===2&&this.getCursor&&b&&b==this.getCursor()&&this.k();return!0});this.attachEvent("onXLE",function(){this.callEvent("onBindRequest",[])})}},dhtmlXGridObject.prototype.item=function(a){if(a===null)return null;var b=this.getRowById(a);if(!b)return null;var c="_attrs",
d=dhx.copy(b[c]);d.id=a;for(var e=this.getColumnsNum(),f=0;f<e;f++)d[this.columnIds[f]]=this.cells(a,f).getValue();return d},dhtmlXGridObject.prototype.update=function(a,b){for(var c=0;c<this.columnIds.length;c++){var d=this.columnIds[c];dhx.isUndefined(b[d])||this.cells(a,c).setValue(b[d])}var e="_attrs",f=this.getRowById(a)[e];for(d in b)f[d]=b[d];this.callEvent("onBindUpdate",[a])},dhtmlXGridObject.prototype.add=function(a,b,c){for(var d=[],e=0;e<this.columnIds.length;e++){var f=this.columnIds[e];d[e]=dhx.isUndefined(b[f])?"":b[f]}this.addRow(a,d,c);var g="_attrs";this.getRowById(a)[g]=dhx.copy(b)},dhtmlXGridObject.prototype.getSelected=function(){return this.getSelectedRowId()},dhtmlXGridObject.prototype.isVisible=function(){var a="_f_rowsBuffer";return!this.rowsBuffer.length&&!this[a]&&!this.a.dataFeed?!1:!0},dhtmlXGridObject.prototype.refresh=function(){this.render_dataset()},dhtmlXGridObject.prototype.filter=function(a,b){if(this.a.dataFeed){var c={};if(!a&&!b)return;if(typeof a=="function"){if(!b)return;a(b,c)}else dhx.isUndefined(a)?c=b:c[a]=b;this.clearAll();var d=this.a.dataFeed;if(typeof d=="function")return d.call(this,b,c);var e=[],f;for(f in c)e.push("dhx_filter["+f+"]="+encodeURIComponent(c[f]));this.load(d+(d.indexOf("?")<0?"?":"&")+e.join("&"));return!1}if(b===null)return this.filterBy(0,function(){return!1});this.filterBy(0,function(c,d){return a.call(this,d,b)})};if(window.dhtmlXTreeObject)dhtmlXTreeObject.prototype.bind=function(){dhx.BaseBind.bind.apply(this,arguments)},dhtmlXTreeObject.prototype.unbind=function(a){dhx.BaseBind.g.call(this,a)},dhtmlXTreeObject.prototype.dataFeed=function(a){this.a?this.a.dataFeed=a:this.j=a},dhtmlXTreeObject.prototype.b=function(){if(dhx.isUndefined(this.a))this.a={id:dhx.uid(),dataFeed:this.j},dhx.ui.views[this.a.id]=this,this.data={silent:dhx.bind(function(a){a.call(this)},this)},dhtmlxEventable(this.data),this.attachEvent("onSelect",
function(a){this.callEvent("onSelectChange",[a])}),this.attachEvent("onEdit",function(a,b){a===2&&b&&b==this.getCursor()&&this.k();return!0})},dhtmlXTreeObject.prototype.item=function(a){return a===null?null:{id:a,text:this.getItemText(a)}},dhtmlXTreeObject.prototype.getSelected=function(){return this.getSelectedItemId()},dhtmlXTreeObject.prototype.isVisible=function(){return!0},dhtmlXTreeObject.prototype.refresh=function(){},dhtmlXTreeObject.prototype.filter=function(a,b){if(this.a.dataFeed){var c=
{};if(a||b){if(typeof a=="function"){if(!b)return;a(b,c)}else dhx.isUndefined(a)?c=b:c[a]=b;this.deleteChildItems(0);var d=this.a.dataFeed;if(typeof d=="function")return d.call(this,[data.id||data,data]);var e=[],f;for(f in c)e.push("dhx_filter["+f+"]="+encodeURIComponent(c[f]));this.loadXML(d+(d.indexOf("?")<0?"?":"&")+e.join("&"));return!1}}},dhtmlXTreeObject.prototype.update=function(a,b){dhx.isUndefined(b.text)||this.setItemText(a,b.text)};dhtmlx.skin='dhx_skyblue';