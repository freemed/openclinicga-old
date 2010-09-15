<%@ page import="net.admin.system.Email"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%ScreenHelper.setIncludePage("mailTab.jsp",pageContext);%>

<form name="transactionForm" method="post">
<%
    String sFindEmailID = checkString(request.getParameter("FindEmailID"));
    String sEditEmailID = checkString(request.getParameter("EditEmailID"));
    String sFindShowUnreadMessages = checkString(request.getParameter("FindShowUnreadMessages"));

    if (!sFindShowUnreadMessages.toLowerCase().equals("off")) {
        sFindShowUnreadMessages = "checked";
    }

    if ((sFindEmailID!=null)&&(sFindEmailID.trim().length()>0)) {
        String sFindSubject, sFindSenderMessage, sFindSenderDate, sFindReceiverDate, sFindReceiverMessage
                , sFindLastname, sFindFirstname;
        byte[] aTmp;

        Email objEmail = Email.selectEmail(Integer.parseInt(sFindEmailID));

        if(objEmail!=null){
            sFindSubject = objEmail.getSubject();
            sFindSenderMessage = new String(objEmail.getSendermessage());
            sFindSenderDate   = getSQLTimeStamp(objEmail.getSenderdate());
            sFindReceiverDate = getSQLTimeStamp(objEmail.getReceiverdate());
            aTmp = objEmail.getReceivermessage();

            if (aTmp!=null) sFindReceiverMessage = new String(aTmp);
            else            sFindReceiverMessage = "";

            String[] sFullname = Email.getSenderFullname(Integer.toString(objEmail.getSenderid()));

            sFindLastname  = sFullname[1];
            sFindFirstname = sFullname[0];

            sFindLastname += " "+sFindFirstname;
            %>
            <br>

            <table class="list" width="100%" cellspacing="1" id="printtable">
                <tr class="admin">
                    <td width="30%"><%=getTran("Web","Email",sWebLanguage)%></td>
                    <td width="*" align="right">
                        <a href="#topp" class="topbutton">&nbsp;</a>
                    </td>
                </tr>

                <%=setRow("Web.Mail","SendDate",sFindSenderDate,sWebLanguage)%>
                <%=setRow("Web.Mail","From",sFindLastname,sWebLanguage)%>
                <%=setRow("Web.Mail","Subject",sFindSubject,sWebLanguage)%>
                <%=setRow("Web.Occup","medwan.common.description",sFindSenderMessage,sWebLanguage)%>
                <%=setRow("Web.Mail","AnswerDate",sFindReceiverDate,sWebLanguage)%>

                <tr>
                    <td class="admin"><%=getTran("Web.Mail","Answer",sWebLanguage)%></td>
                    <td class="admin2"><%=writeTextarea("EditAnswer","","10","",sFindReceiverMessage)%></td>
                </tr>

                <input type="hidden" name="EditEmailID" value="<%=sFindEmailID%>">
                <script>transactionForm.EditAnswer.focus();</script>
            </table>

            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" value="<%=getTran("web","save",sWebLanguage)%>" class="button" name="SaveEmailButton" onclick="transactionForm.submit();">
                <input type="button" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" class="button" onclick="doPrint();">&nbsp;
            <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    }
    else if ((sEditEmailID!=null)&&(sEditEmailID.trim().length()>0)){
        String sEditAnswer = checkString(request.getParameter("EditAnswer"));
        Email.setReceiverDateAndMessage(sEditEmailID,sEditAnswer);
    }

//nieuwe antwoorden in outbox?
    boolean bNewMessages = false;
    bNewMessages = Email.newMessages(activeUser.userid);

    if (bNewMessages) {
        out.print("<a href='main.do?Page=system/mailOutbox.jsp'>"+getTran("Web.Mail","New.Answers",sWebLanguage)+"</a><br><br>");
    }
%>
<table cellspacing="1" class="list" width="100%">
<tr class="admin">
    <td width="1%"></td>
    <td width="120"><%=getTran("Web.Mail","SendDate",sWebLanguage)%></td>
    <td width="120"><%=getTran("Web.Mail","AnswerDate",sWebLanguage)%></td>
    <td width="200"><%=getTran("Web.Mail","From",sWebLanguage)%></td>
    <td width="*"><%=getTran("Web.Mail","Subject",sWebLanguage)%></td>
</tr>
<%
    String sEmailID, sSubject, sSenderDate, sReceiverDate, sImg, sClass = "", sLastname, sFirstname;
    Vector vEmails = Email.selectEmailsByToemail("%" + activeUser.userid + "%", sFindShowUnreadMessages);
    Iterator iter = vEmails.iterator();

    Hashtable hEmailInfo;
    Email objEmail;

    while (iter.hasNext()) {
        hEmailInfo = (Hashtable) iter.next();
        objEmail = (Email) hEmailInfo.get("email");
        sFirstname = (String) hEmailInfo.get("firstname");
        sLastname = (String) hEmailInfo.get("lastname");

        sEmailID = Integer.toString(objEmail.getEmailid());
        sSubject = objEmail.getSubject();
        sSenderDate = getSQLTimeStamp(objEmail.getSenderdate());
        sReceiverDate = getSQLTimeStamp(objEmail.getReceiverdate());


        sLastname += (" " + sFirstname);

        sImg = "<img src='" + sCONTEXTPATH + "/_img/unread.gif'>";

        if (sClass.equals("")) sClass = " class='list'";
        else sClass = "";

        if ((sReceiverDate != null) && (sReceiverDate.trim().length() > 0)) {
            sImg = "<img src='" + sCONTEXTPATH + "/_img/read.gif'>";
        }
%>
        <tr<%=sClass%>>
            <td><%=sImg%></td>
            <td><a href="#" onclick="transactionForm.FindEmailID.value='<%=sEmailID%>';transactionForm.submit();"><%=sSenderDate%></a></td>
            <td><%=sReceiverDate%></td>
            <td><%=sLastname%></td>
            <td><%=sSubject%></td>
        </tr>
        <%
    }
%>
</table>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="checkbox" name="EditShowUnreadMessages" <%=sFindShowUnreadMessages%> onclick="setShow();">
    <%=getTran("Web.Mail","Show.Unread.Messages",sWebLanguage)%>
<%=ScreenHelper.alignButtonsStop()%>

<input type="hidden" name="FindEmailID">
<input type="hidden" name="FindShowUnreadMessages">

<script>
  function setShow(){
    if (transactionForm.EditShowUnreadMessages.checked) {
      transactionForm.FindShowUnreadMessages.value = "on";
    }
    else {
      transactionForm.FindShowUnreadMessages.value = "off";
    }

    transactionForm.submit();
  }
</script>
</form>

<script>
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }
</script>