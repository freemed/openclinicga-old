<%@ page import="be.openclinic.adt.Planning,
                 be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("planning.user", "select", activeUser)%><%!
    private int testItemMargin(List l, Planning a) {
        for (int i = 0; i < l.size(); i++) {
            Planning tempA = (Planning) l.get(i);
            long actualBegin = a.getPlannedDate().getTime();
            long actualEnd = a.getPlannedEndDate().getTime();
            long tempBegin = tempA.getPlannedDate().getTime();
            long tempEnd = tempA.getPlannedEndDate().getTime();
            if ((actualBegin < tempEnd && actualBegin > tempBegin) || (actualEnd > tempBegin && actualEnd < tempEnd)) {
                if (a.getMargin() == tempA.getMargin()) {
                    a.setMargin((tempA.getMargin() - 10));
                }
            }
        }
        return a.getMargin();
    }
%><%
    String sYear = checkString(request.getParameter("year"));
    String sUserId = checkString(request.getParameter("FindUserUID"));
    String sPatientId = checkString(request.getParameter("PatientID"));
    String sMonth = checkString(request.getParameter("month"));
    String sDay = checkString(request.getParameter("day"));
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy"),
            fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String sBegin = checkString(activeUser.getParameter("PlanningFindFrom"));
    if (sBegin.length() == 0) {
        sBegin = 8 + "";
    }
    String sEnd = checkString(activeUser.getParameter("PlanningFindUntil"));
    if (sEnd.length() == 0) {
        sEnd = 20 + "";
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    Date startOfWeek = sdf.parse(sDay + "/" + sMonth + "/" + sYear);
    long week=604800000;
    Date endOfWeek = new Date(startOfWeek.getTime()+week);
    // display all registered appointments for the active User
    StringBuffer sHtml = new StringBuffer();
    String appointmentDate, visitDate;
    Planning appointment;
    String sUserName, sOnClick;
    String sTranViewDossier = getTranNoLink("web", "viewDossier", sWebLanguage);
    List userAppointments = new LinkedList();
    if (sUserId.length() > 0 && sPatientId.length() <= 0) {
        userAppointments = Planning.getUserPlannings(sUserId, startOfWeek, endOfWeek);
    } else if (sPatientId.length() > 0) {
        if(sUserId.trim().equals("-1")){
            sUserId = "";
        }
        userAppointments = Planning.getPatientPlannings(sPatientId,sUserId, startOfWeek, endOfWeek);
    }
    for (int i = 0; i < userAppointments.size(); i++) {
        appointment = (Planning) userAppointments.get(i);
        // margin left
        appointment.setMargin(0);

        //If hidden appointment
        String hidden = "";
        Date plannedStart=appointment.getPlannedDate();
        Date plannedEnd=appointment.getPlannedEndDate();

        int startHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sBegin.replace(",",".")))).intValue();    // Start hour of week planner
		
        if (Integer.parseInt(new SimpleDateFormat("HH").format(plannedStart)) < startHourOfWeekPlanner || (Integer.parseInt(new SimpleDateFormat("HH").format(plannedEnd)) > (Float.parseFloat(sEnd.replace(",",".")) + 1) || ((Integer.parseInt(new SimpleDateFormat("HH").format(plannedEnd)) == (Float.parseFloat(sEnd) + 1)) && Integer.parseInt(new SimpleDateFormat("mm").format(plannedEnd)) > 0))) {
            hidden = fullDateFormat.format(plannedStart.getTime()) + " -> " + fullDateFormat.format(plannedEnd.getTime());
        }
        // user names
        sUserName = appointment.getUserUID();
        if (appointment.getUserUID().length() > 0) {
            sUserName += " <b>&</b> " + appointment.getUserUID();
        }
        // display one appointment
        sHtml.append(">");
         sHtml.append(">");
        String sToDisplay = "<ul>";
        if (!appointment.getUserUID().equals("")) {
            sToDisplay += "<li><span class='info person'>" + ((appointment.getPatient()!=null)?HTMLEntities.htmlentities(appointment.getPatient().lastname + " " + appointment.getPatient().firstname):"") + "</li>";
        }
        if(appointment.getContextID().length()>0){
            sToDisplay+="<li><span class='info'>"+getTran("Web.Occup", appointment.getContextID(), sWebLanguage)+"</li>";
        }
        sToDisplay+="</ul>";
        // appointment info
        sHtml.append("\n\n<item>");
        sHtml.append("\n<id>" + appointment.getUid() + "</id>");
        sHtml.append("\n<description>" + sToDisplay + "</description>");
        sHtml.append("\n<eventStartDate>" + new SimpleDateFormat("MMM dd, yyyy HH:mm:ss",new java.util.Locale("en","US")).format(appointment.getPlannedDate()) + "</eventStartDate>");
        sHtml.append("\n<eventEndDate>" + new SimpleDateFormat("MMM dd, yyyy HH:mm:ss",new java.util.Locale("en","US")).format(appointment.getPlannedEndDate()) + "</eventEndDate>");
        sHtml.append("\n<marginleft>" + testItemMargin(userAppointments, appointment) + "</marginleft>");
        sHtml.append("\n<hidden>" + hidden + "</hidden>");
        sHtml.append("\n<effective>" + ((appointment.getEffectiveDate()!=null)?"1":"") + "</effective>");
        sHtml.append("\n</item>");
    }
    out.print(sHtml);%>




