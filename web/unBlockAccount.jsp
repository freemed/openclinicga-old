<%@page import="java.text.DecimalFormat,
                net.admin.system.IntrusionAttempt"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>

<%!
    //--- VERIFY UNBLOCK CODE ---------------------------------------------------------------------
    private boolean verifyUnblockCode(int requestId, int unblockCode){
        return ((int)((Math.floor(((requestId%97)/5.25)*(requestId/525))%787153))==unblockCode);
    }
%>

<%
    String msg = "";

    String sAction = checkString(request.getParameter("Action"));

    // get form data    
    String sLogin       = checkString(request.getParameter("login")),
           sIP          = checkString(request.getParameter("ip")),
           sRequestId   = checkString(request.getParameter("requestId")),
           sUnblockCode = checkString(request.getParameter("unblockCode"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
	    Debug.println("\n************************** /unBlockAccount.jsp ************************");
	    Debug.println("sAction      : "+sAction);
	    Debug.println("sLogin       : "+sLogin);
	    Debug.println("sIP          : "+sIP);
	    Debug.println("sRequestId   : "+sRequestId);
	    Debug.println("sUnblockCode : "+sUnblockCode+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // generate random requestID
    if(sRequestId.length()==0){
        sRequestId = ""+(100000+(int)(Math.random()*1000000000));
    }

    // get ip
    if(sAction.length()==0){
        sIP = request.getLocalAddr();
    }


    //--- UNBLOCK ---------------------------------------------------------------------------------
    if(sAction.equals("unblock")){
        boolean validUnblockCode = verifyUnblockCode(Integer.parseInt(sRequestId),Integer.parseInt(sUnblockCode));

        if(validUnblockCode){
            // intruderID is login or ip
            String sIntruderID = "";
            if(sLogin.length() > 0){
                sIntruderID = sLogin;
            }
            else if(sIP.length() > 0){
                sIntruderID = sIP;
            }

            // unblock account
            try{
                IntrusionAttempt.unblockAccount(sIntruderID,sLogin,sIP);
            }
            catch(Exception e){
                e.printStackTrace();

                // generate new id in order to prevent the user from guessing the unblock-code
                sRequestId = ""+(100000+(int)(Math.random()*1000000000));
            }

            msg = ScreenHelper.getTranNoLink("web.manage","unblocksuccessfull","en")+
                  ", click <a href='"+sCONTEXTPATH+"/"+ScreenHelper.getCookie("activeProjectDir",request)+"'>here</a> to login again.";
        }
        else{
            msg = ScreenHelper.getTranNoLink("web.manage","invalidunblockcode","en");
            sRequestId = ""+(100000+(int)(Math.random()*1000000000));
        }
    }

    Debug.println("*** UNBLOCK CODE : "+new DecimalFormat("000000").format((int)((Math.floor(((Integer.parseInt(sRequestId)%97)/5.25)*(Integer.parseInt(sRequestId)/525))%787153))));
%>

<html>
<head>
    <%=sCSSNORMAL%>
    <%=sJSDROPDOWNMENU%>
</head>

<body>
    <br><br><br>

    <form name="unblockForm" method="post" onKeyDown="if(enterEvent(event,13)){doUnblock();}">
        <input type="hidden" name="Action">

        <table border="0" width="100%" cellspacing="1" class="list">
            <%-- TITLE --%>
            <tr class="admin">
                <td colspan="2">&nbsp;&nbsp;<%=(ScreenHelper.getTranNoLink("Web.manage","unblockaccount","e"))%>&nbsp;</td>
            </tr>

            <%-- LOGIN --%>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=ScreenHelper.getTranNoLink("Web.manage","login","e")%></td>
                <td class="admin2">
                    <input class='text' type='text' name='login' size='20' maxLength='50' value='<%=sLogin%>'/>
                </td>
            </tr>

            <%-- IP --%>
            <tr>
                <td class="admin"><%=ScreenHelper.getTranNoLink("Web.manage","ip","e")%></td>
                <td class="admin2">
                    <input class='text' type='text' name='ip' size='20' maxLength='15' value='<%=sIP%>'/>
                </td>
            </tr>

            <%-- REQUEST ID --%>
            <tr>
                <td class="admin"><%=ScreenHelper.getTranNoLink("Web.manage","unblockrequestid","e")%></td>
                <td class="admin2">
                    <%
                        DecimalFormat deci = new DecimalFormat();
                        deci.setGroupingSize(3);
                        deci.setGroupingUsed(true);
                        String sRequestIdFormatted = deci.format(Integer.parseInt(sRequestId));
                    %>
                    <input type="hidden" name="requestId" value="<%=sRequestId%>">
                    <input class='text' type='text' name='requestIdFormatted' size='20' maxLength='9' value='<%=sRequestIdFormatted%>' READONLY/>
                </td>
            </tr>

            <%-- UNBLOCK CODE --%>
            <tr>
                <td class="admin"><%=ScreenHelper.getTranNoLink("Web.manage","unblockcode","e")%></td>
                <td class="admin2">
                    <input class='text' type='text' name='unblockCode' size='20' maxLength='6' value='<%=sUnblockCode%>'/>
                </td>
            </tr>

            <%-- UNBLOCK BUTTON --%>
            <tr>
                <td class="admin"></td>
                <td class="admin2">
                    <input type='button' name='unblockButton' class="button" value='<%=ScreenHelper.getTranNoLink("Web.manage","unblock","e")%>' onclick="doUnblock();">
                </td>
            </tr>
        </table>

        <%
            // display message
            if(msg.length() > 0){
                %>&nbsp;<%=msg%><%
            }
        %>

        <script>
          document.getElementsByName('login')[0].focus();

          function doUnblock(){
            if((unblockForm.login.value.length>0 || unblockForm.ip.value.length>0) &&
               unblockForm.requestId.value.length>0 &&
               unblockForm.unblockCode.value.length>0){
              unblockForm.unblockButton.disabled = true;
              unblockForm.Action.value = "unblock";
              unblockForm.submit();
            }
            else{
                        window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
            }
          }
        </script>
    </form>
</body>
</html>

