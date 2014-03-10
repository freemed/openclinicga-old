<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="stats">
<%
    if(activeUser.getAccessRight("datacenter.select")){
        out.print(ScreenHelper.writeTblHeader(getTran("web","datacenter.monitoring",sWebLanguage),sCONTEXTPATH)
            +writeTblChildNoButton("main.do?Page=datacenter/projectoverview.jsp",getTran("web","datacenter.projectoverview",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    }

%>
</form>
<script>
    function downloadStats(query,db){
        var w=window.open("<c:url value='/util/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.getElementsByName('begin')[0].value+"&end="+document.getElementsByName('end')[0].value);
    }
</script>