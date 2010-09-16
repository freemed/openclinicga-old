<%@ page import="be.openclinic.finance.Insurar, java.util.Vector,be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindInsurarUid = checkString(request.getParameter("FindInsurarUid")),
            sFindInsurarName = checkString(request.getParameter("FindInsurarName")),
            sFindInsurarContact = checkString(request.getParameter("FindInsurarContact"));
    String sFunction = checkString(request.getParameter("doFunction"));
    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldInsurarUid")),
            sReturnFieldName = checkString(request.getParameter("ReturnFieldInsurarName")),
            sReturnFieldContact = checkString(request.getParameter("ReturnFieldInsurarContact"));
    if (sAction.length() == 0 && sFindInsurarName.length() > 0) sAction = "search"; // default

    // DEBUG //////////////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n### searchInsurar #############################");
        System.out.println("# sAction             : " + sAction);
        System.out.println("# sFindInsurarUid     : " + sFindInsurarUid);
        System.out.println("# sFindInsurarName    : " + sFindInsurarName);
        System.out.println("# sFindInsurarContact : " + sFindInsurarContact + "\n");
        System.out.println("# sReturnFieldUid     : " + sReturnFieldUid);
        System.out.println("# sReturnFieldName    : " + sReturnFieldName);
        System.out.println("# sReturnFieldContact : " + sReturnFieldContact + "\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    String msg = "";
%>

<%
    //--- SHOW FOUND INSURARS -----------------------------------------------------------------
    if (sAction.equals("search")) {
        Vector foundInsurars = Insurar.getInsurarsByName(sFindInsurarName);
        int insurarCount = 0;

        if (foundInsurars.size() > 0) {
%>
<br>
<%-- SEARCH RESULTS TABLE --%>
<table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable"
       style="border:1px solid #cccccc;">
    <%-- header --%>
    <tr class="admin">
        <td width="200"><%=HTMLEntities.htmlentities(getTran("system.manage", "insurarName", sWebLanguage))%>
        </td>
        <td width="*"><%=HTMLEntities.htmlentities(getTran("system.manage", "insurarContact", sWebLanguage))%>
        </td>
    </tr>
    <tbody>
        <%
            String sClass = "1", sContact;
            Insurar insurar;
            for (int i = 0; i < foundInsurars.size(); i++) {
                insurar = (Insurar) foundInsurars.get(i);
                if ("true".equalsIgnoreCase(request.getParameter("excludePatientSelfInsurarUID")) && insurar.getUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("patientSelfInsurarUID", "none"))) {
                    continue;
                }
                insurarCount++;

                sContact = checkString(insurar.getContact());
                //sContact = sContact.replaceAll("\r\n","<br>");

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

        %>
        <tr class="list<%=sClass%>" onmouseover="this.className='list_select';this.style.cursor='hand';"
            onmouseout="this.className='list<%=sClass%>';this.style.cursor='default';">
            <td onClick="selectInsurar('<%=insurar.getUid()%>','<%=HTMLEntities.htmlentities(insurar.getName())%>');"><%=
                HTMLEntities.htmlentities(checkString(insurar.getName()))%>
            </td>
            <td onClick="selectInsurar('<%=insurar.getUid()%>','<%=HTMLEntities.htmlentities(insurar.getName())%>');"><%=
                HTMLEntities.htmlentities(sContact)%>
            </td>
        </tr>
        <%
            }
        %>
    </tbody>
</table>
<%
    }

    // number of found records
    if (insurarCount > 0) {
%><%=insurarCount%> <%=HTMLEntities.htmlentities(getTran("web", "recordsFound", sWebLanguage))%><%
} else {
%><br><%=HTMLEntities.htmlentities(getTran("web", "noRecordsFound", sWebLanguage))%><%
    }

    // display message
    if (msg.length() > 0) {
%><br><%=HTMLEntities.htmlentities(msg)%><br><%
        }
    }
%>
 