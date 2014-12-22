<%@ page import="java.util.Vector,java.util.StringTokenizer" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%=sJSSORTTABLE%>

<%-- TODO : Mind the fact that each occurance of 'item' actually means 'itemType' --%>
<%!
    //--- ADD SOURCE ITEM -------------------------------------------------------------------------
    private String addSourceItem(int itemTypeIdx, String itemTypeId, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass;

        // alternate row-style
        if(itemTypeIdx%2==0) sClass = "1";
        else                 sClass = "";

        // display one source item
        html.append("<tr class='list"+sClass+"' id='rowSourceItem"+itemTypeIdx+"'>")
            .append("<td width='18'>")
            .append("<a href='javascript:deleteSourceItem(rowSourceItem"+itemTypeIdx+")'>")
            .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web","delete",sWebLanguage)+"' class='link'>")
            .append("</a>")
            .append("</td>")
            .append("<td>"+itemTypeId+"</td>")
            .append("</tr>");

        return html.toString();
    }
%>

<%
    StringBuffer sourceItemsHTML = new StringBuffer(),
            sourceItemsJS = new StringBuffer();

    int sourceItemIdx = 1;
    Vector foundItemTypes;
    String msg = "";

    String sAction = checkString(request.getParameter("Action"));

    // get data from form
    String sSelectedSourceItemTypes = checkString(request.getParameter("selectedSourceItemTypes")),
            sEditDestinationItemType = checkString(request.getParameter("EditDestinationItemType"));

    /*
    // DEBUG ////////////////////////////////////////////////////////////////////////////
    Debug.println("### ACTION = " + sAction + " ####################################");
    Debug.println("# sSelectedSourceItemTypes = " + sSelectedSourceItemTypes);
    Debug.println("# sEditDestinationItemType = " + sEditDestinationItemType + "\n\n");
    /////////////////////////////////////////////////////////////////////////////////////
    */

    //--- SAVE ---------------------------------------------------------------------------------------------------------
    if (sAction.equals("Save")) {
        String sourceItemType;

        // tokenize string containing source items to save
        if (sSelectedSourceItemTypes.length() > 0) {
            sourceItemIdx = 1;

            // delete all sourceItems in the specified itemGroup
            MedwanQuery.getInstance().deleteLastItemGroup(sEditDestinationItemType);

            // add all selected sourceItems to the specified itemGroup 
            StringTokenizer idTokenizer = new StringTokenizer(sSelectedSourceItemTypes, "$");
            while (idTokenizer.hasMoreTokens()) {
                sourceItemType = idTokenizer.nextToken();
                MedwanQuery.getInstance().addSourceItemToLastItemGroup(sourceItemType, sEditDestinationItemType);
            }
        }

        sAction = "Find";
    }
    //--- DELETE -------------------------------------------------------------------------------------------------------
    if (sAction.equals("Delete")) {
        MedwanQuery.getInstance().deleteLastItemGroup(sEditDestinationItemType);
        msg = getTran("web.manage", "lastitemgroupdeleted", sWebLanguage);
        sAction = "Find";
    }

    //--- FIND (sourceItems belonging to selected destination item) ----------------------------------------------------
    if (sAction.equals("Find")) {
        foundItemTypes = MedwanQuery.getInstance().getItemTypesInItemTypeGroup(sEditDestinationItemType);
        String sourceItemType;

        for (int i = 0; i < foundItemTypes.size(); i++) {
            sourceItemType = (String) foundItemTypes.get(i);
            sourceItemIdx++;

            sourceItemsJS.append("rowSourceItem" + sourceItemIdx + "=" + sourceItemType + "$");
            sourceItemsHTML.append(addSourceItem(sourceItemIdx, sourceItemType, sWebLanguage));
        }
    }
%>

