<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<html>
<head>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sCSSNORMAL%>
</head>

<%
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server
%>

<%
    if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
        %>
            <script>
              if(window.history.forward(1) != null){
                window.history.forward(1);
              }
            </script>
        <%
    }
%>

<body>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="list" height="100%">
        <%-- CONTENT --%>
        <tr>
            <td  valign="top" class="white" height="100%">
                <div class="content" id="Juist">
                    <a name='topp'></a>
                    <table width="100%" border="0" id="mijn">
                        <tr>
                            <td valign="top" class="white">
                                <%ScreenHelper.setIncludePage("/healthrecord/content.jsp",pageContext);%>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>

    <%=sJSJUIST%>

    <script>
      resizeAllTextareas(10);

      <%
          if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
              %>
                if(window.history.forward(1) != null){
                  window.history.forward(1);
                }
              <%
          }
      %>
    </script>

    <%=ScreenHelper.getDefaults(request)%>
</body>
</html>