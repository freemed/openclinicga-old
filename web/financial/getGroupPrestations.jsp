<%@ page import="be.openclinic.finance.Prestation" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sPrestationGroupUID = checkString(request.getParameter("PrestationGroupUID"));
    String prestationcontent="<td colspan='3'><table>";
    try{
    if (sPrestationGroupUID.split("\\.").length==2) {
    	String sSql="select oc_prestationgroup_prestationuid from oc_prestationgroups_prestations where oc_prestationgroup_groupuid=?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	PreparedStatement ps = oc_conn.prepareStatement(sSql);
    	ps.setString(1,sPrestationGroupUID);
    	ResultSet rs = ps.executeQuery();
    	while(rs.next()){
    		String sPrestationUid=rs.getString("oc_prestationgroup_prestationuid");
    		Prestation prestation = Prestation.get(sPrestationUid);
    		if(prestation!=null){
    	        prestationcontent+="<tr>";
    	        prestationcontent+="<td>";
				prestationcontent+="<a href='javascript:deleteprestation(\\\""+prestation.getUid()+"\\\")'><img src='"+ request.getRequestURI().replaceAll(request.getServletPath(), "")+"/_img/icon_delete.gif'/></a> ";
    	        prestationcontent+=prestation.getCode()+"</td><td><b>"+prestation.getDescription()+"</b></td>";
    	        prestationcontent+="</tr>";
   	        }
    	}
        rs.close();
        ps.close();
        oc_conn.close();
	}
    prestationcontent+="</table></td>";
}
catch(Exception e){
	e.printStackTrace();
}
%>
{
"PrestationContent":"<%=prestationcontent%>"
}