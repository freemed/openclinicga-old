<%@page import = " be.mxs.common.util.db.MedwanQuery,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>

<form action="http://localhost/openclinic/mobile/showTransactions.jsp" method="post">
<table border = 1 width = 100%>
<tr bgcolor = "silver"><td>  Date de la transaction </td><td> Type de la transaction </td><td> Utilisateur responsable pour la transaction </td></tr>

<p/>
<%   
   	   Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	   String sQuery="select distinct a.updateTime, a.transactionType, a.userid "+
       "from transactions a, items b, oc_encounters c "+
       "where a.serverid = b.serverid and a.transactionid = b.transactionid "+
       "and b.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' "+
       "and b.value = concat((c.oc_encounter_serverid),'.',(c.oc_encounter_objectid))"+
       "and b.value ='"+request.getParameter("contactuid")+"'";
	   PreparedStatement ps = conn.prepareStatement(sQuery);   
	   ResultSet rs = ps.executeQuery();
	   while(rs.next()){
		   String updateTime= new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("updateTime"));
		   String typeTransaction= getTran("web.occup",rs.getString("transactionType"),sWebLanguage);
		   String userId = MedwanQuery.getInstance().getUserName(Integer.parseInt(rs.getString("userid")));
		   out.println("<tr><td>"+updateTime+"</td><td>"+typeTransaction+"</td><td>"+userId+"</td></tr>");
		}
		rs.close();
		ps.close();
		conn.close();	
  %>
</table>
</form>

