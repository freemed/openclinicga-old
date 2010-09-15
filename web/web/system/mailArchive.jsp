<%@ page import="net.admin.system.Email"%>
<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%ScreenHelper.setIncludePage("mailTab.jsp",pageContext);%>
<%
    String sFindEmailID = checkString(request.getParameter("FindEmailID"));

    if ((sFindEmailID!=null)&&(sFindEmailID.trim().length()>0)) {
        String sFindSubject, sFindSenderMessage, sFindSenderDate, sFindReceiverDate, sFindReceiverMessage, sFindReceiverName
                ,sFindSenderReadDate;
        byte[] aTmp;
        Email objEmail = Email.selectEmail(Integer.parseInt(sFindEmailID));

        if(objEmail != null){
            sFindSubject = objEmail.getSubject();
            sFindSenderMessage = new String(objEmail.getSendermessage());
            sFindSenderDate = getSQLTimeStamp(objEmail.getSenderdate());
            sFindReceiverDate = getSQLTimeStamp(objEmail.getReceiverdate());

            aTmp = objEmail.getReceivermessage();
            if (aTmp!=null) {
                sFindReceiverMessage = new String(aTmp);
            }
            else {
                sFindReceiverMessage = "";
            }

            sFindReceiverName = objEmail.getReceivername();
            sFindSenderReadDate = getSQLTimeStamp(objEmail.getSenderreaddate());

            if ((sFindSenderReadDate==null)||(sFindSenderReadDate.trim().length()==0)||(sFindSenderReadDate.trim().equals("")))  {
                Email.setEmailRead(Integer.parseInt(sFindEmailID));
            }
            %>
                <br>

                <table class="list" width="100%" cellspacing="1" id="printtable">
                    <tr class="admin">
                        <td width="30%"><%=getTran("Web","Email",sWebLanguage)%></td>
                        <td width="*" align="right"><a href="#topp" class="topbutton">&nbsp;</a></td>
                    </tr>
                    <%=setRow("Web.Mail","Subject",sFindSubject,sWebLanguage)%>
                    <%=setRow("Web.Mail","SendDate",sFindSenderDate,sWebLanguage)%>
                    <%=setRow("Web.Occup","medwan.common.description",sFindSenderMessage,sWebLanguage)%>
                    <%=setRow("Web.Mail","Destination",sFindReceiverName,sWebLanguage)%>
                    <%=setRow("Web.Mail","AnswerDate",sFindReceiverDate,sWebLanguage)%>
                    <%=setRow("Web.Mail","Answer",sFindReceiverMessage,sWebLanguage)%>
                </table>

                <%=ScreenHelper.alignButtonsStart()%>
                    <input type="button" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" class="button" onclick="doPrint();">&nbsp;
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    }
%>

<form name="transactionForm" method="post">
<table cellspacing="1" class="list" width="100%">
    <%-- HEADER --%>
    <tr class="admin">
        <td width="1%"></td>
        <td width="120"><%=getTran("Web.Mail","SendDate",sWebLanguage)%></td>
        <td width="120"><%=getTran("Web.Mail","AnswerDate",sWebLanguage)%></td>
        <td width="200"><%=getTran("Web.Mail","Destination",sWebLanguage)%></td>
        <td width="*"><%=getTran("Web.Mail","Subject",sWebLanguage)%></td>
    </tr>

    <%
        String sEmailID, sSubject, sReceiverName, sSenderDate, sReceiverDate, sImg, sClass = "", sSenderReadDate;
        Vector vEmails = Email.selectEmailsFromSenderArchived(Integer.parseInt(activeUser.userid));
        Iterator iter = vEmails.iterator();
        Email objEmail;

        while (iter.hasNext()) {
            objEmail = (Email) iter.next();
            sEmailID = Integer.toString(objEmail.getEmailid());
            sSubject = objEmail.getSubject();
            sReceiverName = objEmail.getReceivername();
            sSenderDate = getSQLTimeStamp(objEmail.getSenderdate());
            sReceiverDate = getSQLTimeStamp(objEmail.getReceiverdate());
            sSenderReadDate = getSQLTimeStamp(objEmail.getSenderreaddate());
            sImg = "<img src='" + sCONTEXTPATH + "/_img/unread.gif'>";

            if (sClass.equals("")) sClass = " class='list'";
            else sClass = "";

            if ((sSenderReadDate != null) && (sSenderReadDate.trim().length() > 0)) {
                sImg = "<img src='" + sCONTEXTPATH + "/_img/read.gif'>";
            }
    %>
                <tr<%=sClass%>>
                    <td><%=sImg%></td>
                    <td><a href="#" onclick="transactionForm.FindEmailID.value='<%=sEmailID%>';transactionForm.submit();"><%=sSenderDate%></a></td>
                    <td><%=sReceiverDate%></td>
                    <td><%=sReceiverName%></td>
                    <td><%=sSubject%></td>
                </tr>
            <%
        }
    %>
</table>

<input type="hidden" name="FindEmailID">
</form>

<script>
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }
</script>
