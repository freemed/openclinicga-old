<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindMealName = checkString(request.getParameter("FindMealName"));

    boolean bWithSearchFields = (checkString(request.getParameter("withSearchFields")).length() > 0),
            bToMakeProfile    = (checkString(request.getParameter("toMakeProfile")).length() > 0);

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************************ meals/ajax/getMeals.jsp **********************");
		Debug.println("sFindMealName     : "+sFindMealName);
		Debug.println("bWithSearchFields : "+bWithSearchFields);
		Debug.println("bToMakeProfile    : "+bToMakeProfile+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
    Meal meal = new Meal();
    meal.name = sFindMealName;
    List lMeals = Meal.getList(meal);
    
    if(bWithSearchFields){
        %>
		<div id="mealsSearchDiv" style="width:520px"> 
			<%-- MEAL NAME --%>
			<table class="list" width="100%" cellpadding="1" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchMealsWindow();return false;}">
			    <tr>
			        <td class="admin" width="100"><%=getTran("meals","mealName",sWebLanguage)%></td>
			        <td class="admin2">
			            <input type="text" class="text" name="FindMealName" id="FindMealNameWindow" size="30" value="<%=sFindMealName%>" maxLength="100">&nbsp;&nbsp;
			          
			            <%-- BUTTONS --%>
			            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchMealsWindow(true);">
			            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="document.getElementById('FindMealNameWindow').value='';document.getElementById('FindMealNameWindow').focus();">			      
			        </td>
			    </tr>
			</table>
			<br>
			
		    <script>setTimeout("if(document.getElementById('FindMealNameWindow')) document.getElementById('FindMealNameWindow').focus()",200);</script>
			
			<%-- SEARCH RESULTS --%>
			<%
			    if(lMeals.size() > 0){
			        %>
					<table width="100%" id="searchresultsMeals" class="sortable" cellspacing="0">
					    <%-- HEADER --%>
					    <tr class="gray">
					        <td><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
					        <td><%=HTMLEntities.htmlentities(getTran("meals","ingredients",sWebLanguage))%></td>
					    </tr>
					    
				        <tbody class="hand">
					    <%
					        Iterator iter = lMeals.iterator();
					        int i = 0;
					        while(iter.hasNext()){
					        	meal = (Meal)iter.next();
					            
					            out.write("<tr class='list"+(i%2==0?"":"1")+"'>");
					            if(bToMakeProfile){
					                out.write("<td onclick='insertMeal(\""+meal.getUid()+"\",\""+HTMLEntities.htmlentities(meal.name)+"\","+meal.mealDatetime.getHours()+","+meal.mealDatetime.getMinutes()+")'>"+HTMLEntities.htmlentities(meal.name)+"</td>");
					            }
					            else{
					                out.write("<td onclick='getPatientMeal(\""+meal.getUid()+"\",null,null)'>"+HTMLEntities.htmlentities(meal.name)+"</td>");
					            }

					             out.write("<td>"+meal.mealItems.size()+"</td>");
					            out.write("</tr>");
					            
					            i++;
					        }
					    %>
					    </tbody>
					</table>
	
					<%=lMeals.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%><br><br>
                    <script>ts_makeSortable(document.getElementById("searchresultsMeals"));</script>	
			        <%
			    }
		    	else{
		    	    %><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
		    	}
		
		  		if(bWithSearchFields){
		      		%>
		          		<input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="openBackProfile();">
		          		<script>Modalbox.resizeToContent();</script>
				    <%
				}
			%>
		</div>
		<%
	}
    else{
    	if(lMeals.size() > 0){
	    	%>    
			<div id="mealsSearchDiv" style="width:100%"> 
				<table width="100%" id="searchresultsMeals" class="sortable" cellspacing="0">
				    <%-- HEADER --%>
				    <tr class="gray">
				        <td width="25">&nbsp;</td>
				        <td width="200"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
					    <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","ingredients",sWebLanguage))%></td>
				    </tr>
				    
				    <tbody class="hand">
				    <%
				        Iterator iter = lMeals.iterator();
				        int i = 0;
				        while(iter.hasNext()){
				        	meal = (Meal)iter.next();
				            
				            out.write("<tr class='list"+(i%2==0?"":"1")+"'>");
				             out.write("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick=\"deleteMeal('"+meal.getUid()+"');\"></td>");
				             out.write("<td onclick='openMeal(\""+meal.getUid()+"\")'>"+HTMLEntities.htmlentities(meal.name)+"</td>");
 				             out.write("<td onclick='openMeal(\""+meal.getUid()+"\")'>"+meal.mealItems.size()+"</td>");
				            out.write("</tr>");
				           
				            i++;
				        }
				    %>
				    </tbody>
				</table>

				<%
    				if(bWithSearchFields){
        				%>
            				<input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","back",sWebLanguage))%>" onclick="openBackProfile();">
            				<script>Modalbox.resizeToContent();</script>
				        <%
					}
				%>
			</div>
			<%
		
        	out.write(lMeals.size()+" "+HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage)));
            %><script>ts_makeSortable(document.getElementById("searchresultsMeals"));</script><%	
    	}
    	else{
    	    %><%=HTMLEntities.htmlentities(getTran("web","noRecordsFound",sWebLanguage))%><%
    	}
    }
%>