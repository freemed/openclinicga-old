<%@ page import="   java.util.*" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<% String sAction = checkString(request.getParameter("addOrDeleteItem"));
    String sItemType = checkString(request.getParameter("ItemSearchingHidden")).toUpperCase();

    int sUserId = 0;
    if (!checkString(request.getParameter("userID")).equals("")) {
        sUserId = Integer.parseInt(checkString(request.getParameter("userID")));
    }
    int sItemId = 0;
    if (!checkString(request.getParameter("itemid")).equals("")) {

        sItemId = Integer.parseInt(checkString(request.getParameter("itemid")));
    }
    MedwanQuery medwanQuery = MedwanQuery.getInstance();
    if (sAction.equals("del")) {

        /*********************************** delete items types ******************************/
        medwanQuery.delAutocompletionItems(sItemType);
        Vector vResults;
        vResults = User.searchUsers("", ""); //get all users
        Iterator it = vResults.iterator();
        while (it.hasNext()) {
            Hashtable userId = (Hashtable) it.next();
            // delete values from users
            medwanQuery.delAutocompletionItemsValues(0, sItemType, Integer.parseInt(userId.get("userid").toString()));

        }
    } else if (sAction.equals("add")) {
        /************************************** add items types *******************************/
        medwanQuery.setAutocompletionItems(sItemType);
        Vector vResults = new Vector();
        /******* TEST IF ONLY ONE USER SEARCHING***********************/
        boolean exists = false;
        if (sUserId == 0) {
            vResults = User.searchUsers("", "");  //get all users
        } else {
            //******** test if item not exists in user *****/
            List itemsTypes = medwanQuery.getAllAutocompleteTypeItemsByUser(sUserId);
            Iterator it = itemsTypes.iterator();
            while (it.hasNext()) {
                if (it.next().equals(sItemType)) {
                    exists = true;
                }
            }
            if (!exists) {
                Hashtable user = new Hashtable();
                user.put("userid", new Integer(sUserId));
                vResults.add(user);
                // write javascriptscript for updating
                out.write("<script>var getValues = ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm,'' , 'selectedItemsTypes');</script>");
            }
        }

        /*********************** ********************/
        Iterator it = vResults.iterator();
        while (it.hasNext()) {

            Hashtable userId = (Hashtable) it.next();
            List l = medwanQuery.getItemsValuesByType(sItemType); //get all values
            Iterator it2 = l.iterator();
            while (it2.hasNext()) {
                String value = (String) it2.next();
                //test if exists
                Vector temp = medwanQuery.getValuesByTypeItemByUser(sItemType, Integer.parseInt(userId.get("userid").toString()), "");
                exists = temp.size() > 0;
                //set values with users
                if (!exists) {
                    //********* if value not exist in user then insert ***********/
                    medwanQuery.setAutocompletionItemsValues(sItemType, value, Integer.parseInt(userId.get("userid").toString()), 0);
                }
            }
            //**************  if value not exists then set void value *******/
            if (l.size() < 1) {
                medwanQuery.setAutocompletionItemsValues(sItemType, "", sUserId, 0);
            }

        }
    } else if (sAction.equals("addAll")) {
        //********************************* add all autocomplement types in user *********************//
        if (sUserId > 0) {
            //********* get autocomplete itemTypes ********************//
            List itemTypes = medwanQuery.getAllAutocompleteTypeItems();
            Iterator it = itemTypes.iterator();
            while (it.hasNext()) {
                String itemType = (String) it.next();
                //******** test if item not exists in user *****/
                List testItemTypes = medwanQuery.getValuesByTypeItemByUser(itemType, sUserId, "%");
                if (testItemTypes.size() < 1) {
                    ///********  NOT EXISTS THEN PUT ITEMTYPE IN USER **********//
                    medwanQuery.setAutocompletionItemsValues(itemType, "", sUserId, 0);
                }
            }
            out.write("<script>var getValues = ajaxChangeSearchResults('_common/search/searchByAjax/itemsTypesShow.jsp', transactionForm,'' , 'selectedItemsTypes');</script>");
        }
    }
%>


