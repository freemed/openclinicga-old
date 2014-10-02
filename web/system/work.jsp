<%@ page import="java.util.Enumeration,java.util.StringTokenizer,java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));
    String tmpLang;

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    // get all params starting with 'EditLabelValueXX', representing labels in different languages
    Hashtable labelValues = new Hashtable();
    Enumeration paramEnum = request.getParameterNames();
    String tmpParamName, tmpParamValue;

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("Save")) {
        session.removeAttribute("WorkTimeMessage");

        // filter out labels from parameters
        while (paramEnum.hasMoreElements()) {
            tmpParamName = (String) paramEnum.nextElement();

            if (tmpParamName.startsWith("EditLabelValue")) {
                tmpParamValue = request.getParameter(tmpParamName);
                labelValues.put(tmpParamName.substring(14), tmpParamValue); // language, value
            }
        }

        // first delete all worktimemessages, then save the new ones
        Label label;

        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            Label.delete("WorkTime", "WorkTimeMessage", tmpLang);

            label = new Label("WorkTime", "WorkTimeMessage", tmpLang, (String) labelValues.get(tmpLang), "", activeUser.userid);
            label.saveToDB();

            // save label in active language to session
            if (sWebLanguage.equalsIgnoreCase(tmpLang)) {
                session.setAttribute("WorkTimeMessage", label.value);
            }
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("Delete")) {
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            Label.delete("WorkTime", "WorkTimeMessage", tmpLang);
        }

        session.removeAttribute("WorkTimeMessage");
    }
    //--- LOAD SAVED VALUES -----------------------------------------------------------------------
    else {
        Label label;
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            label = Label.get("WorkTime", "WorkTimeMessage", tmpLang);
            if (label != null) {
                labelValues.put(tmpLang, label.value);
            }
        }
    }
%>

<form name="transactionForm" method="post">
<input type="hidden" name="Action" value="">
<%=writeTableHeader("Web.occup","medwan.common.work",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<table border="0" width="100%" align="center" cellspacing="1" cellpadding="0" class="list">
<%
    // display input field for each of the supported languages
    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
    while(tokenizer.hasMoreTokens()){
        tmpLang = tokenizer.nextToken();

        %>
        <tr>
            <td class="admin" width="300"><%=getTran("Web.Occup","medwan.common.workuntil",tmpLang)%></td>
            <td class="admin2">
                <input type="text" size="<%=sTextWidth%>" maxLength="255" name="EditLabel
                Value<%=tmpLang%>" value="<%=checkString((String)labelValues.get(tmpLang))%>" class="text">
            </td>
        </tr>
        <%
    }
%>
    <%-- BUTTONS --%>
    <%=ScreenHelper.setFormButtonsStart()%>
        <input type="button" name="SaveButton" class="button" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onClick="doSave();">&nbsp;
        <input type="button" name="ClearButton" class="button" value="<%=getTranNoLink("Web.Work","ShutOff",sWebLanguage)%>" onClick="doClear();">&nbsp;
        <Input type="button" name="BackButton" class="button" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onClick="doBack();">
    <%=ScreenHelper.setFormButtonsStop()%>
</table>
<script>
  <%-- DO CLEAR --%>
  function doClear(){
    transactionForm.Action.value = "Delete";
    transactionForm.SaveButton.disabled = true;
    transactionForm.ClearButton.disabled = true;
    transactionForm.submit();
  }

  <%-- DO SAVE --%>
  function doSave(){
    var allLabelsHaveAValue = true;
    var emptyLabelField = "";

    <%
        tokenizer = new StringTokenizer(supportedLanguages,",");
        while(tokenizer.hasMoreTokens()){
            tmpLang = tokenizer.nextToken();

            %>
                transactionForm.EditLabelValue<%=tmpLang%>.value = trim(transactionForm.EditLabelValue<%=tmpLang%>.value);

                if(allLabelsHaveAValue){
                  if(transactionForm.EditLabelValue<%=tmpLang%>.value.length == 0){
                    allLabelsHaveAValue = false;
                    emptyLabelField = transactionForm.EditLabelValue<%=tmpLang%>;
                  }
                }
            <%
        }
    %>

    if(allLabelsHaveAValue){
      transactionForm.Action.value = "Save";
      transactionForm.SaveButton.disabled = true;
      transactionForm.ClearButton.disabled = true;
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","datamissing");
      emptyLabelField.focus();
    }
  }

  <%-- LTRIM --%>
  function LTrim(value){
    var re = /\s*((\S+\s*)*)/;
    return value.replace(re, "$1");
  }

  <%-- RTRIM --%>
  function RTrim(value){
    var re = /((\s*\S+)*)\s*/;
    return value.replace(re, "$1");
  }

  <%-- TRIM --%>
  function trim(value){
    return LTrim(RTrim(value));
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  <%
      // refresh page to make the "work in progress"-icon visible
      if(sAction.equals("Save") || sAction.equals("Delete")){
          %>
            transactionForm.SaveButton.disabled = true;
            transactionForm.ClearButton.disabled = true;
            transactionForm.submit();
         <%
      }
  %>
</script>
</form>
