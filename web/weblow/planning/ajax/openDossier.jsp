<%@ page import="be.openclinic.adt.Planning,be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO" %>
<%@ page import="java.util.*" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindPlanningUID = checkString(request.getParameter("FindPlanningUID"));
    boolean bSetEffectiveDate = checkString(request.getParameter("setEffectiveDate")).length()>0;
  if (sFindPlanningUID.length() > 0) {
        //####################### IF EXISTS APPOINTMENT ###################################//
      Planning planning = Planning.get(sFindPlanningUID);
        String patientUid = planning.getPatientUID();
        if(planning.getEffectiveDate()==null && !bSetEffectiveDate){
       %>
<script>
    Modalbox.show("<div id=\"executionQuestion\" class=\"question\" style=\"width:300px;height:50px;text-align:center;margin-left:140px;\">"+
            "<b><%=HTMLEntities.htmlentities(getTran("planning","wantYouSetExecutionDateToNow",sWebLanguage))%></b>"+
            "<br /><br /><div >"+
            "<input class=\"button large\" type=\"button\" name=\"buttonDelete\" value=\"<%=HTMLEntities.htmlentities(getTranNoLink("openclinic.chuk","ok",sWebLanguage))%>\" onclick=\"openDossier('<%=sFindPlanningUID%>',1)\">&nbsp;"+
             "<input class=\"button large\" type=\"button\" name=\"buttonBack\" value=\"<%=getTranNoLink("openclinic.chuk","no",sWebLanguage)%>\" onclick=\"Modalbox.hide();redirectToDossier('<%=patientUid%>')\">"+
             "</div></div>",{title: "question", width: 600});
    </script>
     <%
        }else{
            planning.setEffectiveDate(new Date());
            planning.store();
            out.write("<script>redirectToDossier('"+patientUid+"');</script>");
        }
    }
%>



