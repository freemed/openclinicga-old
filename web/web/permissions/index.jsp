<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    out.print(
        ScreenHelper.writeTblHeader(getTran("Web","Permissions",sWebLanguage),sCONTEXTPATH)
        +writeTblChild("main.do?Page=permissions/profiles.jsp",getTran("Web.UserProfile","UserProfile",sWebLanguage))
        +writeTblChild("main.do?Page=permissions/searchProfile.jsp",getTran("Web.UserProfile","usersPerProfile",sWebLanguage))
    );

    if ((activePatient!=null)&&(activePatient.lastname!=null)&&(activePatient.lastname.trim().length()>0)) {
        out.print(
            writeTblChild("main.do?Page=permissions/userpermission.jsp"
                ,getTran("Web.Permissions","PermissionsFor",sWebLanguage)+" "+activePatient.lastname+" "+activePatient.firstname)
        );
    }

    out.print(ScreenHelper.writeTblFooter());
%>