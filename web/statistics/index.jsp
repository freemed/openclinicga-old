<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
	//--- GET FIRST DAY PREVIOUS MONTH ------------------------------------------------------------
	public String getFirstDayPreviousMonth(){
	    // DATE
	    Calendar cal = Calendar.getInstance();
	    cal.setTime(new java.util.Date()); // now
	    cal.add(Calendar.MONTH,-1); // previous month
	    cal.set(Calendar.DAY_OF_MONTH,1); // first day

	    // HOUR
	    cal.set(Calendar.HOUR_OF_DAY,0);
	    cal.set(Calendar.MINUTE,0);
	    cal.set(Calendar.SECOND,0);
	    cal.set(Calendar.MILLISECOND,0);
	    
        return ScreenHelper.formatDate(cal.getTime());  
	}

	//--- GET LAST DAY PREVIOUS MONTH -------------------------------------------------------------
	public String getLastDayPreviousMonth(){
	    // DATE
	    Calendar cal = Calendar.getInstance();
	    cal.setTime(new java.util.Date()); // now
	    cal.add(Calendar.MONTH,-1); // previous month
	    cal.set(Calendar.DAY_OF_MONTH,cal.getActualMaximum(Calendar.DAY_OF_MONTH)); // last day
	
	    // HOUR
	    cal.set(Calendar.HOUR_OF_DAY,23);
	    cal.set(Calendar.MINUTE,59);
	    cal.set(Calendar.SECOND,59);
	    cal.set(Calendar.MILLISECOND,99);
	    	    
	    return ScreenHelper.formatDate(cal.getTime());    
	}
%>

<%
    String firstdayPreviousMonth = getFirstDayPreviousMonth(),
           lastdayPreviousMonth  = getLastDayPreviousMonth();

    Debug.println("firstdayPreviousMonth : "+firstdayPreviousMonth);
    Debug.println("lastdayPreviousMonth  : "+lastdayPreviousMonth);
