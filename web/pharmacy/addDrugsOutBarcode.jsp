<%@ page import="be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String loadonly    = checkString(request.getParameter("loadonly")),
           drugbarcode = checkString(request.getParameter("DrugBarcode")),
	       sQuantity   = checkString(request.getParameter("Quantity"));
	
	int quantity = 1;
	try{
		quantity = Integer.parseInt(sQuantity);
	}
	catch(Exception e){
		e.printStackTrace();
	}
	
	String servicestock = checkString(request.getParameter("ServiceStock"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** pharmacy/addDrugsOutBarcode.jsp ******************");
    	Debug.println("loadonly    : "+loadonly);
    	Debug.println("drugbarcode : "+drugbarcode);
    	Debug.println("sQuantity   : "+sQuantity+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

	// search product
	ProductStock productstock = ProductStock.getByBarcode(drugbarcode,servicestock);
	if(loadonly.length()==0 && productstock==null){
		out.print("{\"message\":\""+getTranNoLink("web","productstock.does.not.exist",sWebLanguage)+"\"}");
	}
	else if(loadonly.length()==0 && productstock.getLevel()<quantity){
		out.print("{\"message\":\""+getTranNoLink("web","insufficient.stock",sWebLanguage)+"\"}");
	}
	else{
		// load-only
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		if(loadonly.length()==0){
			// aflevering toevoegen aan oc_drugsoutlist
			String batchuid = "";
			int tofind = quantity;
			
			Vector batches = Batch.getBatches(productstock.getUid());
			for(int n=0; n<batches.size(); n++){
				Batch batch = (Batch)batches.elementAt(0);
				
				if(batch.getLevel()<tofind){
					ps = conn.prepareStatement("SELECT * FROM OC_DRUGSOUTLIST WHERE OC_LIST_PATIENTUID=?"+
				                               " AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
					ps.setString(1,activePatient.personid);
					ps.setString(2,productstock.getUid());
					ps.setString(3,batch.getUid());
					rs = ps.executeQuery();
					
					if(rs.next()){
						rs.close();
						ps.close();
						
						ps = conn.prepareStatement("update OC_DRUGSOUTLIST set OC_LIST_QUANTITY=OC_LIST_QUANTITY+?"+
						                           " where  OC_LIST_PATIENTUID=? AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
						ps.setInt(1,batch.getLevel());
						ps.setString(2,activePatient.personid);
						ps.setString(3,productstock.getUid());
						ps.setString(4,batch.getUid());
						ps.execute();
						ps.close();
					}
					else{
						rs.close();
						ps.close();
						
						ps = conn.prepareStatement("insert into OC_DRUGSOUTLIST(OC_LIST_SERVERID,OC_LIST_OBJECTID,OC_LIST_PATIENTUID,"+
						                           "OC_LIST_PRODUCTSTOCKUID,OC_LIST_QUANTITY,OC_LIST_BATCHUID) values(?,?,?,?,?,?)");
						ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
						ps.setInt(2,MedwanQuery.getInstance().getOpenclinicCounter("DRUGSOUT"));
						ps.setString(3,activePatient.personid);
						ps.setString(4,productstock.getUid());
						ps.setInt(5,batch.getLevel());
						ps.setString(6,batch.getUid());
						ps.execute();
						ps.close();
					}
					tofind = tofind-batch.getLevel();
				}
				else{
					ps = conn.prepareStatement("select * from OC_DRUGSOUTLIST where OC_LIST_PATIENTUID=?"+
				                               " AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
					ps.setString(1,activePatient.personid);
					ps.setString(2,productstock.getUid());
					ps.setString(3,batch.getUid());
					rs = ps.executeQuery();
					if(rs.next()){
						rs.close();
						ps.close();
						
						ps = conn.prepareStatement("update OC_DRUGSOUTLIST set OC_LIST_QUANTITY=OC_LIST_QUANTITY+?"+
						                           " where  OC_LIST_PATIENTUID=? AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
						ps.setInt(1,tofind);
						ps.setString(2,activePatient.personid);
						ps.setString(3,productstock.getUid());
						ps.setString(4,batch.getUid());
						ps.execute();
						ps.close();
					}
					else {
						rs.close();
						ps.close();
						
						ps = conn.prepareStatement("insert into OC_DRUGSOUTLIST(OC_LIST_SERVERID,OC_LIST_OBJECTID,OC_LIST_PATIENTUID,"+
						                           " OC_LIST_PRODUCTSTOCKUID,OC_LIST_QUANTITY,OC_LIST_BATCHUID) values(?,?,?,?,?,?)");
						ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
						ps.setInt(2,MedwanQuery.getInstance().getOpenclinicCounter("DRUGSOUT"));
						ps.setString(3,activePatient.personid);
						ps.setString(4,productstock.getUid());
						ps.setInt(5,tofind);
						ps.setString(6,batch.getUid());
						ps.execute();
						ps.close();
					}
					tofind = 0;
					break;
				}
			}
			
			if(tofind > 0){
				ps = conn.prepareStatement("select * from OC_DRUGSOUTLIST where OC_LIST_PATIENTUID=?"+
			                               " AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
				ps.setString(1,activePatient.personid);
				ps.setString(2,productstock.getUid());
				ps.setString(3,"");
				rs = ps.executeQuery();
				
				if(rs.next()){
					rs.close();
					ps.close();
					
					ps = conn.prepareStatement("update OC_DRUGSOUTLIST set OC_LIST_QUANTITY=OC_LIST_QUANTITY+?"+
					                           " where OC_LIST_PATIENTUID=? AND OC_LIST_PRODUCTSTOCKUID=? and OC_LIST_BATCHUID=?");
					ps.setInt(1,tofind);
					ps.setString(2,activePatient.personid);
					ps.setString(3,productstock.getUid());
					ps.setString(4,"");
					ps.execute();
					ps.close();
				}
				else{
					rs.close();
					ps.close();
					
					ps = conn.prepareStatement("insert into OC_DRUGSOUTLIST(OC_LIST_SERVERID,OC_LIST_OBJECTID,OC_LIST_PATIENTUID,"+
					                           " OC_LIST_PRODUCTSTOCKUID,OC_LIST_QUANTITY,OC_LIST_BATCHUID) values(?,?,?,?,?,?)");
					ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
					ps.setInt(2,MedwanQuery.getInstance().getOpenclinicCounter("DRUGSOUT"));
					ps.setString(3,activePatient.personid);
					ps.setString(4,productstock.getUid());
					ps.setInt(5,tofind);
					ps.setString(6,"");
					ps.execute();
					ps.close();
				}
			}
		}
		
		// lijst maken van oc_drugsoutlist producten in wacht voor patiënt
	    String drugs = "<table width='100%' class='list' cellpadding='0' cellspacing='1'>";
		
		ps = conn.prepareStatement("select * from oc_drugsoutlist where OC_LIST_PATIENTUID=? order by OC_LIST_PRODUCTSTOCKUID");
		ps.setString(1,activePatient.personid);
		rs = ps.executeQuery();
		int count = 0;
		
		ProductStock stock;
		while(rs.next()){
			stock = ProductStock.get(rs.getString("OC_LIST_PRODUCTSTOCKUID"));
			
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
				count++;
				
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
			}
		}
		rs.close();
		ps.close();
		conn.close();
		
		drugs+= "</table>";
		
		out.print("{\"drugs\":\""+drugs+"\"}");
	}
%>