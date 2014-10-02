<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%@page import="java.util.Enumeration,
                net.admin.system.Email"%>
<%@ page import="java.util.Vector" %>
<%ScreenHelper.setIncludePage("mailTab.jsp",pageContext);%>

<%
    String sFindEmailID = checkString(request.getParameter("FindEmailID"));

    if ((sFindEmailID!=null)&&(sFindEmailID.trim().length()>0)) {
        String sFindSubject, sFindSenderMessage, sFindSenderDate, sFindReceiverDate, sFindReceiverMessage, sFindReceiverName
                ,sFindSenderReadDate;
        byte[] aTmp;
        Email objEmail = Email.selectEmail(Integer.parseInt(sFindEmailID));
        if(objEmail!=null){
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

            if (((sFindSenderReadDate==null)||(sFindSenderReadDate.trim().length()==0)||(sFindSenderReadDate.trim().equals("")))
            &&(sFindReceiverMessage.trim().length()>0)) {
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
                <input type="button" value="<%=getTranNoLink("Web.Occup","medwan.common.print",sWebLanguage)%>" class="button" onclick="doPrint();">&nbsp;
            <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    }
%>
<form name="transactionForm" method="post">
<table cellspacing="1" class="list" width="100%">
<tr class="admin">
    <td width="1%"></td>
    <td width="120"><%=getTran("Web.Mail","SendDate",sWebLanguage)%></td>
    <td width="120"><%=getTran("Web.Mail","AnswerDate",sWebLanguage)%></td>
    <td width="200"><%=getTran("Web.Mail","Destination",sWebLanguage)%></td>
    <td width="*"><%=getTran("Web.Mail","Subject",sWebLanguage)%></td>
    <td width="1%"></td>
</tr>
<%
    String sActionField = checkString(request.getParameter("ActionField"));
    if ((sActionField != null) && (sActionField.trim().equals("Archive"))) {
        String sArchiveEmailID;
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            sArchiveEmailID = (String) e.nextElement();
            if (sArchiveEmailID.startsWith("Archive")) {
                sArchiveEmailID = sArchiveEmailID.substring(7);
                Email.setEmailArchived(Integer.parseInt(sArchiveEmailID));
            }
        }
    }
    String sEmailID, sSubject, sReceiverName, sSenderDate, sReceiverDate, sImg, sClass = "", sSenderReadDate, sBoldBegin, sBoldEnd;
    Vector vEmails = Email.selectEmailsFromSenderNotArchived(Integer.parseInt(activeUser.userid));
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
        sBoldBegin = "<b>";
        sBoldEnd = "</b>";

        if (sClass.equals("")) {
            sClass = " class='list'";
        } else {
            sClass = "";
        }

        if ((sSenderReadDate != null) && (sSenderReadDate.trim().length() > 0) && (sReceiverDate.trim().length() == 0)) {
            sImg = "<img src='" + sCONTEXTPATH + "/_img/read.gif'>";
            sBoldBegin = "";
            sBoldEnd = "";
        }
%>
        <tr<%=sClass%>>
            <td><%=sImg%></td>
            <td><a href="#" onclick="transactionForm.FindEmailID.value='<%=sEmailID%>';transactionForm.submit();"><%=sSenderDate%></a></td>
            <td><%=(sBoldBegin+sReceiverDate+sBoldEnd)%></td>
            <td><%=(sBoldBegin+sReceiverName+sBoldEnd)%></td>
            <td><%=(sBoldBegin+sSubject+sBoldEnd)%></td>
            <td><input type="checkbox" name="Archive<%=sEmailID%>"></td>
        </tr>
        <%
    }
%>
</table>
<input type="hidden" name="ActionField">
<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" name="ButtonArchive" value="<%=getTranNoLink("Web.mail","ArchiveButton",sWebLanguage)%>" onclick="transactionForm.ActionField.value='Archive';transactionForm.submit()">
<%=ScreenHelper.alignButtonsStop()%>
<input type="hidden" name="FindEmailID">
</form>

<script>
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }
</script>
