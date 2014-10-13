<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    out.print(ScreenHelper.writeTblHeader(getTran("Web","Permissions",sWebLanguage),sCONTEXTPATH));
    int rowIdx = 0;

    out.print(
        writeTblChild("main.do?Page=permissions/profiles.jsp",getTran("Web.UserProfile","UserProfile",sWebLanguage),rowIdx++)+
        writeTblChild("main.do?Page=permissions/searchProfile.jsp",getTran("Web.UserProfile","usersPerProfile",sWebLanguage),rowIdx++)
    );

    if(activePatient!=null && activePatient.lastname!=null && activePatient.lastname.trim().length()>0){
        out.print(
            writeTblChild("main.do?Page=permissions/userpermission.jsp",getTran("Web.Permissions","PermissionsFor",sWebLanguage)+" "+activePatient.lastname+" "+activePatient.firstname,rowIdx++)
        );
    }

    out.print(ScreenHelper.writeTblFooter());
%>