<%@page import="be.openclinic.finance.*,
                java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- GET INVERTED BAR ------------------------------------------------------------------------
	public String getInvertedBar(double d){
		String sReturn = "<table width='100%'><tr>";
		try{
	        String[] sColors = new String[]{"5be25a","7be755","b8f04a","f3f93c","fffc15","fee604","fdcd0b","fb8622","fa6d2b","f83d3c"};
	        for(int i=0; i<50; i++){
	            sReturn+= "<td";
	            if(Math.ceil(d) >= (i+1)*2){
	                sReturn+= " color='#"+sColors[9-i/5]+"' style='background-color:#"+sColors[9-i/5]+"'";
	            }
	            sReturn+= ">&nbsp;</td>";
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
		
	    return sReturn+"</table>";
	}

    //--- GET BAR ---------------------------------------------------------------------------------
	public String getBar(double d){
		String sReturn = "<table width='100%'><tr>";
		try{
	        String[] sColors = new String[]{"5be25a","7be755","b8f04a","f3f93c","fffc15","fee604","fdcd0b","fb8622","fa6d2b","f83d3c"};
	        for(int i=0; i<50; i++){
	            sReturn+= "<td";
	            if(Math.ceil(d) >= (i+1)*2){
	                sReturn+= " color='#"+sColors[i/5]+"' style='background-color:#"+sColors[i/5]+"'";
	            }
	            sReturn+= ">&nbsp;</td>";
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
		
	    return sReturn+"</table>";
	}
%>

<%
	String sInsurarUid = checkString(request.getParameter("insuraruid"));

	String sBegin = checkString(request.getParameter("begin"));
	String sEnd = checkString(request.getParameter("end"));

	java.util.Date begin = new java.util.Date();
	java.util.Date end = new java.util.Date();
	
	try{
		begin = ScreenHelper.parseDate(sBegin);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	
	try{
		end = ScreenHelper.parseDate(sEnd);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	
	InsuranceStats stats = new InsuranceStats();
	double dTotalClaimedAmount = stats.getClaimedDebetInsurarAmount(sInsurarUid,begin,end);
	double dAllClaimedAmount = stats.getClaimedDebetInsurarAmount(begin,end);
	double dTotalAcceptedAmount = stats.getAcceptedDebetInsurarAmount(sInsurarUid,begin,end);
	
	int dTotalAffiliatesToday = stats.getTotalAffiliatesToday(sInsurarUid);
	int dTotalAffiliatesPeriod = stats.getTotalAffiliatesPeriod(sInsurarUid,begin,end);
	int dAllAffiliatesPeriod = stats.getAllAffiliatesPeriod(begin,end);
	int dTotalAffiliateDaysPeriod = stats.getTotalAffiliateDaysPeriod(sInsurarUid,begin,end);
	int dAllAffiliateDaysPeriod = stats.getAllAffiliateDaysPeriod(begin,end);
	int dTotalInsuredDaysPeriod = stats.getTotalInsuredDaysPeriod(sInsurarUid,begin,end);
	String contributionTypes = "", s = "";
	
	Vector types = stats.getContributionTypesDeclared(sInsurarUid,begin,end);
	for(int n=0; n<types.size(); n++){
		s = (String)types.elementAt(n);
		Prestation prestation = Prestation.get(s.split(";")[0]);
		if(n > 0){
			contributionTypes+= "<BR/>";
		}
		contributionTypes+= s.split(";")[1]+" x "+prestation.getDescription();
	}
	
	int dTotalCoveredToday  = stats.getTotalCoveredToday(sInsurarUid),
	    dTotalCoveredPeriod = stats.getTotalCoveredPeriod(sInsurarUid,begin,end);
	
	double dTotalContributionsInvoiced = stats.getInsurerCoverageAmount(sInsurarUid,begin,end);
	double day = 60000*60*24;
	double period = 1+(end.getTime()-begin.getTime())/day;
	double dAverageAffiliates = dTotalAffiliateDaysPeriod/period;
	double dAverageAllAffiliates = dAllAffiliateDaysPeriod/period;
	double dAverageInsured = dTotalInsuredDaysPeriod/period;
	double dAverageAllInsuredAmount = stats.getAllAverageInsuredAmount(begin,end);
	double dStdDevAllInsuredAmount = stats.getAllStdDevInsuredAmount(begin, end);
	double insuredRiskindex = ((dTotalClaimedAmount/dAverageInsured)-dAverageAllInsuredAmount)/dStdDevAllInsuredAmount;
	double dAverageAllInsuredCoverage = stats.getAllAverageInsuredCoverage(begin,end);
	double dStdDevAllInsuredCoverage = stats.getAllStdDevInsuredCoverage(begin, end);
	double insuredCoverageindex = ((dTotalContributionsInvoiced/dAverageInsured)-dAverageAllInsuredCoverage)/dStdDevAllInsuredCoverage;
	
	stats.writeAgeConsumptionChart(sInsurarUid,sWebLanguage,1,MedwanQuery.getInstance().getConfigString("DocumentsFolder")+"/"+activeUser.userid+".png",begin,end);
	
%>
<table width='100%'>
	<tr><td class='admin'><h3><%=getTran("web","totalclaimedamount",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3></center></td></tr>
	<tr><td class='admin'><%=getTran("web","totalacceptedamount",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalAcceptedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></b></td></tr>
	<tr><td class='admin'><%=getTran("web","waitingclaims",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount-dTotalAcceptedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></b></td></tr>
	<tr><td class='admin' colspan='3'><hr/></td></tr>
	<tr><td class='admin'><h3><%=getTran("web","totalcontributionsamount",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalContributionsInvoiced)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3></center></td></tr>
	<tr><td class='admin'><%=getTran("web","brutoprofitabilityindex",sWebLanguage)%></td><td class='admin2' width='1%' nowrap><b><%=new DecimalFormat("#0.00").format(dTotalContributionsInvoiced/dTotalClaimedAmount)%> (0 <%=getTran("web","to",sWebLanguage)%> +2)</b></td><td class='admin2'><%=getInvertedBar(dTotalContributionsInvoiced*50/dTotalClaimedAmount)%></td></tr>
	<tr><td class='admin' colspan='3'><hr/></td></tr>
	<tr><td class='admin'><%=getTran("web","totalaffiliatedaysperiod",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=dTotalAffiliateDaysPeriod %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","totalaffiliatiestoday",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=dTotalAffiliatesToday %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","totalaffiliatiesperiod",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=dTotalAffiliatesPeriod %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","averageaffiliatiesperiod",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat("#.00").format(dAverageAffiliates) %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","contributiontypesdeclared",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=contributionTypes %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","totalcoveredtoday",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=dTotalCoveredToday %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","totalcoveredperiod",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=dTotalCoveredPeriod %></b></td></tr>
	<tr><td class='admin'><%=getTran("web","averagecoveredperiod",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat("#.00").format(dAverageInsured) %></b></td></tr>
	<tr><td class='admin'><h3><%=getTran("web","averageaffiliatecost",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount/dAverageAffiliates)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3><center></td></tr>
<%
    if(sInsurarUid.length()>0){
        %><tr><td class='admin'><%=getTran("web","riskindex",sWebLanguage)%></td><td class='admin2' width='1%' nowrap><b><%=new DecimalFormat("#0.00").format(insuredRiskindex) %> (-2 <%=getTran("web","to",sWebLanguage)%> +2)</b></td><td class='admin2'><%=getBar((insuredRiskindex+2)*100/4)%></td></tr><%
    }
%>
	<tr><td class='admin'><h3><%=getTran("web","averageaffiliatecontribution",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalContributionsInvoiced/dAverageAffiliates)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3><center></td></tr>
	<tr><td class='admin'><h3><%=getTran("web","averageinsuredcost",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount/dAverageInsured)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3><center></td></tr>
	<tr><td class='admin'><h3><%=getTran("web","averageinsuredcontribution",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalContributionsInvoiced/dAverageInsured)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3><center></td></tr>
	<tr><td class='admin'><%=getTran("web","coverageindex",sWebLanguage)%></td><td class='admin2' width='1%' nowrap><b><%=new DecimalFormat("#0.00").format(insuredCoverageindex) %> (-2 <%=getTran("web","to",sWebLanguage)%> +2)</b></td><td class='admin2'><%=getInvertedBar((insuredCoverageindex+2)*100/4)%></td></tr>
	<tr><td colspan="3"><img src="<%=MedwanQuery.getInstance().getConfigString("DocumentsURL")+"/"+activeUser.userid+".png"%>"/></tr>
</table>