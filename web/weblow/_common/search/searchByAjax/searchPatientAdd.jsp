<%@ page import="java.util.Vector,
                 java.util.Hashtable,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sFindLastname = checkString(request.getParameter("FindLastname")),
           sFindFirstname = checkString(request.getParameter("FindFirstname")),
           sFindDOB = checkString(request.getParameter("FindDOB")),
           sFindGender = checkString(request.getParameter("FindGender"));

    AdminPerson person = new AdminPerson();
    person.lastname = sFindLastname;
    person.firstname = sFindFirstname;
    person.dateOfBirth = sFindDOB;
    person.gender = sFindGender;
    person.export = true;
    person.checkArchiveFileCode = false;
    person.checkImmatnew = false;
    person.checkImmatold = false;
    person.checkNatreg = false;
    person.sourceid = "";
    person.updateuserid = activeUser.userid;
	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    person.saveMiniToDB(ad_conn);
    ad_conn.close();

    if (checkString(person.personid).length()>0){
%>
<script>
    setPerson("<%=person.personid%>","<%=sFindLastname+" "+sFindFirstname%>");
</script>
<%
    }
%>
