<%@page import="be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String userid = checkString(request.getParameter("userid"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************** system/getCareProviderFees.jsp ********************");
		Debug.println("userid : "+userid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
%>

<%
    if(userid.length() > 0){
        %>
<br>
<table width="100%" class="list" cellpadding="0" cellspacing="1">
	<%
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID = ?"+
		                                             " ORDER by OC_CAREPROVIDERFEE_TYPE");
		ps.setString(1,userid);
		ResultSet rs = ps.executeQuery();
		String type,id,amount;
		Float famount;
		boolean nodata = true;
		
		while(rs.next()){
			// header
			if(nodata){
				out.print("<tr class='admin'>"+
			               "<td width='25'>&nbsp;</td>"+
			               "<td width='120'>"+getTran("web","type",sWebLanguage)+"</td>"+
			               "<td width='200'>&nbsp;</td>"+
			               "<td width='*'>"+getTran("web","amount",sWebLanguage)+"</td>"+
						  "</tr>");
			}
			
			type = rs.getString("OC_CAREPROVIDERFEE_TYPE");
			id = rs.getString("OC_CAREPROVIDERFEE_ID");
			famount = rs.getFloat("OC_CAREPROVIDERFEE_AMOUNT");
			
			if(type.equalsIgnoreCase("prestation")){
				Prestation prestation = Prestation.get(rs.getString("OC_CAREPROVIDERFEE_ID"));
				if(prestation!=null){
					String a = "<a href='javascript:editline(\"prestation\",\""+prestation.getUid()+"\",\""+prestation.getDescription()+"\",\""+famount+"\");'>"+getTran("web","prestation",sWebLanguage)+"<a>";
					String sLine = "<tr class='list'>"+
					                "<td><img src='_img/icons/icon_delete.png' class='link' onclick='deleteline(\"prestation\",\""+prestation.getUid()+"\",\""+userid+"\");'/></td>"+
					                "<td>"+a+"</td>"+
					                "<td>"+prestation.getDescription()+"</td>"+
					                "<td>"+new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(famount)+MedwanQuery.getInstance().getConfigString("currency","")+"</td>"+
					               "</tr>";
					out.print(sLine);
					nodata = false;
				}
			}
			else if(type.equalsIgnoreCase("prestationtype")){
				String a = "<a href='javascript:editline(\"prestationtype\",\""+id+"\",\"\",\""+famount+"\");'>"+getTran("web","type",sWebLanguage)+"<a>";
				out.print("<tr class='list'>"+
				           "<td><img src='_img/icons/icon_delete.png' class='link' onclick='deleteline(\"prestationtype\",\""+id+"\",\""+userid+"\");'/></td>"+
				           "<td>"+a+"</td>"+
				           "<td>"+getTran("prestation.type",id,sWebLanguage)+"</td>"+
				           "<td>"+rs.getFloat("OC_CAREPROVIDERFEE_AMOUNT")+"%</td>"+
				          "</tr>");
				nodata = false;
			}
			else if(type.equalsIgnoreCase("invoicegroup")){
				String a = "<a href='javascript:editline(\"invoicegroup\",\""+id+"\",\"\",\""+famount+"\");'>"+getTran("web","invoicegroup",sWebLanguage)+"<a>";
				out.print("<tr class='list'>"+
				           "<td><img src='_img/icons/icon_delete.png' class='link' onclick='deleteline(\"invoicegroup\",\""+id+"\",\""+userid+"\");'/></td>"+
				           "<td>"+a+"</td>"+
				           "<td>"+id+"</td>"+
				           "<td>"+famount+"%</td>"+
				          "</tr>");
				nodata = false;
			}
			else if(type.equalsIgnoreCase("default")){
				String a = "<a href='javascript:editline(\"default\",\"\",\"\",\""+famount+"\");'>"+getTran("web","default",sWebLanguage)+"<a>";
				out.print("<tr class='admin2'>"+
				           "<td><img src='_img/icons/icon_delete.png' onclick='deleteline(\"default\",\""+id+"\",\""+userid+"\");'/></td>"+
				           "<td colspan='2'>"+a+"</td>"+
				           "<td>"+famount+"%</td>"+
				          "</tr>");
				nodata = false;
			}
		}
		rs.close();
		ps.close();
		conn.close();
		
		if(nodata){
			out.print("<tr><td>"+getTran("web","nodata",sWebLanguage)+"</td></tr>");
		}
	%>
</table>
        <%
    }
%>