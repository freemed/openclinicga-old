<%@ page import="be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String listuid=checkString(request.getParameter("listuid"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps=null;
	//De aflevering toevoegen aan oc_drugsoutlist
	ps = conn.prepareStatement("delete from OC_DRUGSOUTLIST where OC_LIST_SERVERID=? and OC_LIST_OBJECTID=?");
	ps.setInt(1,Integer.parseInt(listuid.split("\\.")[0]));
	ps.setInt(2,Integer.parseInt(listuid.split("\\.")[1]));
	ps.execute();
	ps.close();

	//Nu een lijst maken van de oc_drugsoutlist producten in wacht voor deze patiënt
	String drugs="<table width='100%'>";
	ps=conn.prepareStatement("select * from oc_drugsoutlist where OC_LIST_PATIENTUID=? order by OC_LIST_PRODUCTSTOCKUID");
	ps.setString(1,activePatient.personid);
	ResultSet rs = ps.executeQuery();
	int count=0;
	while(rs.next()){
		ProductStock stock = ProductStock.get(rs.getString("OC_LIST_PRODUCTSTOCKUID"));
		int level=stock.getLevel();
		Batch batch=Batch.get(rs.getString("OC_LIST_BATCHUID"));
		String sBatch="?";
		if(batch!=null){
			sBatch=batch.getBatchNumber();
			level=batch.getLevel();
		}
		if(stock!=null){
			if(count==0){
				drugs+="<tr class='admin'><td/><td>ID</td><td>"+getTran("web","product",sWebLanguage)+"</td><td>"+getTran("web","quantity",sWebLanguage)+"</td><td>"+getTran("web","batch",sWebLanguage)+"</td></tr>";
			}
			count++;
			drugs+="<tr><td class='admin2'><a href='javascript:doDelete(\\\""+rs.getInt("OC_LIST_SERVERID")+"."+rs.getInt("OC_LIST_OBJECTID")+"\\\");'><img src='_img/icon_delete.gif'/></a></td><td class='admin2'>"+stock.getUid()+"</td><td class='admin2'>"+stock.getProduct().getName()+"</td><td class='admin2'>"+rs.getInt("OC_LIST_QUANTITY")+"</td><td class='admin2'>"+sBatch+" ("+level+")</td></tr>";
		}
	}
	rs.close();
	ps.close();
	conn.close();
	drugs+="</table>";
	out.print("{\"drugs\":\""+drugs+"\"}");
%>
