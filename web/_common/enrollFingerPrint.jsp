<%@include file="/includes/validateUser.jsp"%>
<form name="frmEnrollFingerPrint" method="post">
    <%=writeTableHeader("web","enrollFingerPrint",sWebLanguage,"")%>
    <table width="100%" class="list">
        <tr>
            <td>
                <input type="radio" id="righthand" name="rightleft" value="R" checked/><%=getTran("web","right",sWebLanguage)%>
                <input type="radio" id="lefthand" name="rightleft" value="L"/><%=getTran("web","left",sWebLanguage)%>
            </td>
            <td>
                <select name="finger" class="text">
                    <option value="0"><%=getTran("web","thumb",sWebLanguage)%></option>
                    <option selected value="1"><%=getTran("web","index",sWebLanguage)%></option>
                    <option value="2"><%=getTran("web","middlefinger",sWebLanguage)%></option>
                    <option value="3"><%=getTran("web","ringfinger",sWebLanguage)%></option>
                    <option value="4"><%=getTran("web","littlefinger",sWebLanguage)%></option>
                </select>
            </td>
        </tr>
    </table>
    <center>
        <input type="button" class="button" name="enrollButton" value="<%=getTran("web","read",sWebLanguage)%>" onclick="doRead()"/>
        <input type="button" class="button" name="buttonClose" value="<%=getTran("web","close",sWebLanguage)%>" onclick="window.close()"/>
    </center>
    <table>
    	<tr>
    		<td>
			    <table>
			    	<tr>
			    		<td><span name='clock' id='clock'></span></td>
			    		<td><label name='readerID' id='readerID'></label></td>
			       	</tr>
			    </table>
    		</td>
    		<td>
				<img width='80px' id='fingerprintImage' name='fingerprintImage' src="<c:url value="/_img/fingerprintImageSmallNoPrint.jpg"/>"/>
    		</td>
    	</tr>
    </table>
    <br>
</form>