<form name="transactionForm" method="POST" onClick="clearMessage();">
    <%=writeTableHeader("Web.manage","ManageLastItemGroups",sWebLanguage,"doBack();")%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DESTINATION ITEM --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","destinationItem",sWebLanguage)%></td>
            <td class="admin2">
                <select type="text" class="text" name="EditDestinationItemType" onChange="doSearchSourceItems();">
                    <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        Vector destinationItemTypes = MedwanQuery.getInstance().getTransactionItems();
                        String destinationItemType;
                        int prefixIdx;
                        boolean selected;
                        String prefix = "be.mxs.common.model.vo.healthrecord.IConstants.";

                        for(int i=0; i<destinationItemTypes.size(); i++){
                            destinationItemType = (String)destinationItemTypes.get(i);
                            selected = destinationItemType.equalsIgnoreCase(sEditDestinationItemType);

                            %>
                                <option value="<%=destinationItemType%>" <%=(selected?"SELECTED":"")%>>
                                    <%
                                        // do not display prefix
                                        prefixIdx = destinationItemType.indexOf("be.mxs.common.model.vo.healthrecord.IConstants.");
                                        if(prefixIdx > -1){
                                            destinationItemType = destinationItemType.substring(prefixIdx+prefix.length());
                                        }
                                    %>
                                    
                                    <%=destinationItemType%>
                                </option>
                            <%
                        }
                    %>
                </select>
            </td>
        </tr>
        <%-- SELECTED SOURCE ITEMS --%>
        <tr>
            <td class="admin" nowrap><%=getTran("Web","sourceItems",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%-- add row --%>
                <input type="hidden" name="SourceItemIdAdd">
                <select type="text" class="text" name="SourceItemTypeAdd">
                    <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        for(int i=0; i<destinationItemTypes.size(); i++){
                            destinationItemType = (String)destinationItemTypes.get(i);

                            %>
                                <option value="<%=destinationItemType%>">
                                    <%
                                        // do not display prefix
                                        prefixIdx = destinationItemType.indexOf("be.mxs.common.model.vo.healthrecord.IConstants.");
                                        if(prefixIdx > -1){
                                            destinationItemType = destinationItemType.substring(prefixIdx+prefix.length());
                                        }
                                    %>

                                    <%=destinationItemType%>
                                </option>
                            <%
                        }
                    %>
                </select>
                <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addSourceItem();">
                <br><br>
                <%-- selection --%>
                <table width="95%" cellspacing="0" cellpadding="0" class="sortable" id="tblSourceItems">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="22"/>
                        <td width="98%"><%=getTranNoLink("Web","sourceItem",sWebLanguage)%></td>
                    </tr>
                    <%
                        if(sourceItemsHTML.length() > 0){
                            %><%=sourceItemsHTML%><%
                        }
                    %>
                </table>
                <%-- display message --%>
                <span id="msgArea"><%=msg%></span>
                <br><br>
            </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">
            <input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web.manage","deleteLastItemGroup",sWebLanguage)%>" onclick="deleteDestinationItem();">
            <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <%-- HIDDEN FIELDS --%>
    <input type="hidden" name="Action" value=""/>
    <input type="hidden" name="selectedSourceItemTypes" value="<%=sSelectedSourceItemTypes%>"/>
</form>
<script>

  var selectedSourceItemsArray = new Array();

  var iSourceItemIdx = <%=sourceItemIdx%>;
  var sSourceItems = "<%=sourceItemsJS%>";

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }
          
  <%-- ADD SOURCE ITEM --%>
  function addSourceItem(){

    if(transactionForm.EditDestinationItemType.value.length > 0 &&
       transactionForm.SourceItemTypeAdd.value.length > 0){

      if(!allreadySelected(transactionForm.SourceItemTypeAdd.value)){
        iSourceItemIdx++;
        
        sSourceItems+= "rowSourceItem"+iSourceItemIdx+"="+transactionForm.SourceItemTypeAdd.value+"$";


        var row = tblSourceItems.insertRow(1);
        row.id = "rowSourceItem"+iSourceItemIdx;


        <%-- alternate row-style --%>
        if(tblSourceItems.rows.length%2==0){
          row.className = "list1";
        } else{
            row.className = "list";
        }
        var td1 = document.createElement('td');
        var td2 = document.createElement('td');

        td1.innerHTML = "<a href='javascript:deleteSourceItem(rowSourceItem"+iSourceItemIdx+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' border='0'></a>";
        td2.innerHTML = transactionForm.SourceItemTypeAdd.value;
        row.appendChild(td1);
        row.appendChild(td2);
        selectedSourceItemsArray.push(transactionForm.SourceItemTypeAdd.value);
        transactionForm.selectedSourceItemTypes.value = selectedSourceItemsArray.join("$");
          
        clearAddFields();
      }

    }
    else{ 
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectasourceitem";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","selectasourceitem",sWebLanguage)%>');

      if(transactionForm.EditDestinationItemType.value.length==0){
        transactionForm.EditDestinationItemType.focus();
      }
      else{
        transactionForm.SourceItemTypeAdd.focus();
      }
    }
  }

  <%-- ALLREADY SELECTED --%>
  function allreadySelected(sourceItemId){
      itemtypes = transactionForm.selectedSourceItemTypes.value.split("$");
      var selected = false;
      itemtypes.each(function(itemtypes){
           if(itemtypes==sourceItemId){
               selected = true;
           }
      });

      
      return selected;
  }
          
  <%-- CLEAR ADD FIELDS --%>
  function clearAddFields(){
    transactionForm.SourceItemIdAdd.value = "";
    transactionForm.SourceItemTypeAdd.value = "";
  }

  <%-- DELETE DESTINATION ITEM --%>
  function deleteDestinationItem(rowid){
      if(yesnoDeleteDialog()){
      transactionForm.Action.value = "Delete";
      transactionForm.submit();
    }
  }
          
  <%-- DELETE SOURCE ITEM --%>
  function deleteSourceItem(rowid){
      if(yesnoDeleteDialog()){

      sSourceItems = deleteRowFromArrayString(sSourceItems,rowid.id);
      initSelectedSourceItemsArray(sSourceItems);
      tblSourceItems.deleteRow(rowid.rowIndex);
      clearAddFields();   
    }
  }

  <%-- INIT SELECTED SOURCE TEMS ARRAY --%>
  function initSelectedSourceItemsArray(sArray){
    selectedSourceItemsArray = new Array();
    transactionForm.selectedSourceItemTypes.value = "";

    if(sArray != ""){
      var sOneSourceItem;
      for(var i=0; i<iSourceItemIdx-1; i++){
        sOneSourceItem = getRowFromArrayString(sArray,"rowSourceItem"+(i+2)); // deze index is normaal maar +1..
        if(sOneSourceItem != ""){
          selectedSourceItemsArray.push(sOneSourceItem);
        }
      }

      transactionForm.selectedSourceItemTypes.value = selectedSourceItemsArray.join("$");
    }
  }

  <%-- GET ROW FROM ARRAY STRING --%>
  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";

    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
      
    return row;
  }
          
  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for(var i=0;i<array.length;i++){
      if(array[i].indexOf(rowid)>-1){
        array.splice(i,1);
      }
    }

    return array.join("$");
  }

  <%-- DO SEARCH SOURCE ITEMS --%>
  function doSearchSourceItems(){
    transactionForm.Action.value = "Find";
    transactionForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp&ts=<%=getTs()%>";
  }

  <%-- DO SAVE --%>
  function doSave(){
    <%-- add selected sourceItemType before saving --%>
    if(transactionForm.SourceItemTypeAdd.value.length > 0){
      addSourceItem();
    }

    if(transactionForm.selectedSourceItemTypes.value.length == 0){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectatleastonesourceitem";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","selectatleastonesourceitem",sWebLanguage)%>');

      transactionForm.SourceItemTypeAdd.focus();
    }
    else{
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "Save";
      transactionForm.submit();
    }
  }

  <%-- UPDATE ROW STYLES --%>
  function updateRowStyles(){
    for(var i=1; i<tblSourceItems.rows.length; i++){
      tblSourceItems.rows[i].className = "list1";           
    }

    for(var i=1; i<tblSourceItems.rows.length; i++){
      if(i%2>0){
        tblSourceItems.rows[i].className = "list";
      }
    }
  }

  initSelectedSourceItemsArray(sSourceItems);
</script>