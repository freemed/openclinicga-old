<%@page isThreadSafe="true"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private String setTab(String sName, String sLink, String sTabID) {
        String sBreak = "<td class='tabs' width='5'>&nbsp;</td>";

        if ((sTabID==null)||(!sTabID.toLowerCase().equals(sLink.toLowerCase()))) {
            return sBreak+"<td class='tabunselected' width='1%' nowrap>&nbsp;<a href='main.do?Page="+sLink+"' class='menuItem'>"+sName+"</a>&nbsp;</td>";
        }
        else {
            return sBreak+"<td class='tabselected' width='1%' nowrap><b>&nbsp;"+sName+"&nbsp;</b></td>";
        }
    }
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <%
            String sTabID = checkString(request.getParameter("Page"));

            String sMailNew     = setTab(getTran("Web.Mail","New",sWebLanguage),"system/mailNew.jsp", sTabID);
            String sMailInbox   = setTab(getTran("Web.Mail","Inbox",sWebLanguage),"system/mailInbox.jsp", sTabID);
            String sMailOutbox  = setTab(getTran("Web.Mail","Outbox",sWebLanguage),"system/mailOutbox.jsp", sTabID);
            String sMailArchive = setTab(getTran("Web.Mail","Archive",sWebLanguage),"system/mailArchive.jsp", sTabID);

            out.print(sMailNew+sMailInbox+sMailOutbox+sMailArchive);
        %>
        <td width="*" class='tabs'>&nbsp;</td>
    </tr>
</table>