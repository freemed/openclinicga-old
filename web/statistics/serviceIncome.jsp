<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sBegin = request.getParameter("begin");
    if(sBegin==null){
        sBegin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String sEnd = request.getParameter("end");
    if(sEnd==null){
        sEnd="31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String service =activeUser.activeService.code;
    if(request.getParameter("statserviceid")!=null){
    	service=request.getParameter("statserviceid");
    }
    String serviceName = activeUser.activeService.getLabel(sWebLanguage);
    if(request.getParameter("statserviceid")!=null){
    	serviceName=request.getParameter("statservicename");
    }
%>
<%=sJSDATE%>
<form method="post" name="serviceIncome" id="serviceIncome">
    <table>
        <tr>
            <td>
                <%=getTran("web","from",sWebLanguage)%>&nbsp;</td><td><%=writeDateField("begin","serviceIncome",sBegin,sWebLanguage)%>&nbsp;<%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","serviceIncome",sEnd,sWebLanguage)%>&nbsp;
                <input type="submit" class="button" name="find" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
        <tr>
        	<td><%=getTran("Web","service",sWebLanguage) %></td><td colspan='2'><input type='hidden' name='statserviceid' id='statserviceid' value='<%=service %>'>
        		<input class='text' type='text' name='statservicename' id='statservicename' readonly size='40' value='<%=serviceName %>'>
        		<img src='_img/icon_search.gif' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage) %>' onclick='searchService("statserviceid","statservicename");'>
        		<img src='_img/icon_delete.gif' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage) %>' onclick='statserviceid.value="";statservicename.value="";'>
        	</td>
        </tr>
    </table>
</form>
<table>
<%
    if(request.getParameter("find")!=null){
    	java.util.Date begin = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("begin"))+" 00:00");
    	java.util.Date end = ScreenHelper.fullDateFormat.parse(checkString(request.getParameter("end"))+" 23:59");
        //We zoeken alle debets op van de betreffende periode en ventileren deze per dienst
		
        String sQuery="select sum(number) number, sum(quantity) quantity, sum(total) total, sum(patientincome) patientincome, sum(insurarincome) insurarincome, oc_debet_serviceuid, oc_prestation_description, oc_prestation_code from ("+
                        " select count(*) number,sum(oc_debet_quantity) quantity,sum(oc_debet_amount+oc_debet_insuraramount+oc_debet_extrainsuraramount) total,sum(oc_debet_amount) patientincome, sum(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurarincome, oc_debet_serviceuid, oc_prestation_description, oc_prestation_code" +
                        " from oc_debets a, oc_prestations b" +
                        " where" +
                        " oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+ 
                        " (oc_debet_patientinvoiceuid is not null and oc_debet_patientinvoiceuid<>'') and"+
                        " oc_debet_date between ? and ? and"+
                        " oc_debet_serviceuid in ("+Service.getChildIdsAsString(service)+")"+
                        " group by oc_debet_serviceuid,oc_prestation_description,oc_prestation_code" +
        				" union "+
                        " select count(*) number,sum(oc_debet_quantity) quantity,sum(oc_debet_amount+oc_debet_insuraramount+oc_debet_extrainsuraramount) total,sum(oc_debet_amount) patientincome, sum(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurarincome, serviceuid as oc_debet_serviceuid, oc_prestation_description, oc_prestation_code" +
                        " from" +
                        " (select oc_debet_amount,oc_debet_insuraramount,oc_debet_quantity,oc_debet_extrainsuraramount,oc_debet_prestationuid," +
                        "   (" +
                        "       select max(oc_encounter_serviceuid) " +
                        "       from oc_encounters_view" +
                        "       where" +
                        "       oc_encounter_objectid=replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                        "   ) serviceuid" +	
                        "   from oc_debets where (oc_debet_patientinvoiceuid is not null and oc_debet_patientinvoiceuid<>'') and oc_debet_date between ? and ? and oc_debet_serviceuid is null) a, oc_prestations b" +
                        " where" +
                        " oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                        " and serviceuid in ("+Service.getChildIdsAsString(service)+")"+
                        " group by oc_debet_serviceuid,oc_prestation_description,oc_prestation_code" +
                        " ) q"+
                        " group by oc_debet_serviceuid,oc_prestation_description,oc_prestation_code" +
                        " order by oc_debet_serviceuid,total desc";
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        PreparedStatement ps = loc_conn.prepareStatement(sQuery);
        ps.setDate(1,new java.sql.Date(begin.getTime()));
        ps.setDate(2,new java.sql.Date(end.getTime()));
        ps.setDate(3,new java.sql.Date(begin.getTime()));
        ps.setDate(4,new java.sql.Date(end.getTime()));
        ResultSet rs =ps.executeQuery();
        String activeservice=null;
        int totalpatientincome=0;
        int totalinsurarincome=0;
        int totalservicepatientincome=0;
        int totalserviceinsurarincome=0;
        while (rs.next()){
            String serviceuid=checkString(rs.getString("oc_debet_serviceuid"));
            if(activeservice==null || !activeservice.equalsIgnoreCase(serviceuid)){
                if(activeservice!=null){
                    out.println("<tr><td/><td colspan='4'><hr/></td></tr><tr><td colspan='2'/><td><b>"+(totalserviceinsurarincome+totalservicepatientincome)+"</b></td><td><b>"+totalservicepatientincome+"</b></td><td><b>"+totalserviceinsurarincome+"</b></td></tr>");
                }
                activeservice=serviceuid;
                out.println("<tr class='admin'><td>"+(activeservice.length()==0?"?":activeservice+": "+getTran("service",activeservice,sWebLanguage))+"</td>"+
                        "<td>#</td><td>"+getTran("web","total",sWebLanguage)+"</td><td>"+getTran("web","patient",sWebLanguage)+"</td><td>"+getTran("web","insurar",sWebLanguage)+"</td></tr>");
                totalpatientincome+=totalservicepatientincome;
                totalinsurarincome+=totalserviceinsurarincome;
                totalserviceinsurarincome=0;
                totalservicepatientincome=0;
            }
            int patientincome = rs.getInt("patientincome");
            int insurarincome = rs.getInt("insurarincome");
            totalserviceinsurarincome+=insurarincome;
            totalservicepatientincome+=patientincome;
            out.println("<tr><td class='admin'>"+rs.getString("oc_prestation_code")+": "+rs.getString("oc_prestation_description")+"</td><td>"+rs.getInt("quantity")+" ("+rs.getInt("number")+" "+getTran("web","invoices",sWebLanguage)+")</td><td>"+(patientincome+insurarincome)+"</td><td>"+patientincome+"</td><td>"+insurarincome+"</td></tr>");
        }
        if(activeservice!=null){
            out.println("<tr><td/><td colspan='4'><hr/></td></tr><tr><td colspan='2'/><td><b>"+(totalserviceinsurarincome+totalservicepatientincome)+"</b></td><td><b>"+totalservicepatientincome+"</b></td><td><b>"+totalserviceinsurarincome+"</b></td></tr>");
            totalpatientincome+=totalservicepatientincome;
            totalinsurarincome+=totalserviceinsurarincome;
            out.println("<tr class='admin'><td>"+getTran("web","allservices",sWebLanguage)+"</td><td/><td><b>"+(totalinsurarincome+totalpatientincome)+"</b></td><td><b>"+totalpatientincome+"</b></td><td><b>"+totalinsurarincome+"</b></td></tr>");
        }
        rs.close();
        ps.close();
        loc_conn.close();
    }
%>
</table>

<script>
	function searchService(serviceUidField,serviceNameField){
        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.getElementById(serviceNameField).focus();
    }
</script>