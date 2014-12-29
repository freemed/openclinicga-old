<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    if(activePatient!=null && activePatient.personid.length()>0){
        AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);
        String sCountry = "&nbsp;";
        if (checkString(apc.country).trim().length()>0) {
            sCountry = getTran("Country",apc.country,sWebLanguage);
        }

        String sProvince = "&nbsp;";
        if (checkString(apc.province).trim().length()>0) {
            sProvince = getTran("province",apc.province,sWebLanguage);
        }

        if (apc!=null){
            %>
                <table width="100%" cellspacing="1" class="list">
                    <%=		setRow("Web.admin","addresschangesince",apc.begin,sWebLanguage)+
        		            setRow("Web","country",sCountry,sWebLanguage)+
        		            setRow("Web","district",apc.district,sWebLanguage)+
        		            setRow("Web","county",apc.city,sWebLanguage)+
        		            setRow("Web","zipcode",apc.zipcode,sWebLanguage)+
        		            setRow("Web","sector",apc.sector,sWebLanguage)+
        		            setRow("Web","cell",apc.cell,sWebLanguage)+
        		            setRow("Web","address",apc.address,sWebLanguage)+
        		            setRow("Web","email",apc.email,sWebLanguage)+
        		            setRow("Web","telephone",apc.telephone,sWebLanguage)+
        		            setRow("Web","mobile",apc.mobile,sWebLanguage)+
        		            setRow("Web","function",apc.businessfunction,sWebLanguage)+
        		            setRow("Web","business",apc.business,sWebLanguage)+
        		            setRow("Web","comment",apc.comment,sWebLanguage)
					%>
                    <tr height='1'><td width='<%=sTDAdminWidth%>'/></tr>
                </table>
            <%
        }
    }
%>
<%-- BUTTONS -------------------------------------------------------------------------------------%>
<%
    String sShowButton = checkString(request.getParameter("ShowButton"));
    if(!sShowButton.equals("false")){
        %>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" value="<%=getTran("Web","history",sWebLanguage)%>" name="ButtonHistoryPrivate" onclick="parent.location='patienthistory.do?ts=<%=getTs()%>&contacttype=private'">&nbsp;
                <%
                    if (activeUser.getAccessRight("patient.administration.edit")){
                        %>
                            <input type="button" class="button" onclick="window.location.href='<c:url value="/patientedit.do"/>?Tab=AdminPrivate&ts=<%=getTs()%>'" value="<%=getTran("Web","edit",sWebLanguage)%>">
                        <%
                    }
                %>
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>