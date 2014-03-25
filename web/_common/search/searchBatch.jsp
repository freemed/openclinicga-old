<%@page import="be.openclinic.pharmacy.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<%
	String sProductStockUid=checkString(request.getParameter("ProductStockUid"));
	String sReturnNumber=checkString(request.getParameter("ReturnNumber"));
	String sReturnEnd=checkString(request.getParameter("ReturnEnd"));
	String sReturnComment=checkString(request.getParameter("ReturnComment"));

	Vector batches = Batch.getAllBatches(sProductStockUid);
	for(int n=0;n<batches.size();n++){
		Batch batch = (Batch)batches.elementAt(n);
		if(batch.getEnd()==null || !batch.getEnd().before(new java.util.Date())){
		%>
		<tr>
			<td class='admin'><a href="javascript:selectbatch('<%=batch.getBatchNumber()%>','<%=batch.getEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())%>','<%=batch.getComment() %>')"><%=batch.getBatchNumber() %></a></td>
			<td class='admin2'><%=batch.getEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd()) %></td>
			<td class='admin2'><%=batch.getComment() %></td>
		</tr>
		<%
		}
	}
%>
</table>
<input type='button' class='button' value='<%=getTran("web","close",sWebLanguage) %>' onclick='window.close();'/>
<script>
	function selectbatch(number,enddate,comment){
		if(window.opener.<%=sReturnNumber%>){
			window.opener.<%=sReturnNumber%>.value=number;
		}
		if(window.opener.<%=sReturnEnd%>){
			window.opener.<%=sReturnEnd%>.value=enddate;
		}
		if(window.opener.<%=sReturnComment%>){
			window.opener.<%=sReturnComment%>.value=comment;
		}
		window.close();
	}
</script>