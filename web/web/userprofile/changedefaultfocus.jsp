<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>
<%!
    //--- WRITE OPTION ----------------------------------------------------------------------------
    private String writeOption(String sKey, String sCode, String sValue, User activeUser, String sWebLanguage) {
        String sSelected = checkString(activeUser.getParameter(sKey));
        if (sSelected.equals(sValue)) {
            sSelected = " selected";
        }
        else {
            sSelected = "";
        }

        return "<option value='"+sValue+"'"+sSelected+">"+getTran(sCode,sValue,sWebLanguage)+"</option>";
    }
%>
<%
    String sAction = checkString(request.getParameter("Action"));

    //--- DISPLAY FORM ----------------------------------------------------------------------------
    if(sAction.length() == 0) {
        %>
            <form name='UserProfile' method='post'>
                <input type="hidden" name="Action">
                <%=writeTableHeader("Web.UserProfile","changeFocus",sWebLanguage," doBack();")%>
                <table width='100%' cellspacing="1" cellpadding="0" class="list">
                    <tr>
                        <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("Web.UserProfile","Focus",sWebLanguage)%></td>
                        <td class="admin2">
                            <select name='DefaultFocus' class="text">
                                <%=writeOption("DefaultFocus","Web","Name",activeUser,sWebLanguage)%>
                                <%=writeOption("DefaultFocus","Web","DateOfBirth",activeUser,sWebLanguage)%>
                                <%=writeOption("DefaultFocus","Web","natreg",activeUser,sWebLanguage)%>
                                <%=writeOption("DefaultFocus","Web","immatnew",activeUser,sWebLanguage)%>
                                <%=writeOption("DefaultFocus","Web","immatold",activeUser,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type='button' name='saveButton' class="button" value='<%=getTran("Web","save",sWebLanguage)%>' onClick="doSave();">
                        <input type='button' name='backButton' class="button" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
            </form>
        <%
    }
    //--- SAVE FOCUS AND RETURN TO INDEX ----------------------------------------------------------
    else if(sAction.equals("save")){
        String sDefaultFocus = checkString(request.getParameter("DefaultFocus"));
        Parameter parameter = new Parameter("DefaultFocus",sDefaultFocus);

      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        activeUser.removeParameter("DefaultFocus",ad_conn);
        activeUser.updateParameter(parameter,ad_conn);
        ad_conn.close();
        activeUser.parameters.add(parameter);
        session.setAttribute("activeUser",activeUser);

        // return to userprofile index
        out.print("<script>doBack();</script>");
    }
%>
<script>
  function doSave(){
    UserProfile.saveButton.disabled = true;
    UserProfile.backButton.disabled = true;
    UserProfile.Action.value = "save";
    UserProfile.submit();
  }
</script>