<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.pharmacy.*" %>

<%=checkPermission("pharmacy.manageproductstockdocuments","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
	String sAction = checkString(request.getParameter("formaction"));
	String sDoAction = checkString(request.getParameter("doaction"));
	if(sAction.length()==0 && sDoAction.length()>0){
		sAction=sDoAction;
	}
	String sUid = checkString(request.getParameter("documentuid"));
	String sType = checkString(request.getParameter("documenttype"));
	String sSource = checkString(request.getParameter("documentsource"));
	String sDestination = checkString(request.getParameter("documentdestination"));
	String sDate = checkString(request.getParameter("documentdate"));
	String sComment = checkString(request.getParameter("documentcomment"));
	String sReference = checkString(request.getParameter("documentreference"));
	
	String sFindType = checkString(request.getParameter("finddocumenttype"));
	String sFindSource = checkString(request.getParameter("finddocumentsource"));
	String sFindDestination = checkString(request.getParameter("finddocumentdestination"));
	String sFindSourceText = checkString(request.getParameter("finddocumentsourcetext"));
	String sFindDestinationText = checkString(request.getParameter("finddocumentdestinationtext"));
	String sFindMinDate = checkString(request.getParameter("finddocumentmindate"));
	String sFindMaxDate = checkString(request.getParameter("finddocumentmaxdate"));
	String sFindReference = checkString(request.getParameter("finddocumentreference"));
	String sDeleteOperation = checkString(request.getParameter("deleteoperation"));
	
	if(sDeleteOperation.length()>0){
		ProductStockOperation.deleteWithProductStockUpdate(sDeleteOperation);
	}
	System.out.println(1);
	OperationDocument operationDocument = new OperationDocument();

	if(sAction.equalsIgnoreCase("save")){
		operationDocument.setUid(sUid);
		operationDocument.setType(sType);
		operationDocument.setSourceuid(sSource);
		operationDocument.setDestinationuid(sDestination);
		java.util.Date d = null;
		try{
			d=new SimpleDateFormat("dd/MM/yyyy").parse(sDate);
		}
		catch(Exception e){};
		operationDocument.setDate(d);
		operationDocument.setComment(sComment);
		operationDocument.setReference(sReference);
		operationDocument.store();
		sAction="find";
		sFindType=sType;
		sFindSource=sSource;
		sFindSourceText=operationDocument.getSource().getName();
		sFindDestination=sDestination;
		sFindDestinationText=operationDocument.getDestination().getName();
		sFindMinDate=sDate;
		sFindMaxDate=sDate;
		sFindReference=sReference;
	}
	System.out.println(2);

	if(sAction.length()==0 || sAction.equalsIgnoreCase("find")){
		if(sUid.length()>0){
			operationDocument=OperationDocument.get(sUid);
			sFindType=operationDocument.getType();
			sFindSource=operationDocument.getSourceuid();
			sFindSourceText=operationDocument.getSource().getName();
			sFindDestination=operationDocument.getDestinationuid();
			sFindDestinationText=operationDocument.getDestination().getName();
			sFindMinDate=new SimpleDateFormat("dd/MM/yyyy").format(operationDocument.getDate());
			sFindMaxDate=new SimpleDateFormat("dd/MM/yyyy").format(operationDocument.getDate());
			sFindReference=operationDocument.getReference();
		}
		else if(sFindType.length()==0 && sFindSource.length()==0 && sFindDestination.length()==0 && sFindMinDate.length()==0 && sFindMaxDate.length()==0 && sFindReference.length()==0){
			sFindMinDate=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date().getTime()-7*24*3600*1000);			
		}
		//First show search header
		%>
		<table>
			<tr>
				<td>
					<form name="searchForm" method="post" action="<c:url value="/main.jsp"/>">
						<input type="hidden" name="Page" value="pharmacy/manageProductStockDocuments.jsp"/>
						<table width="100%">
							<tr class="admin">
								<td colspan="2"><%=getTran("web","findoperationdocuments",sWebLanguage) %></td>
							</tr>
							<tr>
								<td class="admin" width="1%" nowrap><%=getTran("web","type",sWebLanguage) %></td>
								<td class="admin2">
									<select name="finddocumenttype" id="finddocumenttype" class="text">
										<option value=""></option>
										<%=ScreenHelper.writeSelect("operationdocumenttypes", sFindType, sWebLanguage) %>
									</select>
								</td>
							</tr>
							<tr>
								<td class="admin" width="1%" nowrap><%=getTran("web","source",sWebLanguage) %></td>
								<td class="admin2">
					                <input class='text' TYPE="text" NAME="finddocumentsourcetext" id="finddocumentsourcetext" readonly size="50" TITLE="" VALUE="<%=sFindSourceText %>" onchange="">
					                <img src='/openclinic/_img/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=finddocumentsource&ReturnServiceStockNameField=finddocumentsourcetext");'>&nbsp;<img src='/openclinic/_img/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('finddocumentsource')[0].value='';document.getElementsByName('finddocumentsourcetext')[0].value='';">
					                <input TYPE="hidden" NAME="finddocumentsource" id="finddocumentsource" VALUE="">
								</td>
							</tr>
							<tr>
								<td class="admin" width="1%" nowrap><%=getTran("web","destination",sWebLanguage) %></td>
								<td class="admin2">
					                <input class='text' TYPE="text" NAME="finddocumentdestinationtext" id="finddocumentdestinationtext" readonly size="50" TITLE="" VALUE="<%=sFindDestinationText %>" onchange="">
					                <img src='/openclinic/_img/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=finddocumentdestination&ReturnServiceStockNameField=finddocumentdestinationtext");'>&nbsp;<img src='/openclinic/_img/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('finddocumentdestination')[0].value='';document.getElementsByName('finddocumentdestinationtext')[0].value='';">
					                <input TYPE="hidden" NAME="finddocumentdestination" id="finddocumentdestination" VALUE="">
								</td>
							</tr>
							<tr>
								<td class="admin" width="1%" nowrap><%=getTran("web","period",sWebLanguage) %></td>
								<td class="admin2"><%=getTran("web", "from", sWebLanguage) %> <%=writeDateField("finddocumentmindate","searchForm",sFindMinDate,sWebLanguage) %> <%=getTran("web", "to", sWebLanguage) %> <%=writeDateField("finddocumentmaxdate","searchForm",sFindMaxDate,sWebLanguage) %></td>
							</tr>
							<tr>
								<td class="admin" width="1%" nowrap><%=getTran("web","documentreference",sWebLanguage) %></td>
								<td class="admin2"><input type="text" class="text" name="finddocumentreference" id="finddocumentreference" value="<%=sFindReference%>" size="50"/></td>
							</tr>
							<tr>
								<td colspan="2">
									<input type="submit" name="submitfind" value="<%=getTran("web","find",sWebLanguage)%>"/>
									<input type="button" name="submitnew" value="<%=getTran("web","new",sWebLanguage)%>" onclick="document.getElementById('formaction').value='new';searchForm.submit();"/>
									<input type="button" name="clear" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearFindFields();"/>
								</td>
							</tr>
						</table>
						<input type='hidden' name='formaction' id='formaction' value='find'/>
					</form>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%">
					<%
					Vector documents = OperationDocument.find(sFindType,sFindSource,sFindDestination,sFindMinDate,sFindMaxDate,sFindReference,"OC_DOCUMENT_DATE DESC, OC_DOCUMENT_OBJECTID DESC");
					if(documents.size()>0){
						%>
						<tr class='admin'>
							<td><%=getTran("web","ID",sWebLanguage) %></td>
							<td><%=getTran("web","date",sWebLanguage) %></td>
							<td><%=getTran("web","type",sWebLanguage) %></td>
							<td><%=getTran("web","source",sWebLanguage) %></td>
							<td><%=getTran("web","destination",sWebLanguage) %></td>
							<td><%=getTran("web","documentreference",sWebLanguage) %></td>
						</tr>
						<%
					}
					for(int n=0;n<documents.size();n++){
						OperationDocument document = (OperationDocument)documents.elementAt(n);
						sType=checkString(document.getType());
						if(document.getSourceuid().length()>0){
							System.out.println("document.getSourceuid()="+document.getSourceuid());
							sSource=document.getSource().getName();
						}
						else {
							sSource="";
						}
						if(document.getDestinationuid().length()>0){
							sDestination=document.getDestination().getName();
						}
						else {
							sDestination="";
						}
						if(document.getDate()!=null){
							sDate=new SimpleDateFormat("dd/MM/yyyy").format(document.getDate());
						}
						else {
							sDate="";
						}
						System.out.println("sDate="+sDate);
						sComment=checkString(document.getComment());
						System.out.println("sComment="+sComment);
						sReference=checkString(document.getReference());
						System.out.println("sReference="+sReference);
						out.println("<tr class='listText'><td>"+document.getUid()+"</td><td><a href='javascript:editDocument(\""+document.getUid()+"\");'>"+sDate+"</a></td><td>"+getTran("operationdocumenttypes",sType,sWebLanguage)+"</td><td>"+sSource+"</td><td>"+sDestination+"</td><td>"+sReference+"</td></tr>");
					}
					%>
					</table>
				</td>
			</tr>
		</table>
		<%		
	}
	else if(sAction.equalsIgnoreCase("new") || sAction.equalsIgnoreCase("edit")){ 
		System.out.println(3);
		if(sAction.equalsIgnoreCase("edit")){
			operationDocument = OperationDocument.get(sUid);
		}
		System.out.println("4: "+operationDocument);
		%>
		<table><tr><td colspan="5">
		<form name="editForm" method="post" action="<c:url value="/main.jsp"/>">
			<input type="hidden" name="Page" value="pharmacy/manageProductStockDocuments.jsp"/>
			<input type="hidden" name="documentuid" value="<%=sUid %>"/>
			<table>
				<tr class="admin">
					<td colspan="2"><%=getTran("web","editoperationdocument",sWebLanguage) %></td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","type",sWebLanguage) %> *</td>
					<td class="admin2">
						<select name="documenttype" id="documenttype" class="text">
							<%=ScreenHelper.writeSelect("operationdocumenttypes", operationDocument.getType(), sWebLanguage) %>
						</select>
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","source",sWebLanguage) %> *</td>
					<td class="admin2">
		                <input class='text' TYPE="text" NAME="documentsourcetext" readonly size="50" TITLE="" VALUE="<%=operationDocument.getSourceuid()!=null && operationDocument.getSourceuid().length()>0 && operationDocument.getSource()!=null?operationDocument.getSource().getName():"" %>" onchange="">
		                <img src='/openclinic/_img/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=documentsource&ReturnServiceStockNameField=documentsourcetext");'>&nbsp;<img src='/openclinic/_img/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('documentsource')[0].value='';document.getElementsByName('documentsourcetext')[0].value='';">
		                <input TYPE="hidden" NAME="documentsource" id="documentsource" VALUE="<%=operationDocument.getSourceuid()%>">
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","destination",sWebLanguage) %> *</td>
					<td class="admin2">
		                <input class='text' TYPE="text" NAME="documentdestinationtext" readonly size="50" TITLE="" VALUE="<%=operationDocument.getDestinationuid()!=null && operationDocument.getDestinationuid().length()>0 && operationDocument.getDestination()!=null?operationDocument.getDestination().getName():"" %>" onchange="">
		                <img src='/openclinic/_img/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=documentdestination&ReturnServiceStockNameField=documentdestinationtext");'>&nbsp;<img src='/openclinic/_img/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('documentdestination')[0].value='';document.getElementsByName('documentdestinationtext')[0].value='';">
		                <input TYPE="hidden" NAME="documentdestination" id="documentdestination" VALUE="<%=operationDocument.getDestinationuid()%>">
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","date",sWebLanguage) %> *</td>
					<td class="admin2"><%=writeDateField("documentdate","editForm",operationDocument.getDate()!=null?new SimpleDateFormat("dd/MM/yyyy").format(operationDocument.getDate()):"",sWebLanguage) %></td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","documentcomment",sWebLanguage) %></td>
					<td class="admin2"><textarea class="text" name="documentcomment" id="documentcomment" cols="80"><%=operationDocument.getComment()%></textarea></td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","documentreference",sWebLanguage) %></td>
					<td class="admin2"><input type="text" class="text" name="documentreference" id="documentreference" value="<%=operationDocument.getReference()%>" size="50"/></td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="button" name="submitsave" value="<%=getTran("web","save",sWebLanguage)%>" onclick="saveForm();"/>
						<input type="button" name="cancel" value="<%=getTran("web","cancel",sWebLanguage)%>" onclick="findDocument('<%=sUid%>')"/>
						<input type="button" name="print" value="<%=getTran("web","print",sWebLanguage)%>" onclick="printDocument('<%=sUid%>')"/>
					</td>
				</tr>
			</table>
			<input type='hidden' name='formaction' id='formaction' value=''/>
		</form>		
		</td></tr>
		<%
		//Now show the product stock operations that go with this document
		Vector operations = operationDocument.getProductStockOperations();
		if(operations.size()>0){
			%>
				<tr><td colspan="5"><hr/></td></tr>
				<tr class='admin'>
					<td><%=getTran("web","ID",sWebLanguage) %></td>
					<td><%=getTran("web","date",sWebLanguage) %></td>
					<td><%=getTran("web","description",sWebLanguage) %></td>
					<td><%=getTran("web","product",sWebLanguage) %></td>
					<td><%=getTran("web","quantity",sWebLanguage) %></td>
				</tr>
			<%
		}
		for(int n=0;n<operations.size();n++){
			ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
			%>
			<tr><td><img src='<c:url value="/"/>_img/icon_delete.gif' onclick='javascript:deleteOperation("<%=operation.getUid()%>");'/> <%=operation.getUid()%></td><td><%=new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate())%></td><td><%=getTran("productstockoperation.medicationdelivery", operation.getDescription(), sWebLanguage)%></td><td><%=operation.getProductStock().getProduct().getName()%></td><td><%=operation.getUnitsChanged()+" ("+operation.getProductStock().getLevel()+")"%></td></tr>
			<%
		}
		%>
		</table>
		<%
	}
