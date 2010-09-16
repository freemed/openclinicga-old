<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sType = checkString(request.getParameter("contacttype"));

    if (activePatient != null && sType.length() > 0) {
        String sID;
        boolean bFound;
        int iTotal = 0;

        //--- ADMIN PRIVATE -----------------------------------------------------------------------
        if (sType.equalsIgnoreCase("private")) {
            AdminPrivateContact apc;
            Vector vResults = AdminPerson.getPrivateId(activePatient.personid);
            Iterator iter = vResults.iterator();

            while (iter.hasNext()) {
                bFound = false;
                sID = (String) iter.next();

                for (int i = 0; (i < activePatient.privateContacts.size()) && (!bFound); i++) {
                    apc = ((AdminPrivateContact) activePatient.privateContacts.elementAt(i));
                    if (apc.privateid.equals(sID)) {
                        bFound = true;
%>
                            <table border=0 width='100%' align='center' class='list' cellspacing='0'>
                                <tr class='admin'>
                                    <td width='1%'>
                                        <img id="Apc<%=apc.privateid%>S" src="<c:url value='/_img/plus.png'/>" onclick="showD('Apc<%=apc.privateid%>','Apc<%=apc.privateid%>S','Apc<%=apc.privateid%>H');" style="display:none">
                                        <img id="Apc<%=apc.privateid%>H" src="<c:url value='/_img/minus.png'/>" onclick="hideD('Apc<%=apc.privateid%>','Apc<%=apc.privateid%>S','Apc<%=apc.privateid%>H');">
                                    </td>
                                    <td><%=getTran("Web","private",sWebLanguage)%></td>
                                    <td align='right'>&nbsp;
                                        <a href="<c:url value='/patientdata.do'/>?ts=<%=getTs()%>"><img src="<c:url value='/_img/arrow.jpg'/>" border='0' alt="<%=getTran("Web","back",sWebLanguage)%>"></a>&nbsp;
                                        <a href='#topp' class='topbutton'>&nbsp;</a>
                                    </td>
                                </tr>
                                <tr id='Apc<%=apc.privateid%>'>
                                    <td colspan='3'>
                                        <table cellspacing='1' width='100%'>
                                            <%=ScreenHelper.setAdminPrivateContact(apc,sWebLanguage)%>
                                            <tr height='1'><td width='<%=sTDAdminWidth%>'></td></tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <br>
                        <%

                        //-- buttons --
                        if (iTotal==0) {
                            %>
                                <%=ScreenHelper.alignButtonsStart()%>
                                    <%
                                        if (activeUser.getAccessRight("patient.administration.edit")){
                                            %>
                                            <input type="button" class="button" name="ButtonEdit" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="parent.location='patientedit.do?ts=<%=getTs()%>'">
                                            <%
                                        }
                                    %>
                                    <input type="button" class="button" name="ButtonBack" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="parent.location='patientdata.do?ts=<%=getTs()%>'">
                                <%=ScreenHelper.alignButtonsStop()%>
                            <%
                        }

                        iTotal++;
                    }
                }
            }
        }
    }
%>
