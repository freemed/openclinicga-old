<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String keyword=checkString(request.getParameter("keyword"));
	String code=checkString(request.getParameter("code"));
	if(request.getParameter("save")!=null){
		if(keyword.length()>0 && code.length()>0){
			//Save the new keyword-concept link
			String concept="OC_"+MedwanQuery.getInstance().getOpenclinicCounter("ConceptID");
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sSql = "insert into keywords(keyword,concept,language) values(?,?,?)";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setString(1,keyword);
			ps.setString(2,concept);
			ps.setString(3, sWebLanguage.substring(0,1).toUpperCase());
			ps.execute();
			ps.close();
			//Save the new concept-DSM4 link
			sSql="insert into dsm4concepts(concept,dsm4) values(?,?)";
			ps=conn.prepareStatement(sSql);
			ps.setString(1, concept);
			ps.setString(2, code);
			ps.execute();
			conn.close();
		}
		out.println("<script>window.close();</script>");
		out.flush();
	}
%>
<form name="addKeywordForm" method="post">
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran("web","add.dsm4.keyword",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","keyword",sWebLanguage) %></td>
			<td class='admin2'><input type='text' class='text' size='50' name='keyword' id='keyword'/></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","code",sWebLanguage) %></td>
			<td class='admin2'>
				<select class='text' name='code' id='code'>
					<%
					Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
					String sSql = "select * from dsm4 order by code";
					PreparedStatement ps = conn.prepareStatement(sSql);
					ResultSet rs = ps.executeQuery();
					while(rs.next()){
						code=rs.getString("code");
						out.println("<option value='"+code+"'>"+(code+"          ").substring(0,10)+": "+rs.getString("label"+sWebLanguage)+"</option>");
					}
					rs.close();
					ps.close();
					conn.close();
					%>
				</select>
			</td>
		</tr>
	</table>
	<input type='submit' class='button' name='save' value='<%=getTranNoLink("web","save",sWebLanguage) %>'/>
</form>

<script>
	document.getElementById("keyword").focus();	
</script>