<%@page import="be.mxs.common.util.system.ScreenHelper,
                java.util.Date,
                java.text.SimpleDateFormat,
                be.openclinic.adt.Encounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    //*** begin ***
    String sBegin = ScreenHelper.checkString(request.getParameter("begin"));
    if(sBegin.length()==0){
        sBegin = ScreenHelper.formatDate(new Date());
    }
    
    Date begin = null;
    try{ 
        begin = ScreenHelper.parseDate(sBegin);
    }
    catch(Exception e){
        begin = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date()));
    }
    
    //*** end ***
    String sEnd = ScreenHelper.checkString(request.getParameter("end"));
    if(sEnd.length()==0){
        sEnd = ScreenHelper.formatDate(new Date());
    }
    
    Date end = null;
    try{
        end = ScreenHelper.parseDate(sEnd);
    }
    catch(Exception e){
        end = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date()));
    }
%>
<form name="diagnosisList" method="POST">
    <%=writeTableHeader("Web","statistics.diagnosisList",sWebLanguage," doBack()")%>
    
    <table width="100%" class="list" cellpadding="0" cellspacing="1">
        <tr>
            <td class="admin2">
                <%=getTran("web","begin",sWebLanguage)%>&nbsp;
                <%=writeDateField("begin","diagnosisList",sBegin,sWebLanguage)%>&nbsp;
                
                <%=getTran("web","end",sWebLanguage)%>&nbsp;
                <%=writeDateField("end","diagnosisList",sEnd,sWebLanguage)%>&nbsp;
                
                <%-- BUTTONS --%>
                <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>&nbsp;
                <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();"/>
            </td>
        </tr>
    </table>
</form>

<%
    int patientcounter = 0, diagnosiscounter = 0;
    
    if(request.getParameter("submit")!=null){
	    %>
	        <table width="100%" class="list" cellpadding="0" cellspacing="1">
			    <tr class="gray">
			        <td><%=getTran("web","patient",sWebLanguage)%></td>
			        <td><%=getTran("web","service",sWebLanguage)%></td>
			        <td colspan="3"><%=getTran("web","diagnoses",sWebLanguage)%></td>
			    </tr>
	    <%

        String sQuery = "select a.*, OC_LABEL_VALUE"+MedwanQuery.getInstance().concatSign()+"'$'"+MedwanQuery.getInstance().concatSign()+"OC_DIAGNOSIS_SERVICEUID as DIAGNOSIS_SERVICEUID"+
                        " from OC_DIAGNOSES a, OC_LABELS b"+
                        "  where OC_LABEL_TYPE = 'service'"+
                        "   and OC_LABEL_ID = a.OC_DIAGNOSIS_SERVICEUID"+
                        "   and OC_LABEL_LANGUAGE = 'fr'"+
                        "   and a.OC_DIAGNOSIS_UPDATETIME >= ?"+
                        "   and a.OC_DIAGNOSIS_UPDATETIME < ?"+
                        " order by OC_LABEL_VALUE, OC_DIAGNOSIS_ENCOUNTERUID";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        end.setTime(end.getTime()+24*3600*1000);
        ps.setTimestamp(1,new Timestamp(begin.getTime()));
        ps.setTimestamp(2,new Timestamp(end.getTime()));
        ResultSet rs = ps.executeQuery();
        String activename = "", sClass = "1";
        
        while(rs.next()){
            String encounterUid = rs.getString("OC_DIAGNOSIS_ENCOUNTERUID");
            
            Encounter encounter = Encounter.get(encounterUid);
            if(encounter!=null){
                diagnosiscounter++;
                
                AdminPerson patient = encounter.getPatient();
                String name = "";
                
                // alternate row-style
                if(sClass.length()==0) sClass = "1";
                else                   sClass = ""; 
                
                // service
                String[] sv = checkString(rs.getString("DIAGNOSIS_SERVICEUID")).split("\\$");
                Service service= Service.getService(sv.length>1?sv[1]:"---");
                String servicename = "-";
                if(service!=null){
                    servicename = service.getLabel(sWebLanguage)+": "+(encounter.getBegin()==null?"":ScreenHelper.stdDateFormat.format(encounter.getBegin()))+" -> "+(encounter.getEnd()==null?"":ScreenHelper.stdDateFormat.format(encounter.getEnd()));
                    if(encounter.getDurationInDays()>90){
                        servicename+= " <img src='_img/icons/icon_warning.gif'/>";
                    }
                }
                
                // patient
                if(!activename.equalsIgnoreCase(patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth)){
                    name = patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth+"</b></td><td><b>"+servicename;
                    activename = patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth;
                    patientcounter++;
                }
                
                if(name.length() > 0){
                    out.print("<tr><td colspan='5'><hr/></td></tr>");
                }
                else{
                    name = "</td><td>";
                }
                
                String code = ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODE")),
                       type = ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODETYPE")).toUpperCase();
                %>
                    <tr class="list<%=sClass%>">
                        <td><b><a href="<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>&PersonID=<%=patient.personid%>"><%=name%></a></b></td>
                        <td><%=ScreenHelper.fullDateFormat.format(rs.getTimestamp("OC_DIAGNOSIS_UPDATETIME"))%></td>
                        <td><%=type%></td>
                        <td><%=code%></td>
                        <td><%=MedwanQuery.getInstance().getDiagnosisLabel(type,code,sWebLanguage)%></td>
                    </tr>
                <%
            }
        }
        rs.close();
        ps.close();
        oc_conn.close();
    
        // total
        %>
			    <tr>
			        <td class="admin2"><%=getTran("web","total.patients",sWebLanguage)%></td>
			        <td class="admin2"><b><%=patientcounter%></b></td>
			        <td class="admin2">&nbsp;</td>
			        <td class="admin2"><%=getTran("web","total.diagnosis",sWebLanguage)%></td>
			        <td class="admin2"><b><%=diagnosiscounter%></b></td>
			    </tr>
		    </table>
	
			<%=ScreenHelper.alignButtonsStart()%>
			    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();"/>
			<%=ScreenHelper.alignButtonsStop()%>
		<%
    }
%>

<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
</script>