%>
<form name="stats">
<%
    //*** 1 - RECORD CREATION *********************************************************************
	if(true){	    
	    out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.record.creation",sWebLanguage),sCONTEXTPATH));
	    out.print("<tr>"+
	               "<td class='admin2' colspan='2'>"+
	                getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begincnar","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;&nbsp;"+
	                getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("endcnar","stats",lastdayPreviousMonth,sWebLanguage)+
	               "</td>"+
	              "</tr>"+
	              writeTblChildWithCode("javascript:oldandnewcases()",getTran("Web","statistics.oldandnewcases",sWebLanguage))+
	              writeTblChildWithCode("javascript:newpatients()",getTran("Web","statistics.newpatients",sWebLanguage))+
	              writeTblChildWithCode("javascript:agedistribution()",getTran("Web","statistics.agedistribution",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");
	}

    //*** 2 - QUICK DIAGNOSIS ENTRY ***************************************************************
    if(activeUser.getAccessRight("patient.administration.add") || activeUser.getAccessRight("statistics.quickdiagnosisentry")){
         out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.quickdiagnosisentry",sWebLanguage),sCONTEXTPATH));
         out.print(writeTblChildWithCode("javascript:openPopup(\"statistics/quickFile.jsp\",800,600,\"quickFile\")",getTran("Web","statistics.quickdiagnosisentry",sWebLanguage)));
         out.print(ScreenHelper.writeTblFooter()+"<br>");
    }

    //*** 3 - PATHOLOGY ***************************************************************************
    if(activeUser.getAccessRight("statistics.globalpathologydistribution.select")){
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.pathologystats",sWebLanguage),sCONTEXTPATH));
        out.print(writeTblChildNoButton("main.do?Page=statistics/diagnosisStats.jsp",getTran("Web","statistics.globalpathology",sWebLanguage))+
        		  writeTblChildNoButton("main.do?Page=statistics/mortality.jsp",getTran("Web","statistics.mortality",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/diagnosesList.jsp",getTran("Web","statistics.diagnosisList",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");
    }

    //*** 4 - TECHNICAL STATS *********************************************************************
    if(activeUser.getAccessRight("statistics.select")){        
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.technicalstats",sWebLanguage),sCONTEXTPATH));
        out.print("<tr>"+
                   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begintech","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;&nbsp;"+
                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("endtech","stats",lastdayPreviousMonth,sWebLanguage)+
                   "</td>"+
                  "</tr>"+
                  writeTblChildWithCode("javascript:labStatistics()",getTran("Web","statistics.lab",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");
    }

    //*** 5 - ACTIVITY STATS **********************************************************************
    if(activeUser.getAccessRight("statistics.select")){
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.activitystats",sWebLanguage),sCONTEXTPATH));
        out.print(writeTblChildNoButton("main.do?Page=statistics/databaseStatistics.jsp",getTran("Web","statistics.activitystats.database",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/diagnosticCodingStats.jsp",getTran("Web","statistics.activitystats.diagnosticcoding",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/encounterCodingStats.jsp",getTran("Web","statistics.activitystats.encountercoding",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/recordViewingStats.jsp",getTran("Web","statistics.activitystats.recordviewing",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/transactionViewingStats.jsp",getTran("Web","statistics.activitystats.transactionviewing",sWebLanguage)));
                  //writeTblChildNoButton("main.do?Page=statistics/prestationCodingStats.jsp",getTran("Web","statistics.activitystats.prestationcoding",sWebLanguage))
        out.print(ScreenHelper.writeTblFooter()+"<br>");

        //*** 5a - INSURANCE AND INVOICING STATS ***************        
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.insuranceandinvoicingstats",sWebLanguage),sCONTEXTPATH));
        out.print("<tr>"+
                   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begin3","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;&nbsp;"+
                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3","stats",lastdayPreviousMonth,sWebLanguage)+
                   "</td>"+
                  "</tr>");
        out.print(writeTblChildWithCode("javascript:insuranceReport()",getTran("Web","statistics.insurancestats.distribution",sWebLanguage))+
	              writeTblChildWithCode("javascript:incomeVentilation()",getTran("Web","statistics.incomeVentilationPerFamily",sWebLanguage))+
	              writeTblChildWithCode("javascript:incomeVentilationExtended()",getTran("Web","statistics.incomeVentilationPerCategoryAndService",sWebLanguage))+
	              writeTblChildWithCode("javascript:incomeVentilationPerformers()",getTran("Web","statistics.incomeVentilationPerPerformer",sWebLanguage))+
	              writeTblChildWithCode("javascript:paymentrate()",getTran("Web","statistics.paymentrate",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");
        
        String service = activeUser.activeService.code;
        String serviceName = activeUser.activeService.getLabel(sWebLanguage);
        
        String today = ScreenHelper.formatDate(new java.util.Date()); // now

        //*** 5b - TREATED PATIENTS ****************************
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.treatedpatients",sWebLanguage),sCONTEXTPATH));
        out.print("<tr>"+
                   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begin3b","stats",today,sWebLanguage)+"&nbsp;&nbsp;"+
                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end3b","stats",today,sWebLanguage)+
                   "</td>"+
                  "</tr>");
        
        out.print("<tr>"+
                   "<td class='admin2' colspan='2'>"+getTran("Web","service",sWebLanguage)+" "+
                    "<input type='hidden' name='statserviceid' id='statserviceid' value='"+service+"'>"+
                    "<input class='text' type='text' name='statservicename' id='statservicename' readonly size='"+sTextWidth+"' value='"+serviceName+"'>&nbsp;"+
                    "<img src='_img/icons/icon_search.gif' class='link' alt='"+getTranNoLink("Web","select",sWebLanguage)+"' onclick='searchService(\"statserviceid\",\"statservicename\");'>&nbsp;"+
                    "<img src='_img/icons/icon_delete.gif' class='link' alt='"+getTranNoLink("Web","clear",sWebLanguage)+"' onclick='statserviceid.value=\"\";statservicename.value=\"\";'>"+
                   "</td>"+
                  "</tr>"+
                  writeTblChildWithCode("javascript:patientslistvisits()",getTran("Web","statistics.patientslist.visits",sWebLanguage))+
                  writeTblChildWithCode("javascript:patientslistadmissions()",getTran("Web","statistics.patientslist.admissions",sWebLanguage))+
                  writeTblChildWithCode("javascript:patientslistsummary()",getTran("Web","statistics.patientslist.summary",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");

        //*** 5c - SERVICE STATS *******************************
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.servicestats",sWebLanguage),sCONTEXTPATH)+
                  writeTblChildNoButton("main.do?Page=statistics/hospitalStats.jsp",getTran("Web","statistics.hospitalstats.global",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/serviceStats.jsp",getTran("Web","statistics.servicestats.contacts",sWebLanguage))+
                  writeTblChildNoButton("main.do?Page=statistics/districtStats.jsp",getTran("Web","statistics.districtstats",sWebLanguage)));

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
        );
        out.print(ScreenHelper.writeTblFooter()+"<br>");

        //*** 5d - DOWNLOADS ***********************************
        String sBeginOfYear = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
       
        String sEndOfYear = "31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
        if(ScreenHelper.stdDateFormat.toPattern().equals("MM/dd/yyyy")){
            sEndOfYear = "12/31/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1); // US-date
        }
    	
        out.print(ScreenHelper.writeTblHeader(getTran("Web","statistics.download",sWebLanguage),sCONTEXTPATH));
        out.print(writeTblChildWithCodeNoButton("javascript:downloadStats(\"patients.list\",\"openclinic\");",getTran("Web","statistics.download.patients",sWebLanguage))+
                  "<tr>"+
        		   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begin","stats",sBeginOfYear,sWebLanguage)+"&nbsp;&nbsp;"+
        		    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end","stats",sEndOfYear,sWebLanguage)+
        		   "</td>"+
        		  "</tr>"+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"global.list\",\"openclinic\");",getTran("Web","statistics.download.global",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"globalrfe.list\",\"openclinic\");",getTran("Web","statistics.download.globalrfe",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"encounter.list\",\"openclinic\");",getTran("Web","statistics.download.encounterlist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"diagnosis.list\",\"openclinic\");",getTran("Web","statistics.download.diagnosislist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"rfe.list\",\"openclinic\");",getTran("Web","statistics.download.rfelist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"document.list\",\"openclinic\");",getTran("Web","statistics.download.documentlist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"user.list\",\"admin\");",getTran("Web","statistics.download.userlist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"service.list\",\"openclinic\");",getTran("Web","statistics.download.servicelist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"debet.list\",\"openclinic\");",getTran("Web","statistics.download.debetlist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"debet.list.per.encounter\",\"openclinic\");",getTran("Web","statistics.download.debetlist.per.encounter",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"prestation.list\",\"openclinic\");",getTran("Web","statistics.download.prestationlist",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadStats(\"wicketcredits.list\",\"openclinic\");",getTran("Web","statistics.download.wicketcredits",sWebLanguage))+
                  writeTblChildWithCodeNoButton("javascript:downloadInvoicesSummary(\"hmk.invoices.list\",\"openclinic\");",getTran("Web","statistics.download.invoicessummary",sWebLanguage))+
                  (MedwanQuery.getInstance().getConfigInt("datacenterEnabled",0)==1?writeTblChildWithCodeNoButton("javascript:downloadDatacenterStats(\"service.income.list\",\"stats\");",getTran("Web","statistics.download.serviceincomelist",sWebLanguage)):""));
        out.print(ScreenHelper.writeTblFooter()+"<br>");

        //*** 5e - PATHOLOGY ***********************************	    
        out.print(ScreenHelper.writeTblHeader(getTran("Web","financial",sWebLanguage),sCONTEXTPATH));	    
        out.print(writeTblChildNoButton("main.do?Page=statistics/toInvoiceLists.jsp",getTran("Web","statistics.toinvoicelists",sWebLanguage))+
                  "<tr>"+
                   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("beginfin","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;&nbsp;"+
                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("endfin","stats",lastdayPreviousMonth,sWebLanguage)+
                   "</td>"+
                  "</tr>"+
                  writeTblChildWithCode("javascript:getOpenInvoices()",getTran("Web","statistics.openinvoicelists",sWebLanguage))+
                  writeTblChildWithCode("javascript:getClosedNonZeroInvoices()",getTran("Web","statistics.closednonzeroinvoicelists",sWebLanguage))+
                  writeTblChildWithCode("javascript:getCanceledInvoices()",getTran("Web","statistics.canceledinvoicelists",sWebLanguage))+
                  writeTblChildWithCode("javascript:getIssuedInsurerInvoices()",getTran("Web","statistics.issuedinsurerinvoices",sWebLanguage))+
        		  writeTblChildWithCode("javascript:getUserInvoices()",getTran("Web","statistics.userinvoices",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter()+"<br>");

        //*** 5f - MFP *****************************************
        if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
	        out.print(ScreenHelper.writeTblHeader(getTran("Web","MFP",sWebLanguage),sCONTEXTPATH));
	        out.print("<tr>"+
	                   "<td class='admin2' colspan='2'>"+
	                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("beginmfp","stats",sBeginOfYear,sWebLanguage)+"&nbsp;&nbsp;"+
	                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("endmfp","stats",sEndOfYear,sWebLanguage)+
	                   "</td>"+
	                  "</tr>"+
                      "<tr>"+
	                   "<td class='admin2'>"+getTran("Web","service",sWebLanguage)+"</td>"+
                       "<td class='admin2' colspan='2'>"+
	                    "<input type='hidden' name='mfpserviceid' id='mfpserviceid' value='"+service+"'>"+
                        "<input class='text' type='text' name='mfpservicename' id='mfpservicename' readonly size='"+sTextWidth+"' value='"+serviceName+"'>&nbsp;"+
                        "<img src='_img/icons/icon_search.gif' class='link' alt='"+getTranNoLink("Web","select",sWebLanguage)+"' onclick='searchService(\"mfpserviceid\",\"mfpservicename\");'>&nbsp;"+
                        "<img src='_img/icons/icon_delete.gif' class='link' alt='"+getTranNoLink("Web","clear",sWebLanguage)+"' onclick='mfpserviceid.value=\"\";mfpservicename.value=\"\";'>"+
                       "</td>"+
               	      "</tr>"+
                      writeTblChildWithCode("javascript:getMFPSummary()",getTran("Web","statistics.mfpsummary",sWebLanguage))+
	                  writeTblChildWithCode("javascript:getMFPUnsignedInvoices()",getTran("Web","statistics.mfpunsignedinvoices",sWebLanguage))+
	                  writeTblChildWithCode("javascript:getMFPAcceptedUnsignedInvoices()",getTran("Web","statistics.mfpacceptedunsignedinvoices",sWebLanguage))+
	                  writeTblChildWithCode("javascript:getMFPUnvalidatedInvoices()",getTran("Web","statistics.mfpunvalidatedinvoices",sWebLanguage)));
	        out.print(ScreenHelper.writeTblFooter()+"<br>");
        }
    }

    //*** 6 - CHIN ********************************************************************************
    if(activeUser.getAccessRight("statistics.chin.select")){      
        out.print(ScreenHelper.writeTblHeader(getTran("Web","chin",sWebLanguage),sCONTEXTPATH));
        out.print("<tr>"+
                   "<td class='admin2' colspan='2'>"+
                    getTran("web","from",sWebLanguage)+"&nbsp;"+writeDateField("begin2","stats",firstdayPreviousMonth,sWebLanguage)+"&nbsp;&nbsp;"+
                    getTran("web","to",sWebLanguage)+"&nbsp;"+writeDateField("end2","stats",lastdayPreviousMonth,sWebLanguage)+
                   "</td>"+
                  "</tr>"+
                  writeTblChildWithCode("javascript:hospitalReport()",getTran("Web","chin.global.hospital.report",sWebLanguage))+
                  writeTblChildWithCode("javascript:minisanteReport()",getTran("Web","chin.minisantereport.health.center",sWebLanguage))+
                  writeTblChildWithCode("javascript:minisanteReportDH()",getTran("Web","chin.minisantereport.district.hospital",sWebLanguage))+
                  writeTblChildWithCode("javascript:openPopup(\"chin/chinGraph.jsp&ts="+getTs()+"\",1000,750)",getTran("Web","chin.actualsituation",sWebLanguage))+
                  writeTblChildWithCode("javascript:window.location.href=\"main.jsp?Page=healthnet/index.jsp&ts="+getTs()+"\"",getTran("Web","chin.healthnet",sWebLanguage)));
        out.print(ScreenHelper.writeTblFooter());
    }
%>
</form>

<script>
  function downloadInvoicesSummary(query,db){
    var URL = "/statistics/downloadInvoicesSummary.jsp&query="+query+"&db="+db+"&begin="+document.getElementsByName('begin')[0].value+"&end="+document.getElementsByName('end')[0].value;
	openPopup(URL,400,300,"OpenClinic");
  }
  function downloadStats(query,db){
    window.open("<c:url value='/util/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.getElementsByName('begin')[0].value+"&end="+document.getElementsByName('end')[0].value);
  }
  function downloadDatacenterStats(query,db){
    window.open("<c:url value='/datacenterstatistics/csvStats.jsp?'/>query="+query+"&db="+db+"&begin="+document.getElementsByName('begin')[0].value+"&end="+document.getElementsByName('end')[0].value);
  }
  function minisanteReport(){
    window.open("<c:url value='/statistics/createMonthlyReportPdf.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
  }
  function getMFPSummary(){
    var URL = "/statistics/createMFPSummary.jsp&start="+document.getElementById('beginmfp').value+"&end="+document.getElementById('endmfp').value+"&serviceid="+document.getElementById('mfpserviceid').value+"&ts=<%=getTs()%>";
    openPopup(URL,400,600,"OpenClinic");
  }
  function getMFPUnsignedInvoices(){
    var URL = "/statistics/findMFPUnsignedInvoices.jsp&start="+document.getElementById('beginmfp').value+"&end="+document.getElementById('endmfp').value+"&serviceid="+document.getElementById('mfpserviceid').value+"&ts=<%=getTs()%>";
    openPopup(URL,800,600,"OpenClinic");
  }
  function getProductStockFile(){
    var URL = "/statistics/pharmacy/getProductStockFile.jsp&start="+document.getElementById('beginpharmacy').value+"&end="+document.getElementById('endpharmacy').value+"&productstockid="+document.getElementById('productstockid').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function getMFPUnvalidatedInvoices(){
    var URL = "/statistics/findMFPUnvalidatedInvoices.jsp&start="+document.getElementById('beginmfp').value+"&end="+document.getElementById('endmfp').value+"&serviceid="+document.getElementById('mfpserviceid').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function getMFPAcceptedUnsignedInvoices(){
    var URL = "/statistics/findMFPUnsignedInvoices.jsp&acceptedonly=1&start="+document.getElementById('beginmfp').value+"&end="+document.getElementById('endmfp').value+"&serviceid="+document.getElementById('mfpserviceid').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function minisanteReportDH(){
    window.open("<c:url value='/statistics/createMonthlyReportPdfDH.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
  }
  function hospitalReport(){
    window.open("<c:url value='/statistics/printHospitalReportChapterSelection.jsp?'/>start="+document.getElementById('begin2').value+"&end="+document.getElementById('end2').value+"&ts=<%=getTs()%>");
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
  function patientslistsummary(){
	var URL = "statistics/patientslistsummary.jsp&start="+document.getElementById('begin3b').value+"&end="+document.getElementById('end3b').value+"&statserviceid="+document.getElementById('statserviceid').value+"&ts=<%=getTs()%>";
	openPopup(URL,1024,600,"OpenClinic");
  }
  function insuranceReport(){
    window.location.href="<c:url value='main.jsp?Page=/statistics/insuranceStats.jsp&'/>start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
  }
  function incomeVentilation(){
	var URL = "statistics/incomeVentilation.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function incomeVentilationExtended(){
    var URL = "statistics/incomeVentilationExtended.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function incomeVentilationPerformers(){
    var URL = "statistics/incomeVentilationPerformers.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function paymentrate(){
	var URL = "statistics/insurarIncome.jsp&start="+document.getElementById('begin3').value+"&end="+document.getElementById('end3').value+"&ts=<%=getTs()%>";
	openPopup(URL,500,600,"OpenClinic");
  }
  function getOpenInvoices(){
		var URL = "statistics/openInvoiceLists.jsp&start="+document.getElementById('beginfin').value+"&end="+document.getElementById('endfin').value+"&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
	  }
  function getUserInvoices(){
		var URL = "statistics/getInvoicesPerUser.jsp&ts=<%=getTs()%>";
		openPopup(URL,800,600,"OpenClinic");
	  }
  function getClosedNonZeroInvoices(){
	var URL = "statistics/closedNonZeroInvoiceLists.jsp&start="+document.getElementById('beginfin').value+"&end="+document.getElementById('endfin').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function getCanceledInvoices(){
	var URL = "statistics/canceledInvoiceLists.jsp&start="+document.getElementById('beginfin').value+"&end="+document.getElementById('endfin').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }
  function getIssuedInsurerInvoices(){
	var URL = "statistics/issuedInsurerInvoiceList.jsp&start="+document.getElementById('beginfin').value+"&end="+document.getElementById('endfin').value+"&ts=<%=getTs()%>";
    openPopup(URL,800,600,"OpenClinic");
  }
  function searchService(serviceUidField,serviceNameField){
    openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    document.getElementsByName(serviceNameField)[0].focus();
  }
  function oldandnewcases(){
    var URL = "statistics/oldAndNewCases.jsp&start="+document.getElementById('begincnar').value+"&end="+document.getElementById('endcnar').value+"&ts=<%=getTs()%>";
    openPopup(URL,200,200,"OpenClinic");
  }
  function newpatients(){
	var URL = "statistics/newPatients.jsp&start="+document.getElementById('begincnar').value+"&end="+document.getElementById('endcnar').value+"&ts=<%=getTs()%>";
	openPopup(URL,200,200,"OpenClinic");
  }
  function agedistribution(){
	var URL = "statistics/ageDistribution.jsp&start="+document.getElementById('begincnar').value+"&end="+document.getElementById('endcnar').value+"&ts=<%=getTs()%>";
    openPopup(URL,200,650,"OpenClinic");
  }
  function genderdistribution(){
    var URL = "statistics/genderGraph.jsp?start="+document.getElementById('begincnar').value+"&end="+document.getElementById('endcnar').value+"&ts=<%=getTs()%>";
    window.open(URL);
  }
  function labStatistics(){
    var URL = "statistics/labStatistics.jsp&start="+document.getElementById('begintech').value+"&end="+document.getElementById('endtech').value+"&ts=<%=getTs()%>";
	openPopup(URL,800,600,"OpenClinic");
  }    
</script>