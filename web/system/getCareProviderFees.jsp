<%@page import="be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="600px">
	<%
		String userid = checkString(request.getParameter("userid"));
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID=? ORDER by OC_CAREPROVIDERFEE_TYPE");
		ps.setString(1,userid);
		ResultSet rs = ps.executeQuery();
		String type,id,amount;
		Float famount;
		boolean nodata=true;
		while(rs.next()){
			type=rs.getString("OC_CAREPROVIDERFEE_TYPE");
			id=rs.getString("OC_CAREPROVIDERFEE_ID");
			famount=rs.getFloat("OC_CAREPROVIDERFEE_AMOUNT");
			if(type.equalsIgnoreCase("prestation")){
				Prestation prestation = Prestation.get(rs.getString("OC_CAREPROVIDERFEE_ID"));
				if(prestation!=null){
					String a="<a href='javascript:editline(\"prestation\",\""+prestation.getUid()+"\",\""+prestation.getDescription()+"\",\""+famount+"\")'>"+getTran("web","prestation",sWebLanguage)+"<a>";
					String sLine="<tr class='admin'><td><img src='_img/icon_delete.png' onclick='deleteline(\"prestation\",\""+prestation.getUid()+"\",\""+userid+"\")'/></td><td>"+a+"</td><td width='400px'>"+prestation.getDescription()+"</td><td>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(famount)+MedwanQuery.getInstance().getConfigString("currency","")+"</td></tr>";
					out.println(sLine);
					nodata=false;
				}
			}
			else if(type.equalsIgnoreCase("prestationtype")){
				String a="<a href='javascript:editline(\"prestationtype\",\""+id+"\",\"\",\""+famount+"\")'>"+getTran("web","type",sWebLanguage)+"<a>";
				out.println("<tr class='admin'><td><img src='_img/icon_delete.png' onclick='deleteline(\"prestationtype\",\""+id+"\",\""+userid+"\")'/></td><td>"+a+"</td><td>"+getTran("prestation.type",id,sWebLanguage)+"</td><td>"+rs.getFloat("OC_CAREPROVIDERFEE_AMOUNT")+"%</td></tr>");
				nodata=false;
			}
			else if(type.equalsIgnoreCase("invoicegroup")){
				String a="<a href='javascript:editline(\"invoicegroup\",\""+id+"\",\"\",\""+famount+"\")'>"+getTran("web","invoicegroup",sWebLanguage)+"<a>";
				out.println("<tr class='admin'><td><img src='_img/icon_delete.png' onclick='deleteline(\"invoicegroup\",\""+id+"\",\""+userid+"\")'/></td><td>"+a+"</td><td>"+id+"</td><td>"+famount+"%</td></tr>");
				nodata=false;
			}
			else if(type.equalsIgnoreCase("default")){
				String a="<a href='javascript:editline(\"default\",\"\",\"\",\""+famount+"\")'>"+getTran("web","default",sWebLanguage)+"<a>";
				out.println("<tr class='admin'><td><img src='_img/icon_delete.png' onclick='deleteline(\"default\",\""+id+"\",\""+userid+"\")'/></td><td colspan=2>"+a+"</td><td>"+famount+"%</td></tr>");
				nodata=false;
			}
		}
		rs.close();
		ps.close();
		conn.close();
		if(nodata){
			out.println("<tr><td>"+getTran("web","nodata",sWebLanguage)+"</td></tr>");
		}
	%>
</table>