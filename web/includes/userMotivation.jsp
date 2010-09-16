<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%
String sScreenID = checkString(request.getParameter("ScreenID"));
String sMotivation = "";
if (checkString(request.getParameter("SaveMotivation")).trim().length()>0)
//Save
{

    sMotivation = checkString(request.getParameter("EditMotivation"));
    UserProfileMotivation.update(activeUser.userid,activePatient.personid,sMotivation,sScreenID.toLowerCase(),"empty");
%>
<script>window.close();</script>
<%
}else{
        sMotivation = UserProfileMotivation.getMotivation(activeUser.userid,activePatient.personid);
        
        UserProfileMotivation uObjMot = new UserProfileMotivation();
        uObjMot.setUserid(Integer.parseInt(activeUser.userid));
        uObjMot.setPatientid(Integer.parseInt(activePatient.personid));
        uObjMot.setUpdatetime(getSQLTime());
        uObjMot.setMotivation("empty");
        uObjMot.setScreenid(sScreenID.toLowerCase());
        uObjMot.insert();
%>
<html>
<head>
    <title>OpenClinic <%=sAPPTITLE%> <%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_PV_MOTIVATION",sWebLanguage)%></title>
    <%=sCSSNORMAL%>
</head>
<body>
    <form name="MotivationForm" method="post" action="<c:url value='/includes/userMotivation.jsp'/>?SaveMotivation=ok&ts=<%=getTs()%>">
    <center>
    <br>
    <table border="0" cellpadding="5" cellspacing="0" class="list">
        <tr class="admin">
            <td><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_PV_MOTIVATION",sWebLanguage)%></td>
            <td><input type="text" class="text" name="EditMotivation" size="50" value="<%=sMotivation%>"></td>
        </tr>
        <tr>
            <td colspan="2" align="right" class="menu">
                <input type="submit" name="SaveMotivation" class="button" value="<%=getTran("Web","Save",sWebLanguage)%>">
            </td>
        </tr>
    </table>
    </center>
    <input type="hidden" name="ScreenID" value="<%=sScreenID%>">
    <script>
      window.focus();
      MotivationForm.EditMotivation.focus();
    </script>
    </form>
</body>
</html>
<%
}
%>