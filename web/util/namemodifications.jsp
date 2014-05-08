<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%' border="1">
<%
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	String sQuery="select personid,count(*) from (select personid,searchname from admin where searchname is not null union select personid,searchname from adminhistory where searchname is not null) aa group by personid having count(*)>2";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		int personid=rs.getInt("personid");
		//Zoek de historiek van de facturaties
		SortedMap invoices = new TreeMap();
		sQuery="select oc_patientinvoice_objectid invoiceid,oc_patientinvoice_createtime date,(select sum(oc_debet_amount) from openclinic_dbo.oc_debets where oc_debet_patientinvoiceuid='1.'||oc_patientinvoice_objectid) amount from openclinic_dbo.oc_patientinvoices where oc_patientinvoice_patientuid=?";
		PreparedStatement ps2 = conn.prepareStatement(sQuery);
		ps2.setString(1,personid+"");
		ResultSet rs2 = ps2.executeQuery();
		while(rs2.next()){
			int amount=rs2.getInt("amount");
			Timestamp date = rs2.getTimestamp("date");
			if(date!=null && amount>0){
				invoices.put(date, rs2.getString("invoiceid")+": "+amount+" FCFA");
			}
		}
		rs2.close();
		ps2.close();
		String tpat="";
		if(invoices.size()>0){
			tpat+="<tr class='admin'><td>Dossier patient</td><td colspan='3'>"+personid+"</td></tr>";
			tpat+="<tr><td class='admin'>Nom du patient</td><td class='admin'>Date modification</td><td class='admin'>Utilisateur</td><td class='admin'>Factures émises</td></tr>";
			//Zoek nu de historiek van de naamwijzigingen
			sQuery = "select lastname,firstname,updatetime,updateuserid from admin where personid=? and searchname is not null union select lastname,firstname,updatetime,updateuserid from adminhistory where personid=? and searchname is not null order by updatetime";
			ps2 = conn.prepareStatement(sQuery);
			ps2.setInt(1,personid);
			ps2.setInt(2,personid);
			rs2 = ps2.executeQuery();
			java.util.Date previousinvoicedate=null,thisinvoicedate=null;
			boolean bvalidline;
			String spat="",spreviousname="",sthisname="";
			int counter=0;
			while(rs2.next()){
				thisinvoicedate=rs2.getTimestamp("updatetime");
				bvalidline=false;
				if(previousinvoicedate!=null && thisinvoicedate!=null){
					//We zoeken nu alle facturen die werden uitgegeven voor de vorige naamswijziging (tussen previousinvoicedate and thisinvoicedate)	
					Iterator i = invoices.keySet().iterator();
					while(i.hasNext()){
						Timestamp invoicedate = (Timestamp)i.next();
						if(invoicedate.before(thisinvoicedate)){
							bvalidline=true;
						}
						if(!invoicedate.before(previousinvoicedate) && invoicedate.before(thisinvoicedate)){
							spat+="<td class='admin2'>"+(String)invoices.get(invoicedate)+"</td>";
						}
					}
					if(bvalidline){
						spat+="</tr></table></td></tr>";
						if(!spreviousname.equalsIgnoreCase(sthisname)){
							tpat+=spat;
							spreviousname=sthisname;
						}
						counter++;
					}
				}
				previousinvoicedate=thisinvoicedate;
				sthisname=checkString(rs2.getString("lastname")).toUpperCase()+", "+rs2.getString("firstname");
				spat="<tr><td>"+sthisname+"</td><td>"+(thisinvoicedate==null?"?":ScreenHelper.fullDateFormatSS.format(thisinvoicedate))+"</td><td>"+MedwanQuery.getInstance().getUserName(rs2.getInt("updateuserid"))+"</td><td><table><tr>";
			}
			if(previousinvoicedate!=null && thisinvoicedate!=null){
				bvalidline=false;
				//We zoeken nu alle facturen die werden uitgegeven voor de vorige naamswijziging (> previousinvoicedate)				
				Iterator i = invoices.keySet().iterator();
				while(i.hasNext()){
					Timestamp invoicedate = (Timestamp)i.next();
					if(invoicedate.before(thisinvoicedate)){
						bvalidline=true;
					}
					if(!invoicedate.before(previousinvoicedate)){
						spat+="<td class='admin2'>"+(String)invoices.get(invoicedate)+"</td>";
					}
				}
				spat+="</tr></table></td></tr>";
				tpat+=spat;
				counter++;
			}
			rs2.close();
			ps2.close();
			if(counter>1){
				out.println(tpat);
			}
		}
		out.println("<tr/>");
	}
	rs.close();
	ps.close();
%>
</table>