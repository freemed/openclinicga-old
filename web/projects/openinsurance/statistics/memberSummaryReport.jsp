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
	if(activePatient!=null && activePatient.personid!=null && activePatient.personid.length()>0 && Insurance.getMostInterestingInsuranceForPatient(activePatient.personid)!=null){
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
		double dMemberConsumption = stats.getMemberAmount(activePatient.personid, begin, end);	
		double dCompanyMemberConsumption=0;
		if(Insurance.getMostInterestingInsuranceForPatient(activePatient.personid)!=null && Insurance.getMostInterestingInsuranceForPatient(activePatient.personid).getInsurar()!=null){
			dCompanyMemberConsumption=stats.getCompanyMemberAmount(Insurance.getMostInterestingInsuranceForPatient(activePatient.personid).getInsurar().getUid(), begin, end);
		}	
		double dAllMemberConsumption=stats.getAllMemberAmount(begin, end);
		
		double dBeneficiaryConsumption = stats.getBeneficiaryAmount(activePatient.personid, begin, end);	
		double dCompanyBeneficiaryConsumption=0;
		if(Insurance.getMostInterestingInsuranceForPatient(activePatient.personid)!=null && Insurance.getMostInterestingInsuranceForPatient(activePatient.personid).getInsurar()!=null){
			dCompanyBeneficiaryConsumption=stats.getCompanyBeneficiaryAmount(Insurance.getMostInterestingInsuranceForPatient(activePatient.personid).getInsurar().getUid(), begin, end);
		}	
		double dAllBeneficiaryConsumption=stats.getAllBeneficiaryAmount(begin, end);
	%>
	<table width='100%'>
		<tr>
			<td class='admin' nowrap><h3><%=getTran("web","memberConsumption",sWebLanguage)%></h3></td>
			<td class='admin2' colspan='2'>
				<table width='100%'>
					<tr>
						<td><center><u><%=activePatient.lastname.toUpperCase()+", "+activePatient.firstname %></u></center></td>
						<td><center><u><%=Insurance.getMostInterestingInsuranceForPatient(activePatient.personid).getInsurar().getName()%></u></center></td>
						<td><center><u><%=getTran("web","totalpopulation",sWebLanguage)%></u></center></td>
					</tr>
					<tr>
						<td width='33%'>
							<center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dMemberConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3></center>
						</td>
						<td width='33%'>
							<center>
								<%=dCompanyMemberConsumption==0?"?":new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dCompanyMemberConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></br>
								<%=dCompanyMemberConsumption==0 || dMemberConsumption==0?"?":new DecimalFormat("###.0").format(dMemberConsumption*100/dCompanyMemberConsumption)+" %"%>
							</center>
						</td>
						<td width='33%'>
							<center>
								<%=dAllMemberConsumption==0?"?":new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dAllMemberConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></br>
								<%=dAllMemberConsumption==0 || dMemberConsumption==0?"?":new DecimalFormat("###.0").format(dMemberConsumption*100/dAllMemberConsumption)+" %"%>
							</center>
						</td>
					</tr>
					<tr>
						<td colspan='3'><%=getBar(dMemberConsumption*50/dAllMemberConsumption)%></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class='admin' nowrap><h3><%=getTran("web","benificiaryConsumption",sWebLanguage)%></h3></td>
			<td class='admin2' colspan='2'>
				<table width='100%'>
					<tr>
						<td width='33%'>
							<center><h3><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dBeneficiaryConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></h3></center>
						</td>
						<td width='33%'>
							<center>
								<%=dCompanyBeneficiaryConsumption==0?"?":new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dCompanyBeneficiaryConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></br>
								<%=dCompanyBeneficiaryConsumption==0 || dBeneficiaryConsumption==0?"?":new DecimalFormat("###.0").format(dBeneficiaryConsumption*100/dCompanyBeneficiaryConsumption)+" %"%>
							</center>
						</td>
						<td width='33%'>
							<center>
								<%=dAllBeneficiaryConsumption==0?"?":new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatReport","#,###")).format(dAllBeneficiaryConsumption)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")%></br>
								<%=dAllBeneficiaryConsumption==0 || dBeneficiaryConsumption==0?"?":new DecimalFormat("###.0").format(dBeneficiaryConsumption*100/dAllBeneficiaryConsumption)+" %"%>
							</center>
						</td>
					</tr>
					<tr>
						<td colspan='3'><%=getBar(dBeneficiaryConsumption*50/dAllBeneficiaryConsumption)%></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
<%
	}
	else {
		out.println("<script>window.opener.alert('"+getTran("web","activepatient.not.insured",sWebLanguage)+"');window.close();</script>");
	}
%>