<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*" %>

<%=checkPermission("system.management","all",activeUser)%>

<%
    Label label;

    String sAction = checkString(request.getParameter("Action"));

    // get form data
    String sEditFavoriteId = checkString(request.getParameter("EditFavoriteId")).toLowerCase(),
            sEditOldFavoriteId = checkString(request.getParameter("EditOldFavoriteId")).toLowerCase();
    if (sAction.equals("show")) sEditFavoriteId = sEditOldFavoriteId;
    if (sEditFavoriteId.equals("-1")) sEditOldFavoriteId = sEditFavoriteId;
    if (sEditOldFavoriteId.length() == 0) sEditOldFavoriteId = sEditFavoriteId;

    // DEBUG ////////////////////////////////////////////////////////////
    Debug.println("*** sAction : " + sAction + " *******************************");
    Debug.println(" sEditFavoriteId    : " + sEditFavoriteId);
    Debug.println(" sEditOldFavoriteId : " + sEditOldFavoriteId + "\n");
    /////////////////////////////////////////////////////////////////////

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if (supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();

    Hashtable labelsForOneFavorite = new Hashtable();
    String tmpParamName, tmpParamValue, tmpLang;

    //--- LABELS FOR ONE FOVORITE -----------------------------------------------------------------
    if (sAction.equals("save")) {
        // get all params starting with 'EditLabelValueXX', representing labels in different languages
        Enumeration paramEnum = request.getParameterNames();
        while (paramEnum.hasMoreElements()) {
            tmpParamName = (String) paramEnum.nextElement();

            if (tmpParamName.startsWith("EditLabelValue")) {
                tmpParamValue = request.getParameter(tmpParamName);
                tmpLang = tmpParamName.substring(14);

                label = new Label();
                label.type = "favorite";
                label.id = sEditFavoriteId;
                label.language = tmpLang;
                label.value = tmpParamValue;

                labelsForOneFavorite.put(label.language, label); // language, label
            }
        }
    } else {
        if (sEditFavoriteId.length() > 0) {
            // add a label to the favorite for each supported language
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                label = Label.get("favorite", sEditOldFavoriteId, tmpLang);
                if (label != null) {
                    labelsForOneFavorite.put(label.language, label);
                }
            }
        }
    }
    //--- SAVE ------------------------------------------------------------------------------------
  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    if (sAction.equals("save")) {
        // check existence in db
        //***** NEW *****
        if (!Label.existsBasedOnName("favorite", sEditFavoriteId, sWebLanguage)) {
            Label tmplabel;
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");

            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();
                Label.delete("favorite", "sEditOldFavoriteId", tmpLang);

                tmplabel = new Label("favorite", sEditFavoriteId, tmpLang, checkString(((Label) labelsForOneFavorite.get(tmpLang)).value), "0", activeUser.userid);
                tmplabel.saveToDB();
            }
        }
        //***** UPDATE *****
        else {

            UserParameter.updateParameter("favorite", sEditFavoriteId, sEditOldFavoriteId);
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                Label objLabel = new Label();
                objLabel.id = sEditFavoriteId;
                objLabel.value = checkString(((Label) labelsForOneFavorite.get(tmpLang)).value);
                objLabel.type = "service";
                objLabel.language = tmpLang;
                objLabel.updateUserId = activeUser.userid;

                objLabel.updateByTypeIdLanguage("service",sEditOldFavoriteId,tmpLang);
            }
        }

        reloadSingleton(session);

        // update userparameters in user-object
        byte[] aPassword = activeUser.password;
        String sLogin = activeUser.userid;
        activeUser = new User();
        activeUser.initialize(ad_conn, sLogin, aPassword);
        session.setAttribute("activeUser", activeUser);
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete")) {
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();
            Label.delete("favorite", sEditFavoriteId, tmpLang);
        }
        Parameter parameter = new Parameter();
        parameter.parameter = "favorite";
        parameter.value = sEditFavoriteId;
        reloadSingleton(session);
        sEditFavoriteId = "";
        labelsForOneFavorite = new Hashtable();

        // update userparameters in user-object
        byte[] aPassword = activeUser.password;
        String sLogin = activeUser.userid;
        activeUser = new User();
        activeUser.initialize(ad_conn, sLogin, aPassword);
        session.setAttribute("activeUser", activeUser);
    }
	ad_conn.close();
    //--- ANY ACTION : display favorites dropdown -------------------------------------------------
    Hashtable hFavorites = (Hashtable) MedwanQuery.getInstance().getLabels().get("nl");
    hFavorites = (Hashtable) hFavorites.get("favorite");
    StringBuffer sSavedFavorites = new StringBuffer();

    if (hFavorites != null) {
        // create a hash with the labelvalue as id
        String labelId;
        Hashtable labelValues = new Hashtable();
        Enumeration enum = hFavorites.keys();
        while (enum.hasMoreElements()) {
            labelId = (String) enum.nextElement();
            label = (Label) hFavorites.get(labelId);
            labelValues.put(label.value, label);
        }

        // sort favorites on VALUE
        Vector keys = new Vector(labelValues.keySet());
        Collections.sort(keys);

        // put favorites in a dropdown
        Iterator iter = keys.iterator();
        while (iter.hasNext()) {
            labelId = (String) iter.next();
            label = (Label) labelValues.get(labelId);

            // add option
            sSavedFavorites.append("<option value='" + label.id + "'");
            if (label.id.equals(sEditFavoriteId)) {
                sSavedFavorites.append(" selected ");
            }
            sSavedFavorites.append(">");

            sSavedFavorites.append(label.value);
        }
    }
