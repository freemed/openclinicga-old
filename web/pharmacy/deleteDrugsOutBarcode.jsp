<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String listuid = checkString(request.getParameter("listuid"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************* pharmacy/deleteDrugsOutBarcode.jsp *****************");
		Debug.println("listuid : "+listuid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = null;
	
	// aflevering toevoegen aan oc_drugsoutlist
	ps = conn.prepareStatement("delete from OC_DRUGSOUTLIST where OC_LIST_SERVERID=? and OC_LIST_OBJECTID=?");
	ps.setInt(1,Integer.parseInt(listuid.split("\\.")[0]));
	ps.setInt(2,Integer.parseInt(listuid.split("\\.")[1]));
	ps.execute();
	ps.close();

	// lijst maken van oc_drugsoutlist producten in wacht voor patiënt
	String drugs = "<table width='100%' class='list' cellpadding='0' cellspacing='1'>";
	
	ps=conn.prepareStatement("select * from OC_DRUGSOUTLIST where OC_LIST_PATIENTUID=?"+
	                         " order by OC_LIST_PRODUCTSTOCKUID");
	ps.setString(1,activePatient.personid);
	ResultSet rs = ps.executeQuery();
	int count = 0;
	
	while(rs.next()){
		ProductStock stock = ProductStock.get(rs.getString("OC_LIST_PRODUCTSTOCKUID"));
		if(stock!=null){
			int level = stock.getLevel();
			
			Batch batch = Batch.get(rs.getString("OC_LIST_BATCHUID"));
			String sBatch = "?";
			if(batch!=null){
				sBatch = batch.getBatchNumber();
				level = batch.getLevel();
			}
			
			// header
			if(count==0){
				drugs+= "<tr class='admin'>"+
			             "<td/>"+
						 "<td>ID</td>"+
			             "<td>"+getTran("web","product",sWebLanguage)+"</td>"+
						 "<td>"+getTran("web","quantity",sWebLanguage)+"</td>"+
			             "<td>"+getTran("web","batch",sWebLanguage)+"</td>"+
						"</tr>";
			}
			
			// one row
			drugs+= "<tr>"+
			         "<td class='admin2'>"+
			          "<a href='javascript:doDelete(\\\""+rs.getInt("OC_LIST_SERVERID")+"."+rs.getInt("OC_LIST_OBJECTID")+"\\\");'>"+
			           "<img src='_img/icons/icon_delete.gif' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"'/></a>"+
			         "</td>"+
			         "<td class='admin2'>"+stock.getUid()+"</td>"+
			         "<td class='admin2'>"+stock.getProduct().getName()+"</td>"+
			         "<td class='admin2'>"+rs.getInt("OC_LIST_QUANTITY")+"</td>"+
			         "<td class='admin2'>"+sBatch+" ("+level+")</td>"+
			        "</tr>";

			count++;
		}
	}
	rs.close();
	ps.close();
	conn.close();
	
	drugs+= "</table>";
	
	out.print("{\"drugs\":\""+drugs+"\"}");
%>