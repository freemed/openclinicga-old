<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<html>
<head>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sCSSNORMAL%>
    <%=sJSPROTOTYPE %>
    <%=sJSAXMAKER %>
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
<% 
	if(request.getParameter("logout")!=null){
		session.removeAttribute("datacenteruser");
	}
	if(request.getParameter("username")!=null && request.getParameter("password")!=null){
		if(MedwanQuery.getInstance().getConfigString("datacenterUserPassword."+request.getParameter("username"),"plmouidgsjejn,fjfk").equalsIgnoreCase(request.getParameter("password"))){
			session.setAttribute("datacenteruser",request.getParameter("username"));
		}
		activeUser.person.language=MedwanQuery.getInstance().getConfigString("datacenterUserLanguage."+request.getParameter("username"),"FR");
        session.setAttribute(sAPPTITLE + "WebLanguage", activeUser.person.language);
	}
	if(session.getAttribute("datacenteruser")==null){
%>
	<table width="100%">
		<tr>
			<td width="1%"><img height="150px" src="<c:url value="/_img/ghb.png"/>"/></td>
			<td>
				<form name="transactionForm" method="post" action="datacenterHome.jsp"/>
					<input type="text" name="username" class="text"/><br/>
					<input type="password" name="password" class="text"/><br/>
					<input type="submit" name="submit" value="login" class="button"/>
				</form>
			</td>
		</tr>
	</table>
	
<%
	}
	else {
	
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
							<td align="right"><a href="javascript:logout();"><%=getTran("web","logout",sWebLanguage) %></a></td>
						</tr>
                        <tr>
                            <td valign="top" class="white">
                                <%ScreenHelper.setIncludePage("/datacenter/projectoverview.jsp&servergroups="+MedwanQuery.getInstance().getConfigString("datacenterUserServerGroups."+session.getAttribute("datacenteruser")),pageContext);%>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>

    <%=sJSJUIST%>

    <script>
	    function keepAlive(){
	        var r="";
	        var today = new Date();
	        var url= '<c:url value="/util/keepAlive.jsp"/>?ts='+today;
	        new Ajax.Request(url,{
	                method: "GET",
	                parameters: "",
	                onSuccess: function(resp){
	                },
	                onFailure: function(){
	                }
	            }
	        );
	    }

	  window.setInterval("keepAlive()",30000);
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

      function logout(){
  		window.location.href="<c:url value="/datacenter/datacenterHome.jsp?logout=true"/>";
      }

      
    </script>

    <%=ScreenHelper.getDefaults(request)%>
    
    
</body>

<%
	}
%>
</html>