%>
<form name="transactionForm" method="post">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.UserProfile","managefavorites",sWebLanguage," doBack();")%>
    <%-- SELECT FAVORITE ------------------------------------------------------------------------%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Favorite",sWebLanguage)%></td>
            <td class="admin2">
                <select name="EditOldFavoriteId" class="text" onchange="doShow();">
                    <option value="-1"><%=getTran("Web","new",sWebLanguage)%></option>
                    <%=sSavedFavorites%>
                </select>
            </td>
        </tr>
    </table>
    <br>
    <%-- FAVORITE DETAILS -----------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%
            // display input field for each of the supported languages
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                label = (Label)labelsForOneFavorite.get(tmpLang);
                if(label==null) label = new Label();

                %>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"> <%=getTran("Web","Description",sWebLanguage)%> <%=tmpLang%> *</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditLabelValue<%=tmpLang%>" value="<%=label.value%>" size="80">
                        </td>
                    </tr>
                <%
            }
        %>
        <%-- URL (=labelid) --%>
        <tr>
            <td class="admin">URL *</td>
            <td class="admin2">
                <input type="text" class="text" name="EditFavoriteId" value="<%=(sEditFavoriteId.equals("-1")?"":sEditFavoriteId)%>" size="80">
            </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <%
                // new favorite
                // display saveButton with add-label + do not display delete button
                if(sEditFavoriteId.equals("-1") || sEditFavoriteId.length()==0){
                    %>
                    <input type="button" class="button" name="saveButton" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="doSave();">
                    <%
                }
                else{
                    // existing favorite
                    // display saveButton with save-label
                    %>
                    <input type="button" class="button" name="saveButton" value="<%=getTran("Web","save",sWebLanguage)%>" onclick="doSave();">
                    <input type="button" class="button" name="deleteButton" value="<%=getTran("Web","delete",sWebLanguage)%>" onclick="doDelete();"/>
                    <%
                }
            %>
            <input type="button" name="backButton" class="button" value="<%=getTran("Web","back",sWebLanguage)%>" OnClick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <%-- indication of obligated fields --%>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<script>
  <%-- DO DELETE --%>
  function doDelete(){
	if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.saveButton.disabled = true;
      transactionForm.backButton.disabled = true;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO SHOW --%>
  function doShow(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    transactionForm.Action.value = "show";
    transactionForm.submit();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(transactionForm.EditFavoriteId.value.length > 0){
        var allLabelsHaveAValue = true;
        var emptyLabelField = "";

        <%
            tokenizer = new StringTokenizer(supportedLanguages,",");
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();

                %>
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
          transactionForm.backButton.disabled = true;
          transactionForm.Action.value = "save";
          transactionForm.submit();
        }
        else{
            var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
            var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            window.showModalDialog(popupUrl,"",modalities);

            emptyLabelField.focus();
        }
    }
    else{
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = window.showModalDialog(popupUrl,"",modalities);

      if(transactionForm.EditFavoriteId.value.length==0){
         transactionForm.EditFavoriteId.focus();
      }
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>