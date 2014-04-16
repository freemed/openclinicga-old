// load an url in the window/frame designated by "framename".
function popup(url,framename){	
	var w=parent.open(url,framename,"top=200,left=200,width=400,height=200,scrollbars=1,resizable=1");
	if(w&&url.split(":")[0]=="mailto") w.close();
	else if(w&&!framename) w.focus();
}

// return the d(ate) of the q-th n-day of a specific m(onth) in a specific y(ear)
function getDateByDOW(y,m,q,n){ 
// q: 1 - 5 ( 5 denotes the last n-day )
// n: 0 - Sunday, 1 - Monday ... 6 - Saturday
	var dom=new Date(y,m-1,1).getDay();
	var d=7*q-6+n-dom;
	if(dom>n) d+=7;
	if(d>fGetDays(y)[m]) d-=7;
	return d;	// ranged from 1 to 31
}