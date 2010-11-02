<%@ page import="be.openclinic.adt.Planning,be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO" %>
<%@ page import="java.util.*" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("planning", "select", activeUser)%><%!
    //--- INITIALIZE CALENDAR ---------------------------------------------------------------------
    private Calendar initializeCalendar(String sDate, int iHour) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(ScreenHelper.getSQLDate(sDate));
        calendar.set(Calendar.HOUR_OF_DAY, iHour);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 00);
        calendar.set(Calendar.MILLISECOND, 00);
        return calendar;
    }
    private boolean setDates(Planning planning, HttpServletRequest request, SimpleDateFormat fullDateFormat,int[]defaultDates) throws Exception {
       boolean bRefresh = false; // variable to refresh if fout with date
       try{
            String sPlanningDateDay = checkString(request.getParameter("appointmentDateDay")),
                    sPlanningDateHour = checkString(request.getParameter("appointmentDateHour")),
                    sPlanningDateMinutes = checkString(request.getParameter("appointmentDateMinutes"));
            // set appointment End date
            String sPlanningDateEndDay = checkString(request.getParameter("appointmentDateEndDay")),
                    sPlanningDateEndHour = checkString(request.getParameter("appointmentDateEndHour")),
                    sPlanningDateEndMinutes = checkString(request.getParameter("appointmentDateEndMinutes"));

            int defaultBeginHour = defaultDates[0];
            int defaultBeginMin = defaultDates[1];
            int defaultEndHour = defaultDates[2];
            int defaultEndMin = defaultDates[3];

            // date control
            if(Integer.parseInt(sPlanningDateEndHour)>defaultEndHour){
                sPlanningDateEndHour = defaultEndHour+"";
                sPlanningDateEndMinutes = defaultEndMin+"";
                bRefresh = true;
            }else if((Integer.parseInt(sPlanningDateEndHour)==defaultEndHour)&&(Integer.parseInt(sPlanningDateEndMinutes)>0 && defaultEndMin==0)){
                sPlanningDateEndMinutes = "0";
                bRefresh = true;
            }else if((Integer.parseInt(sPlanningDateEndHour)==defaultEndHour) && (Integer.parseInt(sPlanningDateEndMinutes) >defaultEndMin )){
                sPlanningDateEndMinutes = defaultEndMin+"";
                bRefresh = true;
            }
            if((Integer.parseInt(sPlanningDateHour)==defaultBeginHour)&& Integer.parseInt(sPlanningDateMinutes)<defaultBeginMin){
                sPlanningDateMinutes = defaultBeginMin+"";
                bRefresh = true;
            }

            Date beginDate =  fullDateFormat.parse(sPlanningDateDay + " " + sPlanningDateHour + ":" + sPlanningDateMinutes);
            Date enddate = (fullDateFormat.parse(sPlanningDateDay + " " + sPlanningDateEndHour + ":" + sPlanningDateEndMinutes));
            if(beginDate.compareTo(enddate)>-1){
                // set begin date -5 min of end date if begin date is after the default end date
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(enddate);
                calendar.add(Calendar.MINUTE,-5);
                beginDate = calendar.getTime();
            }
            planning.setPlannedDate(beginDate);

            long minutes = ((enddate.getTime()-planning.getPlannedDate().getTime())/1000)/60;
            if(minutes>55){
                  planning.setEstimatedtime((minutes/60+":"+(minutes-((minutes/60)*60))));
            }else{
                   planning.setEstimatedtime("00:"+minutes);
           }
       }catch(Exception e){
           Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
       }
       return bRefresh;
    }
