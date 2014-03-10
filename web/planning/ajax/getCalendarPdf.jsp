<%@ page import="be.openclinic.adt.Planning,
                 be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.dom4j.DocumentException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.ByteArrayOutputStream,be.mxs.common.util.pdf.general.*" %>
<%@ page import="be.mxs.common.util.pdf.calendar.PDFCalendarGenerator" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("planning.user", "select", activeUser)%>

<%!private int testItemMargin(Vector v, Planning a) {
    for (int i = 0; i < v.size(); i++) {
        Planning tempA = (Planning) v.get(i);
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
%>

<%
    String sYear = checkString(request.getParameter("year"));
    String sUserId = checkString(request.getParameter("FindUserUID"));
    String sPatientId = checkString(request.getParameter("PatientID"));
    String sMonth = checkString(request.getParameter("month"));
    String sDay = checkString(request.getParameter("day"));
    String sDayToShow = checkString(request.getParameter("dayToShow"));
    boolean isPatient = checkString(request.getParameter("ispatient")).equals("true");
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy"), fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String sBegin = checkString(activeUser.getParameter("PlanningFindFrom"));
    String sProjectName = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();


   
    PDFCalendarGenerator calendarGenerator = new PDFCalendarGenerator(activeUser, sProjectName, sWebLanguage);
    User calendarUser = User.get(Integer.parseInt(sUserId));
    String sHeader = getTranNoLink("web","calendar.health.professional",sWebLanguage)+": "+(calendarUser==null?"":calendarUser.person.lastname+" "+calendarUser.person.firstname);
    if(isPatient){
        sHeader = getTranNoLink("web","appointment.list.patient",sWebLanguage)+" \n"+activePatient.lastname+" "+activePatient.firstname+" \n"+ activePatient.dateOfBirth+" ("+activePatient.personid+")";
    }
    calendarGenerator.addHeader(sHeader);
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

    Planning appointment;
    List userAppointments = new LinkedList();


    if (sUserId.length() > 0 && !isPatient) {
        userAppointments = Planning.getUserPlannings(sUserId, startOfWeek, endOfWeek);
    } else if (isPatient) {
        if (sUserId.trim().equals("-1")) {
            sUserId = "";
        }
        userAppointments = Planning.getPatientFuturePlannings(sPatientId, ScreenHelper.formatDate(startOfWeek));
    }
    String sActiveDate="";
    for (int i = 0; i < userAppointments.size(); i++) {
        boolean bShow = true;
        appointment = (Planning) userAppointments.get(i);
        // margin left
        appointment.setMargin(0);

        Date plannedStart=appointment.getPlannedDate();
        Date plannedEnd=appointment.getPlannedEndDate();
        if(sDayToShow.length()>0){
          int iDayToShow = Integer.parseInt(sDayToShow);
            if(iDayToShow!=plannedStart.getDay()+1){
                bShow = false;
            }
        }

        if(bShow){
        	if(!sActiveDate.equals(new SimpleDateFormat("dd/MM/yyyy").format(plannedStart))){
        		sActiveDate=new SimpleDateFormat("dd/MM/yyyy").format(plannedStart);
        		if(isPatient){
        			calendarGenerator.addDateRow(appointment);
        		}
        		else {
        			calendarGenerator.addCleanDateRow(appointment);
        		}
        	}
            if(isPatient){
                calendarGenerator.addAppointmentRow(activeUser);
            }else{
                 calendarGenerator.addTimedAppointmentRow(appointment);
            }
        }
    }
   calendarGenerator.addPrintedRow();
   ByteArrayOutputStream baosPDF = null;
    try {


        baosPDF = calendarGenerator.generatePDFDocumentBytes(request,"","",activePatient);
        // PDF generator
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");
        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=").append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition", sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch
            (Exception dex) {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }

%>




