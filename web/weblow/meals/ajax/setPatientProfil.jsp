<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.MealProfil" %>
<%@ page import="be.mxs.common.util.io.messync.Helper" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("action"));
    String sMealProfileId = checkString(request.getParameter("mealProfileId"));
    String sChoosedDate = checkString(request.getParameter("choosedDate"));
    MealProfil profil = new MealProfil(sMealProfileId);
    if (sAction.equals("save")) {
        List l = profil.getMealProfil();
        Iterator it = l.iterator();
        while (it.hasNext()) {
            profil = (MealProfil) it.next();
            Calendar c = GregorianCalendar.getInstance();
            c.setTime(ScreenHelper.getSQLDate(sChoosedDate));
            Calendar c2 = GregorianCalendar.getInstance();
            c2.setTime(profil.mealDatetime);
            c2.set(c.get(Calendar.YEAR), c.get(Calendar.MONTH), c.get(Calendar.DATE));
            profil.mealDatetime = c2.getTime();
        }
        new Meal().insertPatientProfil(l, activePatient, activeUser.userid);
        out.write("<script>closeModalbox();refreshPatientMeals();</script>");
    }
%>
