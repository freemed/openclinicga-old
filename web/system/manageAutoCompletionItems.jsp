<%@ page import="java.util.Vector,
                 java.util.StringTokenizer,
                 java.util.*" %>
<%@ include file="/includes/validateUser.jsp" %>

<%=checkPermission("system.management", "all", activeUser)%>


<script type="text/javascript" src="../_common/_script/scriptaculous/scriptaculous.js"></script>
<script type="text/javascript" src="../_common/_script/unittest.js"></script>
<script type="text/javascript" src="../_common/_script/sorttable.js"></script>

<form name="transactionForm" method="POST">

    <%=writeTableHeader("Web.manage", "ManageAutoCompletion", sWebLanguage, " doBack();")%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DESTINATION ITEM --%>
        <tr>

            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage", "TypeItemsSearch", sWebLanguage)%>
            </td>

            <td class="admin2">

                <input id="ac" autocomplete="off" TYPE='TEXT'
                       style='text-transform:uppercase' NAME='ItemSearching' size='100%' class="text">

                <div id="acUpdate" style="display: none;border: 1px solid black;background-color: white; "></div>
            </td>
        </tr>
        <tr>
            <td class="admin" nowrap><%=getTran("Web", "AutocompletionTypeItems", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <div id="allItemsTypes">
                </div>
            </td>
        </tr>
    </table>


</form>
<script>

    ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm);
    new Ajax.Autocompleter('ac',
            'acUpdate',
            '_common/search/searchByAjax/itemsTypesShow.jsp',
    {
        method: 'post',
        afterUpdateElement: ac_return
    });

    function ac_return(field, item) {
        ///************  GET ITEM ID FROM AUTOCOMPLETE FIELD ***********/
        var re1 = '(<span).*';
        // Tag 1
        var re2 = '(>)';
        // Tag 1
        var re3 = '(.*)';
        // Non-greedy match on filler
        var re4 = '(<\\/span>)';
        // Tag 2
        var p = new RegExp(re1 + re2 + re3 + re4, ["i"]);
        var m = p.exec(item.innerHTML);
        if (m.length > 0)
        {
            var word = m[3];
            addItem(word);
        }
        ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm, "", "allItemsTypes");
    }
    function addItem(Item) {
        //******* ADD ITEM TYPE TO ALL USERS **************//
        ajaxChangeSearchResults('_common/search/searchByAjax/addOrDelAutocompletionItems.jsp', transactionForm, "&addOrDeleteItem=add&ItemSearchingHidden=" + Item);
        ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm);
    }
    function delItem(Item) {
        //******* DELETE ITEM TYPE FROM ALL USERS ************//
        var Check = confirm("Voulez vous vraiment supprimer : " + Item + " ?");
        if (Check == true) {
            ajaxChangeSearchResults('_common/search/searchByAjax/addOrDelAutocompletionItems.jsp', transactionForm, "&addOrDeleteItem=del&ItemSearchingHidden=" + Item);
            ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm);
        }
    }

    function ajaxChangeSearchResults(urlForm, SearchForm, moreParams) {
        document.getElementById('allItemsTypes').innerHTML = "<div style='text-align:center'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading</div>";
        var url = urlForm;
        var params = Form.serialize(SearchForm) + moreParams;

        var myAjax = new Ajax.Updater(
                "allItemsTypes", url,
        {
            evalScripts:true,
            method: 'post',
            parameters: params,
            onFailure:function() {
                $('allItemsTypes').innerHTML = "Problem with ajax request !!";
            }
        });
        Form.reset(transactionForm);

    }
    <%-- popup : search authorized user --%>
    function searchAuthorizedUser(userUidField, userNameField) {
        openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID=" + userUidField + "&ReturnName=" + userNameField + "&displayImmatNew=no");
    }
</script>