<script>
   	var _app = navigator.appName;
   	var presscount=0;
   	var readerActive=false;
   	var r="";
  	
  	function onErrorHandler() {
        alert("Error");
    }
  	
  	function onLoadHandler(){
  		document.UareUApplet.SelectFormatISO();
	}

    function onDisconnectedHandler() {
        setTimeout('document.getElementById("readerID").innerHTML="<%=getTranNoLink("web","no.reader",sWebLanguage)%>"');
    }

    function onConnectedHandler(reader) {
  		r=reader;
  		document.getElementById('readerID').innerHTML=r+' <%=getTranNoLink("web","detected",sWebLanguage)%>';
  		document.UareUApplet.SelectFormatISO();
    }

    function onCaptureHandler() {
    	if(readerActive){
    		presscount++;
    		if(presscount<4){
				document.getElementById('readerID').innerHTML='<%=getTranNoLink("web","enroll.fingerprint",sWebLanguage)%>: <font style="font-size: 20px" color="red">'+(4-presscount)+'</font></span> <%=getTranNoLink("web","readings.to.go",sWebLanguage)%>';
    		}
    	}
    }

    function onEnrollmentFailureHandler() {
    	if(readerActive){
	    	document.getElementById("fingerprintImage").src="<c:url value="/_img/fingerprintImageSmallWrong.jpg"/>";
			document.getElementById('readerID').innerHTML='<%=getTranNoLink("web","error.fingerprint",sWebLanguage)%>';
	    	setTimeout("document.getElementById('fingerprintImage').src='<c:url value="/_img/fingerprintImageSmallNoPrint.jpg"/>'", 2000);
	    	setTimeout("doRead()",2000);
    	}
    }


    function onFMDHandler( hexFMD ) {
    	if(readerActive){
		    var url = '<c:url value="/_common/storeFingerprint.jsp"/>?ts=' + <%=getTs()%>;
		    var r='L';
		    if(document.getElementById('righthand').checked){
		    	r='R';
		    }
		    var parameters= 'fmd=' + hexFMD+'&rightleft='+r+'&finger='+frmEnrollFingerPrint.finger.value;
		
		    new Ajax.Request(url, {
		        method: "POST",
		        postBody: parameters,
		        onSuccess: function(resp) {
			    	document.getElementById("fingerprintImage").src='<c:url value="/_img/fingerprintImageSmall.jpg"/>';
					document.getElementById('readerID').innerHTML='<%=getTranNoLink("web","succes.enroll.fingerprint",sWebLanguage)%>';
		    		readerActive=false;
			  		setTimeout("document.getElementById('readerID').innerHTML=r+' <%=getTranNoLink("web","detected",sWebLanguage)%>'",2000);
			    	setTimeout("document.getElementById('fingerprintImage').src='<c:url value="/_img/fingerprintImageSmallNoPrint.jpg"/>'", 2000);
		        },
		        onFailure: function() {
			    	document.getElementById("fingerprintImage").src="<c:url value="/_img/fingerprintImageSmallWrong.jpg"/>";
					document.getElementById('readerID').innerHTML='<%=getTranNoLink("web","error.fingerprint",sWebLanguage)%>';
			    	setTimeout("document.getElementById('fingerprintImage').src='<c:url value="/_img/fingerprintImageSmallNoPrint.jpg"/>'", 2000);
			    	setTimeout("doRead()",2000);
		        }
		    }
		    );
	    }
	    presscount=0;
    }

	function doRead(){
		readerActive=true;
		presscount=0;
		document.UareUApplet.resetEnrollment();
		document.getElementById('readerID').innerHTML='<%=getTranNoLink("web","enroll.fingerprint",sWebLanguage)%>: <font style="font-size: 20px" color="red">'+(4-presscount)+'</font></span> <%=getTranNoLink("web","readings.to.go",sWebLanguage)%>';
		
	}
	
    if (_app == 'Netscape' || _app == 'Opera') {
        document.write('<object classid="java:UareUApplet.class"',
          'type="application/x-java-applet"',
          'name="UareUApplet"',
          'width="1"',  //apparently need to have dimension > 0 for foreground window to be associated with jvm process.
          'height="0"', //otherwise, if w&h=0, must use exlusive priority
          'type="application/x-java-applet"',
          'pluginspage="http://java.sun.com/javase/downloads"',
          'archive="<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/UareUApplet.jar,<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/dpuareu.jar"',
          'onFMDAcquiredScript="onFMDHandler"',
          'onEnrollmentFailureScript="onEnrollmentFailureHandler"',
          'onImageCapturedScript="onCaptureHandler"',
          'onErrorScript="onErrorHandler"',
          'onLoadScript="onLoadHandler"',
          'onDisconnectedScript="onDisconnectedHandler"',
          'onConnectedScript="onConnectedHandler"',
          'bRegistrationMode="true"',
          'bDebug="true"',
          'bExclusivePriority="true"',
          'scriptable="true"',
          'mayscript="true"',
          'separate_jvm="true"> </object>');
   }
   else if(_app=="Microsoft Internet Explorer") {
	   document.write( '<object classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93"',
	    'height="1" width="0" name="UareUApplet">',
	    '<param name="type" value="application/x-java-applet;version=1.6" />',
	    '<param name="code" value="UareUApplet"/>',
	    '<param name="scriptable" value="true" />',
	    '<param name="archive" value="<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/UareUApplet.jar,<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/dpuareu.jar"/>',
	    '<param name="onFMDAcquiredScript" value="onFMDHandler" />',
	    '<param name="onImageCapturedScript" value="onCaptureHandler" />',
	    '<param name="onEnrollmentFailureScript" value="onEnrollmentFailureHandler"/>',
	    '<param name="bDebug" value="true" />',
	    '<param name="bRegistrationMode" value="true" />',
	    '<param name="onErrorScript" value="onErrorHandler" />',
	    '<param name="onLoadScript" value="onLoadHandler" />',
	    '<param name="onDisconnectedScript" value="onDisconnectedHandler" />',
	    '<param name="onConnectedScript" value="onConnectedHandler" />',
	    '<param name="bExclusivePriority" value="false"/>',
	    '<param name="separate_jvm" value="true" />',
	    '</object>');
    }
	
</script>