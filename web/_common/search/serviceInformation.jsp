<%@ page import="java.util.Vector" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<table width="100%" class="list" cellspacing="1" id="tblInformation">
    <%
        String sServiceID = checkString(request.getParameter("ServiceID")).toUpperCase();

        if (sServiceID.length() > 0) {
            Service service = Service.getService(sServiceID);

            if (service != null) {
                // translate country code
                String sCountry = service.country;
                if (sCountry.length() > 0) {
                    sCountry = getTran("Country", sCountry, sWebLanguage);
                }

                // header with service ans its parents
                String sServiceLabel = getTran("Service", sServiceID, sWebLanguage);
                Vector serviceParents = Service.getParentIds(sServiceID);
                String sParentServiceID;
                String arrow = "<img src='" + sCONTEXTPATH + "/_img/pijl.gif'/>&nbsp;";
                for (int i = serviceParents.size() - 1; i >= 0; i--) {
                    sParentServiceID = (String) serviceParents.get(i);
                    sServiceLabel = getTran("Service", sParentServiceID, sWebLanguage) + "&nbsp;" + arrow + sServiceLabel;
                }

    %>
    <tr class='admin'>
        <td colspan='2'>&nbsp;<%=sServiceLabel%>
        </td>
    </tr>
    <%

        out.print(setRow("Web", "Address", checkString(service.address), sWebLanguage) +
                setRow("Web", "zipcode", checkString(service.zipcode), sWebLanguage) +
                setRow("Web", "city", checkString(service.city), sWebLanguage) +
                setRow("Web", "country", sCountry, sWebLanguage) +
                setRow("Web", "telephone", checkString(service.telephone), sWebLanguage) +
                setRow("Web", "fax", checkString(service.fax), sWebLanguage) +
                setRow("Web", "contract", checkString(service.contract), sWebLanguage) +
                setRow("Web", "contracttype", checkString(service.contracttype), sWebLanguage) +
                setRow("Web", "contactperson", checkString(service.contactperson), sWebLanguage) +
                setRow("Web", "comment", checkString(service.comment), sWebLanguage));

    %>
    <tr height="1">
        <td width="30%"></td>
    </tr>
    <%
            }
        }
    %>
</table>

<br>

<%-- BUTTON --%>
<center>
    <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>'
           onclick='window.close()'>
</center>

<script>
    window.resizeTo(550, ((parseInt(document.getElementsByName('tblInformation')[0].rows.length) - 1) * 27) + 100);
</script>
