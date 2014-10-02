<%@page import="be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ProductStockOperation,java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%=checkPermission("medication.medicationdelivery","all",activeUser)%>
<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private String objectsToHtml(Vector deliveries, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        ProductStockOperation delivery;
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
        String sClass = "1";

        // run thru deliveries
        for (int i = 0; i < deliveries.size(); i++) {
            delivery = (ProductStockOperation) deliveries.get(i);

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            //*** display product in one row ***
            html.append("<tr class='list" + sClass + "'>")
                .append("<td>" + getTran("productstockoperation.medicationdelivery", delivery.getDescription(), sWebLanguage) + "</td>")
                .append("<td>" + delivery.getUnitsChanged() + "</td>")
                .append("<td>" + stdDateFormat.format(delivery.getDate()) + "&nbsp;</td>")
                .append("<td>" + delivery.getProductStock().getServiceStock().getName() + "</td>")
                .append("</tr>");
        }

        return html.toString();
    }
%>
<%
    // retreive form data
    String sPatientId       = checkString(request.getParameter("PatientId")),
           sProductStockUid = checkString(request.getParameter("ProductStockUid")),
           sSince           = checkString(request.getParameter("Since"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("################## deliveriesPopup ################################");
        Debug.println("* sPatientId       : "+sPatientId);
        Debug.println("* sProductStockUid : "+sProductStockUid);
        Debug.println("* sSince           : "+sSince+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////
%>
<form name="transactionForm" method="post">
    <%-- title --%>
    <table width="100%" cellspacing="1">
        <tr class='admin'>
            <td colspan='2'>&nbsp;&nbsp;<%=getTran("Web.manage","medicationDeliveries",sWebLanguage)%></td>
        </tr>
        <%-- product --%>
        <%
            ProductStock productStock = ProductStock.get(sProductStockUid);
        %>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","product",sWebLanguage)%></td>
            <td class="admin2"><%=productStock.getProduct().getName()%></td>
        </tr>
        <%-- patient --%>
        <%
            AdminPerson patient = AdminPerson.getAdminPerson(sPatientId);
        %>
        <tr>
            <td class="admin"><%=getTran("web","patient",sWebLanguage)%></td>
            <td class="admin2"><%=patient.firstname+" "+patient.lastname%></td>
        </tr>
        <%-- since --%>
        <tr>
            <td class="admin"><%=getTran("web","since_uc",sWebLanguage)%></td>
            <td class="admin2"><%=sSince%></td>
        </tr>
    </table>
    <br>
    <%-- found deliveries --%>
    <div class="search" style="width:100%;height:200px;">
    <%
        Vector deliveries = productStock.getDeliveriesToPatient(sPatientId);
        String deliveriesAsHtml = objectsToHtml(deliveries,sWebLanguage);

        if(deliveries.size() > 0){
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="list">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="40%"><%=getTran("Web","description",sWebLanguage)%></td>
                        <td width="10%"><%=getTran("Web","units",sWebLanguage)%></td>
                        <td width="*"><%=getTran("Web","date",sWebLanguage)%></td>
                        <td width="40%"><%=getTran("Web","serviceStock",sWebLanguage)%></td>
                    </tr>
                    <%=deliveriesAsHtml%>
                </table>
                <%-- number of deliveries found --%>
                <span style="width:100%;text-align:left;">
                    <%=deliveries.size()%> <%=getTran("web","deliveriesfound",sWebLanguage)%>
                </span>
            <%
        }
        else{
            // no records found
            %><%=getTran("web.manage","nodeliveriesfound",sWebLanguage)%><%
        }
    %>
    </div>
    <%-- close button --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>