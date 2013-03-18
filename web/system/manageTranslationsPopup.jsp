<%@page import="java.util.StringTokenizer" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermissionPopup("system.managetranslations","",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

    // get values from form
    String findLabelID    = checkString(request.getParameter("FindLabelID")),
           findLabelType  = checkString(request.getParameter("FindLabelType")),
           findLabelLang  = checkString(request.getParameter("FindLabelLang")),
           findLabelValue = checkString(request.getParameter("FindLabelValue"));

    String editLabelID    = checkString(request.getParameter("EditLabelID")).toLowerCase(),
           editLabelType  = checkString(request.getParameter("EditLabelType")).toLowerCase(),
           editLabelLang  = checkString(request.getParameter("EditLabelLang")).toLowerCase(),
           editLabelValue = checkString(request.getParameter("EditLabelValue"));

    String editOldLabelID   = checkString(request.getParameter("EditOldLabelID")).toLowerCase(),
           editOldLabelType = checkString(request.getParameter("EditOldLabelType")).toLowerCase(),
           editOldLabelLang = checkString(request.getParameter("EditOldLabelLang")).toLowerCase();

    String editShowLink = checkString(request.getParameter("EditShowLink"));

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";

    // exclusions on labeltype
    boolean excludeServices  = checkString(request.getParameter("excludeServices")).equals("true");
    boolean excludeFunctions = checkString(request.getParameter("excludeFunctions")).equals("true");

    // exclude by default
    if(sAction.equals("")){
        excludeServices = true;
        excludeFunctions = true;
    }

    boolean labelAllreadyExists = false;
    boolean invalidCharFound = false;
    boolean bExists = false;
    String msg = null;

    //*** SAVE ************************************************************************************
    if(sAction.equals("Save")){
        // invalid key chars
        String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
        if(invalidLabelKeyChars.length() == 0){
            invalidLabelKeyChars = " /:"; // default
        }

        // check label type and id for invalid chars
        invalidCharFound = false;
        for(int i=0; i<invalidLabelKeyChars.length(); i++){
            if((editLabelType+editLabelID).indexOf(invalidLabelKeyChars.charAt(i)) > -1){
                invalidCharFound = true;
                msg = getTran("Web.manage","invalidcharsfound",sWebLanguage)+" '"+invalidLabelKeyChars+"'";
                break;
            }
        }

        if(!invalidCharFound){            
            // check existence
            Label oldLabel = new Label();
            oldLabel.type     = editOldLabelType;
            oldLabel.id       = editOldLabelID;
            oldLabel.language = editOldLabelLang;

            if(oldLabel.exists()) bExists = true;

            if(bExists){
                Label label = new Label();
                label.type         = editLabelType;
                label.id           = editLabelID;
                label.language     = editLabelLang;
                label.value        = editLabelValue;
                label.updateUserId = activeUser.userid;
                label.showLink     = editShowLink;

                label.updateByTypeIdLanguage(editOldLabelType,editOldLabelID, editOldLabelLang);

                editOldLabelID = editLabelID;
                editOldLabelType = editLabelType;
                editOldLabelLang = editLabelLang;
                findLabelType = editLabelType;

                reloadSingleton(session);

                msg = "'"+editLabelType+"$"+editLabelID+"$"+editLabelLang+"' "+getTran("Web","saved",sWebLanguage);
            }
            else{
                sAction = "Add";
            }
        }
    }

    //*** ADD *************************************************************************************
    if(sAction.equals("Add")){
        // invalid key chars
        String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
        if(invalidLabelKeyChars.length() == 0){
            invalidLabelKeyChars = " /:"; // default
        }

        // check label type and id for invalid chars
        invalidCharFound = false;
        for(int i=0; i<invalidLabelKeyChars.length(); i++){
            if((editLabelType+editLabelID).indexOf(invalidLabelKeyChars.charAt(i)) > -1){
                invalidCharFound = true;
                msg = getTran("Web.manage","invalidcharsfound",sWebLanguage)+" '"+invalidLabelKeyChars+"'";
                break;
            }
        }

        if(!invalidCharFound){
            // exists ?
            Label label = new Label();
            label.id = editLabelID;
            label.type = editLabelType;
            label.language = editLabelLang;
            label.showLink = editShowLink;
            label.value = editLabelValue;
            label.updateUserId = activeUser.userid;

            // INSERT
            if(!label.exists()){
                label.saveToDB();

                msg = "'"+editLabelType+"$"+editLabelID+"$"+editLabelLang+"' "+getTran("Web","added",sWebLanguage);

                editOldLabelID = editLabelID;
                editOldLabelType = editLabelType;
                editOldLabelLang = editLabelLang;
                findLabelType = editLabelType;

                reloadSingleton(session);
            }
            else{
                // a label with the given ids allready exists
                labelAllreadyExists = true;
                msg = getTran("Web.Manage","labelExists",sWebLanguage);
            }
        }
    }
    //*** DELETE **********************************************************************************
    else if(sAction.equals("Delete")) {
        Label.delete(editLabelType,editLabelID,editLabelLang);
        msg = "'"+editLabelType+"$"+editLabelID+"$"+editLabelLang+"' "+getTran("Web","deleted",sWebLanguage);
        editLabelID = "";
    }

    // reload window-opener after changes are made
    if(sAction.equals("Save") || sAction.equals("Add") || sAction.equals("Delete")){
        if(!bExists){
            out.print("<script>window.opener.location.reload();</script>");
            out.flush();
        }
    }
%>
<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:220px;top:160px;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center"><%=getTran("web","searchInProgress",sWebLanguage)%></td>
        </tr>
    </table>
</div>
<%-- End Floating layer -------------------------------------------------------------------------%>
<form name="transactionForm" method="post" action="<c:url value='/popup.jsp'/>?Page=system/manageTranslationsPopup.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","ManageTranslations",sWebLanguage,"")%>

