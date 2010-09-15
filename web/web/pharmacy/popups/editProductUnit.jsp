<%@page import="be.openclinic.pharmacy.Product"%>
<%@page import="java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.editproductunit","all",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditProductUid   = checkString(request.getParameter("EditProductUid")),
           sEditUnit         = checkString(request.getParameter("EditUnit")),
           sEditPackageUnits = checkString(request.getParameter("EditPackageUnits"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n\n################## editProductUnit : "+sAction+" ###############");
        System.out.println("* sEditProductUid   : "+sEditProductUid);
        System.out.println("* sEditUnit         : "+sEditUnit);
        System.out.println("* sEditPackageUnits : "+sEditPackageUnits);
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "";

    // get specified record
    Product product = Product.get(sEditProductUid);

    //--- SAVE (update only) ----------------------------------------------------------------------
    if(sAction.equals("save") && sEditProductUid.length() > 0){
        product.setUnit(sEditUnit);
        if(sEditPackageUnits.length() > 0) product.setPackageUnits(Integer.parseInt(sEditPackageUnits));
        product.setUpdateUser(activeUser.userid);
        product.store(false);

        // catch search-parameters of the openenr to be able to reproduce the same search as you did just now
        String sSearchProductName  = checkString(request.getParameter("SearchProductName")),
               sSearchSupplierUid  = checkString(request.getParameter("SearchSupplierUid")),
               sSearchSupplierName = checkString(request.getParameter("SearchSupplierName")),
               sSearchProductGroup = checkString(request.getParameter("SearchProductGroup")),
               sSelectProductUid   = checkString(request.getParameter("SelectProductUid"));
        %>
            <script>
              var url = window.opener.location.href+
                        "&SearchProductName=<%=sSearchProductName%>"+
                        "&SearchSupplierUid=<%=sSearchSupplierUid%>"+
                        "&SearchSupplierName=<%=sSearchSupplierName%>"+
                        "&SearchProductGroup=<%=sSearchProductGroup%>"+
                        "&OpenerAction=selectProduct&SelectProductUid=<%=sSelectProductUid%>";
              window.opener.location.href = url;
              window.close();
            </script>
        <%
    }
%>

<form name="transactionForm" id="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doSaveProduct();}" onClick="clearMessage();">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditProductUid" value="<%=sEditProductUid%>">

    <%-- page title --%>
    <%=writeTableHeader("Web.manage","editproductunit",sWebLanguage," doBack();")%>

    <table class="list" width="100%" cellspacing="1">
        <%-- product name --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","productName",sWebLanguage)%></td>
            <td class="admin2"><%=product.getName()%></td>
        </tr>

        <%-- unit --%>
        <tr>
            <td class="admin" nowrap><%=getTran("Web","unit",sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" name="EditUnit">
                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelectUnsorted("product.unit",checkString(product.getUnit()),sWebLanguage)%>
                </select>
            </td>
        </tr>

        <%-- packageUnits --%>
        <%
            String sPackageUnits = (product.getPackageUnits()<=0?"":product.getPackageUnits()+"");
        %>
        <tr>
            <td class="admin" nowrap><%=getTran("Web","PackageUnits",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="EditPackageUnits" size="5" maxLength="5" value="<%=sPackageUnits%>" onKeyUp="isNumber(this);">
            </td>
        </tr>
            
    </table>

    <%-- indication of obligated fields --%>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

    <%-- display message --%>
    <span id="msgArea"><br><%=msg%></span>

    <%-- EDIT BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSaveProduct();">
        <input class="button" type="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  transactionForm.EditUnit.focus();

  <%-- DO SAVE PRODUCT --%>
  function doSaveProduct(){
    if(checkProductFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditUnit.value.length==0){
        transactionForm.EditUnit.focus();
      }
      /*
      else if(transactionForm.EditPackageUnits.value.length==0){
        transactionForm.EditPackageUnits.focus();
      }
      else if(transactionForm.EditProductGroup.value.length==0){
        transactionForm.EditProductGroup.focus();
      }
      */
    }
  }

  <%-- CHECK PRODUCT FIELDS --%>
  function checkProductFields(){
    var maySubmit = true;

    if(transactionForm.EditUnit.value.length==0){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");

      transactionForm.EditUnit.focus();
      maySubmit = false;
    }

    return maySubmit;
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    window.close();
  }
</script>