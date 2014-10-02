<%@page import="be.mxs.common.util.db.MedwanQuery"%>

<%
    MedwanQuery.NationalBarcodeID nationalBarcodeID = MedwanQuery.getInstance().getNationalBarcodeID(request.getLocalAddr());
    if(nationalBarcodeID!=null){
        out.println("REMOVE : "+nationalBarcodeID.id+"$"+nationalBarcodeID.lastname+"$"+nationalBarcodeID.firstname);
        MedwanQuery.getInstance().removeNationalBarcodeID(request.getLocalAddr());
    }
%>