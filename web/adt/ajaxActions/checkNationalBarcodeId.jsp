<%@ page import="be.mxs.common.util.db.MedwanQuery" %>
<%@ page import="java.util.Date" %>
<%@ page import="net.admin.AdminPerson" %>
<%@ page import="java.util.List" %><%
    MedwanQuery.NationalBarcodeID nationalBarcodeID = MedwanQuery.getInstance().getNationalBarcodeID(request.getLocalAddr());
    if(nationalBarcodeID!=null ){
        out.println(nationalBarcodeID.id+"$"+nationalBarcodeID.lastname+"$"+nationalBarcodeID.firstname);
        MedwanQuery.getInstance().removeNationalBarcodeID(request.getLocalAddr());
    }
    else if (nationalBarcodeID!=null){
        MedwanQuery.getInstance().removeNationalBarcodeID(request.getLocalAddr());
    }
%>