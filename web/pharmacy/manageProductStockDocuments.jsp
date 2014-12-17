<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.pharmacy.*"%>
<%=checkPermission("pharmacy.manageproductstockdocuments","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
	String sAction = checkString(request.getParameter("formaction"));
	String sDoAction = checkString(request.getParameter("doaction"));
	if(sAction.length()==0 && sDoAction.length()>0){
		sAction = sDoAction;
	}
	
	String sUid         = checkString(request.getParameter("documentuid")),
	       sType        = checkString(request.getParameter("documenttype")),
	       sSource      = checkString(request.getParameter("documentsource")),
	       sDestination = checkString(request.getParameter("documentdestination")),
	       sDate        = checkString(request.getParameter("documentdate")),
	       sComment     = checkString(request.getParameter("documentcomment")),
	       sReference   = checkString(request.getParameter("documentreference"));
	
	String sFindType        = checkString(request.getParameter("finddocumenttype")),
	       sFindSource      = checkString(request.getParameter("finddocumentsource")),
	       sFindDestination = checkString(request.getParameter("finddocumentdestination")),
	       sFindSourceText  = checkString(request.getParameter("finddocumentsourcetext")),
	       sFindDestinationText = checkString(request.getParameter("finddocumentdestinationtext")),
	       sFindMinDate     = checkString(request.getParameter("finddocumentmindate")),
	       sFindMaxDate     = checkString(request.getParameter("finddocumentmaxdate")),
	       sFindReference   = checkString(request.getParameter("finddocumentreference")),
	       sDeleteOperation = checkString(request.getParameter("deleteoperation"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n*************** pharmacy/manageProductStockDocuments.jsp **************");
		Debug.println("sAction      : "+sAction);
		Debug.println("sDoAction    : "+sDoAction);
		Debug.println("sUid         : "+sUid);
		Debug.println("sType        : "+sType);
		Debug.println("sSource      : "+sSource);
		Debug.println("sDestination : "+sDestination);
		Debug.println("sDate        : "+sDate);
		Debug.println("sComment     : "+sComment);
		Debug.println("sReference   : "+sReference+"\n");
		Debug.println("sFindType        : "+sFindType);
		Debug.println("sFindSource      : "+sFindSource);
		Debug.println("sFindDestination : "+sFindDestination);
		Debug.println("sFindSourceText  : "+sFindSourceText);
		Debug.println("sFindDestinationText : "+sFindDestinationText);
		Debug.println("sFindMinDate     : "+sFindMinDate);
		Debug.println("sFindMaxDate     : "+sFindMaxDate);
		Debug.println("sFindReference   : "+sFindReference);
		Debug.println("sDeleteOperation : "+sDeleteOperation+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	
	if(sDeleteOperation.length() > 0){
		ProductStockOperation.deleteWithProductStockUpdate(sDeleteOperation);
	}
	
	OperationDocument operationDocument = new OperationDocument();

	//--- SAVE ------------------------------------------------------------------------------------	
	if(sAction.equalsIgnoreCase("save")){
		operationDocument.setUid(sUid);
		operationDocument.setType(sType);
		operationDocument.setSourceuid(sSource);
		operationDocument.setDestinationuid(sDestination);
		java.util.Date d = null;
		try{
			d = ScreenHelper.parseDate(sDate);
		}
		catch(Exception e){};
		operationDocument.setDate(d);
		operationDocument.setComment(sComment);
		operationDocument.setReference(sReference);
		operationDocument.store();
		
		sAction = "find";
		sFindType = sType;
		sFindSource = sSource;
		sFindSourceText = operationDocument.getSourceName(sWebLanguage);
		sFindDestination = sDestination;
		sFindDestinationText = operationDocument.getDestination().getName();
		sFindMinDate = sDate;
		sFindMaxDate = sDate;
		sFindReference = sReference;
	}

	//--- FIND ------------------------------------------------------------------------------------
	if(sAction.length()==0 || sAction.equalsIgnoreCase("find")){
		if(sUid.length()>0){
			operationDocument = OperationDocument.get(sUid);
		
			sFindType = operationDocument.getType();
			sFindSource = operationDocument.getSourceuid();
			sFindSourceText = operationDocument.getSourceName(sWebLanguage);
			sFindDestination = operationDocument.getDestinationuid();
			sFindDestinationText = operationDocument.getDestination().getName();
			sFindMinDate = ScreenHelper.formatDate(operationDocument.getDate());
			sFindMaxDate = ScreenHelper.formatDate(operationDocument.getDate());
			sFindReference = operationDocument.getReference();
		}
		else if(sFindType.length()==0 && sFindSource.length()==0 && sFindDestination.length()==0 &&
				sFindMinDate.length()==0 && sFindMaxDate.length()==0 && sFindReference.length()==0){
			sFindMinDate = ScreenHelper.formatDate(new java.util.Date().getTime()-7*24*3600*1000);			
		}
		
		// show search header
		%>
			<form name="searchForm" method="post" action="<c:url value="/main.jsp"/>">
				<input type="hidden" name="Page" value="pharmacy/manageProductStockDocuments.jsp"/>
				
				<table width="100%" class="list" cellpadding="1" cellspacing="1">
					<tr class="admin">
						<td colspan="2"><%=getTran("web","findoperationdocuments",sWebLanguage)%>&nbsp;</td>
					</tr>
					<tr>
						<td class="admin" width="1%" nowrap><%=getTran("web","type",sWebLanguage)%>&nbsp;</td>
						<td class="admin2">
							<select name="finddocumenttype" id="finddocumenttype" class="text">
								<option value=""></option>
								<%=ScreenHelper.writeSelect("operationdocumenttypes",sFindType,sWebLanguage)%>
							</select>
						</td>
					</tr>
					<tr>
						<td class="admin" width="1%" nowrap><%=getTran("web","source",sWebLanguage)%>&nbsp;</td>
						<td class="admin2">
			                <input class='text' TYPE="text" name="finddocumentsourcetext" id="finddocumentsourcetext" readonly size="50" TITLE="" VALUE="<%=sFindSourceText %>" onchange="">
			                <img src='/openclinic/_img/icons/icon_search.gif' id='buttonUnit' class='link' alt='Choisir' onclick='findsearchsource("finddocumentsource","finddocumentsourcetext");'>&nbsp;<img src='/openclinic/_img/icons/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('finddocumentsource')[0].value='';document.getElementsByName('finddocumentsourcetext')[0].value='';">
			                <input type="hidden" name="finddocumentsource" id="finddocumentsource" VALUE="">
						</td>
					</tr>
					<tr>
						<td class="admin" width="1%" nowrap><%=getTran("web","destination",sWebLanguage)%>&nbsp;</td>
						<td class="admin2">
			                <input class='text' TYPE="text" name="finddocumentdestinationtext" id="finddocumentdestinationtext" readonly size="50" TITLE="" VALUE="<%=sFindDestinationText %>" onchange="">
			                <img src='/openclinic/_img/icons/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=finddocumentdestination&ReturnServiceStockNameField=finddocumentdestinationtext");'>&nbsp;<img src='/openclinic/_img/icons/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('finddocumentdestination')[0].value='';document.getElementsByName('finddocumentdestinationtext')[0].value='';">
			                <input type="hidden" name="finddocumentdestination" id="finddocumentdestination" VALUE="">
						</td>
					</tr>
					<tr>
						<td class="admin" width="1%" nowrap><%=getTran("web","period",sWebLanguage)%>&nbsp;</td>
						<td class="admin2"><%=getTran("web", "from", sWebLanguage)%> <%=writeDateField("finddocumentmindate","searchForm",sFindMinDate,sWebLanguage)%> <%=getTran("web", "to", sWebLanguage)%> <%=writeDateField("finddocumentmaxdate","searchForm",sFindMaxDate,sWebLanguage)%></td>
					</tr>
					<tr>
						<td class="admin" width="1%" nowrap><%=getTran("web","documentreference",sWebLanguage)%>&nbsp;</td>
						<td class="admin2"><input type="text" class="text" name="finddocumentreference" id="finddocumentreference" value="<%=sFindReference%>" size="50"/></td>
					</tr>
					<%-- BUTTONS --%>
					<tr>
					    <td class="admin">&nbsp;</td>
						<td class="admin2">
							<input type="submit" class="button" name="submitfind" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
							<input type="button" class="button" name="submitnew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="document.getElementById('formaction').value='new';searchForm.submit();"/>
							<input type="button" class="button" name="clear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearFindFields();"/>
						</td>
					</tr>
				</table>
				
				<input type='hidden' name='formaction' id='formaction' value='find'/>
			</form>

			<table width="100%" cellpadding="0" cellspacing="1" class="list">
				<%
					Vector documents = OperationDocument.find(sFindType,sFindSource,sFindDestination,sFindMinDate,sFindMaxDate,
							                                  sFindReference,"OC_DOCUMENT_DATE DESC, OC_DOCUMENT_OBJECTID DESC");
					if(documents.size()>0){
						%>
						<tr class='admin'>
							<td><%=getTran("web","ID",sWebLanguage)%>&nbsp;</td>
							<td><%=getTran("web","date",sWebLanguage)%>&nbsp;</td>
							<td><%=getTran("web","type",sWebLanguage)%>&nbsp;</td>
							<td><%=getTran("web","source",sWebLanguage)%>&nbsp;</td>
							<td><%=getTran("web","destination",sWebLanguage)%>&nbsp;</td>
							<td><%=getTran("web","documentreference",sWebLanguage)%>&nbsp;</td>
						</tr>
						<%
					}

					for(int n=0; n<documents.size(); n++){
						OperationDocument document = (OperationDocument)documents.elementAt(n);						
						sType = checkString(document.getType());
						
						if(document.getSourceuid().length()>0){
							sSource = document.getSourceName(sWebLanguage);
						}
						else{
							sSource = "";
						}
						if(document.getDestinationuid()!=null && document.getDestinationuid().length()>0 && document.getDestination()!=null){
							sDestination = document.getDestination().getName();
						}
						else{
							sDestination = "";
							System.out.println("3.4: "+document.getDestinationuid());
							
						}
						
						if(document.getDate()!=null){
							sDate = ScreenHelper.formatDate(document.getDate());
						}
						else{
							sDate = "";
						}
						
						sComment = checkString(document.getComment());
						sReference = checkString(document.getReference());
						
						out.print("<tr class='listText'>"+
						           "<td>"+document.getUid()+"</td>"+
								   "<td><a href='javascript:editDocument(\""+document.getUid()+"\");'>"+sDate+"</a></td>"+
						           "<td>"+getTran("operationdocumenttypes",sType,sWebLanguage)+"</td>"+
								   "<td>"+sSource+"</td><td>"+sDestination+"</td>"+
						           "<td>"+sReference+"</td>"+
						          "</tr>");
					}
				%>
			</table>
		<%		
	}
	//--- EDIT ------------------------------------------------------------------------------------
	else if(sAction.equalsIgnoreCase("new") || sAction.equalsIgnoreCase("edit")){ 
		if(sAction.equalsIgnoreCase("edit")){
			operationDocument = OperationDocument.get(sUid);
		}
		
		%>
		<form name="editForm" method="post" action="<c:url value="/main.jsp"/>">
			<input type="hidden" name="Page" value="pharmacy/manageProductStockDocuments.jsp"/>
			<input type="hidden" name="documentuid" value="<%=sUid %>"/>
			
			<table width="100%" class="list" cellpadding="1" cellspacing="1" width="100%">
				<tr class="admin">
					<td colspan="2"><%=getTran("web","editoperationdocument",sWebLanguage)%></td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","type",sWebLanguage)%> *</td>
					<td class="admin2">
						<select name="documenttype" id="documenttype" class="text">
							<%=ScreenHelper.writeSelect("operationdocumenttypes", operationDocument.getType(), sWebLanguage)%>
						</select>
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","source",sWebLanguage)%> *</td>
					<td class="admin2">
		                <input class="text" type="text" name="documentsourcetext" readonly size="50" title="" value="<%=operationDocument.getSourceuid()!=null && operationDocument.getSourceuid().length()>0 && operationDocument.getSource()!=null?operationDocument.getSourceName(sWebLanguage):"" %>" onchange="">
		                <img src='/openclinic/_img/icons/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='findsource("documentsource","documentsourcetext");'>&nbsp;<img src='/openclinic/_img/icons/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('documentsource')[0].value='';document.getElementsByName('documentsourcetext')[0].value='';">
		                <input type="hidden" name="documentsource" id="documentsource" value="<%=operationDocument.getSourceuid()%>">
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","destination",sWebLanguage)%> *</td>
					<td class="admin2">
		                <input class="text" type="text" name="documentdestinationtext" readonly size="50" title="" value="<%=operationDocument.getDestinationuid()!=null && operationDocument.getDestinationuid().length()>0 && operationDocument.getDestination()!=null?operationDocument.getDestination().getName():"" %>" onchange="">
		                <img src='/openclinic/_img/icons/icon_search.gif' id='buttonUnit' class='link' alt='Choisir'onclick='openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField=documentdestination&ReturnServiceStockNameField=documentdestinationtext");'>&nbsp;<img src='/openclinic/_img/icons/icon_delete.gif' class='link' alt='Vider' onclick="document.getElementsByName('documentdestination')[0].value='';document.getElementsByName('documentdestinationtext')[0].value='';">
		                <input type="hidden" name="documentdestination" id="documentdestination" value="<%=operationDocument.getDestinationuid()%>">
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","date",sWebLanguage)%> *</td>
					<td class="admin2"><%=writeDateField("documentdate","editForm",operationDocument.getDate()!=null?ScreenHelper.formatDate(operationDocument.getDate()):"",sWebLanguage)%></td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","documentcomment",sWebLanguage)%></td>
					<td class="admin2">
					    <textarea class="text" name="documentcomment" id="documentcomment" cols="80"><%=operationDocument.getComment()%></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin"><%=getTran("web","documentreference",sWebLanguage)%></td>
					<td class="admin2">
					    <input type="text" class="text" name="documentreference" id="documentreference" value="<%=operationDocument.getReference()%>" size="50"/>
					</td>
				</tr>
				<%-- BUTTONS --%>
				<tr>
					<td class="admin">&nbsp;</td>
					<td class="admin2">
						<input type="button" class="button" name="submitsave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveForm();"/>
						<input type="button" class="button" name="cancel" value="<%=getTranNoLink("web","cancel",sWebLanguage)%>" onclick="findDocument('<%=sUid%>')"/>
						<input type="button" class="button" name="print" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onclick="printDocument('<%=sUid%>')"/>
					</td>
				</tr>
			</table>
			
			<input type='hidden' name='formaction' id='formaction' value=''/>
		</form>		

        <table class="list" width="100%" cellpadding="0" cellspacing="1">
			<%
				// show the product stock operations that go with this document
				Vector operations = operationDocument.getProductStockOperations();
				if(operations.size() > 0){
					%>
						<tr><td colspan="5"><hr/></td></tr>
						<tr class='admin'>
							<td><%=getTran("web","ID",sWebLanguage)%></td>
							<td><%=getTran("web","date",sWebLanguage)%></td>
							<td><%=getTran("web","description",sWebLanguage)%></td>
							<td><%=getTran("web","product",sWebLanguage)%></td>
							<td><%=getTran("web","quantity",sWebLanguage)%></td>
						</tr>
					<%
				}
				
				ProductStockOperation operation;
				for(int n=0; n<operations.size(); n++){
					operation = (ProductStockOperation)operations.elementAt(n);
					
					out.print("<tr>"+
					           "<td><img src='"+sCONTEXTPATH+"_img/icons/icon_delete.gif' class='link' onclick='javascript:deleteOperation(\""+operation.getUid()+"\");' title='"+getTranNoLink("web","delete",sWebLanguage)+"'>"+operation.getUid()+"</td>"+
                               "<td>"+ScreenHelper.formatDate(operation.getDate())+"</td>"+
					           "<td>"+getTran("productstockoperation.medicationdelivery",operation.getDescription(),sWebLanguage)+"</td>"+
                               "<td>"+operation.getProductStock().getProduct().getName()+"</td>"+
					           "<td>"+operation.getUnitsChanged()+" ("+operation.getProductStock().getLevel()+")</td>"+
                              "</tr>");
				}
			%>
		</table>
		<%
	}
%>

<script>
  <%-- SAVE FORM --%>
  function saveForm(){
	if(document.getElementById("documenttype").value.length>0 &&
	   document.getElementById("documentsource").value.length>0 &&
	   document.getElementById("documentdestination").value.length>0 &&
	   document.getElementById("documentdate").value.length>0){
	  document.getElementById('formaction').value = "save";
	  editForm.submit();
	}
	else{
	       if(document.getElementById("documenttype").value.length==0) document.getElementById("documenttype").focus();
	  else if(document.getElementById("documentsource").value.length==0) document.getElementById("documentsourcetext").focus();
      else if(document.getElementById("documentdestination").value.length==0) document.getElementById("documentdestinationtext").focus();
	  else if(document.getElementById("documentdate").value.length==0) document.getElementById("documentdate").focus();
			  
	  alertDialog("web.manage","datamissing");
	}
  }
	
  function editDocument(uid){
	window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=edit&documentuid='+uid;	
  }
	
  function findDocument(uid){
	window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=find&documentuid='+uid;	
  }
	
  function deleteOperation(uid){
	if(yesnoDialog("Web","areYouSureToDelete")){
      window.location.href='<c:url value="/main.jsp"/>?Page=pharmacy/manageProductStockDocuments.jsp&ts=<%=getTs()%>&doaction=edit&deleteoperation='+uid+'&documentuid=<%=sUid%>';
    }
  }
	
  <%-- PRINT DOCUMENT --%>
  function printDocument(uid){
    window.open("<c:url value='/pharmacy/printStockOperationDocumentPdf.jsp'/>?ts=<%=getTs()%>&documentuid="+uid,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
  }

  <%-- FIND SOURCE --%>
  function findsource(sourceid,sourcename){
  	if('<%=MedwanQuery.getInstance().getConfigString("stockOperationDocumentServiceSources","")%>'.indexOf('*'+document.getElementById("documenttype").options[document.getElementById("documenttype").selectedIndex].value+'*')>-1){
	  openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+sourceid+"&VarText="+sourcename);
	}
	else{
	  openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>"+
			    "&ReturnServiceStockUidField="+sourceid+
			    "&ReturnServiceStockNameField="+sourcename);
	}
  }

  <%-- FIND SEARCH SOURCE --%>
  function findsearchsource(sourceid,sourcename){
   	if('<%=MedwanQuery.getInstance().getConfigString("stockOperationDocumentServiceSources","")%>'.indexOf('*'+document.getElementById("finddocumenttype").options[document.getElementById("finddocumenttype").selectedIndex].value+'*')>-1){
	  openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+sourceid+"&VarText="+sourcename);
	}
	else{
	  openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>"+
			    "&ReturnServiceStockUidField="+sourceid+
			    "&ReturnServiceStockNameField="+sourcename);
	}
  }

  <%-- CLEAR FIND FIELDS --%>
  function clearFindFields(){
	document.getElementById("finddocumenttype").selectedIndex = 0;
	document.getElementById("finddocumentsourcetext").value='';
	document.getElementById("finddocumentsource").value='';
	document.getElementById("finddocumentdestinationtext").value='';
	document.getElementById("finddocumentdestination").value='';
	document.getElementById("finddocumentmindate").value='';
	document.getElementById("finddocumentmaxdate").value='';
	document.getElementById("finddocumentreference").value='';
  }
</script>