<%-- SEARCH TABLE -------------------------------------------------------------------------------%>
<table width="100%" cellspacing="0" class="menu" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%-- LABEL TYPE --%>
    <tr>
      <td>&nbsp;<%=getTran("Web","type",sWebLanguage)%></td>
      <td>
          <select name="FindLabelType" class="text">
              <option></option>
              <%
                  String sTmpLabeltype;
                  Vector vLabelTypes = Label.getLabelTypes();
                  Iterator iter = vLabelTypes.iterator();

                  while(iter.hasNext()){
                      sTmpLabeltype = (String)iter.next();

                      %><option value="<%=sTmpLabeltype%>" <%=(sTmpLabeltype.equals(findLabelType)?"selected":"")%>><%=sTmpLabeltype%></option><%
                  }
              %>
          </select>
      </td>
  </tr>

  <%-- LABEL ID --%>
  <tr>
      <td>&nbsp;<%=getTran("Web.Translations","labelid",sWebLanguage)%></td>
      <td><input type="text" class="text" name="FindLabelID" value="<%=findLabelID%>" size="50"></td>
  </tr>
  <%-- LABEL LANGUAGE --%>
  <tr>
      <td>&nbsp;<%=getTran("Web","Language",sWebLanguage)%></td>
      <td>
          <select name="FindLabelLang" class="text">
              <option></option>
              <%
                  String tmpLang;
                  StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                  while (tokenizer.hasMoreTokens()) {
                      tmpLang = tokenizer.nextToken();

              %><option value="<%=tmpLang%>" <%=(findLabelLang.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                  }
              %>
          </select>
      </td>
  </tr>
  <%-- LABEL VALUE --%>
  <tr>
      <td>&nbsp;<%=getTran("Web.Translations","label",sWebLanguage)%></td>
      <td><input type="text" class="text" name="FindLabelValue" value="<%=findLabelValue%>" size="50"></td>
  </tr>
  <%-- EXCLUSIONS --%>
  <tr>
      <td>&nbsp;<%=getTran("Web.Translations","exclusion",sWebLanguage)%></td>
      <td>
          <input type="checkbox" class="checkbox" name="excludeFunctions" id="excludeFunctionsCB" value="true" <%=(excludeFunctions?" CHECKED":"")%>><%=getLabel("web","functions",sWebLanguage,"excludeFunctionsCB")%>&nbsp;
          <input type="checkbox" class="checkbox" name="excludeServices" id="excludeServicesCB" value="true" <%=(excludeServices?" CHECKED":"")%>><%=getLabel("web","services",sWebLanguage,"excludeServicesCB")%>
          &nbsp;&nbsp;

           <%-- SEARCH BUTTONS --%>
          <input type="button" class="button" name="FindButton"  value="<%=getTran("Web","Find",sWebLanguage)%>" onclick="doFind();">&nbsp;
          <input type="button" class="button" name="ClearButton" value="<%=getTran("Web","Clear",sWebLanguage)%>" onClick="clearFindFields();">&nbsp;
          <input type="button" class="button" name="NewButton"   value="<%=getTran("Web","New",sWebLanguage)%>" onClick="doNew();">
      </td>
  </tr>
</table>
<script>
  <%-- do find --%>
  function doFind(){
    var labelType = document.getElementById("FindLabelType");
    var labelID = document.getElementById("FindLabelID");
    var labelLang = document.getElementById("FindLabelLang");
    var labelValue = document.getElementById("FindLabelValue");

    if(labelType.value.length>0 || labelID.value.length>0 || labelLang.value.length>0 || labelValue.value.length>0){
      transactionForm.Action.value = "Find";
      ToggleFloatingLayer("FloatingLayer",1);
      transactionForm.submit();
    }
  }

  <%-- do new --%>
  function doNew(){
    transactionForm.Action.value = "New";
    transactionForm.submit();
  }

  <%-- clear find fields --%>
  function clearFindFields(){
    transactionForm.FindLabelType.selectedIndex = 0;
    transactionForm.FindLabelID.value = "";
    transactionForm.FindLabelLang.selectedIndex = 0;
    transactionForm.FindLabelValue.value = "";

    transactionForm.excludeFunctions.checked = true;
    transactionForm.excludeServices.checked = true;
  }
</script>
<%
    //***** FIND *****
    if(sAction.equals("Find")){
        // compose query
        Vector vLabels = Label.findFunction_manageTranslationsPage(ScreenHelper.checkDbString(findLabelType).toLowerCase(),
                                                                   ScreenHelper.checkDbString(findLabelID).toLowerCase(),
                                                                   ScreenHelper.checkDbString(findLabelLang).toLowerCase(),
                                                                   ScreenHelper.checkDbString(findLabelValue).toLowerCase(),
                                                                   excludeFunctions,excludeServices);

        String sLabelType, sLabelID, sLabelLang, sLabelValue, sClass = "";
        int recsFound = 0;
        StringBuffer foundLabels = new StringBuffer();

        Label label;
        Iterator iterFind = vLabels.iterator();
        while(iterFind.hasNext()){
            label = (Label)iterFind.next();
            sLabelType  = checkString(label.type);
            sLabelID    = checkString(label.id);
            sLabelLang  = checkString(label.language);
            sLabelValue = checkString(label.value);

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            foundLabels.append("<tr class='list"+sClass+"'  onclick=\"setLabel('"+sLabelType+"','"+sLabelID+"','"+sLabelLang+"');\">")
                       .append(" <td colspan='2'>"+sLabelType+"</td>")
                       .append(" <td>"+sLabelID+"</td>")
                       .append(" <td>"+getTran("web.language",sLabelLang,sWebLanguage)+"</td>")
                       .append("<td colspan='2'>"+sLabelValue+"</td>");

            recsFound++;
        }

        if(recsFound>0){
            %>
                <br>
                <%-- SEARCH RESULTS --%>
                <table width="100%" align="center" cellspacing="0" class="list">
                  <%-- HEADER --%>
                  <tr class="admin">
                      <td width="1%">
                          <img id="Input_Hist_S" src="<c:url value='/_img/plus.png'/>" OnClick='showD("Input_Hist","Input_Hist_S","Input_Hist_H")' <%=(sAction.equals("Find")?"style='display:none'":"")%>>
                          <img id="Input_Hist_H" src="<c:url value='/_img/minus.png'/>" OnClick='hideD("Input_Hist","Input_Hist_S", "Input_Hist_H")' <%=(sAction.equals("Find")?"":"style='display:none'")%>>
                      </td>
                      <td width="25%"><%=getTran("Web.Translations","LabelType",sWebLanguage)%></td>
                      <td width="25%"><%=getTran("Web.Translations","LabelID",sWebLanguage)%></td>
                      <td width="10%"><%=getTran("Web","Language",sWebLanguage)%></td>
                      <td width="38%"><%=getTran("Web","Value",sWebLanguage)%></td>
                      <td align="right" width="1%">
                          <a href="#topp" class="topbutton">&nbsp;</a>
                      </td>
                  </tr>

                  <%-- FOUND LABELS --%>
                  <tbody id="Input_Hist" <%=(sAction.equals("Find")?"":"style='display:none'")%> onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                      <%=foundLabels%>
                  </tbody>
                </table>

                <script>
                  <%-- SET LABEL --%>
                  function setLabel(sType,sID,sLang){
                    transactionForm.EditOldLabelType.value = sType;
                    transactionForm.EditOldLabelID.value = sID;
                    transactionForm.EditOldLabelLang.value = sLang;

                    transactionForm.Action.value = "Select";
                    transactionForm.submit();
                  }
                </script>
            <%
        }

        %>
            <span><%=recsFound%> <%=getTran("web","recordsfound",sWebLanguage)%></span>

            <%-- CLOSE BUTTON --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input class="button" type="button" name="closeButton" value="<%=getTran("Web","close",sWebLanguage)%>" onclick="window.close();">
            <%=ScreenHelper.alignButtonsStop()%>
            <br>
        <%
    }
    //***** NEW *****
    else if(sAction.equals("New")){
        editLabelType = "";
        editLabelID = "";
        editLabelLang = "";
        editLabelValue = "";

        editOldLabelType = "";
        editOldLabelID = "";
        editOldLabelLang = "";
    }
    //***** SELECT *****
    else if(sAction.equals("Select")){
        editLabelID = editOldLabelID;
        editLabelType = editOldLabelType;
        editLabelLang = editOldLabelLang;

        Label label = Label.get(editLabelType,editLabelID,editLabelLang);

        if(label!=null){
            editLabelValue = label.value;
            editShowLink = label.showLink;
        }
    }

    if(!sAction.equals("Find")){
        %>
            <br>

            <%-- EDIT TABLE ---------------------------------------------------------------------%>
            <table class="list" width="100%" cellspacing="1">
              <%-- type --%>
              <tr>
                  <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Translations","LabelType",sWebLanguage)%></td>
                  <td class="admin2">
                      <input type="text" class="normal" name="EditLabelType" value="<%=editLabelType%>" size="80">
                  </td>
              </tr>

              <%-- id --%>
              <tr>
                  <td class="admin"><%=getTran("Web.Translations","LabelID",sWebLanguage)%></td>
                  <td class="admin2">
                      <input type="text" class="normal" name="EditLabelID" value="<%=editLabelID%>" size="80">
                  </td>
              </tr>
              <%-- language --%>
              <tr>
                  <td class="admin"><%=getTran("Web","Language",sWebLanguage)%></td>
                  <td class="admin2">
                      <select name="EditLabelLang" class="text">
                          <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                          <%
                              tokenizer = new StringTokenizer(supportedLanguages,",");
                              while(tokenizer.hasMoreTokens()){
                                  tmpLang = tokenizer.nextToken();

                                  %><option value="<%=tmpLang%>" <%=(editLabelLang.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                              }
                          %>
                      </select>
                  </td>
              </tr>
              <%-- value --%>
              <tr>
                  <td class="admin"><%=getTran("Web.Translations","Label",sWebLanguage)%></td>
                  <td class="admin2">
                      <textarea name="EditLabelValue" class="normal" rows="4" cols="80" onKeyDown="textCounter(document.transactionForm.EditLabelValue,document.transactionForm.remLen,250)" onKeyUp="textCounter(document.transactionForm.EditLabelValue,document.transactionForm.remLen,250);resizeTextarea(this,10);"><%=editLabelValue%></textarea>
                      <input readonly type="text" class="normal" name="remLen" size="3" value="250">
                  </td>
              </tr>
              <%-- show link --%>
              <tr>
                  <td class="admin"><%=getTran("Web.Translations","ShowLink",sWebLanguage)%></td>
                  <td class="admin2">
                      <select name="EditShowLink" class="text">
                          <option value="1"<%=(editShowLink.equals("1")?" selected":"")%>><%=getTran("Web","Yes",sWebLanguage)%></option>
                          <option value="0"<%=(editShowLink.equals("0")?" selected":"")%>><%=getTran("Web","No",sWebLanguage)%></option>
                      </select>
                  </td>
              </tr>
            </table>
            <%-- MESSAGE --%>
            <%
                if(sAction.equals("Add") || sAction.equals("Save") || sAction.equals("Delete")){
                    if(msg == null){
                        // std message
                        out.print(getTran("Web.Manage","noDataChanged",sWebLanguage));
                    }
                    else{
                        // custom (red) message
                        %><span <%=(labelAllreadyExists || invalidCharFound)? "style=\"color:red\"":""%>><%=msg%></span><%
                    }
                }
            %>
            <%-- BUTTONS --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input class="button" type="button" name="AddButton" value="<%=getTran("Web","Add",sWebLanguage)%>" onclick="checkAdd();">&nbsp;
                <input class="button" type="button" name="SaveButton" value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="checkSave();">&nbsp;
                <input class="button" type="button" name="DeleteButton" value="<%=getTran("Web","Delete",sWebLanguage)%>" onclick="askDelete();">&nbsp;
                <input class="button" type="button" name="closeButton" value="<%=getTran("Web","close",sWebLanguage)%>" onclick="window.close();">
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      if(sAction.equals("New")){
          %>
            if(transactionForm.FindLabelType.selectedIndex > 0){
              transactionForm.EditLabelType.value = transactionForm.FindLabelType.value;
            }
            transactionForm.EditLabelID.value = transactionForm.FindLabelID.value;

            clearFindFields();
          <%
      }
      else if(sAction.equals("Delete")){
          %>
            clearEditFields();
          <%
      }
      else if(sAction.equals("Edit")){
          %>
            textCounter(transactionForm.EditLabelValue,transactionForm.remLen,250);
            transactionForm.EditLabelType.focus();
          <%
      }
  %>

  transactionForm.FindLabelType.focus();

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditLabelType.value = "";
    transactionForm.EditLabelID.value = "";
    transactionForm.EditLabelLang.value = "";

    transactionForm.EditLabelValue.value = "";
    transactionForm.EditShowLink.selectedIndex = 0;

    textCounter(transactionForm.EditLabelValue,transactionForm.remLen,250);

    transactionForm.EditLabelType.focus();
    transactionForm.SaveButton.disabled = true;
  }

  <%-- CHECK SAVE --%>
  function checkSave(){
    if(formComplete()){
      transactionForm.Action.value = "Save";
      transactionForm.submit();
    }
  }

  <%-- CHECK ADD --%>
  function checkAdd(){
    if(formComplete()){
      transactionForm.Action.value = "Add";
      transactionForm.submit();
    }
  }

  <%-- IS FORM COMPLETE --%>
  function formComplete(){
    if(transactionForm.EditLabelType.value=="" || transactionForm.EditLabelID.value=="" ||
       transactionForm.EditLabelLang.value=="" || transactionForm.EditLabelValue.value==""){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=somefieldsareempty";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","somefieldsareempty",sWebLanguage)%>");

      if(transactionForm.EditLabelType.value.length==0){
        transactionForm.EditLabelType.focus();
      }
      else if(transactionForm.EditLabelID.value.length==0){
        transactionForm.EditLabelID.focus();
      }
      else if(transactionForm.EditLabelLang.selectedIndex==0){
        transactionForm.EditLabelLang.focus();
      }
      else if(transactionForm.EditLabelValue.value.length==0){
        transactionForm.EditLabelValue.focus();
      }

      return false;
    }

    return true;
  }

  <%-- ASK DELETE --%>
  function askDelete() {
    if(transactionForm.EditLabelType.value.length==0 || transactionForm.EditLabelID.value.length==0 || transactionForm.EditLabelLang.value.length==0){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=somefieldsareempty";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","somefieldsareempty",sWebLanguage)%>");

           if(transactionForm.EditLabelType.value.length==0) transactionForm.EditLabelType.focus();
      else if(transactionForm.EditLabelID.value.length==0) transactionForm.EditLabelID.focus();
      else if(transactionForm.EditLabelLang.value.length==0) transactionForm.EditLabelLang.focus();
    }
    else{
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");


      if(answer==1){
        transactionForm.Action.value = "Delete";
        transactionForm.submit();
      }
    }
  }
</script>
  <%-- hidden fields --%>
  <input type="hidden" name="EditOldLabelLang" value="<%=editLabelLang%>">
  <input type="hidden" name="EditOldLabelType" value="<%=editLabelType%>">
  <input type="hidden" name="EditOldLabelID" value="<%=editLabelID%>">
  <input type="hidden" name="Action">

  <%-- ALERT --%>
  <%
      if(labelAllreadyExists || invalidCharFound){
          %>
              <script>
                var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelValue=<%=msg%>";
                var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
               (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=msg%>");
              </script>
          <%
      }
  %>
</form>
