<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,java.util.Hashtable,java.util.Enumeration" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

System.out.println("******************************************* sAction : "+sAction); ////////////////
    String sFindKey = checkString(request.getParameter("FindKey"));
    String sFindValue = checkString(request.getParameter("FindValue"));

    String sEditOc_key = checkString(request.getParameter("EditOc_key"));
    String sEditOc_value = checkString(request.getParameter("EditOc_value"));
    String sEditDefaultvalue = checkString(request.getParameter("EditDefaultvalue"));
    String sEditOverride = checkString(request.getParameter("EditOverride"));
    String sEditComment = checkString(request.getParameter("EditComment"));
    String sEditSQLvalue = checkString(request.getParameter("EditSQLvalue"));
    String sEditDeleted = checkString(request.getParameter("EditDeleted"));
    String sEditSynchronize = checkString(request.getParameter("EditSynchronize"));

    /*
    Debug.println("\n==========================================");
    Debug.println("ACTION = "+sAction);
    Debug.println("sFindKey          : "+sFindKey);
    Debug.println("sFindValue        : "+sFindValue);
    Debug.println("sEditOw_key       : "+sEditOw_key);
    Debug.println("sEditOw_value     : "+sEditOw_value);
    Debug.println("sEditDefaultvalue : "+sEditDefaultvalue);
    Debug.println("sEditOverride     : "+sEditOverride);
    Debug.println("sEditComment      : "+sEditComment);
    Debug.println("sEditSQLvalue     : "+sEditSQLvalue);
    Debug.println("sEditDeleted      : "+sEditDeleted);
    Debug.println("sEditSynchronize  : "+sEditSynchronize);
    Debug.println("==========================================\n");
    */
    boolean keyAllreadyExists = false;
    String msg = "";
    String sSelectedOc_key = "", sSelectedOc_value = "", sSelectedComment = "", sSelectedSynchronize = "",
            sSelectedDefaultvalue = "", sSelectedOverride = "", sSelectedSQL_value = "";

    //--- SEARCH -----------------------------------------------------------------------------------
    if (sAction.equals("Add")) {
        if (sEditOc_key != null && sEditOc_key.length() > 0) {
            // check existence
            boolean bExist = Config.exists(sEditOc_key);

            //*** insert ***
            if (!bExist) {
                Config objConfig = new Config();
                objConfig.setOc_key(sEditOc_key);
                objConfig.setOc_value(new StringBuffer(sEditOc_value));
                objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
                objConfig.setUpdatetime(getSQLTime());
                objConfig.setComment(new StringBuffer(sEditComment));
                objConfig.setDefaultvalue(sEditDefaultvalue);
                objConfig.setOverride(sEditOverride.length() > 0 ? Integer.parseInt(sEditOverride) : 0);
                objConfig.setSql_value(new StringBuffer(sEditSQLvalue));

                if (sEditDeleted.equals("on")) {
                    objConfig.setDeletetime(new Timestamp(new java.util.Date().getTime()));
                } else {
                    objConfig.setDeletetime(null);
                }

                Config.addConfig(objConfig);

                msg = "Key '" + sEditOc_key + "' " + getTran("Web", "added", sWebLanguage);
            } else {
                // record found
                keyAllreadyExists = true;
                msg = "Key '" + sEditOc_key + "' " + getTran("Web", "exists", sWebLanguage);
            }

            sFindKey = sEditOc_key;
            sAction = "Show";

            MedwanQuery.getInstance().reloadConfigValues();
        }
    }
    //--- SAVE -------------------------------------------------------------------------------------
    else if (sAction.equals("Save")) {
        if (sEditOc_key != null && sEditOc_key.length() > 0) {
            //*** update ***
            Config objConfig = Config.getConfig(sEditOc_key);
            
            objConfig.setOc_value(new StringBuffer(sEditOc_value));
            objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objConfig.setUpdatetime(getSQLTime());
            objConfig.setComment(new StringBuffer(sEditComment));
            objConfig.setDefaultvalue(sEditDefaultvalue);
            objConfig.setOverride(sEditOverride.length() > 0 ? Integer.parseInt(sEditOverride) : 0);
            objConfig.setSql_value(new StringBuffer(sEditSQLvalue));
            objConfig.setSynchronize(sEditSynchronize);

            if (sEditDeleted.equals("on")) {
                objConfig.setDeletetime(new Timestamp(new java.util.Date().getTime()));
            } else {
                objConfig.setDeletetime(null);
            }

            Config.saveConfig(objConfig);

            msg = "Key '" + sEditOc_key + "' " + getTran("Web", "saved", sWebLanguage);
            sAction = "Show";

            MedwanQuery.getInstance().reloadConfigValues();
        }
        out.print("<script>window.setTimeout('doSearch();',500);</script>");
    }
    //--- DELETE -----------------------------------------------------------------------------------
    else if (sAction.equals("Delete")) {
        if (sEditOc_key != null && sEditOc_key.length() > 0) {
            Config.deleteConfig(sEditOc_key);

            MedwanQuery.reload();

            msg = "Key '" + sEditOc_key + "' " + getTran("Web", "deleted", sWebLanguage);
            sAction = "Show";

            MedwanQuery.getInstance().reloadConfigValues();
        }
    }
    //--- NEW --------------------------------------------------------------------------------------
    else if (sAction.equals("New")) {
        sSelectedOc_key = sFindKey;
        sSelectedOc_value = sFindValue;
    }

    //--- SHOWDETAILS (= search one specific record to show later) ---------------------------------
    if (sAction.equals("Show")) {
    	System.out.println("*********************** sAction *****************************"); ////////////////
        Config objConfig = Config.getConfig(sEditOc_key);
        if (objConfig.getDeletetime() != null) sEditDeleted = "on";

        sSelectedOc_key = sEditOc_key;
        sSelectedOc_value = objConfig.getOc_value().toString();
        System.out.println("****************** sSelectedOc_value : "+sSelectedOc_value); //////////
        sSelectedComment = objConfig.getComment().toString();
        sSelectedDefaultvalue = objConfig.getDefaultvalue();
        sSelectedOverride = Integer.toString(objConfig.getOverride());
        sSelectedSQL_value = objConfig.getSql_value().toString();
        sSelectedSynchronize = objConfig.getSynchronize();
        
        MedwanQuery.getInstance().reloadConfigValues();  
        
        out.print("<script>window.setTimeout('doSearch();',500);</script>");
    }

