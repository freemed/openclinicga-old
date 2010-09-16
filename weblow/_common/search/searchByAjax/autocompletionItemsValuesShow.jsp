<%@ page import="   java.util.*, be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
    String sTestValues = checkString(request.getParameter("testValue"));
    String sItemValue = checkString(request.getParameter("itemValue"));
    String sItemType = checkString(request.getParameter("item"));
    int sUserId = Integer.parseInt(activeUser.userid);
    MedwanQuery medwanQuery = MedwanQuery.getInstance();

    /**************** IF SET AUTOCOMPLETION *************/
    //**** sTestValues IS A BOOLEAN TO SEE IF TEST VALUE OF ONLY SEE VALUE ****//

    if (sTestValues.equals("")) {
        out.write("<ul id=\"autocompletion\">");
        /******** if search autocomplements values *********************************/
        Vector itemsValues = medwanQuery.getValuesByTypeItemByUser("%" + sItemType + "%", sUserId, sItemValue);
        Iterator it = itemsValues.iterator();
        while (it.hasNext()) {
            Vector itemValue = (Vector) it.next();

            String value = (String) itemValue.elementAt(1);

            if (!value.equals("")) {
                out.write("<li>" + HTMLEntities.htmlentities(value) + "</li>");
            }
        }
    } else {
        //********* SPLIT VALUES STRING TO GET INDEPENDENT VALUES ****//
        String[] itemValues = sItemValue.split(";");
        for (int i = 0; i < itemValues.length; i++) {
            /********* IF TEST AND ADD VALUE AND AUTOINCREMENT OF THE COUNTER *****/
            /********* Test if Value exists ********************************************/
            Vector itemsValues = medwanQuery.getValuesByTypeItemByUser(sItemType, sUserId, itemValues[i]);

            if (itemsValues.size() < 1) {
                //****** if not exists -> set values with user ************************* /
                medwanQuery.setAutocompletionItemsValues(sItemType, itemValues[i], sUserId, 0);
                out.print("not exist");
            } else {
                //******** if exists -> increment the counter ******************************/
                Iterator it = itemsValues.iterator();
                while (it.hasNext()) {
                    Vector itemValue = (Vector) it.next();
                    Integer itemid = (Integer) itemValue.elementAt(0);
                    String value = (String) itemValue.elementAt(1);
                    Integer counter = (Integer) itemValue.elementAt(2);
                    if (!value.equals("")) {
                        out.print("exist = " + counter);
                        /********** autoincrement counter value ***********************************/
                        medwanQuery.setAutocompletionCounterValues(itemid.intValue(), counter.intValue() + 1);
                    }
                }

            }
        }
    }

%>
