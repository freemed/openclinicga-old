<%@page import="be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.pharmacy.Batch,
                be.openclinic.pharmacy.ProductStock"%>
<%@ page import="be.openclinic.medical.Prescription" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationdelivery","all",activeUser)%>
<%
    String centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode"),
            sDefaultSrcDestType = "patient";

    // action
    String sAction = checkString(request.getParameter("Action"));
    if (sAction.length() == 0) sAction = "deliverMedication"; // default
	Hashtable availableProductStocks = new Hashtable();
    Vector availableProductStocksVector = new Vector();
    int iMaxQuantity=99;
    int iMaxStock=0;

    // retreive form data
    String sEditOperationUid = checkString(request.getParameter("EditOperationUid")),
            sEditOperationDescr = checkString(request.getParameter("EditOperationDescr")),
            sEditUnitsChanged = checkString(request.getParameter("EditUnitsChanged")),
            sEditSrcDestType = checkString(request.getParameter("EditSrcDestType")),
            sEditSrcDestUid = checkString(request.getParameter("EditSrcDestUid")),
            sEditSrcDestName = checkString(request.getParameter("EditSrcDestName")),
            sEditProductName = checkString(request.getParameter("EditProductName")),
            sEditOperationDate = checkString(request.getParameter("EditOperationDate")),
            sEditProductStockUid = checkString(request.getParameter("EditProductStockUid")),
            sEditBatchUid = checkString(request.getParameter("EditBatchUid")),
            sEditServiceStockUid = "",
            sEditServiceStockName = "",
            sEditPrescriptionUid = checkString(request.getParameter("EditPrescriptionUid"));
    Prescription prescription=null;
    if (sEditUnitsChanged.length()==0 && sEditPrescriptionUid.length() > 0){
        prescription = Prescription.get(sEditPrescriptionUid);
        if (prescription!=null) {
            sEditUnitsChanged = (prescription.getRequiredPackages()-prescription.getDeliveredQuantity())+"";
            iMaxQuantity=new Double(Double.parseDouble(sEditUnitsChanged)).intValue();
        }
    }
    // lookup available productStocks if none provided
    if (sEditProductStockUid.length() == 0 && sEditPrescriptionUid.length() > 0) {
    	if(prescription!=null){
			Vector productStocks=ProductStock.find("",prescription.getProductUid(),"1","","","","","","","","","OC_STOCK_LEVEL","DESC");
			for(int n=0;n<productStocks.size();n++){
				ProductStock productStock = (ProductStock)productStocks.elementAt(n);
	            sEditProductName = productStock.getProduct().getName()+" ("+productStock.getProduct().getPackageUnits()+" "+getTranNoLink("product.unit",productStock.getProduct().getUnit(),sWebLanguage)+")";
				ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
				if(stock.isAuthorizedUser(activeUser.userid)){
					availableProductStocksVector.add(productStock);
					availableProductStocks.put(productStock,stock);
				}
			}
        }
    }
    else if (sEditProductStockUid.length() > 0 && sEditProductName.length() == 0) {
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if (productStock != null) {
            sEditProductName = productStock.getProduct().getName();
			ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
			if(stock.isAuthorizedUser(activeUser.userid)){
				availableProductStocksVector.add(productStock);
				availableProductStocks.put(productStock,stock);
			}
        }
    }
    else if (sEditProductStockUid.length() > 0) {
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if (productStock != null) {
			ServiceStock stock = ServiceStock.get(productStock.getServiceStockUid());
			if(stock.isAuthorizedUser(activeUser.userid)){
				availableProductStocksVector.add(productStock);
				availableProductStocks.put(productStock,stock);
			}
        }
    }

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("\n\n################## sAction : " + sAction + " ############################");
        Debug.println("* sEditOperationUid    : " + sEditOperationUid);
        Debug.println("* sEditOperationDescr  : " + sEditOperationDescr);
        Debug.println("* sEditUnitsChanged    : " + sEditUnitsChanged);
        Debug.println("* sEditSrcDestType     : " + sEditSrcDestType);
        Debug.println("* sEditSrcDestUid      : " + sEditSrcDestUid);
        Debug.println("* sEditSrcDestName     : " + sEditSrcDestName);
        Debug.println("* sEditOperationDate   : " + sEditOperationDate);
        Debug.println("* sEditProductName     : " + sEditProductName);
        Debug.println("* sEditProductStockUid : " + sEditProductStockUid + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "", sSelectedOperationDescr = "", sSelectedSrcDestType = "",
            sSelectedSrcDestUid = "", sSelectedSrcDestName = "", sSelectedOperationDate = "",
            sSelectedProductName = "", sSelectedUnitsChanged = "", sSelectedProductStockUid = "";

    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // display options
    boolean displayEditFields = true;
    // default description
    if (sEditOperationDescr.length() == 0) {
        sEditOperationDescr = MedwanQuery.getInstance().getConfigString("defaultMedicationDeliveryType","medicationdelivery.typeb1");
    }

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE (deliver) --------------------------------------------------------------------------
    if (sAction.equals("save") && sEditOperationUid.length() > 0) {
        //*** store 4 of the used values in session for later re-use ***
        String sPrevUsedOperationDescr = checkString((String) session.getAttribute("PrevUsedDeliveryOperationDescr"));
        if (!sPrevUsedOperationDescr.equals(sEditOperationDescr)) {
            session.setAttribute("PrevUsedDeliveryOperationDescr", sEditOperationDescr);
        }

        String sPrevUsedSrcDestType = checkString((String) session.getAttribute("PrevUsedDeliverySrcDestType"));
        if (sPrevUsedSrcDestType.equals(sEditSrcDestType)) {
            session.setAttribute("PrevUsedDeliverySrcDestType", sEditSrcDestType);
        }

        String sPrevUsedSrcDestUid = checkString((String) session.getAttribute("PrevUsedDeliverySrcDestUid"));
        if (!sPrevUsedSrcDestUid.equals(sEditSrcDestUid)) {
            session.setAttribute("PrevUsedDeliverySrcDestUid", sEditSrcDestUid);
        }

        String sPrevUsedSrcDestName = checkString((String) session.getAttribute("PrevUsedDeliverySrcDestName"));
        if (!sPrevUsedSrcDestName.equals(sEditSrcDestName)) {
            session.setAttribute("PrevUsedDeliverySrcDestName", sEditSrcDestName);
        }

        //*** create product ***
        ProductStockOperation operation = new ProductStockOperation();
        operation.setUid(sEditOperationUid);
        operation.setDescription(sEditOperationDescr);
        operation.setBatchUid(sEditBatchUid);

        // sourceDestination
        ObjectReference sourceDestination = new ObjectReference();
        sourceDestination.setObjectType(sEditSrcDestType);
        sourceDestination.setObjectUid(sEditSrcDestUid);
        operation.setSourceDestination(sourceDestination);
        if (sEditOperationDate.length() > 0) operation.setDate(stdDateFormat.parse(sEditOperationDate));
        operation.setProductStockUid(sEditProductStockUid);
        if (sEditUnitsChanged.length() > 0) operation.setUnitsChanged(new Double(sEditUnitsChanged).intValue());
        operation.setUpdateUser(activeUser.userid);
        operation.setPrescriptionUid(sEditPrescriptionUid);
        if(sEditProductStockUid.length()>0){
        	ProductStock productStock=ProductStock.get(sEditProductStockUid);
        	if(productStock!=null){
        		session.setAttribute("activeServiceStockUid",productStock.getServiceStockUid());
        	}
        }

        String sResult=operation.store();
        if(sResult==null){

        // reload opener to see the change in level
        %>
        
		<%@page import="be.openclinic.pharmacy.ServiceStock"%>
		<script>
			if(window.opener.document.getElementById('EditServiceStockUid') && window.opener.document.getElementById('ServiceId')){
				window.opener.location.href='<c:url value="/"/>main.do?Page=pharmacy/manageProductStocks.jsp&Action=findShowOverview&EditServiceStockUid='+window.opener.document.getElementById('EditServiceStockUid').value+'&DisplaySearchFields=false&ServiceId='+window.opener.document.getElementById('ServiceId').value;
			}
	        window.close();
        </script>
        <%
        }
        else {
        %>
        <script>
            alert('<%=getTranNoLink("web",sResult,sWebLanguage)%>');
        </script>
        <%
        sAction = "showDetailsNew";
        }
    }

    //--- DELIVER MEDICATION ----------------------------------------------------------------------
    if(sAction.equals("deliverMedication")){
        //*** set medication delivery defaults ***

        // reuse description-value from session
        String sPrevUsedOperationDescr = checkString((String)session.getAttribute("PrevUsedDeliveryOperationDescr"));
        if(sEditPrescriptionUid.length() == 0 && sPrevUsedOperationDescr.length() > 0) sEditOperationDescr = sPrevUsedOperationDescr;
        else                                     sEditOperationDescr = MedwanQuery.getInstance().getConfigString("defaultMedicationDeliveryType","medicationdelivery.typeb1"); // default

        // reuse srcdestType-value from session
        String sPrevUsedSrcDestType = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestType"));
        if(sEditSrcDestType.length()==0 && sEditPrescriptionUid.length() == 0 && sPrevUsedSrcDestType.length() > 0) sEditSrcDestType = sPrevUsedSrcDestType;
        else                                  sEditSrcDestType = sDefaultSrcDestType; // default

        // reuse srcdestUid-value from session
        String sPrevUsedSrcDestUid = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid"));
        if(sEditPrescriptionUid.length() == 0 && sPrevUsedSrcDestUid.length() > 0) sEditSrcDestUid = sPrevUsedSrcDestUid;
        else{
            if(activePatient!=null) sEditSrcDestUid = activePatient.personid; // default
            else                    sEditSrcDestUid = "";
        }

        // reuse srcdestName-value from session
        String sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
        if(sEditSrcDestName.length()==0 && sEditPrescriptionUid.length() == 0 && sPrevUsedSrcDestName.length() > 0) {
            sEditSrcDestName = sPrevUsedSrcDestName;
        }
        else{
            if(activePatient!=null) sEditSrcDestName = activePatient.firstname+" "+activePatient.lastname; // default
            else                    sEditSrcDestName = "";
        }

        sEditOperationDate = stdDateFormat.format(new java.util.Date()); // now
        if(sEditUnitsChanged.length()==0) {
            sEditUnitsChanged = "1";
        }

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
<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/template.jsp"/>?Page=pharmacy/medication/popups/deliverMedicationPopup.jsp&ts=<%=getTs()%>' onKeyDown="if(enterEvent(event,13)){doDeliver();}" onClick="clearMessage();">
    <%-- page title --%>
    <%=writeTableHeader("Web.manage","deliverproducts",sWebLanguage,"")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- Product name --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <b><%=sSelectedProductName%></b>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web","pharmacy",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <%
                            	String productStockBatches="";
                            	Iterator e = availableProductStocksVector.iterator();
                            	while(e.hasNext()){
                            		ProductStock productStock = (ProductStock)e.next();
                            		ServiceStock serviceStock = (ServiceStock)availableProductStocks.get(productStock);
                            		out.println("<input onclick='totalStock="+productStock.getLevel()+";setMaxQuantityValue("+(iMaxQuantity<productStock.getLevel()?iMaxQuantity:productStock.getLevel())+");showBatches();' type='radio' "+(serviceStock.getUid().equalsIgnoreCase((String)session.getAttribute("activeServiceStockUid"))||availableProductStocks.size()==1?"checked":"")+" name='EditProductStockUid' value='"+productStock.getUid()+"'><font "+(productStock.getLevel()<iMaxQuantity?"color='red'>":">")+serviceStock.getName()+" ("+productStock.getLevel()+")</font><br/>");
									if(serviceStock.getUid().equalsIgnoreCase((String)session.getAttribute("activeServiceStockUid"))||availableProductStocks.size()==1){
										iMaxStock=productStock.getLevel();
									}
                            		Vector batches = Batch.getBatches(productStock.getUid());
                        			if(productStockBatches.length()>0){
                        				productStockBatches+="£";
                        			}
									productStockBatches+=productStock.getUid();
                            		for(int n=0;n<batches.size();n++){
                            			Batch batch = (Batch)batches.elementAt(n);
                            			productStockBatches+="$"+batch.getUid()+";"+batch.getBatchNumber()+";"+batch.getLevel()+";"+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+";"+batch.getComment();
                            		}
                            	}
                            	out.println("<script>var batches='"+productStockBatches+"';</script>");
                            %>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web","batch",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2"><div id="batch" name="batch"/></td>
                    </tr>
					<%
						if(prescription==null){
					%>
	                    <%-- description --%>
	                    <tr>
	                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","description",sWebLanguage)%>&nbsp;*</td>
	                        <td class="admin2">
	                            <select class="text" name="EditOperationDescr" onChange="displaySrcDestSelector();" style="vertical-align:-2;">
	                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
	                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.medicationdelivery",sSelectedOperationDescr,sWebLanguage)%>
	                            </select>
	                        </td>
	                    </tr>
	                <%
						}
						else {
	                %>
                           <input type="hidden" name="EditOperationDescr" value="<%=sSelectedOperationDescr%>">
	                <%
						}
	                %>
                    <%-- units changed --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","unitschanged",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" id="EditUnitsChanged" size="5" maxLength="5" value="<%=sSelectedUnitsChanged%>" onKeyUp="if(this.value=='0'){this.value='';}isNumber(this);setMaxQuantityValue(setMaxQuantity);" onblur="validateMaxFocus(this);" <%=(sAction.equals("showDetails")?"READONLY":"")%>><span id="maxquantity" name="maxquantity"/>
                        </td>
                    </tr>
					<%
						if(prescription==null){
					%>
	                    <%-- SourceDestination type --%>
	                    <tr height="23">
	                        <td class="admin"><%=getTran("web","deliveredto",sWebLanguage)%>&nbsp;*</td>
	                        <td class="admin2">
	                            <select class="text" name="EditSrcDestType" id="EditSrcDestType" onChange="displaySrcDestSelector();" style="vertical-align:-2;">
	                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
	                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.sourcedestinationtype",sSelectedSrcDestType,sWebLanguage)%>
	                            </select>
	                            <%-- SOURCE DESTINATION SELECTOR --%>
	                            <span id="SrcDestSelector" style="visibility:hidden;">
	                                <input class="text" type="text" name="EditSrcDestName" id="EditSrcDestName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSrcDestName%>" onchange="if(document.getElementById('EditSrcDestType')[document.getElementById('EditSrcDestType').selectedIndex].value=='servicestock'){showBatches();}">
	                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
	                                <input type="hidden" name="EditSrcDestUid" id="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
	                            </span>
	                        </td>
	                    </tr>
	                    <tr>
	                        <td class="admin"><%=getTran("Web","prescriptionid",sWebLanguage)%></td>
	                        <td class="admin2">
	                            <input class="text" type="text" name="EditPrescriptionUid" size="10" maxLength="10" value="<%=sEditPrescriptionUid%>" <%=(sAction.equals("showDetails")?"READONLY":"")%>>
	                        </td>
	                    </tr>
	                <%
						}
						else {
	                %>
                           <input type="hidden" name="EditSrcDestType" value="<%=sSelectedSrcDestType%>">
                           <input type="hidden" name="EditSrcDestName" value="<%=sSelectedSrcDestName%>">
                           <input type="hidden" name="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
                           <input type="hidden" name="EditPrescriptionUid" value="<%=sEditPrescriptionUid%>">
	                <%
						}
	                %>
                    <%
                        // get previous used values to reuse in javascript
                        String sPrevUsedSrcDestUid  = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid")),
                               sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
                        String supplierCode = "";
                        if(sPrevUsedSrcDestUid.length()==0){
                            if(sSelectedProductStockUid.length() > 0){
                               	ProductStock productStock = ProductStock.get(sSelectedProductStockUid);
                                // get supplier service from product
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
                      displaySrcDestSelector();

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

                      <%-- DISPLAY SOURCE DESTINATION SELECTOR --%>
                      function displaySrcDestSelector(){
                        var srcDestType, emptyEditSrcDest, srcDestUid, srcDestName;

                        srcDestType = transactionForm.EditSrcDestType.value;
                        if(srcDestType.length > 0){
                          document.getElementById('SrcDestSelector').style.visibility = 'visible';

                          <%-- medic --%>
                          if(srcDestType.indexOf('user') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchDoctor('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";

                            if('<%=sPrevUsedSrcDestUid%>'.length > 0){
                              transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                              transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                            }
                            else{
                              transactionForm.EditSrcDestUid.value = "<%=activeUser.userid%>";
                              transactionForm.EditSrcDestName.value = "<%=activeUser.person.firstname+" "+activeUser.person.lastname%>";
                            }
                          }
                          <%-- patient --%>
                          else if(srcDestType.indexOf('patient') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchPatient('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";

                            if('<%=sEditSrcDestName%>'.length == 0 && '<%=sPrevUsedSrcDestUid%>'.length > 0){
                              transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                              transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                            }
                            else{
                              <%
                                  if(activePatient!=null){
                                      %>
                                        transactionForm.EditSrcDestUid.value = "<%=activePatient.personid%>";
                                        transactionForm.EditSrcDestName.value = "<%=activePatient.firstname+" "+activePatient.lastname%>";
                                      <%
                                  }
                                  else{
                                      %>
                                        transactionForm.EditSrcDestUid.value = "";
                                        transactionForm.EditSrcDestName.value = "";
                                      <%
                                  }
                              %>
                            }
                          }
                          <%-- service --%>
                          else if(srcDestType.indexOf('servicestock') > -1){
                            document.getElementById('SearchSrcDestButtonDiv').innerHTML = "<img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick=\"searchService('EditSrcDestUid','EditSrcDestName');\">&nbsp;"
                                                                                         +"<img src='<c:url value="/_img/icon_delete.gif"/>' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick=\"transactionForm.EditSrcDestUid.value='';transactionForm.EditSrcDestName.value='';\">";

                            if('<%=sPrevUsedSrcDestUid%>'.length > 0){
                              transactionForm.EditSrcDestUid.value = "<%=sPrevUsedSrcDestUid%>";
                              transactionForm.EditSrcDestName.value = "<%=sPrevUsedSrcDestName%>";
                            }
                            else if('<%=supplierCode%>'.length > 0){
                              transactionForm.EditSrcDestUid.value = "<%=supplierCode%>";
                              transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",supplierCode,sWebLanguage)%>";
                            }
                            else if('"<%=centralPharmacyCode%>"'.length > 0){
                              transactionForm.EditSrcDestUid.value = "<%=centralPharmacyCode%>";
                              transactionForm.EditSrcDestName.value = "<%=getTranNoLink("service",centralPharmacyCode,sWebLanguage)%>";
                            }
                            else{
                              transactionForm.EditSrcDestUid.value = "";
                              transactionForm.EditSrcDestName.value = "";
                            }
                          }
                        }
                        else{
                          transactionForm.EditSrcDestType.value = "<%=sDefaultSrcDestType%>";
                          document.getElementById('SrcDestSelector').style.visibility = 'hidden';
                        }

                        prevSrcDestType = srcDestType;
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
                        if(sAction.equals("showDetailsNew") && availableProductStocks.size()>0 ){
                            %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","deliver",sWebLanguage)%>' onclick="doDeliver();"><%
                        }
                    %>
                    <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>' onclick='window.close();'>
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditOperationUid" value="<%=sEditOperationUid%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
	var setMaxQuantity=<%=iMaxQuantity%>;
	var totalStock=<%=iMaxStock%>;
	window.resizeTo(700,370);

  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditOperationDescr.focus();<%
      }
  %>

  <%-- DO DELIVER --%>
  function doDeliver(){
    transactionForm.EditOperationUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields() && validateMax(transactionForm.EditUnitsChanged)){
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

  <%-- CHECK PRODUCT FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;
    <%-- required fields --%>
    var productStockChecked=transactionForm.EditProductStockUid.checked;
    for(i=0;i<transactionForm.EditProductStockUid.length; i++){
        if(transactionForm.EditProductStockUid[i].checked){
        	productStockChecked=true;
        }
    }
    if(!transactionForm.EditOperationDescr.value.length>0 ||
       !transactionForm.EditUnitsChanged.value.length>0 ||
       !transactionForm.EditSrcDestType.value.length>0 ||
       !transactionForm.EditSrcDestName.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !productStockChecked){
      maySubmit = false;

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
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
    String excludeServiceUid="";
  	if(sEditProductStockUid.length()>0){
  	    ProductStock productStock = ProductStock.get(sEditProductStockUid);
  	    if(productStock!=null){
  	        excludeServiceUid=productStock.getServiceStockUid();
  	    }
  	}
  %>
openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceUidField+"&ReturnServiceStockNameField="+serviceNameField+"&ExcludeServiceStockUid=<%=excludeServiceUid%>");
  }

  <%-- popup : search patient --%>
  function searchPatient(patientUidField,patientNameField){
    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnName="+patientNameField+"&displayImmatNew=no&isUser=no");
  }

  <%-- popup : search doctor --%>
  function searchDoctor(doctorUidField,doctorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+doctorUidField+"&ReturnName="+doctorNameField+"&displayImmatNew=no");
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

    function showBatches(){
		var remainingQuantity=totalStock;
    	var ih="";
    	var productStockUid="";
	    if(transactionForm.EditProductStockUid.checked){
		 	productStockUid=transactionForm.EditProductStockUid.value;
	    }
	    else {
		    for(i=0;i<transactionForm.EditProductStockUid.length; i++){
		        if(transactionForm.EditProductStockUid[i].checked){
		        	productStockUid=transactionForm.EditProductStockUid[i].value;
		        }
		    }
	    }
	    var bFound=false;
	    if(productStockUid.length>0){
		    var b=batches.split("£");
		    for(n=0;n<b.length;n++){
				var c=b[n].split("$");
				if(c[0]==productStockUid){
					for(q=1;q<c.length;q++){
						var d=c[q].split(";");
						ih+="<input onclick='setMaxQuantityValue("+d[2]+");' type='radio' name='EditBatchUid' value='"+d[0]+"' ";
						if(q==1){
							bFound=true;
							ih+="checked";
							setMaxQuantityValue(d[2]);
						}
						if(document.getElementById("EditUnitsChanged").value*1>d[2]*1){
							ih+=" />"+d[1]+" (<font color='red'><b>"+d[2]+"</b></font> - exp. "+d[3]+") <i>"+d[4]+"</i><br/>";
						}
						else{
							ih+=" />"+d[1]+" ("+d[2]+" - exp. "+d[3]+") <i>"+d[4]+"</i><br/>";
						}
						remainingQuantity-=d[2];
					}
				}
		    } 
			if(remainingQuantity>0){
			    ih+="<input onclick='setMaxQuantityValue("+remainingQuantity+");' type='radio' name='EditBatchUid' value=''";
				if(!bFound){
					ih+="checked";
					setMaxQuantityValue(remainingQuantity);
				}
				ih+=" />? ("+remainingQuantity+")";
			}
	    }
	    document.getElementById("batch").innerHTML=ih;
    }

    function setMaxQuantityValue(mq){
        setMaxQuantity=mq;
        if(document.getElementById("EditUnitsChanged").value*1>setMaxQuantity*1){
        	document.getElementById("maxquantity").innerHTML=" <img src='<c:url value="/_img/warning.gif"/>'/> <font color='red'><b> &gt;"+setMaxQuantity+"</b></font>";
        }
        else {
        	document.getElementById("maxquantity").innerHTML="";
        }
    }

	showBatches();
	
</script>