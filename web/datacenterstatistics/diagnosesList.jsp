<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="be.openclinic.adt.Encounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sBegin = ScreenHelper.checkString(request.getParameter("begin"));
    if(sBegin.length()==0){
        sBegin=ScreenHelper.stdDateFormat.format(new Date());
    }
    Date begin=null;
    try {
        begin = ScreenHelper.parseDate(sBegin);
    }
    catch(Exception e){
        begin = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date()));
    }
    String sEnd = ScreenHelper.checkString(request.getParameter("end"));
    if(sEnd.length()==0){
        sEnd=ScreenHelper.stdDateFormat.format(new Date());
    }
    Date end=null;
    try {
        end = ScreenHelper.parseDate(sEnd);
    }
    catch(Exception e){
        end = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date()));
    }
%>
<form name="diagnosisList" method="POST">
    <table width="100%" border="0">
        <tr class="admin">
            <td><%=getTran("web","begin",sWebLanguage)%>&nbsp;
                <%=writeDateField("begin","diagnosisList",sBegin,sWebLanguage)%>&nbsp;
                <%=getTran("web","end",sWebLanguage)%>&nbsp;
                <%=writeDateField("end","diagnosisList",sEnd,sWebLanguage)%>&nbsp;
                <input class="button" type="submit" name="submit" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
</form>
<table width="100%">
    <%
        if(request.getParameter("submit")!=null){
    %>
    <tr class="gray"><td><%=getTran("web","patient",sWebLanguage)%></td><td><%=getTran("web","service",sWebLanguage)%></td><td colspan="4"><%=getTran("web","diagnoses",sWebLanguage)%></td></tr>
<%
    }
    int patientcounter=0,diagnosiscounter=0;
    if(request.getParameter("submit")!=null){
        String sQuery="select a.*,(select max(OC_LABEL_VALUE+'$'+OC_ENCOUNTER_SERVICEUID) from OC_ENCOUNTERS_VIEW,OC_LABELS where OC_LABEL_TYPE='service' and OC_LABEL_ID=OC_ENCOUNTER_SERVICEUID and OC_LABEL_LANGUAGE='fr' and OC_ENCOUNTER_OBJECTID=replace(OC_DIAGNOSIS_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')) OC_ENCOUNTER_SERVICEUID from OC_DIAGNOSES a "+
        " where "+
        " a.OC_DIAGNOSIS_UPDATETIME>=? and "+
        " a.OC_DIAGNOSIS_UPDATETIME<? "+
        " order by OC_ENCOUNTER_SERVICEUID,OC_DIAGNOSIS_ENCOUNTERUID";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        end.setTime(end.getTime()+24*3600*1000);
        ps.setTimestamp(1,new Timestamp(begin.getTime()));
        ps.setTimestamp(2,new Timestamp(end.getTime()));
        ResultSet rs = ps.executeQuery();
        String activename="";
        while (rs.next()){
            String encounterUid = rs.getString("OC_DIAGNOSIS_ENCOUNTERUID");
            Encounter encounter = Encounter.get(encounterUid);
            if(encounter!=null){
                diagnosiscounter++;
                AdminPerson patient=encounter.getPatient();
                String name="";
                String[] sv=checkString(rs.getString("OC_ENCOUNTER_SERVICEUID")).split("\\$");
                Service service= Service.getService(sv.length>1?sv[1]:"---");
                String servicename="-";
                if(service!=null){
                    servicename=service.getLabel(sWebLanguage)+": "+
                            (encounter.getBegin()==null?"":ScreenHelper.stdDateFormat.format(encounter.getBegin()))+
                            " -> "+
                            (encounter.getEnd()==null?"":ScreenHelper.stdDateFormat.format(encounter.getEnd()));
                    if(encounter.getDurationInDays()>90){
                        servicename+=" <img src='_img/warning.gif'/>";
                    }
                }
                if(!activename.equalsIgnoreCase(patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth)){
                    name=patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth+"</b></td><td><b>"+servicename;
                    activename=patient.personid+" "+patient.firstname+" "+patient.lastname+" "+patient.gender+" °"+patient.dateOfBirth;
                    patientcounter++;
                }
                if(name.length()>0){
                    out.println("<tr><td colspan='6'><hr/></td></tr>");
                }
                else {
                    name="</td><td>";
                }
                String code = ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODE"));
                String type=rs.getString("OC_DIAGNOSIS_CODETYPE").toUpperCase();
                %>
                    <tr class="admin2"><td><b><a href="<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>&PersonID=<%=patient.personid%>"><%=name%></a></b></td>
                <%
                out.println("<td>"+ScreenHelper.fullDateFormat.format(rs.getTimestamp("OC_DIAGNOSIS_UPDATETIME"))+"</td><td>"+type+"</td><td>"+code+"</td><td>"+MedwanQuery.getInstance().getDiagnosisLabel(type,code,sWebLanguage)+"</td></tr>");
            }
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }
%>
</table>
<%
    if(request.getParameter("submit")!=null){
%>
<table>
<tr class="admin2"><td><%=getTran("web","total.patients",sWebLanguage)%></td><td><b><%=patientcounter%></b></td><td>&nbsp;</td><td><%=getTran("web","total.diagnosis",sWebLanguage)%></td><td><b><%=diagnosiscounter%></b></td></tr>
</table>
<%
    }
%>