<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%-- MAIN TABLE ----------------------------------------------------------------------------------%>
<table width='100%' cellspacing="1" class="list">
    <%=(
            setRow("web","fathername",checkString((String)activePatient.adminextends.get("fathername")),sWebLanguage)
            +setRow("web","fatherprofession",checkString((String)activePatient.adminextends.get("fatherprofession")),sWebLanguage)
            +setRow("web","fatheremployer",checkString((String)activePatient.adminextends.get("fatheremployer")),sWebLanguage)
            +setRow("web","mothername",checkString((String)activePatient.adminextends.get("mothername")),sWebLanguage)
            +setRow("web","motherprofession",checkString((String)activePatient.adminextends.get("motherprofession")),sWebLanguage)
            +setRow("web","motheremployer",checkString((String)activePatient.adminextends.get("motheremployer")),sWebLanguage)
            +setRow("web","spousename",checkString((String)activePatient.adminextends.get("spousename")),sWebLanguage)
            +setRow("web","spouseprofession",checkString((String)activePatient.adminextends.get("spouseprofession")),sWebLanguage)
            +setRow("web","spouseemployer",checkString((String)activePatient.adminextends.get("spouseemployer")),sWebLanguage)
        )
    %>
    <tr height='1'><td width='<%=sTDAdminWidth%>'/></tr>
</table>
