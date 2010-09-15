<%@ page import="java.util.Vector,
                 java.util.Hashtable,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sFindLastname = checkString(request.getParameter("FindLastname")),
           sFindFirstname = checkString(request.getParameter("FindFirstname")),
           sFindDOB = checkString(request.getParameter("FindDOB")),
           sFindGender = checkString(request.getParameter("FindGender")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID"));

    if (sReturnPersonID.length() == 0) {
        sReturnPersonID = checkString(request.getParameter("ReturnField"));
    }

    boolean bIsUser = checkString(request.getParameter("isUser")).equalsIgnoreCase("yes");
    boolean displayImmatNew = !checkString(request.getParameter("displayImmatNew")).equalsIgnoreCase("no");

    String sSelectLastname = ScreenHelper.normalizeSpecialCharacters(sFindLastname),
            sSelectFirstname = ScreenHelper.normalizeSpecialCharacters(sFindFirstname);
%>
<table width="100%" cellspacing="0" cellpadding="0">
    <%
        Vector vPersons = AdminPerson.searchPatients(sSelectLastname, sSelectFirstname, sFindGender, sFindDOB, bIsUser);
        Iterator personIter = vPersons.iterator();

        Hashtable hPersonInfo;
        if ((sSelectLastname.length() > 0 || sSelectFirstname.length() > 0 || sFindGender.length() > 0 || sFindDOB.length() > 0) || bIsUser) {
            String sClass = "", sLastname, sFirstname;
            boolean recsFound = false;
            StringBuffer results = new StringBuffer();

            while (personIter.hasNext()) {
                hPersonInfo = (Hashtable) personIter.next();
                recsFound = true;

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                // names
                sLastname = (String) hPersonInfo.get("lastname");
                sFirstname = (String) hPersonInfo.get("firstname");
                if (displayImmatNew) {
                    sFirstname += " " + hPersonInfo.get("immatnew");
                }
                sLastname = sLastname.replace('\'', '´');
                sFirstname = sFirstname.replace('\'', '´');

                // one row
                if (bIsUser) {
                    results.append("<tr class='list" + sClass + "' onclick=\"setPerson(" + hPersonInfo.get("userid") + ", '" + sLastname + " " + sFirstname + "');\">")
                            .append(" <td>" + sLastname + " " + sFirstname + " (" + hPersonInfo.get("userid") + ")</td>")
                            .append(" <td>" + ((String) hPersonInfo.get("gender")).toUpperCase() + "</td>")
                            .append(" <td colspan='2'>" + hPersonInfo.get("dateofbirth") + "</td>")
                            .append("</tr>");
                } else {
                    results.append("<tr class='list" + sClass + "' onclick=\"setPerson(" + hPersonInfo.get("personid") + ", '" + sLastname + " " + sFirstname + "');\">")
                            .append(" <td>" + sLastname + " " + sFirstname + "</td>")
                            .append(" <td>" + ((String) hPersonInfo.get("gender")).toUpperCase() + "</td>")
                            .append(" <td colspan='2'>" + hPersonInfo.get("dateofbirth") + "</td>")
                            .append("</tr>");
                }

            }
            if (recsFound) {
    %>
    <%-- header --%>
    <tr class="admin">
        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web", "name", sWebLanguage))%></td>
        <td width="50" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "gender", sWebLanguage))%></td>
        <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "dateofbirth", sWebLanguage))%></td>
    </tr>

    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=HTMLEntities.htmlentities(results.toString())%>
    </tbody>
    <%
    } else {
        // display 'no results' message
    %>
    <tr>
        <td colspan="3">
            <%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><br>
            <a href="#" onclick="addPerson()"><%=HTMLEntities.htmlentities(getTranNoLink("web", "add.this.person", sWebLanguage))%></a>
        </td>
    </tr>
    <%
            }
        }
    %>
</table>