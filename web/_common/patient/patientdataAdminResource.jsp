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

        String sGroup = "&nbsp;";
        if (checkString((String)activePatient.adminextends.get("usergroup")).length()>0) {
            sGroup = getTran("usergroup",checkString((String)activePatient.adminextends.get("usergroup")),sWebLanguage);
        }

        %>
        <table width="100%" cellspacing="1" class="list" style="border-top:none;">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("admin","category",sWebLanguage)%></td>
                <td class="admin2"><%=sCategory%></td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("admin","statut",sWebLanguage)%></td>
                <td class="admin2"><%=sStatut%></td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("admin","group",sWebLanguage)%></td>
                <td class="admin2"><%=sGroup%></td>
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
                <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminResource&ts=<%=getTs()%>'" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
                <%
            }
        %>
        <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>