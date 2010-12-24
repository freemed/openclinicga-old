<%@ page import="be.openclinic.adt.Encounter" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sPatientUid;
    if (activePatient != null) {
        sPatientUid = checkString(activePatient.personid);
    } else {
        sPatientUid = "";
    }

    if (sPatientUid.length() > 0) {
        Encounter lastAdmissionEncounter = Encounter.getInactiveEncounterBefore(sPatientUid, "admission", new java.util.Date());
        Encounter lastVisitEncounter = Encounter.getInactiveEncounterBefore(sPatientUid, "visit", new java.util.Date());

        java.util.Date dLastAdmission = null;
        if (lastAdmissionEncounter != null) {
            dLastAdmission = lastAdmissionEncounter.getBegin();
        }
        java.util.Date dLastVisit = null;
        if (lastVisitEncounter != null) {
            dLastVisit = lastVisitEncounter.getBegin();
        }

        Encounter activeEncounter = Encounter.getActiveEncounter(sPatientUid);
%>
<table width="100%" class="list">
    <tr>
        <td>
            <table width="100%" class='list' cellspacing="0" border="0">
                <tr class="admin">
                    <td width="200">
                        <%=getTran("curative","encounter.status.title",sWebLanguage)%>&nbsp;
                        <a href="<c:url value='/main.do'/>?Page=adt/historyEncounter.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/icon_history2.gif'/>" class="link" alt="<%=getTran("web","historyencounters",sWebLanguage)%>" style="vertical-align:-4px;"></a>
                        <a href="javascript:newEncounter();"><img src="<c:url value='/_img/icon_new.gif'/>" class="link" alt="<%=getTran("web","newencounter",sWebLanguage)%>" style="vertical-align:-4px;"></a>
                    </td>
                    <td width="250"><i><%=getTran("curative","encounter.last.hospitalisation",sWebLanguage)%>:
                        <%
                            if(dLastAdmission != null){
                                out.print("<a href='javascript:goRead(\""+lastAdmissionEncounter.getUid()+"\");'>"+new SimpleDateFormat("dd/MM/yyyy").format(dLastAdmission)+"</a>");
                            }
                        %></i>
                    </td>
                    <td><i><%=getTran("curative","encounter.last.visit",sWebLanguage)%>:
                        <%
                            if(dLastVisit != null){
                                out.print("<a href='javascript:goRead(\""+lastVisitEncounter.getUid()+"\");'>"+new SimpleDateFormat("dd/MM/yyyy").format(dLastVisit)+"</a>");
                            }
                        %></i>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%
        if(activeEncounter != null){
    %>
    <tr>
        <td>
            <table width='100%' cellspacing='0' cellpadding="0" class='list'>
                <tr class='admin'>
                    <td width="200">
                        <%=getTran("web","id",sWebLanguage)%>
                    </td>
                    <td width="200"><%=getTran("web","type",sWebLanguage)%></td>
                    <td width="100"><%=getTran("web","begindate",sWebLanguage)%></td>
                    <td><%=getTran("web","service",sWebLanguage)%></td>
                    <%
                        if(!checkString(activeEncounter.getType()).equalsIgnoreCase("visit")){
                    %>
                        <td width="100"><%=getTran("web","bed",sWebLanguage)%></td>
                    <%
                        }
                    %>
                    <td><%=getTran("web","manager",sWebLanguage)%></td>
                </tr>
                <tr class='list' onmouseover="this.style.cursor='hand';this.className='list_select';"
                                 onmouseout="this.style.cursor='default';this.className='list';"
                                 onclick="goEdit('<%=activeEncounter.getUid()%>');">
                    <td>
                        <b><%=checkString(activeEncounter.getUid())%></b>
                        <%
                            if(activeEncounter.getDurationInDays()>Encounter.getAccountedAccomodationDays(activeEncounter.getUid())){
                                %>
                                    <img class="link" src="<c:url value='/_img/money.gif'/>"/>
                                <%
                            }
                        %>
                    </td>
                    <td>
                        <img src="<c:url value='/_img/icon_edit.gif'/>" class="link" alt="<%=getTran("web","edit",sWebLanguage)%>" onclick="goEdit('<%=activeEncounter.getUid()%>');">
                        <b><%=getTran("web",checkString(activeEncounter.getType()),sWebLanguage)%></b>
                    </td>
                    <td>
                    <%
                        if(activeEncounter.getBegin() != null){
                            out.print(new SimpleDateFormat("dd/MM/yyyy").format(activeEncounter.getBegin()));
                        }
                    %>
                    </td>
                    <%
                        String sService = "";

                        if (activeEncounter.getService()!=null){
                            sService = activeEncounter.getService().code+" "+getTran("Service",activeEncounter.getService().code,sWebLanguage);
                        }
                    %>
                    <td><b><%=sService%></b>
                        <%
                        if(!checkString(activeEncounter.getType()).equalsIgnoreCase("visit")){
                        %>
                        </td><td>
                        <%
                            if(activeEncounter.getBed()!=null){
                                out.print(activeEncounter.getBed().getName());
                            }
                        %>
                    </td>
                    <%
                        }
                    %>
                    <td>
                    <%
                        User manager = activeEncounter.getManager();

                        if((manager!=null)&&(manager.userid != null) && (manager.userid.length() > 0)){
                            Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                            out.print(ScreenHelper.getFullUserName(manager.userid,ad_conn));//MedwanQuery.getInstance().getUser(sArts).getPersonVO().personId+"",dbConnection));
                            ad_conn.close();
                        }
                    %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%
        }
    %>
</table>

<script>

    function goEdit(EncounterUid){
        window.location.href="<c:url value='/main.do'/>?Page=adt/editEncounter.jsp&EditEncounterUID=" + EncounterUid + "&ts=<%=getTs()%>";
    }

    function goRead(EncounterUid){
        openPopup("adt/editEncounter.jsp&ReadOnly=yes&Popup=yes&EditEncounterUID=" + EncounterUid + "&ts=<%=getTs()%>",800);
    }

</script>
<%
    }else{
        out.print(getTran("web","nopatientselected",sWebLanguage));
    }
    Debug.println("encounter stop");
%>