%>
<%
	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    String sAction = checkString(request.getParameter("Action"));
    String sFindPlanningUID = checkString(request.getParameter("FindPlanningUID"));
    String sPage = checkString(request.getParameter("Page"));
    String sFindUserUID = checkString(request.getParameter("FindUserUID"));
    SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String sEstimatedTime = "";
    boolean show = false;
    String appointmentDateDay = "", appointmentDateHour = "", appointmentDateMinutes = "",
            appointmentDateEndDay = "", appointmentDateEndHour = "", appointmentDateEndMinutes = "";
    Planning planning = null;
    String sInterval = checkString(activeUser.getParameter("PlanningFindInterval"));
    if (sInterval.length() == 0) {
        sInterval = 30 + "";
    }
    String sFrom = checkString(activeUser.getParameter("PlanningFindFrom"));
    if (sFrom.length() == 0) {
        sFrom = 8 + "";
    }
    String sUntil = checkString(activeUser.getParameter("PlanningFindUntil"));
    if (sUntil.length() == 0) {
        sUntil = 20 + "";
    }

    int startHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sFrom))).intValue();    // Start hour of week planner
    int endHourOfWeekPlanner = Double.valueOf(Math.floor(Float.parseFloat(sUntil))).intValue();    // End hour of weekplanner.
    int startMinOfWeekPlanner = (sFrom.split("\\.").length>1)?Integer.parseInt(sFrom.split("\\.")[1]):0;
    int endMinOfWeekPlanner = (sUntil.split("\\.").length>1)?Integer.parseInt(sUntil.split("\\.")[1]):0;


    if (sAction.equalsIgnoreCase("save")) {
        try {
            //####################### IF APPOINTMENT TO SAVE ###################################//
            String sEditPlanningUID = checkString(request.getParameter("EditPlanningUID"));
            String sEditEstimatedtime = checkString(request.getParameter("EditEstimatedtime"));
            String sEditEffectiveDate = checkString(request.getParameter("EditEffectiveDate")) + " " + checkString(request.getParameter("EditEffectiveDateTime"));
            String sEditCancelationDate = checkString(request.getParameter("EditCancelationDate")) + " " + checkString(request.getParameter("EditCancelationDateTime"));
            String sEditUserUID = checkString(request.getParameter("EditUserUID"));
            String sEditPatientUID = checkString(request.getParameter("EditPatientUID"));
            String sEditTransactionUID = checkString(request.getParameter("EditTransactionUID"));
            String sEditContactType = checkString(request.getParameter("EditContactType"));
            String sEditContactUID = checkString(request.getParameter("EditContactUID"));
            String sEditDescription = checkString(request.getParameter("EditDescription"));
            String sEditContext = checkString(request.getParameter("EditContext"));

            planning = new Planning();
            planning.setUid(sEditPlanningUID);
            planning.setEstimatedtime(sEditEstimatedtime);
            planning.setEffectiveDate(ScreenHelper.getSQLTime(sEditEffectiveDate));
            planning.setCancelationDate(ScreenHelper.getSQLTime(sEditCancelationDate));
            planning.setUserUID(sEditUserUID);

            planning.setPatientUID(sEditPatientUID);
            planning.setTransactionUID(sEditTransactionUID);
            planning.setContextID(sEditContext);
            setDates(planning, request, fullDateFormat,new int[]{startHourOfWeekPlanner,startMinOfWeekPlanner,endHourOfWeekPlanner,endMinOfWeekPlanner});
            ObjectReference orContact = new ObjectReference();
            orContact.setObjectType(sEditContactType);
            orContact.setObjectUid(sEditContactUID);
            planning.setContact(orContact);
            planning.setDescription(sEditDescription);
            if(planning.store()){
                if(sPage.length()==0){
                    out.write("<script>clientMsg.setValid('"+HTMLEntities.htmlentities(getTranNoLink("web.control","dataissaved",sWebLanguage))+"',null,500);doClose();</script>");
                }else{
                    out.write("<script>window.location.reload(true);Modalbox.hide();</script>");
                }
            }else{
                if(sPage.length()==0){
                    out.write("<script>clientMsg.setError('"+HTMLEntities.htmlentities(getTranNoLink("web.control","dberror",sWebLanguage))+"');</script>");
                }else{
                    if(sPage.length()==0){
                        out.write("<script>alert('"+HTMLEntities.htmlentities(getTranNoLink("web.control","dberror",sWebLanguage))+"');</script>");                        
                    }
                }
            }

        }
        catch (Exception e) {
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
    } else if (sAction.equalsIgnoreCase("delete")) {
        String sEditPlanningUID = checkString(request.getParameter("AppointmentID"));
        Planning.delete(sEditPlanningUID);
        if(sPage.length()==0){
            out.write("<script>clientMsg.setValid('"+HTMLEntities.htmlentities(getTranNoLink("web","dataisdeleted",sWebLanguage))+"',null,1000);doClose();</script>");
        }else{
            out.write("<script>doClose();window.location.reload(true);</script>");
        }
    } else if (sAction.equalsIgnoreCase("update")) {
        //####################### IF TO APPOINTMENT DATE UPDATE ###################################//
        try {
            String sEditPlanningUID = checkString(request.getParameter("AppointmentID"));
            planning = new Planning();
            // set appointment date
            boolean bRefresh = setDates(planning, request, fullDateFormat,new int[]{startHourOfWeekPlanner,startMinOfWeekPlanner,endHourOfWeekPlanner,endMinOfWeekPlanner});
            if(planning.updateDate(sEditPlanningUID)){
                out.write("<script>clientMsg.setValid('"+HTMLEntities.htmlentities(getTranNoLink("web.control","dataissaved",sWebLanguage))+"',null,1000);"+((bRefresh)?"refreshAppointments();":"")+"</script>");

            }
        }
        catch (Exception e) {
            out.write("<script>clientMsg.setError('"+HTMLEntities.htmlentities(getTranNoLink("web.control","dberror",sWebLanguage))+"');</script>");
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
    } else if (sAction.equalsIgnoreCase("new")) {
        //####################### IF NEW APPOINTMENT ###################################//
        planning = new Planning();
        if(activePatient!=null){
            planning.setPatientUID(activePatient.personid);
            planning.setPatient(activePatient);
        }
        planning.setUserUID(sFindUserUID);

        if(Integer.parseInt(planning.getUserUID())<=0){
            planning.setUserUID(activeUser.userid);
        }
        setDates(planning, request, fullDateFormat,new int[]{startHourOfWeekPlanner,startMinOfWeekPlanner,endHourOfWeekPlanner,endMinOfWeekPlanner});
        // appointment date
        if (planning.getPlannedDate() != null) {
            appointmentDateDay = new SimpleDateFormat("dd/MM/yyyy").format(planning.getPlannedDate());
            appointmentDateHour = new SimpleDateFormat("HH").format(planning.getPlannedDate());
            appointmentDateMinutes = new SimpleDateFormat("mm").format(planning.getPlannedDate());
        } else {
            appointmentDateDay = "";
            appointmentDateHour = new SimpleDateFormat("HH").format(sFrom + "");
            appointmentDateMinutes = "";
        }
        // appointment edn date
        planning.setPlannedEndDate();
        if (planning.getPlannedEndDate() != null) {
            appointmentDateEndDay = new SimpleDateFormat("dd/MM/yyyy").format(planning.getPlannedEndDate());
            appointmentDateEndHour = new SimpleDateFormat("HH").format(planning.getPlannedEndDate());
            appointmentDateEndMinutes = new SimpleDateFormat("mm").format(planning.getPlannedEndDate());
        } else {
            appointmentDateEndDay = appointmentDateDay;
            appointmentDateEndHour = appointmentDateHour;
            appointmentDateEndMinutes = appointmentDateMinutes;
        }

        show = true;
    } else if (sFindPlanningUID.length() > 0) {
        //####################### IF EXISTS APPOINTMENT ###################################//
        planning = Planning.get(sFindPlanningUID);
        // appointment date
        if (planning.getPlannedDate() != null) {
            appointmentDateDay = new SimpleDateFormat("dd/MM/yyyy").format(planning.getPlannedDate());
            appointmentDateHour = new SimpleDateFormat("HH").format(planning.getPlannedDate());
            appointmentDateMinutes = new SimpleDateFormat("mm").format(planning.getPlannedDate());
        } else {
            appointmentDateDay = "";
            appointmentDateHour = new SimpleDateFormat("HH").format(sFrom + "");
            appointmentDateMinutes = "";
        }
        // appointment edn date
        if (planning.getPlannedEndDate() != null) {
            appointmentDateEndDay = new SimpleDateFormat("dd/MM/yyyy").format(planning.getPlannedEndDate());
            appointmentDateEndHour = new SimpleDateFormat("HH").format(planning.getPlannedEndDate());
            appointmentDateEndMinutes = new SimpleDateFormat("mm").format(planning.getPlannedEndDate());
        } else {
            appointmentDateEndDay = appointmentDateDay;
            appointmentDateEndHour = appointmentDateHour;
            appointmentDateEndMinutes = appointmentDateMinutes;
        }
        show = true;
    }
    if (show) {

%>

<table class='list' border='0' width='630' cellspacing='1'>
    <tr>
        <td width="<%=sTDAdminWidth%>" class="admin"><%=HTMLEntities.htmlentities(getTran("planning", "planneddate", sWebLanguage))%>*</td>
        <td class="admin2">
            <%-- hour --%> <select id="appointmentDateHour" name="appointmentDateHour" class="text" onchange="updateSelect();">
            <%
                for (int n = startHourOfWeekPlanner; n <= endHourOfWeekPlanner; n++) {
                out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                if (appointmentDateHour.length() > 0 && n == Integer.parseInt(appointmentDateHour)) {
                    out.print("selected");
                }
                out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
            }%>
        </select> <%-- minutes --%>
         <select id="appointmentDateMinutes" name="appointmentDateMinutes" class="text">
            <%for (int n = 0; n < 60; n=n+5) {
                out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                if (appointmentDateMinutes.length() > 0 && n == Integer.parseInt(appointmentDateMinutes)) {
                    out.print("selected");
                }
                out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
            }%>
        </select><%=getTran("Web.occup", "medwan.common.hour", sWebLanguage)%>&nbsp;<%=ScreenHelper.planningDateTimeField("appointmentDateDay", appointmentDateEndDay, sWebLanguage, sCONTEXTPATH)%>
        </td>
    </tr>
   <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("web.hrm", "until", sWebLanguage))%>
        </td>
        <td class="admin2">
            <%-- hour --%> <select id="appointmentDateEndHour" name="appointmentDateEndHour" class="text" onchange="updateSelect();">
            <%for (int n = startHourOfWeekPlanner; n <= endHourOfWeekPlanner; n++) {
                out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                if (appointmentDateEndHour.length() > 0 && n == Integer.parseInt(appointmentDateEndHour)) {
                    out.print("selected");
                }
                out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
            }%>
        </select> <%-- minutes --%>
            <select id="appointmentDateEndMinutes" name="appointmentDateEndMinutes" class="text">
                <%for (int n = 0; n < 60; n=n+5) {
                    out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                    if (appointmentDateEndMinutes.length() > 0 && n == Integer.parseInt(appointmentDateEndMinutes)) {
                        out.print("selected");
                    }
                    out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
                }%>
            </select><%=HTMLEntities.htmlentities(getTran("Web.occup", "medwan.common.hour", sWebLanguage))%>&nbsp;

        </td>
    </tr>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("planning", "effectivedate", sWebLanguage))%>
        </td>
        <td class="admin2"><%=ScreenHelper.newWriteDateTimeField("EditEffectiveDate", planning.getEffectiveDate(), sWebLanguage, sCONTEXTPATH)%>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("planning", "cancelationdate", sWebLanguage))%>
        </td>
        <td class="admin2"><%=ScreenHelper.newWriteDateTimeField("EditCancelationDate", planning.getCancelationDate(), sWebLanguage, sCONTEXTPATH)%>
        </td>
    </tr>
    <tr>
        <td class='admin'><%=HTMLEntities.htmlentities(getTran("planning", "user", sWebLanguage))%>*</td>
        <td class='admin2'>
            <input type="hidden" id="EditUserUID" name="EditUserUID" value="<%=planning.getUserUID()%>">
            <input class="text" type="text" id="EditUserName" name="EditUserName" readonly size="<%=sTextWidth%>" value="<%=HTMLEntities.htmlentities(ScreenHelper.getFullUserName(planning.getUserUID(),ad_conn))%>">
            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('EditUserUID','EditUserName');">
            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="$('EditUserUID').clear();$('EditUserName').clear();">
        </td>
    </tr>
    <tr>
        <td class='admin'><%=HTMLEntities.htmlentities(getTran("planning", "patient", sWebLanguage))%>*</td>
        <td class='admin2'>
            <input type="hidden" id="EditPatientUID" name="EditPatientUID" value="<%=(planning.getPatientUID()==null)?"":planning.getPatientUID()%>">
            <input class="text" id="EditPatientName" type="text" name="EditPatientName" readonly size="<%=sTextWidth%>" value="<%=HTMLEntities.htmlentities(ScreenHelper.getFullPersonName(planning.getPatientUID(),ad_conn))%>">
            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchMyPatient('EditPatientUID','EditPatientName');">
            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="$('EditPatientUID').clear();$('EditPatientName').clear();">
        </td>
    </tr>
    <%
        if (checkString(planning.getTransactionUID()).length() > 0) {
            TransactionVO transaction = planning.getTransaction();
            String sTransactionType = "";
            if (transaction != null) {
                sTransactionType = getTran("web.occup", transaction.getTransactionType(), sWebLanguage);
            }
    %>
    <tr>
        <td class='admin'><%=getTran("planning", "transaction", sWebLanguage)%>
        </td>
        <td class='admin2'>
            <input type="text" id="EditTransactionUID" name="EditTransactionUID" value="<%=planning.getTransactionUID()%>"/>
            <input class="text" type="text" readonly size="<%=sTextWidth%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+": "+sTransactionType%>"/>
        </td>
    </tr>
    <%}%>
    <tr>
        <td class='admin'><%=getTran("web", "prestation", sWebLanguage)%>
        </td>
        <td class='admin2'>
            <%
                String sEditCheckProduct = "", sEditCheckExamination = "", sEditContactName = "";
                ObjectReference orContact = planning.getContact();
                if (orContact != null) {
                    if (orContact.getObjectType().equalsIgnoreCase("examination")) {
                        sEditCheckExamination = " checked";

                        ExaminationVO examination = MedwanQuery.getInstance().getExamination(orContact.getObjectUid(), sWebLanguage);
                        if (examination != null) {
                            sEditContactName = HTMLEntities.htmlentities(getTran("web.occup", examination.getTransactionType(), sWebLanguage));
                        }
                    } else if (orContact.getObjectType().equalsIgnoreCase("product")) {
                        Product p = Product.get(orContact.getObjectUid());
                        if(p!=null){
                            sEditContactName = p.getName();
                        }
                        sEditCheckProduct = " checked";
                    }
                } else {
                    orContact = new ObjectReference();
                }
            %>
            <input type='radio' name='EditContactType' id='ContactProduct' value='Product' onclick='changeContactType();' onDblClick="uncheckRadio(this);" <%=sEditCheckProduct%>><label for='ContactProduct'><%=getTran("planning", "product", sWebLanguage)%>
        </label>
            <input type='radio' name='EditContactType' id='ContactExamination' value='Examination' onclick='changeContactType();' onDblClick="uncheckRadio(this);" <%=sEditCheckExamination%>><label for='ContactExamination'><%=getTran("planning", "examination", sWebLanguage)%>
        </label> <br>
            <input type="hidden" id="EditEffectiveDateTime" value="" />
            <input type="hidden" id="EditCancelationDateTime" value="" />
            <input type="hidden" id="EditContactUID" name="EditContactUID" value="<%=orContact.getObjectUid()%>">
            <input class="text" type="text" id="EditContactName" name="EditContactName" readonly size="<%=sTextWidth%>" value="<%=sEditContactName%>">
            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation('EditContactUID','EditContactName');">
            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="$('EditContactUID').clear();$('EditContactName').clear();">
        </td>
    </tr>
    <div id="trContext">
        <tr>
            <td class='admin'><%=getTran("web", "context", sWebLanguage)%>
            </td>
            <td class='admin2'>
                <select class="text" name="EditContext" id="EditContext">
                    <option value=""/>
                    <%
                        // list possible contexts from XML-file
                        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "contexts.xml";
                        if (sDoc.length() > 0) {
                            SAXReader reader = new SAXReader(false);
                            Document document = reader.read(new URL(sDoc));
                            Iterator elements = document.getRootElement().elementIterator("context");

                            // put context-elements in hash
                            Element contextElement;
                            String contextName;
                            Hashtable contexts = new Hashtable();
                            while (elements.hasNext()) {
                                contextElement = (Element) elements.next();
                                contextName = getTran("Web.Occup", contextElement.attribute("id").getValue(), sWebLanguage);
                                contexts.put(contextName, contextElement);
                            }

                            // sort hash on context-name
                            Vector contextNames = new Vector(contexts.keySet());
                            Collections.sort(contextNames);
                            Iterator contextIter = contextNames.iterator();
                            while (contextIter.hasNext()) {
                                contextName = (String) contextIter.next();
                                contextElement = (Element) contexts.get(contextName);
                                out.print("<option value='" + contextElement.attribute("id").getValue() + "' " + (contextElement.attribute("id").getValue().equalsIgnoreCase(planning.getContextID()) ? "selected" : "") + ">" + HTMLEntities.htmlentities(contextName) + "</option>");
                            }
                        }
                    %>
                </select>
            </td>
        </tr>
    </div>
    <tr>
        <td class='admin'><%=HTMLEntities.htmlentities(getTran("planning", "description", sWebLanguage))%>
        </td>
        <td class='admin2'><%=writeTextarea("EditDescription", "", "", "", HTMLEntities.htmlentities(checkString(planning.getDescription())))%>
        </td>
    </tr>
    <tr>
        <td class="admin"/>
        <td class="admin2">
            <input type="hidden" id="EditPage" value="<%=sPage%>" />
            <%-- Buttons --%><%if (activeUser.getAccessRight("planning.add") || activeUser.getAccessRight("planning.edit")) {%>
            <input class='button' type="button" name="buttonSave" id="buttonSaveEditPlanning" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="saveAppointment();">&nbsp;<%
            }
            if ((sFindPlanningUID.length() > 0) && (activeUser.getAccessRight("planning.delete"))) {
        %>
            <input class='button' type="button" name="buttonDelete" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="deleteAppointment2();">&nbsp;<%}%>
            <input class='button' type="button" name="buttonBack" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doClose();">
        </td>
    </tr>
    <tr>
        <td class="admin"/>
        <td class="admin2">
            <%=getTran("Web", "colored_fields_are_obligate", sWebLanguage)%>. <input type="hidden" name="Action"/>
        </td>
    </tr>
</table>

<input type="hidden" id="EditPlanningUID" name="EditPlanningUID" value="<%=sFindPlanningUID%>"/>
<script>
    checkContext();
    changeInputColor();
    updateSelect = function(){
        setCorrectAppointmentDate(<%=startHourOfWeekPlanner+","+startMinOfWeekPlanner+","+endHourOfWeekPlanner+","+endMinOfWeekPlanner%>);
    }
    updateSelect();
</script>
</div>
<%}
	ad_conn.close();

%>          