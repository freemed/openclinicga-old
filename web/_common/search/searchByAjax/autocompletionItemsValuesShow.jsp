<%@ page import="   java.util.*, be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
    String sTestValues = checkString(request.getParameter("testValue"));
    String sItemValue = checkString(request.getParameter("itemValue"));
    String sItemType = checkString(request.getParameter("item"));
    int sUserId = Integer.parseInt(activeUser.userid);
    MedwanQuery medwanQuery = MedwanQuery.getInstance();

    if (sTestValues.equals("")) {
        out.write("<ul id=\"autocompletion\">");
        Vector itemsValues = medwanQuery.getValuesByTypeItemByUser("%" + sItemType + "%", sUserId, sItemValue);
        Iterator it = itemsValues.iterator();
        while (it.hasNext()) {
            Vector itemValue = (Vector) it.next();

            String value = (String) itemValue.elementAt(1);

            if (!value.equals("")) {
                out.write("<li>" + HTMLEntities.htmlentities(value) + "</li>");
            }
        }
    }
    else {
        String[] itemValues = sItemValue.split(";");
        for (int i = 0; i < itemValues.length; i++) {
            Vector itemsValues = medwanQuery.getValuesByTypeItemByUser(sItemType, sUserId, itemValues[i]);

            if (itemsValues.size() < 1) {
                medwanQuery.setAutocompletionItemsValues(sItemType, itemValues[i], sUserId, 0);
                out.print("not exist");
            } 
            else {
                Iterator it = itemsValues.iterator();
                while (it.hasNext()) {
                    Vector itemValue = (Vector) it.next();
                    Integer itemid = (Integer) itemValue.elementAt(0);
                    String value = (String) itemValue.elementAt(1);
                    Integer counter = (Integer) itemValue.elementAt(2);
                    if (!value.equals("")) {
                        out.print("exist = " + counter);
                        medwanQuery.setAutocompletionCounterValues(itemid.intValue(), counter.intValue() + 1);
                    }
                }
            }
        }
    }

%>
