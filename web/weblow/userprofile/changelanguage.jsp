<%@ page import="java.util.StringTokenizer" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>
<%
    String sAction = checkString(request.getParameter("Action"));

    //--- DISPLAY FORM ----------------------------------------------------------------------------
    if(sAction.length() == 0){
        %>
            <form name='transactionForm' method='post'>
                <input type="hidden" name="Action">
                <%=writeTableHeader("Web.UserProfile","changelanguage",sWebLanguage," doBack();")%>
                <table width='100%' cellspacing="1" cellpadding="0" class="list">
                    <%-- language --%>
                    <tr>
                        <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("Web","language",sWebLanguage)%></td>
                        <td class="admin2">
                            <select name="ChangeLanguage" class="text">
                                <%
                                    // supported languages
                                    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                                    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";

                                    String tmpLang;
                                    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                                    while (tokenizer.hasMoreTokens()) {
                                        tmpLang = tokenizer.nextToken();

                                %><option value="<%=tmpLang%>" <%=(sWebLanguage.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type='button' name='saveButton' class="button" Value='<%=getTran("Web","save",sWebLanguage)%>' onClick="doSubmit();">
                        <input type='button' name='backButton' class="button" Value='<%=getTran("Web","back",sWebLanguage)%>' onClick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
            </form>
        <%
    }
    //--- SAVE LANGUAGE AND RETURN TO INDEX -------------------------------------------------------
    else if(sAction.equals("save")){
        sWebLanguage = checkString(request.getParameter("ChangeLanguage"));

        // put new language in activeUser
        ((User)session.getAttribute("activeUser")).person.language = sWebLanguage;

        // put new language in userVO
        SessionContainerWO sessionContainerWO = (SessionContainerWO)session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        if (sessionContainerWO.getUserVO()==null){
            sessionContainerWO.setUserVO(MedwanQuery.getInstance().getUser(activeUser.userid));
        }

        sessionContainerWO.getUserVO().personVO.setLanguage(sWebLanguage);
        session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER",sessionContainerWO);

        // put new language in attribute
        session.setAttribute(sAPPTITLE+"WebLanguage",sWebLanguage);

        // return to userprofile index
        out.print("<script>doBack();</script>");
    }
%>
<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    transactionForm.Action.value = "save";
    transactionForm.submit();
  }
</script>