<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.Vector,
                be.openclinic.statistics.DistrictStats,
                be.mxs.common.util.db.MedwanQuery"%>
          
<%=writeTableHeader("web","statistics.districtstats",sWebLanguage," doBack()")%> 
<div style="padding-top:3px"></div>         
             
<%-- 1 - distribution_admissions_per_service_per_district ---------------------------------------%>   
<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr class="admin">
        <td colspan="3"><%=getTran("web","distribution_admissions_per_service_per_district",sWebLanguage)%></td>
    </tr>
    
	<%
	    Vector admissionservicedistrictstats = DistrictStats.getAdmissionServiceDistrictStats();

	    if(admissionservicedistrictstats.size() > 0){
	        for(int n=0; n<admissionservicedistrictstats.size(); n++){
		        DistrictStats.ServiceDistrictStat serviceDistrictStat = (DistrictStats.ServiceDistrictStat)admissionservicedistrictstats.elementAt(n);
		            
		        out.print("<tr class='list1'>"+
		        		   "<td colspan='3'><b>"+serviceDistrictStat.service+" - "+(serviceDistrictStat.service.length()==0?getTran("web","unknown",sWebLanguage):getTran("service",serviceDistrictStat.service,sWebLanguage)).toUpperCase()+"</b></td>"+
		                  "</tr>");
		        int total = 0;
		        
		        for(int i=0; i<serviceDistrictStat.districtstats.size(); i++){
		            DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) serviceDistrictStat.districtstats.elementAt(i);
		            total+=districtStat.total;
		        }
		        
		        for(int i=0; i<serviceDistrictStat.districtstats.size(); i++){
		            DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) serviceDistrictStat.districtstats.elementAt(i);
		            	            
		            out.print("<tr class='list'>"+
		                       "<td width='1%'/>"+
		                       "<td width='1%' nowrap>"+(districtStat.district.length()==0?getTran("web","unknown",sWebLanguage):districtStat.district).toUpperCase()+"</td>"+
		                       "<td>"+districtStat.total +(total>0?" ("+districtStat.total*100/total+"%)":"")+"</td>"+
		                      "</tr>");
		        }
		    }
	    }
	    else{
	    	%>
	    	    <tr>
	    	        <td><%=getTran("web","noRecordsFound",sWebLanguage)%></td>
	    	    </tr>
	    	<%
	    }
	%>
</table>
<div style="padding-top:3px"></div>

<%-- 2 - distribution_admissions_per_district ---------------------------------------------------%>
<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr class="admin">
        <td colspan="2"><%=getTran("web","distribution_admissions_per_district",sWebLanguage)%></td>
    </tr>
	<%
	    Vector admissiondistrictstats = DistrictStats.getAdmissionDistrictStats();
	
	    if(admissiondistrictstats.size() > 0){
		    int total = 0;
		    
		    for(int n=0; n<admissiondistrictstats.size(); n++){
		        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat)admissiondistrictstats.elementAt(n);
		        total+= districtStat.total;
		    }
	
	        String sClass = "1";
		    for(int n=0; n<admissiondistrictstats.size(); n++){
		        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat)admissiondistrictstats.elementAt(n);
	
	            // alternate row-style
	            if(sClass.length()==0) sClass = "1";
	            else                   sClass = "";
	            
		        out.print("<tr class='list"+sClass+"'>"+
		                   "<td width='1%' nowrap><b>"+(districtStat.district.length()==0?getTran("web","unknown",sWebLanguage):districtStat.district).toUpperCase()+"</b></td>"+
		                   "<td>"+districtStat.total+(total>0?" ("+districtStat.total*100/total+"%)":"")+"</td>"+
		                  "</tr>");
		    }
	    }
	    else{
	    	%>
	    	    <tr>
	    	        <td><%=getTran("web","noRecordsFound",sWebLanguage)%></td>
	    	    </tr>
	    	<%
	    }	
	%>
</table>
<div style="padding-top:3px"></div>

<%-- 3 - distribution_passive_per_district ------------------------------------------------------%>
<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr class="admin">
        <td colspan="2"><%=getTran("web","distribution_passive_per_district",sWebLanguage)%></td>
    </tr>
	<%
	    Vector passivedistrictstats = DistrictStats.getPassiveDistrictStats();
		
	    if(passivedistrictstats.size() > 0){
	    	int total = 0;
	    	
		    for(int n=0; n<passivedistrictstats.size(); n++){
		        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat)passivedistrictstats.elementAt(n);
		        total+= districtStat.total;
		    }
	
	        String sClass = "1";
		    for(int n=0; n<passivedistrictstats.size(); n++){
		        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat)passivedistrictstats.elementAt(n);
	
	            // alternate row-style
	            if(sClass.length()==0) sClass = "1";
	            else                   sClass = "";
		        
		        out.print("<tr class='list"+sClass+"'>"+
		                   "<td width='1%' nowrap><b>"+(districtStat.district.length()==0?getTran("web","unknown",sWebLanguage):districtStat.district).toUpperCase()+"</b></td>"+
		                   "<td>"+districtStat.total+(total>0?" ("+districtStat.total*100/total+"%)":"")+"</td>"+
		                  "</tr>");
		    }
	    }
	    else{
	    	%>
	    	    <tr>
	    	        <td><%=getTran("web","noRecordsFound",sWebLanguage)%></td>
	    	    </tr>
	    	<%
	    }	
	%>
</table>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();"/>
<%=ScreenHelper.alignButtonsStop()%>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
</script>