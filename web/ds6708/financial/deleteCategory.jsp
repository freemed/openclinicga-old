<%@page import="be.openclinic.finance.Insurar,
                be.mxs.common.util.system.ScreenHelper"%>
<%
    String sInsurarUid     = ScreenHelper.checkString(request.getParameter("InsurarUid")),
           sCategoryLetter = ScreenHelper.checkString(request.getParameter("CategtoryLetter"));

    Insurar.deleteCategory(sInsurarUid,sCategoryLetter);
%>