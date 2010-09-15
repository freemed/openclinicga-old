<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("action"));
    String sNutricientItemId = checkString(request.getParameter("nutricientItemId"));
    String sNutricientUnit = checkString(request.getParameter("nutricientItemUnit"));
    String sNutricientName = checkString(request.getParameter("nutricientItemName"));
    NutricientItem item = new NutricientItem(sNutricientItemId);
    if (sAction.equals("save")) {
        item.name = sNutricientName;
        item.unit = sNutricientUnit;
        item.updateOrInsert(activeUser.userid);
        out.write("<script>closeModalbox();refreshNutricientItems();</script>");
    } else if (sAction.equals("delete")) {
        item.delete();
        out.write("<script>closeModalbox();refreshNutricientItems();</script>");
    }
%>
