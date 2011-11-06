<%@include file="/mobile/validatePatient.jsp"%>

<%
	String orderdate="", healthprofessional="", exam="", protocoldate="",radiologist="", protocol="", reason="";
	TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
	if(transaction!=null){
		orderdate = new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime());
		healthprofessional = transaction.getUser().personVO.getFullName();
		ItemVO item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			exam = getTran("mir_type",item.getValue(),activeUser);
			item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SPECIFICATION");
			if(item!=null && item.getValue()!=null && item.getValue().length()>0){
				exam = exam + " - " + transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SPECIFICATION").getValue();
			}
		}
		item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_EXAMINATIONREASON");
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			reason = item.getValue();
		}
		item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALIDATION");
		if(item!=null && item.getValue().equalsIgnoreCase("medwan.common.true")){
			protocoldate = new SimpleDateFormat("dd/MM/yyyy").format(transaction.getTimestamp());
			item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_PROTOCOL");
			if(item!=null && item.getValue()!=null && item.getValue().length()>0){
				protocol = item.getValue();
			}
		}
	}
%>
<table width='100%'>
	<tr><td colspan='2' bgcolor='peachpuff'><b><%=getTran("mobile","imagingdata",activeUser) %></b></td></tr>
	<tr>
		<td><%=getTran("web","date",activeUser) %></td>
		<td><b><%=orderdate %></b></td>
	</tr>
	<tr>
		<td><%=getTran("web","healthprofessional",activeUser) %></td>
		<td><%=healthprofessional %></td>
	</tr>
	<tr>
		<td><%=getTran("web","examination",activeUser) %></td>
		<td><%=exam %></td>
	</tr>
	<tr>
		<td><%=getTran("web","reason",activeUser) %></td>
		<td><%=reason %></td>
	</tr>
	<% if(protocoldate.length()>0){ %>
	<tr>
		<td><%=getTran("web","protocoldate",activeUser) %></td>
		<td><%=protocoldate %></td>
	</tr>
	<tr>
		<td><%=getTran("web","radiologist",activeUser) %></td>
		<td><%=radiologist %></td>
	</tr>
	<tr>
		<td><%=getTran("web","protocol",activeUser) %></td>
		<td><%=protocol %></td>
	</tr>
	<%} %>
</table>	