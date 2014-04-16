<%@page import="be.openclinic.finance.Prestation"%>
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
            <td valign='bottom'>
                <%=getTran("web","from",sWebLanguage)%>&nbsp;</td><td  valign='bottom'><%=writeDateField("begin","serviceIncome",sBegin,sWebLanguage)%>&nbsp;<%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","serviceIncome",sEnd,sWebLanguage)%>&nbsp;
                <input type="submit" class="button" name="find" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
        <tr>
        	<td valign='bottom'>
        		<%=getTran("Web","service",sWebLanguage) %></td><td colspan='2'  valign='bottom'><input type='hidden' name='statserviceid' id='statserviceid' value='<%=service %>'>
        		<input class='text' type='text' name='statservicename' id='statservicename' readonly size='40' value='<%=serviceName %>'>
        		<img src='_img/icon_search.gif' class='link' alt='<%=getTran("Web","select",sWebLanguage) %>' onclick='searchService("statserviceid","statservicename");'>
        		<img src='_img/icon_delete.gif' class='link' alt='<%=getTran("Web","clear",sWebLanguage) %>' onclick='statserviceid.value="";statservicename.value="";'>
				<input type="checkbox" class="text" name="details" <%=request.getParameter("details")!=null?"checked":"" %>/><%= getTran("web","showdetails",sWebLanguage) %>
        	</td>
        </tr>
    </table>
</form>
<table>
<%
    if(request.getParameter("find")!=null){
        java.util.Date begin=new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("begin"));
        java.util.Date end=new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("end"));
        //We zoeken alle debets op van de betreffende periode en ventileren deze per dienst
		
        String sQuery="select count(*) number,sum(oc_amount) total,sum(oc_patientamount) patientincome,sum(oc_insuraramount+oc_extrainsuraramount) insurarincome,oc_serviceuid,oc_prestationcode" +
                        " from updatestats4" +
                        " where oc_serviceuid in ("+Service.getChildIdsAsString(service)+")"+
                        " and oc_enddate>?"+
                       	" and oc_begindate<?"+
                        " group by oc_serviceuid,oc_prestationcode" +
                        " order by oc_serviceuid,total desc";
        Connection loc_conn=MedwanQuery.getInstance().getStatsConnection();
        PreparedStatement ps = loc_conn.prepareStatement(sQuery);
        ps.setDate(1,new java.sql.Date(begin.getTime()));
        ps.setDate(2,new java.sql.Date(end.getTime()));
        ResultSet rs =ps.executeQuery();
        String activeservice=null;
        int totalpatientincome=0;
        int totalinsurarincome=0;
        int totalservicepatientincome=0;
        int totalserviceinsurarincome=0;
        while (rs.next()){
            String serviceuid=checkString(rs.getString("oc_serviceuid"));
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
            if(request.getParameter("details")!=null){
                String prestationcode=rs.getString("oc_prestationcode");
                Prestation prestation = Prestation.getByCode(prestationcode);
            	out.println("<tr><td class='admin'>"+prestationcode+": "+(prestation==null?"":prestation.getDescription())+"</td><td>"+rs.getInt("number")+"</td><td>"+(patientincome+insurarincome)+"</td><td>"+patientincome+"</td><td>"+insurarincome+"</td></tr>");
            }
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