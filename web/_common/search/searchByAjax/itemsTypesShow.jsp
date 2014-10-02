<%@ page import="   java.util.*, be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%

    String sItemTypeSelect = HTMLEntities.htmlentities(checkString(request.getParameter("itemTypeSelect")));
    String sItemTypes = HTMLEntities.htmlentities(checkString(request.getParameter("ItemSearching")));
    int sUserId = 0;
    if (!checkString(request.getParameter("userID")).equals("")) {
        sUserId = Integer.parseInt(checkString(request.getParameter("userID")));
    }
    MedwanQuery medwanQuery = MedwanQuery.getInstance();
    boolean hasMoreResults;

    /**************   SHOW TYPE ITEMS FOR AUTOCOMPLETION SEARCH **********************************/

    if (!sItemTypes.equals("") && !sItemTypes.equals("UNDEFINED") && !sItemTypes.equals("undefined")) {

        out.write("<ul id=\"autocompletion\">");
        int iMaxRows = medwanQuery.getConfigInt("MaxSearchFieldsRows", 30);
        List lResults = medwanQuery.getAllItemsTypesByLetters(sItemTypes, iMaxRows);
        hasMoreResults = lResults.size() >= iMaxRows;
        if (lResults.size() > 0) {
            Iterator it = lResults.iterator();

            while (it.hasNext()) {
                String type = (String) it.next();
                String typeSpan = type;
                String[] s = setTypeToShort(type);
                type = s[0];
                String newSItem = new String("<b>" + sItemTypes + "</b>");
                type = type.replaceAll(sItemTypes, newSItem);
                if (!sItemTypes.equals("")) {
                    out.write("\n<li>");
                    // String e = person.firstname;
                    out.write(HTMLEntities.htmlentities(type));
                    out.write("<span class='informal' style='display:none'>" + typeSpan + "</span>");
                    out.write("</li>");
                }
            }
        }
        out.write("</ul>");
%>
<%
        if (hasMoreResults) {
            out.write("</ul><ul id='autocompletion'><li>....</li>");
        }

    } else if (sUserId == 0) {

        /******************* SHOW AUTOCOMPLETION TYPE ITEMS FROM AUTOCOMPLETEITEMS TABLE ************************/

        out.write("<br /><ul id=\"autocompletion\" >");
        StringBuffer s = new StringBuffer();
        List list = medwanQuery.getAllAutocompleteTypeItems();
        Iterator it = list.iterator();
        while (it.hasNext()) {
            String itemType = (String) it.next();
            s.append("<li id='Items'>")
                    .append("<a href='#' onclick='delItem(\"" + itemType + "\")'>")
                    .append("<img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt=" + getTranNoLink("Web", "delete", sWebLanguage) + "' class='link'>")
                    .append("</a>")
                    .append(itemType + "</li>");
        }
        out.write(s.toString());
        out.write("</ul><br />");

    } else if (!sItemTypeSelect.equals("")) {

        /******************** SHOW ITEMS VALUES BY TYPE AND USER ********************/

        out.write("\n<br /><ul id=\"autocompletion\">");
        out.write("\n<li><a href='#' id='newTypeButton'> <img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTranNoLink("Web", "edit", sWebLanguage) + "' border='0'></a>&nbsp;&nbsp;<span id='newItemField'>" + getTran("Web.manage", "addNewValue", sWebLanguage) + "</span> </li><br />");
        Vector itemsValues = medwanQuery.getValuesByTypeItemByUser(sItemTypeSelect, sUserId, "%");
        int i = 0;
        Iterator it = itemsValues.iterator();
        while (it.hasNext()) {
            Vector v = (Vector) it.next();
            Integer itemid = (Integer) v.elementAt(0);
            String value = (String) v.elementAt(1);
            Integer counter = (Integer) v.elementAt(2);

            if (!value.equals("")) {
                out.write("\n<li>");
                out.write("<a href='#' onclick=\"delValue('','" + itemid + "' );\" ><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTranNoLink("Web", "delete", sWebLanguage) + "' class='link' /></a> ");
                //out.write(" <img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' alt='"+getTranNoLink("Web","edit",sWebLanguage)+"' border='0'> ");
                out.write("&nbsp;&nbsp;<b><span  id='" + i + "_editCount'>" + counter + "</span></b>");
                out.write("&nbsp;&nbsp;<span  id='" + i + "_edit'>" + value + "</span>");
                out.write("</li>");
            }
            i++;
        }
        out.write("\n</ul><br />");

        /********************* SET JAVASCRIPT FOR INPLACEEDITOR FIELDS **********************/

        out.write("\n<script>");
        out.write("onPlaceEditor('newItemField','_common/search/searchByAjax/editAutocompletionValues.jsp?&itemType=" + sItemTypeSelect + "&userID=" + sUserId + "','newTypeButton');");
        it = itemsValues.iterator();
        i = 0;
        while (it.hasNext()) {
            Vector v = (Vector) it.next();
            Integer itemid = (Integer) v.elementAt(0);
            String value = (String) v.elementAt(1);
            Integer counter = (Integer) v.elementAt(2);
            if (!value.equals("")) {
                out.write("onPlaceEditor('" + i + "_edit','_common/search/searchByAjax/editAutocompletionValues.jsp?&itemType=" + sItemTypeSelect + "&itemid=" + itemid + "&addOrDeleteValue=edit&counterValue=" + counter + "&userID=" + sUserId + "','');");
                out.write("onPlaceEditor('" + i + "_editCount','_common/search/searchByAjax/editAutocompletionValues.jsp?&editCounter=1&itemid=" + itemid + "&addOrDeleteValue=edit&counterValue=" + counter + "','');");
            }
            i++;
        }
        out.write("\n</script>");
    } else {

        /******************* SHOW AUTOCOMPLETION TYPE ITEMS BY USER ************************/

        out.write("<br /><SELECT class=\"text\"  name=\"itemTypeSelect\" onchange=\"getValuesByItemTypeAndUser(this)\">");
        out.write("<OPTION selected='selected'>----</OPTION>");
        List itemsTypes = medwanQuery.getAllAutocompleteTypeItemsByUser(sUserId);
        Iterator it = itemsTypes.iterator();
        while (it.hasNext()) {
            String[] s = setTypeToShort((String) it.next());
            out.write("<OPTION value='" + s[1] + "'>" + s[0] + "</OPTION>");
        }
        out.write("</SELECT>");
    }
%>
