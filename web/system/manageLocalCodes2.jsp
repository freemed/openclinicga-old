<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String	sLocalCode=checkString(request.getParameter("localcode")),
			sAction=checkString(request.getParameter("action")),
			sShowlist=checkString(request.getParameter("showlist")),
			sLabelNL=checkString(request.getParameter("labelnl")),
			sType=checkString(request.getParameter("type")),
			sLabelFR=checkString(request.getParameter("labelfr")),
			sLabelEN=checkString(request.getParameter("labelen"));

	if(request.getParameter("submitform")!=null){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		if(sLocalCode.length()==0){
			sLocalCode=""+MedwanQuery.getInstance().getOpenclinicCounter("LocalCode");
		}
		else {
			String sQuery="delete from icd10 where code=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setString(1,sType+sLocalCode);
			ps.execute();
			ps.close();
		}

		String sQuery="insert into icd10 (code,labelnl,labelfr,labelen) values(?,?,?,?)";
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setString(1, sType+sLocalCode);
		ps.setString(2,sLabelNL);
		ps.setString(3,sLabelFR);
		ps.setString(4,sLabelEN);
		ps.execute();
		ps.close();
		conn.close();
		sAction="save";
	}

	if(sAction.equalsIgnoreCase("delete")){
		if(sLocalCode.length()>0){
			Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="delete from icd10 where code=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setString(1,sType+sLocalCode);
			ps.execute();
			ps.close();
			conn.close();
		}
%>
		<input class='button' type='button' name='new' value='<%=getTranNoLink("web","new",sWebLanguage)%>' onclick='window.location.href="popup.jsp?Page=system/manageLocalCodes.jsp&localcode=&action=edit&showlist=true&type=<%=sType%>&PopupHeight=<%=checkString(request.getParameter("PopupHeight"))%>&PopupWidth=<%=checkString(request.getParameter("PopupWidth"))%>"'/>		
		<input class='button' type='button' name='close' value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick='window.close()'/>
<%
	}
	else if(sAction.equalsIgnoreCase("edit")){
		if(sLocalCode.length()>0){
			Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from icd10 where code=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setString(1,sLocalCode);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				sLocalCode=sLocalCode.substring(sType.length());
				sLabelNL=rs.getString("labelnl");
				sLabelFR=rs.getString("labelfr");
				sLabelEN=rs.getString("labelen");
			}
			rs.close();
			ps.close();
			conn.close();
		}
%>
	<form name="localCodeForm" id="localCodeForm" method="post" action="<c:url value="/popup.jsp?Page=/system/manageLocalCodes2.jsp"/>">
		<table width='100%'>
			<tr>
				<td class='admin'><%=getTran("web","code",sWebLanguage)%></td>
				<td class='admin2'><%=sType %><input type='text' name='localcode' size='10' value='<%=sLocalCode %>'/></td>
			</tr>
			<tr>
				<td class='admin'><label class='text'>FR</label></td>
				<td class='admin2'><input class='text' name='labelfr' type='text' size='80' value='<%=sLabelFR%>'/></td>
			</tr>
			<tr>
				<td class='admin'><label class='text'>EN</label></td>
				<td class='admin2'><input class='text' name='labelen' type='text' size='80' value='<%=sLabelEN%>'/></td>
			</tr>
			<tr>
				<td class='admin'><label class='text'>NL</label></td>
				<td class='admin2'><input class='text' name='labelnl' type='text' size='80' value='<%=sLabelNL%>'/></td>
			</tr>
		</table>
		<input type='hidden' name='action' id='action' value='<%=sAction%>'/>
		<input type='hidden' name='type' id='type' value='<%=sType%>'/>
		<input type='hidden' name='showlist' id='showlist' value='<%=sShowlist%>'/>
		<input type='hidden' name='PopupHeight' id='PopupHeight' value='<%=checkString(request.getParameter("PopupHeight"))%>'/>
		<input type='hidden' name='PopupWidth' id='PopupWidth' value='<%=checkString(request.getParameter("PopupWidth"))%>'/>
		<p/>
		<input class='button' type='submit' name='submitform' value='<%=getTranNoLink("web","save",sWebLanguage)%>'/>
		<input class='button' type='button' name='delete' value='<%=getTranNoLink("web","delete",sWebLanguage)%>' onclick='document.getElementById("action").value="delete";document.getElementById("localCodeForm").submit();if(typeof window.opener.doFind=="function") window.opener.doFind();'/>
		<input class='button' type='button' name='new' value='<%=getTranNoLink("web","new",sWebLanguage)%>' onclick='window.location.href="popup.jsp?Page=system/manageLocalCodes2.jsp&localcode=&action=edit&showlist=true&PopupHeight=<%=checkString(request.getParameter("PopupHeight"))%>&PopupWidth=<%=checkString(request.getParameter("PopupWidth"))%>"'/>		
		<input class='button' type='button' name='close' value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick='window.close()'/>
	</form>
<% 
	}
	else {
%>
	<script>window.opener.doFind();window.close();</script>
<%
	}
 	String	sDiv="";

	if(sShowlist.length()>0){
		//Eerst zoeken we alle lokale codes op
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		String sCode="";
		String sQuery="select * from icd10 where code like '"+sType+"%'";
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			sCode=rs.getString("code");
			sDiv+="<tr><td class='admin'>"+sCode+"</td><td class='admin2'><a href='popup.jsp?Page=system/manageLocalCodes2.jsp&localcode="+sCode+"&action=edit&showlist=true&type="+sType+"&PopupHeight="+checkString(request.getParameter("PopupHeight"))+"&PopupWidth="+checkString(request.getParameter("PopupWidth"))+"'>"+rs.getString("label"+sWebLanguage)+"</a></td></tr>";
		}
		rs.close();
		ps.close();
		conn.close();
	}
 %>
 
 <div>
	<table><%=sDiv %></table>
</div>
 