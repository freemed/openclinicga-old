<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name="stats">
	<%
		out.print(ScreenHelper.writeTblHeader(getTran("Web","select.datasource",sWebLanguage),sCONTEXTPATH));
	%>
		<tr>
			<td width="1%">
				<input class="radiobutton" type="radio" name="datasource" checked/><%=getTran("web","hospital",sWebLanguage)%>&nbsp;
			</td>
			<td>
				<select name="datasourcehospital" class="text">
					<option>RH CHUK</option>
					<option>RH Ndera</option>
					<option>DH Gihundwe</option>
					<option>DH Muhima</option>
					<option>DH Nyamata</option>
					<option>DH Kibagabaga</option>
					<option>DH Rutongo</option>
					<option>DH Rwamagana</option>
					<option>PC Bien Naître</option>
					<option>PC Biomedical Center</option>
					<option>PC Carrefour</option>
					<option>PC La Croix du Sud</option>
					<option>PC La Médicale</option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<input class="radiobutton" type="radio" name="datasource"/><%=getTran("web","district",sWebLanguage)%>&nbsp;
			</td>
			<td>
			<%
		        StringBuffer sDistricts = new StringBuffer("<select class='text' id='PDistrict' name='PDistrict'>");
		        Vector vDistricts = Zipcode.getDistricts(MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
		        Collections.sort(vDistricts);
		        String sTmpDistrict;
		        boolean bDistrictSelected = false;
		        for (int i=0;i<vDistricts.size();i++){
		            sTmpDistrict = (String)vDistricts.elementAt(i);
		            sDistricts.append("<option value='"+sTmpDistrict+"'>"+sTmpDistrict+"</option>");
		        }
		        sDistricts.append("</select>");
		        out.print(sDistricts.toString());
			%>
			</td>
		</tr>
	<%=ScreenHelper.writeTblFooter()+"<br>"%>
<%
    if(activeUser.getAccessRight("statistics.globalpathologydistribution.select")){
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.pathologystats",sWebLanguage),sCONTEXTPATH)
            +writeTblChildNoButton("main.do?Page=statistics/diagnosisStats.jsp",getTran("Web","statistics.globalpathology",sWebLanguage))
            +writeTblChildNoButton("main.do?Page=datacenterstatistics/mortality.jsp",getTran("Web","statistics.mortality",sWebLanguage))
            +writeTblChildNoButton("main.do?Page=statistics/diagnosesList.jsp",getTran("Web","statistics.diagnosisList",sWebLanguage))
            +ScreenHelper.writeTblFooter()+"<br>");
    }

    if(activeUser.getAccessRight("statistics.select")) {
        String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        String lastdayPreviousMonth=ScreenHelper.stdDateFormat.format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.insurancestats",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin3","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3","stats",lastdayPreviousMonth,sWebLanguage)+"&nbsp;</td></tr>"
                +writeTblChildWithCode("javascript:insuranceReport()",getTran("Web","statistics.insurancestats.distribution",sWebLanguage))
	        +ScreenHelper.writeTblFooter()+"<br>");
        String service =activeUser.activeService.code;
        String serviceName = activeUser.activeService.getLabel(sWebLanguage);
        String today=ScreenHelper.stdDateFormat.format(new java.util.Date());
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.treatedpatients",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin3b","stats",today,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3b","stats",today,sWebLanguage)+"&nbsp;</td></tr>"
                +"<tr><td>"+getTran("Web","service",sWebLanguage)+"</td><td colspan='2'><input type='hidden' name='statserviceid' id='statserviceid' value='"+service+"'>"
                +"<input class='text' type='text' name='statservicename' id='statservicename' readonly size='"+sTextWidth+"' value='"+serviceName+"'>"
                +"<img src='_img/icon_search.gif' class='link' alt='"+getTranNoLink("Web","select",sWebLanguage)+"' onclick='searchService(\"statserviceid\",\"statservicename\");'>"
                +"<img src='_img/icon_delete.gif' class='link' alt='"+getTranNoLink("Web","clear",sWebLanguage)+"' onclick='statserviceid.value=\"\";statservicename.value=\"\";'>"
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

    }

    if(activeUser.getAccessRight("statistics.chin.select")){
        String firstdayPreviousMonth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        String lastdayPreviousMonth=ScreenHelper.stdDateFormat.format(new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime()-100));
        out.print(ScreenHelper.writeTblHeader(getTran("Web","chin",sWebLanguage),sCONTEXTPATH)
                +"<tr><td>"+getTran("web","from",sWebLanguage)+"&nbsp;</td><td>"+writeDateField("begin2","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;"+getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end2","stats",lastdayPreviousMonth,sWebLanguage)+"&nbsp;</td></tr>"
                +writeTblChildWithCode("javascript:hospitalReport()",getTran("Web","chin.global.hospital.report",sWebLanguage))
                +writeTblChildWithCode("javascript:minisanteReport()",getTran("Web","chin.minisantereport",sWebLanguage))
                +writeTblChildWithCode("javascript:openPopup(\"chin/chinGraph.jsp&ts="+getTs()+"\",1000,750)",getTran("Web","chin.actualsituation",sWebLanguage))
                +writeTblChildWithCode("main.jsp?Page=healthnet/index.jsp&ts="+getTs(),getTran("Web","chin.healthnet",sWebLanguage))
           +ScreenHelper.writeTblFooter()+"<br>");
    }
%>
</form>
<script>
    function downloadStats(query,db){
        var w=window.open("<c:url value='/util/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.getElementsByName('begin')[0].value+"&end="+document.getElementsByName('end')[0].value);
    }
    function minisanteReport(){
        var w=window.open("<c:url value='/statistics/createMonthlyReportPdf.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
    }
    function hospitalReport(){
        var w=window.open("<c:url value='/datacenterstatistics/printHospitalReportChapterSelection.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
    }
    function insuranceReport(){
        window.location.href="<c:url value='main.jsp?Page=/datacenterstatistics/insuranceStats.jsp&'/>start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
    }
    function patientslistvisits(){
		var URL = "datacenterstatistics/patientslistvisits.jsp&start="+document.getElementById('begin3b').value+"&end="+document.getElementById('end3b').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function patientslistadmissions(){
		var URL = "datacenterstatistics/patientslistadmissions.jsp&start="+document.getElementById('begin3b').value+"&end="+document.getElementById('end3b').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
    }
    function searchService(serviceUidField,serviceNameField){
        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.getElementsByName(serviceNameField)[0].focus();
    }
    
</script>