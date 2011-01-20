<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="stats">
<%
    if(activeUser.getAccessRight("patient.administration.add")||activeUser.getAccessRight("statistics.quickdiagnosisentry")){

        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.quickdiagnosisentry",sWebLanguage),sCONTEXTPATH)
            +writeTblChildWithCode("javascript:openPopup(\"statistics/quickFile.jsp\",800,600,\"quickFile\")",getTran("Web","statistics.quickdiagnosisentry",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    }

    if(activeUser.getAccessRight("statistics.globalpathologydistribution.select")){
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.pathologystats",sWebLanguage),sCONTEXTPATH)
            +writeTblChildNoButton("main.do?Page=statistics/diagnosisStats.jsp",getTran("Web","statistics.globalpathology",sWebLanguage))
            +writeTblChildNoButton("main.do?Page=statistics/mortality.jsp",getTran("Web","statistics.mortality",sWebLanguage))
            +writeTblChildNoButton("main.do?Page=statistics/diagnosesList.jsp",getTran("Web","statistics.diagnosisList",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    }

    if(activeUser.getAccessRight("statistics.select")) {
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.activitystats",sWebLanguage),sCONTEXTPATH)
                +writeTblChildNoButton("main.do?Page=statistics/databaseStatistics.jsp",getTran("Web","statistics.activitystats.database",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/diagnosticCodingStats.jsp",getTran("Web","statistics.activitystats.diagnosticcoding",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/encounterCodingStats.jsp",getTran("Web","statistics.activitystats.encountercoding",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/recordViewingStats.jsp",getTran("Web","statistics.activitystats.recordviewing",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/transactionViewingStats.jsp",getTran("Web","statistics.activitystats.transactionviewing",sWebLanguage))
                //+writeTblChildNoButton("main.do?Page=statistics/prestationCodingStats.jsp",getTran("Web","statistics.activitystats.prestationcoding",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
        String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        String lastdayPreviousMonth=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.insuranceandinvoicingstats",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin3","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3","stats",lastdayPreviousMonth,sWebLanguage)+"&nbsp;</td></tr>"
                +writeTblChildWithCode("javascript:insuranceReport()",getTran("Web","statistics.insurancestats.distribution",sWebLanguage))
	            +writeTblChildWithCode("javascript:incomeVentilation()",getTran("Web","statistics.incomeVentilationPerFamily",sWebLanguage))
	            +writeTblChildWithCode("javascript:incomeVentilationExtended()",getTran("Web","statistics.incomeVentilationPerCategoryAndService",sWebLanguage))
	        +ScreenHelper.writeTblFooter()+"<br>");
        String service =activeUser.activeService.code;
        String serviceName = activeUser.activeService.getLabel(sWebLanguage);
        String today=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.treatedpatients",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin3b","stats",today,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3b","stats",today,sWebLanguage)+"&nbsp;</td></tr>"
                +"<tr><td>"+getTran("Web","service",sWebLanguage)+"</td><td colspan='2'><input type='hidden' name='statserviceid' id='statserviceid' value='"+service+"'>"
                +"<input class='text' type='text' name='statservicename' id='statservicename' readonly size='"+sTextWidth+"' value='"+serviceName+"' onblur=''>"
                +"<img src='_img/icon_search.gif' class='link' alt='"+getTran("Web","select",sWebLanguage)+"' onclick='searchService(\"statserviceid\",\"statservicename\");'>"
                +"<img src='_img/icon_delete.gif' class='link' alt='"+getTran("Web","clear",sWebLanguage)+"' onclick='statserviceid.value=\"\";statservicename.value=\"\";'>"
                +"</td></tr>"
                +writeTblChildWithCode("javascript:patientslistvisits()",getTran("Web","statistics.patientslist.visits",sWebLanguage))
                +writeTblChildWithCode("javascript:patientslistadmissions()",getTran("Web","statistics.patientslist.admissions",sWebLanguage))
	        +ScreenHelper.writeTblFooter()+"<br>");
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.servicestats",sWebLanguage),sCONTEXTPATH)
                +writeTblChildNoButton("main.do?Page=statistics/hospitalStats.jsp",getTran("Web","statistics.hospitalstats.global",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/serviceStats.jsp",getTran("Web","statistics.servicestats.contacts",sWebLanguage))
                +writeTblChildNoButton("main.do?Page=statistics/districtStats.jsp",getTran("Web","statistics.districtstats",sWebLanguage)));

        if(activeUser.getAccessRight("statistics.servicetransactions.select")){
            out.print(writeTblChildNoButton("main.do?Page=statistics/serviceTransactionStats.jsp",getTran("Web","statistics.servicetransactions",sWebLanguage)));
        }
        if(activeUser.getAccessRight("statistics.episodesperdepartment.select")){
            out.print(writeTblChildNoButton("main.do?Page=statistics/showEncountersPerService.jsp",getTran("Web","statistics.serviceepisodes",sWebLanguage)));
        }

        out.print(
            writeTblChildNoButton("main.do?Page=statistics/hospitalizedPatients.jsp",getTran("Web","statistics.hospitalizedpatients",sWebLanguage))+
            writeTblChildNoButton("main.do?Page=statistics/serviceIncome.jsp",getTran("Web","statistics.serviceIncome",sWebLanguage))+
            writeTblChildNoButton("main.do?Page=statistics/diagnosesPerSituation.jsp",getTran("Web","statistics.diagnosespersituation",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");

        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.download",sWebLanguage),sCONTEXTPATH)
            +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin","stats","01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date()),sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","stats","31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date()),sWebLanguage)+"&nbsp;</td></tr>"
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"global.list\",\"openclinic\");",getTran("Web","statistics.download.global",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"globalrfe.list\",\"openclinic\");",getTran("Web","statistics.download.globalrfe",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"encounter.list\",\"openclinic\");",getTran("Web","statistics.download.encounterlist",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"diagnosis.list\",\"openclinic\");",getTran("Web","statistics.download.diagnosislist",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"rfe.list\",\"openclinic\");",getTran("Web","statistics.download.rfelist",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"document.list\",\"openclinic\");",getTran("Web","statistics.download.documentlist",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"user.list\",\"admin\");",getTran("Web","statistics.download.userlist",sWebLanguage))
            +writeTblChildWithCodeNoButton("javascript:downloadStats(\"service.list\",\"openclinic\");",getTran("Web","statistics.download.servicelist",sWebLanguage))
            +(MedwanQuery.getInstance().getConfigInt("datacenterenabled",0)==1?writeTblChildWithCodeNoButton("javascript:downloadDatacenterStats(\"service.income.list\",\"stats\");",getTran("Web","statistics.download.serviceincomelist",sWebLanguage)):"")
            +ScreenHelper.writeTblFooter()+"<br>");

         out.print(ScreenHelper.writeTblHeader(getTran("Web","financial",sWebLanguage),sCONTEXTPATH)+
            writeTblChildNoButton("main.do?Page=statistics/toInvoiceLists.jsp",getTran("Web","statistics.toinvoicelists",sWebLanguage))+
            ScreenHelper.writeTblFooter()+"<br>");
    }

    if(activeUser.getAccessRight("statistics.chin.select")){
        String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        String lastdayPreviousMonth=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        out.print(ScreenHelper.writeTblHeader(getTran("Web","chin",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin2","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end2","stats",lastdayPreviousMonth,sWebLanguage)+"&nbsp;</td></tr>"
                +writeTblChildWithCode("javascript:hospitalReport()",getTran("Web","chin.global.hospital.report",sWebLanguage))
                +writeTblChildWithCode("javascript:minisanteReport()",getTran("Web","chin.minisantereport.health.center",sWebLanguage))
                +writeTblChildWithCode("javascript:minisanteReportDH()",getTran("Web","chin.minisantereport.district.hospital",sWebLanguage))
                +writeTblChildWithCode("javascript:openPopup(\"chin/chinGraph.jsp&ts="+getTs()+"\",1000,750)",getTran("Web","chin.actualsituation",sWebLanguage))
                +writeTblChildWithCode("main.jsp?Page=healthnet/index.jsp&ts="+getTs(),getTran("Web","chin.healthnet",sWebLanguage))
           +ScreenHelper.writeTblFooter()+"<br>");
    }
%>
</form>
<script type="text/javascript">
	function downloadStats(query,db){
	    var w=window.open("<c:url value='/util/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.all['begin'].value+"&end="+document.all['end'].value);
	}
	function downloadDatacenterStats(query,db){
	    var w=window.open("<c:url value='/datacenterstatistics/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.all['begin'].value+"&end="+document.all['end'].value);
	}
    function minisanteReport(){
        var w=window.open("<c:url value='/statistics/createMonthlyReportPdf.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
    }
    function minisanteReportDH(){
        var w=window.open("<c:url value='/statistics/createMonthlyReportPdfDH.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
    }
    function hospitalReport(){
        var w=window.open("<c:url value='/statistics/printHospitalReportChapterSelection.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
    }
    function insuranceReport(){
        window.location.href="<c:url value='main.jsp?Page=/statistics/insuranceStats.jsp&'/>start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
    }
    function patientslistvisits(){
		var URL = "statistics/patientslistvisits.jsp&start="+document.getElementById('begin3b').value+"&end="+document.getElementById('end3b').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function patientslistadmissions(){
		var URL = "statistics/patientslistadmissions.jsp&start="+document.getElementById('begin3b').value+"&end="+document.getElementById('end3b').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function incomeVentilation(){
		var URL = "statistics/incomeVentilation.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function incomeVentilationExtended(){
		var URL = "statistics/incomeVentilationExtended.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function searchService(serviceUidField,serviceNameField){
        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.all[serviceNameField].focus();
    }
    
</script>