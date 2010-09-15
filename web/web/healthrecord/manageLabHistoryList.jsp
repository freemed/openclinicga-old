<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page import="be.openclinic.system.Transaction" %>
<%@ page import="java.util.*" %>
<%=sCSSNORMAL%>
<%
    String myParent = request.getParameter("parent");
    if(myParent==null){
        myParent = "myParent";
        out.print("<script>window.opener.name='myParent';</script>");
    }
%>

<form name="labHistoryList" method="post" action="<c:url value="/main.do"/>?Page=healthrecord/manageLabCumulResult_view.jsp&ts=<%=getTs()%>" target="<%=myParent%>">
<table width='100%'>
    <tr>
        <td class='menuItem' colspan='2'>
            <input type='submit' class='button' onmouseup='window.close();' value='<%= getTran("web","Find",sWebLanguage)%>'/>
        </td>
    </tr>

<%
    String sHealthRecordId = checkString(request.getParameter("healthRecordId"));

    Vector vLabHistoryListTranData = Transaction.getLabHistoryListTransactionData(sHealthRecordId);
    Iterator iter = vLabHistoryListTranData.iterator();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    int counter = 0;
    Hashtable hLabHistoryListTranData;
    while (iter.hasNext()) {
        hLabHistoryListTranData = (Hashtable)iter.next();
        out.print("<tr>");
        out.print("<td class='menuItem'><input type='checkbox' name='cb" + counter + "' value='" + hLabHistoryListTranData.get("serverId") + "." + hLabHistoryListTranData.get("transactionId") + "' " + (counter < 5 ? "checked" : "") + "/></td><td class='menuItem'>" + dateFormat.format(hLabHistoryListTranData.get("updateTime")) + "</td>");
        out.print("</tr>");

        counter++;
    }
%>
</table>
</form>