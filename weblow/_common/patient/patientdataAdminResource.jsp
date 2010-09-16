<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    if(activePatient!=null && activePatient.personid.length()>0){

        String sCategory = "&nbsp;";
        if (checkString((String)activePatient.adminextends.get("category")).length()>0) {
            sCategory = getTran("admin.category",checkString((String)activePatient.adminextends.get("category")),sWebLanguage);
        }

        String sStatut = "&nbsp;";
        if (checkString((String)activePatient.adminextends.get("statut")).length()>0) {
            sStatut = getTran("admin.statut",checkString((String)activePatient.adminextends.get("statut")),sWebLanguage);
        }

        %>
        <table width="100%" cellspacing="1" class="list">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("admin","category",sWebLanguage)%></td>
                <td class="admin2"><%=sCategory%></td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("admin","statut",sWebLanguage)%></td>
                <td class="admin2"><%=sStatut%></td>
            </tr>
        </table>
        <%
    }

    String sShowButton = checkString(request.getParameter("ShowButton"));
    if(!sShowButton.equals("false")){
        %>
        <%=ScreenHelper.alignButtonsStart()%>
        <%
            if (activeUser.getAccessRight("patient.administration.edit")){
                %>
                <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminResource&ts=<%=getTs()%>'" value="<%=getTran("Web","edit",sWebLanguage)%>">
                <%
            }
        %>
        <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>