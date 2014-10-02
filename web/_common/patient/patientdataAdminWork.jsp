<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    if(activePatient!=null && activePatient.personid.length()>0){
        AdminWorkContact awc = ScreenHelper.getActiveWork(activePatient);

        if(awc!=null){
            %>
                <table width="100%" cellspacing="1" class="list" style="border-top:none;">
                    <%=ScreenHelper.setAdminWorkContact(awc, sWebLanguage,sCONTEXTPATH,sTDAdminWidth)%>                    
            <%
        }
    }
%>

<%-- BUTTONS ------------------------------------------------------------------------------------%>
<%
    String sShowButton = checkString(request.getParameter("ShowButton"));
    if(!sShowButton.equals("false")){
        %>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" value="<%=getTranNoLink("Web","history",sWebLanguage)%>" name="ButtonHistoryWork" onclick="parent.location='patienthistory.do?ts=<%=getTs()%>&contacttype=work'">&nbsp;
                <%
                    if (activeUser.accessRights.get("administration.edit")!=null){
                        %><input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminWork&ts=<%=getTs()%>'" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>"><%
                    }
                %>
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>