%>
<form name="transactionForm" method="post"
    <%                      
        // enter button only works when searching (not when the edit fields are visible)
            %>onKeyDown='if(enterEvent(event,13)){doSearch();}'<%
    %>
>
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.manage","ManageConfiguration",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width="100%" cellspacing="0" class="menu">
        <%-- search fields --%>
        <tr>
            <td>Key</td>
            <td><input type="text" class="text" name="FindKey" size="40" value="<%=sFindKey%>"></td>
        </tr>
        <tr>
            <td><%=getTran("Web","value",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindValue" size="40" value="<%=sFindValue%>"></td>
        </tr>
        <tr>
            <td/>
            <td>
                <input type="button" class="button" name="SearchButton" value="<%=getTran("Web","search",sWebLanguage)%>" onClick="doSearch();">&nbsp;
                <input type="button" class="button" name="ClearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onClick="clearFindFields();">&nbsp;
                <input type="button" class="button" name="NewButton" value="<%=getTran("Web","New",sWebLanguage)%>" onClick="doNew();">&nbsp;
                <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
                &nbsp;
                <img src='<c:url value="/_img/pijl.gif"/>'>
                <a  href="<c:url value='/main.do?Page=system/manageConfigTabbed.jsp?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Manage","manageConfigurationTabbed",sWebLanguage)%></a>&nbsp;
            </td>
        </tr>
    </table>
    <br>
    <div style="height:150px;" class="searchResults" id="divFindRecords"></div>
    <%
      //  if(sAction.equals("Show") || sAction.equals("New")){
            %>
            <br>
            <%-- edit fields --%>
            <table class="list" width="100%" cellspacing="1">
                <%-- key --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>">Key</td>
                    <td class="admin2"><input class="text" type="text" name="EditOc_key" value="<%=sSelectedOc_key%>" size="70"></td>
                </tr>
                <%-- value --%>
                <tr>
                    <td class="admin"><%=getTran("Web","value",sWebLanguage)%></td>
                    <td class="admin2">
                    <%
                        if(sSelectedSQL_value.length() > 0 && sSelectedSQL_value.toLowerCase().startsWith("select")){
                            %><select class="text" name="EditOc_value"><%
                        Hashtable hSQL = Config.executeConfigSQL_value(sSelectedSQL_value);
                        Enumeration enum2 = hSQL.keys();
                        String sSQLID, sSQLName;
                        while (enum2.hasMoreElements()) {
                            sSQLID = (String) enum2.nextElement();
                            sSQLName = (String) hSQL.get(sSQLID);

                            if (sSQLID.equalsIgnoreCase(sSelectedOc_value)) {
                    %><option value="<%=sSQLID%>" SELECTED><%=(sSQLID+" "+sSQLName)%></option><%
                                }
                                else{
                                    %><option value="<%=sSQLID%>"><%=(sSQLID+" "+sSQLName)%></option><%
                                }
                            }
                            %></select><%
                        }
                        else{
                            %><%=writeTextarea("EditOc_value","","4","",sSelectedOc_value)%><%
                        }
                     %>
                    </td>
                </tr>
                <%-- default value --%>
                <tr>
                    <td class="admin"><%=getTran("Web.Manage.Config","Defaultvalue",sWebLanguage)%></td>
                    <td class="admin2"><%=writeTextarea("EditDefaultvalue","","4","",sSelectedDefaultvalue)%></td>
                </tr>
                <%-- systemvalue overwritable --%>
                <tr>
                    <td class="admin"><%=getTran("Web.Manage.Config","OverrideSystemValue",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="radio" name="EditOverride" value="0" onDblClick="uncheckRadio(this);" <%if(sSelectedOverride.equals("0")){out.print("checked");}%>><%=getTran("Web","No",sWebLanguage)%>
                        <input type="radio" name="EditOverride" value="1" onDblClick="uncheckRadio(this);" <%if(sSelectedOverride.equals("1")){out.print("checked");}%>><%=getTran("Web","Yes",sWebLanguage)%>
                    </td>
                </tr>
                <%-- SQL --%>
                <tr>
                    <td class="admin">SQL (SQLID, SQLName)</td>
                    <td class="admin2"><%=writeTextarea("EditSQLvalue","","4","",sSelectedSQL_value)%></td>
                </tr>
                <%-- comment --%>
                <tr>
                    <td class="admin"><%=getTran("Web","Comment",sWebLanguage)%></td>
                    <td class="admin2"><%=writeTextarea("EditComment","","4","",sSelectedComment)%></td>
                </tr>
                <%-- synchronize --%>
                <tr>
                    <td class="admin"><%=getTran("Web.manage","synchronise",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="checkbox" name="EditSynchronize" value="1" <%=(sSelectedSynchronize.equals("1")?"CHECKED":"")%>>
                    </td>
                </tr>
                <%-- deleted --%>
                <tr>
                    <td class="admin"><%=getTran("Web","deleted",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="checkbox" name="EditDeleted" <%=(sEditDeleted.equals("on")?"CHECKED":"")%>>
                    </td>
                </tr>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                     <%
                            if(sAction.equals("Show")){
                                %>
                                <input class='button' type="button" name="SaveButton" value='<%=getTran("Web","Save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                                <input class="button" type="button" name="AddButton" value='<%=getTran("Web","Add",sWebLanguage)%>' onclick="doAdd();">&nbsp;
                                <%
                            }
                            else if(sAction.equals("New")){
                                %>
                                <input class="button" type="button" name="AddButton" value='<%=getTran("Web","Add",sWebLanguage)%>' onclick="doAdd();">&nbsp;
                                <%
                            }
                        %>
                    </td>
                </tr>
                <%-- message --%>
                <tr>
                    <td class="admin2" colspan="2">
                        <%
                          if(sAction.equals("Show") || sAction.equals("New")){
                              if(msg == null){
                                  // std message
                                  %><%=getTran("Web.Manage","noDataChanged",sWebLanguage)%><%
                              }
                              else{
                                  // custom (red) message
                                  %><span <%=(keyAllreadyExists? "style=\"color:red\"":"")%>><%=msg%></span><%
                              }
                          }
                        %>
                    </td>
                </tr>
            </table>
            <%
      //  }
    %>
</form>
<%-- SCRIPTS -------------------------------------------------------------------------------------%>
<script>
    function doSave(){
      if(formComplete()){
        transactionForm.Action.value = 'Save';
        transactionForm.submit();
      }
    }

    function doAdd(){
      if(formComplete()){
        transactionForm.Action.value = 'Add';
        transactionForm.submit();
      }
    }

    function formComplete(){
      if(transactionForm.EditOc_key.value==""){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web&labelID=someFieldsAreEmpty";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("Web","someFieldsAreEmpty",sWebLanguage)%>");

        transactionForm.EditOc_key.focus();
        return false;
      }

      return true;
    }

    function doShow(key){
      transactionForm.EditOc_key.value = key;
      transactionForm.Action.value = 'Show';
      transactionForm.submit();
    }

  function doSearch(){
    var today = new Date();
    var params = 'FindKey=' + document.getElementsByName('FindKey')[0].value
            +"&FindValue="+ document.getElementsByName('FindValue')[0].value;
    var url= '<c:url value="/system/manageConfigFind.jsp"/>?ts=' + today;
    new Ajax.Request(url,{
            method: "GET",
            parameters: params,
            onSuccess: function(resp){
                $('divFindRecords').innerHTML = resp.responseText;
            },
            onFailure: function(){
            }
        }
    );
  }

  function doNew(){
    transactionForm.Action.value = 'New';
    transactionForm.submit();
  }

  function clearFindFields(){
    transactionForm.FindKey.value = "";
    transactionForm.FindValue.value = "";
    transactionForm.FindKey.focus();
  }

  function doBack(){
    window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
  }

  transactionForm.EditOc_key.focus();
</script>

<%-- ALERT ---------------------------------------------------------------------------------------%>
<%
    if(keyAllreadyExists){
        %>
          <script>
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelValue=<%=msg%>";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=msg%>");
          </script>
        <%
    }
%>