%>

<script>
	function saveForm(){
		if(document.getElementById("documentdate").value.length>0 && document.getElementById("documentsource").value.length>0 && document.getElementById("documentdestination").value.length>0 ){
			document.getElementById('formaction').value='save';
			editForm.submit();
		}
		else {
		      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
		      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
		      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
		}
	}
	
	function editDocument(uid){
		window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=edit&documentuid='+uid;	
	}
	
	function findDocument(uid){
		window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=find&documentuid='+uid;	
	}
	
	function deleteOperation(uid){
        if(confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")){
			window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=edit&deleteoperation='+uid+'&documentuid=<%=sUid%>';
        }
	}
	
    function printDocument(uid){
        window.open("<c:url value='/pharmacy/printStockOperationDocumentPdf.jsp'/>?ts=<%=getTs()%>&documentuid="+uid,"Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }

	function clearFindFields(){
		document.getElementById("finddocumenttype").selectedIndex=0;
		document.getElementById("finddocumentsourcetext").value='';
		document.getElementById("finddocumentsource").value='';
		document.getElementById("finddocumentdestinationtext").value='';
		document.getElementById("finddocumentdestination").value='';
		document.getElementById("finddocumentmindate").value='';
		document.getElementById("finddocumentmaxdate").value='';
		document.getElementById("finddocumentreference").value='';
	}
</script>