<script src='<c:url value="/_common/_script/prototype.js"/>'></script>

<style>
<!--
.hide { position:absolute; visibility:hidden; }
.show { position:absolute; visibility:visible; }
-->
</style>

<SCRIPT LANGUAGE="JavaScript">

//Progress Bar script- by Todd King (tking@igpp.ucla.edu)
//Modified by JavaScript Kit for NS6, ability to specify duration
//Visit JavaScript Kit (http://javascriptkit.com) for script

var progressId="";
var duration=3 // Specify duration of progress bar in seconds
var _progressWidth = 50;	// Display width of progress bar.

var _progressBar = "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
var _progressEnd = 5;
var _progressAt = 0;
var handle;


// Create and display the progress dialog.
// end: The number of steps to completion
function ProgressCreate(end) {
	// Initialize state variables
	_progressEnd = end;
	_progressAt = 0;

	// Move layer to center of window to show
	if (document.all) {	// Internet Explorer
		progress.className = 'show';
		progress.style.left = (document.body.clientWidth/2) - (progress.offsetWidth/2);
		progress.style.top = document.body.scrollTop+(document.body.clientHeight/2) - (progress.offsetHeight/2);
	} else if (document.layers) {	// Netscape
		document.progress.visibility = true;
		document.progress.left = (window.innerWidth/2) - 100+"px";
		document.progress.top = pageYOffset+(window.innerHeight/2) - 40+"px";
	} else if (document.getElementById) {	// Netscape 6+
		document.getElementById("progress").className = 'show';
		document.getElementById("progress").style.left = (window.innerWidth/2)- 100+"px";
		document.getElementById("progress").style.top = pageYOffset+(window.innerHeight/2) - 40+"px";
	}

	ProgressUpdate();	// Initialize bar
}

// Hide the progress layer
function ProgressDestroy() {
	window.clearInterval(handle);
	// Move off screen to hide
	if (document.all) {	// Internet Explorer
		progress.className = 'hide';
	} else if (document.layers) {	// Netscape
		document.progress.visibility = false;
	} else if (document.getElementById) {	// Netscape 6+
		document.getElementById("progress").className = 'hide';
	}
}

// Increment the progress dialog one step
function ProgressStepIt() {
	_progressAt++;
	if(_progressAt > _progressEnd) _progressAt = _progressAt % _progressEnd;
	ProgressUpdate();
}

// Update the progress dialog with the current state
function ProgressUpdate() {
	var n = (_progressWidth / _progressEnd) * _progressAt;
	if (document.all) {	// Internet Explorer
		var bar = dialog.bar;
 	} else if (document.layers) {	// Netscape
		var bar = document.layers["progress"].document.forms["dialog"].bar;
		n = n * 0.55;	// characters are larger
	} else if (document.getElementById){
                var bar=document.getElementById("bar")
        }
	var temp = _progressBar.substring(0, n);
	bar.value = temp;
}

function startProgress(id) {
	progressId=id;
	initProgressValue();
	handle=window.setInterval('getProgressValue();',100);
	ProgressCreate(100);
}

function setProgress(progressValue) {
	if(_progressAt >= _progressEnd) {
		ProgressDestroy();
		return;
	}
	_progressAt = progressValue;
	ProgressUpdate();
}

function makeProgressBar(){
	//Create layer for progress dialog
	document.write("<span id=\"progress\" class=\"hide\">");
		document.write("<FORM name=dialog id=dialog>");
		document.write("<TABLE border=2  bgcolor=\"#FFFFCC\">");
		document.write("<TR><TD ALIGN=\"center\">");
		document.write("Progress<BR>");
		document.write("<input type=text readonly name=\"bar\" id=\"bar\" size=\"" + _progressWidth/2 + "\"");
		if(document.all||document.getElementById) 	// Microsoft, NS6
			document.write(" bar.style=\"color:navy;\">");
		else	// Netscape
			document.write(">");
		document.write("</TD></TR>");
		document.write("</TABLE>");
		document.write("</FORM>");
	document.write("</span>");
	ProgressDestroy();	// Hides
}

function getProgressValue(){
    var params = 'id='+progressId;
    var today = new Date();
    var url= '<c:url value="/util/ajax/getProgressBarValue.jsp?ts="/>'+today;
	new Ajax.Request(url,{
			method: "GET",
            parameters: params,
            onSuccess: function(resp){
                setProgress(resp.responseText);
            },
			onFailure: function(){
            }
		}
	);
}

function initProgressValue(){
    var params = 'id='+progressId+"&init=true";
    var today = new Date();
    var url= '<c:url value="/util/ajax/getProgressBarValue.jsp?ts=i"/>'+today;
	new Ajax.Request(url,{
			method: "GET",
            parameters: params,
            onSuccess: function(resp){
            },
			onFailure: function(){
            }
		}
	);
}


</script>
