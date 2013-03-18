<%@ page import="be.openclinic.medical.Problem" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	AdminPerson person=activePatient;
	String codetype = ScreenHelper.checkString(request.getParameter("codetype"));
    String code = ScreenHelper.checkString(request.getParameter("code"));
    String gravity = ScreenHelper.checkString(request.getParameter("gravity"));
    String certainty = ScreenHelper.checkString(request.getParameter("certainty"));
    if(ScreenHelper.checkString(request.getParameter("patientuid")).length()>0){
    	person=AdminPerson.getAdminPerson(request.getParameter("patientuid"));
    }
    Problem problem=new Problem(person.personid,codetype,code,"",new java.util.Date(),null);
    problem.setGravity(Integer.parseInt(gravity));
    problem.setCertainty(Integer.parseInt(certainty));
    problem.setUpdateDateTime(new java.util.Date());
    problem.store();
%>
<script type="text/javascript">window.close();</script>