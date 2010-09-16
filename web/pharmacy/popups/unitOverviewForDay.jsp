<%@ page import="be.openclinic.pharmacy.ProductStock" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.pharmacy.ProductStockOperation" %>
<%@ page import="be.openclinic.pharmacy.ServiceStock" %>
<%@include file="/_common/templateAddIns.jsp"%>

<%
    String date = checkString(request.getParameter("date"));
    java.util.Date dDate = new SimpleDateFormat("dd/MM/yyyy").parse(date);
    ProductStock productStock = ProductStock.get(request.getParameter("productStockUid"));
%>

<%-- title ----------------------------------------------------------------------------------%>
<table width="100%" cellspacing="1">
    <tr class="admin">
        <td colspan="2">&nbsp;<%=getTran("Web.manage","unitOverviewPerMonth",sWebLanguage)%></td>
    </tr>
    <%-- MONTH --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("web","day",sWebLanguage)%></td>
        <td class="admin2"><%=date%></td>
    </tr>
    <%-- SERVICE STOCK --%>
    <tr>
        <td class="admin">&nbsp;<%=getTran("web","serviceStock",sWebLanguage)%></td>
        <td class="admin2"><%=productStock.getServiceStock().getName()%></td>
    </tr>
    <%-- PRODUCT STOCK --%>
    <tr>
        <td class="admin">&nbsp;<%=getTran("web","productStock",sWebLanguage)%></td>
        <td class="admin2"><%=productStock.getProduct().getName()%></td>
    </tr>
</table>
<br>

<div class="search" style="width:100%;height:300px;">

<table width="100%" cellspacing="1">
    <tr class='admin'>
        <td><%=getTran("web","type",sWebLanguage)%></td>
        <td><%=getTran("web","quantity",sWebLanguage)%></td>
        <td><%=getTran("web","source",sWebLanguage)%>/<%=getTran("web","destination",sWebLanguage)%></td>
        <td><%=getTran("web","user",sWebLanguage)%></td>
    </tr>
<%
    Vector operations = ProductStockOperation.searchProductStockOperations("", "", date, productStock.getUid(), "", "OC_OPERATION_OBJECTID");
    for (int n = 0; n < operations.size(); n++) {
        ProductStockOperation operation = (ProductStockOperation) operations.elementAt(n);
        ObjectReference sourceDestination = operation.getSourceDestination();
        String sd = "",username="";
        UserVO user=MedwanQuery.getInstance().getUser(operation.getUpdateUser());
        if(user!=null){
            username=user.getPersonVO().getFullName();
        }
        if (sourceDestination != null) {
            if (sourceDestination.getObjectType().equalsIgnoreCase("patient")) {
              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                AdminPerson patient = AdminPerson.getAdminPerson(ad_conn, sourceDestination.getObjectUid());
                ad_conn.close();
                sd = patient.personid + ": " + patient.firstname + " " + patient.lastname;
            } else if (sourceDestination.getObjectType().equalsIgnoreCase("servicestock")) {
                ServiceStock serviceStock = ServiceStock.get(sourceDestination.getObjectUid());
                sd = serviceStock.getName();
            }
        }
        String movement = "", sClass = "";
        if (operation.getSourceDestination() != null && operation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")) {
            if (operation.getDescription().indexOf("receipt") > -1) {
                movement = "+";
                sClass = "list";
            } else if (operation.getDescription().indexOf("delivery") > -1) {
                movement = "-";
                sClass = "list1";
            }
        } else
        if (operation.getSourceDestination() != null && operation.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")) {
            if (operation.getDescription().indexOf("receipt") > -1 || operation.getDescription().indexOf("correctionin") > -1) {
                movement = "+";
                sClass = "list";
            } else
            if (operation.getDescription().indexOf("delivery") > -1 || operation.getDescription().indexOf("correctionout") > -1) {
                movement = "-";
                sClass = "list1";
            }
        }
        else {
            if (operation.getDescription().indexOf("receipt") > -1 || operation.getDescription().indexOf("correctionin") > -1) {
                movement = "+";
                sClass = "list";
            } else
            if (operation.getDescription().indexOf("delivery") > -1 || operation.getDescription().indexOf("correctionout") > -1) {
                movement = "-";
                sClass = "list1";
            }
        }
%>
    <tr class="<%=sClass%>">
        <td><%=getTran("web", operation.getDescription(), sWebLanguage)%></td>
        <td><%=movement+operation.getUnitsChanged()%></td>
        <td><b><%=sd%></b></td>
        <td><%=username%></td>
    </tr>
        <%
    }
%>
</table>
    </div>
<%-- CLOSE BUTTON --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>' onclick='window.close();'>
<%=ScreenHelper.alignButtonsStop()%>

<script type="text/javascript">
    <%-- SHOW UNITS FOR DAY --%>
    function showOperation(operationuid){
      openPopup("pharmacy/manageProductStockOperations.jsp&Action=find&EditOperationUid="+operationuid+"&ts=<%=getTs()%>",700,400);
    }
</script>