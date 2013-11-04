<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sItems = checkString(request.getParameter("items"));
    Map finalList = new LinkedHashMap();
    List l = new LinkedList();
    if (sItems.trim().length() > 0) {
        List mealItems = new LinkedList();
        String[] mealitems = sItems.split(",");
        MealItem mealitem = null;
        for (int i = 0; i < mealitems.length; i++) {
            String[] values = mealitems[i].split("-");
            mealitem = new MealItem(values[0]);
            mealitem.quantity = Float.parseFloat(values[1].replace(",","."));
            Iterator it = MealItem.get(mealitem).nutricientItems.iterator();
            while (it.hasNext()) {
                NutricientItem nutricient = (NutricientItem) it.next();
                if (finalList.keySet().contains(nutricient.name + "$" + nutricient.unit)) {
                	float tmp = ((Float) finalList.get(nutricient.name + "$" + nutricient.unit)).floatValue();
                    finalList.put(nutricient.name + "$" + nutricient.unit, Float.valueOf( tmp + (nutricient.quantity * mealitem.quantity)));

                } else {
                    finalList.put(nutricient.name + "$" + nutricient.unit, Float.valueOf((nutricient.quantity * mealitem.quantity)));
                }
            }
        }
    }
    Iterator it = finalList.keySet().iterator();
    int i = 3;
    while (it.hasNext()) {
        String s = (String) it.next();
        if (i > 9) i = 1;
        out.write("<li class='color" + i + "'><div style='width:210px;padding-left:10px'>" + s.split("\\$")[0] + "</div><div style='width:80px;padding-left:10px'>" + finalList.get(s) + "</div><div style='width:50px'>" + s.split("\\$")[1] + "</div></li>");
        i++;
    }%>
<script>
    Modalbox.resizeToContent();
</script>
