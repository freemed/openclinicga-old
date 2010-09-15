<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sMeals = checkString(request.getParameter("meals"));
    Map finalList = new LinkedHashMap();
    Meal meal = null;
    String[] meals = sMeals.split("\\,");
    for(int i=0;i<meals.length;i++){
        meal = new Meal(meals[i]);
        meal = Meal.get(meal);
        if (meal.mealItems.size() > 0) {

            MealItem mealitem = null;
            Iterator it = meal.mealItems.iterator();
            while (it.hasNext()){

                mealitem = (MealItem)it.next();
                Iterator it2 = MealItem.get(mealitem).nutricientItems.iterator();
                while (it2.hasNext()) {
                    NutricientItem nutricient = (NutricientItem) it2.next();
                    if (finalList.keySet().contains(nutricient.name + "$" + nutricient.unit)) {
                        float tmp = ((Float) finalList.get(nutricient.name + "$" + nutricient.unit)).floatValue();
                        finalList.put(nutricient.name + "$" + nutricient.unit, Float.valueOf( tmp + (nutricient.quantity * mealitem.quantity)));
                    } else {
                        finalList.put(nutricient.name + "$" + nutricient.unit, Float.valueOf((nutricient.quantity * mealitem.quantity)));
                    }
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
    if(Modalbox.initialized)Modalbox.resizeToContent();
</script>
