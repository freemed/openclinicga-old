<%@ page import="be.openclinic.adt.Bed,
be.openclinic.adt.Encounter,
java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindEncounterPatient = checkString(request.getParameter("FindEncounterPatient"));
    String sFindEncounterManager = checkString(request.getParameter("FindEncounterManager"));
    String sFindEncounterService = checkString(request.getParameter("FindEncounterService"));
    String sFindEncounterBed = checkString(request.getParameter("FindEncounterBed"));

    String sVarCode  = checkString(request.getParameter("VarCode"));
    String sVarText  = checkString(request.getParameter("VarText"));
    String sVarFunction  = checkString(request.getParameter("VarFunction"));

    String sSelectEncounterPatient = ScreenHelper.normalizeSpecialCharacters(sFindEncounterPatient);
    String sSelectEncounterManager = ScreenHelper.normalizeSpecialCharacters(sFindEncounterManager);
    String sSelectEncounterService = ScreenHelper.normalizeSpecialCharacters(sFindEncounterService);
    String sSelectEncounterBed     = ScreenHelper.normalizeSpecialCharacters(sFindEncounterBed);
%>
<script type="text/javascript">
    <%-- SET encounter --%>
    function setEncounter(sEncounterUID,sEncounterName) {
      window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sEncounterUID;

        if ('<%=sVarText%>'!=''){
            window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sEncounterName;
        }

        <%
            if(sVarFunction.length()>0){
        %>
            window.opener.<%=sVarFunction%>;
        <%
        }
        %>

      window.close();
    }

</script>
    <form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
            <%-- SEARCH RESULTS TABLE --%>
        <table>
            <tr>
                <td valign="top" colspan="3" align="center" class="white" width="100%">
                    <div class="search" style="width:500">
                        <table border='0' width='100%' cellpadding="1" cellspacing="0">
                            <%
                                String sortColumn = "A.OC_ENCOUNTER_BEGINDATE DESC";

                                Vector vEncounters = Encounter.selectLastEncounters("", "", "", "", "", sSelectEncounterManager, sSelectEncounterService, sSelectEncounterBed, sSelectEncounterPatient, sortColumn);
                                Iterator iter = vEncounters.iterator();

                                Encounter eTmp;
                                boolean recsFound = false;
                                StringBuffer results = new StringBuffer();
                                String sClass = "";
                                String sType = "";
                                String sEnd = "";
                                String sStart = "";
                                String sTRClass = "";
                                String sTRSelectClass = "";
                                String sEncounterUID = "";
                                String sService = "";

                                while (iter.hasNext()) {

                                    eTmp = (Encounter) iter.next();
                                    recsFound = true;

                                    // alternate row-style
                                    if (sClass.equals("")) sClass = "1";
                                    else sClass = "";

                                    // names
                                    sEncounterUID = eTmp.getUid();
                                    Encounter e = Encounter.get(sEncounterUID);
                                    if(e.getEnd()==null){
                                        eTmp.setEnd(null);
                                    }

                                    if (eTmp.getType().length() > 0) {
                                        sType = getTran("encountertype", eTmp.getType(), sWebLanguage);
                                    }

                                    if (eTmp.getServiceUID().length() > 0) {
                                        sService = getTran("service", eTmp.getServiceUID(), sWebLanguage);
                                    }

                                    sStart = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getBegin());

                                    if (eTmp.getEnd() != null) {
                                    	sEnd = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getEnd());
                                    } else {
                                        sEnd = "";
                                    }

                                    if (sEnd.length() > 0) {
                                        sTRClass = "listText" + sClass;
                                        sTRSelectClass = "";
                                    } else {
                                        sTRClass = "listbold" + sClass;
                                        sTRSelectClass = "bold";
                                    }
                                    results.append("<tr class='" + sTRClass + "' " +
                                            " onmouseover=\"this.style.cursor='hand';\" " +
                                            " onmouseout=\"this.style.cursor='default';\" " +
                                            " onclick=\"setEncounter('" + sEncounterUID + "', '" + sService + ", " + sStart + " -> " + sEnd + ", " + sType + "');\">")
                                            .append(" <td>" + sEncounterUID + "</td>")
                                            .append(" <td>" + sStart + "</td>")
                                            .append(" <td>" + sEnd + "</td>")
                                            .append(" <td>" + sService + "</td>")
                                            .append(" <td>" + sType + "</td>")
                                            .append("</tr><tr height='1'/>");
                                }

                                if (recsFound) {
                            %>
                                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                            <tr class="admin">
                                                <td>ID</td>
                                                <td nowrap><%=getTran("Web","start",sWebLanguage)%></td>
                                                <td nowrap><%=getTran("Web","end",sWebLanguage)%></td>
                                                <td><%=getTran("Web","service",sWebLanguage)%></td>
                                                <td nowrap><%=getTran("Web.encounter","type",sWebLanguage)%></td>
                                            </tr>

                                            <%=results%>
                                        </tbody>
                                    <%
                                }
                                else{
                                    // display 'no results' message
                                    %>
                                        <tr>
                                            <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                        </tr>
                                    <%
                                }
                            %>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <br>

        <%-- CLOSE BUTTON --%>
        <center>
            <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
        </center>

        <script>
          window.resizeTo(480,455);

        </script>
    </form>
