<%@ page import="be.openclinic.finance.WicketCredit,java.util.Vector" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.finance.Wicket" %>
<%@include file="/includes/validateUser.jsp"   %>
<%!
    private String addTodayWickets(Vector vWickets,String sWeblanguage,boolean bCanEdit) {
        String sReturn = "";

        if (vWickets != null) {
            String sClass ="";
            WicketCredit wicketOps;
            for (int i = 0; i < vWickets.size(); i++) {
                wicketOps = (WicketCredit) vWickets.elementAt(i);

                if (wicketOps != null) {
                    if (sClass.equals("")) {
                        sClass = "1";
                    } else {
                        sClass = "";
                    }
                    sReturn += "<tr class='list" + sClass+"'"
                            + ""
                            +(wicketOps.getOperationType().equalsIgnoreCase("patient.payment") && !bCanEdit?"":"  onclick=\"setWicket('" + wicketOps.getUid() + "');\"")+">"
                            + "<td>" +ScreenHelper.stdDateFormat.format(wicketOps.getOperationDate())+ "</td>"
                            + "<td>" +wicketOps.getUid()+ "</td>"
                            + "<td>" +HTMLEntities.htmlentities(getTran("service",Wicket.get(wicketOps.getWicketUID()).getServiceUID(),sWeblanguage))+ "</td>"
                            + "<td>" +HTMLEntities.htmlentities(getTran((wicketOps.getOperationType().equalsIgnoreCase("patient.payment")?"credit.type.hidden":"credit.type"),wicketOps.getOperationType(),sWeblanguage))+ "</td>"
                            + "<td >" +wicketOps.getAmount()+ "</td>"
                            + "<td>" +HTMLEntities.htmlentities(wicketOps.getComment().toString())+ "</td>"
                            + "</tr>";
                }
            }
        }
        return sReturn;
    }
%>
<%
    String sEditWicketOperationWicket = checkString(request.getParameter("EditWicketOperationWicket"));
%>
<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td>ID</td>
        <td><%=HTMLEntities.htmlentities(getTran("web","wicket",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("wicket","operation_type",sWebLanguage))%></td>
        <td width="200"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web", "comment", sWebLanguage))%></td>
    </tr>
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
<%
    Vector vWicketsToday = WicketCredit.selectWicketOperations(getDate(), ScreenHelper.getDateAdd(getDate(),"1"),"","","",sEditWicketOperationWicket,"OC_WICKET_CREDIT_OPERATIONDATE DESC,OC_WICKET_CREDIT_OBJECTID DESC");
    out.print(addTodayWickets(vWicketsToday,sWebLanguage,activeUser.getAccessRight("financial.superuser.select")));
%>
    </tbody>
</table>
