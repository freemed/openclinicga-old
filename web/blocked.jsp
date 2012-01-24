<%@include file="/includes/helper.jsp"%>
<html>
<head>
     <%=sCSSNORMAL%>
    <%=sJSCOOKIE%>
    <%=sJSDROPDOWNMENU%>
    <%=sIcon%>
    <script>
      function escBackSpaceAndRefresh(){
        if(window.event && (enterEvent(event,8) ||enterEvent(event,116))){
          window.event.keyCode = 123; // F12
        }
      }

      function closeWindow() {
        window.opener = null;
        window.close();
      }

      function unBlockAccount(){
        window.location.href = "<%=sCONTEXTPATH%>/unBlockAccount.jsp";
      }
    </script>

    <%
        // title
        String sTmpAPPDIR   = ScreenHelper.getCookie("activeProjectDir",request);
        String sTmpAPPTITLE = ScreenHelper.getCookie("activeProjectTitle",request);

        if(sTmpAPPTITLE==null) sTmpAPPTITLE = "OpenClinic";
    %>
	<title><%=sWEBTITLE+" "+sTmpAPPTITLE%></title>
</head>
<body class="Geenscroll login" onkeydown="escBackSpaceAndRefresh();if(enterEvent(event,13)){goToLogin();}" >
<div id="login" class="withoutfields">
  <div id="logo">
       <% if ("datacenter".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))) {
            session.setAttribute("edition", "datacenter");%>
        <img src="projects/datacenter/_img/logo.jpg" border="0">
        <% } else if ("openlab".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))) {
            session.setAttribute("edition", "openlab");%>
        <img src="projects/openlab/_img/logo.jpg" border="0">
        <% } else if ("openpharmacy".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("edition",""))) {
            session.setAttribute("edition", "openlab");%>
        <img src="_img/openpharmacy_logo.jpg" border="0">
        <% } else {
            session.setAttribute("edition", "openclinic");%>
        <img src="<%=sTmpAPPDIR%>_img/logo.jpg" border="0">
        <% }%>
      </div>
    <div id="version">
        &nbsp;
    </div>
    <div id="fields" >
        <table width="170" cellspacing="0" cellpadding="0" align="left" >
                            <tr>
                                <td >Accesss denied&nbsp;</td>
                            </tr>
                            <tr>

                                <td >
                                <%
                                    String sDuration = checkString(request.getParameter("duration"));

                                    if(sDuration.length() > 0){
                                        %>Access denied<%
                                        if(sDuration.equals("0")){ %> permanently<% }
                                        else{
                                            %> for <%
                                            int mins  = Integer.parseInt(sDuration);

                                            int days  = mins/1440;
                                            mins = mins%1440;
                                            if(days > 0){ %><%=days%> day(s)<% }

                                            int hours = mins/60;
                                            mins = mins%60;
                                            if(hours > 0){
                                              if(days > 0){ %> and<% }
                                              %><%=hours%> hour(s)<%
                                            }

                                            if(mins > 0){
                                              if(hours > 0){ %> and<% }
                                              %><%=mins%> minute(s)<%
                                            }
                                        }
                                    }
                                    else{
                                        %>Your IP is blocked<%
                                    }
                                %>.<br>Please contact your system administrator.
                                    <br><br>
                                    <a href="javascript:unBlockAccount();" onMouseOver="window.status='';return true;">unblock account</a><br>
                                    <a href="javascript:closeWindow();" onMouseOver="window.status='';return true;">close window</a>
                               </td>
                           </tr>
                        </table>
                </div>
           <div id="messages" class="messagesnofields">
            <img src="_img/rwandaflag.jpg" height="15px" width="30px" alt="Rwanda"/> Copyright:&nbsp;<a href="http://mxs.rwandamed.org" target="_new"><b>MXS Central Africa SARL</b></a> - PO Box 3242 - Kigali Rwanda - Tel +250 084 32 435 - <a href="mailto:mxs@rwandamed.org">mxs@rwandamed.org</a>
       </div>
    </div>

</body>
</html>