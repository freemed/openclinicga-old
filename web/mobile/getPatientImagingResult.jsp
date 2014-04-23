<%@include file="/mobile/_common/head.jsp"%>

<%
	String orderdate = "", healthprofessional = "", exam = "", protocoldate = "", 
	       radiologist = "", protocol = "", reason = "";

	TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),
			                                                              Integer.parseInt(request.getParameter("transactionid")));
	if(transaction!=null){
		orderdate = stdDateFormat.format(transaction.getUpdateTime());
		healthprofessional = transaction.getUser().personVO.getFullName();
		
		// type
		String sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_TYPE");
		if(sItemValue.length() > 0){
			exam = getTran("mir_type",sItemValue,activeUser);
			
			// specification
			sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_SPECIFICATION");
			if(sItemValue.length() > 0){
				exam+= " - "+sItemValue;
			}
		}
		
		// reason
		sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_EXAMINATIONREASON");
		if(sItemValue.length() > 0){
			reason = sItemValue;
		}
		
		// validation ?
		sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALIDATION");
		if(sItemValue.equalsIgnoreCase("medwan.common.true")){
			protocoldate = stdDateFormat.format(transaction.getTimestamp());
			
			// protocol
			sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_PROTOCOL");
			if(sItemValue.length() > 0){
				protocol = sItemValue;
			}
		}
	}
%>
<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="2"><%=getTran("mobile","imagingdata",activeUser)%></td></tr>
	
	<tr>
		<td class="admin" width="100"><%=getTran("web","date",activeUser)%></td>
		<td><b><%=orderdate %></b></td>
	</tr>
	<tr>
		<td class="admin"><%=getTran("web","healthprofessional",activeUser)%></td>
		<td><%=healthprofessional %></td>
	</tr>
	<tr>
		<td class="admin"><%=getTran("web","examination",activeUser)%></td>
		<td><%=exam %></td>
	</tr>
	<tr>
		<td class="admin"><%=getTran("web","reason",activeUser)%></td>
		<td><%=reason %></td>
	</tr>
	<%
	    if(protocoldate.length()>0){
	        %>
	<tr>
		<td class="admin"><%=getTran("web","protocoldate",activeUser)%></td>
		<td><%=protocoldate %></td>
	</tr>
	<tr>
		<td class="admin"><%=getTran("web","radiologist",activeUser)%></td>
		<td><%=radiologist %></td>
	</tr>
	<tr>
		<td class="admin"><%=getTran("web","protocol",activeUser)%></td>
		<td><%=protocol %></td>
	</tr>
	        <%
	    }
	%>
</table>	
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
	<input type="button" class="button" name="backButton" onclick="showPatientMenu();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
		 			
<%@include file="/mobile/_common/footer.jsp"%>