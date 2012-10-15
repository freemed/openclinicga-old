<%@ page import="be.openclinic.finance.*,java.text.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getInvertedBar(double d){
		String sReturn = "<table width='100%'><tr>";
		try{
	        String[] sColors = new String[]{"5be25a","7be755","b8f04a","f3f93c","fffc15","fee604","fdcd0b","fb8622","fa6d2b","f83d3c"};
	        for (int i=0;i<50;i++){
	            sReturn+="<td";
	            if(Math.ceil(d)>=(i+1)*2){
	                sReturn+=" color='#"+sColors[9-i/5]+"' style='background-color:#"+sColors[9-i/5]+"'";
	            }
	            sReturn+=">&nbsp;</td>";
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
	    return sReturn+"</table>";
	}
	public String getBar(double d){
		String sReturn = "<table width='100%'><tr>";
		try{
	        String[] sColors = new String[]{"5be25a","7be755","b8f04a","f3f93c","fffc15","fee604","fdcd0b","fb8622","fa6d2b","f83d3c"};
	        for (int i=0;i<50;i++){
	            sReturn+="<td";
	            if(Math.ceil(d)>=(i+1)*2){
	                sReturn+=" color='#"+sColors[i/5]+"' style='background-color:#"+sColors[i/5]+"'";
	            }
	            sReturn+=">&nbsp;</td>";
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
	    return sReturn+"</table>";
	}
%>
<%
	String sServiceUid=checkString(request.getParameter("serviceuid"));
	String sBegin=checkString(request.getParameter("begin"));
	String sEnd=checkString(request.getParameter("end"));
	java.util.Date begin = new java.util.Date();
	java.util.Date end = new java.util.Date();
	try{
		begin=new SimpleDateFormat("dd/MM/yyyy").parse(sBegin);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	try{
		end=new SimpleDateFormat("dd/MM/yyyy").parse(sEnd);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	InsuranceStats stats = new InsuranceStats();
	double dTotalClaimedAmount = stats.getClaimedDebetCareproviderAmount(sServiceUid,begin,end);
	double dTotalAcceptedAmount = stats.getAcceptedDebetCareproviderAmount(sServiceUid,begin,end);
	int dTotalCareProviderInsuredPeriod = stats.getTotalCareProviderInsuredPeriod(sServiceUid,begin,end);
	int dTotalInsuredDaysPeriod=stats.getTotalInsuredDaysPeriod(sServiceUid,begin,end);
	int dTotalCoveredPeriod = stats.getTotalCareproviderCoveredPeriod(sServiceUid,begin,end);
	double day=60000*60*24;
	double period=1+(end.getTime()-begin.getTime())/day;
	String costcenter="";
	if(sServiceUid.length()>0){
		Service service = Service.getService(sServiceUid);
		if(service!=null){
			costcenter=service.costcenter;
		}
	}
	double dAverageSameCategoryCareproviderAmount=stats.getAllAverageCareproviderAmount(costcenter,begin, end);
	double dStdDevSameCategoryCareproviderAmount=stats.getAllStdDevCareproviderAmount(costcenter,begin, end);
	double dAverageAllCareproviderAmount=stats.getAllAverageCareproviderAmount("",begin, end);
	double dStdDevAllCareproviderAmount=stats.getAllStdDevCareproviderAmount("",begin, end);
	double sameCategoryConsumptionRiskindex=dStdDevSameCategoryCareproviderAmount==0?0:((dTotalClaimedAmount/dTotalCoveredPeriod)-dAverageSameCategoryCareproviderAmount)/dStdDevSameCategoryCareproviderAmount;
	double consumptionRiskindex=dStdDevAllCareproviderAmount==0?0:((dTotalClaimedAmount/dTotalCoveredPeriod)-dAverageAllCareproviderAmount)/dStdDevAllCareproviderAmount;
	
	
%>
<table width='100%'>
	<tr><td class='admin' nowrap><h3><%=getTran("web","totalclaimedamount",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3></center></td></tr>
	<tr><td class='admin' nowrap><%=getTran("web","totalacceptedamount",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalAcceptedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></b></td></tr>
	<tr><td class='admin' nowrap><%=getTran("web","waitingclaims",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount-dTotalAcceptedAmount)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></b></td></tr>
	<tr><td class='admin' nowrap><%=getTran("web","totalinsuredtreated",sWebLanguage)%></td><td class='admin2' colspan='2'><b><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalCareProviderInsuredPeriod)%></b></td></tr>
	<tr><td class='admin' nowrap><h3><%=getTran("web","averageinsuredcost",sWebLanguage)%></h3></td><td class='admin2' colspan='2'><center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dTotalClaimedAmount/dTotalCoveredPeriod)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3><center></td></tr>
	<tr><td class='admin' nowrap><%=getTran("web","consumptionindex",sWebLanguage) %> (<%=getTran("web","samecareprovidercategory",sWebLanguage) %>)</td><td class='admin2' width='1%' nowrap><b><%=new DecimalFormat("#0.00").format(sameCategoryConsumptionRiskindex) %> (-2 <%=getTran("web","to",sWebLanguage) %> +2)</b></td><td class='admin2'><%=getBar((sameCategoryConsumptionRiskindex+2)*100/4)%></td></tr>
	<tr><td class='admin' nowrap><%=getTran("web","consumptionindex",sWebLanguage) %> (<%=getTran("web","allcareprovidercategories",sWebLanguage) %>)</td><td class='admin2' width='1%' nowrap><b><%=new DecimalFormat("#0.00").format(consumptionRiskindex) %> (-2 <%=getTran("web","to",sWebLanguage) %> +2)</b></td><td class='admin2'><%=getBar((consumptionRiskindex+2)*100/4)%></td></tr>
</table>