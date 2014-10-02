<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.Mail,
                net.admin.system.EmailDestination,
                net.admin.system.Email"%>
<%@ page import="java.util.Vector" %>

<%ScreenHelper.setIncludePage("mailTab.jsp",pageContext);%>

<%
    if (checkString(request.getParameter("EditDestinationName")).length()==0){
        String sText = "";
        if ((activePatient!=null)&&(activePatient.lastname!=null)) {
            sText = "Patient: "+activePatient.lastname+" "+activePatient.firstname+" "+activePatient.getID("immatnew")+"\r\n";
        }
%>
<form name="MailForm" method="post">

<table width="100%" class="list" cellspacing="1">
    <tr class="admin">
        <td colspan="2"><%=getTran("Web","Email",sWebLanguage)%></td>
    </tr>

    <%-- DESTINATION --%>
    <tr>
        <td class="admin"><%=getTran("Web.Mail","Destination",sWebLanguage)%></td>
        <td class="admin2">
            <select name="EditDestination" class="text">
            <%
                String sTmpDestinationID, sTmpDestinationLabel;
                Vector vEmailDest = EmailDestination.getEmailDestinations(" ORDER BY destinationlabel");
                Iterator iter = vEmailDest.iterator();

                EmailDestination objED;

                while (iter.hasNext()) {
                    objED = (EmailDestination) iter.next();
                    sTmpDestinationID = Integer.toString(objED.getDestinationid());
                    sTmpDestinationLabel = objED.getDestinationlabel();
            %>
                        <option value="<%=sTmpDestinationID%>"><%=sTmpDestinationLabel%></option>
                    <%
                }
            %>
            </select>
        </td>
    </tr>

    <%-- MESSAGE --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
        <td class="admin2"><%=writeTextarea("EditMessage","","10","",sText)%></td>
    </tr>
</table>

<%-- SUBMIT BUTTON --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="SendEmail" value="<%=getTranNoLink("Web.Occup","medwan.common.send",sWebLanguage)%>" onclick="submitForm()">
<%=ScreenHelper.alignButtonsStop()%>

<input type="hidden" name="EditDestinationName">

<script>
  MailForm.EditMessage.focus();

  function submitForm(){
    MailForm.EditDestinationName.value = MailForm.EditDestination.options[document.MailForm.EditDestination.selectedIndex].text;
    MailForm.SendEmail.disabled = true;
    MailForm.submit();
  }
</script>

</form>
<%
    }
    else{
        String sMessage = checkString(request.getParameter("EditMessage"));
        String sDestination = checkString(request.getParameter("EditDestination"));
        String sDestinationName = checkString(request.getParameter("EditDestinationName"));

        if ((sMessage.trim().length()>0)&&(sDestination.trim().length()>0)) {
            String sFrom = checkString(activeUser.person.lastname+" "+activeUser.person.firstname);
            String sUnit = "", sFromEmail = activeUser.person.getActiveWork().email+"";
            AdminWorkContact awc = ScreenHelper.getActiveWork(activeUser.person);
            if (awc != null) {
                Service as =ScreenHelper.getService(awc,"M");
                if (as != null) {
                    String sTmp = checkString(as.code);
                    if (sTmp.trim().length()>0){
                       sUnit = getTran("service",sTmp, sWebLanguage);
                    }
                    sFromEmail = checkString(as.email);
                    if (sFromEmail.trim().length()==0) {
                        sFromEmail = MedwanQuery.getInstance().getConfigString("DefaultFromMailAddress");
                    }
                }
            }
            String sDestinationEmail = "", sDestinationUserIDs = "";
            EmailDestination objED = EmailDestination.getEmailDestination(sDestination);
            if(objED != null){
                sDestinationEmail = objED.getDestinationemail();
                sDestinationUserIDs = objED.getDestinationuserids();
            }

            sMessage += "\r\n \r\n \r\n"+sFrom+"\r\n"+sUnit+"\r\n\r\n"+getDate();

            String errorMsg = "";
            try{
                Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"),sFromEmail,sDestinationEmail,sAPPTITLE+" message from "+sFrom.toUpperCase(), sMessage);
            }
            catch(Exception e){
                errorMsg = e.getMessage();
            }

            String sEmailID = MedwanQuery.getInstance().getNewResultCounterValue("EmailID");

            Email objEmail = new Email();
            objEmail.setEmailid(Integer.parseInt(sEmailID));
            objEmail.setSenderid(Integer.parseInt(activeUser.userid));
            objEmail.setSenderemail(sFromEmail);
            objEmail.setSubject(sAPPTITLE+" message from "+sFrom.toUpperCase());
            objEmail.setSenderdate(getSQLTime());
            objEmail.setToemail(sDestinationUserIDs);
            objEmail.setReceivername(sDestinationName);
            objEmail.setSendermessage(sMessage.getBytes());

            Email.addEmail(objEmail);

            // mail result
            if(errorMsg.length() > 0){
                %>
                    <br>
                    <div style="color:red"><b>An error occurred</b></div>
                    <br>
                    <b><%=errorMsg%></b>
                    <br><br>
                    <table class="list">
                        <tr><td class="admin" width="70">Server</td><td class="admin2" width="300"><%=MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer")%></td></tr>
                        <tr><td class="admin">From</td><td class="admin2"><%=sFromEmail%></td></tr>
                        <tr><td class="admin">To</td><td class="admin2"><%=sDestinationEmail%></td></tr>
                    </table>
                    <br><br>
                <%
            }
            else{
                %>
                    <br>
                    <b><%=getTran("Web.Occup","medwan.common.email-is-send",sWebLanguage)%> <%=sDestinationEmail%></b>
                    <br><br>
                <%
            }

            %><a href="<c:url value='/main.do'/>?Page=system/mailNew.jsp"><%=getTran("Web.Mail","New",sWebLanguage)%></a><%
        }
    }
%>
