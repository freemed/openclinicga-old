<%@include file="/includes/helper.jsp"%>
<%
    String sProductUid =  checkString(request.getParameter("productuid"));
    if(sProductUid.length()>0){
        String sQuery="select * from OC_PRODUCTS where OC_PRODUCT_SERVERID=? and OC_PRODUCT_OBJECTID=?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps =oc_conn.prepareStatement(sQuery);
        ps.setInt(1,Integer.parseInt(sProductUid.split("\\.")[0]));
        ps.setInt(2,Integer.parseInt(sProductUid.split("\\.")[1]));
        ResultSet rs = ps.executeQuery();
        if (rs.next()){
            out.println("$"+checkString(rs.getString("OC_PRODUCT_PRESCRIPTIONINFO"))+"$R/ "+rs.getString("OC_PRODUCT_NAME")+"$");
        }
        else {
            out.println("$$$");
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }
%>