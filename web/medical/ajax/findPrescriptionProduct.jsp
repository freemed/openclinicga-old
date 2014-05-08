<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<%
    String sProductName =  checkString(request.getParameter("productname"));
    if(sProductName.length()>0){
        String sQuery="select * from OC_PRODUCTS where OC_PRODUCT_NAME like '%"+sProductName+"%' order by OC_PRODUCT_NAME";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps =oc_conn.prepareStatement(sQuery);
        ResultSet rs = ps.executeQuery();
        String l="";
        while (rs.next()){
            if(l.length()==0){
                l="1";
            }
            else{
                l="";
            }
            out.println("<tr class='list"+l+"'><td valign='middle'><a href='javascript:copyproduct(\""+rs.getInt("OC_PRODUCT_SERVERID")+"."+rs.getInt("OC_PRODUCT_OBJECTID")+"\");'>");
            %>
            <img src='<c:url value="/_img/arrow_right.gif"/>' alt='<%=getTranNoLink("web","right",sWebLanguage)%>'/></a>&nbsp;
            <%
            out.print("<a href='javascript:copycontent(\""+rs.getInt("OC_PRODUCT_SERVERID")+"."+rs.getInt("OC_PRODUCT_OBJECTID")+"\");'>"+rs.getString("OC_PRODUCT_NAME")+"</a></td></tr>");
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }
%>
</table>