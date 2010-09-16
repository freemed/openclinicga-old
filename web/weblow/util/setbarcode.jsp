<%@ page import="be.mxs.common.util.db.MedwanQuery" %><%
    MedwanQuery.getInstance().setNationalBarcodeId(request.getLocalAddr(),request.getParameter("ident"),request.getParameter("lastname"),request.getParameter("firstname"));
%>