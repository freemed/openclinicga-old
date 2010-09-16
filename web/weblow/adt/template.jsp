<%@include file="/_common/templateAddIns.jsp"%>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
    <%=sJSPOPUPSEARCH%>
</head>
<%
    //response.setHeader("Cache-Control","no-cache"); // HTTP 1.1
    response.setHeader("Pragma","no-cache"); // HTTP 1.0
    response.setDateHeader("Expires",0); // prevents caching at the proxy server

    String sPage = request.getParameter("Page");
    ScreenHelper.setIncludePage(sPage, pageContext);
%>
