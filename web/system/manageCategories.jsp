<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    String sAction             = checkString(request.getParameter("Action")),
           sFindCategoryCode    = checkString(request.getParameter("FindCategoryCode")),
           sFindCategoryText    = checkString(request.getParameter("FindCategoryText")),
           sEditOldCategoryCode = checkString(request.getParameter("EditOldCategoryCode"));

    // DEBUG ////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n### mngCategories #############################################");
        Debug.println("# sAction             : " + sAction);
        Debug.println("# sFindCategoryCode    : " + sFindCategoryCode);
        Debug.println("# sFindCategoryText    : " + sFindCategoryText);
        Debug.println("# sEditOldCategoryCode : " + sEditOldCategoryCode + "\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    String tmpLang;

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    // get all params starting with 'EditLabelValueXX', representing labels in different languages
    Hashtable labelValues = new Hashtable();
    Enumeration paramEnum = request.getParameterNames();
    String tmpParamName, tmpParamValue;

    if (sAction.equals("save")) {
        while (paramEnum.hasMoreElements()) {
            tmpParamName = (String) paramEnum.nextElement();

            if (tmpParamName.startsWith("EditLabelValue")) {
                tmpParamValue = request.getParameter(tmpParamName);
                labelValues.put(tmpParamName.substring(14), tmpParamValue); // language, value
            }
        }
    }
    else if (sAction.equals("edit")) {
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            labelValues.put(tmpLang, getTranDb("admin.category", sFindCategoryCode, tmpLang)); // language, value
        }
    }

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") && sEditOldCategoryCode.length() > 0) {
        String sEditCategoryCode = checkString(request.getParameter("EditCategoryCode"));
        String sEditCategoryParentID = checkString(request.getParameter("EditCategoryParentCode"));
        // new
        if (sEditOldCategoryCode.equals("-1")) {
            //*** INSERT Category ******************************************************************
            Hashtable hCategoryInfo = new Hashtable();
            hCategoryInfo.put("categoryid",sEditCategoryCode.toUpperCase());
            hCategoryInfo.put("oldcategoryid",sEditOldCategoryCode.toUpperCase());
            hCategoryInfo.put("updatetime",getSQLTime());
            hCategoryInfo.put("categoryparentid",sEditCategoryParentID);
            hCategoryInfo.put("updateuserid",activeUser.userid);

            Category.manageCategorySave(hCategoryInfo);

            Label objLabel;
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                objLabel = new Label();
                objLabel.type = "admin.category";
                objLabel.id = sEditCategoryCode;
                objLabel.language = tmpLang;
                objLabel.value = checkString((String) labelValues.get(tmpLang));
                objLabel.showLink = "0";
                objLabel.updateUserId = activeUser.userid;

                objLabel.saveToDB();

                MedwanQuery.getInstance().removeLabelFromCache("admin.category", sEditCategoryCode, tmpLang);
                MedwanQuery.getInstance().getLabel("admin.category", sEditCategoryCode, tmpLang);
            }
        }
        //*** UPDATE Category **********************************************************************
        else {
            Hashtable hCategoryInfo = new Hashtable();
            hCategoryInfo.put("categoryid",sEditCategoryCode);
            hCategoryInfo.put("updatetime",getSQLTime());
            hCategoryInfo.put("categoryparentid",sEditCategoryParentID);
            hCategoryInfo.put("updateuserid",activeUser.userid);
            hCategoryInfo.put("oldcategoryid",sEditOldCategoryCode.toUpperCase());

            Category.manageCategoryUpdate(hCategoryInfo);

            //***** update labels for all supported languages *****

            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            Label objLabel;
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                objLabel = new Label();
                objLabel.type = "admin.category";
                objLabel.id = sEditCategoryCode;
                objLabel.language = tmpLang;
                objLabel.value = checkString((String) labelValues.get(tmpLang));
                objLabel.showLink = "0";
                objLabel.updateUserId = activeUser.userid;

                objLabel.saveToDB();

                MedwanQuery.getInstance().removeLabelFromCache("admin.category", sEditCategoryCode, tmpLang);
                MedwanQuery.getInstance().getLabel("admin.category", sEditCategoryCode, tmpLang);
            }
        }

        reloadSingleton(session);

        sFindCategoryCode = sEditCategoryCode;
        if (sFindCategoryCode.length() > 0) {
            sFindCategoryText = getTranNoLink("admin.category", sEditCategoryCode, sWebLanguage);
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete")) {
        //*** delete Category **********************************************************************
        try {
            if (sFindCategoryCode.length() > 0) {
                Category category = Category.getCategory(sFindCategoryCode);
                if (category != null) {
                  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    category.delete(ad_conn);
                    ad_conn.close();
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        //*** delete label ************************************************************************
        try {
            if (sFindCategoryCode.length() > 0) {
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                while (tokenizer.hasMoreTokens()) {
                    tmpLang = tokenizer.nextToken();
                    Label.delete("admin.category", sFindCategoryCode, tmpLang);
                }
                labelValues = new Hashtable();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        sAction = "";
        sFindCategoryCode = "";
        sFindCategoryText = "";
    }
%>
<%=sJSEMAIL%>
<form name="transactionForm" id="transactionForm" method="post">
    <input type="hidden" name="Action">
<%-- SEARCH FIELDS ------------------------------------------------------------------------------%>
<%
    // only display header when not editing the data
    if(sAction.equals("") || sAction.equals("save")){
        %>
            <%=writeTableHeader("Web.manage","ManageCategories",sWebLanguage," doBackToMenu();")%>

            <table width="100%" class="menu" cellspacing="0">
                <tr>
                    <td class="menu">
                        &nbsp;<%=getTran("admin","category",sWebLanguage)%>
                        <input class="text" type="text" name="FindCategoryText" READONLY size="<%=sTextWidth%>" title="<%=sFindCategoryText%>" value="<%=sFindCategoryText%>">
                        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchCategory('FindCategoryCode','FindCategoryText');">
                        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindCategoryCode.value='';transactionForm.FindCategoryText.value='';">
                        <input type="hidden" name="FindCategoryCode" value="<%=sFindCategoryCode%>">&nbsp;
                        <%-- BUTTONS --%>
                        <input type="button" class="button" name="editButton" value="<%=getTran("Web","Edit",sWebLanguage)%>" onclick="doEdit(transactionForm.FindCategoryCode.value);">
                        <input type="button" class="button" name="clearButton" value="<%=getTran("Web","Clear",sWebLanguage)%>" onclick="clearFields();">
                        <input type="button" class="button" name="newButton" value="<%=getTran("Web","new",sWebLanguage)%>" onclick="doNew();">
                        <input type="button" class="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete(transactionForm.FindCategoryCode.value);">
                        <input type="button" class="button" name="backButton" value="<%=getTran("Web","Back",sWebLanguage)%>" OnClick="doBackToMenu();">
                    </td>
                </tr>
            </table>
        <%
    }
%>

<script>
  <%-- popup : search Category --%>
  function searchCategory(CategoryUidField,CategoryNameField){
    openPopup("/_common/search/searchCategory.jsp&ts=<%=getTs()%>&VarCode="+CategoryUidField+"&VarText="+CategoryNameField);
  }

  <%-- DO EDIT --%>
  function doEdit(CategoryId){
    if(CategoryId.length > 0){
      transactionForm.Action.value = "edit";
      transactionForm.submit();
    }
  }

  <%-- DO DELETE --%>
  function doDelete(CategoryId){
    if(CategoryId.length > 0){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

      if(answer==1){
        transactionForm.Action.value = "delete";
        transactionForm.submit();
      }
    }
  }

  <%-- DO BACK --%>
  function doBackToMenu(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/manageCategories.jsp";
  }

  <%-- DO NEW --%>
  function doNew(){
    clearFields();

    transactionForm.Action.value = "new";
    transactionForm.submit();
  }

  <%-- CLEAR FIELDS --%>
  function clearFields() {
    transactionForm.FindCategoryCode.value = "";
    transactionForm.FindCategoryText.value = "";
  }
</script>
<%
    if(sAction.equals("new")){
        sFindCategoryCode = "-1";
        sAction = "edit";
    }

    //--- DISPLAY SPECIFIED Category ---------------------------------------------------------------
    if(sAction.equals("edit") && sFindCategoryCode.length() > 0){
        String sCategoryParentCodeText = "";
        Label label = new Label();
        Category category;

        category = Category.getCategory(sFindCategoryCode);
        if(category!=null){
            // translate
            if(category.parentcode.trim().length()>0) {
                sCategoryParentCodeText = getTran("admin.category",category.parentcode,sWebLanguage);
            }

            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
            Label objLabel;
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                objLabel = new Label();
                Label.get("admin.category",category.code,tmpLang);
                category.labels.add(objLabel);
                category.labels.add(label);
            }
        }else{
            category = new Category();
        }
        %>
            <input type="hidden" name="EditOldCategoryCode" value="<%=sFindCategoryCode%>">
            <%-- page title --%>
            <%=writeTableHeader("Web.manage","ManageCategories",sWebLanguage," doBackToMenu();")%>
            <%-- Category DETAILS ----------------------------------------------------------------%>
            <table width="100%" class="list" cellspacing="1">
                <%-- Category --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"> <%=getTran("Web.Manage.Category","ID",sWebLanguage)%> *</td>
                    <td class="admin2">
                        <input type="text" class="text" name="EditCategoryCode" value="<%=category.code%>" size="<%=sTextWidth%>">
                    </td>
                </tr>
                <%-- ParentID --%>
                <tr>
                    <td class="admin"> <%=getTran("Web.Manage.Category","ParentID",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" readonly class="text" name="EditCategoryParentText" value="<%=sCategoryParentCodeText%>" size="<%=sTextWidth%>">
                        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchCategory('EditCategoryParentCode','EditCategoryParentText');">
                        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditCategoryParentCode.value='';transactionForm.EditCategoryParentText.value='';">
                        <input type="hidden" name="EditCategoryParentCode" value="<%=category.parentcode%>">
                    </td>
                </tr>
                <%
                    // display input field for each of the supported languages
                    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                    while(tokenizer.hasMoreTokens()){
                        tmpLang = tokenizer.nextToken();

                        %>
                            <tr>
                                <td class="admin"> <%=getTran("Web","Description",sWebLanguage)%> <%=tmpLang%> *</td>
                                <td class="admin2">
                                    <input type="text" class="text" name="EditLabelValue<%=tmpLang%>" value="<%=checkString((String)labelValues.get(tmpLang))%>" size="<%=sTextWidth%>">
                                </td>
                            </tr>
                        <%
                    }
                %>
            </table>
            <%-- indication of obligated fields --%>
            <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%-- EDIT BUTTONS --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input class="button" type="button" name="saveButton" value='<%=getTran("Web","Save",sWebLanguage)%>' onclick="doSave();">
                <input type="button" class="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete(transactionForm.EditCategoryCode.value);">
                <input class="button" type="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick='doBack();'>
            <%=ScreenHelper.alignButtonsStop()%>
            <script>
              transactionForm.EditCategoryCode.focus();

              <%-- DO SAVE --%>
              function doSave(){
                  if(transactionForm.EditCategoryCode.value.length>0){
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
                      transactionForm.saveButton.disabled = true;
                      transactionForm.Action.value = "save";
                      transactionForm.submit();
                    }
                    else{
                        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
                        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");

                        emptyLabelField.focus();
                    }
                  }
                  else{
                    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
                    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
                  }
              }
            </script>
        <%
    }
%>
</form>