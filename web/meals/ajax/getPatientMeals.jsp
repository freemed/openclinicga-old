<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindMealByDay = checkString(request.getParameter("FindMealByDay"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).length() > 0;

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************* meals/ajax/getPatientMeals.jsp *******************");
		Debug.println("sFindMealByDay : "+sFindMealByDay);
		Debug.println("bWithSearch    : "+bWithSearch+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
    List lMeals = Meal.getPatientMeals(activePatient,sFindMealByDay,null);
    
    if(lMeals.size() > 0){
        %>
		<table width="100%" cellspacing="1" cellpadding="1" class="sortable" id="patientmeals">
		    <%-- HEADER --%>
		    <tr class="gray">
		        <td width="30">&nbsp;</td>
		        <td width="80"><%=HTMLEntities.htmlentities(getTran("meals","mealTaken",sWebLanguage))%></td>
		        <td width="80"><%=HTMLEntities.htmlentities(getTran("meals","mealTime",sWebLanguage))%></td>
		        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","mealName",sWebLanguage))%></td>
		    </tr>
		        
		    <%
		        Iterator iter = lMeals.iterator();
    		    Meal item = null;
		        int i = 0;
		        
		        while(iter.hasNext()){
		            item = (Meal)iter.next();
		            
		            out.write("<tr id='patientmeal_"+item.getUid()+"' class='list"+(i%2==0?"":"1")+"' style='cursor:hand;'>");
		             out.write("<td>"+
		                        "<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+(HTMLEntities.htmlentities(getTran("web","delete",sWebLanguage)))+"' onclick=\"deleteMealFromPatient('"+item.patientMealUid+"');\">"+
		                       "</td>");
		             
		            out.write("<td>");        		            
		            if(item.taken){
		                out.write("<img src='"+sCONTEXTPATH+"/_img/themes/default/check.gif' class='link' title='"+(HTMLEntities.htmlentities(getTran("meals","mealTaken",sWebLanguage)))+"' onclick=\"setMealTaken('"+item.patientMealUid+"','');\">");
		            }
		            else{
		                out.write("<img src='"+sCONTEXTPATH+"/_img/themes/default/uncheck.gif' class='link' title='"+(HTMLEntities.htmlentities(getTran("meals","mealNotTaken",sWebLanguage)))+"' onclick=\"setMealTaken('"+item.patientMealUid+"','ok');\">");
		            }
		            out.write("</td>");
		            
		             out.write("<td onclick='getPatientMeal(\""+item.getUid()+"\",true,\""+item.patientMealUid+"\")'><b>"+HTMLEntities.htmlentities(new SimpleDateFormat("HH:mm").format(item.mealDatetime))+"</b></td>");
		             out.write("<td onclick='getPatientMeal(\""+item.getUid()+"\",true,\""+item.patientMealUid+"\")'>"+HTMLEntities.htmlentities(item.name)+"</td>");
		            out.write("</tr>");
		            
		            i++;
		        }
		    %>
		</table>
        <%
    }

    if(lMeals.size() > 0){
    	%><script>ts_makeSortable(document.getElementById("patientmeals"));</script><%
    	%><script>$("mealNutricientsButton").disabled = false;</script><%
    	%><%=lMeals.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage))%><%
    }
    else{
    	%><script>$("mealNutricientsButton").disabled = true;</script><%
    	%><%=HTMLEntities.htmlentities(getTran("web","noRecordsFound",sWebLanguage))%><%
    }
%>