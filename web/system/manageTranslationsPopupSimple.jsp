<%@page import="java.util.StringTokenizer" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>
<%=checkPermission("system.managetranslations","all",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

    // get values from form
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
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr,en";

    String msg = null;
    boolean labelAllreadyExists = false,
            invalidCharFound = false,
            labelExists = false;


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

            if(oldLabel.exists()) labelExists = true;

            if(labelExists){
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
            label.type = editLabelType;
            label.id = editLabelID;
            label.language = editLabelLang;
            label.showLink = editShowLink;
            label.value = editLabelValue;
            label.updateUserId = activeUser.userid;

            // INSERT
            if(!label.exists()){
                label.saveToDB();

                msg = getTran("Web.manage","labeladded",sWebLanguage);

                editOldLabelID = editLabelID;
                editOldLabelType = editLabelType;
                editOldLabelLang = editLabelLang;

                reloadSingleton(session);
            }
            else{
                // a label with the given ids allready exists
                labelAllreadyExists = true;
                msg = getTran("Web.Manage","labelExists",sWebLanguage);
            }
        }
    }

    // reload window-opener after changes are made
    if(sAction.equals("Save") || sAction.equals("Add")){
        if(!labelExists){
            out.print("<script>window.opener.location.reload();</script>");
            out.flush();
        }
    }

    //*** ACTIONS *********************************************************************************
    //*** NEW ***
    if(sAction.equals("New")){
        editLabelType = "";
        editLabelID = "";
        editLabelLang = "";
        editLabelValue = "";

        editOldLabelType = "";
        editOldLabelID = "";
        editOldLabelLang = "";
    }
    //*** SELECT ***
    else if(sAction.equals("Select")){
        editLabelID = editOldLabelID;
        editLabelType = editOldLabelType;
        editLabelLang = editOldLabelLang;

        Label label = Label.get(editLabelType,editLabelID,editLabelLang);
        if(label != null){
            editLabelValue = label.value;
            editShowLink   = label.showLink;
        }
    }
%>

<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:220;top:160;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>

<%-- End Floating layer -------------------------------------------------------------------------%>
<form name="transactionForm" method="post" action="<c:url value='/popup.jsp'/>?Page=system/manageTranslationsPopupSimple.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","ManageTranslations",sWebLanguage,"")%>

    <%-- EDIT TABLE -----------------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1" onkeydown="if(enterEvent(event,13)){checkSave();}">
        <input type="hidden" name="EditLabelType" value="<%=editLabelType%>">
        <input type="hidden" name="EditLabelID" value="<%=editLabelID%>">

        <%-- language --%>
        <tr>
            <td class="admin"><%=getTran("Web","Language",sWebLanguage)%></td>
            <td class="admin2">
                <select name="EditLabelLang" class="text">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                        String tmpLang;
                        while (tokenizer.hasMoreTokens()) {
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
                <input readonly type="text" class="text" name="remLen" size="3" value="250">
            </td>
        </tr>
    </table>

    <%-- MESSAGE --%>
    <%
        if(sAction.equals("Add") || sAction.equals("Save")){
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
        <input class="button" type="button" name="SaveButton" value="<%=getTranNoLink("Web","Save",sWebLanguage)%>" onclick="checkSave();">&nbsp;
        <input class="button" type="button" name="closeButton" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
    <%=ScreenHelper.alignButtonsStop()%>
    
    <%-- hidden fields --%>
    <input type="hidden" name="EditOldLabelLang" value="<%=editLabelLang%>">
    <input type="hidden" name="EditOldLabelType" value="<%=editLabelType%>">
    <input type="hidden" name="EditOldLabelID" value="<%=editLabelID%>">
    <input type="hidden" name="Action">
    
    <%-- ALERT --%>
    <%
        if(labelAllreadyExists || invalidCharFound){
            %><script>alertDialogDirectText("<%=msg%>");</script><%
        }
    %>
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  textCounter(transactionForm.EditLabelValue,transactionForm.remLen,250);
  transactionForm.EditLabelValue.focus();

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

  <%-- FORM COMPLETE --%>
  function formComplete(){
    if(transactionForm.EditLabelType.value=="" || transactionForm.EditLabelID.value=="" ||
       transactionForm.EditLabelLang.value=="" || transactionForm.EditLabelValue.value==""){
      alertDialog("web","someFieldsAreEmpty");
      
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
</script>
