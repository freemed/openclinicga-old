<%@ page import="be.openclinic.adt.Planning,
be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO,
java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("planning.patient","select",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    //--- DELETE ----------------------------------------------------------------------------------
    if(sAction.equals("delete")){
        String sEditPlanningUID = checkString(request.getParameter("EditPlanningUID"));
        Planning.delete(sEditPlanningUID);

        %>
          <script>
            window.location.href = "<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&Tab=missedAppointments&ts=<%=getTs()%>";
          </script>
        <%
    }

if (activePatient!=null){
    String sFindPatientDate = checkString(request.getParameter("FindPatientDate"));

    if (sFindPatientDate.length()==0){
        sFindPatientDate = checkString(request.getParameter("FindDate"));

        if (sFindPatientDate.length()==0){
            sFindPatientDate = getDate();
        }
    }
%>

<form name="appointmentsForm" method="post" action="<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&Tab=missedAppointments&ts=<%=getTs()%>">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditPlanningUID">

<%=writeTableHeader("planning","missedAppointments",sWebLanguage," doBack();")%>
<%
    String sClass = "";
    SimpleDateFormat hhmmDateFormat = new SimpleDateFormat("HH:mm");

    Vector vPatientMissedPlannings = Planning.getPatientMissedPlannings(activePatient.personid);

    if (vPatientMissedPlannings.size()>0){
        %>
            <br/>

            <table class="list" width="100%" cellspacing="0" cellpadding="0">
                <tr class="admin">
                    <td width="20">&nbsp;</td>
                    <td width="80"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
                    <td width="50"><%=getTran("web","from",sWebLanguage)%></td>
                    <td width="50"><%=getTran("web","to",sWebLanguage)%></td>
                    <td width="200"><%=getTran("planning","user",sWebLanguage)%></td>
                    <td width="250"><%=getTran("web","prestation",sWebLanguage)%></td>
                    <td><%=getTran("web","description",sWebLanguage)%></td>
                </tr>

                <%
                    Planning planning;
                    String[] aHour;
                    Calendar calPlanningStop;
                    ObjectReference orContact;
                    ExaminationVO examination;
                    
                    String sTextAdd = getTran("web", "add", sWebLanguage);
                    SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

                    Iterator iter = vPatientMissedPlannings.iterator();
                    while (iter.hasNext()) {
                        planning = (Planning)iter.next();

                        calPlanningStop = Calendar.getInstance();
                        calPlanningStop.setTime(planning.getPlannedDate());
                        calPlanningStop.set(Calendar.SECOND, 00);
                        calPlanningStop.set(Calendar.MILLISECOND, 00);

                        if (planning.getEstimatedtime().length() > 0) {
                            try {
                                aHour = planning.getEstimatedtime().split(":");
                                calPlanningStop.setTime(planning.getPlannedDate());
                                calPlanningStop.add(Calendar.HOUR, Integer.parseInt(aHour[0]));
                                calPlanningStop.add(Calendar.MINUTE, Integer.parseInt(aHour[1]));
                            }
                            catch (Exception e1) {
                                calPlanningStop.setTime(planning.getPlannedDate());
                            }
                        }

                        // alternate row-style
                        if (sClass.equals("")) sClass = "1";
                        else                   sClass = "";

                        %>
                            <tr class="list<%=sClass%>" >
                                <td><a href="#" onClick="actualAppointmentId='<%=planning.getUid()%>';deleteAppointment2('missedappointements');"><img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","delete",sWebLanguage)%>"></a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');"><%=ScreenHelper.getSQLDate(planning.getPlannedDate())%></a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');"><%=hhmmDateFormat.format(planning.getPlannedDate())%></a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');"><%=hhmmDateFormat.format(calPlanningStop.getTime())%></a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');">
                                    <%
	                                  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                                        if (planning.getUserUID().equals(activeUser.userid)){
                                            out.print("<b>"+ScreenHelper.getFullUserName(planning.getUserUID(), ad_conn)+"</b>");
                                        }
                                        else {
                                            out.print(ScreenHelper.getFullUserName(planning.getUserUID(), ad_conn));
                                        }
                                        ad_conn.close();
                                    %>
                                </a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');">
                                    <%
                                        orContact = planning.getContact();
                                        if (orContact != null) {
                                            if (orContact.getObjectType().equalsIgnoreCase("examination")) {
                                                examination = MedwanQuery.getInstance().getExamination(orContact.getObjectUid(), sWebLanguage);
                                                if(checkString(planning.getTransactionUID()).length()==0){
                                                    out.print("<img src='_img/icon_add.gif' onclick='doExamination(\""+planning.getUid()+"\",\"" + planning.getPatientUID() + "\",\"" + examination.getTransactionType() + "\")' alt='" + sTextAdd + "' class='link'/> "
                                                        + getTran("examination", examination.getId().toString(), sWebLanguage));
                                                }
                                                else {
                                                    String sTextFind = getTran("web", "find", sWebLanguage);
                                                    out.print("<img src='_img/icon_search.gif' onclick='openExamination(\""+planning.getTransactionUID().split("\\.")[0]+"\",\""+planning.getTransactionUID().split("\\.")[1]+"\",\"" + planning.getPatientUID() + "\",\"" + examination.getTransactionType() + "\")' alt='" + sTextFind + "' class='link'/> "
                                                        + getTran("examination", examination.getId().toString(), sWebLanguage));
                                                }
                                            }
                                        }
                                    %>
                                </a></td>
                                <td><a href="#" onclick="openAppointment('<%=planning.getUid()%>','missedappointments');"><%=planning.getDescription()%></a></td>
                            </tr>
                        <%
                    }
                %>
            </table>
            <%=vPatientMissedPlannings.size()%> <%=getTran("web","recordsFound",sWebLanguage)%>
            <br>
        <%
    }
%>
<br/>

<input type="button" name="buttonback" class="button" value="<%=getTran("web","back",sWebLanguage)%>" onclick="doBack();"/>   
</form>
<%
}
else{
    out.print(getTran("web","noactivepatient",sWebLanguage));
}
%>