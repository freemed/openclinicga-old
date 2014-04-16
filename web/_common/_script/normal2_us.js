var giDatePos=1;
var gbEuroCal=false;
var giFirstDOW=1;

var gsSplit="/";
var gbPadZero=true;
var giMonthMode=0;
var gbShortYear=false;
var gbAutoPos=true;
var gbPopDown=true;
var gbAutoClose=true;
var gPosOffset=[0,0];
var gbFixedPos=false;

var gMonths=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
var gWeekDay=["Su","Mo","Tu","We","Th","Fr","Sa"];

var gBegin=[1900,1,1];
var gEnd=gToday;
var gsOutOfRange="";
var guOutOfRange=null;

var gcCalBG="#a7c3d8";
var guCalBG=null;
var gcCalFrame="#778899";
var gsInnerTable="border=0 cellpadding=2 cellspacing=1";
var gsOuterTable=NN4?"border=1 cellpadding=3 cellspacing=0":"border=0 cellpadding=0 cellspacing=2";

var gbHideTop=false;
var giDCStyle=0;
var gsCalTitle="gMonths[gCurMonth[1]-1]+' '+gCurMonth[0]";
var gbDCSeq=true;
var gsYearInBox="i";
var gsNavPrev="<INPUT type='button' value=' &lt; ' class='MonthNav' onmousedown='showPrevMon()' onmouseup='stopShowMon()' onmouseout='stopShowMon();if(this.blur)this.blur()'>";
var gsNavNext="<INPUT type='button' value=' &gt; ' class='MonthNav' onmousedown='showNextMon()' onmouseup='stopShowMon()' onmouseout='stopShowMon();if(this.blur)this.blur()'>";

var gbHideBottom=false;
var dayNumberAppendix = (gToday[2]==1?"st":(gToday[2]==2?"nd":(gToday[2]==3?"rd":"th")));
var gsBottom="<A href='javascript:void(0)' class='Today' onclick='if(this.blur)this.blur();if(!fSetDate(gToday[0],gToday[1],gToday[2]))alert(\"Today is not a selectable date!\");return false;' onmouseover='return true;' title='Today'>Today: "+gMonths[gToday[1]-1]+" "+gToday[2]+dayNumberAppendix+" "+gToday[0]+"</A>";

var giCellWidth=18;
var giCellHeight=14;
var giHeadHeight=14;
var giWeekWidth=14;
var giHeadTop=1;
var giWeekTop=0;

var gcCellBG="#e5e5e5";
var gsCellHTML="";
var guCellBGImg="";
var gsAction=" ";
var gsDays="dayNo";

var giWeekCol=-1;
var gsWeekHead="#";
var gsWeeks="weekNo";

var gcWorkday="black";
var gcSat="black";
var gcSatBG="#99ccff";
var gcSun="black";
var gcSunBG="#99ccff";

var gcOtherDay="silver";
var gcOtherDayBG=gcCellBG;
var giShowOther=2;

var gbFocus=true;
var gcToggle="yellow";

var gcFGToday="red";
var gcBGToday="white";
var guTodayBGImg="";
var giMarkToday=1+2;
var gsTodayTip="Today";

var gcFGSelected="white";
var gcBGSelected="#DB5141";
var guSelectedBGImg="";
var giMarkSelected=2;
var gsSelectedTip="";

var gbBoldAgenda=true;
var gbInvertBold=false;
var gbShrink2fit=true;
var gdSelect=[0,0,0];
var giFreeDiv=0;
var gAgendaMask=[-1,-1,-1,null,null,-1,null];

var giResizeDelay=KO3?150:50;
var gbFlatBorder=false;
var gbInvertBorder=false;
var gbShareAgenda=false;
var gsAgShared="gContainer._cxp_agenda";
var gbCacheAgenda=false;
var giShowInterval=250;