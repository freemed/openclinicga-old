<%@page import="be.openclinic.pharmacy.*"%>
<%@page import="org.apache.taglibs.standard.tag.common.core.CatchTag"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationreceipt","all",activeUser)%>

<%
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
           sDefaultSrcDestType = "type2patient", sServiceStockUid = "", sSourceStockName = "", sEditRemaining;

    // action
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0) sAction = "receiveMedication"; // default

    // retreive form data
    String sEditOperationUid    = checkString(request.getParameter("EditOperationUid")),
    	   sEditReferenceOperationUid=checkString(request.getParameter("EditReferenceOperationUid")),
           sEditOperationDescr  = checkString(request.getParameter("EditOperationDescr")),
           sEditUnitsChanged    = checkString(request.getParameter("EditUnitsChanged")),
           sEditSrcDestType     = checkString(request.getParameter("EditSrcDestType")),
           sEditSrcDestUid      = checkString(request.getParameter("EditSrcDestUid")),
           sEditSrcDestName     = checkString(request.getParameter("EditSrcDestName")),
           sEditProductName     = checkString(request.getParameter("EditProductName")),
           sEditOperationDate   = checkString(request.getParameter("EditOperationDate")),
           sEditBatchUid        = checkString(request.getParameter("EditBatchUid")),
           sEditBatchNumber     = checkString(request.getParameter("EditBatchNumber")),
           sEditBatchEnd        = checkString(request.getParameter("EditBatchEnd")),
           sEditBatchComment    = checkString(request.getParameter("EditBatchComment")),
           sEditReceiveComment  = checkString(request.getParameter("EditReceiveComment")),
           sEditProductStockDocumentUid = checkString(request.getParameter("EditProductStockDocumentUid")),
           sEditProductStockDocumentUidText = "",
           sProductUid			= checkString(request.getParameter("EditProductUid")),
           sForceNew			= checkString(request.getParameter("forcenew")),
           sEditProductStockUid = checkString(request.getParameter("EditProductStockUid"));

    // lookup productName if none provided
    if(sEditProductStockUid.length() > 0){
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if(productStock!=null){
            sEditProductName = productStock.getProduct().getName();
            sServiceStockUid = productStock.getServiceStockUid();
            sProductUid = productStock.getProductUid();
        }
    }
    
    //Fill-in parameters if EditReferenceOperationUid has been provided
    if(sEditReferenceOperationUid.length()>0 && sForceNew.length()>0){
    	ProductStockOperation operation = ProductStockOperation.get(sEditReferenceOperationUid);
    	if(operation.getDescription().equalsIgnoreCase("medicationdelivery.2")){
    		sEditOperationDescr = "medicationreceipt.1";
    		sEditUnitsChanged = (operation.getUnitsChanged()-operation.getUnitsReceived())+"";
    		sEditRemaining = (operation.getUnitsChanged()-operation.getUnitsReceived())+"";
    		sEditSrcDestType = operation.getSourceDestination().getObjectType();
    		sEditSrcDestUid = operation.getSourceDestination().getObjectUid();
    		sEditSrcDestName = operation.getProductStock().getServiceStock().getName();
    		sEditBatchNumber = checkString(operation.getBatchNumber());
    		sEditBatchUid = checkString(operation.getBatchUid());
    		
    		if(operation.getBatchEnd()!=null){
    			sEditBatchEnd = new SimpleDateFormat("dd/MM/yyyy").format(operation.getBatchEnd());
    		}
    		else{
    			sEditBatchEnd = "?";
    		}
    		
    		sEditProductStockDocumentUid = checkString(operation.getDocumentUID());
    	}
    }

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n######### pharmacy/medication/popups/receiveMedicationPopup.jsp #########");
        Debug.println("sEditOperationUid    : "+sEditOperationUid);
        Debug.println("sEditReferenceOperationUid    : "+sEditReferenceOperationUid);
        Debug.println("sEditOperationDescr  : "+sEditOperationDescr);
        Debug.println("sEditUnitsChanged    : "+sEditUnitsChanged);
        Debug.println("sEditSrcDestType     : "+sEditSrcDestType);
        Debug.println("sEditSrcDestUid      : "+sEditSrcDestUid);
        Debug.println("sEditSrcDestName     : "+sEditSrcDestName);
        Debug.println("sEditOperationDate   : "+sEditOperationDate);
        Debug.println("sEditProductName     : "+sEditProductName);
        Debug.println("sEditBatchUid     	  : "+sEditBatchUid);
        Debug.println("sEditProductStockUid : "+sEditProductStockUid+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sSelectedOperationDescr = "", sSelectedSrcDestType = "",
           sSelectedSrcDestUid = "", sSelectedSrcDestName = "", sSelectedOperationDate = "",
           sSelectedProductName = "", sSelectedUnitsChanged = "", sSelectedProductStockUid = "";

    boolean displayEditFields = true;

    // default description
    if(sEditOperationDescr.length()==0){
        sEditOperationDescr = "operation.medicationreceipt";
    }

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE (receive) --------------------------------------------------------------------------
    if(sAction.equals("save") && sEditOperationUid.length()>0){
        //*** store 4 of the used values in session for later re-use ***
        String sPrevUsedOperationDescr = checkString((String)session.getAttribute("PrevUsedReceiptOperationDescr"));
        if(!sPrevUsedOperationDescr.equals(sEditOperationDescr)){
            session.setAttribute("PrevUsedReceiptOperationDescr",sEditOperationDescr);
        }

        String sPrevUsedSrcDestType = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestType"));
        if(!sPrevUsedSrcDestType.equals(sEditSrcDestType)){
            session.setAttribute("PrevUsedReceiptSrcDestType",sEditSrcDestType);
        }

        String sPrevUsedSrcDestUid = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestUid"));
        if(!sPrevUsedSrcDestUid.equals(sEditSrcDestUid)){
            session.setAttribute("PrevUsedReceiptSrcDestUid",sEditSrcDestUid);
        }

        String sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestName"));
        if(!sPrevUsedSrcDestName.equals(sEditSrcDestName)){
            session.setAttribute("PrevUsedReceiptSrcDestName",sEditSrcDestName);
        }

        String sPrevUsedDocument = checkString((String) session.getAttribute("PrevUsedReceiptDocument"));
        if(!sPrevUsedDocument.equals(sEditProductStockDocumentUid)){
            session.setAttribute("PrevUsedReceiptDocument", sEditProductStockDocumentUid);
        }

        //*** create product ***
        ProductStockOperation operation = new ProductStockOperation();
        operation.setUid(sEditOperationUid);
        operation.setDescription(sEditOperationDescr);
        //if the batchnumber does not exist yet, then create one if at least the batchnumber has been provided

        if(sEditBatchUid.length()==0 && sEditBatchNumber.length()>0){
        	//First we'll have a look if the batch doesn't already exist for this productStock
			Batch batch = Batch.getByBatchNumber(sEditProductStockUid,sEditBatchNumber);   
        	if(batch==null){
	        	batch = new Batch();
	        	batch.setUid("-1");
	        	batch.setProductStockUid(sEditProductStockUid);
	        	batch.setBatchNumber(sEditBatchNumber);
	            if(sEditBatchEnd.length()>0){
	            	try{
	            		batch.setEnd(ScreenHelper.stdDateFormat.parse(sEditBatchEnd));
	            	}
	            	catch(Exception e){
	            		
	            	}
	            }
	            batch.setComment(sEditBatchComment);
	            batch.setLevel(0);
	            batch.setCreateDateTime(new java.util.Date());
	            batch.setUpdateDateTime(new java.util.Date());
	            batch.setUpdateUser(activeUser.userid);
	            batch.store();
        	}
            sEditBatchUid = batch.getUid();
        }
        operation.setBatchUid(sEditBatchUid);
        operation.setDocumentUID(sEditProductStockDocumentUid);

        // sourceDestination
        ObjectReference sourceDestination = new ObjectReference();
        sourceDestination.setObjectType(sEditSrcDestType);
        if(sEditSrcDestType.equalsIgnoreCase("supplier")){
            sourceDestination.setObjectUid(sEditSrcDestName);
        }
        else{
            sourceDestination.setObjectUid(sEditSrcDestUid);
        }
        operation.setSourceDestination(sourceDestination);
        if(sEditOperationDate.length() > 0) operation.setDate(ScreenHelper.stdDateFormat.parse(sEditOperationDate));
        operation.setProductStockUid(sEditProductStockUid);
        if(sEditUnitsChanged.length() > 0) operation.setUnitsChanged(Integer.parseInt(sEditUnitsChanged));
        operation.setUpdateUser(activeUser.userid);

        String sResult = operation.store(false);
        if(sResult==null){
        	//In case this is a receipt operation linked to a delivery operation, update the delivery operation
        	if(sEditReferenceOperationUid.length()>0){
        		operation = ProductStockOperation.get(sEditReferenceOperationUid);
        		if(operation!=null){
        	        if(sEditUnitsChanged.length() > 0) operation.setUnitsReceived(operation.getUnitsReceived()+Integer.parseInt(sEditUnitsChanged));
        	        operation.setReceiveProductStockUid(sEditProductStockUid);
        	        operation.setReceiveComment(sEditReceiveComment);
        	        operation.store();
        		}
        	}

	        // reload opener to see the change in level
	        %>
			  <script>
				if(window.opener.document.getElementById("EditServiceStockUid") && window.opener.document.getElementById("ServiceId")){
				  window.opener.location.href = "main.do?Page=pharmacy/manageProductStocks.jsp"+
						                        "&Action=findShowOverview"+
						                        "&EditServiceStockUid="+window.opener.document.getElementById("EditServiceStockUid").value+
						                        "&ServiceId="+window.opener.document.getElementById("ServiceId").value+
						                        "&DisplaySearchFields=false";
				}
	         	window.close();
	          </script>
	        <%
        }
        else{
            %>
              <script>
                alert("<%=getTranNoLink("web",sResult,sWebLanguage)%>");
              </script>
            <%
            sAction = "showDetailsNew";
        }
    }

    //--- RECEIVE MEDICATION ----------------------------------------------------------------------
    if(sAction.equals("receiveMedication")){
        //*** set medication delivery defaults ***

        // reuse description-value from session
        if(sEditReferenceOperationUid.length()==0){
	        String sPrevUsedOperationDescr = checkString((String)session.getAttribute("PrevUsedReceiptOperationDescr"));
	        if(sPrevUsedOperationDescr.length() > 0) sEditOperationDescr = sPrevUsedOperationDescr;
	        else                                     sEditOperationDescr = "operation.medicationreceipt"; // default
	        
	        // reuse srcdestType-value from session
	        String sPrevUsedSrcDestType = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestType"));
	        if(sPrevUsedSrcDestType.length() > 0) sEditSrcDestType = sPrevUsedSrcDestType;
	        else                                  sEditSrcDestType = sDefaultSrcDestType; // default
	        
	        // reuse srcdestUid-value from session
	        String sPrevUsedSrcDestUid = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestUid"));
	        if(sPrevUsedSrcDestUid.length() > 0) sEditSrcDestUid = sPrevUsedSrcDestUid;
	        else{
	            if(activePatient!=null) sEditSrcDestUid = activePatient.personid; // default
	            else                    sEditSrcDestUid = "";
	        }
	        
	        // reuse srcdestName-value from session
	        String sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestName"));
	        if(sPrevUsedSrcDestName.length() > 0) sEditSrcDestName = sPrevUsedSrcDestName;
	        else{
	            if(activePatient!=null) sEditSrcDestName = activePatient.firstname+" "+activePatient.lastname; // default
	            else                    sEditSrcDestName = "";
	        }
	        
	        String sPrevUsedDocument = checkString((String) session.getAttribute("PrevUsedReceiptDocument"));
	        if(sEditProductStockDocumentUid.length()==0 && sPrevUsedDocument.length() > 0){
	        	sEditProductStockDocumentUid = sPrevUsedDocument;
	        }
	        if(sEditProductStockDocumentUid.length() > 0){
	        	sEditProductStockDocumentUidText = getTran("operationdocumenttypes",OperationDocument.get(sEditProductStockDocumentUid).getType(),sWebLanguage);
	        }
	        
        	sEditUnitsChanged = "1";
        }

        sEditOperationDate = ScreenHelper.stdDateFormat.format(new java.util.Date()); // now
        sAction = "showDetailsNew";
    }

    //--- SHOW DETAILS NEW ------------------------------------------------------------------------
    if(sAction.equals("showDetailsNew")){
        sSelectedOperationDescr  = sEditOperationDescr;
        sSelectedUnitsChanged    = sEditUnitsChanged;
        sSelectedSrcDestType     = sEditSrcDestType;
        sSelectedSrcDestUid      = sEditSrcDestUid;
        sSelectedSrcDestName     = sEditSrcDestName;
        sSelectedOperationDate   = sEditOperationDate;

        sSelectedProductStockUid = sEditProductStockUid;
        sSelectedProductName     = sEditProductName;
    }
%>

<script>
  var setMaxQuantity = <%=sEditReferenceOperationUid.length()>0?sEditUnitsChanged:"1"%>;

  function validateMaxFocus(o){
    if(o.value*1>setMaxQuantity){
      alert('<%=getTran("web","maxvalueis",sWebLanguage)%> '+setMaxQuantity);
      o.focus();
      return false;
    }
    return true;
  }

  function validateMax(o){
    if(o.value*1>setMaxQuantity){
      alert('<%=getTran("web","maxvalueis",sWebLanguage)%> '+setMaxQuantity);
      return false;
    }
    return true;
  }

  function showBatchInfo(){
    if(document.getElementById("EditSrcDestType")[document.getElementById("EditSrcDestType").selectedIndex].value=="servicestock"){
      if(transactionForm.EditSrcDestUid.value.length>0){
        var params = "";
        var today = new Date();
	    var url= '<c:url value="/pharmacy/medication/ajax/getProductStockBatches.jsp"/>?destinationproductstockuid=<%=sEditProductStockUid%>&sourceservicestockuid='+transactionForm.EditSrcDestUid.value+'&ts='+today;
	    new Ajax.Request(url,{
	      method: "POST",
	      parameters: params,
	      onSuccess: function(resp){
	        $("batch").innerHTML = resp.responseText;
	      }
	    }); 
    }
    else{
	  document.getElementById("batch").innerHTML="";
	}
	setTimeout("updateMaxVal();",500);
  }
  else if(document.getElementById("EditSrcDestType")[document.getElementById("EditSrcDestType").selectedIndex].value=="supplier"){
    document.getElementById("batch").innerHTML = "<table>"+
                                                  "<tr><td><%=getTran("web","batch.number",sWebLanguage)%></td><td><input type='text' name='EditBatchNumber' value='' size='40'/></td></tr>"+
                                                  "<tr><td><%=getTran("web","batch.expiration",sWebLanguage)%></td><td><%=writeDateField("EditBatchEnd","transactionForm","",sWebLanguage)%></td></tr>"+
                                                  "<tr><td><%=getTran("web","comment",sWebLanguage)%></td><td><input type='text' name='EditBatchComment' value='' size='80'/></td></tr>"+
                                                 "</table>";
    setMaxQuantityValue(999999);
  }		
    else if(document.getElementById("EditSrcDestType")[document.getElementById("EditSrcDestType").selectedIndex].value=="patient"){
      document.getElementById("batch").innerHTML = "<table>"+
                                                    "<tr><td><%=getTran("web","batch.number",sWebLanguage)%></td><td><input type='text' name='EditBatchNumber' value='' size='40'/></td></tr>"+
                                                    "<tr><td><%=getTran("web","comment",sWebLanguage)%></td><td><input type='text' name='EditBatchComment' value='' size='80'/></td></tr>"+
                                                   "</table>";
      setMaxQuantityValue(999999);  
    }	
    else{
      document.getElementById("batch").innerHTML = "";
      setMaxQuantityValue(999999);
    }
  }

  function setMaxQuantityValue(mq){
    setMaxQuantity = mq;
    if(document.getElementById("EditUnitsChanged").value*1>setMaxQuantity*1){
      document.getElementById("maxquantity").innerHTML = " <img src='<c:url value="/_img/warning.gif"/>'/> <font color='red'><b> &gt;"+setMaxQuantity+"</b></font>";
    }
    else{
      document.getElementById("maxquantity").innerHTML = "";
    }
  }

  function updateMaxVal(){
    var uids = document.getElementsByName("EditBatchUid");
    for(i=0; i<uids.length; i++){
      if(uids[i].checked){
        uids[i].onclick();
      }
    }
  }
</script>

<%
	//eerst verifiëren of er voor dit product geen leveringen in de wacht staan
	//indien ja, toon de wachtende leveringen (en zet displayEditFields=false)
	//indien neen, toon een generiek ontvangstschermpje
	if(sForceNew.length()==0 && sServiceStockUid.length()>0 && sProductUid.length()>0){
		Vector openDeliveries = ProductStockOperation.getOpenProductStockDeliveries(sServiceStockUid, sProductUid);
		if(openDeliveries.size()>0){
			displayEditFields=false;
			out.println("<label class='text'>"+getTran("web","open.deliveries.exist",sWebLanguage)+"</label>");
			out.println("<table width='100%'>");
			out.println("<tr class='admin'><td>ID</td><td>"+getTran("web","date",sWebLanguage)+"</a></td><td>"+getTran("web","source",sWebLanguage)+"</td><td>"+getTran("web","quantity",sWebLanguage)+"</td></tr>");
			for (int n = 0; n<openDeliveries.size(); n++){
				ProductStockOperation productStockOperation = (ProductStockOperation)openDeliveries.elementAt(n);
				out.print("<tr class='admin2'><td>"+productStockOperation.getOperationUID()+"</td><td><a href='javascript:selectOpenDelivery(\""+productStockOperation.getUid()+"\")'>"+new SimpleDateFormat("dd/MM/yyyy").format(productStockOperation.getDate())+"</a></td>");
				out.print("<td>"+productStockOperation.getProductStock().getServiceStock().getName()+"</td>");
				out.print("<td>"+(productStockOperation.getUnitsChanged()-productStockOperation.getUnitsReceived())+(productStockOperation.getUnitsReceived()>0?" ("+productStockOperation.getUnitsChanged()+"-"+productStockOperation.getUnitsReceived()+")":"")+"</td></tr>");
			}
			out.println("</table>");
			%>
			<p/>
			<a href='<c:url value="/popup.jsp"/>?Page=pharmacy/medication/popups/receiveMedicationPopup.jsp&Action=receiveMedication&forcenew=1&ts=<%=getTs()%>&EditProductStockUid=<%=sEditProductStockUid%>&PopupWidth=<%=request.getParameter("PopupWidth") %>&PopupHeight=<%=request.getParameter("PopupHeight") %>'><label class='text'><%=getTran("web","create.new.reception",sWebLanguage)%></label></a>
			<%
		}
	}
	
%>
<script>
  function selectOpenDelivery(operationUid){
    window.location.href = '<c:url value="/popup.jsp"/>?Page=pharmacy/medication/popups/receiveMedicationPopup.jsp&Action=receiveMedication&forcenew=1&ts=<%=getTs()%>&EditReferenceOperationUid='+operationUid+'&EditProductStockUid=<%=sEditProductStockUid%>&PopupWidth=<%=request.getParameter("PopupWidth") %>&PopupHeight=<%=request.getParameter("PopupHeight") %>';
  }
</script>
<%
		//*****************************************************************************************
		//*** process display options *************************************************************
		//*****************************************************************************************
		
		//--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
			<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/popup.jsp"/>?Page=pharmacy/medication/popups/receiveMedicationPopup.jsp&ts=<%=getTs()%>' onClick="clearMessage();">
			    <%-- page title --%>
			    <%=writeTableHeader("Web.manage","receiveproducts",sWebLanguage,"")%>
                <table class="list" width="100%" cellspacing="1">
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>"/>
                            <input type="hidden" name="EditProductStockName" value="<%=sSelectedProductName%>"/>
                            <input type="hidden" name="EditReferenceOperationUid" value="<%=sEditReferenceOperationUid %>"/>
                            <%=sSelectedProductName%>
                        </td>
                    </tr>
                    <%-- description --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","description",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                        	<%
                        		if(sEditReferenceOperationUid.length()>0){
                        	%>
                        		<label class='text'><%=getTran("productstockoperation.medicationreceipt",sSelectedOperationDescr,sWebLanguage)%></label>
                        		<input class='text' type='hidden' name='EditOperationDescr' value='<%=sSelectedOperationDescr %>'/>
                        	<%
                        		}
                        		else {
                        	%>
	                            <select class="text" name="EditOperationDescr" id="EditOperationDescr"  onChange="displaySrcDestSelector();" style="vertical-align:-2px;">
	                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
	                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationreceipt",sSelectedOperationDescr,sWebLanguage)%>
	                            </select>
                            <%
                        		}
                            %>
                        </td>
                    </tr>
                    <%-- units changed --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","unitschanged",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" id="EditUnitsChanged" size="10" maxLength="10" value="<%=sSelectedUnitsChanged%>" onKeyUp="if(this.value=='0'){this.value='';}isNumber(this);setMaxQuantityValue(setMaxQuantity);" <%=(sAction.equals("showDetails")?"READONLY":"")%>><span id="maxquantity"></span>
                        </td>
                    </tr>
                    <%-- SourceDestination type --%>
                    <tr height="23" id="sourceline">
                        <td class="admin"><%=getTran("web","receivedfrom",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                        	<%
                        		if(sEditReferenceOperationUid.length()>0){
                        	%>
                        		<label class='text'><%=getTran("productstockoperation.sourcedestinationtype",sSelectedSrcDestType,sWebLanguage)%>: <%=sSelectedSrcDestName %></label>
                        		<input class='text' type='hidden' name='EditSrcDestType'  id="EditSrcDestType" value='<%=sSelectedSrcDestType %>'/>
                        		<input class='text' type='hidden' name='EditSrcDestUid'  id="EditSrcDestUid" value='<%=sSelectedSrcDestUid %>'/>
							<%
                        		}
                        		else{
							%>
	                            <select class="text" name="EditSrcDestType" id="EditSrcDestType" onchange="displaySrcDestSelector();" style="vertical-align:-2px;" >
	                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
	                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.sourcedestinationtype",sSelectedSrcDestType,sWebLanguage)%>
	                            </select>
	                            
	                            <%-- SOURCE DESTINATION SELECTOR --%>
	                            <span id="SrcDestSelector" style='visibility:hidden;'>
	                                <input class="text" type="text" name="EditSrcDestName" id="EditSrcDestName" onchange="if(document.getElementById('EditSrcDestType')[document.getElementById('EditSrcDestType').selectedIndex].value=='servicestock'){showBatchInfo();}" readonly size="<%=sTextWidth%>" value="<%=sSelectedSrcDestName%>">
	                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
	                                <input type="hidden" name="EditSrcDestUid" id="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
	                            </span>
                            <%
                        		}
                            %>
                        </td>
                    </tr>
                    <tr id='documentline'>
                        <td class="admin"><%=getTran("Web","productstockoperationdocument",sWebLanguage)%></td>
	                    <td class="admin2">
	                    	<input type='text' class='text' name='EditProductStockDocumentUid' id='EditProductStockDocumentUid' size='10' value="<%=sEditProductStockDocumentUid %>" readonly/>
	                    	<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick="searchDocument('EditProductStockDocumentUid','EditProductStockDocumentUidText');">&nbsp;
	                    	<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick="transactionForm.EditProductStockDocumentUid.value='';document.getElementById('EditProductStockDocumentUidText').innerHTML='';">
	                    	<label class='text' name='EditProductStockDocumentUidText' id='EditProductStockDocumentUidText'><%=sEditProductStockDocumentUidText %></label>
	                    </td>
                    </tr>
	                    
                    <%
                    	if(sEditReferenceOperationUid.length()>0){
	                     	%>
	                      		<tr> 
	                      		    <td class="admin"><%=getTran("web","receivecomment",sWebLanguage)%></td>
	                      		    <td><textarea class='text' name='EditReceiveComment'  id="EditReceiveComment"></textarea></td>
	                      		<tr>
						    <%
                      	}
					%>
                    <tr>
                        <td class="admin"><%=getTran("Web","batch",sWebLanguage)%></td>
                        <td class="admin2"><div id="batch" name="batch"/></td>
                    </tr>
                    <%
                        // get previous used values to reuse in javascript
                        String sPrevUsedSrcDestType  = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestType")),
                        	sPrevUsedSrcDestUid  = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestUid")),
                        	sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedReceiptSrcDestName"));
                        String supplierCode = "";

                        if(sPrevUsedSrcDestUid.length()==0){
                            if(sSelectedProductStockUid.length() > 0){
                                // get supplier service from product
                                ProductStock productStock = ProductStock.get(sSelectedProductStockUid);
                                if(productStock!=null){
                                    supplierCode = checkString(productStock.getProduct().getSupplierUid());
                                }

                                // get default-supplier from serviceStock if not specified in product
                                if(supplierCode.length()==0){
                                    supplierCode = checkString(productStock.getServiceStock().getDefaultSupplierUid());
                                }
                            }
                        }
                    %>
                    
                    <script>
                      var prevSrcDestType;
                      <%=sEditReferenceOperationUid.length()==0?"displaySrcDestSelector();":""%>

                      <%-- DISPLAY SOURCE DESTINATION SELECTOR --%>
                      function displaySrcDestSelector(){
                        var srcDestType, emptyEditSrcDest, srcDestUid, srcDestName;
                        transactionForm.EditSrcDestUid.value = "";
                        transactionForm.EditSrcDestName.value = "";
                        
						// For specific EditOperationDescr values, an EditSrcDestType value may be forced
						if('<%=MedwanQuery.getInstance().getConfigString("forceservicestockforproductstockoperations","medicationreceipt.1")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
							transactionForm.EditSrcDestType.value='servicestock';
						}
						if('<%=MedwanQuery.getInstance().getConfigString("forcepatientforproductstockoperations","medicationreceipt.2")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
							transactionForm.EditSrcDestType.value='patient';
						}
						if('<%=MedwanQuery.getInstance().getConfigString("forceproviderforproductstockoperations","medicationreceipt.4")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
							transactionForm.EditSrcDestType.value='supplier';
						}
						if('<%=MedwanQuery.getInstance().getConfigString("productstockoperationswithoutsource","medicationreceipt.3*medicationreceipt.99")%>'.indexOf(document.getElementById('EditOperationDescr').value)>-1){
							document.getElementById('sourceline').style.visibility="hidden";
							document.getElementById('documentline').style.visibility="hidden";
							document.getElementById('EditProductStockDocumentUid').value='';
							document.getElementById('EditProductStockDocumentUidText').innerHTML='';
							transactionForm.EditSrcDestType.value="";
                          	document.getElementById('SrcDestSelector').style.visibility = 'hidden';
						}
						else{
						  document.getElementById('sourceline').style.visibility="visible";
						}
                        srcDestType = transactionForm.EditSrcDestType.value;
                        if(srcDestType.length > 0){
                          	document.getElementById('SrcDestSelector').style.visibility = 'visible';

                          	<%-- service --%>
                          	if(srcDestType.indexOf('service') > -1){
    							<%
									if(MedwanQuery.getInstance().getConfigInt("productstockoperationdocumentmandatory",1)!=1){
										%>
			                            	document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
			                                                                                             +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';document.getElementById('batch').innerHTML='';setMaxQuantityValue(999999);\">";
			   	                            document.getElementById('EditSrcDestName').readOnly=true;
			   	                        <%
									}
	   	                        %>
								document.getElementById('documentline').style.visibility="visible";

                            	if('<%=sPrevUsedSrcDestUid%>'.length > 0 && '<%=sPrevUsedSrcDestType%>'.indexOf('service') > -1 && '<%=sPrevUsedSrcDestUid%>'!='<%=sServiceStockUid%>'){
                              		transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                              		transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                            	}
                            	else{
                              		transactionForm.EditSrcDestUid.value = "";
                              		transactionForm.EditSrcDestName.value = "";
                            	}
                          	}
	                        else if(srcDestType.indexOf('supplier') > -1){
								document.getElementById('documentline').style.visibility="visible";
    							<%
	    							if(MedwanQuery.getInstance().getConfigInt("productstockoperationdocumentmandatory",1)!=1){
										%>document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";<%
									}
	   	                        %>

	                            document.getElementById('EditSrcDestName').readOnly=false;
								if('<%=sPrevUsedSrcDestName%>'.length > 0 && '<%=sPrevUsedSrcDestType%>'.indexOf('supplier') > -1){
									transactionForm.EditSrcDestUid.value = "";
									transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
								}
								else{
									transactionForm.EditSrcDestUid.value = "";
									transactionForm.EditSrcDestName.value = "";
								}
	                        }
	                        else if(srcDestType.indexOf('patient') > -1){
								document.getElementById('documentline').style.visibility="hidden";
                            	document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                             +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';document.getElementById('batch').innerHTML='';setMaxQuantityValue(999999);\">";
								document.getElementById('EditSrcDestName').readOnly=true;
								
								if('<%=sPrevUsedSrcDestUid%>'.length > 0 && '<%=sPrevUsedSrcDestType%>'.indexOf('patient') > -1){
									transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
									transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
								}
								else{
									if(<%=activePatient!=null?"true":"false"%> && transactionForm.EditSrcDestUid.value==''){
										transactionForm.EditSrcDestUid.value='<%=activePatient==null?"":activePatient.personid%>';
										transactionForm.EditSrcDestName.value='<%=activePatient==null?"":activePatient.lastname.toUpperCase()+", "+activePatient.firstname.toUpperCase()%>';
									}
									else{
										transactionForm.EditSrcDestUid.value = "";
										transactionForm.EditSrcDestName.value = "";
									}

								}
	                        }
                        }
                        prevSrcDestType = srcDestType;
                        showBatchInfo();
                      }
                    </script>

                    <%-- operation date --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","date",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2"><%=writeDateField("EditOperationDate","transactionForm",sSelectedOperationDate,sWebLanguage)%></td>
                    </tr>
                </table>

                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

                <%-- display message --%>
                <br><span id="msgArea"><%=msg%></span>

                <%-- EDIT BUTTONS --%>
                <%=ScreenHelper.alignButtonsStart()%>
                    <%
                        if(sAction.equals("showDetailsNew")){
                            %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","receive",sWebLanguage)%>' onclick="doReceive();"><%
                        }
                    %>
                    <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>' onclick='window.close();'>
                <%=ScreenHelper.alignButtonsStop()%>
                
			    <%-- hidden fields --%>
			    <input type="hidden" name="Action">
			    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
			</form>
            <%
        }
    %>
    
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  window.resizeTo(700,270);
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }
  %>

  <%-- DO RECEIVE --%>
  function doReceive(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditOperationDescr.value.length==0){
        transactionForm.EditOperationDescr.focus();
      }
      else if(transactionForm.EditUnitsChanged.value.length==0){
        transactionForm.EditUnitsChanged.focus();
      }
      else if(transactionForm.EditSrcDestType.value.length==0){
        transactionForm.EditSrcDestType.focus();
      }
      else if(transactionForm.EditSrcDestUid.value.length==0){
        transactionForm.EditSrcDestName.focus();
      }
      else if(transactionForm.EditOperationDate.value.length==0){
        transactionForm.EditOperationDate.focus();
      }
    }
  }

  <%-- CHECK STOCK FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditOperationDescr.value.length>0 ||
       !transactionForm.EditUnitsChanged.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !transactionForm.EditProductStockUid.value.length>0){
      maySubmit = false;

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }
    
	if(maySubmit){
	  maySubmit = validateMax(document.getElementById('EditUnitsChanged'));
	}
	
    return maySubmit;
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditOperationDescr.value = "";
    transactionForm.EditUnitsChanged.value = "";
    transactionForm.EditSrcDestName.value = "";
    transactionForm.EditOperationDate.value = "";
    transactionForm.EditProductStockUid.value = "";
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    <%
        String productuid = "",excludeServiceUid = "";
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if(productStock!=null){
            productuid = productStock.getProductUid();
            excludeServiceUid=productStock.getServiceStockUid();
        }
    %>
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceUidField+"&ReturnServiceStockNameField="+serviceNameField+"&SearchProductUid=<%=productuid%>&SearchProductLevel="+document.all['EditUnitsChanged'].value+"&ExcludeServiceStockUid=<%=excludeServiceUid%>");
  }

  <%-- popup : search patient --%>
  function searchPatient(patientUidField,patientNameField){
    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnName="+patientNameField+"&displayImmatNew=no&isUser=no");
  }

  <%-- popup : search doctor --%>
  function searchDoctor(doctorUidField,doctorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+"&ReturnName="+doctorNameField+"&displayImmatNew=no&isUser=yes");
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }
  
  <%-- popup : search document --%>
  function searchDocument(documentUidField,documentUidTextField){
	<%
	    String sDocumentSource = "", sDocumentSourceText = "", sFindMinDate = "";
		ProductStock p = ProductStock.get(sEditProductStockUid);
		if(p!=null && p.getServiceStockUid()!=null){
			sDocumentSource = p.getServiceStockUid();
			sDocumentSourceText = p.getServiceStock().getName();
			sFindMinDate = new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date().getTime()-7*24*3600*1000);
		}			
	%>
    openPopup("/_common/search/searchStockOperationDocument.jsp&ts=<%=getTs()%>&documentuid="+document.getElementById("EditProductStockDocumentUid").value+"&finddocumentsource=<%=sDocumentSource%>&finddocumentmindate=<%=sFindMinDate%>&finddocumentsourcetext=<%=sDocumentSourceText%>&ReturnDocumentID="+documentUidField+"&ReturnDocumentName="+documentUidTextField+"&ReturnSourceName=EditSrcDestName");
  }

  <%=sEditReferenceOperationUid.length()==0?"displaySrcDestSelector();":""%>
  <%
      if(sEditReferenceOperationUid.length()>0){
   	      // Show batch information
   	      String sBatchInfo="<input type=\"radio\" checked/>"+(sEditBatchNumber!=null?sEditBatchNumber:"?")+" ("+sEditUnitsChanged+" - exp. "+sEditBatchEnd+")";
   	      sBatchInfo+="<input type=\"hidden\" name=\"EditBatchUid\" value= \""+sEditBatchUid+"\"/>";
   	      out.print("document.getElementById('batch').innerHTML='"+sBatchInfo+"';");
      }
  %>
</script>