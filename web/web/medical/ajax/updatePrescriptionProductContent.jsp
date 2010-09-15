<%@include file="/includes/helper.jsp"%>
<%
    String sProductUid =  checkString(request.getParameter("productuid"));
    String sPrescriptionInfo =  checkString(request.getParameter("prescriptioninfo"));
    if(sProductUid.length()>0){
        String sQuery="update OC_PRODUCTS set OC_PRODUCT_PRESCRIPTIONINFO=? where OC_PRODUCT_SERVERID=? and OC_PRODUCT_OBJECTID=?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps =oc_conn.prepareStatement(sQuery);
        ps.setString(1,sPrescriptionInfo);
        ps.setInt(2,Integer.parseInt(sProductUid.split("\\.")[0]));
        ps.setInt(3,Integer.parseInt(sProductUid.split("\\.")[1]));
        ps.executeUpdate();
        ps.close();
        oc_conn.close();
    }
%>