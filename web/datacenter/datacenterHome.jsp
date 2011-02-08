<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<html>
<head>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%//=sCSSNORMAL%>
    <%=sJSPROTOTYPE %>
    <%=sJSAXMAKER %>
    <%=sJSPROTOCHART %>
    <!--[if IE]>
    <%=sJSEXCANVAS %>
    <![endif]-->
    <%=sJSAXMAKER %>
    <%=sJSSCRPTACULOUS %>
    <%=sJSMODALBOX%>
    <%=sCSSDATACENTER%>
    <%=sCSSMODALBOXDATACENTER%>
    <!--[if IE]>
    <%=sCSSDATACENTERIE%>
     <![endif]-->
</head>

<%
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server
%>

<%
    String sPage=checkString(request.getParameter("p"));
    if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
        %>
            <script>
              if(window.history.forward(1) != null){
               // window.history.forward(1);
              }
            </script>
        <%
    }
%>
<%!
    class Tester{
        int cinq = 5;
        public Tester(){

        }
    }
    public void test(Tester i){
        i.cinq--;
        
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

%>
<body>
        <div id="footer-wrap">
           <div id="footer-container">
                <div id="footer">
                    <div id="footer_logo">
                        <%
                            if(session.getAttribute("datacenteruser")!=null){
                        %>
                            <img height="40px;" src="<%=MedwanQuery.getInstance().getConfigString("datacenterUserLogo."+session.getAttribute("datacenteruser"))%>"/>
                        <%
                            }
                        %>

                        </div>
                        <div id="footer_info">developped by Mxs</div>
                </div>
            </div>
        </div>
        <div id="header-wrap">
            <div id="header-container">
                <div id="header">
                    <div id="logout"><a href="javascript:logout();" title="<%=getTranNoLink("web","logout",sWebLanguage) %>" <%=((session.getAttribute("datacenteruser")==null)?"style='display:none;'":"")%>>&nbsp;</a></div>
                </div>
            </div>
        </div>
        <div id="container">
            <div id="content">

                 <%
                     if(session.getAttribute("datacenteruser")!=null){
                        if(sPage.length()>0){
                            ScreenHelper.setIncludePage(sPage,pageContext);

                        }else{
                            ScreenHelper.setIncludePage("/datacenter/projectoverview.jsp&servergroups="+MedwanQuery.getInstance().getConfigString("datacenterUserServerGroups."+session.getAttribute("datacenteruser")),pageContext);
                        }
                       %>
                     <script type="text/javascript">
                        Event.observe(window, 'load', function() {
                          //  window.setInterval("keepAlive()",30000);
                        });
                     </script>
                      <%
                     }else{
                        %>
                <div class="container">
               
                    <div id="login">

                        <form name="transactionForm" id="transactionForm" onkeyup="entsub(event,'transactionForm')" method="post" action="datacenterHome.jsp" >
                            <table width="100%" class="content">
                                <tr ><td colspan="2"></td></tr>
                                <tr class="last">
                                    <td>Login</td>
                                    <td>
                                        <input type="text" name="username" class="text"/>
                                    </td>
                                </tr>
                                <tr class="last">
                                    <td>Password</td>
                                    <td>
                                        <input type="password" name="password" class="text"/><br/>
                                    </td>
                                </tr>
                                <tr class="last">
                                    <td>&nbsp;</td>
                                    <td>
                                        <a href="javascript:void(0)" class="button" onclick="$('transactionForm').submit()"><span class="title">Submit</span></a>
                                    </td>
                                </tr>
                            </table>
                        </form> 
                    </div>
                </div>
                <%
                    }
                %>

            </div>
            <div class="pad2">&nbsp;</div>
        </div>

    <%//=sJSJUIST%>

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


    //  resizeAllTextareas(10);

      <%
          if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
              %>
                if(window.history.forward(1) != null){
                 // window.history.forward(1);
                }
              <%
          }
      %>

      function logout(){
  		window.location.href="<c:url value="/datacenter/datacenterHome.jsp?logout=true"/>";
      }

    function openPopupWindow(page, width, height, title){
        if (width == undefined){
            width = 700;
        }
        if (title == undefined) {
           title = "&nbsp;";
        }
        page = "<c:url value="/"/>"+page;

        Modalbox.show(page, {title: title, width: width,height:'400'} );
    }

    function setGraph(array){
        var options = {
        lines: { show: true },
        points: { show: true },
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($('barchart'),
        [
            {data: array, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"}
        ],options);
    }
    function entsub(event,ourform) {
        if (event && event.which == 13){
            $('transactionForm').submit();
            return true;
        }else{
           return false;
        }
    }
    </script>

    <%//=ScreenHelper.getDefaults(request)%>


</body>


</html>