<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<script>
  function doSubmit(){
    checkTimeOut();
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    transactionForm.Action.value = 'save';
    transactionForm.submit();
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>
<%
    String sAction = checkString(request.getParameter("Action"));

    //--- DISPLAY ---------------------------------------------------------------------------------
    if(sAction.length() == 0){
        %>
            <form name='transactionForm' method='post'>
                <input type="hidden" name="Action" value="">
                <%=writeTableHeader("Web.UserProfile","timeout",sWebLanguage," doBack();")%>
                <table width='100%' cellspacing="1" cellpadding="0" class="list">
                    <%-- TIMEOUT --%>
                    <% String sTimeout = checkString(activeUser.getParameter("Timeout")); %>
                    <tr>
                        <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("Web.UserProfile","Change",sWebLanguage)%> <%=getTran("Web.UserProfile","Timeout",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditTimeout" size="5" value="<%=sTimeout%>" onblur="checkTimeOut();">
                            <%=getTran("Web.UserProfile","Seconds",sWebLanguage)%>
                        </td>
                    </tr>
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type='button' name='saveButton' class="button" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick="doSubmit();">
                        <input type='button' name='backButton' class="button" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' OnClick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
                <script>transactionForm.EditTimeout.focus();</script>
            </form>
            <%
                int iDefaultTimeout = MedwanQuery.getInstance().getConfigInt("DefaultTimeOutInSeconds");
                if(iDefaultTimeout==0) iDefaultTimeout = 3600;

                int iMinimumTimeout = MedwanQuery.getInstance().getConfigInt("MinimumTimeoutInSeconds");
                if(iMinimumTimeout==0) iMinimumTimeout = 60;

                int iMaximumTimeout = MedwanQuery.getInstance().getConfigInt("MaximumTimeoutInSeconds");
                if(iMaximumTimeout==0) iMaximumTimeout = 24*3600;
            %>
            <script>
              function checkTimeOut(){
                if(!isNumberLimited(document.getElementsByName('EditTimeout')[0],<%=iMinimumTimeout%>,<%=iMaximumTimeout%>)){
                  alertDialog("Web.Occup","out-of-bounds-value");
                  transactionForm.EditTimeout.value = '<%=iDefaultTimeout%>';
                }
              }
            </script>
        <%
    }
    //--- SAVE AND RETURN TO INDEX ----------------------------------------------------------------
    else if(sAction.equals("save")){
        String sTimeout = checkString(request.getParameter("EditTimeout"));
        if (sTimeout.length()==0) {
            String sDefaultTimeout = checkString(MedwanQuery.getInstance().getConfigString("DefaultTimeOutInSeconds"));
            if (sDefaultTimeout.length()==0) {
                sDefaultTimeout = "3600";
            }
            sTimeout = sDefaultTimeout;
        }

        int iTimeOutInSeconds = 0;
        try {
            iTimeOutInSeconds = Integer.parseInt(sTimeout);
        }
        catch (Exception e) {
            // nothing
        }

        // minimum timeout
        int iMinimumTimeout = MedwanQuery.getInstance().getConfigInt("MinimumTimeoutInSeconds");
        if(iMinimumTimeout==0) iMinimumTimeout = 60;
        if (iTimeOutInSeconds < iMinimumTimeout){
            iTimeOutInSeconds = iMinimumTimeout;
        }

        sTimeout = Integer.toString(iTimeOutInSeconds);
        session.setMaxInactiveInterval(iTimeOutInSeconds);

        // set timeout as parameter in user
        Parameter parameter = new Parameter("Timeout",sTimeout);
        activeUser.removeParameter("Timeout");
        activeUser.updateParameter(parameter);
        activeUser.parameters.add(parameter);
        session.setAttribute("activeUser",activeUser);

        // return to userprofile index
        out.print("<script>doBack();</script>");
    }
%>