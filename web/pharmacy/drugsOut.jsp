<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String defaultPharmacy = MedwanQuery.getInstance().getConfigString("defaultPharmacy","");
	if(defaultPharmacy.length()>0){
		%>
		<script>
			window.location.href='<c:url value="/main.do?"/>Page=pharmacy/manageProductStocks.jsp&Action=findShowOverview&EditServiceStockUid=<%=defaultPharmacy%>&DisplaySearchFields=false&ts=<%=getTs()%>';
		</script>				
		<%
	}
	else {
		%>
		<script>
			window.location.href='<c:url value="/main.do?"/>Page=pharmacy/manageServiceStocks.jsp&ts=<%=getTs()%>';
		</script>				
		<%
	}
%>