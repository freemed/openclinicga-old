<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.RequestedLabAnalysis" %>
<%@include file="/includes/validateUser.jsp"%>
<%
     String sFind = checkString(request.getParameter("value"));
    List l =RequestedLabAnalysis.getAntibiogrammesGerm(sFind);
     out.write("<ul id='autocompletion'>");
     Iterator it = l.iterator();
    while(it.hasNext()){
        out.write("<li>"+it.next()+"</li>");
    }
    out.write("</ul>");
%>
