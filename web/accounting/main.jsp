<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	// prevent caching
    response.setHeader("Content-Type", "text/html; charset=ISO-8859-1");
    response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
    response.addHeader("Cache-Control", "post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
%>
<html>
<head>
    <%=sCSSNORMAL%>
    <%=sCSSMODALBOX%>
    <%//=sCSSOPERA%>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSSCRPTACULOUS%>
    <%=sJSMODALBOX%>
    <%=sIcon%>

</head>
<body id="body" onresize="pageResize();">

<table width="100%" border="0" cellspacing="0" cellpadding="0"  id="holder">
    <tr>
        <td colspan="2" style="vertical-align:top;" id="header"><%ScreenHelper.setIncludePage("/accountancy/header.jsp", pageContext);%></td>
    </tr>
    <tr class="menu_navigation">
    	<td colspan="2">&nbsp;</td>
    </tr>
    <%-- INCLUDE PAGE --%>
    <tr>
        <td colspan="2" height="100%" style="vertical-align:top;" class="white">
            <div class="content" id="Juist" height="100%"><a name="topp">&nbsp;</a>
                <table width="100%" border="0" id="mijn">
                    <tr>
                        <td style="vertical-align:top;" class="white">
                            <%
                                String sPage = checkString(request.getParameter("Page"));

                                if (sPage.length() > 0 && !sPage.equalsIgnoreCase("null")) {
                                    ScreenHelper.setIncludePage(customerInclude("/" + sPage), pageContext);
                                } else {
                                    ScreenHelper.setIncludePage("/accountancy/index.jsp", pageContext);
                                }
                            %>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
    
</table>
<script>
    var ie = document.all;
    var ns6 = document.getElementById && !document.all;

   ;
    //rcts = Juist.getClientRects();
    //Juist.style.height = document.body.offsetHeight - rcts[0].top - 5;

    function hasScrollbar() {
        return (document.getElementById("Juist").scrollHeight > document.getElementById("Juist").clientHeight);
    }

    function pageResize() {
        if (ie) {
            var rcts = document.getElementById("Juist").getClientRects();
            var headerH = rcts[0].top;
            document.getElementById("Juist").style.height = document.body.clientHeight - headerH;
            if (hasScrollbar()) {
                document.getElementById("holder").style.width = document.body.clientWidth - 1;
                document.getElementById("Juist").style.width = document.body.clientWidth - 2;
                document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth - 17;
            } else {
                document.getElementById("holder").style.width = document.body.clientWidth - 1;
                document.getElementById("Juist").style.width = document.body.clientWidth - 2;
                document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth;

            }
        } else {
            var divHeight = document.getElementById("body").offsetHeight - (document.getElementById("menu").offsetHeight + document.getElementById("header").offsetHeight + 5);
            document.getElementById("Juist").style.height = divHeight + "px";
        }
        resizeSearchFields();
    }
    Event.observe(window, 'load', function() {
      resizeAllTextareas(10);
      changeInputColor();
      pageResize();
    });

    function checkDropdown(evt) {

        if (!dropDownChecked) {
            if (window.myButton) {
                //lastEvent = window.event;
                if (ns6) {
                    lastEvent = evt;
                    if ((lastEvent.target.id.indexOf("menu") > -1) || (lastEvent.target.id.indexOf("ddIcon") > -1)) {
                        if (!bSaveHasNotChanged) {
                            dropDownChecked = true;
                            if (checkSaveButton("<c:url value="/"/>", "<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")) {
                                lastEvent.target.click();
                            }
                        }
                    }
                } else {
                    lastEvent = window.event;
                    if ((lastEvent.srcElement.id.indexOf("menu") > -1) || (lastEvent.srcElement.id.indexOf("ddIcon") > -1)) {
                        if (!bSaveHasNotChanged) {
                            dropDownChecked = true;
                            if (checkSaveButton("<c:url value="/"/>", "<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")) {
                                lastEvent.srcElement.click();
                            }
                        }
                    }
                }
            }
        } else {
            if (ns6) {
                lastEvent = evt;
                lastEvent.target.click;

            } else {
                lastEvent = window.event;
                lastEvent.srcElement.click();
            }
        }
    }
</script>
</body>
</html>
