<%@page import="java.util.Vector,
                java.util.StringTokenizer,
                java.util.regex.*,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>

<script type="text/javascript" src="../_common/_script/scriptaculous.js"></script>
<script type="text/javascript" src="../_common/_script/unittest.js"></script>
<script type="text/javascript" src="../_common/_script/sorttable.js"></script>

<form name="transactionForm" method="POST">
    <%=writeTableHeader("Web.manage","ManageAutoCompletion",sWebLanguage," doBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- DESTINATION ITEM --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","user",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="userID" value="">
                <input TYPE='TEXT' NAME='userName' size='35px' class="text" onchange='setUserItemsValues();'>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchUser('userName','userID');">
                <br/><br/>
            </td>
        </tr>
        
        <%-- All AVAILABLE TYPE ITEMS --%>
        <tr>
            <td class="admin"><%=getTran("Web.manage","ItemTypes",sWebLanguage)%>
            </td>

            <td class="admin2">
                <select class="text" name="allItemsAvailable">
                    <%
                        //*********  SET ALL AVAILABLE ITEMS TYPES ************//
                        List typeItems = MedwanQuery.getInstance().getAllAutocompleteTypeItems();
                        Iterator it = typeItems.iterator();
                        while(it.hasNext()){
                            String[] s = setTypeToShort((String) it.next());
                            out.write("\n<OPTION value='"+s[1]+"'>"+s[0]+"</OPTION>");
                        }
                    %>
                </select>
                <br/>

                <div id="ALLITEMTYPES" style="visibility:hidden;">
                    <a href='#'
                       onclick="addItem(transactionForm.allItemsAvailable.value,transactionForm.userID.value);">
                        <img src='<%=sCONTEXTPATH%>/_img/icons/icon_add.gif'
                             alt='<%=getTranNoLink("Web","add",sWebLanguage)%>'
                            class='link'>
                        <%=getTran("Web.manage","addthisTypeinUser",sWebLanguage)%>
                    </a><br>
                    <a href='#' onclick="addItem('',transactionForm.userID.value);">
                        <img src='<%=sCONTEXTPATH%>/_img/icons/icon_add.gif'
                             alt='<%=getTranNoLink("Web","add",sWebLanguage)%>'
                            class='link'>
                        <%=getTran("Web.manage","addAllTypesinUser",sWebLanguage)%>
                    </a>
                </div>
                <br/>
            </td>
        </tr>

        <%-- SELECTED TYPE ITEMS --%>
        <tr id="SELECTEDTYPEITEMS" style="visibility:hidden;">
            <td class="admin"><%=getTran("Web.manage","selectedItems",sWebLanguage)%>
            </td>

            <td class="admin2">
                <div id="selectedItemsTypes"></div>
                <a href='#' onclick="delValue(transactionForm.itemTypeSelect.value,'',transactionForm.userID.value);">
                    <img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' class='link'><%=getTran("Web.manage","deletethisTypeFromUser",sWebLanguage)%>
                </a>
                <br/>
            </td>
        </tr>

        <tr id="VALUES" style="visibility:hidden;">
            <td class="admin"><%=getTran("Web.manage","itemValues",sWebLanguage)%></td>
            <td class="admin2">
                <div id="ItemsValuesByType"></div>
            </td>
        </tr>
    </table>
</form>

<script>
  var onPlaceEditor = function onPlaceEditor(div,page,external){
    new Ajax.InPlaceEditor($(div),page,{
      okButton: true,
      okText:'<%=getTranNoLink("Web","save",sWebLanguage)%>',
      cancelText:'<%=getTranNoLink("Web","back",sWebLanguage)%>',
      okLink: false,
      cancelButton: true,
      cancelLink: false,
      cols:40,
      rows:2,
      externalControl: external,
      ajaxOptions: {method:'post'},
      callback: function(form,value){
        if(value.length > 255){
          value = value.substr(0,255);
        }
        return 'Itemvalue='+value;
      }
    });
  }

  function addItem(item,user){
    if(item!=""){
      ajaxChangeSearchResults('_common/search/searchByAjax/addOrDelAutocompletionItems.jsp',transactionForm,"&ItemSearchingHidden="+item+"&addOrDeleteItem=add","ItemsValuesByType");
    }
    else{
      ajaxChangeSearchResults('_common/search/searchByAjax/addOrDelAutocompletionItems.jsp',transactionForm,"&addOrDeleteItem=addAll&addOrDeleteItem=add","ItemsValuesByType");
    }
  }

  function delValue(itemType,itemid,user){
    if(itemid==""){
      if(yesnoDialog("web","areYouSureToDelete")){
        ajaxChangeSearchResults('_common/search/searchByAjax/editAutocompletionValues.jsp',transactionForm,"&itemType="+itemType+"&addOrDeleteValue=del&userID="+user,"ItemsValuesByType");
        ajaxChangeSearchResults("_common/search/searchByAjax/itemsTypesShow.jsp",transactionForm,'','selectedItemsTypes');
        ajaxChangeSearchResults("_common/search/searchByAjax/itemsTypesShow.jsp",transactionForm,"&itemTypeSelect="+itemType+"","ItemsValuesByType");
      }
    }
    else{
      if(yesnoDialog("web","areYouSureToDelete")){
        ajaxChangeSearchResults('_common/search/searchByAjax/editAutocompletionValues.jsp',transactionForm,"&addOrDeleteValue=del&itemid="+itemid,"ItemsValuesByType");
        ajaxChangeSearchResults("_common/search/searchByAjax/itemsTypesShow.jsp",transactionForm,"&itemTypeSelect="+itemType+"","ItemsValuesByType");
      }
    }
  }

  function ajaxChangeSearchResults(urlForm,SearchForm,moreParams,div){
    document.getElementById(div).innerHTML = "<div style='text-align:center'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..</div>";
    var url = urlForm;
    var params = Form.serialize(SearchForm)+moreParams;

    var myAjax = new Ajax.Updater(div,url,{
      evalScripts:true,
      method: 'post',
      postBody: params,
      onFailure:function() {
        $(div).innerHTML = "Problem with ajax request !!";
      }
    });
  }
    
  function setUserItemsValues(){
    $("SELECTEDTYPEITEMS").style.visibility = "visible";
    $("ALLITEMTYPES").style.visibility = "visible";
    $("ItemsValuesByType").innerHTML = "";
    ajaxChangeSearchResults("_common/search/searchByAjax/itemsTypesShow.jsp",transactionForm,"","selectedItemsTypes");
  }
  
  <%-- popup : search authorized user --%>
  function searchUser(userName,userID){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+userID+"&ReturnName="+userName+"&displayImmatNew=no");
  }
    
  function getValuesByItemTypeAndUser(thi){
    $("VALUES").style.visibility = "visible";
    ajaxChangeSearchResults("_common/search/searchByAjax/itemsTypesShow.jsp",transactionForm,"&itemTypeSelect="+thi.options[thi.selectedIndex].value,"ItemsValuesByType")
  }
</script>