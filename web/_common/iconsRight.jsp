<%@ page import="be.openclinic.id.FingerPrint" %>
<%@ page import="be.mxs.common.util.system.Picture" %>
<%@ page import="be.openclinic.id.Barcode" %>
<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp" %>
 <%-- icons right-top --------------------------------------------------------------------%>
<%
    String sPage       = checkString(request.getParameter("Page")).toLowerCase();
    boolean bMenu = false;
    if ((activePatient!=null) && (activePatient.lastname!=null) && (activePatient.personid.trim().length()>0)){
        if (!sPage.equals("patientslist.jsp")) {
            bMenu = true;
        }
    }
    else{
        activePatient = new AdminPerson();
    }
	if(activePatient!=null && "1".equalsIgnoreCase((String)activePatient.adminextends.get("vip")) && !activeUser.getAccessRight("vipaccess.select")){
	}
	else {

%>

            <input type="text" id="barcode" name="barcode" size="8" class="text" style="{visibility: hidden;color: #FFFFFF;background: #EEEEEE; background-color: #EEEEEE;border-style: none;}" onKeyDown="if(enterEvent(event,13)){readBarcode2(this.value);}"/>
            <%
                String sTmpPersonid = checkString(request.getParameter("personid"));
                if (sTmpPersonid.length() == 0) {
                                sTmpPersonid = checkString(request.getParameter("PersonID"));
                            }
                if (sTmpPersonid.length() > 0) {
                                boolean bFingerPrint = FingerPrint.exists(Integer.parseInt(sTmpPersonid));
                                boolean bPicture = Picture.exists(Integer.parseInt(sTmpPersonid));
                                boolean bBarcode = Barcode.exists(Integer.parseInt(sTmpPersonid));
                                if (!bFingerPrint) {
                                    %> <img class="link" onclick="enrollFingerPrint();"  border='0' src="<c:url value='/_img/icon_fingerprint.png'/>" alt="<%=getTranNoLink("web","enrollFingerPrint",sWebLanguage)%>"/><%
                                }
                                if (!bBarcode) {
                                    %> <img class="link" onclick="printPatientCard();"  border='0' src="<c:url value='/_img/icon_barcode.gif'/>" alt="<%=getTranNoLink("web","printPatientCard",sWebLanguage)%>"/><%
                                }
                                //todo 1=1 to remove
                                if(!bPicture || 1==1){
                                    %> <img class="link" onclick="storePicture();"  border='0' src="<c:url value='/_img/icon_camera.png'/>" alt="<%=getTranNoLink("web","loadPicture",sWebLanguage)%>"/><%
                                }
                                %><!--<img src="<c:url value='/'/><%=sAPPDIR%>_img/logo2.jpg" border='0' class="logo">--><%
                            }



                if(activeUser.getAccessRight("labos.patientlaboresults.select") && activePatient!=null && activePatient.personid.length()>0 && activePatient.hasLabRequests()){
                    %>
                    <img class="link" onclick="searchLab();" title="<%=getTranNoLink("Web","labresults",sWebLanguage)%>"  src="<c:url value='/_img/icon_labo.png'/>" />
                    <%
                }
                if(bMenu && activeUser.getAccessRight("labos.fastresults.select")){
                    %>
                        <img class="link" onclick="showLabResultsEdit();" title="<%=getTranNoLink("Web","fastresultsedit",sWebLanguage)%>"  src="<c:url value='/_img/icon_labo_insert.png'/>" />
                <%}
                if(bMenu && activeUser.getAccessRight("patient.administration.select")){
                    %>
                        <img class="link" onclick="showAdminPopup();" title="<%=getTranNoLink("Web","Administration",sWebLanguage)%>" src="<c:url value='/_img/icon_admin.png'/>" />

        <%                }
            %>
<img class="link" onclick="searchMyHospitalized();" alt="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>" title="<%=getTranNoLink("Web","my_hospitalized_patients",sWebLanguage)%>"  src="<c:url value='/_img/icon_bed.png'/>" />
<img class="link" onclick="window.location = '<c:url value="/main.do" />?Page=meals/manageMeals.jsp&ts='+new Date().getTime()" alt="<%=getTranNoLink("web","meals",sWebLanguage)%>" title="<%=getTranNoLink("web","meals",sWebLanguage)%>"  src="<c:url value='/_img/icon_meals.png'/>" />
<img class="link" onclick="searchMyVisits();" title="<%=getTranNoLink("Web","my_on_visit_patients",sWebLanguage)%>"  src="<c:url value='/_img/icon_doctor.png'/>" />
<img class="link" onclick="doPrint();" title="<%=getTranNoLink("Web","Print",sWebLanguage)%>" src="<c:url value='/_img/printer-print.png'/>" />
<img class="link" id="ddIconAgenda" onclick="window.location='<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&ts='+new Date().getTime()" title="<%=getTranNoLink("Web","Planning",sWebLanguage)%>"  src="<c:url value='/_img/icon_agenda.gif'/>" />
            <%
                String sHelp = MedwanQuery.getInstance().getConfigString("HelpFile");
                if(sHelp.length()>0){
                    %><!--<img id="ddIconHelp" src="<c:url value='/_img/icon_help.gif'/>" height="16" width="16" border="0" alt="Help" onclick="openHelpFile();" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>--><%
                }
            %>
<img class="link" id="ddIconFingerprint" onclick="readFingerprint();" title="<%=getTranNoLink("Web","Read_fingerprint",sWebLanguage)%>"  src="<c:url value='/_img/icon_fingerprint.png'/>" />
          
<%
	}
%>
<img class="link" id="ddIconLogoff" onclick="confirmLogout();" title="<%=getTranNoLink("Web","LogOff",sWebLanguage)%>"  src="<c:url value='/_img/icon_logout.png'/>" />
          &nbsp;
    