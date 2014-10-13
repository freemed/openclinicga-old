<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="stats">
<%
String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date());
String lastdayPreviousMonth=ScreenHelper.formatDate(new java.util.Date());

out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.memberconsumptionstats",sWebLanguage),sCONTEXTPATH)
        +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","stats",lastdayPreviousMonth,sWebLanguage));

out.println("&nbsp;</td></tr>"
        +writeTblChildWithCode("javascript:memberSummaryReport()",getTran("Web","statistics.member.summary.report",sWebLanguage))
    +ScreenHelper.writeTblFooter()+"<br>");

out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.insuranceandinvoicingstats",sWebLanguage),sCONTEXTPATH)
        +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","stats",lastdayPreviousMonth,sWebLanguage)
        +" "+getTran("web","insurar",sWebLanguage));
%>
        <input type="hidden" name="insuraruid" id="insuraruid" value=""/>
        <input class="text" type="text" readonly name="EditInsurarName" value="" size="<%=sTextWidth%>"/>
        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
<%

out.println("&nbsp;</td></tr>"
        +writeTblChildWithCode("javascript:insurerSummaryReport()",getTran("Web","statistics.insurar.summary.report",sWebLanguage))
    +ScreenHelper.writeTblFooter()+"<br>");

out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.careproviderstats",sWebLanguage),sCONTEXTPATH)
        +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin2","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end2","stats",lastdayPreviousMonth,sWebLanguage)
        +" "+getTran("web","careprovider",sWebLanguage));
%>
        <input type="hidden" name="serviceuid" id="serviceuid" value=""/>
        <input class="text" type="text" readonly name="EditServiceName" value="" size="<%=sTextWidth%>"/>
        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('serviceuid','EditServiceName');">
<%

out.println("&nbsp;</td></tr>"
        +writeTblChildWithCode("javascript:careproviderSummaryReport()",getTran("Web","statistics.careprovider.summary.report",sWebLanguage))
    +ScreenHelper.writeTblFooter()+"<br>");

%>
</form>

<script>
function insurerSummaryReport(){
	var URL = "statistics/insurerSummaryReport.jsp&begin="+document.getElementById('begin').value+"&end="+document.getElementById('end').value+"&insuraruid="+document.getElementById('insuraruid').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,670,"OpenClinic");
}

function careproviderSummaryReport(){
	var URL = "statistics/careproviderSummaryReport.jsp&begin="+document.getElementById('begin').value+"&end="+document.getElementById('end').value+"&serviceuid="+document.getElementById('serviceuid').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,230,"OpenClinic");
}

function memberSummaryReport(){
	var URL = "statistics/memberSummaryReport.jsp&begin="+document.getElementById('begin').value+"&end="+document.getElementById('end').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,230,"OpenClinic");
}

    function searchInsurar(){
        openPopup("_common/search/searchInsurar.jsp&ts=<%=getTs()%>&showinactive=1&ReturnFieldInsurarUid=insuraruid&ReturnFieldInsurarName=EditInsurarName&ExcludeCoverageplans=true");
    }
    
    function searchService(serviceUidField,serviceNameField){
        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.getElementsByName(serviceNameField)[0].focus();
    }


</script>