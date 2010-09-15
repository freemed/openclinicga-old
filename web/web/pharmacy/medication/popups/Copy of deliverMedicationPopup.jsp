<%@page import="be.openclinic.pharmacy.ProductStockOperation,
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
    ServiceStock serviceStock=null;

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
            sEditServiceStockUid = "",
            sEditServiceStockName = "",
            sEditPrescriptionUid = checkString(request.getParameter("EditPrescriptionUid"));
    Prescription prescription=null;
    if (sEditUnitsChanged.length()==0 && sEditPrescriptionUid.length() > 0){
        prescription = Prescription.get(sEditPrescriptionUid);
        if (prescription!=null) {
            sEditUnitsChanged = (prescription.getRequiredPackages()-prescription.getDeliveredQuantity())+"";
        }
    }
    // lookup productName if none provided
    if (sEditProductStockUid.length() == 0 && sEditPrescriptionUid.length() > 0) {
        if(prescription!=null){
            ProductStock productStock=ProductStock.get(prescription.getProductUid(),prescription.getServiceStockUid());
            if (productStock != null && productStock.getLevel()>0) {
                sEditProductStockUid=productStock.getUid();
                sEditProductName = productStock.getProduct().getName();
                serviceStock = ServiceStock.get(prescription.getServiceStockUid());
                if(serviceStock!=null && serviceStock.isAuthorizedUser(activeUser.userid)){
                	sEditServiceStockName=serviceStock.getName();
                	sEditServiceStockUid=serviceStock.getUid();
                }
                else {
                	serviceStock=null;
                }
            }
            else {
            	Vector serviceStocks = ServiceStock.find(centralPharmacyCode);
            	if(serviceStocks.size()>0){
                	serviceStock=(ServiceStock)serviceStocks.elementAt(0);
                    if(serviceStock!=null && serviceStock.isAuthorizedUser(activeUser.userid)){
	            		sEditServiceStockName=serviceStock.getName();
	                	sEditServiceStockUid=serviceStock.getUid();
	                    productStock=ProductStock.get(prescription.getProductUid(),sEditServiceStockUid);
	                    if (productStock != null && productStock.getLevel()>0) {
	                        sEditProductStockUid=productStock.getUid();
	                        sEditProductName = productStock.getProduct().getName();
	                    }
                    }
                    else {
                    	serviceStock=null;
                    }
            	}
            }
        }
    }
    else if (sEditProductStockUid.length() > 0 && sEditProductName.length() == 0) {
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if (productStock != null) {
            sEditProductName = productStock.getProduct().getName();
            serviceStock = ServiceStock.get(productStock.getServiceStockUid());
            if(serviceStock!=null && serviceStock.isAuthorizedUser(activeUser.userid)){
            	sEditServiceStockName=serviceStock.getName();
            	sEditServiceStockUid=serviceStock.getUid();
            }
            else {
            	serviceStock=null;
            }
        }
    }
    else if (sEditProductStockUid.length() > 0) {
        ProductStock productStock = ProductStock.get(sEditProductStockUid);
        if (productStock != null) {
            serviceStock = ServiceStock.get(productStock.getServiceStockUid());
            if(serviceStock!=null && serviceStock.isAuthorizedUser(activeUser.userid)){
            	sEditServiceStockName=serviceStock.getName();
            	sEditServiceStockUid=serviceStock.getUid();
            }
            else {
            	serviceStock=null;
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
        sEditOperationDescr = "medicationdelivery.type1";
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

        String sResult=operation.store();
        if(sResult==null){

        // reload opener to see the change in level
        %>
        
<%@page import="be.openclinic.pharmacy.ServiceStock"%><script>
          window.opener.location.reload();
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
        else                                     sEditOperationDescr = "medicationdelivery.type1"; // default

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
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","pharmacy",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=sEditServiceStockUid+" "+sEditServiceStockName%>
                        </td>
                    </tr>
                    <%-- Product stock --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","product",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductStockUid" value="<%=sSelectedProductStockUid%>">
                            <input type="hidden" name="EditProductStockName" value="<%=sSelectedProductName%>">
                            <%=sSelectedProductName%>
                        </td>
                    </tr>
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
                    <%-- units changed --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","unitschanged",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditUnitsChanged" size="5" maxLength="5" value="<%=sSelectedUnitsChanged%>" onKeyUp="if(this.value=='0'){this.value='';}isNumber(this);" onblur="validateMax(this);" <%=(sAction.equals("showDetails")?"READONLY":"")%>>
                        </td>
                    </tr>
                    <%-- SourceDestination type --%>
                    <tr height="23">
                        <td class="admin"><%=getTran("web","deliveredto",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" name="EditSrcDestType" onChange="displaySrcDestSelector();" style="vertical-align:-2;">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstockoperation.sourcedestinationtype",sSelectedSrcDestType,sWebLanguage)%>
                            </select>
                            <%-- SOURCE DESTINATION SELECTOR --%>
                            <span id="SrcDestSelector" style="visibility:hidden;">
                                <input class="text" type="text" name="EditSrcDestName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSrcDestName%>">
                                <span id="SearchSrcDestButtonDiv"><%-- filled by JS below --%></span>
                                <input type="hidden" name="EditSrcDestUid" value="<%=sSelectedSrcDestUid%>">
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
                        // get previous used values to reuse in javascript
                        String sPrevUsedSrcDestUid  = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestUid")),
                               sPrevUsedSrcDestName = checkString((String)session.getAttribute("PrevUsedDeliverySrcDestName"));
                        String supplierCode = "";
                        ProductStock productStock = ProductStock.get(sEditProductStockUid);
                        if(sPrevUsedSrcDestUid.length()==0){
                            if(sSelectedProductStockUid.length() > 0){
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

                      function validateMax(o){
                        if(o.value*1><%=Math.min(prescription!=null?prescription.getRequiredPackages()-prescription.getDeliveredQuantity():9999999,productStock!=null?productStock.getLevel():999999)%>){
                            alert('<%=getTran("web","maxvalueis",sWebLanguage)%> <%=new Double(Math.min(prescription!=null?prescription.getRequiredPackages()-prescription.getDeliveredQuantity():9999999,productStock!=null?productStock.getLevel():999999)).intValue()%>');
                            o.focus();
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
                        if(sAction.equals("showDetailsNew") && serviceStock!=null ){
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
  window.resizeTo(700,270);

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

  <%-- CHECK PRODUCT FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditOperationDescr.value.length>0 ||
       !transactionForm.EditUnitsChanged.value.length>0 ||
       !transactionForm.EditSrcDestType.value.length>0 ||
       !transactionForm.EditSrcDestName.value.length>0 ||
       !transactionForm.EditOperationDate.value.length>0 ||
       !transactionForm.EditProductStockUid.value.length>0){
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
    ProductStock productStock = ProductStock.get(sEditProductStockUid);
    if(productStock!=null){
        excludeServiceUid=productStock.getServiceStockUid();
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
</script>