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
                        <input type='button' name='saveButton' class="button" Value='<%=getTran("Web","save",sWebLanguage)%>' onClick="doSubmit();">
                        <input type='button' name='backButton' class="button" Value='<%=getTran("Web","back",sWebLanguage)%>' OnClick='doBack();'>
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
                if(!isNumberLimited(document.all['EditTimeout'],<%=iMinimumTimeout%>,<%=iMaximumTimeout%>)){
                  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Occup&labelID=out-of-bounds-value";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Occup","out-of-bounds-value",sWebLanguage)%>");

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
      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        activeUser.removeParameter("Timeout",ad_conn);
        activeUser.updateParameter(parameter,ad_conn);
        ad_conn.close();
        activeUser.parameters.add(parameter);
        session.setAttribute("activeUser",activeUser);

        // return to userprofile index
        out.print("<script>doBack();</script>");
    }
%>